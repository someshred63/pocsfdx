/*************************************************************************************************************************************
CLASS NAME: ApprovalHistoryCmpController
DESCRIPTION: 
Retrives all approval process instances for a record.

DATE            DEVELOPER           PURPOSE
--------------------------------------------------------------------------------------------------------------------------------------
11-Feb-2022     Lavanya               Created  a method ApprovalHistoryCmpController() to retrive app process instances for a record.
**************************************************************************************************************************************/

public class ApprovalHistoryCmpController {
    
    
    @AuraEnabled
    public static list<ProcessInstanceHistory> getAllStepsandWorkItems(string appId)
    {
        List<ProcessInstanceHistory> listp = new List<ProcessInstanceHistory>();
        Map<Id,ProcessInstance> processInstanceMap = New Map<Id,ProcessInstance>([SELECT Id, Status, (SELECT ID, ProcessNodeId,  
                                                                                                      StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                                                                                                      ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,  
                                                                                                      OriginalActor.Name , ProcessNode.Name FROM StepsAndWorkitems order by Id DESC)   
                                                                                  FROM ProcessInstance where TargetObjectId =:appId order by CreatedDate DESC]); 
        
        if(!processInstanceMap.isEmpty()){
            for(ProcessInstance pr :  processInstanceMap.values()){
                for(ProcessInstanceHistory  str : pr.StepsAndWorkitems) {
                    listp.add(str);
                }
            }
        }else{
            return listp;
        }
        return listp;
        
    }
    
}