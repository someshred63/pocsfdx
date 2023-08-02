public without sharing class GNE_FRM_Rep2Territory_Scheduler implements Schedulable{
    public GNE_FRM_Rep2Territory_Scheduler(){}
    
    public void execute(SchedulableContext sc){
        GNE_FRM_Rep2Territory_Create_Batch createBatch = new GNE_FRM_Rep2Territory_Create_Batch();
        Database.executeBatch(createBatch);
        GNE_FRM_Rep2Territory_Clean_Batch cleanBatch = new GNE_FRM_Rep2Territory_Clean_Batch();
        Database.executeBatch(cleanBatch);
    }
}