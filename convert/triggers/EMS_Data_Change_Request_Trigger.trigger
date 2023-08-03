trigger EMS_Data_Change_Request_Trigger on EMS_Data_Change_Request_gne__c (after insert, after update, before insert, before update) {
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
		EMS_DataChRequest_Notifications.onAfterInsertUpdate(Trigger.oldMap, Trigger.new);
    }
}