@isTest
private class AGS_Latency_BatchSchedule_Test {

    @testSetUp
    private static void testData() {
        GNE_Foun_Misc_Config_Items_gne__c [] configs = new GNE_Foun_Misc_Config_Items_gne__c[]{};

        GNE_Foun_Misc_Config_Items_gne__c config1 = new GNE_Foun_Misc_Config_Items_gne__c(
                Configuration_Value_gne__c ='EDM_AB_Approver,EDM_AB_Approver_no_license,EDM_ABM_AB_Lead_no_license',
                name = 'EDM_Dont_Deact_Users_With_These_Ps'
        );
        configs.add(config1);

        Database.upsert(configs, false);
    }
    
    @isTest
    public static void testJobShouldBeScheduled() {
        // given
        final AGS_Latency_BatchSchedule scheduleUnderTest = new AGS_Latency_BatchSchedule();
        // when
        Test.startTest();
        final Id jobId = System.schedule('AGS_Latency_BatchSchedule', '0 0 0 * * ? *', scheduleUnderTest);
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
        System.assertEquals('AGS_Latency_BatchSchedule', actualLogs[0].Class_Name__c, actualLogs[0]);
        System.assertEquals(true, actualLogs[0].Custom_Error_Message__c.endsWith(jobId), actualLogs[0]);
        System.assertEquals(true, actualLogs[0].Custom_Error_Message__c.startsWith(scheduleUnderTest.batchClassName),
            actualLogs[0]
        );
    }
}