@isTest
private class gFRS_UnitTestHelperTest {

    /**
    * @author: GFRS Dev Team
    * @date: 16/07/2013
    * @description: Test method of helper method creating IMED Funding Request on Application step.
    */

    private static Id ID_FR_CORP_MEMBER_RECTYPE = [select Id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName = 'Corporate_Memberships'].Id;

    @isTest
    private static void testCreateImedRequestApplicationStep() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Test.startTest();
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
        List<GFRS_Funding_Allocation__c> fundingAllocations = gFRS_DAO.getFundingAllocationsByRequestId(request.Id);
        List<GFRS_Program__c> programs = gFRS_DAO.getProgramListByRequestId(request.Id);

        Test.stopTest();

        System.assertNotEquals(request, null);
        System.assert(fundingAllocations.size() > 0);
    }

    /**
    * @author: GFRS Dev Team
    * @date: 16/07/2013
    * @description: Test method of helper method creating IMED Funding Request on Program step.
    */
    @isTest
    private static void testCreateImedRequestProgramStep() {

        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Test.startTest();
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        List<GFRS_Funding_Allocation__c> fundingAllocations = gFRS_DAO.getFundingAllocationsByRequestId(request.Id);

        Test.stopTest();

        System.assertNotEquals(request, null);
        System.assert(fundingAllocations.size() > 0);
    }

    /**
    * @author: GFRS Dev Team
    * @date: 16/07/2013
    * @description: Test method of helper method creating IMED Funding Request on Budget step.
    */
    @isTest
    private static void testCreateImedRequestBudgetStep() {

        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Test.startTest();
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestBudgetStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        List<GFRS_Funding_Allocation__c> fundingAllocations = gFRS_DAO.getFundingAllocationsByRequestId(request.Id);

        Test.stopTest();

        System.assertNotEquals(request, null);
        System.assert(fundingAllocations.size() > 0);
    }

    /**
    * @author: GFRS Dev Team
    * @date: 16/07/2013
    * @description: Test method of helper method creating IMED Funding Request on Confirmation step.
    */
    @isTest
    private static void testCreateImedRequestConfirmationStep() {

        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        User testUser = gFRS_UnitTestHelper.createInternalGFRSUser();
        Test.startTest();
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestConfirmationStep(organizationId, localizationId, startDate, stopDate, testUser, 5, 5);
        List<GFRS_Funding_Allocation__c> fundingAllocations = gFRS_DAO.getFundingAllocationsByRequestId(request.Id);

        Test.stopTest();

        System.assertNotEquals(request, null);
        System.assert(fundingAllocations.size() > 0);
    }

    @isTest
    private static void createACCMETest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Test.startTest();
        gFRS_ACCME__c testAccme = gFRS_UnitTestHelper.createACCME('Accreditation', '12-1234567');
        Test.stopTest();

        System.assertEquals('Accreditation', testAccme.Accreditation_Status__c);
    }

    @isTest
    private static void createExternalOrganizationTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');

        Test.startTest();
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createExternalOrganization('12-1234567', account.Id);
        Test.stopTest();

        System.assertEquals('test org', testOrganization.Organization_Name__c);
        System.assertEquals('Yes', testOrganization.IsValidationExternalOnly__c);
    }

    @isTest
    private static void createAccountTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');

        Test.startTest();
        Contact contactTest = gFRS_UnitTestHelper.createContact(account.Id);
        Test.stopTest();

        System.assertEquals('test123456789@123test.com', contactTest.Email);
        System.assertEquals('Test', contactTest.LastName);
    }

    @isTest
    private static void createPortalUserWithoutSavingTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact contactTest = gFRS_UnitTestHelper.createContact(account.Id);

        Test.startTest();
        User userTest = gFRS_UnitTestHelper.createPortalUserWithoutSaving(contactTest);
        Test.stopTest();

        System.assertEquals('TestPortal', userTest.FirstName);
        System.assertEquals('TestPortal.TestPortal@gene.com', userTest.Email);
    }

    @isTest
    private static void createUserWithSpecificProfileTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        Test.startTest();
        User user = gFRS_UnitTestHelper.createUserWithSpecificProfile(profile.Id);
        Test.stopTest();

        System.assertEquals(profile.Id, user.ProfileId);
    }

    @isTest
    private static void createPortalUserTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact contactTest = gFRS_UnitTestHelper.createContact(account.Id);

        Test.startTest();
        User user = gFRS_UnitTestHelper.createPortalUser(contactTest);
        Test.stopTest();

        System.assertEquals('TestPortal.TestPortal@gene.com', user.Email);
        System.assertEquals('Genentech', user.CompanyName);
    }

    @isTest
    private static void createInternalGFRSUserTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);

        Test.startTest();
        User user = gFRS_UnitTestHelper.createInternalGFRSUser('mahony@test.com');
        Test.stopTest();

        System.assertEquals('TestInternal.TestInternal@gene.com', user.Email);
        System.assertEquals('Genentech', user.CompanyName);
        System.assertEquals('mahony@test.com', user.username);
    }

    @isTest
    private static void createIMEDFundingRequestObjectTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        Test.startTest();
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(organizationId, localizationId, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, 'Cardiology', 'Juvenile Rheumatoid Arthritis', 'Program');
        Test.stopTest();

        System.assertEquals(gFRS_Util.REQUEST_DEFAULT_STATUS, fundingRequest.Status__c);
        System.assertEquals(gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, fundingRequest.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, fundingRequest.External_Sub_status__c);
    }

    @isTest
    private static void createCorporateMembershipFundingRequestObjectTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        Test.startTest();
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(organizationId, localizationId, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, 'Cardiology', 'Juvenile Rheumatoid Arthritis', 'Program');
        Test.stopTest();

        System.assertEquals(gFRS_Util.REQUEST_DEFAULT_STATUS, fundingRequest.Status__c);
        System.assertEquals(gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, fundingRequest.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, fundingRequest.External_Sub_status__c);
    }

    @isTest
    private static void createFieldInitiatedExhibitsFundingRequestObjectTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        Test.startTest();
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFieldInitiatedExhibitsFundingRequestObject(organizationId, localizationId, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, 'Cardiology', 'Juvenile Rheumatoid Arthritis', 'Program');
        Test.stopTest();

        System.assertEquals(gFRS_Util.REQUEST_DEFAULT_STATUS, fundingRequest.Status__c);
        System.assertEquals(gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, fundingRequest.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, fundingRequest.External_Sub_status__c);
    }

    @isTest
    private static void createFundingRequestObjectTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        Test.startTest();
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFundingRequestObject(ID_FR_CORP_MEMBER_RECTYPE, organizationId, localizationId, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, 'Cardiology', 'Juvenile Rheumatoid Arthritis', 'Program');
        Test.stopTest();

        System.assertEquals(gFRS_Util.REQUEST_DEFAULT_STATUS, fundingRequest.Status__c);
        System.assertEquals(gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, fundingRequest.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, fundingRequest.External_Sub_status__c);
    }

    @isTest
    private static void updateFundingAllocationLineItem() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);

        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        List<GFRS_Funding_Allocation__c> fundingAllocations = gFRS_DAO.getFundingAllocationsByRequestId(request.Id);
        Double myDouble = 1261992;
        GFRS_Funding_Allocation_Line_Item__c lineAllocationLineItem = gFRS_TestCreationUtils.createFundingAllocationLIWithNumber(fundingAllocations.get(0), myDouble, 5);

        Test.startTest();
        gFRS_UnitTestHelper.updateFundingAllocationLineItem(request.Id);
        Test.stopTest();

    }

    @isTest
    private static void createFundingAllocationWithoutSaving() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);

        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);

        Test.startTest();
        gFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocationWithoutSaving(ID_FR_CORP_MEMBER_RECTYPE, request, 'Genentech');
        Test.stopTest();

        System.assertEquals('Genentech', fundingAllocation.Type_of_Check_Received__c);
    }

    @isTest
    private static void createUserDelegateRecordTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        Contact contactTest = gFRS_UnitTestHelper.createContact(account.Id);
        User user = gFRS_UnitTestHelper.createPortalUser(contactTest);
        User delegate = gFRS_UnitTestHelper.createInternalGFRSUser();

        Test.startTest();
        Id id = gFRS_UnitTestHelper.createUserDelegateRecord(user.Id, 'delegate', delegate.Id);
        Test.stopTest();

        GNE_User_Delegation__c newDelegation = [SELECT Id, Delegated_User__c FROM GNE_User_Delegation__c];
        System.assertEquals(delegate.Id, newDelegation.Delegated_User__c);
    }

    @isTest
    private static void createThirdPartyTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);

        Test.startTest();
        gFRS_Third_Party__c thirdParty = gFRS_UnitTestHelper.createThirdParty(request);
        Test.stopTest();

        System.assertEquals('Health Screenings', thirdParty.Third_Party_Company_Function__c);
        System.assertEquals('test@wp.pl', thirdParty.Third_Party_Contact_Email__c);
    }

    @isTest
    private static void createWBSCodeTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);

        Test.startTest();
        GFRS_WBS_Codes__c wbsCodes = gFRS_UnitTestHelper.createWBSCode('test', '1000');
        Test.stopTest();

        System.assertEquals('Biogen-Idec', wbsCodes.Type__c);
        System.assertEquals('test', wbsCodes.WBS__c);
    }

    @isTest
    private static void createWBSCodeWithoutSavingTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);

        Test.startTest();
        GFRS_WBS_Codes__c wbsCodes = gFRS_UnitTestHelper.createWBSCodeWithoutSaving('Test', true, 'Arkanzas', 30, 'test', '1000', Date.today().addYears(1), 'Biogen-Idec', 'Test', 'description');
        Test.stopTest();

        System.assertEquals('Biogen-Idec', wbsCodes.Type__c);
        System.assertEquals('Test', wbsCodes.WBS__c);
    }

    @isTest
    private static void createCostCenterCodeTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);

        Test.startTest();
        GFRS_Cost_Center_Code__c costCenterCode = gFRS_UnitTestHelper.createCostCenterCode('test', '1000');
        Test.stopTest();

        System.assertEquals('IMED Description', costCenterCode.Cost_Center_Description__c);
    }

    @isTest
    private static void createFundingAllocationLineItemTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact contactTest = gFRS_UnitTestHelper.createContact(account.Id);
        User user = gFRS_UnitTestHelper.createPortalUser(contactTest);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        GFRS_Cost_Center_Code__c costCenterCode = gFRS_UnitTestHelper.createCostCenterCode('test', '1000');
        gFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocation(request);
        GFRS_WBS_Codes__c wbsCodes = gFRS_UnitTestHelper.createWBSCode('test', '1000');

        Test.startTest();
        GFRS_Funding_Allocation_Line_Item__c lineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(user, costCenterCode, fundingAllocation, wbsCodes);
        Test.stopTest();

        System.assertEquals('IMED', lineItem.Funding_Record_Type__c);
        System.assertEquals(1000.0, lineItem.Amount__c);
    }

    @isTest
    private static void createFundingAllocationLineItemWithoutSavingTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact contactTest = gFRS_UnitTestHelper.createContact(account.Id);
        User user = gFRS_UnitTestHelper.createPortalUser(contactTest);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        GFRS_Cost_Center_Code__c costCenterCode = gFRS_UnitTestHelper.createCostCenterCode('test', '1000');
        gFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocation(request);
        GFRS_WBS_Codes__c wbsCodes = gFRS_UnitTestHelper.createWBSCode('test', '1000');

        Test.startTest();
        GFRS_Funding_Allocation_Line_Item__c lineItem = gFRS_UnitTestHelper.createFundingAllocationLineItemWithoutSaving(user, costCenterCode, fundingAllocation, wbsCodes);
        Test.stopTest();

        System.assertEquals('IMED', lineItem.Funding_Record_Type__c);
        System.assertEquals(1000.0, lineItem.Amount__c);
    }

    @isTest
    private static void createRequestBudgetLineItemTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact contactTest = gFRS_UnitTestHelper.createContact(account.Id);
        User user = gFRS_UnitTestHelper.createPortalUser(contactTest);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        GFRS_RequestBudget__c liveBudget = new  GFRS_RequestBudget__c( Budget_Summary_Description__c = GFRS_Util.BUDGET_DESC_LIVE, Grant_Request__c = request.id, Type__c = GFRS_Util.BUDGET_TYPE_LIVE);

        Test.startTest();
        GFRS_Request_Budget_Line_Item__c budgetLineItem = gFRS_UnitTestHelper.createRequestBudgetLineItem(10, liveBudget.Id, 'Accreditation', 'Advertising', 10, 2, 5, 4);
        Test.stopTest();

        System.assertEquals(10, budgetLineItem.Amount__c);
        System.assertEquals(liveBudget.Id, budgetLineItem.Budget__c);
    }

    @isTest
    private static void createRequestBudgetTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact contactTest = gFRS_UnitTestHelper.createContact(account.Id);
        User user = gFRS_UnitTestHelper.createPortalUser(contactTest);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        GFRS_Program__c program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, request, 3, 'test1234');

        Test.startTest();
        GFRS_RequestBudget__c requestBudget = gFRS_UnitTestHelper.createRequestBudget('test', 10, 5, 2, 6, request.Id, program.Id, 10, 'Enduring', 2);
        Test.stopTest();

        System.assertEquals('Enduring', requestBudget.Type__c);
        System.assertEquals( 2, requestBudget.Units__c);
    }

    @isTest
    private static void createProgramTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);

        Test.startTest();
        GFRS_Program__c program = gFRS_UnitTestHelper.createProgram(request.Id, 'Live', 1, 2, 3, ID_FR_CORP_MEMBER_RECTYPE);
        Test.stopTest();

        System.assertEquals('Live', program.Type__c);
        System.assertEquals( 2, program.Expected_of_attendees_that_are_HCPs__c);
    }

    @isTest
    private static void createFmvTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);

        Test.startTest();
        GFRS_FMV__c fmv = gFRS_UnitTestHelper.createFmv('Venue', 'Activity Marketing', 1, 5, 'Enduring Materials', 10);
        Test.stopTest();

        System.assertEquals('Venue', fmv.Budget_Category__c);
        System.assertEquals( 'Activity Marketing', fmv.Budget_SubCategory__c);
    }

    @isTest
    private static void createPaymentHistoryTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12-1234567', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);

        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestProgramStep(organizationId, localizationId, startDate, stopDate, 5, 5);
        GFRS_Cost_Center_Code__c costCenterCode = gFRS_UnitTestHelper.createCostCenterCode('test', '1000');
        GFRS_WBS_Codes__c wbsCodes = gFRS_UnitTestHelper.createWBSCode('test', '1000');

        Test.startTest();
        gFRS_Payment_History__c paymentHistory = gFRS_UnitTestHelper.createPaymentHistory(request, 'Payment', 'Genentech', '12345', wbsCodes, costCenterCode, 2);
        Test.stopTest();

        System.assertEquals('Payment', paymentHistory.Payment_Type__c);
        System.assertEquals( 'Genentech', paymentHistory.Type_of_Check_Received__c);
    }

    @isTest
    private static void createAdministrativeBudgetTest() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);

        Test.startTest();
        GFRS_Administrative_Budget__c administrativeBudget = gFRS_UnitTestHelper.createAdministrativeBudget();
        Test.stopTest();

        System.assertEquals('testBudget', administrativeBudget.Name);
    }

}