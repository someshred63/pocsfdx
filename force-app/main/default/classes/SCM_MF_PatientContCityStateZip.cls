// Added By: Deepak Yadav
// Merge Field for Patient contact city state zip
public class SCM_MF_PatientContCityStateZip extends 
SCM_MF_PatientContactCollection{
	
	public SCM_MF_PatientContCityStateZip(String patientId) {
		super(patientId);
		
		key = 'Patient Contact City State and Zip';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 		
	}
	
    public override String getFieldValue() {
    	string cityStateZip = '';
    	if(patientContact != null ) {
    		if (patientContact.pat_con_City_gne__c != null)
	    		cityStateZip = patientContact.pat_con_City_gne__c ;			
			if (patientContact.pat_con_Zip_gne__c != null)
	    		cityStateZip = cityStateZip + ' ' + patientContact.pat_con_Zip_gne__c ;
	    		
	    	return cityStateZip;
    	}    
    	else
        	return cityStateZip ;
  	}

}