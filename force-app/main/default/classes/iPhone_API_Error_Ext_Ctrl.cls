public with sharing class iPhone_API_Error_Ext_Ctrl {
	
	public String requestString {get; set;}
	public Id errorId {get; private set;}
	public String requestStringOrig {get; private set; }

	public iPhone_API_Error_Ext_Ctrl(ApexPages.StandardController ctrl) {
		SObject record = ctrl.getRecord();
		errorId = record!=null ? record.Id : null;
		
	}
    
    public PageReference init() {
    	requestString = requestStringOrig = iPhoneBase.getRequestStringFromErrorLog(errorId); 
        return null;
    }
    
    public PageReference setMessageText() {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Testing Request...'));
    	return null;
    }
    
    public PageReference testRequest() {
    	try {
    		iPhoneBase.testRequest(errorId, requestString);
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Result Status: OK'));
    	} catch (iPhoneBase.TestRequestException ex) {
    		ApexPages.addMessages(ex);
    	} catch(Exception ex) {	
    		ApexPages.addMessage(new ApexPages.Message(
    				ApexPages.Severity.ERROR, 
    				String.format('{0}<br/>{1}', new String[]{ex.getMessage(), ex.getStackTraceString()})));
    		
    	}
    	
    	return null;
    }
    
    @ReadOnly @RemoteAction
    public static String getApexScript(Id errorId, String requestString) {
    	System.Type requestClass = iPhoneBase.getRequestClassFromErrorLog(errorId);
    	
    	List<String> apexScriptLines = new List<String>{ 
    		'String requestString = \'' + requestString + '\';',
    		'System.Type requestClass = ' + (requestClass!=null ? ('System.Type.forName(\'' + requestClass.getName() + '\')') : 'null') +';',
    		'iPhoneBase.testRequest(requestString, requestClass);'
    	};
    	
    	return String.join(apexScriptLines, '\n');
    }
    
    @ReadOnly @RemoteAction
    public static String getRestRequest(Id errorId, String requestString) {
    	System.Type requestClass = iPhoneBase.getRequestClassFromErrorLog(errorId);
    	
    	List<String> restRequestLines = new List<String>{ 
    		'"errorLogId": "' + errorId + '"',
    		'"requestClassName": ' + (requestClass!=null ? '"' + requestClass.getName() + '"' : null),
    		'"requestJSON": ' + (requestString!=null ? '"' + requestString.replaceAll('"','\\\\"') + '"' : null)
    	};
    	
    	return '{\n\t' + String.join(restRequestLines, ',\n\t') + '\n}';
    }
    
    
}