global class SRW_EmergencySweepScheduleJob implements Schedulable {

	  global void execute(SchedulableContext sc) {

	  	Date cToday = system.today();
		List<SRW_DataMonths__c> contexDataMonth = [Select Id,Sweep_Default_Date_gne__c,Sweep_Custom_Date_gne__c 
                                               from SRW_DataMonths__c 
                                               where ((Sweep_Default_Date_gne__c =: cToday AND Sweep_Custom_Date_gne__c = NULL) OR (Sweep_Custom_Date_gne__c =: cToday))
                                               AND (Sweep_Status_gne__c = 'Active' OR Sweep_Status_gne__c = 'Current') limit 1];
	  	if(contexDataMonth.size() >0 ){

	  		if ([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 10){
	            SRW_SweepProcessBatch batchJob = new SRW_SweepProcessBatch(contexDataMonth[0],true);
	            Database.executeBatch(batchJob); 
	        }else {

	              String hour = String.valueOf(Datetime.now().hour());
	              String min = String.valueOf(Datetime.now().minute()+5); 
	              String ss = String.valueOf(Datetime.now().second());

	              //parse to cron expression
	              String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

	              SRW_EmergencySweepScheduleJob s = new SRW_EmergencySweepScheduleJob(); 
	              System.schedule('gST Daily job re-run (Sweep batch only) ' + String.valueOf(Datetime.now()), nextFireTime, s);
	        }
	  	}
      	system.abortJob(sc.getTriggerId());
	}
}