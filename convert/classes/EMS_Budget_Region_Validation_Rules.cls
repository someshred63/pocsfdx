public without sharing class EMS_Budget_Region_Validation_Rules {

    private static Set<String> availableTerritoryNames;
    private static Map<Id, EMS_Budget_Product_gne__c> productBudgets = new Map<Id, EMS_Budget_Product_gne__c>();
    private static Map<Id, String> usersRolesFromSR = EMS_Util.getUsersRolesFromSR();
    private static Map<String, Set<String>> allowedOwners = new Map<String, Set<String>>();
    private static Map<Id, Set<String>> usersPermissions = new Map<Id, Set<String>>();
    public static final Set<String> allowedRoles = new Set<String>{
            'PM', 'RSM', 'Rep', 'MM', 'ML', 'RAMA', 'AARC'
    };

    public static Boolean onBeforeInsert(List<EMS_Budget_Region_gne__c > triggerNew) {
        fetchProductBudgets(triggerNew);
        fetchAllowedOwners();
        usersPermissions = EMS_Util.fetchBudgetUsersPermissions(triggerNew);

        if (EMS_Region_Budget_Helper.skipTriggerValidationRules == false) {
            availableTerritoryNames = fetchAvailableTerritoryNames(triggerNew);
            return runOnBeforeInsert(triggerNew);
        } else {
            return false;
        }
    }

    public static Boolean onBeforeUpdate(List<EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        fetchProductBudgets(triggerNew);
        fetchAllowedOwners();
        usersPermissions = EMS_Util.fetchBudgetUsersPermissions(triggerNew);

        if (EMS_Region_Budget_Helper.skipTriggerValidationRules == false) {
            availableTerritoryNames = fetchAvailableTerritoryNames(triggerNew);
            return runOnBeforeUpdate(triggerOld, triggerNew);
        } else {
            return false;
        }
    }

    public static Boolean onBeforeDelete(Map<Id, EMS_Budget_Region_gne__c > triggerOldMap) {
        if (EMS_Region_Budget_Helper.skipTriggerValidationRules == false) {
            Boolean error = false;
            List<EMS_Budget_Region_gne__c> childrenForRegionBudget = fetchChildrenForRegionBudget(triggerOldMap.keySet());
            for (EMS_Budget_Region_gne__c budgetRegion : childrenForRegionBudget) {
                if (budgetRegion.EMS_Territory_Budgets__r != null && budgetRegion.EMS_Territory_Budgets__r.size() > 0) {
                    triggerOldMap.get(budgetRegion.Id).addError(System.Label.Remove_Related_Records);
                    error = true;
                }
            }

            List<EMS_Budget_Allocation_gne__c> budgetAllocations = fetchBudgetAllocations(triggerOldMap.keySet());
            for (EMS_Budget_Allocation_gne__c allocation : budgetAllocations) {
                triggerOldMap.get(allocation.EMS_Region_Budget_gne__c).addError('Unable to delete budget due to existing Budget Allocations');
                error = true;
            }
            return error;
        } else {
            return false;
        }
    }

    private static Boolean runOnBeforeInsert(List<EMS_Budget_Region_gne__c > triggerNew) {
        for (EMS_Budget_Region_gne__c budgetRegion : triggerNew) {
            if (!validateApprovedAmount(budgetRegion)) {
                budgetRegion.addError(System.Label.Total_Region_Funds_Approved_Cannot_Be_Negative_OR_Zero);
                return true;
            }

            if (!validateTotalAllocatedAmount(budgetRegion)) {
                budgetRegion.addError(budgetRegion.Name + ': ' + System.Label.Total_Budget_Allocated_Amount_Cannot_Be_Higher_Than_Funds_Approved_Amount);
                return true;
            }

            if (!validateStartDate(null, budgetRegion)) {
                budgetRegion.addError(System.Label.Start_Date_Cannot_Be_Prior_Than_Current_Year);
                return true;
            }

            if (!validateEndDate(budgetRegion)) {
                budgetRegion.addError(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date);
                return true;
            }
            if (!validateAssignedToUserRole(budgetRegion)) {
                budgetRegion.addError(System.Label.Budget_Invalid_Assigned_To_User);
                return true;
            }
            if (!validateDatesWithinParent(budgetRegion)) {
                budgetRegion.addError(System.Label.Invalid_Year);
                return true;
            }
            if (!validateIfDatesBetweenDatesOfRegionBudget(budgetRegion)) {
                budgetRegion.addError(System.Label.Budget_Start_End_dates_must_be_between_parent_budget_Dates);
                return true;
            }
        }
        return false;
    }

    private static Boolean runOnBeforeUpdate(List<EMS_Budget_Region_gne__c> triggerOld, List<EMS_Budget_Region_gne__c> triggerNew) {
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (!validateApprovedAmount(triggerNew[i])) {
                triggerNew[i].addError(System.Label.Total_Region_Funds_Approved_Cannot_Be_Negative_OR_Zero);
                return true;
            }

            if (!validateTotalAllocatedAmount(triggerNew[i])) {
                triggerNew[i].addError(triggerNew[i].Name + ': ' + System.Label.Total_Budget_Allocated_Amount_Cannot_Be_Higher_Than_Funds_Approved_Amount);
                return true;
            }

            if (!validateStartDate(triggerOld[i], triggerNew[i])) {
                triggerNew[i].addError(System.Label.Start_Date_Cannot_Be_Prior_Than_Current_Year);
                return true;
            }

            if (!validateEndDate(triggerNew[i])) {
                triggerNew[i].addError(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date);
                return true;
            }
            if (!validateAssignedToUserRole(triggerNew[i])) {
                triggerNew[i].addError(System.Label.Budget_Invalid_Assigned_To_User);
                return true;
            }
            if (!validateDatesWithinParent(triggerNew[i])) {
                triggerNew[i].addError(System.Label.Invalid_Year);
                return true;
            }
            if (!validateInactiveBudget(triggerOld[i], triggerNew[i])) {
                triggerNew[i].addError(System.Label.Cannot_activate_inactive_budget);
                return true;
            }
            if (!validateIfInactiveBudgetEdited(triggerOld[i])) {
                triggerNew[i].addError(System.Label.Budget_editing_inactive_budget);
                return true;
            }
            if (!validateIfDatesBetweenDatesOfRegionBudget(triggerNew[i])) {
                triggerNew[i].addError(System.Label.Budget_Start_End_dates_must_be_between_parent_budget_Dates);
                return true;
            }
        }
        return false;
    }

    private static Boolean validateInactiveBudget(EMS_Budget_Region_gne__c oldValue, EMS_Budget_Region_gne__c newValue) {
        if (oldValue.Status_gne__c == 'Inactive' && newValue.Status_gne__c != 'Inactive') {
            return false;
        } else {
            return true;
        }
    }

    private static void fetchAllowedOwners() {
        for (EMS_Cost_Center_Type_gne__c costCenterType : [SELECT Name, Allowed_Owners_gne__c FROM EMS_Cost_Center_Type_gne__c]) {
            if (!allowedOwners.containsKey(costCenterType.Name) && !String.isEmpty(costCenterType.Allowed_Owners_gne__c)) {
                allowedOwners.put(costCenterType.Name, new Set<String>(costCenterType.Allowed_Owners_gne__c.split(';')));
            }
        }
    }

    private static void fetchProductBudgets(List<EMS_Budget_Region_gne__c> triggerNew) {
        Set<Id> productBudgetIds = new Set<Id>();
        for (EMS_Budget_Region_gne__c regionBudget : triggerNew) {
            productBudgetIds.add(regionBudget.EMS_Budget_Product_gne__c);
        }
        productBudgets = new Map<Id, EMS_Budget_Product_gne__c>([SELECT Id, Year_gne__c, Start_Date_gne__c, End_Date_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgetIds]);
    }

    private static Set<String> fetchAvailableTerritoryNames(List<EMS_Budget_Region_gne__c> triggerNew) {
        Set<String> territories = new Set<String>();
        for (EMS_Budget_Region_gne__c region : triggerNew) {
            if (!territories.contains(region.Assigned_To_Territory_gne__c)) {
                territories.add(region.Assigned_To_Territory_gne__c);
            }
        }

        territories.clear();
        Map<String, EMS_Util.EMS_Territory> availableTerritories = EMS_Util.getTerritoriesByNames(territories);
        for (EMS_Util.EMS_Territory terr : availableTerritories.values()) {
            if (!territories.contains(terr.Name)) {
                territories.add(terr.Name);
            }
        }
        return territories;
    }

    private static List<EMS_Budget_Region_gne__c> fetchChildrenForRegionBudget(Set<Id> regionIds) {
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>([SELECT Id, (SELECT Id FROM EMS_Territory_Budgets__r WHERE IsDeleted = FALSE) FROM EMS_Budget_Region_gne__c WHERE Id IN:regionIds]);
        return regionBudgets;
    }

    private static Boolean validateApprovedAmount(EMS_Budget_Region_gne__c record) {
        return record.Total_Region_Funds_Approved_gne__c >= 0;
    }

    private static Boolean validateTotalAllocatedAmount(EMS_Budget_Region_gne__c record) {
        return record.Total_Region_Funds_Approved_gne__c >= record.Child_Budgets_Allocated_Amount_gne__c;
    }

    private static Boolean validateStartDate(EMS_Budget_Region_gne__c oldValue, EMS_Budget_Region_gne__c newValue) {
        if (oldValue == null || oldValue.Start_Date_gne__c != newValue.Start_Date_gne__c) {
            return newValue.Start_Date_gne__c == null ? false : newValue.Start_Date_gne__c.year() >= Date.today().year();
        } else {
            return true;
        }
    }

    private static Boolean validateEndDate(EMS_Budget_Region_gne__c record) {
        return record.Start_Date_gne__c <= record.End_Date_gne__c;
    }

    private static Boolean validateAssignedToUserRole(EMS_Budget_Region_gne__c record) {
        String userRoleFromSR = usersRolesFromSR.get(record.Assigned_to_gne__c);
        Set<String> typeAllowedOwners = allowedOwners.get(record.Cost_Center_Type_gne__c);

        for (String permissionSet : usersPermissions.get(record.Assigned_to_gne__c)) {
            // Cost Center Type does contains Permission Set definition which might not reflect role in
            if(typeAllowedOwners.contains(permissionSet)) {
                return allowedRoles.contains(userRoleFromSR);
            }
        }

        // else apply standard field validation
        return allowedRoles.contains(userRoleFromSR) && typeAllowedOwners.contains(userRoleFromSR);
    }

    private static Boolean validateDatesWithinParent(EMS_Budget_Region_gne__c record) {
        EMS_Budget_Product_gne__c parent = productBudgets.get(record.EMS_Budget_Product_gne__c);
        return parent.Start_Date_gne__c <= record.Start_Date_gne__c && record.End_Date_gne__c <= parent.End_Date_gne__c;
    }

    private static Boolean validateIfInactiveBudgetEdited(EMS_Budget_Region_gne__c recordOld) {
        return !(recordOld.Status_gne__c == 'Inactive');
    }

    private static Boolean validateIfDatesBetweenDatesOfRegionBudget(EMS_Budget_Region_gne__c budgetRecord) {
        return !(budgetRecord.Start_Date_gne__c < productBudgets.get(budgetRecord.EMS_Budget_Product_gne__c).Start_Date_gne__c ||
                budgetRecord.End_Date_gne__c > productBudgets.get(budgetRecord.EMS_Budget_Product_gne__c).End_Date_gne__c);
    }

    private static List<EMS_Budget_Allocation_gne__c> fetchBudgetAllocations(Set<Id> budgetIds) {
        return [
                SELECT Id, EMS_Territory_Budget_gne__c, EMS_Region_Budget_gne__c, EMS_Product_Budget_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE EMS_Territory_Budget_gne__c IN :budgetIds
                OR EMS_Region_Budget_gne__c IN :budgetIds
                OR EMS_Product_Budget_gne__c IN :budgetIds
        ];
    }
}