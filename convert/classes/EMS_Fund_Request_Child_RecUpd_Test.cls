@isTest
private class EMS_Fund_Request_Child_RecUpd_Test {

    private static final Integer BATCH_SIZE = 10;

	/**
	 * Tests List:
	 * 1. PB to RB FR-Allocation
	 * 2. PB to RB FR-Allcoation - delete FR  
	 * 3. PB to RB FR-De Allocation
     * 4. PB to RB FR-De Allcoation - delete FR 
     * 
	 * 5. RB to TB FR-Allcoation
	 * 6. RB to TB FR-Allocation - delete FR
	 * 7. RB to TB FR-DE Allocation	
	 * 8. RB to TB FR-De Allocation - delete FR
	 * 9. Share with approver
	 */
	
	/**
	 * Product to Region
	 */

    // 1. PB to RB FR-Allocation
    private static testMethod void pbToRB_Allocation_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1);

            Test.startTest();

            for (EMS_Fund_Request_gne__c fundRequest : fundRequests) {
                fundRequest.Status_gne__c = 'Approved';
            }
            update fundRequests;

            Test.stopTest();

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(350, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(650, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(350, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(350, rbNew.Region_Balance_gne__c);
            }
        }
    }

    // 2. PB to RB FR-Allcoation - delete FR
    private static testMethod void pbToRB_AllocationDelete_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1);

            Test.startTest();

            for (EMS_Fund_Request_gne__c fundRequest : fundRequests) {
                fundRequest.Status_gne__c = 'Approved';
            }
            update fundRequests;

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(350, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(650, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(350, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(350, rbNew.Region_Balance_gne__c);
            }

            EMS_Fund_Request_Trigger_Helper.clearProcessedSet();

            delete fundRequests;

            Test.stopTest();

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(300, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(700, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(300, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(300, rbNew.Region_Balance_gne__c);
            }
        }
    }

    // 3. PB to RB FR-De Allocation
    private static testMethod void pbToRB_DeAllocation_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, 1);

            Test.startTest();

            for (EMS_Fund_Request_gne__c fundRequest : fundRequests) {
                fundRequest.Status_gne__c = 'Approved';
            }
            update fundRequests;

            Test.stopTest();

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(250, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(750, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(250, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(250, rbNew.Region_Balance_gne__c);
            }
        }
    }

    // 4. PB to RB FR-De Allcoation - delete FR
    private static testMethod void pbToRB_DeAllocationDelete_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 300.0, rsmUser);
            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, 1);

            Test.startTest();

            for (EMS_Fund_Request_gne__c fundRequest : fundRequests) {
                fundRequest.Status_gne__c = 'Approved';
            }
            update fundRequests;

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(250, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(750, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(250, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(250, rbNew.Region_Balance_gne__c);
            }
            EMS_Fund_Request_Trigger_Helper.clearProcessedSet();

            delete fundRequests;

            Test.stopTest();

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(300, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(700, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(300, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(300, rbNew.Region_Balance_gne__c);
            }
        }
    }


    // Region to Territory
    // 5. RB to TB FR-Allcoation
    private static testMethod void rbToTB_Allocation_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, 1);

            Test.startTest();

            for (EMS_Fund_Request_gne__c fundRequest : fundRequests) {
                fundRequest.Status_gne__c = 'Approved';
            }
            update fundRequests;

            Test.stopTest();

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(600, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(400, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Budget_Allocated_Amount_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(600, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(350, rbNew.Region_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount_gne__c
                system.assertEquals(250, rbNew.Region_Balance_gne__c);
            }

            for (EMS_Budget_Territory_gne__c tbNew : [SELECT Id, Total_Territory_Funds_Approved_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
                system.assertEquals(350, tbNew.Total_Territory_Funds_Approved_gne__c);
            }
        }
    }

    // 6. RB to TB FR-Allocation - delete FR
    private static testMethod void rbToTB_AllocationDelete_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, 1);

            Test.startTest();

            for (EMS_Fund_Request_gne__c fundRequest : fundRequests) {
                fundRequest.Status_gne__c = 'Approved';
            }
            update fundRequests;

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(600, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(400, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Budget_Allocated_Amount_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(600, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(350, rbNew.Region_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount_gne__c
                system.assertEquals(250, rbNew.Region_Balance_gne__c);
            }

            for (EMS_Budget_Territory_gne__c tbNew : [SELECT Id, Total_Territory_Funds_Approved_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
                system.assertEquals(350, tbNew.Total_Territory_Funds_Approved_gne__c);
            }

            EMS_Fund_Request_Trigger_Helper.clearProcessedSet();

            delete fundRequests;


            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(600, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(400, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Budget_Allocated_Amount_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(600, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(300, rbNew.Region_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount_gne__c
                system.assertEquals(300, rbNew.Region_Balance_gne__c);
            }

            for (EMS_Budget_Territory_gne__c tbNew : [SELECT Id, Total_Territory_Funds_Approved_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
                system.assertEquals(300, tbNew.Total_Territory_Funds_Approved_gne__c);
            }

            Test.stopTest();
        }
    }

    // 7. RB to TB FR-DE Allocation
    private static testMethod void rbToTB_DeAllocation_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, 1);

            Test.startTest();

            for (EMS_Fund_Request_gne__c fundRequest : fundRequests) {
                fundRequest.Status_gne__c = 'Approved';
            }
            update fundRequests;

            Test.stopTest();

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(600, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(400, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Budget_Allocated_Amount_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(600, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(250, rbNew.Region_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount_gne__c
                system.assertEquals(350, rbNew.Region_Balance_gne__c);
            }

            for (EMS_Budget_Territory_gne__c tbNew : [SELECT Id, Total_Territory_Funds_Approved_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
                system.assertEquals(250, tbNew.Total_Territory_Funds_Approved_gne__c);
            }
        }
    }

    // 8. RB to TB FR-DeAllocation - delete FR
    private static testMethod void rbToTB_DeAllocationDelete_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, 1);

            Test.startTest();

            for (EMS_Fund_Request_gne__c fundRequest : fundRequests) {
                fundRequest.Status_gne__c = 'Approved';
            }
            update fundRequests;

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(600, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(400, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Budget_Allocated_Amount_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(600, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(250, rbNew.Region_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount_gne__c
                system.assertEquals(350, rbNew.Region_Balance_gne__c);
            }

            for (EMS_Budget_Territory_gne__c tbNew : [SELECT Id, Total_Territory_Funds_Approved_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
                system.assertEquals(250, tbNew.Total_Territory_Funds_Approved_gne__c);
            }

            EMS_Fund_Request_Trigger_Helper.clearProcessedSet();
            delete fundRequests;

            for (EMS_Budget_Product_gne__c pbNew : [SELECT Id, Product_Budget_Allocated_Amount_gne__c, Product_Balance_gne__c FROM EMS_Budget_Product_gne__c WHERE Id = :productBudgets]) {
                system.assertEquals(600, pbNew.Product_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount__c
                system.assertEquals(400, pbNew.Product_Balance_gne__c);
            }

            for (EMS_Budget_Region_gne__c rbNew : [SELECT Id, Total_Region_Funds_Approved_gne__c, Region_Budget_Allocated_Amount_gne__c, Region_Balance_gne__c FROM EMS_Budget_Region_gne__c WHERE Id = :regionBudgets]) {
                system.assertEquals(600, rbNew.Total_Region_Funds_Approved_gne__c);
                system.assertEquals(300, rbNew.Region_Budget_Allocated_Amount_gne__c); // Child_Budgets_Allocated_Amount_gne__c + Events_Allocated_Amount_gne__c
                system.assertEquals(300, rbNew.Region_Balance_gne__c);
            }

            for (EMS_Budget_Territory_gne__c tbNew : [SELECT Id, Total_Territory_Funds_Approved_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
                system.assertEquals(300, tbNew.Total_Territory_Funds_Approved_gne__c);
            }

            Test.stopTest();
        }
    }

    // 9. Share with parent territory PB -> RB Region Fund Allocation
    private static testMethod void pbToRB_AllocationShare_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        String rowCauseParentBudget = Schema.EMS_Fund_Request_gne__Share.RowCause.Parent_Budget_Sharing__c;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);

            Test.startTest();

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1);

            Test.stopTest();

            System.assertEquals(BATCH_SIZE * 2, [SELECT count() FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :fundRequests AND RowCause = :rowCauseParentBudget]);

            Set<Id> parentBudgetTerritoryIds = new Set<Id>();
            for (EMS_Budget_Region_gne__c rb : [SELECT Assigned_To_Territory_Id_gne__c, EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
                parentBudgetTerritoryIds.add(rb.Assigned_To_Territory_Id_gne__c);
                parentBudgetTerritoryIds.add(rb.EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c);
            }

            List<Id> relatedGroupIds = EMS_Util.getTerritoriesGroups(parentBudgetTerritoryIds).values();
            for (EMS_Fund_Request_gne__Share frShare : [SELECT Id, RowCause, Accesslevel, UserOrGroupId FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :fundRequests AND RowCause = :rowCauseParentBudget]) {
                System.assertEquals('Edit', frShare.Accesslevel);
                System.assert(relatedGroupIds.contains(frShare.UserOrGroupId), relatedGroupIds + '  ' + frShare.UserOrGroupId);
            }
        }
    }

    // 10. Share with parent territory PB -> RB Region Fund De-Allocation
    private static testMethod void pbToRB_DeAllocationShare_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        String rowCauseParentBudget = Schema.EMS_Fund_Request_gne__Share.RowCause.Parent_Budget_Sharing__c;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);

            Test.startTest();

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, 1);

            Test.stopTest();

            System.assertEquals(BATCH_SIZE * 2, [SELECT count() FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :fundRequests AND RowCause = :rowCauseParentBudget]);

            Set<Id> parentBudgetTerritoryIds = new Set<Id>();
            for (EMS_Budget_Region_gne__c rb : [SELECT Assigned_To_Territory_Id_gne__c, EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
                parentBudgetTerritoryIds.add(rb.Assigned_To_Territory_Id_gne__c);
                parentBudgetTerritoryIds.add(rb.EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c);
            }

            List<Id> relatedGroupIds = EMS_Util.getTerritoriesGroups(parentBudgetTerritoryIds).values();
            for (EMS_Fund_Request_gne__Share frShare : [SELECT Id, RowCause, Accesslevel, UserOrGroupId FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :fundRequests AND RowCause = :rowCauseParentBudget]) {
                system.assertEquals('Edit', frShare.Accesslevel);
                system.assert(relatedGroupIds.contains(frShare.UserOrGroupId));
            }
        }
    }

    // 11. Share with parent territory RB -> TB Territory Fund Allocation
    private static testMethod void rbToTB_AllocationShare_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        String rowCauseParentBudget = Schema.EMS_Fund_Request_gne__Share.RowCause.Parent_Budget_Sharing__c;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

            Test.startTest();

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, 1);

            Test.stopTest();

            System.assertEquals(BATCH_SIZE * 2, [SELECT count() FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :fundRequests AND RowCause = :rowCauseParentBudget]);

            Set<Id> parentBudgetTerritoryIds = new Set<Id>();
            for (EMS_Budget_Region_gne__c rb : [SELECT Assigned_To_Territory_Id_gne__c, EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
                parentBudgetTerritoryIds.add(rb.Assigned_To_Territory_Id_gne__c);
                parentBudgetTerritoryIds.add(rb.EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c);
            }
            for (EMS_Budget_Territory_gne__c bt: [SELECT Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
                parentBudgetTerritoryIds.add(bt.Assigned_To_Territory_Id_gne__c);
            }

            List<Id> relatedGroupIds = EMS_Util.getTerritoriesGroups(parentBudgetTerritoryIds).values();
            for (EMS_Fund_Request_gne__Share frShare : [SELECT RowCause, Accesslevel, UserOrGroupId FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :fundRequests AND RowCause = :rowCauseParentBudget]) {
                system.assertEquals('Edit', frShare.Accesslevel);
                system.assert(relatedGroupIds.contains(frShare.UserOrGroupId), 'Actual groupId: ' + frShare.UserOrGroupId);
            }
        }
    }

    // 12. Share with parent territory TB -> RB Territory Fund De-Allocation
    private static testMethod void rbToTB_DeAllocationShare_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        String rowCauseParentBudget = Schema.EMS_Fund_Request_gne__Share.RowCause.Parent_Budget_Sharing__c;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

            Test.startTest();

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, 1);

            Test.stopTest();

            System.assertEquals(BATCH_SIZE * 2, [SELECT count() FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :fundRequests AND RowCause = :rowCauseParentBudget]);

            Set<Id> parentBudgetTerritoryIds = new Set<Id>();
            for (EMS_Budget_Region_gne__c rb : [SELECT Assigned_To_Territory_Id_gne__c, EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c FROM EMS_Budget_Region_gne__c WHERE Id IN :regionBudgets]) {
                parentBudgetTerritoryIds.add(rb.Assigned_To_Territory_Id_gne__c);
                parentBudgetTerritoryIds.add(rb.EMS_Budget_Product_gne__r.Assigned_To_Territory_Id__c);
            }
            for (EMS_Budget_Territory_gne__c bt: [SELECT Assigned_To_Territory_Id_gne__c FROM EMS_Budget_Territory_gne__c WHERE Id IN :territoryBudgets]) {
                parentBudgetTerritoryIds.add(bt.Assigned_To_Territory_Id_gne__c);
            }

            List<Id> relatedGroupIds = EMS_Util.getTerritoriesGroups(parentBudgetTerritoryIds).values();
            for (EMS_Fund_Request_gne__Share frShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Fund_Request_gne__Share WHERE ParentId IN :fundRequests AND RowCause = :rowCauseParentBudget]) {
                system.assertEquals('Edit', frShare.Accesslevel);
                system.assert(relatedGroupIds.contains(frShare.UserOrGroupId));
            }
        }
    }

    private static testMethod void territoryBudgetAllocationSharBudgetseWithApproverTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        String rowCauseApprover = Schema.EMS_Fund_Request_gne__Share.RowCause.Approver_Sharing__c;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

            Test.startTest();

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, 1);

            // submit FRs for approval
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setObjectId(fr.id);
                requests.add(request);
            }

            List<Approval.ProcessResult> result = Approval.process(requests);
            Test.stopTest();

            System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCauseApprover]);
            System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :territoryBudgets AND RowCause = :rowCauseApprover]);

            for (EMS_Budget_Region_gne__Share regionBudgetShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCauseApprover]) {
                system.assertEquals('Read', regionBudgetShare.Accesslevel);
                system.assertEquals(rsmUser, regionBudgetShare.UserOrGroupId);
            }

            for (EMS_Budget_Territory_gne__Share territoryBudgetShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :territoryBudgets AND RowCause = :rowCauseApprover]) {
                system.assertEquals('Read', territoryBudgetShare.Accesslevel);
                system.assertEquals(rsmUser, territoryBudgetShare.UserOrGroupId);
            }
        }
    }

    private static testMethod void regionBudgetAllocationShareWithApproverTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        String rowCauseApprover = Schema.EMS_Fund_Request_gne__Share.RowCause.Approver_Sharing__c;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);

            Test.startTest();

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1);

            // submit FRs for approval
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setObjectId(fr.id);
                requests.add(request);
            }

            List<Approval.ProcessResult> result = Approval.process(requests);
            Test.stopTest();

            System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :productBudgets AND RowCause = :rowCauseApprover]);
            System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCauseApprover]);

            for (EMS_Budget_Product_gne__Share pbShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :productBudgets AND RowCause = :rowCauseApprover]) {
                system.assertEquals('Read', pbShare.Accesslevel);
                system.assertEquals(pmUser, pbShare.UserOrGroupId);
            }

            for (EMS_Budget_Region_gne__Share rbShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCauseApprover]) {
                system.assertEquals('Read', rbShare.Accesslevel);
                system.assertEquals(pmUser, rbShare.UserOrGroupId);
            }
        }
    }

    private static testMethod void territoryBudgetDeAllocationShareWithApproverTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        String rowCauseApprover = Schema.EMS_Fund_Request_gne__Share.RowCause.Approver_Sharing__c;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

            Test.startTest();

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, 1);

            // submit FRs for approval
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setObjectId(fr.id);
                requests.add(request);
            }

            List<Approval.ProcessResult> result = Approval.process(requests);
            Test.stopTest();

            System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCauseApprover]);
            System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :territoryBudgets AND RowCause = :rowCauseApprover]);

            for (EMS_Budget_Region_gne__Share rbShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCauseApprover]) {
                system.assertEquals('Read', rbShare.Accesslevel);
                system.assertEquals(repUser, rbShare.UserOrGroupId);
            }

            for (EMS_Budget_Territory_gne__Share tbShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Budget_Territory_gne__Share WHERE ParentId IN :territoryBudgets AND RowCause = :rowCauseApprover]) {
                system.assertEquals('Read', tbShare.Accesslevel);
                system.assertEquals(repUser, tbShare.UserOrGroupId);
            }
        }
    }

    private static testMethod void regionBudgetDeAllocationShareWithApproverTest() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        String rowCauseApprover = Schema.EMS_Fund_Request_gne__Share.RowCause.Approver_Sharing__c;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        system.runAs(u) {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);

            Test.startTest();

            List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, 1);

            // submit FRs for approval
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setObjectId(fr.id);
                requests.add(request);
            }

            List<Approval.ProcessResult> result = Approval.process(requests);
            Test.stopTest();

            System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :productBudgets AND RowCause = :rowCauseApprover]);
            System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCauseApprover]);

            for (EMS_Budget_Region_gne__Share rbShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Budget_Region_gne__Share WHERE ParentId IN :regionBudgets AND RowCause = :rowCauseApprover]) {
                system.assertEquals('Read', rbShare.Accesslevel);
                system.assertEquals(rsmUser, rbShare.UserOrGroupId);
            }

            for (EMS_Budget_Product_gne__Share pbShare : [SELECT Accesslevel, UserOrGroupId FROM EMS_Budget_Product_gne__Share WHERE ParentId IN :productBudgets AND RowCause = :rowCauseApprover]) {
                system.assertEquals('Read', pbShare.Accesslevel);
                system.assertEquals(rsmUser, pbShare.UserOrGroupId);
            }
        }
    }
}