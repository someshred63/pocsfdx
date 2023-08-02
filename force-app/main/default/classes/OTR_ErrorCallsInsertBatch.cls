global class OTR_ErrorCallsInsertBatch implements Database.Batchable<sObject> {

	private String query;
	private String errorName;
	
	global OTR_ErrorCallsInsertBatch(String errorNameParam){
		query = 'Select Details__c, Details_Exception__c ' 
	    + 'FROM iPhone_API_Errors__c ';
	    errorName = errorNameParam;
	}
	
	global Database.QueryLocator start(Database.batchableContext bc){            
        return Database.getQueryLocator(query);      
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    
    	for(iPhone_API_Errors__c iPhoneAPIError : (List<iPhone_API_Errors__c>)scope){
    		if(iPhoneAPIError.Details_Exception__c == errorName){
    			List<iPhoneApex.CallAttributes> iPhoneCallAttribs = iphoneApex_test_controller.prepareCallAttributes(iPhoneAPIError.Details__c);	
		        //TODO: uncomment after adding logging to iPhone API Error 
		        /*
		        for(iPhoneApex.CallAttributes iPhoneCallAttrib : iPhoneCallAttribs){
		        	iPhoneApex.Response iPhoneCallResponse = new iPhoneApex.Response();
	                iPhoneCallResponse = iPhoneApex.updateOrCreateCall(iPhoneCallAttrib);
	                Integer i = 0;          
	                while ((i < iPhoneCallResponse.RequestIdResponseIdList.size()) && (iPhoneCallResponse.RequestIdResponseIdList[i].ObjectType <> 'Call2_vod__c')) {
	                    i++;
	                }
	                if(iPhoneCallResponse.ErrorMessage != null){
	                	//TODO: add logging to iPhone API Error
	                }
		        }
		        */
    		}
    	}
    }
    
    global void finish(Database.BatchableContext BC){
    }
	
}