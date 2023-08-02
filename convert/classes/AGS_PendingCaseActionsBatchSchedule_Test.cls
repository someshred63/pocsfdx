@isTest
private class AGS_PendingCaseActionsBatchSchedule_Test {
    
    @isTest
    public static void testJobShouldBeScheduled() {
        // given
        final AGS_PendingCaseActionsBatchSchedule scheduleUnderTest = new AGS_PendingCaseActionsBatchSchedule();
        // when
        Test.startTest();
        final Id jobId = System.schedule('AGS_PendingCaseActionsBatchSchedule', '0 0 0 * * ? *', scheduleUnderTest);
        Test.stopTest();
        // then
        final AGS_Error_Log__c[] actualLogs = [
          SELECT Batch_Id__c, Class_Name__c, Custom_Error_Message__c, Error_Type__c, Method_Name__c
          FROM AGS_Error_Log__c LIMIT 2
        ];
        System.assertEquals(1, actualLogs.size(), actualLogs);
        System.assertNotEquals(null, actualLogs[0].Batch_Id__c, actualLogs[0]);
        System.assertEquals('Success', actualLogs[0].Error_Type__c, actualLogs[0]);
        System.assertEquals('execute', actualLogs[0].Method_Name__c, actualLogs[0]);
        System.assertEquals(true, actualLogs[0].Custom_Error_Message__c.endsWith(jobId), actualLogs[0]);
        System.assertEquals('AGS_PendingCaseActionsBatchSchedule', actualLogs[0].Class_Name__c, actualLogs[0]);
        System.assertEquals(true, actualLogs[0].Custom_Error_Message__c.startsWith(scheduleUnderTest.batchClassName),
            actualLogs[0]
        );
    }
}