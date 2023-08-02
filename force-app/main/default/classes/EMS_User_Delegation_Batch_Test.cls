@isTest
private class EMS_User_Delegation_Batch_Test {
    private static final Integer BATCH_SIZE = 101;
    private static final String COST_CENTER_NAME = 'Commercial Product';
    private static final RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];

    //1. reasignFRApproverOnUserDelegation Activation
    private static testMethod void reasignFRApproverOnDelegationActivate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id pmUser2 = EMS_Test_Util.findExistingUser('PM', null, new Set<Id>{
                pmUser
        })[0];

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(testU) {
            insert fundRequests;

            List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(fr.Id);
                req.setComments('Submit step comment.');
                apprRequests.add(req);
            }

            List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);
        }

        for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c, Status_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
            System.assertEquals(pmUser, fr.Approver_gne__c);
        }

        GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser, pmUser2, Date.today(), Date.today() + 3, 'Test user delegation');

        Test.startTest();

        Database.executeBatch(new EMS_User_Delegation_Batch());

        Test.stopTest();

        for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c, Status_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
            System.assertEquals(pmUser2, fr.Approver_gne__c);
        }
    }

    private static testMethod void reasignFRApproverOnDelegationInsert_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id pmUser2 = EMS_Test_Util.findExistingUser('PM', null, new Set<Id>{
                pmUser
        })[0];

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, false);

        User testU = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(testU) {
            insert fundRequests;

            List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setObjectId(fr.Id);
                req.setComments('Submit step comment.');
                apprRequests.add(req);
            }

            List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);
        }

        for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c, Status_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
            System.assertEquals(pmUser, fr.Approver_gne__c);
        }

        Test.startTest();

        GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser, pmUser2, Date.today(), Date.today() + 3, 'Test user delegation');

        Test.stopTest();

        for (EMS_Fund_Request_gne__c fr : [SELECT Id, Approver_gne__c, Status_gne__c FROM EMS_Fund_Request_gne__c WHERE id IN :fundRequests]) {
            System.assertEquals(pmUser2, fr.Approver_gne__c);
        }
    }

    private static testMethod void reasignEventApproverOnDelegationActivate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'PM');
        Id pmUser1 = ids[0];
        Id pmUser2 = ids[1];
        System.assertNotEquals(null, pmUser1);
        System.assertNotEquals(null, pmUser2);
        System.assertNotEquals(pmUser1, pmUser2);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser1, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Grants', 'Grant in Aid Education - Individual', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser1, 'Grants', 'Grant in Aid Education - Individual', Date.today(), Date.today() + 1, 100, BATCH_SIZE);
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createAttachments(events, 'Letter of Request');

        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(event.Id);
            req.setComments('Submit step comment.');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);
        GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today(), Date.today() + 3, 'Test user delegation');

        Test.startTest();
        Database.executeBatch(new EMS_User_Delegation_Batch());
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Approver_gne__c FROM EMS_Event__c WHERE id IN :events]) {
            System.assertEquals(pmUser2, event.Approver_gne__c);
        }
    }

    private static testMethod void reasignEventApproverOnDelegationInsert_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'PM');
        Id pmUser1 = ids[0];
        Id pmUser2 = ids[1];
        System.assertNotEquals(null, pmUser1);
        System.assertNotEquals(null, pmUser2);
        System.assertNotEquals(pmUser1, pmUser2);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser1, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Grants', 'Grant in Aid Education - Individual', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser1, 'Grants', 'Grant in Aid Education - Individual', Date.today(), Date.today() + 1, 100, BATCH_SIZE);
        EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createAttachments(events, 'Letter of Request');

        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Event__c event : events) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(event.Id);
            req.setComments('Submit step comment.');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);

        Test.startTest();
        GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today(), Date.today() + 3, 'Test user delegation');
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Approver_gne__c FROM EMS_Event__c WHERE id IN :events]) {
            System.assertEquals(pmUser2, event.Approver_gne__c);
        }
    }

    private static testMethod void reasignBudgetAllocationApproverOnDelegationActivate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'PM');
        Id pmUser1 = ids[0];
        Id pmUser2 = ids[1];
        System.assertNotEquals(null, pmUser1);
        System.assertNotEquals(null, pmUser2);
        System.assertNotEquals(pmUser1, pmUser2);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser1, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Non-promotional program', 'Non-promotional program', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser1, 'Non-promotional program', 'Non-promotional program', Date.today(), Date.today() + 1, 100, BATCH_SIZE);
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createAttachments(events, 'Letter of Request');
        EMS_Test_Util.createEventConfiguration('Non-promotional program', 'Non-promotional program', 'Pending Medical Manager Review');

        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Budget_Allocation_gne__c budgetAllocation : budgetAllocations) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(budgetAllocation.Id);
            req.setComments('Submit step comment.');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);

        GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today(), Date.today() + 3, 'Test user delegation');
        Test.startTest();
        Database.executeBatch(new EMS_User_Delegation_Batch());
        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Approver_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(pmUser2, ba.Approver_gne__c);
        }
    }

    private static testMethod void reasignBudgetAllocationApproverOnDelegationInsert_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'PM');
        Id pmUser1 = ids[0];
        Id pmUser2 = ids[1];
        System.assertNotEquals(null, pmUser1);
        System.assertNotEquals(null, pmUser2);
        System.assertNotEquals(pmUser1, pmUser2);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser1, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Non-promotional program', 'Non-promotional program', costCenters[0]);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser1, 'Non-promotional program', 'Non-promotional program', Date.today(), Date.today() + 1, 100, BATCH_SIZE);
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createAttachments(events, 'Letter of Request');
        EMS_Test_Util.createEventConfiguration('Non-promotional program', 'Non-promotional program', 'Pending Medical Manager Review');

        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Budget_Allocation_gne__c budgetAllocation : budgetAllocations) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(budgetAllocation.Id);
            req.setComments('Submit step comment.');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);

        Test.startTest();
        GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today(), Date.today() + 3, 'Test user delegation');
        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Approver_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(pmUser2, ba.Approver_gne__c);
        }
    }
}