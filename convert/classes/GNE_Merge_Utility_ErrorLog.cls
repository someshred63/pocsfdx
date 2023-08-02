public class GNE_Merge_Utility_ErrorLog {

    static final String UNABLE_TO_LOG_ERROR  = 'Unable to log error';
    
    public static void  writeErrorLog (String parentRecordId,
                                       String objectName,
                                       String className, 
                                       Exception exceptionRecord) {               
        try {
        	   Error_log_gne__c errorLog     = new Error_log_gne__c();
        	   errorLog.error_level_gne__c   = 'High';
        	   errorLog.object_name__c       = objectName;
        	   errorLog.code_type__c         = 'Batch Apex Class';
        	   errorLog.snippet_name__c      = className;
        	   errorLog.error_description__c = 'Parent Record Id / Exception Recorded: ' + 
        	                                   parentRecordId + '/' + exceptionRecord.getMessage();        	   
        	   insert errorLog;        	
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 
                          UNABLE_TO_LOG_ERROR + ' ( ' + 
                          exceptionRecord.getMessage() + '). ' + 
                          'writeErrorLog exception --> ' + e.getMessage() );	
        }
    }

}