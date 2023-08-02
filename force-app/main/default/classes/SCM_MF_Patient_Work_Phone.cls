//Condition is as follows
//Join Case.Patient_gnec to Patient.PatientID_gnec and merge Patient.pat_home_phone_gnec. 
public class SCM_MF_Patient_Work_Phone extends SCM_MergeField 
{
  public SCM_MF_Patient_Work_Phone(String patientIdLocal)
    {
      
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='PatientWorkPhone';
      className='SCM_MF_Patient_Work_Phone';
      fieldValue = obtainWorkPhone(patientIdLocal);
    }
    
    public  string obtainWorkPhone(String patientIdLocal)
    {
       String returnString='';
       List<Case> patientList = [Select c.Patient_gne__r.Patient_ID_gne__c, c.Patient_gne__r.pat_home_phone_gne__c, 
       									  c.Patient_gne__r.pat_work_phone_gne__c, c.Patient_gne__c From Case c where
										  c.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal
         								  order by c.LastModifiedDate desc LIMIT 500];
        
        if(patientList.size()==0)
        {
         //do nothing
        
        }
        else
        {
         returnString=patientList[0].Patient_gne__r.pat_work_phone_gne__c;
        }
        
        if(returnString==null)
       {
        returnString='';
       }
        
       return returnString;
    }
    
     public override String getFieldvalue()
   {
    return fieldValue;
   }
}