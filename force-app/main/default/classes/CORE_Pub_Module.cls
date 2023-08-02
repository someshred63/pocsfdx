public with sharing class CORE_Pub_Module {

    private static Map<String, Schema.DescribeSObjectResult> sObjectDescribeMap = new Map<String, Schema.DescribeSObjectResult>();
    private static Map<String, Set<Schema.sObjectField>> fieldsToJSONFormatValidationSetMap = new Map<String, Set<Schema.sObjectField>>();
    private static Set<Schema.sObjectField> customRequiredPartyFieldsINDSet;
    private static Set<Schema.sObjectField> customRequiredPartyFieldsORGSet;
    private static Set<Schema.sObjectField> validPartyFieldsOnlyINDSet;
    private static Set<Schema.sObjectField> validPartyFieldsOnlyORGSet;

    private static Boolean isPubAdminMode;

    public static void validateJSONFieldsFormat(List<SObject> triggerNew, List<SObject> triggerOld) {
        for (Integer i = 0; i < triggerNew.size(); i++) {
            for (Schema.sObjectField field : getFieldsToJSONFormatValidationSet(triggerNew.getSObjectType())) {
                Type jsonType = getJSONType(field);
                String fieldValue = String.valueOf(triggerNew[i].get(field));

                if ((String.isNotBlank(fieldValue) && jsonType != null && triggerOld != null && fieldValue != String.valueOf(triggerOld[i].get(field))) || (triggerOld == null && String.isNotBlank(fieldValue) && jsonType != null)) {
                    try {
                        List<BaseRecord> baseRecordArray = (List<BaseRecord>)JSON.deserializeStrict(fieldValue, jsonType);
                        for (Integer j = 0; j < baseRecordArray.size(); j++) {
                            if (baseRecordArray[j].isValid() == false) {
                                addErrorToRecord(triggerNew[i], field, 'Missing value for ' + (j + 1) + ((j + 1) == 1 ? 'st' : (j + 1) == 2 ? 'nd' : (j + 1) == 3 ? 'rd' : 'th') + ' property');
                                break;
                            }
                        }
                    } catch (Exception e) {
                        addErrorToRecord(triggerNew[i], field, e.getMessage());
                    }
                }
            }
        }
    }

    private static Set<Schema.sObjectField> getFieldsToJSONFormatValidationSet(Schema.SObjectType sObjectType) {
        if(!fieldsToJSONFormatValidationSetMap.isEmpty() && fieldsToJSONFormatValidationSetMap.containsKey(sObjectType.getDescribe().getName())) {
            return fieldsToJSONFormatValidationSetMap.get(sObjectType.getDescribe().getName());
        } else {
            Set<Schema.sObjectField> fieldsToJSONFormatValidationSet = new Set<Schema.sObjectField>();
            for (Schema.SObjectField field : getSObjectDescribe(sObjectType).fields.getMap().values()) {
                String fieldName = String.valueOf(field.getDescribe().getSObjectField());
                if (fieldName.toUpperCase().contains('JSON')) {
                    fieldsToJSONFormatValidationSet.add(field);
                }
            }

            fieldsToJSONFormatValidationSetMap.put(sObjectType.getDescribe().getName(), fieldsToJSONFormatValidationSet);
            return fieldsToJSONFormatValidationSetMap.get(sObjectType.getDescribe().getName());
        }
    }

    private static Type getJSONType(Schema.sObjectField field) {
        String fieldHelpText = field.getDescribe().getInlineHelpText(); 
        if(String.isNotBlank(fieldHelpText)) {
            if(fieldHelpText.containsIgnoreCase('CODES') && fieldHelpText.containsIgnoreCase('VALUES') && fieldHelpText.containsIgnoreCase('EXTENSIONS')) {
                return List<CodeAndValueAndExtensionRecord>.class;
            } else if(fieldHelpText.containsIgnoreCase('CODES') && fieldHelpText.containsIgnoreCase('VALUES')) {
                return List<CodeAndValueRecord>.class;
            } else if(fieldHelpText.containsIgnoreCase('CODES')) {
                return List<CodeRecord>.class;
            } else if(fieldHelpText.containsIgnoreCase('VALUES')) {
                return List<ValueRecord>.class;
            }
        }

        return null;
    }

    public static void populateLookupRefColumn (List<SObject> childRecords, String childTableParentFieldName, String childTableParentLookupFieldName, String parentTableName, String parentExternalFieldName) {

        Set<String> parentFieldIdSet = fetchSet(childRecords, childTableParentFieldName);

        if(parentFieldIdSet.isEmpty()) {
            return;
        }

        Map<String, String> m_parentFieldName_id = new Map<String, String> ();

        String parentQuery = 'SELECT id, ' + parentExternalFieldName + ' FROM ' + parentTableName + ' WHERE ' + parentExternalFieldName + ' IN :parentFieldIdSet';

        for (SObject parentRecord : Database.query(parentQuery)) {
            m_parentFieldName_id.put (String.valueOf(parentRecord.get(parentExternalFieldName)), parentRecord.id);
        }

        for (SObject childRecord : childRecords) {
            String parentExternalId = String.valueOf(childRecord.get(childTableParentFieldName));
            if (parentExternalId != null) {
                String parentRecordId = m_parentFieldName_id.get(parentExternalId);
                if (String.isBlank(parentRecordId)) {
                    childRecord.addError('Parent External Id ' + parentExternalId + ' not found in the parent table ' + parentTableName + '.');
                } else {
                    childRecord.put(childTableParentLookupFieldName, parentRecordId);
                }
            }
        }
    }

    private static Set<String> fetchSet(List<sObject> sObjectList, String fieldName) {
        Set<String> stringSet = new Set<String>();
        for (sObject sObjectItem : sObjectList) {
            if(sObjectItem.get(fieldName) != null) {
                stringSet.add((String)sObjectItem.get(fieldName));
            }
        }
        return stringSet;
    }

    public static void checkCustomRequiredConditionsForParty(List<SObject> triggerNew) {
        for (Integer i = 0; i < triggerNew.size(); i++) {
            String partyType = String.valueOf(triggerNew[i].get('Type_gne__c'));
            if(String.isNotBlank(partyType) && partyType.toUpperCase() == 'ORG') {
                if(!getCustomRequiredPartyFieldsORGSet(triggerNew.getSObjectType()).isEmpty()) {
                    for(Schema.SObjectField field : getCustomRequiredPartyFieldsORGSet(triggerNew.getSObjectType())) {
                        if(String.isBlank(String.valueOf(triggerNew[i].get(field)))) {
                            addErrorToRecord(triggerNew[i], field, 'The field is required for ORG type party.');
                            break;
                        }
                    }
                }
            } else if(String.isNotBlank(partyType) && partyType.toUpperCase() == 'IND') {
                if(!getCustomRequiredPartyFieldsINDSet(triggerNew.getSObjectType()).isEmpty()) {
                    for(Schema.SObjectField field : getCustomRequiredPartyFieldsINDSet(triggerNew.getSObjectType())) {
                        if(String.isBlank(String.valueOf(triggerNew[i].get(field)))) {
                            addErrorToRecord(triggerNew[i], field, 'The field is required for IND type party.');
                            break;
                        }
                    }
                }
            }
        }
    }

    public static void validPartyFieldsBasedOnType(List<SObject> triggerNew) {
        for (Integer i = 0; i < triggerNew.size(); i++) {
            String partyType = String.valueOf(triggerNew[i].get('Type_gne__c'));
            if(String.isNotBlank(partyType) && partyType.toUpperCase() == 'ORG') {
                if(!getValidPartyFieldsOnlyINDSet(triggerNew.getSObjectType()).isEmpty()) {
                    for(Schema.SObjectField field : getValidPartyFieldsOnlyINDSet(triggerNew.getSObjectType())) {
                        if(String.isNotBlank(String.valueOf(triggerNew[i].get(field)))) {
                            addErrorToRecord(triggerNew[i], field, 'The field is available only for IND type party.');
                            break;
                        }
                    }
                }
            } else if(String.isNotBlank(partyType) && partyType.toUpperCase() == 'IND') {
                if(!getValidPartyFieldsOnlyORGSet(triggerNew.getSObjectType()).isEmpty()) {
                    for(Schema.SObjectField field : getValidPartyFieldsOnlyORGSet(triggerNew.getSObjectType())) {
                        if(String.isNotBlank(String.valueOf(triggerNew[i].get(field)))) {
                            addErrorToRecord(triggerNew[i], field, 'The field is available only for ORG type party.');
                            break;
                        }
                    }
                }
            }
        }
    }

    private static Set<Schema.SObjectField> getCustomRequiredPartyFieldsINDSet(Schema.SObjectType sObjectType) {
        if (customRequiredPartyFieldsINDSet != null) {
            return customRequiredPartyFieldsINDSet;
        } else {
            Set<String> requiredFields = new Set<String>();
            requiredFields.addAll(CORE_Found_Misc_Config__c.getValues('CustomRequiredPartyFieldsINDList') != null ? CORE_Found_Misc_Config__c.getValues('CustomRequiredPartyFieldsINDList').Configuration_Value_gne__c.split(',') : new List<String>());
            customRequiredPartyFieldsINDSet = new Set<Schema.SObjectField>();
            for (Schema.SObjectField field : getSObjectDescribe(sObjectType).fields.getMap().values()) {
                String fieldName = String.valueOf(field.getDescribe().getSObjectField());
                if (requiredFields.contains(fieldName)) {
                    customRequiredPartyFieldsINDSet.add(field);
                }
            }

            return customRequiredPartyFieldsINDSet;
        }
    }

    private static Set<Schema.SObjectField> getCustomRequiredPartyFieldsORGSet(Schema.SObjectType sObjectType) {
        if (customRequiredPartyFieldsORGSet != null) {
            return customRequiredPartyFieldsORGSet;
        } else {
            Set<String> requiredFields = new Set<String>();
            requiredFields.addAll(CORE_Found_Misc_Config__c.getValues('CustomRequiredPartyFieldsORGList') != null ? CORE_Found_Misc_Config__c.getValues('CustomRequiredPartyFieldsORGList').Configuration_Value_gne__c.split(',') : new List<String>());
            customRequiredPartyFieldsORGSet = new Set<Schema.SObjectField>();
            for (Schema.SObjectField field : getSObjectDescribe(sObjectType).fields.getMap().values()) {
                String fieldName = String.valueOf(field.getDescribe().getSObjectField());
                if (requiredFields.contains(fieldName)) {
                    customRequiredPartyFieldsORGSet.add(field);
                }
            }

            return customRequiredPartyFieldsORGSet;
        }
    }

    private static Set<Schema.SObjectField> getValidPartyFieldsOnlyINDSet(Schema.SObjectType sObjectType) {
        if (validPartyFieldsOnlyINDSet != null) {
            return validPartyFieldsOnlyINDSet;
        } else {
            Set<String> requiredFields = new Set<String>();
            requiredFields.addAll(CORE_Found_Misc_Config__c.getValues('ValidPartyFieldsOnlyINDList') != null ? CORE_Found_Misc_Config__c.getValues('ValidPartyFieldsOnlyINDList').Configuration_Value_gne__c.split(',') : new List<String>()); 
            validPartyFieldsOnlyINDSet = new Set<Schema.SObjectField>();
            for (Schema.SObjectField field : getSObjectDescribe(sObjectType).fields.getMap().values()) {
                String fieldName = String.valueOf(field.getDescribe().getSObjectField());
                if (requiredFields.contains(fieldName)) {
                    validPartyFieldsOnlyINDSet.add(field);
                }

                validPartyFieldsOnlyINDSet.addAll(getCustomRequiredPartyFieldsINDSet(sObjectType));
            }

            return validPartyFieldsOnlyINDSet;
        }
    }

    private static Set<Schema.SObjectField> getValidPartyFieldsOnlyORGSet(Schema.SObjectType sObjectType) {
        if (validPartyFieldsOnlyORGSet != null) {
            return validPartyFieldsOnlyORGSet;
        } else {
            Set<String> requiredFields = new Set<String>();
            requiredFields.addAll(CORE_Found_Misc_Config__c.getValues('ValidPartyFieldsOnlyORGList') != null ? CORE_Found_Misc_Config__c.getValues('ValidPartyFieldsOnlyORGList').Configuration_Value_gne__c.split(',') : new List<String>());
            validPartyFieldsOnlyORGSet = new Set<Schema.SObjectField>();
            for (Schema.SObjectField field : getSObjectDescribe(sObjectType).fields.getMap().values()) {
                String fieldName = String.valueOf(field.getDescribe().getSObjectField());
                if (requiredFields.contains(fieldName)) {
                    validPartyFieldsOnlyORGSet.add(field);
                }
            }

            validPartyFieldsOnlyORGSet.addAll(getCustomRequiredPartyFieldsORGSet(sObjectType));

            return validPartyFieldsOnlyORGSet;
        }
    }

    public static void assignBatchIndex(List<CORE_Pub_Party__c> triggerNew) {
    	Integer numberOfBatchesInd = CORE_Found_Misc_Config__c.getValues('NumberOfParallelAutoSubBatchesInd') != null ? Integer.valueOf(CORE_Found_Misc_Config__c.getValues('NumberOfParallelAutoSubBatchesInd').Configuration_Value_gne__c) : CORE_Subscribe_Util.DEFAULT_AUTO_SUB_BATCH_NUMBER_IND;
		Integer numberOfBatchesOrg = CORE_Found_Misc_Config__c.getValues('NumberOfParallelAutoSubBatchesOrg') != null ? Integer.valueOf(CORE_Found_Misc_Config__c.getValues('NumberOfParallelAutoSubBatchesOrg').Configuration_Value_gne__c) : CORE_Subscribe_Util.DEFAULT_AUTO_SUB_BATCH_NUMBER_ORG;
        Integer ind = 0;
        Integer org = 0;

        for (CORE_Pub_Party__c party : triggerNew) {
        	if(party.Type_gne__c == CORE_Subscribe_Base.PARTY_TYPE_INDIVIDUAL_CODE){
            	party.Batch_Index_gne__c = Math.mod(ind++, numberOfBatchesInd);
            }
            if(party.Type_gne__c == CORE_Subscribe_Base.PARTY_TYPE_ORGANIZATION_CODE){
            	party.Batch_Index_gne__c = numberOfBatchesInd + Math.mod(org++, numberOfBatchesOrg);
            }
        }
    }

    public static void updateLastPubUpsertDate(List<CORE_Pub_Party__c> triggerNew) {
        for (CORE_Pub_Party__c party : triggerNew) {
            party.Last_Pub_Upsert_Date_gne__c = Datetime.now();
        }
    }

    private static Schema.DescribeSObjectResult getSObjectDescribe(Schema.SObjectType sObjectType) {
        if(!sObjectDescribeMap.isEmpty() && sObjectDescribeMap.containsKey(sObjectType.getDescribe().getName())) {
            return sObjectDescribeMap.get(sObjectType.getDescribe().getName());
        } else {
            sObjectDescribeMap.put(sObjectType.getDescribe().getName(), sObjectType.getDescribe());
            return sObjectDescribeMap.get(sObjectType.getDescribe().getName());
        }
    }

    private static void addErrorToRecord (SObject record, Schema.sObjectField field, String errorMsg) {
        String fieldName = field.getDescribe().getLabel() + '(' + field.getDescribe().getName() + ')';
        System.debug (LoggingLevel.INFO, record.get('Name') + ' / ' + fieldName + ' : '+ errorMsg);
        if (Trigger.isExecuting) {
            record.addError(fieldName + ' : ' + errorMsg);
        }
    }

    public static Boolean isPubAdminMode() {
        if(isPubAdminMode != null) {
            return isPubAdminMode;
        } else {
            if(CORE_Pub_Admin_Mode__c.getValues(Userinfo.getUserId()) != null || CORE_Pub_Admin_Mode__c.getValues(Userinfo.getProfileId()) != null) {
                isPubAdminMode = true;
            } else {
                Integer cpamSize = [SELECT count() FROM CORE_Pub_Admin_Mode__c];
                if(cpamSize != 0) {
                    isPubAdminMode = false;
                } else {
                    isPubAdminMode = true;
                }
            }
            return isPubAdminMode;
        }  
    }

    public abstract class BaseRecord {
        abstract Boolean isValid();
    }

    public class CodeRecord extends BaseRecord  {
        public String code { get; set; }
        
        public override Boolean isValid() {
            return String.isNotBlank(code);
        }
    }

    public class ValueRecord extends BaseRecord  {
        public String value { get; set; }
        
        public override Boolean isValid() {
            return String.isNotBlank(value);
        }
    }

    public class CodeAndValueRecord extends BaseRecord {
        public String code { get; set; }
        public String value { get; set; }

        public override Boolean isValid() {
            return String.isNotBlank(code) && String.isNotBlank(value);
        }
    }

    public class CodeAndValueAndExtensionRecord extends BaseRecord {
        public String code { get; set; }
        public String value { get; set; }
        public String extension { get; set; }

        public override Boolean isValid() {
            return (String.isNotBlank(code) && String.isNotBlank(value) && String.isNotBlank(extension)) || (String.isNotBlank(code) && String.isNotBlank(value));
        }
    }

}