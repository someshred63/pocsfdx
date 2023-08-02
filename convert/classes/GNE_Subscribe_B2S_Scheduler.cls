global class GNE_Subscribe_B2S_Scheduler {
	
	global void execute(SchedulableContext SC) {
		GNE_Subscribe_Brand_2_Salesforce subscribe = new GNE_Subscribe_Brand_2_Salesforce(false);
      	Database.executeBatch(subscribe, 100); 
   }

}