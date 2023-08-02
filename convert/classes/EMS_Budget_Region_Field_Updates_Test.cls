@isTest
private class EMS_Budget_Region_Field_Updates_Test {
    private static Integer BATCH_SIZE = 101;

    @isTest
    static void updateTerritoryIdOnInsertTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);

        Test.startTest();

        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        Test.stopTest();

        for (EMS_Budget_Region_gne__c rb : [SELECT Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertNotEquals(null, rb.Assigned_To_Territory_Id_gne__c);
        }
    }

    @isTest
    static void updateNameOnInsertTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);

        Test.startTest();

        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        Test.stopTest();

        for (EMS_Budget_Region_gne__c rb : [SELECT Name, Name_gne__c, Year_gne__c, Cost_Center_gne__c, Product_Indication_gne__c, Assigned_To_Territory_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals('RB-' + rb.Year_gne__c + '-' + rb.Cost_Center_gne__c + '-' + rb.Product_Indication_gne__c + '-' + rb.Assigned_To_Territory_gne__c, rb.Name_gne__c);
        }
    }

    @isTest
    static void updateRTonDeactivateTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        Test.startTest();

        for (EMS_Budget_Region_gne__c rb : regionBudgets) {
            rb.Status_gne__c = 'Inactive';
        }
        update regionBudgets;

        Test.stopTest();

        for (EMS_Budget_Region_gne__c rb : [SELECT RecordType.DeveloperName FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals('EMS_Canada_Inactive_Region_Budget_gne', rb.RecordType.DeveloperName);
        }
    }

    @isTest
    static void updateNameOnUpdateTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        // select new territory
        EMS_Util.EMS_Territory newTerr = EMS_Util.getTerritoryByName(productBudgets[0].Assigned_To_Territory_Id__c);

        Test.startTest();

        for (EMS_Budget_Region_gne__c rb : regionBudgets) {
            rb.Assigned_To_Territory_gne__c = newTerr.Name;
        }
        update regionBudgets;

        Test.stopTest();

        for (EMS_Budget_Region_gne__c rb : [SELECT Name, Assigned_To_Territory_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assert(newTerr.Name.contains(rb.Assigned_To_Territory_gne__c));
        }
    }

    @isTest
    static void updateTerritoryIdOnUpdateTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        // select new territory
        EMS_Util.EMS_Territory newTerr = EMS_Util.getTerritoryByName(productBudgets[0].Assigned_To_Territory_Id__c);

        Test.startTest();

        for (EMS_Budget_Region_gne__c rb : regionBudgets) {
            rb.Assigned_To_Territory_gne__c = newTerr.Name;
        }
        update regionBudgets;

        Test.stopTest();

        for (EMS_Budget_Region_gne__c rb : [SELECT Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(newTerr.Id, rb.Assigned_To_Territory_Id_gne__c);
        }
    }
}