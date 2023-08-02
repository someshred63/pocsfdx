public class GNE_FRM_Sync_Records_MDM_Scheduler implements Schedulable{
    public GNE_FRM_Sync_Records_MDM_Scheduler (){}
    
    public void execute(SchedulableContext sc) {
        GNE_FRM_Sync_Records_With_MDM_Batch batch = new GNE_FRM_Sync_Records_With_MDM_Batch();
        Database.executeBatch(batch, 1);
    }
}