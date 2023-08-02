global class GNE_CAN_Subscribe_Scheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
      // Run both jobs in the same time
      GNE_CAN_Subscribe_Batch_OrgAccount orgBatchProcess = new GNE_CAN_Subscribe_Batch_OrgAccount();
      Database.executeBatch(orgBatchProcess, GNE_CAN_Subscribe_Util.BATCH_SIZE);
      
      GNE_CAN_Subscribe_Batch_PersonAccount personBatchProcess = new GNE_CAN_Subscribe_Batch_PersonAccount();
      Database.executeBatch(personBatchProcess, GNE_CAN_Subscribe_Util.BATCH_SIZE);
   }
}