@isTest
private class EMS_Fund_Request_Edit_Create_Ext_Test {

    private static final Integer BATCH_SIZE = 1;

    static testMethod void initControllerWithNewFR() {

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createTerritoryBudgetForEachRB(BATCH_SIZE, regionBudgets, 0.0, 300.0, rsmUser);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, Date.Today() + 1, 1, false);

        ApexPages.currentPage().getParameters().put('productId', productBudgets[0].Id);
        ApexPages.currentPage().getParameters().put('regionId', regionBudgets[0].Id);
        ApexPages.currentPage().getParameters().put('territoryId', territoryBudgets[0].Id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(fundRequests[0]);
        EMS_Fund_Request_Edit_Create_Ext ctrl = new EMS_Fund_Request_Edit_Create_Ext(stdCtrl);
    }


    static testMethod void initControllerWithExistingFR() {

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createTerritoryBudgetForEachRB(BATCH_SIZE, regionBudgets, 0.0, 300.0, rsmUser);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, Date.Today() + 1, 1, true);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(fundRequests[0]);
        EMS_Fund_Request_Edit_Create_Ext ctrl = new EMS_Fund_Request_Edit_Create_Ext(stdCtrl);
    }

    static testMethod void resubmitForApprovalExistingFR() {

        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);

        EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = true;

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1);

        ApexPages.currentPage().getParameters().put('isResubmit', 'true');
        ApexPages.currentPage().getParameters().put('resubmitId', fundRequests[0].Id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(fundRequests[0]);
        EMS_Fund_Request_Edit_Create_Ext ctrl = new EMS_Fund_Request_Edit_Create_Ext(stdCtrl);
        
/*        List<Approval.ProcessSubmitRequest> apprRequests = new List<Approval.ProcessSubmitRequest>();
        
		for (EMS_Fund_Request_gne__c fr : fundRequests) {
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setObjectId(fr.Id);
			apprRequests.add(req);
		}
		
		List<Approval.ProcessResult> apprRequestsResults = Approval.process(apprRequests); */

        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            fr.Status_gne__c = 'Submitted';
        }

        update fundRequests;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            ctrl.resubmit();

            ctrl.cancelResubmit();
        }
    }


}