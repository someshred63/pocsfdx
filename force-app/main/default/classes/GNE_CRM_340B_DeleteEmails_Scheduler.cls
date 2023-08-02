global class GNE_CRM_340B_DeleteEmails_Scheduler implements Schedulable, Database.AllowsCallouts {
    
    public void execute(SchedulableContext SC) {        
        Date d = system.today().adddays(-30);        
        List<GNE_CRM_340B_Email__c> emails = [ SELECT Id FROM GNE_CRM_340B_Email__c WHERE Inactive__c = true AND CreatedDate <= :d LIMIT 50000 ];
        delete emails;
    }
    
}