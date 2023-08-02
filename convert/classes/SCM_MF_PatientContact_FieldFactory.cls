public class SCM_MF_PatientContact_FieldFactory {
    private static List<Patient_Contact_gne__c> patientContactList;
    
    
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
    private static List<Patient_Contact_gne__c> getPatientContactList(String patientId)
    {
        if( patientContactList == null )
        {
            try
            {
            patientContactList = [Select p.pat_con_Patient_gne__r.Patient_ID_gne__c, 
                                         p.pat_con_Patient_gne__c, 
                                         p.pat_con_Contact_Type_gne__c, 
                                         p.LAST_NAME_CONT_gne__c, 
                                         p.First_Name_gne__c,
                                         p.pat_con_Home_Phone_gne__c,
                                         p.pat_con_Work_gne__c,
                                         p.pat_con_Other_Phone_gne__c,
                                         p.pat_con_Relationship_to_Patient_gne__c,
                                         p.pat_con_Mail_Box_gne__c,
                                         p.pat_con_Street_gne__c,
                                         p.pat_con_City_gne__c,
                                         p.pat_con_State_gne__c,
                                         p.pat_con_Zip_gne__c
                                  From Patient_Contact_gne__c p
                                  where //p.pat_con_Contact_Type_gne__c='Primary' and 
                                        p.pat_con_Patient_gne__c=:patientId 
                                  order by p.LastModifiedDate desc 
                                  LIMIT 500];
            }catch(Exception ex)
            {
                return null;                
            }
                      
        }
        
        return patientContactList;
    }
    
    private static Patient_Contact_gne__c getPrimaryContact(String patientId)
    {
        getPatientContactList(patientId);
        
        for(Patient_Contact_gne__c contact:patientContactList)
        {
            if(contact.pat_con_Contact_Type_gne__c=='Primary')
                return contact;
        }
        
        return null;
    }
    
     public static List<SCM_MergeField> GetAllNames(string patientId) {
    
    	List<SCM_MergeField> Fields = new List<SCM_MergeField>();
    	fields.add(PatientContactFullName(patientId));
    	fields.add(PatientPrimaryConFullName(patientId));
    	fields.add(PatientPrimaryConFirstName(patientId));
    	fields.add(PatientPrimaryConLastName(patientId));
    	return Fields;
    	
    }
    
    public static SCM_MergeField PatientContactFullName(String patientId)
    {
        SCM_MergeField mField = createMergeField('PatientFullName');
        mField.fieldvalue = '';

        try
        {
            Patient_Contact_gne__c patientPrimaryContact =  getPrimaryContact(patientId);
            if(patientPrimaryContact!=null)
            {
                if(patientPrimaryContact.First_Name_gne__c!=null)
                    mField.fieldValue+=patientPrimaryContact.First_Name_gne__c;
                if(patientPrimaryContact.LAST_NAME_CONT_gne__c!=null)
                    mField.fieldValue+=patientPrimaryContact.LAST_NAME_CONT_gne__c;
            }
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }

        return mField;
    }

    public static SCM_MergeField PatientPrimeConHmPh(String patientId)
    {
        SCM_MergeField mField = createMergeField('PatientPrimeConHmPh');
        mField.fieldvalue = '';
        
        try
        {
            Patient_Contact_gne__c patCon = getPrimaryContact(patientId);
            
            if (patCon != null)
            	mField.fieldValue = String.valueOf(patCon.pat_con_Home_Phone_gne__c).ReplaceAll('\\Dx', '');
            	if (mField.fieldValue == null)
            		mField.fieldValue = '';
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }

        return mField;
    }
    
        public static SCM_MergeField PatientPrimeworkPh(String patientId)
    {
        SCM_MergeField mField = createMergeField('Pat_Work_Ph');
        mField.fieldvalue = '';
        
        try
        {
            Patient_Contact_gne__c patCon = getPrimaryContact(patientId);
            
            if (patCon != null)
            	mField.fieldValue = String.valueOf(patCon.pat_con_Work_gne__c).ReplaceAll('\\Dx', '');
            	if (mField.fieldValue == null)
            		mField.fieldValue = '';
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }

        return mField;
    }

    public static SCM_MergeField PatientHomePhone(String patientId)
    {
        SCM_MergeField mField = createMergeField('Pat_Home_Ph');
        mField.fieldvalue = '';
        
        try
        {
            if(getPatientContactList(patientId).size() > 0)
            {
                mField.fieldValue = (String.valueOf(getPatientContactList(patientId)[0].pat_con_Home_Phone_gne__c).ReplaceAll('\\Dx', ''));
            }
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }

        return mField;
    }

    public static SCM_MergeField PatientWorkPhone(String patientId)
    {
        SCM_MergeField mField = createMergeField('Pat_Work_Ph');
        mField.fieldvalue = '';
        
        try
        {
            if(getPatientContactList(patientId).size() > 0l)
            {
                mField.fieldValue = (String.valueOf(getPatientContactList(patientId)[0].pat_con_Work_gne__c).ReplaceAll('\\Dx', ''));
            }
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }
        
        return mField;
    }
    
    public static SCM_MergeField PatientOtherPhone(String patientId)
    {
        SCM_MergeField mField = createMergeField('Pat_Other_Ph');
        mField.fieldvalue = '';
        
        try
        {
            if(getPatientContactList(patientId).size() > 0)
            {
                mField.fieldValue = (String.valueOf(getPatientContactList(patientId)[0].pat_con_Other_Phone_gne__c).ReplaceAll('\\Dx', ''));
            }
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }

        return mField;
    }

    private static string FormatPhoneNumber(String phoneNumber)
    {
        String formattedPhoneNumber = '';
        try
        {
            if (phoneNumber.contains('x'))
            {
                formattedPhoneNumber = phoneNumber;
            }
            else
            {
                // Not sure what assigning character > 10 means.
                phoneNumber = (phoneNumber.length() > 10 )? phoneNumber.Trim():phoneNumber;
                if (phoneNumber.length() == 7)
                {
                    phoneNumber = phoneNumber.substring(0,2) + '-' + phoneNumber.substring(3,6);                    
                }
                else if (phoneNumber.length() > 7)
                {
                    Integer startIndex = 0;
                    String phoneNumberLocal;
                    String PhoneNumberCode;
                    
                    startIndex = phoneNumber.length() - 7; 
                    phoneNumberLocal = phoneNumber.substring(startIndex , (startIndex + 2) ) 
                                  + '-' + phoneNumber
                                  .substring(( startIndex + 3),( startIndex + 6 ) );
                    
                    phoneNumberCode = '(' + phoneNumber.substring(0, startIndex) + ')';
                    phoneNumber = phoneNumberCode + phoneNumberLocal;                                                       
                }
                else if ((phoneNumber.length() < 7))
                {
                    Integer EndIndex = 0;
                    
                    EndIndex = phoneNumber.length() - 4 ;
                    if (EndIndex <= 0)
                    {
                        phoneNumber = '(999)999-9999';
                    }
                    else
                    { 
                        phoneNumber = phoneNumber.substring(0,EndIndex) + '-' 
                                        + phoneNumber.substring(EndIndex + 1);                                              
                    }
                }               
                formattedPhoneNumber = phoneNumber;                 
            }
        }       
        catch(Exception ex)
        {
            formattedPhoneNumber = '';
        }
        return formattedPhoneNumber ;
    }

    public static SCM_MergeField PatientPrimaryConFullName(String patientId)
    {
        string name;
        SCM_MergeField mField = createMergeField('PatientPrimeConFullName');
        mField.fieldvalue = '';
        
        try
        {
            Patient_Contact_gne__c patCon = getPrimaryContact(patientId);
            
            if (patCon != null)
            	 name=patCon.First_Name_gne__c+' '+patCon.LAST_NAME_CONT_gne__c;
            mField.fieldValue = (name==null)? '': name;	
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }
        
        return mField;
    }
    
     public static SCM_MergeField PatientPrimaryConFirstName(String patientId)
    {
        string name;
        SCM_MergeField mField = createMergeField('PatientPrimeConFirstName');
        mField.fieldvalue = '';
        
        try
        {
            Patient_Contact_gne__c patCon = getPrimaryContact(patientId);
            
            if (patCon != null)
            	 name=patCon.First_Name_gne__c;
            mField.fieldValue = (name==null)? '': name;	
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }
        
        return mField;
    }
    
     public static SCM_MergeField PatientPrimaryConLastName(String patientId)
    {
        string name;
        SCM_MergeField mField = createMergeField('PatientPrimeConLastName');
        mField.fieldvalue = '';
        
        try
        {
            Patient_Contact_gne__c patCon = getPrimaryContact(patientId);
            
            if (patCon != null)
            	 name=patCon.LAST_NAME_CONT_gne__c;
            mField.fieldValue = (name==null)? '': name;	
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }
        
        return mField;
    }

 public static SCM_MergeField PatientPrimeRelationship(String patientId)
    {
        SCM_MergeField mField = createMergeField('Relationship');
        mField.fieldvalue = '';
        
        try
        {
            Patient_Contact_gne__c patCon = getPrimaryContact(patientId);
            
            if (patCon != null)
            	mField.fieldValue = patCon.pat_con_Relationship_to_Patient_gne__c;
            	if (mField.fieldValue == null)
            		mField.fieldValue = '';
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }

        return mField;
    }
    public static SCM_MergeField PatientRelationship(String patientId)
    {
        SCM_MergeField mField = createMergeField('Relationship');
        mField.fieldvalue = '';
        
        try
        {
            Patient_Contact_gne__c patCon = getPrimaryContact(patientId);
            
            if (patCon != null)
            	mField.fieldValue = patCon.pat_con_Relationship_to_Patient_gne__c;
            	if (mField.fieldValue == null)
            		mField.fieldValue = '';
        }
        catch(Exception ex)
        {
            mField.fieldvalue = '';
        }

        return mField;
    }
}