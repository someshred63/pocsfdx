global class AGS_ST_DM_StatusNotificationBatch_gne implements Database.Batchable<sObject>, Database.Stateful {
    global List<AGS_ST_DisputeManagement_gne__c> disputes;
    global Integer MAX_DAY_NUMBER = 3;
    global Datetime now;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        disputes = new List<AGS_ST_DisputeManagement_gne__c>();
        now = System.now();
        return Database.getQueryLocator([
            SELECT  Id, Name, Owner.Name, Dispute_Resolver_gne__r.Owner.Name, CreatedDate,
                (SELECT OldValue, NewValue, CreatedDate
                FROM    Histories
                WHERE   Field = 'Internal_Status_gne__c'
                ORDER BY CreatedDate DESC
                LIMIT 1)
            FROM    AGS_ST_DisputeManagement_gne__c
            WHERE   Internal_Status_gne__c = 'Corrected Pending SSR'
            ORDER BY CreatedDate
        ]);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        for(AGS_ST_DisputeManagement_gne__c d : (List<AGS_ST_DisputeManagement_gne__c>)scope) {
            Boolean isDisputeEditedMoreThanMaxDaysAgo = d.Histories.isEmpty() && ( now > d.CreatedDate.addDays(MAX_DAY_NUMBER) );
            Boolean isDisputeStatusChangedMoreThanMaxDaysAgo = !d.Histories.isEmpty() && ( now > d.Histories[0].CreatedDate.addDays(MAX_DAY_NUMBER) );
            if(isDisputeEditedMoreThanMaxDaysAgo || isDisputeStatusChangedMoreThanMaxDaysAgo) {
                disputes.add(d);
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        AGS_ST_MailUtil.sendEmailWithCorrectedPendingSsrDisputes(disputes);
    }
}