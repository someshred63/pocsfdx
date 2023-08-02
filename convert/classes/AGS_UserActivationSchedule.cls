public class AGS_UserActivationSchedule extends AGS_AbstractCaseSchedule implements Schedulable {
    
    public AGS_UserActivationSchedule() {
        super('AGS_UserActivationCaseActionsAssingment');
    }
    
    protected override Boolean isBatchExecutable() {
        final AGS_User_Activation_Finish_gne__c[] settings = AGS_User_Activation_Finish_gne__c.getAll().values();
        return super.isBatchExecutable() && (settings.isEmpty() || settings[0].Status_gne__c == 'Process');
    }
}