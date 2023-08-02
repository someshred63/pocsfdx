//Condition is as follows
//Join Case.Patient_gne__c to Patient.PatientID_gne__c and join Patient.PatientID_gne__c to Patient Contact.pat_con_Patient_gne__c to return a list of Patient Contact objects where Patient Contact.pat_con_Contact_Type_gne__c  = Primary
//If count of Patient Contact = 0, then merge ""
//If count of Patient Contact = 1, then merge Patient Contact.pat_con_Relationship_to_Patient_gne__c
//If count of Patient Contact > 1, then merge Patient Contact.pat_con_Relationship_to_Patient_gne__c where last modified

public class SCM_MF_PatientRelationship extends SCM_MergeField 
 {
  
  public SCM_MF_PatientRelationship(String patientIdLocal)
    {
      
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='Relationship';
      className='SCM_MF_PatientRelationship';
      fieldValue = obtainRelationShip(patientIdLocal);
    }
     public string obtainRelationShip(String patientIdLocal)
    {
       String returnString='';
       List<Patient_Contact_gne__c> patientList = [Select p.pat_con_Relationship_to_Patient_gne__c, p.pat_con_Patient_gne__r.Patient_ID_gne__c, 
                                 p.pat_con_Patient_gne__c, p.pat_con_Contact_Type_gne__c From Patient_Contact_gne__c p  where p.pat_con_Contact_Type_gne__c='Primary' and 
                                                  p.pat_con_Patient_gne__r.Patient_ID_gne__c=:patientIdLocal LIMIT 500];
        
        if(patientList.size()==0)
        {
         //do nothing
        }
        else if(patientList.size()==1)
        {
         returnString=patientList[0].pat_con_Relationship_to_Patient_gne__c ;
        }
        else //if there are more that 1 objects
        {
            List<Patient_Contact_gne__c> patientListUpdated = [Select p.pat_con_Relationship_to_Patient_gne__c, p.pat_con_Patient_gne__r.Patient_ID_gne__c, 
                                 p.pat_con_Patient_gne__c, p.pat_con_Contact_Type_gne__c From Patient_Contact_gne__c p  where p.pat_con_Contact_Type_gne__c='Primary' and 
                                                  p.pat_con_Patient_gne__r.Patient_ID_gne__c=:patientIdLocal
                order by p.LastModifiedDate desc LIMIT 500];
            returnString=patientListUpdated[0].pat_con_Relationship_to_Patient_gne__c ;
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