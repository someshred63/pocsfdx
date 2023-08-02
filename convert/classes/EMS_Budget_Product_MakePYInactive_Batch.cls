global without sharing class EMS_Budget_Product_MakePYInactive_Batch implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Year_gne__c, Status_gne__c FROM EMS_Budget_Product_gne__c WHERE Status_gne__c != \'Inactive\' AND Year_gne__c = \'' + String.valueOf(System.today().year() - 1) + '\'');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<EMS_Budget_Product_gne__c> budgetsToUpdate = new List<EMS_Budget_Product_gne__c>();
        EMS_Product_Budget_Helper.skipTriggerValidationRules = TRUE;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = TRUE;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = TRUE;
        EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = TRUE;

        for (EMS_Budget_Product_gne__c pb : (List<EMS_Budget_Product_gne__c>) scope) {
            pb.Status_gne__c = 'Inactive';
            budgetsToUpdate.add(pb);
        }

        if (!budgetsToUpdate.isEmpty()) {
            update budgetsToUpdate;
        }

    }

    global void finish(Database.BatchableContext BC) {
		AsyncApexJob a = [SELECT Id FROM AsyncApexJob WHERE Id =:BC.getJobId()];
		
		List<String> mails = EMS_Util.getApplicationAdminsEmails();
    	
    	EMS_Email.prepareSingleEmail('EMS_Batch_Job_Notification', a.Id, mails);
    	
    	EMS_Email.Send();
    }

}