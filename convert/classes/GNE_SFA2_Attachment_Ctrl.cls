global without sharing class GNE_SFA2_Attachment_Ctrl { //global because of iframe and remoteAction
	public Attachment newAtt { get; set; }
	public Id parentId { get; set; }
	private Id attachmentIdToUpdate;
	public Boolean attachmentUploaded {get; set;}
	public String uploadedFileName {get; set;}

	public GNE_SFA2_Attachment_Ctrl() {
		newAtt = new Attachment();
		attachmentIdToUpdate = ApexPages.currentPage().getParameters().get('attachmentId');
		parentId = ApexPages.currentPage().getParameters().get('parentId');

		attachmentUploaded = false;
	}

	public PageReference addAttachment() {
		if(newAtt.body == null) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please choose a File to upload'));
			return ApexPages.currentPage();
		}
		SavePoint sp = Database.setSavepoint(); 
		try {
			if(parentId == null)
				initParentObjectRecord();

			if (attachmentIdToUpdate == null) {
				insertAttachment(parentId);
			} else {
				DELETE [SELECT Id From Attachment where Id = :attachmentIdToUpdate];
				insertAttachment(parentId);				
			}
		} catch (Exception ex) {
			Database.rollback(sp);
			System.debug(ex.getMessage());
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
		} finally {
			System.debug('finally');
			attachmentUploaded = true;
			uploadedFileName = newAtt.Name;

			newAtt = new Attachment();
		}
		
		return null;
	}

	private void initParentObjectRecord() {
		ParentObjectTemp__c parentObj = new ParentObjectTemp__c();
		insert parentObj;
		parentId = parentObj.Id;
	}

	private void insertAttachment(Id parentObjId) {
		if(String.isNotEmpty(parentId))
		{
			newAtt.parentId = parentId;
		}
			
		insert newAtt;	
	}

	@RemoteAction
	global static Integer getAttachmentCount(Id pId) { //global because of iframe
		return [SELECT Id FROM Attachment WHERE ParentId = :pId].size();
	}

	public Integer getAttachmentCountLimit() {
		return 5;
	}
}