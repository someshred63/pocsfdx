@isTest
private class EMS_Table_With_Pagination_Ext_Test {

    private static Integer BATCH_SIZE = 21; // equals to 3 pages with 10 records on each one

    @isTest static void test_method_one() {
        String etype = 'Program';
        String esubtype = 'Product Promo';
        Decimal amount = 100;

        EMS_Email_Boxes__c emailboxes = new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
        insert emailboxes;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Budget_Product_gne__c> productBudgets = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today(), Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        List<EMS_Budget_Allocation_gne__c> budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Product_gne__c pb :productBudgets) {
            EMS_Budget_Allocation_gne__c ba = new EMS_Budget_Allocation_gne__c(
                    Allocated_Budget_gne__c = amount,
                    Percentage_Contribution_gne__c = 1,
                    Budget_Deductions_gne__c = 0,
                    EMS_Event_gne__c = event.Id,
                    RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                    EMS_Product_Budget_gne__c = pb.Id
            );
            budgetAllocations.add(ba);
        }
        insert budgetAllocations;

        Test.startTest();
        PageReference budgetPage = Page.EMS_Budget_Allocation_Page;
        budgetPage.getParameters().put('objectid', event.Id);
        Test.setCurrentPage(budgetPage);

        EMS_Budget_Allocation_Controller baCtrl = new EMS_Budget_Allocation_Controller();
        EMS_Table_With_Pagination_Ext twpCtrl = new EMS_Table_With_Pagination_Ext();

        Integer availableBudgetSize = baCtrl.myBudgets.objectList.size();
        twpCtrl.setWrappersList(baCtrl.myBudgets);

        System.assertEquals(twpCtrl.hasNext, (twpCtrl.countPages == 0) ? false : true);
        System.assertEquals(twpCtrl.hasPrevious, false);
        System.assertEquals(twpCtrl.currentPage, 1);

        List<EMS_Wrapper> wl = twpCtrl.getWrappersList().objectList.clone();
        twpCtrl.ascending = false;
        twpCtrl.compareBy = 'budgetName';
        twpCtrl.sortTable();
        System.assert(wl[0] != twpCtrl.getWrappersList().objectList[0]);

        twpCtrl.showLastPage();
        System.assert(twpCtrl.countPages == twpCtrl.currentPage);

        Integer curPageNumber = twpCtrl.currentPage;
        twpCtrl.showPreviousPage();
        System.assert((curPageNumber - 1) == twpCtrl.currentPage);

        twpCtrl.showNextPage();
        System.assert(curPageNumber == twpCtrl.currentPage);

        // set page to jump on
        twpCtrl.currentPage = 1;
        twpCtrl.goToPage();
        Test.stopTest();
        // test comment to check if it works
    }

}