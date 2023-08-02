public without sharing class EMS_Event_Product_Ext {

    private EMS_Event__c event;

    public EMS_Event_Product_Ext(ApexPages.standardController stdController) {
        event = (EMS_Event__c) stdController.getRecord();
    }

    public Boolean getCanEdit() {
    	List<EMS_Budget_Allocation_gne__c> budgetAllocations = [SELECT Id, Name, Cost_Center_gne__c, Cost_Center_Type_gne__c, Percentage_Contribution_gne__c, Product_Indication_gne__c, Allocated_Budget_gne__c, Approver_gne__c, Budget_Owner_gne__c, Budget_Owner_gne__r.Name, Status_gne__c, Submitted_By_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :event.Id];
        return EMS_Access.isEventProductEditable(event,budgetAllocations);
    }

    private static List<EMS_Event_Product_gne__c> getEventProducts(Id eventId) {
        return [
            SELECT Product_Indication_gne__r.Name, Product_Indication_gne__c, Product_Strategy_gne__c, Product_Strategy_gne__r.Name, Event_gne__c
            FROM EMS_Event_Product_gne__c
            WHERE Event_gne__c = :eventId
            ORDER BY Product_Indication_gne__r.Name, CreatedDate ASC];
    }

    @RemoteAction
    public static EMS_Remote_Response removeCatalogProduct(String productCatalogID) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        try {
            delete [SELECT Id FROM EMS_Event_Product_gne__c WHERE Product_Indication_gne__c = :productCatalogID];
            response.isSuccess = true;
        } catch (DMLException ex) {
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.addError(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.addError(ex.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response getAvailableProductsWithStrategies(Id eventId){
        EMS_Remote_Response response = new EMS_Remote_Response();

        // Getting Product Catalogs (checkboxes)
        Set<Id> userIDs = new Set<Id>();
        for (EMS_Roche_Attendee_gne__c ra :[SELECT User_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c = :eventId AND Is_Watcher_gne__c = false]) {
            userIDs.add(ra.User_gne__c);
        }
        List<Product_vod__c> availableProductCatalogs = [SELECT Id, Name FROM Product_vod__c WHERE Id IN (SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE ownerId IN :userIDs) ORDER BY Name ASC];

        // Getting Strategies for each Product Catalogs
        Map<Id, List<Product_Strategy_vod__c>> productCatalogIDToStrategy = new Map<Id, List<Product_Strategy_vod__c>>();
        for (Product_Strategy_vod__c strategy :[SELECT Name, Product_Plan_vod__r.Product_vod__c FROM Product_Strategy_vod__c WHERE Product_Plan_vod__r.Product_vod__c IN :availableProductCatalogs and Active_vod__c = true ORDER BY Name ASC ]) {
            if (!productCatalogIDToStrategy.containsKey(strategy.Product_Plan_vod__r.Product_vod__c)) {
                productCatalogIDToStrategy.put(strategy.Product_Plan_vod__r.Product_vod__c, new List<Product_Strategy_vod__c>());
            }
            productCatalogIDToStrategy.get(strategy.Product_Plan_vod__r.Product_vod__c).add(strategy);
        }

        // Getting Strategies for each Product Catalogs
        List<EMS_Event_Product_gne__c> products = getEventProducts(eventId);

        response.customMapIDList = productCatalogIDToStrategy;
        //Assign to first object list available product catalogs and products to second
        response.objectList1 = availableProductCatalogs;
        response.objectList2 = products;
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response saveEventProduct(Id eventId, EMS_Event_Product_gne__c eventProduct) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        try {
            upsert eventProduct;
            response.isSuccess = true;
            response.responseObject = eventProduct;
        } catch (DMLException ex) {
            response.errorMessages = new List<String>();
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.addError(ex.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response removeEventProduct(Id productID) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        try {
            delete [SELECT Id FROM EMS_Event_Product_gne__c WHERE Id = :productID];
            response.isSuccess = true;
        } catch (DMLException ex) {
            response.errorMessages = new List<String>();
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.errorMessages.add(ex.getDmlMessage(i));
            }
        } catch (Exception ex) {
            response.addError(ex.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response refreshProducts(Id eventId) {
        EMS_Remote_Response response = getAvailableProductsWithStrategies(eventId);

        List<EMS_Event_Product_gne__c> productsToDelete = [
            SELECT Id
            FROM EMS_Event_Product_gne__c
            WHERE Event_gne__c = :eventId AND (Product_Indication_gne__c NOT IN :response.objectList1)
        ];
        delete productsToDelete;
        return response;
    }
}