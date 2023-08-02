public without sharing class EMS_Fund_Request_Child_RecUpdate {

    private static Map<Id, String> fundRequestRecordTypes = new Map<Id, String>();
    private static Map<Id, Id> relatedGroups;
    private static Map<Id, EMS_Budget_Territory_gne__c> relatedTerritoryBudgets;
    private static Map<Id, EMS_Budget_Region_gne__c> relatedRegionBudgets;
    private static Map<Id, EMS_Budget_Product_gne__c> relatedProductBudgets;

    private static void moveFundsUponApproval(Map<Id, EMS_Fund_Request_gne__c> triggerOld, Map<Id, EMS_Fund_Request_gne__c> triggerNew) {
        List<EMS_Fund_Request_gne__c> approvedTerritoryFundRequests = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedRegionFundRequests = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedRegionFundTransfers = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedTerritoryFundTransfers = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedRegionDeallocationFundRequests = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedTerritoryDeallocationFundRequests = new List<EMS_Fund_Request_gne__c>();

        for (EMS_Fund_Request_gne__c request : triggerNew.values()) {
            Boolean isApproved = (request.Status_gne__c == 'Approved' && (triggerOld == null || !triggerOld.containsKey(request.Id))) || (request.Status_gne__c == 'Approved' && triggerOld.get(request.Id).Status_gne__c != 'Approved');
            Boolean isAcknowledged = (request.Status_gne__c == 'Acknowledged' && (triggerOld == null || !triggerOld.containsKey(request.Id))) || (request.Status_gne__c == 'Acknowledged' && triggerOld.get(request.Id).Status_gne__c != 'Acknowledged');

            if ((isAcknowledged || isApproved) && !EMS_Fund_Request_Trigger_Helper.isAlreadyProcessed(request.Id)) {
                // if the request was approved

                if (fundRequestRecordTypes.get(request.RecordTypeId) == 'Territory Fund Allocation') {
                    approvedTerritoryFundRequests.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_ALLOCATION_REGION_FUNDS) {
                    approvedRegionFundRequests.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_DEALLOCATION_REGION_FUNDS) {
                    approvedRegionDeallocationFundRequests.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_DEALLOCATION_TERRITORY_FUNDS) {
                    approvedTerritoryDeallocationFundRequests.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_TRANSFER_REGION_FUNDS) {
                    approvedRegionFundTransfers.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS) {
                    approvedTerritoryFundTransfers.add(request);
                }
                EMS_Fund_Request_Trigger_Helper.addToProcessed(request.Id);
            }
        }

        Map<Id, EMS_Budget_Territory_gne__c> territoryBudgetsToUpdate = new Map<Id, EMS_Budget_Territory_gne__c>();
        Map<Id, EMS_Budget_Region_gne__c> regionBudgetsToUpdate = new Map<Id, EMS_Budget_Region_gne__c>();
        Map<Id, EMS_Budget_Product_gne__c> productBudgetsToUpdate = new Map<Id, EMS_Budget_Product_gne__c>();

        // move funds from product to region
        for (EMS_Fund_Request_gne__c request : approvedRegionFundRequests) {
            if (!regionBudgetsToUpdate.containsKey(request.Related_Region_Budget_gne__c)) {
                EMS_Budget_Region_gne__c regionBudgetToUpdate = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c);
                regionBudgetsToUpdate.put(regionBudgetToUpdate.Id, regionBudgetToUpdate);
            }

            regionBudgetsToUpdate.get(request.Related_Region_Budget_gne__c).Total_Region_Funds_Approved_gne__c += request.Requested_Amount_gne__c;
        }

        // move funds from region to territory
        for (EMS_Fund_Request_gne__c request : approvedTerritoryFundRequests) {
            if (!territoryBudgetsToUpdate.containsKey(request.Related_Territory_Budget_gne__c)) {
                EMS_Budget_Territory_gne__c territoryBudgetToUpdate = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c);
                territoryBudgetsToUpdate.put(territoryBudgetToUpdate.Id, territoryBudgetToUpdate);
            }

            territoryBudgetsToUpdate.get(request.Related_Territory_Budget_gne__c).Total_Territory_Funds_Approved_gne__c += request.Requested_Amount_gne__c;
        }

        // move funds from region to product (de-allocation)
        for (EMS_Fund_Request_gne__c request : approvedRegionDeallocationFundRequests) {
            if (!regionBudgetsToUpdate.containsKey(request.Related_Region_Budget_gne__c)) {
                EMS_Budget_Region_gne__c regionBudgetToUpdate = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c);
                regionBudgetsToUpdate.put(regionBudgetToUpdate.Id, regionBudgetToUpdate);
            }

            regionBudgetsToUpdate.get(request.Related_Region_Budget_gne__c).Total_Region_Funds_Approved_gne__c += request.Requested_Amount_gne__c;
        }

        // move funds from territory to region (de-allocation)
        for (EMS_Fund_Request_gne__c request : approvedTerritoryDeallocationFundRequests) {
            if (!territoryBudgetsToUpdate.containsKey(request.Related_Territory_Budget_gne__c)) {
                EMS_Budget_Territory_gne__c territoryBudgetToUpdate = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c);

                territoryBudgetsToUpdate.put(territoryBudgetToUpdate.Id, territoryBudgetToUpdate);
            }

            territoryBudgetsToUpdate.get(request.Related_Territory_Budget_gne__c).Total_Territory_Funds_Approved_gne__c += request.Requested_Amount_gne__c;
        }

        // move funds from source to target region budget
        for (EMS_Fund_Request_gne__c request : approvedRegionFundTransfers) {
            EMS_Budget_Region_gne__c sourceBudget;
            EMS_Budget_Region_gne__c targetBudget;

            if (!regionBudgetsToUpdate.containsKey(request.Target_Region_Budget_ID_gne__c)) {
                targetBudget = relatedRegionBudgets.get(request.Target_Region_Budget_ID_gne__c);
                regionBudgetsToUpdate.put(targetBudget.Id, targetBudget);
            } else {
                targetBudget = regionBudgetsToUpdate.get(request.Target_Region_Budget_ID_gne__c);
            }

            if (!regionBudgetsToUpdate.containsKey(request.Related_Region_Budget_gne__c)) {
                sourceBudget = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c);
                regionBudgetsToUpdate.put(sourceBudget.Id, sourceBudget);
            } else {
                sourceBudget = regionBudgetsToUpdate.get(request.Related_Region_Budget_gne__c);
            }

            sourceBudget.Total_Region_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;
            targetBudget.Total_Region_Funds_Approved_gne__c += request.Requested_Amount_gne__c;
        }

        // move funds from source to target territory budget
        for (EMS_Fund_Request_gne__c request : approvedTerritoryFundTransfers) {
            EMS_Budget_Territory_gne__c sourceBudget;
            EMS_Budget_Territory_gne__c targetBudget;

            if (!territoryBudgetsToUpdate.containsKey(request.Target_Territory_Budget_ID_gne__c)) {
                targetBudget = relatedTerritoryBudgets.get(request.Target_Territory_Budget_ID_gne__c);
                territoryBudgetsToUpdate.put(targetBudget.Id, targetBudget);
            } else {
                targetBudget = territoryBudgetsToUpdate.get(request.Target_Territory_Budget_ID_gne__c);
            }

            if (!territoryBudgetsToUpdate.containsKey(request.Related_Territory_Budget_gne__c)) {
                sourceBudget = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c);
                territoryBudgetsToUpdate.put(sourceBudget.Id, sourceBudget);
            } else {
                sourceBudget = territoryBudgetsToUpdate.get(request.Related_Territory_Budget_gne__c);
            }

            sourceBudget.Total_Territory_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;
            targetBudget.Total_Territory_Funds_Approved_gne__c += request.Requested_Amount_gne__c;
        }

        System.Savepoint initialState = Database.setSavepoint();
        try {

            if (regionBudgetsToUpdate.size() > 0) {
                update regionBudgetsToUpdate.values();
            }

            if (territoryBudgetsToUpdate.size() > 0) {
                update territoryBudgetsToUpdate.values();
            }

        } catch (DMLException ex) {
            Database.rollback(initialState);
            triggerNew.Values()[0].addError('Fund Request database error! Details: ' + ex.getMessage());
        }
    }

    private static void moveFundsUponDelete(Map<Id, EMS_Fund_Request_gne__c> triggerOld) {
        List<EMS_Fund_Request_gne__c> approvedTerritoryFundRequests = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedRegionFundRequests = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedRegionFundTransfers = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedTerritoryFundTransfers = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedRegionDeallocationFundRequests = new List<EMS_Fund_Request_gne__c>();
        List<EMS_Fund_Request_gne__c> approvedTerritoryDeallocationFundRequests = new List<EMS_Fund_Request_gne__c>();

        for (EMS_Fund_Request_gne__c request : triggerOld.values()) {
            if ((request.Status_gne__c == 'Approved' || request.Status_gne__c == 'Acknowledged') && !EMS_Fund_Request_Trigger_Helper.isAlreadyProcessed(request.Id)) {    // if the approved request is deleted
                if (fundRequestRecordTypes.get(request.RecordTypeId) == 'Territory Fund Allocation') {
                    approvedTerritoryFundRequests.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == 'Region Fund Allocation') {
                    approvedRegionFundRequests.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == 'Region Fund De-Allocation') {
                    approvedRegionDeallocationFundRequests.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == 'Territory Fund De-Allocation') {
                    approvedTerritoryDeallocationFundRequests.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_TRANSFER_REGION_FUNDS) {
                    approvedRegionFundTransfers.add(request);
                } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS) {
                    approvedTerritoryFundTransfers.add(request);
                }
                EMS_Fund_Request_Trigger_Helper.addToProcessed(request.Id);
            }
        }

        Map<Id, EMS_Budget_Territory_gne__c> territoryBudgetsToUpdate = new Map<Id, EMS_Budget_Territory_gne__c>();
        Map<Id, EMS_Budget_Region_gne__c> regionBudgetsToUpdate = new Map<Id, EMS_Budget_Region_gne__c>();
        Map<Id, EMS_Budget_Product_gne__c> productBudgetsToUpdate = new Map<Id, EMS_Budget_Product_gne__c>();

        // move funds back to product
        for (EMS_Fund_Request_gne__c request : approvedRegionFundRequests) {
            if (!regionBudgetsToUpdate.containsKey(request.Related_Region_Budget_gne__c)) {
                EMS_Budget_Region_gne__c regionBudgetToUpdate = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c);
                regionBudgetToUpdate.Total_Region_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;

                regionBudgetsToUpdate.put(regionBudgetToUpdate.Id, regionBudgetToUpdate);
            } else {
                regionBudgetsToUpdate.get(request.Related_Region_Budget_gne__c).Total_Region_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;
            }
        }

        // move funds back to region
        for (EMS_Fund_Request_gne__c request : approvedTerritoryFundRequests) {
            if (!territoryBudgetsToUpdate.containsKey(request.Related_Territory_Budget_gne__c)) {
                EMS_Budget_Territory_gne__c territoryBudgetToUpdate = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c);
                territoryBudgetToUpdate.Total_Territory_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;

                territoryBudgetsToUpdate.put(territoryBudgetToUpdate.Id, territoryBudgetToUpdate);
            } else {
                territoryBudgetsToUpdate.get(request.Related_Territory_Budget_gne__c).Total_Territory_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;
            }
        }

        // move funds back to product (de-allocation)
        for (EMS_Fund_Request_gne__c request : approvedRegionDeallocationFundRequests) {
            if (!regionBudgetsToUpdate.containsKey(request.Related_Region_Budget_gne__c)) {
                EMS_Budget_Region_gne__c regionBudgetToUpdate = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c);
                regionBudgetToUpdate.Total_Region_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;

                regionBudgetsToUpdate.put(regionBudgetToUpdate.Id, regionBudgetToUpdate);
            } else {
                regionBudgetsToUpdate.get(request.Related_Region_Budget_gne__c).Total_Region_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;
            }
        }

        // move funds back to region (de-allocation)
        for (EMS_Fund_Request_gne__c request : approvedTerritoryDeallocationFundRequests) {
            if (!territoryBudgetsToUpdate.containsKey(request.Related_Territory_Budget_gne__c)) {
                EMS_Budget_Territory_gne__c territoryBudgetToUpdate = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c);
                territoryBudgetToUpdate.Total_Territory_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;

                territoryBudgetsToUpdate.put(territoryBudgetToUpdate.Id, territoryBudgetToUpdate);
            } else {
                territoryBudgetsToUpdate.get(request.Related_Territory_Budget_gne__c).Total_Territory_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;
            }
        }

        // move funds back to source region budget
        for (EMS_Fund_Request_gne__c request : approvedRegionFundTransfers) {
            EMS_Budget_Region_gne__c sourceBudget;
            EMS_Budget_Region_gne__c targetBudget;

            // TODO: should not be the case when target or related budget Id is empty
            if (String.isBlank(request.Target_Region_Budget_ID_gne__c)
                    || String.isBlank(request.Related_Region_Budget_gne__c)
            ) {
                continue;
            }

            if (!regionBudgetsToUpdate.containsKey(request.Target_Region_Budget_ID_gne__c)) {
                targetBudget = relatedRegionBudgets.get(request.Target_Region_Budget_ID_gne__c);
                regionBudgetsToUpdate.put(targetBudget.Id, targetBudget);
            } else {
                targetBudget = regionBudgetsToUpdate.get(request.Target_Region_Budget_ID_gne__c);
            }

            if (!regionBudgetsToUpdate.containsKey(request.Related_Region_Budget_gne__c)) {
                sourceBudget = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c);
                regionBudgetsToUpdate.put(sourceBudget.Id, sourceBudget);
            } else {
                sourceBudget = regionBudgetsToUpdate.get(request.Related_Region_Budget_gne__c);
            }

            sourceBudget.Total_Region_Funds_Approved_gne__c += request.Requested_Amount_gne__c;
            targetBudget.Total_Region_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;
        }

        // move funds back to source territory budget
        for (EMS_Fund_Request_gne__c request : approvedTerritoryFundTransfers) {
            EMS_Budget_Territory_gne__c sourceBudget;
            EMS_Budget_Territory_gne__c targetBudget;

            // TODO: should not be the case when target or related budget Id is empty
            if (String.isBlank(request.Target_Territory_Budget_ID_gne__c)
                    || String.isBlank(request.Related_Territory_Budget_gne__c)
            ) {
                continue;
            }

            if (!territoryBudgetsToUpdate.containsKey(request.Target_Territory_Budget_ID_gne__c)) {
                targetBudget = relatedTerritoryBudgets.get(request.Target_Territory_Budget_ID_gne__c);
                territoryBudgetsToUpdate.put(targetBudget.Id, targetBudget);
            } else {
                targetBudget = territoryBudgetsToUpdate.get(request.Target_Territory_Budget_ID_gne__c);
            }

            if (!territoryBudgetsToUpdate.containsKey(request.Related_Territory_Budget_gne__c)) {
                sourceBudget = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c);
                territoryBudgetsToUpdate.put(sourceBudget.Id, sourceBudget);
            } else {
                sourceBudget = territoryBudgetsToUpdate.get(request.Related_Territory_Budget_gne__c);
            }

            sourceBudget.Total_Territory_Funds_Approved_gne__c += request.Requested_Amount_gne__c;
            targetBudget.Total_Territory_Funds_Approved_gne__c -= request.Requested_Amount_gne__c;
        }

        System.Savepoint initialState = Database.setSavepoint();

        try {

            if (regionBudgetsToUpdate.size() > 0) {
                update regionBudgetsToUpdate.values();
            }

            if (territoryBudgetsToUpdate.size() > 0) {
                update territoryBudgetsToUpdate.values();
            }

        } catch (DMLException ex) {
            Database.rollback(initialState);
            triggerOld.Values()[0].addError('Fund Request database error! Details: ' + ex.getMessage());
        }
    }

    private static void shareWithApprover(Map<Id, EMS_Fund_Request_gne__c> triggerOld, Map<Id, EMS_Fund_Request_gne__c> triggerNew) {
        List<EMS_Fund_Request_gne__Share> sharesToInsert = new List<EMS_Fund_Request_gne__Share>();
        String rowCause = Schema.EMS_Fund_Request_gne__Share.RowCause.Approver_Sharing__c;
        Set<String> existingSharesExternalIds = new Set<String>();
        Set<Id> parentIdsOfSharesToRemove = new Set<Id>();

        for (EMS_Fund_Request_gne__Share existingShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :triggerNew.values()]) {
            existingSharesExternalIds.add(String.valueOf(existingShare.ParentId) + String.valueOf(existingShare.UserOrGroupId) + String.valueOf(existingShare.RowCause));
        }

        for (EMS_Fund_Request_gne__c fundRequest : triggerNew.values()) {
            if (fundRequest.Status_gne__c == 'Submitted' && (triggerOld.containsKey(fundRequest.Id) == false || triggerOld.get(fundRequest.Id).Status_gne__c != 'Submitted') && !existingSharesExternalIds.contains(String.valueOf(fundRequest.Id) + String.valueOf(fundRequest.Approver_gne__c) + rowCause)) {
                EMS_Fund_Request_gne__Share frShare = new EMS_Fund_Request_gne__Share(
                        ParentId = fundRequest.Id,
                        UserOrGroupId = fundRequest.Approver_gne__c,
                        AccessLevel = 'Edit',
                        RowCause = rowCause
                );
                sharesToInsert.add(frShare);
                parentIdsOfSharesToRemove.add(fundRequest.Id);
            }
        }

        if (!parentIdsOfSharesToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :parentIdsOfSharesToRemove AND RowCause = :rowCause];
        }

        if (sharesToInsert.size() > 0) {
            insert sharesToInsert;
        }
    }

    // shares FR related budgets with approver
    private static void shareFundRequestRelatedBudgetsWithApprover(Map<Id, EMS_Fund_Request_gne__c> triggerOld, Map<Id, EMS_Fund_Request_gne__c> triggerNew) {
        List<EMS_Budget_Product_gne__Share> productBudgetSharesToInsert = new List<EMS_Budget_Product_gne__Share>();
        List<EMS_Budget_Region_gne__Share> regionBudgetSharesToInsert = new List<EMS_Budget_Region_gne__Share>();
        List<EMS_Budget_Territory_gne__Share> territoryBudgetSharesToInsert = new List<EMS_Budget_Territory_gne__Share>();

        String productBudgetRowCause = Schema.EMS_Budget_Product_gne__Share.RowCause.Approver_Sharing__c;
        String regionBudgetRowCause = Schema.EMS_Budget_Region_gne__Share.RowCause.Approver_Sharing__c;
        String territoryBudgetRowCause = Schema.EMS_Budget_Territory_gne__Share.RowCause.Approver_Sharing__c;

        Set<String> existingProductBudgetSharesExternalIds = new Set<String>();
        Set<Id> parentIdsOfProductBudgetSharesToRemove = new Set<Id>();

        Set<String> existingRegionBudgetSharesExternalIds = new Set<String>();
        Set<Id> parentIdsOfRegionBudgetSharesToRemove = new Set<Id>();

        Set<String> existingTerritoryBudgetSharesExternalIds = new Set<String>();
        Set<Id> parentIdsOfTerritoryBudgetSharesToRemove = new Set<Id>();

        for (EMS_Budget_Product_gne__Share existingShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :relatedProductBudgets.values()]) {
            existingProductBudgetSharesExternalIds.add(String.valueOf(existingShare.ParentId) + String.valueOf(existingShare.UserOrGroupId) + String.valueOf(existingShare.RowCause));
        }

        for (EMS_Budget_Region_gne__Share existingShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :relatedRegionBudgets.values()]) {
            existingRegionBudgetSharesExternalIds.add(String.valueOf(existingShare.ParentId) + String.valueOf(existingShare.UserOrGroupId) + String.valueOf(existingShare.RowCause));
        }

        for (EMS_Budget_Territory_gne__Share existingShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :relatedTerritoryBudgets.values()]) {
            existingTerritoryBudgetSharesExternalIds.add(String.valueOf(existingShare.ParentId) + String.valueOf(existingShare.UserOrGroupId) + String.valueOf(existingShare.RowCause));
        }

        for (EMS_Fund_Request_gne__c fundRequest : triggerNew.values()) {
            // check the type of the fund request
            if (fundRequest.Status_gne__c == 'Submitted' && (triggerOld.containsKey(fundRequest.Id) == false || triggerOld.get(fundRequest.Id).Status_gne__c != 'Submitted')) {
                if (fundRequest.Related_Product_Budget_gne__c != null && !existingProductBudgetSharesExternalIds.contains(String.valueOf(fundRequest.Related_Product_Budget_gne__c) + String.valueOf(fundRequest.Approver_gne__c) + productBudgetRowCause)) {
                    EMS_Budget_Product_gne__Share pbShare = new EMS_Budget_Product_gne__Share(
                            ParentId = fundRequest.Related_Product_Budget_gne__c,
                            UserOrGroupId = fundRequest.Approver_gne__c,
                            AccessLevel = 'Read',
                            RowCause = productBudgetRowCause
                    );
                    productBudgetSharesToInsert.add(pbShare);
                    parentIdsOfProductBudgetSharesToRemove.add(fundRequest.Related_Product_Budget_gne__c);
                }

                if (fundRequest.Related_Region_Budget_gne__c != null && !existingRegionBudgetSharesExternalIds.contains(String.valueOf(fundRequest.Related_Region_Budget_gne__c) + String.valueOf(fundRequest.Approver_gne__c) + regionBudgetRowCause)) {
                    EMS_Budget_Region_gne__Share rbShare = new EMS_Budget_Region_gne__Share(
                            ParentId = fundRequest.Related_Region_Budget_gne__c,
                            UserOrGroupId = fundRequest.Approver_gne__c,
                            AccessLevel = 'Read',
                            RowCause = regionBudgetRowCause
                    );
                    regionBudgetSharesToInsert.add(rbShare);
                    parentIdsOfRegionBudgetSharesToRemove.add(fundRequest.Related_Region_Budget_gne__c);
                }

                if (fundRequest.Related_Territory_Budget_gne__c != null && !existingTerritoryBudgetSharesExternalIds.contains(String.valueOf(fundRequest.Related_Territory_Budget_gne__c) + String.valueOf(fundRequest.Approver_gne__c) + territoryBudgetRowCause)) {
                    EMS_Budget_Territory_gne__Share tbShare = new EMS_Budget_Territory_gne__Share(
                            ParentId = fundRequest.Related_Territory_Budget_gne__c,
                            UserOrGroupId = fundRequest.Approver_gne__c,
                            AccessLevel = 'Read',
                            RowCause = territoryBudgetRowCause
                    );
                    territoryBudgetSharesToInsert.add(tbShare);
                    parentIdsOfTerritoryBudgetSharesToRemove.add(fundRequest.Related_Territory_Budget_gne__c);
                }
            }
        }
        if (!parentIdsOfProductBudgetSharesToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :parentIdsOfProductBudgetSharesToRemove AND RowCause = :productBudgetRowCause];
        }
        if (!parentIdsOfRegionBudgetSharesToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :parentIdsOfRegionBudgetSharesToRemove AND RowCause = :regionBudgetRowCause];
        }
        if (!parentIdsOfTerritoryBudgetSharesToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :parentIdsOfTerritoryBudgetSharesToRemove AND RowCause = :territoryBudgetRowCause];
        }

        if (productBudgetSharesToInsert.size() > 0) {
            insert productBudgetSharesToInsert;
        }
        if (regionBudgetSharesToInsert.size() > 0) {
            insert regionBudgetSharesToInsert;
        }
        if (territoryBudgetSharesToInsert.size() > 0) {
            insert territoryBudgetSharesToInsert;
        }
    }

    // shares region budget with the parent territory of the fund request
    public static void shareFundRequestWithParentBudgetTerritory(Map<Id, EMS_Fund_Request_gne__c> triggerNew) {
        List<EMS_Fund_Request_gne__Share> sharesToInsert = new List <EMS_Fund_Request_gne__Share>();
        Set<Id> parentIdsOfSharesToRemove = new Set<Id>();

        Set<String> existingSharesExternalIds = new Set<String>();
        for (EMS_Fund_Request_gne__Share existingShare : [SELECT Id, AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :triggerNew.values()]) {
            existingSharesExternalIds.add(String.valueOf(existingShare.ParentId) + String.valueOf(existingShare.UserOrGroupId) + String.valueOf(existingShare.RowCause));
        }

        String rowCauseParentBudget = Schema.EMS_Fund_Request_gne__Share.RowCause.Parent_Budget_Sharing__c;

        for (EMS_Fund_Request_gne__c fundRequest : triggerNew.values()) {
            // check the type of the fund request
            String parentBudgetTerritoryId;
            String productBudgetTerritoryId;

            if (fundRequestRecordTypes.get(fundRequest.RecordTypeId).contains('Region')) {
                // share with the territory of the Region Budget
                parentBudgetTerritoryId = relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).Assigned_To_Territory_Id_gne__c;
            } else if (fundRequestRecordTypes.get(fundRequest.RecordTypeId).contains('Territory')) {
                // share with the territory of the Territory Budget
                parentBudgetTerritoryId = relatedTerritoryBudgets.get(fundRequest.Related_Territory_Budget_gne__c).Assigned_To_Territory_Id_gne__c;
            }

            // fund requests need to be also shared with the product budget territory
            if (relatedRegionBudgets.containsKey(fundRequest.Related_Region_Budget_gne__c)) {
                productBudgetTerritoryId = relatedRegionBudgets.get(fundRequest.Related_Region_Budget_gne__c).EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c;
            }

            if (parentBudgetTerritoryId != null
                    && !existingSharesExternalIds.contains(String.valueOf(fundRequest.Id) + String.valueOf(relatedGroups.get(parentBudgetTerritoryId)) + rowCauseParentBudget)
                    && relatedGroups.containsKey(parentBudgetTerritoryId)
                    ) {
                EMS_Fund_Request_gne__Share frShare = new EMS_Fund_Request_gne__Share(
                        ParentId = fundRequest.Id,
                        UserOrGroupId = relatedGroups.get(parentBudgetTerritoryId),
                        AccessLevel = 'Edit',
                        RowCause = rowCauseParentBudget
                );
                sharesToInsert.add(frShare);
                parentIdsOfSharesToRemove.add(fundRequest.Id);
            }

            if (productBudgetTerritoryId != null
                    && !existingSharesExternalIds.contains(String.valueOf(fundRequest.Id) + String.valueOf(relatedGroups.get(productBudgetTerritoryId)) + rowCauseParentBudget)
                    && relatedGroups.containsKey(productBudgetTerritoryId)
                    ) {
                EMS_Fund_Request_gne__Share frShare = new EMS_Fund_Request_gne__Share(
                        ParentId = fundRequest.Id,
                        UserOrGroupId = relatedGroups.get(productBudgetTerritoryId),
                        AccessLevel = 'Edit',
                        RowCause = rowCauseParentBudget
                );
                sharesToInsert.add(frShare);
                parentIdsOfSharesToRemove.add(fundRequest.Id);
            }
        }

        if (!parentIdsOfSharesToRemove.isEmpty()) {
            delete [SELECT Id FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :parentIdsOfSharesToRemove AND RowCause = :rowCauseParentBudget];
        }

        if (!sharesToInsert.isEmpty()) {
            insert sharesToInsert;
        }

    }

    private static void getGroupsRelatedToProductBudgetTerritories() {
        Map <Id, Id> relatedTerritories = new Map <Id, Id>();
        for (EMS_Budget_Product_gne__c productBudget : relatedProductBudgets.values()) {
            if (productBudget.Assigned_To_Territory_Id__c != null) {
                relatedTerritories.put(productBudget.id, productBudget.Assigned_To_Territory_Id__c);
            }
        }

        for (EMS_Budget_Region_gne__c regionBudget : relatedRegionBudgets.values()) {
            if (regionBudget.Assigned_To_Territory_Id_gne__c != null) {
                relatedTerritories.put(regionBudget.id, regionBudget.Assigned_To_Territory_Id_gne__c);
                relatedTerritories.put(regionBudget.EMS_Budget_Product_gne__c, regionBudget.EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c);
            }
        }

        for (EMS_Budget_Territory_gne__c territoryBudget : relatedTerritoryBudgets.values()) {
            if (territoryBudget.Assigned_To_Territory_Id_gne__c != null) {
                relatedTerritories.put(territoryBudget.id, territoryBudget.Assigned_To_Territory_Id_gne__c);
            }
        }
        relatedGroups = EMS_Util.getTerritoriesGroups(new Set<Id>(relatedTerritories.values()));
    }

    private static void getRelatedObjectFields(Map<Id, EMS_Fund_Request_gne__c> triggerNew) {
        Set <Id> relatedBudgetsIds = new Set <Id>();
        for (EMS_Fund_Request_gne__c request : triggerNew.values()) {
            if (request.Related_Region_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Region_Budget_gne__c);
            }
            if (request.Related_Product_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Product_Budget_gne__c);
            }
            if (request.Related_Territory_Budget_gne__c != null) {
                relatedBudgetsIds.add(request.Related_Territory_Budget_gne__c);
            }
            if (request.Target_Region_Budget_ID_gne__c != null) {
                relatedBudgetsIds.add(request.Target_Region_Budget_ID_gne__c);
            }
            if (request.Target_Territory_Budget_ID_gne__c != null) {
                relatedBudgetsIds.add(request.Target_Territory_Budget_ID_gne__c);
            }
        }
        relatedTerritoryBudgets = new Map<Id, EMS_Budget_Territory_gne__c>([
                SELECT Id, Assigned_To_Territory_Id_gne__c, Total_Territory_Funds_Approved_gne__c, Assigned_to_gne__c,
                        EMS_Budget_Region_gne__r.Assigned_to_gne__c, EMS_Budget_Region_gne__r.EMS_Budget_Product_gne__r.Assigned_to_gne__c
                FROM EMS_Budget_Territory_gne__c
                WHERE Id IN :relatedBudgetsIds
        ]);
        relatedRegionBudgets = new Map<Id, EMS_Budget_Region_gne__c>([
                SELECT Id, Assigned_To_Territory_Id_gne__c, EMS_Budget_Product_gne__c, EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c,
                        Total_Region_Funds_Approved_gne__c, Child_Budgets_Allocated_Amount_gne__c, Assigned_to_gne__c, EMS_Budget_Product_gne__r.Assigned_to_gne__c
                FROM EMS_Budget_Region_gne__c
                WHERE Id IN :relatedBudgetsIds
        ]);
        relatedProductBudgets = new Map<Id, EMS_Budget_Product_gne__c>([
                SELECT Id, Assigned_To_Territory_Id__c, Assigned_to_gne__c, Total_Product_Funds_Approved_gne__c, Child_Budgets_Allocated_Amount_gne__c
                FROM EMS_Budget_Product_gne__c
                WHERE Id IN :relatedBudgetsIds
        ]);
    }

    public static void sendTransferEmailNotifications(Map<Id, EMS_Fund_Request_gne__c> triggerNew) {
        if (Trigger.isInsert == false) {
            return;
        }
        // A logic works only for after insert action
        for (EMS_Fund_Request_gne__c request : triggerNew.values()) {
            if (request.Status_gne__c != 'Approved') {
                continue;
            }
            Id sourceRecipiendId, targetRecipientId;

            if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_ALLOCATION_TERRITORY_FUNDS) {
                sourceRecipiendId = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c).Assigned_to_gne__c;
                targetRecipientId = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c).Assigned_to_gne__c;
            } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_ALLOCATION_REGION_FUNDS) {
                sourceRecipiendId = relatedProductBudgets.get(request.Related_Product_Budget_gne__c).Assigned_to_gne__c;
                targetRecipientId = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c).Assigned_to_gne__c;
            } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_DEALLOCATION_REGION_FUNDS) {
                sourceRecipiendId = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c).Assigned_to_gne__c;
                targetRecipientId = relatedProductBudgets.get(request.Related_Product_Budget_gne__c).Assigned_to_gne__c;
            } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_DEALLOCATION_TERRITORY_FUNDS) {
                sourceRecipiendId = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c).Assigned_to_gne__c;
                targetRecipientId = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c).Assigned_to_gne__c;
            } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_TRANSFER_REGION_FUNDS) {
                sourceRecipiendId = relatedRegionBudgets.get(request.Related_Region_Budget_gne__c).Assigned_to_gne__c;
                targetRecipientId = relatedRegionBudgets.get(request.Target_Region_Budget_ID_gne__c).Assigned_to_gne__c;
            } else if (fundRequestRecordTypes.get(request.RecordTypeId) == EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS) {
                sourceRecipiendId = relatedTerritoryBudgets.get(request.Related_Territory_Budget_gne__c).Assigned_to_gne__c;
                targetRecipientId = relatedTerritoryBudgets.get(request.Target_Territory_Budget_ID_gne__c).Assigned_to_gne__c;
            }

            EMS_Email.prepareSingleEmail('EMS_Transfer_Funds_Decrease', request.Id, sourceRecipiendId);
            EMS_Email.prepareSingleEmail('EMS_Transfer_Funds_Increase', request.Id, targetRecipientId);
        }
        EMS_Email.send();
    }

    public static void onAfterInsertUpdate(Map<Id, EMS_Fund_Request_gne__c> triggerOld, Map<Id, EMS_Fund_Request_gne__c> triggerNew) {
        getObjectRecordTypes();

        getRelatedObjectFields(triggerNew);
        getGroupsRelatedToProductBudgetTerritories();

        shareFundRequestWithParentBudgetTerritory(triggerNew);
        shareFundRequestRelatedBudgetsWithApprover(triggerOld, triggerNew);

        moveFundsUponApproval(triggerOld, triggerNew);
        shareWithApprover(triggerOld, triggerNew);
        sendTransferEmailNotifications(triggerNew);
    }

    public static void onBeforeDelete(Map<Id, EMS_Fund_Request_gne__c> triggerOld) {
        getObjectRecordTypes();
        getRelatedObjectFields(triggerOld);
        moveFundsUponDelete(triggerOld);
    }

    private static void getObjectRecordTypes() {
        Schema.DescribeSObjectResult obj = EMS_Fund_Request_gne__c.SObjectType.getDescribe();
        Map<Id, Schema.RecordTypeInfo> recordTypeInfos = obj.getRecordTypeInfosByID();
        for (Schema.RecordTypeInfo rtInfo : recordTypeInfos.values()) {
            fundRequestRecordTypes.put(rtInfo.getRecordTypeId(), rtInfo.getName());
        }
    }
}