trigger EMS_Travel_Trigger on EMS_Travel_gne__c (after insert, after update, before insert, before update) {
    if (Trigger.isAfter && Trigger.isInsert) {
		EMS_Travel_Email_Notifications.onAfterInsert(Trigger.new);
    }
}