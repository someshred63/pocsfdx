@isTest
private class EMS_Approval_History_Controller_Test {

    private static Integer BATCH_SIZE = 1;
    private static final Id productBudgetRTID = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1].Id;

    private static String type = 'Program';
    private static String subtype = 'Product Promo';

    static testMethod void addApprovalItemsFromProcessInstanceApprovalTest() {

        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        //Creating cost center and product budget
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(type, subtype, costCenters[0]);

        //Creating test event
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Draft', pmUsers[0], type, subtype, Date.today(), Date.today() + 7, 100.0, BATCH_SIZE);
        System.assertNotEquals(0, events.size());

        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;

        //Creating budget allocation for test event
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        List<EMS_Budget_Allocation_gne__c> baList = EMS_Test_Util.createBudgetAllocations(productBudgetRTID, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        Test.startTest();

        //Initializing test class
        EMS_Approval_History_Controller historyController = new EMS_Approval_History_Controller();

        //Check for "new" budget allocation
        historyController.records = baList;

        for (EMS_Event__c event :events) {
            event.Status_gne__c = 'Pending Approval';
            event.Pending_Budget_Approval_gne__c = true;
        }
        update events;

        for (EMS_Budget_Allocation_gne__c baItem : baList) {
            baItem.Status_gne__c = 'Approved';
        }
        update baList;

        historyController.records = baList;

        Test.stopTest();
    }

    static testMethod void addApprovalItemsFromProcessInstanceRejectTest() {

        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        //Creating cost center and product budget
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0 * BATCH_SIZE, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(type, subtype, costCenters[0]);

        //Creating test event
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Draft', pmUsers[0], type, subtype, Date.today(), Date.today() + 7, 100.0, BATCH_SIZE);
        System.assertNotEquals(0, events.size());

        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;

        //Creating budget allocation for test event
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        List<EMS_Budget_Allocation_gne__c> baList = EMS_Test_Util.createBudgetAllocations(productBudgetRTID, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);

        Test.startTest();

        //Initializing test class
        EMS_Approval_History_Controller historyController = new EMS_Approval_History_Controller();

        //Check for "new" budget allocation
        historyController.records = baList;

        for (EMS_Event__c event :events) {
            event.Status_gne__c = 'Pending Approval';
            event.Pending_Budget_Approval_gne__c = true;
        }
        update events;

        for (EMS_Budget_Allocation_gne__c baItem : baList) {
            baItem.Status_gne__c = 'Rejected';
        }
        update baList;

        historyController.records = baList;

        Test.stopTest();
    }

}