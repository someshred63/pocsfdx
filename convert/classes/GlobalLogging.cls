/************************************************************
*  @author: Sebastian Wajrych, Roche
*  Date: 2010-10-19
*  Description: 
*  The class gives generic logging functionality                         
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
public class GlobalLogging {

	private String className;
	public List<Error_log_gne__c> logs = new List<Error_log_gne__c>();
		
	public GlobalLogging(String className){
		this.className = className; 
	}
	
	//errorLevel
	public static final String LEVEL_HIGH = 'high';
	public static final String LEVEL_LOW = 'low';
	
	//objectType
	public static final String TYPE_CLASS = 'Apex Class';
			
	private static final String LOGGING_ERROR = 'error';
	private static final String LOGGING_WARN = 'warn';
	private static final String LOGGING_DEBUG = 'debug';
	private static final String LOGGING_INFO = 'info';
	private static final String LOGGING_FINE = 'fine';
	private static final String LOGGING_FINER = 'finer';
	private static final String LOGGING_FINEST = 'finest';
			
	/**
	*	Diff levels of logging
	*/
	//ERROR
	public void error(String errorLevel, String objectType, String errorDescription, String objectName, String recordId ){
		addLog(GlobalLogging.LOGGING_ERROR, errorLevel, objectType, objectName, recordId, errorDescription, false); 
	}
	public void errorAndSave(String errorLevel, String objectType, String errorDescription, String objectName, String recordId){ 
		addLog(GlobalLogging.LOGGING_ERROR, errorLevel, objectType, objectName, recordId, errorDescription, true);
	}
	
	//WARN
	public void warn(String errorLevel, String objectType, String errorDescription, String objectName, String recordId ){
		addLog(GlobalLogging.LOGGING_WARN, errorLevel, objectType, objectName, recordId, errorDescription, false);
	}
	public void warnAndSave(String errorLevel, String objectType, String errorDescription, String objectName, String recordId){ 
		addLog(GlobalLogging.LOGGING_WARN, errorLevel, objectType, objectName, recordId, errorDescription, true);
	}
	
	//INFO
	public void info(String errorLevel, String objectType, String errorDescription, String objectName, String recordId ){
		addLog(GlobalLogging.LOGGING_INFO, errorLevel, objectType, objectName, recordId, errorDescription, false);
	}
	public void infoAndSave(String errorLevel, String objectType, String errorDescription, String objectName, String recordId){ 
		addLog(GlobalLogging.LOGGING_INFO, errorLevel, objectType, objectName, recordId, errorDescription, true);
	}
	
	//DEBUG
	public void debug(String errorLevel, String objectType, String errorDescription, String objectName, String recordId ){ 
		addLog(GlobalLogging.LOGGING_DEBUG, errorLevel, objectType, objectName, recordId, errorDescription, false);
	}
	public void debugAndSave(String errorLevel, String objectType, String errorDescription, String objectName, String recordId){ 
		addLog(GlobalLogging.LOGGING_DEBUG, errorLevel, objectType, objectName, recordId, errorDescription, true);
	}
	
	//FINE
	public void fine(String errorLevel, String objectType, String errorDescription, String objectName, String recordId ){
		addLog(GlobalLogging.LOGGING_DEBUG, errorLevel, objectType, objectName, recordId, errorDescription, false);
	}
	public void fineAndSave(String errorLevel, String objectType, String errorDescription, String objectName, String recordId){ 
		addLog(GlobalLogging.LOGGING_FINE, errorLevel, objectType, objectName, recordId, errorDescription, true);
	}
	
	//FINER
	public void finer(String errorLevel, String objectType, String errorDescription, String objectName, String recordId ){
		addLog(GlobalLogging.LOGGING_DEBUG, errorLevel, objectType, objectName, recordId, errorDescription, false);
	}
	public void finerAndSave(String errorLevel, String objectType, String errorDescription, String objectName, String recordId){ 
		addLog(GlobalLogging.LOGGING_FINER, errorLevel, objectType, objectName, recordId, errorDescription, true);
	}
		
	//FINEST
	public void finest(String errorLevel, String objectType, String errorDescription, String objectName, String recordId ){
		addLog(GlobalLogging.LOGGING_DEBUG, errorLevel, objectType, objectName, recordId, errorDescription, false);
	}
	public void finestAndSave(String errorLevel, String objectType, String errorDescription, String objectName, String recordId){ 
		addLog(GlobalLogging.LOGGING_FINEST, errorLevel, objectType, objectName, recordId, errorDescription, true);
	}
	
	/**
	* Main logic of logging
	*/
	private void addLog(String loggingLevel, String errorLevel, String objectType, String objectName, String recordId, String errorDescription, Boolean saveAfterAdd){
		
		//TODO:add checking logging level in Properties and depending on this log or not
		
		if(loggingLevel==LOGGING_DEBUG){
			System.debug('LOGGING[DEBUG] = '+objectType + ':'+this.className +', objectName:' + objectName + ', recordId='+ recordId +', Description:['+errorDescription+']');
		}
				
		logs.add(new Error_log_gne__c(Error_Level_gne__c	= errorLevel,
        							  Code_Type__c      	= objectType,
        							  Snippet_Name__c   	= this.className,
        							  User_Name__c			= UserInfo.getUserName(),
        							  Object_Name__c    	= objectName,			
        							  Record_Id_gne__c		= recordId,							
        							  Error_Description__c 	= errorDescription
        							 ));
		
		//if method executed from exception
		if(saveAfterAdd){
			save();
		}	
	}
	
	/**
	* Persisting logs
	*/
	public void save(){
		try {        	        	
            Database.UpsertResult[] results = Database.upsert(logs, false);
            logs.clear();
		} catch (Exception e) { 
			System.debug('Error: ' + e.getMessage()); 
        }
	}
}