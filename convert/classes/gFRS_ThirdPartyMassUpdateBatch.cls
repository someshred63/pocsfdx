global with sharing class gFRS_ThirdPartyMassUpdateBatch implements Database.Batchable<sObject> {
	
	
	Map<Id,GFRS_Funding_Request__c> gFRSFundingRequestIds = new Map<Id,GFRS_Funding_Request__c>();
	global String query = '';
	
	
	global Database.Querylocator start(Database.BatchableContext BC){     
        query = 'select Record_Type_Name__c,Is_the_Third_Party_org_accredited__c,Is_the_Third_Party_org_owned_physician__c, Will_You_be_Working_With_a_3rd_Party__c from GFRS_Funding_Request__c where  Will_You_be_Working_With_a_3rd_Party__c=\'Yes\' and Record_Type_Name__c=\'IMED\'';  
        return Database.getQueryLocator(query);
    }
   
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
     	Map<Id, GFRS_Funding_Request__c> fundingRequestMap = new Map<Id, GFRS_Funding_Request__c>();
     	Map<Id,gFRS_Third_Party__c> thirdPartyMap  = new Map<Id,gFRS_Third_Party__c>();
     	//List <gFRS_Third_Party__c> thirdPartyTempList = new List <gFRS_Third_Party__c>();
     	
     	System.debug('PN Scope Size: ' + scope.size());
     	
     	for (sObject obj: scope) {
     		
     		fundingRequestMap.put(((GFRS_Funding_Request__c )obj).Id,(GFRS_Funding_Request__c )obj);
     	}
     	        
        
        for (gFRS_Third_Party__c item: [select Is_Third_Party_org_owned_by_physicians__c, Is_the_Third_Party_org_accredited__c, Funding_Request__c from gFRS_Third_Party__c where Funding_Request__c in: fundingRequestMap.keySet() order by CreatedDate] ){
            if (!thirdPartyMap.containsKey(item.Funding_Request__c)){
                GFRS_Funding_Request__c tempRequest = fundingRequestMap.get(item.Funding_Request__c);
                item.Is_Third_Party_org_owned_by_physicians__c= tempRequest.Is_the_Third_Party_org_owned_physician__c;
                item.Is_the_Third_Party_org_accredited__c = tempRequest.Is_the_Third_Party_org_accredited__c;
                thirdPartyMap.put(item.Funding_Request__c, item);
            }                    
        }
        
        System.debug('PN thirdPartyMap: ' + thirdPartyMap.values());
        update thirdPartyMap.values();
      	
     }
    
     global void finish(Database.BatchableContext BC){
        
    }
    
    

}