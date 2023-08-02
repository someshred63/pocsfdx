/**
* @author GFRS Dev Team
* @date 28/06/2013
* @description gFRS_Util_NoShareTester class - test class for gFRS_Util_NoShare
*/
@isTest
private class gFRS_Util_NoShareTester {

	private static Id ID_FR_IMED_RECTYPE = [select Id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and Name='IMED'].Id;
	private static Id ID_FR_FIELD_INI_EXHIBIT = [select Id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Field_Initiated_Exhibits'].Id;
	private static Id ID_FR_FELLOWSHIPS_RECTYPE = [select Id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Fellowships'].Id;
	public static Id ID_PROGRAM_CM_RECTYPE = [select Id from RecordType where SobjectType = 'GFRS_Program__c' and DeveloperName='Corporate_Memberships_Program'].Id;

	class TestSettings {
		public id PROF_GFRS_USER;
		public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
		public User user;
		GFRS_Location__c location;
		Account account;
		Contact contact;
		public GFRS_Organization__c organization;
		public GFRS_Funding_Request__c request;
		public List<GFRS_Program__c> programList;
		public GFRS_Program__c program;
		public gFRS_Funding_Allocation__c fundingAllocation;
		public GFRS_Funding_Allocation_Line_Item__c lineItem;

		public void setupData(){
			Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
			Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
			User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
			GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
			GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
			GFRS_Funding_Request__c testFundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'HC Compliance', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
			testFundingRequest.Venue_city__c = 'Test';
			update testFundingRequest;
			GFRS_Program__c testProgram = gFRS_UnitTestHelper.createProgram(testFundingRequest.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_HC_RECTYPE);
			testProgram.Venue_city__c = 'Test';
			insert testProgram;

			account = testAccount;
			contact = testContact;
			user = testUser;
			organization = testOrganization;
			program = testProgram;
			request = testFundingRequest;
		}

		public void setupSuperUser() {
			user = gFRS_UnitTestHelper.createUserWithSpecificProfile([select Id, Name from Profile where Name='GNE-GFRS-Grant Coordinator'].Id);
		}

		public void insertHCRequest() {
			GFRS_Organization__c organization = [SELECT Id FROM GFRS_Organization__c LIMIT 1];
			GFRS_Location__c location = [SELECT Id FROM GFRS_Location__c LIMIT 1];
			GFRS_Funding_Request__c request = gFRS_UnitTestHelper.createHCFundingRequestObject(organization.Id, location.Id, 'HC Compliance', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments' );
			upsert request;
		}

		public void insertPhilanthropicRequest() {
			GFRS_Organization__c organization = [SELECT Id FROM GFRS_Organization__c LIMIT 1];
			GFRS_Location__c location = [SELECT Id FROM GFRS_Location__c LIMIT 1];
			GFRS_Funding_Request__c request = gFRS_UnitTestHelper.createPhilantrophicFundingRequestObject(organization.Id, location.Id, 'HC Compliance', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments' );
			upsert request;
		}

		public void insertCorporateMembershipRequest() {
			GFRS_Organization__c organization = [SELECT Id FROM GFRS_Organization__c LIMIT 1];
			GFRS_Location__c location = [SELECT Id FROM GFRS_Location__c LIMIT 1];
			GFRS_Funding_Request__c request = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObjectWithoutSaving(organization.Id, location.Id, 'Decision', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments' );
			upsert request;
		}

		public void insertIMEDMembershipRequest() {
			GFRS_Organization__c organization = [SELECT Id FROM GFRS_Organization__c LIMIT 1];
			GFRS_Location__c location = [SELECT Id FROM GFRS_Location__c LIMIT 1];
			GFRS_Funding_Request__c request = gFRS_UnitTestHelper.createIMEDFundingRequestObject(organization.Id, location.Id, 'Decision', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments' );
			upsert request;
		}

		public void insertFundingAllocation() {
			this.fundingAllocation = gFRS_UnitTestHelper.createFundingAllocation(this.request);
		}

		public void insertFundingAllocationWithSpecificRequest(GFRS_Funding_Request__c request) {
			this.fundingAllocation = gFRS_UnitTestHelper.createFundingAllocation(request);
		}

		public void insertFundingAllocationLineItem() {
			GFRS_Cost_Center_Code__c costCenter = gFRS_UnitTestHelper.createCostCenterCode('testName', '1010');
			GFRS_WBS_Codes__c wbsCode = gFRS_UnitTestHelper.createWBSCodeWithoutSaving('1010', true, 'Autism', 20, 'IMED', '1010', Date.today()+1, 'Biogen-Idec', '1010', '1010 Description');
			insert wbsCode;
			GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItemWithoutSaving(user, costCenter, fundingAllocation, wbsCode);
			insert fundingAllocationLineItem;
		}

		public void modifyOrganization(){
			this.organization.Medicare_Guideline_Development__c = 'Yes';
			update this.organization;
		}
	}

	static testMethod void testApplySharingRulesForSelectedUsers(){
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.request = [SELECT Id FROM GFRS_Funding_Request__c limit 1].get(0);
		ts.PROF_GFRS_USER = [ select Id, Name from Profile where Name =:ts.PROF_GFRS_USER_NAME limit 1 ].Id;
		ts.user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', ts.PROF_GFRS_USER, '1234');
        insert ts.user;

		Boolean isSuccess = gFRS_Util_NoShare.applySharingRulesForSelectedUsers(ts.request.Id,'aaa@gene.com');
		gFRS_Funding_Request__Share shareObject =  [select Id, ParentId, UserOrGroupId, AccessLevel, RowCause from gFRS_Funding_Request__Share where UserOrGroupId = :ts.user.Id].get(0);
		
		System.assertEquals(true, isSuccess);
		System.assertNotEquals(shareObject.Id, null);
	}

	static testMethod void testPopulateVenueCityAfterDelete(){
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.programList = [select Id, Name, Funding_Request__c, Venue_city__c from GFRS_Program__c where Funding_Request__c != null and Venue_city__c != null limit 10];

		gFRS_Util_NoShare.populateVenueCityAfterDelete(ts.programList);
		GFRS_Funding_Request__c fundingRequest = [select Id, Venue_city__c from GFRS_Funding_Request__c where Id = :ts.programList.get(0).Funding_Request__c];
		System.assertNotEquals(fundingRequest.Venue_city__c, null);
		
		
		ts.programList = new List<GFRS_Program__c>();
		gFRS_Util_NoShare.populateVenueCityAfterDelete(ts.programList);
	}

	static testMethod void testPopulateVenueCityIMED(){
		TestSettings ts = new TestSettings();
		ts.setupData();
		GFRS_Program__c testProgram = gFRS_UnitTestHelper.createProgram(ts.request.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_IMED_RECTYPE);
		testProgram.Venue_city__c = 'Test';
		insert testProgram;

		ts.programList = [select Id, Name, Funding_Request__c, RecordTypeId, Venue_city__c from GFRS_Program__c where Funding_Request__c != null and Venue_city__c != null and RecordTypeId =: gFRS_UnitTestHelper.ID_PROGRAM_IMED_RECTYPE];

		Test.startTest();
		gFRS_Util_NoShare.populateVenueCity(ts.programList);
		GFRS_Funding_Request__c fundingRequest = [select Id, Venue_city__c from GFRS_Funding_Request__c where Id = :ts.programList.get(0).Funding_Request__c];
		Test.stopTest();

		System.assertNotEquals(fundingRequest.Venue_city__c, null);
	}

	static testMethod void testPopulateVenueCityElse(){
		TestSettings ts = new TestSettings();
		ts.setupData();
		GFRS_Program__c testProgram = gFRS_UnitTestHelper.createProgram(ts.request.Id, 'Live', 1, 2, 3, ID_PROGRAM_CM_RECTYPE);
		testProgram.Venue_city__c = 'Test';
		insert testProgram;

		ts.programList = [select Id, Name, Funding_Request__c, RecordTypeId, Venue_city__c from GFRS_Program__c where Funding_Request__c != null and Venue_city__c != null and RecordTypeId =: ID_PROGRAM_CM_RECTYPE];

		Test.startTest();
		gFRS_Util_NoShare.populateVenueCity(ts.programList);
		GFRS_Funding_Request__c fundingRequest = [select Id, Venue_city__c from GFRS_Funding_Request__c where Id = :ts.programList.get(0).Funding_Request__c];
		Test.stopTest();

		System.assertNotEquals(fundingRequest.Venue_city__c, null);
	}

	static testMethod void testAddTimestampToFileName(){
		String testString = 'test.txt';
		String resultString = gFRS_Util_NoShare.addTimestampToFileName(testString);
		System.assert(resultString.length()>testString.length());
	}

	static testMethod void testGetFieldLabelsMapForGivenObject(){
		Map<String, String> resultMap = gFRS_Util_NoShare.getFieldLabelsMapForGivenObject('GFRS_Funding_Request__c');
		System.assert(resultMap.size()>0);
	}

	static testMethod void testCheckIsPageInRFIStatus(){
		TestSettings ts = new TestSettings();
		ts.setupData();
		GFRS_Funding_Request__c fundingRequest = [select Id, Information_Needed__c from GFRS_Funding_Request__c limit 1];
		fundingRequest.Is_Reconciliation_In_RFI__c = true;
		update fundingRequest;
		gFRS_Util_NoShare.createTask('Not Started', 'Test Subject', null, fundingRequest.id, null, 'Reconciliation');
		Boolean isRFI = gFRS_Util_NoShare.checkIsReconciliationPageInRFI(fundingRequest.Id);
		System.assert(isRFI);
	}

	static testMethod void testInsertVendorDetailsAttachment(){
		TestSettings ts = new TestSettings();
		ts.setupData();
		GFRS_Funding_Request__c fundingRequest = [select Id, Process_Disposition_Date__c from GFRS_Funding_Request__c where Process_Disposition_Date__c = null AND Record_Type_Name__c = 'Corporate Memberships' limit 1];
		fundingRequest.Process_Disposition_Date__c = Date.today();
		List<Attachment> requestAttachments = [Select Name From Attachment Where ParentId =: fundingRequest.Id and Name like '%Vendor_Details%'];
        System.assertEquals(0,requestAttachments.size());
		update fundingRequest;
	}

	static testMethod void testInsertVendorDetailsAttachmentWithAttachments(){
		TestSettings ts = new TestSettings();
		ts.setupData();
		GFRS_Funding_Request__c fundingRequest = [select Id, Name, Process_Disposition_Date__c from GFRS_Funding_Request__c where Process_Disposition_Date__c = null AND Record_Type_Name__c = 'Corporate Memberships' limit 1];
		String documentName = 'Vendor_Details_' + fundingRequest.Name + '_V1.pdf';
		Attachment att = gFRS_TestCreationUtils.createAttachment(fundingRequest.Id, documentName, Blob.valueOf('testBody'));
		insert att;
		List<Attachment> requestAttachments = [Select Name From Attachment Where ParentId =: fundingRequest.Id and Name like '%Vendor_Details%'];
        System.assertEquals(1,requestAttachments.size());

        fundingRequest.Process_Disposition_Date__c = Date.today();
        update fundingRequest;
	}

	static testMethod void findOverdueReconciliationsTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		GFRS_Funding_Request__c fundingRequest = [select Id, RecordTypeId, Record_Type_Name__c, Name, Sub_Status__c, Program_End_Date_max__c from GFRS_Funding_Request__c LIMIT 1];
		GFRS_Program__c testProgram = [SELECT Id, End_Date__c FROM GFRS_Program__c LIMIT 1];
		testProgram.End_Date__c = Date.today().addDays(-90);
		update testProgram;
		fundingRequest.RecordTypeId = ID_FR_IMED_RECTYPE;
		fundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ;
		update fundingRequest;

		Test.startTest();
		gFRS_Funding_Request__c[] overdueRequests = gFRS_Util_NoShare.findOverdueReconciliations();
		System.assertEquals(0, overdueRequests.size());
		Test.stopTest();
	}

	static testMethod void findOverdueRequestsTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [select Id, RecordTypeId, Record_Type_Name__c, Name, Sub_Status__c, Program_End_Date_max__c from GFRS_Funding_Request__c LIMIT 1];
		fundingRequest.RecordTypeId = ID_FR_IMED_RECTYPE;
		fundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ;
		update fundingRequest;
		GFRS_Funding_Request__c request = [select Id, RecordTypeId, OwnerId, Record_Type_Name__c, Name, Sub_Status__c, Program_End_Date_max__c from GFRS_Funding_Request__c LIMIT 1];

		Test.startTest();
		gFRS_Funding_Request__c[] overdueRequests = gFRS_Util_NoShare.findOverdueRefunds();
		System.assertEquals(0, overdueRequests.size());
		Test.stopTest();
	}

	static testMethod void findOverdueSunshineActDisclosuresTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertIMEDMembershipRequest();

		GFRS_Funding_Request__c fundingRequest = [SELECT Id, RecordTypeId, Record_Type_Name__c, Name, Sub_Status__c, Program_End_Date_max__c
		FROM GFRS_Funding_Request__c
		WHERE Record_Type_Name__c =: gFRS_Util.TYPE_IMED
		LIMIT 1];
		GFRS_Program__c programNew = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, fundingRequest, 3, 'test1234');
		programNew.End_Date__c = Date.today().addDays(-100);
		insert programNew;
		fundingRequest.Sunshine_Act_Disclosure_Submitted__c = 'No';
		update fundingRequest;

		Test.startTest();
		gFRS_Funding_Request__c[] overdueRequests = gFRS_Util_NoShare.findOverdueSunshineActDisclosures();
		Test.stopTest();

		System.assertEquals(1, overdueRequests.size());
	}

	static testMethod void findOverdueEvaluationsTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [select Id, RecordTypeId, Record_Type_Name__c, Name, Sub_Status__c, Program_End_Date_max__c from GFRS_Funding_Request__c LIMIT 1];
		fundingRequest.RecordTypeId = ID_FR_IMED_RECTYPE;
		fundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ;
		update fundingRequest;

		Test.startTest();
		gFRS_Funding_Request__c[] overdueRequests = gFRS_Util_NoShare.findOverdueEvaluations();
		Test.stopTest();

		System.assertEquals(0, overdueRequests.size());
	}

	static testMethod void createAccountFromOrganizationTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Organization__c organization = [SELECT Id, Organization_Name__c from GFRS_Organization__c LIMIT 1];

		Test.startTest();
		Account account = gFRS_Util_NoShare.createAccountFromOrganization(organization);
		Test.stopTest();

		System.assertEquals(organization.Organization_Name__c, account.Name);
	}

	static testMethod void associateUserWithAccountTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Test.startTest();
		Boolean isAssociated = gFRS_Util_NoShare.associateUserWithAccount(ts.user.Id, ts.account.Id, ts.organization.Id);
		Test.stopTest();

		System.assertEquals(false,isAssociated);
	}

	static testMethod void applySharingRulesForNewUserTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		GFRS_Funding_Request__c fundingRequest = [select Id, Signing_Authority_Email__c, Name, Sub_Status__c, Program_End_Date_max__c from GFRS_Funding_Request__c LIMIT 1];
		fundingRequest.Signing_Authority_Email__c = 'test@gmail.com';
		update fundingRequest;

		Test.startTest();
		Boolean areUpdated = gFRS_Util_NoShare.applySharingRulesForNewUser('test@gmail.com', ts.user.Id);
		Test.stopTest();

		System.assertEquals(true, areUpdated);
	}

	static testMethod void getUserByIdTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Test.startTest();
		User user = gFRS_Util_NoShare.getUserById(ts.user.Id);
		Test.stopTest();

		System.assertEquals(ts.user.Id, user.Id);
	}

	static testMethod void getUserByUnixIdTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Test.startTest();
		Id id = gFRS_Util_NoShare.getUserByUnixId(gFRS_TestCreationUtils.makeUnique('ux0001'));
		Test.stopTest();

		System.assertEquals(null, id);
	}

	static testMethod void upsertRequestSharesTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Map<Id, GFRS_Funding_Request__c> reqs = new Map<Id, GFRS_Funding_Request__c> {};
		reqs.put(ts.request.Id, ts.request);
		gFRS_Funding_Request__Share[] shares = new List<gFRS_Funding_Request__Share>();
		shares.add(gFRS_Util.createRequestShare(ts.request.Id, ts.user.Id, 'Edit'));

		Test.startTest();
		gFRS_Util_NoShare.upsertRequestShares(shares, reqs);
		Test.stopTest();
	}

	static testMethod void createAppropriateTaskTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(ts.request.Id, ts.request);
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		fundingRequest.Status__c = 'Decision';
		update fundingRequest;
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.createAppropriateTask(requests, oldMap);
		Test.stopTest();

		List<gFRS_Tasks__c> tasks = [SELECT Id FROM gFRS_Tasks__c];
		System.assertEquals(0, tasks.size());
	}

	static testMethod void createAppropriateTaskRFITest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(ts.request.Id, ts.request);
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		fundingRequest.Sub_Status__c = 'RFI';
		fundingRequest.Status__c = 'Decision';
		update fundingRequest;
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.createAppropriateTask(requests, oldMap);
		Test.stopTest();

		List<gFRS_Tasks__c> tasks = [SELECT Id FROM gFRS_Tasks__c];
		System.assertEquals(1, tasks.size());
	}

	static testMethod void createAppropriateTaskApprovedLOAProcessingTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(ts.request.Id, ts.request);
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		fundingRequest.RecordTypeId = ID_FR_FIELD_INI_EXHIBIT;
		fundingRequest.Sub_Status__c = 'Approved-Awaiting LOA';
		fundingRequest.Status__c = 'Processing & Disposition';
		update fundingRequest;
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.createAppropriateTask(requests, oldMap);
		Test.stopTest();

		List<gFRS_Tasks__c> tasks = [SELECT Id FROM gFRS_Tasks__c];
		System.assertEquals(1, tasks.size());
	}

	static testMethod void createAppropriateTaskApprovedLOAProcessingIMEDTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(ts.request.Id, ts.request);
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		fundingRequest.RecordTypeId = ID_FR_IMED_RECTYPE;
		fundingRequest.Sub_Status__c = 'Approved-Status Updates/Outcomes';
		fundingRequest.Status__c = 'Processing & Disposition';
		update fundingRequest;
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.createAppropriateTask(requests, oldMap);
		Test.stopTest();

		List<gFRS_Tasks__c> tasks = [SELECT Id FROM gFRS_Tasks__c];
		System.assertEquals(0, tasks.size());
	}

	static testMethod void resetToSunshineAfterReconTaskStartedTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c oldRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldRequest.Sub_Status__c = 'Sunshine Act Disclosure';
		oldMap.put(oldRequest.Id, oldRequest);
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		fundingRequest.Sub_Status__c = 'Reconciliation Required';
		fundingRequest.Sunshine_Act_Disclosure_Submitted__c = gFRS_Util.NO;
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.resetToSunshineAfterReconTaskStarted(requests, oldMap);
		Test.stopTest();

		List<GFRS_Funding_Request__c> fundingRequests = [SELECT Id, Sub_Status__c, External_Sub_status__c, Status__c FROM GFRS_Funding_Request__c];
		System.assertEquals(fundingRequests.get(0).Sub_Status__c, gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE);
		System.assertEquals(fundingRequests.get(0).External_Sub_status__c, gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE);
	}

	static testMethod void insertLOAattachmentTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		String myString = 'insertLOAattachment';
		Blob myBlob = Blob.valueof(myString);

		Test.startTest();
		gFRS_Util_NoShare.insertLOAattachment('test', myBlob, fundingRequest);
		Test.stopTest();

		List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment LIMIT 1];
		GFRS_Funding_Request__c request = [SELECT Id, LOA_PDF__c FROM GFRS_Funding_Request__c LIMIT 1];
		System.assertEquals(attachments.get(0).Id, request.LOA_PDF__c);
		System.assertEquals('test', attachments.get(0).Name);
	}

	static testMethod void insertComplianceAttachmentTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		String myString = 'insertComplianceAttachment';
		Blob myBlob = Blob.valueof(myString);

		Test.startTest();
		gFRS_Util_NoShare.insertComplianceAttachment('test', myBlob, fundingRequest);
		Test.stopTest();

		List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment LIMIT 1];
		GFRS_Funding_Request__c request = [SELECT Id, Compliance_flags_PDF__c FROM GFRS_Funding_Request__c LIMIT 1];
		System.assertEquals(attachments.get(0).Id, request.Compliance_flags_PDF__c);
		System.assertEquals('test', attachments.get(0).Name);
	}

	static testMethod void insertVendorDetailsAttachmentExternalTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		String myString = 'insertVendorDetailsAttachmentExternal';
		Blob myBlob = Blob.valueof(myString);

		Test.startTest();
		gFRS_Util_NoShare.insertVendorDetailsAttachmentExternal('test', myBlob, fundingRequest);
		Test.stopTest();

		List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment LIMIT 1];
		GFRS_Funding_Request__c request = [SELECT Id, Vendor_Details_PDF__c FROM GFRS_Funding_Request__c LIMIT 1];
		System.assertEquals(attachments.get(0).Id, request.Vendor_Details_PDF__c);
		System.assertEquals('test', attachments.get(0).Name);
	}

	static testMethod void insertFundingRequestAttachmentTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c request = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		String myString = 'insertFundingRequestAttachment';
		Blob myBlob = Blob.valueof(myString);

		Test.startTest();
		gFRS_Util_NoShare.insertVendorDetailsAttachmentExternal('test', myBlob, request);
		Test.stopTest();

		List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment LIMIT 1];
		GFRS_Funding_Request__c requestWithInsert = [SELECT Id, Vendor_Details_PDF__c FROM GFRS_Funding_Request__c LIMIT 1];
		System.assertEquals(attachments.get(0).Id, requestWithInsert.Vendor_Details_PDF__c);
		System.assertEquals('test', attachments.get(0).Name);
	}

	static testMethod void checkIfUserIsExternalRequesterTest() {
		Id profileId = [SELECT Id, Name FROM Profile WHERE Name = 'GNE-GFRS-External Requestor'].Id;
		Test.startTest();
		Boolean isExternalRequestor = gFRS_Util_NoShare.checkIfUserIsExternalRequester(profileId);
		Test.stopTest();

		System.assertEquals(true, isExternalRequestor);
	}

	static testMethod void insertFundingRequestAttachmentSubTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c request = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		String myString = 'insertFundingRequestAttachment';
		Blob myBlob = Blob.valueof(myString);

		Test.startTest();
		gFRS_Util_NoShare.insertFundingRequestAttachment('HC_Compliance_Flags_PDF__c', 'test', myBlob, request);
		Test.stopTest();

		List<Attachment> attachments = [SELECT Id, Name, Body FROM Attachment LIMIT 1];
		GFRS_Funding_Request__c requestWithInsert = [SELECT Id, HC_Compliance_Flags_PDF__c FROM GFRS_Funding_Request__c LIMIT 1];
		System.assertEquals(attachments.get(0).Id, requestWithInsert.HC_Compliance_Flags_PDF__c);
		System.assertEquals('test', attachments.get(0).Name);
	}

	static testMethod void setLastGrantStatusTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c oldRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(oldRequest.Id, oldRequest);
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.setLastGrantStatus(requests, oldMap);
		Test.stopTest();

		System.assertEquals(requests.get(0).Last_Grant_Status__c, oldRequest.Sub_Status__c);
	}

	static testMethod void setProcessPaymentStatusDateTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c oldRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(oldRequest.Id, oldRequest);
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.setProcessPaymentStatusDate(requests, oldMap);
		Test.stopTest();

		System.assertEquals(requests.get(0).Process_Payment_Status_Date__c, Date.today());
	}

	static testMethod void setClosedDateTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c oldRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		fundingRequest.Status__c = 'Closed';
		update fundingRequest;
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(oldRequest.Id, oldRequest);
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.setClosedDate(requests, oldMap);
		Test.stopTest();

		System.assertEquals(null, requests.get(0).Process_Payment_Status_Date__c);
	}


	static testMethod void resetSysRequestApprovedToNoTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		GFRS_Funding_Request__c oldRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		fundingRequest.Status__c = 'Closed';
		fundingRequest.Sub_Status__c = 'Sub_Status__c';
		fundingRequest.SYS_Request_Approved__c = gFRS_Util.YES;
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(oldRequest.Id, oldRequest);
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.resetSysRequestApprovedToNo(requests, oldMap);
		Test.stopTest();

		System.assertEquals(false, requests.get(0).Request_Approved__c);
	}

	static testMethod void getSubmitedRequestUnderOrgTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Request_Approved__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];
		String taxId = '';
		String nonUSTaxId = '';

		Test.startTest();
		gFRS_Util_NoShare.getSubmitedRequestUnderOrg(taxId, nonUSTaxId);
		Test.stopTest();

		System.assertEquals(false, fundingRequest.Request_Approved__c);
	}

	static testMethod void resetExhibitOpportunityTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Request_Approved__c, Sunshine_Act_Disclosure_Submitted__c FROM GFRS_Funding_Request__c LIMIT 1];

		Test.startTest();
		gFRS_Util_NoShare.resetExhibitOpportunity(fundingRequest);
		Test.stopTest();

		System.assertEquals(false, fundingRequest.Request_Approved__c);
	}

	static testMethod void preventUnifiedCalendarDuplicateTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		UnifiedCalendar_gne__c unifiedCalendarGne = new UnifiedCalendar_gne__c(Secondary_Calendar_ID__c = 'test@gmail.com', UniqRecord__c = 'test1');
		UnifiedCalendar_gne__c unifiedCalendarGne1 = new UnifiedCalendar_gne__c(Secondary_Calendar_ID__c = 'test@gmail.com', UniqRecord__c = 'test2');
		List<UnifiedCalendar_gne__c> unifiedCalendarGnes = new List<UnifiedCalendar_gne__c> {unifiedCalendarGne, unifiedCalendarGne1};
		insert unifiedCalendarGnes;

		Test.startTest();
		gFRS_Util_NoShare.preventUnifiedCalendarDuplicate(unifiedCalendarGnes);
		Test.stopTest();
	}

	static testMethod void submitHC_ProgramsTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertHCRequest();

		GFRS_Funding_Request__c newRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Record_Type_Name__c
		FROM GFRS_Funding_Request__c WHERE
				Record_Type_Name__c =: gFRS_Util.TYPE_HC_CHAR_NAME
		LIMIT 1];

		GFRS_Funding_Request__c oldRequests = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Record_Type_Name__c
		FROM GFRS_Funding_Request__c WHERE
				Record_Type_Name__c =: gFRS_Util.TYPE_HC_CHAR_NAME
		LIMIT 1];

		newRequest.Status__c = 'HC Compliance';
		oldRequests.Status__c = 'Intake';
		update newRequest;
		update oldRequests;
		gFRS_Program__c program = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, newRequest, 3, 'test1234');
		program.Program_Status__c = 'Planned';
		insert program;

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(oldRequests.Id, oldRequests);

		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		requests.add(newRequest);

		Test.startTest();
		gFRS_Util_NoShare.submitHC_Programs(requests, oldMap);
		Test.stopTest();

		List<gFRS_Program__c> programAfterUpdate  =  [SELECT Id, Program_Status__c FROM gFRS_Program__c WHERE Program_Status__c = 'Confirmed'];

		System.assertEquals(1, programAfterUpdate.size());
	}

	static testMethod void checkCustomPermissionTest() {
        Profile profile = [SELECT Id, Name FROM Profile WHERE Name = 'GNE-GFRS-User' LIMIT 1];

        User user = gFRS_UnitTestHelper.createInternalGFRSUser();

        PermissionSet paymentButtonEnable = [SELECT Id, Name FROM PermissionSet WHERE Name = 'gFRS_Submit_Payment_Button_enable'];
        PermissionSetAssignment permissionSetAssignment = new PermissionSetAssignment(PermissionSetId = paymentButtonEnable.Id, AssigneeId = user.Id);
        insert permissionSetAssignment;

		System.runAs(user) {
			Boolean hasCustomPermission = gFRS_Util_NoShare.checkCustomPermission('gFRS_Payment_Submit_Button');
			System.assertEquals(true, hasCustomPermission);
		}
	}

	static testMethod void checkIfUserIsSuperUserTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		Profile superProfile = [SELECT Id, Name FROM Profile WHERE Name = 'GNE-GFRS-Admin'];
		User user = [SELECT Id, ProfileId FROM User WHERE ProfileId =: superProfile.Id LIMIT 1];

		Test.startTest();
		Boolean isSuperUser = gFRS_Util_NoShare.checkIfUserIsSuperUser(user.ProfileId);
		Test.stopTest();

		System.assertEquals(true, isSuperUser);
	}

	static testMethod void deleteAppropriateHCProgramsIfExistsTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		GFRS_Funding_Request__c fundingRequests = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c
		FROM GFRS_Funding_Request__c LIMIT 1];

		fundingRequests.Event_Project_type__c = 'Financial assistance';
		update fundingRequests;

		Test.startTest();
		gFRS_Util_NoShare.deleteAppropriateHCProgramsIfExists(fundingRequests.Id);
		Test.stopTest();

		List<GFRS_Program__c> programs = [SELECT Id FROM GFRS_Program__c];
		System.assertEquals(1, programs.size());
	}

	static testMethod void deleteAppropriateHCProgramsIfExistsFundraiserTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		GFRS_Funding_Request__c fundingRequests = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c
		FROM GFRS_Funding_Request__c LIMIT 1];

		fundingRequests.Event_Project_type__c = 'Fundraiser';
		update fundingRequests;

		Test.startTest();
		gFRS_Util_NoShare.deleteAppropriateHCProgramsIfExists(fundingRequests.Id);
		Test.stopTest();

		List<GFRS_Program__c> programs = [SELECT Id FROM GFRS_Program__c];
		System.assertEquals(1, programs.size());
	}

	static testMethod void deleteAppropriateHCProgramsIfExistsFInternationalTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		GFRS_Funding_Request__c fundingRequests = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c
		FROM GFRS_Funding_Request__c LIMIT 1];

		fundingRequests.Event_Project_type__c = 'International scientific/medical meeting';
		update fundingRequests;

		Test.startTest();
		gFRS_Util_NoShare.deleteAppropriateHCProgramsIfExists(fundingRequests.Id);
		Test.stopTest();

		List<GFRS_Program__c> programs = [SELECT Id FROM GFRS_Program__c];
		System.assertEquals(1, programs.size());
	}

	static testMethod void resetUnusedFieldForHCCharLiveTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Program__c program = [SELECT Id, Type__c,Web_URL__c FROM GFRS_Program__c LIMIT 1];
		program.Type__c = 'Live Activity';

		Test.startTest();
		gFRS_Util_NoShare.resetUnusedFieldForHCChar(program);
		Test.stopTest();

		System.assertEquals(null, program.Web_URL__c);
	}

	static testMethod void resetUnusedFieldForHCChaOngoingTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Program__c program = [SELECT Id, Type__c FROM GFRS_Program__c LIMIT 1];
		program.Type__c = 'Ongoing';

		Test.startTest();
		gFRS_Util_NoShare.resetUnusedFieldForHCChar(program);
		Test.stopTest();

		System.assertEquals(null, program.Web_URL__c);
	}

	static testMethod void resetUnusedFieldForHCCharOnlineTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Program__c program = [SELECT Id, Type__c FROM GFRS_Program__c LIMIT 1];
		program.Type__c = 'Online Resources';

		Test.startTest();
		gFRS_Util_NoShare.resetUnusedFieldForHCChar(program);
		Test.stopTest();

		System.assertEquals(null, program.Exhibits_or_Displays_Allowed__c);
	}

	static testMethod void setDeliveryMethodForFundationOrNoTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Record_Type_Name__c, Students_of_Color_Scholarships__c,Hunger__c,Pediatric_Cancer_Assistance__c,Basic_Research_Fellow__c,Requested_Amount__c,Foundation_Eligible__c
												  FROM GFRS_Funding_Request__c
												  WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC];
		GFRS_Funding_Request__c oldRequest = [SELECT Id, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Record_Type_Name__c, Students_of_Color_Scholarships__c,Hunger__c,Pediatric_Cancer_Assistance__c,Basic_Research_Fellow__c,Requested_Amount__c,Foundation_Eligible__c
											  FROM GFRS_Funding_Request__c
											  WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC];
		fundingRequest.Status__c = 'Decision';
		fundingRequest.Foundation_Eligible__c = 'TRUE';
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(oldRequest.Id, oldRequest);
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		requests.add(fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.setDeliveryMethodForFundationOrNo(requests, oldMap);
		Test.stopTest();

		System.assertEquals(null, requests.get(0).Delivery_Method__c);
	}

	static testMethod void getRfiDateTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c request = [SELECT Id FROM GFRS_Funding_Request__c LIMIT 1];
		gFRS_Tasks__c t = gFRS_TestCreationUtils.createTask2(request.Id, 'In Progress', ts.user.Id);
		t.Action_Type__c = gFRS_Util.REQUEST_STATUS_RFI;
		upsert t;

		Test.startTest();
		Datetime rfiDatetime = gFRS_Util_NoShare.getRfiDate(request.Id);
		Test.stopTest();

		System.assertEquals(true, String.isNotBlank(String.valueOf(rfiDatetime)));
	}

	static testMethod void getRfiDateByActionTypeTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c request = [SELECT Id FROM GFRS_Funding_Request__c LIMIT 1];
		gFRS_Tasks__c t = gFRS_TestCreationUtils.createTask2(request.Id, 'In Progress', ts.user.Id);
		t.Action_Type__c = gFRS_Util.REQUEST_STATUS_RFI;
		upsert t;

		Test.startTest();
		Datetime rfiDatetime = gFRS_Util_NoShare.getRfiDateByActionType(request.Id, gFRS_Util.REQUEST_STATUS_RFI);
		Test.stopTest();

		System.assertEquals(true, String.isNotBlank(String.valueOf(rfiDatetime)));
	}

	static testMethod void checkIsRFITest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c request = [SELECT Id, Information_Needed__c FROM GFRS_Funding_Request__c LIMIT 1];
		request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS;
		update request;
		gFRS_Tasks__c t = gFRS_TestCreationUtils.createTask2(request.Id, 'In Progress', ts.user.Id);
		t.Action_Type__c = gFRS_Util.REQUEST_STATUS_RFI;
		upsert t;

		Test.startTest();
		Boolean isRFI = gFRS_Util_NoShare.checkIsRFI(request.Id);
		Test.stopTest();

		System.assertEquals(true, isRFI);
	}

	static testMethod void checkIsPageInRFIStatus() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c request = [SELECT Id, Information_Needed__c FROM GFRS_Funding_Request__c LIMIT 1];
		request.Information_Needed__c = gFRS_Util.INFO_NEEDED_APPLICATION;
		update request;
		gFRS_Tasks__c t = gFRS_TestCreationUtils.createTask2(request.Id, 'In Progress', ts.user.Id);
		t.Action_Type__c = gFRS_Util.REQUEST_STATUS_RFI;
		upsert t;

		Test.startTest();
		Boolean isRFI = gFRS_Util_NoShare.checkIsPageInRFIStatus(request.Id, gFRS_Util.INFO_NEEDED_APPLICATION);
		Test.stopTest();

		System.assertEquals(true, isRFI);
	}

	static testMethod void checkIsSunshineCommunicationSentTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c request = [SELECT Id, Sunshine_Communication_Sent__c FROM GFRS_Funding_Request__c LIMIT 1];
		request.Sunshine_Communication_Sent__c = true;
		update request;

		Test.startTest();
		Boolean isCommunicationSent = gFRS_Util_NoShare.checkIsSunshineCommunicationSent(request.Id);
		Test.stopTest();

		System.assertEquals(true, isCommunicationSent);
	}

	static testMethod void getFieldLabelsMapForGivenObjectTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		GFRS_Funding_Request__c request = [SELECT Id, Sunshine_Communication_Sent__c FROM GFRS_Funding_Request__c LIMIT 1];
		request.Sunshine_Communication_Sent__c = true;
		update request;

		Test.startTest();
		Map<String,String> objectSchema= gFRS_Util_NoShare.getFieldLabelsMapForGivenObject('GFRS_Funding_Request__c');
		Test.stopTest();

		System.assertEquals('Location State',objectSchema.get('location_state__c'));
	}

	static testMethod void IsUserHasDelegationRecordTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		Test.startTest();
		boolean userHasDelegationRecord = gFRS_Util_NoShare.IsUserHasDelegationRecord('Sherie', gFRS_Util.TYPE_HC_CHAR_NAME);
		Test.stopTest();

		System.assertEquals(false , userHasDelegationRecord);
	}

	static testMethod void IsUserHasPSStandardUserDelegationTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();

		Test.startTest();
		boolean hasPSStandard = gFRS_Util_NoShare.IsUserHasPSStandardUserDelegation(ts.user.Id);
		Test.stopTest();

		System.assertEquals(false , hasPSStandard);
	}

	static testMethod void checkIsPaymentSuccesfullySubmittedTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();

		Test.startTest();
		boolean hasHistory = gFRS_Util_NoShare.checkIsPaymentSuccesfullySubmitted(ts.fundingAllocation);
		Test.stopTest();

		System.assertEquals(false , hasHistory);
	}

	static testMethod void stopApprovalProcessIFBADidntSetApprovedAmountTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id,Name, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c
				FROM GFRS_Funding_Request__c
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c
				FROM GFRS_Funding_Request__c
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.Business_Approver_Decision_Date__c = Date.today().addDays(1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.Foundation_Eligible__c = 'No';
		fundingRequest.Business_Approver_Decision__c = 'Approved';
		fundingRequest.Business_Approver_Decision_Date__c = Date.today();
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.stopApprovalProcessIFBADidntSetApprovedAmount(newMap, oldMap);
		Test.stopTest();

		String errorMessages = '';
		for(ApexPages.Message message : ApexPages.getMessages()) {
			errorMessages += message.getSummary();
		}
		System.assert(errorMessages.contains(fundingRequest.Id));
	}

	static testMethod void stopApprovalProcessIfGCDidntSetApproversTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c newRequest = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};

		oldRequest.GC_Review_Decision_Date__c = Date.today().addDays(1);

		newRequest.Foundation_Eligible__c = 'Yes';
		newRequest.Students_of_Color_Scholarships__c = 'Yes';
		newRequest.Hunger__c = 'Yes';
		newRequest.Pediatric_Cancer_Assistance__c = 'Yes';
		newRequest.Basic_Research_Fellow__c = 'Yes';
		newRequest.GC_Decision__c = 'Approved';
		newRequest.Requested_Amount__c = 27000;

		update newRequest;
		update oldRequest;

		GFRS_Funding_Request__c newRequestAfterUpdate = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequestAfterUpdate = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		newRequestAfterUpdate.GC_Review_Decision_Date__c = Date.today();
		oldRequestAfterUpdate.GC_Review_Decision_Date__c = Date.today().addDays(1);

		oldMap.put(oldRequestAfterUpdate.Id, oldRequestAfterUpdate);
		newMap.put(newRequestAfterUpdate.Id, newRequestAfterUpdate);

		Test.startTest();
		gFRS_Util_NoShare.stopApprovalProcessIfGCDidntSetApprovers(newMap, oldMap);
		Test.stopTest();

		String errorMessages = '';
		for(ApexPages.Message message : ApexPages.getMessages()) {
			errorMessages += message.getSummary();
		}
		System.assertEquals(false, errorMessages.contains(newRequest.Id));
	}

	static testMethod void foundationBA1ApproveSubStatusUpdateTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c newRequest = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};

		oldRequest.GC_Review_Decision_Date__c = Date.today().addDays(1);

		newRequest.Foundation_Eligible__c = 'Yes';
		newRequest.Students_of_Color_Scholarships__c = 'Yes';
		newRequest.Hunger__c = 'Yes';
		newRequest.Pediatric_Cancer_Assistance__c = 'Yes';
		newRequest.Basic_Research_Fellow__c = 'Yes';
		newRequest.Business_Approver_Decision__c = 'Approved';
		newRequest.Requested_Amount__c = 27000;

		update newRequest;
		update oldRequest;

		GFRS_Funding_Request__c newRequestAfterUpdate = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequestAfterUpdate = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		newRequestAfterUpdate.Business_Approver_Decision_Date__c = Date.today();
		oldRequestAfterUpdate.Business_Approver_Decision_Date__c = Date.today().addDays(1);

		oldMap.put(oldRequestAfterUpdate.Id, oldRequestAfterUpdate);
		newMap.put(newRequestAfterUpdate.Id, newRequestAfterUpdate);

		Test.startTest();
		gFRS_Util_NoShare.foundationBA1ApproveSubStatusUpdate(newMap, oldMap);
		Test.stopTest();
	}

	static testMethod void 	validateBA1ApprovalTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c,Financial_Approver_1_Decision_Date__c,Financial_Approver_1_Decision__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c,Financial_Approver_1_Decision_Date__c,Financial_Approver_1_Decision__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.Business_Approver_Decision_Date__c = Date.today().addDays(1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.Business_Approver_Decision__c = gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
		fundingRequest.Business_Approver_Decision_Date__c = Date.today();
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.validateBA1Approval(newMap, oldMap);
		Test.stopTest();

		String errorMessages = '';
		for(ApexPages.Message message : ApexPages.getMessages()) {
			errorMessages += message.getSummary();
		}
		System.assert(errorMessages.contains(fundingRequest.Id));
	}

	static testMethod void validateFA1ApprovalTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Status__c, Name, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c,Financial_Approver_1_Decision_Date__c,Financial_Approver_1_Decision__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Status__c, Name, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c,Financial_Approver_1_Decision_Date__c,Financial_Approver_1_Decision__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.Financial_Approver_1_Decision_Date__c = Date.today().addDays(1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.Financial_Approver_1_Decision__c = gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
		fundingRequest.Financial_Approver_1_Decision_Date__c = Date.today();
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.validateFA1Approval(newMap, oldMap);
		Test.stopTest();

		String errorMessages = '';
		for(ApexPages.Message message : ApexPages.getMessages()) {
			errorMessages += message.getSummary();
		}
		System.assertEquals(false, errorMessages.contains(fundingRequest.Id));
	}

	static testMethod void validateFA3ApprovalTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.Financial_Approver_3_Decision_Date__c = Date.today().addDays(1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.Financial_Approver_3_Decision__c = gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
		fundingRequest.Financial_Approver_3_Decision_Date__c = Date.today();
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.validateFA3Approval(newMap, oldMap);
		Test.stopTest();

		String errorMessages = '';
		for(ApexPages.Message message : ApexPages.getMessages()) {
			errorMessages += message.getSummary();
		}
		System.assertEquals(false, errorMessages.contains(fundingRequest.Id));
	}

	static testMethod void validateFA1CoverageOfPaymentTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c = :gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		List<GFRS_Funding_Allocation__c> listOfFundingAllocation = [SELECT Id FROM GFRS_Funding_Allocation__c];

		Test.startTest();
		gFRS_Util_NoShare.validateFA1CoverageOfPayment(fundingRequest,listOfFundingAllocation);
		Test.stopTest();
	}

	static testMethod void validateFA1PercentageOfLineItemsTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Name ,Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c = :gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		List<GFRS_Funding_Allocation_Line_Item__c> listOfFundingAllocation = [SELECT Id FROM GFRS_Funding_Allocation_Line_Item__c];

		Test.startTest();
		Boolean valid = gFRS_Util_NoShare.validateFA1PercentageOfLineItems(fundingRequest, listOfFundingAllocation);
		Test.stopTest();

		System.assertEquals(true, valid);
	}

	static testMethod void validateFA3CoverageOfPaymentTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c = :gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		List<GFRS_Funding_Allocation__c> listOfFundingAllocation = [SELECT Id FROM GFRS_Funding_Allocation__c];

		Test.startTest();
		Boolean valid  = gFRS_Util_NoShare.validateFA3CoverageOfPayment(fundingRequest, listOfFundingAllocation);
		Test.stopTest();

		System.assertEquals(true, valid);
	}

	static testMethod void validateFA3PercentageOfLineItemsTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c = :gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		List<GFRS_Funding_Allocation_Line_Item__c> listOfFundingAllocation = [SELECT Id FROM GFRS_Funding_Allocation_Line_Item__c];

		Test.startTest();
		Boolean valid  = gFRS_Util_NoShare.validateFA3PercentageOfLineItems(fundingRequest, listOfFundingAllocation);
		Test.stopTest();

		System.assertEquals(true, valid);
	}

	static testMethod void validateBA1CoverageOfPaymentTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c = :gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		List<GFRS_Funding_Allocation__c> listOfFundingAllocation = [SELECT Id FROM GFRS_Funding_Allocation__c];

		Test.startTest();
		Boolean valid = gFRS_Util_NoShare.validateBA1CoverageOfPayment(fundingRequest, listOfFundingAllocation);
		Test.stopTest();

		System.assertEquals(false, valid);
	}

	static testMethod void validateBA1PercentageOfLineItemsTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id, Status__c, Sub_Status__c, Record_Type_Name__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c = :gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		List<GFRS_Funding_Allocation_Line_Item__c> listOfFundingAllocation = [SELECT Id FROM GFRS_Funding_Allocation_Line_Item__c];

		Test.startTest();
		Boolean valid = gFRS_Util_NoShare.validateBA1PercentageOfLineItems(fundingRequest, listOfFundingAllocation);
		Test.stopTest();

		System.assertEquals(false, valid);
	}

	static testMethod void addSharingForBrBaApproversForFoundationTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c newRequest = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};

		oldRequest.GC_Review_Decision_Date__c = Date.today().addDays(1);

		newRequest.Foundation_Eligible__c = 'Yes';
		newRequest.Students_of_Color_Scholarships__c = 'Yes';
		newRequest.Hunger__c = 'Yes';
		newRequest.Pediatric_Cancer_Assistance__c = 'Yes';
		newRequest.Basic_Research_Fellow__c = 'Yes';
		newRequest.Business_Approver_Decision__c = 'Approved';
		newRequest.Requested_Amount__c = 27000;

		update newRequest;
		update oldRequest;

		GFRS_Funding_Request__c newRequestAfterUpdate = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequestAfterUpdate = [
				SELECT Id, Name, Record_Type_Name__c, Status__c, Sub_Status__c, GC_Review_Decision_Date__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c, Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		newRequestAfterUpdate.Business_Reviewer_1__c = ts.user.Id;
		newRequestAfterUpdate.Business_Approver__c = ts.user.Id;
		newRequestAfterUpdate.Legal_Reviewer_1__c = ts.user.Id;
		newRequestAfterUpdate.Business_Approver_2__c = ts.user.Id;
		newRequestAfterUpdate.Business_Approver_3__c = ts.user.Id;

		newRequestAfterUpdate.GC_Review_Decision_Date__c = Date.today();
		oldRequestAfterUpdate.GC_Review_Decision_Date__c = Date.today().addDays(1);

		oldMap.put(oldRequestAfterUpdate.Id, oldRequestAfterUpdate);
		newMap.put(newRequestAfterUpdate.Id, newRequestAfterUpdate);

		Test.startTest();
		gFRS_Util_NoShare.addSharingForBrBaApproversForFoundation(newMap, oldMap);
		Test.stopTest();

	}

	static testMethod void stopApprovalProcessIFFA3DidntSetComAcitvityTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertCorporateMembershipRequest();

		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id,Name, Record_Type_Name__c, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c, Requested_Amount__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c,Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c = 'Corporate Memberships'
				LIMIT 1
		];
		ts.insertFundingAllocationWithSpecificRequest(fundingRequest);
		ts.insertFundingAllocationLineItem();
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c FROM GFRS_Funding_Request__c
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.Financial_Approver_3_Decision_Date__c = Date.today().addDays(-1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.Financial_Approver_3_Decision_Date__c = Date.today();
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.stopApprovalProcessIFFA3DidntSetComAcitvity(newMap, oldMap);
		Test.stopTest();
	}

	static testMethod void restrictBA1FromEdittingTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertCorporateMembershipRequest();

		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id,Name, Record_Type_Name__c, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c, Requested_Amount__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c,Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c = 'Corporate Memberships'
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c FROM GFRS_Funding_Request__c
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldMap.put(oldRequest.Id, oldRequest);
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.restrictBA1FromEditting(newMap, oldMap);
		Test.stopTest();
	}

	static testMethod void stopApprovalIfLRNotSpecifiedTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id,Name, Record_Type_Name__c, Status__c, Legal_Review_Develops_Medicare_Notes__c, Organization_Medicare_Gudeline_Dev__c, Foundation_Classified__c, Foundation_Eligible__c, Requested_Amount__c,
						Legal_Reviewer_1__c, CCO_Decision_Date__c, CCO_Decision__c,Students_of_Color_Scholarships__c, Hunger__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id, Name, Status__c, Sub_Status__c, CCO_Decision_Date__c,Foundation_Eligible__c, Foundation_Classified__c, Business_Approver_Decision__c,
						Business_Approver_Decision_Date__c,Legal_Reviewer_1__c  FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		ts.modifyOrganization();
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.CCO_Decision_Date__c = Date.today().addDays(-1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.CCO_Decision_Date__c = Date.today();
		fundingRequest.CCO_Decision__c = 'Approved';
		fundingRequest.Legal_Reviewer_1__c = null;
		fundingRequest.Legal_Review_Develops_Medicare_Notes__c = null;
		update fundingRequest;
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.stopApprovalIfLRNotSpecified(newMap, oldMap);
		Test.stopTest();
	}

	static testMethod void stopApprovalIfLRNeedToBeSpecifiedWhenComplianceRedPhilanthropicTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id,Name, Record_Type_Name__c, Organization_Develops_Medicare__c, GC_Review_Decision_Date__c, GC_Decision__c,Business_Reviewer_Decision_Date__c,
						Business_Reviewer_Decision__c,Legal_Reviewer_1__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id,Name, Record_Type_Name__c, Organization_Develops_Medicare__c, GC_Review_Decision_Date__c, GC_Decision__c,Business_Reviewer_Decision_Date__c,
						Business_Reviewer_Decision__c,Legal_Reviewer_1__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.GC_Review_Decision_Date__c = Date.today().addDays(-1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.GC_Review_Decision_Date__c = Date.today();
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.stopApprovalIfLRNeedToBeSpecifiedWhenComplianceRed(newMap, oldMap);
		Test.stopTest();
	}

	static testMethod void stopApprovalIfLRNeedToBeSpecifiedWhenComplianceRedHCTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id,Name, Record_Type_Name__c, Organization_Develops_Medicare__c, GC_Review_Decision_Date__c, GC_Decision__c,Business_Reviewer_Decision_Date__c,
						Business_Reviewer_Decision__c,Legal_Reviewer_1__c
				FROM GFRS_Funding_Request__c
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id,Name, Record_Type_Name__c, Organization_Develops_Medicare__c, GC_Review_Decision_Date__c, GC_Decision__c,Business_Reviewer_Decision_Date__c,
						Business_Reviewer_Decision__c,Legal_Reviewer_1__c
				FROM GFRS_Funding_Request__c
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldMap.put(oldRequest.Id, oldRequest);
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.stopApprovalIfLRNeedToBeSpecifiedWhenComplianceRed(newMap, oldMap);
		Test.stopTest();
	}

	static testMethod void stopApprovalIfBA1IsRequiredTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id,Name, Record_Type_Name__c, Organization_Develops_Medicare__c, GC_Review_Decision_Date__c, GC_Decision__c,Business_Reviewer_Decision_Date__c,
						Business_Reviewer_Decision__c,Legal_Reviewer_1__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id,Name, Record_Type_Name__c, Organization_Develops_Medicare__c, GC_Review_Decision_Date__c, GC_Decision__c,Business_Reviewer_Decision_Date__c,
						Business_Reviewer_Decision__c,Legal_Reviewer_1__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.GC_Review_Decision_Date__c = Date.today().addDays(-1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.GC_Review_Decision_Date__c = Date.today();
		fundingRequest.GC_Decision__c = 'Approved';
		fundingRequest.Business_Approver__c = null;
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.stopApprovalIfBA1IsRequired(newMap, oldMap);
		Test.stopTest();
	}

	static testMethod void updateFinanceReportJunctionPaymentHistoryUpdateTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();

		gFRS_Payment_History__c paymentHistory = createPaymentHistory(ts.request);
		Map<Id, gFRS_Payment_History__c> oldPayments = new Map<Id, gFRS_Payment_History__c>();
		gFRS_Payment_History__c[] paymentsHistory = new gFRS_Payment_History__c[]{paymentHistory};
		oldPayments.put(paymentHistory.Id, paymentHistory);

		Test.startTest();
		gFRS_Util_NoShare.updateFinanceReportJunctionPaymentHistoryUpdate(paymentsHistory, oldPayments);
		Test.stopTest();
	}

	static testMethod void updateOutcomesSubmissonTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertIMEDMembershipRequest();

		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Record_Type_Name__c, Outcomes_Submission_Status__c FROM GFRS_Funding_Request__c
		WHERE Record_Type_Name__c =: gFRS_Util.TYPE_IMED LIMIT 1];
		gFRS_Util_NoShare.createTask('Not Started', 'Test Subject', null, fundingRequest.id, null, 'Outcomes');
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(fundingRequest.Id, fundingRequest);
		fundingRequest.Outcomes_Submission_Status__c = 'Partial Outcomes';
		requests.add(fundingRequest);

		System.debug('ID OF FUNDING: ' + fundingRequest.Record_Type_Name__c);
		Test.startTest();
		gFRS_Util_NoShare.updateOutcomesSubmisson(requests, oldMap);
		Test.stopTest();

		gFRS_Tasks__c retrievedTask = [SELECT Id, Status__c FROM gFRS_Tasks__c LIMIT 1];

		System.assertEquals(gFRS_Util.TASK_ONGOING ,retrievedTask.Status__c);
	}

	static testMethod void updateOutcomesSubmissonSecTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertIMEDMembershipRequest();

		GFRS_Funding_Request__c fundingRequest = [SELECT Id, Record_Type_Name__c, Outcomes_Submission_Status__c FROM GFRS_Funding_Request__c
		WHERE Record_Type_Name__c =: gFRS_Util.TYPE_IMED LIMIT 1];
		gFRS_Util_NoShare.createTask('Not Started', 'Test Subject', null, fundingRequest.id, null, 'Outcomes');
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(fundingRequest.Id, fundingRequest);
		fundingRequest.Outcomes_Submission_Status__c = 'Partial Outcomes';
		requests.add(fundingRequest);

		System.debug('ID OF FUNDING: ' + fundingRequest.Record_Type_Name__c);
		Test.startTest();
		gFRS_Util_NoShare.updateOutcomesSubmisson(requests);
		Test.stopTest();

		gFRS_Tasks__c retrievedTask = [SELECT Id, Status__c FROM gFRS_Tasks__c LIMIT 1];

		System.assertEquals(gFRS_Util.TASK_ONGOING ,retrievedTask.Status__c);
	}

	static testMethod void updateSubstatusOnProgramDatesChangeTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertIMEDMembershipRequest();
		ts.insertPhilanthropicRequest();

		GFRS_Funding_Request__c newRequest = [SELECT Id, Record_Type_Name__c, Program_End_Date_max__c, Outcomes_Submission_Status__c, Last_Live_Program_End_Date__c
		FROM GFRS_Funding_Request__c
		WHERE Record_Type_Name__c =: gFRS_Util.TYPE_IMED LIMIT 1];
		GFRS_Funding_Request__c oldRequest = [SELECT Id, Record_Type_Name__c, Program_End_Date_max__c, Outcomes_Submission_Status__c, Last_Live_Program_End_Date__c
		FROM GFRS_Funding_Request__c
		WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC LIMIT 1];

		GFRS_Program__c programNew = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, newRequest, 3, 'test1234');
		programNew.End_Date__c = Date.today();
		insert programNew;

		GFRS_Program__c programOld = gFRS_TestCreationUtils.createProgram('Live', gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE, oldRequest, 3, 'test1234');
		programOld.End_Date__c = Date.today().addDays(1);
		insert programOld;

		GFRS_Funding_Request__c requestNewAfterUpdate = [SELECT Id, Record_Type_Name__c, Sub_Status__c, Program_End_Date_max__c, Outcomes_Submission_Status__c, Last_Live_Program_End_Date__c
		FROM GFRS_Funding_Request__c
		WHERE Record_Type_Name__c =: gFRS_Util.TYPE_IMED AND Id =: newRequest.Id LIMIT 1];
		GFRS_Funding_Request__c requestOldAfterUpdate = [SELECT Id, Record_Type_Name__c, Sub_Status__c, Program_End_Date_max__c, Outcomes_Submission_Status__c, Last_Live_Program_End_Date__c
		FROM GFRS_Funding_Request__c
		WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC LIMIT 1];

		System.debug('NEW REQUEST END DATE: ' + requestNewAfterUpdate.Program_End_Date_max__c + ', ' + requestOldAfterUpdate.Program_End_Date_max__c);

		gFRS_Util_NoShare.createTask('Not Started', 'Test Subject', null, requestNewAfterUpdate.id, null, GFRS_Util.TASK_RECONCILIATION);
		GFRS_Funding_Request__c[] requests = new GFRS_Funding_Request__c[]{};
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c> {};
		oldMap.put(requestOldAfterUpdate.Id, requestOldAfterUpdate);
		requests.add(requestNewAfterUpdate);
		Test.startTest();
		gFRS_Util_NoShare.updateSubstatusOnProgramDatesChange(requests, oldMap);
		Test.stopTest();

		gFRS_Tasks__c retrievedTask = [SELECT Id, Status__c FROM gFRS_Tasks__c LIMIT 1];
	}

	static testMethod void addSharingForChangedApproversTest() {
		TestSettings ts = new TestSettings();
		ts.setupData();
		ts.setupSuperUser();
		ts.insertPhilanthropicRequest();
		GFRS_Funding_Request__c fundingRequest = [
				SELECT Id,Name, Record_Type_Name__c, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c, Requested_Amount__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c,Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];
		GFRS_Funding_Request__c oldRequest = [
				SELECT Id,Name, Record_Type_Name__c, Status__c, Sub_Status__c, Sunshine_Act_Disclosure_Submitted__c, Foundation_Classified__c, Foundation_Eligible__c, Requested_Amount__c,
						Business_Approver_Decision__c, Business_Approver_Decision_Date__c,Legal_Reviewer_1__c,Students_of_Color_Scholarships__c, Hunger__c, Pediatric_Cancer_Assistance__c, Basic_Research_Fellow__c
				FROM GFRS_Funding_Request__c
				WHERE Record_Type_Name__c =: gFRS_Util.TYPE_PHILANTHROPIC
				LIMIT 1
		];

		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>{};
		Map<Id, GFRS_Funding_Request__c> newMap = new Map<Id, GFRS_Funding_Request__c>{};
		oldRequest.GC_Review_Decision_Date__c = Date.today().addDays(1);
		oldMap.put(oldRequest.Id, oldRequest);
		fundingRequest.Foundation_Eligible__c = 'Yes';
		newMap.put(fundingRequest.Id, fundingRequest);

		Test.startTest();
		gFRS_Util_NoShare.addSharingForChangedApprovers(newMap, oldMap);
		Test.stopTest();
	}

	public static gFRS_Payment_History__c createPaymentHistory(GFRS_Funding_Request__c objRequest) {
		GFRS_WBS_Codes__c wbsCodes = gFRS_TestCreationUtils.createWBSCode('testIMED_A', 'Asthma', gFRS_Util.TYPE_IMED_NAME);
		insert wbsCodes;
		GFRS_Cost_Center_Code__c costCenterCode = gFRS_TestCreationUtils.createCostCenter('testIMED', gFRS_Util.TYPE_IMED_NAME);
		insert costCenterCode;

		gFRS_Payment_History__c paymentHistory = new gFRS_Payment_History__c();
		paymentHistory.Grant__c = objRequest.Id;
		paymentHistory.WBS_Code__c = wbsCodes.Id;
		paymentHistory.Cost_Center__c = costCenterCode.Id;
		paymentHistory.Amount__c = 100;
		insert paymentHistory;
		return paymentHistory;
	}
}