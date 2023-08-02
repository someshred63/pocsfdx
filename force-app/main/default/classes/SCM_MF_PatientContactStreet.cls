// Added By: Deepak Yadav
// MergeField for Patient contact Stree
public class SCM_MF_PatientContactStreet extends 
SCM_MF_PatientContactCollection {
	
	public SCM_MF_PatientContactStreet(String patientId) {
		super(patientId);
		
		Key = 'Patient Contact Street';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
	}
	
	public override String getFieldValue(){
		if(patientContact != null && patientContact.pat_con_Street_gne__c != null) {			
        	return patientContact.pat_con_Street_gne__c;
		}
    	else {
   			return '';
    	}
  	}
 
}