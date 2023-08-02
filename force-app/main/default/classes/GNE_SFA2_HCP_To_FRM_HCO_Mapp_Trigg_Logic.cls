public without sharing class GNE_SFA2_HCP_To_FRM_HCO_Mapp_Trigg_Logic {
	public static void avoidMappingsDuplicate(Map<Id, HCP_To_FRM_HCO_Mapping_gne__c> triggerOldMap, List<HCP_To_FRM_HCO_Mapping_gne__c> triggerNew) {
        Set<Id> addressIds = new Set<Id>();
        for (HCP_To_FRM_HCO_Mapping_gne__c htfm : triggerNew) {
            if (triggerOldMap == null || (triggerOldMap != null && htfm.HCP_Address_gne__c != triggerOldMap.get(htfm.Id).HCP_Address_gne__c)) {
                addressIds.add(htfm.HCP_Address_gne__c);
            }
        }

        if (!addressIds.isEmpty()) {
            Map<Id, Integer> existingMappingsPerAddress = new Map<Id, Integer>();
            for (Address_vod__c addr : [SELECT Id, (SELECT Id FROM FRM_HCO_Mappings__r), (SELECT Id FROM HCP_TO_FRM_HCO_Mappings__r) FROM Address_vod__c WHERE Id IN : addressIds]) {
                Integer mappingsSize = addr.FRM_HCO_Mappings__r.size() + addr.HCP_TO_FRM_HCO_Mappings__r.size();
                existingMappingsPerAddress.put(addr.Id, mappingsSize);
            }

            for (HCP_To_FRM_HCO_Mapping_gne__c htfm : triggerNew) {
                if (existingMappingsPerAddress.containsKey(htfm.HCP_Address_gne__c)) {
                	Integer mappingsCount = existingMappingsPerAddress.get(htfm.HCP_Address_gne__c);
                	if (mappingsCount > 0) {
                    	htfm.addError(System.Label.GNE_SFA2_ErrMsg_Mapping_Duplicate);
                	} else {
                    	existingMappingsPerAddress.put(htfm.HCP_Address_gne__c, mappingsCount + 1);
                	}
                }
            }    
        }
    }
}