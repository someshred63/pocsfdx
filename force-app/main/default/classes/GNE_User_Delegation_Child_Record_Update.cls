public without sharing class GNE_User_Delegation_Child_Record_Update {

    public static Set<Id> processedUserDelegationIds {
        get {
            if (processedUserDelegationIds == null) {
                processedUserDelegationIds = new Set<Id>();
            }
            return processedUserDelegationIds;
        }
        set;
    }

    public static void onAfterInsertUpdate(List<GNE_User_Delegation__c> triggerNew) {
        List<Id> userDelegationIds = new List<Id>();
        for (GNE_User_Delegation__c userDelegationRecord :triggerNew) {
            Boolean isPocessed = GNE_User_Delegation_Child_Record_Update.processedUserDelegationIds.contains(userDelegationRecord.Id);
            if (userDelegationRecord.Start_Date__c <= System.today() && !isPocessed) {
                userDelegationIds.add(userDelegationRecord.Id);
            }
        }
        if (!userDelegationIds.isEmpty()) {
            if (System.isFuture()) {
                EMS_User_Delegation_Batch.handleUserDelegations(userDelegationIds);
            } else {
                EMS_User_Delegation_Batch.handleUserDelegationsFuture(userDelegationIds);
            }
            for (GNE_User_Delegation__c userDelegationRecord :triggerNew) {
                GNE_User_Delegation_Child_Record_Update.processedUserDelegationIds.add(userDelegationRecord.Id);
            }
        }
    }
}