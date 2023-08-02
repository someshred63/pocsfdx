public with sharing class EMS_Checklist_Validation_Rules {

    private static Map<String, EMS_Checklist_gne__c> existingChecklitstMap = new Map<String, EMS_Checklist_gne__c>();
    // This map contains external Id as a key value without having a verison number value at the end
    private static Map<String, EMS_Checklist_gne__c> truncatedKey_lastChecklistVersionMap = new Map<String, EMS_Checklist_gne__c>();
    // This map contains the List of all checklist version for specified index (Index 1 might have 1 or more version). This map will be used for Date validation
    private static Map<String, Map<Decimal, EMS_Checklist_gne__c>> truncatedKey_allChecklistVersionMap = new Map<String, Map<Decimal, EMS_Checklist_gne__c>>();

    public static boolean skipTriggerValidationRules = false;


    // Populate the map that contains External Id and lisf of Checklists
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
                if (truncatedKey_allChecklistVersionMap.containsKey(truncatedKey)) {
                    Map<Decimal, EMS_Checklist_gne__c> temp = truncatedKey_allChecklistVersionMap.get(truncatedKey);
                    temp.put(checklist.Verison_Number_gne__c, checklist);
                    truncatedKey_allChecklistVersionMap.put(truncatedKey, temp);
                } else {
                    Map<Decimal, EMS_Checklist_gne__c> temp = new Map<Decimal, EMS_Checklist_gne__c>();
                    temp.put(checklist.Verison_Number_gne__c, checklist);
                    truncatedKey_allChecklistVersionMap.put(truncatedKey, temp);
                }

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

    public static void validate(List<EMS_Checklist_gne__c> newRecords, Map<Id, EMS_Checklist_gne__c> oldRecords) {
        if (skipTriggerValidationRules) return;

        prepare(newRecords, oldRecords.keySet());

        Boolean isUpdate = !oldRecords.isEmpty();
        for (EMS_Checklist_gne__c record : newRecords) {
            String key = record.External_Id_gne__c;
            String truncatedKey = key.substring(0, key.length() - String.valueOf(record.Verison_Number_gne__c).length());

            if (truncatedKey_allChecklistVersionMap.containsKey(truncatedKey)) {
                Map<Decimal, EMS_Checklist_gne__c> versionsMap = truncatedKey_allChecklistVersionMap.get(truncatedKey);

                Date startDate = record.Start_Date_gne__c;
                Date endDate = record.End_Date_gne__c;

                // General Date validation
                if (endDate < startDate) {
                    record.addError('Please validate Start and End Dates');
                    break;
                }

                // Validation for records that are updated
                if (isUpdate) {
                    Decimal currentVersion = record.Verison_Number_gne__c;
                    // Next following version of checklist if exists
                    EMS_Checklist_gne__c vTop = (versionsMap.containsKey(currentVersion + 1)) ? versionsMap.get(currentVersion + 1) : null;
                    // Previous version of checklist if exists
                    EMS_Checklist_gne__c vBottom = (versionsMap.containsKey(currentVersion - 1)) ? versionsMap.get(currentVersion - 1) : null;

                    if (vTop != null && vBottom != null) {
                        if (vBottom.End_Date_gne__c >= startDate || vTop.Start_Date_gne__c <= endDate) {
                            record.addError('Available date period is: from ' + String.valueOf(vBottom.End_Date_gne__c.addDays(1)) +
                                    ' to ' + String.valueOf(vTop.Start_Date_gne__c.addDays(-1)));
                        }

                    } else if (vTop != null && vBottom == null) {
                        if (vTop.Start_Date_gne__c <= endDate) {
                            record.addError('End Date should be less than ' + String.valueOf(vTop.Start_Date_gne__c));
                        }
                    } else if (vTop == null && vBottom != null) {
                        if (vBottom.End_Date_gne__c >= startDate) {
                            record.addError('Start Date should be more than ' + String.valueOf(vBottom.End_Date_gne__c));
                        }
                    }
                } else {
                    // Validation for records that are created
                    Decimal currentVersion = record.Verison_Number_gne__c;
                    // Previous version of checklist if exists
                    EMS_Checklist_gne__c vBottom = (versionsMap.containsKey(currentVersion - 1)) ? versionsMap.get(currentVersion - 1) : null;

                    if (vBottom != null) {
                        // if the last version of checklist has End Date = null, throw the error
                        if (vBottom.End_Date_gne__c == null) {
                            record.addError('User has to set End Date for the actual version of checklist record');
                            break;
                        }

                        // if Start Date of newly created record is betweend exising dates for the last version
                        if (vBottom.Start_Date_gne__c <= startDate && startDate <= vBottom.End_Date_gne__c) {
                            record.addError('Start Date should be above the existing date period (' + String.valueOf(vBottom.End_Date_gne__c) + ')');
                            break;
                        }

                        // if Start Date of newly created record is before existing Start Date for the last version
                        if (startDate <= vBottom.Start_Date_gne__c) {
                            record.addError('Start Date should be above the existing date period (' + String.valueOf(vBottom.Start_Date_gne__c) + ')');
                            break;
                        }
                    }
                }
            }
        }
    }
}