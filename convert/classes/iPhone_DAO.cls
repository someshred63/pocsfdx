/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: Data Abstraction Object for the project.
*******************************************************************************************/
public with sharing class iPhone_DAO {

    private static final Integer RECORDS_LIMIT = 45000;

    public static List<UserTerritory2Association> getUserTerritories(String userId) {
        return  [
            SELECT
                Territory2Id
            FROM
                UserTerritory2Association
            WHERE
                    IsActive    = true
                AND userid      =:userId
        ];
    }

    public static List<Territory2> getUserTopTerritories(Id userId) {
        return  [
            SELECT
                Id,
                Name,
                External_id_gne__c,
                ParentTerritory2Id
            FROM
                Territory2
            WHERE
                Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId =: userId)
            ORDER BY Name
        ];
    }

    public static List<Territory2> getChildrenTerritories(List<Territory2> parentTerritories, List<Territory2> result) {
        return  [
            SELECT
                Id,
                Name,
                External_id_gne__c,
                ParentTerritory2Id
            FROM
                Territory2
            WHERE
                ParentTerritory2Id IN : parentTerritories
            ORDER BY ParentTerritory2Id
        ];
    }

    public static List<Territory2> getTerritories(List<String> territoriesIds) {
        return  [
            SELECT
                Id,
                Name,
                Salesforce_Code_gne__c,
                Salesforce_SubTeam_Code_gne__c
            FROM
                Territory2
            WHERE
                id in : territoriesIds
        ];
    }

    public static List<Territory2> getTerritoriesForName(List<String> territoriesName) {
        return  [
            SELECT
                Id
            FROM
                Territory2
            WHERE
                Name IN : territoriesName
        ];
    }

    public static User getUserByExternalId(String externalId) {
        return (User)getFirstSObject([
            SELECT
                Id,
                Name,
                AccountId,
                CompanyName,
                Profile_Name_gne__c,
                ProfileId,
                FirstName,
                LastName,
                External_ID_gne__c,
                Title,
                ManagerId,
                Manager.Name,
                Manager.Email,
                FullPhotoUrl,
                SmallPhotoUrl
            FROM
                User
            WHERE
                External_ID_gne__c =: externalId
        ]);
    }

    public static User getUserById(String userId) {
        return (User)getFirstSObject([
           SELECT
                Id,
                Name,
                Username,
                AccountId,
                CompanyName,
                Profile_Name_gne__c,
                ProfileId,
                FirstName,
                LastName,
                External_ID_gne__c,
                Title,
                ManagerId,
                Manager.Name,
                Manager.Email,
                FullPhotoUrl,
                SmallPhotoUrl
            FROM
                User
            WHERE
                Id =: userId
        ]);
    }

    public static User getUserByAlias(String alias) {
        return (User)getFirstSObject([
            SELECT
                Id
            FROM
                User
            WHERE
                    Alias =: alias
                AND IsActive = true
        ]);
    }

    /*Return users needed due to sfa-793*/
    public static List<User> getReferralUsers() {
        return [
            SELECT
                Id,
                Name,
                CompanyName,
                Profile_Name_gne__c,
                ProfileId,
                FirstName,
                LastName,
                External_ID_gne__c,
                CreatedDate,
                LastModifiedDate
            FROM
                User
            WHERE
                IsActive=true AND (Profile_Name_gne__c LIKE 'GNE-SFA-%-CS' or Profile_Name_gne__c LIKE 'GNE-TLS-%' or Profile_Name_gne__c LIKE  'GNE-MedAffairs-MSL')
        ];
    }

    public static List<Group> getGroupsForTerritories(List<Territory2> territories) {
        return  [
            SELECT
                Id
            FROM
                Group
            WHERE
                relatedId in: territories
        ];
    }

    public static List<AccountShare> getAccountSharesForGroups(List<Group> groups) {
        return  [
            SELECT
                Id,
                accountId
            FROM
                AccountShare
            WHERE
                UserOrGroupId in: groups
        ];
    }

    public static List<TSF_vod__c> getTSFForTerritoriesName(List<String> territoriesName) {
        return  [
            SELECT
                Id,
                Account_vod__c
            FROM
                TSF_vod__c
            WHERE
                    Territory_vod__c in: territoriesName
                AND Address_vod__c != null
                AND External_Id_vod__c != null
        ];
    }

    public static List<TSF_vod__c> getTSFForTerritoriesNameAndAccountId(List<String> accountIds, List<String> territoriesName) {
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
            ORDER BY
                Account_vod__c
        ];
    }

    public static List<Account> getAccountsByIds(List<String> accountIds) {
        return  [
            SELECT
                Id
            FROM
                Account
            WHERE
                Id in: accountIds
            ORDER BY
                CreatedDate
        ];
    }

    public static List<Account> getAccountsByIds(Set<String> accountIds) {
        return  [
            SELECT
                Id
            FROM
                Account
            WHERE
                Id in: accountIds
            ORDER BY
                CreatedDate
        ];
    }

    public static List<Product_Metrics_vod__c> getProductMetricsByAccountIds(List<String> accountIds) {
        return  [
            SELECT
                Id,
                Name,
                Account_vod__c,
                Products_vod__c,
                Products_vod__r.Id,
                Prod_Decile_gne__c,
                Market_Decile_gne__c,
                Segment_gne__c,
                Classification_gne__c,
                Company_Frequency_gne__c,
                Brand_Affiliation_Status_gne__c,
                Contracted_Speaker__c,
                TLL_Region_gne__c,
                LastModifiedDate,
                CreatedDate
            FROM
                Product_Metrics_vod__c
            WHERE
                Account_vod__c in :accountIds
        ];
    }

    public static List<Targets_and_Tiers_can_gne__c> getTargetAndTiersByIds(List<Id> ids) {
        String query = getTargetAndTiersQuery();
        return Database.query(query + 'WHERE Id In :ids');
    }

    public static List<Targets_and_Tiers_can_gne__c> getTargetAndTiersByAccountIds(List<String> accountIds, List<String> territoryNames, List<Id> productsIds) {
        String query = getTargetAndTiersQuery();
        return Database.query(query + 'WHERE Account_can_gne__c IN :accountIds AND Territory_gne__c IN :territoryNames AND Product_Catalog_gne__c IN :productsIds');
    }

    private static String getTargetAndTiersQuery() {
        String productCatalogRelName = Targets_and_Tiers_can_gne__c.Product_Catalog_gne__c.getDescribe().getRelationshipName();
        String productCatalogFN = productCatalogRelName + '.' + String.valueOf(Targets_and_Tiers_can_gne__c.Product_Catalog_gne__r.Name);

        List<String> fieldsToSelect = new List<String>{
            String.valueOf(Targets_and_Tiers_can_gne__c.Id),
            String.valueOf(Targets_and_Tiers_can_gne__c.Name),
            String.valueOf(Targets_and_Tiers_can_gne__c.Account_can_gne__c),
            String.valueOf(Targets_and_Tiers_can_gne__c.Product_Catalog_gne__c),
            productCatalogFN,
            String.valueOf(Targets_and_Tiers_can_gne__c.Territory_gne__c),
            String.valueOf(Targets_and_Tiers_can_gne__c.Target_gne__c),
            String.valueOf(Targets_and_Tiers_can_gne__c.Segment_gne__c),
            String.valueOf(Targets_and_Tiers_can_gne__c.Tier_can_gne__c),
            String.valueOf(Targets_and_Tiers_can_gne__c.My_Target_gne__c),
            String.valueOf(Targets_and_Tiers_can_gne__c.LastModifiedDate),
            String.valueOf(Targets_and_Tiers_can_gne__c.CreatedDate)
        };

        return String.format('Select {0} From Targets_and_Tiers_can_gne__c ',
            new String[]{
                String.join(fieldsToSelect, ', ')
            }
        );
    }

    public static List<TSF_vod__c> getTerritoryFieldsByAccountIds(List<String> accountIds) {
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
                    Account_vod__c in :accountIds
                AND Address_vod__c != null
                AND External_Id_vod__c != null
            ORDER BY
                Account_vod__c
        ];
    }

    public static List<Territory2> getTerritoriesByName(List<String> territoryNames) {
        return  [
            SELECT
                Id,
                Name
            FROM
                Territory2
            WHERE
                Name in: territoryNames
        ];
    }

    public static List<Address_vod__c> getAddressesByAccountIds(List<String> accountIds) {
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
                AND Inactive_vod__c = false
        ];
    }

    /*Methos used by SFA-US brand users - ignore inactive flag.*/
    public static List<Address_vod__c> getAllAddressesByAccountIds(List<String> accountIds) {
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
        ];
    }

    public static List<Account> getAccountDetailsByAccountIds(List<String> accountIds) {
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
        ];
    }

    public static List<Speaker_Bureau_Membership_gne__c> getSpeakerBureauMembershipByAccountIds(List<String> accountIds) {
        return  [
            SELECT
                Id,
                Name,
                Speaker_Bureau_ID_gne__r.Name,
                Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c,
                Bureau_Member_gne__c,
                Speaker_Category_gne__c,
                Contract_Active_gne__c,
                Speaker_Scope_gne__c,
                Nomination_Date_gne__c,
                Meets_Speaker_Criteria_gne__c,
                Speaker_Status_gne__c,
                EDM_Bureau_Type_gne__c,
                Exclusion_Status_gne__c,
                LastModifiedDate,
                CreatedDate
            FROM
                Speaker_Bureau_Membership_gne__c
            WHERE
                Bureau_Member_gne__c in :accountIds
        ];
    }
    
    public static List<Medical_Communication_gne__c> getMedicalCommunicationsAccountsByUserUnixId(String unixId) {
        return  [
            SELECT Account_gne__c
            FROM Medical_Communication_gne__c
            WHERE CreatedBy.External_ID_gne__c = :unixId
                AND CreatedDate >= LAST_N_DAYS:180
        ];
    }

    public static List<Medical_Communication_gne__c> getMedicalCommunicationByAccountIds(List<String> accountIds) {
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
                AND Open_Date_gne__c >= LAST_N_DAYS:180
        ];
    }

    public static List<Referral_Assignment_gne__c> getMedicalCommunicationReferralsByUnixId(String unixId) {
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
            ORDER BY CreatedDate DESC
        ];
    }

    public static List<Medical_Communication_gne__c> getMedicalCommunicationByRequestId(String iphoneRequestId) {
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
                iPhone_Request_Id_gne__c,
                CreatedDate,
                Referral_Assignment_gne__c,
                Requested_By_gne__c,
                Requested_Completion_Date_gne__c,
                Language_of_Preference_can_gne__c,
                Unsolicited_Request_Verified_gne__c,
                Referral_History_gne__c,
                Comments_Referral_gne__c
            FROM
                Medical_Communication_gne__c
            WHERE
                iPhone_Request_Id_gne__c =:iphoneRequestId
        ];
    }

    public static List<Medical_Communication_gne__c> getMedicalCommunicationById(String recordId) {
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
                iPhone_Request_Id_gne__c,
                CreatedDate,
                Referral_Assignment_gne__c,
                Requested_By_gne__c,
                Requested_Completion_Date_gne__c,
                Language_of_Preference_can_gne__c,
                Unsolicited_Request_Verified_gne__c,
                Referral_History_gne__c,
                Comments_Referral_gne__c
            FROM
                Medical_Communication_gne__c
            WHERE
                Id =:recordId
        ];
    }

    public static List<Event_Attendee_vod__c> getEventAttendeesByAccountIds(List<String> accountIds) {
       return  [
           SELECT
               Id,
               Name,
               Status_vod__c,
               Role_gne__c,
               Willing_to_Interact_gne__c,
               Departure_Date_gne__c,
               Attendee_Type_vod__c,
               Interaction_type_gne__c,
               Medical_Event_vod__r.Name,
               Arrival_Date_gne__c,
               Account_vod__c,
               Event_Status_gne__c,
               Event_Type_gne__c,
               Medical_Event_vod__r.Event_Sub_Type_Code_gne__c,
               Medical_Event_vod__r.Start_Date_vod__c,
               Medical_Event_vod__r.timing_gne__c,
               Medical_Event_vod__r.event_medium_type_gne__c,
               Medical_Event_vod__r.Location_gne__c,
               Meal_Consumption_Status_gne__c, 
               Event_ID_gne__c,
               Medical_Event_vod__r.Time_Zone_gne__c,
               Medical_Event_vod__r.Start_Time_gne__c,               
               LastModifiedDate,
               CreatedDate
           FROM
               Event_Attendee_vod__c
           WHERE
               Account_vod__c in :accountIds
       ];
   }

    public static List<User_Preference_gne__c> getUserPreferencesByUserId(String userId) {
        return  [
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
        ];
    }

    public static Account getAccountById(String accountId) {
        return  [
            SELECT
                id,
                name,
                firstname,
                lastname,
                middle_vod__c,
                suffix_gne__c,
                suffix_vod__c,
                professional_type_gne__c,
                credentials_gne__c,
                specialties_gne__c,
                specialties_can_gne__c,
                ispersonaccount,
                account_type_gne__c,
                group_specialty_1_vod__c,
                stewardship_system_name_gne__c,
                ams_id_gne__c,
                mdmid_gne__c,
                Gender_vod__c
            FROM
                Account
            WHERE
                id =: accountId
        ];
    }

    public static Id getRecordTypeId(String recordTypeName, String sObjType) {
        return  [
            SELECT
                Id
            FROM
                RecordType
            WHERE
                    IsActive    =   true
                AND Name        =:  recordTypeName
                AND sObjectType =:  sObjType
        ].Id;
    }

    public static Id getRecordTypeIdByDeveloperName(String recordTypeDeveloperName, String sObjType) {
        return  [
            SELECT
                Id
            FROM
                RecordType
            WHERE
                    IsActive    =   true
                AND DeveloperName        =:  recordTypeDeveloperName
                AND sObjectType =:  sObjType
        ].Id;
    }

    public static Address_vod__c getAddressById(String addressId) {
         return [
            SELECT
                Id,
                Name,
                city_vod__c,
                state_vod__c,
                zip_vod__c,
                address_line_2_vod__c,
                address_line_3_gne__c,
                address_Line_4_gne__c,
                account_vod__r.Id, account_vod__r.name,
                account_vod__r.isPersonAccount,
                account_vod__r.stewardship_system_name_gne__c,
                Postal_Code_can_gne__c,
                Province_can_gne__c
            FROM
                Address_vod__c
            WHERE
                id =: addressId
        ];
    }

    public static Profile getProfileById(String profileId) {
        return  [
            SELECT
                Id,
                Name
            FROM
                Profile
            WHERE
                Id = :profileId
        ];
    }
    
    public static List<Change_Request_gne__c> getDCRsAccountsByUserUnixId(String unixId) {
        return  [
            SELECT Account_gne__c
            FROM Change_Request_gne__c
            WHERE CreatedBy.External_ID_gne__c = :unixId
                AND CreatedDate >= LAST_N_DAYS:180
        ];
    }

    public static List<Change_Request_gne__c> getChangeRequestsByAccountIds(List<String> accountIds) {
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
            AND LastModifiedDate = LAST_N_DAYS:180
            ORDER BY
                CreatedDate, Account_gne__c
        ];
    }

    public static List<Questionnaire_gne__c> getQuestionnaires() {
        return [
            SELECT
                Id,
                Category_gne__c,
                Type_gne__c,
                Name,
                    (   SELECT
                            Id,
                            Name,
                            Type_gne__c,
                            Questionnaire_gne__c,
                            CreatedDate,
                            Force_Ranking_Value_gne__c,
                            Help_Text_gne__c,
                            Labels_gne__c,
                            LastModifiedDate,
                            Maximum_Score_gne__c,
                            Minimum_Score_gne__c,
                            Multiple_Responses_gne__c,
                            Position_gne__c,
                            Region_Code_gne__c,
                            Category_gne__c,
                            Title_gne__c,
                            Values_gne__c,
                            Weight_gne__c
                        FROM
                            Questions__r
                    )
                FROM
                    Questionnaire_gne__c
                WHERE
                    Ready_For_Use_gne__c    = true  AND
                    ProductSpecific_gne__c  = false AND
                    Hide_Surveys_gne__c     = false AND
                    Freeze_Surveys_gne__c   = false AND
                    Category_gne__c         != null AND
                    Audience_Type_gne__c    = 'General'
        ];
    }

    public static Referral_Assignment_gne__c getReferralAssignmentById(String id) {
        return  [
            SELECT
                Id,
                Name,
                Call2_vod__c,
                Status_Referral_gne__c,
                Status_Referral_Date_gne__c,
                Status_Email_gne__c,
                Status_Email_Date_gne__c,
                Assigned_To_gne__c,
                Referral_Assigned_User_Email_gne__c,
                Assigned_To_Manager_gne__c,
                Referral_Assigned_Manager_Email_gne__c,
                Medical_Request_gne__c,
                Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c,
                Revised_Requested_Completion_Date_gne__c,
                Due_Date_gne__c,
                Escalation_Status_gne__c
            FROM
                Referral_Assignment_gne__c
            WHERE
                Id = :id
        ];
    }

    public static List<Referral_Assignment_gne__c> getReferralAssignmentByUserId(String userId) {
        return  [
            SELECT
                Id,
                AccountId_gne__c
            FROM
                Referral_Assignment_gne__c
            WHERE
                Assigned_To_gne__c =: userId
        ];
    }

    public static Map<Id, Question_gne__c> getQuestionsMapByIds(List<String> questionIds) {
        return new Map<Id, Question_gne__c>([
            SELECT
                Id,
                Name,
                Type_gne__c,
                Questionnaire_gne__c,
                CreatedDate,
                Force_Ranking_Value_gne__c,
                Help_Text_gne__c,
                Labels_gne__c,
                LastModifiedDate,
                Maximum_Score_gne__c,
                Minimum_Score_gne__c,
                Multiple_Responses_gne__c,
                Position_gne__c,
                Region_Code_gne__c,
                Category_gne__c,
                Title_gne__c,
                Values_gne__c,
                Weight_gne__c
            FROM
                Question_gne__c
            WHERE
                id in :questionIds
        ]);
    }

    public static List<SFA2_Configuration_Object_gne__c> getUIConfigurationObjects(String objectApiName, String appName, String brandName, String roleName){
        return [
            SELECT
                Id,
                Name,
                Role_gne__c,
                Object_Name_gne__c,
                Section_Header_gne__c,
                Record_Type_gne__c,
                Brand_gne__c,
                Order_gne__c,
                External_ID_gne__c
            FROM
                SFA2_Configuration_Object_gne__c
            WHERE
                Object_Name_gne__c              = :objectApiName
                AND Role_gne__c                 = :roleName
                AND Brand_gne__c                = :brandName
                AND Application_Type__c         = :appName
                AND Configuration_Type_gne__c   = 'Page'
                AND Is_Active_gne__c            = true
                //AND OTR2_gne__c                   = true
            ORDER BY
                Order_gne__c, Section_Header_gne__c
        ];
    }

    public static List<SFA2_Configuration_Object_Detail_gne__c> getUIConfigurationObjectsDetails(List<SFA2_Configuration_Object_gne__c> cfgObjectIds){
        return  [
            SELECT
                Id,
                Name,
                Configuration_Object_ref_gne__c,
                API_Name_gne__c,
                Label_gne__c,
                Attributes_gne__c,
                Is_Read_Only_gne__c,
                Is_Required_gne__c,
                Order_gne__c,
                Style_gne__c,
                Type_gne__c,
                Availability_Mode_gne__c
            FROM
                SFA2_Configuration_Object_Detail_gne__c
            WHERE
                    Is_Active_gne__c            = true
                //AND OTR2_gne__c                   = true
                AND Configuration_Object_ref_gne__c in :cfgObjectIds
            ORDER BY
                Order_gne__c, API_Name_gne__c
        ];
    }

    public static SFA2_User_Sales_Roster_gne__c getSalesRosterByUserId(String userId) {
        return (SFA2_User_Sales_Roster_gne__c)getFirstSObject([
            SELECT
                Sales_Roster_gne__r.Type_gne__c,
                Sales_Roster_gne__r.Brand_Name_gne__c,
                Role_gne__c
            FROM
                SFA2_User_Sales_Roster_gne__c
            WHERE
                    user_gne__c = :userId
                AND Sales_Roster_gne__r.Runs_in_SFA2_Mode_gne__c = true
        ]);
    }
    
    public static List<Call2_vod__c> getCallsByAccountIds(List<String> accountIds) {
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
                AND Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_vod__c> getCallsCreatedByUser(User user) {
        return [
                SELECT
                    Account_vod__c
                FROM
                    Call2_vod__c
                WHERE
                    CreatedById =: user.Id
                AND Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_vod__c> getCallsIdsByAccountIds(List<String> accountIds) {
        return  [
            SELECT
                Id
            FROM
                Call2_vod__c
            WHERE
                    Account_vod__c in :accountIds
                AND Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Parent_Call_vod__c = null
        ];
    }

    public static List<Survey_gne__c> getSurveysByAccountIds(List<String> accountIds) {
        String toQuestionnaireRelName = Survey_gne__c.Questionnaire_gne__c.getDescribe().getRelationshipName();
        String fieldsToSelect = String.join(
            new List<String>{
                'Id',
                'Name',
                'CreatedById',
                'CreatedDate',
                'OwnerId',
                'LastModifiedDate',
                'CreatedBy.Name',
                String.valueOf(Survey_gne__c.Title_gne__c),
                String.valueOf(Survey_gne__c.Type_gne__c),
                String.valueOf(Survey_gne__c.Version_gne__c),
                String.valueOf(Survey_gne__c.Total_Score_gne__c),
                String.valueOf(Survey_gne__c.Survey_Status_gne__c),
                String.valueOf(Survey_gne__c.Questionnaire_gne__c),
                String.valueOf(Survey_gne__c.Account__c),
                String.valueOf(Survey_gne__c.Category_gne__c),
                String.valueOf(Survey_gne__c.Product_Metrics_vod__c),
                String.valueOf(Survey_gne__c.iPhone_Request_Id_gne__c),
                toQuestionnaireRelName + '.LastModifiedDate'
            },
            ', '
        );

        String whereClause = String.format('{0} IN :accountIds AND LastModifiedDate = {1}'
            , new String[]{
                String.valueOf(Survey_gne__c.Account__c),
                (GNE_SFA2_Util.isCanadaUser() ? 'LAST_N_DAYS:365' : 'LAST_N_DAYS:180')
            }
        );

        String selQuery = String.format('SELECT {0} FROM Survey_gne__c WHERE {1}',
            new String[]{
                fieldsToSelect,
                whereClause
            }
        );
        return Database.query(selQuery);
    }

    public static List<Survey_gne__c> getSurveysByBrandAffiliationIds(List<String> brandAffiliationIds) {
        String toQuestionnaireRelName = Survey_gne__c.Questionnaire_gne__c.getDescribe().getRelationshipName();
        String fieldsToSelect = String.join(
            new List<String>{
                'Id',
                'Name',
                'CreatedById',
                'CreatedDate',
                'OwnerId',
                'LastModifiedDate',
                'CreatedBy.Name',
                String.valueOf(Survey_gne__c.Title_gne__c),
                String.valueOf(Survey_gne__c.Type_gne__c),
                String.valueOf(Survey_gne__c.Version_gne__c),
                String.valueOf(Survey_gne__c.Total_Score_gne__c),
                String.valueOf(Survey_gne__c.Survey_Status_gne__c),
                String.valueOf(Survey_gne__c.Questionnaire_gne__c),
                String.valueOf(Survey_gne__c.Account__c),
                String.valueOf(Survey_gne__c.Category_gne__c),
                String.valueOf(Survey_gne__c.Product_Metrics_vod__c),
                String.valueOf(Survey_gne__c.iPhone_Request_Id_gne__c),
                toQuestionnaireRelName + '.LastModifiedDate'
            },
            ', '
        );

        String whereClause = String.format('{0} IN :brandAffiliationIds AND LastModifiedDate = {1}'
            , new String[]{
                String.valueOf(Survey_gne__c.Product_Metrics_vod__c),
                (GNE_SFA2_Util.isCanadaUser() ? 'LAST_N_DAYS:365' : 'LAST_N_DAYS:180')
            }
        );

        String selQuery = String.format('SELECT {0} FROM Survey_gne__c WHERE {1}',
            new String[]{
                fieldsToSelect,
                whereClause
            }
        );

        return Database.query(selQuery);
    }

    public static List<Survey_Response_gne__c> getSurveyResponsesByAccountIds(List<String> accountIds) {
        String toQuestionRelName = Survey_Response_gne__c.Question_gne__c.getDescribe().getRelationshipName();
        String toSurveyRelName = Survey_Response_gne__c.Survey_gne__c.getDescribe().getRelationshipName();

        String fieldsToSelect = String.join(
            new List<String>{
                'Id',
                'CreatedBy.Name',
                'CreatedById',
                'CreatedDate',
                'LastModifiedDate',
                String.valueOf(Survey_Response_gne__c.Force_Ranking_Value_gne__c),
                String.valueOf(Survey_Response_gne__c.Free_Text_gne__c),
                String.valueOf(Survey_Response_gne__c.Full_Title_gne__c),
                String.valueOf(Survey_Response_gne__c.Help_Text_gne__c),
                String.valueOf(Survey_Response_gne__c.Labels_gne__c),
                String.valueOf(Survey_Response_gne__c.Maximum_Score_gne__c),
                String.valueOf(Survey_Response_gne__c.Minimum_Score_gne__c),
                String.valueOf(Survey_Response_gne__c.Multiple_Responses_gne__c),
                String.valueOf(Survey_Response_gne__c.Position_gne__c),
                String.valueOf(Survey_Response_gne__c.Question_gne__c),
                String.valueOf(Survey_Response_gne__c.Report_Value_gne__c),
                String.valueOf(Survey_Response_gne__c.Response_Score_gne__c),
                String.valueOf(Survey_Response_gne__c.Category_gne__c),
                String.valueOf(Survey_Response_gne__c.Selected_Label_gne__c),
                String.valueOf(Survey_Response_gne__c.Selected_Values_gne__c),
                String.valueOf(Survey_Response_gne__c.Survey_gne__c),
                String.valueOf(Survey_Response_gne__c.Title_gne__c),
                String.valueOf(Survey_Response_gne__c.Type_gne__c),
                String.valueOf(Survey_Response_gne__c.Values_gne__c),
                String.valueOf(Survey_Response_gne__c.Weight_gne__c),
                String.valueOf(Survey_Response_gne__c.Weighted_Score_gne__c),
                toQuestionRelName + '.LastModifiedDate',
                toQuestionRelName + '.' + String.valueOf(Question_gne__c.Type_gne__c)
            },
            ', '
        );

        String whereClause = String.format('{0} IN :accountIds AND LastModifiedDate = {1}'
            , new String[]{
                toSurveyRelName + '.' + String.valueOf(Survey_gne__c.Account__c),
                (GNE_SFA2_Util.isCanadaUser() ? 'LAST_N_DAYS:365' : 'LAST_N_DAYS:180')
            }
        );

        String selQuery = String.format('SELECT {0} FROM Survey_Response_gne__c WHERE {1}',
            new String[]{
                fieldsToSelect,
                whereClause
            }
        );

        return Database.query(selQuery);
    }

    public static List<Survey_Response_gne__c> getSurveyResponsesByBrandAffiliationIds(List<String> brandAffiliationIds) {
        String toQuestionRelName = Survey_Response_gne__c.Question_gne__c.getDescribe().getRelationshipName();
        String toSurveyRelName = Survey_Response_gne__c.Survey_gne__c.getDescribe().getRelationshipName();

        String fieldsToSelect = String.join(
            new List<String>{
                'Id',
                'CreatedBy.Name',
                'CreatedById',
                'CreatedDate',
                'LastModifiedDate',
                String.valueOf(Survey_Response_gne__c.Force_Ranking_Value_gne__c),
                String.valueOf(Survey_Response_gne__c.Free_Text_gne__c),
                String.valueOf(Survey_Response_gne__c.Full_Title_gne__c),
                String.valueOf(Survey_Response_gne__c.Help_Text_gne__c),
                String.valueOf(Survey_Response_gne__c.Labels_gne__c),
                String.valueOf(Survey_Response_gne__c.Maximum_Score_gne__c),
                String.valueOf(Survey_Response_gne__c.Minimum_Score_gne__c),
                String.valueOf(Survey_Response_gne__c.Multiple_Responses_gne__c),
                String.valueOf(Survey_Response_gne__c.Position_gne__c),
                String.valueOf(Survey_Response_gne__c.Question_gne__c),
                String.valueOf(Survey_Response_gne__c.Report_Value_gne__c),
                String.valueOf(Survey_Response_gne__c.Response_Score_gne__c),
                String.valueOf(Survey_Response_gne__c.Category_gne__c),
                String.valueOf(Survey_Response_gne__c.Selected_Label_gne__c),
                String.valueOf(Survey_Response_gne__c.Selected_Values_gne__c),
                String.valueOf(Survey_Response_gne__c.Survey_gne__c),
                String.valueOf(Survey_Response_gne__c.Title_gne__c),
                String.valueOf(Survey_Response_gne__c.Type_gne__c),
                String.valueOf(Survey_Response_gne__c.Values_gne__c),
                String.valueOf(Survey_Response_gne__c.Weight_gne__c),
                String.valueOf(Survey_Response_gne__c.Weighted_Score_gne__c),
                toQuestionRelName + '.LastModifiedDate',
                toQuestionRelName + '.' + String.valueOf(Question_gne__c.Type_gne__c)
            },
            ', '
        );

        String whereClause = String.format('{0} IN :brandAffiliationIds AND LastModifiedDate = {1}'
            , new String[]{
                toSurveyRelName + '.' + String.valueOf(Survey_gne__c.Product_Metrics_vod__c),
                (GNE_SFA2_Util.isCanadaUser() ? 'LAST_N_DAYS:365' : 'LAST_N_DAYS:180')
            }
        );

        String selQuery = String.format('SELECT {0} FROM Survey_Response_gne__c WHERE {1}',
            new String[]{
                fieldsToSelect,
                whereClause
            }
        );

        return Database.query(selQuery);
    }

    public static List<Call2_Detail_vod__c> getCallDetailsByAccountIds(List<String> accountIds) {
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
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Interaction_Detail_vod__c> getCallInteractionDetailsByAccountIds(List<String> accountIds) {
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
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Category_vod__c> getCallCategoriesByAccountIds(List<String> accountIds) {
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
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Discussion_vod__c> getCallDiscussionsByAccountIds(List<String> accountIds) {
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
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }
    
    public static List<Call2_Threat_vod__c> getCallThreatsByAccountIds(List<String> accountIds) {
        return [
            SELECT Id, Product_vod__c, Book_of_Business__c, Requested_Position__c, Rebate__c, Requested_Start_Date__c, Risk_Level__c, Initial_Assessment__c, Call2_vod__c, CreatedDate, LastModifiedDate
            FROM Call2_Threat_vod__c
            WHERE Call2_vod__r.Account_vod__c IN : accountIds
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Key_Message_vod__c> getCallKeyMessagesByAccountIds(List<String> accountIds) {
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
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

        public static List<Call_Pre_Call_gne__c> getCallPreCallsByAccountIds(List<String> accountIds) {
        return [
            SELECT
                Id,
                Name,
                Customer_Segment_gne__c,
                Decision_Cycle_gne__c,
                Questions_gne__c,
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
                AND Call_gne__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call_gne__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call_gne__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call_PFG_Detail_gne__c> getCallPFGDetailsByAccountIds(List<String> accountIds) {
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
                AND Call_gne__c IN (SELECT Id
                                    FROM Call2_vod__c
                                    WHERE Account_vod__c IN :accountIds
                                        AND Call_Datetime_vod__c >= LAST_N_DAYS:180
                                        AND Call_Datetime_vod__c <= NEXT_N_DAYS:180
                                        AND Parent_Call_vod__c = null)
        ];
    }

    public static List<Call2_Sample_vod__c> getCallSamplesByAccountIds(List<String> accountIds) {
        return [
            SELECT
                Id,
                Account_vod__c,
                Contact_vod__c,
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
                AND Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c = null
        ];
    }

    public static List<Call2_Sample_vod__c> getCallSamplesByParentCallIds(List<Call2_vod__c> parentCallIds) {
        return [
            SELECT
                Id,
                Account_vod__c,
                Contact_vod__c,
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
                    Call2_vod__r.Call_Datetime_vod__c >= LAST_N_DAYS:180
                AND Call2_vod__r.Call_Datetime_vod__c <= NEXT_N_DAYS:180
                AND Call2_vod__r.Parent_Call_vod__c in : parentCallIds
        ];
    }

    public static List<Call2_vod__c> getCallsByParentIds(List<Call2_vod__c> parentCallIds) {
        return [
            SELECT
                Id,
                Parent_Call_vod__c,
                Parent_Call_vod__r.Interaction_Status_gne__c,
                Attendee_Type_vod__c,
                Account_vod__c,
                Account_vod__r.Name,
                Account_vod__r.PREP_Professional_Type_gne__c,
                Account_vod__r.PREP_Status_gne__c,
                Account_vod__r.iPhone_Fields_LastModifiedDate_gne__c,
                Contact_vod__r.LastModifiedDate,
                Contact_vod__c,
                Contact_vod__r.Name,
                User_vod__c,
                User_vod__r.Name,
                HCP_Attendee_Meal_Opt_Out_gne__c,
                PREP_Status_gne__c,
                CreatedDate,
                LastModifiedDate
            FROM
                Call2_vod__c
            WHERE
                Parent_Call_vod__c IN : parentCallIds AND EMS_International_Speaker_gne__c = null
        ];
    }

    public static List<GNE_SFA2_Ratings_Configuration__c> getRatingsConfiguration(String roleName, String brandName, String appType) {
        return [
            SELECT
                Columns_List_gne__c, Record_Type_gne__c
            FROM
                GNE_SFA2_Ratings_Configuration__c
            WHERE
                    Role_gne__c             =: roleName
                AND Brand_gne__c            =: brandName
                AND Application_Type_gne__c =: appType
        ];
    }

    public static List<Product_vod__c> getUserSetupProducts(String userId) {
        return [
            SELECT
                Id,
                Name,
                Parent_Product_vod__c,
                CreatedDate,
                LastModifiedDate,
                Product_Type_vod__c,
                Detail_Product_Subtype_Code_gne__c,
                active__c,
                (SELECT Product_vod__c, CreatedDate, LastModifiedDate
                    FROM My_Setup_Products_vod__r
                    WHERE OwnerId =: userId
                    ORDER BY LastModifiedDate Desc
                    LIMIT 1)
            FROM
                Product_vod__c
            WHERE Id IN (
                    SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId =: userId
                  )
            ORDER BY
                Name
        ];
    }

    public static GNE_SFA2_User_App_Context_gne__c insertUserAppliactionContext(String userId, String appName, String brandName, String roleName) {
        GNE_SFA2_User_App_Context_gne__c appCtx = new GNE_SFA2_User_App_Context_gne__c(SetupOwnerId = userId, App_Name_gne__c = appName, Brand_gne__c = brandName, Role_gne__c = roleName, SFA2_Mode_gne__c = true);
        insert appCtx;
        return appCtx;
    }


    public static List<UserRecordAccess> getUserAccessibleRecords(String userId, List<Id> recordIds) {
       return [
            SELECT
                RecordId
            FROM
                UserRecordAccess
            WHERE
                    UserId = :userId
                AND HasReadAccess = true
                AND RecordId IN :recordIds
       ];
    }

    public static List<Affiliation_vod__c> getAccountAffiliationsNoContactsByAccountIds(List<String> accountIds) {
        String query = getAccountAffiliationsQuery();
        return Database.query(query + 'WHERE From_Account_vod__c in :accountIds AND To_Contact_vod__c = null');
    }

    public static List<Affiliation_vod__c> getAccountAffiliationsWithContactsByAccountIds(List<String> accountIds) {
        String query = getAccountAffiliationsQuery();
        return Database.query(query + 'WHERE From_Account_vod__c IN :accountIds AND To_Contact_vod__c != null AND To_Contact_vod__r.Active_gne__c = true');
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
                String.valueOf(Affiliation_vod__c.Affiliation_Type_gne__c),
                String.valueOf(Affiliation_vod__c.Influence_vod__c),
                String.valueOf(Affiliation_vod__c.Comments_vod__c),
                String.valueOf(Affiliation_vod__c.MDM_ID_gne__c),
                toAccountRelName + '.LastName',
                toAccountRelName + '.FirstName',
                toAccountRelName + '.IsPersonAccount',
                toAccountRelName + '.Name',
                toAccountRelName + '.' + String.valueOf(Account.iPhone_Fields_LastModifiedDate_gne__c),
                toAccountRelName + '.' + String.valueOf(Account.PREP_Status_gne__c),
                toAccountRelName + '.' + String.valueOf(Account.PREP_Professional_Type_gne__c),
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
                toContactRelName + '.Has_Opted_Out_gne__c',
                toContactRelName + '.phone',
                toContactRelName + '.firstname',
                toContactRelName + '.CreatedDate',
                toContactRelName + '.LastModifiedDate',
                toContactRelName + '.Name',
                toContactRelName + '.' + String.valueOf(Contact.Website_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.LinkedIn_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Type_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Twitter_gne__c),
                'CreatedDate',
                'LastModifiedDate',
                String.valueOf(Affiliation_vod__c.Primary_gne__c),
                String.valueOf(Affiliation_vod__c.Primary_fpm_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.IsPersonAccount),
                toContactRelName + '.' + String.valueOf(Contact.AccountId),
                toContactRelName + '.' + String.valueOf(Contact.Professional_Type_2_frm_gne__c),
                toContactRelName + '.' + String.valueOf(Contact.Active_gne__c)
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

    public static List<Account_Plan_vod__c> getAccountPlansByAccountIds(List<String> accountIds) {
        return [
            SELECT
                Id,
                Name,
                Account_vod__c,
                Segment_gne__c,
                Team_gne__c,
                CreatedDate,
                Active_vod__c,
                LastmodifiedDate
            FROM
                Account_Plan_vod__c
            WHERE
                Account_vod__c IN :accountIds
        ];
    }

    public static List<Account_Tactic_vod__c> getAccountTacticsByAccountIds(List<String> accountIds) {
        return [
            SELECT
                Id,
                Name,
                Account_vod__c,
                Account_Plan_vod__c,
                CreatedDate,
                LastmodifiedDate
            FROM
                Account_Tactic_vod__c
            WHERE
                Account_Plan_vod__c IN (
                    SELECT
                        Id
                    FROM
                        Account_Plan_vod__c
                    WHERE
                        Account_vod__c IN :accountIds
                )
        ];
    }

    public static List<Product_vod__c> getAllProductsForMedAffairsMoleculeNames(List<Id> productOwnerQueueId, List<String> medAffairsMoleculeNames) {
        return [
            SELECT
                Id
            FROM
                Product_vod__c
            WHERE
                    Name NOT IN : medAffairsMoleculeNames
                AND OwnerId NOT IN : ProductOwnerQueueId
                AND Product_Type_vod__c = 'Detail'
                AND Detail_Product_Subtype_Code_gne__c = 'TheraDisease'
            ORDER BY Name
        ];
    }

    public static List<Product_vod__c> getAllProductsForMedAffairsMoleculeNames(List<String> medAffairsMoleculeNames) {
        return [
            SELECT
                Id
            FROM
                Product_vod__c
            WHERE
                    Name NOT IN : medAffairsMoleculeNames
                AND Product_Type_vod__c = 'Detail'
                AND Detail_Product_Subtype_Code_gne__c = 'TheraDisease'
            ORDER BY Name
        ];
    }

    public static List<Referral_Roster_Detail_gne__c> getAllReferralRosterDetails(List<Product_vod__c> tASubTAsList) {
        List<Id> taSubTAIdsList = new List<Id>();
        for(Product_vod__c prod : tASubTAsList){
            taSubTAIdsList.add(prod.id);
        }
        return [
            SELECT
                Id,
                Product_TA_SubTA_gne__c
            FROM
                Referral_Roster_Detail_gne__c
            WHERE
                Product_TA_SubTA_gne__c IN : tASubTAIdsList
            ORDER BY Product_TA_SubTA_gne__c
        ];
    }

    public static List<Referral_Roster_Detail_gne__c> getAllReferralRosterDetails(List<Id> tASubTAIdsList) {
        return [
          SELECT
                Id,
                Product_TA_SubTA_gne__c
          FROM
                Referral_Roster_Detail_gne__c
          WHERE
                Product_TA_SubTA_gne__c IN : tASubTAIdsList
          ORDER BY Product_TA_SubTA_gne__c
        ];
    }

    public static List<Product_vod__c> getAllProductsWithoutMySetup(String userId) {
        return [
            SELECT
                Id,
                Name,
                Product_type_vod__c,
                Detail_product_subtype_code_gne__c,
                TheraDisease_Reference_gne__c,
                Parent_Product_vod__c,
                No_details_vod__c
            FROM
                Product_vod__c
            WHERE
                (    Product_Type_vod__c = 'Detail'
                  OR Detail_Product_Subtype_Code_gne__c = 'Molecule'
                )
                AND Id NOT IN ( SELECT
                                    Product_vod__c
                                FROM
                                    My_Setup_Products_vod__c
                                WHERE
                                    OwnerId =: userId
                              )
            ORDER BY TheraDisease_Reference_gne__c
        ];
    }

    public static List<Product_vod__c> getMySetupProducts(String userId) {
        return [
            SELECT
                Id,
                Name,
                Product_type_vod__c,
                Detail_product_subtype_code_gne__c,
                TheraDisease_Reference_gne__c,
                Parent_Product_vod__c,
                No_details_vod__c
            FROM
                Product_vod__c
            WHERE
                (    Product_Type_vod__c = 'Detail'
                  OR Detail_Product_Subtype_Code_gne__c = 'Molecule'
                )
                AND Id IN ( SELECT
                                    Product_vod__c
                                FROM
                                    My_Setup_Products_vod__c
                                WHERE
                                    OwnerId =: userId
                              )
            ORDER BY TheraDisease_Reference_gne__c
        ];
    }

    public static List<Product_vod__c> getAllChildProducts(Set<String> productsIds) {
        return [
            SELECT
                Id,
                Name,
                Product_type_vod__c,
                Detail_product_subtype_code_gne__c,
                TheraDisease_Reference_gne__c,
                Parent_Product_vod__c,
                No_details_vod__c
            FROM
                Product_vod__c
            WHERE
                    Parent_Product_vod__c IN : productsIds
                AND Parent_Product_vod__r.Product_Type_vod__c = 'Detail'
                AND Product_Type_vod__c NOT IN ('Detail','BRC','Submarket','Market')
            ORDER BY TheraDisease_Reference_gne__c
        ];
    }

    public static List<Speaker_Training_gne__c> getSpeakerTrainingsByAccountIds(List<String> accountsIds) {
        return [
            SELECT
                Id,
                Name,
                Speaker_gne__c,
                Speaker_gne__r.MDMId_gne__c,
                CreatedBy.Id,
                CreatedBy.Name,
                CreatedDate,
                LastmodifiedDate,
                Curriculum_Name__c,
                Curriculum_Status1__c,
                Trained_Date_gne__c,
                Training_Status_gne__c,
                Delivery_Method_gne__c,
                Event_Curriculum_gne__c,
                Speaker_gne__r.Name,
                Event_Curriculum_gne__r.Deactivation_date_gne__c
            FROM
                Speaker_Training_gne__c
            WHERE
                Speaker_gne__c IN : accountsIds
            ORDER BY Speaker_gne__c
        ];
    }

    public static List<Curriculum_Module_gne__c> getModulesForPRC() {
        return [
            SELECT
                Id,
                PRC_Id_gne__c,
                Event_Curriculum_gne__c
            FROM
                Curriculum_Module_gne__c
        ];
    }

    public static List<Event_Curriculum_gne__c> getEventCurriculums() {
        return [
            SELECT
                Id,
                Name
            FROM
                Event_Curriculum_gne__c
            ORDER BY Name
        ];
    }

    public static SObject getFirstSObject(List<SObject> sObjects) {
        if(sObjects.size() == 0)
            return null;
        return sObjects[0];
    }

    public static List<GroupMember> getAffiliationsUserMode(Id userId) {
        return [
            SELECT
                Id
            FROM
                GroupMember
            WHERE GroupId IN ( SELECT
                                   Id
                               FROM
                                   Group
                               WHERE
                                   Name = 'GNE-View-All-Brands-Users-Data-Group'
                             )
             AND UserOrGroupId =: userId LIMIT 1
        ];
    }

    public static List<ProfileID_License_gne__c> getAccountProfileId(List<String> accountIds) {
        return [
            SELECT
                Id,
                Account_Name_gne__c,
                State_gne__c,
                ID_License_gne__c,
                Address_gne__c,
                CreatedDate,
                LastModifiedDate
            FROM
                    ProfileID_License_gne__c
            WHERE
                Account_Name_gne__c in :accountIds
        ];
    }

    public static List<SFA2_PREP_Account_Testing_Strategy_gne__c> getPrepStrategiesByAccountIds(List<String> accountIds) {
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
                 FROM Account_MBOs_gne__r)
            FROM
                SFA2_PREP_Account_Testing_Strategy_gne__c
            WHERE
                Account_gne__c IN :accountIds
        ];
    }
    public static List<SFA2_PREP_Account_Testing_Info_gne__c> getPrepTestingInfoByAccountIds(List<String> accountIds) {
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
        ];
    }

    public static List<SFA2_Account_Society_Membership_gne__c> getSocietyMembershipsByAccountIds(List<String> accountIds) {
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
        ];
    }

    public static List<Distributor_fpm_gne__c> getAccountDistributorsByAccountIds(List<String> accountIds){
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
        ];
    }

    public static List<HIN_Number_fpm_gne__c> getAccountHINNumbersByAccountIds(List<String> accountIds){
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
        ];
    }

    public static List<Contact> getContactsByAccountIds(List<String> accountIds) {
        return [
            SELECT
                Id,
                Name,
                FirstName,
                LastName,
                AccountId,
                Account.Name,
                Email,
                Phone,
                CreatedDate,
                Title_gne__c,
                Title,
                Active_gne__c,
                Cell_Phone_frm_gne__c,
                LastModifiedDate,
                Inactive_Reason__c,
                IsPersonAccount,
                Salutation,
                Middle_frm_gne__c,
                Professional_Type_2_frm_gne__c,
                Preferred_Name_gne__c,
                Reimbursement_KOL_frm_gne__c,
                Primary_Main_Contact_frm_gne__c,
                AFRM_Additional_Target_frm_gne__c,
                BFRM_Additional_Target_frm_gne__c,
                EFRM_Additional_Target_frm_gne__c,
                GFRM_Additional_Target_frm_gne__c,
                IFRM_Additional_Target_frm_gne__c,
                NFRM_Additional_Target_frm_gne__c,
                PFRM_Additional_Target_frm_gne__c,
                RFRM_Additional_Target_frm_gne__c,
                RESPFRM_Additional_Target_frm_gne__c,
                AFRM_Survey_Contact_frm_gne__c,
                BFRM_Survey_Contact_frm_gne__c,
                EFRM_Survey_Contact_frm_gne__c,
                GFRM_Survey_Contact_frm_gne__c,
                IFRM_Survey_Contact_frm_gne__c,
                NFRM_Survey_Contact_frm_gne__c,
                PFRM_Survey_Contact_frm_gne__c,
                RFRM_Survey_Contact_frm_gne__c,
                RESPFRM_Survey_Contact_frm_gne__c,
                DO_NOT_CONTACT_gne__c,
                Has_Opted_Out_gne__c,
                Website_gne__c,
                iPhone_Request_Id_gne__c,
                Photo_gne__c,
            	Credentials_gne__c,
            	Ext_gne__c,
                Function_gne__c,
                ReportsTo.Name,
                ReportsToId,
            	Fax,
            	X340B_Contact__c,
            	OwnerId, Owner.Name,
            	Primary_Contact_gne__c,
            	Communication_Type_gne__c,
            	MailingStreet,
            	State_Province_gne__c,
            	MailingCity,
            	MailingPostalCode,
				MailingCountry,
            	Comments_frm_gne__c,
            	CreatedById, CreatedBy.Name,
            	LastModifiedById, 
            	LastModifiedBy.Name,
            	Function_Other_gne__c
            FROM
                Contact
            WHERE
                AccountId IN : accountIds AND
                Active_gne__c = true
        ];
    }

    public static Contact getContactById(String contactId) {
        return [
            SELECT
                Id,
                Name,
                FirstName,
                LastName,
                Email,
                Phone,
                Title_gne__c,
                Title,
                Active_gne__c,
                Cell_Phone_frm_gne__c,
                Inactive_Reason__c
            FROM
                Contact
            WHERE
                Id = : contactId
            LIMIT 1
        ];
    }

    public static Contact getContactPhotoById(String contactId){
        return (Contact)getFirstSObject([SELECT Id, Photo_gne__c FROM Contact WHERE Id = :contactId LIMIT 1]);
    }

    public static Contact getContactByiPhoneRequestId(String rId) {
        Contact result = new Contact();

        for(Contact c : [SELECT Id FROM Contact WHERE iPhone_Request_Id_gne__c = : rId LIMIT 1]) {
            result = c;
        }

        return result;
    }

    public static List<SObject> getRecordsWithRequestIds(Set<String> requestIds, String sObjName) {
        return Database.query('SELECT Id, iPhone_Request_Id_gne__c FROM ' + sObjName + ' WHERE iPhone_Request_Id_gne__c IN :requestIds');
    }

   /*
    * These two methods are need for new iPhone_Common_Tmp.cls for testing new Delta feature
    */
    public static List<Id> getContactsByAccountIdsTmp(List<String> accountIds, String lastSyncDateString) {
        List<Id> sObjectsId = new List<Id>();
        DateTime lastSyncDate = DateTime.valueofGmt(lastSyncDateString);

        for(SObject obj : [SELECT Id FROM Contact WHERE AccountId IN : accountIds AND ( LastModifiedDate > : lastSyncDate OR CreatedDate > : lastSyncDate )]) {
            sObjectsId.add(obj.Id);
        }

        return sObjectsId;
    }

    public static List<Contact> getContactsByIdsTmp(List<Id> sObjects) {
        return [
            SELECT
                Id,
                Name,
                FirstName,
                LastName,
                AccountId,
                Account.Name,
                Email,
                Phone,
                CreatedDate,
                Title_gne__c,
                Active_gne__c,
                Cell_Phone_frm_gne__c,
                LastModifiedDate,
                Inactive_Reason__c
            FROM
                Contact
            WHERE
                Id IN : sObjects

        ];
    }

    public static OTR_User_Device_gne__c getUserDeviceInfo(String deviceId, Id userId){
        List<OTR_User_Device_gne__c> deviceInfoList = [
            SELECT
                Id,
                Model_Name_gne__c,
                Model_Identifier_gne__c,
                IOS_Version_gne__c,
                OTR_Version_gne__c,
                Last_Stamp_Date_gne__c
            FROM
                OTR_User_Device_gne__c
            WHERE
                    Device_ID_gne__c = :deviceId
                AND User_gne__c = :userId
            LIMIT 1
        ];
        return deviceInfoList.size() == 1 ? deviceInfoList[0] : null;
    }

    public static List<MCE_gne__c> getMCEsByAccountIdsAndTeams(List<String> accountIds, Set<String> teamCodes, Set<String> subTeamCodes) {
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
        ];
    }

    public static List<GNE_MCCO_CRM_Field_Intelligence__c>getFieldIntelligence(List<Id>accountIds, User user){
        return [select Id, Name, CreatedBy.Name, LastModifiedDate, CreatedDate, Account_gne__c, Available_gne__c, Comment_gne__c, Field_Intelligence_Id_gne__c, Previous_Status__c, Survey_gne__c, Survey_Status_gne__c, Title_gne__c, User_gne__c, User_gne__r.Name,
                        (SELECT Answer_gne__c, Conditional_Answer_gne__c, Name, Group_Set_gne__c, Field_Intelligence_gne__c, MCCO_CRM_Survey_Group_gne__c, Survey_Question_gne__c, Id, iPhone_Request_Id_gne__c FROM Field_Intelligence_Answers__r)
                FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Account_gne__c IN :accountIds AND Available_gne__c = true];
    }

    public static GNE_MCCO_CRM_Field_Intelligence__c getFieldIntelligence(Id fieldIntelligenceId){
        return [select Id, Name, CreatedBy.Name, LastModifiedDate, CreatedDate, Account_gne__c, Available_gne__c, Comment_gne__c, Field_Intelligence_Id_gne__c, Previous_Status__c, Survey_gne__c, Survey_Status_gne__c, Title_gne__c, User_gne__c, User_gne__r.Name,
                        (SELECT Answer_gne__c, Conditional_Answer_gne__c, Name, Group_Set_gne__c, Field_Intelligence_gne__c, MCCO_CRM_Survey_Group_gne__c, Survey_Question_gne__c, Id, iPhone_Request_Id_gne__c FROM Field_Intelligence_Answers__r)
                FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Id = :fieldIntelligenceId];
    }

    public static List<GNE_MCCO_CRM_Field_Intelligence__c> getUserFieldIntelligence(Id userId){
        return [select Id, Name, CreatedBy.Name, LastModifiedDate, CreatedDate, Account_gne__c, Available_gne__c, Comment_gne__c, Field_Intelligence_Id_gne__c, Previous_Status__c, Survey_gne__c, Survey_Status_gne__c, Title_gne__c, User_gne__c, User_gne__r.Name,
                        (SELECT Answer_gne__c, Conditional_Answer_gne__c, Name, Group_Set_gne__c, Field_Intelligence_gne__c, MCCO_CRM_Survey_Group_gne__c, Survey_Question_gne__c, Id, iPhone_Request_Id_gne__c FROM Field_Intelligence_Answers__r)
                FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE User_gne__c = :userId AND Survey_gne__r.Record_Type_gne__c = 'General'];
    }

    public static List<ContentDocument> getContentDocuments(){
        return [
            SELECT
                Id,
                Title,
                Description,
                CreatedDate,
                ContentSize,
                FileExtension,
                LatestPublishedVersionId,
                LatestPublishedVersion.VersionNumber,
                LatestPublishedVersion.CreatedDate,
                LatestPublishedVersion.Owner.Name,
                LatestPublishedVersion.Document_Category__c,
                LatestPublishedVersion.Document_Type__c,
                LatestPublishedVersion.Progam_Type__c,
                LatestPublishedVersion.Use__c,
                LastModifiedDate,
                ParentId
            FROM
                ContentDocument
            WHERE
                Id IN (SELECT ContentDocumentId FROM ContentWorkspaceDoc)
        ];
    }

    public static List<FRM_HCO_Mapping_gne__c> getMappingsByAccountIds(List<String> accountIds) {
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
        ];
   }

   /*Return the oldest contact with the same first and last name for specific account*/
    public static Contact getContactByFirstAndLastName(String firstName, String lastName, String accountId){
        if(String.isNotEmpty(accountId) && String.isNotEmpty(firstName) && String.isNotEmpty(lastName)){
            List<Contact> existingContacts = [SELECT id FROM Contact WHERE accountId = :accountId AND FirstName = :firstName AND lastname = :lastName AND Active_gne__c = false order by lastmodifieddate limit 1];
            if(!existingContacts.isEmpty()) {
                return existingContacts.get(0);
            }
        }
        return null;
    }

    public static List<Zip_to_Territory_gne__c> getZipToTerritory(Set<String> terrNumbers){
        return [SELECT Territory_Number_gne__c, Zip_Code_gne__c FROM Zip_to_Territory_gne__c WHERE Territory_Number_gne__c  IN :terrNumbers LIMIT :RECORDS_LIMIT];
    }

    public static List<Prescriber_License_gne__c> getAccountLicenses(List<String> accountIds) {
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
        ];
    }

    public static List<TDDD_License_gne__c> getAccountTdddLicenses(List<String> accountIds) {
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
        ];
    }

    public static List<Independent_Insight_vod__c> getUserIndependentInsight(){
        return [SELECT
                        Id,
                        Name,
                        Account_gne__c,
                        CreatedDate,
                        CreatedBy.Name,
                        CreatedById,
                        LastModifiedDate,
                        Territory_gne__c,
                        Insight_Status_gne__c,
                        Title_gne__c,
                        Therapeutic_Area_gne__c,
                        Product_and_Indication_gne__c,
                        Insight_Description_gne__c
                FROM
                        Independent_Insight_vod__c
                WHERE
                        Call2_vod__c = ''
                ORDER BY
                        CreatedDate ASC
        ];
    }

}