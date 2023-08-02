@isTest
private class EMS_Attendee_Validation_Rules_Test {

    private static Integer BATCH_SIZE = 10;//201;

    private static testMethod void onBeforeInsert_TriggerTest_EXCEPTIONS1() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 10, BATCH_SIZE);

        Account acc1 = EMS_Test_Util.createAndInsertAccount('John', 'Smith');
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Attendee_gne__c att = new EMS_Attendee_gne__c(Account_gne__c = acc1.Id, EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att);
        }
        insert attendees;

        Test.startTest();
        // EXCEPTION: Status is empty
        for (EMS_Attendee_gne__c att : attendees) {
            att.Role_gne__c = 'Attendee';
            att.Status_gne__c = '';
        }
        try {
            update attendees;
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Field Status is required.'), e.getMessage());
        }

        // EXCEPTION: Duplicated Attendees
        List<EMS_Attendee_gne__c> attendee_duplicate_list = new List<EMS_Attendee_gne__c>();
        attendee_duplicate_list.add(new EMS_Attendee_gne__c(Account_gne__c = acc1.Id, EMS_Event_gne__c = events[0].Id, Status_gne__c = 'Attended'));
        attendee_duplicate_list.add(new EMS_Attendee_gne__c(Account_gne__c = acc1.Id, EMS_Event_gne__c = events[0].Id, Status_gne__c = 'Attended'));
        try {
            insert attendee_duplicate_list;
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.Event_Adding_duplicate_attendees), e.getMessage());
        }

        // EXCEPTION: Duplicated IHCPs
        EMS_International_Speaker_gne__c ihcp = EMS_Test_Util.createAndInsertIHCP('Jim', 'Morrison');
        attendee_duplicate_list.clear();
        attendee_duplicate_list.add(new EMS_Attendee_gne__c(EMS_International_Speaker_gne__c = ihcp.id, EMS_Event_gne__c = events[0].Id, Status_gne__c = 'Attended'));
        attendee_duplicate_list.add(new EMS_Attendee_gne__c(EMS_International_Speaker_gne__c = ihcp.id, EMS_Event_gne__c = events[0].Id, Status_gne__c = 'Attended'));
        try {
            insert attendee_duplicate_list;
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.Event_Adding_duplicate_attendees), e.getMessage());
        }

        // Test Passes
        for (EMS_Attendee_gne__c att : attendees) {
            att.Status_gne__c = 'Attended';
        }
        update attendees;

        Test.stopTest();
    }

    private static testMethod void onBeforeInsert_TriggerTest_EXCEPTIONS2() {
        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUser, costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUser, 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 10, BATCH_SIZE);

        Account acc1 = EMS_Test_Util.createAndInsertAccount('John', 'Smith');
        EMS_International_Speaker_gne__c ihcp1 = EMS_Test_Util.createAndInsertIHCP('Jim', 'Morrison');
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Attendee_gne__c att = new EMS_Attendee_gne__c(Account_gne__c = acc1.Id, EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att);
        }
        insert attendees;

        Test.startTest();
        // EXCEPTION: Duplicated Attendee already exist
        try {
            insert (new EMS_Attendee_gne__c(Account_gne__c = acc1.Id, EMS_Event_gne__c = events[0].Id, Status_gne__c = 'Attended'));
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.Event_Adding_duplicate_attendees), e.getMessage());
        }

        // EXCEPTION: Duplicated IHCP already exist
        try {
            insert (new EMS_Attendee_gne__c(EMS_International_Speaker_gne__c = ihcp1.id, EMS_Event_gne__c = events[0].Id, Status_gne__c = 'Attended'));
            insert (new EMS_Attendee_gne__c(EMS_International_Speaker_gne__c = ihcp1.id, EMS_Event_gne__c = events[0].Id, Status_gne__c = 'Attended'));
        } catch (Exception e) {
            System.assert(e.getMessage().contains(System.Label.Event_Adding_duplicate_attendees), e.getMessage());
        }

        // Test Passes
        for (EMS_Attendee_gne__c att : attendees) {
            att.Status_gne__c = 'Attended';
        }
        update attendees;

        Test.stopTest();
    }


    private static testMethod void checkForDuplicatedAttendees_NoDuplicates_Test() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        //Create event
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 10, BATCH_SIZE);

        //Add accounts
        Account a1 = EMS_Test_Util.createAndInsertAccount('John', 'Smith');
        Account a2 = EMS_Test_Util.createAndInsertAccount('Mike', 'Tester');

        Test.startTest();
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Attendee_gne__c att1 = new EMS_Attendee_gne__c(Account_gne__c = a1.Id, EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att1);
            EMS_Attendee_gne__c att2 = new EMS_Attendee_gne__c(Account_gne__c = a2.Id, EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att2);
        }
        insert attendees;
        Test.stopTest();
    }

    private static testMethod void checkForDuplicatedAttendees_duplicates_Test() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        //Create event
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 10, BATCH_SIZE);

        //Add accounts
        Account a1 = EMS_Test_Util.createAndInsertAccount('John', 'Smith');

        Test.startTest();
        List<EMS_Attendee_gne__c> attendees = new List<EMS_Attendee_gne__c>();
        for (EMS_Event__c event : events) {
            EMS_Attendee_gne__c att1 = new EMS_Attendee_gne__c(Account_gne__c = a1.Id, EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att1);
            EMS_Attendee_gne__c att2 = new EMS_Attendee_gne__c(Account_gne__c = a1.Id, EMS_Event_gne__c = event.Id, Status_gne__c = 'Attended');
            attendees.add(att2);
        }
        try {
            insert attendees;
        } catch (exception ex) {
            System.assert(ex.getMessage().contains(System.label.Event_Adding_duplicate_attendees), ex.getMessage());
        }
        Test.stopTest();
    }

}