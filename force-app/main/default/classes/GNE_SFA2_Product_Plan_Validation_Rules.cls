/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-01
*  Description: This is a trigger for handling Product Plan validation rules
*  Test class: GNE_SFA2_Product_Plan_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Plan_Validation_Rules {
	
	private static boolean preventDeletionOfPlansWithStrategies(List<Product_Plan_vod__c> triggerOld) {
		boolean validationFailed = false;
		Map<Id, Product_Plan_vod__c> productPlans = new Map<Id, Product_Plan_vod__c>([ SELECT Id, Name FROM Product_Plan_vod__c WHERE Id IN :triggerOld ]);
		
		for (Product_Strategy_vod__c strategy : [ SELECT Id, Name, Product_Plan_vod__c FROM Product_Strategy_vod__c WHERE Product_Plan_vod__c in :triggerOld ]) {
            Product_Plan_vod__c plan  = productPlans.get(strategy.Product_Plan_vod__c);
            if (plan != null) {
            	plan.addError(String.format(System.Label.GNE_SFA2_Product_Plan_Cannot_Delete, new List<String> {plan.Name, strategy.Name, strategy.Id} ));
            	validationFailed = true;
        	}
		}
		
		return validationFailed;
	}
	
	public static void onBeforeDelete(List<Product_Plan_vod__c> triggerOld) {
		preventDeletionOfPlansWithStrategies(triggerOld);
	}
}