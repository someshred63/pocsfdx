public without sharing class EMS_Roche_Attendee_Validation_Rules {

    public static boolean onBeforeInsert(List<EMS_Roche_Attendee_gne__c> triggerNew) {
        Boolean result = false;
        if (EMS_Roche_Attendee_Trigger_Helper.skipTriggerValidationRules == FALSE) {
            result = checkForDuplicatedRAttendees(triggerNew);
        }
        return result;
    }

    public static boolean checkForDuplicatedRAttendees(List<EMS_Roche_Attendee_gne__c> triggerNew) {
        String duplicatedAttString = System.label.Event_Adding_duplicate_attendees + ' ';

        List<Id> newrAttendeesEvents = new List<Id>(); //EMS_Event_gne__c Id
        Set<Id> duplicatedNewRAttendees = new Set<Id>();
        Set<Id> duplicatedExistingRAttendees = new Set<Id>();

        Map<Id, Set<Id>> newAttendeesByEvent = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> existingAttendeesByEvent = new Map<Id, Set<Id>>();

        // Check if list of new attendees contains duplicates
        for (EMS_Roche_Attendee_gne__c newRa : triggerNew) {
            if (newAttendeesByEvent.get(newRa.EMS_Event_gne__c) == null) {
                newAttendeesByEvent.put(newRa.EMS_Event_gne__c, new Set<Id>());
            }
            if (newAttendeesByEvent.get(newRa.EMS_Event_gne__c).contains(newRa.User_gne__c)) {
                duplicatedNewRAttendees.add(newRa.User_gne__c);
            }
            newAttendeesByEvent.get(newRa.EMS_Event_gne__c).add(newRa.User_gne__c);
            newrAttendeesEvents.add(newRa.EMS_Event_gne__c);
        }

        if (duplicatedNewRAttendees.size() > 0) {
            List<User> duplicatedUsers = [SELECT Firstname, Lastname FROM User WHERE Id IN :duplicatedNewRAttendees];
            for (User u : duplicatedUsers) {
                duplicatedAttString += +u.Firstname + ' ' + u.Lastname + ', ';
            }
            triggerNew[0].addError(duplicatedAttString.removeEnd(', '));
            return true;
        }

        // Check if there are duplicates with rAttendees already assigned to events
        for (EMS_Roche_Attendee_gne__c existingRa : [SELECT User_gne__c, EMS_Event_gne__c, EMS_Event_gne__r.Event_Owner_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c IN :newrAttendeesEvents]) {
            if (existingAttendeesByEvent.get(existingRa.EMS_Event_gne__c) == null) {
                existingAttendeesByEvent.put(existingRa.EMS_Event_gne__c, new Set<Id>());
            }
            existingAttendeesByEvent.get(existingRa.EMS_Event_gne__c).add(existingRa.User_gne__c);
        }

        if (existingAttendeesByEvent.size() > 0) {
            for (EMS_Roche_Attendee_gne__c ra : triggerNew) {
                if (existingAttendeesByEvent.containsKey(ra.EMS_Event_gne__c) && existingAttendeesByEvent.get(ra.EMS_Event_gne__c).contains(ra.User_gne__c)) {
                    duplicatedExistingRAttendees.add(ra.User_gne__c);
                }
            }
        }

        if (duplicatedExistingRAttendees.size() > 0) {
            List<User> duplicatedExistingUsers = [SELECT Firstname, Lastname FROM User WHERE Id IN :duplicatedExistingRAttendees];
            for (User u : duplicatedExistingUsers) {
                duplicatedAttString += +u.Firstname + ' ' + u.Lastname + ', ';
            }
            triggerNew[0].addError(duplicatedAttString.removeEnd(', '));
            return true;
        }

        return false;
    }
}