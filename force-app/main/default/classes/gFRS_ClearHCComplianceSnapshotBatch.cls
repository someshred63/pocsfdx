/**
* @author GFRS Dev Team
* @date 05/07/2014
* @description gFRS_ClearHCComplianceSnapshotBatch class - cleanup of old data in Snapshot table
*/
global with sharing class gFRS_ClearHCComplianceSnapshotBatch implements Database.Batchable<sObject> {

	global String query = '';
	

    /**
	* @author GFRS Dev Team	
	* @date 05/07/2014
	* @description Gathering data to process. 
	*/
    global Database.Querylocator start(Database.BatchableContext BC){    
    	Datetime myDateTime = Datetime.now().addDays(-8); 
        query = 'SELECT CreatedDate FROM gFRS_HC_Compliance_Analytic_Snapshot__c WHERE CreatedDate <:myDateTime';  
        return Database.getQueryLocator(query);
    }
    
    /**
	* @author GFRS Dev Team	
	* @date 05/07/2014
	* @description Processing scope of Snapshot records.
	*/
    global void execute(Database.BatchableContext BC, List<sObject> scope){
		delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
	
}