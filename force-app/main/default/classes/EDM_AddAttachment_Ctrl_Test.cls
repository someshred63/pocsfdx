@isTest
private class EDM_AddAttachment_Ctrl_Test {
	
	@isTest static void shouldAddAttachemntWithNameTakenFromFile() {
		//given
		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		addAttachmentCtrl.newAtt.Name = 'testAttachment';
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');

		//when
		PageReference result = addAttachmentCtrl.addAttachment();

		//then
		System.assertEquals(null, result);
		System.assertEquals(null, addAttachmentCtrl.newAtt.Body);
		checkIfOneAttachmentAndReturnIt();
		EDM_Attachment_gne__c edmAttachment = checkIfOneEDM_AttachmentAndReturnIt();
		System.assertEquals('testAttachment', edmAttachment.EDM_Document_Name_gne__c);
	}

	@isTest static void shouldAddAttachemntWithNameEnteredByUser() {
		//given
		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		addAttachmentCtrl.newAtt.Name = 'testAttachment';
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');
		addAttachmentCtrl.edmAttachment.EDM_Document_Name_gne__c = 'GivenName';

		//when
		PageReference result = addAttachmentCtrl.addAttachment();

		//then
		System.assertEquals(null, result);
		System.assertEquals(null, addAttachmentCtrl.newAtt.Body);
		checkIfOneAttachmentAndReturnIt();
		EDM_Attachment_gne__c edmAttachment = checkIfOneEDM_AttachmentAndReturnIt();
		System.assertEquals('GivenName', edmAttachment.EDM_Document_Name_gne__c);
	}

	@isTest static void shouldNotCreteRecordsAndResetNewAttWhenAttNameIsBlank() {
		//given
		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');

		//when
		PageReference result = addAttachmentCtrl.addAttachment();

		//then
		System.assertEquals(null, result);
		System.assertEquals(null, addAttachmentCtrl.newAtt.Body);
		List<Attachment> attachments = [SELECT Id FROM Attachment];
		System.assertEquals(0, attachments.size());
		List<EDM_Attachment_gne__c> edmAttachments = [SELECT Id, EDM_Document_Name_gne__c FROM EDM_Attachment_gne__c];
		System.assertEquals(0, edmAttachments.size());
	}

	@isTest static void shouldReturnSomeAttachmentCountLimit() {
		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		Integer result = addAttachmentCtrl.getAttachmentCountLimit();
		System.assert(result > 0);
	}

	@isTest static void shouldAddAttachementToAABP() {
		//given
		List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();
		EDM_AABP_gne__c aabp = (EDM_AABP_gne__c)testData[0];

		PageReference currentPage = Page.EDM_AddAttachment;
		currentPage.getParameters().put('parentId', aabp.Id);
		Test.setCurrentPage(currentPage);

		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		addAttachmentCtrl.newAtt.Name = 'testAttachment';
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');

		//when
		PageReference result = addAttachmentCtrl.addAttachment();
		Integer attachmentCount = EDM_AddAttachment_Ctrl.getAttachmentCount(aabp.Id);

		//then
		System.assertEquals(null, result);
		checkIfOneAttachmentAndReturnIt();
		checkIfOneEDM_AttachmentAndReturnIt();
		System.assertEquals(1, attachmentCount);
	}

	@isTest static void shouldAddAttachementToIABP() {
		//given
		List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();
		EDM_IABP_gne__c iabp = (EDM_IABP_gne__c)testData[1];

		PageReference currentPage = Page.EDM_AddAttachment;
		currentPage.getParameters().put('parentId', iabp.Id);
		Test.setCurrentPage(currentPage);

		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		addAttachmentCtrl.newAtt.Name = 'testAttachment';
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');

		//when
		PageReference result = addAttachmentCtrl.addAttachment();
		Integer attachmentCount = EDM_AddAttachment_Ctrl.getAttachmentCount(iabp.Id);

		//then
		System.assertEquals(null, result);
		checkIfOneAttachmentAndReturnIt();
		checkIfOneEDM_AttachmentAndReturnIt();
		System.assertEquals(1, attachmentCount);
	}

	@isTest static void shouldAddAttachementToExeSum() {
		//given
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();

		PageReference currentPage = Page.EDM_AddAttachment;
		currentPage.getParameters().put('parentId', exesum.Id);
		Test.setCurrentPage(currentPage);

		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		addAttachmentCtrl.newAtt.Name = 'testAttachment';
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');

		//when
		PageReference result = addAttachmentCtrl.addAttachment();
		Integer attachmentCount = EDM_AddAttachment_Ctrl.getAttachmentCount(exesum.Id);

		//then
		System.assertEquals(null, result);
		checkIfOneAttachmentAndReturnIt();
		checkIfOneEDM_AttachmentAndReturnIt();
		System.assertEquals(1, attachmentCount);
	}


	private static EDM_IABP_gne__c insertNewExeSumRecord() {
		EDM_IABP_gne__c exeSum = getNewExeSumRecord();
		insert exeSum;
		return exeSum;
	}

	private static EDM_IABP_gne__c getNewExeSumRecord() {
		List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();
		EDM_AABP_gne__c aabp = (EDM_AABP_gne__c)testData[0];
		EDM_IABP_gne__c iabp = (EDM_IABP_gne__c)testData[1];
		return new EDM_IABP_gne__c(
				EDM_Executive_Summary_gne__c = true,
				EDM_Parent_AABP_gne__c = aabp.Id,
				EDM_Parent_IABP_gne__c = iabp.Id,
				EDM_Type_of_Event_gne__c = 'Dummy',
				EDM_IABP_Version_gne__c = 1,
				RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'ExeSum' LIMIT 1].Id);
	}

	@isTest static void shouldNotFailWhenRemoveExeSumNotExisitngFinalAgenda() {
		//given
		List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();
		EDM_IABP_gne__c iabp = (EDM_IABP_gne__c)testData[1];

		//when
		EDM_AddAttachment_Ctrl.removeExeSumFinalAgendaFor(iabp.Id);

		//then
		System.assert(true);
	}

	@isTest static void shouldUpdateFinalAgendaOnExeSum() {
		//given
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		Id edmAttachId = prepareTestFinalAgenda(exesum.Id);
		Id attachId = insertTestAttachment(edmAttachId);

		PageReference currentPage = Page.EDM_AddAttachment;
		currentPage.getParameters().put('parentId', exesum.Id);
		currentPage.getParameters().put('SystemType', 'Final Agenda');
		Test.setCurrentPage(currentPage);

		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		addAttachmentCtrl.newAtt.Name = 'testAttachment';
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');

		//when
		PageReference result = addAttachmentCtrl.addAttachment();

		//then
		System.assertEquals(null, result);
		System.assertEquals(false, ApexPages.hasMessages() , ApexPages.getMessages());
		System.assertNotEquals(attachId, checkIfOneAttachmentAndReturnIt().Id);
		System.assertNotEquals(edmAttachId, checkIfOneEDM_AttachmentAndReturnIt().Id);
	}

	private static Attachment checkIfOneAttachmentAndReturnIt() {
		List<Attachment> attachments = [SELECT Id FROM Attachment];
		System.assertEquals(1, attachments.size());
		return attachments[0];
	}

	private static EDM_Attachment_gne__c checkIfOneEDM_AttachmentAndReturnIt() {
		List<EDM_Attachment_gne__c> edmAttachments = [SELECT Id, EDM_Document_Name_gne__c FROM EDM_Attachment_gne__c];
		System.assertEquals(1, edmAttachments.size());
		return  edmAttachments[0];
	}

	private static Id prepareTestFinalAgenda(Id parentId) {

		EDM_Attachment_gne__c edmAttach = new EDM_Attachment_gne__c(
				EDM_Parent_IABP_gne__c = parentId,
				EDM_Document_Name_gne__c = 'Test',
				EDM_System_Type_gne__c = 'Final Agenda');
		insert edmAttach;

		return edmAttach.id;
	}

	private static Id insertTestAttachment(Id parentId) {
		Attachment attach = new Attachment(
			Name = 'testAttachment',
			Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64'),
			ParentId = parentId);

		insert attach;

		return attach.Id;
	}

	@isTest static void shouldGetAllFileTypesWhenNotExesum() {
		//given
		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();

		//when
		String result = addAttachmentCtrl.getFileTypesAvailableForSelection();

		//then
		System.assertEquals('', result);
	}

	@isTest static void shouldShowErrorMessageWhenBodyIsEmpty() {
		//given
		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();

		//when
		addAttachmentCtrl.addAttachment();

		//then
		System.assertEquals(true, ApexPages.hasMessages());
	}

	@isTest static void shouldReturnZeroWhenWrongTypeIsPassed() {
		//when
		Integer result = EDM_AddAttachment_Ctrl.getAttachmentCount(UserInfo.getUserId());

		//then
		System.assertEquals(0, result);
	}

	@isTest static void shouldShowTypeAndDescriptionFields(){
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();
		exesum.EDM_Executive_Summary_gne__c = false;
		update exesum;

		PageReference currentPage = Page.EDM_AddAttachment;
		currentPage.getParameters().put('parentId', exesum.Id);
		currentPage.getParameters().put('SystemType', 'Event Document');
		Test.setCurrentPage(currentPage);

		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		Boolean showFields = addAttachmentCtrl.getShowTypeAndDescriptionFields();

		System.assertEquals(true, showFields);
	}

	@isTest static void shouldNotShowTypeAndDescriptionFields(){
		//given
		EDM_IABP_gne__c exesum = insertNewExeSumRecord();

		PageReference currentPage = Page.EDM_AddAttachment;
		currentPage.getParameters().put('parentId', exesum.Id);
		currentPage.getParameters().put('SystemType', 'Final Agenda');
		Test.setCurrentPage(currentPage);

		EDM_AddAttachment_Ctrl addAttachmentCtrl = new EDM_AddAttachment_Ctrl();
		Boolean showFields = addAttachmentCtrl.getShowTypeAndDescriptionFields();

		System.assertEquals(false, showFields);
	}
}