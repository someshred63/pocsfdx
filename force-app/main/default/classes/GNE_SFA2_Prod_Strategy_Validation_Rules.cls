/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-01
*  Description: This is a trigger for handling Product Strategy validation rules
*  Test class: GNE_SFA2_Product_Strategy_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Prod_Strategy_Validation_Rules {

	private static boolean preventDeletingStrategiesWithInteractions(List<Product_Strategy_vod__c> triggerOld){
		boolean validationFailed = false;
		Map<Id, Product_Strategy_vod__c> productStrategies = new Map<Id, Product_Strategy_vod__c>([ SELECT Id, Name FROM Product_Strategy_vod__c WHERE Id IN :triggerOld ]);	 
		List<Call2_Discussion_vod__c> interactionDiscussions = [ SELECT Id, Product_Strategy_vod__c FROM Call2_Discussion_vod__c WHERE Product_Strategy_vod__c IN :triggerOld ];
                   
        for(Call2_Discussion_vod__c interactionDiscussion : interactionDiscussions) {
        	productStrategies.get(interactionDiscussion.Product_Strategy_vod__c).addError(System.Label.Cannot_Delete_Object_Call_References);
        	validationFailed = true;
        }
        return validationFailed;
	}
	
    public static void onBeforeDelete(List<Product_Strategy_vod__c> triggerOld) {
    	preventDeletingStrategiesWithInteractions(triggerOld);    
    }
}