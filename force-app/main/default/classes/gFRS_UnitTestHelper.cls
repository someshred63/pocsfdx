/**
* @author ADMD Team
* @date 2/04/2013
* @description gFRS_UnitTestHelper class - helper class for Unit Tests. Creates data for tests.
*
*/
public virtual without sharing class gFRS_UnitTestHelper {

    public static final String REQUEST_STATUS_INTAKE = 'Intake';
    public static final String REQUEST_STATUS_HC_COMPLIANCE = 'HC Compliance';
    public static final String REQUEST_STATUS_NEW = 'New';
    public static final String REQUEST_STATUS_UNDER_REVIEW = 'Under Review';
    public static final String REQUEST_STATUS_NOT_SUBMITTED = 'Not Submitted';
    public static final String REQUEST_BUSINESS_UNIT_IMPACT = 'IMPACT';
    public static final String REQUEST_EVENT_PROGRAM_TYPE = 'Healthcare provider education';
    public static final String REQUEST_THERAPEUTIC_AREA_PARENT_CARDIOLOGY = 'Cardiology';            //Therapeutic area
    public static final String REQUEST_THERAPEUTIC_AREA_CARDIOLOGY = 'Acute Coronary Syndrome';    //Disise state

    public static final String PROGRAM_SUBTYPE_LIVE_GRAND_ROUNDS = 'Grand Rounds: Live';

    public static final String REQUEST_TEST_OUTCOME_LEVELS = 'Level 1: Participation; Level 2: Satisfaction; Level 3: Learning & Procedural Knowledge';
    public static final String REQUEST_TEST_COMPETENCIES_TO_BE_ACHIVED = 'Patient Care; Medical Knowledge';
    public static final String REQUEST_TEST_EXTERNAL_TRACING_CODE = '12345';

    public static final String TEST_TEXT = 'Test text';
    public static final String ANSWER_POSITIVE = 'Yes';
    public static final String ANSWER_NEGATIVE = 'No';

    private static Integer UniversalID = 0;

    private static Id ID_ACC_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'gFRS'].Id;
    private static Id ID_EXTERNAL_ACCOUNT_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Company'].Id;
    private static Id ID_PORTAL_USERS_PROFILE = [SELECT Id, Name FROM Profile WHERE Name = 'GNE-GFRS-External Requestor'].Id;
    private static Id ID_INTERNAL_USER_PROFILE = [SELECT Id, Name FROM Profile WHERE Name = 'GNE-GFRS-User'].Id;
    private static Id ID_FR_IMED_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Funding_Request__c' AND Name = 'IMED'].Id;
    private static Id ID_FR_HC_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Funding_Request__c' AND DeveloperName = 'HC_CHAR'].Id;
    private static Id ID_FR_FIELD_INI_EXHIBIT = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Funding_Request__c' AND DeveloperName = 'Field_Initiated_Exhibits'].Id;
    private static Id ID_FR_CORP_MEMBER_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Funding_Request__c' AND DeveloperName = 'Corporate_Memberships'].Id;
    private static Id ID_FR_PHILANTROPHIC_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Funding_Request__c' AND DeveloperName = 'Philanthropic'].Id;
    private static Id ID_FR_FELLOWSHIPS_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Funding_Request__c' AND DeveloperName = 'Fellowships'].Id;
    public static Id ID_PROGRAM_IMED_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Program__c' AND DeveloperName = 'IMED_Program'].Id;
    public static Id ID_PROGRAM_HC_RECTYPE = [SELECT Id FROM RecordType WHERE SobjectType = 'GFRS_Program__c' AND DeveloperName = 'HC_Char_Program'].Id;

    public static Id ID_FUNDING_ALLOCATION_PAYMENT_RECTYPE = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'GFRS_Funding_Allocation__c' AND Name = 'Payment'].Id;

    public static Integer getUniversalID() {
        return (++UniversalID);
    }

    public static String CreateUnique(String str) {
        return('' + str + (++UniversalID));
    }

    public static gFRS_ACCME__c createACCME(String accreditationStatus, String taxId) {

        return new gFRS_ACCME__c(Accreditation_Status__c = accreditationStatus, Tax_ID__c = taxId);
    }

    public static Account createExternalAccount(String accName) {
        Account acc = new Account(Name = CreateUnique(accName), RecordTypeId = ID_EXTERNAL_ACCOUNT_RECTYPE);

        return acc;
    }

    public static Account createAccount(String accName) {
        Account acc = new Account(Name = CreateUnique('accTest'), RecordTypeId = ID_ACC_RECTYPE);
        insert acc;
        return acc;
    }

    public static GFRS_Organization__c createOrganization(String taxId, Id accountId) {
        GFRS_Organization__c org = new GFRS_Organization__c(
                Organization_Name__c = 'test org',
                Tax_Id__c = taxId,
                Account__c = accountId);
        insert org;
        return org;
    }

    public static GFRS_Organization__c createExternalOrganization(String taxId, Id accountId) {
        GFRS_Organization__c org = new GFRS_Organization__c(
                Organization_Name__c = 'test org',
                IsValidationExternalOnly__c = 'Yes',
                Tax_Id__c = taxId,
                Account__c = accountId);
        insert org;
        return org;
    }

    public static GFRS_Location__c createLocation(String vendorName, Id organizationId) {
        GFRS_Location__c loc = new GFRS_Location__c(
                Vendor_Name__c = vendorName,
                Organization__c = organizationId,
                Vendor_ID__c = '0011000000',
                Vendor_Account_Group__c = 'PC01',
                Department_Chapter_Country__c = 'United States',
                State__c = 'IL',
                Zip__c = '60516');
        insert loc;
        return loc;
    }

    public static Contact createContact(Id accountId) {
        Contact cnt = new Contact(
                FirstName = 'Test',
                LastName = 'Test',
                Email = 'test123456789@123test.com',
                Phone = '555-555-555',
                AccountId = accountId
        );

        insert cnt;
        return cnt;
    }

    /**
       * @author: GFRS Dev Team
       * @date: 28/10/2013
       * @description: createIMEDFundingRequestObject method - create IMED funding request . Returns  - gFRS Funding Request object.
       */
    public static User createPortalUser(Contact contact) {
        User portalUser = createPortalUserWithoutSaving(contact);

        insert portalUser;
        return portalUser;
    }

    /**
      * @author: GFRS Dev Team
      * @date: 06/12/2013
      * @description: createPortalUserWithoutSaving method - create Portal User . Returns  - User object.
      */
    public static User createPortalUserWithoutSaving(Contact contact) {
        User usr = new User(
                FirstName = 'TestPortal',
                LastName = 'TestPortal',
                Username = gFRS_TestCreationUtils.makeUnique('TestPortal.TestPortal@gene.com'),
                Email = 'TestPortal.TestPortal@gene.com',
                ProfileId = ID_PORTAL_USERS_PROFILE,
                IsActive = true,
                CompanyName = 'Genentech',
                ContactId = contact.Id,
                Security_PIN__c = '1234',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
        );
        return usr;
    }

    public static User createInternalGFRSUser() {
        User usr = new User(
                FirstName = 'TestInternal',
                LastName = 'TestInternal',
                Username = 'TestInternal.TestInternal@gene.com.gfrs',
                Email = 'TestInternal.TestInternal@gene.com',
                ProfileId = ID_INTERNAL_USER_PROFILE,
                IsActive = true,
                CompanyName = 'Genentech',
                Security_PIN__c = '1234',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
        );
        insert usr;
        return usr;
    }

    public static User createUserWithSpecificProfile(Id profileId) {
        User usr = new User(
                FirstName = 'TestInternal',
                LastName = 'TestInternal',
                Username = 'TestInternal.TestInternal@gene.com.gfrs',
                Email = 'TestInternal.TestInternal@gene.com',
                ProfileId = profileId,
                IsActive = true,
                CompanyName = 'Genentech',
                Security_PIN__c = '1234',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
        );
        insert usr;
        return usr;
    }

    public static User createInternalGFRSUser(String username) {
        User usr = new User(
                FirstName = 'TestInternal',
                LastName = 'TestInternal',
                Username = username,
                Email = 'TestInternal.TestInternal@gene.com',
                ProfileId = ID_INTERNAL_USER_PROFILE,
                IsActive = true,
                CompanyName = 'Genentech',
                Security_PIN__c = '1234',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
        );
        insert usr;
        return usr;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 28/10/2013
    * @description: createIMEDFundingRequest method - create IMED funding request . Returns  - gFRS Funding Request object Id.
    */
    public static Id createIMEDFundingRequest(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = createIMEDFundingRequestObject(orgId, locId, status, subStatus, extSubStatus, TAParent, TA, infoNeeded);
        return req.Id;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 28/10/2013
    * @description: createIMEDFundingRequestObject method - create IMED funding request . Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createIMEDFundingRequestObject(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
                RecordTypeId = ID_FR_IMED_RECTYPE,
                Status__c = status,
                Sub_Status__c = subStatus,
                External_Sub_status__c = extSubStatus,
                Organization__c = orgId,
                Location__c = locId,
                Information_Needed__c = infoNeeded,
                Attention_To__c = 'tuser',
                Send_By_FedEx_cost_center_will_be_charg__c = 'No',
                Therapeutic_Area__c = TA,
                Therapeutic_Area_Parent__c = TAParent,
                Business_Unit_2__c = null
        );
        insert req;
        return req;
    }


    /**
    * @author: GFRS Dev Team
    * @date: 05/12/2013
    * @description: createIMEDFundingRequestObjectWithoutSaving method - create IMED funding request without saving it to database. Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createIMEDFundingRequestObjectWithoutSaving(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {

        GFRS_Funding_Request__c req = createFundingRequestObject(ID_FR_IMED_RECTYPE, orgId, locId, status, subStatus, extSubStatus, TAParent, TA, infoNeeded);
        return req;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 28/10/2013
    * @description: createIMEDFundingRequestObject method - create IMED funding request . Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createCorporateMembershipFundingRequestObject(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
                RecordTypeId = ID_FR_CORP_MEMBER_RECTYPE,
                Status__c = status,
                Sub_Status__c = subStatus,
                External_Sub_status__c = extSubStatus,
                Organization__c = orgId,
                Location__c = locId,
                Information_Needed__c = infoNeeded,
                Attention_To__c = 'tuser',
                Send_By_FedEx_cost_center_will_be_charg__c = 'No',
                Therapeutic_Area__c = TA,
                Therapeutic_Area_Parent__c = TAParent,
                Business_Unit_2__c = null
        );
        insert req;
        return req;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 13/06/2013
    * @description: createFieldInitiatedExhibitsFundingRequestObject method - create FIE funding request . Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createFieldInitiatedExhibitsFundingRequestObject(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
                RecordTypeId = ID_FR_FIELD_INI_EXHIBIT,
                Status__c = status,
                Sub_Status__c = subStatus,
                External_Sub_status__c = extSubStatus,
                Organization__c = orgId,
                Location__c = locId,
                Information_Needed__c = infoNeeded,
                Attention_To__c = 'tuser',
                Send_By_FedEx_cost_center_will_be_charg__c = 'No',
                Therapeutic_Area__c = TA,
                Therapeutic_Area_Parent__c = TAParent,
                Business_Unit_2__c = null
        );
        insert req;
        return req;
    }


    /**
    * @author: GFRS Dev Team
    * @date: 05/12/2013
    * @description: createCorporateMembershipFundingRequestObjectWithoutSaving method - create Corp Memb funding request without saving it to database. Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createCorporateMembershipFundingRequestObjectWithoutSaving(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = createFundingRequestObject(ID_FR_CORP_MEMBER_RECTYPE, orgId, locId, status, subStatus, extSubStatus, TAParent, TA, infoNeeded);
        return req;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 19/11/2013
    * @description: createHCFundingRequestObject method - create HC Char funding request . Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createHCFundingRequestObject(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = createFundingRequestObject(ID_FR_HC_RECTYPE, orgId, locId, status, subStatus, extSubStatus, TAParent, TA, infoNeeded);
        return req;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 19/11/2013
    * @description: createHCFundingRequestObject method - create HC Char funding request . Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createPhilantrophicFundingRequestObject(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = createFundingRequestObject(ID_FR_PHILANTROPHIC_RECTYPE, orgId, locId, status, subStatus, extSubStatus, TAParent, TA, infoNeeded);
        return req;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 19/11/2013
    * @description: createHCFundingRequestObject method - create HC Char funding request . Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createFellowshipsFundingRequestObject(Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = createFundingRequestObject(ID_FR_FELLOWSHIPS_RECTYPE, orgId, locId, status, subStatus, extSubStatus, TAParent, TA, infoNeeded);
        return req;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 19/11/2013
    * @description: createFundingRequestObject method - create IMED funding request . Returns  - gFRS Funding Request object.
    */
    public static GFRS_Funding_Request__c createFundingRequestObject(Id recordTypeId, Id orgId, Id locId, String status, String subStatus, String extSubStatus, String TAParent, String TA, String infoNeeded) {
        GFRS_Funding_Request__c req = new GFRS_Funding_Request__c(
                RecordTypeId = recordTypeId,
                Status__c = status,
                Sub_Status__c = subStatus,
                External_Sub_status__c = extSubStatus,
                Organization__c = orgId,
                Location__c = locId,
                Information_Needed__c = infoNeeded,
                Attention_To__c = 'tuser',
                Send_By_FedEx_cost_center_will_be_charg__c = 'No',
                Therapeutic_Area__c = TA,
                Therapeutic_Area_Parent__c = TAParent,
                Business_Unit_2__c = null
        );
        return req;
    }

    /**
     * @author: GFRS Dev Team
     * @date: 18/06/2013
     * @description:updateFundingAllocationLineItem method which updating wbs code and cost center under Funding allocation line items.
     * This information is populated under application portal page on section "Allocation Items"
     */
    public static void updateFundingAllocationLineItem(Id requestID) {
        List<GFRS_Funding_Allocation_Line_Item__c> allocationLineItemsList = gFRS_DAO.getAllocationLineItemListByRequestId(requestID);
        List<GFRS_WBS_Codes__c> wbsList = gFRS_DAO.getWBSCodeList('1010');
        List<GFRS_Cost_Center_Code__c> costCenterList = gFRS_DAO.getCostCenterList('1010');
        try {
            for (GFRS_Funding_Allocation_Line_Item__c item : allocationLineItemsList) {
                item.Cost_Center_Lookup__c = wbsList[0].Id;
                item.WBS_Code_Lookup__c = costCenterList[0].Id;
            }
        } catch (Exception ex) {
            System.debug('exception occurs probably data is not proper WBS Code and Cost Center');
        }
        if (allocationLineItemsList.size() > 0) {
            update allocationLineItemsList;
        }
    }

    /**
   * @author: GFRS Dev Team
   * @date: 15/07/2013
   * @description: setGfrsCustomSettings method - setter for custom settings. Needed for unit testing.
   */
    public static void setGfrsCustomSettings(Boolean fundingRequestTriggerEnabled) {
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        myOrgCS.Funding_Request_Trigger_Enabled__c = fundingRequestTriggerEnabled;
        myOrgCS.gCalFailedEventsEmailTime__c = 10;
        myOrgCS.gFRS_Admin_Email__c = 'test@test.xx';
        myOrgCS.gFRS_HC_Compliance_Flag_Start_Date__c = Date.today().addDays(-1);
        myOrgCS.Field_Initiated_Exhibits_WBS_1000__c = '309.01006';
        myOrgCS.Field_Initiated_Exhibits_WBS_1010__c = '309.07076';
        upsert myOrgCS;
    }

    /**
   * @author: GFRS Dev Team
   * @date: 16/07/2013
   * @description: createFundingAllocation method - Creates Funding allocation for given Funding Request.
   */
    public static GFRS_Funding_Allocation__c createFundingAllocation(GFRS_Funding_Request__c fundingRequest) {
        GFRS_Funding_Allocation__c newObjFundingAllocation = new GFRS_Funding_Allocation__c();
        newObjFundingAllocation.Grant_Request__c = fundingRequest.Id;
        //newObjFundingAllocation.RecordTypeId =

        insert newObjFundingAllocation;
        return newObjFundingAllocation;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 16/07/2013
    * @description: createFundingAllocationWithoutSaving method - Creates Funding allocation for given Funding Request. Returns  gFRS_Funding_Allocation__c.
    */
    public static GFRS_Funding_Allocation__c createFundingAllocationWithoutSaving(Id recordType, GFRS_Funding_Request__c fundingRequest, String typeToCheckReceived) {
        GFRS_Funding_Allocation__c newObjFundingAllocation = new GFRS_Funding_Allocation__c();
        newObjFundingAllocation.RecordTypeId = recordType;
        newObjFundingAllocation.Grant_Request__c = fundingRequest.Id;
        newObjFundingAllocation.Type_of_Check_Received__c = typeToCheckReceived;
        return newObjFundingAllocation;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 17/09/2013
    * @description: createUserDelegateRecord method - creates user delegation record. Returns delegation id record.
    */
    public static Id createUserDelegateRecord(Id userId, String userName, Id delegateId) {
        Id retVal;

        GNE_User_Delegation__c newDelegation = new GNE_User_Delegation__c(Name = userName);
        newDelegation.Delegated_User__c = delegateId;
        newDelegation.Username__c = userId;
        newDelegation.Start_Date__c = Date.today();
        newDelegation.End_Date__c = Date.today() + 1;
        newDelegation.RecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'GNE_User_Delegation__c' AND DeveloperName = 'GFRS'][0].Id;

        Database.SaveResult sr = Database.insert(newDelegation);
        if (sr.isSuccess()) {
            retVal = newDelegation.Id;
        }
        return retVal;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 28/10/2013
    * @description: createThirdParty method - creates Third Party records. Returns Third Party record.
    */
    public static gFRS_Third_Party__c createThirdParty(GFRS_Funding_Request__c fundingRequest) {
        gFRS_Third_Party__c newThirdParty = new gFRS_Third_Party__c();
        newThirdParty.Funding_Request__c = fundingRequest.Id;
        newThirdParty.Third_Party_Company_Function__c = 'Health Screenings';
        newThirdParty.Third_Party_Contact_Email__c = 'test@wp.pl';
        newThirdParty.Third_Party_Contact_First_Name__c = 'testFirstName';
        newThirdParty.Third_Party_Contact_Last_Name__c = 'testLastName';
        insert newThirdParty;
        return newThirdParty;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 14/11/2013
    * @description: createWBSCode method - creates WBS Code. Returns WBS Code record.
    */
    public static GFRS_WBS_Codes__c createWBSCode(String defaultName, String SAPCompanyCode) {
        GFRS_WBS_Codes__c wbsCode = new GFRS_WBS_Codes__c(
                Name = defaultName,
                IsActive__c = true,
                Brand__c = defaultName,
                SAP_Company_Code__c = SAPCompanyCode,
                Terminate_Date_Time__c = Date.today() + 1,
                Type__c = 'Biogen-Idec',
                WBS__c = defaultName,
                WBS_Description__c = 'IMED Description'
        );
        insert wbsCode;
        return wbsCode;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 16/12/2013
    * @description: createWBSCodeWithoutSaving method - creates WBS Code. Returns WBS Code object.
    */
    public static GFRS_WBS_Codes__c createWBSCodeWithoutSaving(String defaultName, Boolean isActive, String therapeuticArea, Integer therapeuticAreaPercent, String financialReferenceRecordType, String SAPCompanyCode, Date terminateDateTime, String wbsType, String wbs, String wbsDescription) {
        GFRS_WBS_Codes__c wbsCode = new GFRS_WBS_Codes__c(
                Name = defaultName,
                IsActive__c = isActive,
                Brand__c = defaultName,
                SAP_Company_Code__c = SAPCompanyCode,
                Terminate_Date_Time__c = terminateDateTime,
                Type__c = wbsType,
                WBS__c = wbs,
                WBS_Description__c = wbsDescription
        );
        return wbsCode;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 14/11/2013
    * @description: createCostCenterCode method - creates cost Center Code. Returns cost Center Code record.
    */
    public static GFRS_Cost_Center_Code__c createCostCenterCode(String defaultName, String SAPCompanyCode) {
        GFRS_Cost_Center_Code__c costCenterCode = new GFRS_Cost_Center_Code__c(
                Name = defaultName,
                IsActive__c = true,
                Cost_Center__c = defaultName,
                Cost_Center_Description__c = 'IMED Description',
                SAP_Company_Code__c = SAPCompanyCode
        );

        insert costCenterCode;
        return costCenterCode;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 14/11/2013
    * @description: createFundingAllocationLineItem method - creates Funding Allocation Line Item. Returns cost Funding Allocation Line Item record.
    */
    public static GFRS_Funding_Allocation_Line_Item__c createFundingAllocationLineItem(User user, GFRS_Cost_Center_Code__c costCenterCode, GFRS_Funding_Allocation__c fundingAllocation, GFRS_WBS_Codes__c wbsCode) {
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = new GFRS_Funding_Allocation_Line_Item__c(
                Accountable_Employee__c = user.Id,
                Amount__c = 1000.0,
                Cost_Center_Lookup__c = costCenterCode.Id,
                Funding_Allocation__c = fundingAllocation.Id,
                Funding_Record_Type__c = 'IMED',
                WBS_Code_Lookup__c = wbsCode.Id
        );
        insert fundingAllocationLineItem;
        return fundingAllocationLineItem;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 16/12/2013
    * @description: createFundingAllocationLineItemWithoutSaving method - creates Funding Allocation Line Item. Returns cost Funding Allocation Line Item object.
    */
    public static GFRS_Funding_Allocation_Line_Item__c createFundingAllocationLineItemWithoutSaving(User user, GFRS_Cost_Center_Code__c costCenterCode, GFRS_Funding_Allocation__c fundingAllocation, GFRS_WBS_Codes__c wbsCode) {
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = new GFRS_Funding_Allocation_Line_Item__c(
                Accountable_Employee__c = user.Id,
                Amount__c = 1000.0,
                Cost_Center_Lookup__c = costCenterCode.Id,
                Funding_Allocation__c = fundingAllocation.Id,
                Funding_Record_Type__c = 'IMED',
                WBS_Code_Lookup__c = wbsCode.Id
        );
        return fundingAllocationLineItem;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 21/11/2013
    * @description: createRequestBudgetLineItem method - creates GFRS_Request_Budget_Line_Item__c. Returns GFRS_Request_Budget_Line_Item__c record.
    */
    public static GFRS_Request_Budget_Line_Item__c createRequestBudgetLineItem(Integer amount, Id budget, String budgetCategory, String budgetSubCategory, Integer fmvUpper, Integer fmvLower, Integer fmvMedian, Integer countSize) {
        GFRS_Request_Budget_Line_Item__c lineItem = new GFRS_Request_Budget_Line_Item__c();
        lineItem.Amount__c = amount;
        lineItem.Budget__c = budget;
        lineItem.Budget_Category__c = budgetCategory;
        lineItem.Budget_Subcategory__c = budgetSubCategory;
        lineItem.FMV_Upper__c = fmvUpper;
        lineItem.FMV_Lower__c = fmvLower;
        lineItem.FMV_Median__c = fmvMedian;
        lineItem.Count__c = countSize;
        return lineItem;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 21/11/2013
    * @description: createRequestBudget method - creates GFRS_RequestBudget__c. Returns GFRS_RequestBudget__c record.
    */
    public static GFRS_RequestBudget__c createRequestBudget(String budgetSummaryDescription, Integer fmvMedianTotalActivityCost, Integer fmvMedianTotalActivityEvent, Integer fmvMedianTotalManagementFees, Integer fmvMedianTotalPassThrough, Id grantRequest, Id programRequestDeliveryFormat, Integer sysRequestBudgetYear, String budgetType, Integer units) {
        GFRS_RequestBudget__c requestBudget = new GFRS_RequestBudget__c();
        requestBudget.Budget_Summary_Description__c = budgetSummaryDescription;
        requestBudget.FMV_Median_Total_Activity_Cost__c = fmvMedianTotalActivityCost;
        requestBudget.FMV_Median_Total_Activity_Event__c = fmvMedianTotalActivityEvent;
        requestBudget.FMV_Median_Total_Management_Fees__c = fmvMedianTotalManagementFees;
        requestBudget.FMV_Median_Total_Pass_Through__c = fmvMedianTotalPassThrough;
        requestBudget.Grant_Request__c = grantRequest;
        requestBudget.Request_Delivery_Format__c = programRequestDeliveryFormat;
        requestBudget.SYS_Request_Budget_Year__c = sysRequestBudgetYear;
        requestBudget.Type__c = budgetType;
        requestBudget.Units__c = units;
        return requestBudget;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 21/11/2013
    * @description: createProgram method - creates GFRS_Program__c. Returns GFRS_Program__c record.
    */
    public static GFRS_Program__c createProgram(Id requestId, String programType, Integer numberOfAttendees, Integer numberOfAttendeesThatAreHCP, Integer numberUsBasedHCP, Id recordTypeId) {
        GFRS_Program__c program = new GFRS_Program__c();
        program.Funding_Request__c = requestId;
        program.Type__c = programType;
        program.Expected_Number_of_Attendees__c = numberOfAttendees;
        program.Expected_of_attendees_that_are_HCPs__c = numberOfAttendeesThatAreHCP;
        program.Expected_of_Attendees_US_Based_HCPs__c = numberUsBasedHCP;
        program.RecordTypeId = recordTypeId;
        return program;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 26/11/2013
    * @description: createFmv method - creates GFRS_FMV__c. Returns GFRS_FMV__c record.
    */
    public static GFRS_FMV__c createFmv(String budgetCategory, String budgetSubcategory, Integer lowerAmount, Integer medianAmount, String programName, Integer upperAmount) {
        GFRS_FMV__c fmv = new GFRS_FMV__c();
        fmv.Budget_Category__c = budgetCategory;
        fmv.Budget_SubCategory__c = budgetSubcategory;
        fmv.Lower_Amount__c = lowerAmount;
        fmv.Median_Amount__c = medianAmount;
        fmv.Program_Name__c = programName;
        fmv.Upper_Amount__c = upperAmount;
        return fmv;
    }

    /**
    * @author: GFRS Dev Team
    * @date: 26/11/2013
    * @description: createPaymentHistory method - creates gFRS_Payment_History__c. Returns gFRS_Payment_History__c record.
    */
    public static GFRS_Payment_History__c createPaymentHistory(GFRS_Funding_Request__c fundingRequest, String paymentType, String typeOfCheckReceived, String checkNumber, GFRS_WBS_Codes__c wbs, GFRS_Cost_Center_Code__c costCenter, Integer amount) {
        GFRS_Payment_History__c paymentHistory = new GFRS_Payment_History__c();
        paymentHistory.Grant__c = fundingRequest.Id;
        paymentHistory.Payment_Type__c = paymentType;
        paymentHistory.Type_of_Check_Received__c = typeOfCheckReceived;
        paymentHistory.Check_Number__c = checkNumber;
        paymentHistory.WBS_Code__c = wbs.Id;
        paymentHistory.Cost_Center__c = costCenter.Id;
        paymentHistory.Amount__c = amount;
        return paymentHistory;
    }

    public static GFRS_Administrative_Budget__c createAdministrativeBudget() {
        GFRS_Administrative_Budget__c budget = new GFRS_Administrative_Budget__c();
        budget.Name = 'testBudget';
        budget.Fiscal_Year__c = System.today();
        insert budget;
        return budget;
    }

    public static Approval.ProcessResult setStartApprovalSteps(GFRS_Funding_Request__c fundingRequest) {
        final Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setComments('Submitting request for approval.');
        approvalReq.setObjectId(fundingRequest.Id);
        approvalReq.setNextApproverIds(new Id[]{
                UserInfo.getUserId()
        });

        Approval.ProcessResult result2 = Approval.process(approvalReq);

        fundingRequest.Status__c = 'Decision';
        fundingRequest.Sub_Status__c = 'GC Review';
        update fundingRequest;

        List<Id> newWorkItemIds = result2.getNewWorkitemIds();

        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[]{
                UserInfo.getUserId()
        });
        req2.setWorkitemId(newWorkItemIds.get(0));
        result2 = Approval.process(req2);
        return result2;
    }

    public static void GotoApprovalStep(GFRS_Funding_Request__c fundingRequest, Integer steps) {
        Approval.ProcessResult result2 = setStartApprovalSteps(fundingRequest);
        List<Id> newWorkItemIds = result2.getNewWorkitemIds();

        for (Integer i = 0; i < steps; i++) {
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[]{
                    UserInfo.getUserId()
            });
            req2.setWorkitemId(newWorkItemIds.get(0));

            result2 = Approval.process(req2);
            newWorkItemIds = result2.getNewWorkitemIds();
        }
    }
}