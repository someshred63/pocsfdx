/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-21
*  Description: This is a helper class for handling Product Catalog field updates
*  Test class: GNE_SFA2_Product_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Field_Updates {
	
	public static final String activeCanadaQueue = 'GNE-SFA-CANADA-Queue';
	public static final String inactiveCanadaQueue = 'GNE-CANADA-INACTIVE-PROD-QUEUE';
	
	private static void insertTherapeuticAreaField(List<Product_vod__c> triggerNew) {
		Map<Id,Product_vod__c> mapTaReference = GNE_SFA2_Product_Trigger_Helper.getTAReference(triggerNew);
    	for(Integer i = 0; i < triggerNew.size(); i++) {
    		if(triggerNew[i].Therapeutic_Area_Reference__c != null) {
    			triggerNew[i].Therapeutic_Area_vod__c = mapTaReference.get(triggerNew[i].Therapeutic_Area_Reference__c).Name;
    		}  	
    	}
	}
	
	private static void updateTherapeuticAreaField(List<Product_vod__c> triggerOld, List<Product_vod__c> triggerNew) {
    	Map<Id,Product_vod__c> mapTaReference = GNE_SFA2_Product_Trigger_Helper.getTAReference(triggerNew);
    	for(Integer i = 0; i < triggerNew.size(); i++) {
    		if(triggerNew[i].Therapeutic_Area_Reference__c != null && triggerOld[i].Therapeutic_Area_Reference__c != triggerNew[i].Therapeutic_Area_Reference__c) {
    			triggerNew[i].Therapeutic_Area_vod__c = mapTaReference.get(triggerNew[i].Therapeutic_Area_Reference__c).Name;
    		}  	
    	}  
	}
	
	private static void insertOwnerField(List<Product_vod__c> triggerNew) {
		ID activeQueueId = GNE_SFA2_Product_Trigger_Helper.getQueueId(activeCanadaQueue);
    	ID inactiveQueueId = GNE_SFA2_Product_Trigger_Helper.getQueueId(inactiveCanadaQueue);
    	for(Integer i = 0; i < triggerNew.size(); i++) {
    		if(triggerNew[i].active__c == true && GNE_SFA2_Util.getCurrentUserProfileName().contains('Canada')) {
    			triggerNew[i].OwnerId = activeQueueId;
    		}  
    		if(triggerNew[i].active__c == false && GNE_SFA2_Util.getCurrentUserProfileName().contains('Canada')) {
    			triggerNew[i].OwnerId = inactiveQueueId;
    		} 	
    	}  
	}
	
	private static void updateOwnerField(List<Product_vod__c> triggerOld, List<Product_vod__c> triggerNew) {
		ID activeQueueId = GNE_SFA2_Product_Trigger_Helper.getQueueId(activeCanadaQueue);
    	ID inactiveQueueId = GNE_SFA2_Product_Trigger_Helper.getQueueId(inactiveCanadaQueue);
    	for(Integer i = 0; i < triggerNew.size(); i++) {
    		if(triggerOld[i].OwnerId == activeQueueId && triggerNew[i].active__c == false && triggerOld[i].active__c == true) {
    			triggerNew[i].OwnerId = inactiveQueueId;
    		} 
    		if(triggerOld[i].OwnerId == inactiveQueueId && triggerNew[i].active__c == true && triggerOld[i].active__c == false) {
    			triggerNew[i].OwnerId = activeQueueId;
    		}  	
    	}  
	}
	
	public static void onBeforeInsert(List<Product_vod__c> triggerNew) {
		insertTherapeuticAreaField(triggerNew);	
		insertOwnerField(triggerNew);
	}
	
	public static void onBeforeUpdate(List<Product_vod__c> triggerOld, List<Product_vod__c> triggerNew) {
		updateTherapeuticAreaField(triggerOld, triggerNew);	
		updateOwnerField(triggerOld, triggerNew);	
	}

}