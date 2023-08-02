global class GNE_SFA2_HCPtoFRMHCOMapping_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		GNE_SFA2_HCPtoFRMHCOMappingBatch frmBatch = new GNE_SFA2_HCPtoFRMHCOMappingBatch();
    	Database.executeBatch(frmBatch);
	}
}