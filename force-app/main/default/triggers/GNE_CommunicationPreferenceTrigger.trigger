trigger GNE_CommunicationPreferenceTrigger on Communication_Preference_gne__c (before insert) {
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_CommunicationPrefTriggerHandler')) {
        if(Trigger.isBefore && Trigger.isInsert) {
            GNE_CommunicationPrefTriggerHandler.runValidation();
        } else if(Trigger.isBefore && Trigger.isUpdate) {

        } else if(Trigger.isBefore && Trigger.isDelete) {

        } else if(Trigger.isAfter && Trigger.isInsert) {

        } else if(Trigger.isAfter && Trigger.isUpdate) {

        } else if(Trigger.isAfter && Trigger.isDelete) {

        }
    }
}