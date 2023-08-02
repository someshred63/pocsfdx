public class GNE_PatPers_IU_Support_Helpers 
{

    public GNE_PatPers_IU_PatientAndAddressInfo getPatientAndAddressInfo(String patientID) {
        GNE_PatPers_IU_PatientAndAddressInfo pInfo = null;
        Patient_gne__c pat; // current patient
        Patient_Address_gne__c patAddr; // current patient address info
        
        try
        {       
        // 03-25-09 - patient_id_gne__c commented out by JW
        pat = [select Id,Mid_Initial_gne__c,Name,pat_dob_gne__c,pat_email_gne__c,pat_first_name_gne__c,
            pat_gender_gne__c,pat_home_phone_gne__c,pat_prefix_gne__c,pat_work_phone_gne__c, 
            Patient_Name__c,Patient_Number_gne__c,Suffix_gne__c, Age_gne__c 
        FROM Patient_gne__c 
        WHERE ID = :patientID LIMIT 1];
        }
        catch (Exception ex)
        {
           throw new GNE_PatPers_Exception('URGENT:  COULD NOT FIND PATIENT RECORD.  PLEASE VERIFY THAT A PATIENT IS SELECTED ON THE PATIENT PROGRAM SCREEN BEFORE YOU SAVE !!');
        }
        
        if (pat != null)
        {
           pInfo = new  GNE_PatPers_IU_PatientAndAddressInfo();
           
           // select patient address
           Patient_Address_gne__c[] addrList;
           addrList = [select Id, Address_Line_1_gne__c,Address_Line_2_gne__c,City_gne__c,
                Country_gne__c,Name,Phone_gne__c,Primary_Address_gne__c,Release_gne__c,
                State_gne__c,SystemModstamp,Type_gne__c,Validated_gne__c,Zip_gne__c
           FROM Patient_Address_gne__c
           WHERE Patient_gne__r.ID = :patientID
           ORDER BY SystemModstamp DESC, Primary_Address_gne__c DESC];      
           
           if (addrList.size() >= 1)
           {
           // there are multiple scenarios with Patient_Address that are encountered.  this solution should address
           // all of them.
           // Multiple addresses returned, primary_address tag @ Yes, first record
           // Multiple addresses returned, primary address tag @ No, most recently edited record first
           // single address returned, doesnt matter if primary, will be last edited record
               patAddr = addrList[0];
           } // address was returned successfully    
           else
           {
            
            if(pat.pat_email_gne__c==null){//only if email is not there check for address
             // address record not found.  back out trigger and throw error back to record
             patAddr = null;
             throw new GNE_PatPers_Exception('URGENT: ADDRESS RECORD NOT FOUND FOR PATIENT.  AT LEAST ONE PATIENT ADDRESS RECORD IS REQUIRED !!!');   
            }
           } // end else -- an address record was not found.  in theory, this should not happen
                
        } // pat is not null
        else
        {
             throw new GNE_PatPers_Exception('URGENT: PATIENT RECORD COULD NOT BE RETRIEVED FROM THE DATABASE.  PLEASE MAKE SURE A PATIENT IS SELECTED IN THE PATIENT FIELD ON THE PATIENT PROGRAM SCREEN !!!');   
        
        }


        if (pat != null) 
        {
            pInfo.patientID = pat.ID;
            pInfo.pat_first_name = pat.pat_first_name_gne__c;
            pInfo.pat_mid_initial = pat.Mid_Initial_gne__c;
            pInfo.pat_last_name = pat.Name;
            pInfo.pat_fax = '';
            pInfo.pat_prefix = pat.pat_prefix_gne__c;
            pInfo.pat_suffix = pat.Suffix_gne__c; 
            pInfo.pat_home_phone = pat.pat_home_phone_gne__c;
            pInfo.pat_email_gne = pat.pat_email_gne__c;
            pInfo.pat_gender = pat.pat_gender_gne__c;
            pInfo.pat_work_phone = pat.pat_work_phone_gne__c;
            pInfo.pat_dob = pat.pat_dob_gne__c;
           	
           	if (pat.pat_dob_gne__c == null)
            {
                throw new GNE_PatPers_Exception('URGENT: PLEASE SUPPLY A VALID PATIENT DATE OF BIRTH !!!');
            }
           	else
           	{
           		pInfo.pat_Age = pat.Age_gne__c;
           	}
           	/* 04/03/2015 corrected age mapping
           	if (pat.pat_dob_gne__c != null)
           	{
            	Integer months = pat.pat_dob_gne__c.monthsBetween(System.today());
            	Double years = (months / 12); 
            	pInfo.pat_Age = years;
            }
            else
            pInfo.pat_Age = 18; 
			*/

            //added check SKM 12/23/09   
            if(patAddr!=null)
            {     
	            pInfo.pat_address_line_1 = patAddr.Address_Line_1_gne__c;
	            pInfo.pat_address_line_2 = patAddr.Address_Line_2_gne__c;
	            pInfo.pat_city = patAddr.City_gne__c;
	            pInfo.pat_country = patAddr.Country_gne__c;
	            pInfo.pat_state =  patAddr.State_gne__c;
	            pInfo.pat_zip = patAddr.Zip_gne__c;        

            }
			/// old code was cut from here.  obfuscated - 04012009 - jw      
            // based on age, set the minor fields if required.  < 18
            // we also need to respecify the patient first and last name and get from the patient contact object          
            if (pInfo.pat_Age < 18.0) 
            {       
            
                Patient_Contact_gne__c[] cont = [select Country_gne__c,First_Name_gne__c,Id,LAST_NAME_CONT_gne__c,
                    pat_con_City_gne__c, pat_con_Email_gne__c,pat_con_Home_Phone_gne__c,pat_con_Mail_Box_gne__c,
                    pat_con_Prefix_gne__c,pat_con_State_gne__c, pat_con_Street_gne__c, pat_con_Work_gne__c, 
                    pat_con_Zip_gne__c, pat_con_Relationship_to_Patient_gne__c 
                FROM Patient_Contact_gne__c
                WHERE pat_con_Patient_gne__c =:patientID 
                ORDER BY systemModstamp DESC  LIMIT 1];
            
                if ((cont != null) && (cont.size() >= 1))
                {
                    pInfo.pat_minor_first_name = pat.pat_first_name_gne__c;
                    pInfo.pat_minor_last_name = pat.Name;
                    pInfo.pat_minor_middle_name = pat.Mid_Initial_gne__c;
           
                    pInfo.pat_first_name = cont[0].first_name_gne__c;
                    pInfo.pat_mid_initial = '';
                    pInfo.pat_last_name = cont[0].last_name_cont_gne__c;
                    pInfo.pat_prefix = cont[0].pat_con_prefix_gne__c;
                    pInfo.pat_suffix = ''; 
                    pInfo.pat_address_line_1 = cont[0].pat_con_Street_gne__c;
                    pInfo.pat_address_line_2 = cont[0].pat_con_Mail_Box_gne__c;
                    pInfo.pat_city = cont[0].pat_con_city_gne__c;
                    pInfo.pat_country = cont[0].Country_gne__c;
                    pInfo.pat_state =  cont[0].pat_con_State_gne__c;
                    pInfo.pat_zip = cont[0].pat_con_Zip_gne__c;
                    pInfo.pat_home_phone = cont[0].pat_con_Home_Phone_gne__c;
                    pInfo.pat_email_gne = cont[0].pat_con_email_gne__c;
                    pInfo.pat_work_phone = cont[0].pat_con_work_gne__c;  
                    pInfo.pat_con_Relationship_to_Patient = cont[0].pat_con_Relationship_to_Patient_gne__c;   
                } // size >= 0
                else
                  throw new GNE_PatPers_Exception('URGENT: IF THE PATIENT AGE IS LESS THAN 18 YEARS, A PATIENT CONTACT RECORD SPECIFYING ALTERNATE CONTACTS IS REQUIRED !!!');
                
            }
        }
        return pInfo;
    }

/**
    public Medical_history_gne__c getMedicalHistory(String patientID)
    {
        try {
        Medical_history_gne__c[] hist = [select ID, Date_of_Diagnosis_gne__c,
                            Tumor_Staging_gne__c,Previous_Therapy_Regimens_gne__c,
                            Concurrent_Therapy_Regimens_gne__c,Therapy_Sequence_gne__c,
                            Metastatic_Sites_gne__c,
                            Her2_Test_gne__c,Adjuvant_gne__c,ICD9_Code_1_gne__r.icd9_code_gne__c,
                            ICD9_Code_2_gne__r.icd9_code_gne__c,ICD9_Code_1_gne__r.Name,
                            ICD9_Code_2_gne__r.Name,Eye_Affected_gne__c,
                            Current_Rtx_Tx_Course_gne__c,ICD9_Code_1_gne__c,
                            Eye_Being_Treated_gne__c,VA_eye_being_treated_gne__c,
                            Ancillary_Supplies_gne__c,Freqcy_of_Admin_gne__c,
                            therapy_type_gne__c,FEV1_gne__c,ICD9_Code_2_gne__c,Drug_gne__c,
                            Needle_Size_gne__c,Dilute_with_ml_gne__c,Dosage_mg_gne__c,
                            Dose_per_Inj_ml_gne__c,Dose_mg_kg_wk_gne__c, Treatment_Date_gne__c,
                            Date_of_first_treatment_gne__c, Date_Therapy_Initiated_gne__c
        FROM Medical_history_gne__c
        WHERE Patient_Med_Hist_gne__r.ID = :patientID
        ORDER BY SystemModstamp DESC LIMIT 1];
        if (hist.size() == 0)
           throw new GNE_PatPers_Exception('URGENT: MEDICAL HISTORY FOR THIS PATIENT IS REQUIRED !!!');
           else
           return hist[0];
        }
        catch (Exception ex)
        {
            throw new GNE_PatPers_Exception('URGENT: MEDICAL HISTORY FOR THIS PATIENT IS REQUIRED !!!');
        }
        return null;
    } 
   **/
    
    public Transaction_File_Staging_gne__c getTransactionFileStagingRecord(String codeID)
    {
        try
        {
        Transaction_File_Staging_gne__c[] transList = [Select t.Address_Line_1_gne__c, t.Address_Line_2_gne__c, 
                            t.Age_gne__c, t.City_gne__c, t.Country_gne__c, 
                            t.dob_gne__c, t.fax_gne__c, t.First_Name_gne__c, t.Id, t.Last_Name_gne__c, 
                            t.ME_Number_gne__c, t.Middle_Initial_gne__c, t.Minor_First_Name_gne__c, 
                            t.Minor_Last_Name_gne__c, t.Minor_Middle_Name_gne__c, t.Name, t.pat_email_gne__c, 
                            t.Pat_gender_gne__c, t.Pat_Home_Phone_gne__c, t.Pat_Work_Phone_gne__c, 
                            t.Patient_Program_gne__c, t.Practice_Name_gne__c, t.Prefix_gne__c, t.Product_gne__c, 
                            t.RAPTIVA_GSK_INDICATOR_gne__c, t.Segment_ID_gne__c, t.State_gne__c, t.Suffix_gne__c, 
                            t.Transaction_ID_gne__c, t.Treatment_Date_gne__c, t.Zip_gne__c from Transaction_File_Staging_gne__c t
                    WHERE t.Id = :codeID];
                
            if (transList.size() < 1)
            {    
                return null;
            }
           return transList[0];    
        }
        catch (Exception ex)
        {
            throw new GNE_PatPers_Exception('URGENT: COULD NOT RETRIEVE TRANSACTION FILE !!!');
        }
        
        
       return null;    
    }


}