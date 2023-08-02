public without sharing class EMS_Budget_Allocation_Validation_Rules {

    private static Map<Id, Schema.RecordTypeInfo> recordTypeInfos = EMS_Budget_Allocation_gne__c.SObjectType.getDescribe().getRecordTypeInfosByID();

	/**************************************************************************
	********************* Methods called by trigger ***************************
	**************************************************************************/

    public static boolean onBeforeInsert(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        if (EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules == FALSE) {
            return validateAllocatedAmount(null, triggerNew)
                    || validateDuplicateBudgetAllocation(triggerNew)
                    || validateSponsorshipAmount(triggerNew);
        } else {
            return false;
        }
    }

    public static boolean onBeforeUpdate(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, List<EMS_Budget_Allocation_gne__c> triggerNew) {
        if (EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules == FALSE) {
            return validateAllocatedAmount(triggerOld, triggerNew)
                    || validateSponsorshipAmount(triggerNew);
        } else {
            return false;
        }
    }

	/**************************************************************************
	**************************** Action methods *******************************
	**************************************************************************/

    private static boolean validateAllocatedAmount(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, List<EMS_Budget_Allocation_gne__c> triggerNew) {
        Set<Id> relatedProductBudgetsIds = new Set<Id>();
        Set<Id> relatedRegionBudgetsIds = new Set<Id>();
        Set<Id> relatedTerritoryBudgetsIds = new Set<Id>();

        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation') {
                relatedProductBudgetsIds.add(budgetAllocation.EMS_Product_Budget_gne__c);
            } else if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation') {
                relatedRegionBudgetsIds.add(budgetAllocation.EMS_Region_Budget_gne__c);
            } else if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation') {
                relatedTerritoryBudgetsIds.add(budgetAllocation.EMS_Territory_Budget_gne__c);
            }
        }

        Map<Id, EMS_Budget_Product_gne__c> relatedProductBudgets;
        Map<Id, EMS_Budget_Region_gne__c> relatedRegionBudgets;
        Map<Id, EMS_Budget_Territory_gne__c> relatedTerritoryBudgets;

        if (!relatedProductBudgetsIds.isEmpty()) {
            relatedProductBudgets = new Map<Id, EMS_Budget_Product_gne__c>([SELECT Name, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :relatedProductBudgetsIds]);
        }
        if (!relatedRegionBudgetsIds.isEmpty()) {
            relatedRegionBudgets = new Map<Id, EMS_Budget_Region_gne__c>([SELECT Name, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :relatedRegionBudgetsIds]);
        }
        if (!relatedTerritoryBudgetsIds.isEmpty()) {
            relatedTerritoryBudgets = new Map<Id, EMS_Budget_Territory_gne__c>([SELECT Name, Territory_Balance_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :relatedTerritoryBudgetsIds]);
        }

        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            // negative amounts are not allowed
            if (budgetAllocation.Allocated_Budget_gne__c < 0) {
                budgetAllocation.addError(System.Label.Allocation_Greater_Than_Zero);
                return true;
            }
            if (triggerOld == null || (budgetAllocation.Allocated_Budget_gne__c > triggerOld.get(budgetAllocation.Id).Allocated_Budget_gne__c)) {
                Decimal budgetallocationChange;
                if (triggerOld != null) {
                    budgetallocationChange = budgetAllocation.Allocated_Budget_gne__c - triggerOld.get(budgetAllocation.Id).Allocated_Budget_gne__c;
                }
                if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation') {
                    if ((triggerOld == null && (budgetAllocation.Allocated_Budget_gne__c > relatedProductBudgets.get(budgetAllocation.EMS_Product_Budget_gne__c).Product_Balance_gne__c))
                            || (budgetallocationChange > relatedProductBudgets.get(budgetAllocation.EMS_Product_Budget_gne__c).Product_Balance_gne__c)) {
                        budgetAllocation.addError(relatedProductBudgets.get(budgetAllocation.EMS_Product_Budget_gne__c).Name + ': ' + System.Label.Amount_Exceeds_Balance);
                        return true;
                    }
                } else if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation') {
                    if ((triggerOld == null && (budgetAllocation.Allocated_Budget_gne__c > relatedRegionBudgets.get(budgetAllocation.EMS_Region_Budget_gne__c).Region_Balance_gne__c))
                            || (budgetallocationChange > relatedRegionBudgets.get(budgetAllocation.EMS_Region_Budget_gne__c).Region_Balance_gne__c)) {
                        budgetAllocation.addError(relatedRegionBudgets.get(budgetAllocation.EMS_Region_Budget_gne__c).Name + ': ' + System.Label.Amount_Exceeds_Balance);
                        return true;
                    }
                } else if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation') {
                    if ((triggerOld == null && (budgetAllocation.Allocated_Budget_gne__c > relatedTerritoryBudgets.get(budgetAllocation.EMS_Territory_Budget_gne__c).Territory_Balance_gne__c))
                            || (budgetallocationChange > relatedTerritoryBudgets.get(budgetAllocation.EMS_Territory_Budget_gne__c).Territory_Balance_gne__c)) {
                        budgetAllocation.addError(relatedTerritoryBudgets.get(budgetAllocation.EMS_Territory_Budget_gne__c).Name + ': ' + System.Label.Amount_Exceeds_Balance);
                        return true;
                    }
                }
            }
        }
        return false;
    }

    private static boolean validateDuplicateBudgetAllocation(List<EMS_Budget_Allocation_gne__c> triggerNew) {
        Set<String> existingBudgetAllocations = new Set<String>();

        for (EMS_Budget_Allocation_gne__c budgetAllocation : [SELECT EMS_Product_Budget_gne__c, EMS_Region_Budget_gne__c, EMS_Territory_Budget_gne__c, EMS_Event_gne__c, RecordTypeId FROM EMS_Budget_Allocation_gne__c]) {
            if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation') {
                existingBudgetAllocations.add(String.valueOf(budgetAllocation.EMS_Event_gne__c) + String.valueOf(budgetAllocation.EMS_Product_Budget_gne__c));
            } else if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation') {
                existingBudgetAllocations.add(String.valueOf(budgetAllocation.EMS_Event_gne__c) + String.valueOf(budgetAllocation.EMS_Region_Budget_gne__c));
            } else if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation') {
                existingBudgetAllocations.add(String.valueOf(budgetAllocation.EMS_Event_gne__c) + String.valueOf(budgetAllocation.EMS_Territory_Budget_gne__c));
            }
        }

        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Product Budget Allocation') {
                if (existingBudgetAllocations.contains(String.valueOf(budgetAllocation.EMS_Event_gne__c) + String.valueOf(budgetAllocation.EMS_Product_Budget_gne__c))) {
                    budgetAllocation.addError(System.Label.Budget_Allocation_Already_Exists);
                    return true;
                }
            } else if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Region Budget Allocation') {
                if (existingBudgetAllocations.contains(String.valueOf(budgetAllocation.EMS_Event_gne__c) + String.valueOf(budgetAllocation.EMS_Region_Budget_gne__c))) {
                    budgetAllocation.addError(System.Label.Budget_Allocation_Already_Exists);
                    return true;
                }
            } else if (recordTypeInfos.get(budgetAllocation.RecordTypeId).getName() == 'Territory Budget Allocation') {
                if (existingBudgetAllocations.contains(String.valueOf(budgetAllocation.EMS_Event_gne__c) + String.valueOf(budgetAllocation.EMS_Territory_Budget_gne__c))) {
                    budgetAllocation.addError(System.Label.Budget_Allocation_Already_Exists);
                    return true;
                }
            }
        }

        return false;
    }

    private static Boolean validateSponsorshipAmount(List<EMS_Budget_Allocation_gne__c> triggerNew){
        Set<Id> eventIds = new Set<Id>();
        Boolean result = false;

        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            if (String.isNotBlank(budgetAllocation.EMS_Region_Budget_gne__c)) {
                eventIds.add(budgetAllocation.EMS_Event_gne__c);
            }
        }

        // Collect evens for Region Budget Allocations
        Map<Id, EMS_Event__c> eventsMap = new Map<Id, EMS_Event__c>([
                SELECT Id, Event_Sub_Type_gne__c
                FROM EMS_Event__c
                WHERE Id IN :eventIds
                AND Event_Sub_Type_gne__c = 'Sponsorship of Events'
        ]);

        for (EMS_Budget_Allocation_gne__c budgetAllocation : triggerNew) {
            EMS_Event__c event = eventsMap.get(budgetAllocation.EMS_Event_gne__c);
            Boolean isAllocationExceeded = event != null
                    && String.isNotBlank(budgetAllocation.EMS_Region_Budget_gne__c)
                    && budgetAllocation.Allocated_Budget_gne__c > 10000;

            if (isAllocationExceeded) {
                budgetAllocation.Allocated_Budget_gne__c.addError('Maximum allocation amount can not exceed $10,000');
                result |= true;
            }
        }

        return false;
    }
}