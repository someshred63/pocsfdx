global class CADS_ETL_Override_Email_Schedule implements Schedulable
{
	global void execute(SchedulableContext sc)
	{		
		try
		{
			List<CronTrigger> cron = new List<CronTrigger>([select Id, State from CronTrigger ]); 
			system.debug('The Ids of the Scheduled Jobs  : '+ cron );      
			for (CronTrigger  cr :cron)
			{
				if (cr.state == 'Complete')
				{
					System.debug(' Deleted Job Id : '+ cr.Id);
					system.abortJob(cr.Id);
				}
			}
		}
		catch(Exception e)
		{
			System.debug('I failed to Delete');       
		} 
		
		CADS_ETL_Override_Email.sent_email();

	}

}