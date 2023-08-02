global class GNE_SFA2_AccountToTerritory_Scheduler implements Schedulable, GNE_SFA2_Scheduler.Schedulable {

    global void execute(SchedulableContext SC) {
        GNE_Subscribe_Batch_Preprocessing alignmentBatch = new GNE_Subscribe_Batch_Preprocessing(true, true);
        GNE_Batch_Runner.executeBatch(alignmentBatch, GNE_Subscribe_Batch_Preprocessing.class, 10);
    }

    public System.Type getSelfClass() {
        return GNE_Subscribe_Batch_Preprocessing.class;
    }

    public void execute(GNE_SFA2_Scheduler.SchedulableContext sc) {
        execute((SchedulableContext) null);
    }

}