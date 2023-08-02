// Recreated by : Reji Joseph
public class SCM_MF_PatientCity extends SCM_MF_PatientAddressCollection{
  public SCM_MF_PatientCity(String patientId) 
  { 
    super(patientId);
    setKey('Patient City');
  }
  
  public override String getFieldValue()
  { 
    
    if(patientAddress != null && patientAddress.City_gne__c != null)
        return patientAddress.City_gne__c;
    else
        return '';
  }

}