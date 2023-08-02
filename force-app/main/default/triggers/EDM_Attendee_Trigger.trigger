trigger EDM_Attendee_Trigger on EDM_Attendee_gne__c (after delete, after insert, after undelete, after update, 
                                                before delete, before insert, before update) {
    if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('EDM_Attendee_Trigger')) {
        if (Trigger.isBefore && Trigger.isInsert) {
            EDM_Attendee_Trigger_Helper.onBeforeInsert(Trigger.new);
        } else if(Trigger.isBefore && Trigger.isUpdate) {
            // nope
        } else if(Trigger.isBefore && Trigger.isDelete) {
            EDM_Spend_Participant.sendForRemovalInGSSP(Trigger.oldMap);
            EDM_Attendee_Trigger_Helper.trackDeletedAttendees(Trigger.old);
        } else if(Trigger.isAfter && Trigger.isInsert) {
            EDM_Attendee_Trigger_Helper.trackAddedAttendees(Trigger.new);
        } else if(Trigger.isAfter && Trigger.isUpdate) {
            EDM_Attendee_Trigger_Helper.trackChangedFields(Trigger.new, Trigger.oldMap);
        } else if(Trigger.isAfter && Trigger.isDelete) {
            // nope
        }
    }
}