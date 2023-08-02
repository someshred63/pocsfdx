@isTest
private class EDM_ADM_Periodical_Notification_Test{

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

	@isTest static void shouldNotSendAnyEmailsWhenNoData() {
		//given
		//nothing

		//when
		EDM_ADM_Periodical_Notification mailsAreSentInConstructor = new EDM_ADM_Periodical_Notification();

		//then
		System.assert(mailsAreSentInConstructor.emailsManager.emails.isEmpty());
	}

	@isTest static void shouldEscalateExeSumPastDueMails() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		createIABP('Event Occurred', Date.today() - 42,  Date.today() - 42);
		createIABP('Executive Summary in Progress', Date.today() - 56,  Date.today() - 56);	

		//when
		notif.prepareExeSumPastDueMails();

		//then
		System.assertEquals(2, notif.emailsManager.emails.size());
	}

	@isTest static void shouldNotSendExeSumPastDueMailsWhenAlreadySubmitted() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		createIABP('Executive Summary in Progress', Date.today() - 56,  Date.today() - 56);	
		List<EDM_IABP_gne__c> testExesums = [SELECT Id, EDM_ExeSum_Submitted_gne__c FROM EDM_IABP_gne__c];
		testExesums[0].EDM_ExeSum_Submitted_gne__c = Date.today();
		update testExesums;

		//when
		notif.prepareExeSumPastDueMails();

		//then
		System.assertEquals(0, notif.emailsManager.emails.size());
	}

	@isTest static void shouldNotEscalateExeSumPastDueMailsWhenNoLeads() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		createIABPNoLeads('Event Occurred', Date.today() - 42,  Date.today() - 42);
		createIABPNoLeads('Executive Summary in Progress', Date.today() - 56,  Date.today() - 56);	

		//when
		notif.prepareExeSumPastDueMails();

		//then
		System.assertEquals(0, notif.emailsManager.emails.size());
	}

	@isTest static void shouldNotEscalateExeSumPastDueMails() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		createIABP('Event Occurred', Date.today(),  Date.today());
		createIABP('Executive Summary in Review', Date.today() - 42,  Date.today() - 42);

		//when
		notif.prepareExeSumPastDueMails();

		//then
		System.assert(notif.emailsManager.emails.isEmpty());
	}

	@isTest static void shouldSendPullThroughDocumentationSubmittedMails() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		Id exeSumId = createExecutiveSummary('Not Important', Date.today(), Date.today());
		EDM_Attachment_gne__c edmAttach = newPullThroughDocumentation(exeSumId);
		edmAttach.EDM_Upload_Date_gne__c = Date.today() - 1;
		insert edmAttach;

		//when
		notif.preparePullThroughDocumentationSubmittedMails();

		//then
		System.assertEquals(1, notif.emailsManager.emails.size());
	}

	@isTest static void shouldSendAttachmentUploadedMailsForCurrentEvents() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		Id exeSumId = createExecutiveSummary('Not Important', Date.today() - 14, Date.today() - 13);
		EDM_Attachment_gne__c edmAttach = newEventDocumentation(exeSumId);
		insert edmAttach;
		Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(edmAttach.Id, yesterday);

		//when
		notif.prepareDocumentsUploadedMails();

		//then
		System.assertEquals(1, notif.emailsManager.emails.size());
	}

	@isTest static void shouldNotSendAttachmentUploadedMailsForFutureEvents() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		Id exeSumId = createExecutiveSummary('Not Important', Date.today() + 15, Date.today() + 16);
		EDM_Attachment_gne__c edmAttach = newPullThroughDocumentation(exeSumId);
		insert edmAttach;
		Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(edmAttach.Id, yesterday);

		//when
		notif.prepareDocumentsUploadedMails();

		//then
		System.assertEquals(0, notif.emailsManager.emails.size());
	}

	@isTest static void shouldPrepareActionItemDueMails() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		Id exeSumId = createExecutiveSummary('Not Important', Date.today(), Date.today());
		EDM_Attachment_gne__c edmAttach = newPullThroughDocumentation(exeSumId);
		edmAttach.EDM_Due_Date_gne__c = System.today() + 28;
		insert edmAttach;

		Id exeSumId2 = createExecutiveSummary('Not Important 2', Date.today(), Date.today());
		EDM_Attachment_gne__c edmAttach2 = newPullThroughDocumentation(exeSumId2);
		edmAttach2.EDM_Due_Date_gne__c = System.today() + 28;
		edmAttach2.EDM_Upload_Date_gne__c = Date.today();
		insert edmAttach2;

		//when
		notif.prepareActionItemDueMails();

		//then
		System.assertEquals(1, notif.emailsManager.emails.size());
	}

	@isTest static void shouldPrepareActionItemPastDueTodayMails() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		Id exeSumId = createExecutiveSummary('Not Important', Date.today(), Date.today());
		EDM_Attachment_gne__c edmAttach = newPullThroughDocumentation(exeSumId);
		edmAttach.EDM_Due_Date_gne__c = Date.today();
		insert edmAttach;

		Id exeSumId2 = createExecutiveSummary('Not Important 2', Date.today(), Date.today());
		EDM_Attachment_gne__c edmAttach2 = newPullThroughDocumentation(exeSumId2);
		edmAttach2.EDM_Due_Date_gne__c = System.today();
		edmAttach2.EDM_Upload_Date_gne__c = Date.today() - 1;
		insert edmAttach2;

		//when
		notif.prepareActionItemPastDueTodayMails();

		//then
		System.assertEquals(1, notif.emailsManager.emails.size());
	}

	@isTest static void shouldPrepareActionItemPastDueMails() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		Id exeSumId = createExecutiveSummary('Not Important', Date.today(), Date.today());
		EDM_Attachment_gne__c edmAttach = newPullThroughDocumentation(exeSumId);
		edmAttach.EDM_Due_Date_gne__c = Date.today() - 90;
		insert edmAttach;

		Id exeSumId2 = createExecutiveSummary('Not Important 2', Date.today(), Date.today());
		EDM_Attachment_gne__c edmAttach2 = newPullThroughDocumentation(exeSumId2);
		edmAttach2.EDM_Due_Date_gne__c = System.today() - 90;
		edmAttach2.EDM_Upload_Date_gne__c = Date.today() - 100;
		insert edmAttach2;

		//when
		notif.prepareActionItemPastDueMails();

		//then
		System.assertEquals(1, notif.emailsManager.emails.size());
	}

	@isTest static void shouldNotPrepareActionItemPastDueMailsWhenAlreadyUploaded() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		Id exeSumId = createExecutiveSummary('Not Important', Date.today(), Date.today());
		EDM_Attachment_gne__c edmAttach = newPullThroughDocumentation(exeSumId);
		edmAttach.EDM_Due_Date_gne__c = Date.today() - 90;
		edmAttach.EDM_Upload_Date_gne__c = Date.today() - 1;
		insert edmAttach;

		//when
		notif.prepareActionItemPastDueMails();

		//then
		System.assert(notif.emailsManager.emails.isEmpty());
	}

	@isTest static void shouldPrepareDestroyRecordingsAfterEventMails() {
		//given
		EDM_ADM_Periodical_Notification notif = EDM_ADM_Periodical_Notification.getInstanceWithoutSendingMails();
		createIABP('Event Occurred', Date.today() - 90,  Date.today() - 85);

		//when
		notif.prepareIABPDestroyRecordingsAfterEventMails();

		//then
		System.assertEquals(1, notif.emailsManager.emails.size());
	}

	@isTest static void testEdmNotificationSendDateConfig() {
		EDM_ADM_Periodical_Notification.EDM_Notification_Send_Date_Config notificationSendDateConfig = new EDM_ADM_Periodical_Notification.EDM_Notification_Send_Date_Config();
		System.assertEquals(3, notificationSendDateConfig.getDaysValue('prepareIABPRequiresFinalABSReviewMails'));
		System.assertEquals(-40, notificationSendDateConfig.getDaysValue('prepareIABPFinalizationReminder'));
		System.assertEquals(6, notificationSendDateConfig.getDaysValue('prepareIABPRevisionsPendingMails'));
		System.assertEquals(14, notificationSendDateConfig.getDaysValue('prepareIABPTwoWeekNoticeForFinalDocumentationMails'));
		System.assertEquals(-21, notificationSendDateConfig.getDaysValue('prepareExeSumInOneWeekMails'));
		System.assertEquals(-14, notificationSendDateConfig.getDaysValue('filterAttachmentsBasedOnEventStartDate'));
		System.assertEquals(28, notificationSendDateConfig.getDaysValue('prepareActionItemDueMails'));
		System.assertEquals(-14, notificationSendDateConfig.getDaysValue('filterAttendeesBasedOnEventStartDate'));
	}

	private static Id createExecutiveSummaryNoLeads(String iabpStatus, Date startDate, Date endDate) {
		return createTestData(iabpStatus, startDate, endDate, true, false);
	}

	private static Id createIABPNoLeads(String iabpStatus, Date startDate, Date endDate) {
		return createTestData(iabpStatus, startDate, endDate, false, false);
	}

	private static Id createExecutiveSummary(String iabpStatus, Date startDate, Date endDate) {
		return createTestData(iabpStatus, startDate, endDate, true, true);
	}

	private static Id createIABP(String iabpStatus, Date startDate, Date endDate) {
		return createTestData(iabpStatus, startDate, endDate, false, true);
	}

	private static Id createTestData(String iabpStatus, Date startDate, Date endDate, boolean executiveSummary, boolean withLeads) {
		List<User> abls = EDM_ABM_Test_Utils.getABLs();

		EDM_AABP_gne__c testAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		insert testAABP;

		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c>();
		iabps.add(new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = testAABP.Id,
			EDM_Executive_Summary_gne__c = executiveSummary,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_Historical_gne__c = false,
			EDM_Start_Date_gne__c = startDate,
			EDM_End_Date_gne__c = endDate,
			EDM_Status_gne__c = iabpStatus,
			EDM_Secondary_AB_Lead_gne__c = (withLeads ? abls[2].Id : null),
			EDM_Third_AB_Lead_gne__c = (withLeads ? abls[1].Id : null),
			EDM_Primary_AB_Lead_gne__c = (withLeads ? abls[0].Id : null),
			EDM_Cont_Vendor_Contact_Email_gne__c = 'test@roche.com',
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		));

		insert iabps;

		return iabps[0].Id;
	}

	private static EDM_Attachment_gne__c newPullThroughDocumentation(Id parentId) {
		return new EDM_Attachment_gne__c(
					EDM_Pull_Through_Doc_gne__c = true,
					EDM_Parent_IABP_gne__c = parentId,
					EDM_Responsible_Party_gne__c = UserInfo.getUserId());
	}

	private static EDM_Attachment_gne__c newEventDocumentation(Id parentId) {
		return new EDM_Attachment_gne__c(
				EDM_Pull_Through_Doc_gne__c = false,
				EDM_System_Type_gne__c = 'Event Document',
				EDM_Parent_IABP_gne__c = parentId,
				EDM_Responsible_Party_gne__c = UserInfo.getUserId());
	}
}