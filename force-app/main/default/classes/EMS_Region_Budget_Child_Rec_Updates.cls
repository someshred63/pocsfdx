public without sharing class EMS_Region_Budget_Child_Rec_Updates {

    private static Map<Id, EMS_Budget_Product_gne__c> relatedProducts;        // ProductId, EMS_Budget_Product_gne__c
    private static Map<Id, Id> relatedGroups;                            // Territory ID , Group Id
    private static Set<String> existingRegionSharesExternalIds = new Set<String>();
    private static Set<String> existingProductSharesExternalIds = new Set<String>();
    private static Map<Id, EMS_Fund_Request_gne__c> relatedFundRequests = new Map<Id, EMS_Fund_Request_gne__c>();
    private static List<EMS_Fund_Request_gne__c> fundRequestsToUpdate = new List<EMS_Fund_Request_gne__c>();

    private static final String rowCauseTerritorySharing = Schema.EMS_Budget_Region_gne__Share.RowCause.Territory_Sharing__c;
    private static final String rowCauseProductBudgetSharing = Schema.EMS_Budget_Region_gne__Share.RowCause.Product_Budget_Sharing__c;
    private static final String rowCauseChildTerritorySharing = Schema.EMS_Budget_Product_gne__Share.RowCause.Child_Territory_Sharing__c;

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

    public static void onAfterInsert(List<EMS_Budget_Region_gne__c> triggerNew) {
        fetchRelatedProducts(triggerNew);
        getExistingShares(triggerNew);
        getGroupsRelatedToProductBudgetTerritories(triggerNew);

        shareRegionBudgetWithTerritoryAndParentTerritory(null, triggerNew);
        shareProductBudgetWithRegion(null, triggerNew);

        moveFundsUponInsert(triggerNew);
    }

    public static void onAfterUpdate(List<EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        fetchRelatedProducts(triggerNew);
        getExistingShares(triggerNew);
        getGroupsRelatedToProductBudgetTerritories(triggerNew);

        shareRegionBudgetWithTerritoryAndParentTerritory(new Map<Id, EMS_Budget_Region_gne__c>(triggerOld), triggerNew);
        shareProductBudgetWithRegion(new Map<Id, EMS_Budget_Region_gne__c>(triggerOld), triggerNew);

        findRelatedFundRequests(triggerOld, triggerNew);
        deactivateChildBudgets(triggerOld, triggerNew);
        moveFundsUponUpdate(triggerOld, triggerNew);
        reasignFRApproverOnAssignedToChange(triggerOld, triggerNew);
        updateBudgetAllocations(new Map<Id, EMS_Budget_Region_gne__c>(triggerNew));

        updateFundRequests();
    }

    public static void onBeforeDelete(List<EMS_Budget_Region_gne__c> triggerOld) {
        deleteFundRequestsOnBudgetDelete(triggerOld);
        deleteBudgetAllocations(triggerOld);
        fetchRelatedProducts(triggerOld);
        moveFundsUponDelete(triggerOld);
    }

    /**************************************************************************
    **************************** Action methods *******************************
    **************************************************************************/

    private static void fetchRelatedProducts(List<EMS_Budget_Region_gne__c> regionBudgets) {
        Set<Id> productIds = new Set<Id>();
        for (EMS_Budget_Region_gne__c region : regionBudgets) {
            if (!productIds.contains(region.EMS_Budget_Product_gne__c)) {
                productIds.add(region.EMS_Budget_Product_gne__c);
            }
        }
        relatedProducts = new Map<Id, EMS_Budget_Product_gne__c>([SELECT Assigned_To_Territory_Id__c, Total_Product_Funds_Approved_gne__c, Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productIds]);
    }

    private static void getExistingShares(List<EMS_Budget_Region_gne__c> triggerNew) {
        // Existing Region Shares
        for (EMS_Budget_Region_gne__Share existingRegionShare : [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :triggerNew]) {
            existingRegionSharesExternalIds.add(String.valueOf(existingRegionShare.ParentId) + String.valueOf(existingRegionShare.UserOrGroupId) + String.valueOf(existingRegionShare.RowCause));
        }
        // Existing Product Shares
        Set<Id> productTerritoryIds = new Set<Id>();
        for (EMS_Budget_Product_gne__c productBudget : relatedProducts.values()) {
            if (productBudget.Assigned_To_Territory_Id__c != null) {
                productTerritoryIds.add(productBudget.Assigned_To_Territory_Id__c);
            }
        }
        for (EMS_Budget_Product_gne__Share existingproductShare : [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :productTerritoryIds]) {
            existingProductSharesExternalIds.add(String.valueOf(existingproductShare.ParentId) + String.valueOf(existingproductShare.UserOrGroupId) + String.valueOf(existingproductShare.RowCause));
        }
    }

    public static void getGroupsRelatedToProductBudgetTerritories(List<EMS_Budget_Region_gne__c> triggerNew) {
        Set<Id> relatedTerritories = new Set<Id>();
        for (EMS_Budget_Product_gne__c productBudget : relatedProducts.values()) {
            if (productBudget.Assigned_To_Territory_Id__c != null) {
                relatedTerritories.add(productBudget.Assigned_To_Territory_Id__c);
            }
        }
        for (EMS_Budget_Region_gne__c region : triggerNew) {
            if (region.Assigned_To_Territory_Id_gne__c != null) {
                relatedTerritories.add(region.Assigned_To_Territory_Id_gne__c);
            }
        }

        relatedGroups = EMS_Util.getTerritoriesGroups(relatedTerritories);
    }

    // shares region budget with the territory it is assigned to and the territory of the product budget
    public static void shareRegionBudgetWithTerritoryAndParentTerritory(Map<Id, EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        List<EMS_Budget_Region_gne__Share> regionSharesToInsert = new List <EMS_Budget_Region_gne__Share>();
        Set<Id> parentIdsToRemoveProduct = new Set<Id>();
        Set<Id> parentIdsToRemoveRegion = new Set<Id>();
        for (EMS_Budget_Region_gne__c region : triggerNew) {
            Boolean doesShareExist = false;
            Boolean territoryChanged = false;

            territoryChanged = triggerOld == null
                    || triggerOld.get(region.Id).Assigned_To_Territory_Id_gne__c != region.Assigned_To_Territory_Id_gne__c;
            doesShareExist = existingRegionSharesExternalIds.contains(String.valueOf(region.Id) + String.valueOf(relatedGroups.get(region.Assigned_To_Territory_Id_gne__c)) + rowCauseTerritorySharing);
            if (!doesShareExist
                    && relatedGroups.containsKey(region.Assigned_To_Territory_Id_gne__c)
                    && territoryChanged
                    ) {
                EMS_Budget_Region_gne__Share rShare = new EMS_Budget_Region_gne__Share(
                        ParentId = region.Id,
                        UserOrGroupId = relatedGroups.get(region.Assigned_To_Territory_Id_gne__c),
                        AccessLevel = 'Edit',
                        RowCause = rowCauseTerritorySharing
                );
                regionSharesToInsert.add(rShare);
                parentIdsToRemoveRegion.add(region.Id);
            }

            String productTerritory = relatedProducts.get(region.EMS_Budget_Product_gne__c).Assigned_To_Territory_Id__c;
            doesShareExist = existingRegionSharesExternalIds.contains(String.valueOf(region.Id) + String.valueOf(relatedGroups.get(productTerritory)) + rowCauseProductBudgetSharing);
            if (!doesShareExist
                    && relatedGroups.containsKey(productTerritory)
                    && territoryChanged
                    ) {
                EMS_Budget_Region_gne__Share rShare = new EMS_Budget_Region_gne__Share(
                        ParentId = region.Id,
                        UserOrGroupId = relatedGroups.get(productTerritory),
                        AccessLevel = 'Edit',
                        RowCause = rowCauseProductBudgetSharing
                );
                regionSharesToInsert.add(rShare);
                parentIdsToRemoveProduct.add(region.Id);
            }
        }

        if (!parentIdsToRemoveRegion.isEmpty() || !parentIdsToRemoveProduct.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Region_gne__Share WHERE (ParentId IN :parentIdsToRemoveRegion AND RowCause = :rowCauseTerritorySharing) OR (ParentId IN :parentIdsToRemoveProduct AND RowCause = :rowCauseProductBudgetSharing)];
        }

        if (!regionSharesToInsert.isEmpty()) {
            insert regionSharesToInsert;
        }
    }

    public static void shareProductBudgetWithRegion(Map<Id, EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        List<EMS_Budget_Region_gne__c> regionBudgetList = [SELECT EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c, EMS_Budget_Product_gne__c, Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :triggerNew];
        Set<Id> parentIdsToRemoveproduct = new Set<Id>();
        List<EMS_Budget_Product_gne__Share> productSharesToInsert = new List <EMS_Budget_Product_gne__Share>();
        for (EMS_Budget_Region_gne__c rb : regionBudgetList) {
            Boolean doesShareExist = existingProductSharesExternalIds.contains(String.valueOf(rb.EMS_Budget_Product_gne__c) + String.valueOf(relatedGroups.get(rb.Assigned_To_Territory_Id_gne__c)) + rowCauseChildTerritorySharing);
            Boolean territoryChanged = triggerOld == null
                    || triggerOld.get(rb.Id).Assigned_To_Territory_Id_gne__c != rb.Assigned_To_Territory_Id_gne__c;

            if (!doesShareExist
                    && relatedGroups.containsKey(rb.Assigned_To_Territory_Id_gne__c)
                    && territoryChanged
                    ) {
                EMS_Budget_Product_gne__Share rShare = new EMS_Budget_Product_gne__Share(
                        ParentId = rb.EMS_Budget_Product_gne__c,
                        UserOrGroupId = relatedGroups.get(rb.Assigned_To_Territory_Id_gne__c),
                        AccessLevel = 'Read',
                        RowCause = rowCauseChildTerritorySharing
                );
                productSharesToInsert.add(rShare);
                parentIdsToRemoveproduct.add(rb.Id);
            }
        }

        if (!parentIdsToRemoveproduct.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :parentIdsToRemoveproduct AND RowCause = :rowCauseChildTerritorySharing];
        }

        if (productSharesToInsert.size() > 0) {
            insert productSharesToInsert;
        }
    }

    private static void moveFundsUponInsert(List<EMS_Budget_Region_gne__c> triggerNew) {
        for (EMS_Budget_Region_gne__c region : triggerNew) {
            relatedProducts.get(region.EMS_Budget_Product_gne__c).Child_Budgets_Allocated_Amount_gne__c += region.Total_Region_Funds_Approved_gne__c;
        }
        update relatedProducts.values();
    }

    private static void moveFundsUponDelete(List<EMS_Budget_Region_gne__c> triggerOld) {
        for (EMS_Budget_Region_gne__c region : [SELECT Total_Region_Funds_Approved_gne__c, EMS_Budget_Product_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :triggerOld]) {
            relatedProducts.get(region.EMS_Budget_Product_gne__c).Child_Budgets_Allocated_Amount_gne__c -= region.Total_Region_Funds_Approved_gne__c;
        }
        update relatedProducts.values();
    }

    private static void moveFundsUponUpdate(List<EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        Map<Id, EMS_Budget_Product_gne__c> updateProductBudgets = new Map<Id, EMS_Budget_Product_gne__c>();

        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (triggerNew[i].Total_Region_Funds_Approved_gne__c != triggerOld[i].Total_Region_Funds_Approved_gne__c) {
                Decimal allocatedBudgetChange = triggerNew[i].Total_Region_Funds_Approved_gne__c - triggerOld[i].Total_Region_Funds_Approved_gne__c;
                if (updateProductBudgets.containsKey(triggerNew[i].EMS_Budget_Product_gne__c) == false) {
                    updateProductBudgets.put(triggerNew[i].EMS_Budget_Product_gne__c, relatedProducts.get(triggerNew[i].EMS_Budget_Product_gne__c));
                }

                updateProductBudgets.get(triggerNew[i].EMS_Budget_Product_gne__c).Child_Budgets_Allocated_Amount_gne__c += allocatedBudgetChange;
            }
        }
        update updateProductBudgets.values();
    }

    private static void deleteFundRequestsOnBudgetDelete(List<EMS_Budget_Region_gne__c> triggerOld) {
        delete [SELECT Id FROM EMS_Fund_Request_gne__c WHERE Related_Region_Budget_gne__c IN :triggerOld];
    }

    private static void deleteBudgetAllocations(List<EMS_Budget_Region_gne__c> triggerOld) {
        delete [SELECT Name FROM EMS_Budget_Allocation_gne__c WHERE EMS_Region_Budget_gne__c IN :triggerOld];
    }

    private static void findRelatedFundRequests(List<EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        Map<Id, EMS_Budget_Region_gne__c> oldMap = new Map<Id, EMS_Budget_Region_gne__c>(triggerOld);

        Set<Id> deactivatedIDs = new Set<Id>();
        Set<Id> modifiedOwnerIDs = new Set<Id>();
        for (Integer i = 0; i < triggerNew.size(); i++) {
            Id recID = triggerNew[i].Id;
            if (oldMap.get(recID).Status_gne__c == 'Active' && triggerNew[i].Status_gne__c == 'Inactive') {
                deactivatedIDs.add(triggerNew[i].Id);
            }
            if (oldMap.get(recID).Assigned_to_gne__c != triggerNew[i].Assigned_to_gne__c) {
                modifiedOwnerIDs.add(triggerNew[i].Id);
            }
        }

        List<String> recordTypes = new List<String>{
                'Region Fund De-Allocation', 'Territory Fund Allocation'
        };
        relatedFundRequests = new Map<Id, EMS_Fund_Request_gne__c>([
                SELECT Approver_gne__c, Record_Type_Name_gne__c, Related_Product_Budget_gne__c, Related_Region_Budget_gne__c, Status_gne__c
                FROM EMS_Fund_Request_gne__c
                WHERE (Record_Type_Name_gne__c IN :recordTypes AND Related_Region_Budget_gne__c IN :modifiedOwnerIDs)
                OR Related_Region_Budget_gne__c IN :deactivatedIDs
        ]);
    }

    private static void deactivateChildBudgets(List<EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        // Find budgets to deactivate
        Set<Id> deactivatedBudgets = new Set<Id>();
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (triggerOld[i].Status_gne__c == 'Active' && triggerNew[i].Status_gne__c == 'Inactive') {
                deactivatedBudgets.add(triggerNew[i].Id);
            }
        }
        if (deactivatedBudgets.isEmpty()) {
            return;
        }
        List<EMS_Fund_Request_gne__c> fundRequestsToDeactivate = new List<EMS_Fund_Request_gne__c>();
        for (Id frID : relatedFundRequests.keySet()) {
            if (deactivatedBudgets.contains(frID)) {
                fundRequestsToDeactivate.add(relatedFundRequests.get(frID));
            }
        }

        EMS_Fund_Request_Trigger_Helper.inFundRequestTrigger = true;
        List<Id> rejectIDs = new List<Id>();
        for (ProcessInstanceWorkitem piw : [SELECT p.Id FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId IN :fundRequestsToDeactivate]) {
            rejectIDs.add(piw.Id);
        }
        EMS_Util.rejectApprovals(rejectIDs, 'Related budget was deactivated.');

        for (EMS_Fund_Request_gne__c fundRequest : fundRequestsToDeactivate) {
            if (fundRequest.Status_gne__c == 'New' || fundRequest.Status_gne__c == 'Cancelled') {
                // Reject fund requests in 'New' or 'Cancelled' status
                fundRequest.Status_gne__c = 'Rejected';
                fundRequestsToUpdate.add(fundRequest);
            }
        }

        // Deactive child budgets
        List<EMS_Budget_Territory_gne__c> childBudgets = [SELECT Id, Status_gne__c FROM EMS_Budget_Territory_gne__c WHERE Status_gne__c != 'Inactive' AND EMS_Budget_Region_gne__c IN :deactivatedBudgets];
        for (EMS_Budget_Territory_gne__c childBudget : childBudgets) {
            childBudget.Status_gne__c = 'Inactive';
        }
        update childBudgets;
    }

    private static void reasignFRApproverOnAssignedToChange(List<EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        Map<Id, EMS_Budget_Region_gne__c> oldMap = new Map<Id, EMS_Budget_Region_gne__c>(triggerOld);
        Map<Id, EMS_Budget_Region_gne__c> budgetsWithModifiedOwner = new Map<Id, EMS_Budget_Region_gne__c>();
        for (EMS_Budget_Region_gne__c rec : triggerNew) {
            if (rec.Assigned_to_gne__c != oldMap.get(rec.Id).Assigned_to_gne__c) {
                budgetsWithModifiedOwner.put(rec.Id, rec);
            }
        }
        List<EMS_Fund_Request_gne__c> fundRequestsForModifiedBudget = new List<EMS_Fund_Request_gne__c>();
        for (Id frID : relatedFundRequests.keySet()) {
            Id rbID = relatedFundRequests.get(frID).Related_Region_Budget_gne__c;
            if (budgetsWithModifiedOwner.containsKey(rbID)) {
                fundRequestsForModifiedBudget.add(relatedFundRequests.get(frID));
            }
        }

        // Check which FR have approval process in progress
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :fundRequestsForModifiedBudget];
        List<Approval.ProcessWorkitemRequest> piwiToRemove = new List<Approval.ProcessWorkitemRequest>();
        for (ProcessInstanceWorkitem piw : piwi) {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setComments('Budget owner changed.');
            request.setAction('Removed');
            request.setWorkitemId(piw.Id);
            piwiToRemove.add(request);
        }

        System.Savepoint initialState = Database.setSavepoint();
        try {
            // Recall all current Approval processes
            List<Approval.ProcessResult> results = Approval.process(piwiToRemove);
        } catch (Exception ex) {
            Database.rollback(initialState);
            throw ex;
        }

        // Change FR Approver
        for (EMS_Fund_Request_gne__c fundRequest : fundRequestsForModifiedBudget) {
            fundRequest.Approver_gne__c = budgetsWithModifiedOwner.get(fundRequest.Related_Region_Budget_gne__c).Assigned_to_gne__c;
            fundRequestsToUpdate.add(fundRequest);
        }

        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (ProcessInstanceWorkitem piw : piwi) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(piw.ProcessInstance.TargetObjectId);
            req.setComments('Budget owner changed.');
            apprRequests.add(req);
        }
        try {
            List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);
        } catch (Exception ex) {
            Database.rollback(initialState);
            throw ex;
        }
    }

    private static void updateBudgetAllocations(Map<Id, EMS_Budget_Region_gne__c> budgets) {
        Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocations = new Map<Id, EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Allocation_gne__c budgetAllocation : [
                SELECT Id, Approver_gne__c, Budget_Owner_gne__c, EMS_Region_Budget_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE EMS_Product_Budget_gne__c IN :budgets.keySet()
                AND Status_gne__c IN ('Submitted', 'New')
        ]) {
            Id budgetOwnerId = budgets.get(budgetAllocation.EMS_Region_Budget_gne__c).Assigned_to_gne__c;
            Id newApproverId = getDelegatedUser(budgetOwnerId);
            if (budgetAllocation.Approver_gne__c != newApproverId || budgetAllocation.Budget_Owner_gne__c != budgetOwnerId) {
                budgetAllocation.Budget_Owner_gne__c = budgetOwnerId;
                budgetAllocation.Approver_gne__c = newApproverId;
                budgetAllocations.put(budgetAllocation.Id, budgetAllocation);
            }
        }

        update budgetAllocations.values();
    }

    private static void updateFundRequests() {
        if (fundRequestsToUpdate.isEmpty()) {
            return;
        }
        System.Savepoint initialState = Database.setSavepoint();
        try {
            update fundRequestsToUpdate;
        } catch (Exception ex) {
            Database.rollback(initialState);
            throw ex;
        }
    }
}