@isTest
private class EMS_Region_Budget_Child_Rec_Updates_Test {

    public static testMethod void moveFundsUponInsertTest() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);

        Test.startTest();
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, amount, rsmUser);
        Test.stopTest();

        for (EMS_Budget_Product_gne__c pb : [SELECT Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(amount, pb.Child_Budgets_Allocated_Amount_gne__c);
        }
    }

    public static testMethod void shareBudgetWithTerritoryAndParentTerritoryOnInsertTest() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);

        Test.startTest();
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, amount, rsmUser);
        Test.stopTest();

        String rowCause = Schema.EMS_Budget_Region_gne__Share.RowCause.Territory_Sharing__c;
        List<EMS_Budget_Region_gne__Share> rbShares = [SELECT AccessLevel FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCause];
        System.assertEquals(regionBudgets.size(), rbShares.size());
        for (EMS_Budget_Region_gne__Share rbShare : rbShares) {
            System.assertEquals('Edit', rbShare.AccessLevel);
        }

        rowCause = Schema.EMS_Budget_Region_gne__Share.RowCause.Product_Budget_Sharing__c;
        rbShares = [SELECT AccessLevel FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCause];
        System.assertEquals(regionBudgets.size(), rbShares.size());
        for (EMS_Budget_Region_gne__Share rbShare : rbShares) {
            System.assertEquals('Edit', rbShare.AccessLevel);
        }
    }

    public static testMethod void shareProductBudgetWithRegionBudgetTerritoryOnInsertTest() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);

        Test.startTest();
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, amount, rsmUser);
        Test.stopTest();

        String rowCause = Schema.EMS_Budget_Product_gne__Share.RowCause.Child_Territory_Sharing__c;
        List<EMS_Budget_Product_gne__Share> pbShares = [SELECT AccessLevel FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :productBudgets AND RowCause = :rowCause];
        System.assertEquals(regionBudgets.size(), pbShares.size());
        for (EMS_Budget_Product_gne__Share pbShare : pbShares) {
            System.assertEquals('Read', pbShare.AccessLevel);
        }
    }

    public static testMethod void moveFundsUponUpdateTest() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, amount, rsmUser);

        for (EMS_Budget_Product_gne__c pb : [SELECT Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(amount, pb.Child_Budgets_Allocated_Amount_gne__c);
        }

        Test.startTest();
        for (EMS_Budget_Region_gne__c rb : regionBudgets) {
            rb.Total_Region_Funds_Approved_gne__c = amount + 20.0;
        }
        update regionBudgets;
        Test.stopTest();

        for (EMS_Budget_Product_gne__c pb : [SELECT Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals(amount + 20.0, pb.Child_Budgets_Allocated_Amount_gne__c);
        }
    }

    public static testMethod void deactivateBudgetTest() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUser, costCenters[0].Id);
        EMS_Budget_Region_gne__c rb = EMS_Test_Util.createRegionBudget(pb.Id, 0.0, amount * 5, rsmUser);
        //EMS_Budget_Territory_gne__c tb = EMS_Test_Util.createTerritoryBudget(rb.Id, 0.0, amount*2, repUser);
        EMS_Fund_Request_gne__c fundRequest = EMS_Test_Util.createFundRequest('Region Fund Allocation', pb.Id, rb.Id, null, amount / 10);

        Test.startTest();
        rb.Status_gne__c = 'Inactive';
        update rb;
        Test.stopTest();

        fundRequest = [SELECT Status_gne__c FROM EMS_Fund_Request_gne__c WHERE Id = :fundRequest.Id];
        System.assertEquals('New', fundRequest.Status_gne__c);
    }

    public static testMethod void deleteFundRequestOnDeleteTest() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 5 * amount, rsmUser);
        Integer fundCount = 5;
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, amount / 10, fundCount);

        System.assertEquals(fundCount, [SELECT count() FROM EMS_Fund_Request_gne__c WHERE Related_Region_Budget_gne__c IN :regionBudgets]);
        Test.startTest();
        delete regionBudgets;
        Test.stopTest();
        System.assertEquals(0, [SELECT count() FROM EMS_Fund_Request_gne__c WHERE Related_Region_Budget_gne__c IN :regionBudgets]);
    }

    public static testMethod void deleteBudgetAllocationsOnDeleteTest() {
        String etype = 'Sponsorship';
        String esubtype = 'Sponsorship of Events';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 5 * amount, rsmUser);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today(), Date.today() + 3, amount * 2, regionBudgets.size());

        Test.startTest();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        for (Integer i = 0; i < regionBudgets.size(); i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;
        System.assertEquals(regionBudgets.size(), [SELECT count() FROM EMS_Budget_Allocation_gne__c WHERE EMS_Region_Budget_gne__c IN :regionBudgets]);
        delete regionBudgets;
        Test.stopTest();
        System.assertEquals(0, [SELECT count() FROM EMS_Budget_Allocation_gne__c WHERE EMS_Region_Budget_gne__c IN :regionBudgets]);
    }

    private static testMethod void reasignFRApproverOnOwnerChange_Test() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null, new Set<Id>{
                rsmUser
        });
        Id rsmUser2 = rsmUsers[0];
        System.assertNotEquals(rsmUser2, rsmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 5 * amount, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -1 * (amount / 2), 1, true);

        Test.startTest();
        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(fr.Id);
            req.setComments('Submit step comment.');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);
        for (Approval.ProcessResult res : apprRequestsResults) {
            System.assertEquals(true, res.isSuccess());
            System.assertEquals('Pending', res.getInstanceStatus(), 'Wrong instance Status: ' + res.getInstanceStatus());
        }

        // Change region budget Owners
        for (EMS_Budget_Region_gne__c rb :regionBudgets) {
            rb.Assigned_to_gne__c = rsmUser2;
        }
        update regionBudgets;

        for (EMS_Fund_Request_gne__c fr : [SELECT Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE Id IN :fundRequests]) {
            System.assertEquals(rsmUser2, fr.Approver_gne__c);
        }

        // Find FR have approval process in progress
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :fundRequests];
        System.assertEquals(regionBudgets.size(), piwi.size());

        Test.stopTest();
    }
}