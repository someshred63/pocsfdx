public class SCM_MF_EnrollmentFactory {
    private static SCM_MergeField createMergeField(String key){
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        return mf;
    }
    
    private static Medical_History_gne__c medHistory;
    private static Boolean queried = false;
    private static List<ProfileID_License_gne__c> profileList;
    
    private static void initMedHistory(Case selectedCase) {
        try {
            if (!queried) {
                List<Medical_History_gne__c> medHistoryList = [Select m.medhis_VA_Eye_Being_Treated2_gne__c, 
                    m.X25_mg_Qty_gne__c, m.X150_mg_Qty_gne__c, m.X100_mg_Qty_gne__c, 
                    m.With_Needles_gne__c, m.Weekly_Dose_ml_gne__c, m.Weekly_Dose_mg_gne__c, 
                    m.Vial_Size_gne__c, m.Vial_Qty_gne__c, m.VA_eye_being_treated_gne__c, m.Use_gne__c, 
                    m.Units_Billed_gne__c, m.Type_of_Psoriasis_gne__c, m.Tumor_Staging_gne__c, 
                    m.Treatment_Location_gne__c, m.Treatment_Date_gne__c, 
                    m.Total_Mg_Used_gne__c, m.Total_Cholesterol_gne__c, m.Time_Patient_Observed_gne__c, 
                    m.Thyroid_Type_gne__c, m.Thyroid_Function_gne__c, m.Therapy_Type_gne__c, 
                    m.Therapy_Sequence_gne__c, m.Tests_gne__c, m.Tests_Other_gne__c, 
                    m.Tarceva_Rx_Filled_gne__c, m.Tanner_Stage_gne__c, m.TNM_Staging_gne__c, 
                    m.SystemModstamp, m.Study_Site_gne__c, m.Site_Number_gne__c, 
                    m.Significant_Symptoms_gne__c, m.Sig_Mg_SubQ_gne__c, m.Ship_To_gne__c, 
                    m.Severity_Psoriasis_gne__c, m.SPOC_Referred_Patient_gne__c, 
                    m.SMN_Expiration_Date_gne__c, m.SMN_Expiration_Calc_gne__c, 
                    m.SMN_Effective_Date_gne__c, m.Rx_Expiration_gne__c, 
                    m.Rx_Effective_Date_gne__c, m.Rx_Date_gne__c, m.Route_of_Admin_gne__c, 
                    m.Reviewed_By_gne__c, m.Retest_Assay_Test_Used_gne__c, m.Retest_Assay_Test_Result_gne__c, 
                    m.Retest_Assay_Test_Date_gne__c, m.Release_gne__c, m.Refill_times_gne__c, 
                    m.Refill_Through_Date_gne__c, m.RefillX_PRN_gne__c, m.RecordTypeId, 
                    m.Reason_Rx_Not_Filled_gne__c, m.Reason_Original_Discontinuane_Other_gne__c, 
                    m.Reason_Original_Discontinuance_gne__c, m.Quantity_of_500mg_Vials_gne__c, m.Quantity_of_100mg_Vials_gne__c, 
                    m.Quality_of_Life_Questionaire_gne__c, m.Prophylaxis_gne__c, m.Product_gne__c, 
                    m.Prior_Treatments_gne__c, m.Prior_Treatments_Others_gne__c, m.Prior_Thrombolytic_Agents_Used_gne__c, 
                    m.Previous_Tx_Current_Eye_gne__c, m.Previous_Tx_Current_Eye_Other_gne__c, 
                    m.Previous_Therapy_Regimens_gne__c, m.Previous_Other_gne__c, m.Prescription_Type_gne__c, 
                    m.Preferred_Thrombolytic_gne__c, m.Predicted_Adult_Height_gne__c, m.Place_of_Administration_gne__c, 
                    m.Phone_gne__c, m.Percentile_gne__c, m.Patient_Weight_kg_gne__c, m.Patient_Weight_Percentile_gne__c, 
                    m.Patient_Weight_Date_gne__c, m.Patient_Med_Hist_gne__c, m.Patient_Height_gne__c, 
                    m.Patient_Height_Percentile_gne__c, m.PR_Status_gne__c, m.PASI_gne__c, m.OwnerId, m.Outcome_gne__c, 
                    m.Others_LUC_gne__c, m.Other_Type_Infusion_Center_gne__c, m.Other_Therapies_gne__c, 
                    m.Other_Psoriasis_gne__c, m.Other_ICD9_Description_gne__c, m.Other_ICD9_Code_gne__c, 
                    m.Other_Asthma_Therapies_gne__c, m.Or_years_with_psoriasis_gne__c, m.Onset_gne__c, 
                    m.Number_of_Refills_gne__c, m.Number_of_Doses_gne__c, m.Number_Syringes_Dispense_gne__c, 
                    m.Number_Doses_Status_gne__c, m.Next_Clinic_Date_gne__c, m.New_to_GNE_Date_gne__c, 
                    m.Needle_Size_gne__c, m.Name, m.NKDA_gne__c, m.Metastatic_Sites_gne__c, 
                    m.Medical_Rationale_gne__c, m.Medical_Justification_gne__c, m.Medical_Justification_Others_gne__c, 
                    m.Medical_Assessment_gne__c, m.MayEdit, m.Maint_Dose_mg_gne__c, m.Maint_Dose_Units_Billed_gne__c, 
                    m.MRI_CT_Results_gne__c, m.Loading_Dose_mg_gne__c, m.Loading_Dose_Units_Billed_gne__c, 
                    m.Lipid_Results_gne__c, m.Lesion_Type_gne__c, m.Lesion_Size_gne__c, m.Lesion_Size_Is_gne__c, 
                    m.Lesion_Position_gne__c, m.LastModifiedDate, m.LastModifiedById, m.LastActivityDate, m.Karyotype_Results_gne__c, 
                    m.IsLocked, m.IsDeleted, m.Investigator_Sponsored_Trial_GATCF_gne__c, m.Injs_per_week_gne__c, 
                    m.Injection_Device_gne__c, m.Infuse_mg_Day1_Day15_gne__c, m.Infuse_Other_gne__c, m.Impact_on_Life_gne__c, 
                    m.IgE_Test_Results_IU_ml_gne__c, m.IgE_Test_Date_gne__c, m.Id, m.IWF_gne__c, m.IST_Study_Number_gne__c, 
                    m.IGF_1_Level_gne__c, m.IGFBP_3_gne__c, m.ICD9_Code_3_gne__c, m.ICD9_Code_2_gne__c, m.ICD9_Code_1_gne__c, 
                    m.History_of_Positive_or_RAST_Test_gne__c, m.Her2_Test_gne__c, m.HDL_LDL_gne__c, m.Growth_Velocity_cm_yr_gne__c, 
                    m.GH_Stim_Test_gne__c, m.GATCF_SMN_Expiration_Date_gne__c, m.GATCF_Other_gne__c, m.GATCF_Letter_Date_gne__c, 
                    m.Freqcy_of_Admin_gne__c, m.First_Assay_Test_Used_gne__c, m.First_Assay_Test_Result_gne__c, 
                    m.First_Assay_Test_Date_gne__c, m.FEV1_gne__c, m.Eye_Being_Treated_gne__c, m.Eye_Affected_gne__c, 
                    m.Estimated_Duration_gne__c, m.ER_Status_gne__c, m.EGF_Status_gne__c, m.EGFR_Results_gne__c, 
                    m.Dwell_Time_gne__c, m.Duration_of_Therapy_gne__c, m.Dt_of_1st_Trtmt_for_Current_Course_gne__c, 
                    m.Dt_Pt_Last_Seen_gne__c, m.Drug_gne__c, m.Drug_Substitution_Allowed_gne__c, m.Drug_Allergies_gne__c, 
                    m.Dose_per_Inj_ml_gne__c, m.Dose_mg_kg_wk_gne__c, m.Dose_Modification_gne__c, m.Dose_Frequency_in_weeks_gne__c, 
                    m.Dosage_mg_kg_gne__c, m.Dosage_mg_gne__c, m.Dosage_Regimen_gne__c, m.Dosage_Infused_mg_gne__c, 
                    m.Dispense_month_supply_gne__c, m.Dispense_gne__c, m.Dispense_Reconstitution_Syringes_gne__c, 
                    m.Dispense_Months_gne__c, m.Disease_Caracteristics_gne__c, m.Discontinue_Tx_Date_gne__c, 
                    m.Dilute_with_ml_gne__c, m.Describe_gne__c, m.Declotting_gne__c, m.Date_of_First_Treatment_gne__c, 
                    m.Date_of_Diagnosis_gne__c, m.Date_Therapy_Initiated_gne__c, m.Date_Reviewed_gne__c, 
                    m.Date_Pulmozyme_Discontinued_gne__c, m.Date_First_Treatment_Status_gne__c, m.DEXA_Scan_gne__c, 
                    m.Current_Treatment_gne__c, m.Current_Rtx_Tx_Course_gne__c, 
                    m.CreatedDate, m.CreatedById, m.Counter_gne__c, m.Coordinator_gne__c, 
                    m.Concurrent_Therapy_gne__c, m.Concurrent_Therapy_Regimens_gne__c, m.Concurrent_Other_gne__c, 
                    m.Concurrent_Medications_gne__c, m.Concurrent_Medications_TNK_gne__c, 
                    m.Concomitant_Therapies_gne__c, m.Concomitant_Medications_gne__c, m.Clinical_Trial_gne__c, 
                    m.Clinical_Trial_Name_gne__c, m.Clinical_Trial_End_Date_gne__c, m.Clinical_Impressions_gne__c, 
                    m.Chronological_Age_years_gne__c, m.CMA_Expiration_Date_gne__c, m.CD_20_Tests_gne__c, 
                    m.Bone_Age_gne__c, m.Bone_Age_Date_Performed_gne__c, m.Body_Surface_Area_gne__c, m.Body_Diagram_gne__c, 
                    m.Ancillary_Supplies_gne__c, m.Alt_Infusion_Center_gne__c, m.Aliquot_gne__c, m.Agent_2_gne__c, 
                    m.Agent_2_Peak_Response_gne__c, m.Agent_2_Date_gne__c, m.Agent_1_gne__c, m.Agent_1_Date_gne__c, 
                    m.Agent1_Peak_Response_gne__c, m.Admission_Date_gne__c, m.Adjuvant_gne__c 
                    From Medical_History_gne__c m
                    Where m.Id =: selectedCase.Medical_History_gne__c limit 1];
                    
                    queried = true;
                
                if (!medHistoryList.isEmpty())
                    medHistory = medHistoryList[0];
            }
        }
        catch (Exception e) {
            medHistory = null;
        }
    }
    
    private static String getICD9Detail(String ICD9Code, String returnType) { //returnType = 'Code' or 'Description'
        try {
            List<ICD9_Code_gne__c> icd9List = [Select i.ICD9_Descrption_gne__c, i.ICD9_Code_gne__c 
                From ICD9_Code_gne__c i
                Where i.Id =: ICD9Code];
                
            if (!icd9List.isEmpty()) {
                String code = icd9List[0].ICD9_Code_gne__c;
                String descr = icd9List[0].ICD9_Descrption_gne__c;
                
                if (code == null)
                    code = '';
                if (descr == null)
                    descr = '';
                
                if (returnType.equals('Code'))
                    return code;
                else if (returnType.equals('Description'))
                    return descr;
                else
                    return '';    
            }
            else {
                return '';
            }
        }
        catch (Exception e) {
            return '';
        }
    }
    
    private static void initProfileList(String physicianId) {
        if (profileList == null) {
            try {
                profileList = [Select p.ID_License_gne__c, p.ID_License_Type_gne__c, 
                    p.Account_Name_gne__c 
                    From ProfileID_License_gne__c p
                    Where p.Account_Name_gne__c =: physicianId
                    And p.ID_License_Type_gne__c != null
                    Order By p.LastModifiedDate desc Limit 500];
            }
            catch (Exception e) {
                profileList = new List<ProfileID_License_gne__c>();
            }       
        }
    }
    
    public static SCM_MergeField MedicareNum(String physicianId) {
        SCM_MergeField mf = createMergeField('MedicareNum');
        mf.fieldValue = '';
        initProfileList(physicianId);
        if (!profileList.isEmpty()) {
            for (ProfileID_License_gne__c profile : profileList) {
                if (profile.ID_License_Type_gne__c.equals('Medicare #')) {
                    mf.fieldValue = profile.ID_License_gne__c;
                    break; 
                }
            }
        }
        
        if (mf.fieldValue == null)
            mf.fieldValue = '';
        return mf;
        
    }

    public static SCM_MergeField MedicaidNum(String physicianId) {
        SCM_MergeField mf = createMergeField('MedicaidNum');
        mf.fieldValue = '';
        initProfileList(physicianId);
        if (!profileList.isEmpty()) {
            for (ProfileID_License_gne__c profile : profileList) {
                if (profile.ID_License_Type_gne__c.equals('State Medicaid ID')) {
                    mf.fieldValue = profile.ID_License_gne__c;
                    break; 
                }
            }
        }
        
        if (mf.fieldValue == null)
            mf.fieldValue = '';
        return mf;
        
    }
    
    public static SCM_MergeField BlueCrossBlueShieldNum(String physicianId) {
        SCM_MergeField mf = createMergeField('BlueCrossBlueShieldNum');
        mf.fieldValue = '';
        initProfileList(physicianId);
        if (!profileList.isEmpty()) {
            for (ProfileID_License_gne__c profile : profileList) {
                if (profile.ID_License_Type_gne__c.equals('BC/BS ID')) {
                    mf.fieldValue = profile.ID_License_gne__c;
                    break; 
                }
            }
        }
        
        if (mf.fieldValue == null)
            mf.fieldValue = '';
        return mf;
        
    }

    public static SCM_MergeField ClinicalTrialPatientY(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ClinicalTrialPatientY');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Clinical_Trial_Name_gne__c;
            if (val != null)
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        
        return mf;
    }

    public static SCM_MergeField ClinicalTrialPatientN(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ClinicalTrialPatientN');
        mf.fieldValue = SCM_CheckBox_Values.Checked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Clinical_Trial_Name_gne__c;
            if (val != null)
                mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        }
        
        return mf;
    }

    public static SCM_MergeField StudySite(Case selectedCase) {
        SCM_MergeField mf = createMergeField('StudySite');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Study_Site_gne__c;
            if (val != null)
                mf.fieldValue = val;
        }
        
        return mf;
    }

    public static SCM_MergeField StudyNum(Case selectedCase) {
        SCM_MergeField mf = createMergeField('StudyNum');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Site_Number_gne__c;
            if (val != null)
                mf.fieldValue = val;
        }
        
        return mf;
    }

    public static SCM_MergeField ClinicalCoordinator(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ClinicalCoordinator');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Coordinator_gne__c;
            if (val != null)
                mf.fieldValue = val;
        }
        
        return mf;
    }

    public static SCM_MergeField ClinicalCoordPhone(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ClinicalCoordPhone');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Phone_gne__c;
            if (val != null)
                mf.fieldValue = val;
        }
        
        return mf;
    }

    public static SCM_MergeField ICD9Code(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ICD9Code');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.ICD9_Code_1_gne__c;
            if (val != null)
                mf.fieldValue = getICD9Detail(val, 'Code');
        }
        
        return mf;
    }
    
    public static SCM_MergeField ICD9Desc(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ICD9Desc');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.ICD9_Code_1_gne__c;
            if (val != null)
                mf.fieldValue = getICD9Detail(val, 'Description');
        }
        
        return mf;
    }

    public static SCM_MergeField ICD9Code2(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ICD9Code2');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.ICD9_Code_2_gne__c;
            if (val != null)
                mf.fieldValue = getICD9Detail(val, 'Code');
        }       
        return mf;
    }
    
    public static SCM_MergeField ICD9Desc2(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ICD9Desc2');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.ICD9_Code_2_gne__c;
            if (val != null)
                mf.fieldValue = getICD9Detail(val, 'Description');
        }
        
        return mf;
    }

    public static SCM_MergeField DateOfDx(Case selectedCase) {
        SCM_MergeField mf = createMergeField('DateOfDx');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            Date val = medHistory.Date_of_Diagnosis_gne__c;
            if (val != null)
                mf.fieldValue = val.format();
        }       
        
        return mf;
    }

    public static SCM_MergeField Height(Case selectedCase) {
        SCM_MergeField mf = createMergeField('Height');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            Double val = medHistory.Patient_Height_gne__c;
            if (val != null)
                mf.fieldValue = val + '';
        }       
        
        return mf;
    }
    
    public static SCM_MergeField Weight(Case selectedCase) {
        SCM_MergeField mf = createMergeField('Weight');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            Double val = medHistory.Patient_Weight_kg_gne__c;
            if (val != null)
                mf.fieldValue = val + '';
        }       
        
        return mf;
    }

    public static SCM_MergeField TNM0(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TNM0');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.TNM_Staging_gne__c;
            if (val != null && val.equals('Stage 0'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }
    public static SCM_MergeField TNMI(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TNMI');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.TNM_Staging_gne__c;
            if (val != null && val.equals('Stage I (Early Local Disease)'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }
    
    
    public static SCM_MergeField TNMIIA(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TNMIIA');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.TNM_Staging_gne__c;
            if (val != null && val.equals('Stage IIA (Early Local Disease)'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField TNMIIB(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TNMIIB');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.TNM_Staging_gne__c;
            if (val != null && val.equals('Stage IIB (Early Local Disease)'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField TNMIIIA(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TNMIIIA');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.TNM_Staging_gne__c;
            if (val != null && val.equals('Stage IIIA (Advanced Local Disease)'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField TNMIIIB(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TNMIIIB');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.TNM_Staging_gne__c;
            if (val != null && val.equals('Stage IIIB (Advanced Local Disease)'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField TNMIIIC(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TNMIIIC');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.TNM_Staging_gne__c;
            if (val != null && val.equals('Stage IIIC (Advanced Local Disease)'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField TNMIV(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TNMIV');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.TNM_Staging_gne__c;
            if (val != null && val.equals('Stage IV (Advanced Metastatic Disease)'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField MSAdrenals(Case selectedCase) {
        SCM_MergeField mf = createMergeField('MSAdrenals');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Metastatic_Sites_gne__c;
            if (val != null && val.equals('Adrenals'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField MSBrain(Case selectedCase) {
        SCM_MergeField mf = createMergeField('MSBrain');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Metastatic_Sites_gne__c;
            if (val != null && val.contains('Brain'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }
    
    public static SCM_MergeField MSBone(Case selectedCase) {
        SCM_MergeField mf = createMergeField('MSBone');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Metastatic_Sites_gne__c;
            if (val != null && val.contains('Bone'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }    

    public static SCM_MergeField MSLiver(Case selectedCase) {
        SCM_MergeField mf = createMergeField('MSLiver');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Metastatic_Sites_gne__c;
            if (val != null && val.contains('Liver'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }
    
    public static SCM_MergeField MSLung(Case selectedCase) {
        SCM_MergeField mf = createMergeField('MSLung');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Metastatic_Sites_gne__c;
            if (val != null && val.contains('Lung'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }
    
    public static SCM_MergeField MSLymph(Case selectedCase) {
        SCM_MergeField mf = createMergeField('MSLymph');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Metastatic_Sites_gne__c;
            if (val != null && val.contains('Lymphnodes'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField MSOvaries(Case selectedCase) {
        SCM_MergeField mf = createMergeField('MSOvaries');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Metastatic_Sites_gne__c;
            if (val != null && val.contains('Ovaries'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }
    
    public static SCM_MergeField MSPeritoneal(Case selectedCase) {
        SCM_MergeField mf = createMergeField('MSPeritoneal');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Metastatic_Sites_gne__c;
            if (val != null && val.contains('Peritoneal Cavity'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField PTNone(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTNone');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.contains('None'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }

    public static SCM_MergeField PTBoneMT(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTBoneMT');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.contains('Bone Marrow Transplant'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       
        
        return mf;
    }        

    public static SCM_MergeField PTChemo(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTChemo');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.contains('Chemotherapy'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }       

        return mf;
    }
    
    public static SCM_MergeField PTImmuno(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTImmuno');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.contains('Immunotherapy'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        
        return mf;
    }

    public static SCM_MergeField PTRadiation(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTRadiation');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.contains('Radiation'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        
        return mf;
    }
    
        public static SCM_MergeField PTHormone(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTHormone');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.contains('Hormone Therapy'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        
        return mf;
    }
    
    
    
    public static SCM_MergeField PTOther(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTOther');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.contains('Other'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        
        return mf;
    }

    public static SCM_MergeField PTOtherText(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTOtherText');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Other_gne__c;
            if (val != null)
                mf.fieldValue = val;
        }
        
        return mf;
    }
  
    public static SCM_MergeField PTRadioLA(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTRadioLA');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.contains('Radio Labeled Antibodies'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }

        return mf;
    }

    public static SCM_MergeField PTSurgery(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PTSurgery');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Previous_Therapy_Regimens_gne__c;
            if (val != null && val.equals('Surgery'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }

        return mf;
    }
    
    public static SCM_MergeField PoAPhysician(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PoAPhysician');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Place_of_Administration_gne__c;
            if (val != null && val.equals('MD Office / Clinic'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        
        return mf;
    }
    
    public static SCM_MergeField PoAHospOut(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PoAHospOut');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Place_of_Administration_gne__c;
            if (val != null && val.equals('Hospital Outpatient'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        
        return mf;
    }

    public static SCM_MergeField PoAHospIn(Case selectedCase) {
        SCM_MergeField mf = createMergeField('PoAHospIn');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            String val = medHistory.Place_of_Administration_gne__c;
            if (val != null && val.equals('Hospital Inpatient'))
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        
        return mf;
    }
    
    public static SCM_MergeField TreatStartY(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TreatStartY');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            Date val = medHistory.Dt_of_1st_Trtmt_for_Current_Course_gne__c;
            if (val != null)
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        return mf;
    }
    
    public static SCM_MergeField TreatStartN(Case selectedCase) {
        SCM_MergeField mf = createMergeField('TreatStartN');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);

        if (medHistory != null) {
            Date val = medHistory.Dt_of_1st_Trtmt_for_Current_Course_gne__c;
            if (val == null)
                mf.fieldValue = SCM_CheckBox_Values.Checked;
        }
        return mf;
    }                

    public static SCM_MergeField DateFirstTreatment(Case selectedCase) {
        SCM_MergeField mf = createMergeField('DateFirstTreatment');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            Date val = medHistory.Date_of_First_Treatment_gne__c;
            if (val != null)
                mf.fieldValue = val.format();
        }
        return mf;
    }                

    public static SCM_MergeField DateofTreatment(Case selectedCase) {
        SCM_MergeField mf = createMergeField('DateofTreatment');
        mf.fieldValue = '';
        initMedHistory(selectedCase);

        if (medHistory != null) {
            Date val = medHistory.Treatment_Date_gne__c;
            if (val != null)
                mf.fieldValue = val.format();
        }
        return mf;
    }                

    public static SCM_MergeField HER2StatusN(Case selectedCase) {
        SCM_MergeField mf = createMergeField('HER2StatusN');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Herceptin')) {
            if (medHistory != null) {
                String val = medHistory.Her2_Test_gne__c;
                if (val != null && val.contains('Negative'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        } 
                
        return mf;
    }
    
    public static SCM_MergeField HER2StatusP(Case selectedCase) {
        SCM_MergeField mf = createMergeField('HER2StatusP');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Herceptin')) {
            if (medHistory != null) {
                String val = medHistory.Her2_Test_gne__c;
                if (val != null && val.contains('Positive'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }       
        
        return mf;
    }
    
    public static SCM_MergeField HER2TestMDakoIHC(Case selectedCase) {
        SCM_MergeField mf = createMergeField('HER2TestMDakoIHC');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Herceptin')) {
            if (medHistory != null) {
                String val = medHistory.First_Assay_Test_Used_gne__c;
                if (val != null && val.contains('Dako IHC'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }       
        return mf;
    }
    
    public static SCM_MergeField HER2TestMOtherIHC(Case selectedCase) {
        SCM_MergeField mf = createMergeField('HER2TestMOtherIHC');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Herceptin')) {
            if (medHistory != null) {
                String val = medHistory.First_Assay_Test_Used_gne__c;
                if (val != null && val.contains('Other IHC'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }
        
        return mf;
    }
    
    public static SCM_MergeField HER2TestMFISH(Case selectedCase) {
        SCM_MergeField mf = createMergeField('HER2TestMFISH');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Herceptin')) {
            if (medHistory != null) {
                String val = medHistory.First_Assay_Test_Used_gne__c;
                if (val != null && val.contains('FISH'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }
                
        return mf;
    }

    public static SCM_MergeField AdjuvantYes(Case selectedCase) {
        SCM_MergeField mf = createMergeField('AdjuvantYes');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Herceptin')) {
            if (medHistory != null) {
                String val = medHistory.Adjuvant_gne__c;
                if (val != null && val.contains('Yes'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }
                
        return mf;
    }

    public static SCM_MergeField AdjuvantNo(Case selectedCase) {
        SCM_MergeField mf = createMergeField('AdjuvantNo');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Herceptin')) {
            if (medHistory != null) {
                String val = medHistory.Adjuvant_gne__c;
                if (val != null && val.contains('Yes'))
                    mf.fieldValue = SCM_CheckBox_Values.Unchecked;
                else if (val != null && val.contains('No'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }
                
        return mf;
    }
    
    public static SCM_MergeField RIT_DiseaseCharLow(Case selectedCase) {
        SCM_MergeField mf = createMergeField('RIT_DiseaseCharLow');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Rituxan')) {
            if (medHistory != null) {
                String val = medHistory.Disease_Caracteristics_gne__c;
                if (val != null && val.contains('Low Grade'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }
                
        return mf;
    }
    
    public static SCM_MergeField RIT_DiseaseCharDiffuse(Case selectedCase) {
        SCM_MergeField mf = createMergeField('RIT_DiseaseCharDiffuse');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Rituxan')) {
            if (medHistory != null) {
                String val = medHistory.Disease_Caracteristics_gne__c;
                if (val != null && val.contains('Diffuse / Poorly Differntted'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }       
        
        return mf;
    }
    
    public static SCM_MergeField RIT_DiseaseCharRefractory(Case selectedCase) {
        SCM_MergeField mf = createMergeField('RIT_DiseaseCharRefractory');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Rituxan')) {
            if (medHistory != null) {
                String val = medHistory.Disease_Caracteristics_gne__c;
                if (val != null && val.contains('Refractory'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }       
        return mf;
    }
    
    public static SCM_MergeField RIT_DiseaseCharFollicular(Case selectedCase) {
        SCM_MergeField mf = createMergeField('RIT_DiseaseCharFollicular');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Rituxan')) {
            if (medHistory != null) {
                String val = medHistory.Disease_Caracteristics_gne__c;
                if (val != null && val.contains('Follicular / Nodular'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }
        
        return mf;
    }
    
    public static SCM_MergeField RIT_DiseaseCharCD20(Case selectedCase) {
        SCM_MergeField mf = createMergeField('RIT_DiseaseCharCD20');
        mf.fieldValue = SCM_CheckBox_Values.Unchecked;
        initMedHistory(selectedCase);
        String product = selectedCase.Product_gne__c;

        if (product != null && product.equals('Rituxan')) {
            if (medHistory != null) {
                String val = medHistory.CD_20_Tests_gne__c;
                if (val != null && val.contains('Positive'))
                    mf.fieldValue = SCM_CheckBox_Values.Checked;
            }
        }
        
        return mf;
    }
     
}