@isTest
private class EMS_Roche_Attendee_Child_Rec_Update_Test {

    private static final Integer BATCH_SIZE = 199;
    private static final String COST_CENTER_NAME = 'Commercial Product';

    /**
     * 1. createSharingRecordWithEvent [aI,aU]
     * 2. deleteSharingRecordWithEvent [bD]
     */

    //1. createSharingRecordWithEvent
    private static testMethod void createSharingRecordWithEvent_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Set<Id> rocheAttendeeIds = new Set<Id>();
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');
        List<EMS_Util.EMS_Territory> rsmUserTerritories = EMS_Util.getUserTerritories(rsmUser); // Existing RSM user must have at leat one territory assigned

        System.assertNotEquals(0, rsmUserTerritories.size());

        Test.startTest();
        List<EMS_Budget_Product_gne__c> productBudgets;
        List<EMS_Event__c> events;
        List<EMS_Roche_Attendee_gne__c> attendees;
        // Insert records
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmUser, 'Commercial Product', BATCH_SIZE);
            events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, BATCH_SIZE);
            attendees = EMS_Test_Util.createRocheAttendees(events, rsmUser, rsmUserTerritories.get(0).Id);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        System.assertNotEquals(0, attendees.size());

        for (EMS_Roche_Attendee_gne__c ra : attendees) {
            rocheAttendeeIds.add(ra.User_gne__c);
        }

        String rowCause = Schema.EMS_Event__Share.RowCause.Event_Attendee__c;
        List<EMS_Event__Share> eventShares = [SELECT Id, AccessLevel, ParentId, UserOrGroupId, RowCause FROM EMS_Event__Share WHERE RowCause = :rowCause AND AccessLevel = 'Read'];
        System.assertNotEquals(0, eventShares.size());

        for (EMS_Event__Share es : eventShares) {
            System.assertEquals('Read', es.AccessLevel);
        }
        Test.stopTest();
    }

    //2. deleteSharingRecordWithEvent
    private static testMethod void deleteSharingRecordWithEvent_Test() {
        List<Id> ids = EMS_Test_Util.findDependentUserUnderSpecificRole('PM', 'RSM');
        Id pmUser = ids[0];
        Id rsmUser = ids[1];
        System.assertNotEquals(null, pmUser);
        System.assertNotEquals(null, rsmUser);

        Set<Id> rocheAttendeeIds = new Set<Id>();
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Program', 'Product Promo', 'Commercial Product');

        List<EMS_Util.EMS_Territory> rsmUserTerritories = EMS_Util.getUserTerritories(rsmUser); // Existing RSM user must have at leat one territory assigned
        System.assertNotEquals(0, rsmUserTerritories.size());

        Test.startTest();
        List<EMS_Budget_Product_gne__c> productBudgets;
        List<EMS_Event__c> events;
        List<EMS_Roche_Attendee_gne__c> attendees;
        // Insert records
        try {
            productBudgets = EMS_Test_Util.createMultipleProductBudgets (0, 100, pmUser, 'Commercial Product', BATCH_SIZE);
            events = EMS_Test_Util.createEvents ('Planned', pmUser, 'Program', 'Product Promo', Date.today() + 1, Date.today() + 3, BATCH_SIZE);
            attendees = EMS_Test_Util.createRocheAttendees(events, rsmUser, rsmUserTerritories.get(0).Id);
        } catch (DMLException ex) {
            System.assert(false, 'Test failed with unexpected errors, check tests! Error: ' + ex.getMessage());
        }
        System.assertNotEquals(0, attendees.size());

        for (EMS_Roche_Attendee_gne__c ra : attendees) {
            rocheAttendeeIds.add(ra.User_gne__c);
        }

        String rowCause = Schema.EMS_Event__Share.RowCause.Event_Attendee__c;
        List<EMS_Event__Share> eventShares = [SELECT Id, AccessLevel, ParentId, UserOrGroupId, RowCause FROM EMS_Event__Share WHERE RowCause = :rowCause AND AccessLevel = 'Read'];
        System.assertNotEquals(0, eventShares.size());

        for (EMS_Event__Share es : eventShares) {
            System.assertEquals('Read', es.AccessLevel);
        }

        // Delete
        delete attendees;

        // Verify delete
        eventShares.clear();
        eventShares = [SELECT Id, AccessLevel, ParentId, UserOrGroupId, RowCause FROM EMS_Event__Share WHERE RowCause = :rowCause AND UserOrGroupId IN :rocheAttendeeIds];

        System.assertEquals(0, eventShares.size());
        Test.stopTest();
    }
}