/**
* @author GFRS Dev Team
* @date 19/11/2013
* @description gFRS_DecisionControllerTester class - test class for gFRS_DecisionController
*/
@isTest
private class gFRS_DecisionControllerTester {
    class TestSettings {
        GFRS_Location__c testLocation;
        GFRS_Decision_Link__c dl;
        GFRS_Funding_Request__c fundingRequest {get; set;}
        GFRS_Funding_Request__c overDueFundingRequest {get; set;}
        gFRS_DecisionController controller {get; set;}
        gFRS_Program__c program;
        GFRS_Content__c testContent {get; set;} 
        GFRS_Content_Translation__c testContentTranslation {get; set;}
        
        public String DEFAULT_STATUS = 'Intake';
        public String DEFAULT_SUB_STATUS = 'Not Submitted';
    
         public TestSettings(GFRS_Organization__c testOrganization){
            

            this.testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
            this.fundingRequest = gFRS_UnitTestHelper.createFundingRequestObject(null, testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;program;Budget;Attachments');
            this.overDueFundingRequest = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', testOrganization.Id, testLocation.Id);
            insert overDueFundingRequest;

            this.testContent = new GFRS_Content__c(Name = 'IMED', Filter__c = 'Homepage');
            insert this.testContent;
            this.testContentTranslation = gFRS_TestCreationUtils.createContentTranslation(this.testContent, 'tBlock', 'legacy2','lang');
            //this.testContentTranslation = new GFRS_Content_Translation__c(GFRS_Content__c = testContent.Id);
            insert this.testContentTranslation;

            this.controller = new gFRS_DecisionController(new ApexPages.StandardController(this.fundingRequest));
            this.controller.response = [ select id, GFRS_Content__r.Filter__c, GFRS_Content__c, GFRS_Content__r.Name,TextBlock__c
                from GFRS_Content_Translation__c
                where Id =:this.testContentTranslation.Id];
            this.controller.organizationId = testOrganization.Id;
            this.controller.locationId = testLocation.Id;
            GFRS_Content__c cont = new GFRS_Content__c();
            cont.Filter__c = 'Gcal_Header';
            cont.Name = 'Gcal_Header';
            insert new List<GFRS_Content__c>{cont};
            GFRS_Content_Translation__c contTrans = new GFRS_Content_Translation__c();
            contTrans.GFRS_Content__c = cont.Id;
            contTrans.Language__c ='en_US';
            contTrans.TextBlock__c = 'test';
            insert new List<GFRS_Content_Translation__c>{contTrans};
         }

        public String verifyOverDueErrorPages(GFRS_Funding_Request__c fundingRequest, String contentName){

            if(fundingRequest != null){
              program = gFRS_TestCreationUtils.createProgram_min( 'Live', fundingRequest);
                program.End_Date__c = Date.today().addDays(-91);
                upsert program;  
            }
            
            this.testContent.Name = contentName;
            upsert testContent;

            this.testContentTranslation = new GFRS_Content_Translation__c(GFRS_Content__c = testContent.Id);
            insert this.testContentTranslation;

            this.controller.response = [ select id, GFRS_Content__r.Filter__c, GFRS_Content__c, GFRS_Content__r.Name
                from GFRS_Content_Translation__c
                where Id =:testContentTranslation.Id];

            return (controller.Save().getUrl());
        }
    }
    
    @isTest (SeeAllData=true)
    static  void testControllerConstructor() {
        gFRS_Content_Translation__c translation = [ select TextBlock__c from GFRS_Content_Translation__c where GFRS_Content__r.Filter__c = :gFRS_DecisionController.FILTER_ERROR and GFRS_Content__r.Name = :gFRS_DecisionController.TRANSLATION_INTERNAL_ONLY limit 1];

        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('12-2345678', testAccount.Id);
        update testOrganization;

        Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);

        Test.startTest();
         System.runAs(testUser){
            TestSettings settings = new TestSettings(testOrganization);

            //GFRS_Content__r.Filter__c == Homepage (expected false)
            System.assertEquals(settings.controller.isResponseInternalOnly ,false);
            //isResponseInternalOnly = false
            System.assertEquals(settings.controller.responseBlock ,settings.controller.response.TextBlock__c);
            settings.testContent.Filter__c = gFRS_DecisionController.FILTER_INTERNAL;
            update settings.testContent;
            settings.controller.response.GFRS_Content__r.Filter__c = gFRS_DecisionController.FILTER_INTERNAL;
            update settings.controller.response;

            //GFRS_Content__r.Filter__c == FILTER_INTERNAL (expected true)
            System.assertEquals(settings.controller.isResponseInternalOnly ,true);
            //isResponseInternalOnly = true
            System.assertEquals(settings.controller.responseBlock ,settings.controller.response.TextBlock__c + translation.TextBlock__c);

            //string res = settings.controller.responseBlock;
            settings.controller.q1.selectedAnswer = new GFRS_Content_Translation__c();  
            settings.controller.q1.selectedAnswer.GFRS_Content__c  = settings.testContent.Id;
            GFRS_Decision_Link__c decisionLink = gFRS_TestCreationUtils.createDecisionLink(settings.testContent,'legid',settings.testContent);
            insert decisionLink;
            settings.controller.question1Answered();

            System.debug('settings.controller.q1.selectedAnswer.GFRS_Content__c ' + settings.controller.q1.selectedAnswer.GFRS_Content__c);
            GFRS_Content_Translation__c[] trans = [ select id, TextBlock__c, GFRS_Content__r.Filter__c, GFRS_Content__c, GFRS_Content__r.Name
                from GFRS_Content_Translation__c
                where GFRS_Content__c in
                    ( select Type_Description__c from GFRS_Decision_Link__c where Decision_Answer__c = :settings.controller.q1.selectedAnswer.GFRS_Content__c )];
            System.debug('trans ' + trans);
            System.assertEquals(trans[0],settings.controller.response);
            System.assertEquals(null,settings.controller.q2);
            System.assertEquals(false,settings.controller.shouldShowQ2);
            System.assertEquals(null,settings.controller.literalError);
            System.assertEquals(true,settings.controller.shouldShowResult);
            System.assertEquals(gFRS_DecisionController.PATH_BACK + '?loc=' + settings.controller.locationId + '&org=' + settings.controller.organizationId + '&t=t',settings.controller.back().getUrl());

            delete decisionLink;
            settings.controller.question1Answered();
            System.assertEquals(null,settings.controller.response);
            System.assertNotEquals(null,settings.controller.q2);
            System.assertEquals(false,settings.controller.shouldShowQ2);
            System.assertEquals(null,settings.controller.literalError);

            settings.controller.question2Answered();
            System.assertEquals(null,settings.controller.response);
            System.assertEquals(null,settings.controller.responseBlock);
            System.assertEquals(false,settings.controller.shouldShowResult);
            
        }   
        Test.stopTest();   
    }
    
    
    /**
    * @author GFRS Dev Team
    * @date 19/11/2013
    * @description testInvalidProfitableRTForIMED - test of Invalid_Profitable_Record_Types VR for HC Char
    */
    static testmethod void testInvalidProfitableRTForHC(){
        
        //prepare data
        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        testOrganization.Tax_Status__c = 'For-Profit';
        testOrganization.W9_Form_W_8BEN_Form__c = 'test';
        testOrganization.Is_your_organization_a_Sole_Proprietorsh__c = 'No';
        testOrganization.IsValidationExternalOnly__c = 'Yes';
        update testOrganization;

        Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        
        Test.startTest();
         System.runAs(testUser){
            TestSettings settings = new TestSettings(testOrganization);
            settings.verifyOverDueErrorPages(null, 'HC_CHAR');
            settings.controller.Save();
            List<Apexpages.Message> messages = ApexPages.getMessages();
            Boolean result = false;
            for(Apexpages.Message msg:messages){
                if (msg.getDetail().contains('For profit organizations are ineligible for the selected funding type')) result = true;
            }
            System.assert(result == false); 
         }
            
        Test.stopTest();
    }
    
    
    /**
    * @author GFRS Dev Team
    * @date 19/11/2013
    * @description testInvalidProfitableRTForIMED - test of Invalid_Profitable_Record_Types VR for Philantrophic
    */
    static testmethod void testInvalidProfitableRTForPhilanthropic(){
        
        
        //prepare data
        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        testOrganization.Tax_Status__c = 'For-Profit';
        testOrganization.W9_Form_W_8BEN_Form__c = 'test';
        testOrganization.Is_your_organization_a_Sole_Proprietorsh__c = 'No';
        testOrganization.IsValidationExternalOnly__c = 'Yes';
        update testOrganization;

        Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        
        Test.startTest();
         System.runAs(testUser){
            TestSettings settings = new TestSettings(testOrganization);
            settings.verifyOverDueErrorPages(null, 'Philanthropic');
            settings.controller.Save();
            List<Apexpages.Message> messages = ApexPages.getMessages();
            Boolean result = false;
            for(Apexpages.Message msg:messages){
                if (msg.getDetail().contains('For profit organizations are ineligible for the selected funding type')) result = true;
            }
            System.assert(result == false); 
         }
            
        Test.stopTest();      
    }
    
    /**
    * @author GFRS Dev Team
    * @date 19/11/2013
    * @description testInvalidProfitableRTForIMED - test of Invalid_Profitable_Record_Types VR for IMED
    */
    static testmethod void testInvalidProfitableRTForIMED(){
        
        //prepare data
        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        testOrganization.Tax_Status__c = 'For-Profit';
        testOrganization.W9_Form_W_8BEN_Form__c = 'test';
        testOrganization.Is_your_organization_a_Sole_Proprietorsh__c = 'No';
        testOrganization.IsValidationExternalOnly__c = 'Yes';
        update testOrganization;

        Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        
        Test.startTest();
         System.runAs(testUser){
            TestSettings settings = new TestSettings(testOrganization);
            settings.verifyOverDueErrorPages(null, 'IMED');
            settings.controller.Save();
            List<Apexpages.Message> messages = ApexPages.getMessages();
            Boolean result = false;
            for(Apexpages.Message msg:messages){
                if (msg.getDetail().contains('For profit organizations are ineligible for the selected funding type')) result = true;
            }
            System.assert(result == false); 
         }
            
        Test.stopTest();        
    }

    static testMethod void testCheckValidPageFor_GNE_SFA_Profiles_Passed(){
        String resultURL;
        User user = [ SELECT id, profileId FROM User WHERE IsActive = true AND (Profile_Name_gne__c like 'GNE-SFA-%-Pathology-Specialist' or Profile_Name_gne__c like 'GNE-SFA-%-PS' or Profile_Name_gne__c = 'GNE-SFA-BAM') LIMIT 1 ];

        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);

        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFundingRequestObject(null, testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;program;Budget;Attachments');

        gFRS_DecisionController controller = new gFRS_DecisionController(new ApexPages.StandardController(fundingRequest));
        controller.organizationId = testOrganization.Id;
        controller.locationId = testLocation.Id;
        
  
        Test.startTest();
         System.runAs(user){
            resultURL = controller.checkValidPage().getUrl();
         }       
        Test.stopTest();
        
        System.assert(resultURL.contains(gFRS_DecisionController.PATH_COMPLETE));
    }

     static testMethod void testCheckValidPageFor_GNE_SFA_Profiles_Failed(){
        String resultURL;
        User user = [ SELECT id, profileId FROM User WHERE IsActive = true AND (Profile_Name_gne__c like 'GNE-SFA-%-Pathology-Specialist' or  Profile_Name_gne__c like 'GNE-SFA-%-PS' or  Profile_Name_gne__c = 'GNE-SFA-BAM') LIMIT 1 ];

        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        testOrganization.Exclusion_Blacklist_Reasons__c = 'Declared bankruptcy';
        testOrganization.Funding_Type_Specific_Blacklist__c = 'Fellowships';
        update testOrganization;
        
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);

        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFundingRequestObject(null, testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;program;Budget;Attachments');

        gFRS_DecisionController controller = new gFRS_DecisionController(new ApexPages.StandardController(fundingRequest));
        controller.organizationId = testOrganization.Id;
        controller.locationId = testLocation.Id;
        
  
        Test.startTest();
         System.runAs(user){
            resultURL = controller.checkValidPage().getUrl();
         }       
        Test.stopTest();

        System.assertEquals(gFRS_DecisionController.ERROR_BLACKLIST_LOC,resultURL);
    }


    static testMethod void testSaveForOverDueRequest(){
        String result;
        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);

        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);

        System.runAs(testUser){  
            TestSettings settings = new TestSettings(testOrganization);

            //IMED
            settings.overDueFundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ;
            settings.overDueFundingRequest.Refund_Request_Date__c = Date.today().addDays(-60);
            update settings.overDueFundingRequest;

            result = settings.verifyOverDueErrorPages(settings.overDueFundingRequest,gFRS_Util.TYPE_IMED);
            System.assertEquals(gFRS_DecisionController.ERROR_RECONCILIATON_DUE,result); 

            settings.overDueFundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_REFUND_REQ;
            update settings.overDueFundingRequest;

            result = settings.verifyOverDueErrorPages(settings.overDueFundingRequest,gFRS_Util.TYPE_IMED);
            System.assertEquals(gFRS_DecisionController.ERROR_REFUND_DUE,result); 

            settings.overDueFundingRequest.Sunshine_Act_Disclosure_Submitted__c = 'No';
            settings.overDueFundingRequest.Sub_Status__c = 'Approved';
            update settings.overDueFundingRequest;

            result = settings.verifyOverDueErrorPages(settings.overDueFundingRequest,gFRS_Util.TYPE_IMED);
            System.assertEquals(gFRS_DecisionController.ERROR_W9W8_MISSING,result);

            //HC CHAR
            Test.startTest();
            settings.overDueFundingRequest.recordTypeId = gFRS_TestCreationUtils.RT_FR_HC_CHAR;
            settings.overDueFundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS;
            settings.overDueFundingRequest.Evaluation_Completed__c = 'No';
            update settings.overDueFundingRequest;

            result = settings.verifyOverDueErrorPages(settings.overDueFundingRequest,gFRS_Util.TYPE_HC_CHAR);
            System.assertEquals(gFRS_DecisionController.ERROR_EVALUATIONS_DUE,result);

            //Fellowships
            settings.overDueFundingRequest.recordTypeId = gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS;
            update settings.overDueFundingRequest;

            result = settings.verifyOverDueErrorPages(settings.overDueFundingRequest,gFRS_Util.TYPE_FELLOWSHIPS);
            System.assertEquals(gFRS_DecisionController.ERROR_EVALUATIONS_DUE,result);

            //Philanthropic
            settings.overDueFundingRequest.recordTypeId = gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC;
            update settings.overDueFundingRequest;

            result = settings.verifyOverDueErrorPages(settings.overDueFundingRequest,gFRS_Util.TYPE_PHILANTHROPIC);
            System.assertEquals(gFRS_DecisionController.ERROR_EVALUATIONS_DUE,result);

            //Scientific_Projects
            settings.overDueFundingRequest.recordTypeId = gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS;
            update settings.overDueFundingRequest;

            result = settings.verifyOverDueErrorPages(settings.overDueFundingRequest,gFRS_Util.TYPE_SCIENTIFIC_PROJECTS);
            System.assertEquals(gFRS_DecisionController.ERROR_EVALUATIONS_DUE,result);
            Test.stopTest();
        }
    }

    @IsTest
    static void testControllerProperties() {
        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        testOrganization.Tax_Status__c = 'For-Profit';
        testOrganization.W9_Form_W_8BEN_Form__c = 'test';
        testOrganization.Is_your_organization_a_Sole_Proprietorsh__c = 'No';
        testOrganization.IsValidationExternalOnly__c = 'Yes';
        update testOrganization;

        Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);

        Test.startTest();
        System.runAs(testUser) {
            TestSettings testSettings = new TestSettings(testOrganization);
            testSettings.controller.contentItems.put('Documentation_Instruction', 'Test 1');
            testSettings.controller.contentItems.put('Review_Time_Instruction', 'Test 2');
            testSettings.controller.contentItems.put('Expedited_Request_Instruction', 'Test 3');
            testSettings.controller.contentItems.put('Bundled_Request_Instruction', 'Test 4');
            testSettings.controller.contentItems.put('ConfirmSubmit', 'Test 5');

            System.assertEquals('Test 1', testSettings.controller.documentationInstruction);
            System.assertEquals('Test 2', testSettings.controller.reviewTimeInstruction);
            System.assertEquals('Test 3', testSettings.controller.expeditedRequestInstruction);
            System.assertEquals('Test 4', testSettings.controller.bundledRequestInstruction);
            System.assertEquals('Test 5', testSettings.controller.submitMessage);

            System.debug(testSettings.controller.response);
            gFRS_DecisionQuestion question = new gFRS_DecisionQuestion(testSettings.testContent.Id, true);
            System.assertEquals(null, question.answerOptions);
            System.assertEquals(null, question.selectedAnswerId);
        }
    }

}