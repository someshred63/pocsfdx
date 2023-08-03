trigger GNE_SFA2_FRM_HCO_Mapping_Trigger on FRM_HCO_Mapping_gne__c (before insert, before update, after insert, after delete) {
    if (!GNE_SFA2_Util.isAdminMode()) {
        if(Trigger.isBefore && Trigger.isInsert) {
    		GNE_SFA2_FRM_HCO_Mapping_Trigger_Logic.updateRecordsOfPactIds(Trigger.new);
            GNE_SFA2_FRM_HCO_Mapping_Trigger_Logic.avoidMappingsDuplicate(null, Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            GNE_SFA2_FRM_HCO_Mapping_Trigger_Logic.avoidMappingsDuplicate(Trigger.oldMap, Trigger.new);
        } else if(Trigger.isBefore && Trigger.isDelete) {            
                
        } else if(Trigger.isAfter && Trigger.isInsert) {
        	GNE_SFA2_FRM_HCO_Mapping_Trigger_Logic.deleteTempMappings(Trigger.new);
        	GNE_SFA2_Notification_Handler.onAfterInsertMapping(Trigger.new);
        } else if(Trigger.isAfter && Trigger.isUpdate) {
                
        } else if(Trigger.isAfter && Trigger.isDelete) {            
            GNE_SFA2_Deleted_Records_Util.onAfterDelete(Trigger.old, FRM_HCO_Mapping_gne__c.getSObjectType());
            GNE_SFA2_Notification_Handler.onAfterDeleteMapping(Trigger.old);
        }
    }

    if(Trigger.isAfter && Trigger.isDelete) {
        GNE_SFA2_FRM_HCO_Mapping_Trigger_Logic.storeInformationAboutDeletingRecords();
    }
}