global class CADS_CreateActionsSchedulable implements Schedulable
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
        String query = 'Select Name,Invalid_unixId_gne__c,Is_Infrequent_gne__c,APRMO_SFDC_gne__c,Has_DCR_gne__c,STEWARD_REVIEW_STS_gne__c,Processing_STS_gne__c,Is_Alert_User_Active_gne__c, Alert_user_Unix_Id_gne__c, APRMO_Accountable_Party_UNIXID_gne__c, Issue_Condition_gne__c, Issue_Condition_Description_gne__c, Id from CADS_Account_Address_Issues_gne__c where Alert_user_Unix_Id_gne__c !=null and Current_Action_Type_gne__c =null';
        CADS_CreateActionsBatch issueActionBatch =  new CADS_CreateActionsBatch (query);           
        ID batchprocessid = Database.executeBatch(issueActionBatch);
        System.debug('Created issueActionBatch');

}


}