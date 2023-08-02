@isTest
private class EMS_Product_Budget_Child_Rec_Update_Test {

    private static final Integer BATCH_SIZE = 101;
    private static final String COST_CENTER_NAME = 'Commercial Product';
    private static Decimal plannedExpenses = 10;

	/**
	 * 1. shareProductBudgetWithTerritory [aI,aU]
	 * 2. deactivateChildBudgets [aU]
	 * 3. deleteBudgetAllocations [bD]
	 * 4. reasignFRApproverOnOwnerChange [aU]
	 */

    //1.1 shareProductBudgetWithTerritory
    private static testMethod void shareProductBudgetWithTerritory_testConditions_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmTestUsers.size());

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        List<EMS_Budget_Product_gne__c> productBudgets;
        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        String rowCause = Schema.EMS_Budget_Product_gne__Share.RowCause.Territory_Sharing__c;
        List<EMS_Budget_Product_gne__Share> productShares = [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :productBudgets AND RowCause = :rowCause];

        System.assertEquals(productBudgets.size(), productShares.size());
        for (EMS_Budget_Product_gne__Share ps : productShares) {
            System.assertEquals(rowCause, ps.RowCause);
            System.assertEquals('Edit', ps.AccessLevel);
        }

        // Update
        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            pb.Start_Date_gne__c = Date.today() - 1;
        }

        try {
            update productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        productShares = [SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :productBudgets AND RowCause = :rowCause];
        System.assertEquals(productBudgets.size(), productShares.size());
        for (EMS_Budget_Product_gne__Share ps : productShares) {
            System.assertEquals(rowCause, ps.RowCause);
            System.assertEquals('Edit', ps.AccessLevel);
        }
    }

    //2.1 deactivateChildBudgets
    private static testMethod void deactivateChildBudgets_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets;
        List<EMS_Budget_Region_gne__c> regionBudgets;
        List<EMS_Fund_Request_gne__c> fundRequests;

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 500, pmUser, COST_CENTER_NAME, BATCH_SIZE);
            regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
            fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, true);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.startTest();
        // Update
        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            pb.Status_gne__c = 'Inactive';
        }
        try {
            update productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        for (EMS_Budget_Product_gne__c pb : [SELECT Status_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assertEquals('Inactive', pb.Status_gne__c);
        }

        for (EMS_Budget_Region_gne__c rb : [SELECT Status_gne__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
            System.assertEquals('Inactive', rb.Status_gne__c);
        }

        for (EMS_Fund_Request_gne__c fr : [SELECT Id, Status_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
            system.assertEquals('Rejected', fr.Status_gne__c);
        }
        Test.stopTest();
    }

    //3.1 deleteBudgetAllocations.
    private static testMethod void deleteBudgetAllocations_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmTestUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        // Add budget allcoation
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmTestUsers.get(0), 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 10,
                    Budget_Owner_gne__c = pmTestUsers.get(0),
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    Percentage_Contribution_gne__c = 20,
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;
        System.assertEquals(BATCH_SIZE, budgetAllocations.size());

        delete productBudgets;
        budgetAllocations = [SELECT Id FROM EMS_Budget_Allocation_gne__c WHERE id IN:budgetAllocations];
        System.assertEquals(0, budgetAllocations.size());

        Test.stopTest();
    }

    //4. reasignFRApproverOnOwnerChange
    private static testMethod void reasignFRApproverOnOwnerChange_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];


        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null, new Set<Id>{
                pmUser
        });
        Id pmUser2 = pmUsers[0];

        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets;
        List<EMS_Budget_Region_gne__c> regionBudgets;
        List<EMS_Fund_Request_gne__c> fundRequests;

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 500, pmUser, COST_CENTER_NAME, BATCH_SIZE);
            regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
            fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, true);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.startTest();
        // Submit for approval
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

        //change PB Owner
        List<EMS_Budget_Product_gne__c> pbToUpdate = new List<EMS_Budget_Product_gne__c>();
        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            pb.Assigned_to_gne__c = pmUser2;
            pbToUpdate.add(pb);
        }
        update pbToUpdate;

        for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c, Status_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
            System.assertEquals(pmUser2, fr.Approver_gne__c);
        }

        // Find FR have approval process in progress
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :fundRequests];
        System.assertEquals(BATCH_SIZE, piwi.size());
        Test.stopTest();
    }
}