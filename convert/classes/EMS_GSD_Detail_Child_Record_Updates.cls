public with sharing class EMS_GSD_Detail_Child_Record_Updates {
    public static Boolean skipTrigger = false;

    private static void updateHCPHCONameOnEvent(List<EMS_GSD_Detail__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_GSD_Detail__c gsdDetail : triggerNew) {
            eventIds.add(gsdDetail.EMS_Event__c);
        }
        Map<Id, EMS_Event__c> events = new Map<Id, EMS_Event__c>([SELECT Id, HCP_HCO_Name_gne__c FROM EMS_Event__c WHERE Id IN :eventIds]);
        List<EMS_Event__c> eventsToUpdate = new List<EMS_Event__c>();
        for (EMS_GSD_Detail__c gsdDetail : triggerNew) {
            EMS_Event__c event = events.get(gsdDetail.EMS_Event__c);

            if(event.HCP_HCO_Name_gne__c != gsdDetail.HCP_HCO_Name__c) {
                event.HCP_HCO_Name_gne__c = gsdDetail.HCP_HCO_Name__c;
                eventsToUpdate.add(event);
            }
        }

        Boolean eventValidationRules = EMS_Event_Trigger_Helper.skipTriggerValidationRules;
        if (!eventsToUpdate.isEmpty()) {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            update eventsToUpdate;
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = eventValidationRules;
        }
    }

    public static void onAfterInsertUpdate(List<EMS_GSD_Detail__c> triggerNew) {
        updateHCPHCONameOnEvent(triggerNew);
    }
}