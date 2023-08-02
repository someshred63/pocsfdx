@isTest
private class GNE_User_Delegation_Child_Rec_Upd_Test {

    private static final Integer BATCH_SIZE = 10;
    private static final String COST_CENTER_NAME = 'Commercial Product';
    private static final RecordType productBudgetAllocationRT = [SELECT Id FROM RecordType WHERE sObjectType = 'EMS_Budget_Allocation_gne__c' AND DeveloperName = 'Product_Budget_Allocation' LIMIT 1];


    @isTest
    private static void reasignFRApproverOnDelegationInsert_Test() {
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
        productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 500, pmUser, COST_CENTER_NAME, BATCH_SIZE);
        regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
        fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, true);

        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(fr.Id);
            req.setComments('Submit step comment.');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);

        Test.startTest();
        GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser, rsmUser, Date.today(), Date.today() + 3, 'Test user delegation');
        Test.stopTest();

        for (EMS_Fund_Request_gne__c fr : [SELECT Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE Id IN :fundRequests]) {
            System.assertEquals(rsmUser, fr.Approver_gne__c);
        }
    }

    @isTest
    private static void reasignFRApproverOnDelegationUpdate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser1 = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser1);
        System.assertNotEquals(null, rsmUser);

        Id pmUser2 = EMS_Test_Util.findExistingUser('PM', null, new Set<Id>{
                pmUser1
        })[0];
        System.assertNotEquals(pmUser1, pmUser2);

        List<EMS_Budget_Product_gne__c> productBudgets;
        List<EMS_Budget_Region_gne__c> regionBudgets;
        List<EMS_Fund_Request_gne__c> fundRequests;

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 500, pmUser1, COST_CENTER_NAME, BATCH_SIZE);
        regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
        fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, true);

        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(fr.Id);
            req.setComments('Submit step comment.');
            apprRequests.add(req);
        }
        List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);

        GNE_User_Delegation__c userdelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today() + 1, Date.today() + 3, 'Test user delegation');
        for (EMS_Fund_Request_gne__c fr : [SELECT Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE Id IN :fundRequests]) {
            System.assertEquals(pmUser1, fr.Approver_gne__c);
        }

        Test.startTest();
        userdelegation.Start_Date__c = Date.today();
        update userdelegation;
        Test.stopTest();

        for (EMS_Fund_Request_gne__c fr : [SELECT Approver_gne__c FROM EMS_Fund_Request_gne__c WHERE Id IN :fundRequests]) {
            System.assertEquals(pmUser2, fr.Approver_gne__c);
        }
    }
/*
	//MANAGER_NOT_DEFINED, Manager undefined.:
	@isTest
	private static void reasignEmsEventApproverOnDelegationInsert_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','PM');
		Id pmUser1 = ids[0];
		Id pmUser2 = ids[1];
		System.assertNotEquals(pmUser1, pmUser2);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 2, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser1, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0].Id);

		List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser1, 'Sponsorship', 'Sponsorship of Events', Date.today()+1, Date.today()+3, 100, BATCH_SIZE);
		EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);       
    	EMS_Test_Util.createAttachments(events, 'Letter of Request');

		List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
		for (EMS_Event__c ev : events) {
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(ev.Id);
			req.setComments('Submit step comment.');
			apprRequests.add(req);
		}	
		List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests); 

		for (EMS_Event__c event : [SELECT Approver_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
			System.assertEquals(pmUser1, event.Approver_gne__c);
		}

		Test.startTest();
		GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today(), Date.today()+3 , 'Test user delegation');
		Test.stopTest();

		for (EMS_Event__c event : [SELECT Approver_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
			System.assertEquals(pmUser2, event.Approver_gne__c);
		} 
	}


	//MANAGER_NOT_DEFINED, Manager undefined.:
	@isTest
	private static void reasignEmsEventApproverOnDelegationUpdate_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
		Id pmUser1 = ids[0];
		Id rsmUser = ids[1];
		System.assertNotEquals(null, pmUser1);
		System.assertNotEquals(null, rsmUser);

		Id pmUser2 = EMS_Test_Util.findExistingUser('PM', null, new Set<Id>{pmUser1})[0];
		System.assertNotEquals(pmUser1, pmUser2);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 2, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser1, costCenters[0].Id);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser2, costCenters[1].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
		List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser1, 'Sponsorship', 'Sponsorship of Events', Date.today()+1, Date.today()+3, 100, BATCH_SIZE);
		List<EMS_Budget_Allocation_gne__c> budgetAllocations = EMS_Test_Util.prepareBudgetAllocations(productBudgetAllocationRT.Id, 100, pb.Assigned_to_gne__c, events, pb.Id, null, null);
		EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 100.0, pb.Assigned_to_gne__c, events, pb.Id, null, null);       
    	EMS_Test_Util.createAttachments(events, 'Letter of Request');
       
        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
		for (EMS_Event__c ev : events) {
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(ev.Id);
			req.setComments('Submit step comment.');
			apprRequests.add(req);
		}	
		List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests); 

		for(EMS_Event__c event : [ SELECT Approver_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
			System.assertEquals(pmUser1, event.Approver_gne__c);
		}

		GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today() + 1, Date.today()+3 , 'Test user delegation');
		
		for(EMS_Event__c event : [ SELECT Approver_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
			System.assertEquals(pmUser1, event.Approver_gne__c);
		}

		Test.startTest();
		userDelegation.Start_Date__c = Date.today();
		update userDelegation;
		Test.stopTest();

		for(EMS_Event__c event : [ SELECT Approver_gne__c FROM EMS_Event__c WHERE Id IN :events ]) {
			System.assertEquals(pmUser2, event.Approver_gne__c);
		} 
	}  

	//MANAGER_NOT_DEFINED, Manager undefined.:
	@isTest
	private static void reasignBudgetAllocationApproverOnDelegationInsert_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
		Id pmUser1 = ids[0];
		Id rsmUser = ids[1];
		System.assertNotEquals(null, pmUser1);
		System.assertNotEquals(null, rsmUser);

		Id pmUser2 = EMS_Test_Util.findExistingUser('PM', null, new Set<Id>{pmUser1})[0];
		System.assertNotEquals(pmUser1, pmUser2);
		
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 2, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser1, costCenters[0].Id);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser2, costCenters[1].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        EMS_Test_Util.createEventConfiguration('Sponsorship', 'Sponsorship of Events', 'Pending Budget Approval');

		List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser1, 'Sponsorship', 'Sponsorship of Events', Date.today()+1, Date.today()+3, 1, BATCH_SIZE);
		List<EMS_Budget_Allocation_gne__c> budgetAllocations = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createAttachments(events, 'Letter of Request');

        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
		for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(ba.Id);
			req.setComments('Submit step comment.');
			apprRequests.add(req);
		}	
		List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);

		for (EMS_Budget_Allocation_gne__c ba : [SELECT Approver_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]) {
			System.assertEquals(pmUser1, ba.Approver_gne__c);
		}

		Test.startTest();
		GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today(), Date.today()+3 , 'Test user delegation');
		Test.stopTest();

		for (EMS_Budget_Allocation_gne__c ba : [SELECT Approver_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]) {
			System.assertEquals(pmUser2, ba.Approver_gne__c);
		} 
	}

	//MANAGER_NOT_DEFINED, Manager undefined.:
	@isTest
	private static void reasignBudgetAllocationApproverOnDelegationUpdate_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
		Id pmUser1 = ids[0];
		Id rsmUser = ids[1];
		System.assertNotEquals(null, pmUser1);
		System.assertNotEquals(null, rsmUser);

		Id pmUser2 = EMS_Test_Util.findExistingUser('PM', null, new Set<Id>{pmUser1})[0];
		System.assertNotEquals(pmUser1, pmUser2);
		
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 2, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser1, costCenters[0].Id);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser2, costCenters[1].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        EMS_Test_Util.createEventConfiguration('Sponsorship', 'Sponsorship of Events', 'Pending Budget Approval');

		List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser1, 'Sponsorship', 'Sponsorship of Events', Date.today()+1, Date.today()+3, 1, BATCH_SIZE);
		List<EMS_Budget_Allocation_gne__c> budgetAllocations = EMS_Test_Util.createBudgetAllocations(productBudgetAllocationRT.Id, 1, pb.Assigned_to_gne__c, events, pb.Id, null, null);
        EMS_Test_Util.createAttachments(events, 'Letter of Request');

		List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
		for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(ba.Id);
			req.setComments('Submit step comment.');
			apprRequests.add(req);
		}	
		List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests);

		for(EMS_Budget_Allocation_gne__c ba : [SELECT Approver_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]) {
			System.assertEquals(pmUser1, ba.Approver_gne__c);
		}

		GNE_User_Delegation__c userDelegation = EMS_Test_Util.createUserDelegation(pmUser1, pmUser2, Date.today() + 1, Date.today()+3 , 'Test user delegation');

		for(EMS_Budget_Allocation_gne__c ba : [ SELECT Approver_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]) {
			System.assertEquals(pmUser1, ba.Approver_gne__c);
		}

		Test.startTest();
		userDelegation.Start_Date__c = Date.today();
		update userdelegation;
		Test.stopTest();

		for(EMS_Budget_Allocation_gne__c ba : [ SELECT Approver_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations ]) {
			System.assertEquals(pmUser2, ba.Approver_gne__c);
		} 
	}  */
}