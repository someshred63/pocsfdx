public class SCM_MF_PatientId extends SCM_MergeField {
    public SCM_MF_PatientId(Case selectedCase) {
        key = 'Patient Id';     
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        isRequired = false;
        className = 'SCM_MF_PatientId';
        if (selectedCase.Patient_gne__r.Patient_ID_gne__c != null)
            fieldValue = selectedCase.Patient_gne__r.Patient_ID_gne__c;
        else
            fieldValue = '';
    }

    public override String getFieldValue() {
        return fieldValue;
    }
}