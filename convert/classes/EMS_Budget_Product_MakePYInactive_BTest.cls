@isTest
private class EMS_Budget_Product_MakePYInactive_BTest {

    @isTest static void test_method_one() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        Date newDate = System.today().addYears(-1);
        EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, newDate, newDate.addDays(7), String.valueOf(newDate.year()), pmUsers[0], costCenters[0].Id);

        Test.startTest();
        EMS_Budget_Product_MakePYInactive_Batch batch = new EMS_Budget_Product_MakePYInactive_Batch();
        Database.executeBatch(batch);
        Test.stopTest();

        System.assertEquals('Inactive', [SELECT Status_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :pb.Id].Status_gne__c);
    }
}