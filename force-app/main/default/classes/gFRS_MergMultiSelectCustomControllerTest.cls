@IsTest
private class gFRS_MergMultiSelectCustomControllerTest {

    class TestSettings {
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;

        User user;
        public Account account;
        public GFRS_Program__c program;
        public GFRS_Funding_Request__c request;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;

        public gFRS_MergMultiSelectCustomController controller;

        public TestSettings() {
            this.account = gFRS_TestCreationUtils.createAccount(gFRS_TestCreationUtils.makeUnique('acct'));
            insert this.account;

            this.organization = gFRS_TestCreationUtils.createOrganization2('12345-1234', this.account.id);
            insert this.organization;
            System.debug('this.organization ' + this.organization);

            this.location = gFRS_TestCreationUtils.createLocation('SomeLocation', this.organization.id);
            insert this.location;
        }
        public void setupIMED() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.LOA_Signed__c = 'No';
            this.request.Information_Needed__c = 'test';
            insert this.request;
        }

        public void setupIMEDWithNQS() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.LOA_Signed__c = 'No';
            this.request.Information_Needed__c = 'test';
            this.request.NQS_Criteria__c = 'Making Care Safer';
            insert this.request;
        }

        public void setupExhibits() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            insert this.request;
        }

        public void setupControllerIndex0() {
            ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + this.request.id + '&fundingType=' + gFRS_UTIL.TYPE_IMED_NAME);
            Test.setCurrentPage(imedPage);

            this.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(this.request));
        }

        public void setupControllerIndex1() {
            ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + this.request.id);
            Test.setCurrentPage(imedPage);
            ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_SCIENTIFIC_PROJECTS_NAME);

            this.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(this.request));
        }

        public void setupControllerIndex2() {
            ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + this.request.id);
            Test.setCurrentPage(imedPage);
            ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_SCIENTIFIC_PROJECTS_NAME);
            ApexPages.currentPage().getParameters().put('isExportToExcel', 'Yes');

            this.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(this.request));
        }
    }

    @IsTest
    private static void constructorControllerIMEDTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
    }

    @IsTest
    private static void constructorControllerScientificTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex1();
    }

    @IsTest
    private static void constructorControllerScientificAndExportToExcelTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex2();
    }

    @IsTest
    private static void getMuliSelectDSExcelTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + ts.request.id);
        Test.setCurrentPage(imedPage);
        ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_SCIENTIFIC_PROJECTS_NAME);
        ApexPages.currentPage().getParameters().put('DS', 'test');
        ts.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(ts.request));

        Test.startTest();
        String result = ts.controller.getMuliSelectDSExcel();
        Test.stopTest();
    }

    @IsTest
    private static void getfundingTypeTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex2();

        Test.startTest();
        List<SelectOption> options = ts.controller.getfundingType();
        Test.stopTest();

        System.assertEquals(2, options.size());
    }

    @IsTest
    private static void setMultiselectTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex2();

        ts.controller.dsAvailableValuesToSelect='test,test1,test2';

        Test.startTest();
        ts.controller.setMultiselect();
        Test.stopTest();

        System.assertEquals(3, ts.controller.leftSelectOptions.size());
    }

    @IsTest
    private static void getQuestionPickListTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex2();

        Test.startTest();
        List<SelectOption> options = ts.controller.getQuestionPickList();
        Test.stopTest();

        System.assertEquals(2, options.size());
    }

    @IsTest
    private static void changeFundingTypeTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex1();

        Test.startTest();
        ts.controller.changeFundingType();
        Test.stopTest();

        System.assertEquals('Yes', ts.controller.nqsPicklstVal);
        System.assertEquals('No', ts.controller.barrierPicklstVal);
    }

    @IsTest
    private static void changeBarrierTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex1();

        Test.startTest();
        ts.controller.changeBarrier();
        Test.stopTest();

        System.assertEquals('No', ts.controller.nqsPicklstVal);
        System.assertEquals('No', ts.controller.qualityPicklstVal);
    }

    @IsTest
    private static void changeQualityTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex1();

        Test.startTest();
        ts.controller.changeQuality();
        Test.stopTest();

        System.assertEquals('No', ts.controller.nqsPicklstVal);
        System.assertEquals('No', ts.controller.barrierPicklstVal);
    }

    @IsTest
    private static void renderInConditionForDsTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex1();

        ts.controller.therapeuticAreaSelected = new List<String> { 'test', 'test2'};

        Test.startTest();
        String result = ts.controller.renderInConditionForDs();
        Test.stopTest();

        System.assertEquals(true, String.isNotBlank(result) );
    }

    @IsTest
    private static void generateReportTherapeuticAreaAndNoSelectedTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + ts.request.id);
        Test.setCurrentPage(imedPage);
        ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_SCIENTIFIC_PROJECTS_NAME);
        ApexPages.currentPage().getParameters().put('isExportToExcel', 'Yes');
        ApexPages.currentPage().getParameters().put('TA', 'Cardiology');
        ts.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(ts.request));

        Test.startTest();
        PageReference pageReference = ts.controller.generateReport();
        Test.stopTest();
        System.assertEquals(null, pageReference);
    }

    @IsTest
    private static void generateReportTherapeuticAreaAndSelectedTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + ts.request.id);
        Test.setCurrentPage(imedPage);
        ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_SCIENTIFIC_PROJECTS_NAME);
        ApexPages.currentPage().getParameters().put('isExportToExcel', 'Yes');
        ApexPages.currentPage().getParameters().put('TA', 'Cardiology');
        ApexPages.currentPage().getParameters().put('nqsPicklstVal', 'Yes');
        ts.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(ts.request));
        ts.controller.therapeuticAreaSelected = new List<String> { 'test1', 'test2'};

        Test.startTest();
        PageReference pageReference = ts.controller.generateReport();
        Test.stopTest();
        System.assertEquals(null, pageReference);
    }

    @IsTest
    private static void generateReportTherapeuticAreaAndSelectedAndNQSTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + ts.request.id);
        Test.setCurrentPage(imedPage);
        ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_SCIENTIFIC_PROJECTS_NAME);
        ApexPages.currentPage().getParameters().put('isExportToExcel', 'Yes');
        ApexPages.currentPage().getParameters().put('TA', 'Cardiology');
        ts.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(ts.request));
        ts.controller.therapeuticAreaSelected = new List<String> { 'test1', 'test2'};
        ts.controller.nqsPicklstVal = 'Yes';


        Test.startTest();
        PageReference pageReference = ts.controller.generateReport();
        Test.stopTest();
        System.assertEquals(null, pageReference);
    }

    @IsTest
    private static void generateReportTherapeuticAreaAndSelectedandBarrierTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + ts.request.id);
        Test.setCurrentPage(imedPage);
        ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_SCIENTIFIC_PROJECTS_NAME);
        ApexPages.currentPage().getParameters().put('isExportToExcel', 'Yes');
        ApexPages.currentPage().getParameters().put('TA', 'Cardiology');
        ts.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(ts.request));
        ts.controller.therapeuticAreaSelected = new List<String> { 'test1', 'test2'};
        ts.controller.barrierPicklstVal = 'Yes';


        Test.startTest();
        PageReference pageReference = ts.controller.generateReport();
        Test.stopTest();
        System.assertEquals(null, pageReference);
    }

    @IsTest
    private static void generateReportTherapeuticAreaAndSelectedandQualityTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + ts.request.id);
        Test.setCurrentPage(imedPage);
        ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_SCIENTIFIC_PROJECTS_NAME);
        ApexPages.currentPage().getParameters().put('isExportToExcel', 'Yes');
        ApexPages.currentPage().getParameters().put('TA', 'Cardiology');
        ts.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(ts.request));
        ts.controller.therapeuticAreaSelected = new List<String> { 'test1', 'test2'};
        ts.controller.qualityPicklstVal = 'Yes';


        Test.startTest();
        PageReference pageReference = ts.controller.generateReport();
        Test.stopTest();
        System.assertEquals(null, pageReference);
    }

    @IsTest
    private static void generateReportTherapeuticAreaAndSelectedAndNQSNotNullTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMEDWithNQS();
        ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + ts.request.id);
        Test.setCurrentPage(imedPage);
        ApexPages.currentPage().getParameters().put('fundType', gFRS_UTIL.TYPE_IMED_DESCRIPTION);
        ApexPages.currentPage().getParameters().put('isExportToExcel', 'Yes');
        ApexPages.currentPage().getParameters().put('nqsPicklstVal', 'Yes');
        ApexPages.currentPage().getParameters().put('TA', 'Cardiology');
        ApexPages.currentPage().getParameters().put('NQS', 'Making Care Safer');
        ApexPages.currentPage().getParameters().put('DS', 'Bipolar');
        ts.controller = new gFRS_MergMultiSelectCustomController(new ApexPages.StandardController(ts.request));
        ts.controller.therapeuticAreaSelected = new List<String> { 'test1', 'test2'};

        Test.startTest();
        PageReference pageReference = ts.controller.generateReport();
        Test.stopTest();
        System.assertEquals(null, pageReference);
    }
}