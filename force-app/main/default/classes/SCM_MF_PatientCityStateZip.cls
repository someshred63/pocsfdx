// Added By: Deepak Yadav
// To Get Patient`s CityStateZip
public class SCM_MF_PatientCityStateZip extends SCM_MF_PatientAddressCollection{
    public SCM_MF_PatientCityStateZip(String patientId){
        super(patientId);
              
        Key = 'Patient City State and Zip';            
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;  
        fieldValue=  getFieldValue();

    }
    
    public override String getFieldValue() {
        string cityStateZip = '';
        if(patientAddress != null ) {
            if (patientAddress.City_gne__c != null)
                cityStateZip = patientAddress.City_gne__c ;
            if (patientAddress.State_gne__c != null)
                cityStateZip = cityStateZip + ', ' + patientAddress.State_gne__c ;
            if (patientAddress.Zip_gne__c != null)
                cityStateZip = cityStateZip + ', ' + patientAddress.Zip_gne__c ;
            return cityStateZip;
        }    
        else
            return cityStateZip ;
    }
}