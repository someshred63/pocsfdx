global with  sharing class  gFRS_EvaluationCompletedFixBatch implements Database.Batchable<sObject> {
	global Database.Querylocator start(Database.BatchableContext BC){
		string query= 'select Briefly_Describe_Goals_Met_to_Date__c,Briefly_Describe_Lessons_Goals_Unmet__c,Evaluation_Completed__c from GFRS_Funding_Request__c where Record_Type_Name__c in (\'Fellowships\',\'HC Char\',\'Philanthropic\',\'Scientific Projects\') and isDeleted=false and Status__c !=\'Intake\'';    
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	List<GFRS_Funding_Request__c> itempsToUpdate=new List<GFRS_Funding_Request__c>();
    	try{
	    	for(GFRS_Funding_Request__c item : (List<GFRS_Funding_Request__c>)scope){
	    		if(item.Briefly_Describe_Goals_Met_to_Date__c != null && item.Briefly_Describe_Lessons_Goals_Unmet__c != null){
	    			item.Evaluation_Completed__c='Yes';
	    			itempsToUpdate.add(item);
	    		}
	    	}
	    	if(itempsToUpdate.size()>0){
	    		update itempsToUpdate;
	    	}
    	}catch(Exception ex){
    		system.debug('probelms were occured: '+ex.getMessage());
    		system.debug(ex);
    	}
    }
    global void finish(Database.BatchableContext BC){
        system.debug('execution ended successfully');
    }
}