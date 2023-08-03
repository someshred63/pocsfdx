trigger GNE_SFA2_Spkr_Bur_Membership_Trigger on Speaker_Bureau_Membership_gne__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	if (!GNE_SFA2_Util.isAdminMode()) {
		if (Trigger.isBefore && Trigger.isInsert) {
			GNE_SFA2_Spkr_Bur_Mem_Validation_Rules.onBeforeInsert(Trigger.New);
			GNE_SFA2_Spkr_Bur_Mem_Field_Updates.onBeforeInsert(Trigger.New);
		} 
		else if (Trigger.isBefore && Trigger.isUpdate) {
			GNE_SFA2_Spkr_Bur_Mem_Validation_Rules.onBeforeUpdate(Trigger.Old, Trigger.New, Trigger.OldMap, Trigger.newMap);
			GNE_SFA2_Spkr_Bur_Mem_Field_Updates.onBeforeUpdate(Trigger.OldMap, Trigger.New);
		} 
		else if (Trigger.isBefore && Trigger.isDelete) {
			GNE_SFA2_Spkr_Bur_Mem_Field_Updates.onBeforeDelete(Trigger.old);
		} 
		else if (Trigger.isAfter && Trigger.isInsert) {
			GNE_SFA2_Spkr_Bur_Mem_Field_Updates.onAfterInsert(Trigger.new);
		} 
		else if (Trigger.isAfter && Trigger.isUpdate) {
			GNE_SFA2_Spkr_Bur_Mem_Field_Updates.onAfterUpdate(Trigger.old, Trigger.new);
		} 
		else if (Trigger.isAfter && Trigger.isDelete) {
            GNE_SFA2_Deleted_Records_Util.onAfterDelete(Trigger.old, Speaker_Bureau_Membership_gne__c.getSObjectType());
        }		
	}
}