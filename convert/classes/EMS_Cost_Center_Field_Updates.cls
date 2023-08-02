public without sharing class EMS_Cost_Center_Field_Updates {

    private static void generateExternalId(List<EMS_Cost_Center_gne__c> triggerNew) {
        for (EMS_Cost_Center_gne__c cc : triggerNew) {
            cc.Cost_Center_External_ID_gne__c = cc.Name;
        }
    }

    public static void onBeforeInsertUpdate(List<EMS_Cost_Center_gne__c> triggerNew) {
        generateExternalId(triggerNew);
    }
}