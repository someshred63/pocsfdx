public class gFRS_StatusReportTaskToNotSubmitedImpl implements gFRS_ISchedulable{

    
     public void execute(SchedulableContext sc) {
 
         refreshStatusReportsToNotSubmitted();
     }
     
   /**
    * Function update status to unsubmitted every 1st day of month for tasks where all program have not finished
    */
    private void refreshStatusReportsToNotSubmitted(){
      List<Id> requestIds = new List<Id>();
      for(gFRS_Program__c program:[SELECT Funding_Request__c FROM gFRS_Program__c WHERE Funding_Request__c in (SELECT gFRS_Funding_Request__c FROM gFRS_Tasks__c WHERE Status__c='Submitted' AND Action_Type__c='Status Report') AND Program_Status__c NOT IN ('Completed','Canceled','Entered in Error') AND End_Date__c>=TODAY]){
                requestIds.add(program.Funding_Request__c);     
      }
      if(requestIds.size()>0){
        List<gFRS_Tasks__c> tasksToRefresh =[SELECT Id, Status__c FROM gFRS_Tasks__c WHERE Status__c='Submitted' AND Action_Type__c='Status Report' AND gFRS_Funding_Request__c IN :requestIds];
        for(gFRS_Tasks__c task:tasksToRefresh){
            task.Status__c= gFRS_Util.TASK_NOT_SUBMITTED;
        }
        update tasksToRefresh;
      }
    }
}