global class CFAR_TrialTotalStudyEnrollmentBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id,Planned_Enrollment_gne__c,Total_Study_Enrollment__c FROM CFAR_Trial_gne__c WHERE frm_Trial_Status_ref_gne__c != \'Concluded\' AND Planned_Enrollment_gne__c != null AND Total_Study_Enrollment__c = null');
    }

    global void execute(Database.BatchableContext context, List<CFAR_Trial_gne__c> trials) {
        for(CFAR_Trial_gne__c trial : trials) {
            trial.Total_Study_Enrollment__c = trial.Planned_Enrollment_gne__c;                 
        }
        CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_TrialTrigger'});
        update trials;
        CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>());
        
    }
    global void finish(Database.BatchableContext context) {
        
    }
}