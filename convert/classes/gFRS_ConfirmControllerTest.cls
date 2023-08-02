@IsTest
private class gFRS_ConfirmControllerTest {
    
    public static final String PATH_ATTACHMENTS = '/apex/gFRS_FileAttachments';

    class TestSettings {
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;

        User user;
        public Account account;
        public GFRS_Program__c program;
        public GFRS_Funding_Request__c request;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;

        public gFRS_ConfirmController controller;

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
            this.prepareRequestForUpdate();
            insert this.request;
        }

        public void setupExhibits() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            this.prepareRequestForUpdate();
            insert this.request;
        }

        public void setupExhibitsValidateSuccess() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            this.request.Letter_of_Request__c = 'test';
            this.request.Meeting_Agenda__c = 'test';
            this.request.Promotional_Event_Advertising__c = 'test';
            this.request.Sub_Status__c = 'CCO Review';
            this.request.Signing_Authority_Email__c = 'test@test.com';
            this.request.Signing_Authority_First_Name__c = 'test';
            this.request.Signing_Authority_Last_Name__c = 'test';
            this.prepareRequestForUpdate();
            insert this.request;
        }

        public void setupIMEDValidateSuccess() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            this.request.Letter_of_Request__c = 'test';
            this.request.Meeting_Agenda__c = 'test';
            this.request.Promotional_Event_Advertising__c = 'test';
            this.prepareRequestForUpdate();
            insert this.request;
        }

        public void setupHCChar() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }

        public void setupFellowships() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            GFRS_Program__c program = gFRS_UnitTestHelper.createProgram(this.request.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_HC_RECTYPE);
            program.Venue_city__c = 'Test';
            this.prepareRequestForUpdate();
            insert program;
            insert this.request;
        }

        public void setupScientific() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }

        public void setupControllerIndex0() {
            ApexPages.PageReference imedPage = new ApexPages.PageReference('?id=' + this.request.id + '&' + gFRS_UTIL.PARAM_CURRENT_INDEX + '=0');
            Test.setCurrentPage(imedPage);

            this.controller = new gFRS_ConfirmController(new ApexPages.StandardController(this.request));
        }

        public void createUser() {
            PROF_GFRS_USER = [select Id, Name, Type from Profile where Name = :PROF_GFRS_USER_NAME limit 1].Id;
            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;
        }

        // cleanup the fundingRequest to the point that an update can occur
        public void prepareRequestForUpdate() {
            //this.request.Name = 'testRequest';
        }

        public void completeRequest() {
            this.program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            Date endDate = Date.today().addMonths(2);
            this.program.End_Date__c = endDate;
            insert this.program;
        }
    }

    @isTest
    private static void backTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        ApexPages.PageReference redirect = ts.controller.back();
        String targetUrl = redirect.getUrl();

        System.assertEquals(true, targetURL.contains(PATH_ATTACHMENTS), 'we are retirected to ' + targetUrl + ' since not hc char');
    }

    @isTest
    private static void nextPageTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
		
        Test.startTest();
        ApexPages.PageReference redirect = ts.controller.nextPage();
        Test.stopTest();
        String targetUrl = redirect.getUrl();

        System.assertEquals(false, targetURL.contains('/apex/GFRS_Home'), 'since we are not administrator, we are redirected to home page:' + targetUrl);
    }

    @isTest
    private static void isNotAuthorizedSignerOrInternalValidateSaveTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        ts.controller.isInternal = true;
        ts.controller.isUserAuthorizedSigner = false;

        Test.startTest();
        Boolean isPositive = ts.controller.validateSave();
        Test.stopTest();
        
        System.assertEquals(false, isPositive);
    }

    @isTest
    private static void isInternalAndValidateFailSaveTest() {
        //Validate Internal FT attachments
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.setupControllerIndex0();
        ts.controller.isInternal = false;
        ts.controller.isUserAuthorizedSigner = true;
        ts.controller.isRequestCloned = true;
		
        Test.startTest();
        Boolean isPositive = ts.controller.validateSave();
        Test.stopTest();
        
        System.assertEquals(false, isPositive);
    }

    @isTest
    private static void isInternalAndValidateFailureSaveTest() {
        //Validate Internal FT attachments
        TestSettings ts = new TestSettings();
        ts.setupExhibitsValidateSuccess();
        ts.completeRequest();
        ts.setupControllerIndex0();
        ts.controller.isInternal = false;
        ts.controller.isUserAuthorizedSigner = true;
        ts.controller.isRequestCloned = true;
        
        Test.startTest();
        Boolean isPositive = ts.controller.validateSave();
        Test.stopTest();
        
        System.assertEquals(false, isPositive);
    }

    @isTest
    private static void isInternalHCCharAndValidateSuccessSaveTest() {
        //Validate HC Char attachments
        TestSettings ts = new TestSettings();
        ts.setupHCChar();
        ts.setupControllerIndex0();
        ts.controller.isInternal = false;
        ts.controller.isUserAuthorizedSigner = true;
        ts.controller.isRequestCloned = true;

        Test.startTest();
        Boolean isPositive = ts.controller.validateSave();
        Test.stopTest();
        
        System.assertEquals(true, isPositive);
    }

    @isTest
    private static void isInternalScientificAndValidateFailureSaveTest() {
        //Validate External FT attachments
        TestSettings ts = new TestSettings();
        ts.setupScientific();
        ts.setupControllerIndex0();
        ts.controller.isInternal = false;
        ts.controller.isUserAuthorizedSigner = true;
        ts.controller.isRequestCloned = true;

        Boolean isPositive = ts.controller.validateSave();
    }

    @isTest
    private static void saveValidationSuccessIsInternalAndExhibitsTest() {
        TestSettings ts = new TestSettings();
        ts.setupExhibitsValidateSuccess();
        ts.setupControllerIndex0();
        ts.controller.isInternal = true;
        ts.controller.isUserAuthorizedSigner = true;
        ts.controller.isRequestCloned = true;

        Test.startTest();
        ApexPages.PageReference pageReference = ts.controller.save();
        Test.stopTest();

        String targetUrl = pageReference.getUrl();

        System.assertEquals(true, targetURL.contains(ts.request.Id), 'since we are not administrator, we are redirected to home page:' + targetUrl);
    }

    @isTest
    private static void populateAuthorizedSignerTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        ts.createUser();

        System.runAs(ts.user) {
            Test.startTest();
            ts.controller.populateAuthorizedSigner();
            Test.stopTest();
        }

     	System.assertEquals(ts.user.FirstName, ts.controller.request.Signing_Authority_First_Name__c);
        System.assertEquals(ts.user.LastName, ts.controller.request.Signing_Authority_Last_Name__c);
    }

    @isTest
    private static void clearAuthorizedSignerTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        Test.startTest();
        ts.controller.clearAuthorizedSigner();
        Test.stopTest();
		
        System.assertEquals(null, ts.controller.request.Signing_Authority_Email__c);
        System.assertEquals(null, ts.controller.request.Signing_Authority_First_Name__c);
        System.assertEquals(null, ts.controller.request.Signing_Authority_Last_Name__c);
    }

    @isTest
    private static void saveConfirmationInfoEmailTest() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
		ts.controller.confirmedEmail = 'test@test.com';
        
        System.debug('Signing AUTHORITY: ' + ts.request.Signing_Authority_Email__c);
        Test.startTest();
        ts.controller.saveConfirmationInfoEmail();
        Test.stopTest();

        System.assertEquals(ts.controller.confirmedEmail, ts.controller.request.Signing_Authority_Email__c);
    }
}