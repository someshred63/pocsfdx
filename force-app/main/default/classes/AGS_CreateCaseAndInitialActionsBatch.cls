public class AGS_CreateCaseAndInitialActionsBatch extends AGS_AbstractCaseBatch {
    
    public AGS_CreateCaseAndInitialActionsBatch() {
        this(
            'SELECT Name, AGS_PC_MDM_ID_gne__c, AGS_PC_Rule_ID_gne__c, AGS_PC_Key_gne__c ' +
            'FROM AGS_Provisional_Case_gne__c WHERE AGS_CaseCreation_Status_gne__c = \'Unprocessed\''
        );
    }
    
    public AGS_CreateCaseAndInitialActionsBatch(final String query) {
        super('AGS_UserActivationSchedule', 'AGS User Activation', query);
    }
    
    public override void execute(final Database.BatchableContext ctx, final List<sObject> scope) {
        new AGS_CreateCaseAndInitialActions(ctx.getJobId()).createCase((AGS_Provisional_Case_gne__c[]) scope);
    }
    
    public override DateTime getNextJobScheduledRun() {
        return new AGS_ProvisionalCaseCreationBatch().getNextJobScheduledRun();
    }
}