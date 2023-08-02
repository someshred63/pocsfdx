global class GNE_MED_MSLRoleHierarchy_Scheduler implements Schedulable
{

    /*
    Schedules the GNE_MED_MSLRoleHierarchyBatch batch class
    Author : Sandeep Kumar
    Created on : 22 Aug 2011
    Last Modified : 22 Aug 2011
    */

    static final String BATCH_ROLEHIERARCHYMANAGER = 'GNE_MED_MSLRoleHierarchyBatch'; 
    

    
    global void execute(SchedulableContext sc) 
    {

        try {
            AsyncApexJob[] asyncApexJobList 
                                      =  [Select Id, CreatedDate, Status, NumberOfErrors, 
                                          JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                          from AsyncApexJob 
                                          where     NumberOfErrors = 0
                                                and status in ('Processing', 'Queued') 
                                                and ApexClass.Name = :GNE_MED_MSLRoleHierarchy_Scheduler.BATCH_ROLEHIERARCHYMANAGER                                              
                                          ];
    
            if ( asyncApexJobList.size() == 0 ) {                                            
                GNE_MED_MSLRoleHierarchyBatch roleHierarchyManager = new GNE_MED_MSLRoleHierarchyBatch();
                Database.executeBatch ( roleHierarchyManager, 1 );
            }
        } catch ( Exception e ) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + e.getMessage() );                
            Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
            String addr = configItemsMap.get('MSLRoleHierarchyNotifyEmail').Configuration_Value_gne__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses ( new String[] {addr} );
            mail.setSubject('Scheduler Class GNE_RoleHierarchyManager_Scheduler Exception. ');
            mail.setPlainTextBody
                            ('Scheduler Class GNE_MED_MSLRoleHierarchy_Scheduler Exception.\nException Desc -> ' + 
                            e.getMessage() );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
        }
    } 
    
    global void finish(Database.BatchableContext BC)
    {
        
    }
    
}