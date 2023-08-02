public without sharing class EMS_Territory_Budget_Child_Rec_Updates {
    private static final String rowCauseTerritorySharing = Schema.EMS_Budget_Territory_gne__Share.RowCause.Territory_Sharing__c;
    private static final String rowCauseChildTerritorySharing = Schema.EMS_Budget_Product_gne__Share.RowCause.Child_Territory_Sharing__c;
    private static final String rowCauseProductBudgetSharing = Schema.EMS_Budget_Territory_gne__Share.RowCause.Product_Budget_Sharing__c;

    private static Map<Id, EMS_Budget_Region_gne__c> relatedRegions; // RegionId, EMS_Budget_Region_gne__c
    private static Map<Id, Id> relatedGroups; // Territory ID, Group Id
    private static Set<Id> regionTerritoryIDs = new Set<Id>();
    private static Set<Id> productTerritoryIDs = new Set<Id>();
    private static Set<Id> relatedRegionBudgetIDs = new Set<Id>();

    // Set of external IDs based on ParentId + UserOrGroupId pattern
    private static Set<String> existingTerritorySharesExternalIds;
    private static Set<String> existingRegionSharesExternalIds;

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

    public static void onAfterInsert(List<EMS_Budget_Territory_gne__c> triggerNew) {
        fetchRegionBudgetIds(triggerNew);
        fetchRelatedRegions();

        getGroupsRelatedToProductAndTerritoryBudgetsTerritories(triggerNew);
        fetchExistingShares(triggerNew);

        shareTerritoryBudgetWithTerritory(null, triggerNew);
        shareRegionBudgetWithTerritory(null, triggerNew);
        shareTerritoryBudgetWithProductTerritory(null, triggerNew);

        moveFundsUponInsert(triggerNew);
    }

    public static void onAfterUpdate(List<EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        fetchRegionBudgetIds(triggerNew);
        fetchRelatedRegions();

        getGroupsRelatedToProductAndTerritoryBudgetsTerritories(triggerNew);
        fetchExistingShares(triggerNew);

        shareTerritoryBudgetWithTerritory(new Map<Id, EMS_Budget_Territory_gne__c>(triggerOld), triggerNew);
        shareRegionBudgetWithTerritory(new Map<Id, EMS_Budget_Territory_gne__c>(triggerOld), triggerNew);
        shareTerritoryBudgetWithProductTerritory(new Map<Id, EMS_Budget_Territory_gne__c>(triggerOld), triggerNew);

        moveFundsUponUpdate(triggerOld, triggerNew);
        reasignFRApproverOnAssignedToChange(triggerOld, triggerNew);

        updateBudgetAllocations(new Map<Id, EMS_Budget_Territory_gne__c>(triggerNew));
    }

    public static void onBeforeDelete(List<EMS_Budget_Territory_gne__c> triggerOld) {
        deleteFundRequestsOnBudgetDelete(triggerOld);
        deleteBudgetAllocations(triggerOld);
        fetchRegionBudgetIds(triggerOld);
        fetchRelatedRegions();
        moveFundsUponDelete(triggerOld);
    }

    /**************************************************************************
    **************************** Action methods *******************************
    **************************************************************************/
    private static void fetchRegionBudgetIds(List<EMS_Budget_Territory_gne__c> triggerNew) {
        for (EMS_Budget_Territory_gne__c territory : triggerNew) {
            if (!relatedRegionBudgetIDs.contains(territory.EMS_Budget_Region_gne__c)) {
                relatedRegionBudgetIDs.add(territory.EMS_Budget_Region_gne__c);
            }
        }
    }

    private static void fetchRelatedRegions() {
        relatedRegions = new Map<Id, EMS_Budget_Region_gne__c>([
                SELECT Assigned_To_Territory_Id_gne__c, Total_Region_Funds_Approved_gne__c, Child_Budgets_Allocated_Amount_gne__c, EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c
                FROM EMS_Budget_Region_gne__c
                WHERE Id IN :relatedRegionBudgetIDs
        ]);
    }

    private static void getGroupsRelatedToProductAndTerritoryBudgetsTerritories(List<EMS_Budget_Territory_gne__c> triggerNew) {
        Set<Id> territoryTerritoryIDs = new Set<Id>(); // Territory and Region budgets territories
        List<EMS_Budget_Territory_gne__c> tbs = [SELECT Assigned_To_Territory_Id_gne__c, EMS_Budget_Region_gne__r.Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :triggerNew];
        for (EMS_Budget_Territory_gne__c tb : tbs) {
            // Region Budget Territory ID
            if (String.isNotBlank(tb.EMS_Budget_Region_gne__r.Assigned_To_Territory_Id_gne__c)) {
                regionTerritoryIDs.add(tb.EMS_Budget_Region_gne__r.Assigned_To_Territory_Id_gne__c);
            }
            // Territory Budget Territory ID
            if (String.isNotBlank(tb.Assigned_To_Territory_Id_gne__c)) {
                territoryTerritoryIDs.add(tb.Assigned_To_Territory_Id_gne__c);
            }
        }
        for (EMS_Budget_Region_gne__c regionBudget : relatedRegions.values()) {
            // Product Budget Territory ID
            productTerritoryIDs.add(regionBudget.EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c);
        }
        territoryTerritoryIDs.addAll(regionTerritoryIDs);
        territoryTerritoryIDs.addAll(productTerritoryIDs);
        relatedGroups = EMS_Util.getTerritoriesGroups(territoryTerritoryIDs);
    }

    private static void fetchExistingShares(List<EMS_Budget_Territory_gne__c> triggerNew) {
        String parendID_tmp = '';
        String userOrGroupID_tmp = '';
        String rowCause_tmp = '';

        existingTerritorySharesExternalIds = new Set<String>();
        for (EMS_Budget_Territory_gne__Share btShare : [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :triggerNew]) {
            parendID_tmp = String.valueOf(btShare.ParentId);
            userOrGroupID_tmp = String.valueOf(btShare.UserOrGroupId);
            rowCause_tmp = String.valueOf(btShare.RowCause);
            existingTerritorySharesExternalIds.add(parendID_tmp + userOrGroupID_tmp + rowCause_tmp);
        }

        existingRegionSharesExternalIds = new Set<String>();
        for (EMS_Budget_Region_gne__Share brShare : [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionTerritoryIDs]) {
            parendID_tmp = String.valueOf(brShare.ParentId);
            userOrGroupID_tmp = String.valueOf(brShare.UserOrGroupId);
            rowCause_tmp = String.valueOf(brShare.RowCause);
            existingRegionSharesExternalIds.add(parendID_tmp + userOrGroupID_tmp + rowCause_tmp);
        }
    }

    public static void shareTerritoryBudgetWithTerritory(Map<Id, EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        Set<Id> territorySharesToRemove = new Set<Id>();
        List<EMS_Budget_Territory_gne__Share> territoryShares = new List <EMS_Budget_Territory_gne__Share>();
        for (EMS_Budget_Territory_gne__c territory : triggerNew) {
            if (String.isBlank(territory.Assigned_To_Territory_Id_gne__c)) {
                continue; // Skip 
            }

            Boolean doesShareExist = existingTerritorySharesExternalIds.contains(
                    String.valueOf(territory.Id)
                            + String.valueOf(relatedGroups.get(territory.Assigned_To_Territory_Id_gne__c))
                            + rowCauseTerritorySharing
            );
            Boolean territoryChanged = triggerOld == null
                    || triggerOld.get(territory.Id).Assigned_To_Territory_Id_gne__c != territory.Assigned_To_Territory_gne__c;

            if (!doesShareExist
                    && relatedGroups.containsKey(territory.Assigned_To_Territory_Id_gne__c)
                    && territoryChanged
                    ) {
                EMS_Budget_Territory_gne__Share share = new EMS_Budget_territory_gne__Share(
                        ParentId = territory.Id,
                        UserOrGroupId = relatedGroups.get(territory.Assigned_To_Territory_Id_gne__c),
                        AccessLevel = 'Edit',
                        RowCause = rowCauseTerritorySharing
                );
                territoryShares.add(share);
                territorySharesToRemove.add(territory.Id);
            }
        }
        if (!territorySharesToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :territorySharesToRemove AND RowCause = :rowCauseTerritorySharing];
        }
        if (!territoryShares.isEmpty()) {
            insert territoryShares;
        }
    }

    public static void shareRegionBudgetWithTerritory(Map<Id, EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        Set<Id> regionSharesToRemove = new Set<Id>();
        List<EMS_Budget_Region_gne__Share> regionShares = new List <EMS_Budget_Region_gne__Share>();
        for (EMS_Budget_Territory_gne__c territory : triggerNew) {
            // Not sure if we need to use the SOQL below instead of triggerNew
            // [SELECT EMS_Budget_Region_gne__c, Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :triggerNew]
            if (String.isBlank(territory.Assigned_To_Territory_Id_gne__c)) {
                continue; // Skip 
            }

            Boolean doesShareExist = existingRegionSharesExternalIds.contains(
                    String.valueOf(territory.EMS_Budget_Region_gne__c)
                            + String.valueOf(relatedGroups.get(territory.Assigned_To_Territory_Id_gne__c))
                            + rowCauseChildTerritorySharing
            );
            Boolean territoryChanged = triggerOld == null
                    || triggerOld.get(territory.Id).Assigned_To_Territory_Id_gne__c != territory.Assigned_To_Territory_gne__c;

            if (!doesShareExist
                    && relatedGroups.containsKey(territory.Assigned_To_Territory_Id_gne__c)
                    && territoryChanged
                    ) {
                EMS_Budget_Region_gne__Share rShare = new EMS_Budget_Region_gne__Share(
                        ParentId = territory.EMS_Budget_Region_gne__c,
                        UserOrGroupId = relatedGroups.get(territory.Assigned_To_Territory_Id_gne__c),
                        AccessLevel = 'Read',
                        RowCause = rowCauseChildTerritorySharing
                );
                regionShares.add(rShare);
                regionSharesToRemove.add(territory.Id);
            }
        }
        if (!regionSharesToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionSharesToRemove AND RowCause = :rowCauseChildTerritorySharing];
        }
        if (regionShares.size() > 0) {
            insert regionShares;
        }
    }

    public static void shareTerritoryBudgetWithProductTerritory(Map<Id, EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        Set<Id> territorySharesToRemove = new Set<Id>();
        List<EMS_Budget_Territory_gne__Share> territoryShares = new List <EMS_Budget_Territory_gne__Share>();
        for (EMS_Budget_Territory_gne__c territory : triggerNew) {
            if (String.isBlank(territory.EMS_Budget_Region_gne__c)) {
                continue; // Skip 
            }

            Boolean doesShareExist = existingTerritorySharesExternalIds.contains(
                    String.valueOf(territory.Id) +
                            String.valueOf(relatedGroups.get(relatedRegions.get(territory.EMS_Budget_Region_gne__c).EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c)) +
                            rowCauseProductBudgetSharing
            );
            Boolean territoryChanged = triggerOld == null
                    || triggerOld.get(territory.Id).Assigned_To_Territory_Id_gne__c != territory.Assigned_To_Territory_gne__c;

            if (!doesShareExist
                    && relatedGroups.containsKey(relatedRegions.get(territory.EMS_Budget_Region_gne__c).EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c)
                    && territoryChanged
                    ) {
                EMS_Budget_Territory_gne__Share share = new EMS_Budget_territory_gne__Share(
                        ParentId = territory.Id,
                        UserOrGroupId = relatedGroups.get(relatedRegions.get(territory.EMS_Budget_Region_gne__c).EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c),
                        AccessLevel = 'Read',
                        RowCause = rowCauseProductBudgetSharing
                );
                territoryShares.add(share);
                territorySharesToRemove.add(territory.Id);
            }
        }
        if (!territorySharesToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :territorySharesToRemove AND RowCause = :rowCauseProductBudgetSharing];
        }
        if (!territoryShares.isEmpty()) {
            insert territoryShares;
        }
    }

    private static void moveFundsUponInsert(List<EMS_Budget_Territory_gne__c> triggerNew) {
        for (EMS_Budget_Territory_gne__c territory : triggerNew) {
            relatedRegions.get(territory.EMS_Budget_Region_gne__c).Child_Budgets_Allocated_Amount_gne__c += territory.Total_Territory_Funds_Approved_gne__c;
        }
        update relatedRegions.values();
    }

    private static void moveFundsUponUpdate(List<EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (triggerNew[i].Total_Territory_Funds_Approved_gne__c != triggerOld[i].Total_Territory_Funds_Approved_gne__c) {
                Decimal allocatedBudgetChange = triggerNew[i].Total_Territory_Funds_Approved_gne__c - triggerOld[i].Total_Territory_Funds_Approved_gne__c;
                relatedRegions.get(triggerNew[i].EMS_Budget_Region_gne__c).Child_Budgets_Allocated_Amount_gne__c += allocatedBudgetChange;
            }
        }
        update relatedRegions.values();
    }

    private static void moveFundsUponDelete(List<EMS_Budget_Territory_gne__c> triggerOld) {
        for (EMS_Budget_Territory_gne__c territory : [SELECT Total_Territory_Funds_Approved_gne__c, EMS_Budget_Region_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :triggerOld]) {
            relatedRegions.get(territory.EMS_Budget_Region_gne__c).Child_Budgets_Allocated_Amount_gne__c -= territory.Total_Territory_Funds_Approved_gne__c;
        }
        update relatedRegions.values();
    }


    private static void deleteFundRequestsOnBudgetDelete(List<EMS_Budget_Territory_gne__c> triggerOld) {
        List<EMS_Fund_Request_gne__c> fundRequestsToDelete = new List<EMS_Fund_Request_gne__c>();
        fundRequestsToDelete = [SELECT Id FROM EMS_Fund_Request_gne__c WHERE Related_Territory_Budget_gne__c IN :triggerOld];
        delete fundRequestsToDelete;
    }

    private static void deleteBudgetAllocations(List<EMS_Budget_Territory_gne__c> triggerOld) {
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsToDelete = new List<EMS_Budget_Allocation_gne__c>();
        budgetAllocationsToDelete = [SELECT id FROM EMS_Budget_Allocation_gne__c WHERE EMS_Territory_Budget_gne__c IN :triggerOld];

        delete budgetAllocationsToDelete;
    }

    private static void updateBudgetAllocations(Map<Id, EMS_Budget_Territory_gne__c> budgets) {
        Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocations = new Map<Id, EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Allocation_gne__c budgetAllocation : [
                SELECT Id, Approver_gne__c, Budget_Owner_gne__c, EMS_Territory_Budget_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE EMS_Product_Budget_gne__c IN :budgets.keySet()
                AND Status_gne__c IN ('Submitted', 'New')
        ]) {
            Id budgetOwnerId = budgets.get(budgetAllocation.EMS_Territory_Budget_gne__c).Assigned_to_gne__c;
            Id newApproverId = getDelegatedUser(budgetOwnerId);
            if (budgetAllocation.Approver_gne__c != newApproverId || budgetAllocation.Budget_Owner_gne__c != budgetOwnerId) {
                budgetAllocation.Budget_Owner_gne__c = budgetOwnerId;
                budgetAllocation.Approver_gne__c = newApproverId;
                budgetAllocations.put(budgetAllocation.Id, budgetAllocation);
            }
        }

        update budgetAllocations.values();
    }

    private static void reasignFRApproverOnAssignedToChange(List<EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        Map<Id, EMS_Budget_Territory_gne__c> oldRecords = new Map<Id, EMS_Budget_Territory_gne__c>(triggerOld);
        Map<Id, EMS_Budget_Territory_gne__c> budgetsWithModifiedOwner = new Map<Id, EMS_Budget_Territory_gne__c>();
        List<EMS_Fund_Request_gne__c> frRequests = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> frToUpdate = new List<EMS_Fund_Request_gne__c>();
        List<Approval.ProcessWorkitemRequest> piwiToRemove = new List<Approval.ProcessWorkitemRequest>();

        for (EMS_Budget_Territory_gne__c newRecord : triggerNew) {
            if (newRecord.Assigned_to_gne__c != oldRecords.get(newRecord.Id).Assigned_to_gne__c) {
                budgetsWithModifiedOwner.put(newRecord.Id, newRecord);
            }
        }

        // Find all FR for each modified budget
        frRequests = [
                SELECT Id, Approver_gne__c, Record_Type_Name_gne__c, Related_Product_Budget_gne__c, Related_Territory_Budget_gne__c
                FROM EMS_Fund_Request_gne__c
                WHERE Record_Type_Name_gne__c = 'Territory Fund De-Allocation' AND Related_Territory_Budget_gne__c IN :budgetsWithModifiedOwner.values()
        ];


        // Check which FR have approval process in progress
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :frRequests];

        // Recall all current Approval processes
        for (ProcessInstanceWorkitem piw : piwi) {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setComments('Budget owner changed.');
            request.setAction('Removed');
            request.setWorkitemId(piw.Id);
            piwiToRemove.add(request);
        }

        System.Savepoint initialState = Database.setSavepoint();
        try {
            List<Approval.ProcessResult> results = Approval.process(piwiToRemove);
        } catch (Exception ex) {
            Database.rollback(initialState);
            System.Debug('@@ Approval recall failed: ' + ex);
            throw ex;
        }

        // Change FR Approver
        for (EMS_Fund_Request_gne__c fr : frRequests) {
            fr.Approver_gne__c = budgetsWithModifiedOwner.get(fr.Related_Territory_Budget_gne__c).Assigned_to_gne__c;
            frToUpdate.add(fr);
        }
        try {
            update frToUpdate;
        } catch (Exception ex) {
            Database.rollback(initialState);
            System.Debug('@@ FR Approver change failed: ' + ex);
            throw ex;
        }

        Map<Id, EMS_Fund_Request_gne__c> updatedFRs = new Map<Id, EMS_Fund_Request_gne__c>();
        updatedFRs.putAll([SELECT Id, Related_Territory_Budget_gne__c FROM EMS_Fund_Request_gne__c WHERE Id IN :frToUpdate]);
        // Send for approval items that had approval process in progress
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