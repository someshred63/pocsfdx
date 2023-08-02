public class GNE_SFA2_TierLvlAssignment_Field_Updates {
    
    public static void onBeforeInsert(List<Tier_Level_Assignment_gne__c> triggerNew) {
        onTierLevelValueChange(null, triggerNew);
        GNE_SFA2_ExternalIdUpdater.setExternalId(triggerNew, 'Unique_Key_gne__c');
    }
    
    public static void onBeforeUpdate(List<Tier_Level_Assignment_gne__c> triggerOld, List<Tier_Level_Assignment_gne__c> triggerNew) {
        onTierLevelValueChange(triggerOld, triggerNew);
        GNE_SFA2_ExternalIdUpdater.setExternalId(triggerNew, 'Unique_Key_gne__c');
    }
           
    /* Check whether tier level or/and goal value changed - if yes, update user info and re-stamp date */
    private static void onTierLevelValueChange(List<Tier_Level_Assignment_gne__c> triggerOld, List<Tier_Level_Assignment_gne__c> triggerNew){
    	Boolean isInsert = triggerOld == null;
    	Integer idx = 0;
    	for (Tier_Level_Assignment_gne__c newTierLevelRecord : triggerNew){
    		if ((isInsert && String.isNotBlank(newTierLevelRecord.Tier_Level_gne__c)) || (!isInsert && (triggerOld[idx].Tier_Level_gne__c != newTierLevelRecord.Tier_Level_gne__c))){
    			newTierLevelRecord.Last_Tier_Level_ModifiedBy_gne__c = UserInfo.getUserId();
    			newTierLevelRecord.Last_Tier_Level_Stamp_Date_gne__c = System.now();
    			newTierLevelRecord.Last_Stamp_Date_gne__c = System.now();
    		}
    		if ((isInsert && String.isNotBlank(newTierLevelRecord.Goal_gne__c)) || (!isInsert && (triggerOld[idx].Goal_gne__c != newTierLevelRecord.Goal_gne__c))){
    			newTierLevelRecord.Last_Goal_ModifiedBy_gne__c = UserInfo.getUserId();
    			newTierLevelRecord.Last_Goal_Stamp_Date_gne__c = System.now();
    			newTierLevelRecord.Last_Stamp_Date_gne__c = System.now();
    		}
    		idx++;
    	}
    }
}