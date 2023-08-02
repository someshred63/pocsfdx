/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-09-19
*  Description: This is a helper class for handling TSF child record updates
*  Test class: GNE_SFA2_TSF_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_TSF_Child_Record_Updates {
	
	public static void onAfterInsert(List<TSF_vod__c> triggerNew){
		createContactJunctions(triggerNew);
		setTargetsTiersParentField(triggerNew);
		setTierLevelAssignmentParentField(triggerNew);
	}
	
	public static void onAfterUpdate(List<TSF_vod__c> triggerOld, List<TSF_vod__c> triggerNew){
		recalculateContactJunctions(triggerOld, triggerNew);
	}
	
	private static void createContactJunctions(List<TSF_vod__c> triggerNew) {
		Set<Id> accountIds = new Set<Id>();
		for(TSF_vod__c tsf : triggerNew) {
			accountIds.add(tsf.Account_vod__c);
		}
				
		List<Contact_To_TSF_gne__c> junctionsToInsert = GNE_SFA2_TSF_Trigger_Helper.prepareContactJunctions(triggerNew, accountIds);
		if(!junctionsToInsert.isEmpty()) {
			insert junctionsToInsert;
		}
	}
	
	private static void recalculateContactJunctions(List<TSF_vod__c> triggerOld, List<TSF_vod__c> triggerNew) {
		Set<Id> tsfIds = new Set<Id>();
		Map<Id, Id> changedAccountIds = new Map<Id, Id>();
		
		for(Integer i = 0; i < triggerNew.size(); i++) {
			if(triggerNew[i].Account_vod__c != triggerOld[i].Account_vod__c) {
				tsfIds.add(triggerNew[i].Id);
				changedAccountIds.put(triggerNew[i].Account_vod__c, triggerOld[i].Account_vod__c);
			}
		}
		
		if(!changedAccountIds.isEmpty()) {
			delete [SELECT Id FROM Contact_To_TSF_gne__c WHERE TSF_gne__c IN : tsfIds AND Contact_gne__r.AccountId IN : changedAccountIds.values()];
			
			List<Contact_To_TSF_gne__c> junctionsToInsert = GNE_SFA2_TSF_Trigger_Helper.prepareContactJunctions(triggerNew, changedAccountIds.keySet());
			if(!junctionsToInsert.isEmpty()) {
				insert junctionsToInsert;
			}
		}
	}
	
	private static void setTierLevelAssignmentParentField(List<TSF_vod__c> triggerNew){
		if (triggerNew == null || triggerNew.isEmpty()){
			return;
		}
		
		Set<Id> accountIds = new Set<Id>();
		Set<String> territoryNames = new Set<String>();
		Map<String, Id> extIdToTsfRecordMap = new Map<String, Id>();
		String extId;
		
		for (TSF_vod__c tsfRow : triggerNew){
			if (tsfRow.Region_Code_gne__c != 1 || tsfRow.External_Id_vod__c == null || tsfRow.Address_vod__c == null || tsfRow.Account_vod__c == null || tsfRow.Territory_vod__c == null){
				continue;
			}
			extId = getExternalId(tsfRow.Account_vod__c, tsfRow.Territory_vod__c);			
			extIdToTsfRecordMap.put(extId, tsfRow.Id);
			accountIds.add(tsfRow.Account_vod__c);
			territoryNames.add(tsfRow.Territory_vod__c);
		}
		
		if (extIdToTsfRecordMap.size() == 0){
			return;
		}
		
		List<Tier_Level_Assignment_gne__c> toUpdate = new List<Tier_Level_Assignment_gne__c>();
		for (Tier_Level_Assignment_gne__c tierLevelRecord : [SELECT Id, TSF_vod__c, Account_gne__c, Territory_Name_gne__c FROM Tier_Level_Assignment_gne__c 
			WHERE TSF_vod__c = null AND Account_gne__c In :accountIds AND Territory_Name_gne__c In :territoryNames]){
			extId = getExternalId(tierLevelRecord.Account_gne__c, tierLevelRecord.Territory_Name_gne__c);
			if (extIdToTsfRecordMap.containsKey(extId)){
            	tierLevelRecord.TSF_vod__c = extIdToTsfRecordMap.get(extId);
            	toUpdate.add(tierLevelRecord);
			}
		}
		
		if (toUpdate.size() > 0){
			GNE_SFA2_TierLvlAssignmentTrigger_Helper.setInTierLevelTrig(true);
			update toUpdate;
			GNE_SFA2_TierLvlAssignmentTrigger_Helper.setInTierLevelTrig(false);
		}
	}
	
	/* [SFA-903] Method being used for aligning target and tiers records to tsf record to help determining My Hcp view for Canada users. 
	 * Can be extended in case of other circumstances if needed. */
	private static void setTargetsTiersParentField(List<TSF_vod__c> triggerNew){
		if (triggerNew == null || triggerNew.isEmpty()){
			return;
		}
		
		Map<String, Id> tsfExtToIdMap = new Map<String, Id>();
		Set<Id> accountIds = new Set<Id>();
		Set<String> territoriesNames = new Set<String>();
		String tsfExternalId;
		
		for (TSF_vod__c tsfRow : triggerNew){
			if (tsfRow.Region_Code_gne__c != 2 || tsfRow.My_Target_vod__c == false || tsfRow.External_Id_vod__c == null || tsfRow.Address_vod__c == null || tsfRow.Account_vod__c == null || tsfRow.Territory_vod__c == null){
				continue;
			}
			tsfExternalId = getExternalId(tsfRow.Account_vod__c, tsfRow.Territory_vod__c);						
			tsfExtToIdMap.put(tsfExternalId, tsfRow.Id);			
			accountIds.add(tsfRow.Account_vod__c);
			territoriesNames.add(tsfRow.Territory_vod__c);
		}
		
		if (tsfExtToIdMap.size() == 0){
			return;
		}
		
		List<Targets_and_Tiers_can_gne__c> tntUpdates = new List<Targets_and_Tiers_can_gne__c>();
		for (Targets_and_Tiers_can_gne__c tntRow : [SELECT Account_can_gne__c, Territory_gne__c, Territory_Field_parent_gne__c FROM	Targets_and_Tiers_can_gne__c 
			WHERE Account_can_gne__c In :accountIds AND Territory_gne__c In :territoriesNames AND Account_can_gne__c <> null AND Territory_gne__c <> null AND Product_Catalog_gne__c <> null AND Territory_Field_parent_gne__c = null
			AND (My_Target_gne__c <> null OR Target_gne__c <> null OR Segment_gne__c <> null OR Tier_can_gne__c <> null) ORDER BY Account_can_gne__c, Territory_gne__c]){
			tsfExternalId = getExternalId(tntRow.Account_can_gne__c, tntRow.Territory_gne__c);
			if (tsfExtToIdMap.containsKey(tsfExternalId)){
				tntRow.Territory_Field_parent_gne__c = tsfExtToIdMap.get(tsfExternalId);
				tntUpdates.add(tntRow);
			}	
		}
		if (tntUpdates.size() > 0){
			update tntUpdates;
		}
	}
	
	private static String getExternalId(String accountId, String territoryName){
		return String.format('{0}__{1}',
			new String[]{
				accountId,
				territoryName.toUpperCase()
			}
		);
	}
}