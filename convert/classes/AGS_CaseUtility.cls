public class AGS_CaseUtility {
    
     public static AGS_Case_Action_gne__c addNewAggReco_SpendingLimitReached(AGS_Case_gne__c caseInfo, string caAction, Map<String, RecordType> RecTypes_map) {
        AGS_Case_Action_gne__c newCA = new AGS_Case_Action_gne__c();
        newCA.ownerId = caseInfo.Resolver_gne__c;
        newCA.Action_gne__c = caAction;
        newCA.AGS_Case_gne__c = caseInfo.Id;
        newCA.Action_Status_internal_gne__c = 'Open';
        newCA.RecordTypeId = RecTypes_map.get('AGS Case Action-SendAggregationLimit-Edit-Rect').id;
        return newCA;
    }
    
    public static AGS_Case_Action_gne__c addNewSystem_Reopen(AGS_Case_gne__c caseInfo, string caAction,Map<String, RecordType> RecTypes_map) {
        AGS_Case_Action_gne__c newCA = new AGS_Case_Action_gne__c();
        newCA.ownerId = caseInfo.Resolver_gne__c;
        newCA.Action_gne__c = caAction;
        newCA.AGS_Case_gne__c = caseInfo.Id;
        newCA.Action_Status_internal_gne__c = 'Open';
        newCA.RecordTypeId = RecTypes_map.get('AGS Case Action - Reopen Record Type').id;
        system.debug ('New CA  : ' +newCA );
        return newCA;
    }
    
    public static AGS_Case_Action_gne__c addPleaseValidateData(AGS_Case_gne__c caseInfo, string caAction,Map<String, RecordType> RecTypes_map) {
        AGS_Case_Action_gne__c newCA = new AGS_Case_Action_gne__c();
        newCA.ownerId = caseInfo.Resolver_gne__c;
        newCA.Action_gne__c = caAction;
        newCA.AGS_Case_gne__c = caseInfo.Id;
        newCA.Action_Status_internal_gne__c = 'Open';
        newCA.RecordTypeId = RecTypes_map.get('AGS Case Action-ValidateData-Edit-Rect').id;
        newCA.AGS_Case_Analyst_Email_gne__c = caseInfo.Analyst_gne__r.Email;
        return newCA;
    }
    
    public static Task addClosedTaskToAGSCase(AGS_Case_Action_gne__c caseAction, string agsCaseResolverId, String notificationMessage, string recType) {
        //1.  Create a new Activity History Task and related it to the parent AGS Case
        //2.  Change the "Assigned To" field to be the Case Resolver and their User Manager
        //3.  Make the Subject match the Case Action and add what it did
        //4.  Set the "What ID" (Related To) to be the AGS Case.
        //5.  Set the Status to be Closed, this is just history tracking
        Task newTask = new Task();//1.
        newTask.AGS_isAGS_gne__c = true;
        system.debug('OWNER REFERENCE: '+agsCaseResolverId);
        newTask.ownerId = agsCaseResolverId; //2.
        newTask.subject = notificationMessage; //3.
        newTask.AGS_Case_Action_gne__c =caseAction.Action_gne__c; //'Please Validate Data';
        newTask.whatid = caseAction.AGS_Case_gne__c; //4.  Case Action Id (so it relates to the right one)//uncommented mar 30
        newTask.description = 'Please confirm AGS Case Action #' + caseAction.Name + ' Action: ' + caseAction.Action_gne__c; //5.
        newTask.Status = 'Completed';
        try {
            newTask.RecordTypeId = recType;
        }
        catch (Exception e) {
            e.setMessage('FAILURE TO CREATE TASK. Task RecordType for AGS does not exist.');
        }
        //Make Due Date equal to timestamp
        date myDate = date.today();
        newTask.ActivityDate = myDate;
        datetime myDateTime = datetime.now();
        newTask.Closed_Date_gne__c = myDateTime;
        return newTask;
    }
    
    public static AGS_Case_Action_gne__c addNewCaseActionToCase(AGS_Case_gne__c caseInfo, string caAction) {
        //1. Create a new AGS Case Action
        //1.1 Pick the correct Action depending on what it's spposed to be
        //2. Once inserted, the original trigger should pick it up and do what's necessary
        AGS_Case_Action_gne__c newCA = new AGS_Case_Action_gne__c();//1.
        String UserResult=UserManager.activateSFUser(caseInfo.Inactive_resolver__r.User_External_Id_gne__c,True);
        if (UserResult.substring(0,6)<>'Error' && UserResult.length()==18) {// user activated sccesfully
             newCA.ownerId = UserResult; //2.
        }
        newCA.Action_gne__c = caAction; //3.
        newCA.AGS_Case_gne__c = caseInfo.Id; //4.  Case Action Id (so it relates to the right one)
        newCA.Action_Status_internal_gne__c = 'Open'; //5.
        newCA.AGS_Case_Analyst_Email_gne__c = caseInfo.Analyst_gne__r.Email;
        return newCA;
    }
    
    public static AGS_Case_Action_gne__c addNewCaseActionToCase_owner(AGS_Case_gne__c caseInfo, string caAction,User actionowner){
        //1.  Create a new AGS Case Action
        //1.1 Pick the correct Action depending on what it's spposed to be
        //2.  Once inserted, the original trigger should pick it up and do what's necessary
        AGS_Case_Action_gne__c newCA = new AGS_Case_Action_gne__c();//1.
        newCA.ownerId = actionowner.Id; //2.
        newCA.Action_gne__c = caAction; //3.
        newCA.AGS_Case_gne__c = caseInfo.Id; //4.  Case Action Id (so it relates to the right one)
        newCA.Action_Status_internal_gne__c = 'Open'; //5.
        newCA.AGS_Case_Analyst_Email_gne__c = caseInfo.Analyst_gne__r.Email;
        return newCA;
    }
    
    public static AGS_Case_Activity_History__c addClosedAGSActivityToAGSCase( AGS_Case_Action_gne__c caseAction,string agsCaseResolverId, String notificationMessage) {
        //1.  Create a new custom Activity History and related it to the parent AGS Case
        //2.  Change the "Assigned To" field to be the Case Resolver and their User Manager
        //3.  Make the Subject match the Case Action and add what it did
        //4.  Set the Related To to be the AGS Case.
        //5.  Set the Status to be Closed, this is just history tracking
        AGS_Case_Activity_History__c newTask = new AGS_Case_Activity_History__c();//1
        newTask.ownerId = agsCaseResolverId;//2
        newTask.Assigned_To__c=agsCaseResolverId;
        newTask.Subject__c = notificationMessage;//3
        if(caseAction.Action_gne__c == 'Action Required - Reminder'||caseAction.Action_gne__c == 'Action Required - Overdue'||caseAction.Action_gne__c == 'Action Required - Manager Escalated') {
            string latencycaseactionName = caseAction.AGS_Case_Action_Latency__r != null ? caseAction.AGS_Case_Action_Latency__r.Name : '';
            system.debug('latencycaseactionName');
            newTask.AGS_Case_Action__c =caseAction.Action_gne__c +' for Case action #'+latencycaseactionName;
        } else {
            newTask.AGS_Case_Action__c =caseAction.Action_gne__c +' #'+caseAction.Name; //'Please Validate Data';
        }
        newTask.Related_To__c = caseAction.AGS_Case_gne__c; //4.  Case Action Id (so it relates to the right one)//uncommented mar 30
        newTask.Status__c = 'Completed';
        return newTask;
    }
    
    public static void insertFailedToDeleteErrorLog(String batchid, String className, String errorMessage) {
        try {
            AGS_Error_Log__c errorLog = new AGS_Error_Log__c(
                Batch_Id__c = batchid,
                Class_Name__c = className,
                Custom_Error_Message__c = 'There was and error deleting completed jobs',
                System_Error_Message__c = errorMessage,
                Error_Type__c = 'Error',
                Method_Name__c = 'execute',
                Object_Name__c = 'Crontrigger');
            insert errorLog;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    public static void insertBatchStartedErrorLog(Id batchId, String className, String errorMessage) {
        Database.insert(new AGS_Error_Log__c(
            Custom_Error_Message__c = errorMessage + batchId,
            Method_Name__c = 'execute',
            Class_Name__c = className,
            Error_Type__c = 'Success',
            Batch_Id__c = batchId
        ), false);
    }
    
    public static void abortCompletedJobs(String className) {
        Id lastBatchId;
        try {
            for (CronTrigger cr : [SELECT Id FROM CronTrigger WHERE State = 'Complete']) {
                System.abortJob(lastBatchId = cr.Id);
            }
        } catch (Exception e) {
            AGS_CaseUtility.insertFailedToDeleteErrorLog(lastBatchId, className, e.getMessage());
        }
    }
}