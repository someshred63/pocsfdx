public without sharing class EMS_Budget_Territory_Validation_Rules {

    private static Map<Id, EMS_Budget_Region_gne__c> regionBudgets = new Map<Id, EMS_Budget_Region_gne__c>();
    private static Map<Id, String> usersRolesFromSR = EMS_Util.getUsersRolesFromSR();
    private static Map<String, Set<String>> allowedOwners = new Map<String, Set<String>>();
    private static Map<Id, Set<String>> usersPermissions = new Map<Id, Set<String>>();
    public static final Set<String> allowedRoles = new Set<String>{
            'Rep', 'RSM'
    };

    public static Boolean onBeforeInsert(List<EMS_Budget_Territory_gne__c> triggerNew) {
        fetchAllowedOwners();
        fetchRegionBudgets(triggerNew);
        usersPermissions = EMS_Util.fetchBudgetUsersPermissions(triggerNew);

        if (EMS_Territory_Budget_Helper.skipTriggerValidationRules == false) {
            for (EMS_Budget_Territory_gne__c budgetTerritory : triggerNew) {

                if (!validateApprovedAmount(budgetTerritory)) {
                    budgetTerritory.addError(System.Label.Total_Territory_Funds_Approved_Cannot_Be_Negative_OR_Zero);
                    return true;
                }

                if (!validateStartDate(null, budgetTerritory)) {
                    budgetTerritory.addError(System.Label.Start_Date_Cannot_Be_Prior_Than_Current_Year);
                    return true;
                }

                if (!validateEndDate(budgetTerritory)) {
                    budgetTerritory.addError(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date);
                    return true;
                }
                if (!validateAssignedToUserRole(budgetTerritory)) {
                    budgetTerritory.addError(System.Label.Budget_Invalid_Assigned_To_User);
                    return true;
                }
                if (!validateDatesWithinParent(budgetTerritory)) {
                    budgetTerritory.addError(System.Label.Invalid_Year);
                    return true;
                }
                if (!validateIfDatesBetweenDatesOfRegionBudget(budgetTerritory)) {
                    budgetTerritory.addError(System.Label.Budget_Start_End_dates_must_be_between_parent_budget_Dates);
                    return true;
                }
            }
            return false;
        } else {
            return false;
        }
    }

    public static Boolean onBeforeUpdate(List<EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        fetchAllowedOwners();
        fetchRegionBudgets(triggerNew);
        usersPermissions = EMS_Util.fetchBudgetUsersPermissions(triggerNew);

        if (EMS_Territory_Budget_Helper.skipTriggerValidationRules == false) {
            for (Integer i = 0; i < triggerNew.size(); i++) {

                if (!validateApprovedAmount(triggerNew[i])) {
                    triggerNew[i].addError(System.Label.Total_Territory_Funds_Approved_Cannot_Be_Negative_OR_Zero);
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

        } else {
            return false;
        }
    }

    private static void fetchAllowedOwners() {
        for (EMS_Cost_Center_Type_gne__c costCenterType : [SELECT Name, Allowed_Owners_gne__c FROM EMS_Cost_Center_Type_gne__c]) {
            if (!allowedOwners.containsKey(costCenterType.Name) && !String.isEmpty(costCenterType.Allowed_Owners_gne__c)) {
                allowedOwners.put(costCenterType.Name, new Set<String>(costCenterType.Allowed_Owners_gne__c.split(';')));
            }
        }
    }

    private static void fetchRegionBudgets(List<EMS_Budget_Territory_gne__c> triggerNew) {
        Set<Id> regionBudgetIds = new Set<Id>();
        for (EMS_Budget_Territory_gne__c territoryBudget : triggerNew) {
            regionBudgetIds.add(territoryBudget.EMS_Budget_Region_gne__c);
        }
        regionBudgets = new Map<Id, EMS_Budget_Region_gne__c>([SELECT Id, Year_gne__c, Start_Date_gne__c, End_Date_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgetIds]);
    }

    /* Validation rules */

    private static Boolean validateInactiveBudget(EMS_Budget_Territory_gne__c oldValue, EMS_Budget_Territory_gne__c newValue) {
        if (oldValue.Status_gne__c == 'Inactive' && newValue.Status_gne__c != 'Inactive') {
            return false;
        } else {
            return true;
        }
    }

    private static Boolean validateApprovedAmount(EMS_Budget_Territory_gne__c record) {
        return record.Total_Territory_Funds_Approved_gne__c >= 0;
    }

    private static Boolean validateStartDate(EMS_Budget_Territory_gne__c oldValue, EMS_Budget_Territory_gne__c newValue) {
        if (oldValue == null || oldValue.Start_Date_gne__c != newValue.Start_Date_gne__c) {
            return newValue.Start_Date_gne__c == null ? false : newValue.Start_Date_gne__c.year() >= Date.today().year();
        } else {
            return true;
        }
    }

    private static Boolean validateEndDate(EMS_Budget_Territory_gne__c record) {
        return record.Start_Date_gne__c <= record.End_Date_gne__c;
    }

    private static Boolean validateAssignedToUserRole(EMS_Budget_Territory_gne__c record) {
        String userRoleFromSR = usersRolesFromSR.get(record.Assigned_to_gne__c);
        Set<String> typeAllowedOwners = allowedOwners.get(record.Cost_Center_Type_gne__c);

        for (String permissionSet : usersPermissions.get(record.Assigned_to_gne__c)) {
            // Cost Center Type does contains Permission Set definition which might not reflect role in
            if (typeAllowedOwners.contains(permissionSet)) {
                return allowedRoles.contains(userRoleFromSR);
            }
        }

        // else apply standard field validation
        return allowedRoles.contains(userRoleFromSR) && typeAllowedOwners.contains(userRoleFromSR);
    }

    private static Boolean validateDatesWithinParent(EMS_Budget_Territory_gne__c record) {
        EMS_Budget_Region_gne__c parent = regionBudgets.get(record.EMS_Budget_Region_gne__c);
        return parent.Start_Date_gne__c <= record.Start_Date_gne__c && record.End_Date_gne__c <= parent.End_Date_gne__c;
    }

    private static Boolean validateIfInactiveBudgetEdited(EMS_Budget_Territory_gne__c recordOld) {
        return !(recordOld.Status_gne__c == 'Inactive');
    }

    private static Boolean validateIfDatesBetweenDatesOfRegionBudget(EMS_Budget_Territory_gne__c budgetRecord) {
        return !(budgetRecord.Start_Date_gne__c < regionBudgets.get(budgetRecord.EMS_Budget_Region_gne__c).Start_Date_gne__c ||
                budgetRecord.End_Date_gne__c > regionBudgets.get(budgetRecord.EMS_Budget_Region_gne__c).End_Date_gne__c);
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