public class SCM_MF_AgeBasedCityStZip extends SCM_MergeField{
 public SCM_MF_AgeBasedCityStZip(String patientIdLocal)
     {
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='CityStateZip';
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
         List<Patient_Address_gne__c> patAddList;
         if(monthDiff>216)
         {
               patAddList= [Select p.Zip_gne__c, p.State_gne__c, p.City_gne__c,p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, p.Address_Line_2_gne__c, p.Address_Line_1_gne__c
               From Patient_Address_gne__c p where p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 100];
               
               if(patAddList.Size()==0)
               {
                //do nothing
               }
               else if(patAddList.Size()==1)
               {
                returnString=(patAddList[0].City_gne__c==null)? ', ':patAddList[0].City_gne__c + ', ';
                returnString+=(patAddList[0].State_gne__c==null)? ' ':patAddList[0].State_gne__c + ' ';
                returnString+=(patAddList[0].Zip_gne__c==null)? '':patAddList[0].Zip_gne__c;           
               }
               else if (patAddList.Size()>1)
               {
                List<Patient_Address_gne__c> patAddPryYesList=[Select p.Primary_Address_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Primary_Address_gne__c='Yes'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 100];
                    
                    if(patAddPryYesList.Size()==0)
                    {
                     
                    }
                    else if (patAddPryYesList.Size()==1)
                    {
                        
                      returnString=(patAddPryYesList[0].City_gne__c==null)? ', ':patAddPryYesList[0].City_gne__c + ', ';
                returnString+=(patAddPryYesList[0].State_gne__c==null)? ' ':patAddPryYesList[0].State_gne__c + ' ';
                returnString+=(patAddPryYesList[0].Zip_gne__c==null)? '':patAddPryYesList[0].Zip_gne__c;
                    }
                    else if(patAddPryYesList.Size()> 1)
                    {
                      List<Patient_Address_gne__c> patAddMailList=[Select p.Type_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Type_gne__c='Mailing'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal  LIMIT 100]; 
                                        
                                        
                             if(patAddMailList.Size()>=1)
                             {
                                
                               returnString=(patAddMailList[0].City_gne__c==null)? ', ':patAddMailList[0].City_gne__c + ', ';
                returnString+=(patAddMailList[0].State_gne__c==null)? ' ':patAddMailList[0].State_gne__c + ' ';
                returnString+=(patAddMailList[0].Zip_gne__c==null)? '':patAddMailList[0].Zip_gne__c;
                             }
                             else if(patAddMailList.Size()>1)
                             {
                               List<Patient_Address_gne__c> patAddMailListUpdated=[Select p.Type_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Type_gne__c='Mailing'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal  LIMIT 100]; 
                                        
                                     if(patAddMailListUpdated.Size()>=1)
                                     {
                                       returnString=(patAddMailListUpdated[0].City_gne__c==null)? ', ':patAddMailListUpdated[0].City_gne__c + ', ';
                returnString+=(patAddMailListUpdated[0].State_gne__c==null)? ' ':patAddMailListUpdated[0].State_gne__c + ' ';
                returnString+=(patAddMailListUpdated[0].Zip_gne__c==null)? '':patAddMailListUpdated[0].Zip_gne__c;
                                     }  
                             
                             }
                             else if(patAddMailList.Size()==0)
                             {
                                List<Patient_Address_gne__c> patAddHomeList=[Select p.Type_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Type_gne__c='Home'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal  LIMIT 100]; 
                                    if(patAddHomeList.Size()==1)    
                                    {
                                      returnString=(patAddHomeList[0].City_gne__c==null)? ', ':patAddHomeList[0].City_gne__c + ', ';
                returnString+=(patAddHomeList[0].State_gne__c==null)? ' ':patAddHomeList[0].State_gne__c + ' ';
                returnString+=(patAddHomeList[0].Zip_gne__c==null)? '':patAddHomeList[0].Zip_gne__c;
                                    }
                                    else if(patAddHomeList.Size()>0)
                                    {
                                       List<Patient_Address_gne__c> patAddHomeListUpdated=[Select p.Type_gne__c, p.Patient_gne__r.Patient_ID_gne__c, p.Patient_gne__c, 
                                        p.Address_Line_2_gne__c, p.Address_Line_1_gne__c From Patient_Address_gne__c p where 
                                        p.Type_gne__c='Home'and p.Patient_gne__r.Patient_ID_gne__c=:patientIdLocal  LIMIT 1]; 
                                        
                                            if(patAddHomeListUpdated.Size()==1) 
                                            {
                                              returnString=(PatAddHomeListUpdated[0].City_gne__c==null)? ', ':PatAddHomeListUpdated[0].City_gne__c + ', ';
                returnString+=(PatAddHomeListUpdated[0].State_gne__c==null)? ' ':PatAddHomeListUpdated[0].State_gne__c + ' ';
                returnString+=(PatAddHomeListUpdated[0].Zip_gne__c==null)? '':PatAddHomeListUpdated[0].Zip_gne__c;
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
                                            p.pat_con_Patient_gne__r.Patient_ID_gne__c, p.pat_con_Zip_gne__c, p.pat_con_State_gne__c, p.pat_con_City_gne__c,p.pat_con_Patient_gne__c From Patient_Contact_gne__c p
                                    where p.pat_con_Patient_gne__r.Patient_ID_gne__c=:patientIdLocal order by p.LastModifiedDate desc LIMIT 100];
             
             
                 if(patientLisWithcontact.Size()==0)
                 {
                  //if(patAddList.Size()==1)
               //{
                //returnString=(patAddList[0].City_gne__c==null)? ', ':patAddList[0].City_gne__c + ', ';
                //returnString+=(patAddList[0].State_gne__c==null)? ' ':patAddList[0].State_gne__c + ' ';
                //returnString+=(patAddList[0].Zip_gne__c==null)? '':patAddList[0].Zip_gne__c;           
               //}
                  
                 }
                 else if(patientLisWithcontact.Size()==1)
                 {
                  returnString=(patientLisWithcontact[0].pat_con_City_gne__c==null)? ', ':patientLisWithcontact[0].pat_con_City_gne__c + ', ';
                returnString+=(patientLisWithcontact[0].pat_con_State_gne__c==null)? ' ':patientLisWithcontact[0].pat_con_State_gne__c + ' ';
                returnString+=(patientLisWithcontact[0].pat_con_Zip_gne__c==null)? '':patientLisWithcontact[0].pat_con_Zip_gne__c;
                 }
                 else if(patientLisWithcontact.Size() >1)
                 {
                  List<Patient_Contact_gne__c> patientLisWithPrimaryYes=[Select p.pat_con_Street_gne__c,p.pat_con_Mail_Box_gne__c,
                                                            p.pat_con_Relationship_to_Patient_gne__c, 
                                      p.pat_con_Patient_gne__r.Patient_ID_gne__c, p.pat_con_Patient_gne__r.pat_first_name_gne__c, 
                                      p.pat_con_Patient_gne__r.Name, p.pat_con_Patient_gne__c, p.pat_con_Contact_Type_gne__c, 
                                      p.pat_con_Zip_gne__c, p.pat_con_State_gne__c, p.pat_con_City_gne__c,p.LAST_NAME_CONT_gne__c, p.First_Name_gne__c From Patient_Contact_gne__c p
                                      where p.pat_con_Patient_gne__r.Patient_ID_gne__c=:patientIdLocal 
                                      and p.pat_con_Contact_Type_gne__c='Primary'
                                      order by p.LastModifiedDate desc LIMIT 100];
                                      
                        if(patientLisWithPrimaryYes.Size()==1)
                        {
                         returnString=(patientLisWithPrimaryYes[0].pat_con_City_gne__c==null)? ', ':patientLisWithPrimaryYes[0].pat_con_City_gne__c + ', ';
                returnString+=(patientLisWithPrimaryYes[0].pat_con_State_gne__c==null)? ' ':patientLisWithPrimaryYes[0].pat_con_State_gne__c + ' ';
                returnString+=(patientLisWithPrimaryYes[0].pat_con_Zip_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Zip_gne__c;
                 }
                        
                        else if(patientLisWithPrimaryYes.Size()>1)
                        {
                          if(patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c!=null && patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c!='')
                          {
                               Relation=patientLisWithPrimaryYes[0].pat_con_Relationship_to_Patient_gne__c;
                               if(Relation=='Legal Guardian' || Relation=='Parent')
                               {
                               returnString=(patientLisWithPrimaryYes[0].pat_con_City_gne__c==null)? ', ':patientLisWithPrimaryYes[0].pat_con_City_gne__c + ', ';
                returnString+=(patientLisWithPrimaryYes[0].pat_con_State_gne__c==null)? ' ':patientLisWithPrimaryYes[0].pat_con_State_gne__c + ' ';
                returnString+=(patientLisWithPrimaryYes[0].pat_con_Zip_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Zip_gne__c;
                 }
                        
                               }
                               else
                               {
                              returnString=(patientLisWithPrimaryYes[0].pat_con_City_gne__c==null)? ', ':patientLisWithPrimaryYes[0].pat_con_City_gne__c + ', ';
                returnString+=(patientLisWithPrimaryYes[0].pat_con_State_gne__c==null)? ' ':patientLisWithPrimaryYes[0].pat_con_State_gne__c + ' ';
                returnString+=(patientLisWithPrimaryYes[0].pat_con_Zip_gne__c==null)? '':patientLisWithPrimaryYes[0].pat_con_Zip_gne__c;   
                          }
                        }
                    
             }}
       
     }catch(Exception e){
         returnString ='';
     }                            
     
     return returnString;
    }
    
     public override String getFieldvalue()
   {
    return fieldValue;
   }
}