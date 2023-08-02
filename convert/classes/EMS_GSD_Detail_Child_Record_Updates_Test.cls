@isTest
private class EMS_GSD_Detail_Child_Record_Updates_Test {
    private static Integer BATCH_SIZE = 101;
    @isTest
    static void updateHCPHCPNameOnInsert() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        Account acc = EMS_Test_Util.createAndInsertAccount('HCP Canada');

        Test.startTest();
        EMS_Test_Util.createGSDDetails(acc, events);
        Test.stopTest();

        for (EMS_Event__c event : [SELECT HCP_HCO_Name_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(acc.Id, event.HCP_HCO_Name_gne__c);
        }
    }

    @isTest
    static void updateHCPHCPNameOnUpdate() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today() - 1, Date.today(), 100.0, BATCH_SIZE);

        Account acc = EMS_Test_Util.createAndInsertAccount('HCP Canada');
        Account acc2 = EMS_Test_Util.createAndInsertAccount('HCP Canada');

        List<EMS_GSD_Detail__c> gsdDetails = EMS_Test_Util.createGSDDetails(acc, events);

        for (EMS_Event__c event : [SELECT HCP_HCO_Name_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(acc.Id, event.HCP_HCO_Name_gne__c);
        }

        Test.startTest();
        for (EMS_GSD_Detail__c gsdDetail : gsdDetails) {
            gsdDetail.HCP_HCO_Name__c = acc2.Id;
        }
        update gsdDetails;
        Test.stopTest();

        for (EMS_Event__c event : [SELECT HCP_HCO_Name_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals(acc2.Id, event.HCP_HCO_Name_gne__c);
        }
    }
}