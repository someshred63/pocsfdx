/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-05
*  Description: This is a trigger for handling Product Tactic validation rules
*  Test class: GNE_SFA2_Product_Tactic_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Prod_Tactic_Validation_Rules {
	
	private static void preventDeletionOfTacticsWithCallDiscussions(List<Product_Tactic_vod__c> triggerOld) {
		Map<Id, Product_Tactic_vod__c> productTactics = new Map<Id, Product_Tactic_vod__c>([ SELECT Id, Name FROM Product_Tactic_vod__c WHERE Id IN :triggerOld ]);
		for (Call2_Discussion_vod__c callDiscussion : [Select Id, Product_Tactic_vod__c  from Call2_Discussion_vod__c where Product_Tactic_vod__c  in :triggerOld ]) {
        	productTactics.get(callDiscussion.Product_Tactic_vod__c).addError(System.Label.Cannot_Delete_Object_Call_References);  
        }
	}
	
	public static void onBeforeDelete(List<Product_Tactic_vod__c> triggerOld) {
		preventDeletionOfTacticsWithCallDiscussions(triggerOld);
	}
}