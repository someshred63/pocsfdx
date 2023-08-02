public with sharing class EMS_Budget_Allocation_Trigger_Helper {

    public static Boolean skipTriggerValidationRules = FALSE;

    private static Set<Id> alreadyProcessedSet = new Set<Id>();

    public static boolean isAlreadyProcessed(Id budgetAllocaionId) {
        return alreadyProcessedSet.contains(budgetAllocaionId);
    }

    public static void addToProcessed(Id budgetAllocaionId) {
        alreadyProcessedSet.add(budgetAllocaionId);
    }

    public static void addToProcessed(List<EMS_Budget_Allocation_gne__c> budgetAllocaions) {
        for (EMS_Budget_Allocation_gne__c budgetAllocaion : budgetAllocaions) {
            alreadyProcessedSet.add(budgetAllocaion.Id);
        }
    }

    public static void clearProcessedSet() {
        alreadyProcessedSet.clear();
    }

}