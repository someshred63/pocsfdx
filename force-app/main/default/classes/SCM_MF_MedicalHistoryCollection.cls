// Added By: Deepak Yadav
// Collection class for Medical history table
public virtual class SCM_MF_MedicalHistoryCollection  extends SCM_MergeField {
    
    protected Medical_History_gne__c medicalHistory;
    
    public SCM_MF_MedicalHistoryCollection(String medicalHistoryID){
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        
         List<Medical_History_gne__c> medicalHistoryList = [Select m.medhis_VA_Eye_Being_Treated2_gne__c,
                                                            m.X25_mg_Qty_gne__c, m.X150_mg_Qty_gne__c, 
                                                            m.X100_mg_Qty_gne__c, m.With_Needles_gne__c, 
                                                            m.Weekly_Dose_ml_gne__c, m.Weekly_Dose_mg_gne__c, 
                                                            m.Vial_Size_gne__c, m.Vial_Qty_gne__c, m.VA_eye_being_treated_gne__c, 
                                                            m.Use_gne__c, m.Units_Billed_gne__c, m.Type_of_Psoriasis_gne__c, 
                                                            m.Tumor_Staging_gne__c, m.Treatment_Location_gne__c, 
                                                            m.Treatment_Date_gne__c, m.Total_Mg_Used_gne__c, m.Total_Cholesterol_gne__c, 
                                                            m.Time_Patient_Observed_gne__c, m.Thyroid_Type_gne__c, m.Thyroid_Function_gne__c, 
                                                            m.Therapy_Type_gne__c, m.Therapy_Sequence_gne__c, m.Tests_gne__c, 
                                                            m.Tests_Other_gne__c, m.Tarceva_Rx_Filled_gne__c, m.Tanner_Stage_gne__c, 
                                                            m.TNM_Staging_gne__c, m.SystemModstamp, m.Study_Site_gne__c, 
                                                            m.Site_Number_gne__c, m.Significant_Symptoms_gne__c, m.Sig_Mg_SubQ_gne__c, 
                                                            m.Ship_To_gne__c, m.Severity_Psoriasis_gne__c, m.SPOC_Referred_Patient_gne__c, 
                                                            m.SMN_Expiration_Date_gne__c, m.SMN_Expiration_Calc_gne__c, 
                                                            m.SMN_Effective_Date_gne__c, m.Rx_Expiration_gne__c, m.Rx_Effective_Date_gne__c, 
                                                            m.Rx_Date_gne__c, m.Route_of_Admin_gne__c, m.Reviewed_By_gne__c, 
                                                            m.Retest_Assay_Test_Used_gne__c, m.Retest_Assay_Test_Result_gne__c, 
                                                            m.Retest_Assay_Test_Date_gne__c, m.Release_gne__c, m.Refill_times_gne__c, 
                                                            m.Refill_Through_Date_gne__c, m.RefillX_PRN_gne__c, m.RecordTypeId, m.Reason_Rx_Not_Filled_gne__c, 
                                                            m.Reason_Original_Discontinuane_Other_gne__c, m.Reason_Original_Discontinuance_gne__c, 
                                                            m.Quantity_of_500mg_Vials_gne__c, m.Quantity_of_100mg_Vials_gne__c, 
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
                                                            m.Needle_Size_gne__c, m.Name, m.NKDA_gne__c, m.Metastatic_Sites_gne__c, m.Medical_Rationale_gne__c, 
                                                            m.Medical_Justification_gne__c, m.Medical_Justification_Others_gne__c, m.Medical_Assessment_gne__c, 
                                                            m.MayEdit, m.Maint_Dose_mg_gne__c, m.Maint_Dose_Units_Billed_gne__c, m.MRI_CT_Results_gne__c, 
                                                            m.Loading_Dose_mg_gne__c, m.Loading_Dose_Units_Billed_gne__c, m.Lipid_Results_gne__c, 
                                                            m.Lesion_Type_gne__c, m.Lesion_Size_gne__c, m.Lesion_Size_Is_gne__c, m.Lesion_Position_gne__c, 
                                                            m.LastModifiedDate, m.LastModifiedById, m.LastActivityDate, m.Karyotype_Results_gne__c, m.IsLocked, 
                                                            m.IsDeleted, m.Investigator_Sponsored_Trial_GATCF_gne__c, m.Injs_per_week_gne__c,
                                                            m.Injection_Device_gne__c, m.Infuse_mg_Day1_Day15_gne__c, m.Infuse_Other_gne__c, 
                                                            m.Impact_on_Life_gne__c, m.IgE_Test_Results_IU_ml_gne__c, m.IgE_Test_Date_gne__c, m.Id, 
                                                            m.IWF_gne__c, m.IST_Study_Number_gne__c, m.IGF_1_Level_gne__c, m.IGFBP_3_gne__c, 
                                                            m.ICD9_Code_3_gne__c, m.ICD9_Code_2_gne__c, m.ICD9_Code_1_gne__c, 
                                                            m.History_of_Positive_or_RAST_Test_gne__c, m.Her2_Test_gne__c, m.HDL_LDL_gne__c, 
                                                            m.Growth_Velocity_cm_yr_gne__c, m.GH_Stim_Test_gne__c, m.GATCF_SMN_Expiration_Date_gne__c, 
                                                            m.GATCF_Other_gne__c, m.GATCF_Letter_Date_gne__c, m.Freqcy_of_Admin_gne__c, 
                                                            m.First_Assay_Test_Used_gne__c, m.First_Assay_Test_Result_gne__c, m.First_Assay_Test_Date_gne__c, 
                                                            m.FEV1_gne__c, m.Eye_Being_Treated_gne__c, m.Eye_Affected_gne__c, m.Estimated_Duration_gne__c, 
                                                            m.ER_Status_gne__c, m.EGF_Status_gne__c, m.EGFR_Results_gne__c, m.Dwell_Time_gne__c, 
                                                            m.Duration_of_Therapy_gne__c, m.Dt_of_1st_Trtmt_for_Current_Course_gne__c, 
                                                            m.Dt_Pt_Last_Seen_gne__c, m.Drug_gne__c, m.Drug_Substitution_Allowed_gne__c, 
                                                            m.Drug_Allergies_gne__c, m.Dose_per_Inj_ml_gne__c, m.Dose_mg_kg_wk_gne__c, 
                                                            m.Dose_Modification_gne__c, m.Dose_Frequency_in_weeks_gne__c, m.Dosage_mg_kg_gne__c, 
                                                            m.Dosage_mg_gne__c, m.Dosage_Regimen_gne__c, m.Dosage_Infused_mg_gne__c, 
                                                            m.Dispense_month_supply_gne__c, m.Dispense_gne__c, m.Dispense_Reconstitution_Syringes_gne__c, 
                                                            m.Dispense_Months_gne__c, m.Disease_Caracteristics_gne__c, m.Discontinue_Tx_Date_gne__c, 
                                                            m.Dilute_with_ml_gne__c, m.Describe_gne__c, m.Declotting_gne__c, m.Date_of_First_Treatment_gne__c, 
                                                            m.Date_of_Diagnosis_gne__c, m.Date_Therapy_Initiated_gne__c, m.Date_Reviewed_gne__c, 
                                                            m.Date_Pulmozyme_Discontinued_gne__c, m.Date_First_Treatment_Status_gne__c, m.DEXA_Scan_gne__c, 
                                                            m.Current_Treatment_gne__c, m.Current_Rtx_Tx_Course_gne__c, m.CreatedDate, m.CreatedById, 
                                                            m.Counter_gne__c, m.Coordinator_gne__c, m.Concurrent_Therapy_gne__c, 
                                                            m.Concurrent_Therapy_Regimens_gne__c, m.Concurrent_Other_gne__c, m.Concurrent_Medications_gne__c, 
                                                            m.Concurrent_Medications_TNK_gne__c, m.Concomitant_Therapies_gne__c, m.Concomitant_Medications_gne__c, 
                                                            m.Clinical_Trial_gne__c, m.Clinical_Trial_Name_gne__c, m.Clinical_Trial_End_Date_gne__c, 
                                                            m.Clinical_Impressions_gne__c, m.Chronological_Age_years_gne__c, m.CMA_Expiration_Date_gne__c, 
                                                            m.CD_20_Tests_gne__c, m.Bone_Age_gne__c, m.Bone_Age_Date_Performed_gne__c, 
                                                            m.Body_Surface_Area_gne__c, m.Body_Diagram_gne__c, m.Ancillary_Supplies_gne__c, 
                                                            m.Alt_Infusion_Center_gne__c, m.Aliquot_gne__c, m.Agent_2_gne__c, m.Agent_2_Peak_Response_gne__c, 
                                                            m.Agent_2_Date_gne__c, m.Agent_1_gne__c, m.Agent_1_Date_gne__c, m.Agent1_Peak_Response_gne__c, 
                                                            m.Admission_Date_gne__c, m.Adjuvant_gne__c From Medical_History_gne__c m 
                                                            where m.id=:medicalHistoryID];
                                                            

        if(medicalHistoryList.size() >=1) {
            medicalHistory = medicalHistoryList[0];
        }
        else {
            medicalHistory =null;
        }
        
        
                                                                        
        
    }


}