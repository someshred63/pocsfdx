public abstract class GNE_ETL_DataExchangeSupport implements Database.Stateful {

    protected String objectName = 'Copy Task To Task Replica';        

    protected Integer runtimeErrorCount = 0;
    protected Integer recordReadCount = 0;
    protected Integer recordInsertCount = 0;
    protected Integer recordUpdateCount = 0;
    protected Integer recordDeleteCount = 0;
    protected Integer recordFailCount =0;
        
    protected User etladminUser = null;
    protected User etlcaUser = null;
    
    protected void init () {
    	
    	String sandbox        = Utilities.getEnvironmentName();
    	String etladminUsername   = 'etladmin@gene.com';
    	String etlcaadminUsername = 'etladmin_canada@gene.com';
        
        if ( sandbox.equalsIgnoreCase('prod') == false ) {
            etladminUsername += '.' + sandbox;
            etlcaadminUsername += '.' + sandbox;        	
        }    	 
           	
    	etladminUser = [select id from user where username = :etladminUsername ];
        etlcaUser = [select id from user where username = :etlcaadminUsername ];        
    }
    
    protected void doFinish(Database.BatchableContext BC){

        try {
            AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name, 
                              JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                              createdDate, completedDate 
                              from AsyncApexJob 
                              where Id =:BC.getJobId()
                              ];
            User createdUser = a.CreatedBy;
            ApexClass batchApexClass = a.ApexClass;
                                              
            // Send an email to the Apex job's submitter notifying of job completion.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = System.Label.ETL_Support_Email_List_gne.split(',');
            mail.setToAddresses(toAddresses);
            mail.setSubject('Apex Job ' + + objectName + 
                            ' status ' + a.Status);

            mail.setPlainTextBody
                            ('The batch Apex job ' + batchApexClass.Name + 
                            '(' + objectName + ') processed '    + a.TotalJobItems +
                            ' batches with ' + a.NumberOfErrors + ' failures.\n' + 
                            'Batch Job StartTime / CompletedTime ' + 
                            a.CreatedDate + '/' + a.CompletedDate +  '.\n\n' + 
                            'Total Records Read, Insert, Update, Delete, Fail & Runtime Error Count: ' + 
                            recordReadCount + '/' + 
                            recordInsertCount + '/' + 
                            recordUpdateCount + '/' + 
                            recordDeleteCount + '/' + 
                            recordFailCount + '/' + 
                            runtimeErrorCount );                                                          
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 'Unable to send email ' + e.getStackTraceString() );    
        }

    }
}