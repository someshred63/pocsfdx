@isTest
private class EMS_Budget_Region_Edit_Create_Ext_Test {

    static testMethod void newRegionBudget() {

        //Finding proper user
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        System.assertNotEquals(0, costCenters.size());

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createProductBudget(0, 1000, pmUser, costCenters[0].Id);

        ApexPages.currentPage().getParameters().put('productId', productBudget.Id);

        EMS_Budget_Region_gne__c regionBudget = new EMS_Budget_Region_gne__c();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(regionBudget);
        EMS_Budget_Region_Edit_Create_Ext Ctrl = new EMS_Budget_Region_Edit_Create_Ext(stdCtrl);

        //Finding admin user
        User admin = EMS_Test_Util.getSystemAdministratorUser();
        System.assertNotEquals(null, admin);

        System.runAs(admin) {

            Ctrl.refreshProductBudget();

            Ctrl.getAvailableTerritories();

            regionBudget.Assigned_to_gne__c = rsmUser;

            Ctrl.myObject = regionBudget;

            List<SelectOption> territories = Ctrl.getAvailableTerritories();
            System.assertNotEquals(0, territories.size());

            regionBudget.Assigned_To_Territory_gne__c = territories[0].getValue();

            regionBudget.Total_Region_Funds_Approved_gne__c = 500;
            regionBudget.RecordTypeId = EMS_Test_Util.rbRecordTypesMap.get('EMS Canada Region Budget');
            regionBudget.Start_Date_gne__c = Date.today();
            regionBudget.End_Date_gne__c = Date.today() + 7;
            regionBudget.Status_gne__c = 'Active';
            regionBudget.Year_gne__c = Date.today().year().format();

            Ctrl.myObject = regionBudget;

            Ctrl.save();
        }

    }

    static testMethod void existingBudgetRegion() {

        //Finding proper user
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, 1000, pmUser, 'Commercial Department', 1);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500, rsmUser);

        ApexPages.currentPage().getParameters().put('productId', productBudgets[0].Id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(regionBudgets[0]);
        EMS_Budget_Region_Edit_Create_Ext Ctrl = new EMS_Budget_Region_Edit_Create_Ext(stdCtrl);

        //Finding admin user
        User admin = EMS_Test_Util.getSystemAdministratorUser();
        System.assertNotEquals(null, admin);

        System.runAs(admin) {

            Ctrl.getIsEditable();

            regionBudgets[0].Total_Region_Funds_Approved_gne__c = 700;
            Ctrl.myObject = regionBudgets[0];

            Ctrl.save();

            List<EMS_Budget_Region_gne__c> budgetsToAssert = [
                    SELECT Id, Name, Assigned_to_gne__c, Total_Region_Funds_Approved_gne__c
                    FROM EMS_Budget_Region_gne__c
                    WHERE Assigned_to_gne__c = :rsmUser
            ];

            System.assertEquals(1, budgetsToAssert.size());
            System.assertEquals(700, budgetsToAssert[0].Total_Region_Funds_Approved_gne__c);

            test.stopTest();
        }
    }

    static testMethod void existingClonedBudgetRegion() {

        //Finding proper user
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        System.assertNotEquals(0, costCenters.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, 1000, pmUser, 'Commercial Department', 1);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500, rsmUser);

        ApexPages.currentPage().getParameters().put('productId', productBudgets[0].Id);
        ApexPages.currentPage().getParameters().put('isClone', 'true');

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(regionBudgets[0]);
        EMS_Budget_Region_Edit_Create_Ext Ctrl = new EMS_Budget_Region_Edit_Create_Ext(stdCtrl);

        //Finding admin user
        User admin = EMS_Test_Util.getSystemAdministratorUser();
        System.assertNotEquals(null, admin);

        Ctrl.getIsEditable();

        System.runAs(admin) {

            test.startTest();

            Ctrl.getIsEditable();

            regionBudgets[0].Assigned_to_gne__c = rsmUser;

            Ctrl.myObject = regionBudgets[0];

            List<SelectOption> territories = Ctrl.getAvailableTerritories();
            System.assertNotEquals(0, territories.size());

            regionBudgets[0].Assigned_To_Territory_gne__c = territories[0].getValue();

            regionBudgets[0].Total_Region_Funds_Approved_gne__c = 800;
            regionBudgets[0].Start_Date_gne__c = Date.today();
            regionBudgets[0].End_Date_gne__c = Date.today() + 7;
            regionBudgets[0].Status_gne__c = 'Active';
            regionBudgets[0].Year_gne__c = Date.today().year().format();

            Ctrl.myObject = regionBudgets[0];

            test.stopTest();
        }
    }

    static testMethod void invalidBudgetRegion() {

        //Finding proper user
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createProductBudget(0, 1000, pmUser, costCenters[0].Id);

        ApexPages.currentPage().getParameters().put('productId', productBudget.Id);

        EMS_Budget_Region_gne__c regionBudget = new EMS_Budget_Region_gne__c();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(regionBudget);
        EMS_Budget_Region_Edit_Create_Ext Ctrl = new EMS_Budget_Region_Edit_Create_Ext(stdCtrl);

        //Finding admin user
        User admin = EMS_Test_Util.getSystemAdministratorUser();
        System.assertNotEquals(null, admin);

        Ctrl.getIsEditable();

        System.runAs(admin) {

            Ctrl.getIsEditable();

            //Try to save without required data
            Ctrl.save();

            regionBudget.Total_Region_Funds_Approved_gne__c = 500;
            regionBudget.RecordTypeId = EMS_Test_Util.rbRecordTypesMap.get('EMS Canada Region Budget');
            regionBudget.Start_Date_gne__c = Date.today();
            regionBudget.End_Date_gne__c = Date.today() + 7;
            regionBudget.Status_gne__c = 'Active';
            regionBudget.Year_gne__c = Date.today().year().format();

            Ctrl.myObject = regionBudget;

            //Try to save without assigned user
            Ctrl.save();

            Id hardcodedUser = '01sQ00000008bamIAA';

            regionBudget.Assigned_to_gne__c = rsmUser;

            List<SelectOption> territories = Ctrl.getAvailableTerritories();

            regionBudget.Assigned_To_Territory_gne__c = territories[0].getValue();

            regionBudget.Assigned_to_gne__c = hardcodedUser;

            Ctrl.myObject = regionBudget;

            //Try to save with hardcoded assigned user
            Ctrl.save();

            test.stopTest();
        }
    }
}