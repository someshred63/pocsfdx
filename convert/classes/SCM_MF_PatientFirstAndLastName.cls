public class SCM_MF_PatientFirstAndLastName extends SCM_MergeField {
    protected Case patientCase;
    
    public SCM_MF_PatientFirstAndLastName(Case selectedCase) {
        patientCase = selectedCase;
        key = 'Patient_First_And_Last_Name';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_PatientFirstAndLastName';
        fieldValue = getFieldValue();
    }
   public SCM_MF_PatientFirstAndLastName(Case selectedCase, string newkey) {
       this(selectedCase);
        key = newkey;
    }
   
   
   
    public override String getFieldValue() {
        String firstName = patientCase.Patient_gne__r.pat_first_name_gne__c;
        String lastName = patientCase.Patient_gne__r.Name;
        
        fieldValue = '';
        if(firstName == null && lastName == null){
        	fieldValue = '';
        }
        else if(firstName == null && lastName != null){
        	fieldValue = lastName;
        }
        else if(firstName != null && lastName == null){
        	fieldValue = firstName;
        }
        else if(firstName != null && lastName != null){
        	fieldValue = firstName + ' ' + lastName;
        }
        return fieldValue;
    }
}