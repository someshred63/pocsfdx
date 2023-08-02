public class AGS_Latency_NotificationBatch extends AGS_AbstractCaseBatch {
    
    public AGS_Latency_NotificationBatch() {
        this(
            'SELECT Name, CreatedDate, OwnerId, AGS_Case_gne__c, Latency_Status_gne__c, Latency_Reminder_Check_gne__c ' +
            'FROM AGS_Case_Action_gne__c WHERE Action_Status_gne__c = \'OPEN\' ' +
            'AND Latency_Status_gne__c != \'Escalated\' ' +
            'AND Action_Type_gne__c = \'Compliance Task\''
        );
    }
    
    public AGS_Latency_NotificationBatch(final String query) {
        super('AGS_INF_Deactivation_Schedulable', 'AGS INFU Deactivation', query);
    }
    
    public override void execute(final Database.BatchableContext ctx, final List<sObject> caseActions) {
        new AGS_Latency_NotificationProcess(ctx.getJobId()).processNotification((AGS_Case_Action_gne__c[]) caseActions);
    }
}