public without sharing class EMS_Budget_Product_Validation_Rules {

    private static Set<String> availableTerritoryNames;
    private static Map<Id, String> usersRolesFromSR = EMS_Util.getUsersRolesFromSR();
    private static Map<String, Set<String>> allowedOwners = new Map<String, Set<String>>();
    private static Map<Id, Set<String>> usersPermissions = new Map<Id, Set<String>>();
    public static final Set<String> allowedRoles = new Set<String>{
            'PM', 'MM', 'AP', 'RAMA', 'Admin', 'AARC'
    };

    /**************************************************************************
    ********************* Methods called by trigger ***************************
    *************************************************************************/

    public static Boolean onBeforeInsert(List<EMS_Budget_Product_gne__c > triggerNew) {
        if (EMS_Product_Budget_Helper.skipTriggerValidationRules == false) {
            availableTerritoryNames = fetchAvailableTerritoryNames(triggerNew);
            usersPermissions = EMS_Util.fetchBudgetUsersPermissions(triggerNew);
            fetchAllowedOwners();
            return runOnBeforeInsert(triggerNew);
        } else {
            return false;
        }
    }

    public static Boolean onBeforeUpdate(List<EMS_Budget_Product_gne__c> triggerOld, List<EMS_Budget_Product_gne__c> triggerNew) {
        if (EMS_Product_Budget_Helper.skipTriggerValidationRules == false) {
            availableTerritoryNames = fetchAvailableTerritoryNames(triggerNew);
            usersPermissions = EMS_Util.fetchBudgetUsersPermissions(triggerNew);
            fetchAllowedOwners();
            return runOnBeforeUpdate(triggerOld, triggerNew);
        } else {
            return false;
        }
    }

    public static Boolean onBeforeDelete(Map<Id, EMS_Budget_Product_gne__c > triggerOldMap) {
        Boolean error = false;
        if (EMS_Product_Budget_Helper.skipTriggerValidationRules == false) {
            List<EMS_Budget_Product_gne__c> childrenForProductBudget = fetchChildrenForProductBudget(triggerOldMap.keySet());
            for (EMS_Budget_Product_gne__c budgetProduct : childrenForProductBudget) {
                if (budgetProduct.EMS_Region_Budgets_gne__r != null && budgetProduct.EMS_Region_Budgets_gne__r.size() > 0) {
                    triggerOldMap.get(budgetProduct.Id).addError(System.Label.Remove_Related_Records);
                    error = true;
                }
            }

            List<EMS_Budget_Allocation_gne__c> budgetAllocations = fetchBudgetAllocations(triggerOldMap.keySet());
            for(EMS_Budget_Allocation_gne__c allocation : budgetAllocations) {
                triggerOldMap.get(allocation.EMS_Product_Budget_gne__c).addError('Unable to delete budget due to existing Budget Allocations');
                error = true;
            }
        }
        return error;
    }

    public static Boolean runOnBeforeInsert(List<EMS_Budget_Product_gne__c > triggerNew) {
        for (EMS_Budget_Product_gne__c budgetProduct : triggerNew) {
            if (!validateAssignedToTerritoryName(budgetProduct)) {
                budgetProduct.addError(System.Label.No_Territory_named + ' ' + budgetProduct.Assigned_To_Territory_gne__c);
                return true;
            }

            if (!validateTotalApprovedAmount(budgetProduct)) {
                budgetProduct.addError(System.Label.Total_Product_Funds_Approved_Cannot_Be_Negative_OR_Zero);
                return true;
            }

            if (!validateTotalAllocatedAmount(budgetProduct)) {
                budgetProduct.addError(budgetProduct.Name + ': ' + System.Label.Total_Budget_Allocated_Amount_Cannot_Be_Higher_Than_Funds_Approved_Amount);
                return true;
            }

            if (!validateStartDate(null, budgetProduct)) {
                budgetProduct.addError(System.Label.Start_Date_Cannot_Be_Prior_Than_Current_Year);
                return true;
            }

            if (!validateEndDate(budgetProduct)) {
                budgetProduct.addError(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date);
                return true;
            }
            if (!validateAssignedToUserRole(budgetProduct)) {
                budgetProduct.addError(System.Label.Budget_Invalid_Assigned_To_User);
                return true;
            }
            if (!validateIfStartYearIsPriorToEndDate(budgetProduct)) {
                budgetProduct.addError(System.Label.Budget_Start_End_Dates_in_different_calendar_year);
                return true;
            }
        }
        return false;
    }

    public static Boolean runOnBeforeUpdate(List<EMS_Budget_Product_gne__c> triggerOld, List<EMS_Budget_Product_gne__c> triggerNew) {
        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (!validateAssignedToTerritoryName(triggerNew[i])) {
                triggerNew[i].addError(System.Label.No_Territory_named + ' ' + triggerNew[i].Assigned_To_Territory_gne__c);
                return true;
            }

            if (!validateTotalApprovedAmount(triggerNew[i])) {
                triggerNew[i].addError(System.Label.Total_Product_Funds_Approved_Cannot_Be_Negative_OR_Zero);
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
            if (!validateIfStartYearIsPriorToEndDate(triggerNew[i])) {
                triggerNew[i].addError(System.Label.Budget_Start_End_Dates_in_different_calendar_year);
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
        }
        return false;
    }

    /**************************************************************************
    **************************** Action methods *******************************
    **************************************************************************/

    private static Boolean validateAssignedToTerritoryName(EMS_Budget_Product_gne__c record) {
        return availableTerritoryNames.contains(record.Assigned_To_Territory_gne__c);
    }

    private static Boolean validateTotalApprovedAmount(EMS_Budget_Product_gne__c record) {
        return record.Total_Product_Funds_Approved_gne__c >= 0;
    }

    private static Boolean validateTotalAllocatedAmount(EMS_Budget_Product_gne__c record) {
        return record.Total_Product_Funds_Approved_gne__c >= record.Child_Budgets_Allocated_Amount_gne__c;
    }

    private static Boolean validateStartDate(EMS_Budget_Product_gne__c oldValue, EMS_Budget_Product_gne__c newValue) {
        if (oldValue == null || oldValue.Start_Date_gne__c != newValue.Start_Date_gne__c) {
            return newValue.Start_Date_gne__c == null ? false : newValue.Start_Date_gne__c.year() >= Date.today().year();
        } else {
            return true;
        }
    }

    private static Boolean validateEndDate(EMS_Budget_Product_gne__c record) {
        return record.Start_Date_gne__c <= record.End_Date_gne__c;
    }

    private static Boolean validateAssignedToUserRole(EMS_Budget_Product_gne__c record) {
        String userRoleFromSR = usersRolesFromSR.get(record.Assigned_to_gne__c);
        Set<String> typeAllowedOwners = allowedOwners.get(record.Cost_Center_Type_gne__c);

        for (String permissionSet : usersPermissions.get(record.Assigned_to_gne__c)) {
            // Cost Center Type does contains Permission Set definition which might not reflect role in
            if (typeAllowedOwners.contains(permissionSet)) {
                return allowedRoles.contains(userRoleFromSR);
            }
        }
        return allowedRoles.contains(userRoleFromSR) && typeAllowedOwners.contains(userRoleFromSR);
    }

    private static Boolean validateIfStartYearIsPriorToEndDate(EMS_Budget_Product_gne__c record) {
        return record.Start_Date_gne__c.year() <= record.End_Date_gne__c.year();
    }

    private static Boolean validateInactiveBudget(EMS_Budget_Product_gne__c oldValue, EMS_Budget_Product_gne__c newValue) {
        if (oldValue.Status_gne__c == 'Inactive' && newValue.Status_gne__c != 'Inactive') {
            return false;
        } else {
            return true;
        }
    }

    private static Boolean validateIfInactiveBudgetEdited(EMS_Budget_Product_gne__c recordOld) {
        return !(recordOld.Status_gne__c == 'Inactive');
    }

    /**************************************************************************
    **************************** Helper methods *******************************
    **************************************************************************/

    private static void fetchAllowedOwners() {
        for (EMS_Cost_Center_Type_gne__c costCenterType : [SELECT Name, Allowed_Owners_gne__c FROM EMS_Cost_Center_Type_gne__c]) {
            if (allowedOwners.get(costCenterType.Name) == null) {
                allowedOwners.put(costCenterType.Name, new Set<String>());
            }

            if (!String.isEmpty(costCenterType.Allowed_Owners_gne__c)) {
                allowedOwners.get(costCenterType.Name).addAll(costCenterType.Allowed_Owners_gne__c.split(';'));
            }
        }
    }

    private static Set<String> fetchAvailableTerritoryNames(List<EMS_Budget_Product_gne__c> triggerNew) {
        Set<String> territories = new Set<String>();
        for (EMS_Budget_Product_gne__c product : triggerNew) {
            if (!territories.contains(product.Assigned_To_Territory_gne__c)) {
                territories.add(product.Assigned_To_Territory_gne__c);
            }
        }

        Map<String, EMS_Util.EMS_Territory> availableTerritories = EMS_Util.getTerritoriesByNames(territories);
        territories.clear();

        for (EMS_Util.EMS_Territory terr : availableTerritories.values()) {
            if (!territories.contains(terr.Name)) {
                territories.add(terr.Name);
            }
        }
        return territories;
    }

    private static List<EMS_Budget_Product_gne__c> fetchChildrenForProductBudget(Set<Id> productIds) {
        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>([SELECT Id, (SELECT Id FROM EMS_Region_Budgets_gne__r WHERE IsDeleted = FALSE) FROM EMS_Budget_Product_gne__c WHERE Id IN:productIds]);
        return productBudgets;
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