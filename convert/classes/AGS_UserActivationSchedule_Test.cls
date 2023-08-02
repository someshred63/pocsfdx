@isTest
private class AGS_UserActivationSchedule_Test {
    
    @isTest
    public static void testBatchShouldBeScheduled() {
        // given
        final DateTime nextRunDate = System.now().addDays(1);
        final String jobName = 'AGS User Activation Schedule';
        final String cronExp = nextRunDate.second() + ' ' + nextRunDate.minute() + ' ' + nextRunDate.hour() + ' ' +
            nextRunDate.day() + ' ' + nextRunDate.month() + ' ? ' + nextRunDate.year();
        final AGS_UserActivationSchedule scheduleUnderTest = new AGS_UserActivationSchedule();
        AGS_TestUtil.createAGSUserActivationFinish('Process');
        // when
        Test.startTest();
        final Id jobId = System.schedule(jobName, cronExp, scheduleUnderTest);
        Test.stopTest();
        // then
        final CronTrigger[] actualCronTriggers = [
            SELECT CronExpression, CronJobDetail.JobType, CronJobDetail.Name, NextFireTime
            FROM CronTrigger WHERE Id = :jobId LIMIT 1
        ];
        System.assertEquals(false, actualCronTriggers.isEmpty(), actualCronTriggers);
        System.assertEquals(jobName, actualCronTriggers[0].CronJobDetail.Name, actualCronTriggers[0]);
        System.assertEquals('7', actualCronTriggers[0].CronJobDetail.JobType, actualCronTriggers[0]);
        System.assertEquals(nextRunDate, actualCronTriggers[0].NextFireTime, actualCronTriggers[0]);
        System.assertEquals(cronExp, actualCronTriggers[0].CronExpression, actualCronTriggers[0]);
        final AGS_Error_Log__c[] actualLogs = [
          SELECT Batch_Id__c, Class_Name__c, Custom_Error_Message__c, Error_Type__c, Method_Name__c
          FROM AGS_Error_Log__c LIMIT 2
        ];
        System.assertEquals(1, actualLogs.size(), actualLogs);
        System.assertNotEquals(null, actualLogs[0].Batch_Id__c, actualLogs[0]);
        System.assertEquals('Success', actualLogs[0].Error_Type__c, actualLogs[0]);
        System.assertEquals('execute', actualLogs[0].Method_Name__c, actualLogs[0]);
        System.assertEquals('AGS_UserActivationSchedule', actualLogs[0].Class_Name__c, actualLogs[0]);
        System.assertEquals(true, actualLogs[0].Custom_Error_Message__c.endsWith(jobId), actualLogs[0]);
        System.assertEquals(true, actualLogs[0].Custom_Error_Message__c.startsWith(scheduleUnderTest.batchClassName),
            actualLogs[0]
        );
    }
    
    @isTest
    public static void testBatchShouldNotBeScheduled() {
        // given
        final DateTime nextRunDate = System.now().addDays(1);
        final String jobName = 'AGS User Activation Schedule';
        final String cronExp = nextRunDate.second() + ' ' + nextRunDate.minute() + ' ' + nextRunDate.hour() + ' ' +
            nextRunDate.day() + ' ' + nextRunDate.month() + ' ? ' + nextRunDate.year();
        final AGS_UserActivationSchedule scheduleUnderTest = new AGS_UserActivationSchedule();
        AGS_TestUtil.createAGSUserActivationFinish('NotProcess');
        // when
        Test.startTest();
        final Id jobId = System.schedule(jobName, cronExp, scheduleUnderTest);
        Test.stopTest();
        // then
        final CronTrigger[] actualCronTriggers = [
            SELECT CronExpression, CronJobDetail.JobType, CronJobDetail.Name, NextFireTime
            FROM CronTrigger WHERE Id = :jobId LIMIT 1
        ];
        System.assertEquals(false, actualCronTriggers.isEmpty(), actualCronTriggers);
        System.assertEquals(jobName, actualCronTriggers[0].CronJobDetail.Name, actualCronTriggers[0]);
        System.assertEquals('7', actualCronTriggers[0].CronJobDetail.JobType, actualCronTriggers[0]);
        System.assertEquals(nextRunDate, actualCronTriggers[0].NextFireTime, actualCronTriggers[0]);
        System.assertEquals(cronExp, actualCronTriggers[0].CronExpression, actualCronTriggers[0]);
        final AGS_Error_Log__c[] actualLogs = [
          SELECT Batch_Id__c, Class_Name__c, Custom_Error_Message__c, Error_Type__c, Method_Name__c
          FROM AGS_Error_Log__c LIMIT 1
        ];
        System.assertEquals(true, actualLogs.isEmpty(), actualLogs);
    }
}