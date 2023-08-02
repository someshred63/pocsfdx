public class SCM_MF_PatientFieldFactory {

    private static List<Patient_gne__c> patientsList;

    private static Patient_gne__c getPatient(String patientId)
    {
        if( patientsList == null ){
        try
        {
            patientsList = [Select  p.Counter_gne__c, 
                                   p.Created_Date_Calc_gne__c, 
                                   p.Dist_Pat_ID_gne__c, 
                                   p.Eligible_for_Nutropin_Starter_gne__c, 
                                   p.Eligible_for_Pulmozyme_Starter_gne__c, 
                                   p.Hearing_Impaired_gne__c, 
                                   p.Id, 
                                   p.Mid_Initial_gne__c, 
                                   p.Name, 
                                   p.Non_English_Speaking_gne__c, 
                                   p.Note_gne__c, 
                                   p.PAN_Form_1_Expiration_Date_gne__c, 
                                   p.PAN_Form_1_Product_gne__c, 
                                   p.PAN_Form_2_Exipration_Date_gne__c, 
                                  // p.PAN_Form_2_gne__c, 
                                   p.PAN_Form_2_Product_gne__c, 
                                   p.PAN_Form_2_Rec_gne__c, 
                                   p.PAN_Form_2_Signed_gne__c, 
                                   p.PAN_Form_Rec_gne__c, 
                                   p.PAN_Form_Signed_gne__c, 
                                  // p.PAN_gne__c, 
                                   p.PAN_TAT_gne__c, 
                                   p.pat_dob_gne__c, 
                                   p.pat_email_gne__c, 
                                   p.pat_first_name_gne__c,
                                   p.pat_gender_gne__c, 
                                   p.pat_home_phone_gne__c, 
                                   p.pat_income_gne__c, 
                                   p.pat_other_phone_gne__c, 
                                   p.pat_other_phone_type_gne__c, 
                                   p.pat_patient_deceased_gne__c, 
                                   p.pat_prefix_gne__c, 
                                   p.pat_work_phone_gne__c, 
                                   p.Patient_ID_gne__c, 
                                   p.Patient_Name__c, 
                                   p.Patient_Number_gne__c, 
                                   p.Patient_Preferred_Distributor_gne__c, 
                                   p.Preferred_Language_gne__c, 
                                   p.Release_gne__c, 
                                   p.Service_Quality_gne__c, 
                                   p.Service_Quality_Offered_Date_gne__c, 
                                   p.ssn_gne__c, 
                                   p.Status_Change_Date_gne__c, 
                                   p.Suffix_gne__c, 
                                   p.Translator_Needed_gne__c, 
                                   p.Vendor_Case_ID_gne__c, 
                                   p.Web_Pat_ID_gne__c 
                    from Patient_gne__c p 
                    Where Id=:patientId
                 ];
                 
                 }
                 catch(Exception ex)
                 {
                     return null;
                 }
            if(patientsList.size()==1)
            {
                return patientsList[0];
            }
            else
                return null;
        }
        else if(patientsList.size()>0)
            return patientsList[0];
        else
            return null;
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
      public static List<SCM_MergeField> GetAllNames(string patientId) {
    
    	List<SCM_MergeField> Fields = new List<SCM_MergeField>();
    	fields.add(PatientFirstAndLastName(patientId));
    	fields.add(PatientFirstMiddleAndLastName(patientId));
    	fields.add(PatientFirstName(patientId));
    	fields.add(PatientLastName(patientId));
    	return Fields;
    	
    }
    public static SCM_MergeField PatientDOB(String patientId)
    {
        SCM_MergeField mf = createMergeField('Patient_DOB');
        if( null != getPatient(patientId) )
        {
            Date dob = getPatient(patientId).pat_dob_gne__c;
            if(dob!=null)
                mf.fieldValue = dob.format();
            else
                mf.fieldValue = '';
        }
        return mf;
    }
    
    public static SCM_MergeField PatientAge(String patientId)
    {
        SCM_MergeField mf = createMergeField('PatientAge');
        
        if( null != getPatient(patientId) )
        {
            Date dob = getPatient(patientId).pat_dob_gne__c;
            if(dob!=null)
            {
                integer monthDiff = dob.monthsBetween(Date.Today());
                integer yrs = (monthDiff/12); 
                mf.fieldValue = string.valueOf(yrs);
            }
            else
            {
                mf.fieldValue = '';
            }
        }
       
        return mf;
    }
    
     public static SCM_MergeField Patient_Home_Phone(String patientId)
    {
        SCM_MergeField mf = createMergeField('PatientHomePhone');
        
        if( null != getPatient(patientId) )
        {
          if (patientsList.size() > 0) {
            if(patientsList[0].pat_home_phone_gne__c!=null)
            {
                
                mf.fieldValue = patientsList[0].pat_home_phone_gne__c;
            }
            else
            {
                mf.fieldValue = '';
            }
          }
        }
       
        return mf;
    }
    
    public static SCM_MergeField PatientFirstAndLastName(String patientId)
    {
        SCM_MergeField mf = createMergeField('Patient_First_And_Last_Name');
        try{
        if( null != getPatient(patientId) )
        {
            String firstName = getPatient(patientId).pat_first_name_gne__c;
            String lastName = getPatient(patientId).Name;
           
            
            if(firstName == null && lastName != null){
                mf.fieldValue = lastName;
            }
            else if(firstName != null && lastName == null){
                mf.fieldValue = firstName;
            }
            else if(firstName != null && lastName != null){
                mf.fieldValue = firstName + ' ' + lastName;
            }
            else {
            mf.fieldValue = ''; 
            }
            
        }
        else
            mf.fieldValue = '';
        }
        catch(Exception e){
               mf.fieldValue = '';
        }
        return mf;
    }
    
    public static SCM_MergeField PatientFirstMiddleAndLastName(String patientId)
    {
        SCM_MergeField mf = createMergeField('PatientFullName');
        if( null != getPatient(patientId) )
        {
            String firstName = getPatient(patientId).pat_first_name_gne__c;
            String lastName = getPatient(patientId).Name;
            String middleInitial = getPatient(patientId).Mid_Initial_gne__c;
            
            if(firstName == null && middleInitial==null && lastName != null)
                mf.fieldValue = lastName;
            else if(firstName == null && middleInitial!=null && lastName != null)
                mf.fieldValue = middleInitial + ' ' +lastName;
            else if(firstName != null && lastName == null)
                mf.fieldValue = firstName;
            else if(firstName != null && lastName != null && middleInitial==null)
                mf.fieldValue = firstName + ' ' + lastName;
            else if(firstName != null && lastName != null && middleInitial!=null)
                mf.fieldValue = firstName + ' ' + middleInitial+ ' ' + lastName;
        }
        return mf;
    }
    public static SCM_MergeField PatientGender(string patientId)
    {
        SCM_MergeField mf = createMergeField('Patient Gender');
        if( null != getPatient(patientId) )
        {
             if (getPatient(patientId).pat_gender_gne__c != null)
      mf.fieldvalue = getPatient(patientId).pat_gender_gne__c;
      else 
        mf.fieldvalue = '';    
        }
        
        return mf;
    }
    public static SCM_MergeField PatientHisHer(string patientId)
    {
        SCM_MergeField mf = createMergeField('His_Her');
        mf.fieldvalue = ''; 
        try
        {
            if( null != getPatient(patientId) )
            {
                if (getPatient(patientId).pat_gender_gne__c != null)
                {
                    if(getPatient(patientId).pat_gender_gne__c.ToLowerCase() == 'male')
                    {
                        mf.fieldvalue = 'His'; 
                    }
                    else if (getPatient(patientId).pat_gender_gne__c.ToLowerCase() == 'female')
                    {
                        mf.fieldvalue = 'Her'; 
                    }
                    else
                    {
                        mf.fieldvalue = ''; 
                    }
                }  
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }
    public static SCM_MergeField PatientGenderCheckBoxMale(string patientId)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = 'chkMale';
        mf.label='';
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        mf.fieldvalue = SCM_CheckBox_Values.Unchecked; 

        try
        {
            if( null != getPatient(patientId) )
            {
                 if (getPatient(patientId).pat_gender_gne__c != null)
                    mf.fieldvalue = (getPatient(patientId).pat_gender_gne__c.ToLowerCase() == 'male')? SCM_CheckBox_Values.Checked : SCM_CheckBox_Values.Unchecked; 
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }
    
    public static SCM_MergeField PatientGenderCheckBoxFemale(string patientId)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = 'chkFemale';
        mf.label='';
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        mf.fieldvalue = SCM_CheckBox_Values.Unchecked;
        
        try
        {
            if( null != getPatient(patientId) )
            {
                 if (getPatient(patientId).pat_gender_gne__c != null)
                    mf.fieldvalue = (getPatient(patientId).pat_gender_gne__c.ToLowerCase() == 'female')? SCM_CheckBox_Values.Checked : SCM_CheckBox_Values.Unchecked;  
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }
    
    public static SCM_MergeField PatientFirstName(string patientId)
    {
        SCM_MergeField mf = createMergeField('PatientFirstName');
        mf.fieldvalue = ''; 
        
        try
        {
            if( null != getPatient(patientId) )
            {
                if (getPatient(patientId).pat_first_name_gne__c != null)
                    mf.fieldvalue = getPatient(patientId).pat_first_name_gne__c;   
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        
        return mf;
    }

    public static SCM_MergeField PatientLastName(string patientId)
    {
        SCM_MergeField mf = createMergeField('PatientLastName');
        mf.fieldvalue = ''; 
        try
        {
            if( null != getPatient(patientId) )
            {
                if (getPatient(patientId).Name != null)
                    mf.fieldvalue = getPatient(patientId).Name;
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }
    
    public static SCM_MergeField PatientHomePhone(string patientId)
    {
        SCM_MergeField mf = createMergeField('PatientHomePhone');
        mf.fieldvalue = ''; 
        try
        {
            if( null != getPatient(patientId) )
            {
                if (getPatient(patientId).pat_home_phone_gne__c != null)
                    mf.fieldvalue = getPatient(patientId).pat_home_phone_gne__c;
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }
    
    public static SCM_MergeField PatientWorkPhone(string patientId)
    {
        SCM_MergeField mf = createMergeField('PatientWorkPhone');
        mf.fieldvalue = ''; 
        try
        {
            if( null != getPatient(patientId) )
            {
                if (getPatient(patientId).pat_work_phone_gne__c != null)
                    mf.fieldvalue = getPatient(patientId).pat_work_phone_gne__c;                   
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }
        
        return mf;
    }
    
    public static SCM_MergeField PatientCellPhone(string patientId)
    {
        SCM_MergeField mf = createMergeField('PatientCellPhone');
        Patient_gne__c pat = getPatient(patientId);
        mf.fieldValue = '';
        
        try
        {
            if( null != pat)
            {
                if (pat.pat_other_phone_gne__c != null && pat.pat_other_phone_type_gne__c != null)
                    if (pat.pat_other_phone_type_gne__c.equals('Mobile'))
                        mf.fieldvalue = pat.pat_other_phone_gne__c;
                else 
                    mf.fieldvalue = '';    
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }

        return mf;
    }
    
     public static SCM_MergeField InterpreterNeeded(string patientId)
    {
        SCM_MergeField mf = createMergeField('Interpreter');
        Patient_gne__c pat = getPatient(patientId);
        mf.fieldValue = '';
        
        try
        {
            if( null != pat)
            {
                if (pat.Translator_Needed_gne__c != null)
                    
                    mf.fieldvalue = pat.Translator_Needed_gne__c;
                else 
                    mf.fieldvalue = '';    
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }

        return mf;
    }
    
     public static SCM_MergeField PreferredLanguage(string patientId)
    {
        SCM_MergeField mf = createMergeField('PreferredLang');
        Patient_gne__c pat = getPatient(patientId);
        mf.fieldValue = '';
        
        try
        {
            if( null != pat)
            {
                if (pat.Preferred_Language_gne__c != null)
                    
                    mf.fieldvalue = pat.Preferred_Language_gne__c;
                else 
                    mf.fieldvalue = '';    
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }

        return mf;
    }
    
    public static SCM_MergeField PatientSSN(string patientId) {
        SCM_MergeField mf = createMergeField('PatientSSN');
        Patient_gne__c pat = getPatient(patientId);
        mf.fieldValue = '';
        
        try
        {
            if (pat != null) {
                String ssn = pat.ssn_gne__c;
                if (ssn != null) {
                    ssn = ssn.ReplaceAll('\\D', '').trim();
                    if (ssn.length() > 9) {
                        ssn = ssn.substring(0,8);
                    }
                    ssn = ssn.substring(0,3) + '-' + ssn.substring(3,5) + '-' + ssn.substring(5,9);                          
                    mf.fieldValue = ssn;
                }
            }
        }
        catch(Exception ex)
        {
            mf.fieldvalue = ''; 
        }

        return mf;
    }     
    
    // Manjunath Nilagiri -- 03/02/09
    // This method is added for the testing purpose
    // as we have the static methods we cannot populate the list more than once if its not null
    // so for negative testing we need to make the list as null so that we can test the methods 
    public static void clearList()
    {
        if(patientsList != null)
            patientsList = null;
    }
    
    
    
}