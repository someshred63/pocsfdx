/**
 * Created by tosiks on 29.01.2018.
 */

@IsTest
private class GFRS_gCal_User_PreferenceControllerTest {
    class TestSettings {

        public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        public GFRS_Payment_History__c paymentHistory;
        public GFRS_WBS_Codes__c wbs;
        public GFRS_Cost_Center_Code__c costCenter;
        public GFRS_gCal_User_PreferenceController controller;

        public TestSettings() {
            //gFRS_TestCreationUtils.initialize();
            this.account = gFRS_TestCreationUtils.createAccount(gFRS_TestCreationUtils.makeUnique('acct'));
            insert this.account;

            this.organization = gFRS_TestCreationUtils.createOrganization2('20110101', this.account.id);
            insert this.organization;

            this.location = gFRS_TestCreationUtils.createLocation('SomeLocation', this.organization.id);
            insert this.location;

            this.wbs = gFRS_TestCreationUtils.createWBSCode('testIMED_A', 'Asthma', gFRS_Util.TYPE_IMED_NAME);
            insert this.wbs;

            this.costCenter = gFRS_TestCreationUtils.createCostCenter('testIMED', gFRS_Util.TYPE_IMED_NAME);
            insert this.costCenter;
        }

        public void setupIMED() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            insert this.request;
            this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c from GFRS_Funding_Request__c where Id = :this.request.Id];
        }

        public void setupControllerIndex0() {
            ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + this.request.id + '&' + gFRS_UTIL.PARAM_CURRENT_INDEX + '=0');
            Test.setCurrentPage(imedPage);
            this.controller = new GFRS_gCal_User_PreferenceController(new ApexPages.StandardController(new UnifiedCalendarUserEventPreference_gne__c()));
        }
    }

    @IsTest
    private static void testControllerConstructor() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();

        Test.startTest();
        ts.setupControllerIndex0();
        Test.stopTest();

        System.assertEquals(false, ts.controller.SaveButtonRender);
    }

    @IsTest
    private static void initTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        Test.startTest();
        PageReference pageReference = ts.controller.init();
        Test.stopTest();

        System.assertEquals(false, ts.controller.SaveButtonRender);
        System.assertEquals(null, pageReference);
    }

    @isTest
    private static void initCustomTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        Test.startTest();
        PageReference pageReference = ts.controller.initCustom();
        Test.stopTest();

        System.assertEquals(false, ts.controller.SaveButtonRender);
        System.assertEquals(null, pageReference);
    }

    @isTest
    private static void saveTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        Test.startTest();
        PageReference pageReference = ts.controller.save();
        Test.stopTest();

        System.assertEquals(false, ts.controller.SaveButtonRender);
        System.assertEquals(null, pageReference);
    }
}