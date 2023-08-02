public with sharing class EMS_Roche_Attendee_Email_Notifications {
    private static void notifyWatchers(List<EMS_Roche_Attendee_gne__c> triggerNew) {
        for (EMS_Roche_Attendee_gne__c attendee :triggerNew) {
            if (attendee.Is_Watcher_gne__c) {
                EMS_Email.prepareSingleEmail('EMS_Event_Watcher_Added_Notification', attendee.Id, attendee.User_gne__c);
            }
        }
    }

    public static void onAfterInsert(List<EMS_Roche_Attendee_gne__c> triggerNew) {
        notifyWatchers(triggerNew);

        EMS_Email.send();
    }
}