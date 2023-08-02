/*This batch should be exectuted only once per year at 00:00:00 1st of January. It's closing all opened events from previous year (with end date from previous year) */
global without sharing class EMS_Event_Close_Batch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date currentDate = System.now().date();
        return Database.getQueryLocator('SELECT Id, Status_gne__c, Is_GSD_Event_gne__c, Event_Type_gne__c, Event_Sub_type_gne__c, Is_Planned_gne__c FROM EMS_Event__c WHERE End_Date_gne__c < :currentDate AND Status_gne__c not in (\'Closed\', \'Cancelled\')');
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Set<Id> eventsIds = new Set<Id>();
        for (EMS_Event__c event : (List<EMS_Event__c>) scope) {
            eventsIds.add(event.Id);
        }
        List<Id> workItemIds = new List<Id>();
        for (ProcessInstanceWorkitem workItem : [SELECT p.Id FROM ProcessInstanceWorkitem p WHERE p.ProcessInstance.TargetObjectId IN :eventsIds]) {
            workItemIds.add(workItem.Id);
        }

        Set<String> eventTypes = new Set<String>{
                'Consulting', 'Consulting Meetings', 'Consultancy Meeting', 'Donation', 'Grants', 'Internal staff training', 'Preceptorships (HCP to Roche)', 'Learning Programs', 'Program', 'Programs', 'Non-promotional program', 'Sponsorship', 'Sponsorships'
        };

        Set<String> statusesToClose = new Set<String>{
                'Approved', 'Med Ops Approved', 'Signed Agreement Received', 'Awaiting Signature from HCP', 'Payment Request Initiated'
        };

        EMS_Util.rejectApprovals(workItemIds, 'Event was cancelled.');

        for (EMS_Event__c event : (List<EMS_Event__c>) scope) {
            if (event.Event_Type_gne__c == 'GD' && (event.Event_Sub_Type_gne__c.contains('Grant') || event.Event_Sub_Type_gne__c.contains('Donation'))) {
                if (statusesToClose.contains(event.Status_gne__c)) {
                    event.Status_gne__c = 'Closed';
                } else {
                    event.Status_gne__c = 'Cancelled';
                }
            } else if (eventTypes.contains(event.Event_Sub_Type_gne__c)) {
                if (statusesToClose.contains(event.Status_gne__c)) {
                    event.Status_gne__c = 'Closed';
                } else {
                    event.Status_gne__c = 'Cancelled';
                }
            }
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [SELECT Id FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        List<String> mails = EMS_Util.getApplicationAdminsEmails();

        EMS_Email.prepareSingleEmail('EMS_Batch_Job_Notification', a.Id, mails);

        EMS_Email.send();
    }

}