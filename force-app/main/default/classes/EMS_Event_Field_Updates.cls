public without sharing class EMS_Event_Field_Updates {

    private static Map<Id, GNE_User_Delegation__c> userDelegations;
    private static Map<String, EMS_Event_Configuration_gne__c> eventConfigurations;


    private static void updateHcpHCOName(List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c newEvent : triggerNew) {
            if(newEvent.Is_GSD_Event_gne__c == false) {
                newEvent.HCP_HCO_Name_gne__c = null;
            }
        }
    }

    private static void setOldDates(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew) {
            Boolean startTimeChanged = (triggerOld.get(event.Id).Start_Date_gne__c == null && event.Start_Date_gne__c != null) || (triggerOld.get(event.Id).Start_Date_gne__c != event.Start_Date_gne__c);
            Boolean endTimeChanged = (triggerOld.get(event.Id).End_Date_gne__c == null && event.End_Date_gne__c != null) || (triggerOld.get(event.Id).End_Date_gne__c != event.End_Date_gne__c);
            if (startTimeChanged || endTimeChanged) {
                event.End_Date_Old_gne__c = triggerOld.get(event.Id).End_Date_gne__c;
                event.Start_Date_Old_gne__c = triggerOld.get(event.Id).Start_Date_gne__c;
            }
        }
    }

    private static void overrideApprover(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        if (triggerOld != null) {
            for (EMS_Event__c event : triggerNew) {
                if (!triggerOld.get(event.Id).Status_gne__c.contains('Pending') && event.Status_gne__c.contains('Pending')) {
                    Id approverUserId = event.Event_Owner_gne__c;
                    event.Approver_gne__c = getDelegatedUser(approverUserId);
                }
            }
        }
    }

    private static void changeOwnerOnRequestorChange(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        if (triggerOld != null) {
            for (EMS_Event__c event : triggerNew) {
                if (triggerOld.get(event.Id).Event_Requestor_gne__c != event.Event_Requestor_gne__c) {
                    event.OwnerId = event.Event_Requestor_gne__c;
                }
            }
        }
    }

    private static void updateStatusOnRecall(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew) {
            if (event.Status_gne__c == 'Recalled' && triggerOld.get(event.Id).Status_gne__c != 'Recalled') {
                if (event.Is_Planned_gne__c) {
                    event.Status_gne__c = 'Planned';
                } else {
                    event.Status_gne__c = 'Unplanned';
                }
            }
        }
    }

    private static void updateStatusOnMedOpsRecall(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew) {
            if (event.Approval_Rejection_Comments_gne__c != null && event.Approval_Rejection_Comments_gne__c.startsWith('Med Ops Review Recalled: ') && event.Status_gne__c == 'Med Ops Rejected' && triggerOld.get(event.Id).Status_gne__c != 'Med Ops Rejected') {
                if (event.Is_Planned_gne__c) {
                    event.Status_gne__c = 'Planned';
                } else {
                    event.Status_gne__c = 'Unplanned';
                }
            }
        }
    }

    private static Id getDelegatedUser(Id mainUserId) {
        if (userDelegations.containsKey(mainUserId)) {
            return userDelegations.get(mainUserId).Delegated_User__c;
        }
        return mainUserId;
    }

    private static void updateRecordTypeOnEventClose(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew) {
            if (event.Status_gne__c == 'Closed' && triggerOld.get(event.Id).Status_gne__c != 'Closed') {
                event.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Closed Event').RecordTypeId;
            }
        }
    }

    private static void updateRecordTypeOnEventCancel(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew) {
            if (event.Status_gne__c == 'Cancelled' && triggerOld.get(event.Id).Status_gne__c != 'Cancelled') {
                event.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Cancelled Event').RecordTypeId;
            }
        }
    }

    private static void updateRecordTypeOnSignedContract(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew) {
            if (event.Status_gne__c == 'Signed Agreement Received' && triggerOld.get(event.Id).Status_gne__c != 'Signed Agreement Received') {
                event.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Signed Agreement Received Event').RecordTypeId;
            }
        }
    }

    private static void updateTerritoryId(List<EMS_Event__c> events) {
        Set<String> territoryNames = new Set<String>();
        for (EMS_Event__c event : events) {
            if (String.isNotBlank(event.Assigned_To_Territory_Owner_gne__c)) {
                territoryNames.add(event.Assigned_To_Territory_Owner_gne__c);
            }

            if (String.isNotBlank(event.Assigned_To_Territory_Requestor_gne__c)) {
                territoryNames.add(event.Assigned_To_Territory_Requestor_gne__c);
            }
        }

        Map<String, EMS_Util.EMS_Territory> territoryNameToTerritory = EMS_Util.getTerritoriesByNames(territoryNames);
        for (EMS_Event__c event : events) {
            if (String.isNotBlank(event.Assigned_To_Territory_Owner_gne__c)
                && territoryNameToTerritory.containsKey(event.Assigned_To_Territory_Owner_gne__c)
            ) {
                event.Assigned_To_Territory_Owner_Id_gne__c = territoryNameToTerritory.get(event.Assigned_To_Territory_Owner_gne__c).Id;
            }
            if (String.isNotBlank(event.Assigned_To_Territory_Requestor_gne__c)
                && territoryNameToTerritory.containsKey(event.Assigned_To_Territory_Requestor_gne__c)
            ) {
                event.Assigned_To_Territory_Requestor_Id_gne__c = territoryNameToTerritory.get(event.Assigned_To_Territory_Requestor_gne__c).Id;
            }
        }
    }

    private static void updateCostCenterType(List<EMS_Event__c> events) {
        Set<String> ownerIds = new Set<String>();
        Map<String, String> budgetOwnerToCostCenterType = EMS_Event_Trigger_Helper.getCostCenterTypes();
        for (EMS_Event__c event : events) {
            event.Cost_Center_Type_gne__c = budgetOwnerToCostCenterType.get(event.Event_Owner_gne__c);
        }
    }

    private static void markPlannedEvents(List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew) {
            if (event.Status_gne__c == 'Planned') {
                event.Is_Planned_gne__c = true;
            }
        }
    }

    private static void approveBudgetApprovalOnPlannedExpensesChange(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        for (EMS_Event__c event : triggerNew) {
            if (!EMS_Event_Trigger_Helper.isAlreadyProcessed(event.Id) && event.Budget_Approval_Failed_gne__c &&
                    (triggerOld.get(event.Id).Planned_Expenses_gne__c != event.Planned_Expenses_gne__c) && (event.Planned_Expenses_gne__c == event.Total_Budget_Allocated_gne__c)) {
                // approve event
                event.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Owner Approved Event').RecordTypeId;
                event.Status_gne__c = eventConfigurations.get(event.Event_Type_gne__c + event.Event_Sub_Type_gne__c).Budget_Approved_Label_gne__c;
                event.Pending_Budget_Approval_gne__c = false;
                event.Budget_Approval_Failed_gne__c = false;
            }
        }
    }

    public static void storePrevAgendaValue(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        String prevAgendaComments = '';
        for (EMS_Event__c ev : triggerNew) {
            if (triggerOld.get(ev.Id).Agenda_Comments_gne__c != null) {
                prevAgendaComments = triggerOld.get(ev.Id).Agenda_Comments_gne__c;
            }

            if (ev.Agenda_Comments_gne__c != prevAgendaComments) {
                ev.Agenda_Comments_prev_gne__c = prevAgendaComments;
            }
        }
    }

    private static Map<Id, Integer> getContractsCount(Set<Id> eventIds) {
        Map<Id, Integer> contractsCount = new Map<Id, Integer>();
        for (AggregateResult result : [
                SELECT EMS_Event_gne__c eventId, count(Id) contractsCount
                FROM EMS_Attachment_gne__c
                WHERE EMS_Event_gne__c IN :eventIds
                AND Type_gne__c = 'Signed Contract'
                GROUP BY EMS_Event_gne__c
        ]) {

            Id eventId = (Id) result.get('eventId');
            Integer count = (Integer) result.get('contractsCount');

            if (!contractsCount.containsKey(eventId)) {
                contractsCount.put(eventId, count);
            }
        }
        return contractsCount;
    }

    private static void updateStatusForSpeakerTour(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        Set<Id> parentSpeakerTourIds = new Set<Id>();
        for (EMS_Event__c event : triggerNew) {
            if (triggerOld.get(event.Id).Status_gne__c == 'Pending Med Ops Review' && event.Status_gne__c == 'Med Ops Approved'
                    && event.Parent_Speaker_Tour_Event_gne__c != null) {

                parentSpeakerTourIds.add(event.Parent_Speaker_Tour_Event_gne__c);
            }
        }

        if (parentSpeakerTourIds.isEmpty()) {
            return;
        }

        Map<Id, Integer> contractsCount = getContractsCount(parentSpeakerTourIds);

        for (EMS_Event__c event : triggerNew) {
            if (contractsCount.containsKey(event.Parent_Speaker_Tour_Event_gne__c) && contractsCount.get(event.Parent_Speaker_Tour_Event_gne__c) > 0) {
                event.Status_gne__c = 'Signed Agreement Received';
            }
        }
    }

    private static void updateStatusForSpeakerTourOnAdd(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        Set<Id> parentSpeakerTourIds = new Set<Id>();
        for (EMS_Event__c event : triggerNew) {
            if (triggerOld.get(event.Id).Parent_Speaker_Tour_Event_gne__c == null && event.Parent_Speaker_Tour_Event_gne__c != null) {

                parentSpeakerTourIds.add(event.Parent_Speaker_Tour_Event_gne__c);
            }
        }

        if (parentSpeakerTourIds.isEmpty()) {
            return;
        }
        Map<Id, Integer> contractsCount = getContractsCount(parentSpeakerTourIds);

        for (EMS_Event__c event : triggerNew) {
            if (contractsCount.containsKey(event.Parent_Speaker_Tour_Event_gne__c) && contractsCount.get(event.Parent_Speaker_Tour_Event_gne__c) > 0) {
                if (event.Status_gne__c == 'Med Ops Approved' || event.Status_gne__c == 'Awaiting Signature from HCP') {
                    event.Status_gne__c = 'Signed Agreement Received';
                }
            }
        }
    }

    private static void updateStatusForSpeakerTourOnRemove(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Event__c event : triggerNew) {
            if (triggerOld.get(event.Id).Parent_Speaker_Tour_Event_gne__c != null && event.Parent_Speaker_Tour_Event_gne__c == null) {

                eventIds.add(event.Id);
            }
        }

        if (eventIds.isEmpty()) {
            return;
        }

        Map<Id, Integer> contractsCount = getContractsCount(eventIds);

        for (EMS_Event__c event : triggerNew) {
            if (event.Status_gne__c == 'Signed Agreement Received') {
                if (!contractsCount.containsKey(event.Id) || contractsCount.get(event.Id) == 0) {
                    event.Status_gne__c = 'Med Ops Approved';
                    event.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Med Ops Approved Event').RecordTypeId;
                }
            }
        }
    }

    private static void setApprovalDate(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {

        for (EMS_Event__c newEvent : triggerNew) {
            // set the date value
            if (newEvent.Status_gne__c == 'Pending Committee Review'
                    || newEvent.Status_gne__c == 'Pending Approval'
                    || newEvent.Status_gne__c == 'Approved' // need to check med ops rejected -> event owner approved scenario
                    || newEvent.Status_gne__c == 'Pending Medical Manager Review'
                    || newEvent.Status_gne__c == 'Pending MAC Committee Review'
                    || newEvent.Status_gne__c == 'Pending Manager Review'
                    || newEvent.Status_gne__c == 'Pending Director / Manager Review'
                    ) {
                if (triggerOld.get(newEvent.Id).Status_gne__c != newEvent.Status_gne__c) {
                    newEvent.Approval_Date_gne__c = Date.today();
                }

            }
            // clear the date value
            if (newEvent.Status_gne__c == 'Med Ops Rejected'
                    || newEvent.Status_gne__c == 'Recalled'
                    || newEvent.Status_gne__c == 'Rejected'
                    || newEvent.Status_gne__c == 'Unplanned'
                    ) {
                // reset to null everytime
                newEvent.Approval_Date_gne__c = null;
            }
        }
    }

    public static void onBeforeInsert(List<EMS_Event__c> triggerNew) {
        updateTerritoryId(triggerNew);
        updateCostCenterType(triggerNew);
        markPlannedEvents(triggerNew);
    }

    public static void onBeforeUpdate(Map<Id, EMS_Event__c> triggerOld, List<EMS_Event__c> triggerNew) {
        userDelegations = EMS_Util.getUserDelegations();
        eventConfigurations = EMS_Event_Trigger_Helper.getEventConfigurations();

        setOldDates(triggerOld, triggerNew);
        updateStatusOnRecall(triggerOld, triggerNew);
        updateStatusOnMedOpsRecall(triggerOld, triggerNew);
        overrideApprover(triggerOld, triggerNew);
        changeOwnerOnRequestorChange(triggerOld, triggerNew);
        updateTerritoryId(triggerNew);
        updateRecordTypeOnEventClose(triggerOld, triggerNew);
        updateRecordTypeOnEventCancel(triggerOld, triggerNew);
        updateCostCenterType(triggerNew);
        markPlannedEvents(triggerNew);
        storePrevAgendaValue(triggerOld, triggerNew);
        approveBudgetApprovalOnPlannedExpensesChange(triggerOld, triggerNew);
        updateStatusForSpeakerTour(triggerOld, triggerNew);
        updateStatusForSpeakerTourOnRemove(triggerOld, triggerNew);
        updateStatusForSpeakerTourOnAdd(triggerOld, triggerNew);
        updateRecordTypeOnSignedContract(triggerOld, triggerNew);
        // Change the approval date value of the event(s) (depends on the status)
        setApprovalDate(triggerOld, triggerNew);
        updateHcpHCOName(triggerNew);
    }
}