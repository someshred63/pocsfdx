public without sharing class EMS_Roche_Attendee_Child_Rec_Updates {
    private static Map<Id, RecordType> rocheAttendeeRecordTypes;
    private static Set<Id> rocheAttendeeIds;
    private static Map<Id, Id> territoryGroupMap;  // TerritoryID, GroupID

    private static final String attendeeRowCause = Schema.EMS_Event__Share.RowCause.Event_Attendee__c;
    private static final String watcherRowCause = Schema.EMS_Event__Share.RowCause.Event_Watcher__c;

    public static void onAfterInsertOrUpdate(List<EMS_Roche_Attendee_gne__c> triggerNew) {
        getObjectRecordTypes(triggerNew);
        getGroupsRelatedToTerritory();
        createSharingRecordWithEvent(triggerNew);
    }

    public static void onBeforeDelete(List<EMS_Roche_Attendee_gne__c> triggerOld) {
        getObjectRecordTypes(triggerOld);
        getGroupsRelatedToTerritory();
        deleteSharingRecordWithEvent(triggerOld);
    }

    private static void getGroupsRelatedToTerritory() {
        Set<Id> territoriesIDs = new Set<Id>();
        for (List<EMS_Util.EMS_Territory> uts : EMS_Util.getUserTerritories(rocheAttendeeIds).values()) {
            for (EMS_Util.EMS_Territory ut : uts) {
                territoriesIDs.add(ut.Id);
            }
        }

        territoryGroupMap = EMS_Util.getTerritoriesGroups(territoriesIDs); // TerritoryID, GroupID
    }

    private static void getObjectRecordTypes(List<EMS_Roche_Attendee_gne__c> records) {
        Set<Id> recordTypeIDs = new Set<Id>();
        rocheAttendeeIds = new Set<Id>();
        for (EMS_Roche_Attendee_gne__c r : records) {
            recordTypeIDs.add(r.RecordTypeId);
            rocheAttendeeIds.add(r.User_gne__c);
        }
        rocheAttendeeRecordTypes = new Map<Id, RecordType>([SELECT Name, DeveloperName FROM RecordType WHERE Id IN :recordTypeIDs]);
    }

    private static void createSharingRecordWithEvent(List<EMS_Roche_Attendee_gne__c> triggerNew) {
        Set<String> existingEventSharesExternalIds = new Set<String>(); // set of external ids based on ParentId + UserOrGroupId pattern
        for (EMS_Event__Share existingEventShare : [SELECT AccessLevel, ParentId, UserOrGroupId, RowCause FROM EMS_Event__Share WHERE UserOrGroupId IN :rocheAttendeeIds]) {
            existingEventSharesExternalIds.add(String.valueOf(existingEventShare.ParentId) + String.valueOf(existingEventShare.UserOrGroupId) + existingEventShare.RowCause);
        }

        EMS_Event__Share eShare;
        List<EMS_Event__Share> eventShares = new List<EMS_Event__Share>();
        for (EMS_Roche_Attendee_gne__c rAttendee : triggerNew) {
            // record is a Watcher
            if (rAttendee.Is_Watcher_gne__c
                    && rAttendee.User_gne__c != null
                    ) {
                String existingEventSharesExternalId = (String.valueOf(rAttendee.EMS_Event_gne__c) + rAttendee.User_gne__c + watcherRowCause);
                if (!existingEventSharesExternalIds.contains(existingEventSharesExternalId)) {
                    eShare = new EMS_Event__Share(
                            ParentId = rAttendee.EMS_Event_gne__c,
                            UserOrGroupId = rAttendee.User_gne__c,
                            AccessLevel = 'Read',
                            RowCause = watcherRowCause
                    );
                    eventShares.add(eShare);
                }
                // record isn't a Watcher
            } else if (!rAttendee.Is_Watcher_gne__c
                    && rAttendee.User_gne__c != null
                    && String.isNotBlank(rAttendee.Territory_Id_gne__c)
                    && territoryGroupMap.containsKey(rAttendee.Territory_Id_gne__c)
                    ) {
                String existingEventSharesExternalId = String.valueOf(rAttendee.EMS_Event_gne__c) + String.valueOf(territoryGroupMap.get(rAttendee.Territory_Id_gne__c)) + attendeeRowCause;
                if (!existingEventSharesExternalIds.contains(existingEventSharesExternalId)) {
                    eShare = new EMS_Event__Share(
                            ParentId = rAttendee.EMS_Event_gne__c,
                            UserOrGroupId = territoryGroupMap.get(rAttendee.Territory_Id_gne__c),
                            AccessLevel = 'Read',
                            RowCause = attendeeRowCause
                    );
                    eventShares.add(eShare);
                }
            }
        }
        if (!eventShares.isEmpty()) {
            insert eventShares;
        }
    }

    private static void deleteSharingRecordWithEvent(List<EMS_Roche_Attendee_gne__c> triggerOld) {
        Set<Id> eventIDs = new Set<Id>();
        for (EMS_Roche_Attendee_gne__c attendee : triggerOld) {
            eventIDs.add(attendee.EMS_Event_gne__c);
        }

        // Group rAttendees by event Id
        Map<Id, Set<Id>> allrAttendeesByEvent = new Map<Id, Set<Id>>(); // EventId, Set<UserID>
        Set<String> allEventAttendees = new Set<String>();
        for (EMS_Roche_Attendee_gne__c att : [SELECT User_gne__c, EMS_Event_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c IN :eventIDs]) {
            allEventAttendees.add(att.User_gne__c);
            if (allrAttendeesByEvent.get(att.EMS_Event_gne__c) == null) {
                allrAttendeesByEvent.put(att.EMS_Event_gne__c, new Set<Id>());
            }
            allrAttendeesByEvent.get(att.EMS_Event_gne__c).add(att.User_gne__c);
        }
        // Find all attendees for each event and their territories

        Map<String, Set<Id>> allEventsUsersTerritoriesMap = EMS_Util.getTerritoriesUsers(allEventAttendees); // UserID, List<TerritoryID>

        // Check if there is another user for this event with the same territory
        List<Id> groupsToDelete = new List<Id>();
        for (EMS_Roche_Attendee_gne__c rAttendee : triggerOld) {
            // is not a Watcher
            if (!rAttendee.Is_Watcher_gne__c && String.isNotBlank(rAttendee.Territory_Id_gne__c)) {
                // Remove current attedne from event attendees
                Set<Id> eventAttendees = allrAttendeesByEvent.get(rAttendee.EMS_Event_gne__c);
                eventAttendees.remove(rAttendee.User_gne__c);
                // Prepare territories set of all other rAttendees.
                Set<Id> leftAttendeesTerritories = new Set<Id>();
                for (Id ea : eventAttendees) {
                    if (allEventsUsersTerritoriesMap.get(ea) != null) {
                        leftAttendeesTerritories.addAll(allEventsUsersTerritoriesMap.get(ea));
                    }
                }
                // Check if list of left territories contains territory of user to be removed. If not then sharing can be removed.
                if (allEventsUsersTerritoriesMap.containsKey(rAttendee.User_gne__c)) {
                    for (Id territoryId : allEventsUsersTerritoriesMap.get(rAttendee.User_gne__c)) {
                        if (!leftAttendeesTerritories.contains(rAttendee.Territory_Id_gne__c)) {
                            groupsToDelete.add(territoryGroupMap.get(rAttendee.Territory_Id_gne__c));
                        }
                    }
                }
                // is a Watcher
            } else if (rAttendee.Is_Watcher_gne__c) {
                groupsToDelete.add(rAttendee.User_gne__c);
            }
        }

        // Shares to delete
        if (!groupsToDelete.isEmpty()) {
            delete [SELECT Id FROM EMS_Event__Share where ParentId IN :eventIDs AND UserOrGroupId IN :groupsToDelete AND (RowCause = :attendeeRowCause OR RowCause = :watcherRowCause)];
        }
    }
}