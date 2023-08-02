global class GNE_CRM_340B_EmailsInLabels_Scheduler implements Schedulable, Database.AllowsCallouts {
    
    public void execute(SchedulableContext SC) {        
        Database.executeBatch(new GNE_CRM_340B_EmailsInLabels_Batch(), 10);        
    }
    
}