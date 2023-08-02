/**
 *  Class whose sole responsibility is to create objects used for testing.
 **/
public with sharing class gFRS_TestCreationUtils {

/** English language type **/
    public static final String LANG_EN = 'en_US';

//-- profiles
    public static String PROF_GFRS_PORTAL_NAME = 'GNE-GFRS-External Requestor';
    public static id PROF_GFRS_PORTAL;
    public static String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
    public static id PROF_GFRS_USER;


//-- Record types used
    public static String RT_FR_CORPORATE_MEMBERSHIPS_NAME = 'Corporate_Memberships';
    public static id RT_FR_CORPORATE_MEMBERSHIPS;
    public static String RT_FR_EXHIBITS_OTHER_PROMOS_NAME = 'Exhibits_Other_Promos';
    public static id RT_FR_EXHIBITS_OTHER_PROMOS;
    public static String RT_FR_FELLOWSHIPS_NAME = 'Fellowships';
    public static id RT_FR_FELLOWSHIPS;
    public static String RT_FR_FIELD_INITIATED_EXHIBITS_NAME = 'Field_Initiated_Exhibits';
    public static id RT_FR_FIELD_INITIATED_EXHIBITS;
    public static String RT_FR_HC_CHAR_NAME = 'HC_Char';
    public static id RT_FR_HC_CHAR;
    public static String RT_FR_IMED_NAME = 'IMED';
    public static id RT_FR_IMED;
    public static String RT_FR_PHILANTHROPIC_NAME = 'Philanthropic';
    public static id RT_FR_PHILANTHROPIC;
    public static String RT_FR_SCIENTIFIC_PROJECTS_NAME = 'Scientific_Projects';
    public static id RT_FR_SCIENTIFIC_PROJECTS;

    public static String RT_ADMIN_BUDGET_CAPP_NAME = 'CAPP';
    public static id RT_ADMIN_BUDGET_CAPP;
    public static String RT_ADMIN_BUDGET_IMED_NAME = 'IMED';
    public static id RT_ADMIN_BUDGET_IMED;
    public static String RT_ADMIN_BUDGET_DEV_NAME = 'DEV';
    public static id RT_ADMIN_BUDGET_DEV;


/** determines whether the class has been initialized **/
    public static Boolean isInitialized = initialize();

/** initializes the static values for the class **/
    public static Boolean initialize() {
        //-- setup static items such as profiles etc.
        String[] requestedProfiles = new String[]{
                PROF_GFRS_PORTAL_NAME,
                PROF_GFRS_USER_NAME
        };
        for (Profile prof : [select Id, Name from Profile where Name in :requestedProfiles]) {
            if (prof.Name == PROF_GFRS_PORTAL_NAME) {
                PROF_GFRS_PORTAL = prof.id;
            } else if (prof.Name == PROF_GFRS_USER_NAME) {
                PROF_GFRS_USER = prof.id;
            }
        }

        String[] requestedRecordTypes = new String[]{
                'Corporate_Memberships',
                'Exhibits_Other_Promos',
                'Fellowships',
                'Field_Initiated_Exhibits',
                'HC_Char',
                'IMED',
                'Philanthropic',
                'Scientific_Projects'
        };

        for (RecordType recordType : [select id, DeveloperName from RecordType where DeveloperName in :requestedRecordTypes]) {
            if (recordType.DeveloperName == RT_FR_CORPORATE_MEMBERSHIPS_NAME) {
                RT_FR_CORPORATE_MEMBERSHIPS = recordType.id;
            } else if (recordType.DeveloperName == RT_FR_EXHIBITS_OTHER_PROMOS_NAME) {
                RT_FR_EXHIBITS_OTHER_PROMOS = recordType.id;
            } else if (recordType.DeveloperName == RT_FR_FELLOWSHIPS_NAME) {
                RT_FR_FELLOWSHIPS = recordType.id;
            } else if (recordType.DeveloperName == RT_FR_FIELD_INITIATED_EXHIBITS_NAME) {
                RT_FR_FIELD_INITIATED_EXHIBITS = recordType.id;
            } else if (recordType.DeveloperName == RT_FR_HC_CHAR_NAME) {
                RT_FR_HC_CHAR = recordType.id;
            } else if (recordType.DeveloperName == RT_FR_IMED_NAME) {
                RT_FR_IMED = recordType.id;
            } else if (recordType.DeveloperName == RT_FR_PHILANTHROPIC_NAME) {
                RT_FR_PHILANTHROPIC = recordType.id;
            } else if (recordType.DeveloperName == RT_FR_SCIENTIFIC_PROJECTS_NAME) {
                RT_FR_SCIENTIFIC_PROJECTS = recordType.id;
            }
        }

        for (RecordType recordType : [select id, DeveloperName from RecordType where SobjectType = 'gFRS_Administrative_Budget__c' and DeveloperName in ('IMED', 'CAPP', 'DEV' )]) {
            if (RT_ADMIN_BUDGET_CAPP_NAME.equals(recordType.DeveloperName)) {
                RT_ADMIN_BUDGET_CAPP = recordType.id;
            } else if (RT_ADMIN_BUDGET_IMED_NAME.equals(recordType.DeveloperName)) {
                RT_ADMIN_BUDGET_IMED = recordType.id;
            } else if (RT_ADMIN_BUDGET_DEV_NAME.equals(recordType.DeveloperName)) {
                RT_ADMIN_BUDGET_DEV = recordType.id;
            }
        }


        return(true);
    }

    private static Integer UUID = 0;

    public static Integer getUUID() {
        return(++UUID);
    }

    public static String makeUnique(String str) {
        return('' + str + (++UUID));
    }

    public static Integer rand(Integer size) {
        return(Integer.valueOf(Math.random() * size));
    }

/**
 *  Determines the case condition sent in the parameters.
 *  @return String - the 'case' parameter sent
 **/
    public static String getCaseCondition() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        if (params != null && params.containsKey('case')) {
            return(params.get('case'));
        } else {
            return(null);
        }
    }

//--------------

/*
#Account#createAccount#
#GFRS_Content_Translation__c#createContentTranslation#
#GFRS_Content__c#createContent#
#GFRS_Cost_Center_Code__c#createCostCenter#
#GFRS_Educational_Objective__c#createEducationalObjective#
#GFRS_FMV__c#createFMV#
#GFRS_Funding_Allocation_Line_Item__c#createFundingAllocationLI#
#GFRS_Funding_Allocation__c#createFundingAllocation#
#GFRS_Funding_Request__c#createFundignRequest#
#GFRS_Location__c#createLocation#
#GFRS_Organization__c#createOrganization#
#GFRS_Payment_History__c#createPayment#
#GFRS_Program_Audience_Group__c#createProgramAudience#
#GFRS_RequestBudget__c#createRequestBudget#
#GFRS_Request_Budget_Line_Item__c#createRequestBudgetLI#
#GFRS_Review__c#createReview#
#GFRS_WBS_Codes__c#createWBSCode#
*/

    public static GFRS_Administrative_Budget__c createAdminBudget(Date fiscalYear, String adminBudgetName) {
        //-- default to current year if null
        if (fiscalYear == null) fiscalYear = Date.newInstance(Date.today().year(), 01, 01);
        if (adminBudgetName == null) adminBudgetName = System.Label.GFRS_Temporary_Budget_Name;
        return(new GFRS_Administrative_Budget__c(Fiscal_Year__c = fiscalYear, Name = adminBudgetName));
    }
    public static GFRS_Administrative_Budget_Line_Item__c createAdminBudgetLI(String wbsCode, Decimal plannedAllocation, id adminBudgetId) {
        return(new GFRS_Administrative_Budget_Line_Item__c(Administrative_Budget__c = adminBudgetId, Planned_Allocation__c = plannedAllocation, WBS_Code__c = wbsCode, WBS_Description__c = '_'));
    }

    public static Account createAccount(String accountName) {
        //-- @TODO: stubbed for now
        return(new Account(Name = accountName));
    }

    public static GFRS_Program_Audience_Group__c createAudience(Id programId) {
        //-- @TODO: stubbed for now
        return(new GFRS_Program_Audience_Group__c(Program__c = programId));
    }

    public static GFRS_Content_Translation__c createContentTranslation(GFRS_Content__c content, String TEMP_TextBlock, String LegacyId, String Language) {
        return(new GFRS_Content_Translation__c(GFRS_Content__c = content.Id, TextBlock__c = TEMP_TextBlock, TEMP_TextBlock__c = TEMP_TextBlock, LegacyId__c = LegacyId, Language__c = Language));
    }
    public static GFRS_Content__c createContent(string name, string legacyId, string filter) {
        return(new GFRS_Content__c(Name = name, LegacyId__c = legacyId, Filter__c = filter));
    }

    public static GFRS_Decision_Link__c createDecisionLink(GFRS_Content__c Type_Description, String LegacyId, GFRS_Content__c Decision_Answer) {
        return(new GFRS_Decision_Link__c(Type_Description__c = Type_Description.Id, LegacyId__c = LegacyId, Decision_Answer__c = Decision_Answer.Id));
    }

    public static GFRS_Program__c createProgram_min(String progType, GFRS_Funding_Request__c fundingRequest) {
        return(new GFRS_Program__c(Type__c = progType, Funding_Request__c = fundingRequest.Id));
    }

    public static GFRS_Program__c createProgram(String progType, String progSubType, GFRS_Funding_Request__c fundingRequest, Integer numOfActivities, String venueName) {
        return(new GFRS_Program__c(Type__c = progType, Program_Subtype__c = progSubType, Funding_Request__c = fundingRequest.Id, Number_of_Activities__c = numOfActivities, Venue_Name__c = venueName));
    }

    public static GFRS_Demographic_Group__c createDemographicData(GFRS_Funding_Request__c fundingRequest) {
        return(new GFRS_Demographic_Group__c(gFRS_Funding_Request__c = fundingRequest.Id));
    }
    public static GFRS_Cost_Center_Code__c createCostCenter(String costCenter, String financialRecordType) {
        //-- @TODO: stubbed for now
        return(new GFRS_Cost_Center_Code__c(
                Name = costCenter,
                Cost_Center__c = costCenter,
                SAP_Company_Code__c = '1000'
        ));
    }
    public static GFRS_FMV__c createFMV(String budgetCategory, String subCategory, String programName, Double lower, Double median, Double upper) {
        return(new GFRS_FMV__c(Budget_Category__c = budgetCategory, Budget_SubCategory__c = subCategory, Program_Name__c = programName, Lower_Amount__c = lower, Median_Amount__c = median, Upper_Amount__c = upper));
    }
    public static GFRS_Funding_Allocation_Line_Item__c createFundingAllocationLI(GFRS_Funding_Allocation__c fa, Double am) {
        return(new GFRS_Funding_Allocation_Line_Item__c(Funding_Allocation__c = fa.Id, Amount__c = am));
    }

    public static GFRS_Funding_Allocation_Line_Item__c createFundingAllocationLIWithNumber(GFRS_Funding_Allocation__c fa, Double am, Integer num) {
        return(new GFRS_Funding_Allocation_Line_Item__c(Funding_Allocation__c = fa.Id, Amount__c = am, Split_Number__c = num));
    }


/**
*@author: ADMD Team
*@date: 06/04/2013
*@descritpion: helper method for creating gFRS Funding Allocation Line Items with wbs and cost center. Dedicated for tests.
*/
    public static GFRS_Funding_Allocation_Line_Item__c createFundingAllocationLIWithCostCenterAndWbs(GFRS_Funding_Allocation__c fa, Id wbsCode, Id costCenter, Double am, Integer num) {
        GFRS_Funding_Allocation_Line_Item__c result = null;
        if (num == null) {
            result = createFundingAllocationLI(fa, am);
        } else {
            result = createFundingAllocationLIWithNumber(fa, am, num);
        }
        result.WBS_Code_Lookup__c = wbsCode;
        result.Cost_Center_Lookup__c = costCenter;

        return result;
    }

    public static GFRS_Funding_Allocation__c createFundingAllocation() {
        //-- @TODO: stubbed for now
        return(new GFRS_Funding_Allocation__c());
    }
    public static GFRS_Funding_Allocation__c createFundingAllocation_min(GFRS_Funding_Request__c fr) {
        return(new GFRS_Funding_Allocation__c(Grant_Request__c = fr.Id));
    }
    public static GFRS_Funding_Request__c createFundingRequest(String recordType, String status, String subStatus, String externalSubStatus, String infoNeeded, Id organizationId, Id locationId) {
        RecordType rt = [SELECT id from RecordType where DeveloperName = :recordType and SobjectType = 'GFRS_Funding_Request__c'];
        //-- @TODO: stubbed for now
        return(new GFRS_Funding_Request__c(
                recordTypeId = rt.id,
                Status__c = status,
                Sub_Status__c = subStatus,
                External_Sub_status__c = externalSubStatus,
                Organization__c = organizationId,
                Location__c = locationId,
                Information_Needed__c = infoNeeded,
                Attention_To__c = 'tuser',
                Send_By_FedEx_cost_center_will_be_charg__c = 'No'
        ));
    }
/**
 *  Creates a funding request but uses the statically defined record types defined in 'init'.
 *  <p>This avoids multiple calls for record types if they are already known</p>
 **/
    public static GFRS_Funding_Request__c createFundingRequest2(id recordTypeId, String status, String subStatus, String externalSubStatus, String infoNeeded, Id organizationId, Id locationId) {
        return(new GFRS_Funding_Request__c(
                recordTypeId = recordTypeId,
                Status__c = status,
                Sub_Status__c = subStatus,
                External_Sub_status__c = externalSubStatus,
                Organization__c = organizationId,
                Location__c = locationId,
                Information_Needed__c = infoNeeded,
                Attention_To__c = 'tuser',
                Send_By_FedEx_cost_center_will_be_charg__c = 'No'
        ));
    }

/**
 *  Creates a funding request but uses the statically defined record types defined in 'init' with Therapeutic Area
 *  <p>This avoids multiple calls for record types if they are already known</p>
 **/
    public static GFRS_Funding_Request__c createFundingRequestWithTA(id recordTypeId, String status, String subStatus, String externalSubStatus, String taParent, String ta, String infoNeeded, Id organizationId, Id locationId) {
        return(new GFRS_Funding_Request__c(
                recordTypeId = recordTypeId,
                Status__c = status,
                Sub_Status__c = subStatus,
                External_Sub_status__c = externalSubStatus,
                Organization__c = organizationId,
                Location__c = locationId,
                Information_Needed__c = infoNeeded,
                Attention_To__c = 'tuser',
                Send_By_FedEx_cost_center_will_be_charg__c = 'No',
                Therapeutic_Area__c = ta,
                Therapeutic_Area_Parent__c = taParent,
                Business_Unit_2__c = null
        ));
    }

    public static GFRS_Location__c createLocation(String vendorName, Id organizationId) {
        //-- @TODO: stubbed for now
        return(new GFRS_Location__c(
                Vendor_Name__c = vendorName,
                Vendor_ID__c = '11000000',
                Vendor_Account_Group__c = 'PC01',
                Organization__c = organizationId,
                Department_Chapter_Country__c = 'United States',
                State__c = 'IL',
                Zip__c = '60045'
        ));
    }
    public static GFRS_Organization__c createOrganization(String taxId, Account account) {
        //-- @TODO: stubbed for now
        return(new GFRS_Organization__c(
                Organization_Name__c = 'test org',
                Tax_Id__c = taxId,
                Account__c = account.id

        ));
    }
    public static GFRS_Organization__c createOrganization2(String taxId, id accountId) {
        //-- @TODO: stubbed for now
        return(new GFRS_Organization__c(
                Organization_Name__c = 'test org',
                Tax_Id__c = taxId,
                Account__c = accountId

        ));
    }

    public static GFRS_Organization__c createInternalOrganization(String taxId, Account account) {

        RecordType internalRecordType = [SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName = 'External' AND SobjectType = 'GFRS_Organization__c'];
        return(new GFRS_Organization__c(
                RecordType = internalRecordType,
                Organization_Name__c = 'test org',
                Tax_Id__c = taxId,
                Account__c = account.Id

        ));
    }

    public static GFRS_Payment_History__c createPayment(Id requestId, Decimal amount) {
        //-- @TODO: stubbed for now
        return(new GFRS_Payment_History__c(Grant__c = requestId, Amount__c = amount));
    }

    public static GFRS_Program_Audience_Group__c createProgramAudience_min(GFRS_Program__c program) {
        return(new GFRS_Program_Audience_Group__c(Program__c = program.Id));
    }
    public static GFRS_RequestBudget__c createRequestBudget_min(GFRS_Funding_Request__c fundingRequest) {
        return(new GFRS_RequestBudget__c(Grant_Request__c = fundingRequest.Id));
    }
    public static GFRS_Request_Budget_Line_Item__c createRequestBudgetLI_min(id budgetId, decimal amount) {
        return(new GFRS_Request_Budget_Line_Item__c(Budget__c = budgetId, Amount__c = amount));
    }
    public static GFRS_Request_Budget_Line_Item__c createRequestBudgetLI(id budgetId, decimal amount, String category, String subCategory, String comments) {
        return(new GFRS_Request_Budget_Line_Item__c(Budget__c = budgetId, Amount__c = amount, Budget_Category__c = category, Budget_Subcategory__c = subCategory, Comments_Clarification__c = comments));
    }
    public static GFRS_Request_Budget_Line_Item__c createRequestBudgetLICorrect(id budgetId, decimal amount, String category, String subCategory, String comments, integer Count) {
        return(new GFRS_Request_Budget_Line_Item__c(Budget__c = budgetId, Amount__c = amount, Budget_Category__c = category, Budget_Subcategory__c = subCategory, Comments_Clarification__c = comments, Count__c = Count));
    }
    public static GFRS_WBS_Codes__c createWBSCode(String wbsCode, String therapeuticArea, String financialRecordType) {
        return(new GFRS_WBS_Codes__c(Name = wbsCode, WBS__c = wbsCode, SAP_Company_Code__c = '1000'));
    }
    public static GFRS_WBS_Codes__c createWBSCode2(String wbsCode, String therapeuticArea, String financialRecordType, DateTime startDate, DateTime endDate) {
        return(new GFRS_WBS_Codes__c(Name = wbsCode, WBS__c = wbsCode, Effective_Date_Time__C = startDate, Terminate_Date_Time__c = endDate, SAP_Company_Code__c = '1000'));
    }

/**
*@author: ADMD Team
*@date: 06/06/2013
*@description: method creates WBS object with specified Sap Company Code
*/
    public static GFRS_WBS_Codes__c createWBSCodeWithSAPCompanyCode(String wbsCode, String therapeuticArea, String financialRecordType, DateTime startDate, DateTime endDate, String sapCompanyCode) {
        GFRS_WBS_Codes__c resultObject = null;
        if ((sapCompanyCode == null || sapCompanyCode == '')) {
            resultObject = createWBSCode2(wbsCode, therapeuticArea, financialRecordType, startDate, endDate);
        } else {
            resultObject = createWBSCode(wbsCode, therapeuticArea, financialRecordType);
            resultObject.SAP_Company_Code__c = sapCompanyCode;
        }

        return resultObject;
    }

    public static Contact createContact(Account account) {
        return(new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email = 'test@test.com',
                Phone = '555-555-555',
                AccountID = account.Id
        ));
    }
    public static Contact createContact2(String firstName, String lastName, id accountId) {
        return(new Contact(
                FirstName = firstName,
                LastName = lastname,
                Email = 'test@gene.com',
                Phone = '555-555-555',
                AccountID = accountId
        ));
    }

    public static User createUser(Contact contact, String username) {

        return(new User(
                FirstName = 'Test',
                LastName = 'Test',
                username = username,
                Email = username,
                ProfileId = PROF_GFRS_PORTAL,
                IsActive = true,
                CompanyName = 'Genentech',
                ContactId = contact.Id,
                Security_PIN__c = '1234',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
        ));
    }


    public static User createUser2(Contact contact, String userName) {
        return(new User(
                FirstName = contact.firstName,
                LastName = contact.lastName,
                username = username,
                Email = contact.email,
                ProfileId = PROF_GFRS_PORTAL,
                IsActive = true,
                CompanyName = 'Genentech',
                ContactId = contact.Id,
                Security_PIN__c = '1234',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
        ));
    }
    public static User createUser3(String firstName, String lastName, String email, id profileId, String securityPin) {
        return(new User(
                FirstName = firstName,
                LastName = lastName,
                username = email,
                CompanyName = 'Genentech',
                Email = email,
                ProfileId = profileId,
                IsActive = true,
                Security_PIN__c = securityPin,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                External_ID_gne__c = 'qwertyuio'
        ));
    }
    public static Task createTask(String status) {
        return(new Task(
                Status = status
        ));
    }

    public static gFRS_Tasks__c createTask2(id requestid, String status, id userId) {
        return(new gFRS_Tasks__c(gFRS_Funding_Request__c = requestId, Status__c = status, User__c = userId));
    }

    public static All_User_Hierarchy_gne__c createUserHierarchy(String User_External_Id, String FirstName, String LastName, Id All_User_Hierarchy_Level1, Id All_User_Hierarchy_Level2, Id All_User_Hierarchy_Level3, Id All_User_Hierarchy_Level4, Id All_User_Hierarchy_Level5, Id All_User_Hierarchy_Level6, Id All_User_Hierarchy_Level7) {
        return (new All_User_Hierarchy_gne__c(User_External_Id_gne__c = User_External_Id, FirstName_gne__c = FirstName, LastName_gne__c = LastName, All_User_Hierarchy_Level1_gne__c = All_User_Hierarchy_Level1, All_User_Hierarchy_Level2_gne__c = All_User_Hierarchy_Level2, All_User_Hierarchy_Level3_gne__c = All_User_Hierarchy_Level3, All_User_Hierarchy_Level4_gne__c = All_User_Hierarchy_Level4, All_User_Hierarchy_Level5_gne__c = All_User_Hierarchy_Level5, All_User_Hierarchy_Level6_gne__c = All_User_Hierarchy_Level6, All_User_Hierarchy_Level7_gne__c = All_User_Hierarchy_Level7));
    }

    public static Attachment createAttachment(Id parentId, String attachmentName, Blob AttachmentBody) {
        return(new Attachment(
                parentId = parentId,
                name = attachmentName,
                body = AttachmentBody
        )
        );
    }

    public static gFRS_ACCME__c createAccmeAccreditation(String taxId, String accreditationStatus) {
        return(new gFRS_ACCME__c(Tax_Id__c = taxId, Accreditation_Status__c = accreditationStatus));
    }

    public static gFRS_Third_Party__c createThirdParty(id fundingRequestId, String firstName, String lastName, String companyName, String email, String companyFunction) {
        return(new gFRS_Third_Party__c(Funding_Request__c = fundingRequestId, Third_Party_Contact_First_Name__c = firstName, Third_Party_Contact_Last_Name__c = lastName, Company_Name__c = companyName, Third_Party_Contact_Email__c = email, Third_Party_Company_Function__c = companyFunction));
    }

    public static GFRS_Payment_History__c createFullPayment(Id requestId, String requestIdName) {
        return(new GFRS_Payment_History__c(
                Grant__c = requestId,
                Amount__c = 10000,
                Payment_Type__c = 'Payment',
                Date__c = system.today(),
                SAP_Request_ID__c = requestIdName + '_1'
        ));
    }

}