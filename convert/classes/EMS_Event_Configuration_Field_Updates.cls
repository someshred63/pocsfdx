public without sharing class EMS_Event_Configuration_Field_Updates {

    private static void generateExternalId(List<EMS_Event_Configuration_gne__c> triggerNew) {
        for (EMS_Event_Configuration_gne__c eventConfig : triggerNew) {
            eventConfig.External_Id_gne__c = eventConfig.Event_Type_gne__c + '_' + eventConfig.Event_Sub_Type_gne__c;
        }
    }

    public static void onBeforeInsertUpdate(List<EMS_Event_Configuration_gne__c> triggerNew) {
        generateExternalId(triggerNew);
    }
}