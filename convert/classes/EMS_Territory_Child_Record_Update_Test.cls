@isTest
private class EMS_Territory_Child_Record_Update_Test {

    private static Integer BATCH_SIZE = 2;//101;

    public static testMethod void moveFundsUponInsertTest() {
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 5 * amount, rsmUser);

        Test.startTest();
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, amount, repUser);
        Test.stopTest();

        for (EMS_Budget_Region_gne__c rb : [SELECT Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(amount, rb.Child_Budgets_Allocated_Amount_gne__c);
        }
    }

    public static testMethod void shareBudgetWithTerritoryOnInsertTest() {
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 5 * amount, rsmUser);

        Test.startTest();
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, amount, repUser);
        Test.stopTest();

        String rowCause = Schema.EMS_Budget_Territory_gne__Share.RowCause.Territory_Sharing__c;
        List<EMS_Budget_Territory_gne__Share> btShares = [SELECT AccessLevel FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :territoryBudgets AND RowCause = :rowCause];
        System.assertEquals(territoryBudgets.size(), btShares.size());
        for (EMS_Budget_Territory_gne__Share btShare : btShares) {
            System.assertEquals('Edit', btShare.AccessLevel);
        }

        rowCause = Schema.EMS_Budget_Territory_gne__Share.RowCause.Product_Budget_Sharing__c;
        btShares = [SELECT AccessLevel FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :territoryBudgets AND RowCause = :rowCause];
        System.assertEquals(territoryBudgets.size(), btShares.size());
        for (EMS_Budget_Territory_gne__Share btShare : btShares) {
            System.assertEquals('Read', btShare.AccessLevel);
        }

        rowCause = Schema.EMS_Budget_Region_gne__Share.RowCause.Child_Territory_Sharing__c;
        List<EMS_Budget_Region_gne__Share> brShares = [SELECT AccessLevel FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCause];
        System.assertEquals(territoryBudgets.size(), brShares.size());
        for (EMS_Budget_Region_gne__Share brShare : brShares) {
            System.assertEquals('Read', brShare.AccessLevel);
        }
    }

    public static testMethod void moveFundsUponUpdateTest() {
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 5 * amount, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, amount, repUser);
        for (EMS_Budget_Region_gne__c rb : [SELECT Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(amount, rb.Child_Budgets_Allocated_Amount_gne__c);
        }

        Test.startTest();
        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            tb.Total_Territory_Funds_Approved_gne__c = amount * 2;
        }
        update territoryBudgets;
        Test.stopTest();

        for (EMS_Budget_Region_gne__c rb : [SELECT Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals(amount * 2, rb.Child_Budgets_Allocated_Amount_gne__c);
        }
    }

    public static testMethod void deleteFundRequestOnDeleteTest() {
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 5 * amount, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, amount, repUser);

        List<EMS_Fund_Request_gne__c> fundRequests = new List<EMS_Fund_Request_gne__c>();
        for (EMS_Budget_Territory_gne__c tb :territoryBudgets) {
            fundRequests.add(EMS_Test_Util.prepareFundRequest('Territory Fund De-Allocation', null, tb.EMS_Budget_Region_gne__c, tb.Id, -1 * amount / 10, Date.today().addDays(5)));
        }
        insert fundRequests;
        System.assertEquals(territoryBudgets.size(), [SELECT count() FROM EMS_Fund_Request_gne__c WHERE Related_Territory_Budget_gne__c IN :territoryBudgets]);

        Test.startTest();
        delete territoryBudgets;
        Test.stopTest();

        System.assertEquals(0, [SELECT count() FROM EMS_Fund_Request_gne__c WHERE Related_Territory_Budget_gne__c IN :territoryBudgets]);
    }

    public static testMethod void deleteBudgetAllocationsOnDeleteTest() {
        Decimal amount = 100;
        String etype = 'Sponsorship';
        String esubtype = 'Sponsorship of Events';

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM', 'Rep');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        Id repUser = ids[2];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 10 * amount, pmUser, costCenters);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 5 * amount, rsmUser);
        EMS_Budget_Territory_gne__c territoryBudget = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, amount, repUser)[0];

        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today(), Date.today() + 1, amount * 2, BATCH_SIZE);

        Test.startTest();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Owner_gne__c = repUser,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
                    EMS_Territory_Budget_gne__c = territoryBudget.Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
        insert budgetAllocations;

        System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Allocation_gne__c WHERE EMS_Territory_Budget_gne__c = :territoryBudget.Id]);
        delete territoryBudget;
        Test.stopTest();
        System.assertEquals(0, [SELECT count() FROM EMS_Budget_Allocation_gne__c WHERE EMS_Territory_Budget_gne__c = :territoryBudget.Id]);
    }

    private static testMethod void reasignFRApproverOnOwnerChange_Test() {
        Decimal amount = 100;

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<Id> ids1 = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser_new = ids1[0];
        Id repUser = ids1[1];
        System.assertNotEquals(null, repUser);
        System.assertNotEquals(null, rsmUser_new);
        System.assertNotEquals(repUser, rsmUser_new);

        List<EMS_Budget_Product_gne__c> productBudgets;
        List<EMS_Budget_Region_gne__c> regionBudgets;
        List<EMS_Budget_Territory_gne__c> territoryBudgets;
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, 10 * amount, pmUser, costCenters);
        regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 3 * amount, rsmUser);
        territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, amount, repUser);

        List<EMS_Fund_Request_gne__c> fundRequests = new List<EMS_Fund_Request_gne__c>();
        for (EMS_Budget_Territory_gne__c tb :territoryBudgets) {
            fundRequests.add(EMS_Test_Util.prepareFundRequest('Territory Fund De-Allocation', null, tb.EMS_Budget_Region_gne__c, tb.Id, -1 * amount / 2, Date.today().addDays(5)));
        }
        insert fundRequests;

        Test.startTest();
        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(fr.Id);
            req.setComments('Submit');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);
        for (Approval.ProcessResult res : apprRequestsResults) {
            System.assertEquals(true, res.isSuccess());
            System.assertEquals('Pending', res.getInstanceStatus(), 'Wrong instance Status: ' + res.getInstanceStatus());
        }

        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            tb.Assigned_to_gne__c = rsmUser_new;
        }
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;
        update territoryBudgets;
        Test.stopTest();

        for (EMS_Fund_Request_gne__c fr : [SELECT Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE Id IN :fundRequests]) {
            System.assertEquals(rsmUser_new, fr.Approver_gne__c);
        }
        List<ProcessInstanceWorkitem> piwi = [SELECT ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :fundRequests];
        System.assertEquals(fundRequests.size(), piwi.size());
    }
}