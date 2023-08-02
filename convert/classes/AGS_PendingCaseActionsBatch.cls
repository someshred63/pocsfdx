public class AGS_PendingCaseActionsBatch extends AGS_AbstractCaseBatch {
    public List<AGS_Case_Action_gne__c> CaseAction_list ;
    public List<AGS_Case_Action_gne__c> Caseaction_update;
    public List<AGS_Case_Action_gne__c> Caseaction_insert;
    public List<AGS_Case_gne__c> Case_update;
    public List<AGS_Case_Activity_History__c> Tasks;
    public List<AGS_Error_Log__c> ErrorLog_insert=new   List<AGS_Error_Log__c>();
    public String RecType_Task ;
    public List<RecordType> ObjRecType;
    List<RecordType> RecType;
    Map<String, RecordType> AGS_RecTypes_map;
    Set<ID> CaseIds;
    List<ID> CaseActionIds;
    List<Id> ActionOwnerIds;
    List<AGS_Case_gne__c> CList ;
    Map<ID, AGS_Case_gne__c> CMap;
    Map<id,User> Ownermap;
    List<User> Owners;
    List <String> ActionOwnerExternalIds;
    List<All_User_Hierarchy_gne__c> UHList;
    Map<String,All_User_Hierarchy_gne__c> UserExternalIdMap;
    List<AGS_Case_Action_gne__c> AllCaseActionList;
    Map<Id,AGS_Case_Action_gne__c> AllCaseActionMap;
    Set<String> UserExternalIdList ;
    List<User> UList;
    Map<Id,User> UserMap;
    List<AGSSpendCCOCase_gne__c> AllSpendTransactionsList;
    Map<Id,Integer> CaseSpendUserNumMap;
    String BatchId;
    public List <Task> ActionTasks;
    // Map<string,Task> ActionTasksMaps;
    public AGS_PendingCaseActionsBatch() {
        this('SELECT AGS_Case_gne__c FROM AGS_Case_Action_gne__c WHERE Action_Status_internal_gne__c = \'Open\'');
    }
    
    public AGS_PendingCaseActionsBatch(final String query) {
        super('AGS_Latency_BatchSchedule', 'AGS Latency Case Actions', query);
    }
    
    public override void execute(Database.BatchableContext BC, List<sObject> scope)// try changing it to case action list
    {
        CaseAction_list = (List<AGS_Case_Action_gne__c>) scope;
        BatchId=BC.getJobId();
        AGS_Error_Log__c el2=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
        Custom_Error_Message__c='Action entered batch' +CaseAction_list[0].id ,
        Error_Type__c='Check on entry',Method_Name__c='Execute',Object_Name__c='AGS Case Action');
        //insert el2;
        //LIST TO HOLD ALL RECORDS TO UPDATE/INSERT
        Caseaction_update=new List<AGS_Case_Action_gne__c>();
        Caseaction_insert=new List<AGS_Case_Action_gne__c>();
        Case_update=new List<AGS_Case_gne__c>();
        Tasks = new List<AGS_Case_Activity_History__c>();
        RecType_Task=null;
        //ObjRecType=new List<RecordType>();
        //ObjRecType=[Select Id,name from RecordType where isActive=true and sObjectType='Task' and name='AGS Task'];//soql 1
        /* if(ObjRecType.size()>0)
                {
                    RecType_Task =ObjRecType[0].Id;
                }  */
        RecType =new List<RecordType>();
        RecType= [select Name, Id from RecordType where sobjecttype='AGS_Case_Action_gne__c' or sobjecttype='AGS_Case_gne__c'];//Name like 'AGS%']); //included
        AGS_RecTypes_map= new Map<String, RecordType>();
        for(RecordType r :RecType)
        AGS_RecTypes_map.put(r.name,r);//soql 2
        system.debug(LoggingLevel.ERROR,'complete AGS_RecTypes_map :'+AGS_RecTypes_map);
        // Fetch all casesids , CaseActionIds, action owner ids
        CaseIds = new Set<ID>();
        CaseActionIds = new List<ID>();
        ActionOwnerIds =new List<Id>();
        for (Integer i =0; i < CaseAction_list.size(); i++)
        {
            if (CaseAction_list[i].AGS_Case_gne__c != null)
            CaseIds.add(CaseAction_list[i].AGS_Case_gne__c);
            CaseActionIds.add(CaseAction_list[i].id);
            //ActionOwnerIds.add(CaseAction_list[i].ownerid);
        }
        //fetch all tasks associated with actions
        ActionTasks=new List<Task>();
        ActionTasks=[Select t.CreatedDate, t.Status, t.Subject, t.WhatId from Task t  where WhatId in :CaseActionIds];
        //fetch all cases
        CList = new List<AGS_Case_gne__c>(); //soql 3
        CMap = new Map<ID, AGS_Case_gne__c>([select id,Analyst_gne__r.Email,RecordTypeId, Resolver_gne__c, Case_Closed_Reason_gne__c, Case_Status_gne__c, Analyst_Response_Level_cco_gne__c,
        Expense_Transaction_Total_gne__c,Inactive_resolver__c,Inactive_resolver__r.User_External_Id_gne__c,recordtype.name,Reason_Type_gne__c,
        AGS_Case_Reason_Code_gne__c,Infrequent_User__C from AGS_Case_gne__c where  ID in : CaseIds]);//Map of all cases
        CList = CMap.values();  //List of all cases
        system.debug(LoggingLevel.ERROR,'CaseList size: '+CList.size());
        //fetch all actions associated with all case needed for close case actions
        AllCaseActionList =[Select a.Action_gne__c, a.Action_Status_internal_gne__c, a.Action_Value_gne__c, a.AGS_Case_Analyst_Email_gne__c,
        a.AGS_Case_gne__c,a.Confirm_Compliance_Understanding_gne__c, a.AGS_Escalated_Confirm_Compliance_box_gne__c,
        a.AGS_Validate_Data_1_box_gne__c, a.AGS_Validate_Data_2_box_gne__c, a.AGS_Validate_Data_3_box_gne__c,
        a.AGS_Validate_Data_FollowUp_box_gne__c,a.Ack_Stop_Spending_Limit_High_gne__c, a.Id, a.Infrequent_User_Case_Action_gne__c, a.Owner_Hidden_gne__c,
        a.OwnerId, a.RecordTypeId,Send_Email__c,Send_Error_Email__c,Try_Email_Again__c ,name, AGS_Case_Action_Latency__r.Name from AGS_Case_Action_gne__c a where a.AGS_Case_gne__c in :CaseIds];
        system.debug(LoggingLevel.ERROR,'Case Action List '+AllCaseActionList);
        AllCaseActionMap=new Map<id,AGS_Case_Action_gne__c>();
        for(AGS_Case_Action_gne__c ca:AllCaseActionList)
        {AllCaseActionMap.put(ca.id,ca);
            ActionOwnerIds.add(ca.ownerid);
        }
        // fetch User External Ids
        Ownermap=new Map<id,User> ([Select Id,External_ID_gne__c,Email,name from user where id in :ActionOwnerIds]); //soql 4
        Owners=new List<User>();
        Owners=Ownermap.values();
        // fetch external Ids of Action owners
        ActionOwnerExternalIds=new List<String>();
        for (integer i=0;i<Owners.size();i++)
        ActionOwnerExternalIds.add(Owners[i].External_ID_gne__c);
        // Fetch all user Hierarchy records 1st and 2nd line manager of case action owners //soql 5
        UHList = [Select All_User_Hierarchy_Level1_gne__c, All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c,
        All_User_Hierarchy_Level1_gne__r.email_id__c,
        All_User_Hierarchy_Level2_gne__c, All_User_Hierarchy_Level2_gne__r.User_External_Id_gne__c,
        All_User_Hierarchy_Level2_gne__r.email_id__c,
        FirstName_gne__c,LastName_gne__c,User_External_Id_gne__c,email_id__c from All_User_Hierarchy_gne__c a where
        User_External_Id_gne__c in :ActionOwnerExternalIds and Active_gne__c=true];
        system.debug(LoggingLevel.ERROR,'UHList '+UHList);
        // create a map of User_External_Id_gne__c and All_User_Hierarchy_gne__c record
        UserExternalIdMap=new Map<String,All_User_Hierarchy_gne__c> ();
        for (All_User_Hierarchy_gne__c auh : UHList) {
            UserExternalIdMap.put(auh.User_External_Id_gne__c.toLowerCase(), auh);
        }
        // loop through UHList to collect all user externalds
        UserExternalIdList =new Set<String>();
        for (integer i=0;i<UHList.size();i++)
        {
            UserExternalIdList.add(UHList[i].All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c);
            UserExternalIdList.add(UHList[i].All_User_Hierarchy_Level2_gne__r.User_External_Id_gne__c);
            UserExternalIdList.add(UHList[i].User_External_Id_gne__c);
        }
        //fetch all users for UserExternalIdList//soql 6
        UList=new List<User> ();
        UList=[Select id,External_ID_gne__c,firstname,lastname,name from User where External_ID_gne__c in :UserExternalIdList and UserType ='Standard'];
        //map of User ids and user records
        UserMap=new Map<Id,User>();
        for(integer i=0;i<UList.size();i++)
        UserMap.put(UList[i].Id,UList[i]);
        //Savepoint sp = Database.setSavepoint(); test having the savepoint here
        //Spend Transaction list
        AllSpendTransactionsList=new List<AGSSpendCCOCase_gne__c>();
        AllSpendTransactionsList=[Select Id,AGS_Case_gne__c,AGS_Expense_Transaction_Spend_UserID_gne__c from AGSSpendCCOCase_gne__c
        where AGS_Case_gne__c in :CaseIds];
        //String Caseid_Curr;
        Set<String> SpendUserIds;
        CaseSpendUserNumMap=new Map<Id,Integer>();// Case Id and number of distinc spend users assocaited with the Spend Transactions for the case.
        for (Id Cid : CaseIds)
        {
            SpendUserIds=new Set<String>();
            for (AGSSpendCCOCase_gne__c sp_temp : AllSpendTransactionsList)
            {
                if(sp_temp.AGS_Case_gne__c==Cid)
                SpendUserIds.add(sp_temp.AGS_Expense_Transaction_Spend_UserID_gne__c);
            }
            CaseSpendUserNumMap.put(Cid,SpendUserIds.size());
        }
        system.debug(LoggingLevel.ERROR,'CaseSpendUserNumMap  : ' +CaseSpendUserNumMap);
        // Process each case action coming in the batch
        system.debug(LoggingLevel.ERROR,' case action list '+CaseAction_list);
        for (AGS_Case_Action_gne__c ca_temp: CaseAction_list)
        {
            AGS_Case_Action_gne__c c_CaseAction=AllCaseActionMap.get(ca_temp.id);
            AGS_Error_Log__c el1=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
            Custom_Error_Message__c='Action entered batch' +c_caseaction.id ,
            Error_Type__c='Check in for loop',Method_Name__c='Execute',Object_Name__c='AGS Case Action');
            // insert el1;
            // no of record sin thsi object with check should = batch size
            AGS_Case_gne__c c_Case=CMap.get(c_CaseAction.AGS_Case_gne__c);//fetch associated case record from map
            system.debug(LoggingLevel.ERROR,'c_CaseAction  : '+c_CaseAction);
            system.debug(LoggingLevel.ERROR,'UserMap.get(c_CaseAction.ownerId)'+UserMap.get(c_CaseAction.ownerId));
            // for close case actions actions, processing and sending email should be done in one go
            // if (UserMap.get(c_CaseAction.ownerId)<>null && c_CaseAction.Action_Status_internal_gne__c=='Open')
            DateTime presentdate=system.now();
            if(presentdate.hour()<20 || Test.isRunningTest())
            {
                if (c_CaseAction.Action_Status_internal_gne__c=='Open')
                {
                    if (Math.round(c_CaseAction.Action_Value_gne__c)==110 )                                     ProcessCaseClosedNoIssue(c_CaseAction);
                    else if (Math.round(c_CaseAction.Action_Value_gne__c)==111 )                                ProcessCaseClosedIssueResolved(c_CaseAction);
                    else if (Math.round(c_CaseAction.Action_Value_gne__c)==112 )                                ProcessCaseClosedHCOResolve(c_CaseAction);
                    else if (Math.round(c_CaseAction.Action_Value_gne__c)==119 )                                ProcessCaseClosedNoNotification(c_CaseAction);
                    else if (c_CaseAction.Send_Email__c==False && c_CaseAction.Send_Error_Email__c==False )
                    {system.debug(LoggingLevel.ERROR,'calling send email for '+c_CaseAction.id);
                        sendemail(c_CaseAction);
                    }
                    else if(Math.round(c_CaseAction.Action_Value_gne__c)==107)                                  ProcessPVD(c_CaseAction);
                    else if(Math.round(c_CaseAction.Action_Value_gne__c)==108)                                  ProcessPVD_FollowUp(c_CaseAction);
                    else if(Math.round(c_CaseAction.Action_Value_gne__c)==113)                                  ProcessConfirmCompliance(c_CaseAction);
                    else if(Math.round(c_CaseAction.Action_Value_gne__c)==114)                                  ProcessEscalatedConfirmCompliance(c_CaseAction);
                    else if(Math.round(c_CaseAction.Action_Value_gne__c)==131)                                  ProcessAggrRecommSpendlimit(c_CaseAction);
                    //else if(Math.round(c_CaseAction.Action_Value_gne__c)==106)                                ProcessSystemReopenCase(c_CaseAction);
                    else if(Math.round(c_CaseAction.Action_Value_gne__c)==132)                                  ProcessAggrSpendLimit(c_CaseAction);
                    else if(Math.round(c_CaseAction.Action_Value_gne__c)==133)                                  ProcessAggrLegalSpendLimit(c_CaseAction);
                }
                else
                {
                    system.debug(LoggingLevel.ERROR,'The Case ACtion was not processed as the latest status of the case action is not Open');
                    if(c_CaseAction.Action_Status_internal_gne__c=='Open')
                    ErrorLog_insert.add(new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                    Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' was not processes as the latest status of the action is not Open',Error_Type__c='Success',Method_Name__c='Execute',Object_Name__c='AGS Case Action'));
                    //else
                    //system.debug('UserMap.get(c_CaseAction.ownerId)'+UserMap.get(c_CaseAction.ownerId));
                }
            }
        }
        Savepoint sp = Database.setSavepoint();
        try
        {
            if(Caseaction_insert.size()>0)
            {
                insert Caseaction_insert;}
            if(Caseaction_update.size()>0)
            {
                system.debug(LoggingLevel.ERROR,'action update'+Caseaction_update);
                //Caseaction_update[0].ownerid=null;
                update Caseaction_update;
            }
            if(Tasks.size()>0)
            {   system.debug(LoggingLevel.ERROR,'tasks size'+Tasks.size());
                insert Tasks;
            }
            if(Case_update.size()>0)
            Update Case_update;
            AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
            Custom_Error_Message__c='All insert/update successfull',Error_Type__c='Success',Method_Name__c='Execute',Object_Name__c='AGS Case Action');
            ErrorLog_insert.add(el);
        }
        catch (Exception e)
        {
            system.debug(LoggingLevel.ERROR,'error durig insert 1'+e.getMessage());
            Database.rollback(sp);
            system.debug(LoggingLevel.ERROR,'reached here');
            AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
            System_Error_Message__c=e.getMessage(),Error_Type__c='Error',Method_Name__c='Execute',Object_Name__c='AGS Case Action');
            ErrorLog_insert.add(el);
        }
        try
        {
            //system.debug('reached on insert error');
            if (ErrorLog_insert.size()>0)
            Insert ErrorLog_insert;
        }
        catch(Exception e)
        {
            system.debug(LoggingLevel.ERROR,'Problem inserting error log');
        }
    }
    private void sendemail(AGS_Case_Action_gne__c c_CaseAction) {
        //method activates appropriate user and marks the send email flag accordingly
        AGS_Case_gne__c c_Case=CMap.get(c_CaseAction.AGS_Case_gne__c);//fetch associated case record from map
        system.debug(LoggingLevel.ERROR,'associated case'+c_Case);
        //send a request to activate the owner
        system.debug(LoggingLevel.ERROR,'User record for the owner'+Ownermap.get(c_CaseAction.OwnerId));
        system.debug(LoggingLevel.ERROR,'unix id'+Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c);
        //do we need to check all user hierarchy of the action owner before we try to activate him
        All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
        System.debug(Owner_User_hierarchy);
        //String UserResult=UserManager.activateSFUser(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c,True);
        // first five characters are error.
        if(Math.round(c_CaseAction.Action_Value_gne__c) == 115) {
            // check if there are any tasks associated with the case action
            Integer taskflag=0;
            for(task at:ActionTasks) {
                if (at.WhatId==c_CaseAction.Id) {
                    tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.Ownerid,at.subject));
                    taskflag=1;
                }
            }
            if(taskflag==1) {
                AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,Send_Email__c=true,
                    Action_Status_internal_gne__c='Closed',
                    recordtypeid=AGS_RecTypes_map.get('AGS Case Action-SendCustomNotification-ReadOnly-Rect').Id
                );
                Caseaction_update.add(temp_action);
            }
        } else if (Owner_User_hierarchy<>null && Ownermap.get(c_CaseAction.OwnerId).name<>'No Spend User') { // user  is active employee
            if(Math.round(c_CaseAction.Action_Value_gne__c) == 107 ||
                    Math.round(c_CaseAction.Action_Value_gne__c) == 108 ||
                    Math.round(c_CaseAction.Action_Value_gne__c) == 131 ||
                    Math.round(c_CaseAction.Action_Value_gne__c) == 109 ||
                    Math.round(c_CaseAction.Action_Value_gne__c) == 106) {
                // update temp_action;
                AGS_Case_Action_gne__c temp_action = new AGS_Case_Action_gne__c(
                    id=c_CaseAction.Id,
                    Send_Email__c=true,
                    AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c
                );
                system.debug(LoggingLevel.ERROR,'send email'+temp_action);
                Caseaction_update.add(temp_action);
                //add logic to create a task
                if(Math.round(c_CaseAction.Action_Value_gne__c) == 131) {
                    system.debug(LoggingLevel.ERROR,'aggr recomm limit tasks added');
                    tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.Ownerid, 'Sent Notice Email Agg Limit Low'));
                } else if (Math.round(c_CaseAction.Action_Value_gne__c) == 109 || Math.round(c_CaseAction.Action_Value_gne__c) == 106) {
                    temp_action.Action_Status_internal_gne__c='Closed';//post sqa fix to close notification actions as no more peocessing is done
                    tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.Ownerid, 'Sent Email'));
                    if (Math.round(c_CaseAction.Action_Value_gne__c) == 109)
                    tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.Ownerid, 'Analyst Re-opened AGS Case'));
                    else
                    tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.Ownerid, 'System Re-opened AGS Case'));
                } else {
                    system.debug(LoggingLevel.ERROR,'PVD tasks added');
                    tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.Ownerid, 'Sent Notice Email'));
                    tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.Ownerid, 'Opened Case Action for Review'));
                }
            } else {
                if (Math.round(c_CaseAction.Action_Value_gne__c) == 113 ||
                        Math.round(c_CaseAction.Action_Value_gne__c)==114 ||
                        Math.round(c_CaseAction.Action_Value_gne__c)==132 ||
                        Math.round(c_CaseAction.Action_Value_gne__c)==133 ||
                        Math.round(c_CaseAction.Action_Value_gne__c)==110 ||
                        Math.round(c_CaseAction.Action_Value_gne__c)==111 ||
                        Math.round(c_CaseAction.Action_Value_gne__c)==112 ||
                        Math.round(c_CaseAction.Action_Value_gne__c)==119) {
                    String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                    System.debug(LoggingLevel.ERROR,'gaboo 1 ' + Manager_email_id);
                    if(String.isNotBlank(Manager_email_id)) {
                        System.debug(LoggingLevel.ERROR,'gaboo 2 ' + Manager_email_id);
                        // String UserManagerResult=UserManager.activateSFUser(Manager_external_id,True);
                        if(Math.round(c_CaseAction.Action_Value_gne__c) == 113 || Math.round(c_CaseAction.Action_Value_gne__c)==132 ||
                                Math.round(c_CaseAction.Action_Value_gne__c)==110 ||
                                Math.round(c_CaseAction.Action_Value_gne__c)==111 ||
                                Math.round(c_CaseAction.Action_Value_gne__c)==112 ||
                                Math.round(c_CaseAction.Action_Value_gne__c)==119) {
                            AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,Send_Email__c=true,
                            AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c,
                            Resolver_FirstLevel_Manager_Email_gne__c=Manager_email_id,
                            //AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email) ;
                            AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                            system.debug(LoggingLevel.ERROR,'send email'+temp_action);
                            Caseaction_update.add(temp_action);
                            if(Math.round(c_CaseAction.Action_Value_gne__c)==110 ||
                                    Math.round(c_CaseAction.Action_Value_gne__c)==111 ||
                                    Math.round(c_CaseAction.Action_Value_gne__c)==112 ||
                                    Math.round(c_CaseAction.Action_Value_gne__c)==119)
                            tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId,'Sent Email'));
                            else
                            if(Math.round(c_CaseAction.Action_Value_gne__c)==132)
                            tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId,'Sent Notice Email Agg Limit Medium'));
                            else
                            if(Math.round(c_CaseAction.Action_Value_gne__c)==113)
                            {tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId,'Sent Notice Email'));
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId,'Opened Case Action for Review'));
                            }
                        } else {
                            if(Math.round(c_CaseAction.Action_Value_gne__c)==114 || Math.round(c_CaseAction.Action_Value_gne__c)==133 ) { //fetch 2nd line managers and activate
                                //Manager_external_id='';
                                String Manager2_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level2_gne__r.email_id__c;
                                System.debug(LoggingLevel.ERROR,'gaboo 3 Manager2_email_id: ' + Manager2_email_id);
                                if(String.isNotBlank(Manager2_email_id))
                                {
                                    System.debug(LoggingLevel.ERROR,'gaboo 4 Manager2_email_id: ' + Manager2_email_id);
                                    //String UsersecManagerResult=UserManager.activateSFUser(Manager_external_id,True);
                                    AGS_Case_Action_gne__c temp_action;
                                    if(Math.round(c_CaseAction.Action_Value_gne__c)==133)
                                    {temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,Send_Email__c=true,
                                        AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c,
                                        // AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email,
                                        AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                                        Resolver_FirstLevel_Manager_Email_gne__c=Manager_email_id,
                                        Resolver_SecondLevel_Manager_Email_gne__c=Manager2_email_id) ;
                                        tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Sent Notice Email Agg Limit High'));
                                    }
                                    else //114
                                    {temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,Send_Email__c=true,
                                        AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c,
                                        // AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email,
                                        AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                                        Resolver_FirstLevel_Manager_Email_gne__c=Manager_email_id) ;
                                        tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Sent Notice Email'));
                                        tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Opened Case Action for Review'));
                                    }
                                    system.debug(LoggingLevel.ERROR,'send email'+temp_action);
                                    Caseaction_update.add(temp_action);
                                }
                                else// if 2nd level manager field on the All user  hierarchy record is not populated
                                {
                                    If(c_CaseAction.Try_Email_Again__c==False)
                                    {AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,
                                        Try_Email_Again__c=true,AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c);
                                        Caseaction_update.add(temp_action);
                                        AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                                        Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' try email again was marked as action owner 2nd level Manager name or email id is not available' ,
                                        Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
                                        ErrorLog_insert.add(el);
                                    }
                                    else
                                    {AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,
                                        Send_Error_Email__c=true,Send_Email__c=true,AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c,
                                        //AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email,
                                        AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                                        Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id );
                                        Caseaction_update.add(temp_action);
                                        AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                                        Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' send error email was marked as action owner 2nd level Manager name or email id is not available.Note - Send Email was also marked to inform the action owner' ,
                                        Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
                                        ErrorLog_insert.add(el);
                                        tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent,Manager not informed'));
                                        if(Math.round(c_CaseAction.Action_Value_gne__c)==133)
                                        tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Sent Notice Email Agg Limit High'));
                                        else
                                        {
                                            tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Sent Notice Email'));
                                            tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Opened Case Action for Review'));
                                        }
                                    }
                                }
                            }
                        }
                        //error log not able to activate user
                    }
                    else
                    {//write error log hierarchy record does not have external Id
                        // 1st level manager is  not found then send error email as well as email to action owner
                        If(c_CaseAction.Try_Email_Again__c==False)
                        {AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,
                            Try_Email_Again__c=true,AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c);
                            Caseaction_update.add(temp_action);
                            AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                            Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' try email again was marked as action owner 1st level Manager name or email id is not available ' ,
                            Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
                            ErrorLog_insert.add(el);
                        }
                        else
                        {AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,
                            Send_Error_Email__c=true,Send_Email__c=true,AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c,
                            // AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email);
                            AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                            Caseaction_update.add(temp_action);
                            AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                            Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' send error email was marked as action owner 1st level Manager name or email id is not available .Note - Send Email was also marked to inform the action owner' ,
                            Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
                            ErrorLog_insert.add(el);
                            tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent,Manager not informed'));
                            if(Math.round(c_CaseAction.Action_Value_gne__c)==110 ||
                                    Math.round(c_CaseAction.Action_Value_gne__c)==111 ||
                                    Math.round(c_CaseAction.Action_Value_gne__c)==112 ||
                                    Math.round(c_CaseAction.Action_Value_gne__c)==119)
                            tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId,'Sent Email'));
                            else
                            if(Math.round(c_CaseAction.Action_Value_gne__c)==132)
                            tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId,'Sent Notice Email Agg Limit Medium'));
                            else
                            if(Math.round(c_CaseAction.Action_Value_gne__c)==113)
                            {tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId,'Sent Notice Email'));
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId,'Opened Case Action for Review'));
                            }
                        }
                    }
                }
            }
            //else
            //write to error log action owner not activated
        }
        else // problem activating the action owner itself //serious problem if try again was already true then change the case to manual
        {
            if(Ownermap.get(c_CaseAction.OwnerId).name=='No Spend User')
            {
                //set send error email flag
                AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,
                Send_Error_Email__c=true,AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c);
                //Action_Status_internal_gne__c='Closed');
                Caseaction_update.add(temp_action);
                AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' send error email was marked as action owner is No Spend User,implies No Spend User on expense transaction' ,
                Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
                ErrorLog_insert.add(el);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent,No User on Transaction'));
            }
            else
            {
                If(c_CaseAction.Try_Email_Again__c==False)
                {AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,
                    Try_Email_Again__c=true,AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c);
                    Caseaction_update.add(temp_action);
                    AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                    Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' try email again was marked as action owner is not current employee' ,
                    Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
                    ErrorLog_insert.add(el);
                }
                else
                {
                    AGS_Case_Action_gne__c temp_action=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,
                    Send_Error_Email__c=true,AGS_Case_gne__c=c_CaseAction.AGS_Case_gne__c);
                    if (Math.round(c_CaseAction.Action_Value_gne__c) == 109 || Math.round(c_CaseAction.Action_Value_gne__c) == 106)
                    temp_action.Action_Status_internal_gne__c='Closed';
                    Caseaction_update.add(temp_action);
                    AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                    Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' send error email was marked as action owner is not current employee' ,
                    Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
                    ErrorLog_insert.add(el);
                    tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent'));
                    /*if (c_Case.Case_Status_gne__c=='Open' && (c_Case.Analyst_Response_Level_cco_gne__c<>'Low' && c_case.Reason_Type_gne__c<>'Aggregation Rule'))
                            {
                                c_Case.Case_Status_gne__c='Open - Pending Manual Analysis';//will not apply to close case actions as there is separate method to handle send email for case close actions
                                Case_update.add(c_case);
                            }*/
                }
            }
        }
    }
    private void ProcessPVD(AGS_Case_Action_gne__c c_CaseAction)
    {
        system.debug('entered else');
        if ((c_CaseAction.AGS_Validate_Data_1_box_gne__c == true ||
                    c_CaseAction.AGS_Validate_Data_2_box_gne__c == true ||
                    c_CaseAction.AGS_Validate_Data_3_box_gne__c == true )
                && Math.round(c_CaseAction.Action_Value_gne__c)==107)//Set the RecordType to Readonly, and Close the Case Actions
        {
            system.debug('a response selected');
            AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',
            recordtypeid=AGS_RecTypes_map.get('AGS Case Action-ValidateData-Readonly-Rect').id);
            system.debug('case action with closed status and read only record type'+ca);
            Caseaction_update.add(ca);
            //process based on the answer selected
            AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
            system.debug('case fetched'+c_case);
            if( c_CaseAction.AGS_Validate_Data_1_box_gne__c == true)
            {
                Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Resolver Validated Data, Selected A'));
                If( c_case.Analyst_Response_Level_cco_gne__c == 'Low'
                &&  c_case.Infrequent_User__C==False //may6
                && (c_case.Reason_Type_gne__c=='Instance Rule' ||c_case.Reason_Type_gne__c=='Aggregation Rule' )&& c_case.Case_Status_gne__c =='Open') // // shld check for Case AGS_Case_Reason_Code_gne__c<> 0A//and case in not manual )//I confirm information is correct.
                {
                    AGS_Case_Action_gne__c ca_insert=AGS_CaseUtility.addNewCaseActionToCase(c_case, 'Confirm Compliance Understanding');
                    //if (ca_insert.ownerid<>null) if owner is null then insert will fail and we will roll back everything
                    //set record type can later be moved over to agsworkflow class
                    ca_insert.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-ConfirmCompliance-Edit-Rect').Id;
                    system.debug('confirm compliance insert '+ca_insert);
                    Caseaction_insert.add(ca_insert);
                    //Add a closed task to the AGS CASE signalling the user validated the data email sent
                    system.debug('Tasks inserted'+Tasks);
                }
            }
            if( c_CaseAction.AGS_Validate_Data_2_box_gne__c == true)
            {
                Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Resolver Validated Data, Selected B'));
                If(c_CaseAction.Action_Status_internal_gne__c == 'Open'
                &&  c_case.Infrequent_User__C==False
                && (c_case.Reason_Type_gne__c=='Instance Rule' ||c_case.Reason_Type_gne__c=='Aggregation Rule') &&
                (c_case.AGS_Case_Reason_Code_gne__c=='1A' ||c_case.AGS_Case_Reason_Code_gne__c=='1B'||c_case.AGS_Case_Reason_Code_gne__c=='1C'||
                c_case.AGS_Case_Reason_Code_gne__c=='1D'||c_case.AGS_Case_Reason_Code_gne__c=='1E'))
                //c_case.Case_Status_gne__c =='Open')////in the User Validate Data Check B.
                {
                    system.debug('trying to create close case - No issue');
                    AGS_Case_Action_gne__c ca_insert=AGS_CaseUtility.addNewCaseActionToCase(c_case, 'Close Case - No Issue');
                    //if (ca_insert.ownerid<>null) if owner is null then insert will fail and we will roll back everything
                    ca_insert.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect').Id;
                    system.debug('clos ecase action to insert '+ca_insert);
                    Caseaction_insert.add(ca_insert);
                    //Add a closed task to the AGS CASE signalling the user validated the data email sent
                    system.debug('Tasks inserted'+Tasks);
                }
            }
            if( c_CaseAction.AGS_Validate_Data_3_box_gne__c == true )
            {
                Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Resolver Validated Data, Selected C'));
                if(c_case.Analyst_Response_Level_cco_gne__c == 'Low'
                        // && UserMap.get(c_CaseAction.ownerId).Infrequent_Interacton_Enabled_gne__c==False
                        &&  c_case.Infrequent_User__C==False
                        && (c_case.Reason_Type_gne__c=='Instance Rule' ||c_case.Reason_Type_gne__c=='Aggregation Rule') && c_case.Case_Status_gne__c =='Open')////in the User Validate Data Check B.
                {
                    AGS_Case_Action_gne__c ca_insert=AGS_CaseUtility.addNewCaseActionToCase(c_case, 'Please Validate Data - Follow Up');
                    //if (ca_insert.ownerid<>null) if owner is null then insert will fail and we will roll back everything
                    ca_insert.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-ValidateDataFollowUp-Edit-Rect').Id;
                    Caseaction_insert.add(ca_insert);
                    //Add a closed task to the AGS CASE signalling the user validated the data email sent
                    system.debug('Tasks inserted'+Tasks);
                }
            }
        }
    }
    private void ProcessPVD_FollowUp(AGS_Case_Action_gne__c c_CaseAction)
    {
        AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
        if(c_CaseAction.AGS_Validate_Data_FollowUp_box_gne__c==true)//user has responded
        {
            //close the action and change record type to read only irrespective of severity ,type etc
            AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',
            recordtypeid=AGS_RecTypes_map.get('AGS Case Action-ValidateDataFollowUp-Readonly-Rect').id);
            system.debug('case action with closed status and read only record type'+ca);
            Caseaction_update.add(ca);
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Resolver Acknowledged Case Action'));
            if(c_CaseAction.AGS_Validate_Data_FollowUp_box_gne__c == true && c_case.Analyst_Response_Level_cco_gne__c == 'Low'
                    //&& UserMap.get(c_CaseAction.ownerId).Infrequent_Interacton_Enabled_gne__c==False
                    &&  c_case.Infrequent_User__C==False
                    && c_case.Reason_Type_gne__c=='Instance Rule' && c_case.Case_Status_gne__c =='Open')
            {
                system.debug('case fetched'+c_case);
                system.debug('trying to create close case - No issue');
                AGS_Case_Action_gne__c ca_insert=AGS_CaseUtility.addNewCaseActionToCase(c_case, 'Close Case - Issue Resolved');
                //if (ca_insert.ownerid<>null) if owner is null then insert will fail and we will roll back everything
                ca_insert.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect').Id;
                system.debug('close case action to insert '+ca_insert);
                Caseaction_insert.add(ca_insert);
                //Add a closed task to the AGS CASE signalling the user validated the data email sent
                Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
                system.debug('Tasks inserted'+Tasks);
            }
        }
    }
    private void ProcessConfirmCompliance(AGS_Case_Action_gne__c c_CaseAction)
    {
        AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
        if(c_CaseAction.Confirm_Compliance_Understanding_gne__c==true)//user has responded CMap
        {
            //close the action and change record type to read only irrespective of severity ,type etc
            AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',
            recordtypeid=AGS_RecTypes_map.get('AGS Case Action-ConfirmCompliance-Readonly-Rect').id);
            system.debug('case action with closed status and read only record type'+ca);
            Caseaction_update.add(ca);
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Resolver Acknowledged Case Action'));
            if(c_CaseAction.Confirm_Compliance_Understanding_gne__c == true && c_case.Analyst_Response_Level_cco_gne__c == 'Low'
                    //&& UserMap.get(c_CaseAction.ownerId).Infrequent_Interacton_Enabled_gne__c==False
                    &&  c_case.Infrequent_User__C==False
                    && c_case.Reason_Type_gne__c=='Instance Rule' && c_case.Case_Status_gne__c =='Open')
            {
                system.debug('case fetched'+c_case);
                system.debug('trying to create close case - Issue Resolved');
                AGS_Case_Action_gne__c ca_insert=AGS_CaseUtility.addNewCaseActionToCase(c_case, 'Close Case - Issue Resolved');
                //if (ca_insert.ownerid<>null) if owner is null then insert will fail and we will roll back everything
                ca_insert.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect').Id;
                system.debug('close case action to insert '+ca_insert);
                Caseaction_insert.add(ca_insert);
                //Add a closed task to the AGS CASE signalling the user validated the data email sent
                Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
                system.debug('Tasks inserted'+Tasks);
            }
        }
    }
    private void ProcessCaseClosedNoIssue(AGS_Case_Action_gne__c c_CaseAction)
    {
        AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
        if(c_case.recordtype.name=='AGS Case Per Instance RecordType')//confirm if we need to add a condition to check for CCO case reason type to be per instance
        {   // try sending email
            AGS_Case_Action_gne__c ca;
            Integer SendEmailResult=CloseCaseSendEmail(c_CaseAction);
            if (SendEmailResult==0)//try again
            ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Try_Email_Again__c=true);//close the action
            else if (SendEmailResult==1)//send email
            {
                All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
                String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email,
                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id);
            }
            else if (SendEmailResult==2)//send error email
            {ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Error_Email__c=true);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent')); }
            else if (SendEmailResult==3)// Send both email and error email
            {
                All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                Send_Error_Email__c=true,
                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email);
                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent,Manager not informed'));
            }
            Caseaction_update.add(ca);
            system.debug('ca test '+ca);
            c_case.recordtypeid=AGS_RecTypes_map.get('AGS Case Per Instance Closed RecordType').Id;
            c_case.Case_Status_gne__c= 'Closed';
            c_case.Case_Closed_Reason_gne__c = 'No Issue';
            Case_update.add(c_case);
            system.debug('case to upate'+c_case);
            //Add a closed task to the AGS CASE (Rename to addClosedAGSActivityToAGSCase) signalling email sent
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
            //fetch all case actions associated with the case and set to status close as the trigger does
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList) {
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c && ca_x_2.id!=c_CaseAction.id)
                {
                    ca_x_2.Action_Status_internal_gne__c = 'Closed';
                    Caseaction_update.add(ca_x_2);
                }
            }
            system.debug('all case action closed');
        }
        else
        if(c_case.recordtype.name=='' || c_case.recordtype.name==null ||c_case.recordtype.name=='AGS Case Aggregate RecordType' )
        {
            AGS_Case_Action_gne__c ca;
            Integer NumofCaseCloseActions=0;
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
            {
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c && Math.round(ca_x_2.Action_Value_gne__c)==110)
                NumofCaseCloseActions=NumofCaseCloseActions+1;
            }
            Integer NumOfExpectedCaseCloseActions=CaseSpendUserNumMap.get(c_case.Id);
            Integer SendEmailResult;
            if(NumofCaseCloseActions >= NumOfExpectedCaseCloseActions)
            { //send email for all case actions,close all case actions,close the case
                SendEmailResult=0;
                for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
                {
                    if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c )
                    {
                        if(Math.round(ca_x_2.Action_Value_gne__c)==110 && ca_x_2.Send_Email__c==false && ca_x_2.Send_Error_Email__c==false)
                        {
                            system.debug('ca_x_2 to check '+ca_x_2);
                            SendEmailResult=CloseCaseSendEmail(ca_x_2);
                            system.debug('SendEmailResult for'+ ca_x_2.id+' '+SendEmailResult);
                            if (SendEmailResult==1)//send email
                            {  All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(ca_x_2.OwnerId).External_ID_gne__c.toLowerCase());
                                String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                                ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(ca_x_2.OwnerId).Email,
                                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                                Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id);
                            }
                            else if (SendEmailResult==2)//send error email
                            {ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Error_Email__c=true);
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Error Email Sent'));
                            }
                            else if (SendEmailResult==3)// Send both email and error email
                            {All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(ca_x_2.OwnerId).External_ID_gne__c.toLowerCase());
                                ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                                Send_Error_Email__c=true,
                                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(ca_x_2.OwnerId).Email);
                                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Error Email Sent,Manager not informed'));
                            }
                            system.debug('caupdate'+ca);
                            Caseaction_update.add(ca);
                            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Closed Case and Associated Case Actions'));
                        }
                        else
                        {
                            ca_x_2.Action_Status_internal_gne__c = 'Closed';
                            system.debug('caupdate'+ca);
                            Caseaction_update.add(ca_x_2);
                        }
                    }
                }
                // close the case
                c_case.recordtypeid=AGS_RecTypes_map.get('AGS Case Aggregate Closed RecordType').Id;
                c_case.Case_Status_gne__c= 'Closed';
                c_case.Case_Closed_Reason_gne__c = 'No Issue';
                system.debug(' I am about to close case'+c_case);
                Case_update.add(c_case);
                //Add a closed task to the AGS CASE (Rename to addClosedAGSActivityToAGSCase) signalling email sent
                //Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
            }
        }
    }
    private void ProcessCaseClosedNoNotification(AGS_Case_Action_gne__c c_CaseAction)
    {
        AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
        if(c_case.recordtype.name=='AGS Case Per Instance RecordType')//confirm if we need to add a condition to check for CCO case reason type to be per instance
        {   // try sending email
            AGS_Case_Action_gne__c ca;
            Integer SendEmailResult=CloseCaseSendEmail(c_CaseAction);
            if (SendEmailResult==0)//try again
            ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Try_Email_Again__c=true);//close the action
            else if (SendEmailResult==1)//send email
            {
                All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
                String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email,
                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id);
            }
            else if (SendEmailResult==2)//send error email
            {ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Error_Email__c=true);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent')); }
            else if (SendEmailResult==3)// Send both email and error email
            {
                All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                Send_Error_Email__c=true,
                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email);
                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent,Manager not informed'));
            }
            Caseaction_update.add(ca);
            system.debug('ca test '+ca);
            c_case.recordtypeid=AGS_RecTypes_map.get('AGS Case Per Instance Closed RecordType').Id;
            c_case.Case_Status_gne__c= 'Closed';
            c_case.Case_Closed_Reason_gne__c = 'No Notification';
            Case_update.add(c_case);
            system.debug('case to upate'+c_case);
            //Add a closed task to the AGS CASE (Rename to addClosedAGSActivityToAGSCase) signalling email sent
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
            //fetch all case actions associated with the case and set to status close as the trigger does
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList) {
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c && ca_x_2.id!=c_CaseAction.id)
                {
                    ca_x_2.Action_Status_internal_gne__c = 'Closed';
                    Caseaction_update.add(ca_x_2);
                }
            }
            system.debug('all case action closed');
        }
        else
        if(c_case.recordtype.name=='' || c_case.recordtype.name==null ||c_case.recordtype.name=='AGS Case Aggregate RecordType' )
        {
            AGS_Case_Action_gne__c ca;
            Integer NumofCaseCloseActions=0;
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
            {
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c && Math.round(ca_x_2.Action_Value_gne__c)==119)
                NumofCaseCloseActions=NumofCaseCloseActions+1;
            }
            Integer NumOfExpectedCaseCloseActions=CaseSpendUserNumMap.get(c_case.Id);
            Integer SendEmailResult;
            if(NumofCaseCloseActions >= NumOfExpectedCaseCloseActions)
            { //send email for all case actions,close all case actions,close the case
                SendEmailResult=0;
                for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
                {
                    if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c )
                    {
                        if(Math.round(ca_x_2.Action_Value_gne__c)==119 && ca_x_2.Send_Email__c==false && ca_x_2.Send_Error_Email__c==false)
                        {
                            system.debug('ca_x_2 to check '+ca_x_2);
                            SendEmailResult=CloseCaseSendEmail(ca_x_2);
                            system.debug('SendEmailResult for'+ ca_x_2.id+' '+SendEmailResult);
                            if (SendEmailResult==1)//send email
                            {  All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(ca_x_2.OwnerId).External_ID_gne__c.toLowerCase());
                                String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                                ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(ca_x_2.OwnerId).Email,
                                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                                Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id);
                            }
                            else if (SendEmailResult==2)//send error email
                            {ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Error_Email__c=true);
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Error Email Sent'));
                            }
                            else if (SendEmailResult==3)// Send both email and error email
                            {All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(ca_x_2.OwnerId).External_ID_gne__c.toLowerCase());
                                ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                                Send_Error_Email__c=true,
                                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(ca_x_2.OwnerId).Email);
                                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Error Email Sent,Manager not informed'));
                            }
                            system.debug('caupdate'+ca);
                            Caseaction_update.add(ca);
                            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Closed Case and Associated Case Actions'));
                        }
                        else
                        {
                            ca_x_2.Action_Status_internal_gne__c = 'Closed';
                            system.debug('caupdate'+ca);
                            Caseaction_update.add(ca_x_2);
                        }
                    }
                }
                // close the case
                c_case.recordtypeid=AGS_RecTypes_map.get('AGS Case Aggregate Closed RecordType').Id;
                c_case.Case_Status_gne__c= 'Closed';
                c_case.Case_Closed_Reason_gne__c = 'No Notification';
                system.debug(' I am about to close case'+c_case);
                Case_update.add(c_case);
                //Add a closed task to the AGS CASE (Rename to addClosedAGSActivityToAGSCase) signalling email sent
                //Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
            }
        }
    }
    private void ProcessCaseClosedIssueResolved(AGS_Case_Action_gne__c c_CaseAction)
    {
        AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
        system.debug('Case Fetched in case close issue resolved'+c_case.id+' record type '+c_case.recordtype.name);
        //All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c);
        if(c_case.recordtype.name=='AGS Case Per Instance RecordType')//confirm if we need to add a condition to check for CCO case reason type to be per instance
        {
            // try sending email
            AGS_Case_Action_gne__c ca;
            Integer SendEmailResult=CloseCaseSendEmail(c_CaseAction);
            if (SendEmailResult==1)//send email
            {  All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
                String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                // AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email,
                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id);
            }
            else if (SendEmailResult==2)//send error email
            {ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Error_Email__c=true);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent'));
            }
            else if (SendEmailResult==3)// Send both email and error email
            {
                All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                Send_Error_Email__c=true,
                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email);
                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent,Manager not informed'));
            }
            Caseaction_update.add(ca);
            system.debug('ca test '+ca);
            c_case.recordtypeid=AGS_RecTypes_map.get('AGS Case Per Instance Closed RecordType').Id;
            c_case.Case_Status_gne__c= 'Closed';
            c_case.Case_Closed_Reason_gne__c = 'Issue Resolved';
            Case_update.add(c_case);
            system.debug('case to upate'+c_case);
            //Add a closed task to the AGS CASE (Rename to addClosedAGSActivityToAGSCase) signalling email sent
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
            //fetch all case actions associated with the case and set to status close as the trigger does
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList) {
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c && ca_x_2.id!=c_CaseAction.id)
                {
                    ca_x_2.Action_Status_internal_gne__c = 'Closed';
                    Caseaction_update.add(ca_x_2);
                }
            }
            system.debug('all case action closed');
        }
        else
        if( c_case.recordtype.name=='' || c_case.recordtype.name==null || c_case.recordtype.name=='AGS Case Aggregate RecordType'  )
        {
            AGS_Case_Action_gne__c ca;
            Integer NumofCaseCloseActions=0;
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
            {
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c && Math.round(ca_x_2.Action_Value_gne__c)==111)
                NumofCaseCloseActions=NumofCaseCloseActions+1;
            }
            Integer NumOfExpectedCaseCloseActions=CaseSpendUserNumMap.get(c_case.Id);
            Integer SendEmailResult;
            if(NumofCaseCloseActions >= NumOfExpectedCaseCloseActions)
            { //send email for all case actions,close all case actions,close the case
                SendEmailResult=0;
                for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
                {
                    if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c )
                    {
                        if(Math.round(ca_x_2.Action_Value_gne__c)==111 && ca_x_2.Send_Email__c==false && ca_x_2.Send_Error_Email__c==false)
                        {
                            system.debug('ca_x_2 to check '+ca_x_2);
                            SendEmailResult=CloseCaseSendEmail(ca_x_2);
                            system.debug('SendEmailResult for'+ ca_x_2.id+' '+SendEmailResult);
                            if (SendEmailResult==1)//send email
                            {  All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(ca_x_2.OwnerId).External_ID_gne__c.toLowerCase());
                                String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                                ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                                Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id);
                            }
                            else if (SendEmailResult==2)//send error email
                            {ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Error_Email__c=true);
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Error Email Sent'));
                            }
                            else if (SendEmailResult==3)// Send both email and error email
                            {All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(ca_x_2.OwnerId).External_ID_gne__c.toLowerCase());
                                ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                                Send_Error_Email__c=true,
                                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(ca_x_2.OwnerId).Email);
                                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Error Email Sent,Manager not informed'));
                            }
                            system.debug('caupdate'+ca);
                            Caseaction_update.add(ca);
                            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Closed Case and Associated Case Actions'));
                        }
                        else
                        {
                            ca_x_2.Action_Status_internal_gne__c = 'Closed';
                            system.debug('caupdate'+ca);
                            Caseaction_update.add(ca_x_2);
                        }
                    }
                }
                // close the case
                c_case.recordtypeid=AGS_RecTypes_map.get('AGS Case Aggregate Closed RecordType').Id;
                c_case.Case_Status_gne__c= 'Closed';
                c_case.Case_Closed_Reason_gne__c = 'Issue Resolved';
                system.debug(' I am about to close case'+c_case);
                Case_update.add(c_case);
                //Add a closed task to the AGS CASE (Rename to addClosedAGSActivityToAGSCase) signalling email sent
                // Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
            }
        }
    }
    private void ProcessCaseClosedHCOResolve(AGS_Case_Action_gne__c c_CaseAction)
    {
        AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
        if(c_case.recordtype.name=='AGS Case Per Instance RecordType')//confirm if we need to add a condition to check for CCO case reason type to be per instance
        {
            // try sending email
            AGS_Case_Action_gne__c ca;
            Integer SendEmailResult=CloseCaseSendEmail(c_CaseAction);
            if (SendEmailResult==0)//try again
            ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Try_Email_Again__c=true);//close the action
            else if (SendEmailResult==1)//send email
            {  All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
                String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                // AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email,
                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id);
            }
            else if (SendEmailResult==2)//send error email
            {
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Error_Email__c=true);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent'));
            }
            else if (SendEmailResult==3)// Send both email and error email
            {  All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
                ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                Send_Error_Email__c=true,
                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(c_CaseAction.OwnerId).Email);
                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Error Email Sent,Manager not informed'));
            }
            Caseaction_update.add(ca);
            system.debug('ca test '+ca);
            c_case.recordtypeid=AGS_RecTypes_map.get('AGS Case Per Instance Closed RecordType').Id;
            c_case.Case_Status_gne__c= 'Closed';
            c_case.Case_Closed_Reason_gne__c = 'HCO to Resolve';
            Case_update.add(c_case);
            system.debug('case to upate'+c_case);
            //Add a closed task to the AGS CASE (Rename to addClosedAGSActivityToAGSCase) signalling email sent
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
            //fetch all case actions associated with the case and set to status close as the trigger does
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList) {
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c && ca_x_2.id!=c_CaseAction.id)
                {
                    ca_x_2.Action_Status_internal_gne__c = 'Closed';
                    Caseaction_update.add(ca_x_2);
                }
            }
            system.debug('all case action closed');
        }
        else
        if(c_case.recordtype.name=='' || c_case.recordtype.name==null || c_case.recordtype.name=='AGS Case Aggregate RecordType')
        {
            AGS_Case_Action_gne__c ca;
            Integer NumofCaseCloseActions=0;
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
            {
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c && Math.round(ca_x_2.Action_Value_gne__c)==112)
                NumofCaseCloseActions=NumofCaseCloseActions+1;
            }
            Integer NumOfExpectedCaseCloseActions=CaseSpendUserNumMap.get(c_case.Id);
            Integer SendEmailResult;
            if(NumofCaseCloseActions >= NumOfExpectedCaseCloseActions)
            { //send email for all case actions,close all case actions,close the case
                SendEmailResult=0;
                for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
                {
                    if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c )
                    {
                        if(Math.round(ca_x_2.Action_Value_gne__c)==112 && ca_x_2.Send_Email__c==false && ca_x_2.Send_Error_Email__c==false)
                        {
                            system.debug('ca_x_2 to check '+ca_x_2);
                            SendEmailResult=CloseCaseSendEmail(ca_x_2);
                            system.debug('SendEmailResult for'+ ca_x_2.id+' '+SendEmailResult);
                            if (SendEmailResult==1)//send email
                            {  All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(ca_x_2.OwnerId).External_ID_gne__c.toLowerCase());
                                String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
                                ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(ca_x_2.OwnerId).Email,
                                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c,
                                Resolver_FirstLevel_Manager_Email_gne__c= Manager_email_id);
                            }
                            else if (SendEmailResult==2)//send error email
                            {ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Error_Email__c=true);
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Error Email Sent'));
                            }
                            else if (SendEmailResult==3)// Send both email and error email
                            {All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(ca_x_2.OwnerId).External_ID_gne__c.toLowerCase());
                                ca = new AGS_Case_Action_gne__c (id=ca_x_2.id,Action_Status_internal_gne__c = 'Closed',Send_Email__c=true,
                                Send_Error_Email__c=true,
                                //AGS_Case_Resolver_Email_gne__c=Ownermap.get(ca_x_2.OwnerId).Email);
                                AGS_Case_Resolver_Email_gne__c=Owner_User_hierarchy.email_id__c);
                                tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Error Email Sent,Manager not informed'));
                            }
                            system.debug('caupdate'+ca);
                            Caseaction_update.add(ca);
                            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(ca_x_2,ca_x_2.OwnerId, 'Closed Case and Associated Case Actions'));
                        }
                        else
                        {
                            ca_x_2.Action_Status_internal_gne__c = 'Closed';
                            system.debug('caupdate'+ca);
                            Caseaction_update.add(ca_x_2);
                        }
                    }
                }
                // close the case
                c_case.recordtypeid=AGS_RecTypes_map.get('AGS Case Aggregate Closed RecordType').Id;
                c_case.Case_Status_gne__c= 'Closed';
                c_case.Case_Closed_Reason_gne__c = 'HCO to Resolve';
                system.debug(' I am about to close case'+c_case);
                Case_update.add(c_case);
                //Add a closed task to the AGS CASE (Rename to addClosedAGSActivityToAGSCase) signalling email sent
                //Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
            }
        }
    }
    private void ProcessAggrRecommSpendlimit(AGS_Case_Action_gne__c c_CaseAction)
    {
        AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
        if(c_case.Analyst_Response_Level_cco_gne__c == 'Low'
                && c_case.Reason_Type_gne__c=='Aggregation Rule' && c_case.Case_Status_gne__c =='Open')
        {
            //before creating case closed check if all Aggregate Recomm spending limit
            Boolean actioncheckflag=false;
            system.debug('AllCaseActionList  '+AllCaseActionList);
            for (AGS_Case_Action_gne__c ca_x_2 : AllCaseActionList)
            {
                system.debug(ca_x_2.AGS_Case_gne__c + ' '+ca_x_2.Send_Email__c+' '+ca_x_2.Send_Error_Email__c+' '+c_CaseAction.Action_Value_gne__c);
                if (ca_x_2.AGS_Case_gne__c == c_CaseAction.AGS_Case_gne__c &&
                        ca_x_2.Send_Email__c==False && ca_x_2.Send_Error_Email__c==False && Math.round(ca_x_2.Action_Value_gne__c)==131)
                actioncheckflag=True;
            }
            system.debug('actioncheckflag '+actioncheckflag);
            If(actioncheckflag==false)
            {
                //close the current action
                AGS_Case_Action_gne__c  curr_action=new AGS_Case_Action_gne__c(Id=c_CaseAction.Id,Action_Status_internal_gne__c='Closed');
                Caseaction_update.add(curr_action);
                AGS_Case_Action_gne__c ca_insert=AGS_CaseUtility.addNewCaseActionToCase_owner(c_case, 'Close Case - Issue Resolved',Ownermap.get(c_CaseAction.ownerid));
                //if (ca_insert.ownerid<>null) if owner is null then insert will fail and we will roll back everything
                system.debug('the owner of current action '+Ownermap.get(c_CaseAction.ownerid).Id+' external id '+Ownermap.get(c_CaseAction.ownerid).External_ID_gne__c);
                ca_insert.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect').Id;
                system.debug('close case action to insert '+ca_insert);
                Caseaction_insert.add(ca_insert);
            }
        }
    }
    private void ProcessEscalatedConfirmCompliance (AGS_Case_Action_gne__c c_CaseAction) {
        // if the user has responded change record type to read only ,Create case close- Issue Resolved
        AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
        if(c_CaseAction.AGS_Escalated_Confirm_Compliance_box_gne__c==true) { //user has responded CMap
            //close the action and change record type to read only irrespective of severity ,type etc
            AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',
            recordtypeid=AGS_RecTypes_map.get('AGS Case Action-EscalatedConfirmCompliance-Readonly-Rect').id);
            system.debug('case action with closed status and read only record type'+ca);
            Caseaction_update.add(ca);
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Resolver Acknowledged Case Action'));
            if(c_case.Analyst_Response_Level_cco_gne__c == 'Low'
                    &&  c_case.Infrequent_User__C==False
                    && c_case.Reason_Type_gne__c=='Instance Rule' && c_case.Case_Status_gne__c =='Open') {
                system.debug('case fetched'+c_case);
                system.debug('trying to create close case - Issue Resolved');
                AGS_Case_Action_gne__c ca_insert=AGS_CaseUtility.addNewCaseActionToCase(c_case, 'Close Case - Issue Resolved');
                //if (ca_insert.ownerid<>null) if owner is null then insert will fail and we will roll back everything
                ca_insert.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-CloseCase-Readonly-Rect').Id;
                system.debug('close case action to insert '+ca_insert);
                Caseaction_insert.add(ca_insert);
                //Add a closed task to the AGS CASE signalling the user validated the data email sent
                Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Closed Case and Associated Case Actions'));
                system.debug('Tasks inserted'+Tasks);
            }
        }
    }
    /* private void  ProcessSystemReopenCase(AGS_Case_Action_gne__c c_CaseAction) // method not needed these will be done by the case creation batch
        {   //open the case
            AGS_Case_gne__c c_case=CMap.get(c_CaseAction.AGS_Case_gne__c);
            c_case.Case_Closed_Reason_gne__c=null;
            c_case.Case_Status_gne__c='Open - Pending Manual Analysis';
            c_case.RecordTypeId = AGS_RecTypes_map.get('AGS Case Per Instance RecordType').Id;
            c_case.Analyst_Response_Level_cco_gne__c= 'Medium';
            Case_update.add(c_case);
            tasks.add(agsWorkflow.addClosedAGSActivityToAGSCase(c_CaseAction,c_CaseAction.id, 'Re-opened AGS Case'));
            //Close this system re-open action
            AGS_Case_Action_gne__c ca=new AGS_Case_Action_gne__c(id=c_CaseAction.Id,Action_Status_internal_gne__c = 'Closed');
            Caseaction_update.add(ca);
            //Also create PVD new requirement
            AGS_Case_Action_gne__c ca_insert=AGS_CaseUtility.addNewCaseActionToCase(c_case, 'Please Validate Data');
            //if (ca_insert.ownerid<>null) if owner is null then insert will fail and we will roll back everything
            ca_insert.recordtypeid=AGS_RecTypes_map.get('AGS Case Action-ValidateData-Edit-Rect').Id;
            system.debug('close case action to insert '+ca_insert);
            Caseaction_insert.add(ca_insert);
        }*/
    private void ProcessAggrSpendLimit (AGS_Case_Action_gne__c c_CaseAction)
    {   // Aggregate Spending limit reached is created only for high and medium severity cases hence no followup actions to be created atomatically
        // The case action is closed and record type chnaged to read only
        if(c_CaseAction.Ack_Stop_Spending_Limit_High_gne__c==true)
        {AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',
            recordtypeid=AGS_RecTypes_map.get('AGS Case Action-AcknowledgeStopSpending-Readonly-Rect').Id);
            Caseaction_update.add(ca);
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Resolver Acknowledged Case Action'));
        }
    }
    private void ProcessAggrLegalSpendLimit (AGS_Case_Action_gne__c c_CaseAction)
    {   // Aggregate Spending limit reached is created only for high and medium severity cases hence no followup actions to be created atomatically
        // The case action is closed and record type chnaged to read only
        if(c_CaseAction.Ack_Stop_Spending_Limit_High_gne__c==true)
        {AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c (id=c_CaseAction.id,Action_Status_internal_gne__c = 'Closed',
            recordtypeid=AGS_RecTypes_map.get('AGS Case Action-AcknowledgeStopSpending-Readonly-Rect').Id);
            Caseaction_update.add(ca);
            Tasks.add(AGS_CaseUtility.addClosedAGSActivityToAGSCase(c_CaseAction, c_CaseAction.OwnerId, 'Resolver Acknowledged Case Action'));
        }
    }
    private Integer CloseCaseSendEmail(AGS_Case_Action_gne__c c_CaseAction)
    {
        system.debug('Ownermap.get(c_CaseAction.OwnerId) '+ Ownermap.get(c_CaseAction.OwnerId));
        // String UserResult=UserManager.activateSFUser(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c,True);
        All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c.toLowerCase());
        if (Owner_User_hierarchy<>null) // user  activated sccesfully
        {
            //All_User_Hierarchy_gne__c Owner_User_hierarchy=UserExternalIdMap.get(Ownermap.get(c_CaseAction.OwnerId).External_ID_gne__c);
            system.debug('Owner_User_hierarchy '+Owner_User_hierarchy);
            //if (Owner_User_hierarchy!=Null)
            //{
            String Manager_email_id = Owner_User_hierarchy.All_User_Hierarchy_Level1_gne__r.email_id__c;
            System.debug('gaboo 5 Manager_email_id: ' +  Manager_email_id);
            if(String.isNotBlank(Manager_email_id))
            {
                System.debug('gaboo 6 Manager_email_id: ' +  Manager_email_id);
                return 1;
            }
            else
            { // 1st level manager is not active
                System.debug('gaboo 7 Manager_email_id: ' +  Manager_email_id);
                AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
                Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' send error email was marked as 1st level Manager not found on All User hierarchy record for the action owner.Note - Send Email was also marked to inform the action owner' ,
                Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
                ErrorLog_insert.add(el);
                return 3;
            }
        }
        else
        {
            //Action owner it self is not active
            AGS_Error_Log__c el=new AGS_Error_Log__c(Batch_Id__c=BatchId,Class_Name__c='AGS_PendingCaseActionsBatch',
            Custom_Error_Message__c='Case Action' +c_caseaction.name +' Id=' +c_caseaction.Id+' send error email was marked as action owner could not be activated ' ,
            Error_Type__c='Error',Method_Name__c='SendEmail',Object_Name__c='AGS Case Action');
            ErrorLog_insert.add(el);
            return 2;
        }
    }
    
    public override DateTime getNextJobScheduledRun() {
        return getNextJobName() == super.getNextJobName() ?
            super.getNextJobScheduledRun() : new AGS_UserActivationCaseActionsAssingment().getNextJobScheduledRun();
    }
    
    public override System.Type getNextJobClass() {
        return getNextJobName() == super.getNextJobName() ?
            super.getNextJobClass() : new AGS_UserActivationCaseActionsAssingment().getNextJobClass();
    }
    
    public override String getNextJobName() {
        return System.now().hour() > 17 || Test.isRunningTest() ?
            super.getNextJobName() : new AGS_UserActivationCaseActionsAssingment().getNextJobName();
    }
}