@isTest
private class EDM_PTD_List_View_Controller_Test{

	public static testMethod void initAllModeTest(){

		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);

		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		PageReference pr = ctrl.init();
		System.assertEquals(null,pr);
		System.assert(!ctrl.getIsInSingleExeSumPageMode());
		System.assertEquals(1,ctrl.recordsCount);
	}

	public static testMethod void initSingleModeTest(){

		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);

		ApexPages.currentPage().getParameters().put('parentExeSumId',exeSumIABP.Id);
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		PageReference pr = ctrl.init();
		System.assertEquals(null,pr);
		System.assert(ctrl.getIsInSingleExeSumPageMode());
		System.assertEquals(1,ctrl.recordsCount);
		System.assertEquals(exeSumIABP.Id,ctrl.parentExeSumId);
	}

	public static testMethod void initSingleModeWithParentExeSumTest(){

		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);

		ApexPages.currentPage().getParameters().put('parentExeSumByIABPId',parentIABP.Id);
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		PageReference pr = ctrl.init();
		System.assertEquals(null,pr);
		System.assert(ctrl.getIsInSingleExeSumPageMode());
		System.assertEquals(1,ctrl.recordsCount);
		System.assertEquals(exeSumIABP.Id,ctrl.parentExeSumId);
	}

	public static testMethod void saveAndGoBackTest(){

		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);

		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		ctrl.init();

		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
		PageReference pr = ctrl.saveAndGoBack();
		System.assertEquals('www.google.com',pr.getUrl());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('PTD has been saved.'));
	}

	public static testMethod void saveAndGoBackTest2(){

		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, true);


		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		ctrl.init();

		PageReference pr = ctrl.saveAndGoBack();
		System.assertEquals(null,pr);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Document must be uploaded before completing item.'));
	}

	public static testMethod void saveAndGoBackTest3(){

		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);

		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		ctrl.init();
		ctrl.pageNumber = 2;
		PageReference pr = ctrl.saveAndGoBack();
		System.assertEquals('/apex/EDM_PTD_List_View',pr.getUrl());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('PTD has been saved.'));
		ctrl.setCtrlVariable();
	}

	public static testMethod void retrievePTDsTest(){

		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);

		ApexPages.currentPage().getParameters().put('parentExeSumByIABPId',parentIABP.Id);
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		ctrl.init();
		PageReference pr = ctrl.retrievePTDsAndStayOnTheSamePage();

		System.assertEquals(null,pr);
		System.assertEquals(1,ctrl.getPTDs().size());
	}

	public static testMethod void absUserTest(){

		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABS)];
		Profile p_AB_Man = [Select Id From Profile Where Name = 'GNE-TLS-Manager'];
		User u = new User(
			FirstName = 'Manager',
			ProfileId = p_AB_Man.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u;

		User userToShareWith = new User(
			FirstName = 'testUser',
			ProfileId = p_AB_Man.Id,
			Username = 'c@roche.com',
			LastName = 'Test', 
			Email = 'c@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert userToShareWith;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
			psa.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps[0].Id));
			insert psa;
		

        System.runAs(u){
        	EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();
        	
			System.assert(ctrl.getIsAbsUser());
        }
	}

	public static testMethod void ablUserTest(){

		List<User> users = EDM_ABM_Utils.getUsersForRoles(new List<String> {EDM_ABM_Utils.ABLEAD, EDM_ABM_Utils.VDST_ABM});
		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABLEAD)];
		Profile p_AB_Admin = [Select Id From Profile Where Name = 'GNE-TLS-SpeakerBureauLead'];
		User u2 = new User(
			FirstName = 'ABLEAD',
			ProfileId = p_AB_Admin.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u2;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
		psa.add(new PermissionSetAssignment(AssigneeId = u2.Id, PermissionSetId = ps[0].Id));
		insert psa;

		System.runAs(u2){
			EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();
        	
			System.assert(ctrl.getIsAblUser());
			System.assertEquals(users.size()+1,ctrl.getABPlanners().size());
		}
	}

	public static testMethod void getIsTabEntryTest(){

		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();
		System.assertEquals(false,ctrl.getIsTabEntry());
	}

	public static testMethod void getIsTabEntryTest2(){

		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();
		System.assertEquals(true,ctrl.getIsTabEntry());
	}

	public static testMethod void listOptionsTest() {

		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 200, false);

		ApexPages.currentPage().getParameters().put('parentExeSumByIABPId',parentIABP.Id);
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		ctrl.init();
		
		System.assertEquals(4,ctrl.countPageNumbers());
		System.assert(ctrl.hasNext);
		System.assert(!ctrl.hasPrevious);
		System.assertEquals(1,ctrl.pageNumber);
		ctrl.nextPage();
		System.assert(ctrl.hasNext);
		System.assert(ctrl.hasPrevious);
		System.assertEquals(2,ctrl.pageNumber);
		ctrl.previousPage();
		System.assert(ctrl.hasNext);
		System.assert(!ctrl.hasPrevious);
		System.assertEquals(1,ctrl.pageNumber);
	}

	@isTest
	public static void shouldGetPTDSandAddOne() {
		//given
		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 200, false);
		ApexPages.currentPage().getParameters().put('parentExeSumByIABPId', parentIABP.Id);
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		//when		
		ctrl.init();
		
		//then
		System.assertEquals(200,EDM_PTD_List_View_Controller.getPullThroughDocumentationCount(exeSumIABP.Id));

		//when
		ctrl.addPullThroughDocumentation();

		//then
		System.assertEquals(201,EDM_PTD_List_View_Controller.getPullThroughDocumentationCount(exeSumIABP.Id));


		//coverage
		PageReference pr = ctrl.cancelPullThroughDocumentation();
		System.assertEquals(null,pr);
	}

	@isTest
	public static void shouldLoadRevisedDueDateComments() {
		//given
		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);
		EDM_Comment_gne__c newComment = new EDM_Comment_gne__c(EDM_Parent_Attachment_gne__c = attList[0].Id, EDM_Body_gne__c = 'Test');
		insert newComment;
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();

		//when
		ctrl.init();

		//then
		System.assertEquals(1, ctrl.commentsByParentId.size());

	}

	@isTest
	public static void shouldSaveRevisedDueDateComments() {
		//given
		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);
		EDM_Comment_gne__c newComment = new EDM_Comment_gne__c(EDM_Parent_Attachment_gne__c = attList[0].Id, EDM_Body_gne__c = 'Test');
		insert newComment;
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();
		ctrl.init();

		//when
		ctrl.newDueDateComment.parentId = attList[0].Id;
		ctrl.newDueDateComment.comment = 'new comment';
		ctrl.newDueDateComment.save();

		//then
		System.assertEquals(2, ctrl.commentsByParentId.get(attList[0].Id).size());

	}

	@isTest
	public static void generateCoverage() {
		EDM_AABP_gne__c testAABP = createAABP();
		EDM_IABP_gne__c parentIABP = createIABP(testAABP.Id);
		EDM_IABP_gne__c exeSumIABP = createExeSum(testAABP.Id, parentIABP.Id);
		List<EDM_Attachment_gne__c> attList = createPTDs(exeSumIABP.Id, 1, false);
		EDM_PTD_List_View_Controller ctrl = new EDM_PTD_List_View_Controller();
		ctrl.filterBy = 'AlaMakota';
		ctrl.init();
		ctrl.exportToExcel();
		ctrl.sortByColumn();
		ctrl.filter();
		Integer i = ctrl.PULLTHROUGHDOCUMENTATION_LIMIT;
		Id someId = ctrl.attachmentIdToUpload;

	}

	private static EDM_AABP_gne__c createAABP() {
		User usr = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		EDM_AABP_gne__c newAabp = EDM_ABM_Test_Utils.getTestAABP('GROUP', usr, usr);
		insert newAabp;
		return newAabp;
	}

	private static EDM_IABP_gne__c createIABP(Id parentAABP) {
		return createGenericIABP(false, parentAABP, null);
	}

	private static EDM_IABP_gne__c createExeSum(Id parentAABP, Id parentIABP) {
		return createGenericIABP(true, parentAABP, parentIABP);
	}

	private static EDM_IABP_gne__c createGenericIABP(Boolean isExeSum, Id parentAABP, Id parentIABP) {
		EDM_IABP_gne__c newIabp = new EDM_IABP_gne__c();
		newIabp.EDM_Type_of_Event_gne__c = 'CAB';
		newIabp.EDM_Executive_Summary_gne__c = isExeSum;
		newIabp.EDM_Meeting_Approach_gne__c = 'iAdvise';
		newIabp.EDM_Estimated_Quarter_gne__c = 'Q1';
		newIabp.EDM_Start_Date_gne__c = Date.today();
		newIabp.EDM_End_Date_gne__c = Date.today();
		newIabp.EDM_Meeting_Date_gne__c = Date.today();
		newIabp.EDM_IABP_Version_gne__c = 0;
		List<User> ablead = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
		if (ablead.size() > 0) {
			newIabp.EDM_Primary_AB_Lead_gne__c = ablead[0].Id;
		}
		newIabp.EDM_Parent_AABP_gne__c = parentAABP;
		newIabp.EDM_Parent_IABP_gne__c = parentIABP;
		newIabp.EDM_Strategic_Context_gne__c = 'Context';
		newIabp.EDM_Advisor_Selection_Criteria_gne__c = 'Criteria';
		newIabp.EDM_Advisor_Selection_Duties_gne__c = 'Duties';
		if(isExeSum) {
			newIabp.EDM_ExeSum_Finalized_gne__c = System.today();
		}
		insert newIabp;
		return newIabp;
	}

	private static EDM_IABP_gne__c getIABP() {
		return [SELECT Id, Name FROM EDM_IABP_gne__c WHERE EDM_Executive_Summary_gne__c = false LIMIT 1];
	}

	private static EDM_IABP_gne__c getExeSum() {
		return [SELECT Id, Name FROM EDM_IABP_gne__c WHERE EDM_Executive_Summary_gne__c = true LIMIT 1];
	}

	private static EDM_AABP_gne__c getAABP() {
		return [SELECT Id, Name FROM EDM_AABP_gne__c LIMIT 1];
	}

	private static List<EDM_Attachment_gne__c> createPTDs(Id parentId, Integer num, Boolean complete) {
		List<EDM_Attachment_gne__c> attList = new List<EDM_Attachment_gne__c>();
		for(Integer i = 0; i < num; i++) {
			attList.add(new EDM_Attachment_gne__c(
				EDM_Pull_Through_Doc_gne__c = true,
				EDM_Parent_IABP_gne__c = parentId,
				EDM_Complete_gne__c = complete
			));
		}
		insert attList;
		return attList;
	}
}