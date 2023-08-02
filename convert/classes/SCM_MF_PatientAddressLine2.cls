// Recreated by Reji Joseph

public class SCM_MF_PatientAddressLine2 extends SCM_MF_PatientAddressCollection{
  public SCM_MF_PatientAddressLine2(String patientId) 
  {
    super(patientId);
    setKey('PatientAddressLine2');
  }
  
  public override String getFieldValue()
  { 
    
    if(patientAddress != null && patientAddress.Address_Line_2_gne__c != null)
        return patientAddress.Address_Line_2_gne__c;
    else
        return '';
  }

}