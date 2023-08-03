/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/10/2012
*  Description: This Trigger GNE_SFA2_Interaction_Trigger Consolidates all triggers on Call2_vod__c object
*
*  Modification History
*  Date         Name        Description
*  25.02.2014   hrycenkm    Refactoring code.
*
*************************************************************/

trigger GNE_SFA2_Interaction_Trigger on Call2_vod__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Interaction_Trigger_Helper.inInteractionTrig()) {
        GNE_SFA2_Interaction_Trigger_Helper.setInteractionTrig(true);
        
        if (Trigger.isInsert && Trigger.isBefore) {
            GNE_SFA2_Interaction_Validation_Rules.onBeforeInsert(Trigger.new);
            GNE_SFA2_Interaction_Field_Updates.onBeforeInsert(Trigger.new);
        } else if (Trigger.isInsert && Trigger.isAfter) {
            GNE_SFA2_Interaction_Child_Record_Update.onAfterInsert(Trigger.new);
            GNE_SFA2_Interaction_Adv_Future.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate && Trigger.isBefore) {
            GNE_SFA2_Interaction_Validation_Rules.onBeforeUpdate(Trigger.old, Trigger.new);
            GNE_SFA2_Interaction_Field_Updates.onBeforeUpdate(Trigger.oldMap, Trigger.new);
        } else if (Trigger.isUpdate && Trigger.isAfter) {
            GNE_SFA2_Interaction_Child_Record_Update.onAfterUpdate(Trigger.new);
            GNE_SFA2_Interaction_Adv_Future.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
        } else if (Trigger.isDelete && Trigger.isBefore) {
            GNE_SFA2_Interaction_Validation_Rules.onBeforeDelete(Trigger.old);
            GNE_SFA2_Interaction_Child_Record_Update.onBeforeDelete(Trigger.oldMap);
            GNE_SFA2_Deleted_Records_Util.onBeforeDelete(Trigger.old, Call2_vod__c.getSObjectType());
        } else if (Trigger.isDelete && Trigger.isAfter) {
            GNE_SFA2_Interaction_Adv_Future.onAfterDelete(Trigger.old);
            GNE_SFA2_Deleted_Records_Util.onAfterDelete(Trigger.old, Call2_vod__c.getSObjectType());
        }
        
        GNE_SFA2_Interaction_Trigger_Helper.setInteractionTrig(false);
    }
}