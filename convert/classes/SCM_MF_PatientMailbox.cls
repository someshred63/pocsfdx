//condition is as follows
//Join Case.Patient_gne__c to Patient.PatientID_gne__c and join Patient.PatientID_gne__c to Patient Address.Patient_gne__c to return a list of Patient Address objects.
//If count of Patient Address = 0, then merge ""
//If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c
//If count of Patient Address > 1, then return a list of Patient Address objects where Patient Address.Primary_address_gne__c = Yes
   //If count of Patient Address = 0, then select the last updated Patient Address
   //If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c
   //If count of Patient Address > 1, the return a list of Patient.Address_type_gne__c where Patient Address.Address_Type_gne__c = Mailing address
      //If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c
      //If count of Patient Address > 1, then select by Last Updated date, the Patient Address from which Patient Address.Address_Line_2_gne__c
      //If count of Patient Address = 0, then return a list of Patient.Address_type_gne__c where Patient Address.Address_Type_gne__c = Home Address
         //If count of Patient Address = 1, then merge Patient Address.Address_Line_2_gne__c
         //If count of Patient Address > 1, then select by Last Updated date, the Patient Address from which Patient Address.Address_Line_2_gne__c
         //If count of Patient Address = 0, then select the last updated Patient Address

 
 
public class SCM_MF_PatientMailbox extends SCM_MergeField
 {
 	
    public SCM_MF_PatientMailbox(String patientIdLocal)
    {
    
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='PatientMailbox';
      className='SCM_MF_PatientMailbox';
      fieldValue = obtainMailBox(patientIdLocal);
    }
    
    public String obtainMailBox(String patientIdLocal)
    {
    	try {
        String returnString='';
       List<Patient_Address_gne__c> patientList = [Select p.Address_Line_1_gne__c, p.Address_Line_2_gne__c
         From Patient_Address_gne__c p 
        where p.Patient_gne__r.Patient_ID_gne__c = :patientIdLocal order by p.LastModifiedDate desc LIMIT 20];
        
        if(patientList.size()==0)
        {
         //do nothing
        }
        else if(patientList.size()==1)
        {
         returnString=patientList[0].Address_Line_2_gne__c;
        }
        else //if there are more that 1 objects
        {
	        List<Patient_Address_gne__c> patientListWithAddressyes=[Select p.Address_Line_1_gne__c, p.Address_Line_2_gne__c 
	         From Patient_Address_gne__c p where p.Patient_gne__r.Patient_ID_gne__c = :patientIdLocal 
	         and p.Primary_Address_gne__c = 'Yes' order by p.LastModifiedDate desc LIMIT 500];
		        
		        //traverse through patientListWithAddressyes objects
		        if(patientListWithAddressyes.size()==0)
		        {
		          returnString=patientList[0].Address_Line_2_gne__c;
		        }
		        else if(patientListWithAddressyes.size()==1)
		        {
		         returnString=patientListWithAddressyes[0].Address_Line_2_gne__c;
		        }
                else
                {
                List<Patient_Address_gne__c> patientListWithMail=[Select p.Address_Line_1_gne__c, p.Address_Line_2_gne__c 
	       										  From Patient_Address_gne__c p where p.Patient_gne__r.Patient_ID_gne__c= :patientIdLocal and 
	        									  p.Type_gne__c = 'Mailing' order by p.LastModifiedDate desc LIMIT 500];
		        
		        
                        if(patientListWithMail.size()==1)
                        {
                             returnString=patientListWithMail[0].Address_Line_2_gne__c;
                        }
                        else if(patientListWithMail.size()>1)
                        {
                        	returnString=patientListWithMail[0].Address_Line_2_gne__c;
                        }
                        else 
                        {
                               List<Patient_Address_gne__c> patientListWithHomeAddress=[Select p.Address_Line_1_gne__c, p.Address_Line_2_gne__c 
	       										  From Patient_Address_gne__c p where p.Patient_gne__r.Patient_ID_gne__c = :patientIdLocal and 
	        									p.Type_gne__c = 'Home' order by p.LastModifiedDate desc LIMIT 500
	        									 ];
	        							     if(patientListWithHomeAddress.size()==1)
									        {
									         returnString=patientListWithHomeAddress[0].Address_Line_2_gne__c;
									        }	
									        else if(patientListWithHomeAddress.size()>1)
									        {
									         returnString=patientListWithHomeAddress[0].Address_Line_2_gne__c;
									        }
									        else
									        {
									         returnString=patientListWithAddressyes[0].Address_Line_2_gne__c;
									        }
									        	 
	        									 
                        }
                }
        
        
        } 
        if(returnString==null)
       {
        returnString='';
       }
        
       return returnString;
    }
     catch (exception ex) {
   	return '';
   }
    }
    
     public override String getFieldvalue()
   {
    return fieldValue;
   }
  
}