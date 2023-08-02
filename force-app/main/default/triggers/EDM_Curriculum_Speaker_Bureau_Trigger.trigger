trigger EDM_Curriculum_Speaker_Bureau_Trigger on Curriculum_Speaker_Bureau_gne__c (before delete, after insert, after update) {
    if (!GNE_SFA2_Util.isAdminMode()){
        if (Trigger.isAfter && Trigger.isInsert){
            EDM_Curriculum_SB_TriggerHelper.onAfterInsert(Trigger.new);
        } 
        else if(Trigger.isAfter && Trigger.isUpdate) {
            EDM_Curriculum_SB_TriggerHelper.onAfterUpdate(Trigger.new);
        } 
        else if(Trigger.isBefore && Trigger.isDelete) {
            EDM_Curriculum_SB_TriggerHelper.onBeforeDelete(Trigger.old);
        } 
    }
}