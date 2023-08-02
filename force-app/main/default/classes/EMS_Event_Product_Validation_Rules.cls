public without sharing class EMS_Event_Product_Validation_Rules {

    // Public
    public static boolean onBeforeInsert(List<EMS_Event_Product_gne__c> triggerNew) {
        if (validateIfRecordExist(triggerNew, null)) {
            return true;
        }
        return false;
    }


    public static boolean onBeforeUpdate(List<EMS_Event_Product_gne__c> triggerNew, Map<Id, EMS_Event_Product_gne__c> triggerOldMap) {
        if (validateIfRecordExist(triggerNew, triggerOldMap)) {
            return true;
        }
        return false;
    }

    // Validation rules

    private static boolean validateIfRecordExist(List<EMS_Event_Product_gne__c> triggerNew, Map<Id, EMS_Event_Product_gne__c> triggerOldMap) {
        Set<Id> eventsIds = new Set<Id>();
        Set<Id> prodIndicatorsIds = new Set<Id>();
        Set<Id> prodStrategiesIds = new Set<Id>();
        Set<String> newProductStrategySet = new Set<String>();
        Set<String> existingProductStrategySet = new Set<String>();

        // Find all events for which new producs are added
        for (EMS_Event_Product_gne__c ep : triggerNew) {
            eventsIds.add(ep.Event_gne__c);
            prodIndicatorsIds.add(ep.Product_Indication_gne__c);
            prodStrategiesIds.add(ep.Product_Strategy_gne__c);
        }

        Map<Id, Product_vod__c> prodIndicators = new Map<Id, Product_vod__c>([SELECT Id, Name FROM Product_vod__c WHERE Id IN :prodIndicatorsIds]);
        Map<Id, Product_Strategy_vod__c> prodStrategies = new Map<Id, Product_Strategy_vod__c>([SELECT Id, Name FROM Product_Strategy_vod__c WHERE Id IN :prodStrategiesIds]);

        // Collect existing Product/Strategies
        List<EMS_Event_Product_gne__c> existingEventProducts = [SELECT Id, Event_gne__c, Product_Strategy_gne__c, Product_Strategy_gne__r.Name, Product_Indication_gne__c, Product_Indication_gne__r.Name FROM EMS_Event_Product_gne__c WHERE Event_gne__c IN :eventsIds];
        if (!existingEventProducts.isEmpty()) {
            for (EMS_Event_Product_gne__c exitingEp : existingEventProducts) {
                existingProductStrategySet.add('' + exitingEp.Product_Indication_gne__c + exitingEp.Product_Strategy_gne__c + exitingEp.Event_gne__c);
            }
        }

        // Check if new or edited product/strategy is duplicated
        for (EMS_Event_Product_gne__c ep : triggerNew) {
            if (ep.Product_Indication_gne__c != null && ep.Product_Strategy_gne__c != null) {
                if (triggerOldMap == null || (ep.Product_Indication_gne__c != triggerOldMap.get(ep.Id).Product_Indication_gne__c) || (ep.Product_Strategy_gne__c != triggerOldMap.get(ep.Id).Product_Strategy_gne__c)) {
                    if (!newProductStrategySet.contains('' + ep.Product_Indication_gne__c + ep.Product_Strategy_gne__c + ep.Event_gne__c)) {
                        newProductStrategySet.add('' + ep.Product_Indication_gne__c + ep.Product_Strategy_gne__c + ep.Event_gne__c);
                    } else {
                        ep.addError(System.Label.Event_Duplicate_Product_Product_Strategy + ' ' + prodIndicators.get(ep.Product_Indication_gne__c).Name + ' - ' + prodStrategies.get(ep.Product_Strategy_gne__c).Name + '.') ;
                        return true;
                    }
                }
            }
        }

        // Check if new or edited product/strategy is in existing one
        for (EMS_Event_Product_gne__c ep : triggerNew) {
            if (ep.Product_Indication_gne__c != null && ep.Product_Strategy_gne__c != null) {
                if ((triggerOldMap == null && !String.isEmpty(ep.Product_Strategy_gne__c)) || (ep.Product_Indication_gne__c != triggerOldMap.get(ep.Id).Product_Indication_gne__c) || (ep.Product_Strategy_gne__c != triggerOldMap.get(ep.Id).Product_Strategy_gne__c)) {
                    if (existingProductStrategySet.contains('' + ep.Product_Indication_gne__c + ep.Product_Strategy_gne__c + ep.Event_gne__c)) {
                        ep.addError(System.Label.Event_Product_Product_Strategy_already_exists + ' ' + prodIndicators.get(ep.Product_Indication_gne__c).Name + ' - ' + prodStrategies.get(ep.Product_Strategy_gne__c).Name + '.');
                        return true;
                    }
                }
            }
        }
        return false;
    }

}