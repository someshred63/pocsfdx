public class SCM_MF_PatAddressCityStateZip extends SCM_MergeField{
    private String patientIdLocal;
    private String addressLine1;
    private String addressLine2;
    private String city;
    private String state;
    private String zip;
    public Patient_Address_gne__c patientAdd;
    
    public SCM_MF_PatAddressCityStateZip(String patientId)
    {
        this.patientIdLocal=patientId; 
        checked = false;
        displayCheck = false;
        displayTextBox = false; 
        displayLabel = false;
        setKey('PatientAddressCityStateZip');
        className = 'SCM_MF_PatAddressCityStateZip';
        fieldValue = getFieldValue();
    }
    public override String getFieldValue()
    { 
       String returnString=''; 
      try{
          List<Patient_Address_gne__c> patientList1 = [Select p.Address_Line_1_gne__c, 
                      p.Address_Line_2_gne__c,p.City_gne__c,p.State_gne__c,p.Zip_gne__c  
              From Patient_Address_gne__c p   
              where p.Patient_gne__c = :patientIdLocal order by p.LastModifiedDate desc LIMIT 500];
     
        if( patientList1.size()== 0 )
         {
         
         }          
         else if( patientList1.size()== 1)
         {     
         
             patientAdd=patientList1[0];
             addressLine2=patientAdd.Address_Line_2_gne__c;
             addressLine1=patientAdd.Address_Line_1_gne__c;
             city=patientAdd.City_gne__c;
             state=patientAdd.State_gne__c;
             zip=patientAdd.Zip_gne__c;
             
             addressLine2 = (addressLine2 == null)? '':addressLine2;
             addressLine1 = (addressLine1 == null)? '':addressLine1;
             city = (city == null)? '':city;
             state = (state == null)? '':state;
             zip = (zip == null)? '':zip;
             returnString = 
             (addressLine1 +' '+addressLine2 +' '
             + city+' '+ state+' '+ zip); 
             
         }
         else
         {       
            List<Patient_Address_gne__c> patientList2=[select p.Address_Line_1_gne__c, p.Address_Line_2_gne__c,
            p.City_gne__c,p.State_gne__c,p.Zip_gne__c 
                        From Patient_Address_gne__c p 
                                where p.Patient_gne__c  = :patientIdLocal and p.Primary_address_gne__c = 'Yes' 
                                order by p.LastModifiedDate desc LIMIT 500];
                            
              if( patientList2.size()== 0)
                {   
                    patientAdd=patientList2[0];
             addressLine2=patientAdd.Address_Line_2_gne__c;
             addressLine1=patientAdd.Address_Line_1_gne__c;
             city=patientAdd.City_gne__c;
             state=patientAdd.State_gne__c;
             zip=patientAdd.Zip_gne__c;
             
             addressLine2 = (addressLine2 == null)? '':addressLine2;
             addressLine1 = (addressLine1 == null)? '':addressLine1;
             city = (city == null)? '':city;
             state = (state == null)? '':state;
             zip = (zip == null)? '':zip;
             returnString = 
             (addressLine1 +' '+addressLine2 +' '
             + city+' '+ state+' '+ zip);  
                }
               else if(patientList2.size()== 1)
                { 
             patientAdd=patientList2[0];
             addressLine2=patientAdd.Address_Line_2_gne__c;
             addressLine1=patientAdd.Address_Line_1_gne__c;
             city=patientAdd.City_gne__c;
             state=patientAdd.State_gne__c;
             zip=patientAdd.Zip_gne__c;
             
             addressLine2 = (addressLine2 == null)? '':addressLine2;
             addressLine1 = (addressLine1 == null)? '':addressLine1;
             city = (city == null)? '':city;
             state = (state == null)? '':state;
             zip = (zip == null)? '':zip;
             returnString = 
             (addressLine1 +' '+addressLine2 +' '
             + city+' '+ state+' '+ zip);  
                } 
               else
                {
                 List<Patient_Address_gne__c> patientList3 =[Select p.Address_Line_1_gne__c, p.Address_Line_2_gne__c,
                 p.City_gne__c,p.State_gne__c,p.Zip_gne__c   
                        From Patient_Address_gne__c p 
                        where p.Patient_gne__c  = :patientIdLocal and p.Type_gne__c = 'Mailing'
                                     order by p.LastModifiedDate desc LIMIT 500];
                          
                     if( patientList3.size()== 1)
                        {  
                               patientAdd=patientList3[0];
             addressLine2=patientAdd.Address_Line_2_gne__c;
             addressLine1=patientAdd.Address_Line_1_gne__c;
             city=patientAdd.City_gne__c;
             state=patientAdd.State_gne__c;
             zip=patientAdd.Zip_gne__c;
             
             addressLine2 = (addressLine2 == null)? '':addressLine2;
             addressLine1 = (addressLine1 == null)? '':addressLine1;
             city = (city == null)? '':city;
             state = (state == null)? '':state;
             zip = (zip == null)? '':zip;
             returnString = 
             (addressLine1 +' '+addressLine2 +' '
             + city+' '+ state+' '+ zip);  
    
                        }
                     else if(patientList3.size()> 1)
                        {
                              patientAdd=patientList3[0];
             addressLine2=patientAdd.Address_Line_2_gne__c;
             addressLine1=patientAdd.Address_Line_1_gne__c;
             city=patientAdd.City_gne__c;
             state=patientAdd.State_gne__c;
             zip=patientAdd.Zip_gne__c;
             
             addressLine2 = (addressLine2 == null)? '':addressLine2;
             addressLine1 = (addressLine1 == null)? '':addressLine1;
             city = (city == null)? '':city;
             state = (state == null)? '':state;
             zip = (zip == null)? '':zip;
             returnString = 
             (addressLine1 +' '+addressLine2 +' '
             + city+' '+ state+' '+ zip);  
                        }
                        else
                        {
                            List<Patient_Address_gne__c> patientList4 =[select p.Address_Line_1_gne__c, 
                            p.Address_Line_2_gne__c,p.City_gne__c,p.State_gne__c,p.Zip_gne__c   
                                     From Patient_Address_gne__c p 
                                     where p.Patient_gne__c  = :patientIdLocal and p.Type_gne__c = 'Home'
                                                order by p.LastModifiedDate desc LIMIT 500];
                                     
                                if(patientList4.size()== 1)
                                {   
                                       patientAdd=patientList4[0];
             addressLine2=patientAdd.Address_Line_2_gne__c;
             addressLine1=patientAdd.Address_Line_1_gne__c;
             city=patientAdd.City_gne__c;
             state=patientAdd.State_gne__c;
             zip=patientAdd.Zip_gne__c;
             
             addressLine2 = (addressLine2 == null)? '':addressLine2;
             addressLine1 = (addressLine1 == null)? '':addressLine1;
             city = (city == null)? '':city;
             state = (state == null)? '':state;
             zip = (zip == null)? '':zip;
             returnString = 
             (addressLine1 +' '+addressLine2 +' '
             + city+' '+ state+' '+ zip);  
    
                                }
                                else if(patientList4.size()> 1)
                                {
                                   patientAdd=patientList4[0];
             addressLine2=patientAdd.Address_Line_2_gne__c;
             addressLine1=patientAdd.Address_Line_1_gne__c;
             city=patientAdd.City_gne__c;
             state=patientAdd.State_gne__c;
             zip=patientAdd.Zip_gne__c;
             
             addressLine2 = (addressLine2 == null)? '':addressLine2;
             addressLine1 = (addressLine1 == null)? '':addressLine1;
             city = (city == null)? '':city;
             state = (state == null)? '':state;
             zip = (zip == null)? '':zip;
             returnString = 
             (addressLine1 +' '+addressLine2 +' '
             + city+' '+ state+' '+ zip);  
    
                                }
                                else
                                {
                                  patientAdd=patientList4[0];
             addressLine2=patientAdd.Address_Line_2_gne__c;
             addressLine1=patientAdd.Address_Line_1_gne__c;
             city=patientAdd.City_gne__c;
             state=patientAdd.State_gne__c;
             zip=patientAdd.Zip_gne__c;
             
             addressLine2 = (addressLine2 == null)? '':addressLine2;
             addressLine1 = (addressLine1 == null)? '':addressLine1;
             city = (city == null)? '':city;
             state = (state == null)? '':state;
             zip = (zip == null)? '':zip;
             returnString = 
             (addressLine1 +' '+addressLine2 +' '
             + city+' '+ state+' '+ zip);  
            }
                                
                         } 
                               
              }
              
           }
           if(returnString==null)
           {
            returnString='';
           }
       }catch (Exception e){
           returnString='';
       }
       return returnString;
    }
   
    

}