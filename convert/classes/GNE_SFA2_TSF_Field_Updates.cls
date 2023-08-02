/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-19
*  Description: This is a helper class for handling TSF field updates
*  Test class: GNE_SFA2_TSF_Trigger_Test
*    
*  Modification History
*  Date        Name        			Description
*************************************************************/

public with sharing class GNE_SFA2_TSF_Field_Updates {

	public static List<TSF_vod__c> updateExternalIdField(List<TSF_vod__c> triggerNew){
	    List<TSF_vod__c> changedRecs = new List<TSF_vod__c>();
	    
		for(TSF_vod__c tsf : triggerNew){
		    String oldValue = String.isNotBlank(tsf.External_Id_vod__c) ? tsf.External_Id_vod__c : '';
        	tsf.External_Id_vod__c = tsf.Account_vod__c+'__'+tsf.Territory_vod__c;
        	String newValue = String.isNotBlank(tsf.External_Id_vod__c) ? tsf.External_Id_vod__c : '';
        	
        	if(!oldValue.equals(newValue)) {
                changedRecs.add(tsf);
            }
    	}
    	
    	return changedRecs;
	}
	
	public static void updateAddressField(List<TSF_vod__c> triggerNew) {
		updateAddressField(triggerNew, true);
	}
	
	public static void updateAddressField(List<TSF_vod__c> triggerNew, Boolean triggerMode) {
		Map<String,Address_vod__c> addressMap = GNE_SFA2_TSF_Trigger_Helper.prepareAddressMap(triggerNew);
		List<Address_vod__c> addressesToUpdate = new List<Address_vod__c>();
		Map<Id,TSF_vod__c> addrIdToTSFMap = new Map<Id,TSF_vod__c>();
		
		for(TSF_vod__c tsf : triggerNew) {
			String key = String.isNotBlank(tsf.Territory_vod__c) ? (tsf.Account_vod__c + '_' + tsf.Territory_vod__c.toUpperCase()) : null;
			
			if(key!=null && addressMap.containsKey(key)) {
				tsf.Address_vod__c = addressMap.get(key).Id;
			} else if(addressMap.containsKey(tsf.Account_vod__c)) {
				Address_vod__c addr = addressMap.get(tsf.Account_vod__c);
				tsf.Address_vod__c = addr.Id;				
				if(addr.Primary_vod__c != true && !addrIdToTSFMap.containsKey(addr.Id)) {					
					addressesToUpdate.add(new Address_vod__c(Id = addr.Id, Primary_vod__c = true));										
					addrIdToTSFMap.put(addr.Id, tsf);
				}				
			}
		}
		
		if(!addressesToUpdate.isEmpty()) {
			GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);
			Database.SaveResult[] sResults = Database.update(addressesToUpdate, triggerMode!=true);
			GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
			
			if (triggerMode == true){
				for (Integer sresultIndex = 0; sresultIndex < sResults.size(); sresultIndex++){
					Database.SaveResult sr = sResults[sresultIndex];
					if (!sr.isSuccess()){
						Id addrIdFailed = addressesToUpdate[sresultIndex].Id;						
						for(Database.Error err : sr.getErrors()) {							
							addrIdToTSFMap.get(addrIdFailed).Address_vod__c.addError(err.getMessage());							
						}
					}
				}
			}
		}
	}

	private static void updateLastInteractionDateField(List<TSF_vod__c> triggerNew){
		Map<Id,Map<String,Date>> lastInteractionDateFromCompletedInteractionsMap = GNE_SFA2_TSF_Trigger_Helper.prepareLastInteractionDateFromCompletedInteractionsMap(triggerNew);
		for(TSF_vod__c tsf : triggerNew) {
			if(lastInteractionDateFromCompletedInteractionsMap.containsKey(tsf.Account_vod__c) && lastInteractionDateFromCompletedInteractionsMap.get(tsf.Account_vod__c).containsKey(tsf.Territory_vod__c)) {			
				tsf.Last_Interaction_Date_gne__c = lastInteractionDateFromCompletedInteractionsMap.get(tsf.Account_vod__c).get(tsf.Territory_vod__c);
			}
		}
	}
	
	public static void onBeforeInsert(List<TSF_vod__c> triggerNew){
		updateExternalIdField(triggerNew);
		updateAddressField(triggerNew);	
		updateLastInteractionDateField(triggerNew);
	}

	public static void onBeforeUpdate(List<TSF_vod__c> triggerNew){
		updateExternalIdField(triggerNew);
		updateAddressField(triggerNew);	
	}

}