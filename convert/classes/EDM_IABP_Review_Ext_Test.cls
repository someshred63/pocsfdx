@istest
private class EDM_IABP_Review_Ext_Test{
	private static EDM_AABP_gne__c aabp;
	private static EDM_IABP_gne__c iabp;
	private static ApexPages.StandardController sc;
	private static EDM_IABP_Review_Ext ext;

	private static void setCommonTestData() {
		List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();

		aabp = (EDM_AABP_gne__c)testData[0];
		iabp = (EDM_IABP_gne__c)testData[1];

		List<User> shareWith = [SELECT Id, Name, IsActive FROM User WHERE Id IN (:aabp.EDM_AB_Lead_gne__c, :aabp.EDM_Vendor_Lead_gne__c)];
		shareWith.addAll(EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS));
		EDM_ABM_Utils.shareRecord(aabp.Id, shareWith, EDM_ABM_Utils.AL_EDIT, EDM_ABM_Utils.SHARE_DIRECT);
	}

	private static void setControllers() {
		sc = new ApexPages.StandardController(iabp);
		ext = new EDM_IABP_Review_Ext(sc);
	}

	private static EDM_IABP_gne__c getRefreshedIABP(Id id) {
		List<String> extraFields = new List<String>
						{
							'EDM_Primary_AB_Lead_gne__r.Name',
							'EDM_Secondary_AB_Lead_gne__r.Name',
							'EDM_Third_AB_Lead_gne__r.Name',
							'EDM_Admin_gne__r.Name',
							'EDM_Primary_Vendor_Lead_gne__r.Name',
							'EDM_Second_Vendor_Lead_gne__r.Name'
						};
		return (EDM_IABP_gne__c)Database.query(EDM_ABM_Utils.getAllFieldsSOQL('EDM_IABP_gne__c', 'Id =\'' + id + '\'', extraFields));
	}

	private static User getABSForAABP() {
		return [SELECT Id, Name FROM User WHERE Id = :aabp.EDM_ABS_Manager_gne__c];
	}

	public static testMethod void initExeSumTest(){
		//given
		setCommonTestData();
		iabp.EDM_Executive_Summary_gne__c = true;
		update iabp;
		setControllers();		

		//when
		PageReference pr = ext.init();

		//then
		System.assertEquals('/apex/EDM_ExeSum_Edit_Create?id=' + iabp.Id, pr.getUrl());
	}

	public static testMethod void initIABPNoConfigTest(){
		setCommonTestData();
		setControllers();

		PageReference pr = ext.init();
		System.assertEquals('/apex/GNE_SFA2_Exception_Layout?exMessage=Layout+configuration+records+not+found.',pr.getUrl());
	}

	public static testMethod void shareIABPTest(){

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

        	insert new EDM_Notifications_gne__c(
				Name = 'Default',
				Escalation_Address_gne__c = 'test@gmail.com',
				Test_CC_Address_gne__c = 'test@gmail.com'
			);

        	List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();

			aabp = (EDM_AABP_gne__c)testData[0];
			iabp = (EDM_IABP_gne__c)testData[1];

			EDM_IABP_gne__c exeSumIABP = new EDM_IABP_gne__c(
				EDM_Parent_AABP_gne__c = aabp.Id,
				EDM_Parent_IABP_gne__c = iabp.Id,
				EDM_Executive_Summary_gne__c = true,
				EDM_Type_of_Event_gne__c = 'test event type',
				EDM_IABP_Version_gne__c = 199
			);
			insert exeSumIABP;

			setControllers();

			System.assertEquals(true,ext.getIsUserABS());

			PageReference pr = ext.shareIABP();
			System.assertEquals(null, pr);

			System.assertEquals(2,[Select Id From EDM_IABP_gne__Share].size(),ext.UsersSharedWith);
        }
	}

	public static testMethod void sendForApprovalNoApproversTest(){
		setCommonTestData();
		setControllers();

		System.assert(!ext.getIsUserApprover());

		PageReference pr = ext.sendForApproval();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1, msgs.size());
		System.assert(msgs[0].getDetail().contains('At least one Approver needs to be selected.'));
	}

	@isTest public static void shouldSetStatusToSubmittedWhenSendForApproval() {
		//given
		setCommonTestData();
		User abs = getABSForAABP();
		List<User> approvers = EDM_ABM_Test_Utils.getApprovers();		
		iabp.EDM_Approver_1_gne__c = approvers[0].Id;
		update iabp;		

		System.runAs(abs) {
			setControllers();
			//when
			ext.sendForApproval();
			//then
			iabp = getRefreshedIABP(iabp.Id);
			System.assertEquals('Submitted', iabp.EDM_Approval_Status_gne__c);
			System.assertEquals(null, iabp.EDM_Approval_Request_Comment_gne__c);
			System.assertEquals(Date.today(), iabp.EDM_Version_Validated_gne__c);
		}
	}

	@isTest public static void shouldBeApprovedByOneApprover() {
		shouldBeApprovedByNApprovers(1);
	}

	@isTest public static void shouldBeApprovedByTwoApprovers() {
		shouldBeApprovedByNApprovers(2);
	}

	@isTest public static void shouldBeApprovedByThreeApprovers() {
		shouldBeApprovedByNApprovers(3);
	}

	@isTest public static void shouldBeApprovedByFourApprovers() {
		shouldBeApprovedByNApprovers(4);
	}

	@isTest public static void shouldBeApprovedByFiveApprovers() {
		shouldBeApprovedByNApprovers(5);
	}

	private static void shouldBeApprovedByNApprovers(Integer numberOfApprovers) {
		//given
		setCommonTestData();
		User abs = getABSForAABP();
		List<User> approvers = EDM_ABM_Test_Utils.getApprovers();
		sendForApproval(numberOfApprovers, abs, approvers);

		//when
		Test.startTest();		
		approveByGivenNumberOfApprovers(numberOfApprovers, approvers);
		Test.stopTest();

		//then 
		iabp = getRefreshedIABP(iabp.Id);
		assertIfApprovedForGivenNumberOfApprovers(numberOfApprovers, approvers);
	}

	private static void sendForApproval(Integer numberOfApprovers, User abs, List<User> approvers) {
		for (Integer i = 1; i <= numberOfApprovers; i++) {
			iabp.put('EDM_Approver_' + i + '_gne__c', approvers[i - 1].Id);			
		}
		update iabp;

		System.runAs(abs) {
			setControllers();
			ext.sendForApproval();			
		}		
	}

	private static void approveByGivenNumberOfApprovers(Integer numberOfApprovers, List<User> approvers) {
		for (Integer i = 1; i <= numberOfApprovers; i++) {
			System.runAs(approvers[i - 1]) {				
				setControllers();
				ext.approverSelection = 'Approve';
				ext.submitApproverResponse();				
			}
		}
	}

	private static void assertIfApprovedForGivenNumberOfApprovers(Integer numberOfApprovers, List<User> approvers) {
		for (Integer i = 1; i <= numberOfApprovers; i++) {
			String approverStatus = (String)iabp.get('EDM_Approver_' + i + '_Status_gne__c');
			System.assert(approverStatus.contains('Approved on '));
			//System.runAs(approvers[i - 1]) {
			//	setControllers();
			//	System.assert(ext.getIsUserResponded());
			//}
		}
	}	


	public static testMethod void cancelApprovalProcessTest(){
		
		User approver = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABAPPROVER)[0];
		User abs = EDM_ABM_Test_Utils.getABSes()[0];
		System.runAs(abs) {
			setCommonTestData();			
			iabp.EDM_Approver_1_gne__c = approver.Id;
			update iabp;
			setControllers();

			PageReference pr = ext.sendForApproval();
			
			iabp = [Select EDM_Approval_Status_gne__c,EDM_Approver_1_Status_gne__c,EDM_Version_Validated_gne__c,EDM_Approval_Request_Comment_gne__c From EDM_IABP_gne__c Where EDM_Approver_1_gne__c = :approver.Id Limit 1];
			System.assertEquals('Submitted', iabp.EDM_Approval_Status_gne__c);
			System.assertEquals('Sent for approval ' + Date.today().format(), iabp.EDM_Approver_1_Status_gne__c);
			System.assertEquals(null, iabp.EDM_Approval_Request_Comment_gne__c);
			System.assertEquals(Date.today(), iabp.EDM_Version_Validated_gne__c);

			pr = ext.cancelApprovalProcess();

			iabp = [Select EDM_Approval_Status_gne__c,EDM_Approver_1_Status_gne__c,EDM_Version_Validated_gne__c,EDM_Approval_Request_Comment_gne__c From EDM_IABP_gne__c Where EDM_Approver_1_gne__c = :approver.Id Limit 1];
			System.assertEquals('Canceled', iabp.EDM_Approval_Status_gne__c);
			
			System.assertEquals('/apex/EDM_IABP_Edit_Create?id=' + iabp.Id, pr.getUrl());
		}
	}

	public static testMethod void cancelApprovalProcessAlreadyCompletedTest(){		
		setCommonTestData();
		setControllers();

		PageReference pr = ext.cancelApprovalProcess();
		System.assertEquals(null, pr);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Approval Process has been already completed.'));
	}

	public static testMethod void approversTest(){

		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABAPPROVER_NO_LIC)];
		
		Set<Id> userIds = new Set<Id>();
		for(PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name IN (:EDM_ABM_Utils.ABAPPROVER,:EDM_ABM_Utils.ABAPPROVER_NO_LIC) AND Assignee.IsActive = true]){
			userIds.add(psa.AssigneeId);
		}


		Profile p_AB = [Select Id From Profile Where Name = 'GNE-TLS-ABM-Approver'];
		List<User> approvers = new List<User>();
		approvers.add(new User(
			FirstName = 'Approver1',
			ProfileId = p_AB.Id,
			Username = 'a@roche.com',
			LastName = 'Test', 
			Email = 'a@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		));
		approvers.add(new User(
			FirstName = 'Approver2',
			ProfileId = p_AB.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		));
		insert approvers;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
		psa.add(new PermissionSetAssignment(AssigneeId = approvers[0].Id, PermissionSetId = ps[0].Id));
		insert psa;

		System.runAs(approvers[0]){
			setCommonTestData();
			setControllers();

			List<SelectOption> availableApprovers = ext.getAvailableApprovers();
			
			System.assertEquals(userIds.size()+1,availableApprovers.size());

			ext.selectedApprovers.add(availableApprovers[0]);

			System.assertEquals(1,ext.selectedApprovers.size());

			ext.cancelSelectApprovers();

			System.assertEquals(0,ext.selectedApprovers.size());
		}
		
	}

	public static testMethod void goBackTest(){

		setCommonTestData();

		ApexPages.currentPage().getParameters().put('retUrl','www.google.com');
		setControllers();

		PageReference pr = ext.goBack();
		System.assertEquals('www.google.com',pr.getUrl());
	}

	public static testMethod void goBackTest2(){
		setCommonTestData();
		setControllers();

		PageReference pr = ext.goBack();
		System.assertEquals('/apex/EDM_AABP_Layout?id=' + iabp.EDM_Parent_AABP_gne__c,pr.getUrl());
	}

	public static testMethod void compareVersionsLinkTest(){
		setCommonTestData();
		EDM_IABP_gne__c compareIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = aabp.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert compareIABP;

		setControllers();

		String compareURL = '/apex/EDM_IABP_Version_Compare';
		compareURL += '?idOld=' + compareIABP.Id;
		compareURL += '&idNew=' + iabp.Id;
		compareURL += '&retURL=/apex/EDM_IABP_Edit_Create?Id=' + iabp.Id;

		ext.compareId = compareIABP.Id;
		PageReference pr = ext.compareVersions();
		System.assert(pr.getUrl().contains('/apex/EDM_IABP_Version_Compare'));
		System.assert(pr.getUrl().contains('idOld=' + compareIABP.Id));
		System.assert(pr.getUrl().contains('idNew=' + iabp.Id));
	}

	public static testMethod void totalEstimatedTest(){
		setCommonTestData();
		iabp.EDM_Est_nr_of_Attendees_gne__c = 20;
		iabp.EDM_Est_nr_of_Gne_Attendees_gne__c = 20;
		iabp.EDM_Est_nr_of_Other_Attendees_gne__c = 20;
		update iabp;

		setControllers();

		System.assertEquals(60,ext.getTotalEstimated());
	}

	public static testMethod void totalActualTest(){

		setCommonTestData();

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		ApexPages.currentPage().getParameters().put('account',a.id);
		List<EDM_Attendee_gne__c> attds = new List<EDM_Attendee_gne__c>();
		attds.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = iabp.Id,
			EDM_Account_gne__c = a.Id,
			EDM_System_Type_gne__c = 'Advisor'
		));
		attds.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = iabp.Id,
			EDM_Account_gne__c = a.Id,
			EDM_System_Type_gne__c = 'Genentech'
		));
		attds.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = iabp.Id,
			EDM_Account_gne__c = a.Id,
			EDM_System_Type_gne__c = 'Other'
		));
		insert attds;

		setControllers();

		System.assertEquals(3,ext.getTotalActual());
	}

	public static testMethod void returnToABLTest(){

		setCommonTestData();

		setControllers();

		PageReference pr = ext.returnToABL();
		System.assertEquals(null,pr);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('IABP has been sent to ABL.'));
	}

	public static testMethod void validateUpdatedIABPTest(){
		setCommonTestData();
		iabp.EDM_IABP_Version_gne__c = 199;
		update iabp;
		setControllers();

		PageReference pr = ext.validateUpdatedIABP();
		System.assertEquals(null,pr);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('IABP has been revalidated.'));

		iabp = [Select EDM_Version_Validated_gne__c,EDM_IABP_Version_gne__c,EDM_Status_gne__c 
					  From EDM_IABP_gne__c Where Id = :iabp.Id];

		System.assertEquals(Date.today(),iabp.EDM_Version_Validated_gne__c);
		System.assertEquals(200,iabp.EDM_IABP_Version_gne__c);
		System.assertEquals('IABP Approved',iabp.EDM_Status_gne__c);
	}

	public static testMethod void getBrandsTest(){

		setCommonTestData();
		iabp.EDM_Brand_gne__c = 'Brand1;Brand2;Brand3';
		update iabp;

		setControllers();

		List<String> brands = ext.getBrands();
		System.assertEquals(3,brands.size());
		System.assertEquals('Brand1',brands[0]);
		System.assertEquals('Brand2',brands[1]);
		System.assertEquals('Brand3',brands[2]);
	}
	
	public static testMethod void getDownloadDocumentIdsTest(){
		setCommonTestData();
		EDM_IABP_gne__c exeSumIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = aabp.Id,
			EDM_Parent_IABP_gne__c = iabp.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert exeSumIABP;

		EDM_ABM_Utils.createSnapshot(iabp.Id);

		setControllers();

		List<SelectOption> docs = ext.getDownloadDocumentIds();
		System.assertEquals(3, docs.size());
	}

	public static testMethod void downloadDocumentsTest(){
		setCommonTestData();
		setControllers();

		ext.startDownloadDocuments();
		System.assertEquals(true,ext.downloadDocumentsStarted);

		ext.closeDownloadDocuments();
		System.assertEquals(false,ext.downloadDocumentsStarted);

	}

	public static testMethod void getAgendaParamExeSumTest(){
		setCommonTestData();
		setControllers();

		System.assertEquals('',ext.getAttachAgendaParam());

		EDM_IABP_gne__c exeSumIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = aabp.Id,
			EDM_Parent_IABP_gne__c = iabp.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_ExeSum_Final_Agenda_Source_gne__c = 'ExeSum'
		);
		insert exeSumIABP;
		EDM_Attachment_gne__c at = new EDM_Attachment_gne__c(
			EDM_Parent_IABP_gne__c = exeSumIABP.Id,
			EDM_System_Type_gne__c ='Final Agenda'
		);
		insert at;
		Attachment a = new Attachment(
			Name = 'TestName',
			Body = Blob.valueOf('TestFile'),
			ParentId = at.Id
		);
		insert a;

		ext.downloadDocumentId = exeSumIABP.Id;
		String agendaParam = ext.getAttachAgendaParam();

		System.assertEquals('&ParentIds='+at.Id+'&AttachIds='+a.Id,agendaParam);

	}

	public static testMethod void getAgendaParamTest(){
		setCommonTestData();
		setControllers();

		System.assertEquals('',ext.getAttachAgendaParam());

		EDM_IABP_gne__c exeSumIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = aabp.Id,
			EDM_Parent_IABP_gne__c = iabp.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_ExeSum_Final_Agenda_Source_gne__c = 'IABP'
		);
		insert exeSumIABP;
		EDM_Attachment_gne__c at = new EDM_Attachment_gne__c(
			EDM_Parent_IABP_gne__c = iabp.Id,
			EDM_Type_gne__c ='Agenda'
		);
		insert at;
		Attachment a = new Attachment(
			Name = 'TestName',
			Body = Blob.valueOf('TestFile'),
			ParentId = at.Id
		);
		insert a;

		ext.downloadDocumentId = exeSumIABP.Id;
		String agendaParam = ext.getAttachAgendaParam();

		System.assertEquals('&ParentIds='+at.Id+'&AttachIds='+a.Id,agendaParam);

	}

	public static testMethod void getPresentationTimePercentageTest(){
		setCommonTestData();
		iabp.EDM_Total_Presentation_Time_gne__c = '1:20';
		iabp.EDM_Total_Discussion_Time_gne__c = '1:20';
		iabp.EDM_Total_Break_Time_gne__c = '1:20';

		update iabp;

		setControllers();

		System.assertEquals('50', ext.agendaSummary.getPresentationTimePercentage());
	}

	public static testMethod void getDiscussionTimePercentageTest(){
		setCommonTestData();
		iabp.EDM_Total_Presentation_Time_gne__c = '1:20';
		iabp.EDM_Total_Discussion_Time_gne__c = '1:20';
		iabp.EDM_Total_Break_Time_gne__c = '1:20';
		update iabp;

		setControllers();

		System.assertEquals('50',ext.agendaSummary.getDiscussionTimePercentage());
	}

	public static testMethod void updateAttendeesTest2(){

		List<PermissionSet> ps = [Select id,UserLicenseId From PermissionSet Where Name in (:EDM_ABM_Utils.ABAPPROVER_NO_LIC)];
		
		Profile p_AB = [Select Id From Profile Where Name = 'GNE-TLS-ABM-Approver'];
		User u = new User(
			FirstName = 'Manager',
			ProfileId = p_AB.Id,
			Username = 'b@roche.com',
			LastName = 'Test', 
			Email = 'b@roche.com',
			TimeZoneSidKey = 'America/Los_Angeles', 
			LocaleSidKey = 'en_US', 
			EmailEncodingKey = 'ISO-8859-1', 
			LanguageLocaleKey = 'en_US'
		);
		insert u;

		List<PermissionSetAssignment> psa = new List<PermissionSetAssignment>();
			psa.add(new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps[0].Id));
		insert psa;

		System.runAs(u){
			setCommonTestData();

			ApexPages.currentPage().getParameters().put('pageType','review');
			ApexPages.currentPage().getParameters().put('retURL','www.google.com');
			setControllers();

			PageReference pr = ext.updateAttendees();
			String url = '/apex/EDM_Attendees_Documents?parentId='+iabp.Id+'&prevRetURL=www.google.com&retURL=%2Fapex%2FEDM_IABP_Review_Layout%3Fid%3D' + iabp.Id;
			System.assertEquals(url,pr.getUrl());
		}
	}

	public static testMethod void getSessionDetailsTest(){

		setCommonTestData();

		EDM_Session_gne__c session = new EDM_Session_gne__c(
			EDM_Parent_IABP_gne__c = iabp.Id
		);
		insert session;
		setControllers();

		ext.SessionId = session.Id;
		PageReference pr = ext.getSessionDetails();
		System.assertEquals(session.Id,ext.SessionToShow.Id);
	}

	@isTest public static void shouldBeNoCompareButtonIfNoSnapshots() {
		//given
		setCommonTestData();
		setControllers();

		//when
		Boolean showButton = ext.getShowCompareButton();

		//then
		System.assertEquals(showButton, false);
	}

	@isTest public static void shouldBeNoCompareButtonIfUserIsApprover() {
		//given
		setCommonTestData();
		setControllers();
		User approver = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABAPPROVER)[0];
		ext.compareId = iabp.Id;
		Boolean showButton;
		//when
		System.runAs(approver) {
			showButton = ext.getShowCompareButton();
		}		

		//then
		System.assertEquals(showButton, false);
	}

	@isTest public static void ablShouldNotShareWithAbs() {
		//given
		setCommonTestData();
		setControllers();
		User abs = EDM_ABM_Test_Utils.getABSes()[0];
		User abl = EDM_ABM_Test_Utils.getABLs()[0];
		List<SelectOption> availableUsers;
		Set<Id> absesIds = EDM_ABM_Utils.getUserIdsForRole(EDM_ABM_Utils.ABS);

		//when
		System.runAs(abl) {
			availableUsers = ext.UsersToShareWith;
		}
		Set<Id> availableUsersIds = new Set<Id>();
		for (SelectOption so : availableUsers) {
			availableUsersIds.add(so.getValue());
		}

		//then
		System.assert(!availableUsersIds.containsAll(absesIds));		
	}

	@isTest public static void shouldRedirectToDocuments() {
		//given
		setCommonTestData();
		ApexPages.currentPage().getParameters().put('pageType','review');
		ApexPages.currentPage().getParameters().put('retURL','www.google.com');
		setControllers();

		//when
		PageReference pr = ext.redirectToDocuments();

		//then
		System.assert(pr.getUrl().toLowerCase().contains('edm_attendees_documents'));
	}

	@isTest public static void absShouldBeAbleTovalidate() {
		//given
		setCommonTestData();
		iabp.EDM_Approval_Status_gne__c = 'Approved';
		update iabp;	

		//when
		User abs = EDM_ABM_Test_Utils.getABSes()[0];
		//then
		System.runAs(abs) {
			setControllers();
			System.assert(ext.getCanValidate());
		}
	}
}