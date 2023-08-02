public with sharing class AGS_ST_SourceTransactionExtension {

    public List<AGS_FormRawWrapper> getPrimaryRecipientFormData() {
        return getFormData('PTY1', 'PTY1');
    }


    public List<AGS_FormRawWrapper> getRelatedRecipientFormData() {
        return getFormData('PTY2', 'PTY2');
    }

    private List<AGS_FormRawWrapper> getFormData(String fieldPrefix1, String fieldPrefix2) {
        List<AGS_FormRawWrapper> result = new List<AGS_FormRawWrapper>();
        for (Integer i = 0; i < SRC_FLDS.size(); i++) {
            String reportFieldName = '';
            String reportFieldLabel = '';
            String reportValue = '';
            String srcFieldName = '';
            String srcFieldLabel = '';
            String srcValue = '';
            if (REPORT_FLDS[i] != null) {
                reportFieldName = (fieldPrefix1 + '_' + REPORT_FLDS[i]).toLowerCase().trim();
                if (!AGS_Spend_Expense_Transaction_gne__c.getSObjectType().getDescribe().fields.getMap().keySet().contains(reportFieldName)) {
                    reportFieldName = (fieldPrefix2 + '_' + REPORT_FLDS[i]).toLowerCase().trim();
                }
                reportValue = String.valueOf(sourceTxn.AGS_Spend_Expense_Transaction__r.get(reportFieldName));
                reportFieldLabel = REPORT_LABELS[i];
            }
            if (SRC_FLDS[i] != null) {
                srcFieldName = fieldPrefix2 + '_' + SRC_FLDS[i];
                srcValue = String.valueOf(sourceTxn.get(srcFieldName));
                srcFieldLabel = SRC_LABELS[i];
            }
            Boolean isComparable = COMPARE[i];
            result.add(new AGS_FormRawWrapper(reportFieldLabel, reportValue, srcFieldLabel, srcValue, isComparable));
        }
        return result;
    }

    public Boolean isPrimaryRecipientBlank {
        get {
            return sourceTxn == null || !isRecipientNotBlank('pty1');
        }
    }

    public Boolean isRelatedRecipientBlank {
        get {
            return sourceTxn == null || !isRecipientNotBlank('pty2');
        }
    }

    private Boolean isRecipientNotBlank(final String fldPrefix) {
        String[] fields = sourceTxn == null ? new String[]{
        } : SRC_FLDS;
        for (String fldName : fields) {
            if (fldName != null && fldName != 'credential_gne__c' && String.isNotBlank(String.valueOf(sourceTxn.get(fldPrefix + '_' + fldName)))) {
                return true;
            }
        }
        return false;
    }

    public static final String[] SRC_FLDS = new String[]{
            'src_atnd_key_gne__c',
            'type_gne__c',
            'npi_gne__c',
            'tin_gne__c',
            'name_gne__c',
            'address_gne__c',
            'city_gne__c',
            'state_gne__c',
            'zip_gne__c',
            'country_gne__c',
            'lic_num_gne__c',
            'credential_gne__c',
            'profession_gne__c',
            'speciality_gne__c',
            null,
            null,
            null
    };

    public static final String[] REPORT_FLDS = new String[]{
            'name_gne__c',
            'type_gne__c',
            'npi_gne__c',
            'tin_gne__c',
            'name_gne__c',
            'address_gne__c',
            'city_gne__c',
            'state_gne__c',
            'zip_gne__c',
            'country_gne__c',
            'lic_num_gne__c',
            'Designation_gne__c',
            null,
            'speciality_gne__c',
            'specialty_code_gne__c',
            'specialty_type_gne__c',
            'specialty_classification_gne__c'
    };


    public static final String[] REPORT_LABELS = new String[]{
            'MDM ID',
            'Recipient Type',
            'NPI',
            'TIN',
            'Name',
            'Address',
            'City',
            'State/Province',
            'ZIP Code/Postal Code',
            'Country',
            'State License(s)',
            'Professional Designation',
            null,
            'Specialization',
            'Specialty Code',
            'Specialty Type',
            'Specialty Classification'
    };

    public static final String[] SRC_LABELS = new String[]{
            'Source Party Key',
            'Recipient Type',
            'NPI',
            'TIN',
            'Name',
            'Address',
            'City',
            'State/Province',
            'ZIP Code/Postal Code',
            'Country',
            'State License(s)',
            'Credential',
            'Profession',
            'Specialty',
            null,
            null,
            null
    };

    public static final Boolean[] COMPARE = new Boolean[]{
            false,
            false,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false
    };

    public final AGS_Source_Transaction__c sourceTxn {
        get;
        private set;
    }

    @TestVisible
    private Id srcTxnId;

    public AGS_ST_SourceTransactionExtension(final ApexPages.StandardController stdCtrl) {
        sourceTxn = [
                SELECT Id, PTY1_Profession_gne__c, PTY1_Name_gne__c, PTY1_ADDRESS_gne__c, PTY1_NPI_gne__c, PTY1_CITY_gne__c, PTY1_TIN_gne__c, PTY1_STATE_gne__c, PTY1_SRC_ATND_KEY_gne__c,
                        PTY1_COUNTRY_gne__c, PTY1_TYPE_gne__c, PTY1_ZIP_gne__c, PTY1_SPECIALITY_gne__c, PTY1_LIC_NUM_gne__c, PTY1_Credential_gne__c, PTY1_LIC_ST_CD_gne__c,
                        AGS_Spend_Expense_Transaction__r.Primary_Recipient_gne__r.Name, AGS_Spend_Expense_Transaction__r.Primary_Recipient_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_TYPE_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY1_NPI_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_TIN_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_Name_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY1_ADDRESS_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_CITY_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_State_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY1_ZIP_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_LIC_NUM_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_SPECIALITY_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY1_SPECIALTY_Code_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_SPECIALTY_Type_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY1_SPECIALTY_Classification_gne__c, AGS_Spend_Expense_Transaction__r.PTY1_Designation_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY1_Country_gne__c,

                        PTY2_Profession_gne__c, PTY2_Name_gne__c, PTY2_ADDRESS_gne__c, PTY2_NPI_gne__c, PTY2_CITY_gne__c, PTY2_TIN_gne__c, PTY2_STATE_gne__c, PTY2_SRC_ATND_KEY_gne__c,
                        PTY2_COUNTRY_gne__c, PTY2_TYPE_gne__c, PTY2_ZIP_gne__c, PTY2_SPECIALITY_gne__c, PTY2_LIC_NUM_gne__c, PTY2_Credential_gne__c, PTY2_LIC_ST_CD_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY2_TYPE_gne__c, AGS_Spend_Expense_Transaction__r.PTY2_NPI_gne__c, AGS_Spend_Expense_Transaction__r.PTY2_TIN_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY2_Name_gne__c, AGS_Spend_Expense_Transaction__r.PTY2_ADDRESS_gne__c, AGS_Spend_Expense_Transaction__r.PTY2_City_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY2_State_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY2_ZIP_gne__c, AGS_Spend_Expense_Transaction__r.PTY2_LIC_NUM_gne__c, AGS_Spend_Expense_Transaction__r.PTY2_Speciality_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY2_SPECIALTY_Code_gne__c, AGS_Spend_Expense_Transaction__r.PTY2_SPECIALTY_Type_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY2_SPECIALTY_Classification_gne__c, AGS_Spend_Expense_Transaction__r.PTY2_Designation_gne__c,
                        AGS_Spend_Expense_Transaction__r.PTY2_Country_gne__c
                FROM AGS_Source_Transaction__c
                WHERE AGS_Spend_Expense_Transaction__c = :stdCtrl.getId() ORDER BY CreatedDate LIMIT 1
        ];
        srcTxnId = sourceTxn.Id;
    }
}