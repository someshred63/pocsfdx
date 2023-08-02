/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class gFRS_PrintAllRequestControllerTester {

    /**
     *  Internal Testing class that takes care of setup and tear downs.
     **/
    class TestSettings {

        //-- instance variables
        Account account;
        GFRS_Organization__c organization;
        GFRS_Location__c location;
        GFRS_Funding_Request__c request;
        GFRS_RequestBudget__c budget;
        GFRS_Program__c program;
        GFRS_Program_Audience_Group__c[] audience;
        GFRS_Request_Budget_Line_Item__c[] budgetLineItems;
        GFRS_Demographic_Group__c demographicGroup;
        GFRS_Program_Audience_Group__c audienceGroup;

        ApexPages.PageReference pageRef;
        gFRS_PrintAllRequestController controller;

        public TestSettings() {
            //-- initialization done for ALL SETUPs done here
            this.account = gFRS_TestCreationUtils.createAccount(gFRS_TestCreationUtils.makeUnique('acct'));
            insert this.account;

            this.organization = gFRS_TestCreationUtils.createOrganization2('20110101', this.account.id);
            insert this.organization;

            this.location = gFRS_TestCreationUtils.createLocation('SomeLocation', this.organization.id);
            insert this.location;
        }

        public void setupIMED() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;

            this.setupPrograms();
            this.setupBudgets();
        }

        public void setupHCCHAR() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            insert this.request;

            this.setupPrograms();
            this.setupBudgets();
        }

        public void setupFellowships() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            insert this.request;

            this.setupPrograms();
            this.setupBudgets();
        }

        public void setupPhilanthropic() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            insert this.request;

            this.setupPrograms();
            this.setupBudgets();
        }

        public void setupMemberships() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;

            this.setupPrograms();
        }

        public void setupPrograms() {
            this.program = gFRS_TestCreationUtils.createProgram_min('Live', this.request);
            insert this.program;

            this.audience = new GFRS_Program_Audience_Group__c[]{
                    gFRS_TestCreationUtils.createProgramAudience_min(this.program)
            };
        }

        public void setupBudgets() {
            this.budget = gFRS_TestCreationUtils.createRequestBudget_min(this.request);
            insert this.budget;

            this.budgetLineItems = new GFRS_Request_Budget_Line_Item__c[]{
                    gFRS_TestCreationUtils.createRequestBudgetLI_min(this.budget.id, 2000.00)
            };
            insert this.budgetLineItems;
        }

        public void setupDemographicsGroup() {
            this.demographicGroup = gFRS_TestCreationUtils.createDemographicData(this.request);
            insert this.demographicGroup;
        }

        public void setupController() {
            this.pageRef = new ApexPages.PageReference('/apex/gFRS_PringAllRequest');
            Test.setCurrentPage(this.pageRef);

            this.controller = new gFRS_PrintAllRequestController(new ApexPages.StandardController(this.request));
        }

        /** cleanup the fundingRequest to the point that an update can occur **/
        public void prepareRequestForUpdate() {
            //this.request.Name = 'testRequest';
        }
    }

    @IsTest
    static void testSettingsSetsUpWithoutErrors() {
        try {
            TestSettings ts = new TestSettings();
            ts.setupMemberships();
            ts.setupController();
        } catch (Exception err) {
            System.assert(false, 'TestSetting/Setup must not throw any exceptions');
        }
    }

    @IsTest
    static void testPrintIMED() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupController();

        System.assertEquals(true, ts.controller.showBudget, 'since the request is of type imed, the budget should be shown');
    }

    @IsTest
    static void testPrintMemberships() {
        TestSettings ts = new TestSettings();
        ts.setupMemberships();
        ts.setupController();

        System.assertEquals(false, ts.controller.showBudget, 'since the request is of type memberships, the budget should be shown');
    }

    @IsTest
    static void testControllerProperties() {
        TestSettings ts = new TestSettings();
        ts.setupHCCHAR();
        ts.setupDemographicsGroup();
        ts.setupController();

        // 'Outstanding_Accounts_Payable__c', 'Salary_of_the_Highest_Paid_Executive__c', 'Pending_Litigation__c'
        System.assertEquals(3, ts.controller.FoundationFieldSet.size());

        // 'Signing_Authority_First_Name__c', 'Signing_Authority_Last_Name__c', 'Signing_Authority_Email__c'
        System.assertEquals(3, ts.controller.confirmationFieldSet.size());

        // 'Will_You_be_Working_With_a_3rd_Party__c'
        System.assertEquals(1, ts.controller.FS_ThirdParty.size());

        // 'Company_Name__c','Third_Party_Contact_First_Name__c', 'Third_Party_Contact_Last_Name__c','Third_Party_Company_Function__c', 'Third_Party_Contact_Email__c'
        System.assertEquals(5, ts.controller.FS_ThirdPartyFields.size());

        // 'Cost_Center__c'
        System.assertEquals(1, ts.controller.FS_AllocationReadOnly.size());

        System.assert(!String.isEmpty(ts.controller.getPaymentDeliveryLabel));

        System.assertEquals([SELECT Id, Name, Funding_Request__c FROM GFRS_Program__c WHERE Funding_Request__c = :ts.controller.fundReq.Id].size(), ts.controller.getProgramSize());
        System.assertEquals([SELECT Id, Grant_Request__c FROM GFRS_RequestBudget__c WHERE Grant_Request__c = :ts.controller.fundReq.Id].size(), ts.controller.getBudgetSize());

        System.assert(ts.controller.showDemographic);
        System.assertEquals(1, ts.controller.demographics.size());

        System.assert(!ts.controller.isCMEOShown);

        ts.controller.programs = null;
        ts.controller.budgets = null;
        System.assertEquals(0, ts.controller.getProgramSize());
        System.assertEquals(0, ts.controller.getBudgetSize());

        System.assert(ts.controller.getPaymentDeliveryUser.equals(''));
    }

    @IsTest
    static void testIsFoundationShownForHCCHAR() {
        TestSettings ts = new TestSettings();
        ts.setupHCCHAR();
        ts.setupController();

        System.assert(!ts.controller.isFoundationShown, 'For HC Char should be false');
    }

    @IsTest
    static void testIsFoundationShownForFellowships() {
        TestSettings ts = new TestSettings();
        ts.setupFellowships();
        ts.setupController();

        System.assert(!ts.controller.isFoundationShown, 'For Philanthropic without Students or Hunger should be false');
    }

    @IsTest
    static void testIsFoundationShownForPhilanthropic() {
        TestSettings ts = new TestSettings();
        ts.setupPhilanthropic();
        ts.setupController();

        System.assert(!ts.controller.isFoundationShown, 'For Fellowships without Basic Research Fellow should be false');
    }

    @IsTest
    static void testIsFoundationShownForIMED() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupController();

        System.assert(!ts.controller.isFoundationShown, 'For IMED should be false');
    }
}