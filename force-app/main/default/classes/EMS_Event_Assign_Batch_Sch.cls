global class EMS_Event_Assign_Batch_Sch implements Schedulable {
    global void execute(SchedulableContext SC) {
        EMS_Event_Assignment_Batch eventAssignmentBatch = new EMS_Event_Assignment_Batch();
        Database.executeBatch(eventAssignmentBatch, 50);
    }
}