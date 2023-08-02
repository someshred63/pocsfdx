@isTest
private class EMS_Budget_Region_Validation_Rules_Test {

    private static Integer BATCH_SIZE = 11;//101;


    // Delete
    private static testMethod void validateChildBudgetsOnDeleteTest_skipValidation() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser);

        Test.startTest();
        delete territoryBudgets;
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        delete regionBudgets;
        for (EMS_Budget_Product_gne__c pb : [SELECT Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assert(pb.Child_Budgets_Allocated_Amount_gne__c == 0);
        }
        Test.stopTest();
    }

    private static testMethod void validateChildBudgetsOnDeleteTest() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser);

        Test.startTest();
        try {
            delete regionBudgets;
            System.assert(false, 'Region budget with child territory budget should not be deleted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Remove_Related_Records), ex.getMessage());
        }
        Test.stopTest();
    }

    // Insert
    private static testMethod void validateChildBudgetsOnInsertTest_skipValidation() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);

        Test.startTest();
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 1000.0, 900.0, rsmUser);
        Test.stopTest();
    }

    // Update
    private static testMethod void validateChildBudgetsOnUpdateTest_skipValidation() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);

        Test.startTest();
        EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 1000.0, 900.0, rsmUser);
        for (EMS_Budget_Region_gne__c rb : regionBudgets) {
            rb.Total_Region_Funds_Approved_gne__c = 800;
        }
        update regionBudgets;
        for (EMS_Budget_Product_gne__c pb : [SELECT Child_Budgets_Allocated_Amount_gne__c FROM EMS_Budget_Product_gne__c WHERE Id IN :productBudgets]) {
            System.assert(pb.Child_Budgets_Allocated_Amount_gne__c == 800);
        }
        Test.stopTest();
    }

    // OnbeforeInsert Onbefore update Validation failing
    private static testMethod void validateApprovedAmount_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, -10.0, rsmUser);
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Total_Region_Funds_Approved_Cannot_Be_Negative_OR_Zero), ex.getMessage());
        }
        // Update
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 10.0, rsmUser);
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Total_Region_Funds_Approved_gne__c = -100.0;
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Total_Region_Funds_Approved_Cannot_Be_Negative_OR_Zero), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateTotalAllocatedAmount_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 20.0, 10.0, rsmUser);
            System.assert(false, 'Total allocated amount cannot be higher than the total funds approved amount');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Total_Budget_Allocated_Amount_Cannot_Be_Higher_Than_Funds_Approved_Amount), ex.getMessage());
        }
        // Update
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 10.0, 20.0, rsmUser);
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Total_Region_Funds_Approved_gne__c = 5.0;
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Total_Budget_Allocated_Amount_Cannot_Be_Higher_Than_Funds_Approved_Amount), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateStartDate_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, Date.today().addYears(-1), Date.today().addYears(-1), String.valueOf(Date.today().addYears(-1).year()));
            System.assert(false, 'Region budget with past start date should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Start_Date_Cannot_Be_Prior_Than_Current_Year), ex.getMessage());
        }
        // Update
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, EMS_Test_Util.getStartDate(), EMS_Test_Util.getStartDate().addDays(10), String.valueOf(Date.today().year()));
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Start_Date_gne__c = Date.today().addYears(-1);
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Start_Date_Cannot_Be_Prior_Than_Current_Year), ex.getMessage());
        }
        Test.stopTest();
    }


    private static testMethod void validateEndDate_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, EMS_Test_Util.getStartDate(), EMS_Test_Util.getStartDate().addDays(-2), String.valueOf(Date.today().year()));
            System.assert(false, 'Region budget with end date prior to start date should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date), ex.getMessage());
        }
        // Update
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, EMS_Test_Util.getStartDate(), EMS_Test_Util.getStartDate().addDays(5), String.valueOf(Date.today().year()));
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.End_Date_gne__c = Date.today().addDays(-10);
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateSameYearAsProductBudget_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, Date.today().addYears(1), Date.today().addYears(1), String.valueOf(Date.today().addYears(1).year()));
            System.assert(false, 'Region budget with different year than the region budget should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Invalid_Year), ex.getMessage());
        }
        // Update
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Start_Date_gne__c = Date.today().addYears(1);
                rb.End_Date_gne__c = Date.today().addYears(1);
                rb.Year_gne__c = String.valueOf(Date.today().addYears(1).year());
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Invalid_Year), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateIfStartEndDatesYearInCalendarYear_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', Date.today().addYears(1), Date.today().addYears(1), String.valueOf(Date.today().addYears(1).year()), BATCH_SIZE);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, Date.today().addYears(1), Date.today().addYears(2), String.valueOf(Date.today().addYears(1).year()));
            System.assert(false, 'Region budget with end date not in the calendar year should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Start_End_Dates_in_different_calendar_year), ex.getMessage());
        }
        // Update
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, Date.today().addYears(1), Date.today().addYears(1), String.valueOf(Date.today().addYears(1).year()));
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.End_Date_gne__c = Date.today().addYears(2);
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Start_End_Dates_in_different_calendar_year), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateIfDatesBeetweenDatesOfRegionBudget_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, EMS_Test_Util.getStartDate().addDays(-2), EMS_Test_Util.getStartDate(), String.valueOf(Date.today().year()));
            System.assert(false, 'Region budget with start date earlier than product budget start date should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Start_End_dates_must_be_between_parent_budget_Dates), ex.getMessage());
        }
        // Update
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser, Date.today(), Date.today(), String.valueOf(Date.today().year()));
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Start_Date_gne__c = Date.today().addDays(-1);
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Start_End_dates_must_be_between_parent_budget_Dates), ex.getMessage());
        }
        Test.stopTest();
    }

    // User Role Validation
    private static testMethod void validateAssignedToUserRole_insertupdate_Fail() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, repUsers[0]);
            System.assert(false, 'Region budget can only be assigned to PM/RSM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }
        // Update
        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Assigned_to_gne__c = repUsers[0];
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }
        Test.stopTest();
    }

    // Inactive Budget Validation
    private static testMethod void validateInactiveBudget_update_Fail() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        for (EMS_Budget_Region_gne__c rb : regionBudgets) {
            rb.Status_gne__c = 'Inactive';
        }
        update regionBudgets;

        Test.startTest();
        try {
            for (EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Total_Region_Funds_Approved_gne__c = 100.0;
            }
            update regionBudgets;
            System.assert(false, 'Inactive region budget should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_editing_inactive_budget), ex.getMessage());
        }
        Test.stopTest();
    }


/*

    private static testMethod void validateAssignedToUserRole1Test() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        Test.startTest();

        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, repUsers[0]);
            System.assert(false, 'Region budget can only be assigned to PM/RSM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole2Test() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);

        Test.startTest();

        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        } catch (DMLException ex) {
            System.assert(false, 'Region budget should be assigned to RSM');
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole3Test() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        Test.startTest();

        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, pmUsers[0]);
        } catch (DMLException ex) {
            System.assert(false, 'Region budget should be assigned to PM');
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole5Test() {
        // select test users
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);        

        System.assertNotEquals(0, mmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, mmUsers[0], 'Medical Department', BATCH_SIZE);

        Test.startTest();

        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
            System.assert(false, 'Medical region budget cannot be assigned to RSM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole6Test() {
        // select test users
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);

        System.assertNotEquals(0, mmUsers.size());
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, mmUsers[0], 'Medical Product', BATCH_SIZE);

        Test.startTest();

        try {
            List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, pmUsers[0]);
            System.assert(false, 'Medical territory budget cannot be assigned to PM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole1OnUpdateTest1() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        Test.startTest();

        try {
            for(EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Assigned_to_gne__c = repUsers[0];
            }
            update regionBudgets;
            System.assert(false, 'Region budget can only be assigned to PM/RSM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRoleOnUpdateTest2() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        Test.startTest();

        try {
            for(EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Assigned_to_gne__c = rsmUsers[0];
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Region budget should be assigned to RSM');
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRoleOnUpdateTest3() {
        // select test users
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        
        Test.startTest();
        
        try {
            
            for(EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Assigned_to_gne__c = pmUsers[0];
            }
            update regionBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Region budget should be assigned to PM');
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRoleOnUpdateTest4() {
        // select test users
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        List<Id> mlUsers = EMS_Test_Util.findExistingUser('ML', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);        

        System.assertNotEquals(0, mmUsers.size());
        System.assertNotEquals(0, mlUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, mmUsers[0], 'Medical Department', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, mlUsers[0]);

        Test.startTest();

        try {
            for(EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Assigned_to_gne__c = rsmUsers[0];
            }
            update regionBudgets;
            System.assert(false, 'Medical region budget cannot be assigned to RSM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRoleOnUpdateTest5() {
        // select test users
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        List<Id> mlUsers = EMS_Test_Util.findExistingUser('ML', null);
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);

        System.assertNotEquals(0, mmUsers.size());
        System.assertNotEquals(0, mlUsers.size());
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, mmUsers[0], 'Medical Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, mlUsers[0]);

        Test.startTest();

        try {
            for(EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Assigned_to_gne__c = pmUsers[0];
            }
            update regionBudgets;
            System.assert(false, 'Medical territory budget cannot be assigned to PM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRoleOnUpdateTest6() {
        // select test users
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        List<Id> mlUsers = EMS_Test_Util.findExistingUser('ML', null);
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);

        System.assertNotEquals(0, mmUsers.size());
        System.assertNotEquals(0, mlUsers.size());
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, mmUsers[0], 'GM Budget/Corp Comm department budget', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, mmUsers[0]);

        Test.startTest();

        try {
            for(EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Assigned_to_gne__c = pmUsers[0];
            }
            update regionBudgets;
            System.assert(false, 'Corporate relations territory budget cannot be assigned to PM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }

        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRoleOnUpdateTest7() {
        // select test users
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        List<Id> mlUsers = EMS_Test_Util.findExistingUser('ML', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);

        System.assertNotEquals(0, mmUsers.size());
        System.assertNotEquals(0, mlUsers.size());
        System.assertNotEquals(0, rsmUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, mmUsers[0], 'GM Budget/Corp Comm department budget', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, mmUsers[0]);

        Test.startTest();

        try {
            for(EMS_Budget_Region_gne__c rb : regionBudgets) {
                rb.Assigned_to_gne__c = rsmUsers[0];
            }
            update regionBudgets;
            System.assert(false, 'Corporate relations territory budget cannot be assigned to RSM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }

        Test.stopTest();
    }
*/

}