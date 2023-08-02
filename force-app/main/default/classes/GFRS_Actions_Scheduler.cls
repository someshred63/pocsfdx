/**
 * Created by pawlowsl on 2017-08-30.
 */

global without sharing class GFRS_Actions_Scheduler implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    private class GFRS_EmailMessage{
        public SObject sObj;
        public Messaging.SingleEmailMessage message;
        public GFRS_Scheduled_Action_Interface action;

        public GFRS_EmailMessage(SObject sObj, Messaging.SingleEmailMessage message, GFRS_Scheduled_Action_Interface action) {
            this.sObj = sObj;
            this.message = message;
            this.action = action;
        }
    }

    public static String SCHEDULED_ACTION_RECONCILATION_REQUESTED = 'Reconciliation Requested';
    public static String SCHEDULED_ACTION_RECONCILATION_FIRST_REMINDER = 'Reconcilation First Reminder';
    public static String SCHEDULED_ACTION_RECONCILATION_SECOND_REMINDER = 'Reconcilation Second Reminder';
    public static String SCHEDULED_ACTION_RECONCILATION_LOCKOUT = 'Reconcilation Lockout';

    public static String SCHEDULED_ACTION_SUNSHINE_REQUESTED = 'Sunshine Requested';
    public static String SCHEDULED_ACTION_SUNSHINE_FIRST_REMINDER = 'Sunshine First Reminder';
    public static String SCHEDULED_ACTION_SUNSHINE_SECOND_REMINDER = 'Sunshine Second Reminder';

    public static String getReconciliationCronExp() {
        return GFRS_OrgSettings__c.getOrgDefaults().Act_Sched_Reconciliation_Cron_Exp__c;
    }

    public static String getSunshineCronExp() {
        return GFRS_OrgSettings__c.getOrgDefaults().Act_Sched_Sunshine_Cron_Exp__c;
    }

    public static String getReconcilationQuery() {
        return
            'SELECT  Id, Reconciliation_Required_Status_Date__c, Program_End_Date_max__c, Sub_Status__c, External_Sub_status__c, OwnerId, Contact__r.Email, ' +
            '(SELECT Id, Subject__c, CreatedDate, gFRS_Funding_Request__c, Action_Type__c, Status__c FROM gFRS_Tasks__r WHERE Action_Type__c != NULL AND Action_Type__c = \'' + gFRS_Util.TASK_RECONCILIATION + '\') ' +
            'FROM GFRS_Funding_Request__c WHERE ' +
            'RecordType.Name = \'' +  GFRS_Util.TYPE_IMED_NAME + '\' AND ' +
            'Status__c = \'' +  GFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION + '\' AND ' +
            'LOA_Signed__c = \'' +  'Yes' + '\' AND ' +
            'SYS_Request_Approved__c = \'' +  'Yes' + '\' AND ' +
            'Program_End_Date_max__c != NULL AND ' +
            'SAP_Payment_ID__c != NULL AND ' +
            'Reconciliation_Completed__c != \'Yes\'';
    }

    public static String getSunshineQuery() {
        return
            'SELECT  Id, Sunshine_Communication_Sent__c, Sunshine_Act_Disclosure_Submitted__c, Last_Live_Program_End_Date__c, Sub_Status__c, External_Sub_status__c, RecordType.Name, OwnerId, ' +
            '(SELECT Id, Subject__c, CreatedDate, gFRS_Funding_Request__c, Action_Type__c, Status__c FROM gFRS_Tasks__r WHERE Action_Type__c != NULL AND Action_Type__c = \'' + gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE + '\') ' +
            'FROM GFRS_Funding_Request__c WHERE ' +
            'RecordType.Name = \'' +  GFRS_Util.TYPE_IMED_NAME + '\' AND ' +
            'Status__c = \'' +  GFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION + '\' AND ' +
            'LOA_Signed__c = \'' +  'Yes' + '\' AND ' +
            'Last_Live_Program_End_Date__c != NULL AND ' +
            'SAP_Payment_ID__c != NULL AND ' +
            'Sunshine_Communication_Sent__c = FALSE AND ' +
            'Sunshine_Act_Disclosure_Submitted__c != \'Yes\'';
    }

    public static Integer getScheduledActionsBatchSize() {
        Integer batchSize = (Integer)GFRS_OrgSettings__c.getOrgDefaults().Act_Sched_Batch_Size__c;
        return batchSize != null && batchSize != 0? batchSize : 200;
    }

    List<String> supportedScheduledActions;

    Database.QueryLocator queryLocator;

    String query;

    public gFRS_Actions_Scheduler(List<String> supportedScheduledActions, String query) {
        this.supportedScheduledActions = supportedScheduledActions;
        this.query = query;
    }

    private static Boolean isJobAlreadyInProgress() {
        return ![
                SELECT Id, ApexClass.Name, CreatedDate, JobItemsProcessed, TotalJobItems, ApexClassId
                FROM AsyncApexJob
                WHERE Status NOT IN ('Aborted', 'Completed', 'Failed')
                AND JobType = 'BatchApex'
                AND ApexClass.Name = :GFRS_Actions_Scheduler.class.getName()
        ].isEmpty();
    }

    public static Boolean editEnabled() {
        return isJobAlreadyInProgress()? GFRS_OrgSettings__c.getInstance().Act_Sched_Bypass_Validations__c : true;
    }

    public void schedule(String scheduledActionName, STRING CRON_EXP) {
        system.schedule(scheduledActionName, CRON_EXP, this);
    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(this, getScheduledActionsBatchSize());
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(this.query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {

        System.debug('GFRS Actions Scheduler Batch');
        System.debug(scope);
        System.debug(scope.size());

        List<GFRS_Scheduled_Action_Interface> actions = new List<GFRS_Scheduled_Action_Interface>();

        for(String actionType : supportedScheduledActions) {

            GFRS_Scheduled_Actions__c actionDefinition = GFRS_Scheduled_Actions__c.getValues(actionType);

            Type t = Type.forName(actionDefinition.Apex_Interface__c);
            GFRS_Scheduled_Action_Interface action = (GFRS_Scheduled_Action_Interface)t.newInstance();
            action.initialize(actionDefinition);

            actions.add(action);

        }

        List<SObject> sObjectsToUpdate = new List<SObject>();

        List<GFRS_EmailMessage> messages = new List<GFRS_EmailMessage>();

        for(SObject sObj : scope) {

            System.debug(sObj);

            for(GFRS_Scheduled_Action_Interface action : actions) {

                System.debug(action.getEmailTemplateName());

                if(action.invokable(sObj)) {
                    
                    if(GFRS_OrgSettings__c.getOrgDefaults().Send_Scheduled_Action_Emails__c){
                        
                        Messaging.SingleEmailMessage message = GFRS_NotificationUtil.prepareEmailMessage(
                            GFRS_NotificationUtil.getGFRSCommunicationContactId(),
                            sObj.Id,
                            action.getEmailTemplateName(),
                            null
                        );

                        messages.add(new GFRS_EmailMessage(sObj, message, action));
                        
                    }

                    

                    SObject changedRecord = action.invokeChangeRecord(sObj);
                    System.debug(changedRecord);
                    if(changedRecord != null)
                        sObjectsToUpdate.add(changedRecord);
                }

            }

        }

        Savepoint sp = Database.setSavepoint();
        GFRS_NotificationUtil.sendNotifications(false);
        Database.rollback(sp);

        for(GFRS_EmailMessage message : messages) {
            GFRS_NotificationUtil.prepareEmailMessage(
                message.action.getTargetObject(message.sObj),
                null,
                message.action.getRecipients(message.sObj),
                message.action.getEmailTemplateCC(),
                message.action.getBCCRecipients(message.sObj),
                message.action.getEmailTemplateName(),
                message.action.prepareMergedFields(message.sObj),
                false,
                message.message);
        }

        GFRS_NotificationUtil.sendNotifications();

        System.debug(sObjectsToUpdate);

        if(sObjectsToUpdate.size() > 0) {
            update sObjectsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}