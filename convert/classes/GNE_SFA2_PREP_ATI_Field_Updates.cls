public class GNE_SFA2_PREP_ATI_Field_Updates {
	public static void onBeforeInsert(List<SFA2_PREP_Account_Testing_Info_gne__c> triggerNew) {
        GNE_SFA2_ExternalIdUpdater.setExternalId(triggerNew);
    }
    
    public static void onBeforeUpdate(List<SFA2_PREP_Account_Testing_Info_gne__c> triggerOld, List<SFA2_PREP_Account_Testing_Info_gne__c> triggerNew) {
        GNE_SFA2_ExternalIdUpdater.setExternalId(triggerNew);
    }
}