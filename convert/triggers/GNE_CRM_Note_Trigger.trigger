trigger GNE_CRM_Note_Trigger on Note (after insert, after update) {
    if (GNE_SFA2_Util.isAdminMode() ) return;
    
    if(Trigger.isAfter && Trigger.isInsert){
        GNE_CRM_Note_TriggerHandler.onAfterInsert();
    } else if (Trigger.isAfter && Trigger.isUpdate) {
        GNE_CRM_Note_TriggerHandler.onAfterUpdate();
    }
}