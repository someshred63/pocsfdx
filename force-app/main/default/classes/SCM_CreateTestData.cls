//@isTest 
public class SCM_CreateTestData {
    
    public static Case createRelatedItems(Case docCase)
    {  
         Account casePhysician;
         List<Account>accountList= [Select Id from Account where FirstName = 'PhysicianFirst' and LastName='PhysicianLast' limit 1];
         if(accountList.size()>0)
          casePhysician=accountList[0];
          
         if(casePhysician==null || casePhysician.Id==null)
         {
            String recordTypeProfessional=[select Id from recordtype where  Name='Professional_vod' limit 1].Id;
        
             casePhysician = new Account(
                                    FirstName = 'PhysicianFirst'
                                    //,FRM_Target_frm_gne__c
                                    ,LastName = 'PhysicianLast'
                                    ,MDMID_Status_gne__c='Active'
                                    ,Middle_Name_gne__pc='Middle'
                                    ,Professional_Type_gne__c='Medical Doctor'
                                    ,Primary_Contact_gne__pc = true 
                                    //,Profile_Preferences_gne__c
                                    ,RecordTypeId=recordTypeProfessional
                                    ,Services_Preferences_gne__c='Benefit Investigation'
                                    //, Services_Preferences_gne__pc
                                    , Specialties_gne__c='OPHTHALMOLOGY'
                                    //, Subspecialties_gne__c
                                    //, Suffix_gne__pc
                                    //, Title_gne__pc 
                                );
            insert casePhysician;
         }
        
        List<Contact> relatedContacts = new List<Contact>();
        
        relatedContacts=[Select Id from Contact where  HCP_gne__c=:casePhysician.Id];
        if(relatedContacts.size()==0)
        {
            String recordTypeAssocContact=[select Id from recordtype where  Name='Associated Contact Record Type'].Id;
        
        
            relatedContacts.add (new Contact
                                (
                                Contact_Type_gne__c='Individual'
                                , Fax='(434) 324-5324'
                                , FirstName='Fname'
                                , GATCF_Specific_gne__c=false
                                , HCP_gne__c=casePhysician.Id
                                , Primary_Contact_gne__c=true
                                , LastName='LName'
                                , Salutation='Mr'
                                , Legacy_Contact_ID_gne__c=0
                                , Phone='(434) 324-2342'
                                , Title='Mr'
                                )
                            );
        
        
            relatedContacts.add ( new Contact
                                (
                                Contact_Type_gne__c='Individual'
                                , Fax='(434) 324-2324'
                                , FirstName='Test'
                                , GATCF_Specific_gne__c=false
                                , HCP_gne__c=casePhysician.Id
                                , Primary_Contact_gne__c=false
                                , LastName='Contact'
                                , Salutation='Mr'
                                , Legacy_Contact_ID_gne__c=0
                                , Phone='(434) 324-2322'
                                , Title='Dr'
                                )
                            );
        
            insert relatedContacts;
        }
        
        Address_vod__c physicianAddress;
        List<Address_vod__c>addressList =[Select Id from Address_vod__c where Account_vod__c=:casePhysician.Id limit 1 ];
        if(addressList.size()>0)
            physicianAddress=addressList[0];
            
        if(physicianAddress==null || physicianAddress.Id==null)
        {
         physicianAddress = new Address_vod__c(
                                Account_vod__c = casePhysician.Id
                                ,Name='1234 Green Valley Rd'
                                , Address_line_2_vod__c =' Apt 345'
                                , City_vod__c = 'Atlanta'
                                , Country_gen__c='US'
                                , Fax_vod__c = '(865) 111-1235'
                                , Phone_vod__c = '(865) 111-1234'
                                , Phone_1_Ext_gne__c = '111'
                                , Offered_To_gne__c = 'Dr. Tony Tennessee'
                                , Source_vod__c = 'Manual'
                                , State_vod__c = 'GA'
                                , Service_Quality_Survey_Offered_Date_gne__c = Date.newinstance(2008,11,30)
                                , Primary_vod__c = true
                                , Choose_To_Take_Survey_gne__c ='No'
                                , Address_Type_gne__c='BUSINESS'
                                , Status_gne__c = 'Active'
                                , Zip_vod__c = '30301'
                                );
        insert physicianAddress;
        }
        
         Patient_gne__c casePatient;
         
         List<Patient_gne__c>patientList=[Select Id from Patient_gne__c where Name='TestPatient' limit 1];
         if(patientList.size()>0)
            casePatient=patientList[0];
            
         if(casePatient==null || casePatient.Id==null)
         {
         casePatient = new Patient_gne__c(
                                //LastName='TestPatientL',
                                //FirstName='TextPatientF',
                                //Date_of_Birth_gne__c='2/24/1985',
                                //Patient_ID_gne__c ='0099999999',
                                Counter_gne__c=0,
                                Eligible_for_Pulmozyme_Starter_gne__c='No',
                                Hearing_Impaired_gne__c='No',
                                Name='TestPatient',
                                Non_English_Speaking_gne__c='No',
                                PAN_Form_1_Expiration_Date_gne__c=date.newinstance(2010,1,31), 
                                PAN_Form_1_Product_gne__c='Lucentis',
                                PAN_Form_2_Exipration_Date_gne__c=date.newinstance(2010,1,31),
                                PAN_Form_2_Product_gne__c='Lucentis',
                                PAN_Form_2_Rec_gne__c=date.newinstance(2008,1,31),
                                PAN_Form_2_Signed_gne__c=date.newinstance(2008,1,31),
                                PAN_Form_Rec_gne__c=date.newinstance(2008,1,31),
                                PAN_Form_Signed_gne__c=date.newinstance(2008,5,12), 
                                //PAN_TAT_gne__c=187, 
                                pat_dob_gne__c=date.newinstance(1981,6,2),
                                pat_email_gne__c='testpatient@test.com',
                                pat_first_name_gne__c='fname', 
                                pat_gender_gne__c='Male', 
                                pat_home_phone_gne__c='(222) 222-2222', 
                                pat_income_gne__c=0, 
                                pat_other_phone_gne__c='(708) 555-5555', 
                                pat_other_phone_type_gne__c='Mobile', 
                                //pat_patient_deceased_gne__c, 
                                //pat_prefix_gne__c, 
                                pat_work_phone_gne__c='(708) 555-5555', 
                                //Patient_ID_gne__c='', 
                                //Patient_Name__c='<a href="/a0LS0000000B9ni" target="_self">abhay, G</a>', 
                                //Patient_Number_gne__c='PA00000157', 
                                //Preferred_Language_gne__c, 
                                //Release_gne__c, 
                                Service_Quality_gne__c='Accepted', 
                                Service_Quality_Offered_Date_gne__c=date.newinstance(2008,5,12), 
                                ssn_gne__c='111-11-1111', 
                                Status_Change_Date_gne__c=date.newinstance(2008,9,12), 
                                //Suffix_gne__c, 
                                Translator_Needed_gne__c='No'
                                //,Vendor_Case_ID_gne__c, 
                                //Web_Pat_ID_gne__c
                                );
        insert casePatient;
         }
         
         Patient_Address_gne__c casePatientAddress;
         List<Patient_Address_gne__c> patientAddressList= [Select Id from Patient_Address_gne__c where Patient_gne__c=:casePatient.Id];
         if(patientAddressList.size()>0)
            casePatientAddress=patientAddressList[0];
            
         if(casePatientAddress==null || casePatientAddress.Id==null)
         {
         casePatientAddress = new Patient_Address_gne__c(
                                 Address_Line_1_gne__c='1001 Main Street'
                               , Address_Line_2_gne__c=' Apt 345 '
                               , City_gne__c='San Mateo'
                               , Country_gne__c='USA'
                               , Other_Phone_gne__c='1234565333'
                               , Other_Phone_Type_gne__c='Mobile'
                               , Patient_gne__c=casePatient.Id
                               , Phone_gne__c='(999) 999-1234'
                               , Phone_Type_gne__c='Home'
                               , Primary_Address_gne__c='Yes'
                               //, Release_gne__c=
                               , State_gne__c='CA'
                               , Type_gne__c='Home'
                               , Zip_gne__c='99999'
                               
                               );
        insert casePatientAddress;
         }
//................................................     
         //Added By Sridhar
         Patient_Contact_gne__c patContact ;
         List<Patient_Contact_gne__c> patientContactList = [Select p.pat_con_Patient_gne__r.Patient_ID_gne__c, 
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
                                        p.pat_con_Patient_gne__c=:casePatient.Id 
                                  order by p.LastModifiedDate desc 
                                  LIMIT 500];

        if (patientContactList.size() > 0)
            patContact = patientContactList[0];
            
         if (patContact == null || patContact.Id == null) {
           
        
            patContact = new Patient_Contact_gne__c(
                pat_con_Patient_gne__c = casePatient.Id,
                First_Name_gne__c = 'Fname',
                LAST_NAME_CONT_gne__c = 'Lname',
                pat_con_Home_Phone_gne__c = '123456',
                pat_con_Work_gne__c = '654321',
                pat_con_Other_Phone_gne__c = '1212121', 
                pat_con_Relationship_to_Patient_gne__c = 'ABCRelashion'
                );

            //insert patContact ;
            DataBase.Saveresult result = DataBase.insert(patContact , true);
    }
    //.............................................................................
             
         //Added by Sanat
         ProfileID_License_gne__c caseProfileIdLicense;
         List<ProfileID_License_gne__c> profileIdList = [Select p.ID_License_gne__c, p.ID_License_Type_gne__c, 
                    p.Account_Name_gne__c 
                    From ProfileID_License_gne__c p
                    Where p.Account_Name_gne__c =: casePhysician.Id
                    And p.ID_License_Type_gne__c != null
                    Order By p.LastModifiedDate desc Limit 500];
         
         if (profileIdList.size() > 0)
            caseProfileIdLicense = profileIdList[0];
            
         if (caseProfileIdLicense == null || caseProfileIdLicense.Id == null) {
            System.debug('PhyId = ' + casePhysician.Id);
        
            caseProfileIdLicense = new ProfileID_License_gne__c(
                Account_Name_gne__c = casePhysician.Id,
                ID_License_gne__c = '123212321',
                ID_License_Type_gne__c = 'State Medicaid ID',
                State_gne__c = 'IL'
                );

            //insert caseProfileIdLicense;
            DataBase.Saveresult result = DataBase.insert(caseProfileIdLicense, true);
         }
         
         Medical_History_gne__c medHistory;
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
                    Where m.Id =: docCase.Medical_History_gne__c limit 1];
         
         if (medHistoryList.size() > 0)
            medHistory = medHistoryList[0];

         if (medHistory == null || medHistory.Id == null) {
            medHistory = new Medical_History_gne__c(
                Clinical_Trial_Name_gne__c = 'Yes',
                Study_Site_gne__c = 'Study Site',
                Site_Number_gne__c = '12345678',
                Coordinator_gne__c = 'Willy Wonka',
                Phone_gne__c = '1212121',
                Date_of_Diagnosis_gne__c = date.newinstance(2010,1,31),
                Patient_Height_gne__c = 200,
                Patient_Weight_kg_gne__c = 100,
                TNM_Staging_gne__c = 'Stage 0 / Dukes A',
                Metastatic_Sites_gne__c = 'Adrenals',
                Previous_Therapy_Regimens_gne__c = 'None',
                Place_of_Administration_gne__c = 'MD Office / Clinic',
                Dt_of_1st_Trtmt_for_Current_Course_gne__c = date.newinstance(2010,1,31),
                Date_of_First_Treatment_gne__c = date.newinstance(2010,1,31),
                Treatment_Date_gne__c = date.newinstance(2010,1,31),
                Her2_Test_gne__c = 'Negative',
                First_Assay_Test_Used_gne__c = 'Dako IHC',
                Adjuvant_gne__c = 'Yes',
                Disease_Caracteristics_gne__c = 'Low Grade'
            );
            
            DataBase.Saveresult result = DataBase.insert(medHistory, true);
            docCase.Medical_History_gne__c = medHistory.Id;
         }
         //--End Add
           
         //Added by Vinod
         Contact CRcontact=null;
         List<Contact> CRcontactList;
         List<Contact> CRPrimarycontactList;
         List<Contact> GATCFcontactList;
         List<Contact> GATCFPrimarycontactList;
         string  recordTypeOfCase=null;  
         List<RecordType> RecordTypeList=[Select  r.Name, r.Id From RecordType r where r.sObjectType = 'Case' and r.Id=:docCase.recordtypeid];
         if(RecordTypeList.Size()>0)
         recordTypeOfCase=RecordTypeList[0].Name;
         
         if (recordTypeOfCase.startsWith('C&R'))
         {
             CRcontactList=[Select c.Phone,c.Name,c.fax, c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
                    c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c='C&R' and c.Address_gne__c=:docCase.Address_gne__c
                    and c.HCP_gne__r.Id=:docCase.Case_Treating_Physician_gne__r.Id
                    order by c.LastModifiedDate desc LiMIT 500];
             if(CRcontactList.size()>0)
             CRcontact=CRcontactList[0];
             else
             {
               CRPrimarycontactList = [Select c.Phone,c.Name,c.fax,c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
               c.Address_gne__c From Contact c where c.C_R_Specific_gne__c = true and c.Address_gne__c=:docCase.Address_gne__c
               and c.HCP_gne__r.Id=:docCase.Case_Treating_Physician_gne__r.Id
               and c.Primary_Contact_gne__c=true
               order by c.LastModifiedDate desc LiMIT 500];
               
               if(CRPrimarycontactList.size()>0)
               CRcontact=CRPrimarycontactList[0];
               else if(CRcontact==null)
               {
                 //create a case with all fields with casetype as' c&r'
                CRcontact = new Contact
                (
                FirstName ='FirstNameTest',
                LastName ='LastName',
                C_R_Specific_gne__c =true,
                Is_Primary_for_gne__c='C&R',
                Phone='(434) 324-2322',
                Fax='(434) 324-2324',
                //name='Harry',
                Primary_Contact_gne__c=true
                );
                //insert CRcontact;
                 if(CRcontact!=null)
                 DataBase.Saveresult result = DataBase.insert(CRcontact, true);
               }
             }
             
         }
         else if (recordTypeOfCase.startsWith('GATCF'))
         {
             GATCFcontactList = [Select c.Phone,c.Name,c.fax, c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
             c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c='GATCF' and c.Address_gne__c=:docCase.Address_gne__c
             and c.HCP_gne__r.Id=:docCase.Case_Treating_Physician_gne__r.Id
             order by c.LastModifiedDate desc LiMIT 500 ];
             if(GATCFcontactList.size()>0)
             CRcontact=GATCFcontactList[0];
             else
             {
                  GATCFPrimarycontactList = [Select c.Phone,c.Name,c.fax,c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
                  c.Address_gne__c From Contact c where c.GATCF_Specific_gne__c = true and c.Address_gne__c=:docCase.Address_gne__c
                  and c.HCP_gne__r.Id=:docCase.Case_Treating_Physician_gne__r.Id
                  and c.Primary_Contact_gne__c=true
                  order by c.LastModifiedDate desc LiMIT 1  ];
                  if(GATCFPrimarycontactList.size()>0)
                  CRcontact=GATCFPrimarycontactList[0];
                  else if(CRcontact==null)
                  {
                  //create a case with aall fields with casetype as' gatcf'
                  
                     CRcontact = new Contact
                    (
                    GATCF_Specific_gne__c =true,
                    Is_Primary_for_gne__c='GATCF',
                    Phone='(434) 324-2322',
                    Fax='(434) 324-2324',
                    Lastname = 'testname',
                    //name='Larry',
                    Primary_Contact_gne__c=true
                    );
                    
                    //insert CRcontact;
                 if(CRcontact!=null)
                 DataBase.Saveresult result = DataBase.insert(CRcontact, true);
                  } 
                 
                 
             }
             
         }        
          //-----------------------for ReferralFieldfactory ---------------
         Account account=null;
         String accountId = '';
         List<Account> accountListRef;
         
         accountListRef = [Select a.Name from Account a
                Where a.Id = :docCase.Referred_By_Party_gne__c];
                
         if (accountListRef.size() > 0)
          account = accountListRef[0];
         
         if(account==null)
         {
         account= new Account(
         Name='Harry'
         
         );
         
         DataBase.Saveresult result = DataBase.insert(account, true);
         accountId = account.Id;
         docCase.Referred_By_Party_gne__c = accountId;
         docCase.Referred_By_Type_gne__c = 'Physician/MDO';
         }
         
         
         Address_vod__c address=null;
         String addressId = '';
         List<Address_vod__c> addressListRefEnt=[Select a.Address_1_gne__c, a.Address_line_2_vod__c,
                a.City_vod__c, a.State_vod__c, a.Zip_vod__c, a.Name
                From Address_vod__c a
                Where a.Id = :docCase.Referral_Address_Line_1_gne__c
                And a.Account_vod__c = :accountId];
          if (addressListRefEnt.size() > 0)
          address = addressList[0];
         
          if (address==null)
          {
             address = new Address_vod__c(
                Name = 'Harry',
                Address_line_2_vod__c = 'P.O.Box 420',
                City_vod__c = 'SanFransisco',
                State_vod__c = 'NY',
                Zip_vod__c = '12345',
                Shipping_vod__c=false, 
                Satellite_gne__c=false, 
                //Satellit_gne__c=false, 
                SOLD_TO_gne__c=false, 
                Proactive_BI_Opt_In_gne__c=false, 
                Primary_vod__c=false, 
                Office_gne__c=false,
                OK_to_Contact_Patient_gne__c=false, 
                Mailing_vod__c=false, 
                Injection_Training_gne__c=false,
                Infusion_Services_gne__c=false,
                Include_in_Territory_Assignment_vod__c=false, 
                Inactive_vod__c=false, 
                Hospital_gne__c=false, 
                Home_vod__c=false, 
                GOLD_RECORD_gne__c=false,
                FORWARD_TO_gne__c=false, 
                DEA_gne__c=false, 
                Clinic_gne__c=false,
                Buy_and_Bill_gne__c=false,
                Business_vod__c=false,
                Billing_vod__c=false, 
                Appt_Required_vod__c=false,
                Active_Flag_gne__c=false, 
                Account_vod__c = accountId, 
                Accepting_New_Patients_gne__c=false,
                AMS_gold_record_gne__c=false, 
                AIC_Services_gne__c =false
                
            );
            
          DataBase.Saveresult result = DataBase.insert(address, true);
          addressId = address.Id;
          docCase.Referral_Address_Line_1_gne__c = addressId;
          }

          Contact referralContact = new Contact
                                (
                                Contact_Type_gne__c='Individual'
                                , Fax='(434) 324-2324'
                                , FirstName='Test'
                                , GATCF_Specific_gne__c=false
                                , C_R_Specific_gne__c = true
                                , HCP_gne__c=accountId
                                , Primary_Contact_gne__c=true
                                , LastName='Contact'
                                , Salutation='Mr'
                                , Legacy_Contact_ID_gne__c=0
                                , Phone='(434) 324-2322'
                                , Title='Dr'
                                , Address_gne__c = addressId
                                , Is_Primary_for_gne__c = 'C&R'
                                );
            DataBase.Saveresult result = DataBase.insert(referralContact, true);
                                         
         //End added
         String roleId=[Select Id From UserRole Limit 1].Id;
         String tempProfileId=[Select Id From Profile Where Name='GNE-CM-CASEMANAGER' Limit 1].Id;
         User newUser;
         List<User> userList=[Select Id from User Where Username='email1@gene.com.cm' limit 1];
         if(userList.size()>0)
            newUser=userList[0];
         if(newUser==null || newUser.Id==null)
         {
            newUser = new User(Alias='test1', Email='email1@gene.com',
                                ProfileId=tempProfileId,Username='email1@gene.com.cm',
                                UserRoleId=roleId,
                                EmailEncodingKey='ISO-8859-1', 
                                LanguageLocaleKey='en_US',
                                FirstName = 'Harry',
                                LastName='tester',
                                Extension= '123',
                                LocaleSidKey='en_US',
                                TimeZoneSidKey='America/Los_Angeles'
                                );
        
            //insert newUser;
         }
         
        docCase.Patient_gne__c=casePatient.Id;
        docCase.Case_Manager__c=newUser.Id;
        
        docCase.Case_Treating_Physician_gne__c=casePhysician.Id;
        System.debug('Physician ID Test Main :' +docCase.Case_Treating_Physician_gne__c);
        
        //Added by Sanat
        List<User> caseUsers = [Select Id from User Order by FirstName limit 1];
        if (!caseUsers.isEmpty())
            docCase.Case_Manager__c = caseUsers[0].Id;
            
        //End Add
        
        //update docCase;
        return docCase;
    } 
    
    // Case type :
    // 'C&R - Standard Case', 'C&R - Standard Case', 'GATCF - Standard Case'
    //   product
    public static testMethod Case  createCase()
    {
        String caseType='GATCF - Standard Case';
        String product='Lucentis';
        List<RecordType> recordCase=[select Id from recordtype where  Name=:caseType order by Name];
        //if(recordCase.size()==0)
        //  return null;    

        Case newCase=new Case(recordtypeid =recordCase[0].Id 
                              ,Referred_By_Date_gne__c = system.today()
                              ,case_referral_reason_gne__c='Initial Referral' 
                              ,Referred_By_Type_gne__c = 'Patient'
                              ,Cvg_gne__c='Approved'
                              ,case_being_worked_by_gne__c='Vendor BI' 
                              ,Vendor_name_gne__c='Test' 
                              ,Product_gne__c=product
                              );
        newCase=createRelatedItems(newCase);
        insert newCase;
        System.debug('Case Id : ' + newCase.Id);
        System.debug('Physician ID CreateCase :' +newCase.Case_Treating_Physician_gne__c); 
        //System.debug('Physician Profile ID CreateCase :' + newCase.Case_Treating_Physician_gne__c.ID_License_gne__c);    
        System.debug('Case Number : ' + newCase.CaseNumber);
        return newCase;
    }
    
    public static Case createCase(String caseType, String product)
    {
        List<RecordType> recordCase=[select Id,Name from recordtype where  Name=:caseType order by Name];
        Case newCase=new Case(recordtypeid =recordCase[0].Id 
                              ,Referred_By_Date_gne__c = system.today()
                              ,case_referral_reason_gne__c='Initial Referral' 
                              ,Referred_By_Type_gne__c = 'Patient'
                              ,Cvg_gne__c='Approved'
                              ,case_being_worked_by_gne__c='Vendor BI' 
                              ,Vendor_name_gne__c='Test' 
                              ,Product_gne__c=product,
                              Medical_Eligibility_gne__c = 'Approved',
                              Medical_Eligibility_Year_gne__c = '2008',
                              Medical_Eligibility_Month_gne__c = 'February',
                              GATCF_Status_gne__c = 'Approved',
                              Approval_Date_gne__c = date.newinstance(2008,12,31),
                              Enroll_SMN_Form_Signed_Date_gne__c = date.newinstance(2008,12,31),
                              Enrollment_Form_Rec_gne__c = datetime.newinstance(2008,12,31),
                              Eligibility_gne__c = 'Approved',
                              Eligibility_Determination_Date_gne__c = datetime.newinstance(2008,12,31)
                              );
        
        newCase=createRelatedItems(newCase);
        insert newCase;
        System.debug('Case Id : ' + newCase.Id);
        System.debug('Physician ID CreateCase :' +newCase.Case_Treating_Physician_gne__c);    
        System.debug('Case Number : ' + newCase.CaseNumber);
        createRelatedItemsPostInsert(newCase);
        return newCase;
    }

    // drugType : Cardiology , Dermatology, Endocrinology, Oncology, Ophthalmology,
    //            Pulmonary, Respiratory, Rheumatology
    //
    // product : Activase, Activase 100mg, Activase 50mg , Avastin , 
    //          Cathflo Activase 2mg , Herceptin, Lucentis 10 mg , 
    //          Nutropin 1X10 mg- Vial, Nutropin 1X5 mg-Vial, Nutropin AQ 1X10 mg-Vial
    //          Pulmozyme, Raptiva, Rituxan, Tarceva, TNKase 50mg, 
    //          Xolair, Xolair 150 mg, Xolair 75 mg 
    public static Hotline_gne__c createHotline(Boolean setProduct, String drugType, String product, Boolean createCase)
    {   
        //Select h.Comments_gne__c, h.Counter_gne__c, h.Patient_First_Name_gne__c, h.Patient_Last_Name_gne__c, h.Phone_gne__c, h.Prefix_gne__c, h.Product_gne__c, h.Related_Case_gne__c, h.Release_gne__c, h.Service_Offered_gne__c, h.Status_gne__c from Hotline_gne__c h
        Hotline_gne__c hotline = new Hotline_gne__c
                            (
                                Comments_gne__c='comment'
                                ,Counter_gne__c=0
                                ,Patient_First_Name_gne__c ='First'
                                ,Patient_Last_Name_gne__c ='Last'
                                ,Phone_gne__c='(766) 454-3333'
                                //,Drug_Type_gne__c=drugType
                                //,Product_gne__c=product
                                //,Related_Case_gne__c=caseId
                                ,Service_Offered_gne__c='Opted IN'
                                , Status_gne__c='Open'
                            );
        if(setProduct && drugType!=null && product!=null)
        {
            hotline.Drug_Type_gne__c=drugType;
            hotline.Product_gne__c=product;
        }
        if(createCase)
        {
            Case documentCase = SCM_CreateTestData.CreateCase();
            hotline.Related_Case_gne__c=documentCase.Id;
        }
        insert hotline;
        
        return hotline;
    }
    
    //Added by Sanat
    public static void createRelatedItemsPostInsert(Case createdCase) {
        String caseId = createdCase.Id;
        if (caseId != null) {
             Shipment_gne__c shipmentDet ;
              List<Shipment_gne__c> shipmentDetailList = 
                        [select c.Quantity_1_gne__c, Order_Number_gne__c, Name, Name_gne__c
                         from Shipment_gne__c c
                         where c.Case_Shipment_gne__c = :caseId
                         order by c.LastModifiedDate desc];
                  if (shipmentDetailList.size() > 0)
                    shipmentDet = shipmentDetailList[0];
                    
                 if (shipmentDet == null || shipmentDet.Id == null) {
                    System.debug('Shipment is null');
                     shipmentDet = new Shipment_gne__c(
                        Case_Shipment_gne__c = caseId,
                        Order_Number_gne__c = '1234',
                        Name_gne__c = 'Testing123',
                        Zip_gne__c = '60654',
                        Street_gne__c = '350 N Orleans St',
                        Phone_gne__c = '1232334',
                        City_gne__c = 'Chicago',
                        Expected_Delivery_Date_gne__c = date.newinstance(2008,12,31),
                        Expected_Ship_Date_gne__c = date.newinstance(2008,12,31)
                        );
        
                    //insert shipmentDet;
                    try {
                    DataBase.Saveresult result = DataBase.insert(shipmentDet, true);
                    }catch (exception ex4){
                    	
                    }
                 }
        
            //Fulfillment
            String recordTypeProfessional=[select Id from recordtype where  Name='Professional_vod' limit 1].Id;
                
            Account distributor = new Account(
                          FirstName = 'DistFirst'
                              ,LastName = 'DistLast'
                              ,MDMID_Status_gne__c='Active'
                              ,Middle_Name_gne__pc='Middle'
                              ,Professional_Type_gne__c='Distributor'
                              ,Primary_Contact_gne__pc = true 
                              ,RecordTypeId=recordTypeProfessional
                              ,Services_Preferences_gne__c='Benefit Investigation'
                      );
            insert distributor;
        
        
        
            Fulfillment_gne__c fulfillment = new Fulfillment_gne__c(
                        In_network_name_gne__c = distributor.Id,
                        In_Network_Selected_Distributor_gne__c = 'Yes',
                        Out_Network_Selected_Distributor_gne__c = 'No', 
                        In_network_Contact_Name_gne__c = 'Harry', 
                        Out_network_Contact_Name_gne__c = 'Potter',
                        In_network_Fax_Number_gne__c = '(222) 222-2222',
                        Out_network_Fax_Number_gne__c = '(222) 222-2222',
                        Out_network_Phone_Number_gne__c = '(222) 222-2222',
                        In_network_Phone_Number_gne__c = '(222) 222-2222',
                        Case_Fulfillment_gne__c = caseId    
            );
        
            DataBase.Saveresult result = DataBase.insert(fulfillment, true);
        
            try {
                List<Benefit_Investigation_gne__c> biList = [Select b.BI_Insurance_gne__c From Benefit_Investigation_gne__c b order by b.LastModifiedDate desc limit 1];
                if (!biList.isEmpty()) {
                    List<Insurance_gne__c> insList = [Select i.Case_Insurance_gne__c from Insurance_gne__c i where i.Id =: biList[0].BI_Insurance_gne__c limit 1];
            
                    if (!insList.isEmpty()) {
                        Insurance_gne__c ins = insList[0];
                        ins.Case_Insurance_gne__c = caseId;
                        update ins;
                    }
                }
            }
            catch (Exception e) {
                System.debug('Exception');
            }
        }
    }
    //End Add
    
    public static testMethod void  createHotlineObject()
    {
        Hotline_gne__c hot1 = createHotline(true,'Oncology','Avastin',false);
        Hotline_gne__c hot2 =createHotline(true,'Ophthalmology','Lucentis 10 mg', true);
        
        System.assert(hot1!=null,'Hotline 1 cannot be null!');
        System.assert(hot2!=null,'Hotline 2 cannot be null!');
        
        System.assertEquals(hot1.Patient_Last_Name_gne__c,'Last');
        System.assertEquals(hot1.Status_gne__c,'Open');
        System.assertEquals(hot1.Related_Case_gne__c,null);
        System.assert(hot2.Related_Case_gne__c!=null);
        System.assertEquals(hot2.Product_gne__c,'Lucentis 10 mg');
    }
        
}