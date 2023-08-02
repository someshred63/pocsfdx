public with sharing class gFRS_AttachmentUploadUtil {

    public static Attachment uploadAttachment(Id objectId, Id fundReqId, String fieldApiName, Attachment attachment, Boolean isRFI) {
		Boolean createNewAttachment = false;
		if(isRFI){
			//Object is in RFI state
			if(attachment.Id == null){
				//File does not exists
				createNewAttachment = true;
			}else{
				createNewAttachment = (attachment.CreatedDate < gFRS_Util_NoShare.getRfiDateByActionType(fundReqId, gFRS_Util.REQUEST_STATUS_RFI ))?true:false;	
			}	
		}else{
			//Object is not in RFI
			if(attachment.Id == null){
				createNewAttachment = true;	
			}else{
				createNewAttachment = false;
			}
		}
		return uploadObjectAttachment(objectId, fieldApiName, attachment, createNewAttachment);
	}
	
	private static Attachment uploadObjectAttachment(Id objectId, String fieldApiName, Attachment attachment, Boolean createNewAttachment){
		Attachment newAttachment;
		String objectApiName = objectId.getSobjectType().getDescribe().getName();
		String fieldLabel = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe().getLabel();
		try{
			if(createNewAttachment){
				newAttachment = new Attachment( ParentId = objectId, Name = attachment.Name, Description = fieldLabel, Body = attachment.Body );
				gFRS_Util_NoShare.saveLockedAttachment( newAttachment );
				newAttachment.Body = null;
			}else{
				newAttachment = upsertAttachment(attachment, fieldLabel);
				newAttachment.Body = null;
			}
			assignAttachmentToObject(objectId,fieldApiName,newAttachment.Id);
			newAttachment = refreshAttachment(fieldApiName, newAttachment.Id);
			return newAttachment;
		}catch( Exception err ){
			ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
			throw err;
		}
	}
	
	private static void assignAttachmentToObject(Id objectId, String fieldApiName, Id attachmentId) {
			String objectApiName = objectId.getSobjectType().getDescribe().getName();
        	String soql = 'Select Id from ' + objectApiName + ' where Id = :objectId';
        	Sobject partial = Database.query(soql);
			partial.put(fieldApiName,attachmentId);
			if (objectApiName == gFRS_Util.FUNDING_REQUEST_API_NAME) {
				gFRS_Util_NoShare.saveLockedFundingRequest((GFRS_Funding_Request__c)partial);
			} else if (objectApiName == gFRS_Util.ORGANIZATION_API_NAME) {
				gFRS_Util_NoShare.saveLockedOrganization((GFRS_Organization__c)partial);
			} else if (objectApiName == gFRS_Util.PROGRAM_API_NAME) {
				gFRS_Util_NoShare.saveLockedProgram((GFRS_Program__c)partial);
			} else {
				ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, 'No attachment field available for this object' ) );
			}
	}
	
	private static Attachment upsertAttachment(Attachment attachment, String fieldLabel){
		attachment.Description = fieldLabel;
		gFRS_Util_NoShare.saveLockedAttachment(attachment);
		return attachment;	
	}
	
	private static Attachment refreshAttachment(String fieldApiName, Id attachmentId){
		Attachment attachmentToRefresh = [ select Id, ParentId, Name, Description, CreatedDate from Attachment where Id = :attachmentId];
		attachmentToRefresh.Body = null;
		return attachmentToRefresh;
	}
}