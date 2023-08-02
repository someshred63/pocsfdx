public without sharing class EMS_Budget_Allocation_Child_Rec_Update {

    private static Map<Id, Schema.RecordTypeInfo> budgetAllocationRecordTypes = EMS_Budget_Allocation_gne__c.SObjectType.getDescribe().getRecordTypeInfosByID();

    private static Map<Id, EMS_Budget_Product_gne__c> productBudgetMapToUpdate;
    private static Map<Id, EMS_Budget_Region_gne__c> regionBudgetMapToUpdate;
    private static Map<Id, EMS_Budget_Territory_gne__c> territoryBudgetMapToUpdate;
    private static Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocationFullData;
    private static Map<Id, EMS_Event__c> relatedEvents;
    private static Map<String, EMS_Event_Configuration_gne__c> eventConfigurations;

    public static void onAfterInsert(Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        budgetAllocationFullData = getObjectIds(triggerNew);
        relatedEvents = getRelatedEvents(triggerNew);
        updateAllocatedAmountOnBudget(triggerNew);

        shareWithBudgetOwner(triggerNew);
        submitBudgetAllocationForApproval(null, triggerNew);
        recalculateBudgetDeductions(triggerNew.values());
        changeEventGSDType(triggerNew.values());
    }

    public static void onAfterUpdate(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        budgetAllocationFullData = getObjectIds(triggerNew);
        relatedEvents = getRelatedEvents(triggerNew);
        eventConfigurations = getEventConfigurations();
        updateAllocatedAmountOnBudget(triggerOld, triggerNew);

        shareWithBudgetOwner(triggerNew);
        shareWithApprover(triggerOld, triggerNew);
        approveBudgetAllocations(triggerOld, triggerNew);
        rejectBudgetAllocations(triggerOld, triggerNew);
        recallBudgetAllocations(triggerOld, triggerNew);

        submitBudgetAllocationForApproval(triggerOld, triggerNew);
        recalculateBudgetDeductions(triggerNew.values());
        changeEventGSDType(triggerNew.values());
    }

    public static void onBeforeDelete(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld) {
        budgetAllocationFullData = getObjectIds(triggerOld);
        updateAllocatedAmountOnDelete(triggerOld);
        removeSharingWithBudgetOwner(triggerOld);

        EMS_Budget_Allocation_Trigger_Helper.addToProcessed(triggerOld.values());
    }

    public static void onAfterDelete(List<EMS_Budget_Allocation_gne__c> triggerOld) {
        recalculateBudgetDeductions(triggerOld);
        eventConfigurations = getEventConfigurations();

        // when Rejected BA is manually deleted, the following method will check if there are some approved BAs
        // and then chane the Event status
        changeEventStatusIfNeed(triggerOld);
    }

    public static void onAfterUndelete(List<EMS_Budget_Allocation_gne__c> triggerOld) {
        recalculateBudgetDeductions(triggerOld);
    }

    private static void changeEventGSDType(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        Map<Id, EMS_Event__c> eventsWithNotRejectedBA = new Map<Id, EMS_Event__c>();
        for (EMS_Budget_Allocation_gne__c ba : triggerNew) {
            if (ba.Status_gne__c != 'Submitted' && ba.Status_gne__c != 'Rejected' && ba.Status_gne__c != 'Approved') {
                if (!eventsWithNotRejectedBA.containsKey(ba.EMS_Event_gne__c) && relatedEvents.containsKey(ba.EMS_Event_gne__c)) {
                    eventsWithNotRejectedBA.put(ba.EMS_Event_gne__c, relatedEvents.get(ba.EMS_Event_gne__c));
                }
            }
        }
        Set<Id> eventIdsToResetGSDType = new Set<Id>();
        for (EMS_Event__c event : eventsWithNotRejectedBA.values()) {
            if (event.Event_Type_gne__c == 'Sponsorships') {
                // reset GSD type to "--None--"
                eventIdsToResetGSDType.add(event.id);
            }
        }

        List<EMS_GSD_Detail__c> gsds = [SELECT GSD_Type_gne__c FROM EMS_GSD_Detail__c WHERE EMS_Event__c IN :eventIdsToResetGSDType];
        if (gsds.isEmpty()) {
            return;
        }
        for (EMS_GSD_Detail__c gsd : gsds) {
            gsd.GSD_Type_gne__c = '';
        }
        update gsds;
    }

    // Update and Insert methods
    private static Map<Id, EMS_Budget_Allocation_gne__c> getObjectIds(Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        return new Map<Id, EMS_Budget_Allocation_gne__c>([
                SELECT EMS_Product_Budget_gne__r.Events_Allocated_Amount__c, EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c,
                        EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c, EMS_Event_gne__r.Status_gne__c,
                        EMS_Event_gne__r.Total_Budget_Allocated_gne__c, EMS_Event_gne__r.Planned_Expenses_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE Id IN :triggerNew.keySet()
        ]);
    }

    private static Map<Id, EMS_Event__c> getRelatedEvents(Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            eventIds.add(ba.EMS_Event_gne__c);
        }

        return new Map<Id, EMS_Event__c>([
                SELECT Event_Type_gne__c, Event_Sub_Type_gne__c, Total_Budget_Allocated_gne__c, Planned_Expenses_gne__c, Status_gne__c, Pending_Budget_Approval_gne__c, Budgets_Count_gne__c,
                        Event_Requestor_gne__c, Event_Owner_gne__c, Name
                FROM EMS_Event__c
                WHERE Id IN :eventIds
        ]);
    }

    private static void updateAllocatedAmountOnBudget(Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        productBudgetMapToUpdate = new Map<Id, EMS_Budget_Product_gne__c>();
        regionBudgetMapToUpdate = new Map<Id, EMS_Budget_Region_gne__c>();
        territoryBudgetMapToUpdate = new Map<Id, EMS_Budget_Territory_gne__c>();

        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            if (EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id) == false) {
                updateAllocatedBudgetOnInsert(ba);
            }
        }
        updateBudgets(triggerNew);
    }

    private static void updateAllocatedAmountOnBudget(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        productBudgetMapToUpdate = new Map<Id, EMS_Budget_Product_gne__c>();
        regionBudgetMapToUpdate = new Map<Id, EMS_Budget_Region_gne__c>();
        territoryBudgetMapToUpdate = new Map<Id, EMS_Budget_Territory_gne__c>();

        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            if (
                    EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id) == false
                            && (triggerOld.get(ba.Id).Allocated_Budget_gne__c != ba.Allocated_Budget_gne__c
                            || triggerOld.get(ba.Id).Budget_Deductions_gne__c != ba.Budget_Deductions_gne__c)
                    ) {
                updateAllocatedBudgetOnUpdate(triggerOld.get(ba.Id), ba);
            }
        }
        updateBudgets(triggerNew);
    }

    private static void shareWithBudgetOwner(Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        List <EMS_Event__Share> sharingsToAdd = new List <EMS_Event__Share>();
        Set<Id> budgetOwnersIds = new Set<Id>();

        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            if (EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id) == false) {
                budgetOwnersIds.add(ba.Budget_Owner_gne__c);
            }
        }

        if (budgetOwnersIds.isEmpty()) {
            return;
        }

        Map<Id, User> budgetOwners = new Map<Id, User>([SELECT Id, IsActive FROM User WHERE Id IN :budgetOwnersIds]);
        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            if (
                    EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id) == false
                            && ba.Budget_Owner_gne__c != null
                            && budgetOwners.get(ba.Budget_Owner_gne__c).IsActive == true
                    ) {
                EMS_Event__Share newShare = new EMS_Event__Share();
                newShare.UserOrGroupId = ba.Budget_Owner_gne__c;
                newShare.RowCause = Schema.EMS_Event__Share.RowCause.Budget_Owner__c;
                newShare.ParentId = ba.EMS_Event_gne__c;
                newShare.AccessLevel = 'Read';

                sharingsToAdd.add(newShare);
            }
        }
        if (sharingsToAdd.isEmpty() == false) {
            insert sharingsToAdd;
        }
    }

    private static void shareWithApprover(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        List<EMS_Event__Share> eventSharesToInsert = new List<EMS_Event__Share>();
        List<EMS_Budget_Allocation_gne__c> basWithUpdatedApprover = new List<EMS_Budget_Allocation_gne__c>();
        Set<Id> baApproverIds = new Set<Id>(),
                eventIds = new Set<Id>(),
                baOldApproverIds = new Set<Id>();

        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            if (EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id) == false
                    && (triggerOld == null || triggerOld.get(ba.Id).Approver_gne__c != ba.Approver_gne__c)
                    ) {
                basWithUpdatedApprover.add(ba);
                if (ba.Approver_gne__c != null) baApproverIds.add(ba.Approver_gne__c);
                if (triggerOld != null && triggerOld.get(ba.Id).Approver_gne__c != null) baOldApproverIds.add(triggerOld.get(ba.Id).Approver_gne__c);
                eventIds.add(ba.EMS_Event_gne__c);
            }
        }

        if (basWithUpdatedApprover.isEmpty()) {
            return;
        }

        Map<Id, User> baApprovers = new Map<Id, User>([SELECT Id, IsActive FROM User WHERE Id IN :baApproverIds]);

        Set<String> existingEventSharesExternalIds = new Set<String>(); // set of external ids based on ParentId + UserOrGroupId pattern
        for (EMS_Event__Share existingEventShare : [SELECT Id, AccessLevel, ParentId, rowCause, UserOrGroupId FROM EMS_Event__Share WHERE ParentId IN :eventIds]) {
            existingEventSharesExternalIds.add(String.valueOf(existingEventShare.ParentId) + String.valueOf(existingEventShare.UserOrGroupId) + String.valueOf(existingEventShare.rowCause));
        }

        String eventApproverRowCause = Schema.EMS_Event__Share.rowCause.Event_Approver__c;
        Set<Id> ownerParentIdsToRemove = new Set<Id>();
        for (EMS_Budget_Allocation_gne__c ba : basWithUpdatedApprover) {
            String budgetApproverKey = String.valueOf(ba.Id) + String.valueOf(ba.Approver_gne__c) + String.valueOf(eventApproverRowCause);
            Boolean approverSharing = ba.Approver_gne__c != null && baApprovers.get(ba.Approver_gne__c).IsActive && !existingEventSharesExternalIds.contains(budgetApproverKey);

            if (approverSharing) {
                eventSharesToInsert.add(new EMS_Event__Share(
                        ParentId = ba.EMS_Event_gne__c,
                        UserOrGroupId = ba.Approver_gne__c,
                        AccessLevel = 'Read',
                        rowCause = eventApproverRowCause
                ));
            }

            ownerParentIdsToRemove.add(ba.EMS_Event_gne__c);
        }

        if (!ownerParentIdsToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Event__Share WHERE ParentId IN :ownerParentIdsToRemove AND rowCause = :eventApproverRowCause AND UserOrGroupId IN :baOldApproverIds];
        }
        if (!eventSharesToInsert.isEmpty()) {
            insert eventSharesToInsert;
        }
    }

    private static void submitBudgetAllocationForApproval(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        Set<EMS_Event__c> eventsToUpdate = new Set<EMS_Event__c>();
        List<ProcessInstanceWorkitem> reassignedWorkitems = new List<ProcessInstanceWorkitem>();
        List<ProcessInstanceWorkitem> existingWorkitems = [
                SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId, ProcessInstance.Status, OriginalActorId, ActorId
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId IN :triggerNew.keySet()
        ];

        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            Boolean wasApproved = triggerOld == null || (ba.Status_gne__c == 'New' && triggerOld.get(ba.Id).Status_gne__c == 'Approved');
            Boolean isProcessed = EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id);
            Boolean isPendingApproval = relatedEvents.get(ba.EMS_Event_gne__c).Pending_Budget_Approval_gne__c;
            Boolean isApproverPresent = ba.Approver_gne__c != null && triggerOld != null && ba.Approver_gne__c != triggerOld.get(ba.Id).Approver_gne__c;

            if (isProcessed == false && ba.Allocated_Budget_gne__c > 0 && isPendingApproval) {
                for (ProcessInstanceWorkitem workitem : existingWorkitems) {
                    Boolean isAllocationWorkItem = workitem.ProcessInstance.TargetObjectId == ba.Id;
                    Boolean isActorChanged = workitem.ActorId != ba.Approver_gne__c;

                    // If Process Workitems exist for Budget Allocation
                    // Reassign Process Workitems to new Approver
                    if (isAllocationWorkItem && isActorChanged && isApproverPresent) {
                        workitem.ActorId = ba.Approver_gne__c;
                        reassignedWorkitems.add(workitem);
                    }
                }

                if(wasApproved) {
                    Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                    request.setObjectId(ba.id);
                    requests.add(request);

                    EMS_Event__c event = new EMS_Event__c(Id = ba.EMS_Event_gne__c);
                    event.Budget_Approval_Failed_gne__c = false;

                    if (!eventsToUpdate.contains(event)) {
                        eventsToUpdate.add(event);
                    }
                }
            }
        }

        if (!requests.isEmpty()) {
            List<Approval.ProcessResult> result = Approval.process(requests);
            update new List<EMS_Event__c>(eventsToUpdate);
        }

        if(!reassignedWorkitems.isEmpty()) {
            update reassignedWorkitems;
        }
    }

    private static void approveBudgetAllocations(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        Set<EMS_Event__c> eventsToUpdate = new Set<EMS_Event__c>();
        List<Id> eventsWithApprovedBA = new List<Id>();

        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            if (EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id) == false && ba.Status_gne__c == 'Approved') {
                eventsWithApprovedBA.add(ba.EMS_Event_gne__c);
            }
        }

        Map<Id, List<EMS_Budget_Allocation_gne__c>> budgetallocations = fetchBudgetAllocations(eventsWithApprovedBA);
        for (Id eventId : eventsWithApprovedBA) {
            if (budgetallocations.get(eventId) != null) {
                Boolean allBAsApproved = true;
                for (EMS_Budget_Allocation_gne__c ba : budgetallocations.get(eventId)) {
                    allBAsApproved = allBAsApproved && (ba.Status_gne__c == 'Approved');
                }

                EMS_Event__c eventToUpdate = relatedEvents.get(eventId);
                if (allBAsApproved && eventToUpdate.Pending_Budget_Approval_gne__c) {
                    if (eventToUpdate.Total_Budget_Allocated_gne__c == eventToUpdate.Planned_Expenses_gne__c) {
                        // approve event
                        eventToUpdate.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Owner Approved Event').RecordTypeId;
                        eventToUpdate.Status_gne__c = eventConfigurations.get(eventToUpdate.Event_Type_gne__c + eventToUpdate.Event_Sub_Type_gne__c).Budget_Approved_Label_gne__c;
                        eventToUpdate.Pending_Budget_Approval_gne__c = false;
                        eventToUpdate.Budget_Approval_Failed_gne__c = false;
                    } else {
                        // event is still pending budget approval
                        eventToUpdate.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Event').RecordTypeId;
                        eventToUpdate.Budget_Approval_Failed_gne__c = true;
                    }
                    eventsToUpdate.add(eventToUpdate);
                }
            }
        }

        if (!eventsToUpdate.isEmpty()) {
            update new List<EMS_Event__c>(eventsToUpdate);
        }
    }

    private static void rejectBudgetAllocations(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        List<EMS_Event__c> eventsToUpdate = new List<EMS_Event__c>();
        Map<Id, List<EMS_Budget_Allocation_gne__c>> eventsToReject = new Map<Id, List<EMS_Budget_Allocation_gne__c>>();

        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            if (EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id)) {
                System.debug('Skip rejectBudgetAllocations - already processed');
                continue;
            }

            EMS_Budget_Allocation_gne__c old = triggerOld.get(ba.Id);
            if(ba.Status_gne__c == 'Rejected' && old.Status_gne__c != 'Rejected') {
                System.debug('rejectBudgetAllocations - Status change [' + old.Status_gne__c + '] -> [' + ba.Status_gne__c + ']');

                if (!eventsToReject.containsKey(ba.EMS_Event_gne__c)) {
                    eventsToReject.put(ba.EMS_Event_gne__c, new List<EMS_Budget_Allocation_gne__c>());
                }
                eventsToReject.get(ba.EMS_Event_gne__c).add(ba);
                EMS_Budget_Allocation_Trigger_Helper.addToProcessed(ba.Id);
            }
        }

        if (!eventsToReject.isEmpty()) {
            // reject events
            for (Id eventId : eventsToReject.keySet()) {
                EMS_Event__c event = new EMS_Event__c(Id = eventId);
                event.Status_gne__c = 'Rejected';
                event.RecordTypeId = Schema.SObjectType.EMS_Event__c.recordTypeInfosByName.get('EMS Event').recordTypeId;
                event.Pending_Budget_Approval_gne__c = false;
                event.Approval_Rejection_Comments_gne__c = eventsToReject.get(eventId)[0].Comments_gne__c;
                eventsToUpdate.add(event);
            }
            update eventsToUpdate;
        }
    }

    private static void recallBudgetAllocations(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        List<EMS_Event__c> eventsToUpdate = new List<EMS_Event__c>();
        Map<Id, List<EMS_Budget_Allocation_gne__c>> eventsWithRecalleddBA = new Map<Id, List<EMS_Budget_Allocation_gne__c>>();

        for (EMS_Budget_Allocation_gne__c ba : triggerNew.values()) {
            Boolean isNotProcessed = !EMS_Budget_Allocation_Trigger_Helper.isAlreadyProcessed(ba.Id);
            Boolean isNew = ba.Status_gne__c == 'New' && triggerOld.get(ba.Id).Status_gne__c == 'Submitted';
            if (isNotProcessed && isNew) {
                if (!eventsWithRecalleddBA.containsKey(ba.EMS_Event_gne__c)) {
                    eventsWithRecalleddBA.put(ba.EMS_Event_gne__c, new List<EMS_Budget_Allocation_gne__c>());
                }
                eventsWithRecalleddBA.get(ba.EMS_Event_gne__c).add(ba);
                EMS_Budget_Allocation_Trigger_Helper.addToProcessed(ba.Id);
            }
        }
        if (!eventsWithRecalleddBA.isEmpty()) {
            Map<Id, List<EMS_Budget_Allocation_gne__c>> budgetallocations = fetchBudgetAllocations(new List<Id>(eventsWithRecalleddBA.keySet()));
            Set<Id> otherBudgetAllocationIds = new Set<Id>();
            for (Id eventId : budgetallocations.keySet()) {
                for (EMS_Budget_Allocation_gne__c ba : budgetallocations.get(eventId)) {
                    if (!triggerNew.containsKey(ba.Id)) {
                        otherBudgetAllocationIds.add(ba.Id);
                    }
                }
            }

            // recall other budget allocations
            List<ProcessInstanceWorkitem> piwItems = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN (SELECT Id FROM ProcessInstance WHERE TargetObjectId IN :otherBudgetAllocationIds)];
            if (piwItems.size() > 0) {
                List<Approval.ProcessWorkitemRequest> approvalsToRecall = new List<Approval.ProcessWorkitemRequest>();
                for (ProcessInstanceWorkitem piwItem : piwItems) {
                    Approval.ProcessWorkitemRequest rejectAppr = new Approval.ProcessWorkitemRequest();
                    rejectAppr.setComments('Other budget allocation was rejected or recalled');
                    rejectAppr.setAction('Removed');
                    rejectAppr.setWorkitemId(piwItem.Id);
                    approvalsToRecall.add(rejectAppr);
                }
                List<Approval.ProcessResult> recallResults = Approval.process(approvalsToRecall);
            }

            // recall events
            for (Id eventId : eventsWithRecalleddBA.keySet()) {
                EMS_Event__c event = new EMS_Event__c(Id = eventId);
                event.Status_gne__c = 'Recalled';
                event.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Event').RecordTypeId;
                event.Pending_Budget_Approval_gne__c = false;

                eventsToUpdate.add(event);
            }

            update eventsToUpdate;
        }
    }

    // Additional methods
    private static Map<String, EMS_Event_Configuration_gne__c> getEventConfigurations() {
        Map<String, EMS_Event_Configuration_gne__c> result = new Map<String, EMS_Event_Configuration_gne__c>();
        for (EMS_Event_Configuration_gne__c evConfig : [SELECT Event_Type_gne__c, Event_Sub_Type_gne__c, Budget_Approved_Label_gne__c FROM EMS_Event_Configuration_gne__c]) {
            result.put(evConfig.Event_Type_gne__c + evConfig.Event_Sub_Type_gne__c, evConfig);
        }

        return result;
    }

    private static Map<Id, List<EMS_Budget_Allocation_gne__c>> fetchBudgetAllocations(List<Id> events) {
        Map<Id, List<EMS_Budget_Allocation_gne__c>> result = new Map<Id, List<EMS_Budget_Allocation_gne__c>>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = [SELECT Budget_Owner_gne__c, EMS_Event_gne__c, Status_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :events AND Allocated_Budget_gne__c > 0];
        for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
            if (!result.containsKey(ba.EMS_Event_gne__c)) {
                result.put(ba.EMS_Event_gne__c, new List<EMS_Budget_Allocation_gne__c>());
            }
            result.get(ba.EMS_Event_gne__c).add(ba);
        }

        return result;
    }

    private static void updateBudgets(Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        // disable validation rules for related budgets
        EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;

        if (!productBudgetMapToUpdate.isEmpty()) {
            update productBudgetMapToUpdate.values();
        }
        if (!regionBudgetMapToUpdate.isEmpty()) {
            update regionBudgetMapToUpdate.values();
        }
        if (!territoryBudgetMapToUpdate.IsEmpty()) {
            update territoryBudgetMapToUpdate.values();
        }
    }

    private static void updateAllocatedBudgetOnUpdate(EMS_Budget_Allocation_gne__c budgetAllocationOld, EMS_Budget_Allocation_gne__c budgetAllocationNew) {
        // closed/cancelled events already have the funds sent back to the related budget
        if (budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Event_gne__r.Status_gne__c != 'Closed' && budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Event_gne__r.Status_gne__c != 'Cancelled') {
            Decimal allocatedBudgetChange = budgetAllocationNew.Allocated_Budget_gne__c - budgetAllocationOld.Allocated_Budget_gne__c;
            if (budgetAllocationRecordTypes.get(budgetAllocationNew.RecordTypeId).getName() == 'Product Budget Allocation' && budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c != null) {
                Id bpId = budgetAllocationNew.EMS_Product_Budget_gne__c;
                if (productBudgetMapToUpdate.get(bpID) == null) {
                    EMS_Budget_Product_gne__c bp = new EMS_Budget_Product_gne__c(
                            id = bpId,
                            Events_Allocated_Amount__c = budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c + allocatedBudgetChange
                    );
                    productBudgetMapToUpdate.put(bp.Id, bp);
                } else {
                    productBudgetMapToUpdate.get(bpId).Events_Allocated_Amount__c += allocatedBudgetChange;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocationNew.RecordTypeId).getName() == 'Region Budget Allocation' && budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id brId = budgetAllocationNew.EMS_Region_Budget_gne__c;
                if (regionBudgetMapToUpdate.get(brID) == null) {
                    EMS_Budget_Region_gne__c br = new EMS_Budget_Region_gne__c(
                            id = brId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c + allocatedBudgetChange
                    );
                    regionBudgetMapToUpdate.put(br.Id, br);
                } else {
                    regionBudgetMapToUpdate.get(brID).Events_Allocated_Amount_gne__c += allocatedBudgetChange;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocationNew.RecordTypeId).getName() == 'Territory Budget Allocation' && budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id btId = budgetAllocationNew.EMS_Territory_Budget_gne__c;
                if (territoryBudgetMapToUpdate.get(btID) == null) {
                    EMS_Budget_Territory_gne__c bt = new EMS_Budget_Territory_gne__c(
                            id = btId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c + allocatedBudgetChange
                    );
                    territoryBudgetMapToUpdate.put(bt.Id, bt);
                } else {
                    territoryBudgetMapToUpdate.get(btID).Events_Allocated_Amount_gne__c += allocatedBudgetChange;
                }
            }
        } else {
            //  for closed/cancelled events take actuals
            Decimal budgetDeductionsChange = budgetAllocationNew.Budget_Deductions_gne__c - budgetAllocationOld.Budget_Deductions_gne__c;
            if (budgetAllocationRecordTypes.get(budgetAllocationNew.RecordTypeId).getName() == 'Product Budget Allocation' && budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c != null) {
                Id bpId = budgetAllocationNew.EMS_Product_Budget_gne__c;
                if (productBudgetMapToUpdate.get(bpID) == null) {
                    EMS_Budget_Product_gne__c bp = new EMS_Budget_Product_gne__c(
                            id = bpId,
                            Events_Allocated_Amount__c = budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c + budgetDeductionsChange
                    );
                    productBudgetMapToUpdate.put(bp.Id, bp);
                } else {
                    productBudgetMapToUpdate.get(bpId).Events_Allocated_Amount__c += budgetDeductionsChange;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocationNew.RecordTypeId).getName() == 'Region Budget Allocation' && budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id brId = budgetAllocationNew.EMS_Region_Budget_gne__c;
                if (regionBudgetMapToUpdate.get(brID) == null) {
                    EMS_Budget_Region_gne__c br = new EMS_Budget_Region_gne__c(
                            id = brId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c + budgetDeductionsChange
                    );
                    regionBudgetMapToUpdate.put(br.Id, br);
                } else {
                    regionBudgetMapToUpdate.get(brID).Events_Allocated_Amount_gne__c += budgetDeductionsChange;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocationNew.RecordTypeId).getName() == 'Territory Budget Allocation' && budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id btId = budgetAllocationNew.EMS_Territory_Budget_gne__c;
                if (territoryBudgetMapToUpdate.get(btID) == null) {
                    EMS_Budget_Territory_gne__c bt = new EMS_Budget_Territory_gne__c(
                            id = btId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocationNew.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c + budgetDeductionsChange
                    );
                    territoryBudgetMapToUpdate.put(bt.Id, bt);
                } else {
                    territoryBudgetMapToUpdate.get(btID).Events_Allocated_Amount_gne__c += budgetDeductionsChange;
                }
            }
        }
    }

    private static void updateAllocatedBudgetOnInsert(EMS_Budget_Allocation_gne__c budgetAllocation) {
        // closed/cancelled events already have the funds sent back to the related budget
        if (budgetAllocationFullData.get(budgetAllocation.Id).EMS_Event_gne__r.Status_gne__c != 'Closed' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Event_gne__r.Status_gne__c != 'Cancelled') {
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c != null) {
                Id bpId = budgetAllocation.EMS_Product_Budget_gne__c;
                if (productBudgetMapToUpdate.get(bpID) == null) {
                    EMS_Budget_Product_gne__c bp = new EMS_Budget_Product_gne__c(
                            id = bpId,
                            Events_Allocated_Amount__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c + budgetAllocation.Allocated_Budget_gne__c
                    );
                    productBudgetMapToUpdate.put(bp.Id, bp);
                } else {
                    productBudgetMapToUpdate.get(bpId).Events_Allocated_Amount__c += budgetAllocation.Allocated_Budget_gne__c;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id brId = budgetAllocation.EMS_Region_Budget_gne__c;
                if (regionBudgetMapToUpdate.get(brID) == null) {
                    EMS_Budget_Region_gne__c br = new EMS_Budget_Region_gne__c(
                            id = brId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c + budgetAllocation.Allocated_Budget_gne__c
                    );
                    regionBudgetMapToUpdate.put(br.Id, br);
                } else {
                    regionBudgetMapToUpdate.get(brID).Events_Allocated_Amount_gne__c += budgetAllocation.Allocated_Budget_gne__c;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id btId = budgetAllocation.EMS_Territory_Budget_gne__c;
                if (territoryBudgetMapToUpdate.get(btID) == null) {
                    EMS_Budget_Territory_gne__c bt = new EMS_Budget_Territory_gne__c(
                            id = btId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c + budgetAllocation.Allocated_Budget_gne__c
                    );
                    territoryBudgetMapToUpdate.put(bt.Id, bt);
                } else {
                    territoryBudgetMapToUpdate.get(btID).Events_Allocated_Amount_gne__c += budgetAllocation.Allocated_Budget_gne__c;
                }
            }
        } else {
            //  for closed/cancelled events take actuals
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c != null) {
                Id bpId = budgetAllocation.EMS_Product_Budget_gne__c;
                if (productBudgetMapToUpdate.get(bpID) == null) {
                    EMS_Budget_Product_gne__c bp = new EMS_Budget_Product_gne__c(
                            id = bpId,
                            Events_Allocated_Amount__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c + budgetAllocation.Budget_Deductions_gne__c
                    );
                    productBudgetMapToUpdate.put(bp.Id, bp);
                } else {
                    productBudgetMapToUpdate.get(bpId).Events_Allocated_Amount__c += budgetAllocation.Budget_Deductions_gne__c;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id brId = budgetAllocation.EMS_Region_Budget_gne__c;
                if (regionBudgetMapToUpdate.get(brID) == null) {
                    EMS_Budget_Region_gne__c br = new EMS_Budget_Region_gne__c(
                            id = brId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c + budgetAllocation.Budget_Deductions_gne__c
                    );
                    regionBudgetMapToUpdate.put(br.Id, br);
                } else {
                    regionBudgetMapToUpdate.get(brID).Events_Allocated_Amount_gne__c += budgetAllocation.Budget_Deductions_gne__c;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id btId = budgetAllocation.EMS_Territory_Budget_gne__c;
                if (territoryBudgetMapToUpdate.get(btID) == null) {
                    EMS_Budget_Territory_gne__c bt = new EMS_Budget_Territory_gne__c(
                            id = btId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c + budgetAllocation.Budget_Deductions_gne__c
                    );
                    territoryBudgetMapToUpdate.put(bt.Id, bt);
                } else {
                    territoryBudgetMapToUpdate.get(btID).Events_Allocated_Amount_gne__c += budgetAllocation.Budget_Deductions_gne__c;
                }
            }
        }
    }

    // On Delete Methods
    private static void changeEventStatusIfNeed(List<EMS_Budget_Allocation_gne__c> triggerOld) {
        Set<Id> eventsIDs = new Set<Id>();
        for (EMS_Budget_Allocation_gne__c ba : triggerOld) {
            eventsIDs.add(ba.EMS_Event_gne__c);
        }

        if (eventsIDs.isEmpty()) {
            return;
        }

        List<EMS_Budget_Allocation_gne__c> relatedBudgetAllocations = [
                SELECT Status_gne__c, EMS_Event_gne__c, Allocated_Budget_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE EMS_Event_gne__c IN :eventsIDs
        ];
        Map<Id, List<EMS_Budget_Allocation_gne__c>> eventID_budgetAllocations_map = new Map<Id, List<EMS_Budget_Allocation_gne__c>>();
        for (EMS_Budget_Allocation_gne__c ba : relatedBudgetAllocations) {
            Id key = (Id) ba.EMS_Event_gne__c;
            if (eventID_budgetAllocations_map.containsKey(key)) {
                List<EMS_Budget_Allocation_gne__c> temp = eventID_budgetAllocations_map.get(key);
                temp.add(ba);
                eventID_budgetAllocations_map.put(key, temp);
            } else {
                eventID_budgetAllocations_map.put(key, new List<EMS_Budget_Allocation_gne__c>{
                        ba
                });
            }
        }

        Map<Id, EMS_Event__c> eventMap = new Map<Id, EMS_Event__c>([SELECT Event_Type_gne__c, Event_Sub_Type_gne__c, Total_Budget_Allocated_gne__c, Planned_Expenses_gne__c, Status_gne__c FROM EMS_Event__c WHERE Id IN :eventsIDs]);
        Set<Id> eventIDsToUpdate = new Set<Id>();
        for (Id key : eventID_budgetAllocations_map.keySet()) {
            // only for a case when total budget allocation is equal to planned expenses
            Decimal sum = 0; // sum variable reflects total budget allocation value for an event record
            for (EMS_Budget_Allocation_gne__c ba : eventID_budgetAllocations_map.get(key)) {
                sum = sum + ba.Allocated_Budget_gne__c;
            }

            Boolean isBudgetOK = (eventMap.get(key).Planned_Expenses_gne__c == sum);
            if (isBudgetOK) {
                Boolean doChangeStatus = false;

                for (EMS_Budget_Allocation_gne__c ba : eventID_budgetAllocations_map.get(key)) {
                    if (ba.Status_gne__c == 'Approved') {
                        doChangeStatus = true;
                    } else {
                        doChangeStatus = false;
                        break;
                    }
                }

                if (doChangeStatus) {
                    eventIDsToUpdate.add(key);
                }
            }
        }
        if (eventIDsToUpdate.isEmpty() == false) {
            // Use a future method because roll-up summary field (Event.Total_Budget_Allocated) does not update its value
            updateEvents(eventIDsToUpdate);
        }
    }

    @future
    public static void updateEvents(Set<Id> eventIDsToUpdate) {
        List<EMS_Event__c> eventsToUpdate = [SELECT Status_gne__c, Event_Type_gne__c, Event_Sub_Type_gne__c FROM EMS_Event__c WHERE Id IN:eventIDsToUpdate];
        eventConfigurations = getEventConfigurations();
        if (eventIDsToUpdate.isEmpty() == false) {
            for (EMS_Event__c event :eventsToUpdate) {
                event.Status_gne__c = eventConfigurations.get(event.Event_Type_gne__c + event.Event_Sub_Type_gne__c).Budget_Approved_Label_gne__c;
            }
            update eventsToUpdate;
        }
    }

    private static void updateAllocatedAmountOnDelete(Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        productBudgetMapToUpdate = new Map<Id, EMS_Budget_Product_gne__c>();
        regionBudgetMapToUpdate = new Map<Id, EMS_Budget_Region_gne__c>();
        territoryBudgetMapToUpdate = new Map<Id, EMS_Budget_Territory_gne__c>();

        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew.values()) {
            updateAllocatedBudgetOnDelete(budgetAllocation);
        }
        updateBudgets(triggerNew);
    }

    private static void updateAllocatedBudgetOnDelete(EMS_Budget_Allocation_gne__c budgetAllocation) {
        // closed/cancelled events already have the funds sent back to the related budget
        if (budgetAllocationFullData.get(budgetAllocation.Id).EMS_Event_gne__r.Status_gne__c != 'Closed' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Event_gne__r.Status_gne__c != 'Cancelled') {
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c != null) {
                Id bpId = budgetAllocation.EMS_Product_Budget_gne__c;
                if (productBudgetMapToUpdate.get(bpID) == null) {
                    EMS_Budget_Product_gne__c bp = new EMS_Budget_Product_gne__c(
                            id = bpId,
                            Events_Allocated_Amount__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c - budgetAllocation.Allocated_Budget_gne__c
                    );
                    productBudgetMapToUpdate.put(bp.Id, bp);
                } else {
                    productBudgetMapToUpdate.get(bpId).Events_Allocated_Amount__c -= budgetAllocation.Allocated_Budget_gne__c;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id brId = budgetAllocation.EMS_Region_Budget_gne__c;
                if (regionBudgetMapToUpdate.get(brID) == null) {
                    EMS_Budget_Region_gne__c br = new EMS_Budget_Region_gne__c(
                            id = brId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c - budgetAllocation.Allocated_Budget_gne__c
                    );
                    regionBudgetMapToUpdate.put(br.Id, br);
                } else {
                    regionBudgetMapToUpdate.get(brID).Events_Allocated_Amount_gne__c -= budgetAllocation.Allocated_Budget_gne__c;
                }

            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id btId = budgetAllocation.EMS_Territory_Budget_gne__c;
                if (territoryBudgetMapToUpdate.get(btID) == null) {
                    EMS_Budget_Territory_gne__c bt = new EMS_Budget_Territory_gne__c(
                            id = btId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c - budgetAllocation.Allocated_Budget_gne__c
                    );
                    territoryBudgetMapToUpdate.put(bt.Id, bt);
                } else {
                    territoryBudgetMapToUpdate.get(btID).Events_Allocated_Amount_gne__c -= budgetAllocation.Allocated_Budget_gne__c;
                }
            }
        } else {
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c != null) {
                Id bpId = budgetAllocation.EMS_Product_Budget_gne__c;
                if (productBudgetMapToUpdate.get(bpID) == null) {
                    EMS_Budget_Product_gne__c bp = new EMS_Budget_Product_gne__c(
                            id = bpId,
                            Events_Allocated_Amount__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Product_Budget_gne__r.Events_Allocated_Amount__c - budgetAllocation.Budget_Deductions_gne__c
                    );
                    productBudgetMapToUpdate.put(bp.Id, bp);
                } else {
                    productBudgetMapToUpdate.get(bpId).Events_Allocated_Amount__c -= budgetAllocation.Budget_Deductions_gne__c;
                }
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id brId = budgetAllocation.EMS_Region_Budget_gne__c;
                if (regionBudgetMapToUpdate.get(brID) == null) {
                    EMS_Budget_Region_gne__c br = new EMS_Budget_Region_gne__c(
                            id = brId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Region_Budget_gne__r.Events_Allocated_Amount_gne__c - budgetAllocation.Budget_Deductions_gne__c
                    );
                    regionBudgetMapToUpdate.put(br.Id, br);
                } else {
                    regionBudgetMapToUpdate.get(brID).Events_Allocated_Amount_gne__c -= budgetAllocation.Budget_Deductions_gne__c;
                }

            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation' && budgetAllocationFullData.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c != null) {
                Id btId = budgetAllocation.EMS_Territory_Budget_gne__c;
                if (territoryBudgetMapToUpdate.get(btID) == null) {
                    EMS_Budget_Territory_gne__c bt = new EMS_Budget_Territory_gne__c(
                            id = btId,
                            Events_Allocated_Amount_gne__c = budgetAllocationFullData.get(budgetAllocation.Id).EMS_Territory_Budget_gne__r.Events_Allocated_Amount_gne__c - budgetAllocation.Budget_Deductions_gne__c
                    );
                    territoryBudgetMapToUpdate.put(bt.Id, bt);
                } else {
                    territoryBudgetMapToUpdate.get(btID).Events_Allocated_Amount_gne__c -= budgetAllocation.Budget_Deductions_gne__c;
                }
            }
        }
    }

    private static void removeSharingWithBudgetOwner(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld) {
        List <EMS_Event__Share> sharingsToRemove = new List <EMS_Event__Share>();
        String rowCause = Schema.EMS_Event__Share.RowCause.Budget_Owner__c;
        Set<Id> ownersIds = new Set<Id>();
        Set<Id> parentsIds = new Set<Id>();

        for (EMS_Budget_Allocation_gne__c budgetAllocation : [SELECT Budget_Owner_gne__c, Approver_gne__c, EMS_Event_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :triggerOld.values()]) {
            ownersIds.add(budgetAllocation.Budget_Owner_gne__c);
            ownersIds.add(budgetAllocation.Approver_gne__c);
            parentsIds.add(budgetAllocation.EMS_Event_gne__c);
        }
        sharingsToRemove = [SELECT Id FROM EMS_Event__Share WHERE RowCause = :rowCause AND UserOrGroupId IN :ownersIds AND ParentId IN :parentsIds];

        delete sharingsToRemove;
    }

    @future
    public static void recalculateBudgetDeductionsFuture(Set<Id> eventIds) {
        Map<String, Decimal> budgetAllocationsByCostCenter = new Map<String, Decimal>();
        Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocationsToUpdate = new Map<Id, EMS_Budget_Allocation_gne__c>();

        // select budget allocations
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Cost_Center_gne__c, EMS_Event_gne__c, Percentage_Contribution_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :eventIds]) {
            String costCenterName = ba.Cost_Center_gne__c;
            String eventId = ba.EMS_Event_gne__c;

            if (!budgetAllocationsByCostCenter.containsKey(eventId + costCenterName)) {
                budgetAllocationsByCostCenter.put(eventId + costCenterName, ba.Percentage_Contribution_gne__c);
            } else {
                Double currentPercentage = budgetAllocationsByCostCenter.get(eventId + costCenterName);
                budgetAllocationsByCostCenter.put(eventId + costCenterName, currentPercentage + ba.Percentage_Contribution_gne__c);
            }
        }

        List<EMS_Expense_gne__c> expenses = [SELECT EMS_Cost_Center_gne__r.Name, EMS_Event_gne__c, Country_Expense_Amount_gne__c FROM EMS_Expense_gne__c WHERE EMS_Event_gne__c IN :eventIds];
        Map<String, Decimal> expensesByCostCenter = new Map<String, Decimal>();
        for (EMS_Expense_gne__c exp : expenses) {
            String costCenterName = exp.EMS_Cost_Center_gne__r.Name;
            String eventId = exp.EMS_Event_gne__c;
            Decimal amount = exp.Country_Expense_Amount_gne__c;

            if (!expensesByCostCenter.containsKey(eventId + costCenterName)) {
                expensesByCostCenter.put(eventId + costCenterName, amount);
            } else {
                Decimal currentAmount = expensesByCostCenter.get(eventId + costCenterName);
                currentAmount += amount;

                expensesByCostCenter.put(eventId + costCenterName, currentAmount);
            }
        }

        Map<String, List<EMS_Budget_Allocation_gne__c>> budgetAllocationsMap = new Map<String, List<EMS_Budget_Allocation_gne__c>>();
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Id, EMS_Event_gne__c, Cost_Center_gne__c, Budget_Deductions_gne__c, Percentage_Contribution_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :eventIds ORDER BY Id]) {
            if (!budgetAllocationsMap.containsKey(String.valueOf(ba.EMS_Event_gne__c) + String.valueOf(ba.Cost_Center_gne__c))) {
                budgetAllocationsMap.put(String.valueOf(ba.EMS_Event_gne__c) + String.valueOf(ba.Cost_Center_gne__c), new List<EMS_Budget_Allocation_gne__c>());
            }

            budgetAllocationsMap.get(String.valueOf(ba.EMS_Event_gne__c) + String.valueOf(ba.Cost_Center_gne__c)).add(ba);
        }

        Map<String, Decimal> deductionsSum = new Map<String, Decimal>();
        for (String key : budgetAllocationsMap.keySet()) {
            Integer lastElementIndex = budgetAllocationsMap.get(key).size() - 1;
            for (Integer i = 0; i < budgetAllocationsMap.get(key).size(); i++) {
                EMS_Budget_Allocation_gne__c ba = budgetAllocationsMap.get(key)[i];
                Decimal expensesForCC = expensesByCostCenter.containsKey(key) ? expensesByCostCenter.get(key) : 0;

                if (!budgetAllocationsToUpdate.containsKey(ba.Id) && budgetAllocationsByCostCenter.get(key) != 0) {
                    if (lastElementIndex == 0 || i != lastElementIndex) {
                        Decimal toBeDeducted = expensesForCC * (ba.Percentage_Contribution_gne__c / budgetAllocationsByCostCenter.get(key));
                        Decimal currentDeductions = deductionsSum.containsKey(key) ? deductionsSum.get(key) : 0;
                        deductionsSum.put(key, currentDeductions + toBeDeducted.setScale(2));
                        ba.Budget_Deductions_gne__c = toBeDeducted.setScale(2); // round to 2 decimal places

                    } else {
                        ba.Budget_Deductions_gne__c = (expensesForCC - deductionsSum.get(key)).setScale(2); // round to 2 decimal places
                    }
                    budgetAllocationsToUpdate.put(ba.Id, ba);
                } else if (budgetAllocationsByCostCenter.get(key) != 0) {
                    if (lastElementIndex == 0 || i != lastElementIndex) {
                        Decimal toBeDeducted = expensesForCC * (ba.Percentage_Contribution_gne__c / budgetAllocationsByCostCenter.get(key));
                        Decimal currentDeductions = deductionsSum.containsKey(key) ? deductionsSum.get(key) : 0;
                        deductionsSum.put(key, currentDeductions + toBeDeducted.setScale(2));
                        budgetAllocationsToUpdate.get(ba.Id).Budget_Deductions_gne__c += toBeDeducted.setScale(2); // round to 2 decimal places
                    } else {
                        budgetAllocationsToUpdate.get(ba.Id).Budget_Deductions_gne__c += (expensesForCC - deductionsSum.get(key)).setScale(2); // round to 2 decimal places
                    }
                }
            }
        }

        if (!budgetAllocationsToUpdate.isEmpty()) {
            update budgetAllocationsToUpdate.values();
        }
    }

    private static void recalculateBudgetDeductions(List<EMS_Budget_Allocation_gne__c> triggerOld) {
        Set<Id> ids = new Set<Id>();
        for (EMS_Budget_Allocation_gne__c ba : triggerOld) {
            ids.add(ba.EMS_Event_gne__c);
        }

        if (!System.isFuture() && !System.isBatch() && !Test.isRunningTest()) {
            recalculateBudgetDeductionsFuture(ids);
        }
    }
}