global class EMS_Region_Budget_Assign_Batch_Sch implements Schedulable {
    global void execute(SchedulableContext SC) {
        EMS_Region_Budget_Assignment_Batch regionBudgetAssignmentBatch = new EMS_Region_Budget_Assignment_Batch();
        Database.executeBatch(regionBudgetAssignmentBatch);
    }
}