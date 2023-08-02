public without sharing class EMS_Event_Child_Records_Update {

    private static final String eventApproverRowCause = Schema.EMS_Event__Share.RowCause.Event_Approver__c;
    private static Map<Id, Schema.RecordTypeInfo> budgetAllocationRecordTypes = EMS_Budget_Allocation_gne__c.SObjectType.getDescribe().getRecordTypeInfosById();

    public static void onAfterInsert(Map<Id, EMS_Event__c> triggerNew) {
        notifyOwnerRequestorAboutEventClosure(null, triggerNew);
        shareEventWithOwnerRequestorTerritories(triggerNew, null);
        createRocheAttendeeFromEventRequestor(triggerNew);   // insert attendees
    }

    public static void onAfterUpdate(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        adjustAllocatedAmountOnRelatedBudgetEventCloseCancel(triggerOld, triggerNew);
        createInteractionsForClosedEvent(triggerOld, triggerNew);
        shareEventWithOwnerRequestorTerritories(triggerNew, triggerOld);
        shareEventWithApprover(triggerOld, triggerNew);
        notifyOwnerRequestorAboutEventClosure(triggerOld, triggerNew);
        startBudgetAllocationApproval(triggerOld, triggerNew);
        recallBudgetApproval(triggerOld, triggerNew);

        // handle FMV fields value for each related Attendee record
        handleFMVAttendeeFields(triggerOld, triggerNew);
        recalculateTotalHonorariumAmount(triggerOld, triggerNew);

        // create attendee
        createRocheAttendeeFromEventRequestor(triggerNew);  // insert attendees

        // delete related objects
        deleteUpdateGSDDetails(triggerOld, triggerNew);
        deleteInvestments(triggerOld, triggerNew);
        deleteTravels(triggerOld, triggerNew);
        deleteAttendees(triggerOld, triggerNew);
        deleteBudgetAllocationsOnEventTypeChange(triggerOld, triggerNew);
        detachDependentSpeakerTourEvents(triggerOld, triggerNew);
        updateStatusOnSpeakerToursWhenContractUploaded(triggerOld, triggerNew);
    }

    private static Boolean isConsultingMeeting(EMS_Event__c event) {
        return String.isNotBlank(event.Event_Sub_Type_gne__c) && (
                event.Event_Sub_Type_gne__c.startsWithIgnoreCase('Consultancy Meeting')
        );
    }

    private static Boolean isPreceptorships(EMS_Event__c event) {
        return event.Event_Sub_Type_gne__c == 'Preceptorships (HCP to Roche)' ||
                event.Event_Sub_Type_gne__c == 'Preceptorships (Roche to HCP)' ||
                event.Event_Sub_Type_gne__c == 'Preceptorships (HCP to HCP)';
    }

    private static Boolean isInformalConsulting(EMS_Event__c event) {
        return String.isNotBlank(event.Event_Sub_Type_gne__c) && (
                event.Event_Sub_Type_gne__c.startsWith('Informal consulting') ||
                        event.Event_Sub_Type_gne__c == 'Speaking Session (HCP to Roche)'
        );
    }

    private static Boolean isPanelRoundTable(EMS_Event__c event) {
        return String.isNotBlank(event.Event_Sub_Type_gne__c) &&
                event.Event_Sub_Type_gne__c.startsWith('Panel/Round Table');
    }

    private static Boolean isOLA_CHE(EMS_Event__c event) {
        return event.Event_Type_gne__c == 'Learning Programs' &&
                event.Event_Sub_Type_gne__c != null && (
                event.Event_Sub_Type_gne__c.contains('OLA') ||
                        event.Event_Sub_Type_gne__c.contains('CHE')
        );
    }

    private static void handleFMVAttendeeFields(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        Set<Id> eventIdsToClearFMV = new Set<Id>();
        for (Id eventId : triggerNew.keySet()) {
            EMS_Event__c previousEvent = triggerOld.get(eventId);
            EMS_Event__c currentEvent = triggerNew.get(eventId);
            if (isConsultingMeeting(previousEvent) != isConsultingMeeting(currentEvent)) {
                eventIdsToClearFMV.add(eventId);
            } else if (isPreceptorships(previousEvent) != isPreceptorships(currentEvent)) {
                eventIdsToClearFMV.add(eventId);
            } else if (isInformalConsulting(previousEvent) != isInformalConsulting(currentEvent)) {
                eventIdsToClearFMV.add(eventId);
            } else if (isOLA_CHE(previousEvent) != isOLA_CHE(currentEvent)) {
                eventIdsToClearFMV.add(eventId);
            } else if (isPanelRoundTable(previousEvent) != isPanelRoundTable(currentEvent)) {
                eventIdsToClearFMV.add(eventId);
            }
        }
        if (eventIdsToClearFMV.isEmpty()) {
            return;
        }

        List<EMS_Attendee_gne__c> attendeesToClearFMV = [
                SELECT Preparation_Time_1_gne__c, Preparation_Time_2_gne__c, Preparation_Time_3_gne__c, Preparation_Time_4_gne__c, Preparation_Time_5_gne__c, Preparation_Time_6_gne__c,
                        Activity_Time_gne__c, Disturbance_Fee__c, km_gne__c, Type_of_HCP_other_gne__c, HCP_hourly_rate_table_gne__c, Type_of_HCP_gne__c, Total_Honoraria_gne__c,
                        Activity_Time_1_gne__c, Activity_Time_2_gne__c, Activity_Time_3_gne__c, Activity_Time_4_gne__c, Activity_Time_5_gne__c, Activity_Time_6_gne__c
                FROM EMS_Attendee_gne__c
                WHERE EMS_Event_gne__c IN :eventIdsToClearFMV
        ];
        if (attendeesToClearFMV.isEmpty()) {
            return;
        }

        System.debug('>>>> clearAttendeeFieldsValues');
        for (EMS_Attendee_gne__c attendee : attendeesToClearFMV) {
            EMS_Attendee_Field_Updates.clearAttendeeFieldsValues(attendee);
        }
        update attendeesToClearFMV;
    }

    private static void detachDependentSpeakerTourEvents(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        // *******  Don't we need to push this part to Javascript ??
        Set<Id> parentTourIds = new Set<Id>();
        for (Id key : triggerNew.keySet()) {
            if (triggerOld.get(key).Speaker_Tour_gne__c == true && triggerNew.get(key).Speaker_Tour_gne__c == false) {
                parentTourIds.add(key);
            }
        }
        if (parentTourIds.isEmpty()) {
            return;
        }

        List<EMS_Event__c> relatedEventsToDetach = [SELECT Parent_Speaker_Tour_Event_gne__c FROM EMS_Event__c WHERE Parent_Speaker_Tour_Event_gne__c IN :parentTourIds LIMIT 1000];
        for (EMS_Event__c relatedEvent : relatedEventsToDetach) {
            relatedEvent.Parent_Speaker_Tour_Event_gne__c = null;
        }
        update relatedEventsToDetach;
    }

    private static void updateStatusOnSpeakerToursWhenContractUploaded(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (Id key : triggerNew.keySet()) {
            Boolean wasNotSigned = (triggerOld.get(key).Status_gne__c != 'Signed Agreement Received');
            Boolean isNowSigned = (triggerNew.get(key).Status_gne__c == 'Signed Agreement Received');
            if (wasNotSigned && isNowSigned && triggerNew.get(key).Speaker_Tour_gne__c) {
                eventIds.add(key);
            }
        }
        if (eventIds.isEmpty()) {
            return;
        }

        List<EMS_Event__c> speakerTourEvents = [SELECT Status_gne__c FROM EMS_Event__c WHERE Parent_Speaker_Tour_Event_gne__c IN :eventIds];
        for (EMS_Event__c speakerTour : speakerTourEvents) {
            if (speakerTour.Status_gne__c == 'Med Ops Approved' || speakerTour.Status_gne__c == 'Awaiting Signature from HCP') {
                speakerTour.Status_gne__c = 'Signed Agreement Received';
            }
        }
        update speakerTourEvents;
    }

    public static void onBeforeDelete(Map<Id, EMS_Event__c> triggerOld) {
        // invoke explicitly because cascade deletes do not cause the triggers on the child object to be fired
        updateAllocatedAmountOnDelete(triggerOld);
    }

    private static void adjustAllocatedAmountOnRelatedBudgetEventCloseCancel(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        Map<Id, EMS_Budget_Product_gne__c> productBudgetListToUpdate = new Map<Id, EMS_Budget_Product_gne__c>();
        Map<Id, EMS_Budget_Region_gne__c> regionBudgetListToUpdate = new Map<Id, EMS_Budget_Region_gne__c>();
        Map<Id, EMS_Budget_Territory_gne__c> territoryBudgetListToUpdate = new Map<Id, EMS_Budget_Territory_gne__c>();

        Set<Id> closedCancelledEventIds = new Set<Id>();
        for (EMS_Event__c event : triggerNew.values()) {
            Boolean isNotProcessed = !EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id);
            Boolean isClosedNow = (triggerOld.get(event.Id).Status_gne__c != 'Closed' && event.Status_gne__c == 'Closed');
            Boolean isCancelledNow = (triggerOld.get(event.Id).Status_gne__c != 'Cancelled' && event.Status_gne__c == 'Cancelled');
            Boolean isUnClosedNow = (triggerOld.get(event.Id).Status_gne__c == 'Closed' && event.Status_gne__c != 'Closed');
            Boolean isUnCanceledNow = (triggerOld.get(event.Id).Status_gne__c == 'Cancelled' && event.Status_gne__c != 'Cancelled');

            if (isNotProcessed && (isClosedNow || isCancelledNow || isUnClosedNow || isUnCanceledNow)) {
                closedCancelledEventIds.add(event.Id);
            }
        }
        if (closedCancelledEventIds.isEmpty()) {
            return;
        }

        Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocations = new Map<Id, EMS_Budget_Allocation_gne__c>([
                SELECT RecordTypeId, Allocated_Budget_gne__c, Budget_Deductions_gne__c, EMS_Product_Budget_gne__r.Events_Allocated_Amount__c, EMS_Event_gne__c,
                        EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c, EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c, EMS_Event_gne__r.Status_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE EMS_Event_gne__c IN :closedCancelledEventIds
        ]);
        for (EMS_Budget_Allocation_gne__c budgetAllocation : budgetAllocations.values()) {
            Decimal correction;
            if (budgetAllocation.EMS_Event_gne__r.Status_gne__c == 'Closed' || budgetAllocation.EMS_Event_gne__r.Status_gne__c == 'Cancelled') {
                correction = budgetAllocation.Budget_Deductions_gne__c - budgetAllocation.Allocated_Budget_gne__c;
            } else {
                correction = budgetAllocation.Allocated_Budget_gne__c - budgetAllocation.Budget_Deductions_gne__c;
            }
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation' && budgetAllocations.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c != null) {
                if (productBudgetListToUpdate.get(budgetAllocation.EMS_Product_Budget_gne__c) == null) {
                    EMS_Budget_Product_gne__c bp = new EMS_Budget_Product_gne__c(
                            Id = budgetAllocation.EMS_Product_Budget_gne__c,
                            Events_Allocated_Amount__c = budgetAllocations.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c + correction
                    );
                    productBudgetListToUpdate.put(budgetAllocation.EMS_Product_Budget_gne__c, bp);
                } else {
                    productBudgetListToUpdate.get(budgetAllocation.EMS_Product_Budget_gne__c).Events_Allocated_Amount__c += correction;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation' && budgetAllocations.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                if (regionBudgetListToUpdate.get(budgetAllocation.EMS_Region_Budget_gne__c) == null) {
                    EMS_Budget_Region_gne__c br = new EMS_Budget_Region_gne__c(
                            Id = budgetAllocation.EMS_Region_Budget_gne__c,
                            Events_Allocated_Amount_gne__c = budgetAllocations.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c + correction
                    );
                    regionBudgetListToUpdate.put(budgetAllocation.EMS_Region_Budget_gne__c, br);
                } else {
                    regionBudgetListToUpdate.get(budgetAllocation.EMS_Region_Budget_gne__c).Events_Allocated_Amount_gne__c += correction;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation' && budgetAllocations.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                if (territoryBudgetListToUpdate.get(budgetAllocation.EMS_Territory_Budget_gne__c) == null) {
                    EMS_Budget_Territory_gne__c bt = new EMS_Budget_Territory_gne__c(
                            Id = budgetAllocation.EMS_Territory_Budget_gne__c,
                            Events_Allocated_Amount_gne__c = budgetAllocations.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c + correction
                    );
                    territoryBudgetListToUpdate.put(budgetAllocation.EMS_Territory_Budget_gne__c, bt);
                } else {
                    territoryBudgetListToUpdate.get(budgetAllocation.EMS_Territory_Budget_gne__c).Events_Allocated_Amount_gne__c += correction;
                }
            }
        }

        // disable validation rules for related budgets
        EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;
        if (!productBudgetListToUpdate.isEmpty()) {
            update productBudgetListToUpdate.values();
        }
        if (!regionBudgetListToUpdate.isEmpty()) {
            update regionBudgetListToUpdate.values();
        }
        if (!territoryBudgetListToUpdate.isEmpty()) {
            update territoryBudgetListToUpdate.values();
        }
    }

    private static void createInteractionsForClosedEvent(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        Id interactionRecordType = Schema.SObjectType.Call2_vod__c.recordTypeInfosByName.get('SFA Canada Interaction').recordTypeId;
        List<EMS_Event__c> closedEvents = new List<EMS_Event__c>();
        for (EMS_Event__c event : triggerNew.values()) {
            Boolean isNotProcessed = !EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id);
            Boolean gotClosed = (triggerOld.get(event.Id).Status_gne__c != 'Closed' && event.Status_gne__c == 'Closed');
            if (isNotProcessed && gotClosed) {
                closedEvents.add(event);
            }
        }
        if (closedEvents.isEmpty()) {
            return;
        }

        closedEvents = [
                SELECT Id, (
                        SELECT Territory_gne__c, Product_gne__c, Product_Strategy_gne__c, Product_Tactic_gne__c, Reaction_gne__c, EMS_Event__r.End_Date_gne__c,
                                Product_gne__r.Name, EMS_Attendee_gne__r.Account_gne__c, EMS_Attendee_gne__r.Contact_gne__c, EMS_Attendee_gne__r.Contact_gne__r.Active_gne__c,
                                EMS_Attendee_gne__r.EMS_International_Speaker_gne__c, Tool_gne__c, Quantity_gne__c, EMS_Roche_Attendee__r.User_gne__c
                        FROM EMS_Interactions__r
                )
                FROM EMS_Event__c
                WHERE Id IN :closedEvents
        ];

        Map<Id, List<Call2_vod__c>> callsToInsert = new Map<Id, List<Call2_vod__c>>();
        Map<Id, List<Call2_vod__c>> interactionToCallMap = new Map<Id, List<Call2_vod__c>>(); // EMS_Interaction_gne__c -> Call2_vod__c
        Map<Id, List<Call2_vod__c>> parentInteractionToCallMap = new Map<Id, List<Call2_vod__c>>(); // EMS_Interaction_gne__c -> Call2_vod__c
        for (EMS_Event__c closedEvent : closedEvents) {
            for (EMS_Interaction_gne__c interaction : closedEvent.EMS_Interactions__r) {
                if (interaction.EMS_Attendee_gne__r.Account_gne__c != null && interaction.EMS_Attendee_gne__r.Contact_gne__c == null) {
                    // interaction with account
                    Call2_vod__c newCall = prepareCallObject(interaction, interactionRecordType);
                    putCallIntoMap(callsToInsert, closedEvent.Id, newCall);
                    putCallIntoMap(interactionToCallMap, interaction.Id, newCall);
                } else if (interaction.EMS_Attendee_gne__r.Account_gne__c == null && interaction.EMS_Attendee_gne__r.Contact_gne__c != null) {
                    // interaction with contact - create the interaction with Account associated with Contact (interaction with Contact is created later)
                    Call2_vod__c parentCall = prepareCallObject(interaction, interactionRecordType);
                    putCallIntoMap(callsToInsert, closedEvent.Id, parentCall);
                    putCallIntoMap(interactionToCallMap, interaction.Id, parentCall);
                    putCallIntoMap(parentInteractionToCallMap, interaction.Id, parentCall);
                }
            }
        }

        List<Call2_vod__c> mainCallListToInsert = new List<Call2_vod__c>(); // Is used for not to call Insert operation twice
        if (!callsToInsert.isEmpty()) {
            List<Call2_vod__c> listOfCallsToInsert = new List<Call2_vod__c>();
            for (List<Call2_vod__c> l : callsToInsert.values()) {
                listOfCallsToInsert.addAll(l);
            }
            mainCallListToInsert.addAll(listOfCallsToInsert);
        }

        List<Call2_vod__c> childAccountCallsToInsert = new List<Call2_vod__c>();
        for (EMS_Event__c closedEvent : closedEvents) {
            for (EMS_Interaction_gne__c interaction : closedEvent.EMS_Interactions__r) {
                // create child calls
                if (parentInteractionToCallMap.containsKey(interaction.Id)) {
                    for (Call2_vod__c call : parentInteractionToCallMap.get(interaction.Id)) {
                        Call2_vod__c childCall = prepareChildAccountCallObject(call, interaction, interactionRecordType);
                        putCallIntoMap(interactionToCallMap, interaction.Id, childCall);
                        childAccountCallsToInsert.add(childCall);
                    }
                }
            }
        }
        if (!childAccountCallsToInsert.isEmpty()) {
            mainCallListToInsert.addAll(childAccountCallsToInsert);
        }
        if (!mainCallListToInsert.isEmpty()) {
            insert mainCallListToInsert;
        }

        List<Call2_Sample_vod__c> callSamplesToInsert = new List<Call2_Sample_vod__c>();
        List<Call2_Detail_vod__c> callDetailsToInsert = new List<Call2_Detail_vod__c>();
        List<Call2_Discussion_vod__c> callDiscussionsToInsert = new List<Call2_Discussion_vod__c>();
        for (EMS_Event__c closedEvent : closedEvents) {
            for (EMS_Interaction_gne__c interaction : closedEvent.EMS_Interactions__r) {
                // create call detail and call discussion object
                if (interactionToCallMap.containsKey(interaction.Id)) {
                    for (Call2_vod__c call : interactionToCallMap.get(interaction.Id)) {
                        callDetailsToInsert.add(prepareCallDetailObject(call, interaction));
                        callDiscussionsToInsert.add(prepareCallDiscussionObject(call, interaction));

                        // create sample only when the Tool was selected
                        if (interaction.Tool_gne__c != null) {
                            callSamplesToInsert.add(prepareCallSampleObject(call, interaction));
                        }
                    }
                }
            }
        }
        if (callDiscussionsToInsert.size() > 0) {
            insert callDiscussionsToInsert;
        }
        if (callDetailsToInsert.size() > 0) {
            insert callDetailsToInsert;
        }
        if (callSamplesToInsert.size() > 0) {
            insert callSamplesToInsert;
        }
    }

    private static Map<Id, Id> getGroupsRelatedToTerritory(Map<Id, EMS_Event__c> triggerNew) {
        Set<Id> relatedTerritories = new Set<Id>();
        for (EMS_Event__c event : triggerNew.values()) {
            if (event.Assigned_To_Territory_Owner_Id_gne__c != null) {
                relatedTerritories.add(event.Assigned_To_Territory_Owner_Id_gne__c);
            }
            if (event.Assigned_To_Territory_Requestor_Id_gne__c != null) {
                relatedTerritories.add(event.Assigned_To_Territory_Requestor_Id_gne__c);
            }
        }
        return EMS_Util.getTerritoriesGroups(relatedTerritories);
    }

    private static void shareEventWithOwnerRequestorTerritories(Map<Id, EMS_Event__c> triggerNew, Map<Id, EMS_Event__c> triggerOld) {
        Map<Id, Id> relatedGroups = getGroupsRelatedToTerritory(triggerNew);
        List<EMS_Event__Share> eventSharesToInsert = new List <EMS_Event__Share>();
        Set<String> existingEventSharesExternalIds = new Set<String>(); // set of external ids based on ParentId + UserOrGroupId pattern
        for (EMS_Event__Share existingEventShare : [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Event__Share WHERE ParentId IN :triggerNew.values()]) {
            existingEventSharesExternalIds.add(String.valueOf(existingEventShare.ParentId) + String.valueOf(existingEventShare.UserOrGroupId) + String.valueOf(existingEventShare.RowCause));
        }

        String eventOwnerRowCause = Schema.EMS_Event__Share.RowCause.Event_Owner__c;
        String eventRequestorRowCause = Schema.EMS_Event__Share.RowCause.Event_Requestor__c;
        Set<Id> requestorParentIdsToRemove = new Set<Id>();
        Set<Id> ownerParentIdsToRemove = new Set<Id>();
        for (EMS_Event__c event : triggerNew.values()) {
            Boolean ownerTerritoryChanged = triggerOld == null
                    || triggerOld.get(event.Id).Assigned_To_Territory_Owner_Id_gne__c != event.Assigned_To_Territory_Owner_Id_gne__c;
            Boolean requestorTerritoryChanged = triggerOld == null
                    || triggerOld.get(event.Id).Assigned_To_Territory_Requestor_Id_gne__c != event.Assigned_To_Territory_Requestor_Id_gne__c;

            if (event.Assigned_To_Territory_Owner_Id_gne__c != null
                    && ownerTerritoryChanged
                    && relatedGroups.containsKey(event.Assigned_To_Territory_Owner_Id_gne__c)
                    && !existingEventSharesExternalIds.contains(String.valueOf(event.Id) + String.valueOf(relatedGroups.get(event.Assigned_To_Territory_Owner_Id_gne__c)) + String.valueOf(eventOwnerRowCause))
                    ) {
                EMS_Event__Share eShare = new EMS_Event__Share(
                        ParentId = event.Id,
                        UserOrGroupId = relatedGroups.get(event.Assigned_To_Territory_Owner_Id_gne__c),
                        AccessLevel = 'Edit',
                        RowCause = eventOwnerRowCause
                );
                eventSharesToInsert.add(eShare);
                ownerParentIdsToRemove.add(event.Id);
            }
            if (event.Assigned_To_Territory_Requestor_Id_gne__c != null
                    && requestorTerritoryChanged
                    && relatedGroups.containsKey(event.Assigned_To_Territory_Requestor_Id_gne__c)
                    && !existingEventSharesExternalIds.contains(String.valueOf(event.Id) + String.valueOf(relatedGroups.get(event.Assigned_To_Territory_Requestor_Id_gne__c)) + String.valueOf(eventRequestorRowCause))
                    ) {
                EMS_Event__Share eShare = new EMS_Event__Share(
                        ParentId = event.Id,
                        UserOrGroupId = relatedGroups.get(event.Assigned_To_Territory_Requestor_Id_gne__c),
                        AccessLevel = 'Edit',
                        RowCause = eventRequestorRowCause
                );
                eventSharesToInsert.add(eShare);
                requestorParentIdsToRemove.add(event.Id);
            }
        }

        if (!ownerParentIdsToRemove.isEmpty() || !requestorParentIdsToRemove.isEmpty()) {
            List<EMS_Event__Share> sharesToDelete = new List<EMS_Event__Share>();
            sharesToDelete.addAll([
                    SELECT Id
                    FROM EMS_Event__Share
                    WHERE (ParentId IN :ownerParentIdsToRemove AND RowCause = :eventOwnerRowCause) OR
                    (ParentId IN :requestorParentIdsToRemove AND RowCause = :eventRequestorRowCause)
            ]);
            if (!sharesToDelete.isEmpty()) {
                delete sharesToDelete;
            }
        }

        if (!eventSharesToInsert.isEmpty()) {
            insert eventSharesToInsert;
        }
    }

    private static void shareEventWithApprover(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {

        // This method could be combined with shareEventWithOwnerRequestorTerritories to have a few SOQL additional queries ???
        List<EMS_Event__c> eventsWithUpdatedApprover = new List<EMS_Event__c>();
        Set<Id> eventApproverIds = new Set<Id>();
        for (EMS_Event__c event : triggerNew.values()) {
            if (triggerOld == null || triggerOld.get(event.Id).Approver_gne__c != event.Approver_gne__c) {
                eventsWithUpdatedApprover.add(event);
                eventApproverIds.add(event.Approver_gne__c);
            }
        }
        if (eventsWithUpdatedApprover.isEmpty()) {
            return;
        }

        Map<Id, User> activeApprovers = new Map<Id, User>([SELECT Id FROM User WHERE Id IN :eventApproverIds AND IsActive = TRUE]);
        Set<String> existingEventSharesExternalIds = new Set<String>(); // set of external ids based on ParentId + UserOrGroupId pattern
        for (EMS_Event__Share existingEventShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Event__Share WHERE ParentId IN :triggerNew.values()]) {
            existingEventSharesExternalIds.add(String.valueOf(existingEventShare.ParentId) + String.valueOf(existingEventShare.UserOrGroupId) + String.valueOf(existingEventShare.RowCause));
        }

        List<EMS_Event__Share> eventSharesToInsert = new List<EMS_Event__Share>();
        Set<Id> ownerParentIdsToRemove = new Set<Id>();
        for (EMS_Event__c event : eventsWithUpdatedApprover) {
            Id approver = event.Approver_gne__c;
            String eventSharesExternalId = (String.valueOf(event.Id) + String.valueOf(event.Approver_gne__c) + String.valueOf(eventApproverRowCause));
            if (approver != null && activeApprovers.containsKey(approver) && !existingEventSharesExternalIds.contains(eventSharesExternalId)) {
                EMS_Event__Share eShare = new EMS_Event__Share(
                        ParentId = event.Id,
                        UserOrGroupId = event.Approver_gne__c,
                        AccessLevel = 'Edit',
                        RowCause = eventApproverRowCause
                );
                eventSharesToInsert.add(eShare);
                ownerParentIdsToRemove.add(event.Id);
            }
        }
        if (!ownerParentIdsToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Event__Share WHERE ParentId IN :ownerParentIdsToRemove AND RowCause = :eventApproverRowCause];
        }
        if (!eventSharesToInsert.isEmpty()) {
            insert eventSharesToInsert;
        }
    }

    private static void notifyOwnerRequestorAboutEventClosure(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew.values()) {
            Boolean isNotProcessed = !EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id);
            Boolean startInDecember = (event.Start_Date_gne__c != null && event.Start_Date_gne__c.month() == 12);
            Boolean changedToStartInDecember = (triggerOld == null || (triggerOld.get(event.Id).Start_Date_gne__c != null && triggerOld.get(event.Id).Start_Date_gne__c.month() != 12 && event.Start_Date_gne__c.month() == 12));

            if (isNotProcessed && startInDecember && changedToStartInDecember) {
                EMS_Email.prepareSingleEmail('EMS_Event_Action_Needed_Notification', event.Id, event.Event_Requestor_gne__c);
                EMS_Email.prepareSingleEmail('EMS_Event_Action_Needed_Notification', event.Id, event.Event_Owner_gne__c);
            }
        }
        EMS_Email.send();
    }

    private static void deleteInvestments(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Event__c event : triggerNew.values()) {
            Boolean isNotProcessed = !EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id);
            if (isNotProcessed && event.Investment_gne__c != 'HCO' && triggerOld.get(event.Id).Investment_gne__c == 'HCO') {
                eventIds.add(event.Id);
            }
        }
        if (!eventIds.isEmpty()) {
            delete [SELECT Id FROM EMS_Investment_gne__c WHERE EMS_Event_gne__c IN :eventIds];
        }
    }

    private static void deleteUpdateGSDDetails(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        Set<Id> eventIdsToResetGSD = new Set<Id>();
        for (EMS_Event__c event : triggerNew.values()) {
            Boolean isNotProcessed = !EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id);
            EMS_Event__c oldEvent = triggerOld.get(event.Id);
            Boolean shouldDeleteGsdDetail = event.Is_GSD_Event_gne__c == false &&
                    event.Is_GSD_Event_gne__c <> oldEvent.Is_GSD_Event_gne__c;
            if (isNotProcessed && shouldDeleteGsdDetail) {
                // Make sure GSD detail is removed
                eventIds.add(event.Id);
            } else if (isNotProcessed && EMS_Event_Trigger_Helper.typeHasChanged) { // the flag forces resetting GSD Type picklist
                // If GSD ain't gonna be deleted, we check the flag
                eventIdsToResetGSD.add(event.Id);
            }
        }
        if (!eventIds.isEmpty()) {
            List<EMS_GSD_Detail__c> gsdDetailsToDelete = [SELECT Id FROM EMS_GSD_Detail__c WHERE EMS_Event__c IN :eventIds];
            if (!gsdDetailsToDelete.isEmpty()) {
                delete gsdDetailsToDelete;
            }
        }
        if (!eventIdsToResetGSD.isEmpty()) {
            List<EMS_GSD_Detail__c> gsdDetailsToUpdate = [SELECT Id FROM EMS_GSD_Detail__c WHERE EMS_Event__c IN :eventIdsToResetGSD];
            for (EMS_GSD_Detail__c gsd : gsdDetailsToUpdate) {
                gsd.GSD_Type_gne__c = '';
            }
            if (!gsdDetailsToUpdate.isEmpty()) {
                // an update causes "maximum trigger depth exceeded" without the flag below
                EMS_GSD_Detail_Child_Record_Updates.skipTrigger = true;
                update gsdDetailsToUpdate;
            }
        }
    }

    private static void deleteTravels(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Event__c event : triggerNew.values()) {
            if (!EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id) && (
                    (triggerOld.get(event.Id).Event_Type_gne__c == 'Consulting Meetings' && event.Event_Type_gne__c != 'Consulting Meetings') ||
                            (triggerOld.get(event.Id).Event_Type_gne__c == 'Consultancy Meeting' && event.Event_Type_gne__c != 'Consultancy Meeting') ||
                            (triggerOld.get(event.Id).Event_Type_gne__c == 'Learning Programs' && event.Event_Type_gne__c != 'Learning Programs')
            )) {
                eventIds.add(event.Id);
            }
        }
        if (!eventIds.isEmpty()) {
            List<EMS_Travel_gne__c> travelsToDelete = [SELECT Id FROM EMS_Travel_gne__c WHERE EMS_Event_gne__c IN :eventIds];
            if (travelsToDelete.size() > 0) {
                delete travelsToDelete;
            }
        }
    }

    private static void deleteAttendees(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        if (triggerOld == null || triggerNew == null) return;

        Set<Id> submitedEvents = new Set<Id>();
        EMS_GSD_Event_Types_gne__c eventTypes = EMS_GSD_Event_Types_gne__c.getInstance();

        for (EMS_Event__c event : triggerNew.values()) {
            if (!triggerOld.containsKey(event.Id)) continue;

            EMS_Event__c oldEvent = triggerOld.get(event.Id);
            Boolean isApprovalPending = event.Status_gne__c == 'Pending Approval' && oldEvent.Status_gne__c != 'Pending Approval';
            Boolean isMedOpsPending = event.Status_gne__c == 'Pending Med Ops Review' && oldEvent.Status_gne__c != 'Pending Med Ops Review';
            Boolean isCommitteePending = event.Status_gne__c == 'Pending Committee Review' && oldEvent.Status_gne__c != 'Pending Committee Review';
            Boolean isMedicalManagerReview = event.Status_gne__c == 'Pending Medical Manager Review' && oldEvent.Status_gne__c != 'Pending Medical Manager Review';
            Boolean shouldDeleteAttendees = event.Event_Type_gne__c != null
                    && eventTypes.GSD_Events_names__c.containsIgnoreCase(event.Event_Type_gne__c)
                    && event.Event_Sub_Type_gne__c != 'Journal Club'
                    && event.Event_Sub_Type_gne__c != 'Journal Club / Post Congress'
                    && event.Event_Sub_Type_gne__c != 'Journal Club / Post Congress / In Kind';

            if ((isApprovalPending || isMedOpsPending || isCommitteePending || isMedicalManagerReview) && shouldDeleteAttendees) {
                submitedEvents.add(event.Id);
            }
        }

        if (!submitedEvents.isEmpty()) {
            delete [SELECT Id FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :submitedEvents];
            delete [SELECT Id FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c IN :submitedEvents AND Is_Watcher_gne__c = FALSE];
        }
    }

    private static void updateAllocatedAmountOnDelete(Map<Id, EMS_Event__c> triggerOld) {
        Map<Id, EMS_Budget_Allocation_gne__c> relatedBudgetAllocationsMap = new Map<Id, EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Allocation_gne__c budgetAllocation : [SELECT Id, RecordTypeId, Allocated_Budget_gne__c, EMS_Product_Budget_gne__c, EMS_Region_Budget_gne__c, EMS_Territory_Budget_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :triggerOld.values()]) {
            relatedBudgetAllocationsMap.put(budgetAllocation.Id, budgetAllocation);
        }
        EMS_Budget_Allocation_Child_Rec_Update.onBeforeDelete(relatedBudgetAllocationsMap);
    }

    private static void deleteBudgetAllocationsOnEventTypeChange(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        List<Id> eventsWhichBAWillBeDeleted = new List<Id>();
        for (EMS_Event__c ev : triggerNew.values()) {
            EMS_Event__c oldEvent = triggerOld.get(ev.Id);
            Boolean subTypeChanged = String.isNotBlank(ev.Event_Sub_Type_gne__c)
                    && String.isNotBlank(oldEvent.Event_Sub_Type_gne__c)
                    && ev.Event_Sub_Type_gne__c != oldEvent.Event_Sub_Type_gne__c;
            Boolean typeChanged = String.isNotBlank(ev.Event_Type_gne__c)
                    && String.isNotBlank(oldEvent.Event_Type_gne__c)
                    && ev.Event_Type_gne__c != oldEvent.Event_Type_gne__c;
            Boolean hasCostCenterType = String.isNotBlank(ev.Cost_Center_Type_gne__c)
                    && String.isNotBlank(oldEvent.Cost_Center_Type_gne__c);

            Boolean costCenterTypeChanged = false;
            for (String costCenterType : EMS_Event_Helper.COST_CENTER_TYPES) {
                costCenterTypeChanged |= hasCostCenterType
                        && ev.Cost_Center_Type_gne__c.startsWithIgnoreCase(costCenterType)
                        && !oldEvent.Cost_Center_Type_gne__c.startsWithIgnoreCase(costCenterType);
            }

            if (typeChanged || subTypeChanged || costCenterTypeChanged) { // the flage forces to delete all related budgets
                eventsWhichBAWillBeDeleted.add(ev.Id);
            }
        }

        if (!eventsWhichBAWillBeDeleted.isEmpty()) {
            List<EMS_Budget_Allocation_gne__c> baToDelete = [SELECT Id FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :eventsWhichBAWillBeDeleted];
            if (baToDelete.size() > 0) {
                delete baToDelete;
            }
        }
    }

    private static void startBudgetAllocationApproval(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        Map<Id, List<EMS_Budget_Allocation_gne__c>> budgetAllocations = fetchBudgetAllocations(new List<Id>(triggerNew.keySet()));
        Set<Id> autoApproveAllocations = new Set<Id>();

        for (EMS_Event__c event : triggerNew.values()) {
            Boolean isBps = event.Assigned_AARC_gne__c == UserInfo.getUserId();

            if (event.Pending_Budget_Approval_gne__c && !triggerOld.get(event.Id).Pending_Budget_Approval_gne__c) {
                if (budgetAllocations.get(event.Id) != null) {
                    for (EMS_Budget_Allocation_gne__c ba : budgetAllocations.get(event.Id)) {
                        Boolean shouldAutoApprove = ba.Budget_Owner_gne__c == event.Event_Owner_gne__c;
                        if (ba.Allocated_Budget_gne__c > 0 && ba.Status_gne__c != 'Submitted' && ba.Status_gne__c != 'Approved') {
                            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                            request.setObjectId(ba.Id);
                            if(isBps) {
                                request.setComments('Approval process started by SEA member on behalf of Event Owner');
                            } else {
                                request.setComments('Budget Allocation approval process started');
                            }

                            if (shouldAutoApprove && isBps) {
                                autoApproveAllocations.add(ba.Id);
                            }
                            requests.add(request);
                        }
                    }
                }
            }
        }

        List<Approval.ProcessWorkitemRequest> itemRequests = new List<Approval.ProcessWorkitemRequest>();

        if (!requests.isEmpty()) {
            System.debug('budget allocation process start');
            for(Approval.ProcessResult result : Approval.process(requests)) {
                System.debug('result :: ' + result);

                if(autoApproveAllocations.contains(result.getEntityId())) {
                    for (Id workItem : result.getNewWorkitemIds()) {
                        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                        pwr.setWorkitemId(workItem);
                        pwr.setAction('Approve');
                        pwr.setComments('Budget Allocation approved by SEA Member on behalf of Event Owner');
                        itemRequests.add(pwr);
                    }
                }
            }
        }

        if(!itemRequests.isEmpty()) {
            System.debug('budget allocation auto approval');
            for (Approval.ProcessResult result : Approval.process(itemRequests)) {
                System.debug('result :: ' + result);
            }
        }
    }

    private static void recallBudgetApproval(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        List<Id> recalledEvents = new List<Id>();

        for (EMS_Event__c event : triggerNew.values()) {
            if ((triggerOld.get(event.Id).Status_gne__c != 'Recalled' && event.Status_gne__c == 'Recalled')
                    || (triggerOld.get(event.Id).Status_gne__c != null && triggerOld.get(event.Id).Status_gne__c.contains('Pending') && event.Status_gne__c == 'Planned')
                    || (triggerOld.get(event.Id).Status_gne__c != null && triggerOld.get(event.Id).Status_gne__c.contains('Pending') && event.Status_gne__c == 'Unplanned')) {

                recalledEvents.add(event.Id);
            }
        }

        if (recalledEvents.isEmpty()) {
            return;
        }

        Map<Id, List<EMS_Budget_Allocation_gne__c>> budgetAllocations = fetchBudgetAllocations(recalledEvents);
        Set<Id> budgetAllocationIds = new Set<Id>();
        for (Id eventId : budgetAllocations.keySet()) {
            for (EMS_Budget_Allocation_gne__c ba : budgetAllocations.get(eventId)) {
                budgetAllocationIds.add(ba.Id);
            }
        }
        List<ProcessInstanceWorkitem> piwItems = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN (SELECT Id FROM ProcessInstance WHERE TargetObjectId IN :budgetAllocationIds)];

        if (piwItems.size() > 0) {
            List<Approval.ProcessWorkitemRequest> approvalsToRecall = new List<Approval.ProcessWorkitemRequest>();
            for (ProcessInstanceWorkitem piwItem : piwItems) {
                Approval.ProcessWorkitemRequest rejectAppr = new Approval.ProcessWorkitemRequest();
                rejectAppr.setComments('Event approval was recalled');
                rejectAppr.setAction('Removed');
                rejectAppr.setWorkitemId(piwItem.Id);
                approvalsToRecall.add(rejectAppr);
            }
            List<Approval.ProcessResult> recallResults = Approval.process(approvalsToRecall);
        }
    }

    private static Map<Id, List<EMS_Budget_Allocation_gne__c>> fetchBudgetAllocations(List<Id> events) {
        Map<Id, List<EMS_Budget_Allocation_gne__c>> result = new Map<Id, List<EMS_Budget_Allocation_gne__c>>();
        for (EMS_Budget_Allocation_gne__c budgetAllocation : [SELECT Id, Budget_Owner_gne__c, EMS_Event_gne__c, Status_gne__c, Allocated_Budget_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :events]) {
            if (!result.containsKey(budgetAllocation.EMS_Event_gne__c)) {
                result.put(budgetAllocation.EMS_Event_gne__c, new List<EMS_Budget_Allocation_gne__c>());
            }
            result.get(budgetAllocation.EMS_Event_gne__c).add(budgetAllocation);
        }

        return result;
    }

    // helper methods
    private static Call2_vod__c prepareCallObject(EMS_Interaction_gne__c interaction, Id interactionRecordType) {
        Call2_vod__c call = new Call2_vod__c(
                Detailed_Products_vod__c = interaction.Product_gne__r.Name,
                Call_Datetime_vod__c = interaction.EMS_Event__r.End_Date_gne__c,
                Territory_vod__c = interaction.Territory_gne__c,
                Attendees_vod__c = 1,
                Actual_Attendees_gne__c = 0,
                RecordTypeId = interactionRecordType,
                Completed_gne__c = true,
                //Date_Completed_gne__c = interaction.EMS_Event__r.End_Date_gne__c,
                Date_Completed_gne__c = System.today(),
                Interaction_Type_gne__c = 'Promotional Session',
                iPhone_Request_Id_gne__c = 'EMS_' + System.now().getTime() + '_' + (Math.random() * 1000),
                OwnerId = interaction.EMS_Roche_Attendee__r.User_gne__c,
                Attendee_Type_vod__c = 'Person_Account_vod',
                Call_Type_vod__c = 'Detail Only',
                Meal_Amount_gne__c = 0,
                Planned_Attendees_gne__c = 0,
                Status_vod__c = 'Saved_vod'
        );
        if (interaction.EMS_Attendee_gne__r.Account_gne__c != null && interaction.EMS_Attendee_gne__r.EMS_International_Speaker_gne__c == null) {
            call.Account_vod__c = interaction.EMS_Attendee_gne__r.Account_gne__c;
            return call;
        } else if (interaction.EMS_Attendee_gne__r.Account_gne__c == null && interaction.EMS_Attendee_gne__r.EMS_International_Speaker_gne__c != null) {
            call.EMS_International_Speaker_gne__c = interaction.EMS_Attendee_gne__r.EMS_International_Speaker_gne__c;
            return call;
        }
        return null;
    }

    private static Call2_vod__c prepareChildAccountCallObject(Call2_vod__c parentCall, EMS_Interaction_gne__c interaction, Id interactionRecordType) {
        return (new Call2_vod__c(
                Contact_vod__c = interaction.EMS_Attendee_gne__r.Contact_gne__c,
                Parent_Call_vod__c = parentCall.Id,
                Detailed_Products_vod__c = parentCall.Detailed_Products_vod__c,
                Call_Datetime_vod__c = parentCall.Call_Datetime_vod__c,
                Territory_vod__c = parentCall.Territory_vod__c,
                Territory_Id_gne__c = parentCall.Territory_Id_gne__c,
                Attendees_vod__c = 1,
                Actual_Attendees_gne__c = 0,
                RecordTypeId = interactionRecordType,
                Completed_gne__c = true,
                //Date_Completed_gne__c = interaction.EMS_Event__r.End_Date_gne__c,
                Date_Completed_gne__c = System.today(),
                Interaction_Type_gne__c = 'Promotional Session',
                iPhone_Request_Id_gne__c = 'EMS_' + System.now().getTime() + '_' + (Math.random() * 1000),
                OwnerId = interaction.EMS_Roche_Attendee__r.User_gne__c,
                Attendee_Type_vod__c = 'Person_Account_vod',
                Call_Type_vod__c = 'Detail Only',
                Meal_Amount_gne__c = 0,
                Planned_Attendees_gne__c = 0,
                Status_vod__c = 'Saved_vod'
        ));
        return null;
    }

    private static Call2_Detail_vod__c prepareCallDetailObject(Call2_vod__c call, EMS_Interaction_gne__c interaction) {
        return new Call2_Detail_vod__c(Call2_vod__c = call.Id, Product_vod__c = interaction.Product_gne__c, Detail_Priority_vod__c = 1, iPhone_Request_Id_gne__c = 'EMS_' + System.now().getTime() + '_' + (Math.random() * 1000));
    }

    private static Call2_Discussion_vod__c prepareCallDiscussionObject(Call2_vod__c call, EMS_Interaction_gne__c interaction) {
        Call2_Discussion_vod__c callDiscussion = new Call2_Discussion_vod__c(
                Call2_vod__c = call.Id,
                Product_vod__c = interaction.Product_gne__c,
                Product_Strategy_vod__c = interaction.Product_Strategy_gne__c,
                Product_Tactic_vod__c = interaction.Product_Tactic_gne__c,
                Reaction_gne__c = interaction.Reaction_gne__c,
                Detail_Priority_gne__c = 1,     // set to 1 when only one product is discussed
                iPhone_Request_Id_gne__c = 'EMS_' + System.now().getTime() + '_' + (Math.random() * 1000)
                //zvod_Product_Map_vod__c = interaction.Product_gne__r.Name
        );
        if (interaction.EMS_Attendee_gne__r.Account_gne__c != null && interaction.EMS_Attendee_gne__r.EMS_International_Speaker_gne__c == null) {
            callDiscussion.Account_vod__c = interaction.EMS_Attendee_gne__r.Account_gne__c;
        } else if (interaction.EMS_Attendee_gne__r.Account_gne__c == null && interaction.EMS_Attendee_gne__r.EMS_International_Speaker_gne__c != null) {
            callDiscussion.EMS_International_Speaker_gne__c = interaction.EMS_Attendee_gne__r.EMS_International_Speaker_gne__c;
        }
        return callDiscussion;
    }

    private static Call2_Sample_vod__c prepareCallSampleObject(Call2_vod__c call, EMS_Interaction_gne__c interaction) {
        return new Call2_Sample_vod__c(
                Call2_vod__c = call.Id,
                Account_vod__c = call.Account_vod__c,
                Product_vod__c = interaction.Tool_gne__c,
                Quantity_vod__c = interaction.Quantity_gne__c
        );
    }

    private static void putCallIntoMap(Map<Id, List<Call2_vod__c>> callsMap, Id key, Call2_vod__c call) {
        if (callsMap.get(key) == null) {
            callsMap.put(key, new List<Call2_vod__c>());
        }
        callsMap.get(key).add(call);
    }

    private static void createRocheAttendeeFromEventRequestor(Map<Id, EMS_Event__c> triggerNew) {
        Set<String> existingAttendees = new Set<String>();
        for (EMS_Roche_Attendee_gne__c rocheAttendee : [SELECT EMS_Event_gne__c, User_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c IN :triggerNew.keySet()]) {
            existingAttendees.add(rocheAttendee.EMS_Event_gne__c + '' + rocheAttendee.User_gne__c);
        }

        List<EMS_Roche_Attendee_gne__c> rocheAttendees = new List<EMS_Roche_Attendee_gne__c>();
        for (EMS_Event__c event : triggerNew.values()) {
            Boolean isNotProcessed = !EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id);
            // "Event_Requestor_gne__c" = null during duplication of event when requestor is inactive
            Boolean isRequestorActive = String.isNotBlank(event.Event_Requestor_gne__c)
                    && String.isNotBlank(event.Assigned_To_Territory_Requestor_Id_gne__c);
            if (isNotProcessed && isRequestorActive && !existingAttendees.contains(event.Id + '' + event.Event_Requestor_gne__c)) {
                rocheAttendees.add(new EMS_Roche_Attendee_gne__c(
                        User_gne__c = event.Event_Requestor_gne__c,
                        Territory_Id_gne__c = event.Assigned_To_Territory_Requestor_Id_gne__c,
                        EMS_Event_gne__c = event.Id
                ));
            }
        }
        insert rocheAttendees;
    }

    private static Map<String, Decimal> getDisturbanceFeeAmounts() {
        Map<String, Decimal> result = new Map<String, Decimal>();

        for (EMS_FMV_Configuration_gne__c fmvConfig : [
                SELECT EMS_Event_Configuration_gne__r.Event_Type_gne__c, EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c, Type_of_HCP_gne__c, Disturbance_Fee_gne__c, KM_round_trip_gne__c,
                        Speaker_Tour_gne__c
                FROM EMS_FMV_Configuration_gne__c
                WHERE RecordType.Name LIKE 'KM (Round trip) Config'
        ]) {
            String feeKey = fmvConfig.EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c + '_' + fmvConfig.Disturbance_Fee_gne__c;
            if (!result.containsKey(feeKey)) {
                result.put(feeKey, fmvConfig.KM_round_trip_gne__c);
            }
        }

        return result;
    }

    private static void recalculateTotalHonorariumAmount(Map<Id, EMS_Event__c> triggerOld, Map<Id, EMS_Event__c> triggerNew) {
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        Set<Id> eventIds = new Set<Id>();

        for (EMS_Event__c event : triggerNew.values()) {
            Boolean isSpeakerTour = event.Speaker_Tour_gne__c || event.Parent_Speaker_Tour_Event_gne__c != null;
            Boolean wasSpeakerTour = triggerOld.get(event.Id).Speaker_Tour_gne__c || triggerOld.get(event.Id).Parent_Speaker_Tour_Event_gne__c != null;

            if ((isSpeakerTour && !wasSpeakerTour) || (!isSpeakerTour && wasSpeakerTour)) {
                eventIds.add(event.Id);
            }
        }

        if (eventIds.isEmpty()) {
            return;
        }

        Map<String, Decimal> disturbanceFees = getDisturbanceFeeAmounts();
        for (EMS_Attendee_gne__c att : [
                SELECT EMS_Event_gne__c, Activity_Time_gne__c, Activity_Time_1_gne__c, Activity_Time_2_gne__c, Activity_Time_3_gne__c,
                        Activity_Time_4_gne__c, Activity_Time_5_gne__c, Activity_Time_6_gne__c, Preparation_Time_1_gne__c, Preparation_Time_2_gne__c,
                        Preparation_Time_3_gne__c, Preparation_Time_4_gne__c, Preparation_Time_5_gne__c, Preparation_Time_6_gne__c,
                        Type_of_HCP_gne__c, Hourly_Rate_of_HCP_gne__c, HCP_hourly_rate_table_gne__c, Disturbance_Fee__c, Total_Honoraria_gne__c, km_gne__c,
                        Prep_Time_gne__c, Hourly_Rate_of_HCP_2_gne__c
                FROM EMS_Attendee_gne__c
                WHERE EMS_Event_gne__c IN :eventIds AND Type_of_HCP_gne__c != NULL
        ]) {

            EMS_Event__c event = triggerNew.get(att.EMS_Event_gne__c);

            if (att.Type_of_HCP_gne__c == 'iHCP') {
                att.Total_Honoraria_gne__c = att.Hourly_Rate_of_HCP_gne__c;
            } else {
                Decimal activityTime = 0;
                Decimal preparationTime = 0;
                Decimal disturbanceFeeAmount = 0;
                Decimal hourlyRate = 0;
                Decimal disturbanceFee = 0;

                // calculate activity amount
                // overall Activity Time takes precedence over specific items
                if (att.Activity_Time_gne__c != null) {
                    activityTime = Decimal.valueOf(att.Activity_Time_gne__c);
                } else {
                    activityTime += att.Activity_Time_1_gne__c != null ? Decimal.valueOf(att.Activity_Time_1_gne__c) : 0;
                    activityTime += att.Activity_Time_2_gne__c != null ? Decimal.valueOf(att.Activity_Time_2_gne__c) : 0;
                    activityTime += att.Activity_Time_3_gne__c != null ? Decimal.valueOf(att.Activity_Time_3_gne__c) : 0;
                    activityTime += att.Activity_Time_4_gne__c != null ? Decimal.valueOf(att.Activity_Time_4_gne__c) : 0;
                    activityTime += att.Activity_Time_5_gne__c != null ? Decimal.valueOf(att.Activity_Time_5_gne__c) : 0;
                    activityTime += att.Activity_Time_6_gne__c != null ? Decimal.valueOf(att.Activity_Time_6_gne__c) : 0;
                }

                // calculate preparation amount
                // overall Preparation Time takes precedence over specific items
                if(att.Prep_Time_gne__c != null) {
                    preparationTime = att.Prep_Time_gne__c;
                } else {
                    preparationTime += att.Preparation_Time_1_gne__c != null ? Decimal.valueOf(att.Preparation_Time_1_gne__c) : 0;
                    preparationTime += att.Preparation_Time_2_gne__c != null ? Decimal.valueOf(att.Preparation_Time_2_gne__c) : 0;
                    preparationTime += att.Preparation_Time_3_gne__c != null ? Decimal.valueOf(att.Preparation_Time_3_gne__c) : 0;
                    preparationTime += att.Preparation_Time_4_gne__c != null ? Decimal.valueOf(att.Preparation_Time_4_gne__c) : 0;
                    preparationTime += att.Preparation_Time_5_gne__c != null ? Decimal.valueOf(att.Preparation_Time_5_gne__c) : 0;
                    preparationTime += att.Preparation_Time_6_gne__c != null ? Decimal.valueOf(att.Preparation_Time_6_gne__c) : 0;
                }

                if (att.Hourly_Rate_of_HCP_gne__c != null) {
                    hourlyRate = att.Hourly_Rate_of_HCP_gne__c;
                } else if (att.HCP_hourly_rate_table_gne__c != null) {
                    hourlyRate = Decimal.valueOf(att.HCP_hourly_rate_table_gne__c);
                } else {
                    hourlyRate = Decimal.valueOf(att.Hourly_Rate_of_HCP_2_gne__c);
                }

                // calculate disturbance fee amount
                if (att.Disturbance_Fee__c != null) {
                    String feeKeyST = event.Event_Sub_Type_gne__c + '_' + att.Disturbance_Fee__c;
                    if (disturbanceFees.containsKey(feeKeyST)) {
                        disturbanceFee = disturbanceFees.get(feeKeyST);
                    }

                    if (att.Disturbance_Fee__c.contains('Ground') && att.km_gne__c != null) {
                        disturbanceFeeAmount = disturbanceFee * Decimal.valueOf(att.km_gne__c);
                    } else {
                        disturbanceFeeAmount = hourlyRate * Decimal.valueOf(att.km_gne__c);
                    }
                }

                att.Activity_Amount_gne__c = hourlyRate * activityTime;
                att.Talk_Prep_Amount_gne__c = hourlyRate * preparationTime;
                att.Disturbance_Fee_Amount_gne__c = disturbanceFeeAmount;
                att.Total_Honoraria_gne__c = hourlyRate * (activityTime + preparationTime) + disturbanceFeeAmount;
            }

            attendees.add(att);
        }
        update attendees;
    }
}