trigger GNE_FRM_DST_Merge_Candidate_Trigger on CORE_Merge_Candidate__c (after update) {
    if (GNE_SFA2_Util.isAdminMode()){
        return;
    }
    
    if(Trigger.isBefore && Trigger.isInsert) {

    } else if(Trigger.isBefore && Trigger.isUpdate) {

    } else if(Trigger.isBefore && Trigger.isDelete) {            
            
    } else if(Trigger.isAfter && Trigger.isInsert) {
           
    } else if(Trigger.isAfter && Trigger.isUpdate) {
        GNE_FRM_DST_MergeCandidateTriggerHandler.populateStatusOnDST_Match_Loser();                   
    } else if(Trigger.isAfter && Trigger.isDelete) {
                   
    }
}