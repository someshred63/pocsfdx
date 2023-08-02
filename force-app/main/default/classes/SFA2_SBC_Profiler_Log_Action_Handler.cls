public class SFA2_SBC_Profiler_Log_Action_Handler {
    public static void onAfterInsert() {
        SFA2_SBC_Profiler_Log_Action_Logic.sendAlertEmails((SFA2_SBC_Profiler_Log_Action_gne__c[])Trigger.new);
    }
}