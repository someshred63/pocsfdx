global class GNE_Subscribe_LOA_Batch_Scheduler implements Schedulable{
	
	global void execute(SchedulableContext SC) {
		GNE_Subscribe_LOA_Batch subscribe = new GNE_Subscribe_LOA_Batch(false);
      	Database.executeBatch(subscribe, 10); 
   }
   
}