global class EDM_Curriculum_Status_Update_Batch_Sch implements Schedulable {
	global void execute(SchedulableContext sc) {
		EDM_Curriculum_Status_Update_Batch b = new EDM_Curriculum_Status_Update_Batch();
		database.executebatch(b);
	}
}