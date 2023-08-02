// Added by Reji Joseph
public class SCM_MF_PatientAddress extends SCM_MF_PatientAddessCollectionSMN_Luc {

  public SCM_MF_PatientAddress(String PatientId)
  {
    super(PatientId);
    Key = 'PatientAddress';             
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false; 
    className='SCM_MF_PatientAddress';   
    fieldValue=getFieldValue();

  }
   
  public override String getFieldValue()
  {    
    string patAddress = '';
    if ( PatientAddress != null )
    {
        
        if (PatientAddress.Address_Line_1_gne__c != null && PatientAddress.Address_Line_1_gne__c != '')  
            patAddress = PatientAddress.Address_Line_1_gne__c;
            
        if (PatientAddress.Address_Line_2_gne__c != null && PatientAddress.Address_Line_2_gne__c != '')
            patAddress = patAddress + ', ' + PatientAddress.Address_Line_2_gne__c;
            
        return patAddress;
    }
    else
        return patAddress;
  }
}