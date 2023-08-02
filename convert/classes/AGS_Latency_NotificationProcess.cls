public with sharing class AGS_Latency_NotificationProcess {
    
    public List<AGS_Case_Action_gne__c> CAlatencyFinalInsert= new List< AGS_Case_Action_gne__c>();
    public List<AGS_Case_Activity_History__c> Tasks;
    public String RecType_Task;
    public List<AGS_Case_Action_gne__c> CaseAction_TOupdate = new List<AGS_Case_Action_gne__c>();
    public List<RecordType> RecTypeNEW =new List<RecordType>([select Name, Id from RecordType where Name like 'AGS%']);
    public Map<String, RecordType> AGS_RecTypes_map;
    List<AGS_Error_Log__c> ErrorLog = new List<AGS_Error_Log__c>();
    public final String BatchId;
    
    String OwnID;
    List<User> users = new List<User>();
    String UNIXid;
    List<All_User_Hierarchy_gne__c> allUsers = new List<All_User_Hierarchy_gne__c>();
    savepoint sp;
    
    public AGS_Latency_NotificationProcess(final Id jobId) {
        BatchId = jobId;
    }
    
    public void ProcessNotification(List<AGS_Case_Action_gne__c>CAlatencyList)
    {
        sp = Database.setSavepoint();
        Datetime toDay = system.now();
        List<RecordType> ObjRecType=new List<RecordType>();
        Tasks = new List<AGS_Case_Activity_History__c>();
        RecType_Task=null;
        ObjRecType=[Select Id,name from RecordType where isActive=true and sObjectType='Task' and name='AGS Task'];
        if(ObjRecType.size()>0)
        {
            RecType_Task =ObjRecType[0].Id;
        }
        AGS_RecTypes_map= new Map<String, RecordType>();
        for(RecordType r :RecTypeNEW)
        AGS_RecTypes_map.put(r.name,r);
        try{
             for (AGS_Case_Action_gne__c LA :CAlatencyList)
             {
                    Datetime CreDnT= LA.CreatedDate;
                    Datetime RemCreD = CreDnT.addMinutes(Integer.valueOf(system.label.Action_required_remainder));  //Custom labels in Minutes for 14 days = 20160 Mins
                    Datetime OvrCreD = CreDnT.addMinutes(Integer.valueOf(system.label.Action_required_overdue));    //Custom labels in Minutes for 21 days = 30240 Mins
                    Datetime EscCreD = CreDnT.addMinutes(Integer.valueOf(system.label.Action_required_escalated));  //Custom labels in Minutes for 28 days = 40320 Mins
                    OwnID = LA.OwnerId;
                    users = [Select id,Email, name, External_id_gne__c from user where Id = :OwnID];
                    UNIXid = users[0].External_id_gne__c;
                    //Get the Active flag  and 1st  and 2nd level managers from All user hirearchy
                    allUsers = [Select id,email_id__c,All_User_Hierarchy_Level1_gne__r.email_id__c,All_User_Hierarchy_Level2_gne__r.email_id__c,User_External_Id_gne__c, Active_gne__c  from All_User_Hierarchy_gne__c where User_External_Id_gne__c = :UNIXid LIMIT 1];
                    if(EscCreD <= toDay)
                    {
                        LA.Latency_Reminder_Check_gne__c = TRUE;
                        LA.Latency_Status_gne__c = 'Escalated';
                        CaseAction_TOupdate.add(LA);
                        ProcessEscalatedNotification(LA);
                    }
                    else if(OvrCreD <= toDay && LA.Latency_Status_gne__c != 'Overdue')
                    {
                        LA.Latency_Reminder_Check_gne__c = TRUE;
                        LA.Latency_Status_gne__c = 'Overdue';
                        CaseAction_TOupdate.add(LA);
                        ProcessOverdueNotification(LA);
                    }
                    else if(RemCreD <= toDay && LA.Latency_Reminder_Check_gne__c != TRUE)
                    {
                        LA.Latency_Reminder_Check_gne__c = TRUE;
                        LA.Latency_Status_gne__c = 'Reminder';
                        CaseAction_TOupdate.add(LA);
                        ProcessRemainderNotification(LA);
                    }
                system.debug('CaseAction_TOupdate'+CaseAction_TOupdate);
             }
           if(CaseAction_TOupdate.size()>0)            //UPDATE Case Actions
           update CaseAction_TOupdate;
           if(CAlatencyFinalInsert.size()>0)           //INSERT New Notification Case actions
           insert CAlatencyFinalInsert;
           if(Tasks.size()>0)                           //INSERT tasks
           insert Tasks;
        }
        catch (Exception e)
        {
           Database.rollback(sp);
           //throw(e);
        }
        try
        {
           if(ErrorLog.size()>0)                        //INSERT Error Log
           insert ErrorLog;
        }
        catch(Exception ex)
        {
        }
    }
    void ProcessRemainderNotification(AGS_Case_Action_gne__c ReferenceCA)//Process Remainder Notification
    {
        try{
            AGS_Case_Action_gne__c RemainderCA = new AGS_Case_Action_gne__c();
            RemainderCA.AGS_Case_Action_Latency__c = ReferenceCA.Id;
            RemainderCA.OwnerId = ReferenceCA.OwnerId;
            RemainderCA.AGS_Case_Resolver_Email_gne__c = allUsers[0].email_id__c;
            RemainderCA.Action_gne__c = 'Action Required - Reminder';
            RemainderCA.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-LatencyReminder-Readonly-Rect').Id;
            RemainderCA.Action_Status_internal_gne__c=  'Closed';
            RemainderCA.Close_Date_gne__c = system.today();
            RemainderCA.AGS_Case_gne__c = ReferenceCA.AGS_Case_gne__c;
            RemainderCA.Send_Email__c = TRUE;
            //If the spend user is NOT Current genentech employee,send an error email
            if(allUsers.size()>0 && allUsers[0].Active_gne__c!=True)
            {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_Latency_NotificationProcess',
                Custom_Error_Message__c='A Latency Notification Email is sent to a NON-GENENTECH Employee: ' +users[0].name,Error_Type__c='Success',Method_Name__c='ProcessRemainderNotification',Object_Name__c='AGS_Case_Action_gne__c');
                ErrorLog.add(el);
            }
            CAlatencyFinalInsert.add(RemainderCA);
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(RemainderCA, ReferenceCA.OwnerId, 'Sent Email'));
        }
        catch (Exception ex1)
        {
            throw(ex1);
        }
    }
    //Process Overdue Notification
    void ProcessOverdueNotification(AGS_Case_Action_gne__c ReferenceCA)
    {
        try{
            AGS_Case_Action_gne__c OverdueCA = new AGS_Case_Action_gne__c();
            OverdueCA.AGS_Case_Action_Latency__c = ReferenceCA.Id;
            OverdueCA.OwnerId = ReferenceCA.OwnerId;
            OverdueCA.AGS_Case_Resolver_Email_gne__c = allUsers[0].email_id__c;
            OverdueCA.Action_gne__c = 'Action Required - Overdue';
            OverdueCA.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-LatencyReminder-Readonly-Rect').Id;
            OverdueCA.Action_Status_internal_gne__c=  'Closed';
            OverdueCA.Close_Date_gne__c = system.today();
            OverdueCA.AGS_Case_gne__c = ReferenceCA.AGS_Case_gne__c;
            OverdueCA.Send_Email__c = TRUE;
            if(allUsers.size()>0)
            {
                //If the spend user is NOT Current genentech employee,send an error email
                if(allUsers[0].Active_gne__c!=True)
                {
                    AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_Latency_NotificationProcess',
                    Custom_Error_Message__c='A Latency Notification Email is sent to a NON-GENENTECH Employee: ' +users[0].name,Error_Type__c='Success',Method_Name__c='ProcessRemainderNotification',Object_Name__c='AGS_Case_Action_gne__c');
                    ErrorLog.add(el);
                }
                //Insert spend Users 1st level managers email
                if(allUsers[0].All_User_Hierarchy_Level1_gne__r.email_id__c!= NULL)
                {
                    OverdueCA.Resolver_FirstLevel_Manager_Email_gne__c = allUsers[0].All_User_Hierarchy_Level1_gne__r.email_id__c;
                }
                else //if Spend user 1st level manager's email is NULL send an error email
                {
                    AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_Latency_NotificationProcess',
                    Custom_Error_Message__c='First level Manger`s email is missing for spenduser: ' +users[0].name,Error_Type__c='FAILURE',Method_Name__c='ProcessEscalatedNotification',Object_Name__c='AGS_Case_Action_gne__c');
                    ErrorLog.add(el);
                }
            }
            else
            {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_Latency_NotificationProcess',
                Custom_Error_Message__c=' Spenduser missing IN Alluser hirearchy: ' +users[0].name,Error_Type__c='FAILURE',Method_Name__c='ProcessEscalatedNotification',Object_Name__c='AGS_Case_Action_gne__c');
                ErrorLog.add(el);
            }
            CAlatencyFinalInsert.add(OverdueCA);
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(OverdueCA, ReferenceCA.OwnerId, 'Sent Email'));
        }
        catch (Exception ex2)
        {
           throw(ex2);
        }
    }
    
     void ProcessEscalatedNotification(AGS_Case_Action_gne__c ReferenceCA)//Process Escalated Notification
        {
        try{
            AGS_Case_Action_gne__c EsclatedCA = new AGS_Case_Action_gne__c();
            EsclatedCA.AGS_Case_Action_Latency__c = ReferenceCA.Id;
            EsclatedCA.OwnerId = ReferenceCA.OwnerId;
            EsclatedCA.AGS_Case_Resolver_Email_gne__c = allUsers[0].email_id__c;
            EsclatedCA.Action_gne__c = 'Action Required - Manager Escalated';
            EsclatedCA.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-LatencyReminder-Readonly-Rect').Id;
            EsclatedCA.Action_Status_internal_gne__c=  'Closed';
            EsclatedCA.Close_Date_gne__c = system.today();
            EsclatedCA.AGS_Case_gne__c = ReferenceCA.AGS_Case_gne__c;
            EsclatedCA.Send_Email__c = TRUE;
            if(allUsers.size()>0)
            {
                //If the spend user is NOT Current genentech employee,send an error email
                if(allUsers[0].Active_gne__c!=True)
                {
                    AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_Latency_NotificationProcess',
                    Custom_Error_Message__c='A Latency Notification Email is sent to a NON-GENENTECH Employee: ' +users[0].name,Error_Type__c='Success',Method_Name__c='ProcessRemainderNotification',Object_Name__c='AGS_Case_Action_gne__c');
                    ErrorLog.add(el);
                }
                //Insert spend Users 1st level managers email
                if(allUsers[0].All_User_Hierarchy_Level1_gne__r.email_id__c!= NULL)
                {
                    EsclatedCA.Resolver_FirstLevel_Manager_Email_gne__c = allUsers[0].All_User_Hierarchy_Level1_gne__r.email_id__c;
                }
                else//if Spend user 1st level manager's email is NULL send an error email
                {
                    AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_Latency_NotificationProcess',
                    Custom_Error_Message__c='First level Manger`s email is missing for spenduser: ' +users[0].name,Error_Type__c='FAILURE',Method_Name__c='ProcessEscalatedNotification',Object_Name__c='AGS_Case_Action_gne__c');
                    ErrorLog.add(el);
                }
                //Insert spend Users 2nd level managers email
                if(allUsers[0].All_User_Hierarchy_Level2_gne__r.email_id__c!= NULL)
                {
                    EsclatedCA.Resolver_SecondLevel_Manager_Email_gne__c = allUsers[0].All_User_Hierarchy_Level2_gne__r.email_id__c;
                }
                else//if Spend user 2nd level manager's email is NULL send an error email
                {
                    AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_Latency_NotificationProcess',
                    Custom_Error_Message__c='Second level Manger`s email is missing for spenduser: ' +users[0].name,Error_Type__c='FAILURE',Method_Name__c='ProcessEscalatedNotification',Object_Name__c='AGS_Case_Action_gne__c');
                    ErrorLog.add(el);
                }
            }
            else
            {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_Latency_NotificationProcess',
                Custom_Error_Message__c=' Spenduser missing IN Alluser hirearchy: ' +users[0].name,Error_Type__c='FAILURE',Method_Name__c='ProcessEscalatedNotification',Object_Name__c='AGS_Case_Action_gne__c');
                ErrorLog.add(el);
            }
            CAlatencyFinalInsert.add(EsclatedCA);
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(EsclatedCA, ReferenceCA.OwnerId, 'Sent Email'));
        }
        catch (Exception ex3)
        {
            throw(ex3);
        }
    }
}