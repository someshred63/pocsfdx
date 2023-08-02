@isTest
private class EMS_Budget_Product_Edit_Create_Ext_Test {

    static testMethod void newBudgetProduct() {
        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        EMS_Budget_Product_gne__c budget = new EMS_Budget_Product_gne__c();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(budget);
        EMS_Budget_Product_Edit_Create_Ext Ctrl = new EMS_Budget_Product_Edit_Create_Ext(stdCtrl);

        System.assertEquals(2, Ctrl.costCenters.size());

        Ctrl.productBudget.Cost_Center_gne__c = Ctrl.costCenters[1].getValue();

        Ctrl.refreshCostCenterType();

        Ctrl.productBudget.Assigned_to_gne__c = pmUsers[0];

        List<SelectOption> territories = Ctrl.getAvailableTerritories();
        System.assertNotEquals(0, territories.size());

        Ctrl.productBudget.Assigned_To_Territory_gne__c = territories[0].getValue();

        Ctrl.productBudget.Total_Product_Funds_Approved_gne__c = 5000;
        Ctrl.productBudget.Start_Date_gne__c = Date.today();
        Ctrl.productBudget.End_Date_gne__c = Date.today() + 7;
        Ctrl.productBudget.Budget_State_gne__c = 'LE';
        Ctrl.productBudget.Status_gne__c = 'Active';
        Ctrl.productBudget.Year_gne__c = '2016';

        Ctrl.save();

        List<EMS_Budget_Product_gne__c> budgetsToAssert = [
                SELECT Id, Name, Assigned_to_gne__c, Total_Product_Funds_Approved_gne__c, Budget_State_gne__c
                FROM EMS_Budget_Product_gne__c
                WHERE Assigned_to_gne__c = :pmUsers[0]
        ];

        System.assertEquals(1, budgetsToAssert.size());
        System.assertEquals(5000, budgetsToAssert[0].Total_Product_Funds_Approved_gne__c);
        System.assertEquals('LE', budgetsToAssert[0].Budget_State_gne__c);

        test.stopTest();
    }

    static testMethod void existingBudgetProduct() {

        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        EMS_Budget_Product_gne__c budget = EMS_Test_Util.createProductBudget(0, 100, pmUsers[0], costCenters[0].Id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(budget);
        EMS_Budget_Product_Edit_Create_Ext Ctrl = new EMS_Budget_Product_Edit_Create_Ext(stdCtrl);

        System.assertEquals(2, Ctrl.costCenters.size());

        Ctrl.getIsEditable();

        Ctrl.productBudget.Total_Product_Funds_Approved_gne__c = 2000;

        Ctrl.save();

        List<EMS_Budget_Product_gne__c> budgetsToAssert = [
                SELECT Id, Name, Assigned_to_gne__c, Total_Product_Funds_Approved_gne__c, Budget_State_gne__c
                FROM EMS_Budget_Product_gne__c
                WHERE Assigned_to_gne__c = :pmUsers[0]
        ];

        System.assertEquals(1, budgetsToAssert.size());
        System.assertEquals(2000, budgetsToAssert[0].Total_Product_Funds_Approved_gne__c);

        test.stopTest();
    }

    static testMethod void existingClonedBudgetProduct() {

        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 3, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();
        ApexPages.currentPage().getParameters().put('isClone', 'true');

        EMS_Budget_Product_gne__c budget = EMS_Test_Util.createProductBudget(0, 100, pmUsers[0], costCenters[0].Id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(budget);
        EMS_Budget_Product_Edit_Create_Ext Ctrl = new EMS_Budget_Product_Edit_Create_Ext(stdCtrl);

        Ctrl.getIsEditable();

        System.assertEquals(4, Ctrl.costCenters.size());

        Ctrl.productBudget.Cost_Center_gne__c = Ctrl.costCenters[2].getValue();

        Ctrl.productBudget.Total_Product_Funds_Approved_gne__c = 5000;
        Ctrl.productBudget.Start_Date_gne__c = Date.today();
        Ctrl.productBudget.End_Date_gne__c = Date.today() + 7;
        Ctrl.productBudget.Budget_State_gne__c = 'LE';
        Ctrl.productBudget.Status_gne__c = 'Active';
        Ctrl.productBudget.Year_gne__c = '2016';

        Ctrl.save();

        List<EMS_Budget_Product_gne__c> budgetsToAssert = [
                SELECT Id, Name, Assigned_to_gne__c, Total_Product_Funds_Approved_gne__c, Budget_State_gne__c
                FROM EMS_Budget_Product_gne__c
                WHERE Assigned_to_gne__c = :pmUsers[0]
        ];

        System.assertEquals(2, budgetsToAssert.size());

        test.stopTest();
    }

    static testMethod void invalidBudgetProduct() {

        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        EMS_Budget_Product_gne__c budget = new EMS_Budget_Product_gne__c();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(budget);
        EMS_Budget_Product_Edit_Create_Ext Ctrl = new EMS_Budget_Product_Edit_Create_Ext(stdCtrl);

        System.assertEquals(2, Ctrl.costCenters.size());

        Ctrl.getIsEditable();

        //Try to save without required data
        Ctrl.save();

        Ctrl.productBudget.Cost_Center_gne__c = Ctrl.costCenters[1].getValue();

        Ctrl.refreshCostCenterType();

        Ctrl.productBudget.Total_Product_Funds_Approved_gne__c = 5000;
        Ctrl.productBudget.Start_Date_gne__c = Date.today();
        Ctrl.productBudget.End_Date_gne__c = Date.today() + 7;
        Ctrl.productBudget.Budget_State_gne__c = 'LE';
        Ctrl.productBudget.Status_gne__c = 'Active';
        Ctrl.productBudget.Year_gne__c = '2016';

        //Try to save without assigned user
        Ctrl.save();

        Id hardcodedUser = '01sQ00000008bamIAA';

        Ctrl.productBudget.Assigned_to_gne__c = pmUsers[0];

        List<SelectOption> territories = Ctrl.getAvailableTerritories();
        Ctrl.productBudget.Assigned_To_Territory_gne__c = territories[0].getValue();

        Ctrl.productBudget.Assigned_to_gne__c = hardcodedUser;

        //Try to save with hardcoded assigned user
        Ctrl.save();

        Ctrl.productBudget.Assigned_to_gne__c = pmUsers[0];

        territories = Ctrl.getAvailableTerritories();
        System.assertNotEquals(0, territories.size());

        Ctrl.productBudget.Assigned_To_Territory_gne__c = territories[0].getValue();

        //Try to save duplicate
        EMS_Test_Util.createProductBudget(0, 100, pmUsers[0], costCenters[0].Id);

        Ctrl.save();

        test.stopTest();
    }
}