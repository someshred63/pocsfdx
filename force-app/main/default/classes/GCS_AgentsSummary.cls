/**********************************************************************************************************************
Purpose: GCS_AgentsSummary class is used to Display Agents Summary at Utilitybar.
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raheem       07/06/2020      INITIAL DEVELOPMENT
            
***********************************************************************************************************************/
public class GCS_AgentsSummary {
    @AuraEnabled
       public static List<AgentWrapper> getAgentDataWithStatus(){
           List<AgentWrapper> agentWrapList = new List<AgentWrapper>();
           set<Id> userId = new set<Id>();    
           map<id,string> agentCapacityMap = new map<id,string>();
           List<UserServicePresence> userServicePresenceList=[Select Id,IsAway,Name,AtCapacityDuration,UserId, User.Name, ServicePresenceStatusId, 
                                                     ConfiguredCapacity, CreatedDate, ServicePresenceStatus.MasterLabel,
                                                     StatusEndDate,StatusStartDate, IdleDuration,AverageCapacity, IsCurrentState,
                                                     StatusDuration
                                                     From UserServicePresence Where StatusEndDate = null];
           if(userServicePresenceList.size()>0){
               for(UserServicePresence up:userServicePresenceList){
                   userId.add(up.UserId);            
               } 
           }
        
          List<AgentWork> agentWorkList=[SELECT Id,AcceptDateTime,ActiveTime,AfterConversationActualTime,Name,UserId,
                                           CapacityPercentage,RequestDateTime,SpeedToAnswer,Status,user.Name,WorkItemId 
                                           from AgentWork where Status='Opened' and userId In:userId];
           if(agentWorkList.size()>0){
               for(AgentWork al:agentWorkList){  
                   agentCapacityMap.put(al.UserId,al.Status);
                 //  agentWrapList.add(new AgentWrapper(al.Status));
               }
           }
           if(userServicePresenceList.size()>0){
               for(UserServicePresence up:userServicePresenceList){    
                   string capacity= agentCapacityMap.get(up.UserId);             
                   agentWrapList.add(new AgentWrapper(up,capacity));
               } 
           }
           return agentWrapList;
       }
       public class AgentWrapper{
           @AuraEnabled
           public UserServicePresence userPresencesObj {get;set;}
           @AuraEnabled
           public AgentWork agentWorkObj {get;set;}
           @AuraEnabled
           public string agentStatus {get;set;}
           @AuraEnabled
           public string agentName {get;set;}
            @AuraEnabled
           public string agentCapacity {get;set;}
           public AgentWrapper(UserServicePresence usp,string agentStatus){
               this.userPresencesObj=usp;  
               this.agentStatus=agentStatus;
           }
          
       }
   }