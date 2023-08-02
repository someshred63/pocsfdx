public class SCM_MF_Fulfillment_Factory {
private static List<Fulfillment_gne__c> Fulfillment;
    
    
    private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        mf.fieldValue =''; 
        return mf;
    }
    private static List<Fulfillment_gne__c> getFulfillment(String caseID)
    {
        if( Fulfillment == null )
        {
            try
            {
            Fulfillment = [select f.In_network_name_gne__c,
                                  f.Out_network_name_gne__c, 
                                  f.In_Network_Selected_Distributor_gne__c,
                                  f.Out_Network_Selected_Distributor_gne__c, 
                                f.In_network_Contact_Name_gne__c, 
                                f.Out_network_Contact_Name_gne__c,
                                f.In_network_Fax_Number_gne__c,
                                f.Out_network_Fax_Number_gne__c ,
                                f.In_network_name_gne__r.Name ,
                                f.Out_network_Name_gne__r.Name,
                                f.Out_network_Phone_Number_gne__c,
                                f.In_network_Phone_Number_gne__c
            from Fulfillment_gne__c f
            where f.Case_Fulfillment_gne__c = :caseID 
            order by f.LastModifiedDate desc limit 100];
            }
            catch(Exception ex)
            {
                return null;
            }         
        }
        
        return Fulfillment;
    }
    
    
    public static SCM_MergeField DispensingCenter(String caseId)
    {
        SCM_MergeField mf = createMergeField('Dispensing Center');
        string returnString;
        mf.fieldValue ='';
       List<Account> acList;
      try
      {
        if(getFulfillment(caseID)!=null && Fulfillment.size()>0)
        {   
        Fulfillment_gne__c fulfillmentRecord=Fulfillment[0];
        String fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
               fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
        String fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
               fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
        
           if(fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('No'))
           {
                acList = [select a.Name from Account a where a.Id = :fulfillmentRecord.In_network_name_gne__c];
                if (acList.size() >0)
                {
                    returnString = acList[0].Name;
                }
                //returnString= fulfillmentRecord.In_network_Phone_Number_gne__c;
            }
            else if(fulfillmentOut.equalsIgnoreCase('Yes') && fulfillmentIN.equalsIgnoreCase('No')) {
                {
                    acList = [select a.Name from Account a where a.Id = :fulfillmentRecord.Out_network_name_gne__c];
                    if (acList.size() >0) 
                    {
                        returnString = acList[0].Name;
                    }
                }
                    //returnString= fulfillmentRecord.Out_network_Phone_Number_gne__c;   
            } 
            else if((fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('Yes')) ||
                 (fulfillmentIN.equalsIgnoreCase('No') && fulfillmentOut.equalsIgnoreCase('No'))) {
                    returnString = '';
            }
        }   
        
        returnString= (returnString== null)?'':returnString;
        mf.fieldValue=returnString;
    
                          
        
      }
      catch(Exception ex)
      {
        mf.fieldValue = '';    
      }
        return mf;
    }
    
    
    public static SCM_MergeField DispensingCenter_TextBox(String caseId)
    {
        SCM_MergeField mf = createMergeField('ATTN_Attn');
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = true; 
        mf.displayLabel = true;
        mf.label = 'Attn:';
 
        string returnString='';
        try {
        if(getFulfillment(caseID)!=null && Fulfillment.size()>0)
        {   
        Fulfillment_gne__c fulfillmentRecord=Fulfillment[0];
        
        if(fulfillmentRecord != null) {
            String fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
                   fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
            String fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
                   fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
                             
            if(fulfillmentIN.equalsIgnoreCase('Yes')&& fulfillmentOut.equalsIgnoreCase('No'))
                returnString= fulfillmentRecord.In_network_Contact_Name_gne__c;
            else if(fulfillmentOut.equalsIgnoreCase('Yes') && fulfillmentIN.equalsIgnoreCase('No')) 
                returnString= fulfillmentRecord.Out_network_Contact_Name_gne__c;   
            else if(fulfillmentIN.equalsIgnoreCase(fulfillmentOut)) 
            {
                 if(fulfillmentRecord.In_network_Contact_Name_gne__c != null && 
                    fulfillmentRecord.In_network_Contact_Name_gne__c != '')
                        returnString= fulfillmentRecord.In_network_Contact_Name_gne__c;
                 
                else if(fulfillmentRecord.Out_network_Contact_Name_gne__c != null && 
                            fulfillmentRecord.Out_network_Contact_Name_gne__c != '')
                        returnString= fulfillmentRecord.Out_network_Contact_Name_gne__c;
            }
        }
        }   
        returnString= (returnString== null)?'':returnString;
        mf.fieldValue=returnString;
         }
      catch(Exception ex)
      {
        mf.fieldValue = '';    
      }
        return mf;
    }
    
    public static SCM_MergeField DispensingContactPhone(String caseId)
    {
        SCM_MergeField mf = createMergeField('DispensingContactPhone');
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false; 
        mf.displayLabel = false;
 
        string returnString='';
        try {
        if(getFulfillment(caseID)!=null && Fulfillment.size()>0)
        {   
        Fulfillment_gne__c fulfillmentRecord=Fulfillment[0];
        String fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
               fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
        String fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
               fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
        
           if(fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('No')) {
                returnString= fulfillmentRecord.In_network_Phone_Number_gne__c;
            }
            else if(fulfillmentOut.equalsIgnoreCase('Yes') && fulfillmentIN.equalsIgnoreCase('No')) {
                returnString= fulfillmentRecord.Out_network_Phone_Number_gne__c;   
            } 
            else if((fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('Yes')) ||
                 (fulfillmentIN.equalsIgnoreCase('No') && fulfillmentOut.equalsIgnoreCase('No'))) {
                    returnString = '';
            }
        }   
        
        returnString= (returnString== null)?'':returnString;
        mf.fieldValue=returnString;
         }
      catch(Exception ex)
      {
        mf.fieldValue = '';    
      }
        return mf;
    }

    public static SCM_MergeField DispensingContactName(String caseId)
    {
        SCM_MergeField mf = createMergeField('DispensingContactName');
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false; 
        mf.displayLabel = false;
        mf.fieldValue = '';   
       
        string returnString='';
        try {
       
        if(getFulfillment(caseID)!=null && Fulfillment.size()>0)
        {   
        Fulfillment_gne__c fulfillmentRecord=Fulfillment[0];
        String fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
               fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
        String fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
               fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
        
           if(fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('No')) {
                returnString= fulfillmentRecord.In_network_Contact_Name_gne__c;
            }
            else if(fulfillmentOut.equalsIgnoreCase('Yes') && fulfillmentIN.equalsIgnoreCase('No')) {
                returnString= fulfillmentRecord.Out_network_Contact_Name_gne__c;   
            } 
            else if((fulfillmentIN.equalsIgnoreCase('Yes') && fulfillmentOut.equalsIgnoreCase('Yes')) ||
                 (fulfillmentIN.equalsIgnoreCase('No') && fulfillmentOut.equalsIgnoreCase('No'))) {
                    returnString = '';
            }
        }   
        
        returnString= (returnString== null)?'':returnString;
        mf.fieldValue=returnString;
      
     }
      catch(Exception ex)
      {
      //    mf.fieldValue = '';    
      }
        return mf;
    }

    
    public static SCM_MergeField FulFillmentFaxNumber(String caseId)
    {
        SCM_MergeField mf = createMergeField('RECFAX_Fax');
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = true; 
        mf.displayLabel = true;
        mf.label='Fax:';
        mf.fieldType=SCM_MergeField.FieldTypes.phoneNumberField;
        try {
        string returnString='';
        if(getFulfillment(caseID)!=null && Fulfillment.size()>0)
        {   
        Fulfillment_gne__c fulfillmentRecord=Fulfillment[0];
        String fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
               fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
        String fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
               fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
        
           if(fulfillmentIN.contains('Yes') && fulfillmentOut.contains('No')) {
                returnString= fulfillmentRecord.In_network_Fax_Number_gne__c;
            }
            else if(fulfillmentOut.contains('Yes') && fulfillmentIN.contains('No')) {
                returnString= fulfillmentRecord.Out_network_Fax_Number_gne__c;
            } 
          else if((fulfillmentIN.contains('Yes') && fulfillmentOut.contains('Yes')) ||
                 (fulfillmentIN.contains('No') && fulfillmentOut.contains('No'))) {
                    //returnString = '';
            }
            
        }   
        
        returnString= (returnString== null)?'':returnString;
        mf.fieldValue=returnString;
         }
         
      catch(Exception ex)
      {
        mf.fieldValue = '';    
      }
        return mf;
    }
    
    public static SCM_MergeField FulfillmentAddressTo(String caseId)
    {
     SCM_MergeField mf = createMergeField('RECNAME_To');
     mf.checked = false;
     mf.displayCheck = false;
     mf.displayTextBox = true; 
     mf.displayLabel = true;
     mf.label = 'Addressed To:';

        string returnString='';
        try {
        if(getFulfillment(caseID)!=null && Fulfillment.size()>0)
        {   
        Fulfillment_gne__c fulfillmentRecord=Fulfillment[0];
        
        if(fulfillmentRecord != null) {
            String fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
                   fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
            String fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
                   fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
                             
            if(fulfillmentIN.equalsIgnoreCase('Yes'))
                returnString= fulfillmentRecord.In_network_name_gne__r.Name;
            else if(fulfillmentOut.equalsIgnoreCase('Yes')) 
                returnString= fulfillmentRecord.Out_network_Name_gne__r.Name;   
            else if(fulfillmentIN.equalsIgnoreCase(fulfillmentOut)) 
            {
                 if(fulfillmentRecord.In_network_name_gne__r.Name != null && 
                    fulfillmentRecord.In_network_name_gne__r.Name != '')
                        returnString= fulfillmentRecord.In_network_name_gne__r.Name;
                 
                else if(fulfillmentRecord.Out_network_Name_gne__r.Name != null && 
                            fulfillmentRecord.Out_network_Name_gne__r.Name != '')
                        returnString= fulfillmentRecord.Out_network_Name_gne__r.Name;
            }
        }
        }   
        returnString= (returnString== null)?'':returnString;
        mf.fieldValue=returnString;
         }
      catch(Exception ex)
      {
        mf.fieldValue = '';    
      }
        return mf;
    }
    
    
    public static SCM_MergeField DispensingCenterType(String caseId)
    {
        SCM_MergeField mf = createMergeField('DispensingCenterType');
        string returnString;
      try
      {
         mf.fieldValue = 'In ';
        if(getFulfillment(caseID)!=null)
        {
          List<Account> acList;
          
                if (! Fulfillment.isEmpty()) 
                {
                  if (Fulfillment[0].Out_Network_Selected_Distributor_gne__c.contains('Yes')) 
                  //&& (Fulfillment[0].In_Network_Selected_Distributor_gne__c.contains('No')
                  //|| Fulfillment[0].In_Network_Selected_Distributor_gne__c=='' || Fulfillment[0].In_Network_Selected_Distributor_gne__c== null ))
                  { 
                    
                        acList = [select a.Name from Account a where a.Id = :Fulfillment[0].Out_network_name_gne__c];               
                         if (acList.size() >0) 
                         {
                            mf.fieldValue = 'Out ';
                          }           
                  }
                 
                  else if (Fulfillment[0].In_Network_Selected_Distributor_gne__c.contains('Yes'))
                  //&&(Fulfillment[0].Out_Network_Selected_Distributor_gne__c.contains('No')||Fulfillment[0].Out_Network_Selected_Distributor_gne__c=='' || Fulfillment[0].Out_Network_Selected_Distributor_gne__c== null ))
                  {
                        acList = [select a.Name from Account a where a.Id = :Fulfillment[0].In_network_name_gne__c];               
                        if (acList!=null && !acList.isEmpty())
                        {
                            mf.fieldValue = 'In ';
                        }   
                   }  
                  
                  if (Fulfillment[0].In_Network_Selected_Distributor_gne__c.contains('Yes') && Fulfillment[0].Out_Network_Selected_Distributor_gne__c.contains('Yes') )
                  {
                            mf.fieldValue = '';
                   }  
                }
            }
        
      } 
      catch(Exception ex)
      {
        mf.fieldValue = 'In ';    
      }
        return mF;
    }
    
    
    public static SCM_MergeField DispensingFullAddress(String caseId)
    {
        SCM_MergeField mf = createMergeField('DispensingFullAddress');        
        mf.fieldValue ='';
        
        String returnString='';
        
        try
        {
        if(getFulfillment(caseID)!=null)
        { 
        Fulfillment_gne__c fulfillmentRecord=Fulfillment[0];
        List<Address_vod__c> address;
        
            if (fulfillmentRecord.In_network_name_gne__c !=null)
            {
            
                address = [ Select a.Zip_vod__c, a.State_vod__c,a.Address_line_2_vod__c, a.Name, a.City_vod__c, a.Account_vod__c 
                        From Address_vod__c a where a.Account_vod__c =:fulfillmentRecord.In_network_name_gne__c 
                        order by lastmodifieddate desc ];
             
                        if(address.size() >0)
                        {
                            returnString = address[0].Name ==null?'':address[0].Name;
                            returnString +=' ';
                            returnString += address[0].Address_line_2_vod__c ==null?'':address[0].Address_line_2_vod__c;
                            returnString +=' ';
                            returnString += address[0].City_vod__c== null?'': address[0].City_vod__c;
                            returnString +=' ';
                            returnString +=address[0].State_vod__c ==null?'': address[0].State_vod__c;
                            returnString +=' ';
                            returnString +=address[0].Zip_vod__c ==null?'': address[0].Zip_vod__c;
                        }
                        mf.fieldValue =returnString;
            }
            else
            {
                if (fulfillmentRecord.Out_network_name_gne__c!=null)
                {
                
                        address = [Select a.Zip_vod__c, a.State_vod__c, a.Name, a.City_vod__c, a.Account_vod__c 
                                From Address_vod__c a where a.Account_vod__c =:fulfillmentRecord.Out_network_name_gne__c 
                                order by lastmodifieddate desc ];
                    
                        if(address.size() >0)
                        {
                            returnString = address[0].Name ==null?'':address[0].Name;
                            returnString +=' ';
                            returnString += address[0].City_vod__c== null?'': address[0].City_vod__c;
                            returnString +=' ';
                            returnString +=address[0].State_vod__c ==null?'': address[0].State_vod__c;
                            returnString +=' ';
                            returnString +=address[0].Zip_vod__c ==null?'': address[0].Zip_vod__c;
                            
                            
                        }
                        mf.fieldValue = returnString;
                }
            }
                    
                    if (fulfillmentRecord.In_Network_Selected_Distributor_gne__c == 'Yes' && fulfillmentRecord.Out_network_Selected_Distributor_gne__c == 'Yes') {
                    mf.fieldValue = '';
                }
                  if (fulfillmentRecord.In_Network_Selected_Distributor_gne__c == 'No' && fulfillmentRecord.Out_network_Selected_Distributor_gne__c == 'No') {
                    mf.fieldValue = '';
                }
            }
            
        }
        catch(Exception ex)
        {
            mf.fieldValue ='';
        }
        
       
       
        return mf;
    }
    
    public static SCM_MergeField FulFillmentFaxNumber_BI(String caseId)
    { 
        SCM_MergeField mf = createMergeField('FulFax');
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false; 
        mf.displayLabel = false;
        mf.label='Fax:';
        mf.fieldType=SCM_MergeField.FieldTypes.phoneNumberField;
 
        string returnString='';
        try {
        if(getFulfillment(caseID)!=null && Fulfillment.size()>0)
        {   
        Fulfillment_gne__c fulfillmentRecord=Fulfillment[0];
        String fulfillmentIN = fulfillmentRecord.In_Network_Selected_Distributor_gne__c ;
               fulfillmentIN = (fulfillmentIN == null)? 'No':fulfillmentIN ;
        String fulfillmentOut = fulfillmentRecord.Out_Network_Selected_Distributor_gne__c;
               fulfillmentOut = (fulfillmentOut == null)? 'No':fulfillmentOut ;
        
           if(fulfillmentIN.contains('Yes') && fulfillmentOut.contains('No')) {
                returnString= fulfillmentRecord.In_network_Fax_Number_gne__c;
            }
            else if(fulfillmentOut.contains('Yes') && fulfillmentIN.contains('No')) {
                returnString= fulfillmentRecord.Out_network_Fax_Number_gne__c;
            } 
            else if((fulfillmentIN.contains('Yes') && fulfillmentOut.contains('Yes')) ||
                 (fulfillmentIN.contains('No') && fulfillmentOut.contains('No'))) {
                    mf.fieldValue = '';
            }
        }   
        
        returnString= (returnString== null)?'':returnString;
        mf.fieldValue=returnString;
         }
      catch(Exception ex)
      {
        mf.fieldValue = '';    
      }
        return mf;
    }
    
     
    
    
    
}