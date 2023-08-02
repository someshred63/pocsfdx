global class SPCM_SetApproversNamesBatch implements Database.Batchable<sObject> {
	
	global final String query = 
   		'select Original_Approver__c, Approval_Status__c, Appr_Approver_1_Original__c from SPCM_CARS_Payment_Packet__c where Approval_Status__c = \'Submitted for Approval\'';
	
	global SPCM_SetApproversNamesBatch() {
		
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {

   		for(sobject s : scope)
   		{
     		SPCM_CARS_Payment_Packet__c p = (SPCM_CARS_Payment_Packet__c)s;
     		p.Original_Approver__c = p.Appr_Approver_1_Original__c;
     	}
     	update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}