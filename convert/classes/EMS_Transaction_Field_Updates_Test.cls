@isTest
private class EMS_Transaction_Field_Updates_Test {
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

    @isTest static void updateHCOHCPNameTest() {
        prepare();

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, amount, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(eType, eSubtype, costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, eType, eSubtype, Date.today(), Date.today().addDays(1), amount / 10, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        List<EMS_Transaction_gne__c> transactions = EMS_Test_Util.createTransactions(paymentRequests);
        Test.stopTest();

        for (EMS_Transaction_gne__c trans : [SELECT HCP_HCO_gne__c FROM EMS_Transaction_gne__c WHERE Id IN :transactions]) {
            System.assertEquals('test account', trans.HCP_HCO_gne__c);
        }
    }

    @isTest static void updateIHCPNameTest() {
        prepare();

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, amount, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(eType, eSubtype, costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, eType, eSubtype, Date.today(), Date.today().addDays(1), amount / 10, BATCH_SIZE);
        EMS_International_Speaker_gne__c ihcp = EMS_Test_util.createAndInsertIHCP('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('iHCP Payment Request', events, null, ihcp.Id, Date.today());
        List<EMS_Transaction_gne__c> transactions = EMS_Test_Util.createTransactions(paymentRequests);
        Test.stopTest();

        for (EMS_Transaction_gne__c trans : [SELECT iHCP_gne__c FROM EMS_Transaction_gne__c WHERE Id IN :transactions]) {
            System.assertEquals('test account', trans.iHCP_gne__c);
        }
    }
}