global class GNE_SFA2_AffiliationSubscribe_Scheduler implements Schedulable, GNE_SFA2_Scheduler.Schedulable {

    global void execute(SchedulableContext SC) {
        CORE_Subscribe_Affiliation_Process affiliationBatch = new CORE_Subscribe_Affiliation_Process();
        GNE_Batch_Runner.executeBatch(affiliationBatch, CORE_Subscribe_Affiliation_Process.class, 100);
    }

    public System.Type getSelfClass() {
        return CORE_Subscribe_Affiliation_Process.class;
    }

    public void execute(GNE_SFA2_Scheduler.SchedulableContext sc) {
        execute((SchedulableContext)null);
    }
}