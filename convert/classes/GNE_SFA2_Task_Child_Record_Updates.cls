public with sharing class GNE_SFA2_Task_Child_Record_Updates
{
   public static void OnAfterDelete(Map<Id,Task> oldMap){
        List<Task> tasks = new List<Task>();
        List<Id> idSet = new List<Id>();
        if(oldMap.size() > 0) {
            tasks.addAll(oldMap.values());
            idSet.addAll(oldMap.keySet());
        }
        deletTaskReplicaAfterTaskDelete(idSet);
    }
    private static void deletTaskReplicaAfterTaskDelete (List<Id> idSet){
        if(idSet != null && idSet.size() > 0){
            try {
              database.delete ( [select id from Task_Replica_gne__c where Id_gne__c in :idSet], false);
            } catch (Exception e) {
                GNE_SFA2_ErrorBundle_Util.writeErrorLog('Task', 'deletTaskReplicaAfterTaskDelete', e);           
            }
        }
    }
   
}