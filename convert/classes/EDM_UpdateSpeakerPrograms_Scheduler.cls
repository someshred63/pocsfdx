global class EDM_UpdateSpeakerPrograms_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new EDM_updateNumberOfSpeakerPrograms_Batch(), 50);
	}
}