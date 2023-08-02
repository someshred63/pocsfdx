trigger GNE_SFA2_HCP_To_FRM_HCO_Mapping_Trigger on HCP_To_FRM_HCO_Mapping_gne__c (before insert, before update) {
	if (GNE_SFA2_Util.isAdminMode()){
        return;
    }

    if(Trigger.isBefore && Trigger.isInsert) {
        GNE_SFA2_HCP_To_FRM_HCO_Mapp_Trigg_Logic.avoidMappingsDuplicate(null, Trigger.new);
    } else if(Trigger.isBefore && Trigger.isUpdate) {
        GNE_SFA2_HCP_To_FRM_HCO_Mapp_Trigg_Logic.avoidMappingsDuplicate(Trigger.oldMap, Trigger.new);
    } else if(Trigger.isBefore && Trigger.isDelete) {            
            
    } else if(Trigger.isAfter && Trigger.isInsert) {

    } else if(Trigger.isAfter && Trigger.isUpdate) {
            
    } else if(Trigger.isAfter && Trigger.isDelete) {
    	
    }
}