@isTest
private class EDM_ExeSum_Edit_Create_Ex_Test {
	private static EDM_AABP_gne__c aabp;
	private static EDM_IABP_gne__c iabp;

	private static void setCommonTestData() {
		List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();

		aabp = (EDM_AABP_gne__c)testData[0];
		iabp = (EDM_IABP_gne__c)testData[1];
	}
	
	@isTest static void shouldRedirectToErrorPageWhenIdIsIABP() {
		//given
		setCommonTestData();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', iabp.Id, iabp);

		//when
		PageReference pageRef = controller.init();

		//then
		String expectedURL = Page.GNE_SFA2_Exception_Layout.getUrl().toLowerCase();
		System.assertEquals(expectedURL, pageRef.getUrl().substringBefore('?').toLowerCase());
	}

	@isTest static void shouldRedirectToErrorPageWhenParentIdNoPassed() {
		//given
		setCommonTestData();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', iabp.Id, iabp);

		//when
		PageReference pageRef = controller.init();

		//then
		String expectedURL = Page.GNE_SFA2_Exception_Layout.getUrl().toLowerCase();
		System.assertEquals(expectedURL, pageRef.getUrl().substringBefore('?').toLowerCase());
	}

	private static EDM_ExeSum_Edit_Create_Ex prapereControllerForExeSumPage(String param, Id id, EDM_IABP_gne__c record) {
		return prapereControllerForExeSumPage(param, id, record, false);
	}

	private static EDM_ExeSum_Edit_Create_Ex prapereControllerForExeSumPageWithoutConfig(String param, Id id, EDM_IABP_gne__c record) {
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage(param, id, record, false);
		controller.currentExeSum = record;
		return controller;
	}

	private static EDM_ExeSum_Edit_Create_Ex prapereControllerForExeSumPage(String param, Id id, EDM_IABP_gne__c record, Boolean addRetURL) {
		PageReference currentPage = Page.EDM_ExeSum_Edit_Create;
		if (String.isNotBlank(param)) {
			currentPage.getParameters().put(param, id);
		}
		if (addRetURL) {
			currentPage.getParameters().put('retURL', 'Dummy');
		}
		Test.setCurrentPage(currentPage);

		return new EDM_ExeSum_Edit_Create_Ex(
				new ApexPages.StandardController(record));
	}

	@isTest static void shouldShowErrorPageWhenParentIdIsNoPassed() {
		//given
		EDM_IABP_gne__c exesum = new EDM_IABP_gne__c();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('', null, exesum);

		//when
		PageReference pageRef = controller.init();

		//then
		System.assertEquals(true, Apexpages.hasMessages());
	}

	@isTest static void shouldCreateExeSumAndRedirectWhenParentIdIsIABP() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		EDM_IABP_gne__c exesum = new EDM_IABP_gne__c();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('parentIABPId', iabp.Id, exesum);

		//when
		PageReference pageRef = controller.init();

		//then
		String expectedURL = Page.EDM_ExeSum_Edit_Create.getUrl();
		System.assertEquals(expectedURL.toLowerCase(), pageRef.getUrl().substringBefore('?').toLowerCase());
		System.debug(pageRef);

		List<EDM_IABP_gne__c> insertedExeSums = [SELECT Id FROM EDM_IABP_gne__c where EDM_Executive_Summary_gne__c = true];
		System.assertEquals(1, insertedExeSums.size());
	}

	@isTest static void shouldNotCreateSecondExeSum() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();

		EDM_IABP_gne__c secondExesum = new EDM_IABP_gne__c();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('parentIABPId', iabp.Id, secondExesum);

		//when
		PageReference pageRef = controller.init();

		//then
		String expectedURL = Page.EDM_ExeSum_Edit_Create.getUrl();
		System.assertEquals(expectedURL.toLowerCase(), pageRef.getUrl().substringBefore('?').toLowerCase());
		System.debug(pageRef);

		List<EDM_IABP_gne__c> insertedExeSums = [SELECT Id FROM EDM_IABP_gne__c where EDM_Executive_Summary_gne__c = true];
		System.assertEquals(1, insertedExeSums.size());
	}

	@isTest static void shouldOpenExesum() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		createConfiguration('AB-Lead', 'ABM');
		
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);

		//when
		PageReference pageRef = controller.init();

		//then
		System.assertEquals(null, pageRef);
		System.assertEquals(true, controller.getIsEditMode());
		System.assertEquals('Update ExeSum', controller.getExeSumTitle());
	}

	@isTest static void shouldSaveExesum() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		createConfiguration('AB-Lead', 'ABM');
		
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
		controller.init();

		//when
		PageReference pageRef = controller.save();

		//then
		System.assertEquals(null, pageRef);
	}

	@isTest static void shouldSaveExesumAndGoBack() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		createConfiguration('AB-Lead', 'ABM');
		
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		addMandatoryPTD(exesum.Id, null);
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
		controller.init();

		//when
		PageReference pageRef = controller.saveAndGoBack();

		//then
		System.assertEquals('/apex/EDM_AABP_Layout?id=' + aabp.Id, pageRef.getUrl());
	}

	@isTest static void shouldUpdateAndRedirectToDocuments() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		createConfiguration('AB-Lead', 'ABM');
		
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		addMandatoryPTD(exesum.Id, null);
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
		controller.init();

		//when
		PageReference pageRef = controller.updateAndRedirectToDocuments();

		//then
		System.assert(pageRef.getUrl().startsWith('/apex/EDM_Attendees_Documents?parentId=' + exesum.Id));
	}

	@isTest static void shouldCompareVersions() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		createConfiguration('AB-Lead', 'ABM');
		
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		addMandatoryPTD(exesum.Id, null);
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
		controller.init();

		//when
		PageReference pageRef = controller.compareVersions();

		//then
		System.assert(pageRef.getUrl().startsWith('/apex/EDM_IABP_Version_Compare'));
	}

	@isTest static void shouldCompareVersionsWithoutSave() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		createConfiguration('AB-Lead', 'ABM');
		
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
		controller.init();

		//when
		PageReference pageRef = controller.compareVersionsWithoutSave();

		//then
		System.assert(pageRef.getUrl().startsWith('/apex/EDM_IABP_Version_Compare'));
	}

	@isTest static void shouldSubmitToAbs() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		createConfiguration('AB-Lead', 'ABM');
		
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		addMandatoryPTD(exesum.Id, null);
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
		
		List<EDM_Question_gne__c> questions = insertTestQuestions();
		insertTestQuestionResponse(exesum.Id, questions[0].Id);
		
		controller.init();

		//when
		PageReference pageRef = controller.submitToAbs();

		//then
		List<EDM_IABP_gne__c> insertedExeSums = [SELECT Id FROM EDM_IABP_gne__c where EDM_Historical_gne__c = false AND EDM_ExeSum_Status_gne__c = 'In Review'];
		System.assertEquals(1, insertedExeSums.size());
		System.assertEquals('Review ExeSum', controller.getExeSumTitle());
	}

	@isTest static void shouldReturnToABLead() {
		//Can't assign permission set to this user, user license doesn't match
		//assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABS);
		User absUser = EDM_ABM_Test_Utils.getABSes()[0];
		System.runAs(absUser) {
			//given
			setCommonTestData();
			createConfiguration('AB-Lead', 'ABM');
			
			EDM_IABP_gne__c exesum = insertNewExeSumRecord();
			addMandatoryPTD(exesum.Id, null);
			EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum, true);
			
			List<EDM_Question_gne__c> questions = insertTestQuestions();
			insertTestQuestionResponse(exesum.Id, questions[0].Id);
			
			controller.init();

			//when
			PageReference pageRef = controller.returnToABLead();

			//then
			List<EDM_IABP_gne__c> insertedExeSums = [SELECT Id FROM EDM_IABP_gne__c where EDM_ExeSum_Status_gne__c = 'Started'];
			System.assertEquals(1, insertedExeSums.size());
		}
	}

	@isTest static void shouldFinalizeExesumWhenFeedbackDataisAllAnswered() {
		//Can't assign permission set to this user, user license doesn't match
		//assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABS);
		User absUser = EDM_ABM_Test_Utils.getABSes()[0];
		System.runAs(absUser) {

			//given
			setCommonTestData();
			
			createConfiguration('ABS-Manager', 'ABM');
			
			EDM_IABP_gne__c exesum = insertNewExeSumRecord();
			addMandatoryPTD(exesum.Id, 'PTD_Snapshot');

			EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
			
			List<EDM_Question_gne__c> questions = insertTestQuestions();
			insertTestQuestionResponse(exesum.Id, questions[0].Id);
			controller.init();

			//when
			PageReference pageRef = controller.finalizeExecutiveSummary();

			//then
			System.assertEquals(null, pageRef);
			System.assertEquals('View ExeSum', controller.getExeSumTitle());

			List<EDM_IABP_gne__c> insertedExeSums = [SELECT Id FROM EDM_IABP_gne__c where EDM_ExeSum_Status_gne__c = 'Finalized'];
			System.assertEquals(1, insertedExeSums.size());
		}
	}

	@isTest static void shouldRemoveAllCommentWhenFinalize() {
		//Can't assign permission set to this user, user license doesn't match
		//assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABS);
		User absUser = EDM_ABM_Test_Utils.getABSes()[0];
		User ablUser = EDM_ABM_Test_Utils.getABLs()[0];
		System.runAs(absUser) {

			//given
			setCommonTestData();
			
			createConfiguration('ABS-Manager', 'ABM');
			
			EDM_IABP_gne__c exesum = insertNewExeSumRecord();

			EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
			
			controller.init();
			insertTestCommentsAsDifferentUser(exesum.Id, ablUser);

			//when
			PageReference pageRef = controller.finalizeExecutiveSummary();

			//then
			List<EDM_Comment_gne__c> commentShouldBeDeleted = [SELECT Id FROM EDM_Comment_gne__c WHERE EDM_Parent_IABP_gne__c = :exesum.Id];
			System.assertEquals(0, commentShouldBeDeleted.size());
		}
	}

	private static void insertTestCommentsAsDifferentUser(Id exesumId, User user2) {
		EDM_ABM_Utils.setSharing(exesumId, new Set<Id> {user2.Id}, EDM_ABM_Utils.ABLEAD);
		System.runAs(user2) {
			List<EDM_Comment_gne__c> comments = new List<EDM_Comment_gne__c> {
				new EDM_Comment_gne__c (EDM_Parent_IABP_gne__c = exesumId),
				new EDM_Comment_gne__c (EDM_Parent_IABP_gne__c = exesumId)};
			insert comments;
		}
	}

	@isTest static void shouldHavePossibleAnswers() {
		//given
		EDM_ExeSum_Edit_Create_Ex.Questionnaire feedbackResponses = new EDM_ExeSum_Edit_Create_Ex.Questionnaire(null, 'Feedback Responses');
		EDM_ExeSum_Edit_Create_Ex.Questionnaire aBSAudit = new EDM_ExeSum_Edit_Create_Ex.Questionnaire(null, 'ABS Audit');

		//when

		//then
		System.assert(feedbackResponses.possibleAnswer.size() > 0);
		System.assert(aBSAudit.possibleAnswer.size() > 0);
	}

	@isTest static void shouldShareExeSum() {
		//given
		setCommonTestData();
		assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABLEAD);
		createConfiguration('AB-Lead', 'ABM');
		
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('Id', exesum.Id, exesum);
		controller.init();

		System.assertEquals(0, controller.UsersSharedWith.size());
		System.assertNotEquals(0, controller.UsersToShareWith.size());
		controller.UsersSharedWith.add(controller.UsersToShareWith.get(0));

		//when
		controller.shareExeSum();

		//then
		System.assertEquals(1, EDM_ABM_Utils.populateSharedWith(exesum.Id, EDM_ABM_Utils.ABLEAD).size());
	}

	private static void assignPermissionSet(Id userId, String permissionSetName) {
		System.runAs(new User(Id = Userinfo.getUserId())) {
			PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = :permissionSetName];
			list <PermissionSetAssignment> PSAssignments = new list <PermissionSetAssignment>();
			List<User> users = [SELECT ID, (Select ID FROM PermissionSetAssignments WHERE PermissionSetID = :ps.id) FROM User WHERE Id = :userId];
			
			for (User u : users) {
				if (u.PermissionSetAssignments.size() == 0) 
					PSAssignments.add( new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.ID ) );
			}

			if (!PSAssignments.isEmpty()) {
				insert PSAssignments;
			}
		}
	}

	private static EDM_IABP_gne__c insertNewExeSumRecord() {
		EDM_IABP_gne__c exeSum = getNewExeSumRecord();
		insert exeSum;
		return exeSum;
	}

	private static EDM_IABP_gne__c getNewExeSumRecord() {
		return new EDM_IABP_gne__c(
				EDM_Executive_Summary_gne__c = true,
				EDM_Parent_AABP_gne__c = aabp.Id,
				EDM_Parent_IABP_gne__c = iabp.Id,
				EDM_Type_of_Event_gne__c = 'Dummy',
				EDM_IABP_Version_gne__c = 1,
				EDM_ABS_Manager_gne__c = UserInfo.getUserId(),
				RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ExeSum' LIMIT 1].Id);
	}

	private static List<EDM_Question_gne__c> insertTestQuestions() {
		List<EDM_Question_gne__c> questions = new List<EDM_Question_gne__c> {
			new EDM_Question_gne__c(EDM_Value_gne__c = 'Dummy Question 1?', EDM_Type_gne__c = 'Feedback Responses'),
			new EDM_Question_gne__c(EDM_Value_gne__c = 'Dummy Question 2?', EDM_Type_gne__c = 'ABS Audit')
		};

		insert questions;
		return questions;
	}

	private static void insertTestQuestionResponse(Id exeSumId, Id questionId) {
		insert new EDM_Response_gne__c (
				EDM_Question_gne__c = questionId,
				EDM_Parent_Exe_Summary_gne__c = exeSumId,
				EDM_Response_gne__c = 'Dummy'
				);
	}

	private static void createConfiguration(String role, String appType) {
		insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = appType, Role_gne__c = role, Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

		List<String> recordTypes = new String[]{ 'ExeSum' };

		List<SFA2_Configuration_Object_gne__c> configurationObjects = new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> eventDetailsList 	= new List<SFA2_Configuration_Object_gne__c>();
			
		Integer ord = 0;
		
		for (String recType : recordTypes) {
			ord = 0;
				
			SFA2_Configuration_Object_gne__c eventDetails = new SFA2_Configuration_Object_gne__c(
				Name = 'EDM_IABP_gne__c_detail',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Event Details',
				Attributes_gne__c = ''
			);
			eventDetailsList.add(eventDetails);
			configurationObjects.add(eventDetails);
		}

		for (SFA2_Configuration_Object_gne__c confObj : configurationObjects) {
				confObj.Application_Type__c 			= appType;
				confObj.Role_gne__c  					= role;
				confObj.Object_Name_gne__c  			= 'EDM_IABP_gne__c';
				confObj.Configuration_Type_gne__c 		= 'Page';
				confObj.Is_Active_gne__c  				= true;
				confObj.OTR2_gne__c  					= false;
		}

		insert configurationObjects;
			
		List<SFA2_Configuration_Object_Detail_gne__c> configurationObjectDetails = new List<SFA2_Configuration_Object_Detail_gne__c>();
		List<String> fields = new List<String> {
			'EDM_Joint_AABP_gne__c'
		};
			
		for (SFA2_Configuration_Object_gne__c evtDetail : eventDetailsList) {
			ord = 0;
			for (String field : fields) {
				configurationObjectDetails.add(
					new SFA2_Configuration_Object_Detail_gne__c(
						Configuration_Object_ref_gne__c = evtDetail.Id,
						Order_gne__c 				= ord++,
						Label_gne__c 				= field,
						API_Name_gne__c 			= field,
						Name 						= field,
						Availability_Mode_gne__c 	= 'New;Edit;View',
						Type_gne__c 				= 'Field',
						Is_Required_gne__c 			= false,
						Is_Read_Only_gne__c 		= false
					)
				);
			}
		}
		
		for (SFA2_Configuration_Object_Detail_gne__c det : configurationObjectDetails) {
			det.OTR2_gne__c = false;
			det.Is_Active_gne__c = true;
		}
			
		insert configurationObjectDetails;
	}

	@isTest static void shouldDisplayDocumentsToDownload() {
		//given
		setCommonTestData();
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPageWithoutConfig('Id', exesum.Id, exesum);

		//when
		List<SelectOption> results = controller.getDownloadDocumentIds();
		controller.startDownloadDocuments();
		controller.closeDownloadDocuments();

		//then
		System.assertEquals(3, results.size());
	}

	@isTest static void shouldPrepareURLParamWhenAgendaSourceIsExeSum() {
		//given
		setCommonTestData();
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPageWithoutConfig('Id', exesum.Id, exesum);

		String expectedURLParam = prepareTestDataAgenda(exesum.Id, 'Final Agenda', null);

		controller.downloadDocumentId = exesum.Id;
		exesum.EDM_ExeSum_Final_Agenda_Source_gne__c = 'ExeSum';

		//when
		String result = controller.getAttachAgendaParam();

		//then
		System.assertEquals(expectedURLParam, result);
	}

	@isTest static void shouldPrepareURLParamWhenAgendaSourceIsIABP() {
		//given
		setCommonTestData();
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPageWithoutConfig('Id', exesum.Id, exesum);

		String expectedURLParam = prepareTestDataAgenda(iabp.Id, null, 'Agenda');

		controller.downloadDocumentId = exesum.Id;
		exesum.EDM_ExeSum_Final_Agenda_Source_gne__c = 'IABP';

		//when
		String result = controller.getAttachAgendaParam();

		//then
		System.assertEquals(expectedURLParam, result);
	}

	private static String prepareTestDataAgenda(Id sourceId, String systemType, String type) {

		EDM_Attachment_gne__c edmAttach = new EDM_Attachment_gne__c(
				EDM_Parent_IABP_gne__c = sourceId,
				EDM_Document_Name_gne__c = 'Test',
				EDM_System_Type_gne__c = systemType,
				EDM_Type_gne__c = type);
		insert edmAttach;

		Attachment agenda = getTestAttachment(edmAttach.Id);
		insert agenda;

		return '&ParentIds=' + edmAttach.Id + '&AttachIds=' + agenda.Id;
	}

	private static Attachment getTestAttachment(Id parentId) {
		return new Attachment(
			Name = 'testAttachment',
			Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64'),
			ParentId = parentId);
	}

	@isTest static void shouldGetPullThroughDocumentation() {
		//given
		setCommonTestData();
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPageWithoutConfig('Id', exesum.Id, exesum);

		Integer expectedCount = prepareTestPullThroughDocumentation(exesum.Id);

		//when
		List<EDM_Attachment_gne__c> results = controller.getPullThroughDocumentation();
		Integer countReturnedByRA = EDM_ExeSum_Edit_Create_Ex.getPullThroughDocumentationCount(exesum.Id, false);

		//then
		System.assertEquals(expectedCount, results.size());
		System.assertEquals(expectedCount, countReturnedByRA);
	}


	private static Integer prepareTestPullThroughDocumentation(Id sourceId) {
		List<EDM_Attachment_gne__c> edmAttachs = new List<EDM_Attachment_gne__c>();

		for (Integer quaterNo = 1; quaterNo <= 4; quaterNo++) {
			edmAttachs.add(new EDM_Attachment_gne__c(
					EDM_Parent_IABP_gne__c = sourceId,
					EDM_Year_gne__c = '2015',
					EDM_Estimated_Quarter_gne__c = 'Q' + quaterNo,
					EDM_Pull_Through_Doc_gne__c = true
				));
		}

		insert edmAttachs;


		return edmAttachs.size();
	}

	@isTest static void shouldConvertQuestionsToSessionsForiAdviseIABP() {
		//Can't assign permission set to this user, user license doesn't match
		//assignPermissionSet(UserInfo.getUserId(), EDM_ABM_Utils.ABS);
		User absUser = EDM_ABM_Test_Utils.getABSes()[0];
		System.runAs(absUser) {
			//given
			setCommonTestData();
			iabp.EDM_Meeting_Approach_gne__c = 'iAdvise';
			update iabp;

			insert new EDM_Question_gne__c (
				EDM_Parent_Exe_Summary_gne__c = iabp.id,
				EDM_Value_gne__c = '0123456789'.repeat(30),
				EDM_Type_gne__c = 'Advisory Board');

			EDM_IABP_gne__c exesum = new EDM_IABP_gne__c();
			EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPage('parentIABPId', iabp.Id, exesum);

			//when
			PageReference pageRef = controller.init();

			//then
			String expectedURL = Page.EDM_ExeSum_Edit_Create.getUrl();
			System.assertEquals(expectedURL.toLowerCase(), pageRef.getUrl().substringBefore('?').toLowerCase());
			System.debug(pageRef);

			List<EDM_IABP_gne__c> insertedExeSums = [SELECT Id FROM EDM_IABP_gne__c where EDM_Executive_Summary_gne__c = true];
			System.assertEquals(1, insertedExeSums.size());
		}
	}

	@isTest
	public static void doSomeButtonClicksCoverage() {
		setCommonTestData();
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		EDM_ExeSum_Edit_Create_Ex controller = prapereControllerForExeSumPageWithoutConfig('Id', exesum.Id, exesum);
		prepareTestPullThroughDocumentation(exesum.Id);
		List<EDM_Attachment_gne__c> ptds = [SELECT Id, EDM_Year_gne__c, EDM_Estimated_Quarter_gne__c, EDM_ID_For_Comparator_gne__c FROM EDM_Attachment_gne__c];

		controller.viewDocuments();

		controller.PTDIdToEdit = ptds[0].Id;
		controller.editPullThroughDocumentation();

		controller.cancelPullThroughDocumentation();

		controller.newPullThroughDocumentation = ptds[0];
		controller.addPullThroughDocumentation();
		
		controller.PTDIdToRemove = ptds[0].Id;
		controller.delPullThroughDocumentation();

		controller.getFinalAgendaAttach();
		controller.updateAttendeesWithoutSave();
	}

	private static void addMandatoryPTD(Id parentId, String systemType) {
		EDM_Attachment_gne__c ptdDoc = new EDM_Attachment_gne__c();
		ptdDoc.EDM_Parent_IABP_gne__c = parentId;
		ptdDoc.EDM_Pull_Through_Doc_gne__c = true;
		ptdDoc.EDM_System_Type_gne__c = systemType;
		insert ptdDoc;
	}
}