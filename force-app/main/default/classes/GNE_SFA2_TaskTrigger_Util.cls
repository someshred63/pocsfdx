public with sharing class GNE_SFA2_TaskTrigger_Util{
    public static Map <Id,Call2_vod__c> getCallMap (List <String> callIds) {
        Map <Id, Call2_vod__c> calls = 
                new Map <Id, Call2_vod__c> (
                        [Select Id, Name,Parent_Call_vod__r.Status_vod__c, Status_vod__c, Override_Lock_vod__c, OwnerId, Call_Date_vod__c  
                        From Call2_vod__c
                        Where Id in :callIds]);
        return calls;
        
    }
    
   public static boolean isLocked (String Id, Map <Id,Call2_vod__c> calls) {
        Call2_vod__c call = calls.get(Id);
        
        if (call != null) {
            if (call.Parent_Call_vod__r != null ) {
                if (call.Parent_Call_vod__r.Status_vod__c == 'Submitted_vod')
                    return true;
            }
            
            if (call.Status_vod__c == 'Submitted_vod')
                return true;
        }
        
        return false;
    }
}