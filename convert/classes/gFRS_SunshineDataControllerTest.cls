@isTest
private class gFRS_SunshineDataControllerTest {

    private static final String SUNSHINE_REPORT_API_NAME = 'Sunshine_Report__c';
    private static final String FUNDING_REQUEST_API_NAME = 'gFRS_Funding_Request__c';

    class TestSettings {
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;
        public  Integer NUM = 2;

        public User user;
        public Account account;
        public GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        public GFRS_Program__c program;
        public GFRS_Funding_Request__c request;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;

        public gFRS_SunshineDataController controller;

        public TestSettings() {
            this.account = gFRS_TestCreationUtils.createAccount(gFRS_TestCreationUtils.makeUnique('acct'));
            insert this.account;

            this.organization = gFRS_TestCreationUtils.createOrganization2('20110101', this.account.id);
            insert this.organization;
            System.debug('this.organization ' + this.organization);

            this.location = gFRS_TestCreationUtils.createLocation('SomeLocation', this.organization.id);
            insert this.location;

            PROF_GFRS_USER = [select Id, Name, Type from Profile where Name = :PROF_GFRS_USER_NAME limit 1].Id;
            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;

            if (customSettings.gFRS_Legal_Reviewer_Fields_Required__c) {
                customSettings.gFRS_Legal_Reviewer_Fields_Required__c = false;
                upsert customSettings GFRS_OrgSettings__c.Id;
            }
        }

        public void setupExhibits() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            insert request;
        }

        public void setupExhibitsReconciliationCompleted() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            this.request.Reconciliation_Completed__c = 'Yes';
            this.request.Sunshine_Communication_Sent__c = true;
            this.request.Closed_Date__c = Date.today();
            insert request;
        }

        public void createReconciliation(Id request) {
            gFRS_Util_NoShare.createTask('Not Started', 'Test Subject', null, request, null, 'Reconciliation');
        }

        public void setupControllerIndex0() {
            ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + this.request.id + '&' + gFRS_UTIL.PARAM_CURRENT_INDEX + '=0');
            Test.setCurrentPage(imedPage);
            this.controller = new gFRS_SunshineDataController(new ApexPages.StandardController(this.request));
        }
    }

    @isTest
    private static void savePageTestWithoutReconciliationsTasks() {
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.savePage();
        Test.stopTest();

        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES, ts.controller.request.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES, ts.controller.request.External_Sub_status__c);
    }

    @isTest
    private static void savePageTestWithReconciliationsTasks() {
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.createReconciliation(ts.request.Id);
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.savePage();
        Test.stopTest();

        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ, ts.controller.request.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ, ts.controller.request.External_Sub_status__c);
    }

    @isTest
    private static void savePageTestWithoutReconciliationsTasksCompletedAndCommunicationSent() {
        TestSettings ts = new TestSettings();
        ts.setupExhibitsReconciliationCompleted();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.savePage();
        Test.stopTest();

        System.assertEquals(gFRS_Util.REQUEST_STATUS_CLOSED, ts.controller.request.Status__c);
        System.assertEquals(gFRS_Util.REQUEST_SUB_STATUS_APPROVED, ts.controller.request.Sub_Status__c);
        System.assertEquals(gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED, ts.controller.request.External_Sub_status__c);
    }

    @isTest
    private static void uploadSunshineReportNewAttachmentTrueTest() {
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.uploadSunshineReport();
        Test.stopTest();

        System.assertEquals(null, ts.controller.sunshineReport.Body);
    }

    @isTest
    private static void uploadSunshineReportNewAttachmentFalseTest() {
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        String documentName = 'Vendor_Details_' + ts.request.Name + '_V1.pdf';
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, documentName, Blob.valueOf('testBody'));
        insert att;
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.uploadSunshineReport();
        Test.stopTest();

        System.assertEquals(null, ts.controller.sunshineReport.Body);
    }

    @isTest
    private static void uploadFundingRequestAttachmentTest() {
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.setupControllerIndex0();
        String documentName = 'Vendor_Details_' + ts.request.Name + '_V1.pdf';
        ts.controller.sunshineReport.Name = documentName;
        ts.controller.sunshineReport.Body = Blob.valueOf('testBody');

        Boolean createNewAttachment = true;
        Test.startTest();
        ts.controller.uploadFundingRequestAttachment(SUNSHINE_REPORT_API_NAME, SUNSHINE_REPORT_API_NAME.toLowerCase(), false);
        Test.stopTest();

        System.assertEquals(null, ts.controller.request.IsValidationExternalOnly__c);
        System.assertEquals(null, ts.controller.sunshineReport.Body);
    }

    @isTest
    private static void clearSunshineReportNameTest() {
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.clearSunshineReportName();
        Test.stopTest();

        System.assertEquals(null, ts.controller.sunshineReport.Name );
        System.assertEquals(null, ts.controller.sunshineReport.Body);
    }
}