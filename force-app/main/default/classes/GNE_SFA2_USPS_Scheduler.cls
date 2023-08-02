global class GNE_SFA2_USPS_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		GNE_SFA2_USPS_Batch uspsBatch = new GNE_SFA2_USPS_Batch();
    	Database.executeBatch(uspsBatch);
	}
}