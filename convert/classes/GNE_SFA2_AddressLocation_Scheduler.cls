global class GNE_SFA2_AddressLocation_Scheduler implements Schedulable, GNE_SFA2_Scheduler.Schedulable {
    public GNE_SFA2_AddressLocation_Scheduler() {}
    
    global void execute(SchedulableContext SC) {
        GNE_SFA2_AddressLocation_Batch addressBatch = new GNE_SFA2_AddressLocation_Batch();
        GNE_Batch_Runner.executeBatch(addressBatch, GNE_SFA2_AddressLocation_Batch.class, 5);
    }
    
    public System.Type getSelfClass() {
        return GNE_SFA2_AddressLocation_Scheduler.class;
    }
    
    public void execute(GNE_SFA2_Scheduler.SchedulableContext sc) {
        execute((SchedulableContext)null);
    }
}