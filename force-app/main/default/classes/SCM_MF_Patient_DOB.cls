//condition is as  follows
//Join Case.Patient_gne__c to Patient.PatientID_gne__c  and select Patient.Pat_DOB_gne__c
public class SCM_MF_Patient_DOB extends SCM_MergeField
{
  public SCM_MF_Patient_DOB(String patientIdLocal)
   {
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='DOB';
      className='SCM_MF_Patient_DOB';
      fieldValue = obtainPatientDOB(patientIdLocal);
   
   }
   
   public String obtainPatientDOB(String patientIdLocal)
   {
       String returnString='';
       List<Case> patientList = [Select c.Patient_gne__r.Patient_ID_gne__c, c.Patient_gne__r.pat_dob_gne__c, 
       c.Patient_gne__c, c.LastModifiedDate From Case c
        where c.Patient_gne__r.Patient_ID_gne__c= :patientIdLocal order by c.LastModifiedDate desc LIMIT 1];
                                       
         if(patientList.size()==0)
        {
         //do nothing
        }
        else
        {
         if(patientList[0].Patient_gne__r.pat_dob_gne__c != null)
         	returnString=patientList[0].Patient_gne__r.pat_dob_gne__c.format();
        }
        
        if(returnString==null)
        {
         returnString=''; 
        }
        return returnString;
   }
}