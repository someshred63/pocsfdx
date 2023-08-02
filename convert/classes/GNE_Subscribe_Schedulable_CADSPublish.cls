global class GNE_Subscribe_Schedulable_CADSPublish  implements Schedulable{

    static final String SUBSCRIBE_BATCH_ORGACCOUNT       = 'GNE_Subscribe_Batch_OrgAccount';    
    static final String SUBSCRIBE_BATCH_PERSONACCOUNT    = 'GNE_Subscribe_Batch_PersonAccount';

    /* fetch last batch job createdDate, return null if job in processing or queued status */
    public static DateTime getLastBatchJobStartTime (AsyncApexJob[] asyncApexJobList, 
                                       String apexClassName) {     
        DateTime lastStartTime = null;        
        for ( AsyncApexJob asyncApexJobItem : asyncApexJobList ) {            
            ApexClass apexClass = asyncApexJobItem.ApexClass;             
            if ( apexClass.Name.equalsIgnoreCase ( apexClassName ) ) { 	                
                if ( asyncApexJobItem.Status.equalsIgnoreCase ('Processing') || 
                     asyncApexJobItem.Status.equalsIgnoreCase ('Queued') ) {                      
                    lastStartTime = null;  // job running return null                     
                    break;     	
                } else if ( asyncApexJobItem.Status.equalsIgnoreCase ('Completed') ) {
                    if ( lastStartTime == null )
                        lastStartTime = asyncApexJobItem.CreatedDate;     
                }                	
            }            
        }
        return lastStartTime;                	
    }
    
    public static void startSubscribe () {
        try {
          AsyncApexJob[] asyncApexJobList 
                                    =  [Select Id, CreatedDate, ApexClass.Name, Status, NumberOfErrors, 
                                        JobItemsProcessed, TotalJobItems, CreatedBy.Email
                                        from AsyncApexJob 
                                        where     NumberOfErrors = 0
                                              and status in ('Processing', 'Queued', 'Completed') 
                                              and (ApexClass.Name = :SUBSCRIBE_BATCH_ORGACCOUNT  
                                                   OR 
                                                   ApexClass.Name = :SUBSCRIBE_BATCH_PERSONACCOUNT
                                                  )                                 
                                        order by CreatedDate desc                                                                            
                                        ];
  
            DateTime orgSubscribeBatchLastStartTime    = getLastBatchJobStartTime(asyncApexJobList,SUBSCRIBE_BATCH_ORGACCOUNT );
            DateTime personSubscribeBatchLastStartTime = getLastBatchJobStartTime(asyncApexJobList,SUBSCRIBE_BATCH_PERSONACCOUNT);

            // Org Account Subscribe
            if ( orgSubscribeBatchLastStartTime != null ) {
               System.debug ( LoggingLevel.INFO, 'Starting Batch Job ' + SUBSCRIBE_BATCH_ORGACCOUNT + 
                                                 'with start Date -> ' + orgSubscribeBatchLastStartTime );
               GNE_Subscribe_Batch_OrgAccount subscribe = new GNE_Subscribe_Batch_OrgAccount();
               subscribe.setSelectByTimestamp ( orgSubscribeBatchLastStartTime);
               Database.executeBatch ( subscribe, 10 );
            }  else {
                System.debug (LoggingLevel.INFO, SUBSCRIBE_BATCH_ORGACCOUNT + 
                                                 ' Last Batch Completed Date Not Available or job is currently ' + 
                                                 ' Processing or Queued. ' );   
            }

            // Person Account Subscribe
            if ( personSubscribeBatchLastStartTime != null ) {
               System.debug ( LoggingLevel.INFO, 'Starting Batch Job ' + SUBSCRIBE_BATCH_PERSONACCOUNT + 
                                                 'with start Date -> ' + personSubscribeBatchLastStartTime );
               GNE_Subscribe_Batch_PersonAccount subscribe = new GNE_Subscribe_Batch_PersonAccount();
               subscribe.setSelectByTimestamp ( personSubscribeBatchLastStartTime);
               Database.executeBatch ( subscribe, 10 );
            } else {
                System.debug (LoggingLevel.INFO, SUBSCRIBE_BATCH_PERSONACCOUNT + 
                                                 ' Last Batch Completed Date Not Available or job is currently ' + 
                                                 ' Processing or Queued. ' );   
            }                        
        } catch ( Exception e ) {
            System.debug (LoggingLevel.INFO, 'Error occured. Error Desc -> ' + e.getMessage() );
                
            Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
            String addr = configItemsMap.get('SubscribeNotfyEmail').Configuration_Value_gne__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses ( new String[] {addr} );
            mail.setSubject('Scheduler Class GNE_Subscribe_Schedulable_CADSPublish Exception. ');
            mail.setPlainTextBody
                            ('Scheduler Class GNE_Subscribe_Schedulable_CADSPublish Exception.\nException Desc -> ' + 
                            e.getMessage() );
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
        }
    }
    

    global void execute(SchedulableContext sc) {        
        startSubscribe();
    }   


}