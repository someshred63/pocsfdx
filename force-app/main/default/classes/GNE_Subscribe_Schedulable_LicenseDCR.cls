global class GNE_Subscribe_Schedulable_LicenseDCR implements Schedulable{

    static final String BATCH_LICENSEDCR       = 'GNE_Subscribe_Batch_LicenseDCR';    
    
    global void execute(SchedulableContext sc) {        

        try {
	        AsyncApexJob[] asyncApexJobList 
	                                  =  [Select Id, CreatedDate, Status, NumberOfErrors, 
	                                      JobItemsProcessed, TotalJobItems, CreatedBy.Email
	                                      from AsyncApexJob 
	                                      where     NumberOfErrors = 0
	                                            and status in ('Processing', 'Queued') 
	                                            and ApexClass.Name = :GNE_Subscribe_Schedulable_LicenseDCR.BATCH_LICENSEDCR	                                             
	                                      ];
	
	        if ( asyncApexJobList.size() == 0 ) {                                            
		        GNE_Subscribe_Batch_LicenseDCR licenseDCR = new GNE_Subscribe_Batch_LicenseDCR();
		        Database.executeBatch ( licenseDCR, 1 );
	        }

        } catch ( Exception e ) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + e.getMessage() );
                
            Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
            String addr = configItemsMap.get('SubscribeNotfyEmail').Configuration_Value_gne__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses ( new String[] {addr} );
            mail.setSubject('Scheduler Class GNE_Subscribe_Schedulable_LicenseDCR Exception. ');
            mail.setPlainTextBody
                            ('Scheduler Class GNE_Subscribe_Schedulable_LicenseDCR Exception.\nException Desc -> ' + 
                            e.getMessage() );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
        }
    }   

}