@isTest
private class EMS_Cost_Center_Field_Updates_Test {

    private static Integer BATCH_SIZE = 201;

    // insert
    private static testmethod void generateExternalIdOnInsertTest() {

        Test.startTest();
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', BATCH_SIZE, true);
        Test.stopTest();

        for (EMS_Cost_Center_gne__c costCenter : [SELECT Cost_Center_External_ID_gne__c FROM EMS_Cost_Center_gne__c WHERE ID in :costCenters]) {
            System.assertNotEquals(null, costCenter.Cost_Center_External_ID_gne__c);
            System.assert(costCenter.Cost_Center_External_ID_gne__c.contains('CostCenter'));
        }
    }
}