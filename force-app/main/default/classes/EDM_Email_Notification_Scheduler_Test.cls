@isTest
private class EDM_Email_Notification_Scheduler_Test{

	public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @testSetup static void setup() {
		insert new EDM_Notifications_gne__c(Name = 'Default', 
											Escalation_Address_gne__c = 'EscalationAddress@example.com', 
											Test_CC_Address_gne__c = 'TestCCAddress@example.com');

		insert new EDM_Notifications_gne__c(Name = 'FilterAttachmentsBasedOnEventStartDate', 
											Class_Name_gne__c='EDM_ADM_Periodical_Notification',
											Method_Name_gne__c='filterAttachmentsBasedOnEventStartDate',
											Number_Of_Days_gne__c=-14);

		insert new EDM_Notifications_gne__c(Name = 'FilterAttendeesBasedOnEventStartDate', 
											Class_Name_gne__c='EDM_ADM_Periodical_Notification',
											Method_Name_gne__c='filterAttendeesBasedOnEventStartDate',
											Number_Of_Days_gne__c=-14);

		insert new EDM_Notifications_gne__c(Name = 'PrepareActionItemDueMails', 
											Class_Name_gne__c='EDM_ADM_Periodical_Notification',
											Method_Name_gne__c='prepareActionItemDueMails',
											Number_Of_Days_gne__c=28);

		insert new EDM_Notifications_gne__c(Name = 'PrepareExeSumInOneWeekMails', 
											Class_Name_gne__c='EDM_ADM_Periodical_Notification',
											Method_Name_gne__c='prepareExeSumInOneWeekMails',
											Number_Of_Days_gne__c=-21);

		insert new EDM_Notifications_gne__c(Name = 'PrepareIABPFinalizationReminder', 
											Class_Name_gne__c='EDM_ADM_Periodical_Notification',
											Method_Name_gne__c='prepareIABPFinalizationReminder',
											Number_Of_Days_gne__c=-40);

		insert new EDM_Notifications_gne__c(Name = 'PrepareIABPRequiresFinalABSReviewMails', 
											Class_Name_gne__c='EDM_ADM_Periodical_Notification',
											Method_Name_gne__c='prepareIABPRequiresFinalABSReviewMails',
											Number_Of_Days_gne__c=3);

		insert new EDM_Notifications_gne__c(Name = 'PrepareIABPRevisionsPendingMails', 
											Class_Name_gne__c='EDM_ADM_Periodical_Notification',
											Method_Name_gne__c='prepareIABPRevisionsPendingMails',
											Number_Of_Days_gne__c=6);

		insert new EDM_Notifications_gne__c(Name = 'PrepareIABPTwoWeekNoticeForFinDocMails', 
											Class_Name_gne__c='EDM_ADM_Periodical_Notification',
											Method_Name_gne__c='prepareIABPTwoWeekNoticeForFinalDocumentationMails',
											Number_Of_Days_gne__c=14);

		insert new EDM_Notifications_gne__c(Name = 'PrepareIABPDestroyRecordingsAfterEvent',
				Class_Name_gne__c='EDM_ADM_Periodical_Notification',
				Method_Name_gne__c='prepareIABPDestroyRecordingsAfterEventMails',
				Number_Of_Days_gne__c=-85);
	}

    static testmethod void test() {
    
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest',CRON_EXP,new EDM_Email_Notification_Scheduler());           

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
     
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);   

        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();

    }
    
}