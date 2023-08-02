@isTest
private class EMS_Ariba_Payment_Queue_Export_Ctrl_Test {
    private static final Integer BATCH_SIZE = 1;
    private static final RecordType paymentRequestRT = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Speaker_Role_gne__c' AND Name = 'HCP/HCO Payment Request' LIMIT 1];


    @isTest static void test_method_one() {
        String etype = 'Learning Programs';
        String esubtype = 'OLA Implementation';
        Decimal amount = 100;

        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Medical Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUsers[0], costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Awaiting Signature from HCP', mmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount,
                Budget_Owner_gne__c = mmUsers[0],
                Percentage_Contribution_gne__c = 100,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = productBudget.Id,
                Status_gne__c = 'Approved'
        );
        insert budgetAllocation;

        Account accountHCP = EMS_Test_util.createAndInsertAccount('New HCP Account', 'Account');
        EMS_Speaker_Role_gne__c paymentRequest = EMS_Test_Util.createPaymentRequest(paymentRequestRT.Id, event.Id, accountHCP.Id);
        PageReference exportPage = Page.EMS_Ariba_Payment_Queue_Export;
        exportPage.getParameters().put('bid', '1');
        exportPage.getParameters().put('ids', paymentRequest.Id);


        Decimal transactionAmount = amount / 4;
        EMS_Transaction_gne__c transactionGroup = EMS_Test_Util.createTransaction(
                'Transaction Group',
                paymentRequest.Id,
                event.Id,
                transactionAmount,
                null,
                null
        );

        Test.startTest();
        // insert parent transaction - "Transaction Group"
        insert transactionGroup;
        EMS_Transaction_gne__c transactionRecord = EMS_Test_Util.createTransaction(
                'Transaction',
                paymentRequest.Id,
                event.Id,
                transactionAmount,
                transactionGroup.Id,
                costCenters[0].Id
        );
        // insert child transaction - "Transaction"
        insert transactionRecord;

        Test.setCurrentPage(exportPage);
        EMS_Ariba_Payment_Queue_Export_Ctrl exportCtrl = new EMS_Ariba_Payment_Queue_Export_Ctrl();
        Test.stopTest();
    }
}