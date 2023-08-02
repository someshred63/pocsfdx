public without sharing class EMS_Attachment_Child_Record_Updates {

    private static Set<String> excludedStatuses = new Set<String>{
            'Signed Agreement Received', 'Closed'
    };

    public static void onAfterInsertUpdate(List<EMS_Attachment_gne__c> triggerOld, List<EMS_Attachment_gne__c> triggerNew) {
        Set<Id> idsToUpdate = new Set<Id>();

        for (EMS_Attachment_gne__c att : triggerNew) {
            if (att.Type_gne__c == 'Signed Contract') {
                idsToUpdate.add(att.EMS_Event_gne__c);
            }
        }

        List<EMS_Event__c> eventsToUpdate = new List<EMS_Event__c>();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :idsToUpdate]) {
            if (!excludedStatuses.contains(event.Status_gne__c)) {
                event.Status_gne__c = 'Signed Agreement Received';
                eventsToUpdate.add(event);
            }
        }

        if (!eventsToUpdate.isEmpty()) {
            update eventsToUpdate;
        }
    }
}