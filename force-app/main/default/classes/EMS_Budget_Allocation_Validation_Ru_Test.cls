@isTest
private class EMS_Budget_Allocation_Validation_Ru_Test {

	/**
	 * 1. validateAllocatedAmount
	 * 2. validateDuplicateBudgetAllocation
	 * 3. skipping validation rules
	 */

    private static final Integer BATCH_SIZE = 10;

    //1.1 validateAllocatedAmount. Allcoation from Product Budged exceeded budget balance.
    private static testMethod void validateAllocatedAmount_productBudget_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers[0], 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 5000,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        try {
            insert budgetAllocations;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Amount_Exceeds_Balance), ex.getMessage());
        }

        Test.stopTest();
    }

    //1.2 validateAllocatedAmount. Allcoation from Region Budged exceeded budget balance.
    private static testMethod void validateAllocatedAmount_regionBudget_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
            regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);

        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 5000,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        try {
            insert budgetAllocations;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Amount_Exceeds_Balance), ex.getMessage());
        }

        Test.stopTest();
    }

    //1.4 validateAllocatedAmount. Allcoation from Region Budged on insrt in balance, on updae too exceed balance.
    private static testMethod void validateDuplicateBudgetAllocation_productBudget_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers.get(0), 'Commercial Product', BATCH_SIZE);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Planned', pmUsers.get(0), 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, 500, BATCH_SIZE) ;

        Test.startTest();
        Integer i;
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        insert budgetAllocations;

        // Update
        for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
            ba.Allocated_Budget_gne__c = 5000;
        }
        try {
            update budgetAllocations;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Amount_Exceeds_Balance), ex.getMessage());
        }

        Test.stopTest();
    }

    //2.1 validateDuplicateBudgetAllocation. Product Budget.
    private static testMethod void validateAllocatedAmount_productBudgetAmountToHighOnUpdate_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers.get(0), 'Commercial Product', BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers.get(0), 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, 500, BATCH_SIZE) ;

        Test.startTest();
        // Insert
        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        budgetAllocations.clear();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        try {
            insert budgetAllocations;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Allocation_Already_Exists), ex.getMessage());
        }

        Test.stopTest();

    }

    //2.2 validateDuplicateBudgetAllocation. Region Budget.
    private static testMethod void validateDuplicateBudgetAllocation_regionBudget_Test() {
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
        // Add budget allcoation
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, 500, BATCH_SIZE) ;

        Test.startTest();

        Integer i;
        // Insert
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        try {
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        budgetAllocations.clear();
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 100,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Region Budget Allocation'),
                    EMS_Region_Budget_gne__c = regionBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        try {
            insert budgetAllocations;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Allocation_Already_Exists), ex.getMessage());
        }

        Test.stopTest();
    }

    //3. Skip validation rules.
    private static testMethod void skipValidationRules_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUsers.get(0), 'Commercial Product', BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        // Add budget allcoation
        List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUsers.get(0), 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, 500, BATCH_SIZE) ;

        Test.startTest();
        // Insert
        Integer i;
        for (i = 0; i < BATCH_SIZE; i++) {
            EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = 2000,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = events.get(i).Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = productBudgets.get(i).Id
            );
            budgetAllocations.add(budgetAllocation);
        }
        try {
            EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
            insert budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        // Update
        for (EMS_Budget_Allocation_gne__c ba :budgetAllocations) {
            ba.Allocated_Budget_gne__c = 3000;
        }
        try {
            EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
            update budgetAllocations;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        Test.stopTest();
    }

	/*
	// SOQL 101 Exception
	// Class.EMS_Event_Trigger_Helper.getAttendeeForEvents: line 70, column 1 
	// Class.EMS_Event_Validation_Rules.runValidationRulesOnUpdate: line 77, column 1 
	// Class.EMS_Event_Validation_Rules.onBeforeUpdate: line 15, column 1 
	// Trigger.EMS_Event_Trigger: line 10, column 1
	
	private static testMethod void validateAllocatedAmount_territoryBudget_Test() {
		List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM','RSM');
		Id pmUser = ids[0];
		Id rsmUser = ids[1];
		System.assertNotEquals(null, pmUser);
		System.assertNotEquals(null, rsmUser);

		EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
		List<EMS_Budget_Product_gne__c> productBudgets = new List<EMS_Budget_Product_gne__c>();
		List<EMS_Budget_Region_gne__c> regionBudgets = new List<EMS_Budget_Region_gne__c>();
		List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
		try {
			productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000, pmUser, 'Commercial Product', BATCH_SIZE);
			regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 500.0, rsmUser);
			territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 200.0, rsmUser);
		} catch (DMLException ex) {
			System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
		}
		List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today()+1, Date.today()+3, BATCH_SIZE);

		Test.startTest();

		Integer i;
		List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List <EMS_Budget_Allocation_gne__c>();
		for(i = 0; i < BATCH_SIZE; i++) {
			EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
				Allocated_Budget_gne__c = 100,
				Percentage_Contribution_gne__c = 1,
				Budget_Deductions_gne__c = 0,
				EMS_Event_gne__c = events.get(i).Id,
				RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
				EMS_Territory_Budget_gne__c = territoryBudgets.get(i).Id
			);
			budgetAllocations.add(budgetAllocation);
		}
		insert budgetAllocations;

		Test.stopTest();
	}
	
	SOQL 101 Exception
	//2.3 validateDuplicateBudgetAllocation. Region Budget.
	private static testMethod void validateDuplicateBudgetAllocation_territoryBudget_Test() {
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
			territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 200.0, repUser);
		} catch (DMLException ex) {
			System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
		}

		// Add budget allcoation
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

  			budgetAllocations.clear();
			// Update
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
				System.assert(false, 'Record inserted without expected errors, check tests!');
			} catch(DMLException ex) {
				System.assert(ex.getMessage().contains(System.Label.Budget_Allocation_Already_Exists), ex.getMessage());
			}

		Test.stopTest();
	}

	SOQL 101 Exception
	//1.3 validateAllocatedAmount. Allcoation from Territory Budged exceeded budget balance.
	private static testMethod void validateAllocatedAmount_territoryBudget_Test() {
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

		// Add budget allcoation
		List<EMS_Event__c> events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today()+1, Date.today()+3, BATCH_SIZE) ;

		Test.startTest();

			Integer i;
			for(i = 0; i < BATCH_SIZE; i++) {
				EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
					Allocated_Budget_gne__c = 5000,
					EMS_Event_gne__c = events.get(i).Id,
					RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Territory Budget Allocation'),
					EMS_Territory_Budget_gne__c = territoryBudgets.get(i).Id
				);
				budgetAllocations.add(budgetAllocation);
			}

			try {
				insert budgetAllocations;
				System.assert(false, 'Record inserted without expected errors, check tests!');
			} catch(DMLException ex) {
				System.assert(ex.getMessage().contains(System.Label.Amount_Exceeds_Balance), ex.getMessage());
			}
		Test.stopTest();
	}
*/
}