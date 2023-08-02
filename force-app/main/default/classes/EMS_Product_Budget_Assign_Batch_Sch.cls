global class EMS_Product_Budget_Assign_Batch_Sch implements Schedulable {
    global void execute(SchedulableContext SC) {
        EMS_Product_Budget_Assignment_Batch productBudgetAssignmentBatch = new EMS_Product_Budget_Assignment_Batch();
        Database.executeBatch(productBudgetAssignmentBatch);
    }
}