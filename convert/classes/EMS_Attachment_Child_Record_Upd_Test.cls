@isTest
private class EMS_Attachment_Child_Record_Upd_Test {
    private static Integer BATCH_SIZE = 101;

    @isTest
    static void changeEventStatusOnSignedContractTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Awaiting Signature from HCP';
        }
        update events;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EMS_Test_Util.getUserApplicationContext(currentUser, true, 'Admin', null, 'EMS-Canada');

        Test.startTest();
        EMS_Test_Util.createAttachments(events, 'Signed Contract');
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Signed Agreement Received', event.Status_gne__c);
        }
    }

    @isTest
    static void changeEventStatusOnOtherThanSignedContractTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EMS_Test_Util.getUserApplicationContext(currentUser, true, 'Admin', null, 'EMS-Canada');

        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Awaiting Signature from HCP';
        }
        update events;

        Test.startTest();
        EMS_Test_Util.createAttachments(events, 'Other');
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Awaiting Signature from HCP', event.Status_gne__c);
        }
    }

    @isTest
    static void doNotChangeEventStatusOnClosedEventTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today(), 100.0, BATCH_SIZE);

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EMS_Test_Util.getUserApplicationContext(currentUser, true, 'Admin', null, 'EMS-Canada');

        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        Test.startTest();
        EMS_Test_Util.createAttachments(events, 'Signed Contract');
        Test.stopTest();

        for (EMS_Event__c event : [SELECT Status_gne__c FROM EMS_Event__c WHERE Id IN :events]) {
            System.assertEquals('Closed', event.Status_gne__c);
        }
    }
}