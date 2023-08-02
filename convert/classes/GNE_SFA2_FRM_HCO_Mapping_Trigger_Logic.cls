public without sharing class GNE_SFA2_FRM_HCO_Mapping_Trigger_Logic {
    public static void storeInformationAboutDeletingRecords() {
        insert createCollectionToInsert();
    }

    public static void avoidMappingsDuplicate(Map<Id, FRM_HCO_Mapping_gne__c> triggerOldMap, List<FRM_HCO_Mapping_gne__c> triggerNew) {
        Set<Id> addressIds = new Set<Id>();
        for (FRM_HCO_Mapping_gne__c fm : triggerNew) {
            if (triggerOldMap == null || (triggerOldMap != null && fm.HCP_Address_gne__c != triggerOldMap.get(fm.Id).HCP_Address_gne__c)) {
                addressIds.add(fm.HCP_Address_gne__c);
            }
        }

        if (!addressIds.isEmpty()) {
            Map<Id, Integer> existingMappingsPerAddress = new Map<Id, Integer>();
            for (Address_vod__c addr : [SELECT Id, (SELECT Id FROM FRM_HCO_Mappings__r) FROM Address_vod__c WHERE Id IN : addressIds]) {
                Integer mappingsSize = addr.FRM_HCO_Mappings__r.size();
                existingMappingsPerAddress.put(addr.Id, mappingsSize);
            }

            for (FRM_HCO_Mapping_gne__c fm : triggerNew) {
                if (existingMappingsPerAddress.containsKey(fm.HCP_Address_gne__c)) {
                    Integer mappingsCount = existingMappingsPerAddress.get(fm.HCP_Address_gne__c);
                    if (mappingsCount > 0) {
                        fm.addError(System.Label.GNE_SFA2_ErrMsg_Mapping_Duplicate);
                    } else {
                        existingMappingsPerAddress.put(fm.HCP_Address_gne__c, mappingsCount + 1);
                    }
                }
            }    
        }
    }

    public static void deleteTempMappings(List<FRM_HCO_Mapping_gne__c> triggerNew) {
        Map<Id, HCP_To_FRM_HCO_Mapping_gne__c> tempMappingToDelete = new Map<Id, HCP_To_FRM_HCO_Mapping_gne__c>();
        Set<Id> acctIds = new Set<Id>();
        Set<Id> addrIds = new Set<Id>();
        Map<String, HCP_To_FRM_HCO_Mapping_gne__c> tempMappingsMap = new Map<String, HCP_To_FRM_HCO_Mapping_gne__c>();

        for (FRM_HCO_Mapping_gne__c fhm : triggerNew) {
            acctIds.add(fhm.HCP_Account_gne__c);
            addrIds.add(fhm.HCP_Address_gne__c);
        }

        for (HCP_To_FRM_HCO_Mapping_gne__c tempMap : [
            SELECT Id, HCP_Account_gne__c, HCP_Address_gne__c, PACT_Prescriber_Id_gne__c, PACT_Prescriber_Address_Id_gne__c
            FROM HCP_To_FRM_HCO_Mapping_gne__c
            WHERE HCP_Account_gne__c IN : acctIds
            AND HCP_Address_gne__c IN : addrIds
        ]) {
            tempMappingsMap.put(tempMap.HCP_Account_gne__c + '_' + tempMap.HCP_Address_gne__c, tempMap);
        }

        for (FRM_HCO_Mapping_gne__c fhm : triggerNew) {
            String uniqueKey = fhm.HCP_Account_gne__c + '_' + fhm.HCP_Address_gne__c;
            if (tempMappingsMap.containsKey(uniqueKey)) {
                tempMappingToDelete.put(tempMappingsMap.get(uniqueKey).Id, tempMappingsMap.get(uniqueKey));
            }
        }

        if (!tempMappingToDelete.isEmpty()) {
            delete tempMappingToDelete.values();
        }
    }
    
    public static void updateRecordsOfPactIds(List<FRM_HCO_Mapping_gne__c> triggerNew) {
        Set<Id> acctIds = new Set<Id>();
        Set<Id> addrIds = new Set<Id>();
        Map<String, HCP_To_FRM_HCO_Mapping_gne__c> tempMappingsMap = new Map<String, HCP_To_FRM_HCO_Mapping_gne__c>();

        for (FRM_HCO_Mapping_gne__c fhm : triggerNew) {
            acctIds.add(fhm.HCP_Account_gne__c);
            addrIds.add(fhm.HCP_Address_gne__c);
        }

        for (HCP_To_FRM_HCO_Mapping_gne__c tempMap : [
            SELECT Id, HCP_Account_gne__c, HCP_Address_gne__c, PACT_Prescriber_Id_gne__c, PACT_Prescriber_Address_Id_gne__c
            FROM HCP_To_FRM_HCO_Mapping_gne__c
            WHERE HCP_Account_gne__c IN : acctIds
            AND HCP_Address_gne__c IN : addrIds
        ]) {
            tempMappingsMap.put(tempMap.HCP_Account_gne__c + '_' + tempMap.HCP_Address_gne__c, tempMap);
        }

        for (FRM_HCO_Mapping_gne__c fhm : triggerNew) {
            String uniqueKey = fhm.HCP_Account_gne__c + '_' + fhm.HCP_Address_gne__c;
            if (tempMappingsMap.containsKey(uniqueKey)) {
                HCP_To_FRM_HCO_Mapping_gne__c tempMap = tempMappingsMap.get(uniqueKey);
                if (String.isBlank(fhm.PACT_Prescriber_Id_gne__c) && String.isBlank(fhm.PACT_Prescriber_Address_Id_gne__c)) {
                    fhm.PACT_Prescriber_Id_gne__c = tempMap.PACT_Prescriber_Id_gne__c;
                    fhm.PACT_Prescriber_Address_Id_gne__c = tempMap.PACT_Prescriber_Address_Id_gne__c;
                }
            }
        }
    }    

    private static HCP_To_FRM_HCO_Mapping_gne__c createHCPToFRMHCOMappings(FRM_HCO_Mapping_gne__c mapping, String products) {
        return new HCP_To_FRM_HCO_Mapping_gne__c(
            HCP_Account_gne__c = mapping.HCP_Account_gne__c,
            HCP_Address_gne__c = mapping.HCP_Address_gne__c,
            PACT_Prescriber_Id_gne__c = mapping.PACT_Prescriber_Id_gne__c,
            PACT_Prescriber_Address_Id_gne__c = mapping.PACT_Prescriber_Address_Id_gne__c,
            Products_gne__c = products
        );
    }

    private static FRM_HCO_Mapping_Deleted_gne__c createRecord(FRM_HCO_Mapping_gne__c mapping) {
        String truncatedMDMID = (String.isNotEmpty(mapping.HCP_SFA_MDM_Id_gne__c) && mapping.HCP_SFA_MDM_Id_gne__c.length() > 254) ? mapping.HCP_SFA_MDM_Id_gne__c.left(255) : mapping.HCP_SFA_MDM_Id_gne__c;
        return new FRM_HCO_Mapping_Deleted_gne__c(
            Name = mapping.Id,
            FRM_HCO_Account_Id_gne__c = mapping.FRM_HCO_Account_gne__c,
            PACT_Prescriber_Id_gne__c = mapping.PACT_Prescriber_Id_gne__c,
            HCP_Account_gne__c = mapping.HCP_Account_gne__c,
            HCP_MDM_Id_gne__c = truncatedMDMID,
            PACT_Prescriber_Address_Id_gne__c = mapping.PACT_Prescriber_Address_Id_gne__c,
            HCP_Address_Id_gne__c = mapping.HCP_Address_gne__c,
            HCP_Address_MDM_Id_gne__c = mapping.HCP_SFA_Address_MDM_Id__c
        );
    }

    private static List<FRM_HCO_Mapping_Deleted_gne__c> createCollectionToInsert() {
        List<FRM_HCO_Mapping_Deleted_gne__c> toInsert = new List<FRM_HCO_Mapping_Deleted_gne__c>();
        for (FRM_HCO_Mapping_gne__c m : (FRM_HCO_Mapping_gne__c[])Trigger.old) {
            toInsert.add(createRecord(m));
        }
        return toInsert;
    }
}