public with sharing class EMS_Checklist_Field_Updates {

    private static Map<String, EMS_Checklist_gne__c> existingChecklitstMap = new Map<String, EMS_Checklist_gne__c>();
    // This map contains external Id as a key value without having a verison number value at the end
    private static Map<String, EMS_Checklist_gne__c> truncatedKey_lastChecklistVersionMap = new Map<String, EMS_Checklist_gne__c>();

    public static void onBeforeInsert(List<EMS_Checklist_gne__c> newRecords) {
        prepare(newRecords, new Set<Id>());
        // firstly generate External Ids, then do validation
        generateExternalIds(newRecords, new Map<Id, EMS_Checklist_gne__c>());
    }

    public static void onBeforeUpdate(Map<Id, EMS_Checklist_gne__c> oldRecords, List<EMS_Checklist_gne__c> newRecords) {
        prepare(newRecords, oldRecords.keySet());
        // firstly generate External Ids, then do validation
        generateExternalIds(newRecords, oldRecords);
    }

    // Help Methods
    private static void generateExternalIds(List<EMS_Checklist_gne__c> newRecords, Map<Id, EMS_Checklist_gne__c> oldRecords) {
        for (EMS_Checklist_gne__c record : newRecords) {
            String externalId_truncated = record.Event_Type_gne__c +
                    '_' + record.Event_Sub_Type_gne__c +
                    '_' + record.Type_gne__c +
                    '_' + String.valueOf(record.Index_gne__c) +
                    '_';

            String externalId = '';
            Integer versionNumber = 1;

            if (truncatedKey_lastChecklistVersionMap.containsKey(externalId_truncated)) {
                if (oldRecords.containsKey(record.Id)) { // check if record is updated
                    // version could not be changed
                    versionNumber = (Integer) oldRecords.get(record.Id).Verison_Number_gne__c;
                    // change External id
                    externalId = externalId_truncated + String.valueOf(versionNumber);
                } else { // record is created
                    Decimal existingLastVerison = truncatedKey_lastChecklistVersionMap.get(externalId_truncated).Verison_Number_gne__c;
                    versionNumber = Integer.valueOf(existingLastVerison) + 1;
                    externalId = externalId_truncated + String.valueOf(versionNumber);
                }
            } else {
                // Create a new record with a version number = 1
                externalId = externalId_truncated + String.valueOf(versionNumber);
            }

            record.External_Id_gne__c = externalId;
            record.Verison_Number_gne__c = versionNumber;
        }
    }

    private static void prepare(List<EMS_Checklist_gne__c> newRecords, Set<Id> updIds) {
        Set<String> eventTypes = new Set<String>();
        Set<String> eventSubTypes = new Set<String>();
        for (EMS_Checklist_gne__c record : newRecords) {
            eventTypes.add(record.Event_Type_gne__c);
            eventSubTypes.add(record.Event_Sub_Type_gne__c);
        }

        List<EMS_Checklist_gne__c> existingChecklitst = [
                SELECT External_Id_gne__c, Start_Date_gne__c, End_Date_gne__c, Verison_Number_gne__c
                FROM EMS_Checklist_gne__c
                WHERE Event_Type_gne__c IN :eventTypes
                AND Event_Sub_Type_gne__c IN :eventSubTypes
                AND Id NOT IN :updIds
                LIMIT 5000
        ];

        for (EMS_Checklist_gne__c checklist: existingChecklitst) {
            String key = checklist.External_Id_gne__c;
            existingChecklitstMap.put(key, checklist);

            if (checklist.Verison_Number_gne__c != null) {
                String truncatedKey = key.substring(0, key.length() - String.valueOf(checklist.Verison_Number_gne__c).length());
                if (truncatedKey_lastChecklistVersionMap.containsKey(truncatedKey)) {
                    Decimal existingVerison = truncatedKey_lastChecklistVersionMap.get(truncatedKey).Verison_Number_gne__c;
                    Decimal currentVersion = checklist.Verison_Number_gne__c;

                    if (existingVerison < currentVersion) {
                        // Add only the checklist the last version
                        truncatedKey_lastChecklistVersionMap.put(truncatedKey, checklist);
                    }
                } else {
                    truncatedKey_lastChecklistVersionMap.put(truncatedKey, checklist);
                }
            }
        }
    }
}