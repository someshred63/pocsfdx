trigger EMS_Roche_Attendee_Trigger on EMS_Roche_Attendee_gne__c (after delete, after insert, after update, before delete, before insert, before update) {
    
    private Boolean validationFailed = false;

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            validationFailed = EMS_Roche_Attendee_Validation_Rules.onBeforeInsert(Trigger.new);
        } else if (Trigger.isDelete) {
            EMS_Roche_Attendee_Child_Rec_Updates.onBeforeDelete(Trigger.old);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            EMS_Roche_Attendee_Child_Rec_Updates.onAfterInsertOrUpdate(Trigger.new);
            EMS_Roche_Attendee_Email_Notifications.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            EMS_Roche_Attendee_Child_Rec_Updates.onAfterInsertOrUpdate(Trigger.new);
        } else if (Trigger.isDelete) {
            // do something
        }
    }
}