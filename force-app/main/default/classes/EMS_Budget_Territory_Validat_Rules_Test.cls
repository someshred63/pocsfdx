@isTest
private class EMS_Budget_Territory_Validat_Rules_Test {

    private static Integer BATCH_SIZE = 11;//101;

    private static testMethod void validateTotalApprovedAmount_LessHigher_insert_Fail() {
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
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, -1.0, repUsers[0]);
            System.assert(false, 'Territory budget with negative amount should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Total_Territory_Funds_Approved_Cannot_Be_Negative_OR_Zero), ex.getMessage());
        }

        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 1.0, repUsers[0]);
        } catch (DMLException ex) {
            System.assert(false, 'Territory budget with positive amount should be inseted: ' + ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateTotalApprovedAmount_Less_update_Fail() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);

        Test.startTest();
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Total_Territory_Funds_Approved_gne__c = -10.0;
            }
            update territoryBudgets;
            System.assert(false, 'Territory budget with negative amount should not be updated');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Total_Territory_Funds_Approved_Cannot_Be_Negative_OR_Zero), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateStartDate_PastCurrent_insert_Fail() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);

        Test.startTest();
        List<EMS_Budget_Territory_gne__c> territoryBudgets = new List<EMS_Budget_Territory_gne__c>();
        // Insert
        try {
            territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0], Date.today().addYears(-1), Date.today().addYears(-1), String.valueOf(Date.today().addYears(-1).year()));
            System.assert(false, 'Territory budget with past start date should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Start_Date_Cannot_Be_Prior_Than_Current_Year), ex.getMessage());
        }
        try {
            territoryBudgets.clear();
            territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);
        } catch (DMLException ex) {
            System.assert(false, 'Territory budget with current start date should be inseted: ' + ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateStartDate_update_Fail() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);

        Test.startTest();
        // Update
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Start_Date_gne__c = Date.today().addYears(-1);
            }
            update territoryBudgets;
            System.assert(false, 'Territory budget with past start date should not be updated');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Start_Date_Cannot_Be_Prior_Than_Current_Year), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateEndDate_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);

        Test.startTest();
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser, Date.today(), Date.today().addDays(-2), String.valueOf(Date.today().year()));
            System.assert(false, 'Territory budget with end date prior to start date should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date), ex.getMessage());
        }
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser);
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.End_Date_gne__c = tb.Start_Date_gne__c - 1;
            }
            update territoryBudgets;
            System.assert(false, 'Territory budget with end date prior to start date should not be updated');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.End_Date_Cannot_Be_Prior_Than_Start_Date), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole1_insert_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);

        Test.startTest();
        // Insert PM User Exception
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, pmUser);
            System.assert(false, 'Territory budget can only be assigned to RSM/Rep');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }
        // Insert Rep User Exception
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser);
        } catch (DMLException ex) {
            System.assert(false, 'Territory budget should be assigned to RSM');
        }
        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole1_update_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser);

        Test.startTest();
        // Update Rep User Exception
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Assigned_to_gne__c = pmUser;
            }
            update territoryBudgets;
            System.assert(false, 'Territory budget cannot be assigned to PM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateIfStartEndDatesYearInCalendarYear_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser, Date.today().addYears(1), Date.today().addYears(1), String.valueOf(Date.today().year()));
            System.assert(false, 'Territory budget with start date not in the calendar year should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Start_End_Dates_in_different_calendar_year), ex.getMessage());
        }
        // Update
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser, EMS_Test_Util.getStartDate(), EMS_Test_Util.getStartDate(), String.valueOf(Date.today().year()));
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Year_gne__c = String.valueOf(Date.today().addYears(-1).year());
            }
            update territoryBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Start_End_Dates_in_different_calendar_year), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateSameYearAsRegionBudget_insertupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser, Date.today().addYears(1), Date.today().addYears(1), String.valueOf(Date.today().addYears(1).year()));
            System.assert(false, 'Territory budget with different year than the region budget should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Invalid_Year), ex.getMessage());
        }
        // Update
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser, EMS_Test_Util.getStartDate(), EMS_Test_Util.getStartDate(), String.valueOf(Date.today().year()));
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.End_Date_gne__c = Date.today().addYears(1);
                tb.Start_Date_gne__c = Date.today().addYears(1);
                tb.Year_gne__c = String.valueOf(Date.today().addYears(1).year());
            }
            update territoryBudgets;
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Invalid_Year), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateInactiveBudget_update_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser);
        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            tb.Status_gne__c = 'Inactive';
        }
        update territoryBudgets;

        Test.startTest();
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Status_gne__c = 'Active';
            }
            update territoryBudgets;
            System.assert(false, 'Inactive territory budget should not be activated');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Cannot_activate_inactive_budget), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateIfInactiveBudgetEdited_update_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser);
        for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
            tb.Status_gne__c = 'Inactive';
        }
        update territoryBudgets;

        Test.startTest();
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Total_Territory_Funds_Approved_gne__c = 15.0;
            }
            update territoryBudgets;
            System.assert(false, 'Inactive territory budget should not be updated');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_editing_inactive_budget), ex.getMessage());
        }
        Test.stopTest();
    }


    private static testMethod void validateIfDatesBeetweenDatesOfRegionBudget_inserupdate_Fail() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('RSM', 'Rep');
        Id rsmUser = ids[0];
        Id repUser = ids[1];
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);
        System.assertNotEquals(null, repUser);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUser, 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUser);
        Date yesterday = EMS_Test_Util.getStartDate().addDays(-1);
        Date today = EMS_Test_Util.getStartDate();

        Test.startTest();
        // Insert
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser, yesterday, yesterday, String.valueOf(yesterday.year()));
            System.assert(false, 'Territory budget with start date earlier than region budget start date should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Start_End_dates_must_be_between_parent_budget_Dates), ex.getMessage());
        }

        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser, yesterday, today, String.valueOf(yesterday.year()));
            System.assert(false, 'Territory budget with start date earlier than region budget start date should not be inseted');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Start_End_dates_must_be_between_parent_budget_Dates), ex.getMessage());
        }
        // Update
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUser, today, today, String.valueOf(today.year()));
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Start_Date_gne__c = yesterday;
            }
            update territoryBudgets;
            System.assert(false, 'Territory budget with start date earlier than region budget start date should not be updated');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Start_End_dates_must_be_between_parent_budget_Dates), ex.getMessage());
        }
        try {
            for (EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Start_Date_gne__c = yesterday;
                tb.End_Date_gne__c = yesterday;
            }
            update territoryBudgets;
            System.assert(false, 'Territory budget with start date earlier than region budget start date should not be updated');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Start_End_dates_must_be_between_parent_budget_Dates), ex.getMessage());
        }
        Test.stopTest();

    }

/*
    private static testMethod void validateAssignedToUserRole2_update_Fail() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);

        Test.startTest();
        try {
            for(EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Assigned_to_gne__c = pmUsers[0];
            }
            update territoryBudgets;
            System.assert(false, 'Territory budget cannot be assigned to PM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }
        try {
            for(EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Assigned_to_gne__c = repUsers[0];
            }
            update territoryBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Territory budget should be assigned to Rep');
        }
        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole4Test() {
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
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);
        } catch (DMLException ex) {
            System.assert(false, 'Territory budget should be assigned to RSM');
        }
        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole5Test() {
        // select test users
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        List<Id> mlUsers = EMS_Test_Util.findExistingUser('ML', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', null);

        System.assertNotEquals(0, mmUsers.size());
        System.assertNotEquals(0, mlUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, mmUsers[0], 'Medical Department', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, mlUsers[0]);

        Test.startTest();
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);
            System.assert(false, 'Medical territory budget cannot be assigned to Rep');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateAssignedToUserRole6Test() {
        // select test users
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        List<Id> mlUsers = EMS_Test_Util.findExistingUser('ML', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', null);

        System.assertNotEquals(0, mmUsers.size());
        System.assertNotEquals(0, mlUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, mmUsers[0], 'Medical Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, mlUsers[0]);

        Test.startTest();
        try {
            List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);
            System.assert(false, 'Medical territory budget cannot be assigned to RSM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }
        Test.stopTest();
    }

    // Update
    private static testMethod void validateAssignedToOnUpdateTest3() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Product', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);

        Test.startTest();
        try {
            for(EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Assigned_to_gne__c = repUsers[0];
            }
            update territoryBudgets;


        } catch (DMLException ex) {
            System.assert(false, 'Territory budget should be assigned to RSM');
        }
        Test.stopTest();
    }

    private static testMethod void validateAssignedToOnUpdateTest4() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Department', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);

        Test.startTest();
        try {
            for(EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Assigned_to_gne__c = pmUsers[0];
            }
            update territoryBudgets;

            System.assert(false, 'Territory budget cannot be assigned to PM');
        } catch (DMLException ex) {
            System.assert(ex.getMessage().contains(System.Label.Budget_Invalid_Assigned_To_User), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void validateAssignedToOnUpdateTest5() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Department', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);

        Test.startTest();
        try {
            for(EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Assigned_to_gne__c = repUsers[0];
            }
            update territoryBudgets;


        } catch (DMLException ex) {
            System.assert(false, 'Territory budget should be assigned to Rep');
        }
        Test.stopTest();
    }

    private static testMethod void validateAssignedToOnUpdateTest6() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> rsmUsers = EMS_Test_Util.findExistingUser('RSM', null);
        List<Id> repUsers = EMS_Test_Util.findExistingUser('Rep', rsmUsers[0]);
        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, rsmUsers.size());
        System.assertNotEquals(0, repUsers.size());

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0.0, 1000.0, pmUsers[0], 'Commercial Department', BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0.0, 900.0, rsmUsers[0]);
        List<EMS_Budget_Territory_gne__c> territoryBudgets = EMS_Test_Util.createOneTerritoryBudgetForEachRB(regionBudgets, 0.0, 10.0, repUsers[0]);

        Test.startTest();
        try {
            for(EMS_Budget_Territory_gne__c tb : territoryBudgets) {
                tb.Assigned_to_gne__c = repUsers[0];
            }
            update territoryBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Territory budget should be assigned to RSM');
        }
        Test.stopTest();
    }

*/
}