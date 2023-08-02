@isTest
private class GFRS_Status_ReportControllerTester {

    class TestSettings {
        //-- profiles
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;
        //organization
        GFRS_Organization__c organization;
        Contact contact;
        Account account;
        User user;
        public GFRS_Funding_Request__c request;
        public GFRS_Program__c program;

        public String DEFAULT_STATUS = 'Intake';
        public String DEFAULT_SUB_STATUS = 'Not Submitted';

        public TestSettings() {
            PROF_GFRS_USER = [select Id, Name, Type from Profile where Name = :PROF_GFRS_USER_NAME limit 1].Id;
            account = gFRS_TestCreationUtils.createAccount('test');
            insert account;
            organization = gFRS_TestCreationUtils.createOrganization('223344556', account);
            insert organization;
            contact = gFRS_TestCreationUtils.createContact(account);
            insert contact;
            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;
        }

        public void createFundingRequestWithProgram() {
            this.request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED, DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, null);
            insert this.request;

            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            this.program.Program_Status__c = 'Completed';
            insert this.program;
        }

        public void createFundingRequestWithProgramNotCompleted() {
            this.request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED, DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, null);
            insert this.request;

            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            this.program.Program_Status__c = 'Complete';
            insert this.program;
        }

        public void createProgram() {
            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            Date endDate = Date.today().addDays(-2);
            this.program.End_Date__c = endDate;
            this.program.Program_Status__c = 'Planned';
            insert this.program;
        }

        public void createProgramWithRange() {
            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            Date startDate = Date.today();
            Date endDate = Date.today().addDays(2);
            this.program.Start_Date__c = startDate;
            this.program.End_Date__c = endDate;
            insert this.program;
        }

        public void createProgramStatusNull() {
            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            this.program.Start_Date__c = null;
            this.program.End_Date__c = null;
            this.program.Program_Status__c = null;
            insert this.program;
        }

        public void createWebProgram() {
            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            this.program.Program_Status__c = 'Completed';
            this.program.Venue_Country__c = 'Aruba';
            this.program.Venue_Province_Region__c = null;
            this.program.Start_Date__c = Date.today();
            this.program.Venue_State__c = null;
            insert this.program;
        }
        public void createProgramStatusConfirmed() {
            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            this.program.Program_Status__c = gFRS_Util.PROGRAM_STATUS_CONFIRMED;
            this.program.Venue_Name__c = null;
            this.program.Venue_City__c = null;
            this.program.Venue_Country__c = null;
            this.program.Venue_Type__c = null;

            insert this.program;
        }

        public void createTask() {
            gFRS_Util_NoShare.createTask(gFRS_Util.TASK_NOT_SUBMITTED, 'Test Subject', null, this.request.id, null, 'Status Report');
        }
    }

    @isTest
    private static void testConstructor() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            System.assertNotEquals(null, ts.request, 'Funding Request object has not been created');
            System.assertNotEquals(null, ts.program, 'Funding Request Program object has not been created');

            Test.startTest();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

            system.assertEquals(false, cont.isLastProgramSelected);
            system.assertEquals(ts.request.Id, cont.fundReq.Id);
            system.assertEquals(true, cont.isEditable);
            Test.stopTest();
        }
    }

    @isTest
    private static void testConstructorNullInsteadOfFundingRequset() {
        TestSettings ts = new TestSettings();
        GFRS_Funding_Request__c fundingRequest = new GFRS_Funding_Request__c();
        Test.startTest();
        GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(fundingRequest));
        list<Apexpages.Message> msgs = Apexpages.getMessages();
        Boolean exists = false;
        for (Apexpages.Message m : msgs) {
            if (m.getDetail() == 'Funding request was not sent') {
                exists = true;
                break;
            }
        }
        System.assertEquals(true, exists, 'Missing error message');
        Test.stopTest();
    }

    @isTest
    private static void testSaveProgram() {
        TestSettings ts = new TestSettings();
        ts.createFundingRequestWithProgram();
        GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

        Test.startTest();
        cont.saveProgram();
        Test.stopTest();
    }

    @isTest
    private static void testSaveReport() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            System.assertNotEquals(null, ts.request, 'Funding Request object has not been created');
            System.assertNotEquals(null, ts.program, 'Funding Request Program object has not been created');

            Test.startTest();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            // cont.updateStatus = 'No';
            Apexpages.Pagereference pr = cont.saveReport();

            system.assertEquals(null, pr);
            Test.stopTest();
        }
    }

    @isTest
    private static void testSaveReportIsEditable() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            System.assertNotEquals(null, ts.request, 'Funding Request object has not been created');
            System.assertNotEquals(null, ts.program, 'Funding Request Program object has not been created');

            Test.startTest();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            cont.isEditable = false;
            // cont.updateStatus = 'No';
            Apexpages.Pagereference pr = cont.saveReport();

            system.assertEquals(null, pr);
            Test.stopTest();
        }
    }

    @isTest
    private static void changeValueInCommercialTest() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            cont.changedField = 'Change_in_Number_of_Commercial__c';

            Test.startTest();
            cont.changeValue();
            Test.stopTest();
            System.assertEquals(null, cont.fundReq.If_Yes_New_Total_Budget_for_Program__c);
            System.assertEquals(false, cont.isTotalBugetAmountReq);
        }
    }

    @isTest
    private static void changeValueEducationalObjectiveTest() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            cont.changedField = 'Did_Educational_Objectives_Change__c';

            Test.startTest();
            cont.changeValue();
            Test.stopTest();
            System.assertEquals(null, cont.fundReq.If_Yes_New_Total_Budget_for_Program__c);
            System.assertEquals(false, cont.isTotalBugetAmountReq);
        }
    }

    @isTest
    private static void changeValueTotalBudgetTest() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            cont.changedField = 'Did_Total_Budget_Amount_for_this_Program__c';

            Test.startTest();
            cont.changeValue();
            Test.stopTest();

            System.assertEquals(null, cont.fundReq.If_Yes_New_Total_Budget_for_Program__c);
            System.assertEquals(false, cont.isTotalBugetAmountReq);
        }
    }

    @isTest
    private static void getShowProgramsToUpdateMessageTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgram();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

            Test.startTest();
            Boolean isToUpdate = cont.getShowProgramsToUpdateMessage();
            Test.stopTest();

            System.assertEquals(true, isToUpdate);
        }
    }

    @isTest
    private static void getProgramsToUpdateTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgram();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

            Test.startTest();
            List<GFRS_Program__c> programsToUpdate = cont.getProgramsToUpdate();
            Test.stopTest();

            System.assertEquals(1, programsToUpdate.size());
        }
    }

    @IsTest
    private static void updateTaskStatusTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgram();
            ts.createTask();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

            Test.startTest();
            ApexPages.PageReference pageReference = cont.updateTaskStatus();
            Test.stopTest();

            System.assertEquals(null, pageReference);
        }
    }

    @IsTest
    private static void backTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            cont.showprograms = true;
            ApexPages.Pagereference pageReference = cont.back();

            System.assertEquals(false, cont.showprograms);
            System.assertEquals(null, pageReference);
        }
    }

    @IsTest
    private static void validateLiveProgramVenueRequiredTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgramWithRange();

            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            cont.isVenueRequired = false;

            Test.startTest();
            Boolean isValid = cont.validateLiveProgram(ts.program);
            Test.stopTest();

            System.assertEquals(false, isValid);
        }
    }

    @IsTest
    private static void validateLiveProgramVenueRequiredNullTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgramStatusNull();

            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            cont.isVenueRequired = true;

            Test.startTest();
            Boolean isValid = cont.validateLiveProgram(ts.program);
            Test.stopTest();

            System.assertEquals(false, isValid);
        }
    }

    @IsTest
    private static void validateLiveProgramVenueRequiredConfirmedTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgramStatusConfirmed();

            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            cont.isVenueRequired = true;

            Test.startTest();
            Boolean isValid = cont.validateLiveProgram(ts.program);
            Test.stopTest();

            System.assertEquals(false, isValid);
        }
    }

    @IsTest
    private static void validateEnduringProgramTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgramStatusNull();

            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

            Test.startTest();
            Boolean isValid = cont.validateEnduringProgram(ts.program);
            Test.stopTest();

            System.assertEquals(false, isValid);
        }
    }


    @IsTest
    private static void validateGrandRoundsProgramTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgramStatusNull();

            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

            Test.startTest();
            Boolean isValid = cont.validateGrandRoundsProgram(ts.program);
            Test.stopTest();

            System.assertEquals(false, isValid);
        }
    }

    @IsTest
    private static void validateWebProgramTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createProgramStatusNull();

            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

            Test.startTest();
            Boolean isValid = cont.validateWebProgram(ts.program);
            Test.stopTest();

            System.assertEquals(false, isValid);
        }
    }

    @IsTest
    private static void globalProgramValidationTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createWebProgram();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));

            Test.startTest();
            Boolean isValid = cont.globalProgramValidation(ts.program);
            Test.stopTest();

            System.assertEquals(false, isValid);
        }
    }

    @IsTest
    private static void globalProgramValidationUSTest() {
        TestSettings ts = new TestSettings();

        System.RunAs(ts.user) {
            ts.createFundingRequestWithProgram();
            ts.createWebProgram();
            GFRS_Status_ReportController cont = new GFRS_Status_ReportController(new ApexPages.StandardController(ts.request));
            ts.program.Venue_Country__c = 'United States';
            ts.program.Venue_State__c = 'AK';
            ts.program.Start_Date__c = Date.today();
            upsert ts.program;

            Test.startTest();
            Boolean isValid = cont.globalProgramValidation(ts.program);
            Test.stopTest();

            System.assertEquals(true, isValid);
        }
    }
}