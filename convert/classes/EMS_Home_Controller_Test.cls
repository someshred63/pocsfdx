@isTest
private class EMS_Home_Controller_Test {

    private static final Id productBudgetRTID = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1].Id;
    private static final RecordType paymentRequestRT = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Speaker_Role_gne__c' AND Name = 'HCP/HCO Payment Request' LIMIT 1];

    private static final String type = 'Program';
    private static final String subtype = 'Product Promo';

    static testMethod void Approve_budget() {

        EMS_Home_Controller ctrl = new EMS_Home_Controller();

        apexpages.currentpage().getparameters().put('nr', '1');

        ctrl.initialize();

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        EMS_Event_Trigger_Helper.skipTrigger = true;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(type, subtype, costCenters[0]);

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Pending Approval', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 7, 100.0, 1);

        List<EMS_Budget_Allocation_gne__c> baList = new List<EMS_Budget_Allocation_gne__c>();

        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = 100,
                Budget_Deductions_gne__c = 0,
                Percentage_Contribution_gne__c = 100 / 100,
                Budget_Owner_gne__c = pmUsers[0],
                EMS_Event_gne__c = events[0].Id,
                RecordTypeId = productBudgetRTID,
                EMS_Product_Budget_gne__c = pb.Id,
                Status_gne__c = 'Submitted'
        );
        baList.add(budgetAllocation);

        insert baList;

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        System.runAS(u) {
            //Run as user who got budget to approve
            ctrl.initialize();

            List<String> budgetIds = new List<String>();
            List<String> workItemsIds = new List<String>();
            List<String> amounts = new List<String>();

            for (EMS_Budget_Allocation_gne__c b : baList) {
                budgetIds.add(b.Id);
                amounts.add('100');
            }

            EMS_Home_Controller.approveRejectRecallBudgetAllocations('Approve', budgetIds, workItemsIds, amounts, '');

            ctrl.initialize();
        }
    }

    static testMethod void Approve_event() {

        EMS_Home_Controller ctrl = new EMS_Home_Controller();

        apexpages.currentpage().getparameters().put('nr', '1');

        ctrl.initialize();

        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(type, subtype, costCenters[0]);

        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Pending Approval', pmUsers[0], 'Program', 'Product Promo', Date.today(), Date.today() + 7, 100.0, 1);

        List<EMS_Budget_Allocation_gne__c> baList = new List<EMS_Budget_Allocation_gne__c>();

        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = 100,
                Budget_Deductions_gne__c = 0,
                Percentage_Contribution_gne__c = 100 / 100,
                Budget_Owner_gne__c = pmUsers[0],
                EMS_Event_gne__c = events[0].Id,
                RecordTypeId = productBudgetRTID,
                EMS_Product_Budget_gne__c = pb.Id,
                Status_gne__c = 'Approved'
        );
        baList.add(budgetAllocation);

        insert baList;

        User u = [SELECT Id FROM User WHERE Id = :pmUsers[0]];

        System.runAS(u) {
            //Run as user who got budget to approve
            ctrl.initialize();

            EMS_Event__c event = EMS_Home_Controller.getEvent(events[0].Id);

            EMS_Home_Controller.approveRejectRecallEvent('Approve', event.Id, '', '');

            ctrl.initialize();
        }
    }

    static testMethod void Approve_PR() {

        EMS_Home_Controller ctrl = new EMS_Home_Controller();

        apexpages.currentpage().getparameters().put('nr', '1');

        ctrl.initialize();

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 500, pmUser, 'Commercial Department', 1);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, true);

        EMS_Test_Util.createPossibleBudgetAllocationMapping(type, subtype, 'Commercial Department');

        User u = [SELECT Id FROM User WHERE Id = :pmUser];

        System.runAS(u) {
            //Run as user who got budget to approve
            ctrl.initialize();

            EMS_Home_Controller.approveRejectRecallFundRequest('Approve', fundRequests[0].Id, '', '');

            ctrl.initialize();
        }
    }

    static testMethod void runAsAdmin() {

        apexpages.currentpage().getparameters().put('nr', '1');
        apexpages.currentpage().getparameters().put('msg', 'Run As Admin');

        EMS_Home_Controller ctrl = new EMS_Home_Controller();

        User u = EMS_Test_Util.createEMSTestuser('Admin');

        System.runAS(u) {
            //Run as user who got budget to approve
            ctrl.initialize();
        }
    }

}