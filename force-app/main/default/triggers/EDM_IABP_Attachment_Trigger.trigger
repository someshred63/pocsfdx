trigger EDM_IABP_Attachment_Trigger on Attachment (before insert, after insert) {

	if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('EDM_IABP_Attachment_Trigger')) {
		if (Trigger.isBefore && Trigger.isInsert) {
			List<Attachment> attachmentsIABP = EDM_IABP_DrawLoop.filterAttachmentsBy(trigger.New, new Set<Schema.sObjectType> {
					EDM_IABP_gne__c.SobjectType,
					EDM_Budget_gne__c.SobjectType});
			EDM_IABP_DrawLoop.reparentAttachmentsToEDMAttachments(attachmentsIABP);
		} else if(Trigger.isBefore && Trigger.isUpdate) {
			//nope
		} else if(Trigger.isBefore && Trigger.isDelete) {
			//nope
		} else if(Trigger.isAfter && Trigger.isInsert) {
			List<Attachment> attachmentsEDM = EDM_IABP_DrawLoop.filterAttachmentsBy(trigger.New, EDM_Attachment_gne__c.SobjectType);
			EDM_IABP_DrawLoop.updateEDMAttachmentLinks(attachmentsEDM);
			EDM_IABP_DrawLoop.sendNotificationsWhenAllSystemGeneretedDocumentsReady(attachmentsEDM);
		} else if(Trigger.isAfter && Trigger.isUpdate) {
			//nope
		} else if(Trigger.isAfter && Trigger.isDelete) {
			//nope
		}
	}
}