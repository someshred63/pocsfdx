global class GNE_SFA2_UserDeactivation_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		GNE_SFA2_UserDeactivation_Batch b = new GNE_SFA2_UserDeactivation_Batch();
		database.executebatch(b);
	}
}