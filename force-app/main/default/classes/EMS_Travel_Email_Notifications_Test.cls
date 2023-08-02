@isTest
private class EMS_Travel_Email_Notifications_Test {
    private static Integer BATCH_SIZE = 101;

    @isTest
    static void notifyRequestorOnSubmitTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today(), BATCH_SIZE);

        // create travels
        Test.startTest();
        EMS_Test_Util.createTravels(events);
        Test.stopTest();
    }
}