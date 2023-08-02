/** @date 5/5/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track HCP Notification Scheduler
*/
@isTest
private class AGS_ST_HCP_Notification_Schedule_Test {
	
	@isTest static void shouldExecuteScheduler() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		String CRON_EXP = '0 0 0 15 3 ? 2022';

		// WHEN 
		Test.startTest();
      	String jobId = System.schedule(
      		'ScheduleApexClassTest', CRON_EXP, new AGS_ST_HCP_Notification_Schedule()
      	);
         
      	CronTrigger ct = [
      		SELECT 	Id, CronExpression, TimesTriggered, NextFireTime
         	FROM 	CronTrigger 
         	WHERE	Id = :jobId
       	];
      	Test.stopTest();

      	// THEN
      	System.assertEquals(CRON_EXP, ct.CronExpression);
      	System.assertEquals(0, ct.TimesTriggered);
     	System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
	}
}