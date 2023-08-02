public without sharing class EMS_Cost_Center_Child_Record_Updates {

    public static void updateRelatedBudgetAllocations(List<EMS_Cost_Center_gne__c> triggerOld, Map<Id, EMS_Cost_Center_gne__c> triggerNew) {
        Set<String> costCenterNames = new Set<String>();
        Map<String, EMS_Cost_Center_gne__c> costCenters = new Map<String, EMS_Cost_Center_gne__c>();

        for (EMS_Cost_Center_gne__c cc : triggerOld) {
            costCenterNames.add(cc.Name);
            costCenters.put(cc.Name, triggerNew.get(cc.Id));
        }

        // select related budget allocations
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = [SELECT Cost_Center_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Cost_Center_gne__c IN :costCenterNames];

        for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
            ba.Product_Indication_gne__c = costCenters.get(ba.Cost_Center_gne__c).Product_Indication_Department_gne__c;
            ba.Cost_Center_Type_gne__c = costCenters.get(ba.Cost_Center_gne__c).Cost_Center_Type_gne__c;
            ba.Cost_Center_gne__c = costCenters.get(ba.Cost_Center_gne__c).Name;
        }

        update budgetAllocations;
    }

    public static void onAfterUpdate(List<EMS_Cost_Center_gne__c> triggerOld, Map<Id, EMS_Cost_Center_gne__c> triggerNew) {
        updateRelatedBudgetAllocations(triggerOld, triggerNew);
    }
}