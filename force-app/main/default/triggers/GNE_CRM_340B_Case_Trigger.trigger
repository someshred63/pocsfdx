trigger GNE_CRM_340B_Case_Trigger on GNE_CRM_340B_Case__c (before insert, before update, before delete, after insert, after update, after delete) {
    if (GNE_SFA2_Util.isAdminMode() || GNE_SFA2_Util.isTriggerDisabled('GNE_CRM_340B_Case_Trigger__c') ) {
        return;
    }
    if(Trigger.isBefore && Trigger.isInsert) {
        GNE_CRM_340B_Case_TriggerHandler.onBeforeInsert(Trigger.new);
    } else if(Trigger.isBefore && Trigger.isUpdate) {
        GNE_CRM_340B_Case_TriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
    } else if(Trigger.isBefore && Trigger.isDelete) {
        GNE_CRM_340B_Case_TriggerHandler.onBeforeDelete(Trigger.old);
    } else if(Trigger.isAfter && Trigger.isInsert) {
        GNE_CRM_340B_Case_TriggerHandler.onAfterInsert(Trigger.new, Trigger.oldMap);
    } else if(Trigger.isAfter && Trigger.isUpdate) {
        GNE_CRM_340B_Case_TriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    } else if(Trigger.isAfter && Trigger.isDelete) {
        GNE_CRM_340B_Case_TriggerHandler.onAfterDelete(Trigger.old);
    }
}