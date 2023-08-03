trigger CORE_Merge_Candidate_Trigger on CORE_Merge_Candidate__c (before delete, before insert, before update) {
    if(!CORE_Merge_Util.isTriggerDisabled(CORE_Merge_Candidate__c.sObjectType)) {
        CORE_Merge_Util.setInTrigger(CORE_Merge_Candidate__c.sObjectType, true);
        
        if(Trigger.isBefore && Trigger.isInsert) {
            CORE_Merge_Util.setMergeObject(Trigger.new);
            CORE_Merge_Util.setExternalId(Trigger.new);
            CORE_Merge_Util.onMergeCandidatesUpsert(Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            CORE_Merge_Util.setExternalId(Trigger.new);
            CORE_Merge_Util.onMergeCandidatesUpsert(Trigger.new, Trigger.old);
        } else if(Trigger.isBefore && Trigger.isDelete) {
            CORE_Merge_Util.blockDelete(Trigger.old);
        }
        
        CORE_Merge_Util.setInTrigger(CORE_Merge_Candidate__c.sObjectType, false);
    }
}