public without sharing class EMS_Fund_Request_Trigger_Helper {

    public static boolean inFundRequestTrigger = false;
    public static boolean skipTriggerValidationRules = false;

    private static Set<Id> alreadyProcessedSet = new Set<Id>();
    private static Map<String, Id> emailTemplatesMap;

    public static boolean isAlreadyProcessed(Id fundRequestId) {
        return alreadyProcessedSet.contains(fundRequestId);
    }

    public static void addToProcessed(Id fundRequestId) {
        alreadyProcessedSet.add(fundRequestId);
    }

    public static void clearProcessedSet() {
        alreadyProcessedSet.clear();
    }
}