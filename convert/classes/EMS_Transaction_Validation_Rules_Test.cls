@isTest
private class EMS_Transaction_Validation_Rules_Test {
    private static Integer BATCH_SIZE { get; set; }
    private static String eType { get; set; }
    private static String eSubtype { get; set; }
    private static Decimal amount { get; set; }
    private static Id pmUser { get; set; }

    private static void prepare() {
        eType = 'Sponsorship';
        eSubtype = 'Sponsorship of Events';
        amount = 1000;
        BATCH_SIZE = 11;

        pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        EMS_Email_Boxes__c emailboxes = new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
        insert emailboxes;
    }

    @isTest static void validateAmountOnInsertTest1() {
        prepare();

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, amount, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(eType, eSubtype, costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, eType, eSubtype, Date.today(), Date.today().addDays(1), amount / 10, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        List<EMS_Transaction_gne__c> transactions = EMS_Test_Util.createTransactions(paymentRequests, 1.0);
        Test.stopTest();
    }

    @isTest static void validateAmountOnInsertTest2() {
        prepare();

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, amount, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(eType, eSubtype, costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, eType, eSubtype, Date.today(), Date.today().addDays(1), amount / 10, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        try {
            List<EMS_Transaction_gne__c> transactions = EMS_Test_Util.createTransactions(paymentRequests, -1.0);
            System.assert(false, 'Transcation with negative amount should not be inserted');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Amount must be greater than 0.'), ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest static void validateAmountOnUpdateTest1() {
        prepare();

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, amount, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(eType, eSubtype, costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, eType, eSubtype, Date.today(), Date.today().addDays(1), amount / 10, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        List<EMS_Transaction_gne__c> transactions = EMS_Test_Util.createTransactions(paymentRequests);
        try {
            for (EMS_Transaction_gne__c trans :transactions) {
                trans.Fee_Amount_gne__c = -1.0;
            }
            update transactions;
            System.assert(false, 'Transcation with negative amount should not be updated');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Amount must be greater than 0.'), ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest static void validateAmountOnUpdateTest2() {
        prepare();

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, amount, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(eType, eSubtype, costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, eType, eSubtype, Date.today(), Date.today().addDays(1), amount / 10, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        List<EMS_Transaction_gne__c> transactions = EMS_Test_Util.createTransactions(paymentRequests);
        try {
            for (EMS_Transaction_gne__c trans : transactions) {
                trans.Fee_Amount_gne__c = 2.0;
            }
            update transactions;
        } catch (DmlException ex) {
            System.assert(false, 'Transcation with positive amount should be updated: ' + ex.getMessage());
        }
        Test.stopTest();
    }
}