@IsTest
private class gFRS_AnnualReportControllerTest {

    public static final String PATH_COMPLETE = '/apex/GFRS_Home';

    class TestSettings {
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;

        User portalUser;
        public Account account;
        public Contact contact;
        public GFRS_Program__c program;
        public GFRS_Funding_Request__c request;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public gFRS_Annual_Evaluation__c evaluation;
        public gFRS_Tasks__c task;

        public gFRS_AnnualReportController controller;

        public TestSettings() {
            this.account = gFRS_TestCreationUtils.createAccount(gFRS_TestCreationUtils.makeUnique('acct'));
            insert this.account;

            this.contact = gFRS_TestCreationUtils.createContact(this.account);
            insert this.contact;

            this.portalUser = gFRS_TestCreationUtils.createUser(this.contact, 'test@gene.com');
            insert this.portalUser;

            this.organization = gFRS_TestCreationUtils.createOrganization2('12345-1234', this.account.id);
            insert this.organization;

            this.location = gFRS_TestCreationUtils.createLocation('SomeLocation', this.organization.id);
            insert this.location;
        }

        public void setupIMED() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.LOA_Signed__c = 'No';
            this.request.Information_Needed__c = 'test';
            insert this.request;
            this.completeRequest();
        }

        public void completeRequest() {
            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            Date endDate = Date.today().addMonths(2);
            this.program.End_Date__c = endDate;
            insert this.program;
        }

        public void setupExhibits() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';

            insert this.request;
        }

        public void setupAnnualEvaluation() {
            this.evaluation = new GFRS_Annual_Evaluation__c(Funding_Request__c = this.request.Id);
            this.task = gFRS_TestCreationUtils.createTask2(this.request.id, 'Please Review', this.portalUser.Id);
            this.task.Action_Type__c = 'Annual Evaluation';
            this.task.Years_Before_Annual_Evaluation__c = 1;
            insert this.task;
        }

        public void setupAnnualEvaluationValid() {
            this.evaluation = new GFRS_Annual_Evaluation__c(Funding_Request__c = this.request.Id,
                                                            Were_Goals_Met__c='test',
                                                            Upcoming_Publications__c='Yes',
                                                            Meeting_Presentations__c='No');
            this.task = gFRS_TestCreationUtils.createTask2(this.request.id, 'Please Review', this.portalUser.Id);
            insert this.evaluation;

            this.task.Action_Type__c = 'Annual Evaluation';
            this.task.Years_Before_Annual_Evaluation__c = 1;
            insert this.task;
        }

        public void setupControllerIndex0() {
            ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + this.request.id + '&' + gFRS_UTIL.PARAM_CURRENT_INDEX + '=0');
            Test.setCurrentPage(imedPage);
            ApexPages.currentPage().getParameters().put('requestId', this.request.Id);
            ApexPages.currentPage().getParameters().put('task', this.task.Id);
            this.controller = new gFRS_AnnualReportController(new ApexPages.StandardController(this.evaluation));
        }

    }

    @IsTest
    private static void uploadFinancialReportTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupAnnualEvaluation();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.uploadFinancialReport();
        Test.stopTest();

        System.assertEquals(null, ts.controller.financialReport.body);
    }

    @IsTest
    private static void doSaveValidateFailTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupAnnualEvaluation();
        ts.setupControllerIndex0();

        Test.startTest();
        PageReference pageReference = ts.controller.doSave();
        Test.stopTest();

        System.assertEquals(null, pageReference);
    }

    @IsTest
    private static void doSaveValidateSuccessTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupAnnualEvaluationValid();
        ts.setupControllerIndex0();

        Test.startTest();
        PageReference pageReference = ts.controller.doSave();
        Test.stopTest();

        System.assertEquals(PATH_COMPLETE, pageReference.getUrl());
    }
}