public class SCM_MF_RefferalReason extends SCM_MergeField {
    public SCM_MF_RefferalReason(Case selectedCase) {
        key = 'Referral Reason';     
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
        className = 'SCM_MF_PatientId';
        if (selectedCase.case_referral_reason_gne__c != null)
            fieldValue = selectedCase.case_referral_reason_gne__c;
        else
            fieldValue = '';
    }

    public override String getFieldValue() {
        return fieldValue;
    }
}