@isTest
private class gFRS_ApprovalEmailReminderBatchTester {
    
    @isTest(SeeAllData=true)
    static void testWithApprovalRemindersDaysBetweenRemindersEquelsZero() { 

        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults(); 
        customSettings.ApprovalRemindersDaysBetweenReminders__c = 0;
        update customSettings;
    
        Test.startTest();
            gFRS_ApprovalEmailReminderBatch batchObject = new gFRS_ApprovalEmailReminderBatch();  
            Database.executeBatch(batchObject);
        Test.stopTest();
    }

    @isTest(SeeAllData=true)
    static void testWithApprovalRemindersDaysBetweenRemindersGreaterThanZero() { 

        Test.startTest();
            gFRS_ApprovalEmailReminderBatch batchObject = new gFRS_ApprovalEmailReminderBatch();  
            Database.executeBatch(batchObject);
        Test.stopTest();
    }


}