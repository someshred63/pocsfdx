public without sharing class EDM_ADM_Periodical_Notification {

	private Set<String> templateNames = new Set<String>{
			'IABP_2_Week_Notice_for_Final_Doc', 'Documents_Uploaded', 'ExeSum_Due_in_One_week', 'ExeSum_Past_Due', 'Action_Item_Assigned',
			'Action_Item_Past_Due', 'Action_Item_Past_Due_Today', 'Action_Item_Due', 'Pull_Through_Documentation_Submitted', 'Attendees_Modified',
			'IABP_Requires_Final_ABS_Review', 'IABP_Revisions_Pending', 'Event_Spend_Due', 'IABP_Expired_Exclusion_Check', 'IABP_Destroy_recordings_after_event'
	};
	private Map<String, EmailTemplate> edmABMTemplates;
	@TestVisible private EmailManager emailsManager;
	private Id absOrgWideAddressId;
	private EDM_Notification_Send_Date_Config notificationSendDateConfig;

	@TestVisible private static EDM_Notifications_gne__c notificationsSettings;
	static {
		notificationsSettings = EDM_Notifications_gne__c.getInstance('Default');
		if (notificationsSettings == null) {
			notificationsSettings = new EDM_Notifications_gne__c();
		}
	}

	public EDM_ADM_Periodical_Notification() {
		this.notificationSendDateConfig = new EDM_Notification_Send_Date_Config();
		initTemplates();

		emailsManager = new EmailManager();
		absOrgWideAddressId = getOrgWideAddressIdByName('Advisory Board Services');
		// IABP_Requires_Final_ABS_Review event start 3 days from now
		prepareIABPRequiresFinalABSReviewMails();

		// IABP Not Submitted - event start date 6 days from now  && status revising approved
		prepareIABPRevisionsPendingMails();

		// IABP Two Week Notice for Final Documentation ( event start date > 2 weeks from now )
		prepareIABPTwoWeekNoticeForFinalDocumentationMails();

		// ExeSum Due in One week -  to confirm with business
		prepareExeSumInOneWeekMails();

		// ExeSum Past Due - Send every two weeks until ExeSum is sent for review
		prepareExeSumPastDueMails();

		//Documents_Uploaded - raz dziennie dla tych co maja dodane attachment ( scheduel job )
		prepareDocumentsUploadedMails();

		// Action_Item_Assigned - Send once per day per event showing all PTD action items assigned ( EDM_Attachment -> fetch new  with flag Pull thouhg )
		prepareActionItemAssignedMails();

		//Pull_Through_Documentation_Submitted - for today is any submitted PTD send per IABP
		preparePullThroughDocumentationSubmittedMails();

		//Action_Item_Due - EDM_Resultant_Due_Date_gne__c is in 4 weeks
		prepareActionItemDueMails();

		//Action_Item_Past_Due_Today- EDM_Resultant_Due_Date_gne__c is today
		prepareActionItemPastDueTodayMails();

		//Action Item Past Due - - skomplikowana logika :D formula czy mamy wielkrotnosc 30 dni od (due date due date == today ||  (today - due date) / 30 ) && upload date == null || grupowani po event i Responsible_Party
		prepareActionItemPastDueMails();

		//Attendees Modified - for today is any Attendees Modified
		prepareAttendeesModifiedMails();

		//Event Spend Due - Send warning emails when spend isn't finalized in a timely manner
		prepareIABPFinalizationReminder();

		// Event Attendees Expired Exclusion Check - Send 2 weeks before event start date
		prepareIABPTwoWeekNoticeForExpiredExclusionChecks();

		// IABP_Destroy_recordings_after_event - Send 90 days after event end date
		prepareIABPDestroyRecordingsAfterEventMails();

		emailsManager.sendEmails();
	}

	//above constructor has side effect, send every type of notification. It would be better to change original one, but
	private EDM_ADM_Periodical_Notification(Boolean onlyForTestConstructor) {
		initTemplates();
		this.notificationSendDateConfig = new EDM_Notification_Send_Date_Config();

		emailsManager = new EmailManager();
		absOrgWideAddressId = getOrgWideAddressIdByName('Advisory Board Services');
	}

	@TestVisible private static EDM_ADM_Periodical_Notification getInstanceWithoutSendingMails() {
		Boolean doNotSentMailsInConstructor = true;
		return new EDM_ADM_Periodical_Notification(doNotSentMailsInConstructor);
	}

	private void initTemplates() {
		edmABMTemplates = new Map<String, EmailTemplate>();
		for (EmailTemplate tmpET : [SELECT Id, Name, Developername FROM EmailTemplate WHERE developername IN :templateNames]) {
			edmABMTemplates.put(tmpET.developername, tmpET);
		}
	}

	private Id getOrgWideAddressIdByName(String owaDisplayName) {
		OrgWideEmailAddress owa = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :owaDisplayName LIMIT 1];
		return owa.Id;
	}

	private void prepareIABPRequiresFinalABSReviewMails() {
		//before IABP Forced Submitted renamed in new spec to Requires Final ABS Review
		Date dt = System.today();
		dt = dt.addDays(this.notificationSendDateConfig.getDaysValue('prepareIABPRequiresFinalABSReviewMails'));
		Template template = new Template(edmABMTemplates.get('IABP_Requires_Final_ABS_Review').Id);
		List<EDM_IABP_gne__c> iabps = [
				SELECT Id, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email,	EDM_ABS_Manager_gne__r.email,
						EDM_Primary_AB_Lead_gne__c, EDM_Primary_AB_Lead_gne__r.email,
						EDM_Secondary_AB_Lead_gne__r.email, EDM_Third_AB_Lead_gne__r.email,
						EDM_Admin_gne__r.email, EDM_Primary_Vendor_Lead_gne__r.email, EDM_Second_Vendor_Lead_gne__r.email,
						EDM_Cont_Vendor_Contact_Email_gne__c
				FROM EDM_IABP_gne__c
				WHERE EDM_Historical_gne__c = false AND
				EDM_Start_Date_gne__c = :dt AND
				EDM_Status_gne__c in ('IABP In Progress', 'Revising Approved IABP')
				AND EDM_IABP_SendEmails_gne__c = true
		];

		prepareEmailsForIABPs(iabps, template, absOrgWideAddressId);
	}

	private void prepareEmailsForIABPs(List<EDM_IABP_gne__c> iabps, Template template, Id owaId) {
		prepareEmailsForIABPsWithOWA(iabps, false, template, owaId);
	}

	private void prepareEmailsForIABPsWithEscalate(List<EDM_IABP_gne__c> iabps, Template template, Id owaId) {
		prepareEmailsForIABPsWithOWA(iabps, true, template, owaId);
	}

	private void prepareEmailsForIABPsWithOWA(List<EDM_IABP_gne__c> iabps, Boolean escalate, Template template, Id owaId) {
		for (EDM_IABP_gne__c rec : iabps) {
			List<String> ccAddresses;
			String absManagerEmail = getAbsManagerEmail(rec);
			if (escalate) {
				ccAddresses = new List<String>{
						absManagerEmail,
						notificationsSettings.Escalation_Address_gne__c
				};
			} else {
				ccAddresses = new List<String>{
						rec.EDM_Cont_Vendor_Contact_Email_gne__c
				};
			}

			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Primary_AB_Lead_gne__c, rec.Id).
					replayToEmail(absManagerEmail).
					toAddresses(new List<String>{
							rec.EDM_Primary_AB_Lead_gne__r.email,
							rec.EDM_Secondary_AB_Lead_gne__r.email,
							rec.EDM_Third_AB_Lead_gne__r.email
					}).
					ccAddresses(ccAddresses).
					asOrgWideAddress(owaId).
					build(template);

			emailsManager.add(email);
		}
	}

	private void prepareEmailsForIABPTwoWeekNotice(List<EDM_IABP_gne__c> iabps, Template template, Id owaId) {
		for (EDM_IABP_gne__c rec : iabps) {
			String absManagerEmail = getAbsManagerEmail(rec);
			String absManagerName = getAbsManagerName(rec);
			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Primary_AB_Lead_gne__c, rec.Id).
					replayToEmail(absManagerEmail).
					toAddresses(new List<String>{
							rec.EDM_Primary_AB_Lead_gne__r.email,
							rec.EDM_Secondary_AB_Lead_gne__r.email,
							rec.EDM_Third_AB_Lead_gne__r.email
					}).
					ccAddresses(new List<String>{
							rec.EDM_Cont_Vendor_Contact_Email_gne__c,
							absManagerEmail,
							rec.EDM_Primary_Vendor_Lead_gne__r.email,
							rec.EDM_Second_Vendor_Lead_gne__r.email
					}).
					asOrgWideAddress(owaId).
					withSenderDisplayName(absManagerName).
					build(template);

			emailsManager.add(email);
		}
	}

	private void prepareIABPFinalizationReminder() {
		Date dt = System.today();
		dt = dt.addDays(this.notificationSendDateConfig.getDaysValue('prepareIABPFinalizationReminder'));

		Template template = new Template(edmABMTemplates.get('Event_Spend_Due').Id);
		List<EDM_IABP_gne__c> iabps = [
				SELECT Id, EDM_Status_gne__c, EDM_ABS_Manager_gne__c, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c,
						EDM_Primary_AB_Lead_gne__c, EDM_Primary_AB_Lead_gne__r.Email,
						EDM_Secondary_AB_Lead_gne__c, EDM_Secondary_AB_Lead_gne__r.Email,
						EDM_Third_AB_Lead_gne__c, EDM_Third_AB_Lead_gne__r.Email,
						EDM_Log_Vendor_Contact_Email_gne__c, (SELECT EDM_Cancellation_Type_gne__c FROM EDM_Spends__r)
				FROM
						EDM_IABP_gne__c
				WHERE
				EDM_Historical_gne__c = FALSE AND
				EDM_End_Date_gne__c = :dt AND
				EDM_Executive_Summary_gne__c = FALSE AND
				Id NOT IN (
						SELECT EDM_Parent_IABP_gne__c
						FROM EDM_Spend_gne__c
						WHERE EDM_Spend_Status_gne__c = 'Save & Finalize'
				)
				AND EDM_IABP_SendEmails_gne__c = true
		];

		for (EDM_IABP_gne__c rec : iabps) {
			if (rec.EDM_Status_gne__c == 'Canceled' && (rec.EDM_Spends__r.isEmpty() || rec.EDM_Spends__r.get(0).EDM_Cancellation_Type_gne__c != 'Cancel w/ Spend'))
				continue;

			String absManager = getAbsManagerId(rec);

			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Primary_AB_Lead_gne__c, rec.Id).
					toAddresses(new List<String>{
							absManager,
							rec.EDM_Primary_AB_Lead_gne__r.Email,
							rec.EDM_Secondary_AB_Lead_gne__r.Email,
							rec.EDM_Third_AB_Lead_gne__r.Email,
							rec.EDM_Log_Vendor_Contact_Email_gne__c
					}).
					asOrgWideAddress(absOrgWideAddressId).
					build(template);

			emailsManager.add(email);
		}
	}

	private void prepareIABPRevisionsPendingMails() {
		//before IABP Not Submitted renamed in new spec to Revisions Pending
		Date dt = System.today();
		dt = dt.addDays(this.notificationSendDateConfig.getDaysValue('prepareIABPRevisionsPendingMails'));
		Template template = new Template(edmABMTemplates.get('IABP_Revisions_Pending').Id);
		List<EDM_IABP_gne__c> iabps = [
				SELECT Id, EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email,
						EDM_Primary_AB_Lead_gne__c, EDM_Primary_AB_Lead_gne__r.email,
						EDM_Secondary_AB_Lead_gne__r.email, EDM_Third_AB_Lead_gne__r.email,
						EDM_Cont_Vendor_Contact_Email_gne__c, EDM_Admin_gne__r.email, EDM_Primary_Vendor_Lead_gne__r.email,
						EDM_Second_Vendor_Lead_gne__r.email
				FROM EDM_IABP_gne__c
				WHERE EDM_Historical_gne__c = false AND
				EDM_Start_Date_gne__c = :dt AND
				EDM_Status_gne__c in ('IABP In Progress', 'Revising Approved IABP')
				AND EDM_IABP_SendEmails_gne__c = true
		];

		prepareEmailsForIABPs(iabps, template, absOrgWideAddressId);
	}

	private void prepareIABPTwoWeekNoticeForFinalDocumentationMails() {
		Date dt = System.today();
		dt = dt.addDays(this.notificationSendDateConfig.getDaysValue('prepareIABPTwoWeekNoticeForFinalDocumentationMails'));
		Template template = new Template(edmABMTemplates.get('IABP_2_Week_Notice_for_Final_Doc').Id);
		List<EDM_IABP_gne__c> iabps = [
				SELECT Id, EDM_ABS_Manager_gne__r.email, EDM_ABS_Manager_gne__r.Name,
						EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name,
						EDM_Primary_AB_Lead_gne__c, EDM_Primary_AB_Lead_gne__r.email,
						EDM_Secondary_AB_Lead_gne__r.email, EDM_Third_AB_Lead_gne__r.email,
						EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Admin_gne__r.email, EDM_Primary_Vendor_Lead_gne__r.email, EDM_Second_Vendor_Lead_gne__r.email
				FROM EDM_IABP_gne__c
				WHERE EDM_Historical_gne__c = false AND
				EDM_Start_Date_gne__c =: dt AND
				EDM_Executive_Summary_gne__c = false AND
				EDM_Status_gne__c != 'Canceled'
				AND EDM_IABP_SendEmails_gne__c = true
		];

		prepareEmailsForIABPTwoWeekNotice(iabps, template, absOrgWideAddressId);
	}

	private void prepareExeSumInOneWeekMails() {
		Template template = new Template(edmABMTemplates.get('ExeSum_Due_in_One_week').Id);
		Date dt = System.today();
		dt = dt.addDays(this.notificationSendDateConfig.getDaysValue('prepareExeSumInOneWeekMails'));
		List<EDM_IABP_gne__c> iabps = [
				SELECT Id, EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email,
						EDM_Primary_AB_Lead_gne__c, EDM_Primary_AB_Lead_gne__r.email,
						EDM_Secondary_AB_Lead_gne__r.email, EDM_Third_AB_Lead_gne__r.email,
						EDM_Cont_Vendor_Contact_Email_gne__c, EDM_Admin_gne__r.email, EDM_Primary_Vendor_Lead_gne__r.email,
						EDM_Second_Vendor_Lead_gne__r.email
				FROM EDM_IABP_gne__c
				WHERE EDM_Historical_gne__c = false AND
				EDM_End_Date_gne__c = :dt AND
				EDM_Executive_Summary_gne__c = false AND
				EDM_Status_gne__c in ('Event Occurred', 'Executive Summary in Progress')
				AND EDM_IABP_SendEmails_gne__c = true
		];

		prepareEmailsForIABPs(iabps, template, absOrgWideAddressId);
	}

	@TestVisible private void prepareExeSumPastDueMails() {
		Template template = new Template(edmABMTemplates.get('ExeSum_Past_Due').Id);
		List<EDM_IABP_gne__c> iabps = [
				SELECT Id, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_ABS_Manager_gne__r.email,
						EDM_Primary_AB_Lead_gne__c, EDM_Primary_AB_Lead_gne__r.email,
						EDM_Secondary_AB_Lead_gne__r.email, EDM_Third_AB_Lead_gne__r.email, OwnerId,
						EDM_Admin_gne__r.email, EDM_Primary_Vendor_Lead_gne__r.email, EDM_Second_Vendor_Lead_gne__r.email
				FROM EDM_IABP_gne__c
				WHERE EDM_Historical_gne__c = false AND
				ExeSum_Past_Due_Flag__c = true AND
				EDM_Executive_Summary_gne__c = false AND
				EDM_Status_gne__c in ('Event Occurred', 'Executive Summary in Progress') AND
				EDM_ExeSum_Submitted_gne__c = null
				AND EDM_IABP_SendEmails_gne__c = true
		];

		prepareEmailsForIABPsWithEscalate(iabps, template, absOrgWideAddressId);
	}

	@TestVisible private void prepareDocumentsUploadedMails() {
		Template template = new Template(edmABMTemplates.get('Documents_Uploaded').Id);
		List<EDM_Attachment_gne__c> attachments = [
				SELECT Id, EDM_Parent_IABP_gne__c, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c,
						EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Secondary_AB_Lead_gne__r.email,
						EDM_Parent_IABP_gne__r.EDM_Third_AB_Lead_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Parent_IABP_gne__r.EDM_Admin_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Primary_Vendor_Lead_gne__r.email,
						EDM_Parent_IABP_gne__r.EDM_Second_Vendor_Lead_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Start_Date_gne__c
				FROM EDM_Attachment_gne__c
				WHERE EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false AND
				(CreatedDate = YESTERDAY OR (LastModifiedDate = YESTERDAY AND IsDeleted = true)) AND
				EDM_Parent_IABP_gne__c != null AND EDM_System_Type_gne__c = 'Event Document'
				AND EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true
				ALL ROWS
		];

		attachments = makeAttachmentsListUniquePerIABP(attachments);
		attachments = filterAttachmentsBasedOnEventStartDate(attachments);

		for (EDM_Attachment_gne__c rec : attachments) {
			String absManager = getAbsManagerId(rec.EDM_Parent_IABP_gne__r);
			Messaging.SingleEmailMessage email = new EmailBuilder(
					absManager, rec.EDM_Parent_IABP_gne__c).
					replayToEmail(rec.EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__r.email).
					ccAddresses(new List<String>{
							rec.EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__r.email,
							rec.EDM_Parent_IABP_gne__r.EDM_Secondary_AB_Lead_gne__r.email,
							rec.EDM_Parent_IABP_gne__r.EDM_Third_AB_Lead_gne__r.email,
							rec.EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
							rec.EDM_Parent_IABP_gne__r.EDM_Admin_gne__r.email,
							rec.EDM_Parent_IABP_gne__r.EDM_Primary_Vendor_Lead_gne__r.email,
							rec.EDM_Parent_IABP_gne__r.EDM_Second_Vendor_Lead_gne__r.email
					}).
					asOrgWideAddress(absOrgWideAddressId).
					build(template);
			emailsManager.add(email);
		}

	}

	private void prepareActionItemAssignedMails() {
		Template template = new Template(edmABMTemplates.get('Action_Item_Assigned').Id);
		List<EDM_Attachment_gne__c> attachments = [
				SELECT Id, EDM_Parent_IABP_gne__c, EDM_Responsible_Party_gne__c, Owner.email
				FROM EDM_Attachment_gne__c
				WHERE EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false AND
				CreatedDate = YESTERDAY AND
				EDM_Parent_IABP_gne__r.EDM_Executive_Summary_gne__c = true AND
				EDM_Pull_Through_Doc_gne__c = true AND
				EDM_System_Type_gne__c = null AND
				EDM_Parent_IABP_gne__c != null
				AND EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true
		];

		attachments = makeAttachmentsListUniquePerIABPAndResponsibleParty(attachments);

		for (EDM_Attachment_gne__c rec : attachments) {

			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Responsible_Party_gne__c, rec.EDM_Parent_IABP_gne__c).
					replayToEmail(rec.Owner.email).
					asOrgWideAddress(absOrgWideAddressId).
					build(template);

			emailsManager.add(email);
		}
	}

	@TestVisible private void preparePullThroughDocumentationSubmittedMails() {
		Template template = new Template(edmABMTemplates.get('Pull_Through_Documentation_Submitted').Id);
		List<EDM_Attachment_gne__c> attachments = [
				SELECT Id, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c,
						EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__r.email
				FROM EDM_Attachment_gne__c
				WHERE EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false AND
				EDM_Pull_Through_Doc_gne__c = true AND
				EDM_System_Type_gne__c = null AND
				EDM_Parent_IABP_gne__r.EDM_Executive_Summary_gne__c = true AND
				EDM_Upload_Date_gne__c = YESTERDAY AND
				EDM_Parent_IABP_gne__c != null
				AND EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true
		];

		attachments = makeAttachmentsListUniquePerIABP(attachments);

		for (EDM_Attachment_gne__c rec : attachments) {
			String absManager = getAbsManagerId(rec.EDM_Parent_IABP_gne__r);

			Messaging.SingleEmailMessage email = new EmailBuilder(
					absManager, rec.EDM_Parent_IABP_gne__c).
					replayToEmail(rec.EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__r.email).
					asOrgWideAddress(absOrgWideAddressId).
					build(template);

			emailsManager.add(email);
		}
	}

	private List<EDM_Attachment_gne__c> makeAttachmentsListUniquePerIABP(List<EDM_Attachment_gne__c> attachments) {
		List<EDM_Attachment_gne__c> results = new List<EDM_Attachment_gne__c>();
		Set<String> uniqueIABP = new Set<String>();
		for (EDM_Attachment_gne__c rec : attachments) {
			if (!uniqueIABP.contains(rec.EDM_Parent_IABP_gne__c)) {
				results.add(rec);
				uniqueIABP.add(rec.EDM_Parent_IABP_gne__c);
			}
		}
		return results;
	}

	private List<EDM_Attachment_gne__c> filterAttachmentsBasedOnEventStartDate(List<EDM_Attachment_gne__c> attachments) {
		List<EDM_Attachment_gne__c> results = new List<EDM_Attachment_gne__c>();
		Date dt = System.today();

		for (EDM_Attachment_gne__c rec : attachments) {
			Date eventStartDate = rec.EDM_Parent_IABP_gne__r.EDM_Start_Date_gne__c;
			Date eventStartDateFilter = eventStartDate.addDays(this.notificationSendDateConfig.getDaysValue('filterAttachmentsBasedOnEventStartDate'));
			if (dt >= eventStartDateFilter) {
				results.add(rec);
			}
		}
		return results;
	}

	private String getContentVendorEmail(EDM_IABP_gne__c rec) {
		return String.IsNotBlank(rec.EDM_Cont_Vendor_Contact_Email_gne__c)
				? rec.EDM_Cont_Vendor_Contact_Email_gne__c
				: (String.isNotBlank(rec.EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c) ? rec.EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c : '');
	}

	private static String getAbsManagerEmail(EDM_IABP_gne__c rec) {
		return String.IsNotBlank(rec.EDM_ABS_Manager_gne__r.email)
				? rec.EDM_ABS_Manager_gne__r.email
				: (String.isNotBlank(rec.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email) ? rec.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email : '');
	}

	private static String getAbsManagerName(EDM_IABP_gne__c rec) {
		return String.IsNotBlank(rec.EDM_ABS_Manager_gne__r.Name)
				? rec.EDM_ABS_Manager_gne__r.Name
				: (String.isNotBlank(rec.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name) ? rec.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name : '');
	}

	private static String getAbsManagerId(EDM_IABP_gne__c rec) {
		return String.IsNotBlank(rec.EDM_ABS_Manager_gne__c)
				? rec.EDM_ABS_Manager_gne__c
				: (String.isNotBlank(rec.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c) ? rec.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c : '');
	}

	@TestVisible private void prepareActionItemDueMails() {
		Template template = new Template(edmABMTemplates.get('Action_Item_Due').Id);
		Date dt = System.today();
		dt = dt.addDays(this.notificationSendDateConfig.getDaysValue('prepareActionItemDueMails'));
		List<EDM_Attachment_gne__c> attachments = [
				SELECT Id, EDM_Parent_IABP_gne__c, EDM_Responsible_Party_gne__c,
						EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name
				FROM EDM_Attachment_gne__c
				WHERE EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false AND
				EDM_Pull_Through_Doc_gne__c = true AND
				EDM_System_Type_gne__c = null AND
				EDM_Parent_IABP_gne__r.EDM_Executive_Summary_gne__c = true AND
				EDM_Resultant_Due_Date_gne__c = :dt AND
				EDM_Parent_IABP_gne__c != null AND
				EDM_Upload_Date_gne__c = null
				AND EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true
		];

		attachments = makeAttachmentsListUniquePerIABPAndResponsibleParty(attachments);

		for (EDM_Attachment_gne__c rec : attachments) {
			String contVendorEmail = getContentVendorEmail(rec.EDM_Parent_IABP_gne__r);
			String absManagerEmail = getAbsManagerEmail(rec.EDM_Parent_IABP_gne__r);
			String absManagerName = getAbsManagerName(rec.EDM_Parent_IABP_gne__r);

			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Responsible_Party_gne__c, rec.EDM_Parent_IABP_gne__c).
					ccAddresses(new List<String>{ contVendorEmail }).
					replayToEmail(absManagerEmail).
					asOrgWideAddress(absOrgWideAddressId).
					withSenderDisplayName(absManagerName).
					build(template);

			emailsManager.add(email);
		}
	}

	@TestVisible private void prepareActionItemPastDueTodayMails() {
		Template template = new Template(edmABMTemplates.get('Action_Item_Past_Due_Today').Id);
		List<EDM_Attachment_gne__c> attachments = [
				SELECT Id, EDM_Parent_IABP_gne__c, EDM_Responsible_Party_gne__c,
						EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name
				FROM EDM_Attachment_gne__c
				WHERE EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false AND
				EDM_Pull_Through_Doc_gne__c = true AND
				EDM_System_Type_gne__c = null AND
				EDM_Parent_IABP_gne__r.EDM_Executive_Summary_gne__c = true AND
				EDM_Resultant_Due_Date_gne__c = Today AND
				EDM_Parent_IABP_gne__c != null AND
				EDM_Upload_Date_gne__c = null
				AND EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true
		];

		attachments = makeAttachmentsListUniquePerIABPAndResponsibleParty(attachments);

		for (EDM_Attachment_gne__c rec : attachments) {
			String contVendorEmail = getContentVendorEmail(rec.EDM_Parent_IABP_gne__r);
			String absManagerEmail = getAbsManagerEmail(rec.EDM_Parent_IABP_gne__r);
			String absManagerName = getAbsManagerName(rec.EDM_Parent_IABP_gne__r);

			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Responsible_Party_gne__c, rec.EDM_Parent_IABP_gne__c).
					replayToEmail(absManagerEmail).
					ccAddresses(new List<String>{
							absManagerEmail,
							contVendorEmail,
							notificationsSettings.Escalation_Address_gne__c
					}).
					asOrgWideAddress(absOrgWideAddressId).
					withSenderDisplayName(absManagerName).
					build(template);

			emailsManager.add(email);
		}
	}

	@TestVisible private void prepareActionItemPastDueMails() {
		Template template = new Template(edmABMTemplates.get('Action_Item_Past_Due').Id);
		List<EDM_Attachment_gne__c> attachments = [
				SELECT Id, EDM_Parent_IABP_gne__c, EDM_Responsible_Party_gne__c,
						EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name
				FROM EDM_Attachment_gne__c
				WHERE EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false AND
				EDM_Pull_Through_Doc_gne__c = true AND
				EDM_System_Type_gne__c = null AND
				EDM_Parent_IABP_gne__r.EDM_Executive_Summary_gne__c = true AND
				Action_Item_Past_Due_Flag__c = true AND
				EDM_Parent_IABP_gne__c != null AND
				EDM_Upload_Date_gne__c = null
				AND EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true
		];

		attachments = makeAttachmentsListUniquePerIABPAndResponsibleParty(attachments);

		for (EDM_Attachment_gne__c rec : attachments) {
			String contVendorEmail = getContentVendorEmail(rec.EDM_Parent_IABP_gne__r);
			String absManagerEmail = getAbsManagerEmail(rec.EDM_Parent_IABP_gne__r);
			String absManagerName = getAbsManagerName(rec.EDM_Parent_IABP_gne__r);
			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Responsible_Party_gne__c, rec.EDM_Parent_IABP_gne__c).
					replayToEmail(absManagerEmail).
					ccAddresses(new List<String>{
							absManagerEmail,
							contVendorEmail,
							notificationsSettings.Escalation_Address_gne__c
					}).
					asOrgWideAddress(absOrgWideAddressId).
					withSenderDisplayName(absManagerName).
					build(template);

			emailsManager.add(email);
		}
	}

	private List<EDM_Attachment_gne__c> makeAttachmentsListUniquePerIABPAndResponsibleParty(List<EDM_Attachment_gne__c> attachments) {
		List<EDM_Attachment_gne__c> results = new List<EDM_Attachment_gne__c>();
		Set<String> uniqueIABP = new Set<String>();
		for (EDM_Attachment_gne__c rec : attachments) {
			if (!uniqueIABP.contains(rec.EDM_Parent_IABP_gne__c + '#' + rec.EDM_Responsible_Party_gne__c)) {
				results.add(rec);
				uniqueIABP.add(rec.EDM_Parent_IABP_gne__c + '#' + rec.EDM_Responsible_Party_gne__c);
			}
		}
		return results;
	}

	private void prepareAttendeesModifiedMails() {
		Template template = new Template(edmABMTemplates.get('Attendees_Modified').Id);
		List<EDM_Attendee_gne__c> attendees = [
				SELECT Id, EDM_Parent_IABP_gne__c, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c, EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__c,
						EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__r.email, EDM_Parent_IABP_gne__r.EDM_Start_Date_gne__c,
                        (SELECT Id, createdDate
						 FROM EDM_Attendee_History__r
						 WHERE createdDate = YESTERDAY)
				FROM EDM_Attendee_gne__c
				WHERE  EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__c = ''
				AND EDM_Parent_IABP_gne__r.EDM_Start_Date_gne__c != null
				AND EDM_Parent_IABP_gne__r.EDM_Historical_gne__c = false
				AND EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true
				AND LastModifiedDate = YESTERDAY ALL ROWS
		];

		if(!attendees.isEmpty()) {
			attendees = removeAttendeesWithoutHistoryRecords(attendees);
			attendees = makeAttendeesListUniquePerIABP(attendees);
			attendees = filterAttendeesBasedOnEventStartDate(attendees);
			Set<EDM_Attendee_gne__c> attendeesUnique = filterAttendeesBasedOnTrackedHistory(attendees);

			for (EDM_Attendee_gne__c rec : attendeesUnique) {
				String absManager = getAbsManagerId(rec.EDM_Parent_IABP_gne__r);
				Messaging.SingleEmailMessage email = new EmailBuilder(
						absManager, rec.EDM_Parent_IABP_gne__c).
						replayToEmail(rec.EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__r.email).
						asOrgWideAddress(absOrgWideAddressId).
						build(template);
				emailsManager.add(email);
			}
		}
	}

	private List<EDM_Attendee_gne__c> removeAttendeesWithoutHistoryRecords(List<EDM_Attendee_gne__c> attendees) {
		List<EDM_Attendee_gne__c> results = new List<EDM_Attendee_gne__c>();
		for (EDM_Attendee_gne__c rec : attendees) {
			if(rec.EDM_Attendee_History__r != null || !rec.EDM_Attendee_History__r.isEmpty()) {
				results.add(rec);
			}
		}
		return results;
	}

	private List<EDM_Attendee_gne__c> makeAttendeesListUniquePerIABP(List<EDM_Attendee_gne__c> attendees) {
		List<EDM_Attendee_gne__c> results = new List<EDM_Attendee_gne__c>();
		Set<Id> uniqueIABP = new Set<Id>();
		for (EDM_Attendee_gne__c rec : attendees) {
			if (!uniqueIABP.contains(rec.EDM_Parent_IABP_gne__c)) {
				results.add(rec);
				uniqueIABP.add(rec.EDM_Parent_IABP_gne__c);
			}
		}
		return results;
	}

	private List<EDM_Attendee_gne__c> filterAttendeesBasedOnEventStartDate(List<EDM_Attendee_gne__c> attendees) {
		List<EDM_Attendee_gne__c> results = new List<EDM_Attendee_gne__c>();
		Date dt = System.today();

		for (EDM_Attendee_gne__c rec : attendees) {
			Date eventStartDate = rec.EDM_Parent_IABP_gne__r.EDM_Start_Date_gne__c;
			Date eventStartDateFilter = eventStartDate.addDays(this.notificationSendDateConfig.getDaysValue('filterAttendeesBasedOnEventStartDate'));
			if (dt >= eventStartDateFilter) {
				results.add(rec);
			}
		}
		return results;
	}

	private Set<EDM_Attendee_gne__c> filterAttendeesBasedOnTrackedHistory(List<EDM_Attendee_gne__c> attendees) {
		Set<EDM_Attendee_gne__c> results = new Set<EDM_Attendee_gne__c>();
		Set<Id> uniqueIABP = new Set<Id>();

		for (EDM_Attendee_gne__c rec : attendees) {
			if (!uniqueIABP.contains(rec.EDM_Parent_IABP_gne__c)) {
				uniqueIABP.add(rec.EDM_Parent_IABP_gne__c);
			}
		}

		List<EDM_Attendee_History_gne__c> attHistory = [
				SELECT EDM_Parent_IABP_gne__c
				FROM EDM_Attendee_History_gne__c
				WHERE LastModifiedDate = YESTERDAY AND EDM_Parent_IABP_gne__c IN :uniqueIABP
				AND EDM_Attendee_gne__r.EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true];

		for (EDM_Attendee_gne__c rec : attendees) {
			for (EDM_Attendee_History_gne__c attHist : attHistory) {
				if (attHist.EDM_Parent_IABP_gne__c == rec.EDM_Parent_IABP_gne__c) {
					results.add(rec);
				}
			}
		}

		return results;
	}

	public void prepareIABPTwoWeekNoticeForExpiredExclusionChecks() {
		Date dt = System.today();
		dt = dt.addDays(14);
		Template template = new Template(edmABMTemplates.get('IABP_Expired_Exclusion_Check').Id);
		List<EDM_Attendee_gne__c> expiredAttendees = [
				SELECT EDM_Parent_IABP_gne__c, EDM_Account_gne__r.Name,
						EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email,
						EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email,
						EDM_Parent_IABP_gne__r.EDM_Primary_AB_Lead_gne__r.email,
						EDM_Parent_IABP_gne__r.EDM_Secondary_AB_Lead_gne__r.email,
						EDM_Parent_IABP_gne__r.EDM_Third_AB_Lead_gne__r.email,
						EDM_Parent_IABP_gne__r.EDM_Cont_Vendor_Contact_Email_gne__c,
						EDM_Parent_IABP_gne__r.Name
				FROM EDM_Attendee_gne__c
				WHERE EDM_Parent_IABP_gne__c IN (
						SELECT Id
						FROM EDM_IABP_gne__c
						WHERE EDM_Historical_gne__c = false AND
						EDM_Start_Date_gne__c = :dt AND
						EDM_Executive_Summary_gne__c = false AND EDM_Status_gne__c != 'Canceled'
				)
				AND EDM_Account_gne__r.AGS_EX_Date_Checked_Exclusion_gne__c < LAST_N_DAYS:365
				AND EDM_Account_gne__c != null AND EDM_Account_gne__r.AGS_EX_Exclusion_Status_gne__c NOT IN ('Not Checked','Request Pending')
				AND EDM_Parent_IABP_gne__r.EDM_IABP_SendEmails_gne__c = true
		];

		prepareEmailsForExpiredExclusionCheck(expiredAttendees, template, absOrgWideAddressId);
	}

	private void prepareEmailsForExpiredExclusionCheck(List<EDM_Attendee_gne__c> attendees, Template template, Id owaId) {
		Map<String, List<EDM_Attendee_gne__c>> iabp2attendeesMap = new Map<String, List<EDM_Attendee_gne__c>>();
		for (EDM_Attendee_gne__c att : attendees) {
			if(!iabp2attendeesMap.containsKey(att.EDM_Parent_IABP_gne__c)) {
				iabp2attendeesMap.put(att.EDM_Parent_IABP_gne__c, new List<EDM_Attendee_gne__c>{att});
			} else {
				iabp2attendeesMap.get(att.EDM_Parent_IABP_gne__c).add(att);
			}
		}

		for(String key : iabp2attendeesMap.keySet()) {
			List<EDM_Attendee_gne__c> attendeesWithExpiredExclusionCheck = iabp2attendeesMap.get(key);
			String expiredAttNames = prepareExpiredAttNames(attendeesWithExpiredExclusionCheck);
			EDM_IABP_gne__c rec = attendeesWithExpiredExclusionCheck.get(0).EDM_Parent_IABP_gne__r;
			Map<String, String> dynamicParts = new Map<String, String>();
			dynamicParts.put('#EDM_Expired_Exclusion_Check_HCPs', expiredAttNames);
			String absManagerEmail = getAbsManagerEmail(rec);
			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Primary_AB_Lead_gne__c, rec.Id).
					replayToEmail(absManagerEmail).
					toAddresses(new List<String> {
							rec.EDM_Primary_AB_Lead_gne__r.email,
							rec.EDM_Secondary_AB_Lead_gne__r.email,
							rec.EDM_Third_AB_Lead_gne__r.email,
							rec.EDM_Cont_Vendor_Contact_Email_gne__c}).
					ccAddresses(new List<String> {absManagerEmail}).
					asOrgWideAddress(owaId).
					withDynamicParts(dynamicParts).
					build(template);
			email.subject = 'ACTION: HCP Govt Exclusion Check will Expire Prior to Event ' + rec.Name;
			emailsManager.add(email);
		}
	}

	@TestVisible private void prepareIABPDestroyRecordingsAfterEventMails() {
		Template template = new Template(edmABMTemplates.get('IABP_Destroy_recordings_after_event').Id);
		Date dt = System.today();
		dt = dt.addDays(this.notificationSendDateConfig.getDaysValue('prepareIABPDestroyRecordingsAfterEventMails'));
		List<EDM_IABP_gne__c> iabps = [
				SELECT Id, EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email,
						EDM_Primary_AB_Lead_gne__c, EDM_Primary_AB_Lead_gne__r.email,
						EDM_Secondary_AB_Lead_gne__r.email, EDM_Third_AB_Lead_gne__r.email,
						EDM_Cont_Vendor_Contact_Email_gne__c, EDM_Admin_gne__r.email, EDM_Primary_Vendor_Lead_gne__r.email,
						EDM_Second_Vendor_Lead_gne__r.email
				FROM EDM_IABP_gne__c
				WHERE EDM_Historical_gne__c = false AND
				EDM_End_Date_gne__c = :dt AND
				EDM_Executive_Summary_gne__c = false AND
				EDM_Status_gne__c != 'Canceled'
				AND EDM_IABP_SendEmails_gne__c = true
		];

		prepareIABPDestroyRecordingsAfterEventEmails(iabps, template);
	}

	private void prepareIABPDestroyRecordingsAfterEventEmails(List<EDM_IABP_gne__c> iabps, Template template) {
		for (EDM_IABP_gne__c rec : iabps) {
			String absManagerEmail = getAbsManagerEmail(rec);

			Messaging.SingleEmailMessage email = new EmailBuilder(
					rec.EDM_Primary_AB_Lead_gne__c, rec.Id).
					replayToEmail(absManagerEmail).
					toAddresses(new List<String>{
							rec.EDM_Primary_AB_Lead_gne__r.email,
							rec.EDM_Secondary_AB_Lead_gne__r.email,
							rec.EDM_Third_AB_Lead_gne__r.email,
							rec.EDM_Cont_Vendor_Contact_Email_gne__c,
							rec.EDM_Admin_gne__c
					}).
					ccAddresses(new List<String>{
							absManagerEmail
					}).
					asOrgWideAddress(absOrgWideAddressId).
					build(template);

			emailsManager.add(email);
		}
	}

	private String prepareExpiredAttNames(List<EDM_Attendee_gne__c> expiredAttendees) {
		String result = '';

		for(EDM_Attendee_gne__c att : expiredAttendees) {
			result += att.EDM_Account_gne__r.Name + '<br/>';
		}

		return result;
	}

	public class Template {
		public Id templateId {get; private set;}
		
		public Template(Id templateId) {
			this.templateId = templateId;
		}
	}

	public class EmailBuilder {
		private Id targetObjectId;
		private Id whatId;
		private Id orgWideAddressId;
		private List<String> toAddresses;
		private List<String> ccAddresses;
		private String replayToEmail;
		private String senderDisplayName;
		private List<Attachment> attachments;
		private Map<String, String> dynamicParts;

		public EmailBuilder(Id targetObjectId, Id whatId) {
			this.targetObjectId = targetObjectId;
			this.whatId = whatId;			
		}

		public EmailBuilder replayToEmail(String replayToEmail) {
			this.replayToEmail = replayToEmail;
			return this;
		}

		public EmailBuilder toAddresses(List<String> toAddresses) {
			this.toAddresses = toAddresses;
			return this;
		}

		public EmailBuilder ccAddresses(List<String> ccAddresses) {
			this.ccAddresses = ccAddresses;
			return this;
		}

		public EmailBuilder withSenderDisplayName(String name) {
			this.senderDisplayName = name;
			return this;
		}

		public EmailBuilder withAttachments(List<Attachment> attachments) {
			this.attachments = attachments;
			return this;
		}

		public EmailBuilder withDynamicParts(Map<String, String> dynamicParts) {
			this.dynamicParts = dynamicParts;
			return this;
		}

		public EmailBuilder asOrgWideAddress(Id orgWideAddressId) {
			this.orgWideAddressId = orgWideAddressId;
			return this;
		}
		

		public Messaging.SingleEmailMessage build(Template template) {

			toAddresses = removeEmptyAddresses(toAddresses);

			ccAddresses = addTestUserToCC(ccAddresses);
			ccAddresses = removeEmptyAddresses(ccAddresses);

			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

			email.setTargetObjectId(targetObjectId);
			email.setToAddresses(toAddresses);
			email.setWhatId(whatId);
			email.setTemplateId(template.templateId);
			email.setSaveAsActivity(false);
			email.setCcAddresses(ccAddresses);
			if (String.isNotBlank(senderDisplayName)) {
				email.setSenderDisplayName(senderDisplayName);
			}			
			if (String.isNotBlank(replayToEmail)) {
				email.setReplyTo(replayToEmail);
			}

			if (String.isNotBlank(orgWideAddressId) && String.isBlank(senderDisplayName)) {				
				email.setOrgWideEmailAddressId(orgWideAddressId);
			}
			else if (String.isNotBlank(orgWideAddressId) && String.isNotBlank(senderDisplayName)) {
				System.debug('senderDisplayName not blank - not using OWA for: ' + email);
			}
			else {
				System.debug('orgWideAddressId blank');
			}

			if (targetObjectId == null) {
				System.debug('Email without targetObjectId: ' + email);
				return null;
			}

			addAttachmentsTo(email);
			addDynamicPartsTo(email, template);

			return email;
		}

		private List<String> addTestUserToCC(List<String> toAddresses) {
			String ccTestAddress = EDM_ADM_Periodical_Notification.notificationsSettings.Test_CC_Address_gne__c;
			if (String.isBlank(ccTestAddress)) {
				return toAddresses;
			}
			if (toAddresses == null) {
				return new List<String> {ccTestAddress};
			} else {
				toAddresses.add(ccTestAddress);
				return toAddresses;
			}
		}

		private List<String> removeEmptyAddresses(List<String> addresses) {
			if (addresses == null) {
				return null;
			}
			List<String> results = new List<String>();

			for (String address : addresses) {
				if (String.isNotBlank(address)) {
					results.add(address);
				}
			}

			return results;
		}

		private void addAttachmentsTo(Messaging.SingleEmailMessage email) {
			if (attachments != null) {
				List<Messaging.EmailFileAttachment> fileAttachments = new List<Messaging.EmailFileAttachment>();
				for (Attachment attach : attachments) {
					Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
					efa.setFileName(attach.Name);
					efa.setBody(attach.Body);
					fileAttachments.add(efa);
				}
				email.setFileAttachments(fileAttachments);
			}
		}

		private void addDynamicPartsTo(Messaging.SingleEmailMessage email, Template template) {
			EmailTemplate emailTemplate = [select id,Name, HtmlValue, Body from EmailTemplate where Id =: template.templateId];
			if(dynamicParts != null) {
				for (String key : dynamicParts.keySet()) {
					email.setHtmlBody(emailTemplate.HtmlValue.replace(key, dynamicParts.get(key)));
					email.setPlainTextBody(emailTemplate.Body.replace(key, dynamicParts.get(key)));
				}
			}
		}
	}
	

	public class EmailManager {
		@TestVisible private List<Messaging.SingleEmailMessage> emails;

		public EmailManager() {
			emails = new List<Messaging.SingleEmailMessage>();
		}

		public void add(Messaging.SingleEmailMessage email) {
			if (email != null) {
				emails.add(email);
			}
		}

		public void sendEmails() {
			System.debug(emails);
			if (!emails.isEmpty()) {
				Messaging.sendEmail(emails);
			}
		}
	}

	public class EDM_Notification_Send_Date_Config {
		private Map<String, Integer> methodToDaysMap;

		public EDM_Notification_Send_Date_Config() {
			this.methodToDaysMap = createConfigMap();
		}		

		private List<EDM_Notifications_gne__c> getConfigData() {
			return EDM_Notifications_gne__c.getall().values();
		}

		private Map<String, Integer> createConfigMap() {
			Map<String, Integer> tmpMap = new Map<String, Integer>();
			for(EDM_Notifications_gne__c conf : getConfigData()) {
				if(String.isNotBlank(conf.Class_Name_gne__c) && 'EDM_ADM_Periodical_Notification'.equalsIgnoreCase(conf.Class_Name_gne__c) && String.isNotBlank(conf.Method_Name_gne__c) && conf.Number_Of_Days_gne__c != null) {
					tmpMap.put(conf.Method_Name_gne__c, Integer.valueOf(conf.Number_Of_Days_gne__c));
				}
			}
			return tmpMap;
		}

		public Integer getDaysValue(String methodName) {
			return methodToDaysMap.containsKey(methodName) ? methodToDaysMap.get(methodName) : null;
		}

	}

}