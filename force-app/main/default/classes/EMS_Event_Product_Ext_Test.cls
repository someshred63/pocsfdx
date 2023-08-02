// Note: Commented code was commented because of old version of tested class on branch, please uncomment for new one

@isTest
private class EMS_Event_Product_Ext_Test {

    static testMethod void test_with_existing_event_product() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        //Prepare event to test
        EMS_Event__c event = EMS_Test_Util.createEvent('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1);

        //Preparing event product 
        Product_vod__c product = EMS_Test_Util.getProductIndication();
        System.assertNotEquals(null, product);
        Product_Strategy_vod__c strategy = EMS_Test_Util.getProductStrategy();
        System.assertNotEquals(null, strategy);
        Product_Tactic_vod__c tactic = EMS_Test_Util.getProductTactic();
        System.assertNotEquals(null, tactic);

        Product_Plan_vod__c productPlan = new Product_Plan_vod__c();
        productPlan.Name = 'Name: 1';
        productPlan.Product_vod__c = product.Id;
        productPlan.Active_vod__c = true;

        insert productPlan;

        strategy.Product_Plan_vod__c = productPlan.Id;
        strategy.Active_vod__c = true;

        update strategy;

        EMS_Event_Product_gne__c eventProductToInsert = EMS_Test_Util.createEventProduct(event.Id, product.Id, strategy.Id, tactic.Id);
        System.assertNotEquals(null, eventProductToInsert);

        //Prepare controller to test
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(event);
        EMS_Event_Product_Ext ctrl = new EMS_Event_Product_Ext(stdCtrl);

        //Checking if actual 'standard' user can edit
        Boolean canEdit = ctrl.getCanEdit();
        system.assertEquals(canEdit, true);

        //Refreshing products from event
/*        EMS_Remote_Response response = EMS_Event_Product_Ext.refreshProducts(event.Id);

        system.assertEquals(1,response.products.size()); */
    }

    static testMethod void test_with_adding_event_product() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        //Prepare event to test
        EMS_Event__c event = EMS_Test_Util.createEvent('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1);

        //Prepare controller to test
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(event);
        EMS_Event_Product_Ext ctrl = new EMS_Event_Product_Ext(stdCtrl);

        //Preparing event product 
        Product_vod__c product = EMS_Test_Util.getProductIndication();
        System.assertNotEquals(null, product);
        Product_Strategy_vod__c strategy = EMS_Test_Util.getProductStrategy();
        System.assertNotEquals(null, strategy);

        EMS_Event_Product_gne__c evProd = new EMS_Event_Product_gne__c(
                Event_gne__c = event.Id,
                Product_Indication_gne__c = product.Id,
                Product_Strategy_gne__c = strategy.Id
        );
/*		
		//Creating response object
		EMS_Remote_Response response = new EMS_Remote_Response();
    	
    	//Refreshing products from event when there is no product
        response = EMS_Event_Product_Ext.refreshProducts(event.Id);
      
        system.assertEquals(0,response.products.size());
        
        //Try adding empty product, should throw exception
        response = EMS_Event_Product_Ext.saveEventProduct(event.Id,new EMS_Event_Product_gne__c());
        
        system.assertEquals(null,response.isSuccess);
        system.assertNotEquals(0,response.errorMessages.size());
    	
    	//Adding new product
    	response = EMS_Event_Product_Ext.saveEventProduct(event.Id,evProd);
    	
    	system.assertEquals(true,response.isSuccess);

    	//Refreshing products from event after adding new product
        response = EMS_Event_Product_Ext.refreshProducts(event.Id);
        
        system.assertEquals(1,response.products.size()); */

    }

    static testMethod void test_with_removing_event_product() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        //Prepare event to test
        EMS_Event__c event = EMS_Test_Util.createEvent('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1);

        //Preparing event product 
        Product_vod__c product = EMS_Test_Util.getProductIndication();
        System.assertNotEquals(null, product);
        Product_Strategy_vod__c strategy = EMS_Test_Util.getProductStrategy();
        System.assertNotEquals(null, strategy);
        Product_Tactic_vod__c tactic = EMS_Test_Util.getProductTactic();
        System.assertNotEquals(null, tactic);

        EMS_Event_Product_gne__c eventProductToInsert = EMS_Test_Util.createEventProduct(event.Id, product.Id, strategy.Id, tactic.Id);
        System.assertNotEquals(null, eventProductToInsert);

        //Prepare controller to test
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(event);
        EMS_Event_Product_Ext ctrl = new EMS_Event_Product_Ext(stdCtrl);

        //Checking if actual 'standard' user can edit
        Boolean canEdit = ctrl.getCanEdit();
        system.assertEquals(canEdit, true);

/*        
        //Creating response object
		EMS_Remote_Response response = new EMS_Remote_Response();
        
        //Refreshing products from event
        response = EMS_Event_Product_Ext.refreshProducts(event.Id);
        
        system.assertEquals(1,response.products.size());
        
        //Removing product from event
		response = EMS_Event_Product_Ext.removeEventProduct(eventProductToInsert.Id);
        
        //Refreshing products from event after product removal
        response = EMS_Event_Product_Ext.refreshProducts(event.Id);
        
        system.assertEquals(0,response.products.size()); */
    }

    static testMethod void test_with_adding_multiple_products_and_removing() {

        // select test user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        // select cost center
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);

        // cerate budget for the user
        EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Sponsorship', 'Sponsorship of Events', 'Commercial Department');

        //Prepare event to test
        EMS_Event__c event = EMS_Test_Util.createEvent('Unplanned', pmUsers[0], 'Sponsorship', 'Sponsorship of Events', Date.today(), Date.today() + 1);

        //Preparing event product 
        List<Product_vod__c> products = new List<Product_vod__c>();
        for (Integer i = 0; i < 10; i++) {
            products.add(new Product_vod__c(Name = 'name ' + i));
        }
        System.assertNotEquals(0, products.size());

        insert products;

        Product_Strategy_vod__c strategy = EMS_Test_Util.getProductStrategy();
        System.assertNotEquals(null, strategy);
        Product_Tactic_vod__c tactic = EMS_Test_Util.getProductTactic();
        System.assertNotEquals(null, tactic);

        EMS_Event_Product_gne__c eventProductToInsert;
        for (Product_vod__c p : products) {
            eventProductToInsert = EMS_Test_Util.createEventProduct(event.Id, p.Id, strategy.Id, tactic.Id);
            System.assertNotEquals(null, eventProductToInsert);
        }

        //Prepare controller to test
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(event);
        EMS_Event_Product_Ext ctrl = new EMS_Event_Product_Ext(stdCtrl);
 /*       
        //Checking if actual 'standard' user can edit
        Boolean canEdit = ctrl.getCanEdit();      
        system.assertEquals(canEdit, true);
        
        //Creating response object
		EMS_Remote_Response response = new EMS_Remote_Response();
        
        //Refreshing products from event
        response = EMS_Event_Product_Ext.refreshProducts(event.Id);
        
        system.assertEquals(10,response.products.size());
        
        //Removing products from event
		response = EMS_Event_Product_Ext.removeCatalogProduct(products[0].Id);
        
        //Refreshing products from event after product removal
        response = EMS_Event_Product_Ext.refreshProducts(event.Id);
        
        system.assertEquals(0,response.products.size()); */
    }
}