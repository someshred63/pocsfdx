@isTest
private class EMS_Budget_Allocation_Field_Updates_Test {
	/**
	 *  1. updateRecordType [bI, bU]
	 *	2. updateBudgetOwner [bI, bU]
	 *	3. updateProductIndication [bI, bU]
	 *	4. updateCostCenterInformation [bI, bU]
	 */

    private static final Integer BATCH_SIZE = 10;
    private static final String productIndication = 'ProductIndication';
    private static Decimal plannedExpenses = 10;

    //1.1 updateRecordType product
    private static testMethod void updateRecordType_productBudget_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers.get(0), 'Commercial Product', BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers.get(0), 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.stopTest();

        Id recTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation');
        for (EMS_Budget_Allocation_gne__c ba : [SELECT RecordTypeId FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(recTypeId, ba.RecordTypeId);
        }
    }

    //1.2 updateRecordType region
    private static testMethod void updateRecordType_regionBudget_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];

        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
            regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);

        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.stopTest();

        Id recTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation');
        for (EMS_Budget_Allocation_gne__c ba : [SELECT RecordTypeId FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(recTypeId, ba.RecordTypeId);
        }
    }


    //2.1 updateBudgetOwner product
    private static testMethod void updateBudgetOwner_productBudget_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers.get(0), 'Commercial Product', BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers.get(0), 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Owner_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(pmUsers.get(0), ba.Budget_Owner_gne__c);
        }
    }

    //2.2 updateBudgetOwner region
    private static testMethod void updateBudgetOwner_regionBudget_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];

        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
            regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);

        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Owner_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assertEquals(rsmUser, ba.Budget_Owner_gne__c);
        }
    }

    //3.1 updateProductIndication product
    private static testMethod void updateProductIndication_productBudget_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers.get(0), 'Commercial Product', BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers.get(0), 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Product_Indication_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assert(ba.Product_Indication_gne__c.contains(productIndication));
        }
    }

    //3.2 updateProductIndication region
    private static testMethod void updateProductIndication_regionBudget_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];

        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
            regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);

        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Product_Indication_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assert(ba.Product_Indication_gne__c.contains(productIndication));
        }
    }

    //4.1 updateCostCenterInformation product
    private static testMethod void updateCostCenterInformation_productBudget_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers.get(0), 'Commercial Product', BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers.get(0), 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Cost_Center_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assert(ba.Cost_Center_gne__c.contains('CostCenter'), 'Actual Cost_Center_gne__c: ' + ba.Cost_Center_gne__c);
            System.assert(ba.Cost_Center_Type_gne__c.contains('Commercial Product'), 'Actual Cost_Center_Type_gne__c: ' + ba.Cost_Center_Type_gne__c);
        }
    }

    //4.2 updateCostCenterInformation region
    private static testMethod void updateCostCenterInformation_regionBudget_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];

        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
            regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);

        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, plannedExpenses, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id,
                    Percentage_Contribution_gne__c = 100
            );
            budgetAllocations.add(budgetAllocation);
        }

        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        Test.stopTest();

        for (EMS_Budget_Allocation_gne__c ba : [SELECT Cost_Center_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations]) {
            System.assert(ba.Cost_Center_gne__c.contains('CostCenter'), 'Actual Cost_Center_gne__c: ' + ba.Cost_Center_gne__c);
            System.assert(ba.Cost_Center_Type_gne__c.contains('Commercial Product'), 'Actual Cost_Center_Type_gne__c: ' + ba.Cost_Center_Type_gne__c);

        }
    }


/*
	SOQL 101 Exception
	//1.3 updateRecordType territory
	private static testMethod void updateRecordType_territoryBudget_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
		Id pmUser = ids[0];
		Id rsmUser = ids[1];

		System.assertNotEquals(null, pmUser);
		System.assertNotEquals(null, rsmUser);

		Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
		System.assertNotEquals(null, repUser);

		List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
		List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
		List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
		List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();

		EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

		// Insert
		try {
			productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
			regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);
			territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 100.0, repUser);
		} catch (DMLException ex) {
			System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
		}
		
		List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today()+1, Date.today()+3, BATCH_SIZE) ;
		
		Test.startTest();

			Integer i;
			for(i = 0; i < BATCH_SIZE; i++) {
				EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
					Allocated_Budget_gne__c = 100,
					EMS_Event_gne__c = events.get(i).Id,
					RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
					EMS_Territory_Budget_gne__c = territoryBudgets.get(i).Id
				);
				budgetAllocations.add(budgetAllocation);
			}

			try {
				insert budgetAllocations;
			} catch(DMLException ex) {
				System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
			}

		Test.stopTest();

		Id recTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation');
		for (EMS_Budget_Allocation_gne__c ba : [SELECT RecordTypeId FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations] ) {
			System.assertEquals(recTypeId, ba.RecordTypeId);
		}
	}

	SOQL 101 Exception
	//2.3 updateBudgetOwner territory
	private static testMethod void updateBudgetOwner_territoryBudget_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
		Id pmUser = ids[0];
		Id rsmUser = ids[1];

		System.assertNotEquals(null, pmUser);
		System.assertNotEquals(null, rsmUser);

		Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
		System.assertNotEquals(null, repUser);

		List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
		List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
		List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
		List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
		
		EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
		
		// Insert
		try {
			productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
			regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);
			territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 100.0, repUser);
		} catch (DMLException ex) {
			System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
		}
		
		List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today()+1, Date.today()+3, BATCH_SIZE) ;
		
		Test.startTest();

			Integer i;
			for(i = 0; i < BATCH_SIZE; i++) {
				EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
					Allocated_Budget_gne__c = 100,
					EMS_Event_gne__c = events.get(i).Id,
					RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
					EMS_Territory_Budget_gne__c = territoryBudgets.get(i).Id
				);
				budgetAllocations.add(budgetAllocation);
			}

			try {
				insert budgetAllocations;
			} catch(DMLException ex) {
				System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
			}

		Test.stopTest();

		for (EMS_Budget_Allocation_gne__c ba : [SELECT Budget_Owner_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations] ) {	
			System.assertEquals(repUser, ba.Budget_Owner_gne__c);
		}	
	}

	SOQL 101 Exception
	//3.3 updateProductIndication territory
	private static testMethod void updateProductIndication_territoryBudget_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
		Id pmUser = ids[0];
		Id rsmUser = ids[1];

		System.assertNotEquals(null, pmUser);
		System.assertNotEquals(null, rsmUser);

		Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
		System.assertNotEquals(null, repUser);

		List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
		List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
		List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
		List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
		
		EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
		
		// Insert
		try {
			productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
			regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);
			territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 100.0, repUser);
		} catch (DMLException ex) {
			System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
		}
		
		List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today()+1, Date.today()+3, BATCH_SIZE) ;
		
		Test.startTest();

			Integer i;
			for(i = 0; i < BATCH_SIZE; i++) {
				EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
					Allocated_Budget_gne__c = 100,
					EMS_Event_gne__c = events.get(i).Id,
					RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
					EMS_Territory_Budget_gne__c = territoryBudgets.get(i).Id
				);
				budgetAllocations.add(budgetAllocation);
			}

			try {
				insert budgetAllocations;
			} catch(DMLException ex) {
				System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
			}

		Test.stopTest();

		for (EMS_Budget_Allocation_gne__c ba : [SELECT Product_Indication_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations] ) {	
			System.assert(ba.Product_Indication_gne__c.contains(productIndication));
		}	
	}

	SOQL 101 Exception
	//4.3 updateCostCenterInformation territory
	private static testMethod void updateCostCenterInformation_territoryBudget_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
		Id pmUser = ids[0];
		Id rsmUser = ids[1];

		System.assertNotEquals(null, pmUser);
		System.assertNotEquals(null, rsmUser);

		Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
		System.assertNotEquals(null, repUser);

		List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
		List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
		List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
		List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
		
		EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
		
		// Insert
		try {
			productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
			regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);
			territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 100.0, repUser);
		} catch (DMLException ex) {
			System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
		}
		
		List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today()+1, Date.today()+3, BATCH_SIZE) ;
		
		Test.startTest();

			Integer i;
			for(i = 0; i < BATCH_SIZE; i++) {
				EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
					Allocated_Budget_gne__c = 100,
					EMS_Event_gne__c = events.get(i).Id,
					RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
					EMS_Territory_Budget_gne__c = territoryBudgets.get(i).Id
				);
				budgetAllocations.add(budgetAllocation);
			}

			try {
				insert budgetAllocations;
			} catch(DMLException ex) {
				System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
			}

		Test.stopTest();

		for (EMS_Budget_Allocation_gne__c ba : [SELECT Cost_Center_gne__c, Cost_Center_Type_gne__c FROM EMS_Budget_Allocation_gne__c WHERE Id IN :budgetAllocations] ) {	
			System.assert(ba.Cost_Center_gne__c.contains('CostCenter'), 'Actual Cost_Center_gne__c: ' + ba.Cost_Center_gne__c);
			System.assert(ba.Cost_Center_Type_gne__c.contains('Commercial Product'), 'Actual Cost_Center_Type_gne__c: ' + ba.Cost_Center_Type_gne__c);
			
		}
		
	}
*/
}