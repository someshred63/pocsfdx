@isTest
private class EMS_Event_Email_Notifications_Test {

    private static Integer BATCH_SIZE = 11;

    private static testMethod void notifyEventOwnerRequestorOnEventCloseTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        EMS_Email_Boxes__c emailboxes = new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
        insert emailboxes;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', System.today(), System.today(), BATCH_SIZE);

        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
        update events;
        Test.stopTest();
    }

    private static testMethod void notifyEventOwnerRequestorOnEventCancelTest() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        EMS_Email_Boxes__c emailboxes = new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
        insert emailboxes;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', System.today(), System.today(), BATCH_SIZE);

        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Cancelled';
        }
        update events;
        Test.stopTest();
    }

    private static testMethod void notifyEventOwnerRequestorOnAgendaChange() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        EMS_Email_Boxes__c emailboxes = new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
        insert emailboxes;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', System.today(), System.today(), BATCH_SIZE);

        EMS_Event_Trigger_Helper.clearProcessedSet();

        Test.startTest();
        for (EMS_Event__c event : events) {
            event.Agenda_Comments_gne__c = 'New Agenda Value';
        }
        update events;
        Test.stopTest();
    }

    private static testMethod void notifyBPSMembers() {
        String eType = 'Sponsorship';
        String eSubtype = 'Sponsorship of Events';
        Decimal amount = 1000;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        EMS_Email_Boxes__c emailboxes = new EMS_Email_Boxes__c(Name = 'BPS', Main_Address__c = 'email@test.com');
        insert emailboxes;

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        List<EMS_Event_Configuration_gne__c> confs = [SELECT AARC_Uploads_Contract_gne__c FROM EMS_Event_Configuration_gne__c WHERE Event_Type_gne__c = :eType AND Event_Sub_Type_gne__c = :eSubtype];
        confs[0].AARC_Uploads_Contract_gne__c = true;
        update confs[0];

        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, amount * 10, pmUser, costCenters[0].Id);
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Pending Approval', pmUser, etype, esubtype, Date.today(), Date.today() + 7, amount * 2, BATCH_SIZE);

        Test.startTest();
        EMS_Event_Trigger_Helper.clearProcessedSet();
        for (EMS_Event__c event :events) {
            event.Start_Date_gne__c = event.Start_Date_gne__c.addDays(1);
        }
        update events;
        Test.stopTest();
    }
}