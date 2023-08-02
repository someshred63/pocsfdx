@isTest
private class EMS_Budget_Product_Ext_Test {

    static testMethod void testAsNormalUser() {

        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        System.assertNotEquals(0, costCenters.size());

        List<EMS_Budget_Product_gne__c> budgets = EMS_Test_Util.createMultipleProductBudgets(0, 5000, pmUsers[0], 'Commercial Department', 1);
        EMS_Test_Util.createRegionBudgetForEachPB(1, budgets, 0, 50, pmUsers[0]);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(budgets[0]);
        EMS_Budget_Product_Ext Ctrl = new EMS_Budget_Product_Ext(stdCtrl);

        test.startTest();
        System.assertEquals(false, Ctrl.getCanClose());
        System.assertEquals(false, Ctrl.getCanPlan());
        System.assertEquals(false, Ctrl.getCanSeeHisoryAndDetails());
        System.assertEquals(false, Ctrl.getCanReactive());
        System.assertEquals(false, Ctrl.getCanDuplicate());
        Ctrl.duplicateBudgetClick();

        Ctrl.edit();

        Ctrl.callMethod('newRegionBudgetClick');
        Ctrl.callMethod('newTerritoryBudgetClick');
        Ctrl.callMethod('budgetPlanningClick');
        Ctrl.callMethod('closeBudgetClick');

        Ctrl.reactiveBudgetClick();

        Ctrl.getRelatedFieldSetListOverwritten();

        test.stopTest();
    }

    static testMethod void testAsAdmin() {

        //Finding admin user
        User admin = EMS_Test_Util.createEMSTestuser('Admin');
        System.assertNotEquals(null, admin);

        test.startTest();
        System.runAs(admin) {
            //Finding proper user
            List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
            System.assertNotEquals(0, pmUsers.size());

            List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
            System.assertNotEquals(0, costCenters.size());

            List<EMS_Budget_Product_gne__c> budgets = EMS_Test_Util.createMultipleProductBudgets(0, 5000, pmUsers[0], 'Commercial Department', 1);
            EMS_Test_Util.createRegionBudgetForEachPB(1, budgets, 0, 50, pmUsers[0]);

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(budgets[0]);
            EMS_Budget_Product_Ext Ctrl = new EMS_Budget_Product_Ext(stdCtrl);

            System.assertEquals(true, Ctrl.getCanClose());
            System.assertEquals(true, Ctrl.getCanPlan());
            System.assertEquals(true, Ctrl.getCanSeeHisoryAndDetails());
            System.assertEquals(false, Ctrl.getCanReactive());
            System.assertEquals(true, Ctrl.getCanDuplicate());

            //Inactivate budget

            Ctrl.closeBudgetClick();

            System.assertEquals(false, Ctrl.getCanClose());
            System.assertEquals(false, Ctrl.getCanPlan());
            System.assertEquals(true, Ctrl.getCanReactive());
        }
        test.stopTest();
    }

    static testMethod void testAsPMOwner() {

        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
                Name = 'GNE SFA2 User Application Context (User)',
                SetupOwnerId = pmUsers[0],
                App_Name_gne__c = 'EMS-Canada',
                Role_gne__c = 'PM',
                Run_in_SFA2_UI_gne__c = true,
                SFA2_Mode_gne__c = true,
                Brand_gne__c = 'My Brand'
        );
        insert appContext;

        User pm = [SELECT Id, Name FROM User WHERE Id = :pmUsers[0]];

        test.startTest();
        System.runAs(pm) {

            List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
            System.assertNotEquals(0, costCenters.size());

            List<EMS_Budget_Product_gne__c> budgets = EMS_Test_Util.createMultipleProductBudgets(0, 5000, pmUsers[0], 'Commercial Department', 1);
            EMS_Test_Util.createRegionBudgetForEachPB(1, budgets, 0, 50, pmUsers[0]);

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(budgets[0]);
            EMS_Budget_Product_Ext Ctrl = new EMS_Budget_Product_Ext(stdCtrl);

            System.assertEquals(true, Ctrl.getCanClose());
            System.assertEquals(true, Ctrl.getCanPlan());
            System.assertEquals(true, Ctrl.getCanSeeHisoryAndDetails());
            System.assertEquals(false, Ctrl.getCanReactive());
            System.assertEquals(false, Ctrl.getCanDuplicate());
        }
        test.stopTest();
    }

}