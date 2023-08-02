public class AGS_CreateCaseAndIniActionsSchedulable extends AGS_AbstractCaseSchedule implements Schedulable {
    
    public AGS_CreateCaseAndIniActionsSchedulable() {
        super('AGS_CreateCaseAndInitialActionsBatch', 1);
    }
    
    protected override Boolean isBatchExecutable() {
        return super.isBatchExecutable() && (Test.isRunningTest() || System.now().hour() < 19);
    }
    
    public override void execute(final SchedulableContext ctx) {
        final AGS_User_Activation_Finish_gne__c[] settings = AGS_User_Activation_Finish_gne__c.getAll().values();
        upsert new AGS_User_Activation_Finish_gne__c(
            Name = settings.isEmpty() ? '0' : settings[0].Name,
            Id = settings.isEmpty() ? null : settings[0].Id,
            Status_gne__c = 'Process'
        );
        super.execute(ctx);
    }
}