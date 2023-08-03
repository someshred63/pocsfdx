trigger EMS_Event_Configuration_Trigger on EMS_Event_Configuration_gne__c (before insert, before update) {
	
	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
		EMS_Event_Configuration_Field_Updates.onBeforeInsertUpdate(Trigger.new);
	}
}