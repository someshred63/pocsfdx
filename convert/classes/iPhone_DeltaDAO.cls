public with sharing class iPhone_DeltaDAO {
    
    public static List<Account> getAccountDetailsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return  [
            SELECT
                Id,
                Name,
                FirstName,
                LastName,
                Middle_vod__c,
                MDMID_gne__c,
                Type_gne__pc,
                Phone_gne__c,
                Mobile_ID_vod__c,
                CreatedBy.Name,
                LastModifiedDate,
                LastModifiedBy.Name,
                CreatedDate,
                Language_of_Preference_can_gne__c,
                Specialty_1_vod__c,
                Roche_Id_can_gne__c,
                IsPersonAccount,
                HCP_Patient_Ed_Consent_Form_gne__c,
                PersonEmail,
                Secondary_Email_gne__c,
                SP_Investigator_Status_gne__c,
                TL_Type_gne__c,
                Target__c,
                Specialties_can_gne__c,
                Area_of_Expertise_gne__c,
                Classification_gne__c,
                Account_Type_gne__c,
                Sub_Type_can_gne__c,
                RecordType.Name,
                RecordType.DeveloperName,
                RecordType.Description,             
                Gender_vod__c, 
                Specialties_gne__c,
                Credentials_gne__c,
                iPhone_Fields_LastModifiedDate_gne__c,
                Active_US_License_gne__c,
                Website,
                LinkedIn_gne__c,
                Twitter_gne__c,
                PREP_Status_gne__c,
                PersonDoNotCall,
                PersonHasOptedOutOfEmail,
                PersonHasOptedOutOfFax,
                PREP_Professional_Type_gne__c,
                Fax,
                Professional_Type_gne__c,
                Status_gne__c,
                BAM_Level_gne__c,
                BAM_Area_gne__c,
                BAM_Full_Primary_Title_gne__c,
                BAM_Other_Title_gne__c,
                PREP_Double_Testing_Rate_gne__c,
                PREP_Implied_HER2_Positivity_Rate_gne__c,
                PREP_HER2_Testing_Segment_gne__c,
                Est_Annual_Tested_Breast_Patients_gne__c,
                Est_Annual_Tested_Gastric_Patients_gne__c,
                Est_Annual_Tested_Lung_Patients_gne__c,
                Group_gne__r.Name,
                Art_Account_frm_gne__c,
                Picture_File_Id_gne__c,
                stewardship_system_name_gne__c,
                AFRM_Additional_Account_frm_gne__c,
                BFRM_Additional_Account_frm_gne__c,
                EFRM_Additional_Account_frm_gne__c,
                IFRM_Additional_Account_frm_gne__c,
                NFRM_Additional_Account_frm_gne__c,
                PFRM_Additional_Account_frm_gne__c,
                RFRM_Additional_Account_frm_gne__c,
                RESPFRM_Additional_Account_frm_gne__c,
                AFRM_My_Tier_frm_gne__c,
                BFRM_My_Tier_frm_gne__c,
                EFRM_My_Tier_frm_gne__c,
                IFRM_My_Tier_frm_gne__c,
                NFRM_My_Tier_frm_gne__c,
                PFRM_My_Tier_frm_gne__c,
                RFRM_My_Tier_frm_gne__c,
                RESPFRM_My_Tier_frm_gne__c,
                Title_Position_Role_gne__c,
                Spend_Rest_gne__c,
            	SMA_My_Tier_frm_gne__c,
            	SMA_Additional_Account_frm_gne__c,
            	INS_ID_gne__c
            FROM
                Account
            WHERE
                    Id in :accountIds
                AND iPhone_Fields_LastModifiedDate_gne__c >= :lastSyncDate
        ];
    }
    
    public static List<Address_vod__c> getAddressesByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return  [
            SELECT
                Id,
                Account_vod__c,
                Name,
                Address_line_2_vod__c,
                City_vod__c,
                State_vod__c,
                Zip_vod__c,
                Zip_4_vod__c,
                Phone_vod__c,
                Phone_1_Ext_gne__c,
                Phone_2_vod__c,
                Phone_2_Ext_gne__c,
                Fax_vod__c,
                Fax_2_vod__c,
                License_vod__c,
                License_Expiration_Date_vod__c,
                License_Status_vod__c,
                Province_can_gne__c,
                Postal_Code_can_gne__c,
                RecordTypeId,
                RecordType.Name,
                RecordType.DeveloperName,
                Primary_vod__c,
                License_Valid_To_Sample_vod__c,
                Org_Name_can_gne__c,
                CreatedDate,
                LastModifiedDate,
                iPhone_Fields_LastModifiedDate_gne__c,
                PFG_BDTD_gne__c,
                Location_gne__Latitude__s,
                Location_gne__Longitude__s,
                MDM_Status_gne__c,
                MDM_Address_ID_gne__c,
                Business_Name_gne__c,
                Business_Address_Type_gne__c,
                Changed_Address_gne__c,
                External_ID_vod__c
            FROM
                Address_vod__c
            WHERE
                    Account_vod__c in :accountIds
                AND (CreatedDate >= :lastSyncDate OR iPhone_Fields_LastModifiedDate_gne__c >= :lastSyncDate)
                AND Inactive_vod__c = false
        ];
    }
    
    /*Methos used by SFA-US brand users - ignore inactive flag.*/
    public static List<Address_vod__c> getAllAddressesByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return  [
            SELECT
                Id,
                Account_vod__c,
                Name,
                Address_line_2_vod__c,
                City_vod__c,
                State_vod__c,
                Zip_vod__c,
                Zip_4_vod__c,
                Phone_vod__c,
                Phone_1_Ext_gne__c,
                Phone_2_vod__c,
                Phone_2_Ext_gne__c,
                Fax_vod__c,
                Fax_2_vod__c,
                License_vod__c,
                License_Expiration_Date_vod__c,
                License_Status_vod__c,
                Province_can_gne__c,
                Postal_Code_can_gne__c,
                RecordTypeId,
                RecordType.Name,
                RecordType.DeveloperName,
                Primary_vod__c,
                License_Valid_To_Sample_vod__c,
                Org_Name_can_gne__c,
                CreatedDate,
                LastModifiedDate,
                iPhone_Fields_LastModifiedDate_gne__c,
                PFG_BDTD_gne__c,
                Location_gne__Latitude__s,
                Location_gne__Longitude__s,
                MDM_Status_gne__c,
                MDM_Address_ID_gne__c,
                Business_Name_gne__c,
                Business_Address_Type_gne__c,
                Changed_Address_gne__c,
                External_ID_vod__c
            FROM
                Address_vod__c
            WHERE
                    Account_vod__c in :accountIds
                AND (CreatedDate >= :lastSyncDate OR iPhone_Fields_LastModifiedDate_gne__c >= :lastSyncDate)
        ];
    }
    
    public static List<TSF_vod__c> getTSFForTerritoriesNameAndAccountId(List<String> accountIds, List<String> territoriesName, DateTime lastSyncDate) {
        return  [
            SELECT
                Id,
                My_Frequency_gne__c,
                My_Target_vod__c,
                Planned_Frequency_can_gne__c,
                Territory_vod__c,
                Account_vod__c,
                Address_vod__c,
                Address_vod__r.Name,
                Account_vod__r.Target__c,
                LastModifiedDate,
                CreatedDate
            FROM
                TSF_vod__c
            WHERE
                    Territory_vod__c in: territoriesName
                AND Account_vod__c in: accountIds
                AND Address_vod__c != null
                AND External_Id_vod__c != null
                AND LastModifiedDate >= :lastSyncDate
            ORDER BY
                Account_vod__c
        ];
    }
    
    public static List<Medical_Communication_gne__c> getMedicalCommunicationByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return  [
            SELECT
                Id,
                Name,
                Account_gne__c,
                Product_gne__c,
                Follow_up_Method_gne__c,
                Notify_for_Education_gne__c,
                Priority_gne__c,
                Medical_Question_gne__c,
                Open_Date_gne__c,
                LastModifiedDate,
                Closed_Date_gne__c,
                Status_gne__c,
                Status_Referral_gne__c,
                Email_gne__c,
                Phone_gne__c,
                Fax_gne__c,
                CreatedBy.Id,
                CreatedBy.Name,
                Address_Line_1_gne__c,
                Address_Line_2_gne__c,
                City_gne__c,
                State_gne__c,
                Zip_gne__c,
                Zip_4_gne__c,
                Molecule_gne__c,
                TA_SubTA_gne__c,
                TA_gne__c,
                iPhone_Request_Id_gne__c,
                CreatedDate,
                Referral_Assignment_gne__c,
                Referral_Assignment_gne__r.Name,
                Referral_Assignment_gne__r.Assigned_To_gne__c,
                Referral_Assignment_gne__r.Assigned_To_gne__r.Name,
                Referral_Assignment_gne__r.Call2_vod__c,
                Requested_By_gne__c,
                Requested_Completion_Date_gne__c,
                Language_of_Preference_can_gne__c,
                Unsolicited_Request_Verified_gne__c,
                Comments_Referral_gne__c
            FROM
                Medical_Communication_gne__c
            WHERE
                    Account_gne__c in :accountIds
                AND LastModifiedDate >= :lastSyncDate
                AND Open_Date_gne__c >= LAST_N_DAYS:180
        ];
    }
    
    public static List<Referral_Assignment_gne__c> getMedicalCommunicationReferralsByUnixId(String unixId, DateTime lastSyncDate) {
        return  [
            SELECT
                Medical_Request_gne__r.Account_gne__c, 
                Medical_Request_gne__r.Account_gne__r.Name, 
                Medical_Request_gne__r.Address_Line_1_gne__c, 
                Medical_Request_gne__r.Address_Line_2_gne__c, 
                Medical_Request_gne__r.City_gne__c,
                Medical_Request_gne__r.Closed_Date_gne__c, 
                Medical_Request_gne__r.Comments_Referral_gne__c, 
                CreatedBy.Id, 
                CreatedBy.Name, 
                Medical_Request_gne__r.CreatedDate,
                Medical_Request_gne__r.Email_gne__c, 
                Medical_Request_gne__r.Fax_gne__c, 
                Medical_Request_gne__r.Follow_up_Method_gne__c, 
                Id, 
                Medical_Request_gne__r.Language_of_Preference_can_gne__c,           
                LastModifiedDate, 
                Medical_Request_gne__r.Medical_Question_gne__c, 
                Medical_Request_gne__r.Molecule_gne__c, 
                Name, 
                Medical_Request_gne__r.Notify_for_Education_gne__c, 
                Medical_Request_gne__r.Open_Date_gne__c, 
                Medical_Request_gne__r.Phone_1_gne__c, 
                Medical_Request_gne__r.Phone_gne__c, 
                Medical_Request_gne__r.Priority_gne__c, 
                Medical_Request_gne__r.Product_Name_gne__c, 
                Medical_Request_gne__r.Product_gne__c, 
                Assigned_To_gne__c, 
                Assigned_To_gne__r.Name,
                Call2_vod__c, 
                CreatedDate, 
                Revised_Requested_Completion_Date_gne__c,
                Medical_Request_gne__r.Referral_History_gne__c, 
                Medical_Request_gne__r.Referral_Source_gne__c, 
                Medical_Request_gne__r.Requested_By_gne__c,
                Medical_Request_gne__r.Requested_By_gne__r.Name,  
                Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
                Medical_Request_gne__r.State_gne__c, 
                Medical_Request_gne__r.Status_Referral_gne__c, 
                Medical_Request_gne__r.Status_gne__c,
                Medical_Request_gne__r.TA_SubTA_gne__c, 
                Medical_Request_gne__r.TA_gne__c, 
                Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c, 
                Medical_Request_gne__r.Zip_4_gne__c, 
                Medical_Request_gne__r.Zip_gne__c, 
                Medical_Request_gne__r.iPhone_Request_Id_gne__c,
                Status_Referral_Date_gne__c
            FROM
                Referral_Assignment_gne__c
            WHERE
                    Assigned_To_gne__r.External_ID_gne__c = :unixId
                AND LastModifiedDate >= :lastSyncDate
            ORDER BY CreatedDate DESC
        ];
    }    

    public static List<Change_Request_gne__c> getChangeRequestsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return  [
            SELECT
                Id,
                Name,
                Account_gne__c,
                Account_Group_gne__c,
                Current_Address_gne__c,
                Type_gne__c,
                Approval_State__c,
                CreatedDate,
                CreatedById,
                LastModifiedDate,
                Vendor_Type_gne__c,
                Vendor_Notes_gne__c,
                First_Name_DCR_gne__c,
                New_Value_2_gne__c,
                Last_Name_DCR_gne__c,
                Account_Type_DCR_gne__c,
                Verify_Gender_can_gne__c,
                Suffix_DCR_gne__c,
                Professional_Type_DCR_gne__c,
                verify_HCP_credentials_gne__c,
                Verify_HCP_Specialties_gne__c,
                Credentials_dcr_gne__c,
                Specialties_hcp_dcr_gne__c,
                New_Organization_Name_gne__c,
                Verify_HCO_Specialties_gne__c,
                Description_gne__c,
                Reason_dcr_gne__c,
                Duplicate_Account_2_gne__c,
                Duplicate_Account_2_gne__r.Name,
                Duplicate_Account_3_gne__c,
                Duplicate_Account_3_gne__r.Name,
                Duplicate_Account_4_gne__c,
                Duplicate_Account_4_gne__r.Name,
                Duplicate_Account_5_gne__c,
                Duplicate_Account_5_gne__r.Name,
                Duplicate_Address_2_gne__c,
                Duplicate_Address_3_gne__c,
                Address_Line_1_gne__c,
                Address_Line_2_gne__c,
                City_gne__c,
                State_gne__c,
                Zip_gne__c,
                Province_can_gne__c,
                Postal_Code_can_gne__c,
                Remove_Inactive_Address_gne__c,
                License_State_gne__c,
                License_Number_gne__c,
                License_Designation_gne__c,
                Status_gne__c,
                Status_cs_gne__c,
                Adjusted_License_Expiration_Date_gne__c,
                License_Overwrite_Expiration_Date_gne__c,
                License_Sample_ability_gne__c,
                New_Note_gne__c,
                iPhone_Request_Id_gne__c,
                HCP_National_Provider_Id_gne__c                
            FROM
                Change_Request_gne__c
            WHERE
                    Account_gne__c in :accountIds
                AND LastModifiedDate >= :lastSyncDate
            ORDER BY
                CreatedDate, Account_gne__c         
        ];
    }

    public static List<Call2_vod__c> getCallsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Name,
                Address_vod__c,
                Parent_Call_vod__c,
                Call_Datetime_vod__c,
                Interaction_Status_gne__c,
                Meal_Expense_gne__c,
                Meal_Amount_gne__c,
                Planned_Attendees_gne__c,
                Actual_Attendees_gne__c,
                CreatedBy.Name,
                LastModifiedBy.Name,
                CreatedById,
                OwnerId,
                Owner.Name,
                Account_vod__c,
                iphone_request_id_gne__c,
                LastModifiedDate,
                Parent_Address_vod__c,
                Parent_Address_vod__r.Name,
                Parent_Address_vod__r.Address_line_2_vod__c,
                Parent_Address_vod__r.City_vod__c,
                Parent_Address_vod__r.State_vod__c,
                Parent_Address_vod__r.Zip_vod__c,
                Parent_Address_vod__r.Zip_4_vod__c,
                Parent_Address_vod__r.Province_can_gne__c,
                Parent_Address_vod__r.Postal_Code_can_gne__c,
                customers_gne__c,
                interaction_type_gne__c,
                Is_Sampled_Call_vod__c,
                Signature_Date_vod__c,
                Request_Signature_Date_gne__c,
                License_vod__c,
                Speaker_Program_gne__c,
                Interaction_method_gne__c,
                Topics_Addressed_gne__c,
                Other_Details_Topics_Addressed_gne__c,
                Resolution_gne__c,
                FRM_Response_Time_gne__c,
                Reactive__c,
                Interaction_Location_gne__c,
                Primary_Interaction_Reason_gne__c,
                City_gne__c,
                Group_Meeting_Topic_gne__c,
                Visit_Reason_gne__c,
                State_gne__c,
                Notes_can_gne__c,
                Account_Plan_vod__c,
                Attempted_Visit_HCP_UnwillingToMeet_gne__c,
                Medical_Support_Notes_gne__c,
                CreatedDate,
                HCP_Account_Meal_Opt_Out_gne__c,
                HCP_Follow_Up_Opt_In_gne__c,
                Unsolicited_Request_gne__c,
                Referral_Assignment_gne__c,
                Referral_Assignment_gne__r.Medical_Request_gne__c,
                Sales_Collateral_gne__c,
                Patient_Education_Materials_gne__c,
                Protection_Strategy_gne__c,
                RecordType.DeveloperName,
                PFG_BDTD_gne__c,
                Visit_Reason_RCanada_MSL_gne__c,
                Visit_Reason_Canada_SAM_gne__c,
                Interaction_Length_gne__c,
                Collaboration_gne__c,
                Other_Attendees_Count_gne__c,
                PREP_Status_gne__c,
                PREP_Follow_Up_With_gne__c,
                PREP_Speak_With_gne__c,
                PREP_About_gne__c,
                PREP_Other_gne__c,
                (SELECT Id, Call_gne__c, Mbo_gne__c FROM Call_PREP_MBOs_gne__r),
                Is_Referral_gne__c,
                Other_Referral_Source_gne__c,
                Referral_Requested_By_gne__c,
                Referral_Requested_Date_gne__c,
                Referral_Source_gne__c,
                Territory_vod__c,
                Territory_Id_gne__c,
                MBaC_gne__c,
                MBiC_gne__c,
                MBoC_gne__c,
                Visit_Reason_Description_gne__c,
                HCP_Specialty_gne__c,
                Pre_Call_Plan_gne__c,
                Geolocation_gne__Latitude__s,
                Geolocation_gne__Longitude__s,
                Group_Call_with_gne__c,
                Biosimilars_gne__c,
                No_InService_Attendees__c,
                Owner_External_Id_frm_gne__c,
                Date_Completed_gne__c,
                User_business_role_gne__c,
                createdby_Profile_gne__c,
                Group_RAMA_gne__c,
                Access_Echo_Alignment_RAMA_gne__c,
                Objectives_RAMA_gne__c,
                Key_Messages_RAMA_gne__c,
                Outcomes_RAMA_gne__c,
                Next_Steps_RAMA_gne__c,
            	M_A_Account__c,
            	Probability__c,
            	Initiated_by_Account__c,
                Interaction_Description_gne__c,
                Insight_gne__c,
                Next_Interaction_Objective_gne__c
            FROM
                Call2_vod__c
               WHERE
               Account_vod__c in :accountIds
               AND LastModifiedDate >= :lastSyncDate
               AND Call_Datetime_vod__c >= LAST_N_DAYS:180
               AND Call_Datetime_vod__c <= NEXT_N_DAYS:180
               AND Parent_Call_vod__c = null
        ];
    }
    
    public static List<Call2_vod__c> getAttendeeParentCallsIdsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {               
        List<Call2_vod__c> result = new List<Call2_vod__c>();        
        Set<Id> parentCallIds = new Set<Id>();
        for (Call2_vod__c attendeeRow : [SELECT 
            Parent_Call_vod__c
        FROM 
            Call2_vod__c 
        WHERE 
            Parent_Call_vod__c != null 
            AND Parent_Call_vod__r.Account_vod__c In :accountIds 
            AND Parent_Call_vod__r.Parent_Call_vod__c = null 
            AND Parent_Call_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180 
            AND Parent_Call_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180 
            AND EMS_International_Speaker_gne__c = null 
            AND (LastModifiedDate >= :lastSyncDate OR Account_vod__r.iPhone_Fields_LastModifiedDate_gne__c >= :lastSyncDate OR Contact_vod__r.LastModifiedDate >= :lastSyncDate)]){
            parentCallIds.add(attendeeRow.Parent_Call_vod__c);          
        }        
        for (Id parentCallId : parentCallIds){
            result.add(
                new Call2_vod__c(
                    Id = parentCallId
                )
            );
        }
        return result;
    }
    
    public static List<Call2_vod__c> getCallsIdsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return  [
            SELECT
                Id
            FROM
                Call2_vod__c
            WHERE
                    Account_vod__c in :accountIds
                AND LastModifiedDate >= :lastSyncDate
                AND Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Parent_Call_vod__c = null
        ];
    }
    
    public static List<Call2_Detail_vod__c> getCallDetailsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Detail_Priority_vod__c,
                Call2_vod__c,
                Product_vod__c,
                CreatedDate,
                LastModifiedDate
            FROM
                Call2_Detail_vod__c
            WHERE
                    Call2_vod__r.Account_vod__c in : accountIds
                AND Call2_vod__r.LastModifiedDate >= :lastSyncDate
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Interaction_Detail_vod__c> getCallInteractionDetailsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Name_vod__c,
                Tactic_vod__c,
                Type_vod__c,
                Visit_Reason_vod__c,
                Group_RAMA_vod__c,
                Strategy_RAMA_vod__c,
                Tactic_RAMA_vod__c,
                Tools_RAMA_vod__c,
                Call2_vod__c,                
                CreatedDate,
                LastModifiedDate
            FROM
                Call2_Interaction_Detail_vod__c
            WHERE
                    Call2_vod__r.Account_vod__c in : accountIds
                AND Call2_vod__r.LastModifiedDate >= :lastSyncDate
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Category_vod__c> getCallCategoriesByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Brand_Above_Brand_gne__c,
                Brand_Name_gne__c,
                Indication_gne__c,
                Molecule_gne__c,              
                NOC_Status_gne__c,              
                Therapeutic_Area_gne__c,    
                Call2_vod__c,                
                CreatedDate,
                LastModifiedDate
            FROM
                Call2_Category_vod__c
            WHERE
                    Call2_vod__r.Account_vod__c in : accountIds
                AND Call2_vod__r.LastModifiedDate >= :lastSyncDate
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Discussion_vod__c> getCallDiscussionsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Product_vod__c,
                Product_Strategy_vod__c,
                Product_Tactic_vod__c,
                Call2_vod__c,
                Molecule_gne__c,
                Topic_gne__c,
                Current_Issue_gne__c,
                Answer_gne__c,
                Question_gne__c,
                Number_Of_Patients_Impacted_gne__c,
                Activity_gne__c,
                Event_Curriculum_gne__c,
                Event_gne__c,
                Speaker_Training_gne__c,
                Account_Tactic_vod__c,
                Reaction_gne__c,
                Reason_gne__c,
                CreatedDate,
                LastModifiedDate,
                Detail_Priority_gne__c,
                Activity_Time_Spent_gne__c,
                Observation_gne__c,
                PREP_MBO_gne__c,
                FRM_Issue_Diagnosed_gne__c,
                FRM_Issue_Triaged_gne__c,
                FRM_Triaged_To_gne__c,
                FRM_Patients_Impacted_gne__c,
                FRM_Complex_Issue_gne__c,
                FRM_Issue_Resolved_gne__c,
                FRM_Issue_entered_into_ASMI_gne__c,
                FRM_Deck_Used_gne__c,
                Decision_Cycle_gne__c,
                Attendee_Group_gne__c,
                Number_of_Attendees_gne__c,
                FRM_Issue_Status__c,
                Non_provider_Group__c,
                Patient_Journey_F2F_or_Virtual__c,
                Patient_Interaction_F2F_or_Virtual__c,
            	CRM_Meeting_Objective__c,
            	CRM_Objectives_Met__c, 
            	CRM_Tactic__c,CRM_When__c,
            	CRM_Impact__c,
            	CRM_Marketing_Material__c,
            	CRM_Value__c
            FROM
                Call2_Discussion_vod__c
            WHERE
                    Call2_vod__r.Account_vod__c in : accountIds
                AND Call2_vod__r.LastModifiedDate >= :lastSyncDate
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }
    
    public static List<Call2_Threat_vod__c> getCallThreatsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT Id, Product_vod__c, Book_of_Business__c, Requested_Position__c, Rebate__c, Requested_Start_Date__c, Risk_Level__c, Initial_Assessment__c, Call2_vod__c, CreatedDate, LastModifiedDate
            FROM Call2_Threat_vod__c
            WHERE Call2_vod__r.Account_vod__c IN : accountIds
            	AND Call2_vod__r.LastModifiedDate >= :lastSyncDate
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Key_Message_vod__c> getCallKeyMessagesByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Name,
                Key_Message_vod__c,
                Key_Message_vod__r.Name,
                Key_Message_vod__r.Description_vod__c,
                Key_Message_vod__r.Active_vod__c,
                Call2_vod__c,
                CreatedDate,
                LastModifiedDate
            FROM
                Call2_Key_Message_vod__c
            WHERE
                    Call2_vod__r.Account_vod__c in : accountIds
                AND Call2_vod__r.LastModifiedDate >= :lastSyncDate
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }
    
    public static List<Call_Pre_Call_gne__c> getCallPreCallsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Name,
                Customer_Segment_gne__c,
                Decision_Cycle_gne__c,
                Implication_Questions_gne__c,
                Need_payoff_Questions_gne__c,
                Problem_Questions_gne__c,
                Interaction_Objectives_gne__c,
                Product_gne__c,
                Call_gne__c,
                CreatedDate,
                LastModifiedDate
            FROM
                Call_Pre_Call_gne__c
            WHERE
                    Call_gne__r.Account_vod__c in : accountIds
                AND Call_gne__r.LastModifiedDate >= :lastSyncDate
                AND Call_gne__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call_gne__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call_gne__r.Parent_Call_vod__c = null
        ];
    }
    
    public static List<Call_PFG_Detail_gne__c> getCallPFGDetailsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Call_gne__c,
                Account_gne__c,
                Product_gne__c,
                Quantity_gne__c,
                Lot_No_gne__c,
                Distribution_Method_gne__c,
                DTP_AOC_Status_gne__c,
                Order_Status_gne__c,
                Shipment_ID_gne__c,
                CreatedDate,
                LastModifiedDate,
                (SELECT Id, Transaction_Ref_Number_gne__c, Shipped_Date_gne__c, Pick_Slip_Number_gne__c
                 FROM PFG_Transactions__r)
            FROM
                Call_PFG_Detail_gne__c
            WHERE
                Account_gne__c in : accountIds
                AND (LastModifiedDate >= :lastSyncDate OR Call_gne__r.LastModifiedDate >= :lastSyncDate)
                AND Call_gne__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call_gne__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
        ];
    }

    public static List<Call2_Sample_vod__c> getCallSamplesByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Account_vod__c,
                Call2_vod__c,
                Lot_vod__c,
                Product_vod__c,
                Quantity_vod__c,
                Call2_vod__r.Parent_Call_vod__c,
                CreatedDate,
                LastModifiedDate
            FROM
                Call2_Sample_vod__c
            WHERE
                    Call2_vod__r.Account_vod__c in : accountIds
                AND Call2_vod__r.LastModifiedDate >= :lastSyncDate
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Affiliation_vod__c> getAccountAffiliationsNoContactsByAccountIds(List<String> accountIds) {
        String query = getAccountAffiliationsQuery();
        return Database.query(query + 'WHERE From_Account_vod__c in :accountIds AND To_Contact_vod__c = null');
    }
    
    public static List<Affiliation_vod__c> getAccountAffiliationsWithContactsByAccountIds(List<String> accountIds) {
        String query = getAccountAffiliationsQuery();
        return Database.query(query + 'WHERE From_Account_vod__c IN :accountIds AND To_Contact_vod__c != null');            
    }
    
    private static String getAccountAffiliationsQuery() {
        String toAccountRelName = Affiliation_vod__c.To_Account_vod__c.getDescribe().getRelationshipName();
        String toContactRelName = Affiliation_vod__c.To_Contact_vod__c.getDescribe().getRelationshipName();
        
        String fieldsToSelect = String.join(
            new List<String>{
                'Id',
                String.valueOf(Affiliation_vod__c.Role_vod__c),
                String.valueOf(Affiliation_vod__c.From_Account_vod__c),
                String.valueOf(Affiliation_vod__c.To_Account_vod__c),
                String.valueOf(Affiliation_vod__c.To_Contact_vod__c),
                String.valueOf(Affiliation_vod__c.MDM_ID_gne__c),
                toAccountRelName + '.LastName',
                toAccountRelName + '.FirstName',
                toAccountRelName + '.IsPersonAccount',
                toAccountRelName + '.Name',
                toContactRelName + '.LastName',
                toContactRelName + '.' + String.valueOf(Contact.Secondary_Phone_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Fax),
                toContactRelName + '.' + String.valueOf(Contact.zip_4_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Secondary_ext_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.MailingCity),
                toContactRelName + '.' + String.valueOf(Contact.ext_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Contact_Type_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Secondary_Email_gne__c),
                toContactRelName + '.CreatedById',
                toContactRelName + '.' + String.valueOf(Contact.MailingStreet),
                toContactRelName + '.' + String.valueOf(Contact.iPhone_Request_Id_gne__c),
                toContactRelName + '.MailingState',
                toContactRelName + '.' + String.valueOf(Contact.MailingPostalCode),
                toContactRelName + '.email',
                toContactRelName + '.phone',                
                toContactRelName + '.firstname',
                toContactRelName + '.CreatedDate',
                toContactRelName + '.Name',
                toContactRelName + '.' + String.valueOf(Contact.Website_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.LinkedIn_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Type_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Twitter_gne__c),
                'CreatedDate',
                'LastModifiedDate',
                String.valueOf(Affiliation_vod__c.Primary_gne__c),
                String.valueOf(Affiliation_vod__c.Primary_fpm_gne__c)
            },
            ', '
        );
        
        String activeForMyBrandFieldStr = GNE_Account_Affiliation_Dao.ACTIVE_FOR_MY_BRAND_FIELD_LIST_STR;
        if (String.isNotBlank(activeForMyBrandFieldStr)){
            fieldsToSelect += ', ' + activeForMyBrandFieldStr;
        }
        
        return String.format('SELECT {0} FROM Affiliation_vod__c ',
            new String[]{
                fieldsToSelect
            }
        );
    }
        
    public static List<SFA2_PREP_Account_Testing_Strategy_gne__c> getPrepStrategiesByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Account_gne__c,
                Status_gne__c,
                Testing_Strategy_gne__c,
                Testing_Strategy_gne__r.Name,
                CreatedDate,
                LastModifiedDate,
                (SELECT
                    Id,
                    Status_gne__c,
                    Account_Testing_Strategy_gne__c,
                    MBO_gne__c,
                    MBO_gne__r.Name,
                    CreatedDate,
                    LastModifiedDate
                 FROM Account_MBOs_gne__r
                 WHERE LastModifiedDate >= :lastSyncDate)
            FROM
                SFA2_PREP_Account_Testing_Strategy_gne__c
            WHERE
                    Account_gne__c IN :accountIds
                AND ID IN (Select Account_Testing_Strategy_gne__c FROM SFA2_PREP_Account_MBO_gne__c WHERE LastModifiedDate >= :lastSyncDate)                
        ];
    }
    public static List<SFA2_PREP_Account_Testing_Info_gne__c> getPrepTestingInfoByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Account_gne__c,
                MDT_Lead_gne__c,
                MDT_Lead_Title_gne__c,
                Percent_of_Global_gne__c,
                Percent_of_TC_gne__c,
                Referred_Account_gne__c,
                Referred_Account_gne__r.Name,
                Stage_Tested_gne__c,
                Test_Component_gne__c,
                Test_Hierarchy_gne__c,
                Test_Initiator_gne__c,
                Test_Method_gne__c,
                Test_Type_gne__c,
                Testing_Volume_Month_gne__c,
                CreatedDate,
                LastModifiedDate
            FROM
                SFA2_PREP_Account_Testing_Info_gne__c
            WHERE
                    Account_gne__c IN :accountIds
                AND LastModifiedDate >= :lastSyncDate
        ];
    }
    
    public static List<SFA2_Account_Society_Membership_gne__c> getSocietyMembershipsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Account_gne__c,
                Membership_Name_gne__c,
                Other_gne__c,
                Year_gne__c,
                CreatedDate,
                LastModifiedDate
            FROM
                SFA2_Account_Society_Membership_gne__c
            WHERE
                    Account_gne__c IN :accountIds
                AND LastModifiedDate >= :lastSyncDate
        ];
    }

    public static List<Distributor_fpm_gne__c> getAccountDistributorsByAccountIds(List<String> accountIds, DateTime lastSyncDate){
        return [
            SELECT
                Id,
                Name,
                Distributor_Account_Number_fpm_gne__c,
                Distributor__c,
                Account_ref_gne__c,
                CreatedById,
                CreatedBy.Name,
                CreatedDate,
                LastModifiedDate
            FROM
                Distributor_fpm_gne__c
            WHERE
                    Account_ref_gne__c IN : accountIds
                AND LastModifiedDate >= :lastSyncDate
        ];
    }

    public static List<HIN_Number_fpm_gne__c> getAccountHINNumbersByAccountIds(List<String> accountIds, DateTime lastSyncDate){
        return [
            SELECT
                Id,
                Name,
                HIN_Number_fpm_gne__c,
                Account_ref_gne__c,
                CreatedById,
                CreatedBy.Name,
                CreatedDate,
                LastModifiedDate
            FROM
                HIN_Number_fpm_gne__c
            WHERE
                    Account_ref_gne__c IN : accountIds
                AND LastModifiedDate >= :lastSyncDate
        ];
    }
    
    public static List<MCE_gne__c> getMCEsByAccountIdsAndTeams(List<String> accountIds, Set<String> teamCodes, Set<String> subTeamCodes, DateTime lastSyncDate) {
        return [
         SELECT
           Id,
           Account_gne__c,
           Team_Code_gne__c,
           Subteam_Code_gne__c,
           Brand_gne__c,
           Onlabel_gne__c,
           CreatedDate,
           LastModifiedDate
         FROM
           MCE_gne__c
         WHERE
               Account_gne__c IN :accountIds
           AND Team_Code_gne__c IN :teamCodes
           AND Subteam_Code_gne__c IN :subTeamCodes
           AND LastModifiedDate >= :lastSyncDate
        ];
    }
    
    public static List<User_Preference_gne__c> getUserPreferencesByUserId(String userId, DateTime lastSyncDate) {
        return [
         SELECT
           Id,
           Type_gne__c,
           Account_gne__c,
           OnObject_Id_gne__c,
           OnObject_Type_gne__c,
           Address_gne__c,
           Active_gne__c,
           LastModifiedDate,
           CreatedDate
         FROM
           User_Preference_gne__c
         WHERE
               User_gne__c =: userId
           AND LastModifiedDate >= :lastSyncDate
        ];
    }
    
    public static List<FRM_HCO_Mapping_gne__c> getMappingsByAccountIds(List<String> accountIds, DateTime lastSyncDate) {
        return [
          SELECT
            Id,
            FRM_HCO_Account_gne__c, 
            HCP_Account_gne__c,
            HCP_Account_gne__r.Name,
            HCP_Account_gne__r.FirstName,
            HCP_Account_gne__r.LastName,
            HCP_Account_gne__r.Phone,
            HCP_Account_gne__r.Status_gne__c,
            HCP_Account_gne__r.MDMID_gne__c,
            HCP_Address_gne__c,
            HCP_Address_gne__r.Name,
            HCP_Address_gne__r.Address_line_2_vod__c,
            HCP_Address_gne__r.City_vod__c,
            HCP_Address_gne__r.State_vod__c,
            HCP_Address_gne__r.Zip_vod__c,
            HCP_Address_gne__r.Location_gne__Latitude__s,
            HCP_Address_gne__r.Location_gne__Longitude__s,
            LastModifiedDate,
            CreatedDate         
          FROM
            FRM_HCO_Mapping_gne__c
          WHERE
            FRM_HCO_Account_gne__c in :accountIds
            AND LastModifiedDate >= :lastSyncDate
        ];
   }
   
    public static List<Prescriber_License_gne__c> getAccountLicenses(List<String> accountIds, DateTime lastSyncDate) {
        return [
            SELECT
                Id,
                Name,
                CreatedDate,
                LastModifiedDate,
                Account_gne__c,
                License_Expiration_Date_gne__c,
                License_State_gne__c,
                License_Status_gne__c,
                License_Valid_To_Sample_gne__c
            FROM
                    Prescriber_License_gne__c
            WHERE
                Account_gne__c in :accountIds
                AND LastModifiedDate >= :lastSyncDate
        ];
    }

    public static List<TDDD_License_gne__c> getAccountTdddLicenses(List<String> accountIds, Datetime lastSyncDate) {
        return [
                SELECT
                        Id,
                        Name,
                        CreatedDate,
                        LastModifiedDate,
                        Account_gne__c,
                        License_Expiration_Date_gne__c,
                        License_State_gne__c,
                        License_Status_gne__c,
                        Organization_Address_gne__c,
                        Organization_Name_gne__c
                FROM
                        TDDD_License_gne__c
                WHERE
                Account_gne__c IN :accountIds
                AND LastModifiedDate >= :lastSyncDate
        ];
    }
}