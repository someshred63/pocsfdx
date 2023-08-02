/******************************************************************************************
*  @author: Piotr Przesmycki
*  @email: piotr.przesmycki@contractors.roche.com   
*  Created: 2015-02-19
*  Project: EDM
*  Description: Purpose of this batch to find all curriculums that should be deactivated today/yesterday and do 
*               a blank update on them, so that EDM_Get_Event_Curriculums_gne WS include them in response
*******************************************************************************************/
global class EDM_Curriculum_Status_Update_Batch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM Event_Curriculum_gne__c WHERE Deactivation_Date_gne__c IN (TODAY, YESTERDAY)');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        update scope;
    }

    global void finish(Database.BatchableContext BC){
    }
}