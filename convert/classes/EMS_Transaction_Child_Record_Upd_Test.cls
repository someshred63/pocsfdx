@isTest
private class EMS_Transaction_Child_Record_Upd_Test {
    private static Integer BATCH_SIZE = 11;

    @isTest static void deletePaymentRequestsOnTransactionDeleteTest() {
        String eType = 'Sponsorship';
        String eSubtype = 'Sponsorship of Events';
        Decimal amount = 1000;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        EMS_Email_Boxes__c emailboxes = new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
        insert emailboxes;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 10 * amount, pmUser, costCenters[0].Id);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today(), Date.today().addDays(1), amount / 10, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        List<EMS_Transaction_gne__c> transactions = EMS_Test_Util.createTransactions(paymentRequests);
        System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Speaker_Role_gne__c WHERE Id IN :paymentRequests]);
        delete transactions;
        Test.stopTest();
        System.assertEquals(0, [SELECT count() FROM EMS_Speaker_Role_gne__c WHERE Id IN :paymentRequests]);
    }

    @isTest static void closePaymentRequestsOnTransactionCloseTest() {
        String eType = 'Sponsorship';
        String eSubtype = 'Sponsorship of Events';
        Decimal amount = 1000;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        EMS_Email_Boxes__c emailboxes = new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
        insert emailboxes;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 10 * amount, pmUser, costCenters[0].Id);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today(), Date.today().addDays(1), amount / 10, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        List<EMS_Transaction_gne__c> transactions = EMS_Test_Util.createTransactions(paymentRequests);
        for (EMS_Transaction_gne__c trans : transactions) {
            trans.Status_gne__c = 'Completed';
        }
        update transactions;
        Test.stopTest();
        for (EMS_Speaker_Role_gne__c paymentRequest : [SELECT Status_gne__c FROM EMS_Speaker_Role_gne__c WHERE Id IN :paymentRequests]) {
            System.assertEquals('Completed', paymentRequest.Status_gne__c);
        }
    }
}