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
private class gFRS_SideBarControllerTester {

    /**
     *  Internal Testing class that takes care of setup and tear downs.
     **/
    class TestSettings {

        //-- instance variables
        gFRS_SidebarController controller;
        GFRS_Funding_Request__c request;

        public TestSettings() {
            //-- initialization done for ALL SETUPs done here
            this.controller = new gFRS_SidebarController();
        }

        public void createNewRequest(Id recordTypeId) {
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

            gFRS_TestCreationUtils.initialize();

            request = gFRS_TestCreationUtils.createFundingRequest2(
                    recordTypeId,
                    gFRS_Util.REQUEST_DEFAULT_STATUS,
                    gFRS_Util.REQUEST_DEFAULT_SUB_STATUS,
                    gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS,
                    '',
                    organizationId,
                    localizationId
            );
            request.Will_You_be_Working_With_a_3rd_Party__c = gFRS_Util.YES;
            request.Total_Program_Budget__c = 1000;
            insert request;

            request = [
                    SELECT
                            Id,
                            RecordTypeId,
                            Record_Type_Name__c,
                            RecordType.Name,
                            Sub_Status__c,
                            Event_Project_sub_type__c,
                            External_Sub_status__c,
                            Organization__c,
                            Attention_To__c,
                            Information_Needed__c,
                            Send_By_FedEx_cost_center_will_be_charg__c,
                            Will_You_be_Working_With_a_3rd_Party__c,
                            Status__c,Location__c,
                            Event_Project_type__c
                    FROM GFRS_Funding_Request__c
                    WHERE Id = :request.Id
            ];
        }
    }

    @isTest(SeeAllData=true)
    static void testSettingsSetsUpWithoutErrors() {
        try {
            TestSettings ts = new TestSettings();
            //ts.setupA(); //-- perform specialized setup if needed
        } catch (Exception err) {
            System.assert(false, 'TestSetting/Setup must not throw any exceptions');
        }
    }

    @isTest(SeeAllData=true)
    static void testSection1Style() {
        TestSettings ts = new TestSettings();
        ts.controller.currentSection = '1';

        System.assertEquals(gFRS_SidebarController.STYLE_OVER, ts.controller.nav1Style, 'since we are in section 1, that should be over style');
        System.assertEquals('1', ts.controller.currentSection, 'the current section must be persisted when queried');
    }

    @isTest(SeeAllData=true)
    static void testSection2Style() {
        TestSettings ts = new TestSettings();
        ts.controller.currentSection = '2';

        System.assertEquals(gFRS_SidebarController.STYLE_OVER, ts.controller.nav2Style, 'since we are in section 2, that should be over style');
        System.assertEquals('2', ts.controller.currentSection, 'the current section must be persisted when queried');
    }

    @isTest(SeeAllData=true)
    static void testSection3Style() {
        TestSettings ts = new TestSettings();
        ts.controller.currentSection = '3';

        System.assertEquals(gFRS_SidebarController.STYLE_OVER, ts.controller.nav3Style, 'since we are in section 3, that should be over style');
        System.assertEquals('3', ts.controller.currentSection, 'the current section must be persisted when queried');
    }

    @isTest(SeeAllData=true)
    static void testSection4Style() {
        TestSettings ts = new TestSettings();
        ts.controller.currentSection = '4';

        System.assertEquals(gFRS_SidebarController.STYLE_OVER, ts.controller.nav4Style, 'since we are in section 4, that should be over style');
        System.assertEquals('4', ts.controller.currentSection, 'the current section must be persisted when queried');
    }

    @isTest(SeeAllData=true)
    static void testSection9Style() {
        TestSettings ts = new TestSettings();
        ts.controller.currentSection = '9';

        System.assertEquals(gFRS_SidebarController.STYLE_OVER, ts.controller.nav1Style);
        System.assertEquals(gFRS_SidebarController.STYLE_CLEAR, ts.controller.nav2Style);
        System.assertEquals(gFRS_SidebarController.STYLE_CLEAR, ts.controller.nav3Style);
        System.assertEquals(gFRS_SidebarController.STYLE_CLEAR, ts.controller.nav4Style);
        System.assertEquals('9', ts.controller.currentSection);
    }

    @IsTest
    static void testCheckIfProgramDesignVisible() {
        TestSettings ts = new TestSettings();
        ts.createNewRequest(gFRS_TestCreationUtils.RT_FR_IMED);
        System.assert(ts.controller.checkIfProgramDesignVisible(ts.request));
    }

    @IsTest
    static void testCheckIfThirdPartyVisible() {
        TestSettings ts = new TestSettings();
        ts.createNewRequest(gFRS_TestCreationUtils.RT_FR_IMED);
        System.assert(ts.controller.chechIfThirdPartyVisible(ts.request));
    }

    @IsTest
    static void testCheckThirdPartyAvailability() {
        TestSettings ts = new TestSettings();
        ts.createNewRequest(gFRS_TestCreationUtils.RT_FR_IMED);
        System.assert(!ts.controller.checkThirdPartyAvailability(ts.request));
    }

    @IsTest
    static void testCheckProgramDesignAvailability() {
        TestSettings ts = new TestSettings();
        ts.createNewRequest(gFRS_TestCreationUtils.RT_FR_IMED);
        System.assert(!ts.controller.checkProgramDesignAvailability(ts.request));
    }

    @IsTest
    static void testCheckProgramAvailability() {
        TestSettings ts = new TestSettings();
        ts.createNewRequest(gFRS_TestCreationUtils.RT_FR_IMED);
        System.assert(!ts.controller.checkProgramAvailability(ts.request));
    }

    @IsTest
    static void testGetMenuOptions() {
        PageReference pageRef = Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pageRef);
        TestSettings ts = new TestSettings();

        ts.createNewRequest(gFRS_TestCreationUtils.RT_FR_HC_CHAR);

        ts.controller.fundingRequest = ts.request;

        List<gFRS_SidebarController.MenuWrapper> result = ts.controller.getMenuOptions();
        System.assertEquals(6, result.size());

        for (gFRS_SidebarController.MenuWrapper menuWrapper : result) {
            if (menuWrapper.label.equals('Organization') ||
                    menuWrapper.label.equals('Application') ||
                    menuWrapper.label.equals('Program') ||
                    menuWrapper.label.equals('Third Party') ||
                    menuWrapper.label.equals('Budget') ||
                    menuWrapper.label.equals('Confirmation')) {
                System.assert(true);
            } else {
                System.assert(false);
            }
        }
    }
}