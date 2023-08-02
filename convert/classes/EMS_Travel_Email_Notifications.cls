public without sharing class EMS_Travel_Email_Notifications {

    public static void onAfterInsert(List<EMS_Travel_gne__c> triggerNew) {
        notifyEventRequestorAboutNewTravelSubmission(triggerNew);

        EMS_Email.send();
    }

    private static void notifyEventRequestorAboutNewTravelSubmission(List<EMS_Travel_gne__c> triggerNew) {
        List<EMS_Travel_gne__c> travels = [SELECT EMS_Event_gne__c, EMS_Event_gne__r.Event_Requestor_gne__c FROM EMS_Travel_gne__c WHERE Id IN :triggerNew];
        for (EMS_Travel_gne__c travel :travels) {
            EMS_Email.prepareSingleEmail('EMS_Travel_Submission_Notification', travel.Id, travel.EMS_Event_gne__r.Event_Requestor_gne__c);
        }
    }
}