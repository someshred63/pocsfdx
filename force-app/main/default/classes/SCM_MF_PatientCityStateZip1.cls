// Added by Reji Joseph
public class SCM_MF_PatientCityStateZip1 extends SCM_MF_PatientAddessCollectionSMN_Luc {

  public SCM_MF_PatientCityStateZip1(String PatientId)
  {
    super(PatientId);
    
	key = 'PatientCityStateZip';
	className = 'SCM_MF_PatientCityStateZip1';
	checked = false;
	displayCheck = false;
	displayTextBox = false;
	displayLabel = false;
  }
   
  public override String getFieldValue()
  {    
  	string patCityStateZip = '';
    if ( PatientAddress != null)
    {
    	if (PatientAddress.City_gne__c != null)
        	patCityStateZip = PatientAddress.City_gne__c;

    	if (PatientAddress.State_gne__c != null)  
    		patCityStateZip = patCityStateZip + ', ' + PatientAddress.State_gne__c;

    	if (PatientAddress.Zip_gne__c != null)  
    		patCityStateZip = patCityStateZip + ', ' + PatientAddress.Zip_gne__c;
    		
		return patCityStateZip;
    }
    else
        return patCityStateZip;
  }
}