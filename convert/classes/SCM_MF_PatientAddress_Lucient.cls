//condition is as follows
//Join Case.Patient_gne__c to Patient.PatientID_gne__c and join Patient.PatientID_gne__c to Patient Address.Patient_gne__c to return a list of Patient Address objects.
//If count of Patient Address = 0, then merge ""
//If count of Patient Address = 1, then merge Patient Address.Address_Line_1_gne__c
//If count of Patient Address > 1, then return a list of Patient Address objects where Patient Address.Primary_address_gne__c = Yes
   //If count of Patient Address = 0, then select the last updated Patient Address
   //If count of Patient Address = 1, then merge Patient Address.Address_Line_1_gne__c
   //If count of Patient Address > 1, the return a list of Patient.Address_type_gne__c where Patient Address.Address_Type_gne__c = Mailing address
      //If count of Patient Address = 1, then merge Patient Address.Address_Line_1_gne__c
      //If count of Patient Address > 1, then select by Last Updated date, the Patient Address from which Patient Address.Address_Line_1_gne__c
      //If count of Patient Address = 0, then return a list of Patient.Address_type_gne__c where Patient Address.Address_Type_gne__c = Home Address
         //If count of Patient Address = 1, then merge Patient Address.Address_Line_1_gne__c
         //If count of Patient Address > 1, then select by Last Updated date, the Patient Address from which Patient Address.Address_Line_1_gne__c
         //If count of Patient Address = 0, then select the last updated Patient Address
 
 
public class SCM_MF_PatientAddress_Lucient extends SCM_MergeField
 {
    
    public SCM_MF_PatientAddress_Lucient(String patientIdLocal)
    {
      
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='PatientStAddress';
      className='SCM_MF_PatientAddress_Lucient';
      try{
      fieldValue = obtainAddress(patientIdLocal);
      }catch(Exception e){
          SCM_LogError.sendEmail(e,'SCM_MF_PatientAddress_Lucient->obtainAddress()');
          fieldValue = '';
      }
    }
     
    public string obtainAddress(String patientIdLocal)
    {
       String [] Primary;
       String [] Mailing;
       String [] Home;
       Integer i;
       
       String returnString='';
       List<Patient_Address_gne__c> patientList;
       
       patientList = [Select p.Address_Line_1_gne__c,Primary_Address_gne__c,Type_gne__c
                                                     From Patient_Address_gne__c p 
                                                     where p.Patient_gne__c = :patientIdLocal 
                                                     AND ( p.Primary_Address_gne__c = 'Yes'
                                                           OR  p.Type_gne__c ='Mailing'
                                                           OR  p.Type_gne__c ='Home'
                                                          )
                                                     order by p.LastModifiedDate desc LIMIT 100];
      
        if(patientList.size()==0)
        {
           //do nothing
            return returnstring;
        }
        else if(patientList.size()==1)
        {
          returnString=patientList[0].Address_Line_1_gne__c;

          return returnstring;
          
        }
        else //if there are more that 1 objects
        {
             
             if(patientList != null)
             {
                  for(i=0 ; i < patientList.size() ; i++){
                     Integer p=0, m=0, h=0;
        
                    if(patientList[i].Primary_Address_gne__c == 'Yes'){
                       Primary[p]=patientList[i].Address_Line_1_gne__c;
                        p++;
                    }
                    else if(patientList[i].Type_gne__c == 'Mailing'){   
                       Mailing[i]=patientList[m].Address_Line_1_gne__c;
                       m++;
                    }
                    else if(patientList[i].Type_gne__c == 'Home'){   
                       Home[i]=patientList[h].Address_Line_1_gne__c;
                       h++;
                       }
                  }
             }

          if(Primary.size()==0)
          {
              returnString=patientList[0].Address_Line_1_gne__c;
              return returnstring;
          }
          else if(Primary.size()==1)
          {
             returnString=Primary[0];
             return returnstring;
          }
          else if(Primary.size()>1)
          {
            if(Mailing.size()==0)
            {
                 returnString=Primary[0];
                 return returnstring;
            }
            else if(Mailing.size()==1)
            {
                 returnString=Mailing[0];
                 return returnstring;
            }
            else if(Mailing.size()>1)
            {
                if(Home.size()==0)
                {
                   returnString=Mailing[0];
                   return returnstring;
                }
                else if(Mailing.size()==1)
                {
                     returnString=Home[0];
                     return returnstring;
               }
               else
                returnString=patientList[0].Address_Line_1_gne__c;
            }
          }
                 
        } 

       if(returnString==null)
       {
        returnString='';
       }
       
       return returnString;
    }
   
    public override String getFieldvalue()
    {
        if(fieldValue == null)
        {
            return '';
        }
        else
        {
            return fieldValue;
        }
    }
    
}