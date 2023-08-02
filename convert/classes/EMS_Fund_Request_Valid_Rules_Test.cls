@isTest
private class EMS_Fund_Request_Valid_Rules_Test {

    private static final Integer BATCH_SIZE = 1;

  /**
   * Tests List:
   * 1. validateRequestedAmount
   * 2. validateProductRegionTerritoryBudget
   * 3. validateRequiredDate
   * 4. validateApprovalProcess
   * 5. tests for disabled validation rules.
   * 6. onDelete block coverage
   * 
   */

    //1. validateRequestedAmount
    //1.1 RegionAllocationNegativeAmount. Error.
    static testMethod void validateRequestedAmount_RegionAllocationNegativeAmount_Error_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, -50, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                System.assert(ex.getMessage().contains(System.Label.Requested_Amount_Cannot_Be_Negative), ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //1.2 RegionAllocationPositiveAmount. Pass.
    static testMethod void validateRequestedAmount_RegionAllocationPositiveAmount_Pass_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //1.3 RegionDeAllocationPositvieAmount. Error.
    static testMethod void validateRequestedAmount_RegionDeAllocationPositvieAmount_Error_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, 50, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                System.assert(ex.getMessage().contains(System.Label.Requested_Amount_Must_Be_Negative), ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //1.4 RegionDeAllocationNegativeAmount. Pass.
    static testMethod void validateRequestedAmount_RegionDeAllocationNegativeAmount_Pass_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //1.5 TerritoryAllocationNegativeAmount. Error.
    static testMethod void validateRequestedAmount_TerritoryAllocationNegativeAmount_Error_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, -50, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                System.assert(ex.getMessage().contains(System.Label.Requested_Amount_Cannot_Be_Negative), ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //1.6 TerritoryAllocationPositiveAmount. Pass.
    static testMethod void validateRequestedAmount_TerritoryAllocationPositiveAmount_Pass_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //1.7 TerritoryDeAllocationPositvieAmount. Error.
    static testMethod void validateRequestedAmount_TerritoryDeAllocationPositvieAmount_Error_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, 50, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                System.assert(ex.getMessage().contains(System.Label.Requested_Amount_Must_Be_Negative), ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //1.8 TerritoryDeAllocationNegativeAmount. Pass.
    static testMethod void validateRequestedAmount_TerritoryDeAllocationNegativeAmount_Pass_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);
        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            // Pass on insert
            try {
                insert fundRequests;
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }

            // Fails on update
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Requested_Amount_gne__c = 50;
            }

            try {
                update fundRequests;
            } catch (DMLException ex) {
                System.assert(ex.getMessage().contains(System.Label.Requested_Amount_Must_Be_Negative), ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //2 validateProductRegionTerritoryBudget
    //2.1 PB->RB Allocation, missing PB
    private static testMethod void validateProductRegionTerritoryBudget_regionAllocationMissingPBName_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Region Fund Allocation', null, regionBudgets.get(0).Id, null, 50);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert testFr;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Product Budget cannot be empty.'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    //2.2 PB->RB Allocation, missing RB
    private static testMethod void validateProductRegionTerritoryBudget_regionAllocationMissingRBName_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Region Fund Allocation', productBudgets.get(0).Id, null, null, 50);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert testFr;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Region Budget cannot be empty.'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    //2.3 PB->RB Allocation, unnecesary TB added
    private static testMethod void validateProductRegionTerritoryBudget_regionAllocationExtraTBName_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Region Fund Allocation', productBudgets.get(0).Id, regionBudgets.get(0).Id, territoryBudgets.get(0).Id, 50);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert testFr;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Territory Budget cannot be filled.'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    // 2.4 RB->TB Allocation, unnecesary PB added
    private static testMethod void validateProductRegionTerritoryBudget_territoryAllocationExtraPBName_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Territory Fund Allocation', productBudgets.get(0).Id, regionBudgets.get(0).Id, territoryBudgets.get(0).Id, 50);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert testFr;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Product Budget cannot be filled.'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    // 2.5 RB->TB Allcoation, missing RB
    private static testMethod void validateProductRegionTerritoryBudget_terrioryAllocationMissingRBName_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Territory Fund Allocation', null, null, territoryBudgets.get(0).Id, 50);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert testFr;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Region Budget cannot be empty.'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    // 2.6 RB->TB Allocation, missing TB
    private static testMethod void validateProductRegionTerritoryBudget_terrioryAllocationMissingTBName_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Territory Fund Allocation', null, regionBudgets.get(0).Id, null, 50);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert testFr;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Territory Budget cannot be empty.'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    // 2.7 Error on update
    private static testMethod void validateProductRegionTerritoryBudget_failOnUpdate_Test() {
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
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Territory Fund Allocation', null, regionBudgets.get(0).Id, territoryBudgets.get(0).Id, 50);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert testFr;
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }

            testFr.Related_Territory_Budget_gne__c = null;
            try {
                update testFr;
            } catch (DMLException ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Territory Budget cannot be empty.'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    //3. validateRequiredDate
    //3.1 Required By date cannot be in past
    private static testMethod void validateRequiredDate_dateSetInPast_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Region Fund Allocation', productBudgets.get(0).Id, regionBudgets.get(0).Id, null, 50);
        testFr.Required_By_Date_gne__c = Date.today() - 5;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert testFr;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (DMLException ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By date cannot be in the past'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    //3.2 Required By must be between Start date and End date of the related budgets. Date is set correctly
    private static testMethod void validateRequiredDate_requiredDateSetBeetweenBudgetsDates_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() - 10, Date.today() + 10, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() - 5, Date.today() + 5);

        EMS_Fund_Request_gne__c testFr = EMS_Test_Util.prepareFundRequest('Region Fund Allocation', productBudgets.get(0).Id, regionBudgets.get(0).Id, null, 50);
        testFr.Required_By_Date_gne__c = Date.today() + 2;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            // Pass on insert
            try {
                insert testFr;
            } catch (DMLException ex) {
                System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
            }

            // Update data to fail condition
            testFr.Required_By_Date_gne__c = Date.today() - 2;
            // Fails on update
            try {
                update testFr;
            } catch (DMLException ex) {
                System.assert(ex.getMessage().contains('Required By date cannot be in the past'), ex.getMessage());
            }
            Test.stopTest();
        }
    }

    //Region_Fund_Allocation AND Region_Fund_De_Allocation
    //3.3 Required By must be between Start date and End date of the related budgets. Date is set before PB start date
    private static testMethod void validateRequiredDate_requiredDateBeforePBStartDate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 20, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 15);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, Date.Today() + 2, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By must be between Start date and End date of the related budgets.'), ex.getMessage());

                }
            }
            Test.stopTest();
        }
    }

    //3.4 Required By must be between Start date and End date of the related budgets. Date is set after PB start, before RB start
    private static testMethod void validateRequiredDate_requiredDateAfterPBStartBeforeRBStartDate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 20, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 15);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, Date.Today() + 7, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By must be between Start date and End date of the related budgets.'), ex.getMessage());

                }
            }
            Test.stopTest();
        }
    }

    //3.5 Required By must be between Start date and End date of the related budgets. Date is set after PB end date
    private static testMethod void validateRequiredDate_requiredDateSetAfterPBEndDate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 20, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 15);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, Date.Today() + 22, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By must be between Start date and End date of the related budgets.'), ex.getMessage());

                }
            }
            Test.stopTest();
        }
    }

    //3.6 Required By must be between Start date and End date of the related budgets. Date is set after RB end date, before PB end date
    private static testMethod void validateRequiredDate_requiredDateSetAfterRBEndDateBeforePBEndDate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 20, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 15);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, Date.Today() + 17, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By must be between Start date and End date of the related budgets.'), msg.getSummary());

                }
            }
            Test.stopTest();
        }
    }

    // Territory_Fund_Allocation AND Territory_Fund_De_Allocation
    //3.7 Required By must be between Start date and End date of the related budgets. Date is set before RB start date
    private static testMethod void validateRequiredDate_requiredDateBeforeRBStartDate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser, Date.today() + 15, Date.today() + 20);


        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, Date.Today() + 7, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By must be between Start date and End date of the related budgets.'), msg.getSummary());

                }
            }
            Test.stopTest();
        }
    }

    //3.8 Required By must be between Start date and End date of the related budgets. Date is set after RB start, before TB start
    private static testMethod void validateRequiredDate_requiredDateAfterRBStartBeforeTBStartDate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser, Date.today() + 15, Date.today() + 20);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, Date.Today() + 12, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By must be between Start date and End date of the related budgets.'), ex.getMessage());

                }
            }
            Test.stopTest();
        }
    }

    //3.9 Required By must be between Start date and End date of the related budgets. Date is set after RB end date
    private static testMethod void validateRequiredDate_requiredDateSetAfterRBEndDate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser, Date.today() + 15, Date.today() + 20);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, Date.Today() + 27, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By must be between Start date and End date of the related budgets.'), ex.getMessage());

                }
            }
            Test.stopTest();
        }
    }

    //3.10 Required By must be between Start date and End date of the related budgets. Date is set after TB end date, before RB end date
    private static testMethod void validateRequiredDate_requiredDateSetAfterTBEndDateBeforeRBEndDate_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser, Date.today() + 15, Date.today() + 20);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, Date.Today() + 22, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            try {
                insert fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Required By must be between Start date and End date of the related budgets.'), ex.getMessage());

                }
            }
            Test.stopTest();
        }
    }

    // validateApprovalProcess. Check avaliable amount i budget before FR approval
    // Allocation
    // 4.1 Region_Fund_Allocation. Requested amount is lower than Product Budget Balance. No errors.
    private static testMethod void validateApprovalProcess_AllocationAmountIsLowerThanPBBalance_Pass_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 20, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 15);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, Date.Today() + 12, 1, true);

        User testUsr = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(testUsr) {
            Test.startTest();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Approved';
            }
            update fundRequests;
            Test.stopTest();
        }

        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            System.assertEquals(fr.Status_gne__c, 'Approved');
        }
    }

    // 4.2 Region_Fund_Allocation. Requested amount is higher than Product Budget Balance. Error returned.
    private static testMethod void validateApprovalProcess_AllocationAmountIsHigherThanPBBalance_Error_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 20, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 15);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund Allocation', regionBudgets, 50, Date.Today() + 12, 1, true);

        User testUsr = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(testUsr) {
            Test.startTest();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            try {
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Requested_Amount_gne__c = 1500; // Simplified step. Otherwise we need to create an event and budget allocation to lower budget balance.
                    fr.Status_gne__c = 'Approved';
                }
                update fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Requested value is higher than available amount'), ex.getMessage());
                }
            }
            Test.stopTest();
        }
    }

    // 4.3 Territory_Fund_Allocation. Requested amount is lower than Region Budget Balance. No errors.
    private static testMethod void validateApprovalProcess_AllocationAmountIsLowerThanRBBalance_Pass_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser, Date.today() + 15, Date.today() + 20);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, Date.Today() + 17, 1, true);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Approved';
            }
            update fundRequests;
            Test.stopTest();
        }

        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            System.assertEquals(fr.Status_gne__c, 'Approved');
        }
    }

    // 4.4 Territory_Fund_Allocation. Requested amount is higher than Region budget Balance. Error returned.
    private static testMethod void validateApprovalProcess_AllocationAmountIsHigherThanRBBalance_Error_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser, Date.today() + 15, Date.today() + 20);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund Allocation', territoryBudgets, 50, Date.Today() + 17, 1, true);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            try {
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Requested_Amount_gne__c = 1500; // Simplified step. Otherwise we need to create an event and budget allocation to lower budget balance.
                    fr.Status_gne__c = 'Approved';
                }
                update fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Requested value is higher than available amount'), ex.getMessage());

                }
            }
            Test.stopTest();
        }
    }

    //De-Allocation
    // 4.5 Region_Fund_De_Allocation. Requested amount is higher than Region Balance. Error returned.
    private static testMethod void validateApprovalProcess_DeAllocationAmountIsHigherThanRBBalance_Error_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, Date.Today() + 17, 1, true);

        // Disable validation rules for related budgets as we want to check FR validations
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            try {
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Requested_Amount_gne__c = -1500; // Simplified step. Otherwise we need to create an event and budget allocation to lower budget balance.
                    fr.Status_gne__c = 'Approved';
                }
                update fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Requested value is higher than available amount'), msg.getSummary());
                }
            }
            Test.stopTest();
        }
    }


    // 4.6 Region_Fund_De_Allocation. Requested amount is lower than Region Balance. No errors.
    private static testMethod void validateApprovalProcess_DeAllocationAmountIsLowerThanRBBalance_Pass_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, Date.Today() + 17, 1, true);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Approved';
            }
            update fundRequests;
            Test.stopTest();
        }

        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            System.assertEquals(fr.Status_gne__c, 'Approved');
        }
    }


    // 4.7 Territory_Fund_De_Allocation. Requested amount is higher than Territory Balance. Error returned.
    private static testMethod void validateApprovalProcess_DeAllocationAmountIsHigherThanTBBalance_Error_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser, Date.today() + 15, Date.today() + 20);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, Date.Today() + 17, 1, true);

        // Disable validation rules for related budgets as we want to check FR validations
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            try {
                for (EMS_Fund_Request_gne__c fr : fundRequests) {
                    fr.Requested_Amount_gne__c = -1500; // Simplified step. Otherwise we need to create an event and budget allocation to lower budget balance.
                    fr.Status_gne__c = 'Approved';
                }
                update fundRequests;
                System.assert(false, 'Record inserted without expected errors, check tests!');
            } catch (exception ex) {
                List<ApexPages.Message> msgs = ApexPages.getMessages();
                for (ApexPages.Message msg : msgs) {
                    System.assert(msg.getSummary().contains('Requested value is higher than available amount'), msg.getSummary());
                }
            }
            Test.stopTest();
        }
    }

    // 4.8 Territory_Fund_De_Allocation. Requested amount is lower than Territory Balance. No errors.
    private static testMethod void validateApprovalProcess_DeAllocationAmountIsLowerThanTBBalance_Pass_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0, 300, repUser, Date.today() + 15, Date.today() + 20);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachTB('Territory Fund De-Allocation', territoryBudgets, -50, Date.Today() + 17, 1, true);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Submitted';
            }
            update fundRequests;

            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Status_gne__c = 'Approved';
            }
            update fundRequests;
            Test.stopTest();
        }

        for (EMS_Fund_Request_gne__c fr : fundRequests) {
            System.assertEquals(fr.Status_gne__c, 'Approved');
        }
    }

    //5.tests for disabled validation rules.
    //5.1 Disable validation rules on insert
    private static testMethod void onInsertValidation_DisabledalidationRules_Pass_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, Date.Today() + 17, 1, false);

        EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = true;

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            insert fundRequests;
            Test.stopTest();
        }
    }

    //5.2 Disable validation rules on update
    private static testMethod void onUpdateValidation_DisabledalidationRules_Pass() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, Date.Today() + 17, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            insert fundRequests;
            EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = true;
            for (EMS_Fund_Request_gne__c fr : fundRequests) {
                fr.Reason_gne__c = 'Test';
            }
            update fundRequests;
            Test.stopTest();
        }
    }

    //5.2 Disable validation rules on delete
    private static testMethod void onDeleteValidation_DisabledalidationRules_Pass() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, Date.Today() + 17, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            insert fundRequests;
            EMS_Fund_Request_Trigger_Helper.skipTriggerValidationRules = true;
            delete fundRequests;
            Test.stopTest();
        }
    }

    //6. onDelete block coverage

    //6.1 Disable validation rules on delete
    private static testMethod void onDeleteValidationBlock_DummyTestForEmptyBlock_Pass() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmUser, 'Commercial Product', Date.today() + 5, Date.today() + 30, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 600.0, rsmUser, Date.today() + 10, Date.today() + 25);

        List<EMS_Fund_Request_gne__c> fundRequests = EMS_Test_Util.createFundRequestsForEachRB('Region Fund De-Allocation', regionBudgets, -50, Date.Today() + 17, 1, false);

        User u = [SELECT Id, Name FROM User WHERE Id = :pmUser];
        System.runAs(u) {
            Test.startTest();
            insert fundRequests;
            delete fundRequests;
            Test.stopTest();
        }
    }

}