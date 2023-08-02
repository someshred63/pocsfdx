global class gFRS_CostCenterDml implements Database.Batchable<sObject>{
	
	global List<GFRS_Cost_Center_Code__c> costCentersToDelete = new List<GFRS_Cost_Center_Code__c>();
	
	global Iterable<sObject> start(Database.BatchableContext BC){
		System.debug('PN:gFRS_CostCenterDml: START costCentersToDelete SIZE: ' + costCentersToDelete.size());
      return costCentersToDelete;
   	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope){
   		System.debug('PN:gFRS_CostCenterDml: Execute SCOPE SIZE: ' + scope.size());
   		
   		update scope;

    }

   global void finish(Database.BatchableContext BC){
   }
}