global class GNE_CRM_340B_ProcessEmails_Scheduler implements Schedulable, Database.AllowsCallouts {
    
    public void execute(SchedulableContext SC) {        
        Database.executeBatch(new GNE_CRM_340B_ProcessEmails_Batch(), 10);        
    }
    
}