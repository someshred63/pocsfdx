@isTest
private class EMS_Budget_Allocation_Email_Notif_Test {

	/**
	 * 1. notifyBudgetOwner
	 */

    private static Integer BATCH_SIZE = 10;
    private static Decimal plannedExpenses = 10;

    //1.1 notifyBudgetOwner
    private static testMethod void updateRecordType_productBudget_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers.get(0), 'Commercial Product', BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers[0], 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();
        Integer emailbefore = Limits.getEmailInvocations();
        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        System.assertNotEquals(emailbefore, Limits.getEmailInvocations(), 'should have decreased');
        Test.stopTest();
    }
}