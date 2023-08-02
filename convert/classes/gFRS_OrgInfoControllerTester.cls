/**
* @author GFRS Dev Team
* @date 16/01/2013
* @description gFRS_OrgInfoControllerTester class - Test class for gFRS_OrgInfoController. 
*/
@isTest
private class gFRS_OrgInfoControllerTester
{


	static testmethod void testSetLocation1(){
		
		System.debug('Starting test: testSetLocation1');	
		TestSettings ts = new TestSettings();
		ts.createEmptyFundingRequest();

		gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
		cont.selectedLocation = ts.location.Id;
		cont.lLocs = new List<GFRS_Location__c>{ts.location};
		
		Test.startTest(); 
		
			cont.setLocation();

		Test.stopTest(); 
		
	}
	
	static testmethod void testSetLocation2(){
		
		System.debug('Starting test: testSetLocation2');	
		TestSettings ts = new TestSettings();
		ts.createEmptyFundingRequest();

		gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
		cont.selectedLocation = 'xxx';

		
		Test.startTest(); 
		
			cont.setLocation();
			
			cont.selectedLocation = ts.location.Id;
			
			cont.setLocation();

		Test.stopTest(); 
		
	}
	
	static testmethod void testSaveLocationDetails(){
		
		System.debug('Starting test: testSaveLocationDetails');	
		TestSettings ts = new TestSettings();
		ts.createEmptyFundingRequest();

		gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
		cont.selectedLocation = 'xxx';
        ts.setOrganizationDetails();
        cont.organization = ts.organizationNonUs;
        cont.currentLocation = ts.location;
        cont.w9FormAttachment = ts.attachment;

		Test.startTest();
		
        cont.saveLocationDetails();
        System.assertEquals(ts.location.Id, cont.currentLocation.Id);

		Test.stopTest();
	}
	
/*
	static testmethod void testCheckIfLocationWasModified(){
		
		System.debug('Starting test: testCheckIfLocationWasModified');	
		GFRS_Location__c testLocation = null;
		TestSettings ts = new TestSettings();
		ts.createEmptyFundingRequest();

		gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
	
		Test.startTest();
			
			Boolean result = cont.checkIfLocationWasModified(testLocation);
			System.assert(result == false);
		
		Test.stopTest();
		
		
	}
	
*/
	

    static testMethod void testConstructorNewFundingRequest() {
        System.debug('Starting test: testConstructorNewFundingRequest');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createEmptyFundingRequest();
            System.assertNotEquals(null, ts.request);
            System.assertEquals(null, ts.program);

            Test.startTest(); 
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
                        
            system.assertEquals(null, cont.selectedLocation);
            system.assertEquals(true, cont.isLocationEditable);
            system.assertEquals(true, cont.isEditable);
            
            Test.stopTest(); 
        }
    }
       
    static testMethod void testConstructorExistingFundingRequest() {
    	
        System.debug('Starting test: testConstructorExistingFundingRequest');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);
            System.assertNotEquals(null, ts.request);
            System.assertNotEquals(null, ts.program);
          
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
                        
            system.assertEquals(null, cont.selectedLocation);
            system.assertEquals(false, cont.isLocationEditable);
            system.assertEquals(false, cont.isEditable);
            Test.stopTest(); 
        }
    }
    
    
    static testMethod void testConstructorExistingFundingRequestLocationInfoNeed() {
        System.debug('Starting test: testConstructorExistingFundingRequestLocationInfoNeed');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram('Location');
            System.assertNotEquals(null, ts.request);
            System.assertNotEquals(null, ts.program);
           
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
                        
            system.assertEquals(null, cont.selectedLocation);
            system.assertEquals(true, cont.isLocationEditable);
            system.assertEquals(false, cont.isEditable);
            Test.stopTest(); 
        }
    }
    
    static testMethod void testConstructorExistingFundingRequestOrganizationInfoNeed() {
        System.debug('Starting test: testConstructorExistingFundingRequestOrganizationInfoNeed');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram('Organization');
            System.assertNotEquals(null, ts.request);
            System.assertNotEquals(null, ts.program);
            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            system.assertEquals(null, cont.selectedLocation);
            system.assertEquals(false, cont.isLocationEditable);
            system.assertEquals(true, cont.isEditable);
            Test.stopTest(); 
        }
    }
    
    static testMethod void testFetchOrganizationByTaxOrOrgOrgId() {
        System.debug('Starting test: testFetchOrganizationByTaxOrOrgOrgId');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgramNonUsOrg(null);            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            Id organizationId = cont.fetchOrganizationByTaxOrOrg(false, null, '1234');
            system.assertEquals(ts.organizationNonUs.Id, organizationId);
            Test.stopTest(); 
        }
    }
    
    static testMethod void testFetchOrganizationByTaxOrOrgTaxId() {
        System.debug('Starting test: testFetchOrganizationByTaxOrOrgTaxId');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            Id organizationId = cont.fetchOrganizationByTaxOrOrg(true, '22-3344556', '');
            system.assertEquals(true, organizationId != null);
            Test.stopTest(); 
        }
    }

    static testMethod void testFetchOrganizationByTaxOrOrgUnexistingTaxId() {
        System.debug('Starting test: testFetchOrganizationByTaxOrOrgUnexistingTaxId');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);        
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            Id organizationId = cont.fetchOrganizationByTaxOrOrg(true, '22-334d4556', '');
            system.assertEquals(null, organizationId);
            Test.stopTest(); 
        }
    }
    
    static testMethod void testOrganizationExists () {
        System.debug('Starting test: testOrganizationExists');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            system.assertEquals(true, cont.organizationExists);
            Test.stopTest(); 
        }
    }
    
    static testMethod void testHasMessages () {
        System.debug('Starting test: testHasMessages');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);          
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            system.assertEquals(false, cont.hasMessages);
            Test.stopTest(); 
        }
    }

    static testMethod void testIsUSBased () {
        System.debug('Starting test: testIsUSBased');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            system.assertEquals(true, cont.isUSBased);
            Test.stopTest(); 
        }
    }

    static testMethod void testIsUSBasedForNonUSOrg () {
        System.debug('Starting test: testIsUSBasedForNonUSOrg');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgramNonUsOrg(null);            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            system.assertEquals(false, cont.isUSBased);
            Test.stopTest(); 
        }
    }
    
    static testMethod void testRefreshOrganization() {
        System.debug('Starting test: testRefreshOrganization');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest();
            ts.createFundingRequestWithProgram(null);             
            ApexPages.currentPage().getParameters().put(gFRS_OrgInfoController.PARAM_SOC, '1');
            ApexPages.currentPage().getParameters().put('t' ,'t');
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            cont.organization.Description__c = 'changed description';
            cont.refreshOrganization();
            update cont.organization;
            
            GFRS_Organization__c org = [SELECT Tax_Id__c, Description__c FROM GFRS_Organization__c WHERE Id =: ts.organization.Id];
            system.assertEquals(org.Description__c, cont.organization.Description__c);
            Test.stopTest(); 
        }
    }

    static testMethod void testValidateSaveOrganization() {
        System.debug('Starting test: testValidateSaveOrganization');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgramNonUsOrg(null);           
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            boolean result = cont.validateSaveOrganization();
            system.assertEquals(true, result);
            Test.stopTest();
        }
    }
    static testMethod void testValidateSaveOrganizationError() {
        System.debug('Starting test: testValidateSaveOrganizationError');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest();
            ts.createFundingRequestWithProgramNonUsOrg(null);            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Some stupid error'));
            boolean result = cont.validateSaveOrganization();
            system.assertEquals(false, result);
            Test.stopTest();
        }
    }
    
    static testMethod void testSaveOrganizationDetails() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest();
            ts.createFundingRequestWithProgramNonUsOrg(null);           
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            ts.organization.Organization_Name__c = 'testOrgName';
            Pagereference pr = cont.saveOrganizationDetails();
            
            system.assertNotEquals(ts.organization, null);
            system.assertNotEquals(ts.organization.Organization_Name__c, null);
            system.assertEquals(ts.organization.Organization_Name__c, 'testOrgName');
            
            
            
            gFRS_OrgInfoController cont2 = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            cont.organization = new GFRS_Organization__c();
            Pagereference pr2 = cont.saveOrganizationDetails();
            
            
            cont.organization.Organization_Name__c = 'newTestOrgName';
            cont.saveOrganizationDetails();
            
            system.assertNotEquals(cont.organization, null);
            system.assertNotEquals(cont.organization.Organization_Name__c, null);
            system.assertEquals(cont.organization.Organization_Name__c, 'newTestOrgName');
            Test.stopTest();
        }
    }
    
    static testMethod void testBack() {
        System.debug('Starting test: testBack');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgramNonUsOrg(null);
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            Pagereference pr = cont.back();
            system.assertEquals(new ApexPages.PageReference(gFRS_OrgInfoController.PATH_HOME).getUrl(), pr.getUrl());
            Test.stopTest(); 
        }
    }

    static testMethod void testValidateSaveLocation() {
        System.debug('Starting test: testValidateSaveLocation');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest();
            ts.createFundingRequestWithProgram(null);         
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            boolean result = cont.validateSaveLocation();
            system.assertEquals(false, result);            
            Test.stopTest(); 
        }
    }
    static testMethod void testValidateRequiredFiles() {
        System.debug('Starting test: testValidateRequiredFiles');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            boolean result = cont.validateRequiredFiles();
            system.assertEquals(false, result);            
            Test.stopTest(); 
        }
    }
    static testMethod void testUploadW9Form() {
        System.debug('Starting test: testUploadW9Form');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest();
	            ts.createFundingRequestWithProgram(null);            
	            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
	            cont.organization = ts.organization;
	            cont.w9FormAttachment = ts.attachment;
	            cont.uploadW9Form();
	            System.assert(cont.w9FormAttachment.Body == null);
            Test.stopTest(); 
        }
    }

    static testMethod void testToImproveCodeCoverage() {
        System.debug('Starting test: testToImproveCodeCoverage');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest();
            ts.createFundingRequestWithProgram(null); 
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            cont.saveLocationDetails();
            cont.setLocation();
            cont.next();
            Test.stopTest(); 
        }
    }
    
     static testMethod void testConstructorExternalOrg() {
        System.debug('Starting test: testConstructorExternalOrg');
        TestSettings ts = new TestSettings();
        ts.setOrganizationRecordTypeExternal();
        update ts.organization;
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram( NULL );
            System.assertNotEquals(null, ts.request);
            System.assertNotEquals(null, ts.program);
             
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
                        
            system.assertEquals(null, cont.selectedLocation);
            system.assertEquals(false, cont.isLocationEditable);
            system.assertEquals(false, cont.isLocationSelectable );
            system.assertEquals(false, cont.isEditable);
            system.assertEquals(false, cont.isTaxInfoEditable );
            Test.stopTest(); 
        }
    }
    
    
    static testMethod void testNewOrganizationCanSetOrgType(){
        System.debug('Starting test: testNewOrganizationCanSetOrgType');
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);
            
            ApexPages.currentPage().getParameters().put(gFRS_OrgInfoController.PARAM_SOC, '1');
            ApexPages.currentPage().getParameters().put('t' ,'t');
            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            
            
            cont.organization.Type__c = gFRS_OrgInfoController.ORG_TYPE_PRIV_PHYSICIAN;
                       
            System.assertEquals( true, cont.validateSaveOrganization(), 'the page should have enough to validate the organization and pass org type changed' );
            Test.stopTest();
        }
    }
    
    static testMethod void testNewOrganizationCannotChangeOrgType(){
        System.debug('Starting test: testNewOrganizationCannotChangeOrgType');
        TestSettings ts = new TestSettings();
        
        
        ts.organization.Type__c = gFRS_OrgInfoController.ORG_TYPE_PRIV_PHYSICIAN;
        update ts.organization;
        
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);
            
            ApexPages.currentPage().getParameters().put(gFRS_OrgInfoController.PARAM_SOC, '1');
            ApexPages.currentPage().getParameters().put('t' ,'t');
            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
                 
            cont.organization.Type__c = gFRS_OrgInfoController.ORG_TYPE_PRIV_PHYSICIAN;
            
            System.assertEquals( false, cont.validateSaveOrganization(), 'the page should have enough to validate the organization and pass org type changed' );
            Test.stopTest();
        }
        
    }
    
    static testMethod void testGetOrgTaxIdSectionUrl (){
        System.debug('Starting test: testGetOrgTaxIdSectionUrl');
        TestSettings ts = new TestSettings();
        
        System.RunAs(ts.user){
            Test.startTest(); 
            ts.createFundingRequestWithProgram(null);
            
            ApexPages.currentPage().getParameters().put(gFRS_OrgInfoController.PARAM_SOC, '1');
            ApexPages.currentPage().getParameters().put('t' ,'t');
            
            gFRS_OrgInfoController cont = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));
            
            cont.organization.Type__c = gFRS_OrgInfoController.ORG_TYPE_PRIV_PHYSICIAN;
            
            System.debug( 'previous org type[' + cont.initialOrgType + ']');
            
            System.assertEquals( true, cont.validateSaveOrganization(), 'the page should have enough to validate the organization and pass org type changed' );
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testControllerProperties() {
        TestSettings ts = new TestSettings();
        System.runAs(ts.user) {
            ts.createEmptyFundingRequest();

            gFRS_OrgInfoController controller = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));

            //Check isW9Editable property
            System.assertEquals(true, controller.isW9Editable);

            //Check locationExist property
            controller.currentLocation = ts.location;
            System.assertEquals(true, controller.locationExists);

            //Check getW9PageUrl
            System.assertEquals(null, controller.getW9PageUrl);
            controller.organization = ts.organization;
            controller.w9FormAttachment = ts.attachment;
            controller.uploadW9Form();
            System.assert(controller.getW9PageUrl.contains(ts.location.Id));
            System.assert(controller.getW9PageUrl.contains(ts.organization.Id));

            //Check getOrgTaxIdSectionUrl
            System.assert(controller.getOrgTaxIdSectionUrl.contains(ts.location.Id));
            System.assert(controller.getOrgTaxIdSectionUrl.contains(ts.organization.Id));

            //Check getOrgDetailSectionUrl
            System.assert(controller.getOrgDetailSectionUrl.contains(ts.location.Id));
            System.assert(controller.getOrgDetailSectionUrl.contains(ts.organization.Id));

            //Check getLocationSelectSectionUrl
            System.assert(controller.getLocationSelectSectionUrl.contains(ts.location.Id));
            System.assert(controller.getLocationSelectSectionUrl.contains(ts.organization.Id));

            //Check isExtenralHolderAccount
            System.assert(!controller.isExtenralHolderAccount);

            //Check instance
            System.assertEquals(controller.Instance.organization.Id, ts.organization.Id);
        }
    }

    @IsTest
    static void testFetchOrganizationById() {
        TestSettings ts = new TestSettings();
        System.runAs(ts.user) {
            ts.createEmptyFundingRequest();

            gFRS_OrgInfoController controller = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));

            controller.organization = ts.organization;
            System.assertEquals(ts.organization.Id ,controller.fetchOrganizationById(ts.organization.Id).Id);
            controller.fetchOrganizationById(null);
            System.assertEquals(null, controller.initialOrgType);
            System.assertEquals(null, controller.fetchOrganizationById('012300000004567'));
            System.assertEquals(0, controller.lLocs.size());
        }
    }

    @IsTest
    static void testValidateW9File() {
        TestSettings ts = new TestSettings();
        System.runAs(ts.user) {
            ts.createEmptyFundingRequest();

            gFRS_OrgInfoController controller = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));

            controller.organization = ts.organization;
            controller.currentLocation = ts.location;
            controller.validateW9File();
            System.assertEquals(2, controller.currentIndex);

            controller.w9FormAttachment = ts.attachment;
            controller.uploadW9Form();
            controller.validateW9File();
            System.assertEquals(3, controller.currentIndex);
        }
    }

    @IsTest
    static void testPartialRerenderTaxIdAccordion() {
        TestSettings ts = new TestSettings();
        System.runAs(ts.user) {
            ts.createEmptyFundingRequest();

            gFRS_OrgInfoController controller = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));

            controller.organization = ts.organizationNonUs;

            controller.partialRerenderTaxIdAccordion();
            System.assertEquals(null, controller.organization.Organization_Name__c);
            System.assertEquals(null, controller.organization.Non_US_Organization_ID__c);
            System.assertEquals(null, controller.organization.W8BEN_Status__c);
            System.assertEquals(null, controller.organization.Tax_Id__c);
        }
    }

    @IsTest
    static void testOrgTypeOnChange() {
        TestSettings ts = new TestSettings();
        System.runAs(ts.user) {
            ts.createEmptyFundingRequest();

            gFRS_OrgInfoController controller = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));

            controller.organization = ts.organization;
            controller.orgTypeValue = 'Charitable Foundation';
            controller.IsCHValue = 'Yes';

            controller.OrgTypeOnChange();
            System.assert(controller.IsCHValueYes);

            controller.IsCHValue = 'No';
            controller.OrgTypeOnChange();
            System.assert(!controller.IsCHValueYes);

            controller.orgTypeValue = 'Imed';

            controller.OrgTypeOnChange();
            System.assert(!controller.IsCharitableFundation);
            System.assert(!controller.IsCHValueYes);
            System.assertEquals(null, controller.IsCHValue);
            System.assertEquals(null, controller.organization.IsCHOrg__c);
            System.assertEquals(null, controller.organization.of_Physicians_in__c);
        }
    }

    @IsTest
    static void testIsCHChangedOnChange() {
        TestSettings ts = new TestSettings();
        System.runAs(ts.user) {
            ts.createEmptyFundingRequest();

            gFRS_OrgInfoController controller = new gFRS_OrgInfoController(new ApexPages.StandardController(ts.request));

            controller.organization = ts.organization;
            controller.orgTypeValue = 'Charitable Foundation';
            controller.IsCHValue = 'Yes';

            controller.IsCHChangedOnChange();
            System.assert(controller.IsCHValueYes);

            controller.IsCHValue = 'No';
            controller.IsCHChangedOnChange();
            System.assertEquals(null, controller.organization.of_Physicians_in__c);
            System.assert(!controller.IsCHValueYes);

            controller.IsCHValue = null;
            controller.IsCHChangedOnChange();
            System.assertEquals(null, controller.organization.IsCHOrg__c);
        }
    }

    class TestSettings
    {
        //-- profiles
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;
        
        public String ORG_RECORD_TYPE_EXTERNAL_NAME = gFRS_Util.RT_ORG_EXTERNAL;
        public id ORG_RECORD_TYPE_EXTERNAL_ID;
        
        public String ORG_RECORD_TYPE_INTERNAL_NAME = gFRS_Util.RT_ORG_INTERNAL;
        public id ORG_RECORD_TYPE_INTERNAL_ID;
        //organization
        Contact contact;
        Contact contactNonUs;
        Contact contactExternal;
        Account account;
        Account accountNonUs;
        Account accountHolderAccount;
        
        User user;
        User userExternal;
        User userExternalNew;
        User userExternalExisting;
        GFRS_Location__c location;
        GFRS_Location__c locationNonUs;
        
        public GFRS_Funding_Request__c request;
        public GFRS_Program__c program;
        public GFRS_Organization__c organization;
        public GFRS_Organization__c organizationNonUs;
        public GFRS_Organization__c organizationNonUsWithoutId;
        
        public Attachment attachment;
    
        public String DEFAULT_STATUS = 'Intake';
        public String DEFAULT_SUB_STATUS = 'Not Submitted';
        
        
        public TestSettings()
        {
            PROF_GFRS_USER = [ select Id, Name from Profile where Name =:PROF_GFRS_USER_NAME limit 1 ].Id;
            
            try {
                //delete [ select id from gFRS_Organization__c where Tax_Id__c = '22-3344556' or Non_US_Organization_ID__c = '1234' ];
            } catch( Exception err ){}
            
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
	    	myOrgCS.USBasedOrganizations__c = 'United States|American Samoa|Guam|Northern Mariana Islands|Virgin Islands|Wake Island|Puerto Rico';
	    	myOrgCS.gFRS_HC_Compliance_Flag_Start_Date__c = Date.today();
	    	myOrgCS.Field_Initiated_Exhibits_WBS_1000__c = '309.01006';
	    	myOrgCS.Field_Initiated_Exhibits_WBS_1010__c = '309.07076';
	    	myOrgCS.AuthorizedSignerEmailSuffix__c = 'test';
	    	upsert myOrgCS;
            
            account = gFRS_TestCreationUtils.createAccount('test');
            insert account;
            
            accountNonUs = gFRS_TestCreationUtils.createAccount('testNonUs');
            insert accountNonUs;
            
            accountHolderAccount = gFRS_UnitTestHelper.createExternalAccount('testExternalAccount');
            contactExternal = gFRS_TestCreationUtils.createContact( accountHolderAccount );
            insert contactExternal;
            
            contact = gFRS_TestCreationUtils.createContact(account);
            insert contact;
            
            contactNonUs = gFRS_TestCreationUtils.createContact(accountNonUs);
            insert contactNonUs;
            
            userExternal = gFRS_TestCreationUtils.createUser(contact, 'testuserexternal@gene.com');
            insert userExternal;
            
           // userExternalNew = gFRS_TestCreationUtils.createUser(contactExternal, 'testuserexternal1@gene.com');
            //insert userExternalNew;
            
            
            
            organization = gFRS_TestCreationUtils.createOrganization('22-3344556', account);
            organization.Tax_Status__c = 'For-Profit';
            organization.Is_your_organization_a_Sole_Proprietorsh__c = 'No';
            organization.IsValidationExternalOnly__c = 'Yes';
            insert organization;
            
            organizationNonUs = gFRS_TestCreationUtils.createOrganization('22-3344556', accountNonUs);
            organizationNonUs.Non_US_Organization_ID__c = '1234';
            organizationNonUs.country__c = 'Canada';
            organizationNonUs.Tax_Id__c = null;
            organizationNonUs.W8BEN_Status__c = 'Yes';
            insert organizationNonUs;
            locationNonUs = gFRS_TestCreationUtils.createLocation('testNoUs',organizationNonUs.id);
            
            location = gFRS_TestCreationUtils.createLocation('test',organization.id);
            location.Name = 'Test location';
            insert location;
           // contact = gFRS_TestCreationUtils.createContact(account);
           // insert contact;
            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;
            
            
            Attachment att = gFRS_TestCreationUtils.createAttachment(this.account.Id, 'testName', Blob.valueOf('testBody'));
            insert att;
            this.attachment = [SELECT Id, name, body FROM Attachment WHERE Id =: att.Id]; 
            
        }            
    
        public void createFundingRequestWithProgram(String informationNeeded){
            this.request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, location.Id);
            this.request.Information_Needed__c = informationNeeded;
            insert this.request;
            
            this.program =  gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            this.program.Program_Status__c = 'Complete';
            setProgramRecordType('IMED_Program');
            insert this.program;          
        }

        public void createFundingRequestWithProgramNonUsOrg(String informationNeeded){
            this.request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organizationNonUs.Id, location.Id);
            this.request.Information_Needed__c = informationNeeded;
            insert this.request;
            
            this.program =  gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, this.request, 3, 'test1234');
            this.program.Program_Status__c = 'Complete';
            setProgramRecordType('IMED_Program');
            insert this.program;          
        }

        public void createEmptyFundingRequest(){
            this.request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, null);
        }
        
        public void setOrganizationRecordTypeExternal(){
            ORG_RECORD_TYPE_EXTERNAL_ID = [ select Id from RecordType where DeveloperName =:ORG_RECORD_TYPE_EXTERNAL_NAME and SobjectType = 'GFRS_Organization__c' limit 1 ].Id;
            this.organization.RecordTypeId = ORG_RECORD_TYPE_EXTERNAL_ID;
            
        }
        public void setOrganizationRecordTypeInternal(){
            ORG_RECORD_TYPE_INTERNAL_ID = [ select Id from RecordType where DeveloperName =:ORG_RECORD_TYPE_INTERNAL_NAME and SobjectType = 'GFRS_Organization__c' limit 1 ].Id;
            this.organization.RecordTypeId = ORG_RECORD_TYPE_INTERNAL_ID;
        }
        public void setProgramRecordType(String recordType){
            this.program.RecordTypeId=[select Id from RecordType where DeveloperName =:recordType and SobjectType = 'GFRS_Program__c' limit 1].Id;
        }
         public void setOrganizationDetails(){
            this.organization.Organization_Name__c = null;
            this.organization.Type__c = 'Academic Center';
            this.organization.of_Physicians_in__c = 4;
            this.organization.Operational_Budget__c = 4000;
            this.organization.Website_Address__c = 'aaa';
            this.organization.Mission_Statement__c = 'aaa';
            this.organization.Number_of_Employees__c = 5;
            this.organization.Roche_Purchaser__c = 'Yes';
            this.organization.Roche_Prescriber__c = 'No';
            this.organization.Medicare_Guideline_Development__c = 'No';
            this.organization.Physician_Ownership__c = 'No';
            this.organization.ParentOrganization__c = null;
            this.organization.Parent_Org_Name__c = 'aaaa';
            this.organization.Parent_Organization_Tax_ID__c = '98-7654321';
         }
    }
    
}