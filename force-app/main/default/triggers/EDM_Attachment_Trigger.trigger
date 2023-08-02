trigger EDM_Attachment_Trigger on EDM_Attachment_gne__c (after delete, after insert, after undelete, after update, 
												before delete, before insert, before update) {
	if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('EDM_Attachment_Trigger')) {
		if (Trigger.isBefore && Trigger.isInsert) {
			//nope
		} else if(Trigger.isBefore && Trigger.isUpdate) {
			EDM_PTD_Utils.onBeforeUpdate(Trigger.old, Trigger.newMap);
		} else if(Trigger.isBefore && Trigger.isDelete) {
			//nope
		} else if(Trigger.isAfter && Trigger.isInsert) {
			//nope
		} else if(Trigger.isAfter && Trigger.isUpdate) {
			//nope
		} else if(Trigger.isAfter && Trigger.isDelete) {
			//nope
		}
	}
}