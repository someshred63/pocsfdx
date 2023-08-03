trigger CORE_Merge_ArchiveAppRecord_Trigger on CORE_Merge_Archive_App_Record__c (before delete) {
    if(!CORE_Merge_Util.isTriggerDisabled(CORE_Merge_Archive_App_Record__c.sObjectType)) {
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_App_Record__c.sObjectType, true);
        
        if(Trigger.isBefore && Trigger.isDelete) {
            CORE_Merge_Util.blockDelete(Trigger.old);
        }
        
        CORE_Merge_Util.setInTrigger(CORE_Merge_Archive_App_Record__c.sObjectType, false);
    }
}