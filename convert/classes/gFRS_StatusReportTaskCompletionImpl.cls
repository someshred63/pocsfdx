public class gFRS_StatusReportTaskCompletionImpl implements gFRS_ISchedulable{

 public void execute(SchedulableContext sc) {
      
        Set<Id> fundRequests = new Set<Id>();
        
        for(AggregateResult ar:[select Funding_Request__c from GFRS_Program__c WHERE Program_Status__c IN ('Completed','Canceled','Entered in Error') AND End_Date__c>=YESTERDAY AND End_Date__c<TODAY Group by Funding_Request__c]){
            fundRequests.add((Id) ar.get('Funding_Request__c'));
        }
    
        for(AggregateResult ar:[select Funding_Request__c from GFRS_Program__c WHERE (Program_Status__c NOT IN ('Completed','Canceled','Entered in Error') OR End_Date__c>=TODAY) AND Funding_Request__c IN :fundRequests GROUP BY Funding_Request__c]){
            fundRequests.remove((Id) ar.get('Funding_Request__c'));
        } 
    
        List<gFRS_Tasks__c> tasks = [SELECT Id, Status__c from gFRS_Tasks__c WHERE gFRS_Funding_Request__c IN :fundRequests AND Action_Type__c='Status Report' AND Status__c!=:gFRS_Util.TASK_COMPLETED];
        
        for(gFRS_Tasks__c task:tasks){
            task.Status__c = gFRS_Util.TASK_COMPLETED;
        }
        
        update tasks;
    
    }
    
}