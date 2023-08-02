@isTest
private class EMS_GSD_Detail_Validation_Rules_Test {
    private static Integer BATCH_SIZE = 101;

    // insert
    @isTest
    static void validateInvalidPostalCodeOnInsertTest() {
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
            EMS_Test_Util.createGSDDetails(events, 'inavlid_postal_code', null);
            System.assert(false, 'GSD detail with invalid postal code should not be inserted');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains(System.label.Address_Invalid_Canada_Postal_Code), ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void validateValidPostalCodeOnInsertTest() {
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
            EMS_Test_Util.createGSDDetails(events, 'A0A 1B1', null);
        } catch (DmlException ex) {
            System.assert(false, 'GSD detail with valid postal code should be inserted: ' + ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void validateInvalidURLOnInsertTest() {
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
            EMS_Test_Util.createGSDDetails(events, 'A0A 1B1', 'invalid_url');
            System.assert(false, 'GSD detail with invalid URL should not be inserted');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains(System.label.Invalid_URL), ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void validateValidURLOnInsertTest() {
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
            EMS_Test_Util.createGSDDetails(events, 'A0A 1B1', 'google.com');
        } catch (DmlException ex) {
            System.assert(false, 'GSD detail with valid URL should be inserted: ' + ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void validateDuplicateGSDDetailOnInsertTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        EMS_Test_Util.createGSDDetails(events);

        Test.startTest();
        try {
            EMS_Test_Util.createGSDDetails(events);
            System.assert(false, 'Duplicate GSD detail should not be inserted');
        } catch (DmlException ex) {

            System.assert(ex.getMessage().contains(System.label.EMS_GSD_Detail_Already_Exists), ex.getMessage());
        }
        Test.stopTest();
    }

    // update
    @isTest
    static void validateInvalidPostalCodeOnUpdateTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        List<EMS_GSD_Detail__c> gsdDetails = EMS_Test_Util.createGSDDetails(events, 'A0A 1B1', null);

        Test.startTest();
        try {
            for (EMS_GSD_Detail__c gsdDetail : gsdDetails) {
                gsdDetail.Postal_Code_gne__c = 'invalid_postal_code';
            }
            update gsdDetails;
            System.assert(false, 'GSD detail with invalid postal code should not be inserted');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains(System.label.Address_Invalid_Canada_Postal_Code), ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void validateValidPostalCodeOnUpdateTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        List<EMS_GSD_Detail__c> gsdDetails = EMS_Test_Util.createGSDDetails(events, 'A0A 1B1', 'google.com');

        Test.startTest();
        try {
            for (EMS_GSD_Detail__c gsdDetail : gsdDetails) {
                gsdDetail.Postal_Code_gne__c = 'A1A 2B2';
            }
            update gsdDetails;
        } catch (DmlException ex) {
            System.assert(false, 'GSD detail with valid postal code should be updated: ' + ex.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void validateInvalidURLOnUpdateTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        List<EMS_GSD_Detail__c> gsdDetails = EMS_Test_Util.createGSDDetails(events, 'A0A 1B1', 'google.com');

        Test.startTest();
        try {
            for (EMS_GSD_Detail__c gsdDetail : gsdDetails) {
                gsdDetail.Website_URL_gne__c = 'invalid_url';
            }
            update gsdDetails;
            System.assert(false, 'GSD detail with invalid URL should not be inserted');
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains(System.label.Invalid_URL), ex.getMessage());
        }
        Test.stopTest();
    }

    static void validateValidURLOnUpdateTest() {
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');
        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);
        List<EMS_GSD_Detail__c> gsdDetails = EMS_Test_Util.createGSDDetails(events, 'A0A 1B1', 'google.com');

        Test.startTest();
        try {
            for (EMS_GSD_Detail__c gsdDetail : gsdDetails) {
                gsdDetail.Website_URL_gne__c = 'yahoo.com';
            }
            update gsdDetails;
        } catch (DmlException ex) {
            System.assert(false, 'GSD detail with valid URL should be inserted: ' + ex.getMessage());
        }
        Test.stopTest();
    }
}