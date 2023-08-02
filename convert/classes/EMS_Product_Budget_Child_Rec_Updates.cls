public without sharing class EMS_Product_Budget_Child_Rec_Updates {

    private static Map<Id, Id> relatedGroups; //territory Id , group Id
    private static final String rowCauseTerritorySharing = Schema.EMS_Budget_Product_gne__Share.RowCause.Territory_Sharing__c;

    private static Map<Id, GNE_User_Delegation__c> userDelegations = EMS_Util.getUserDelegations();
    private static Id getDelegatedUser(Id mainUserId) {
        Id delegatedUserId = mainUserId;
        if (userDelegations.containsKey(mainUserId)) {
            delegatedUserId = userDelegations.get(mainUserId).Delegated_User__c;
        }
        return delegatedUserId;
    }

    /**************************************************************************
    ********************* Methods called by trigger ***************************
    **************************************************************************/

    public static void onAfterInsert(List<EMS_Budget_Product_gne__c> triggerNew) {
        getGroupsRelatedToTerritory(triggerNew);
        shareProductBudgetWithTerritory(null, triggerNew);
    }

    public static void onAfterUpdate(List<EMS_Budget_Product_gne__c> triggerOld, List<EMS_Budget_Product_gne__c> triggerNew) {
        System.debug('>>>> EMS_Product_Budget_Child_Rec_Updates.onAfterUpdate');
        getGroupsRelatedToTerritory(triggerNew);
        shareProductBudgetWithTerritory(new Map<Id, EMS_Budget_Product_gne__c>(triggerOld), triggerNew);

        deactivateChildBudgets(triggerOld, triggerNew);
        reasignFRApproverOnAssignedToChange(triggerOld, triggerNew);
        updateBudgetAllocations(new Map<Id, EMS_Budget_Product_gne__c>(triggerNew));
    }

    public static void onBeforeDelete(List<EMS_Budget_Product_gne__c> triggerOld) {
        deleteBudgetAllocations(triggerOld);
    }

    /**************************************************************************
    **************************** Action methods *******************************
    **************************************************************************/

    private static void getGroupsRelatedToTerritory(List<EMS_Budget_Product_gne__c> triggerNew) {
        Set<Id> relatedTerritories = new Set<Id>();
        for (EMS_Budget_Product_gne__c pb : triggerNew) {
            if (pb.Assigned_To_Territory_Id__c == null) {
                continue;
            }
            relatedTerritories.add(pb.Assigned_To_Territory_Id__c);
        }
        relatedGroups = EMS_Util.getTerritoriesGroups(relatedTerritories);
    }

    private static void shareProductBudgetWithTerritory(Map<Id, EMS_Budget_Product_gne__c> triggerOld, List<EMS_Budget_Product_gne__c> triggerNew) {
        Set<String> existingProductSharesExternalIds = new Set<String>(); // set of external ids based on ParentId + UserOrGroupId pattern
        for (EMS_Budget_Product_gne__Share existingProductShare : [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :triggerNew]) {
            existingProductSharesExternalIds.add(String.valueOf(existingProductShare.ParentId) + String.valueOf(existingProductShare.UserOrGroupId) + String.valueOf(existingProductShare.RowCause));
        }

        Set<Id> parentIdsToRemove = new Set<Id>();
        List<EMS_Budget_Product_gne__Share> productSharesToInsert = new List <EMS_Budget_Product_gne__Share>();
        for (EMS_Budget_Product_gne__c pb : triggerNew) {
            if (pb.Assigned_To_Territory_Id__c == null) {
                continue;
            }

            Boolean territoryChanged = triggerOld == null
                    || triggerOld.get(pb.Id).Assigned_To_Territory_Id__c != pb.Assigned_To_Territory_Id__c;
            Boolean doesShareExist = existingProductSharesExternalIds.contains(String.valueOf(pb.Id) + String.valueOf(relatedGroups.get(pb.Assigned_To_Territory_Id__c)) + rowCauseTerritorySharing);
            if (!doesShareExist
                    && relatedGroups.containsKey(pb.Assigned_To_Territory_Id__c)
                    && territoryChanged
                    ) {
                EMS_Budget_Product_gne__Share pShare = new EMS_Budget_Product_gne__Share(
                        ParentId = pb.Id,
                        UserOrGroupId = relatedGroups.get(pb.Assigned_To_Territory_Id__c),
                        AccessLevel = 'Edit',
                        RowCause = rowCauseTerritorySharing
                );
                productSharesToInsert.add(pShare);
                parentIdsToRemove.add(pb.Id);
            }
        }
        if (!parentIdsToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :parentIdsToRemove AND RowCause = :rowCauseTerritorySharing];
        }
        if (!productSharesToInsert.isEmpty()) {
            insert productSharesToInsert;
        }
    }


    private static void deactivateChildBudgets(List<EMS_Budget_Product_gne__c> triggerOld, List<EMS_Budget_Product_gne__c> triggerNew) {
        List<EMS_Budget_Product_gne__c> deactivatedBudgets = new List<EMS_Budget_Product_gne__c>();
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (triggerOld[i].Status_gne__c == 'Active' && triggerNew[i].Status_gne__c == 'Inactive') {
                deactivatedBudgets.add(triggerNew[i]);
            }
        }
        if (deactivatedBudgets.isEmpty()) {
            return;
        }

        // reject related fund requests
        EMS_Fund_Request_Trigger_Helper.inFundRequestTrigger = true;
        List<EMS_Fund_Request_gne__c> relatedFundRequests = [SELECT Status_gne__c FROM EMS_Fund_Request_gne__c WHERE Related_Product_Budget_gne__c IN :deactivatedBudgets];
        List<Id> ids = new List<Id>();
        for (ProcessInstanceWorkitem workItem : [SELECT p.Id FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId IN :relatedFundRequests]) {
            // EMS_Util.rejectApproval(workItem.Id);
            ids.add(workItem.Id);
        }
        EMS_Util.rejectApprovals(ids, 'Related budget was deactivated.');


        List<EMS_Fund_Request_gne__c> fundRequestsToUpdate = new List<EMS_Fund_Request_gne__c>();
        // reject fund requests in 'New' status
        for (EMS_Fund_Request_gne__c fundRequest : relatedFundRequests) {
            if (fundRequest.Status_gne__c == 'New' || fundRequest.Status_gne__c == 'Cancelled') {
                fundRequest.Status_gne__c = 'Rejected';
                fundRequestsToUpdate.add(fundRequest);
            }
        }
        if (!fundRequestsToUpdate.isEmpty()) {
            update fundRequestsToUpdate;
        }

        // deactive child budgets
        List<EMS_Budget_Region_gne__c> childBudgets = [SELECT Status_gne__c FROM EMS_Budget_Region_gne__c WHERE Status_gne__c != 'Inactive' AND EMS_Budget_Product_gne__c IN :deactivatedBudgets];
        for (EMS_Budget_Region_gne__c childBudget : childBudgets) {
            childBudget.Status_gne__c = 'Inactive';
        }
        update childBudgets;
    }

    private static void deleteBudgetAllocations(List<EMS_Budget_Product_gne__c> triggerOld) {
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsToDelete = new List<EMS_Budget_Allocation_gne__c>();
        budgetAllocationsToDelete = [SELECT id FROM EMS_Budget_Allocation_gne__c WHERE EMS_Product_Budget_gne__c IN :triggerOld];

        delete budgetAllocationsToDelete;
    }

    private static void updateBudgetAllocations(Map<Id, EMS_Budget_Product_gne__c> budgets) {
        Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocations = new Map<Id, EMS_Budget_Allocation_gne__c>();
        for(EMS_Budget_Allocation_gne__c budgetAllocation : [
                SELECT Id, Approver_gne__c, Budget_Owner_gne__c, EMS_Product_Budget_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE EMS_Product_Budget_gne__c IN :budgets.keySet()
                AND Status_gne__c IN ('Submitted', 'New')
        ]) {
            Id budgetOwnerId = budgets.get(budgetAllocation.EMS_Product_Budget_gne__c).Assigned_to_gne__c;
            Id newApproverId = getDelegatedUser(budgetOwnerId);
            if(budgetAllocation.Approver_gne__c != newApproverId || budgetAllocation.Budget_Owner_gne__c != budgetOwnerId) {
                budgetAllocation.Budget_Owner_gne__c = budgetOwnerId;
                budgetAllocation.Approver_gne__c = newApproverId;
                budgetAllocations.put(budgetAllocation.Id, budgetAllocation);
            }
        }

        update budgetAllocations.values();
    }
    private static void reasignFRApproverOnAssignedToChange(List<EMS_Budget_Product_gne__c> triggerOld, List<EMS_Budget_Product_gne__c> triggerNew) {
        Map<Id, EMS_Budget_Product_gne__c> oldRecords = new Map<Id, EMS_Budget_Product_gne__c>(triggerOld);
        Map<Id, EMS_Budget_Product_gne__c> budgetsWithModifiedOwner = new Map<Id, EMS_Budget_Product_gne__c>();
        for (EMS_Budget_Product_gne__c newRecord : triggerNew) {
            if (newRecord.Assigned_to_gne__c != oldRecords.get(newRecord.Id).Assigned_to_gne__c) {
                budgetsWithModifiedOwner.put(newRecord.Id, newRecord);
            }
        }

        // Find all FR for each modified budget
        List<EMS_Fund_Request_gne__c> frRequests = [
                SELECT Approver_gne__c, Record_Type_Name_gne__c, Related_Product_Budget_gne__c
                FROM EMS_Fund_Request_gne__c
                WHERE Record_Type_Name_gne__c = 'Region Fund Allocation' AND Related_Product_Budget_gne__c IN :budgetsWithModifiedOwner.values()
        ];

        // Check which FR have approval process in progress
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :frRequests];
        List<Approval.ProcessWorkitemRequest> piwiToRemove = new List<Approval.ProcessWorkitemRequest>();
        for (ProcessInstanceWorkitem piw : piwi) {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setComments('Budget owner changed.');
            request.setAction('Removed');
            request.setWorkitemId(piw.Id);
            piwiToRemove.add(request);
        }
        // Recall all current Approval processes
        System.Savepoint initialState = Database.setSavepoint();
        try {
            List<Approval.ProcessResult> results = Approval.process(piwiToRemove);
        } catch (Exception ex) {
            Database.rollback(initialState);
        }

        // Change FR Approver
        List<EMS_Fund_Request_gne__c> frToUpdate = new List<EMS_Fund_Request_gne__c>();
        for (EMS_Fund_Request_gne__c fr : frRequests) {
            fr.Approver_gne__c = budgetsWithModifiedOwner.get(fr.Related_Product_Budget_gne__c).Assigned_to_gne__c;
            frToUpdate.add(fr);
        }
        try {
            update frToUpdate;
        } catch (Exception ex) {
            Database.rollback(initialState);
        }

        // Send for approval items that had approval process in progress
        Map<Id, EMS_Fund_Request_gne__c> updatedFRs = new Map<Id, EMS_Fund_Request_gne__c>([SELECT Related_Product_Budget_gne__c FROM EMS_Fund_Request_gne__c WHERE Id IN :frToUpdate]);
        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (ProcessInstanceWorkitem piw : piwi) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(piw.ProcessInstance.TargetObjectId);
            req.setComments('Budget owner changed.');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);
    }

}