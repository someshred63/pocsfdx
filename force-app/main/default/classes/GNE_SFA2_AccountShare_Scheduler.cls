global class GNE_SFA2_AccountShare_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		GNE_SFA2_AccountShareBatch acctShareBatch = new GNE_SFA2_AccountShareBatch();
    	Database.executeBatch(acctShareBatch);
	}
}