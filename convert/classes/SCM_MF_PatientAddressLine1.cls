// Recreated By Reji Joseph
public class SCM_MF_PatientAddressLine1 extends SCM_MF_PatientAddressCollection{
  public SCM_MF_PatientAddressLine1(String patientId) 
  {
    super(patientId);
    
    key = 'Patient AddressLine1';
  }
  
  public override String getFieldValue()
  {     
    if(patientAddress != null && patientAddress.Address_Line_1_gne__c != null)
        return patientAddress.Address_Line_1_gne__c;
    else
        return '';
  }

}