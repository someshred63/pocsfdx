global class GNE_CRM_HPSM_Update_Incident_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		GNE_CRM_HPSM_Update_Incident_Batch b = new GNE_CRM_HPSM_Update_Incident_Batch();
		Database.executeBatch(b, 10);
	}
}