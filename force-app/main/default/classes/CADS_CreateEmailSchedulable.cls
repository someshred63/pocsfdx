global class CADS_CreateEmailSchedulable implements Schedulable
{
global void execute(SchedulableContext sc)
     {
      
      try{
            List<CronTrigger> cron = new List<CronTrigger>([select Id, State from CronTrigger ]); 
            system.debug('The Ids of the Scheduled Jobs  : '+ cron );      
            for (CronTrigger  cr :cron)
            {
               if (cr.state == 'Complete')
               {
                  System.debug(' Deleted Job Id : '+ cr.Id);
                  system.abortJob(cr.Id);
                }
            }
      
          
        }catch(Exception e){
            System.debug('I failed to Delete');       
        } 
        List<CADS_Email_Batch_Process_gne__c> batchStatus = CADS_Email_Batch_Process_gne__c.getall().values();
        batchStatus[0].Status_gne__c = 'Processing';
		update batchStatus; 
        String query = 'Select Name,Id,Is_Infrequent_gne__c, Is_Alert_User_Active_gne__c, Alert_user_Unix_Id_gne__c,Alert_User_Email_Id_gne__c from CADS_Account_Address_Issues_gne__c  where Alert_the_User_gne__c = \'yes\' and Current_Action_Email_Status_gne__c= \'Not Sent\' and Alert_User_Email_Id_gne__c != null and LastModifiedDate =today and lastmodifiedby.name != \'ETL Publish\'';
        CADS_CreateEmailsBatch emailsBatch =  new CADS_CreateEmailsBatch (query);           
        ID batchprocessid = Database.executeBatch(emailsBatch);
        System.debug('Created emailsBatch');

}


}