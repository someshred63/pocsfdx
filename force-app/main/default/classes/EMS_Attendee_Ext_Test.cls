@isTest
private class EMS_Attendee_Ext_Test {

    static testMethod void controllerInit() {

        //Finding proper user
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Corporate Relations', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        EMS_Budget_Product_gne__c budget = EMS_Test_Util.createProductBudget(0, 100, mmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Donation', 'Donation / Patient Association', costCenters[0]);

        EMS_Event__c event = EMS_Test_Util.createEvent('Unplanned', mmUsers[0], 'Donation', 'Donation / Patient Association', Date.today(), Date.today() + 2);

        EMS_Attendee_gne__c attendee = EMS_Test_Util.createAttendee(event.Id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(attendee);
        EMS_Attendee_Ext ctrl = new EMS_Attendee_Ext(stdCtrl);

    }
}