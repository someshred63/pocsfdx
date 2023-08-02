@isTest
private class EMS_Event_Product_Validation_Rules_Test {
    private static Integer BATCH_SIZE = 101;

    @isTest
    static void validateEventProductAlreadyExistsOnInsert() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Product_vod__c product = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        EMS_Test_Util.createEventProducts(events, product.Id, strategy.Id);

        try {
            Test.startTest();

            EMS_Test_Util.createEventProducts(events, product.Id, strategy.Id);
            System.assert(false, 'Event products that already exist should not be inserted');

            Test.stopTest();
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.Event_Product_Product_Strategy_already_exists), ex.getMessage());
        }
    }

    @isTest
    static void validateEventProductAlreadyExistsOnUpdate() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Product_vod__c product = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        Product_vod__c product2 = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy2 = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        EMS_Test_Util.createEventProducts(events, product.Id, strategy.Id);

        List<EMS_Event_Product_gne__c> eventProducts = EMS_Test_Util.createEventProducts(events, product2.Id, strategy2.Id);

        try {
            Test.startTest();

            for (EMS_Event_Product_gne__c eventProduct : eventProducts) {
                eventProduct.Product_Indication_gne__c = product.Id;
                eventProduct.Product_Strategy_gne__c = strategy.Id;
            }

            update eventProducts;
            System.assert(false, 'Event products that already exist should not be updated');

            Test.stopTest();
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.Event_Product_Product_Strategy_already_exists), ex.getMessage());
        }
    }

    @isTest
    static void validateEventProductNotExistsOnUpdate() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Product_vod__c product = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        Product_vod__c product2 = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy2 = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        List<EMS_Event_Product_gne__c> eventProducts = EMS_Test_Util.createEventProducts(events, product.Id, strategy.Id);

        try {
            Test.startTest();

            for (EMS_Event_Product_gne__c eventProduct : eventProducts) {
                eventProduct.Product_Indication_gne__c = product2.Id;
                eventProduct.Product_Strategy_gne__c = strategy2.Id;
            }

            update eventProducts;


            Test.stopTest();
        } catch (Exception ex) {
            System.assert(false, 'Event products that not exist yet should not be updated');
        }
    }

    @isTest
    static void validateDuplicateEventProductOnInsert() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Product_vod__c product = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        try {
            Test.startTest();

            EMS_Test_Util.createEventProducts(events, product.Id, strategy.Id, 2);
            System.assert(false, 'Duplicate event products should not be inserted');

            Test.stopTest();
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.Event_Duplicate_Product_Product_Strategy), ex.getMessage());
        }
    }

    @isTest
    static void validateDuplicateEventProductOnUpdate() {
        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);

        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        List<EMS_Event__c> events = EMS_Test_Util.createEvents('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1, 100.0, BATCH_SIZE);

        Product_vod__c product = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        Product_vod__c product2 = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy2 = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        Product_vod__c product3 = EMS_Test_Util.createProduct('test product');
        Product_Strategy_vod__c strategy3 = EMS_Test_Util.createStrategy(product.Id, 'test strategy');

        List<EMS_Event_Product_gne__c> eventProducts = EMS_Test_Util.createEventProducts(events, product.Id, strategy.Id);

        List<EMS_Event_Product_gne__c> eventProducts2 = EMS_Test_Util.createEventProducts(events, product2.Id, strategy2.Id);

        try {
            Test.startTest();

            eventProducts.addAll(eventProducts2);

            for (EMS_Event_Product_gne__c eventProduct : eventProducts) {
                eventProduct.Product_Indication_gne__c = product3.Id;
                eventProduct.Product_Strategy_gne__c = strategy3.Id;
            }

            update eventProducts;
            System.assert(false, 'Duplicate event products should not be updated');

            Test.stopTest();
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains(System.Label.Event_Duplicate_Product_Product_Strategy), ex.getMessage());
        }
    }
}