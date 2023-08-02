public class AGS_PendingCaseActionsBatch_Invoke {
    
    
       private final ApexPages.StandardController theController;

       public AGS_PendingCaseActionsBatch_Invoke (ApexPages.StandardController controller){
       theController = controller;  
            System.debug('Create Gene Batch line 1');
        }   
              
            
            Public void autorun()
            { 
            String query = 'Select a.Action_gne__c, a.Action_Status_internal_gne__c, a.Action_Value_gne__c, a.AGS_Case_Analyst_Email_gne__c, a.AGS_Case_gne__c,a.Confirm_Compliance_Understanding_gne__c, a.AGS_Escalated_Confirm_Compliance_box_gne__c, a.AGS_Validate_Data_1_box_gne__c, a.AGS_Validate_Data_2_box_gne__c, a.AGS_Validate_Data_3_box_gne__c, a.AGS_Validate_Data_FollowUp_box_gne__c, a.Id, a.Infrequent_User_Case_Action_gne__c, a.Owner_Hidden_gne__c, a.OwnerId, a.RecordTypeId,Send_Email__c,Send_Error_Email__c,Try_Email_Again__c ,name from AGS_Case_Action_gne__c a where a.Action_Status_internal_gne__c=\'Open\' ';
            system.debug(query);
           List<AsyncApexJob > job=[Select Id,JobType ,ApexClassID ,MethodName ,Status,CompletedDate from AsyncApexJob where JobType ='batchApex'];
            system.debug('past jobs'+job.size());
            system.debug('past jobs ' +job);
            list<CronTrigger> cron = new list<CronTrigger>([select Id,State,StartTime,EndTime,
            NextFireTime ,PreviousFireTime from CronTrigger]);   
            system.debug('cron '+cron.size() );
            system.debug('cron '+cron );
             //ApexClass PBClass=[Select id,name from apexclass where name='AGS_PendingCaseActionsBatch'];
             //system.debug('PBClass'+PBClass.Id);
           //if(job.size()==0) 
            //{
            
           AGS_PendingCaseActionsBatch ActionsBatch =  new AGS_PendingCaseActionsBatch (query);           
                             
            ID batchprocessid = Database.executeBatch(ActionsBatch,1);
           System.debug('Created ActionsBatch');
           // }
           // else
                //System.debug('Cannot start batch as another batch is running');
           //return theController.view().setRedirect(true);
         }  
                 
    
    
}