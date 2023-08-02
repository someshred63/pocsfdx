public without sharing class EMS_Budget_Allocation_Field_Updates {

    private static Map<Id, Schema.RecordTypeInfo> budgetAllocationRecordTypes = EMS_Budget_Allocation_gne__c.SObjectType.getDescribe().getRecordTypeInfosById();
    private static Map<Id, EMS_Budget_Product_gne__c> relatedProductBudgets = new Map<Id, EMS_Budget_Product_gne__c>();
    private static Map<Id, EMS_Budget_Region_gne__c> relatedRegionBudgets = new Map<Id, EMS_Budget_Region_gne__c>();
    private static Map<Id, EMS_Budget_Territory_gne__c> relatedTerritoryBudgets = new Map<Id, EMS_Budget_Territory_gne__c>();
    private static Map<Id, EMS_Event__c> relatedEvents = new Map<Id, EMS_Event__c>();
    private static Map<Id, GNE_User_Delegation__c> userDelegations;

    /**************************************************************************
    ********************* Methods called by trigger ***************************
    **************************************************************************/

    public static void onBeforeInsert(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        userDelegations = EMS_Util.getUserDelegations();

        fetchRelatedBudgets(triggerNew);
        fetchRelatedEvents(triggerNew);
        updatePercentageContribution(triggerNew);
        updateRecordType(triggerNew);
        updateBudgetOwner(triggerNew);
        updateProductIndication(triggerNew);
        updateCostCenterInformation(triggerNew);
    }

    public static void onBeforeUpdate(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, List<EMS_Budget_Allocation_gne__c> triggerNew) {
        userDelegations = EMS_Util.getUserDelegations();

        fetchRelatedBudgets(triggerNew);
        fetchRelatedEvents(triggerNew);
        updatePercentageContribution(triggerNew);
        updateRecordType(triggerNew);
        updateBudgetOwner(triggerNew);
        updateProductIndication(triggerNew);
        updateCostCenterInformation(triggerNew);
        updateSubmittedBy(triggerOld, triggerNew);
        updateStatusOnUpdate(triggerOld, triggerNew);
        overrideApprover(triggerOld, triggerNew);
    }

    /**************************************************************************
    **************************** Action methods *******************************
    **************************************************************************/
    private static void updatePercentageContribution(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        for (EMS_Budget_Allocation_gne__c allocation : triggerNew) {
            EMS_Event__c event = relatedEvents.get(allocation.EMS_Event_gne__c);

            Decimal planned = event.Planned_Expenses_gne__c;
            if (planned == null || planned == 0) {
                System.debug('>>> Planned Expense is 0 or empty: ' + planned);
                allocation.Percentage_Contribution_gne__c = 0;
                continue;
            }

            Decimal allocated = allocation.Allocated_Budget_gne__c;
            if (allocated == null || allocated == 0) {
                System.debug('>>> Allocated Amount is 0 or empty: ' + allocated);
                allocation.Percentage_Contribution_gne__c = 0;
                continue;
            }

            Decimal percentage = allocation.Percentage_Contribution_gne__c;

            Integer compareScale = 2;
            Decimal calculatedPercentage = allocated.divide(planned, allocated.scale()) * 100;
            if (percentage.setScale(compareScale) != calculatedPercentage.setScale(compareScale)) {
                allocation.Percentage_Contribution_gne__c = calculatedPercentage;
            }
        }
    }

    private static void updateRecordType(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        Schema.SObjectType budgetAllocationSObject = EMS_Budget_Allocation_gne__c.getSObjectType();
        DescribeSObjectResult budgetAllocationDescribe = budgetAllocationSObject.getDescribe();

        Map<String, Schema.RecordTypeInfo> rtMapByName = budgetAllocationDescribe.getRecordTypeInfosByName();
        Schema.RecordTypeInfo productBudgetAllocation = rtMapByName.get('Product Budget Allocation');
        Schema.RecordTypeInfo regionBudgetAllocation = rtMapByName.get('Region Budget Allocation');
        Schema.RecordTypeInfo territoryBudgetAllocation = rtMapByName.get('Territory Budget Allocation');

        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (budgetAllocation.EMS_Product_Budget_gne__c != null) {
                // product budget allocation
                budgetAllocation.RecordTypeId = productBudgetAllocation.getRecordTypeId();
            } else if (budgetAllocation.EMS_Region_Budget_gne__c != null) {
                // region budget allocation
                budgetAllocation.RecordTypeId = regionBudgetAllocation.getRecordTypeId();
            } else if (budgetAllocation.EMS_Territory_Budget_gne__c != null) {
                // territory budget allocation
                budgetAllocation.RecordTypeId = territoryBudgetAllocation.getRecordTypeId();
            }
        }
    }

    private static void updateBudgetOwner(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation') {
                budgetAllocation.Budget_Owner_gne__c = relatedProductBudgets.get(budgetAllocation.EMS_Product_Budget_gne__c).Assigned_to_gne__c;
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation') {
                budgetAllocation.Budget_Owner_gne__c = relatedRegionBudgets.get(budgetAllocation.EMS_Region_Budget_gne__c).Assigned_to_gne__c;
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation') {
                budgetAllocation.Budget_Owner_gne__c = relatedTerritoryBudgets.get(budgetAllocation.EMS_Territory_Budget_gne__c).Assigned_to_gne__c;
            }
        }
    }

    private static void updateProductIndication(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation') {
                budgetAllocation.Product_Indication_gne__c = relatedProductBudgets.get(budgetAllocation.EMS_Product_Budget_gne__c).Product_Indication_gne__c;
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation') {
                budgetAllocation.Product_Indication_gne__c = relatedRegionBudgets.get(budgetAllocation.EMS_Region_Budget_gne__c).Product_Indication_gne__c;
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation') {
                budgetAllocation.Product_Indication_gne__c = relatedTerritoryBudgets.get(budgetAllocation.EMS_Territory_Budget_gne__c).Product_Indication_gne__c;
            }
        }
    }

    private static void updateCostCenterInformation(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation') {
                budgetAllocation.Cost_Center_gne__c = relatedProductBudgets.get(budgetAllocation.EMS_Product_Budget_gne__c).Cost_Center_gne__r.Name;
                budgetAllocation.Cost_Center_Type_gne__c = relatedProductBudgets.get(budgetAllocation.EMS_Product_Budget_gne__c).Cost_Center_Type_gne__c;
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation') {
                budgetAllocation.Cost_Center_gne__c = relatedRegionBudgets.get(budgetAllocation.EMS_Region_Budget_gne__c).Cost_Center_gne__c;
                budgetAllocation.Cost_Center_Type_gne__c = relatedRegionBudgets.get(budgetAllocation.EMS_Region_Budget_gne__c).Cost_Center_Type_gne__c;
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation') {
                budgetAllocation.Cost_Center_gne__c = relatedTerritoryBudgets.get(budgetAllocation.EMS_Territory_Budget_gne__c).Cost_Center_gne__c;
                budgetAllocation.Cost_Center_Type_gne__c = relatedTerritoryBudgets.get(budgetAllocation.EMS_Territory_Budget_gne__c).Cost_Center_Type_gne__c;
            }
        }
    }

    private static void updateSubmittedBy(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, List<EMS_Budget_Allocation_gne__c> triggerNew) {
        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (budgetAllocation.Status_gne__c == 'Submitted' && triggerOld.get(budgetAllocation.Id).Status_gne__c != 'Submitted') {
                budgetAllocation.Submitted_By_gne__c = UserInfo.getUserId();
            }
        }
    }

    private static void updateStatusOnUpdate(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, List<EMS_Budget_Allocation_gne__c> triggerNew) {
        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (budgetAllocation.Status_gne__c == 'Approved') {
                if (budgetAllocation.Allocated_Budget_gne__c != triggerOld.get(budgetAllocation.Id).Allocated_Budget_gne__c) {
                    budgetAllocation.Status_gne__c = 'New';
                }
            }
        }
    }

    private static void overrideApprover(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, List<EMS_Budget_Allocation_gne__c> triggerNew) {
        for (EMS_Budget_Allocation_gne__c ba : triggerNew) {
            Boolean statusChanged = triggerOld.get(ba.Id).Status_gne__c != ba.Status_gne__c;
            Boolean isSubmitted = String.isNotBlank(ba.Status_gne__c) && ba.Status_gne__c.contains('Submitted');

            if (isSubmitted) {
                ba.Approver_gne__c = getDelegatedUser(ba.Budget_Owner_gne__c);
            } else if (statusChanged) {
                ba.Approver_gne__c = null;
            }
        }
    }
    /**************************************************************************
    **************************** Helper methods *******************************
    **************************************************************************/

    private static void fetchRelatedEvents(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();

        for (EMS_Budget_Allocation_gne__c allocation : triggerNew) {
            eventIds.add(allocation.EMS_Event_gne__c);
        }

        relatedEvents = new Map<Id, EMS_Event__c>([SELECT Id, Planned_Expenses_gne__c FROM EMS_Event__c WHERE Id IN :eventIds]);
    }

    private static void fetchRelatedBudgets(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        List<Id> relatedProductBudgetIds = new List<Id>();
        List<Id> relatedRegionBudgetIds = new List<Id>();
        List<Id> relatedTerritoryBudgetIds = new List<Id>();

        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation') {
                relatedProductBudgetIds.add(budgetAllocation.EMS_Product_Budget_gne__c);
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation') {
                relatedRegionBudgetIds.add(budgetAllocation.EMS_Region_Budget_gne__c);
            } else if (budgetAllocationRecordTypes.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation') {
                relatedTerritoryBudgetIds.add(budgetAllocation.EMS_Territory_Budget_gne__c);
            }
        }

        for (EMS_Budget_Product_gne__c productBudget : [SELECT Assigned_to_gne__c, Product_Indication_gne__c, Cost_Center_gne__r.Name, Cost_Center_Type_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :relatedProductBudgetIds]) {
            relatedProductBudgets.put(productBudget.Id, productBudget);
        }

        for (EMS_Budget_Region_gne__c regionBudget : [SELECT Assigned_to_gne__c, Product_Indication_gne__c, Cost_Center_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :relatedRegionBudgetIds]) {
            relatedRegionBudgets.put(regionBudget.Id, regionBudget);
        }

        for (EMS_Budget_Territory_gne__c territoryBudget : [SELECT Assigned_to_gne__c, Product_Indication_gne__c, Cost_Center_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :relatedTerritoryBudgetIds]) {
            relatedTerritoryBudgets.put(territoryBudget.Id, territoryBudget);
        }
    }

    private static Id getDelegatedUser(Id mainUserId) {
        if (userDelegations.containsKey(mainUserId)) {
            return userDelegations.get(mainUserId).Delegated_User__c;
        }
        return mainUserId;
    }
}