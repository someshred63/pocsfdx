@isTest
private class EMS_Speaker_Role_Child_Record_Upd_Test {
    private static Integer BATCH_SIZE = 101;

    @isTest
    static void updateEventStatusTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        for (EMS_Speaker_Role_gne__c paymentRequest :paymentRequests) {
            paymentRequest.Status_gne__c = 'Submitted';
        }
        update paymentRequests;
        Test.stopTest();
        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Payment Request Initiated', event.Status_gne__c);
        }
    }

    @isTest
    static void createAttendeeFromSpeakerRoleNoAttendeesTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');

        // select attendee
        System.assertEquals(0, [SELECT count() FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :events AND Account_gne__c = :hcp.Id]);

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        Test.stopTest();

        System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :events AND Account_gne__c = :hcp.Id]);
    }

    @isTest
    static void createAttendeeFromSpeakerRoleWithAttendeesTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        Account existingAttendee = EMS_Test_util.createAndInsertAccount('test', 'account');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        List<EMS_Attendee_gne__c> attendees = EMS_Test_Util.createAttendees(existingAttendee, events);

        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');
        // select attendee
        System.assertEquals(0, [SELECT count() FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :events AND Account_gne__c = :hcp.Id]);

        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        Test.stopTest();
        System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :events AND Account_gne__c = :hcp.Id]);
    }

    @isTest
    static void createAttendeeFromSpeakerRoleWithExistingAttendeeTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        Account hcp = EMS_Test_util.createAndInsertAccount('test', 'account');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        List<EMS_Attendee_gne__c> attendees = EMS_Test_Util.createAttendees(hcp, events);

        // select attendee
        System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :events AND Account_gne__c = :hcp.Id]);
        Test.startTest();
        List<EMS_Speaker_Role_gne__c> paymentRequests = EMS_Test_Util.createPaymentRequests('HCP/HCO Payment Request', events, hcp.Id, null, Date.today());
        Test.stopTest();
        System.assertEquals(BATCH_SIZE, [SELECT count() FROM EMS_Attendee_gne__c WHERE EMS_Event_gne__c IN :events AND Account_gne__c = :hcp.Id]);
    }

}