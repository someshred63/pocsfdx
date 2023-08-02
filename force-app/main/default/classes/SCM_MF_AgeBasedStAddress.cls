//Condition is as  follows
//Join Case.Patient_gne__c to Patient.PatientID_gne__c  and select Patient.Pat_DOB_gne__c
//If number of months between current system date and Patient.pat_dob_gne__c for patient associated with the selected case is greater than 216 then,
//Join Case.Patient_gne__c to Patient.PatientID_gne__c and join Patient.PatientID_gne__c to Patient Address.Patient_gne__c to return a list of Patient Address objects.
//If count of Patient Address = 0, then merge ""
//If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
//If count of Patient Address > 1, then return a list of Patient Address objects where Patient Address.Primary_address_gne__c = Yes
   //If count of Patient Address = 0, then select the last updated Patient Address
   //If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
   //If count of Patient Address > 1, the return a list of Patient.Address_type_gne__c where Patient Address.Address_Type_gne__c = Mailing address
      //If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
      //If count of Patient Address > 1, then select Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c where Patient Address.ModifiedDate is most current
      //If count of Patient Address = 0, then return a list of Patient.Address_type_gne__c where Patient Address.Address_Type_gne__c = Home Address
         //If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c
         //If count of Patient Address > 1, then Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c where Patient Address.ModifiedDate is most current
         //If count of Patient Address = 0, then select Patient Address.Address_Line_2_gne__c || Patient Address.Address_Line_1_gne__c where Patient Address.ModifiedDate is most current
//Else
//Use logic for AgeBasedFullName to merge Patient Contact.pat_con_Mail_Box_gne__c || Patient Contact.pat_con_Street_gne__c
 
public class SCM_MF_AgeBasedStAddress extends SCM_MergeField 
{
     public  SCM_MF_AgeBasedStAddress(String patientIdLocal)
     {
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='Addr';
      className='SCM_MF_AgeBasedStAddress';
      fieldValue = obtainAgeBasedStAddress(patientIdLocal); 
     }
    
    public String obtainAgeBasedStAddress(String patientIdLocal)
    {
     String Relation ,returnString='';
     Date dob;
     integer monthDiff;
     try{
         List<Patient_gne__c> patientList=[Select p.pat_dob_gne__c, p.Patient_ID_gne__c From Patient_gne__c p 
                                           where p.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 1];
         
         if(patientList.size()>0 && patientList[0].pat_dob_gne__c!=null)
         dob= patientList[0].pat_dob_gne__c; 
         else
         dob=Date.today();
         monthDiff = dob.monthsBetween(Date.today());
         
         if(monthDiff>216)
         {
               List<Patient_Address_gne__c> patAddList= [Select p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, p.Address_Line_2_gne__c, p.Address_Line_1_gne__c
               From Patient_Address_gne__c p where p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 100];
               
               if(patAddList.Size()==0)
               {
                //do nothing
               }
               else if(patAddList.Size()==1)
               {
                returnString=(patAddList[0].Address_Line_1_gne__c==null)? '':patAddList[0].Address_Line_1_gne__c;
                returnString+=(patAddList[0].Address_Line_2_gne__c==null)? '':patAddList[0].Address_Line_2_gne__c;
               
               }
               else if (patAddList.Size()>1)
               {
                List<Patient_Address_gne__c> patAddPryYesList=[Select p.Primary_Address_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Primary_Address_gne__c='Yes'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 100];
                    
                    if(patAddPryYesList.Size()==0)
                    {
                      returnString=(patAddList[0].Address_Line_1_gne__c==null)? '':patAddList[0].Address_Line_1_gne__c;
                      returnString+=(patAddList[0].Address_Line_2_gne__c==null)? '':patAddList[0].Address_Line_2_gne__c;
                    }
                    else if (patAddPryYesList.Size()==1)
                    {
                      returnString=(patAddPryYesList[0].Address_Line_1_gne__c==null)? '':patAddPryYesList[0].Address_Line_1_gne__c;
                      returnString+=(patAddPryYesList[0].Address_Line_2_gne__c==null)? '':patAddPryYesList[0].Address_Line_2_gne__c;
                    }
                    else if(patAddPryYesList.Size()> 1)
                    {
                      List<Patient_Address_gne__c> patAddMailList=[Select p.Type_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Type_gne__c='Mailing'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal  LIMIT 100]; 
                                        
                                        
                             if(patAddMailList.Size()>=1)
                             {
                               returnString=(patAddMailList[0].Address_Line_1_gne__c==null)? '':patAddMailList[0].Address_Line_1_gne__c;
                               returnString+=(patAddMailList[0].Address_Line_2_gne__c==null)? '':patAddMailList[0].Address_Line_2_gne__c;
                             }
                             else if(patAddMailList.Size()>1)
                             {
                               List<Patient_Address_gne__c> patAddMailListUpdated=[Select p.Type_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Type_gne__c='Mailing'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal  LIMIT 100]; 
                                        
                                     if(patAddMailListUpdated.Size()>=1)
                                     {
                                       returnString=(patAddMailListUpdated[0].Address_Line_1_gne__c==null)? '':patAddMailListUpdated[0].Address_Line_1_gne__c;
                                       returnString+=(patAddMailListUpdated[0].Address_Line_2_gne__c==null)? '':patAddMailListUpdated[0].Address_Line_2_gne__c;
                                     }  
                             
                             }
                             else if(patAddMailList.Size()==0)
                             {
                                List<Patient_Address_gne__c> patAddHomeList=[Select p.Type_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Type_gne__c='Home'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal  LIMIT 100]; 
                                    if(patAddHomeList.Size()==1)    
                                    {
                                      returnString=(patAddHomeList[0].Address_Line_1_gne__c==null)? '':patAddHomeList[0].Address_Line_1_gne__c;
                                      returnString+=(patAddHomeList[0].Address_Line_2_gne__c==null)? '':patAddHomeList[0].Address_Line_2_gne__c;
                                    }
                                    else if(patAddHomeList.Size()>0)
                                    {
                                       List<Patient_Address_gne__c> patAddHomeListUpdated=[Select p.Type_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Type_gne__c='Home'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal  LIMIT 1]; 
                                        
                                            if(patAddHomeListUpdated.Size()==1) 
                                            {
                                              returnString=(patAddHomeListUpdated[0].Address_Line_1_gne__c==null)? '':patAddHomeListUpdated[0].Address_Line_1_gne__c;
                                              returnString+=(patAddHomeListUpdated[0].Address_Line_2_gne__c==null)? '':patAddHomeListUpdated[0].Address_Line_2_gne__c;
                                            }
                                    }   
                                        
                             
                             }
                     
                    
                    }
               
               }
         }
         else
         {
                List<Patient_Contact_gne__c> patientLisWithcontact=[Select p.pat_con_Street_gne__c,p.pat_con_Mail_Box_gne__c,
                                                        p.pat_con_Patient_gne__r.pat_first_name_gne__c,p.pat_con_Patient_gne__r.Name,
                                            p.pat_con_Patient_gne__r.Patient_ID_gne__c, p.pat_con_Patient_gne__c From Patient_Contact_gne__c p
                                    where p.pat_con_Patient_gne__r.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 100];
             
             
                 if(patientLisWithcontact.Size()==0)
                 {
                  
                 }
                 else if(patientLisWithcontact.Size()==1)
                 {
                  returnString=(patientLisWithcontact[0].pat_con_Street_gne__c==null)? '':patientLisWithcontact[0].pat_con_Street_gne__c;
                  returnString+=(patientLisWithcontact[0].pat_con_Mail_Box_gne__c==null)? '':patientLisWithcontact[0].pat_con_Mail_Box_gne__c;
                 }
                 else if(patientLisWithcontact.Size() >1)
                 {
                  List<Patient_Contact_gne__c> patientLisWithPrimaryYes=[Select p.pat_con_Street_gne__c,p.pat_con_Mail_Box_gne__c,
                                                            p.pat_con_Relationship_to_Patient_gne__c, 
                                      p.pat_con_Patient_gne__r.Patient_ID_gne__c, p.pat_con_Patient_gne__r.pat_first_name_gne__c, 
                                      p.pat_con_Patient_gne__r.Name, p.pat_con_Patient_gne__c, p.pat_con_Contact_Type_gne__c, 
                                      p.LAST_NAME_CONT_gne__c, p.First_Name_gne__c From Patient_Contact_gne__c p
                                      where p.pat_con_Patient_gne__r.Patient_ID_gne__c=:patientIdLocal 
                                      and p.pat_con_Contact_Type_gne__c='Primary'
                                      order by p.LastModifiedDate desc LIMIT 100];
                                      
                        if(patientLisWithPrimaryYes.Size()==1)
                        {
                         returnString=(patientLisWithPrimaryYes[0].pat_con_Street_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Street_gne__c;
                         returnString+=(patientLisWithPrimaryYes[0].pat_con_Mail_Box_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Mail_Box_gne__c;
                        
                        } 
                        else if(patientLisWithPrimaryYes.Size()>1)
                        {
                          if(patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c!=null && patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c!='')
                          {
                               Relation=patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c;
                               if(Relation=='Legal Guardian' || Relation=='Parent')
                               {
                                returnString=(patientLisWithPrimaryYes[0].pat_con_Street_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Street_gne__c;
                                returnString+=(patientLisWithPrimaryYes[0].pat_con_Mail_Box_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Mail_Box_gne__c;
                        
                               }
                               else
                               {
                                returnString=(patientLisWithPrimaryYes[0].pat_con_Street_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Street_gne__c;
                                returnString+=(patientLisWithPrimaryYes[0].pat_con_Mail_Box_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Mail_Box_gne__c;
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