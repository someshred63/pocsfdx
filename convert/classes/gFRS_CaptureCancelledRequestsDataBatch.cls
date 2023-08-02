/**
* @author ADMD Team
* @date 26/04/2013
* @description gFRS_CaptureCancelledRequestsDataBatch class - update of historical data: SFDC-2892.
* Should be executed post deployment steps of release 3.1.0 (R1 2013).
* Database.executeBatch(new gFRS_CaptureCancelledRequestsDataBatch());
*/
global without sharing class gFRS_CaptureCancelledRequestsDataBatch implements Database.Batchable<sObject> {
	
	global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query= 'SELECT CCO_Decision__c, Legal_Decision__c, GC_Decision__c, Business_Reviewer_Decision__c, Business_Approver_Decision__c,  Financial_Approver_1_Decision__c, Financial_Approver_2_Decision__c, Financial_Approver_3_Decision__c, Financial_Approver_4_Decision__c, Financial_Approver_5_Decision__c, Sub_Status__c FROM GFRS_Funding_Request__c where isDeleted=false';    
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	Set<String> decisionFieldsToCheck = new Set<String>{'CCO_Decision__c', 'Legal_Decision__c', 'GC_Decision__c', 'Business_Reviewer_Decision__c', 'Business_Approver_Decision__c',
        		 'Financial_Approver_1_Decision__c', 'Financial_Approver_2_Decision__c',
        		 'Financial_Approver_3_Decision__c', 'Financial_Approver_4_Decision__c', 'Financial_Approver_5_Decision__c'};
        		 
		List<sObject> requestsToUpdate = new List<sObject>();
		
        for(sObject fundingRequest : scope){
        	if(fundingRequest.get('Sub_Status__c') == 'Canceled'){     		
        		for(String field : decisionFieldsToCheck){
		    		if(fundingRequest.get(field) == 'Rejected'){
		    			fundingRequest.put(field, 'Canceled');	
		    			requestsToUpdate.add(fundingRequest);
		    		}	
		    	}   		
        	}
        }
        
        update requestsToUpdate;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('gFRS_CaptureCancelledRequestsDataBatch execution ended');
    }

}