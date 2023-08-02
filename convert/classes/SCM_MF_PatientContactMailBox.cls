// Added By: Deepak Yadav
// MergeField for Patient contact MailBox
public class SCM_MF_PatientContactMailBox extends
SCM_MF_PatientContactCollection {
	
	public SCM_MF_PatientContactMailBox(String patientId) {
		super(patientId);
		
		Key = 'Patient Contact MailBox';    	       
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
	}
	
	public override String getFieldValue(){
		if(patientContact != null && patientContact.pat_con_Mail_Box_gne__c != null) {			
        	return patientContact.pat_con_Mail_Box_gne__c;
		}
    	else {
   			return '';
    	}
  	}
}