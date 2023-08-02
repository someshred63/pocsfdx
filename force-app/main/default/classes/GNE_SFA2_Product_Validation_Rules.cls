/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-21
*  Description: This is a helper class for handling Product Catalog validation rules
*  Test class: GNE_SFA2_Product_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Product_Validation_Rules {
	
	private static void preventDeletionWhenAdminModeIsEqualFalse(List<Product_vod__c> triggerOld) {
        if(!GNE_SFA2_Util.isAdminMode()) {
			for(Product_vod__c product : triggerOld) {
      			product.addError(System.Label.GNE_SFA2_Admin_Mode);      
        	}
        }
	}
	
	private static void preventDeletionWhenInteractionIsExist(List<Product_vod__c> triggerOld) {
		
		Map <Id,Product_vod__c> products = new Map <Id,Product_vod__c>([Select Id, (Select Id from Call_Detail_vod__r limit 1), (Select Id from Call_Discussion_vod__r limit 1), (Select Id from Call_Key_Messages_vod__r limit 1), (Select Id from Call_Sample_vod__r limit 1) from Product_vod__c where Id in : triggerOld]);
        
        for(Integer i = 0; i < triggerOld.size(); i++) {
        	Product_vod__c product = products.get (triggerOld[i].Id);
            Boolean details = false;
            Boolean discussions = false;
            Boolean callMessages = false;
            Boolean samples = false;
        
            if (product != null) {
            	for (Call2_Detail_vod__c detail : product.Call_Detail_vod__r) {
            		details = true;
                	break;
                }   
                for (Call2_Discussion_vod__c discussion : product.Call_Discussion_vod__r) {
                	discussions = true;
                    break;
                }  
                for (Call2_Key_Message_vod__c keyMessage : product.Call_Key_Messages_vod__r) {
                	callMessages = true;
                    break;
                }
                for (Call2_Sample_vod__c samps : product.Call_Sample_vod__r) {
                    samples = true;
                    break;
                }
                if (details || discussions || callMessages || samples) {
                	triggerOld[i].addError(System.Label.Cannot_Delete_Object_Call_References); 
                }
       		}
        }   	
	}
	
	public static void onBeforeDelete(List<Product_vod__c> triggerOld) {
		preventDeletionWhenAdminModeIsEqualFalse(triggerOld);
		preventDeletionWhenInteractionIsExist(triggerOld);	
	}
	
}