/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-10
*  Description: This is a trigger for handling User validations, field updates and child record updates
*  Test class: GNE_SFA2_User_Trigger_Test
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
trigger GNE_SFA2_User_Trigger on User (after delete, after insert, after undelete,after update, before delete, before insert, before update) {
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_User_Trigger__c')) {
        Boolean validationFailed = false;
        if (Trigger.isBefore && Trigger.isInsert) {
            validationFailed = GNE_SFA2_User_Validation_Rules.onBeforeInsert(Trigger.new);
            if (!validationFailed) {
                GNE_SFA2_User_Email_Notifications.onBeforeInsert(Trigger.new);
                GNE_SFA2_User_Field_Updates.onBeforeInsert(Trigger.new);
                GNE_SFA2_Profile_Mapping_Utils.setUserFieldsByMappingFromTrigger(Trigger.new);
            }
        } else if (Trigger.isBefore && Trigger.isUpdate) {
            validationFailed = GNE_SFA2_User_Validation_Rules.onBeforeUpdate(Trigger.old, Trigger.new);
            if (!validationFailed) {
                GNE_SFA2_User_Field_Updates.onBeforeUpdate(Trigger.old, Trigger.new);
                GNE_SFA2_Profile_Mapping_Utils.setUserFieldsByMappingFromTrigger(Trigger.new);
            }
        } else if (Trigger.isAfter && Trigger.isInsert) {
            if (!validationFailed) {
                GNE_SFA2_User_Child_Record_Updates.onAfterInsert(Trigger.new);
                GNE_SFA2_User_Field_Updates.onAfterInsert(Trigger.new);
            }
        } else if (Trigger.isAfter && Trigger.isUpdate) {
            if (!validationFailed) {
                GNE_SFA2_User_Child_Record_Updates.onAfterUpdate(Trigger.oldMap, Trigger.new);
            }
        }
    }
}