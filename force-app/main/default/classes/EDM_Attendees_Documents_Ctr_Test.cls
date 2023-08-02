@isTest
private class EDM_Attendees_Documents_Ctr_Test {
	private static EDM_AABP_gne__c testAABP;
	private static EDM_IABP_gne__c parentIABP;
	private static EDM_IABP_gne__c parentExeSum;

	private static void insertAABP() {
		testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;
	}
	private static void insertIABP() {
		parentIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = false,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert parentIABP;
	}

	private static void insertExeSum() {
		parentExeSum = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert parentExeSum;
	}

	@isTest
	public static void iabpParameterMissingTest(){
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Parent IABP ID parameter is missing or incorrect. Did you come here from IABP page?'));
	}

	@isTest
	public static void wrongIABPIdTest(){

		insertAABP();
		insertIABP();

		String id = parentIABP.Id;

		delete parentIABP;
		ApexPages.currentPage().getParameters().put('parentId',id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Parent IABP not found. Did you come here from IABP page?'));
	}

	@isTest
	public static void saveAndGoBackTest(){

		insertAABP();
		insertIABP();

		ApexPages.currentPage().getParameters().put('parentId',parentIABP.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		System.assert(!ctrl.getEventOccured());

		PageReference pr = ctrl.saveAndGoBack();
		System.assertEquals('/apex/EDM_IABP_Edit_Create?id=' + parentIABP.Id,pr.getUrl());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Attendees and documents have been saved!'));
	}

	@isTest
	public static void saveAndGoBackExeSumTest(){
		insertAABP();
		insertExeSum();

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		System.assert(ctrl.getEventOccured());

		PageReference pr = ctrl.saveAndGoBack();
		System.assertEquals('/apex/EDM_ExeSum_Edit_Create?id=' + parentExeSum.Id, pr.getUrl());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Attendees and documents have been saved!'));
	}

	@isTest
	public static void goBackTest(){
		insertAABP();
		insertExeSum();

		ApexPages.currentPage().getParameters().put('retUrl','/apex/EDM_ExeSum_Edit_Create');
		ApexPages.currentPage().getParameters().put('prevRetURL','/apex/EDM_IABP_Edit_Create');
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.goBack();
		System.assertEquals('/apex/EDM_IABP_Edit_Create',pr.getUrl());
	}

	@isTest
	public static void goBackTest2(){
		insertAABP();
		insertExeSum();

		ApexPages.currentPage().getParameters().put('retUrl','/apex/EDM_ExeSum_Edit_Create');
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.goBack();
		System.assertEquals('/apex/EDM_ExeSum_Edit_Create',pr.getUrl());
	}

	@isTest
	public static void saveExeSumErrorTest(){
		insertAABP();
		insertExeSum();
		Account acc = new Account(Name = 'Test Account');
        insert acc;

		List<EDM_Attendee_gne__c> atts = new List<EDM_Attendee_gne__c>();
		atts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentExeSum.Id,
			EDM_System_Type_gne__c = 'Advisor',
			Originate_from_ExeSum_gne__c = true,
			EDM_Account_gne__c = acc.id
		));
		atts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentExeSum.Id,
			EDM_System_Type_gne__c = 'Genentech',
			Originate_from_ExeSum_gne__c = true
		));
		insert atts;

		List<EDM_Attendee_gne__c> parentAtts = new List<EDM_Attendee_gne__c>();
		parentAtts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentExeSum.Id,
			EDM_Parent_Attendee_gne__c = atts[0].Id,
			EDM_System_Type_gne__c = 'Advisor',
			Originate_from_ExeSum_gne__c = true,
			EDM_Account_gne__c = acc.id
		));
		parentAtts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentExeSum.Id,
			EDM_Parent_Attendee_gne__c = atts[1].Id,
			EDM_System_Type_gne__c = 'Genentech',
			Originate_from_ExeSum_gne__c = true
		));
		insert parentAtts;

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.saveAD();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(2,msgs.size(),msgs);
		System.assert(msgs[1].getDetail().contains('Could not save Attendees!'));
	}

	@isTest
	public static void saveExeSumTest(){

		insertAABP();
		insertIABP();
		Account acc = new Account(Name = 'Test Account');
        insert acc;
		EDM_IABP_gne__c exesum = new EDM_IABP_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = true,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199
		);
		insert exesum;

		List<EDM_Attendee_gne__c> atts = new List<EDM_Attendee_gne__c>();
		atts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = exesum.Id,
			EDM_System_Type_gne__c = 'Advisor',
			Originate_from_ExeSum_gne__c = true,
			EDM_Account_gne__c = acc.id
		));
		atts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = exesum.Id,
			EDM_System_Type_gne__c = 'Genentech',
			Originate_from_ExeSum_gne__c = true
		));
		insert atts;

		List<EDM_Attendee_gne__c> parentAtts = new List<EDM_Attendee_gne__c>();
		parentAtts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = exesum.Id,
			EDM_Parent_Attendee_gne__c = atts[0].Id,
			EDM_System_Type_gne__c = 'Advisor',
			Originate_from_ExeSum_gne__c = true,
			EDM_Account_gne__c = acc.id
		));
		parentAtts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = exesum.Id,
			EDM_Parent_Attendee_gne__c = atts[1].Id,
			EDM_System_Type_gne__c = 'Genentech',
			Originate_from_ExeSum_gne__c = true
		));
		insert parentAtts;

		ApexPages.currentPage().getParameters().put('parentId',parentIABP.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.saveAD();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size(),msgs);
		System.assert(msgs[0].getDetail().contains('Attendees and documents have been saved!'));
	}

	@isTest
	public static void saveAndGoToSBCTest(){		
		insertAABP();
		insertIABP();

		ApexPages.currentPage().getParameters().put('parentId',parentIABP.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.saveAndGoToSBC();
		System.assertEquals('/apex/GNE_SFA2_SBC',pr.getUrl());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Attendees and documents have been saved!'));
	}

	@isTest
	public static void addAndDelGeneRepTest(){

		insertAABP();
		insertIABP();

		ApexPages.currentPage().getParameters().put('parentId',parentIABP.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		Integer geneRepsSize = ctrl.GeneReps.size();

		System.assert(ctrl.getCanAddGeneAttendees());
		PageReference pr = ctrl.addGeneRep();

		System.assertEquals(null,pr);
		System.assertEquals(geneRepsSize+1,ctrl.GeneReps.size());

		ctrl.RowToDel = 0;
		ctrl.delGeneRep();
		System.assertEquals(geneRepsSize,ctrl.GeneReps.size());
	}

	@isTest
	public static void addGeneRepLimitTest(){
		insertAABP();
		insertExeSum();

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		for(Integer i = 0; i < ctrl.GENE_REPS_LIMIT; i++ ){
			ctrl.addGeneRep();
		}
		System.assertEquals(ctrl.GENE_REPS_LIMIT,ctrl.GeneReps.size());

		PageReference pr = ctrl.addGeneRep();
		System.assertEquals(null,pr);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('You cannot add more than ' + String.valueOf(ctrl.GENE_REPS_LIMIT) + ' Representatives!'));
	}

	@isTest
	public static void delExistingGeneRepTest(){
		insertAABP();
		insertExeSum();

		List<EDM_Attendee_gne__c> atts = new List<EDM_Attendee_gne__c>();
		atts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentExeSum.Id,
			EDM_System_Type_gne__c = 'Genentech',
			Originate_from_ExeSum_gne__c = false
		));
		atts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentExeSum.Id,
			EDM_System_Type_gne__c = 'Genentech',
			Originate_from_ExeSum_gne__c = true
		));
		insert atts;

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		ctrl.RowToDel = 1;
		ctrl.delGeneRep();
		
		ctrl.RowToDel = 0;
		ctrl.delGeneRep();

		atts = [Select Id From EDM_Attendee_gne__c Where EDM_System_Type_gne__c = 'Genentech' And is_deleted_gne__c = false];
		System.assertEquals(0,atts.size());
	}

	@isTest
	public static void addAndDelOtherTest(){

		insertAABP();
		insertIABP();

		ApexPages.currentPage().getParameters().put('parentId',parentIABP.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		Integer otherAttendeesSize = ctrl.OtherAttendees.size();

		PageReference pr = ctrl.addOther();

		System.assertEquals(null,pr);
		System.assertEquals(otherAttendeesSize+1,ctrl.OtherAttendees.size());

		ctrl.RowToDel = 0;
		ctrl.delOther();
		System.assertEquals(otherAttendeesSize,ctrl.OtherAttendees.size());
	}

	@isTest
	public static void addOtherLimitTest(){
		insertAABP();
		insertExeSum();

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		for(Integer i = 0; i < ctrl.OTHER_LIMIT; i++ ){
			ctrl.addOther();
		}
		System.assertEquals(ctrl.OTHER_LIMIT,ctrl.OtherAttendees.size());

		PageReference pr = ctrl.addOther();
		System.assertEquals(null,pr);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('You cannot add more than ' + String.valueOf(ctrl.OTHER_LIMIT) + ' Other Attendees!'));
	}

	@isTest
	public static void delEventDocErrorTest(){
		insertAABP();
		insertExeSum();

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.delEventDoc();
		System.assertEquals(null,pr);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Could not delete Attachment!'));
	}

	@isTest
	public static void delEventDocTest(){
		insertAABP();
		insertExeSum();

		List<EDM_Attachment_gne__c> attList = new List<EDM_Attachment_gne__c>();
		attList.add(new EDM_Attachment_gne__c(
			EDM_Parent_IABP_gne__c = parentExeSum.Id,
			EDM_System_Type_gne__c = 'Event Document'
		));
		insert attList;

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		ctrl.retrieveAttachments();
		System.assertEquals(1,ctrl.EventDocuments.size());

		ctrl.RowToDel = 0;
		PageReference pr = ctrl.delEventDoc();
		System.assertEquals(null,pr);

		System.assertEquals(0,ctrl.EventDocuments.size());
	}

	@isTest
	public static void redirectToClassificationErrorTest(){
		insertAABP();
		insertExeSum();

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.redirectToClassification();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Classification Request: Account ID or Type of classification is missing.'));
	}

	@isTest
	public static void redirectToClassificationTest(){
		insertAABP();
		insertExeSum();

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		ApexPages.currentPage().getParameters().put('accountId', a.Id);
		Apexpages.currentPage().getParameters().put('typeOfClassification','Business');

		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.redirectToClassification();

		PageReference pr2 = Page.EDM_Classification_Request_Edit_Create;
		pr2.getParameters().put('accountId', a.Id);
		pr2.getParameters().put('typeOfClassification', 'Business');
		pr2.getParameters().put('retUrl', '/apex/EDM_Attendees_Documents?parentId=' + parentExeSum.Id);

		System.assertEquals(pr2.getUrl(),pr.getUrl());
	}

	@isTest
	public static void submitExclusionRequestErrorTest() {
		insertAABP();
		insertExeSum();

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		PageReference pr = ctrl.submitExclusionRequest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(2,msgs.size());
		System.assert(msgs[1].getDetail().contains('Classification Request: Account ID is missing.'));
	}

	@isTest
	public static void submitExclusionRequestTest(){
		insertAABP();
		insertExeSum();

		Account a = new Account(
			Name = 'TestAccount',
			AGS_EX_Exclusion_Status_base_gne__c = 'Not Checked'
		);
		insert a;
		insert new Contact(
            Firstname='Exclusion',
            Lastname = 'Check',
            Account = a,
            Email='test@roche.com'
        );

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);

		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		ctrl.accountId = a.Id;

		PageReference pr = ctrl.submitExclusionRequest();

		System.assertEquals(1,[Select Id From AGS_EX_Exclusion_Request_gne__c Where AGS_EX_Account_Name_gne__c = :a.Id].size());
	}

	@isTest
	public static void submitExclusionRequestAccountIdErrorTest(){
		insertAABP();
		insertExeSum();

		Account a = new Account(
			Name = 'TestAccount'
		);
		insert a;

		String accId = a.Id;

		delete a;

		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);

		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();
		ctrl.accountId = accId;

		PageReference pr = ctrl.submitExclusionRequest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(2,msgs.size());
		System.assert(msgs[1].getDetail().contains('Classification Request: Did not find Account with ID: ' + accId));
	}

	@isTest
	public static void shouldCacheCommentAndGoToSBC() {
		//given
		insertAABP();
		insertExeSum();
		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();

		//when		
		ctrl.reasonComment = 'Some Comment';
		PageReference sbcRr = ctrl.cacheCommentAndGoToSBC();
		String cacheKey = 'local.EDMCache.AttendeeChangeReason' + parentExeSum.Id;

		//then 
		System.assert(sbcRr.getUrl().containsIgnoreCase('GNE_SFA2_SBC'));
		System.assert(Cache.Session.contains(cacheKey));
		EDM_Attendees_Documents_Ctr.AttendeeChangeReason cachedChangeReason = (EDM_Attendees_Documents_Ctr.AttendeeChangeReason)Cache.Session.get(cacheKey);
		System.assert(cachedChangeReason.getFormattedComment().contains('Some Comment'));
	}

	@isTest
	public static void createCoverage() {
		insertAABP();
		insertExeSum();
		ApexPages.currentPage().getParameters().put('parentId', parentExeSum.Id);
		EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();
		ctrl.shareIABP();
		ctrl.regenerateSystemDocuments();
		ctrl.refreshPageAfertWaitingForDrawloopDocuments();
		EDM_Attendees_Documents_Ctr.isWaitingForDrawloopDocuments(parentExeSum.Id);
	}

	@isTest
	public static void readOnlyModeFalseForFinalizedExeSumTest() {
		User absUser = EDM_ABM_Test_Utils.getABSes()[0];
		System.runAs(absUser) {
			insertAABP();
			insertIABP();
			parentIABP.EDM_Status_gne__c = 'PTD in Progress';
			update parentIABP;

			insertExeSum();
			parentExeSum.EDM_Status_gne__c = 'Finalized';
			update parentExeSum;

			ApexPages.currentPage().getParameters().put('parentId', parentIABP.Id);
			ApexPages.currentPage().getParameters().put('eaction', 'updateAttendees');
			EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();
			System.assertEquals(false, ctrl.getIsPageReadOnly());
		}
	}

	@isTest
	public static void readOnlyModeTrueForFinalizedSpend() {
		User absUser = EDM_ABM_Test_Utils.getABSes()[0];
		System.runAs(absUser) {
			insertAABP();
			insertIABP();
			parentIABP.EDM_Status_gne__c = 'PTD in Progress';
			update parentIABP;

			insertExeSum();
			parentExeSum.EDM_Status_gne__c = 'Finalized';
			parentExeSum.EDM_Parent_IABP_gne__c = parentIABP.Id;
			update parentExeSum;

			Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
			ApexPages.StandardController sc = new ApexPages.StandardController(parentIABP);
			EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);
			ext.goBackAfterSave = false;
			ext.save();
			ext.edmSpend.EDM_Spend_Status_gne__c = 'Save & Finalize';
			update ext.edmSpend;

			Test.setCurrentPage(Page.EDM_Attendees_Documents);
			ApexPages.currentPage().getParameters().put('parentId', parentIABP.Id);
			ApexPages.currentPage().getParameters().put('eaction', 'updateAttendees');
			EDM_Attendees_Documents_Ctr ctrl = new EDM_Attendees_Documents_Ctr();
			System.assertEquals(true, ctrl.getIsPageReadOnly());			
		}
	}
}