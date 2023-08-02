global class GNE_SFA2_RepToTerritory_Scheduler implements Schedulable, GNE_SFA2_Scheduler.Schedulable {
    
    global void execute(SchedulableContext SC) {
        GNE_UserToTerritoryAssignment_Batch assignmentBatch = new GNE_UserToTerritoryAssignment_Batch(false, UserInfo.getUserName());
        GNE_Batch_Runner.executeBatch(assignmentBatch, GNE_UserToTerritoryAssignment_Batch.class, 1);
    }
    
    public System.Type getSelfClass() {
        return GNE_UserToTerritoryAssignment_Batch.class;
    }
    
    public void execute(GNE_SFA2_Scheduler.SchedulableContext sc) {
        execute((SchedulableContext)null);
    }
}