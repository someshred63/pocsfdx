@isTest
private class EMS_Attachment_Validation_Rules_test {
    private static Integer BATCH_SIZE = 101;

    @isTest
    static void validateNotNullTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Test.startTest();
        try {
            EMS_Test_Util.createAttachments(events, '');
            System.assert(false, 'Attachment without the type should not be added to the event');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains(System.label.Must_Enter_A_Value));
        }
        Test.stopTest();
    }

    @isTest
    static void signedContractNonAARCUserTest() {
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

        Test.startTest();
        // select PM user
        User pmUser = [SELECT Id FROM User WHERE Id IN :pmUsers AND IsActive = true LIMIT 1];
        try {
            System.runAs(pmUser) {
                EMS_Test_Util.createAttachments(events, 'Signed Contract');
            }
            System.assert(false, 'Signed Contract should not be added to unplanned event');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains(System.label.EMS_Signed_Contract_AARC), ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void signedContractAARCUserTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        List<Id> aarcUsers = EMS_Test_Util.findExistingUser('AARC', null);

        System.assertNotEquals(0, pmUsers.size());
        System.assertNotEquals(0, aarcUsers.size());

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

        // select AARC user
        User aarcUser = [SELECT Id FROM User WHERE Id IN :aarcUsers AND IsActive = true LIMIT 1];
        EMS_Test_Util.getUserApplicationContext(aarcUser, true, 'AARC', null, 'EMS-Canada');

        Test.startTest();
        try {
            System.runAs(aarcUser) {
                EMS_Test_Util.createAttachments(events, 'Signed Contract');
            }
        } catch (DmlException ex) {
            System.assert(false, 'Signed Contract should be added by AARC');
        }
        Test.stopTest();
    }


    @isTest
    static void validateSignedContractUnlpannedEventTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Test.startTest();
        try {
            EMS_Test_Util.createAttachments(events, 'Signed Contract');
            System.assert(false, 'Signed Contract should not be added to unplanned event');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains(System.label.EMS_Signed_Contract_Awaiting_Signature));
        }
        Test.stopTest();
    }

    @isTest
    static void validateSignedContractAwaitingSignatureEventTest() {
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
        try {
            EMS_Test_Util.createAttachments(events, 'Signed Contract');
        } catch (DmlException ex) {
            System.assert(false, 'Signed Contract should be added to event with Awaiting Signature from HCP status');
        }
        Test.stopTest();
    }

    @isTest
    static void validateSignedContractSignedAgreementEventTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Signed Agreement Received';
        }
        update events;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EMS_Test_Util.getUserApplicationContext(currentUser, true, 'Admin', null, 'EMS-Canada');

        Test.startTest();
        try {
            EMS_Test_Util.createAttachments(events, 'Signed Contract');
        } catch (DmlException ex) {
            System.assert(false, 'Signed Contract should be added to event with Signed Agreement Received status');
        }
        Test.stopTest();
    }

    @isTest
    static void validateClosedEventTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today(), 100.0, BATCH_SIZE);

        for (EMS_Event__c event : events) {
            event.Status_gne__c = 'Closed';
        }
        update events;

        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        EMS_Test_Util.getUserApplicationContext(currentUser, true, 'Admin', null, 'EMS-Canada');

        Test.startTest();
        try {
            EMS_Test_Util.createAttachments(events, 'Signed Contract');
        } catch (DmlException ex) {
            System.assert(false, 'Signed Contract should be added to the closed event.');
        }
        Test.stopTest();
    }
}