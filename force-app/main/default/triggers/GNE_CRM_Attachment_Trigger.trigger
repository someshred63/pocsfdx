trigger GNE_CRM_Attachment_Trigger on Attachment (after insert, after update) {
    if (GNE_SFA2_Util.isAdminMode() ) return;
    
    if(Trigger.isAfter && Trigger.isInsert){
        GNE_CRM_Attachment_TriggerHandler.onAfterInsert();
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        GNE_CRM_Attachment_TriggerHandler.onAfterUpdate();
    }
}