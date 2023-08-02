public with sharing class GNE_SFA2_PFG_ExceptionHandler {
	
	private static Set<String> sessionLabels;
	private static List<ExceptionInfo> exceptionInfoCache;
	
	public static void addSessionLabel(String label) {
		if(sessionLabels==null) {
			sessionLabels = new Set<String>();
		}
		
		sessionLabels.add(label);
	}
	
	public static Set<String> getSessionLabels() {
		return sessionLabels;
	}
	
	public static void setSessionLabels(Set<String> a_sessionLabels) {
		sessionLabels = a_sessionLabels;
	}
	
	public static void handleException(Exception ex) {
    	if(exceptionInfoCache==null) {
    		exceptionInfoCache = new List<ExceptionInfo>();
    	}
    	
    	exceptionInfoCache.add(new ExceptionInfo(ex));
    }
    
    public static void reportExceptions() {
    	if(exceptionInfoCache!=null && !exceptionInfoCache.isEmpty()) {
    		if(System.isBatch() || System.isFuture() || System.isScheduled()) {
    			intReportExceptions();
    		} else {
    			futureReportExceptions(JSON.serialize(exceptionInfoCache), JSON.serialize(sessionLabels));
    			exceptionInfoCache = null;
    		}
    	}
    }
    
    @future
    public static void futureReportExceptions(String exceptionInfosJSON, String sessionLabelsJSON) {
    	exceptionInfoCache = (List<ExceptionInfo>)JSON.deserializeStrict(exceptionInfosJSON, List<ExceptionInfo>.class);
    	sessionLabels = (Set<String>)JSON.deserializeStrict(sessionLabelsJSON, Set<String>.class);
    	intReportExceptions();
    }
    
    public static void intReportExceptions() {
    	insertErrorLogs();
    	sendErrorEmailNotification();
    	exceptionInfoCache = null;
    }
    
    public static void insertErrorLogs() {
    	if(exceptionInfoCache!=null && !exceptionInfoCache.isEmpty()) {
    		List<Error_Log_gne__c> errorLogs = new List<Error_Log_gne__c>();
    	   	for(ExceptionInfo exInfo : exceptionInfoCache) {
    	   		errorLogs.add(exInfo.convertToErrorLog());
    	   	}
    	   	
    	   	Database.DMLOptions dml = new Database.DMLOptions();
        	dml.allowFieldTruncation = true;
        	dml.optAllOrNone = false;
    		Database.Saveresult[] saveResults = Database.insert(errorLogs, dml);
    		
    		for(Database.Saveresult result : saveResults) {
    			if(!result.isSuccess()) {
    				for(Database.Error err : result.getErrors()) {
    					System.debug('Error while inserting PFG Error: ' + err.getMessage());
    				}
    			}
    		}
    	}
    }
    
    public static void sendErrorEmailNotification() {
    	if(exceptionInfoCache!=null && !exceptionInfoCache.isEmpty()) {
    		String subject = '[PFG] Raised Exceptions (' + exceptionInfoCache.size() + ')';
    		String message = 'List of Exceptions:\n';
    		
    		Integer idx = 1;
    		for(ExceptionInfo exInfo : exceptionInfoCache) {
    			message += idx++ + '. ' + exInfo.getEmailDescription() + '\n';
    		}
    		
    		sendEmailNotification(subject, message);
    	}
    }
    
    public static void sendEmailNotification(String subject, String message) {
    	sendEmailNotification(GNE_SFA2_PFG_Config.ERROR_NOTIFICATION_EMAILS, subject, message, false);
    }
    
    public static void sendEmailNotification(String subject, String message, Boolean isHtmlBody) {
    	sendEmailNotification(GNE_SFA2_PFG_Config.ERROR_NOTIFICATION_EMAILS, subject, message, isHtmlBody);
    }
    
    public static void sendEmailNotification(List<String> emailAddresses, String subject, String message) {
    	sendEmailNotification( emailAddresses, subject, message, false);
    }
    
    public static void sendEmailNotification(List<String> emailAddresses, String subject, String message, Boolean isHtmlBody) {
    	message = getUserInfoDescription(isHtmlBody) + getSessionLabelsDescription(isHtmlBody) + (message!=null ? '\n' + message : '');
    		
    	if(!emailAddresses.isEmpty()) {
			//Create a new single email message object
	        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage();
	        emailMsg.setCharset('UTF-8');
	        //Address
	        emailMsg.setToAddresses(emailAddresses);
	        // Subject
	        emailMsg.setSubject(subject);
	        //Content
	        if(isHtmlBody==true) {
	        	emailMsg.setHtmlBody(message!=null ? message : '');
	        } else {
	        	emailMsg.setPlainTextBody(message!=null ? message : '');
	        }
	        //Send
	        List<Messaging.Sendemailresult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailMsg});
		    
		    for(Messaging.Sendemailresult result : results) {
		    	if (!result.isSuccess()){
			    	for(Messaging.SendEmailError err : result.getErrors()) {
			       		System.debug('Couldn\'t send PFG Email Notification. Reason: ' + err.getMessage());
			    	}
			    }	
		    }
		}
    }
    
    private static String getUserInfoDescription(Boolean isHtmlMode) {
    	String userDesc;
    	List<String> userInfos = new List<String>{
    			UserInfo.getName(), UserInfo.getUserId(), UserInfo.getUserName(), 
    			UserInfo.getOrganizationName(), UserInfo.getOrganizationId()};
    	
    	if(isHtmlMode==true) {
    		userInfos.add(getSalesforceURL(UserInfo.getUserId()));
    		userInfos.add(getSalesforceURL(UserInfo.getOrganizationId()));
    		userDesc = String.format('User: <a href="{5}">{0} ({2})</a><br/>Organization: <a href="{6}">{3}</a><br/>', userInfos);
    	} else {
    		userDesc = String.format('User: {0} ({1}, {2})\nOrganization: {3} ({4})\n', userInfos);
    	}
    	
    	return userDesc;
	}
	
	private static String getSessionLabelsDescription(Boolean isHtmlMode) {
		String sessionLabelsDesc = (sessionLabels!=null && !sessionLabels.isEmpty()) 
				? ('Session Labels: ' + String.join(new List<String>(sessionLabels), ', ') + (isHtmlMode==true ? '<br/>' : '\n')) 
				: '';
		return sessionLabelsDesc;
	}
	
	public static String getSalesforceURL(String objectId) {
		return URL.getSalesforceBaseUrl().toExternalForm() + '/' + objectId;
	}
	
	public static String getSalesforceLink(String objectId, String objectName) {
		return String.format('<a href="{0}">{1}</a>', new String[]{getSalesforceURL(objectId), objectName});
	}
	
	public class ExceptionInfo {
    	private String codeType;
    	private String errorLevel;
    	private String errorMessage;
    	private String errorStackTrace;
    	private String errorType;
    	private String snippetName;
    	
    	public ExceptionInfo(Exception ex) {
    		codeType = 'PFG';
    		errorLevel = 'High';
    		errorMessage = ex.getMessage();
    		errorStackTrace = ex.getStackTraceString();
    		String exType = ex.getTypeName();
    		errorType = exType.contains('.') ? exType.substringAfterLast('.') : exType;
    		snippetName = exType.contains('.') ? exType.substringBeforeLast('.') : null;
    	}
    	
    	public Error_Log_gne__c convertToErrorLog() {
    		return new Error_Log_gne__c(
    				Code_Type__c = codeType,
    				Error_Description__c = String.format('{0}\n{1}{2}', new String[]{errorMessage, getSessionLabelsDescription(false), errorStackTrace}),
    				Error_Level_gne__c = errorLevel,
    				Record_Id_gne__c = errorType,
    				Snippet_Name__c = snippetName,
    				User_Name__c = UserInfo.getName()
    		);
    	}
    	
    	public String getEmailDescription() {
    		return String.format('{0}: {1}\n[{2}]', new String[]{(snippetName!=null ? (snippetName + '.' + errorType) : errorType), errorMessage, errorStackTrace});
    	}
    	
    }
}