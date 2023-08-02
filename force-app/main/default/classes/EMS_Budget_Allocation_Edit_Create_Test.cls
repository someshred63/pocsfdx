@isTest
private class EMS_Budget_Allocation_Edit_Create_Test {

    static testMethod void initWithNewAllocation() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Payment Request Initiated', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 1, 100.0, 1);

        EMS_Budget_Allocation_gne__c ba = new EMS_Budget_Allocation_gne__c();

        RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];
        ApexPages.currentPage().getParameters().put('preSetRecordType', productBudgetAllocationRT.Id);

        ApexPages.currentPage().getParameters().put('objectId', events[0].Id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ba);
        EMS_Budget_Allocation_Edit_Create_Ext ctrl = new EMS_Budget_Allocation_Edit_Create_Ext(stdCtrl);

        ctrl.save();
    }
}