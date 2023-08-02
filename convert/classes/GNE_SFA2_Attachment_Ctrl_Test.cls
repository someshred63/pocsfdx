@isTest
private class GNE_SFA2_Attachment_Ctrl_Test {
	
	@isTest static void shouldAddAttachemntWithNameTakenFromFile() {
		//given
		GNE_SFA2_Attachment_Ctrl addAttachmentCtrl = new GNE_SFA2_Attachment_Ctrl();
		addAttachmentCtrl.newAtt.Name = 'testAttachment';
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');

		//when
		PageReference result = addAttachmentCtrl.addAttachment();

		//then
		System.assertEquals(null, result);
		System.assertEquals(null, addAttachmentCtrl.newAtt.Body);

		checkIfOneAttachmentAndReturnIt();
	}	

	@isTest static void shouldReturnSomeAttachmentCountLimit() {
		GNE_SFA2_Attachment_Ctrl addAttachmentCtrl = new GNE_SFA2_Attachment_Ctrl();
		Integer result = addAttachmentCtrl.getAttachmentCountLimit();
		System.assert(result > 0);
	}

	private static Attachment checkIfOneAttachmentAndReturnIt() {
		List<Attachment> attachments = [SELECT Id FROM Attachment];
		System.assertEquals(1, attachments.size());
		return attachments[0];
	}

	@isTest static void shouldDeleteInsertAttachment() {
		//given
		ParentObjectTemp__c parentObj = new ParentObjectTemp__c();
		insert parentObj;
		String attachId = insertTestAttachment(parentObj.Id);

		PageReference currentPage = Page.GNE_SFA2_Attachment;
		currentPage.getParameters().put('parentId', parentObj.Id);
		currentPage.getParameters().put('attachmentId', attachId);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Attachment_Ctrl addAttachmentCtrl = new GNE_SFA2_Attachment_Ctrl();
		addAttachmentCtrl.newAtt.Name = 'testAttachment';
		addAttachmentCtrl.newAtt.Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64');

		//when
		PageReference result = addAttachmentCtrl.addAttachment();

		//then
		System.assertEquals(null, result);
		System.assertEquals(false, ApexPages.hasMessages() , ApexPages.getMessages());
		System.assertNotEquals(attachId, checkIfOneAttachmentAndReturnIt().Id);
		System.assertEquals(1, GNE_SFA2_Attachment_Ctrl.getAttachmentCount(parentObj.Id));
	}

	private static Id insertTestAttachment(Id parentId) {
		Attachment attach = new Attachment(
			Name = 'testAttachment',
			Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64'),
			ParentId = parentId);

		insert attach;

		return attach.Id;
	}
}