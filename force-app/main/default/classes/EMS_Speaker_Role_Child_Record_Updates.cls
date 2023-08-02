public without sharing class EMS_Speaker_Role_Child_Record_Updates {

    private static void updateEventStatus(List<EMS_Speaker_Role_gne__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Speaker_Role_gne__c paymentRequest : triggerNew) {
            if (paymentRequest.Status_gne__c == 'Submitted') {
                eventIds.add(paymentRequest.EMS_Event_gne__c);
            }
        }
        List<EMS_Event__c> eventsToUpdate = new List<EMS_Event__c>();
        List<EMS_Event__c> eventsList = [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :eventIds];
        for (EMS_Event__c event : eventsList) {
            if (event.Status_gne__c != 'Closed' && event.Status_gne__c != 'Payment Request Initiated') {
                event.Status_gne__c = 'Payment Request Initiated';
                eventsToUpdate.add(event);
            }
        }

        if (!eventsToUpdate.isEmpty()) {
            update eventsToUpdate;
        }
    }


    public static void createAttendeeForEventFromSpeakerRole(List<EMS_Speaker_Role_gne__c> triggerNew) {
        List<EMS_Attendee_gne__c> attendeesToInsert = new List<EMS_Attendee_gne__c>();

        Set<Id> eventIds = new Set<Id>();
        for (EMS_Speaker_Role_gne__c paymentRequest : triggerNew) {
            eventIds.add(paymentRequest.EMS_Event_gne__c);
        }

        // check for existing attendees
        Map<Id, Set<Id>> existingEventAttendees = new Map<Id, Set<Id>>();
        for (EMS_Attendee_gne__c attendee : [SELECT Account_gne__c, EMS_Event_gne__c FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :eventIds]) {
            if (!existingEventAttendees.containsKey(attendee.EMS_Event_gne__c)) {
                existingEventAttendees.put(attendee.EMS_Event_gne__c, new Set<Id>());
            }

            existingEventAttendees.get(attendee.EMS_Event_gne__c).add(attendee.Account_gne__c);
        }
        for (EMS_Speaker_Role_gne__c speakerRole : triggerNew) {
            if (existingEventAttendees.get(speakerRole.EMS_Event_gne__c) == null || /*(existingEventAttendees.get(speakerRole.EMS_Event_gne__c) != null && */!existingEventAttendees.get(speakerRole.EMS_Event_gne__c).contains(speakerRole.HCP_gne__c)) {
                EMS_Attendee_gne__c attendee = new EMS_Attendee_gne__c(Account_gne__c = speakerRole.HCP_gne__c, EMS_Event_gne__c = speakerRole.EMS_Event_gne__c, Status_gne__c = 'Attended', Role_gne__c = 'Speaker');
                attendeesToInsert.add(attendee);
            }
        }

        if (!attendeesToInsert.isEmpty()) {
            insert attendeesToInsert;
        }
    }

    public static void onAfterUpdate(List<EMS_Speaker_Role_gne__c> triggerNew) {
        updateEventStatus(triggerNew);
        createAttendeeForEventFromSpeakerRole(triggerNew);
    }

    public static void onAfterInsert(List<EMS_Speaker_Role_gne__c> triggerNew) {
        updateEventStatus(triggerNew);
        createAttendeeForEventFromSpeakerRole(triggerNew);
    }
}