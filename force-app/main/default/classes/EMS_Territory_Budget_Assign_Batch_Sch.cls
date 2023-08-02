global class EMS_Territory_Budget_Assign_Batch_Sch implements Schedulable {
    global void execute(SchedulableContext SC) {
        EMS_Territory_Budget_Assignment_Batch territoryBudgetAssignmentBatch = new EMS_Territory_Budget_Assignment_Batch();
        Database.executeBatch(territoryBudgetAssignmentBatch);
    }
}