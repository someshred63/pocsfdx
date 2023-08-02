global without sharing class EMS_Event_Assignment_Batch implements Database.Batchable<sObject>, Database.Stateful {
    global Map<String, Set<Id>> territoryToUserMap = new Map<String, Set<Id>>(); // territory id, List<user id>
    global Id eventOwnerErrorId = Schema.SObjectType.EMS_Assignment_Error_gne__c.RecordTypeInfosByName.get('Event Owner Assignment Error').RecordTypeId;
    global Id eventRequestorErrorId = Schema.SObjectType.EMS_Assignment_Error_gne__c.RecordTypeInfosByName.get('Event Requestor Assignment Error').RecordTypeId;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Name, Event_Name_gne__c, Event_Owner_gne__c, Assigned_To_Territory_Owner_Id_gne__c, Assigned_To_Territory_Owner_gne__c, Event_Requestor_gne__c, ' +
                'Assigned_To_Territory_Requestor_Id_gne__c, Assigned_To_Territory_Requestor_gne__c FROM EMS_Event__c WHERE Status_gne__c != \'Closed\' AND Status_gne__c != \'Cancelled\'');
    }

    global Boolean hasOneTerritoryMember(String territoryId) {
        return territoryToUserMap.get(territoryId) != null && territoryToUserMap.get(territoryId).size() == 1;
    }

    global Id findTerritoryMember(String territoryId) {
        return hasOneTerritoryMember(territoryId) ? new List<Id>(territoryToUserMap.get(territoryId))[0] : null;
    }

    global void handleAssignmentErrors(Set<Id> eventIds, Map<Id, String> missingRequestor, Map<Id, String> missingOwners) {
        // Clear obsolate assignment errors
        eventIds.removeAll(missingOwners.keySet());
        eventIds.removeAll(missingRequestor.keySet());
        System.debug('>>> events to clear assignment errors: ' + eventIds.size());
        Database.delete([
                SELECT id
                FROM EMS_Assignment_Error_gne__c
                WHERE EMS_Event_gne__c IN :eventIds
        ], false);


        // Query existing assignment errors
        Map<String, EMS_Assignment_Error_gne__c> existingAssignmentErrors = new Map<String, EMS_Assignment_Error_gne__c>();
        for (EMS_Assignment_Error_gne__c assignmentError : [SELECT EMS_Event_gne__c, RecordTypeId FROM EMS_Assignment_Error_gne__c WHERE EMS_Event_gne__c IN :missingRequestor.keySet() OR EMS_Event_gne__c IN :missingOwners.keySet()]) {
            existingAssignmentErrors.put(String.valueOf(assignmentError.EMS_Event_gne__c) + String.valueOf(assignmentError.RecordTypeId), assignmentError);
        }

        List<EMS_Assignment_Error_gne__c> assignmentErrorsToUpsert = new List<EMS_Assignment_Error_gne__c>();

        for (Id eventId : missingOwners.keySet()) {
            String errorMessage = 'Could not assign the event to the new owner.';
            if (!String.isBlank(missingOwners.get(eventId))) {
                errorMessage += missingOwners.get(eventId);
            }

            String key = String.valueOf(eventId) + String.valueOf(eventOwnerErrorId);
            EMS_Assignment_Error_gne__c error = null;
            if (!existingAssignmentErrors.containsKey(key)) {
                assignmentErrorsToUpsert.add(new EMS_Assignment_Error_gne__c(EMS_Event_gne__c = eventId, Error_Message_gne__c = errorMessage, RecordTypeId = eventOwnerErrorId));
            } else {
                existingAssignmentErrors.get(key).Error_Message_gne__c = errorMessage;
                assignmentErrorsToUpsert.add(existingAssignmentErrors.get(key));
            }
        }

        for (Id eventId : missingRequestor.keySet()) {
            String errorMessage = 'Could not assign the event to the new requestor.';
            if (!String.isBlank(missingRequestor.get(eventId))) {
                errorMessage += missingRequestor.get(eventId);
            }

            String key = String.valueOf(eventId) + String.valueOf(eventRequestorErrorId);
            if (!existingAssignmentErrors.containsKey(key)) {
                assignmentErrorsToUpsert.add(new EMS_Assignment_Error_gne__c(EMS_Event_gne__c = eventId, Error_Message_gne__c = errorMessage, RecordTypeId = eventRequestorErrorId));
            } else {
                existingAssignmentErrors.get(key).Error_Message_gne__c = errorMessage;
                assignmentErrorsToUpsert.add(existingAssignmentErrors.get(key));
            }
        }

        if (!assignmentErrorsToUpsert.isEmpty()) {
            Database.upsert(assignmentErrorsToUpsert, false);
        }
    }

    // Scope size is expected to be 50 records
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<String> territoryIds = new Set<String>();
        Map<Id, EMS_Event__c> eventsToUpdate = new Map<Id, EMS_Event__c>();
        Map<Id, String> eventsWithMissingOwnerTerritory = new Map<Id, String>();
        Map<Id, String> eventsWithMissingRequestorTerritory = new Map<Id, String>();
        Set<Id> eventsWithRequestorUpdated = new Set<Id>();
        Set<Id> eventsWithOwnerUpdated = new Set<Id>();

        for (EMS_Event__c event : (List<EMS_Event__c>) scope) {
            territoryIds.add(event.Assigned_To_Territory_Requestor_Id_gne__c);
            territoryIds.add(event.Assigned_To_Territory_Owner_Id_gne__c);
        }

        //select territory info
        territoryToUserMap.putAll(EMS_Util.getTerritoriesUsers(territoryIds));

        Id territoryMemberId = null;
        for (EMS_Event__c event : (List<EMS_Event__c>) scope) {
            if (hasOneTerritoryMember(event.Assigned_To_Territory_Owner_Id_gne__c)) {
                territoryMemberId = findTerritoryMember(event.Assigned_To_Territory_Owner_Id_gne__c);
                if (event.Event_Owner_gne__c != territoryMemberId) {
                    if (!eventsToUpdate.containsKey(event.Id)) eventsToUpdate.put(event.Id, event);
                    eventsToUpdate.get(event.Id).Event_Owner_gne__c = territoryMemberId;
                    eventsWithOwnerUpdated.add(event.Id);
                }
            } else {
                eventsWithMissingOwnerTerritory.put(event.Id, String.valueOf(territoryToUserMap.get(event.Assigned_To_Territory_Owner_Id_gne__c)));
            }

            if (hasOneTerritoryMember(event.Assigned_To_Territory_Requestor_Id_gne__c)) {
                territoryMemberId = findTerritoryMember(event.Assigned_To_Territory_Requestor_Id_gne__c);
                if (event.Event_Requestor_gne__c != territoryMemberId) {
                    if (!eventsToUpdate.containsKey(event.Id)) eventsToUpdate.put(event.Id, event);
                    eventsToUpdate.get(event.Id).Event_Requestor_gne__c = territoryMemberId;
                    eventsWithRequestorUpdated.add(event.Id);
                }
            } else {
                eventsWithMissingRequestorTerritory.put(event.Id, String.valueOf(territoryToUserMap.get(event.Assigned_To_Territory_Requestor_Id_gne__c)));
            }
        }

        if (!eventsToUpdate.isEmpty()) {
            List<EMS_Event__c> events = eventsToUpdate.values();
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;

            Database.SaveResult [] results = Database.update(events, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    // add error
                    if (eventsWithOwnerUpdated.contains(events[i].Id)) {
                        eventsWithMissingOwnerTerritory.put(events[i].Id, results[i].getErrors()[0].getMessage());
                    }
                    if (eventsWithRequestorUpdated.contains(events[i].Id)) {
                        eventsWithMissingRequestorTerritory.put(events[i].Id, results[i].getErrors()[0].getMessage());
                    }
                }
            }
        }

        System.debug('>>> events with updated owner: ' + eventsWithOwnerUpdated.size());
        System.debug('>>> events with updated requestor: ' + eventsWithRequestorUpdated.size());
        System.debug('>>> events w/o owner: ' + eventsWithMissingOwnerTerritory.size());
        System.debug('>>> events w/o requestor : ' + eventsWithMissingRequestorTerritory.size());

        handleAssignmentErrors(eventsToUpdate.keySet().clone(), eventsWithMissingRequestorTerritory, eventsWithMissingOwnerTerritory);
    }

    global void finish(Database.BatchableContext BC) {
        List<String> mails = EMS_Util.getApplicationAdminsEmails();
        EMS_Email.prepareSingleEmail('EMS_Batch_Job_Notification', BC.getJobId(), mails);
        EMS_Email.Send();
    }
}