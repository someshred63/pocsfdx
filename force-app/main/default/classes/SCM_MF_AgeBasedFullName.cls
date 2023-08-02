//created by:Vinod
//condition is a s  follows
//Join Case.Patient_gne__c to Patient.PatientID_gne__c  and select Patient.Pat_DOB_gne__c
//If number of months between current system date and Patient.pat_dob_gne__c for patient associated with the selected case is greater than 216 then,
//Join Case.Patient_gne__c to Patient.PatientID_gne__c  and select Patient.FirstName || Patient.LastName
//Else
//Join Case.Patient_gne__c to Patient.PatientID_gne__c and join Patient.PatientID_gne__c to Patient Contact.pat_con_Patient_gne__c to return a list of Patient Contact objects
//If count of Patient Contact = 0, then merge then merge Patient.FirstName || Patient.LastName
//If count of Patient Contact = 1, then merge Patient Contact.First_Name_gne__c || Patient Contact.Last_Name_gne__c
//If count of Patient Contact > 1, then return a list of Patient Contact objects where Patient Contact.pat_con_Contact_Type_gne__c  = Primary
   //If count of Patient Contact = 0, then
      //If Patient Contact.pat_con_Relationship_to_Patient_gne__c = Parent OR Legal Guardian, then merge Patient Contact.First_Name_gne__c || Patient Contact.Last_Name_gne__c
      //If Both, use where = Parent is last modifed
      //If neither, merge Patient.FirstName || Patient.LastName
   //If count of Patient Contact = 1, then merge Patient Contact.First_Name_gne__c || Patient Contact.Last_Name_gne__c
   //If count of Patient Contact > 1, then 
      //If Patient Contact.pat_con_Relationship_to_Patient_gne__c = Parent OR Legal Guardian, then merge Patient Contact.First_Name_gne__c || Patient Contact.Last_Name_gne__c
      //If Both, use where = Parent is last modifed
   //Else use last modified Patient Contact.First_Name_gne__c || Patient Contact.Last_Name_gne__c where Patient Contact.pat_con_Contact_Type_gne__c  = Primary

public class SCM_MF_AgeBasedFullName extends SCM_MergeField
{
  
  public  SCM_MF_AgeBasedFullName(String patientIdLocal)
  {
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='Age';
      className='SCM_MF_AgeBasedFullName';
      fieldValue = obtainAgeBasedFullName(patientIdLocal); 
  } 
  
  public String obtainAgeBasedFullName(String patientIdLocal)
  {
     String Relation ,returnString='';
     Date dob;
     integer monthDiff;
     List<Patient_gne__c> patientList;
     try{   
          patientList = [Select p.pat_first_name_gne__c,p.Name,p.pat_dob_gne__c, p.Patient_ID_gne__c From Patient_gne__c p 
                                       where p.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 1];
         if(patientList.size()>0 && patientList[0].pat_dob_gne__c!=null)
         dob= patientList[0].pat_dob_gne__c; 
         else
         dob=Date.today();
         monthDiff = dob.monthsBetween(Date.today());
         
         if(monthDiff>216)
         {
          returnString=(patientList[0].pat_first_name_gne__c==null)? '':patientList[0].pat_first_name_gne__c;
          returnString+=(patientList[0].Name==null)? '':' ' + patientList[0].Name;
           
         }  
         else
         {
        
          List<Patient_Contact_gne__c> patientLisWithcontact=[Select p.First_Name_gne__c,p.LAST_NAME_CONT_gne__c,
                                                p.pat_con_Patient_gne__r.pat_first_name_gne__c,p.pat_con_Patient_gne__r.Name,
                                    p.pat_con_Patient_gne__r.Patient_ID_gne__c, p.pat_con_Patient_gne__c From Patient_Contact_gne__c p
                            where p.pat_con_Patient_gne__r.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 100];
     
     
         if(patientLisWithcontact.Size()==0)
         {
            if (patientList.size() != 0) {
           returnString=(patientList[0].pat_first_name_gne__c==null)? '':patientList[0].pat_first_name_gne__c;
              returnString+=(patientList[0].Name==null)? '':' ' + patientList[0].Name;
         }}
         else if(patientLisWithcontact.Size()==1)
         {
            system.debug('right here');
          returnString=(patientLisWithcontact[0].First_Name_gne__c==null)? '':patientLisWithcontact[0].First_Name_gne__c;
          returnString+=(patientLisWithcontact[0].LAST_NAME_CONT_gne__c==null)? '':' ' + patientLisWithcontact[0].LAST_NAME_CONT_gne__c;
         }
         else if(patientLisWithcontact.Size() >1)
         {
          List<Patient_Contact_gne__c> patientLisWithPrimaryYes=[Select p.pat_con_Relationship_to_Patient_gne__c, 
                              p.pat_con_Patient_gne__r.Patient_ID_gne__c, p.pat_con_Patient_gne__r.pat_first_name_gne__c, 
                              p.pat_con_Patient_gne__r.Name, p.pat_con_Patient_gne__c, p.pat_con_Contact_Type_gne__c, 
                              p.LAST_NAME_CONT_gne__c, p.First_Name_gne__c From Patient_Contact_gne__c p
                              where p.pat_con_Patient_gne__r.Patient_ID_gne__c=:patientIdLocal 
                              and p.pat_con_Contact_Type_gne__c='Primary'
                              order by p.LastModifiedDate desc LIMIT 100];
                              
                if(patientLisWithPrimaryYes.Size()==1)
                {
                 returnString=(patientLisWithPrimaryYes[0].First_Name_gne__c==null)? '':patientLisWithPrimaryYes[0].First_Name_gne__c;
                 returnString+=(patientLisWithPrimaryYes[0].LAST_NAME_CONT_gne__c==null)? '':' ' + patientLisWithPrimaryYes[0].LAST_NAME_CONT_gne__c;
                
                } 
                else if(patientLisWithPrimaryYes.Size()==0 || patientLisWithPrimaryYes.Size()>1)
                {
                  if(patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c!=null && patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c!='')
                  {
                       Relation=patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c;
                       if(Relation=='Legal Guardian' || Relation=='Parent')
                       {
                        returnString=(patientLisWithPrimaryYes[0].First_Name_gne__c==null)? '':patientLisWithPrimaryYes[0].First_Name_gne__c;
                        returnString+=(patientLisWithPrimaryYes[0].LAST_NAME_CONT_gne__c==null)? '':' ' + patientLisWithPrimaryYes[0].LAST_NAME_CONT_gne__c;
                
                       }
                       else
                       {
                        returnString=(patientLisWithPrimaryYes[0].pat_con_Patient_gne__r.pat_first_name_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Patient_gne__r.pat_first_name_gne__c;
                        returnString+=(patientLisWithPrimaryYes[0].pat_con_Patient_gne__r.Name==null)? '':' ' + patientLisWithPrimaryYes[0].pat_con_Patient_gne__r.Name;
                       }
                  }
                }
                
         }
     
         }
         }catch(Exception e){
              returnString = '';
         }
      return returnString;                                      
  }
   
    public override String getFieldvalue()
   {
    return fieldValue;
   }    
}