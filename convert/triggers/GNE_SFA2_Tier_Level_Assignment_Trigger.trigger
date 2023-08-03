trigger GNE_SFA2_Tier_Level_Assignment_Trigger on Tier_Level_Assignment_gne__c(before insert, before update) {
    
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_Tier_Level_Assignment_Trigger') 
        && !GNE_SFA2_TierLvlAssignmentTrigger_Helper.inTierLevelTrig()) {
        
        GNE_SFA2_TierLvlAssignmentTrigger_Helper.setInTierLevelTrig(true);
        
        if(Trigger.isBefore && Trigger.isInsert){
            GNE_SFA2_TierLvlAssignment_Field_Updates.onBeforeInsert(Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate){
            GNE_SFA2_TierLvlAssignment_Field_Updates.onBeforeUpdate(Trigger.old, Trigger.new);
        }
        
        GNE_SFA2_TierLvlAssignmentTrigger_Helper.setInTierLevelTrig(false);
    }
}