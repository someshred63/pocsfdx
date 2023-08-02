@isTest
private class EMS_Expense_Child_Record_Upd_Test {

    private static Integer BATCH_SIZE = 100;
    private static Integer EXPENSES_PER_EVENT = 2;

    @isTest
    static void increaseDecreaseTotalExpensesAmountOnInsertDeleteOneBudgetTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Test.startTest();

        List<EMS_Budget_Allocation_gne__c> budgetAllocations = EMS_Test_Util.createBudgetAllocations((Id) productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(events, 10.0, EXPENSES_PER_EVENT, costCenters[0]);
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            //System.assertEquals(10.0 * EXPENSES_PER_EVENT, ba.Budget_Deductions_gne__c);
        }
        delete expenses;

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            //System.assertEquals(0, ba.Budget_Deductions_gne__c);
        }

        undelete expenses;

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(10.0 * EXPENSES_PER_EVENT, ba.Budget_Deductions_gne__c);
        }
    }

    @isTest
    static void updateTotalExpensesAmountOnUpdateOneBudgetTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Test.startTest();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = EMS_Test_Util.createBudgetAllocations((Id) productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(events, 10.0, EXPENSES_PER_EVENT, costCenters[0]);

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            //System.assertEquals(10.0 * EXPENSES_PER_EVENT, ba.Budget_Deductions_gne__c);
        }

        for (EMS_Expense_gne__c expense : expenses) {
            expense.Country_Expense_Amount_gne__c = 20;
        }
        update expenses;

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(20.0 * EXPENSES_PER_EVENT, ba.Budget_Deductions_gne__c);
        }
    }

    @isTest
    static void updateTotalExpensesAmountOnParentChangeOneBudgetTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 100000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> eventsPack = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        Map<String, EMS_Event__c> events = new Map<String, EMS_Event__c>();
        Map<String, EMS_Event__c> events2 = new Map<String, EMS_Event__c>();
        for (Integer i = 0; i < eventsPack.size(); i++) {
            if (i < BATCH_SIZE / 2) {
                events.put(eventsPack[i].Id, eventsPack[i]);
            } else {
                events2.put(eventsPack[i].Id, eventsPack[i]);
            }
        }
        System.assert(events.size() == events2.size());

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        Test.startTest();
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsPack = EMS_Test_Util.createBudgetAllocations((Id) productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, eventsPack, pb.Id, null, null);
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations2 = new List<EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Allocation_gne__c baItem : budgetAllocationsPack) {
            if (events.containsKey(baItem.EMS_Event_gne__c)) {
                budgetAllocations.add(baItem);
            } else if (events2.containsKey(baItem.EMS_Event_gne__c)) {
                budgetAllocations2.add(baItem);
            }
        }
        List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(events.values(), 10.0, EXPENSES_PER_EVENT, costCenters[0]);

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            //System.assertEquals(10.0 * EXPENSES_PER_EVENT, ba.Budget_Deductions_gne__c);
        }

        for (Integer i = 0; i < expenses.size(); i++) {
            expenses[i].EMS_Event_gne__c = events2.values()[Math.mod(i, BATCH_SIZE / 2)].Id;
        }
        update expenses;

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(0, ba.Budget_Deductions_gne__c);
        }

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations2]) {
            System.assertEquals(10.0 * EXPENSES_PER_EVENT, ba.Budget_Deductions_gne__c);
        }
    }
/*
        @isTest
        static void increaseDecreaseTotalExpensesAmountOnInsertTwoBudgetsSameCCTest() {
                List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
                Id pmUser = ids[0];
                Id rsmUser = ids[1];
                System.assertNotEquals(null, pmUser);
                System.assertNotEquals(null, rsmUser);

                // select cost center
                List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

                // cerate budget for the user
                EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
                EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 100.0, rsmUser);

                EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
                RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];
                RecordType regionBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Region_Budget_Allocation' LIMIT 1 ];

                List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
                List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
                
                // product budget allocation
                for(EMS_Event__c event : events) {
                        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                                Allocated_Budget_gne__c = 100,
                                Budget_Owner_gne__c = pb.Assigned_to_gne__c,
                                EMS_Event_gne__c = event.Id,
                                RecordTypeId = (Id)productBudgetAllocationRT.Id,
                                EMS_Product_Budget_gne__c = pb.Id,
                                EMS_Region_Budget_gne__c = null,
                                EMS_Territory_Budget_gne__c = null
                        );
                        budgetAllocations.add(budgetAllocation);
                }
                // region budget allocation
                for(EMS_Event__c event : events) {
                        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                                Allocated_Budget_gne__c = 100,
                                Budget_Owner_gne__c = rb.Assigned_to_gne__c,
                                EMS_Event_gne__c = event.Id,
                                RecordTypeId = (Id)regionBudgetAllocationRT.Id,
                                EMS_Product_Budget_gne__c = null,
                                EMS_Region_Budget_gne__c = rb.Id,
                                EMS_Territory_Budget_gne__c = null
                        );
                        budgetAllocations.add(budgetAllocation);
                }
                

                Test.startTest();                
                insert budgetAllocations;
                List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(events, 10.0, EXPENSES_PER_EVENT, costCenters[0]); 
                for(EMS_Budget_Allocation_gne__c ba : [ SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]){
                        System.assertEquals((10.0 * EXPENSES_PER_EVENT) / 2, ba.Budget_Deductions_gne__c);
                }
                
                // here the SOQL 101
                //delete expenses;
                Test.stopTest();

                
                
                for(EMS_Budget_Allocation_gne__c ba : [ SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]){
                        System.assertEquals(0, ba.Budget_Deductions_gne__c);
                }
                undelete expenses;

                for(EMS_Budget_Allocation_gne__c ba : [ SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]){
                        System.assertEquals((10.0 * EXPENSES_PER_EVENT) / 2, ba.Budget_Deductions_gne__c);
                }
        }

        @isTest
        static void updateTotalExpensesAmountOnInsertTwoBudgetsSameCCTest() {
                List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
                Id pmUser = ids[0];
                Id rsmUser = ids[1];
                System.assertNotEquals(null, pmUser);
                System.assertNotEquals(null, rsmUser);

                // select cost center
                List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

                // cerate budget for the user
                EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
                EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, 100.0, rsmUser);

                EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
                RecordType productBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1 ];
                RecordType regionBudgetAllocationRT = [ SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Region_Budget_Allocation' LIMIT 1 ];

                List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
                
                List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();

                // product budget allocation
                for(EMS_Event__c event : events) {
                        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                                Allocated_Budget_gne__c = 100,
                                Budget_Owner_gne__c = pb.Assigned_to_gne__c,
                                EMS_Event_gne__c = event.Id,
                                RecordTypeId = (Id)productBudgetAllocationRT.Id,
                                EMS_Product_Budget_gne__c = pb.Id,
                                EMS_Region_Budget_gne__c = null,
                                EMS_Territory_Budget_gne__c = null
                        );
                        budgetAllocations.add(budgetAllocation);
                }
                // region budget allocation
                for(EMS_Event__c event : events) {
                        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                                Allocated_Budget_gne__c = 100,
                                Budget_Owner_gne__c = rb.Assigned_to_gne__c,
                                EMS_Event_gne__c = event.Id,
                                RecordTypeId = (Id)regionBudgetAllocationRT.Id,
                                EMS_Product_Budget_gne__c = null,
                                EMS_Region_Budget_gne__c = rb.Id,
                                EMS_Territory_Budget_gne__c = null
                        );
                        budgetAllocations.add(budgetAllocation);
                }

                Test.startTest();

                insert budgetAllocations;
                List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(events, 10.0, EXPENSES_PER_EVENT, costCenters[0]); 
                for(EMS_Budget_Allocation_gne__c ba : [ SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]){
                        System.assertEquals((10.0 * EXPENSES_PER_EVENT) / 2, ba.Budget_Deductions_gne__c);
                }

                for(EMS_Expense_gne__c expense : expenses) {
                        expense.Country_Expense_Amount_gne__c = 20;
                }
                // SOQL 101
                update expenses;
                Test.stopTest();

                for(EMS_Budget_Allocation_gne__c ba : [ SELECT Budget_Deductions_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]){
                        System.assertEquals((20.0 * EXPENSES_PER_EVENT) / 2, ba.Budget_Deductions_gne__c);
                }
        }
*/
    @isTest
    static void increaseDecreaseTotalExpensesAmountOnInsertTwoBudgetsOtherCCTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // Record Type
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 2, true);

        // cerate budget for the user
        List<EMS_Budget_Product_gne__c> pbList = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], costCenters);
        EMS_Budget_Product_gne__c pb = pbList[0];
        EMS_Budget_Product_gne__c pb2 = pbList[1];

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        List<EMS_Budget_Allocation_gne__c> budgetAllocationsPack = EMS_Test_Util.createBudgetAllocations((Id) productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pbList);
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations2 = new List<EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Allocation_gne__c baItem : budgetAllocationsPack) {
            if (baItem.EMS_Product_Budget_gne__c == pb.Id) {
                budgetAllocations.add(baItem);
            }
            if (baItem.EMS_Product_Budget_gne__c == pb2.Id) {
                budgetAllocations2.add(baItem);
            }
        }
        System.assert(budgetAllocations.size() == budgetAllocations2.size());

        Test.startTest();
        List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(events, 10.0, EXPENSES_PER_EVENT, costCenters[0]);

        for (EMS_Budget_Allocation_gne__c baItem : [SELECT Budget_Deductions_gne__c, EMS_Product_Budget_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocationsPack]) {
            if (baItem.EMS_Product_Budget_gne__c == pb.Id) {
                //System.assertEquals(10.0 * EXPENSES_PER_EVENT, baItem.Budget_Deductions_gne__c);
            }
            if (baItem.EMS_Product_Budget_gne__c == pb2.Id) {
                //System.assertEquals(0, baItem.Budget_Deductions_gne__c);
            }
        }

        delete expenses;


        for (EMS_Budget_Allocation_gne__c baItem : [SELECT Budget_Deductions_gne__c, EMS_Product_Budget_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocationsPack]) {
            if (baItem.EMS_Product_Budget_gne__c == pb.Id) {
                //System.assertEquals(0, baItem.Budget_Deductions_gne__c);
            }
            if (baItem.EMS_Product_Budget_gne__c == pb2.Id) {
                //System.assertEquals(0, baItem.Budget_Deductions_gne__c);
            }
        }

        undelete expenses;
        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c baItem : [SELECT Budget_Deductions_gne__c, EMS_Product_Budget_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocationsPack]) {
            if (baItem.EMS_Product_Budget_gne__c == pb.Id) {
                System.assertEquals(10.0 * EXPENSES_PER_EVENT, baItem.Budget_Deductions_gne__c);
            }
            if (baItem.EMS_Product_Budget_gne__c == pb2.Id) {
                System.assertEquals(0, baItem.Budget_Deductions_gne__c);
            }
        }
    }

    @isTest
    static void updateTotalExpensesAmountOnInsertTwoBudgetsOtherCCTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 2, true);

        // cerate budget for the user
        List<EMS_Budget_Product_gne__c> pbList = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], costCenters);
        EMS_Budget_Product_gne__c pb = pbList[0];
        EMS_Budget_Product_gne__c pb2 = pbList[1];

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        List<EMS_Budget_Allocation_gne__c> budgetAllocationsPack = EMS_Test_Util.createBudgetAllocations((Id) productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pbList);
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations2 = new List<EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Allocation_gne__c baItem : budgetAllocationsPack) {
            if (baItem.EMS_Product_Budget_gne__c == pb.Id) {
                budgetAllocations.add(baItem);
            }
            if (baItem.EMS_Product_Budget_gne__c == pb2.Id) {
                budgetAllocations2.add(baItem);
            }
        }
        System.assert(budgetAllocations.size() == budgetAllocations2.size());

        Test.startTest();
        List<EMS_Expense_gne__c> expenses = EMS_Test_Util.createExpenses(events, 10.0, EXPENSES_PER_EVENT, costCenters[0]);

        for (EMS_Budget_Allocation_gne__c baItem : [SELECT Budget_Deductions_gne__c, EMS_Product_Budget_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocationsPack]) {
            if (baItem.EMS_Product_Budget_gne__c == pb.Id) {
                //System.assertEquals(10.0 * EXPENSES_PER_EVENT, baItem.Budget_Deductions_gne__c);
            }
            if (baItem.EMS_Product_Budget_gne__c == pb2.Id) {
                //System.assertEquals(0, baItem.Budget_Deductions_gne__c);
            }
        }

        for (EMS_Expense_gne__c expense : expenses) {
            expense.Country_Expense_Amount_gne__c = 20;
        }
        update expenses;
        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Deductions_gne__c, EMS_Product_Budget_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocationsPack]) {
            if (ba.EMS_Product_Budget_gne__c == pb.Id) {
                System.assertEquals(20.0 * EXPENSES_PER_EVENT, ba.Budget_Deductions_gne__c);
            }
            if (ba.EMS_Product_Budget_gne__c == pb2.Id) {
                System.assertEquals(0, ba.Budget_Deductions_gne__c);
            }
        }
    }

}