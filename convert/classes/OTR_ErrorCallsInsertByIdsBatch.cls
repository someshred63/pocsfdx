global class OTR_ErrorCallsInsertByIdsBatch implements Database.Batchable<sObject> {

	private String query;
	private Set<String> errorIds;
	private List<String> resultsListSuccess = new List<String>();
	private List<String> resultsListFailure = new List<String>();
	private List<String> allProcessed = new List<String>();   
	
	global OTR_ErrorCallsInsertByIdsBatch(Set<String> errorIdsParam){
		query = 'Select id,Details__c, Details_Exception__c ' 
	    + 'FROM iPhone_API_Errors__c ';
	    errorIds = errorIdsParam;
	}
	
	global Database.QueryLocator start(Database.batchableContext bc){            
        return Database.getQueryLocator(query);      
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    
    	for(iPhone_API_Errors__c iPhoneAPIError : (List<iPhone_API_Errors__c>)scope){
    		if(errorIds.contains(iPhoneAPIError.id)){
    			List<iPhoneApex.CallAttributes> iPhoneCallAttribs = iphoneApex_test_controller.prepareCallAttributes(iPhoneAPIError.Details__c);	
				allProcessed.add(iPhoneAPIError.id);
		        for(iPhoneApex.CallAttributes iPhoneCallAttrib : iPhoneCallAttribs){
		        	iPhoneApex.Response iPhoneCallResponse = new iPhoneApex.Response();
	                iPhoneCallResponse = iPhoneApex.updateOrCreateCall(iPhoneCallAttrib);
	                Integer i = 0;          
	                while ((i < iPhoneCallResponse.RequestIdResponseIdList.size()) && (iPhoneCallResponse.RequestIdResponseIdList[i].ObjectType <> 'Call2_vod__c')) {
	                    i++;
	                }
	                if(iPhoneCallResponse.ErrorMessage != null){
	                	resultsListFailure.add(iPhoneAPIError.id+','+iPhoneCallResponse.ErrorMessage);
	                }else{
	                	resultsListSuccess.add(iPhoneAPIError.id);
	                }
		        }
		        
    		}
    	}
    }
    
    global void finish(Database.BatchableContext BC){
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<User> usrs = new List<User>([select email,Name from User where id=:UserInfo.getUserId()]);
        mail.setToAddresses(new String[]{usrs[0].email});
        mail.setSubject('Interactions update/insert');
        mail.setReplyTo('wajrycs1@gene.com');
        String mailText = '******PLEASE DO NOT REPLY TO THIS EMAIL****** \n\n';
        mailText += 'Dear '+ usrs[0].Name+',\n\n'; 
        
        for(String itemProcessed : allProcessed){
        	mailText += itemProcessed +'\n';
        }
        
        mailText += '\n\n';
        
        if(resultsListSuccess.size()>0){
        	mailText += 'The folowing Interactions update/insert succesfull:\n\n';
	        for(String success : resultsListSuccess){
	        	mailText += success +'\n';
	        }
        }        
        
        if(resultsListFailure.size()>0){
	        mailText += '\n\n';
	        mailText += 'The folowing Interactions update/insert failure:\n\n';
	        for(String failure : resultsListFailure){
	        	mailText += failure +'\n';
	        }
        }
        mailText += '\nBest regards,\n';
        mailText += 'System Administrator';
		mailText += '\n\n';
        mail.setPlainTextBody(mailText);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	
    	
    	
    }

}