public virtual without sharing class GNE_CAN_Subscribe_Batchable {
    
    private GNE_CAN_Subscribe_Process subscribeProcess;
    public GNE_CAN_Subscribe_Metrics mainMetrics;
    private Stg_SFA_Subscribe_Apex_Job__c currentApexJob;
    private Set<Id> stgCustIds;
    private Boolean incrementalMode;
    private String customerClass;
    
    public GNE_CAN_Subscribe_Batchable(Set<Id> stgCustIds, Boolean incrementalMode) {
        this.stgCustIds = stgCustIds;
        this.incrementalMode = incrementalMode;
        subscribeProcess = new GNE_CAN_Subscribe_Process();
        mainMetrics = new GNE_CAN_Subscribe_Metrics();
    }
    
    protected Database.QueryLocator doStart(Database.BatchableContext BC, String a_customerClass) {
    	customerClass = a_customerClass;
        LoggingLevel lLevel = GNE_CAN_Subscribe_Util.SFDC_DEBUG_LOGGING_LEVEL;
        String jobType = customerClass + (stgCustIds!=null ? '_SINGLE' : '_FULL');
        Stg_SFA_Subscribe_Apex_Job__c lastJob;
        
        for(Stg_SFA_Subscribe_Apex_Job__c job : [SELECT CreatedDate, LastModifiedDate FROM Stg_SFA_Subscribe_Apex_Job__c
                                                 WHERE Job_Type_can__c = :jobType
                                                 ORDER BY CreatedDate desc
                                                 LIMIT 1]) {
            lastJob = job;
            break;                                      
        }
        currentApexJob = new Stg_SFA_Subscribe_Apex_Job__c(
            Job_Type_can__c = jobType,
            Logging_Level_can__c = lLevel!=null ? lLevel.name() : null);
        insert currentApexJob;
        
        // Critical error - abort subscribe process, Accounts Owner must be determined in the settings
        if(GNE_CAN_Subscribe_Util.RECORD_OWNER_ID==null) {
        	throw new GNE_CAN_Subscribe_Util.SubscribeException(GNE_CAN_Subscribe_Util.KnownException.ACCOUNT_OWNER_NOT_SET.name());
        }
    
        if(stgCustIds!=null) { // selected customers mode
            System.debug('SELECTED RECORDS MODE');
            return Database.getQueryLocator([
                SELECT Roche_Cust_Id_can__c, Prim_IMS_Id_can__c, UCI_Id_can__c
                FROM Stg_SFA_Cust_Can__c 
                WHERE Cust_class_can__c = :customerClass
                    AND Id IN :stgCustIds
            ]);
        } else if(incrementalMode && lastJob!=null) { // incrementalMode
            System.debug('INCREMENTAL MODE');
            return Database.getQueryLocator([
                SELECT Roche_Cust_Id_can__c, Prim_IMS_Id_can__c, UCI_Id_can__c
                FROM Stg_SFA_Cust_Can__c 
                WHERE Cust_class_can__c = :customerClass
                    AND (Last_Subscribe_Date_can__c = null // include if record was never subscribed 
                        OR Subscribe_Status_can__c <> :GNE_CAN_Subscribe_Util.SUBSCRIBE_STATUS_SUCCESS // or was subscribed with errors
                        OR LastModifiedDate > :lastJob.LastModifiedDate) // or was modified after last subscribe process
            ]);
        } else { // all customers mode
            System.debug('ALL RECORDS MODE');
            return Database.getQueryLocator([
                SELECT Roche_Cust_Id_can__c, Prim_IMS_Id_can__c, UCI_Id_can__c
                FROM Stg_SFA_Cust_Can__c 
                WHERE Cust_class_can__c = :customerClass
            ]);
        }
    }
    
    protected void doExecute(Database.BatchableContext BC, List<sObject> scope) {       
        List<Id> custIds = new List<Id>();
        for(sObject recordFromScope : scope) {
        	custIds.add(recordFromScope.Id);
        }
        
        subscribeProcess.executeSubscribe(custIds, currentApexJob, mainMetrics);
    }
    
    protected void doFinish(Database.BatchableContext BC) {
        String metricsInfo = mainMetrics.print(currentApexJob);
        GNE_CAN_Subscribe_Util.addDebugMessage(metricsInfo);
        
        currentApexJob.Log_can__c = metricsInfo;
        update currentApexJob;
        
        sendSummaryMail();
    }
    
    protected void sendSummaryMail() {
    	String jobName =  currentApexJob.Job_Type_can__c.replace('_', ' ') + ' Subscribe Process';
        //Create a new single email message object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String addr = GNE_CAN_Subscribe_Util.NOTIFICATION_EMAIL;
        //Address
        email.setToAddresses(new String[] {addr});
        // Subject
        email.setSubject(jobName + ' finished');
        
        String summary = jobName + ' finished: ' + DateTime.now() + '\n';
        summary += mainMetrics.print(currentApexJob);
                    
        //Content
        email.setPlainTextBody(summary);
        //Attachment
        GNE_CAN_Csv_Helper csvHelper = new GNE_CAN_Csv_Helper('Stg_SFA_Subscribe_Apex_Job_Error__c', String.valueOf(currentApexJob.Id));
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {csvHelper.getAttachment()});
        //Send
        List<Messaging.Sendemailresult> error = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        if (!error[0].isSuccess()){
        	GNE_CAN_Subscribe_Util.addDebugMessage('Couldn\'t send metrics summary email to address \'' + addr + '\'!');
        }
    }
}