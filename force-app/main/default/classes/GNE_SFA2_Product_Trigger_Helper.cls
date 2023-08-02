/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-27
*  Description: This is a helper class for GNE_SFA2_Product_Trigger
*  Test class: GNE_SFA2_Product_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Trigger_Helper {
	
	public static Map<Id,Product_vod__c> getTAReference(List<Product_vod__c> triggerNew) {
		Set<Id> setTAReference = new Set<Id>();
		for(Product_vod__c product : triggerNew) {
			setTAReference.add(product.Therapeutic_Area_Reference__c);	
		}
		Map<Id,Product_vod__c> mapTAProducts = new Map<Id,Product_vod__c>([Select Id, Name from Product_vod__c where Id IN :setTAReference and Detail_Product_Subtype_Code_gne__c = 'Therapeutic Area']);
		return mapTAProducts;
	}
	
	public static ID getQueueId(String QueueName){
		List<Group> groups = [ Select Id,Name from Group WHERE Type='Queue' and Name=:QueueName];
		if(groups!=null && groups.size()>0){
			return groups[0].Id;
		}
		return null;
	}

}