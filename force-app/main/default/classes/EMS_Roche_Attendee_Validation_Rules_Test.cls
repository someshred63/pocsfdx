@isTest
private class EMS_Roche_Attendee_Validation_Rules_Test {

    private static Integer BATCH_SIZE = 201;

    private static testMethod void checkForDuplicatedRAttendees_NoDuplicates_Test() {
        List<EMS_Event__c> events = new List<EMS_Event__c>();
        List<EMS_Roche_Attendee_gne__c> attendees = new List<EMS_Roche_Attendee_gne__c>();

        // select test user
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        //Create event
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today(), 10, BATCH_SIZE);

        Test.startTest();
        for (EMS_Event__c event : events) {
            EMS_Roche_Attendee_gne__c ra1 = new EMS_Roche_Attendee_gne__c(User_gne__c = rsmUser, EMS_Event_gne__c = event.Id);
            attendees.add(ra1);
            EMS_Roche_Attendee_gne__c ra2 = new EMS_Roche_Attendee_gne__c(User_gne__c = repUser, EMS_Event_gne__c = event.Id);
            attendees.add(ra2);
        }
        insert attendees;

        Test.stopTest();
    }

    private static testMethod void checkForDuplicatedRAttendees_new_Test() {
        List<EMS_Event__c> events = new List<EMS_Event__c>();
        List<EMS_Roche_Attendee_gne__c> attendees = new List<EMS_Roche_Attendee_gne__c>();

        // select test user
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        //Create event
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 10, BATCH_SIZE);

        Test.startTest();
        for (EMS_Event__c event : events) {
            EMS_Roche_Attendee_gne__c ra1 = new EMS_Roche_Attendee_gne__c(User_gne__c = rsmUser, EMS_Event_gne__c = event.Id);
            attendees.add(ra1);
            EMS_Roche_Attendee_gne__c ra2 = new EMS_Roche_Attendee_gne__c(User_gne__c = rsmUser, EMS_Event_gne__c = event.Id);
            attendees.add(ra2);
        }
        try {
            insert attendees;
        } catch (exception ex) {
            System.assert(ex.getMessage().contains(System.label.Event_Adding_duplicate_attendees), ex.getMessage());
        }
        Test.stopTest();
    }

    private static testMethod void checkForDuplicatedRAttendees_existing_Test() {
        List<EMS_Event__c> events = new List<EMS_Event__c>();
        List<EMS_Roche_Attendee_gne__c> attendees = new List<EMS_Roche_Attendee_gne__c>();

        // select test user
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Id repUser = EMS_Test_Util.findExistingUser('Rep', rsmUser)[0];
        System.assertNotEquals(null, repUser);

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        //Create event
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', costCenters[0]);
        events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 10, BATCH_SIZE);

        for (EMS_Event__c event : events) {
            EMS_Roche_Attendee_gne__c ra1 = new EMS_Roche_Attendee_gne__c(User_gne__c = rsmUser, EMS_Event_gne__c = event.Id);
            attendees.add(ra1);
        }
        insert attendees;

        Test.startTest();
        attendees = new List<EMS_Roche_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Roche_Attendee_gne__c ra1 = new EMS_Roche_Attendee_gne__c(User_gne__c = rsmUser, EMS_Event_gne__c = event.Id);
            attendees.add(ra1);
        }
        try {
            insert attendees;
        } catch (exception ex) {
            System.assert(ex.getMessage().contains(System.label.Event_Adding_duplicate_attendees), ex.getMessage());
        }
        Test.stopTest();
    }
}