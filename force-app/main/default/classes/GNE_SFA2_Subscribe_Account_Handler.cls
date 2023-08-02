public without sharing class GNE_SFA2_Subscribe_Account_Handler extends CORE_Subscribe_Base implements CORE_Subscribe_Interface.Record_Handler {

    public static final String PATIENT_AMBASSADOR_MDM = 'PATIENTAMB';

    public GNE_SFA2_Subscribe_Account_Handler() {
    }

    public void handle(SObject sourceObject, SObject targetObject) {
        CORE_Pub_Party__c party = (CORE_Pub_Party__c) sourceObject;

        if (!String.isEmpty(party.Comm_Channel_json_gne__c)) {
            processCommunicationChannel(party.Comm_Channel_json_gne__c, targetObject, 'account.');
        }
    }

    public class FieldHandler implements CORE_Subscribe_Interface.Field_Handler {
        public Object handle(SObject sourceObject, SObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc) {
            Object fieldValue = null;
            String fieldName = fc.Target_Field_gne__c;
            CORE_Pub_Party__c party = (CORE_Pub_Party__c) sourceObject;
            Account acc = (Account) targetObject;

            if (fieldName == String.valueOf(Account.RecordTypeId)) {
                fieldValue = getAccountTypeWrapper(party, acc).getRecordTypeId();
                fieldValue = fieldValue != null ? fieldValue : acc.RecordTypeId;
            } else if (fieldName == String.valueOf(Account.Account_Type_gne__c)) {
                fieldValue = getAccountTypeWrapper(party, acc).getAccountType();
                fieldValue = fieldValue != null ? fieldValue : acc.Account_Type_gne__c;
            } else if (fieldName == String.valueOf(Account.Stewardship_System_Name_gne__c)) {
                fieldValue = getAccountTypeWrapper(party, acc).getSSN();
                fieldValue = fieldValue != null ? fieldValue : acc.Stewardship_System_Name_gne__c;
            } else if (fieldName == String.valueOf(Account.Professional_Type_gne__c)) {
                fieldValue = getProfessionalType(party, acc);
            } else if (fieldName == String.valueOf(Account.MDMID_Status_gne__c)) {
                fieldValue = getMdmStatus(party, acc);
            } else if (fieldName == String.valueOf(Account.Credentials_gne__c)) {
                fieldValue = getCredentials(party, acc, fc);
            } else if (fieldName == String.valueOf(Account.Spend_Rest_gne__c)) {
                fieldValue = getSpendRestriction(party, acc);
            }

            return fieldValue;
        }

        private GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper getAccountTypeWrapper(CORE_Pub_Party__c party, Account account) {
            GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper result = null;

            if (party.Type_gne__c == 'IND') {
                Boolean isPatientAmbassador = false;
                if(String.isNotBlank(party.Prof_Type_json_gne__c)) {
                    List<JsonList> profTypeWrappers = (List<JsonList>) JSON.deserialize(party.Prof_Type_json_gne__c, List<JsonList>.class);
                    for (JsonList profTypeWrapper : profTypeWrappers) {
                        if (profTypeWrapper.code == PATIENT_AMBASSADOR_MDM) {
                            isPatientAmbassador = true;
                        }
                    }
                }
                if (isPatientAmbassador) {
                    result = new GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper(null, GNE_SFA2_Account_Trigger_Helper.REC_TYPE_CP, GNE_SFA2_Account_Trigger_Helper.DEFAULT_HCP_STEWARDSHIP_SYSTEM_NAME);
                } else {
                    result = new GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper(null, GNE_SFA2_Account_Trigger_Helper.REC_TYPE_HCP, GNE_SFA2_Account_Trigger_Helper.DEFAULT_HCP_STEWARDSHIP_SYSTEM_NAME);
                }
            } else {
                JsonCodeValueList orgTypeWrapper = ((List<JsonCodeValueList>) JSON.deserialize(party.Org_Type_json_gne__c, List<JsonCodeValueList>.class))[0];
                Boolean codeValueMode = String.isNotBlank(orgTypeWrapper.value);
                GNE_SFA2_Account_Trigger_Helper.AccountTypeKeyType keyType = codeValueMode ? GNE_SFA2_Account_Trigger_Helper.AccountTypeKeyType.CODE_TYPE : GNE_SFA2_Account_Trigger_Helper.AccountTypeKeyType.CODE;
                String key = codeValueMode ? (orgTypeWrapper.code + '_' + orgTypeWrapper.value).toUpperCase() : (orgTypeWrapper.code != null ? orgTypeWrapper.code.toUpperCase() : null);
                result = GNE_SFA2_Account_Trigger_Helper.getAccountTypesMap(keyType).get(key);

                if (result == null && codeValueMode) {
                    key = orgTypeWrapper.code != null ? orgTypeWrapper.code.toUpperCase() : null;
                    result = GNE_SFA2_Account_Trigger_Helper.getAccountTypesMap(GNE_SFA2_Account_Trigger_Helper.AccountTypeKeyType.CODE).get(key);
                }

                if (result == null) {
                    result = new GNE_SFA2_Account_Trigger_Helper.AccountTypeWrapper(null, null, null);
                }
            }

            return result;
        }

        private String getProfessionalType(CORE_Pub_Party__c party, Account account) {
            String profType = null;

            if (String.isNotEmpty(party.Prof_Type_json_gne__c)) {
                List<JsonList>wrappers = (List<JsonList>) JSON.deserialize(party.Prof_Type_json_gne__c, List<JsonList>.class);
                Double roleRank = null;

                for (JsonList code : wrappers) {
                    CORE_Pub_Indv_Role_To_Prof_Type_Map__c setting = CORE_Pub_Indv_Role_To_Prof_Type_Map__c.getValues(code.code);
                    if (setting != null && (roleRank == null || setting.Role_Rank_gne__c < roleRank)) {
                        roleRank = setting.Role_Rank_gne__c;
                        profType = setting.Professional_Type_gne__c;
                    }
                }
            }
            return profType != null ? profType : CORE_Found_Misc_Config__c.getInstance(CORE_Subscribe_Base.CONFIG_ITEM_NAME_DEFAULT_INDV_ROLE).Configuration_Value_gne__c;
        }

        private String getMdmStatus(CORE_Pub_Party__c party, Account account) {
            return party.Status_gne__c == 'I' ? (account.Id == null ? 'Active' : account.MDMID_Status_gne__c) : party.Status_gne__c == 'A' ? 'Active' : 'Inactive';
        }

        private String getCredentials(CORE_Pub_Party__c party, Account account, CORE_Subscribe_Field_Configuration_gne__c fc) {
            String credentials = null;
            if (String.isNotEmpty(party.Credentials_json_gne__c)) {
                credentials = CORE_Subscribe_Process.getReferenceValue(fc, party);
            } else if (String.isNotEmpty(party.Prof_Type_json_gne__c)) {
                Boolean isPatientAmbassador = false;
                List<JsonList> profTypeWrappers = (List<JsonList>) JSON.deserialize(party.Prof_Type_json_gne__c, List<JsonList>.class);
                for (JsonList profTypeWrapper : profTypeWrappers) {
                    if (profTypeWrapper.code == PATIENT_AMBASSADOR_MDM) {
                        isPatientAmbassador = true;
                    }
                }
                credentials = isPatientAmbassador ? account.Credentials_gne__c : '';
            }
            return credentials != null ? credentials : CORE_Found_Misc_Config__c.getInstance(CORE_Subscribe_Base.CONFIG_ITEM_NAME_DEFAULT_INDV_CREDENTIAL).Configuration_Value_gne__c;
        }

        private String getSpendRestriction(CORE_Pub_Party__c party, Account account) {
            String spendRestriction = '';
            Set<String> alreadyProcessedCodes = new Set<String>();
            if (String.isNotEmpty(party.Spend_Rest_json_gne__c)) {
                List<JsonList> spendRestrictions = (List<JsonList>) JSON.deserialize(party.Spend_Rest_json_gne__c, List<JsonList>.class);

                for (JsonList spendRest : spendRestrictions) {
                    if (!alreadyProcessedCodes.contains(spendRest.code)) {
                        spendRestriction += spendRest.code + ';';
                    }

                    alreadyProcessedCodes.add(spendRest.code);
                }
                spendRestriction = spendRestriction.removeEnd(';');
            }

            return spendRestriction;
        }
    }
}