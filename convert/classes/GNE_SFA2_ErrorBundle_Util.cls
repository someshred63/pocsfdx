public with sharing class GNE_SFA2_ErrorBundle_Util{                  
             
             
    static final String UNABLE_TO_LOG_ERROR  = 'Unable to log error';        
       
    public static void  writeErrorLog (String objectName,
                                       String methodName, 
                                       Exception exceptionRecord) {               
        try {
               Error_log_gne__c errorLog     = new Error_log_gne__c(
                 error_level_gne__c   = 'High',
                 object_name__c       = objectName,
                 code_type__c         = 'ETL Replicator',
                 snippet_name__c      = methodName,
                 error_description__c =  exceptionRecord.getMessage()  + ':' +  
                                         exceptionRecord.getCause() + ':' +
                                         exceptionRecord.getStackTraceString() );            
               insert errorLog;         
        } catch (Exception e) {
            System.debug (LoggingLevel.INFO, 
                          UNABLE_TO_LOG_ERROR + ' ( ' + 
                          exceptionRecord.getMessage() + '). ' + 
                          'writeErrorLog exception --> ' + e.getStackTraceString() );    
        }
    }
    
    

}