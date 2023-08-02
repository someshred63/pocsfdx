public without sharing class EMS_Budget_Territory_Field_Updates {
    private static void fetchCostCenters(List<EMS_Budget_Territory_gne__c> triggerNew) {
        Set<String> keys = new Set<String>();
        for (EMS_Budget_Territory_gne__c budget : triggerNew) {
            keys.add(budget.Cost_Center_gne__c);
        }

        EMS_Util.queryCostCenters(keys);
    }

    private static Map<Id, String> budgetOwners = new Map<Id, String>();
    private static void fetchBudgetOwners(List<EMS_Budget_Territory_gne__c> budgets) {
        Set<Id> userIds = new Set<Id>();
        for (EMS_Budget_Territory_gne__c b : budgets) {
            userIds.add(b.Assigned_to_gne__c);
        }

        budgetOwners.putAll(EMS_Util.queryBudgetOwners(userIds));
    }

    private static void updateTerritoryId(Map<Id, EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        Set<String> territoryNames = new Set<String>();
        List<EMS_Budget_Territory_gne__c> budgetsWithTerritoryUpdated = new List<EMS_Budget_Territory_gne__c>();

        for (Integer i = 0; i < triggerNew.size(); i++) {
            if (triggerOld == null || (triggerOld.get(triggerNew[i].Id).Assigned_To_Territory_gne__c != triggerNew[i].Assigned_To_Territory_gne__c)) {
                budgetsWithTerritoryUpdated.add(triggerNew[i]);
                territoryNames.add(triggerNew[i].Assigned_To_Territory_gne__c);
            }
        }

        if (budgetsWithTerritoryUpdated.isEmpty()) {
            return;
        }

        Map<String, EMS_Util.EMS_Territory> territoryNameToTerritory = EMS_Util.getTerritoriesByNames(territoryNames);
        for (EMS_Budget_Territory_gne__c territoryBudget : budgetsWithTerritoryUpdated) {
            if (territoryNameToTerritory.containsKey(territoryBudget.Assigned_To_Territory_gne__c)) {
                territoryBudget.Assigned_To_Territory_Id_gne__c = territoryNameToTerritory.get(territoryBudget.Assigned_To_Territory_gne__c).Id;
            }
        }
    }

    public static void updateName(List<EMS_Budget_Territory_gne__c> triggerNew) {
        for (EMS_Budget_Territory_gne__c tb : triggerNew) {
            tb.Name_gne__c = 'TB-' + tb.Year_gne__c + '-' + EMS_Util.getCostCenter(tb.Cost_Center_gne__c).Name + '-' + tb.Product_Indication_gne__c + '-' + tb.Assigned_To_Territory_gne__c + '-' + budgetOwners.get(tb.Assigned_to_gne__c);
        }
    }

    private static void updateRecordType(Map<Id, EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        List<EMS_Budget_Territory_gne__c> deactivatedBudgets = new List<EMS_Budget_Territory_gne__c>();
        List<EMS_Budget_Territory_gne__c> reactivatedBudgets = new List<EMS_Budget_Territory_gne__c>();
        for (EMS_Budget_Territory_gne__c newBudget : triggerNew) {
            if (triggerOld.get(newBudget.Id).Status_gne__c == 'Active' && newBudget.Status_gne__c == 'Inactive') {
                deactivatedBudgets.add(newBudget);
            }
            if (triggerOld.get(newBudget.Id).Status_gne__c == 'Inactive' && (newBudget.Status_gne__c == 'Active' || newBudget.Status_gne__c == 'Pending')) {
                reactivatedBudgets.add(newBudget);
            }
        }

        if (!deactivatedBudgets.isEmpty()) {
            RecordType budgetRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'EMS_Budget_Territory_gne__c' AND DeveloperName = 'EMS_Canada_Inactive_Territory_Budget_gne' LIMIT 1];
            for (EMS_Budget_Territory_gne__c budget : deactivatedBudgets) {
                budget.RecordTypeId = budgetRecordType.Id;
            }
        }

        if (!reactivatedBudgets.isEmpty()) {
            RecordType budgetRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'EMS_Budget_Territory_gne__c' AND DeveloperName = 'EMS_Canada_Territory_Budget_gne' LIMIT 1];
            for (EMS_Budget_Territory_gne__c budget : reactivatedBudgets) {
                budget.RecordTypeId = budgetRecordType.Id;
            }
        }
    }

    public static void onBeforeInsert(List<EMS_Budget_Territory_gne__c> triggerNew) {
        fetchBudgetOwners(triggerNew);
        fetchCostCenters(triggerNew);
        updateTerritoryId(null, triggerNew);
        updateName(triggerNew);
    }

    public static void onBeforeUpdate(Map<Id, EMS_Budget_Territory_gne__c> triggerOld, List<EMS_Budget_Territory_gne__c> triggerNew) {
        fetchBudgetOwners(triggerNew);
        fetchCostCenters(triggerNew);
        updateTerritoryId(triggerOld, triggerNew);
        updateName(triggerNew);
        updateRecordType(triggerOld, triggerNew);
    }
}