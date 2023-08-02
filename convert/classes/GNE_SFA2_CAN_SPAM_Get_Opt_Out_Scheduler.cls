global class GNE_SFA2_CAN_SPAM_Get_Opt_Out_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		GNE_SFA2_CAN_SPAM_opt_out_Batch b = new GNE_SFA2_CAN_SPAM_opt_out_Batch();
		database.executebatch(b);
	}
}