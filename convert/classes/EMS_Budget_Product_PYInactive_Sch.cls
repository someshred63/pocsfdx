global class EMS_Budget_Product_PYInactive_Sch implements Schedulable {

    // Execute batch that changes all Product budgets from previous yer to inactive.
    global void execute(SchedulableContext SC) {
        EMS_Budget_Product_MakePYInactive_Batch makeLastYearProductBudgetsInactiveBatch = new EMS_Budget_Product_MakePYInactive_Batch();
        Database.executeBatch(makeLastYearProductBudgetsInactiveBatch);
    }

}