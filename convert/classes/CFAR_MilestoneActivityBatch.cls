global class CFAR_MilestoneActivityBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, (SELECT Baselined_Date_gne__c, Planned_Date_gne__c FROM CFAR_Milestone_Activities__r) FROM CFAR_Trial_gne__c');
    }

    global void execute(Database.BatchableContext context, List<CFAR_Trial_gne__c> trials) {
        List<CFAR_Milestone_Activity_gne__c> trialsToUpdate = new List<CFAR_Milestone_Activity_gne__c>();

        for (CFAR_Trial_gne__c trial : trials) {
            List<CFAR_Milestone_Activity_gne__c> milestones = new List<CFAR_Milestone_Activity_gne__c>();
                for (CFAR_Milestone_Activity_gne__c activity : trial.CFAR_Milestone_Activities__r) {
                    Boolean checkForRebaseline = true;
                    if (activity.Planned_Date_gne__c == null) {
                        checkForRebaseline = false;
                    }
                    if (checkForRebaseline) {
                        if (activity.Baselined_Date_gne__c == null) {
                            activity.Baselined_Date_gne__c = activity.Planned_Date_gne__c; 
                        }
                        milestones.add(activity);
                    }
                    if (trial.CFAR_Milestone_Activities__r.size() == milestones.size()) {       
                        trialsToUpdate.addAll(milestones);
                    }
            }
    }

    update trialsToUpdate;
        

    }
    global void finish(Database.BatchableContext context) {
        
    }
}