trigger EMS_Attendee_Trigger on EMS_Attendee_gne__c (before insert, before update, before delete, after insert, after update, after delete) {

	private boolean validationFailed = false;

	if (Trigger.isBefore) {
		if (Trigger.isUpdate) {
			validationFailed = EMS_Attendee_Validation_Rules.onBeforeUpdate(Trigger.old, Trigger.new);
			if(!validationFailed) {
				EMS_Attendee_Field_Updates.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
			}
		} else if (Trigger.isInsert) {
            //do something
		} else if (Trigger.isDelete) {
			//do something
		}
	} else if (Trigger.isAfter) {
		if (Trigger.isUpdate) {
			EMS_Attendee_Email_Notifications.isAfter(Trigger.oldMap, Trigger.newMap);
		}
	}
}