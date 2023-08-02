@isTest
private class EMS_Budget_Allocation_Ext_Test {

    private static Integer BATCH_SIZE = 1;

    static testMethod void initializeControllerWithPendingEvent() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        List<EMS_Budget_Allocation_gne__c> bas = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        for (EMS_Event__c event :events) {
            event.Pending_Budget_Approval_gne__c = true;
            event.Status_gne__c = 'Pending Approval';
            event.Submitted_Date_gne__c = System.today();
            event.Submitted_By_gne__c = pmUsers[0];
        }
        update events;

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bas[0]);
        EMS_Budget_Allocation_Ext ctrl = new EMS_Budget_Allocation_Ext(stdCtrl);

        ctrl.edit();
    }

    static testMethod void initializeControllerWithDraftEvent() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Draft', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        List<EMS_Budget_Allocation_gne__c> bas = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(bas[0]);
        EMS_Budget_Allocation_Ext ctrl = new EMS_Budget_Allocation_Ext(stdCtrl);
    }
}