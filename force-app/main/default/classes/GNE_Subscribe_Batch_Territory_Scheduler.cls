/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-03-29
*  This class is used for scheduling GNE_Subscribe_Batch_Territory batch
*************************************************************/ 

global class GNE_Subscribe_Batch_Territory_Scheduler implements Schedulable{
	global void execute(SchedulableContext SC) {
      GNE_Subscribe_Batch_Alignment subscribe = new GNE_Subscribe_Batch_Alignment();
      Database.executeBatch(subscribe,10); 
   }
}