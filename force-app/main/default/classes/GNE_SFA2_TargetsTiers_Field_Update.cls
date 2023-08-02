/************************************************************
*  @author: 
*  Date: 
*  Description: This class handles field updates on Targets_and_Tiers_can_gne__c object on DML operations
*  This class is being used in GNE_SFA2_Targets_and_Tiers_Trigger 
*  
*  Modification History
*  Date        Name        			Description
*************************************************************/
public without sharing class GNE_SFA2_TargetsTiers_Field_Update {
	
	public static void onBeforeUpdate(List<Targets_and_Tiers_can_gne__c> triggerNew){
		updateTargetTiersTerritoryField(triggerNew);
		
		if(!GNE_SFA2_Util.isMergeMode()) {
		  updateExternalId(triggerNew);
		}
	}
	
	public static void onBeforeInsert(List<Targets_and_Tiers_can_gne__c> triggerNew){
		updateTargetTiersTerritoryField(triggerNew);
		
		if(!GNE_SFA2_Util.isMergeMode()) {
		  updateExternalId(triggerNew);
		}
	}
	
	public static List<Targets_and_Tiers_can_gne__c> updateExternalId(List<Targets_and_Tiers_can_gne__c> triggerNew) {
	    List<Targets_and_Tiers_can_gne__c> changedRecs = new List<Targets_and_Tiers_can_gne__c>();
	    
	    for(SObject sobj : GNE_SFA2_ExternalIdUpdater.setExternalId(triggerNew, String.valueOf(Targets_and_Tiers_can_gne__c.External_Id_gne__c), String.valueOf(Targets_and_Tiers_can_gne__c.Unique_Key_Calc_gne__c))) {
	        changedRecs.add((Targets_and_Tiers_can_gne__c)sobj);
	    }
	    
	    return changedRecs;
	}
	
	/* [SFA-903] Method being used for aligning target and tiers records to tsf record to help determining My Hcp view for Canada users. 
	 * Can be extended in case of other circumstances if needed. */
	private static void updateTargetTiersTerritoryField(List<Targets_and_Tiers_can_gne__c> triggerNew){
		if (triggerNew == null || triggerNew.isEmpty()){
			return;
		}
		
		Map<String, List<Targets_and_Tiers_can_gne__c>> tntMap = new Map<String, List<Targets_and_Tiers_can_gne__c>>();
		Set<Id> accountIds = new Set<Id>();
		Set<String> territoriesNames = new Set<String>();		
		String tsfExternalId;		
		
		for (Targets_and_Tiers_can_gne__c tntRow : triggerNew){
			if (tntRow.Territory_Field_parent_gne__c != null || tntRow.Account_can_gne__c == null || tntRow.Territory_gne__c == null || 
				(tntRow.My_Target_gne__c == null && tntRow.Target_gne__c == null && tntRow.Segment_gne__c == null && tntRow.Tier_can_gne__c == null)){
				continue;
			}
			
			tsfExternalId = getExternalId(tntRow.Account_can_gne__c, tntRow.Territory_gne__c);
			if (!tntMap.containsKey(tsfExternalId)){
				tntMap.put(tsfExternalId, new List<Targets_and_Tiers_can_gne__c>());
			}			
			tntMap.get(tsfExternalId).add(tntRow);			
			accountIds.add(tntRow.Account_can_gne__c);
			territoriesNames.add(tntRow.Territory_gne__c);
		}
		
		if (tntMap.size() == 0){
			return;
		}
						
		for (TSF_vod__c tsfRow : [SELECT Id, Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Address_vod__c <> null
			AND External_Id_vod__c <> null AND Account_vod__c In :accountIds AND Territory_vod__c In :territoriesNames ORDER BY Account_vod__c, Territory_vod__c]){			
			tsfExternalId = getExternalId(tsfRow.Account_vod__c, tsfRow.Territory_vod__c);
			if (tntMap.containsKey(tsfExternalId)){
				for (Targets_and_Tiers_can_gne__c dataRow : tntMap.get(tsfExternalId)){
					dataRow.Territory_Field_parent_gne__c = tsfRow.Id;
				}
			}	
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