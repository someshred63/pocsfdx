trigger GNE_SFA2_Medical_Event_Trigger on Medical_Event_vod__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

	if (!GNE_SFA2_Util.isAdminMode()) {
		if(Trigger.IsBefore && Trigger.isInsert) {
			GNE_SFA2_Medical_Event_Validation_Rules.onBeforeInsert(trigger.new);
		} else if(Trigger.IsBefore && Trigger.isUpdate) {
			GNE_SFA2_Medical_Event_Validation_Rules.onBeforeUpdate(trigger.new);
		} else if(Trigger.IsBefore && Trigger.isDelete) {
			GNE_SFA2_Medical_Event_Validation_Rules.onBeforeDelete(trigger.oldMap.keySet(),trigger.Old);
			EDM_Medical_Event_Trigger_Helper.deleteOrphanedEventCuriculumJoins(trigger.oldMap.keySet());
			EDM_Medical_Event_Trigger_Helper.deleteOrphanedSpeakerTrainings(trigger.oldMap.keySet());
		} else if(Trigger.IsAfter && Trigger.isInsert) {
			EDM_Medical_Event_Trigger_Helper.updateUpcomingAndCompletedNumberOfSpeakerProgramsOnSpeakerBureauMembership(null, trigger.New);
		} else if(Trigger.IsAfter && Trigger.isUpdate) {
			EDM_Medical_Event_Trigger_Helper.updateUpcomingAndCompletedNumberOfSpeakerProgramsOnSpeakerBureauMembership(trigger.OldMap, trigger.New);
		}
	}
}