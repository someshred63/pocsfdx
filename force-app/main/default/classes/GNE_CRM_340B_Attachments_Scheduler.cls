global class GNE_CRM_340B_Attachments_Scheduler implements Schedulable, Database.AllowsCallouts {
    
    public void execute(SchedulableContext SC) {        
        Database.executeBatch(new GNE_CRM_340B_Attachments_Batch(), 1);        
    }
    
}