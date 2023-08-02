// Added By: Deepak Yadav
// Merge field for Patient contact First and Last name
public class SCM_MF_PatContFirstAndLastName extends SCM_MF_PatientContactCollection{
    public SCM_MF_PatContFirstAndLastName(String patientId) {
        super(patientId);
         
        key = 'Patient contact First and Last name' ;  
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        className = 'SCM_MF_PatContFirstAndLastName';
    }
    
    public override String getFieldValue() { 
        if(patientContact !=null){
            return patientContact.First_Name_gne__c + ' ' + patientContact.LAST_NAME_CONT_gne__c;
        }
        else {
            return '';
        }
    }

}