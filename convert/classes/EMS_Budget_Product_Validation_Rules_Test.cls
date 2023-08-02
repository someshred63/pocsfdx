@isTest
private class EMS_Budget_Product_Validation_Rules_Test {

    private static final Integer BATCH_SIZE = 11;//210;
    private static final String COST_CENTER_NAME = 'Commercial Product';

	/**
	 *  1. validateAssignedToTerritoryName [bI,bU]
	 *  2. validateTotalApprovedAmount [bI,bU]
	 *  3. validateTotalAllocatedAmount [bI,bU]
	 *  4. validateStartDate [bI,bU]
	 *  5. validateEndDate [bI,bU]
	 *  6. validateAssignedToUserRole 
	 *  7. validateIfStartEndDatesYearInCalendarYear [bI,bU]
	 *
	 *  8. validateInactiveBudget [bU]
	 *  9. validateIfInactiveBudgetEdited [bU]
	 *
	 * 10. onBeforeDelete [bD]
	 * 
	 */

    //1.1 validateAssignedToTerritoryName. Territory is not on the List. Fail.
    private static testMethod void validateAssignedToTerritoryName_territoryIsNotOntheList_Fail_Test_SkippingValidation() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, 100, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            pb.Assigned_To_Territory_gne__c = 'This Territory does not exist';
        }
        update productBudgets;

    }

    private static testMethod void validateAssignedToTerritoryName_territoryIsNotOntheList_Fail_Test_insert() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Update
        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, 100, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE, false);
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Assigned_To_Territory_gne__c = 'This Territory does not exist';
            }
            insert productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.No_Territory_named), ex.getMessage());
            }
        }
    }

    private static testMethod void validateAssignedToTerritoryName_territoryIsNotOntheList_Fail_Test_update() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Update
        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, 100, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Assigned_To_Territory_gne__c = 'This Territory does not exist';
            }
            update productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.No_Territory_named), ex.getMessage());
            }
        }
    }

    //2.1 validateTotalApprovedAmount. Amount negtive. Fail.
    private static testMethod void validateTotalApprovedAmount_amountLessThanZero_Fail_Test_insert() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, -1000.0, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Total_Product_Funds_Approved_Cannot_Be_Negative_OR_Zero), ex.getMessage());
            }
        }
    }

    private static testMethod void validateTotalApprovedAmount_amountLessThanZero_Fail_Test_update() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, 1000.0, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Total_Product_Funds_Approved_gne__c = -10;
            }
            update productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Total_Product_Funds_Approved_Cannot_Be_Negative_OR_Zero), ex.getMessage());
            }
        }
    }

    //2.2 validateTotalApprovedAmount. Amount 0. Fail.
    private static testMethod void validateTotalApprovedAmount_amountEqualsZero_Fail_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, -1000.0, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Total_Product_Funds_Approved_Cannot_Be_Negative_OR_Zero), ex.getMessage());
            }
        }
    }

    //2.3 validateTotalApprovedAmount. Amount more than 0. Pass.
    private static testMethod void validateTotalApprovedAmount_amountMoreThanZero_Pass_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);
        List<EMS_Budget_Product_gne__c> productBudgets;

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 1000.0, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        // Update
        try {
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Total_Product_Funds_Approved_gne__c = 500;
            }
            update productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
    }

    //3.1 validateTotalAllocatedAmount. Amount less than Child_Budgets_Allocated_Amount_gne__c. Fail.
    private static testMethod void validateTotalAllocatedAmount_amountLessThanChildBudgetsAloocated_Fail_Test_insert() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (100, 90, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Total_Budget_Allocated_Amount_Cannot_Be_Higher_Than_Funds_Approved_Amount), ex.getMessage());
            }
        }
    }

    private static testMethod void validateTotalAllocatedAmount_amountLessThanChildBudgetsAloocated_Fail_Test_update() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (100, 110, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Total_Product_Funds_Approved_gne__c = 90;
            }
            update productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Total_Budget_Allocated_Amount_Cannot_Be_Higher_Than_Funds_Approved_Amount), ex.getMessage());
            }
        }
    }

    //3.3 validateTotalAllocatedAmount. Amount more than Child_Budgets_Allocated_Amount_gne__c. Pass.
    private static testMethod void validateTotalAllocatedAmount_amountMoreChildBudgetsAloocated_Pass_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets;
        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (100, 110, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        // Update
        try {
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Child_Budgets_Allocated_Amount_gne__c = 90;
            }
            update productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
    }

    //4.1 validateStartDate. Start Date in current year. Pass.
    private static testMethod void validateStartDate_startDateInCurrentYear_Pass_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets;
        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today() - 10, Date.today() + 5, BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        // Update
        try {
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Start_Date_gne__c = Date.today() - 9;
            }
            update productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
    }

    //4.3 validateStartDate. Start Date before current year. Fail
    private static testMethod void validateStartDate_startDateAfterEndDate_Fail_Test_insert() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today() - 365, Date.today() - 355, BATCH_SIZE);
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Start_Date_Cannot_Be_Prior_Than_Current_Year), ex.getMessage());
            }
        }
    }

    private static testMethod void validateStartDate_startDateAfterEndDate_Fail_Test_update() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, EMS_Test_Util.getStartDate(), EMS_Test_Util.getStartDate() + 10, BATCH_SIZE);
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Start_Date_gne__c = pb.Start_Date_gne__c - 364;
            }
            update productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Start_Date_Cannot_Be_Prior_Than_Current_Year), ex.getMessage());
            }
        }
    }

    //5.1 validateEndDate. End Date before Start Date. Fail
    private static testMethod void validateEndDate_endDateBeforeStartDate_Fail_Test_insert() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today() - 5, BATCH_SIZE);
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.End_Date_Cannot_Be_Prior_Than_Start_Date), ex.getMessage());
            }
        }
    }

    private static testMethod void validateEndDate_endDateBeforeStartDate_Fail_Test_update() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today() + 10, BATCH_SIZE);
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.End_Date_gne__c = Date.today() - 10;
            }
            update productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.End_Date_Cannot_Be_Prior_Than_Start_Date), ex.getMessage());
            }
        }
    }

    //5.2 validateEndDate. End Date equals Start Date. Pass
    private static testMethod void validateEndDate_endDateEqualsStartDate_Pass_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today(), BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
    }

    //5.3 validateEndDate. End Date after Start Date. Pass
    private static testMethod void validateEndDate_endDateAfterStartDate_Pass_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets;
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today() + 5, BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        // Update
        try {
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.End_Date_gne__c = Date.today() + 6;
            }
            update productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
    }

    //7.2 validateIfStartEndDatesYearInCalendarYear. Start Date in current year. Pass.
    private static testMethod void validateIfStartEndDatesYearInCalendarYear_startDateInCurrentYear_Pass_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);
        List<EMS_Budget_Product_gne__c> productBudgets;

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today() + 5, BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        // Update
        try {
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Start_Date_gne__c = Date.today() + 1;
            }
            update productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
    }


    //7.3 validateIfStartEndDatesYearInCalendarYear. Start Date after current year. Fail.
    private static testMethod void validateIfStartEndDatesYearInCalendarYear_startDateAfterCurrentYear_Fail_Test_insert() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);
        List<EMS_Budget_Product_gne__c> productBudgets;

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today() + 500, Date.today() + 510, BATCH_SIZE);
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Budget_Start_End_Dates_in_different_calendar_year), ex.getMessage());
            }
        }
    }

    private static testMethod void validateIfStartEndDatesYearInCalendarYear_startDateAfterCurrentYear_Fail_Test_update() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);
        List<EMS_Budget_Product_gne__c> productBudgets;

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today(), BATCH_SIZE);
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Start_Date_gne__c = Date.today() + 500;
                pb.End_Date_gne__c = Date.today() + 520;
            }
            update productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Budget_Start_End_Dates_in_different_calendar_year), ex.getMessage());
            }
        }
    }


    //7.5 validateIfStartEndDatesYearInCalendarYear. End Date in current year. Pass.
    private static testMethod void validateIfStartEndDatesYearInCalendarYear_endDateInCurrentYear_Pass_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);
        List<EMS_Budget_Product_gne__c> productBudgets;

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        // Insert
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today() + 5, BATCH_SIZE);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }

        // Update
        try {
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.End_Date_gne__c = Date.today() + 6;
            }
            update productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
    }


    //7.6 validateIfStartEndDatesYearInCalendarYear. End Date after current year. Fail.
    private static testMethod void validateIfStartEndDatesYearInCalendarYear_endDateAfterCurrentYear_Fail_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        try {
            List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today() + 500, BATCH_SIZE);
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Budget_Start_End_Dates_in_different_calendar_year), ex.getMessage());
            }
        }
    }


    //8. validateInactiveBudget. Budget state changed from Inactive to any other. Fail.
    private static testMethod void validateInactiveBudget_BudgetStateChangedFromInactive_Fail_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        // Insert
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, Date.today(), Date.today() + 5, BATCH_SIZE);

        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            pb.Status_gne__c = 'Inactive';
        }
        update productBudgets;

        // Update
        Test.startTest();
        try {
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                pb.Status_gne__c = 'Active';
            }
            update productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Cannot_activate_inactive_budget), ex.getMessage());
            }
        }
        Test.stopTest();
    }

    //9. validateIfInactiveBudgetEdited. Fail.
    private static testMethod void validateIfInactiveBudgetEdited_filedEditenOnInactiveBudget_Fail_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(null, pmTestUsers);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);

        for (EMS_Budget_Product_gne__c pb : productBudgets) {
            pb.Status_gne__c = 'Inactive';
        }
        update productBudgets;

        Test.startTest();
        try {
            for (EMS_Budget_Product_gne__c pb : productBudgets) {
                Date newDate = Date.newInstance(pb.Start_Date_gne__c.year(), pb.Start_Date_gne__c.month(), pb.Start_Date_gne__c.day());
                pb.End_Date_gne__c = newDate.addDays(2);
            }
            update productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Budget_editing_inactive_budget), ex.getMessage());
            }
        }
        Test.stopTest();
    }

    //10.1 onBeforeDelete. Delete PB wihout child budgets. Pass.
    private static testMethod void onBeforeDelete_DeletePBWihoutChildBudgets_Pass_Test() {
        List<Id> pmTestUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmTestUsers.size());

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmTestUsers.get(0), COST_CENTER_NAME, BATCH_SIZE);

        try {
            delete productBudgets;
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
    }

    //10.2 onBeforeDelete. Try dleete PB with child budgets. Fail.
    private static testMethod void onBeforeDelete_DeletePBWithChildBudgets_Fail_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmUser, COST_CENTER_NAME, BATCH_SIZE);
        List<EMS_Budget_Region_gne__c> regionBudgets = EMS_Test_Util.createOneRegionBudgetForEachPB(productBudgets, 0, 50, rsmUser);

        try {
            delete productBudgets;
            System.assert(false, 'Record inserted without expected errors, check tests!');
        } catch (DMLException ex) {
            List<ApexPages.Message> msgs = ApexPages.getMessages();
            for (ApexPages.Message msg : msgs) {
                System.assert(msg.getSummary().contains(System.label.Remove_Related_Records), ex.getMessage());
            }
        }
    }

}