global class GNE_CRM_CollabGrpMembAssigner_Scheduler implements Schedulable {

    global void execute(SchedulableContext sc) {
        GNE_CRM_CollabGrpMembAssigner_Batch collabGrpAssigner = new GNE_CRM_CollabGrpMembAssigner_Batch();
        Database.executeBatch(collabGrpAssigner);
    }
}