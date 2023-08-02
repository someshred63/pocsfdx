global class GNE_RoleHierarchyManager_Scheduler implements Schedulable{

    static final String BATCH_ROLEHIERARCHYMANAGER       = 'GNE_PrimaryCareRoleHierarchyManager';    
    
    global void execute(SchedulableContext sc) {        

        try {
            AsyncApexJob[] asyncApexJobList 
                                      =  [Select Id, CreatedDate, Status, NumberOfErrors, 
                                          JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                          from AsyncApexJob 
                                          where     NumberOfErrors = 0
                                                and status in ('Processing', 'Queued') 
                                                and ApexClass.Name = :GNE_RoleHierarchyManager_Scheduler.BATCH_ROLEHIERARCHYMANAGER                                              
                                          ];
    
            if ( asyncApexJobList.size() == 0 ) {                                            
                GNE_PrimaryCareRoleHierarchyManager roleHierarchyManager = new GNE_PrimaryCareRoleHierarchyManager();
                Database.executeBatch ( roleHierarchyManager, 1 );
            }
        } catch ( Exception e ) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + e.getMessage() );                
            Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
            String addr = configItemsMap.get('RoleHierarchyNotfyEmail').Configuration_Value_gne__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses ( new String[] {addr} );
            mail.setSubject('Scheduler Class GNE_RoleHierarchyManager_Scheduler Exception. ');
            mail.setPlainTextBody
                            ('Scheduler Class GNE_RoleHierarchyManager_Scheduler Exception.\nException Desc -> ' + 
                            e.getMessage() );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
        }
    }   

}