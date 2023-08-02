public with sharing class GNE_SFA2_PFG_CPD_Field_Update {
	public static void onBeforeInsert(List<Call_PFG_Detail_gne__c> triggerNew) {
		GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(triggerNew);
    	cancelOrders(null, triggerNew);
    }

    public static void onBeforeUpdate(List<Call_PFG_Detail_gne__c> triggerOld, List<Call_PFG_Detail_gne__c> triggerNew) {
    	GNE_SFA2_PFG_Util.cachePfgToTerritoryDetails(triggerNew);
    	cancelOrders(triggerOld, triggerNew);
    }

    private static void cancelOrders(List<Call_PFG_Detail_gne__c> triggerOld, List<Call_PFG_Detail_gne__c> triggerNew) {
    	Integer idx = 0;
    	for(Call_PFG_Detail_gne__c cpdNew : triggerNew) {
    		Call_PFG_Detail_gne__c cpdOld = triggerOld!=null ? triggerOld[idx] : null;

    		if(cpdNew.Is_Completed_gne__c && (cpdOld==null || !cpdOld.Is_Completed_gne__c)) {
    			cancelOrder(cpdNew);
    		}

    		idx++;
    	}
    }

    private static void cancelOrder(Call_PFG_Detail_gne__c cpdNew) {
    	Boolean limitReached  = true;

        for(Territory2 terr : GNE_SFA2_PFG_Util.getTerritoriesForUser(cpdNew.Owner_calc_gne__c)) {
        	if(terr.Name == cpdNew.Territory_Name_calc_gne__c &&
        	   GNE_SFA2_PFG_Util.validateTerritoryQuantity(terr.Name, cpdNew.Product_gne__c, GNE_SFA2_PFG_Util.getYear(cpdNew), cpdNew.Quantity_gne__c.intValue(), new List<Integer>{null,null})) {
              	limitReached  = false;
            }
        }

        // If limit reached, cancel Call PFG Detail
        if(limitReached) {
           	cpdNew.Order_Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_CANCELLED;
        }
    }
}