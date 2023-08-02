@isTest
private class EMS_Budget_Territory_Field_Updates_Test {
    private static Integer BATCH_SIZE = 101;

    @isTest
    static void updateTerritoryIdOnInsertTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        Test.startTest();
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 1.0, repUsers[0]);
        Test.stopTest();

        for (EMS_Budget_Territory_gne__c tb : [SELECT Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
            System.assertNotEquals(null, tb.Assigned_To_Territory_Id_gne__c);
        }
    }

    @isTest
    static void updateNameOnInsertTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        Test.startTest();
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 1.0, repUsers[0]);
        Test.stopTest();

        for (EMS_Budget_Territory_gne__c tb : [SELECT Name_gne__c, Year_gne__c, Cost_Center_gne__c, Product_Indication_gne__c, Assigned_To_Territory_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
            System.assertEquals('TB-' + tb.Year_gne__c + '-' + tb.Cost_Center_gne__c + '-' + tb.Product_Indication_gne__c + '-' + tb.Assigned_To_Territory_gne__c, tb.Name_gne__c);
        }
    }

    @isTest
    static void updateRTonDeactivateTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 1.0, repUsers[0]);

        Test.startTest();
        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            tb.Status_gne__c = 'Inactive';
        }
        update territoryBudgets;
        Test.stopTest();

        for (EMS_Budget_Territory_gne__c tb : [SELECT RecordType.DeveloperName FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
            System.assertEquals('EMS_Canada_Inactive_Territory_Budget_gne', tb.RecordType.DeveloperName);
        }
    }

    @isTest
    static void updateNameOnUpdateTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 1.0, repUsers[0]);

        // select new territory
        EMS_Util.EMS_Territory newTerr = EMS_Util.getTerritoryByName(regionBudgets[0].Assigned_To_Territory_gne__c);

        Test.startTest();
        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            tb.Assigned_To_Territory_gne__c = newTerr.Name;
        }
        update territoryBudgets;
        Test.stopTest();

        for (EMS_Budget_Territory_gne__c tb : [SELECT Name, Assigned_To_Territory_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
            System.assert(newTerr.Name.contains(tb.Assigned_To_Territory_gne__c));
        }
    }

    @isTest
    static void updateTerritoryIdOnUpdateTest() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 1.0, repUsers[0]);

        // select new territory
        EMS_Util.EMS_Territory newTerr = EMS_Util.getTerritoryByName(regionBudgets[0].Assigned_To_Territory_gne__c);

        Test.startTest();
        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            tb.Assigned_To_Territory_gne__c = newTerr.Name;
        }
        update territoryBudgets;
        Test.stopTest();

        for (EMS_Budget_Territory_gne__c tb : [SELECT Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
            System.assertEquals(newTerr.Id, tb.Assigned_To_Territory_Id_gne__c);
        }
    }
}