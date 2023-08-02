public class SCM_MF_PatientAddressFactory {

    private static List<Patient_Address_gne__c> patientAddressList;

    private static Patient_Address_gne__c getPatientAddress(String patientId)
    {
    	Patient_Address_gne__c PatientAddress;
    	
        if( patientAddressList == null )
        {
            patientAddressList = [Select p.Address_Line_1_gne__c, 
                                   p.Address_Line_2_gne__c, 
                                   p.City_gne__c, 
                                   p.Counter_gne__c, 
                                   p.Country_gne__c, 
                                   p.Id, 
                                   p.Name, 
                                   p.Other_Phone_gne__c, 
                                   p.Other_Phone_Type_gne__c, 
                                   p.Patient_gne__c, 
                                   p.Phone_gne__c, 
                                   p.Phone_Type_gne__c, 
                                   p.Primary_Address_gne__c, 
                                   p.Release_gne__c, 
                                   p.State_gne__c, 
                                   p.Type_gne__c, 
                                   p.Validated_gne__c, 
                                   p.Zip_gne__c,
                                   p.LastModifiedDate
                          from Patient_Address_gne__c p 
                          where p.Patient_gne__c = :patientId 
                          order by p.Primary_Address_gne__c,p.LastModifiedDate desc LIMIT 1];
                 
          //  if(patientAddressList.size()==1)
          //  {
          //      PatientAddress= patientAddressList[0];
          //  }
          //  else
          //      PatientAddress= null;
        }
        else if(patientAddressList.size()>0)
            PatientAddress= patientAddressList[0];
        else
            PatientAddress= null;
            
       return PatientAddress;            
    }
    
    private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        
        return mf;
    }
    
    
    public static List<SCM_MergeField> GetAll(string patientId) {
    
    	List<SCM_MergeField> Fields = new List<SCM_MergeField>();
    	fields.add(PatientAddressLine1(patientId));
    	fields.add(PatientAddressLine2(patientId));
    	fields.add(City(patientId));
    	fields.add(State(patientId));
    	fields.add(Zip(patientId));
    	fields.add(PatientCityStateZip(patientId));
    	fields.add(PatientPhone(patientId));
    	fields.add(PatientStAddress2(patientId));
    	return Fields;
    	
    }
    
         
    public static SCM_MergeField PatientAddressLine1(String patientId)
    {
        SCM_MergeField mf = createMergeField('Patient AddressLine1');
        mf.fieldvalue = '';
        try
        {
        	
        	// Qry is runnig to get the values again
        	   patientAddressList = [Select p.Address_Line_1_gne__c, 
                                   p.Address_Line_2_gne__c, 
                                   p.City_gne__c, 
                                   p.Counter_gne__c, 
                                   p.Country_gne__c, 
                                   p.Id, 
                                   p.Name, 
                                   p.Other_Phone_gne__c, 
                                   p.Other_Phone_Type_gne__c, 
                                   p.Patient_gne__c, 
                                   p.Phone_gne__c, 
                                   p.Phone_Type_gne__c, 
                                   p.Primary_Address_gne__c, 
                                   p.Release_gne__c, 
                                   p.State_gne__c, 
                                   p.Type_gne__c, 
                                   p.Validated_gne__c, 
                                   p.Zip_gne__c,
                                   p.LastModifiedDate
                          from Patient_Address_gne__c p 
                          where p.Patient_gne__c = :patientId 
                          order by p.Primary_Address_gne__c,p.LastModifiedDate desc LIMIT 500]; 
        	
        	
        	  if( getPatientAddress(patientId) != null) 
        	  {    
        	  	//mf.fieldvalue = 'sdfsddfs';    	 
                String Address_Line1 = patientAddressList[0].Address_Line_1_gne__c ;
                if(Address_Line1 != null)
                  {
                  	  mf.fieldvalue = Address_Line1;
                  }                   
            }
            else
            	mf.fieldvalue = '';
        	
        /**	
        Patient_Address_gne__c patAddressList;
        	patAddressList = getPatientAddress(patientId);
            if( patAddressList != null )
            {
                if(patAddressList.Name != null)
                {
                    mf.fieldvalue =  patAddressList.Name;  
                }              
            }
            else
            {
            	
            	mf.fieldvalue = '';
            }
            */
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }
    
    public static SCM_MergeField PatientAddressLine2(String patientId) {
        SCM_MergeField mf = createMergeField('Patient AddressLine2');
        mf.fieldvalue = '';
        try
        {
            if(null != getPatientAddress(patientId)) {
                String Address_Line2 = getPatientAddress(patientId).Address_Line_2_gne__c ;
                if(Address_Line2 != null)
                    mf.fieldvalue = Address_Line2;                   
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }

        return mf;
    }   
    
    public static SCM_MergeField City(String patientId) {
        SCM_MergeField mf = createMergeField('PatientCity');
        mf.fieldvalue = '';
        
        try
        {
            if(null != getPatientAddress(patientId) && getPatientAddress(patientId).City_gne__c != null) 
            {
                mf.fieldvalue =  getPatientAddress(patientId).City_gne__c;
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }

        return mf;
    }   
    
    public static SCM_MergeField State(String patientId) {
        SCM_MergeField mf = createMergeField('PatientState');
        mf.fieldvalue = ''; 

        try
        {
            if( getPatientAddress(patientId) != null) 
            {
                mf.fieldvalue =  getPatientAddress(patientId).State_gne__c;
            }  
        } 
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }

        return mf;
    }   
    
    public static SCM_MergeField Zip(String patientId) {
        SCM_MergeField mf = createMergeField('PatientZip');
        mf.fieldvalue = ''; 
        
        try
        {
            if(null != getPatientAddress(patientId) && getPatientAddress(patientId).Zip_gne__c != null) 
            {
                mf.fieldvalue =  getPatientAddress(patientId).Zip_gne__c;
            }   
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }  
    public static SCM_MergeField PatientCityStateZip(String patientId) {
        
        SCM_MergeField mf = createMergeField('PatientCityStateZip');
        mf.fieldvalue = ''; 

        try
        {
            Patient_Address_gne__c patAddress = getPatientAddress(patientId);
            if(null != patAddress )
            { 
            	
            	String StrPatCity  = patAddress.City_gne__c ==null?'':patAddress.City_gne__c;
            	String StrPatState  = patAddress.State_gne__c ==null?'':patAddress.State_gne__c;
            	String StrPatZip  = patAddress.Zip_gne__c ==null?'':patAddress.Zip_gne__c;
            	/**
            		String StrAddress  = patAddress.City_gne__c ==null?'':patAddress.City_gne__c 
            						+ ', ' + patAddress.State_gne__c==null?'':patAddress.State_gne__c 
            						+ '  ' + patAddress.Zip_gne__c==null?'':patAddress.Zip_gne__c; 
            	
                mf.fieldValue = StrAddress;   
                             mf.fieldValue = patAddress.City_gne__c ==null?'':patAddress.City_gne__c + ', ' + patAddress.State_gne__c==null?'':patAddress.State_gne__c + '  ' + patAddress.Zip_gne__c==null?'':patAddress.Zip_gne__c;
        
                */  
            	
                mf.fieldValue = StrPatCity + ', ' + StrPatState + '  ' + StrPatZip;
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }

        return mf;
    } 
    public static SCM_MergeField PatientPhone(String patientId) {
        SCM_MergeField mf = createMergeField('PatientPhone');
        
        try
        {
            if(null != getPatientAddress(patientId) && getPatientAddress(patientId).Phone_gne__c != null) 
            {
                mf.fieldvalue =  getPatientAddress(patientId).Phone_gne__c;
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }
    
    public static SCM_MergeField PatientStAddress2(String patientId) {
        SCM_MergeField mf = createMergeField('PatientStAddress2');
        mf.fieldvalue = ''; 
        try
        {
            SCM_MergeField patAddLine1 = PatientAddressLine1(patientId);
            SCM_MergeField patAddLine2 = PatientAddressLine2(patientId);
            String Address = patAddLine1.fieldValue;
            Address += ' ';
            Address += patAddLine2.fieldValue ;
            
            mf.fieldValue = Address;
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        return mf;   
    }
}