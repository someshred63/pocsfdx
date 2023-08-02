global class EDM_ABM_Event_Occurred_Status_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		EDM_ABM_Event_Occurred_Status_Batch batch = new EDM_ABM_Event_Occurred_Status_Batch();
		database.executebatch(batch);
	}
}