public without sharing class EDM_ABM_Email_Notifications {

	private static final Boolean IABP_APPROVED_NOTIFICATION_SENT_WHEN_ALL_DRAWLOOP_DOCS_GENERETED = false;

	private static Set<String> TemplateNames = new Set<String> {'AABP_Created', 'AABP_Shared', 'IABP_Approval_Withdrawn', 'IABP_Approved', 'IABP_Rejected', 
		'IABP_Returned_with_Comments', 'IABP_Revision_Approved', 'IABP_Sent_for_Approval_ABL', 'IABP_Sent_for_Review', 'IABP_Shared', 
		'ExeSum_Finalized', 'ExeSum_Returned_with_Comments', 'ExeSum_Submitted'};
	private static Map<String,EmailTemplate> EdmABMTemplates = new Map<String,EmailTemplate>();

	static {
		for (EmailTemplate tmpET : [SELECT Id, Name, Developername FROM EmailTemplate WHERE developername IN :TemplateNames]) {
			EdmABMTemplates.put(tmpET.developername,tmpET);
		}
	}

	@TestVisible private static EDM_Notifications_gne__c notificationsSettings;
	static {
		notificationsSettings = EDM_Notifications_gne__c.getInstance('Default');
		if (notificationsSettings == null) {
			notificationsSettings = new EDM_Notifications_gne__c();
		}
	}

	@TestVisible private static EDM_ADM_Periodical_Notification.EmailManager emailsManager;

	public static void onAABPafterInsert(List<EDM_AABP_gne__c> triggerNew) {
		if (Trigger.isInsert) {
			List<EDM_AABP_gne__c> aabps = new List<EDM_AABP_gne__c>();
			for (EDM_AABP_gne__c rec : triggerNew) {
				if(rec.EDM_Finalized_gne__c && rec.EDM_AB_Lead_gne__c != null) {
					aabps.add(rec);
				}
			}
			sendAABPCreatedMails(aabps);
		}
	}

    private static String absManagerEmail;
    private static String absManagerName;
    private static String absManagerId;

    public static void onAABPafterUpdate(List<EDM_AABP_gne__c> triggerOld, Map<Id,EDM_AABP_gne__c> triggerNew) {
		if (Trigger.isUpdate) {
			List<EDM_AABP_gne__c> aabps = new List<EDM_AABP_gne__c>();
			for (EDM_AABP_gne__c rec : triggerOld) {
				if(!rec.EDM_Finalized_gne__c && triggerNew.get(rec.Id).EDM_Finalized_gne__c && triggerNew.get(rec.Id).EDM_AB_Lead_gne__c != null) {
					aabps.add(triggerNew.get(rec.Id));
				}
			}
			sendAABPCreatedMails(aabps);
		}
	}

	private static void sendAABPCreatedMails(List<EDM_AABP_gne__c> aabps) {
		emailsManager = new EDM_ADM_Periodical_Notification.EmailManager();
		EDM_ADM_Periodical_Notification.Template template = getTemplate('AABP_Created');

		Set<Id> notifiedUserIds = new Set<Id>();
		for (EDM_AABP_gne__c rec : aabps) {
			if(rec.EDM_SendEmails_gne__c == true) {
				notifiedUserIds.add(rec.EDM_Vendor_Lead_gne__c);
				notifiedUserIds.add(rec.EDM_ABS_Manager_gne__c);
			}
		}
		
		NotifiedUsers notifiedUsers = new NotifiedUsers(notifiedUserIds);

		for (EDM_AABP_gne__c rec : aabps) {
			if(rec.EDM_SendEmails_gne__c == true) {
				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						rec.EDM_AB_Lead_gne__c, rec.Id).
						replayToEmail(notifiedUsers.getEmail(rec.EDM_ABS_Manager_gne__c)).
						toAddresses(new List<String>{
								notifiedUsers.getEmail(rec.EDM_Vendor_Lead_gne__c)}).
						ccAddresses(new List<String>{
								notifiedUsers.getEmail(rec.EDM_ABS_Manager_gne__c)}).
						withSenderDisplayName('EDM Notifications').
						build(template);

				emailsManager.add(email);
			}
		}

		emailsManager.sendEmails();
	}

	@TestVisible private static EDM_ADM_Periodical_Notification.Template getTemplate(String templateName) {
		EDM_ADM_Periodical_Notification.Template template = new EDM_ADM_Periodical_Notification.Template(edmABMTemplates.get(templateName).Id);
		return template;
	}

	private class NotifiedUsers {
		private Map<Id, User> notifiedUserEmails;

		public NotifiedUsers(Set<Id> notifiedUserIds) {
			notifiedUserEmails = new Map<Id, User>([Select Id, Email from User where isActive = true and Id IN :notifiedUserIds]);
		}

		public String getEmail(Id userId) {
			User u = notifiedUserEmails.get(userId);
			return u != null ? u.email : null;
		}
	}


	public static void onAABPShare(EDM_AABP_gne__c rec, List<Id> userIds) {
		if(rec.EDM_SendEmails_gne__c == true) {
			sendShareMails('AABP_Shared', rec.Id, userIds);
		}
	}

	public static void onIABPShare(EDM_IABP_gne__c rec, List<Id> userIds) {
		if(rec.EDM_IABP_SendEmails_gne__c == true) {
			sendShareMails('IABP_Shared', rec.Id, userIds);
		}
	}

	private static void sendShareMails(String templateName, Id recId, List<Id> userIdsList) {
		Set<Id> userIds = new Set<Id>(userIdsList);
		emailsManager = new EDM_ADM_Periodical_Notification.EmailManager();
		EDM_ADM_Periodical_Notification.Template template = getTemplate(templateName);

		for (Id uId : userIds) {
			Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
					uId, recId).
					replayToEmail(UserInfo.getUserEmail()).
					withSenderDisplayName(UserInfo.getName()).
					build(template);

			emailsManager.add(email);
		}

		emailsManager.sendEmails();
	}

	public static void  onIABPafterUpdate(List<EDM_IABP_gne__c> triggerOld, Map<Id,EDM_IABP_gne__c> triggerNew){
		/*
		IABP_Sent_for_Review -   zmiana status | in progress -> under review  oraz revising approved -> rereviewing approved  ) sek 3.41
		IABP_Returned_with_Comments -  ( under review -> in progress  | rereviewing approved -> evising approved
		IABP_Sent_for_Approval_ABL -  ( not started | in progress | under review -> IABP Submitted for Approval )
		IABP_Approval_Withdrawn - ( IABP Submitted for Approval -> under review ) do potwierdzenia
		IABP Rejected - ( IABP Submitted for Approval -> under review oraz jest rejected reason uzupelniony ) do potwierdzenia
		IABP_Approved -  ( in approval -> approved )
		IABP_Revision_Approved - ( rereviewing approved -> approved )
		ExeSum Submitted - trigger na update ( executive summary in progress -> executive summary in review )
		ExeSum Returned with Edits - trigger na update ( executive summary in review -> executive summary in progress )
		ExeSum Finalized - trigger na update ( executive summary in review -> PTD in progress )
		*/
		emailsManager = new EDM_ADM_Periodical_Notification.EmailManager();

		Map<Id,EDM_IABP_gne__c> IABPwithRelatedInfo = new Map<Id,EDM_IABP_gne__c>(
				[SELECT Id, 
					EDM_Parent_AABP_gne__r.EDM_ABS_Manager_gne__c, EDM_Parent_AABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_AABP_gne__r.EDM_ABS_Manager_gne__r.name,
					EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.email, EDM_Parent_IABP_gne__r.EDM_ABS_Manager_gne__r.Name,
					EDM_Primary_AB_Lead_gne__r.email, EDM_Secondary_AB_Lead_gne__r.email, EDM_Third_AB_Lead_gne__r.email,
					EDM_Approver_1_gne__r.email, EDM_Approver_2_gne__r.email, EDM_Approver_3_gne__r.email, EDM_Approver_4_gne__r.email, EDM_Approver_5_gne__r.email,
					EDM_Approver_1_gne__r.name, EDM_Approver_2_gne__r.name, EDM_Approver_3_gne__r.name, EDM_Approver_4_gne__r.name, EDM_Approver_5_gne__r.name,
					EDM_Cont_Vendor_Contact_Email_gne__c, EDM_Log_Vendor_Contact_Email_gne__c,EDM_Admin_gne__r.email,EDM_Primary_Vendor_Lead_gne__r.email,EDM_Second_Vendor_Lead_gne__r.email,
					EDM_MCS_Manager_gne__c, EDM_ABS_Manager_gne__r.email, EDM_ABS_Manager_gne__r.Name
				FROM EDM_IABP_gne__c 
				WHERE Id IN: triggerNew.keySet()]);
		system.debug('XXXX Mick triggerOld:'  + triggerOld);

		Boolean isABS = EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABS);

		for (EDM_IABP_gne__c iabp : triggerOld) {
			EDM_IABP_gne__c newIabp = triggerNew.get(iabp.Id);
			if(newIabp.EDM_IABP_SendEmails_gne__c == false) {
				continue;
			}
			String oldStatus = iabp.EDM_Status_gne__c;
			String newStatus = newIabp.EDM_Status_gne__c;
			system.debug('XXXX Mick onIABPafterUpdate on :'  + iabp.Id);
			System.debug('#wk IABPwithRelatedInfo.get(iabp.Id): ' + IABPwithRelatedInfo.get(iabp.Id));
			absManagerEmail = getAbsManagerEmail(IABPwithRelatedInfo.get(iabp.Id));
			absManagerName = getAbsManagerName(IABPwithRelatedInfo.get(iabp.Id));
			absManagerId = getAbsManagerId(IABPwithRelatedInfo.get(iabp.Id));

			// FOR: IABP_Sent_for_Review
			if ( ((oldStatus == 'IABP In Progress' || oldStatus == 'IABP Not Started') && newStatus == 'IABP Under Review') || 
					(oldStatus != 'Re-Reviewing Approved IABP' && newStatus == 'Re-Reviewing Approved IABP')) {

				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						absManagerId, newIabp.Id).
						replayToEmail(UserInfo.getUserEmail()).
						withSenderDisplayName(UserInfo.getName()).
						build(getTemplate('IABP_Sent_for_Review'));

				emailsManager.add(email);
			}
			// FOR: IABP_Returned_with_Comments
			else if ( (oldStatus == 'IABP Under Review' && newStatus == 'IABP In Progress') || 
					(oldStatus == 'Re-Reviewing Approved IABP' && newStatus == 'Revising Approved IABP') ||
					(isABS && oldStatus == 'IABP Not Started' && newStatus == 'IABP In Progress')) {

				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						newIabp.EDM_Primary_AB_Lead_gne__c, newIabp.Id).
						replayToEmail(UserInfo.getUserEmail()).
						withSenderDisplayName(UserInfo.getName()).
						toAddresses(new List<String> {
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Secondary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Third_AB_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Admin_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_Vendor_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Second_Vendor_Lead_gne__r.email}).
						build(getTemplate('IABP_Returned_with_Comments'));

				emailsManager.add(email);
			}
			// FOR: IABP_Sent_for_Approval_ABL 
			else if (oldStatus != 'IABP Submitted for Approval' && newStatus == 'IABP Submitted for Approval') {
				List<String> toAddressesList = new List<String> {
					IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_AB_Lead_gne__r.email,
					IABPwithRelatedInfo.get(iabp.Id).EDM_Secondary_AB_Lead_gne__r.email, 
					IABPwithRelatedInfo.get(iabp.Id).EDM_Third_AB_Lead_gne__r.email,
					IABPwithRelatedInfo.get(iabp.Id).EDM_Admin_gne__r.email,
					IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_Vendor_Lead_gne__r.email,
					IABPwithRelatedInfo.get(iabp.Id).EDM_Second_Vendor_Lead_gne__r.email
				};

				String logVendorEmail = IABPwithRelatedInfo.get(iabp.Id).EDM_Log_Vendor_Contact_Email_gne__c;
				if (String.isNotBlank(logVendorEmail)) {
					toAddressesList.add(logVendorEmail);
				}

				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						newIabp.EDM_Primary_AB_Lead_gne__c, newIabp.Id).
						replayToEmail(absManagerEmail).
						withSenderDisplayName(absManagerName).
						toAddresses(toAddressesList).
						build(getTemplate('IABP_Sent_for_Approval_ABL'));

				emailsManager.add(email);
			}
			// FOR: IABP_Approval_Withdrawn
			else if (oldStatus == 'IABP Submitted for Approval' && newStatus == 'IABP Under Review' && newIabp.EDM_Approval_Status_gne__c == 'Canceled' ) {
				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						newIabp.EDM_Approver_1_gne__c, newIabp.Id).
						replayToEmail(absManagerEmail).
						withSenderDisplayName(absManagerName).
						toAddresses(new List<String> {
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_1_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_2_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_3_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_4_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_5_gne__r.email}).
						build(getTemplate('IABP_Approval_Withdrawn'));

				emailsManager.add(email);
			}
			// FOR: IABP_Rejected 
			else if (oldStatus == 'IABP Submitted for Approval' && newStatus == 'IABP In Progress' && isRejected(newIabp)) {

				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						newIabp.EDM_Primary_AB_Lead_gne__c, newIabp.Id).
						replayToEmail(UserInfo.getUserEmail()).
						withSenderDisplayName(UserInfo.getName()).
						toAddresses(new List<String> {
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Secondary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Third_AB_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Admin_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_Vendor_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Second_Vendor_Lead_gne__r.email}).
						ccAddresses(new List<String> {
							absManagerEmail,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_1_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_2_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_3_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_4_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Approver_5_gne__r.email,
							newIabp.EDM_Cont_Vendor_Contact_Email_gne__c}).
						build(getTemplate('IABP_Rejected'));

				emailsManager.add(email);
			}
			// FOR: IABP_Approved
			else if (oldStatus == 'IABP Submitted for Approval' && newStatus == 'IABP Approved') {
				
				if (!IABP_APPROVED_NOTIFICATION_SENT_WHEN_ALL_DRAWLOOP_DOCS_GENERETED) {
					addEmailForIABPApproved(IABPwithRelatedInfo.get(iabp.Id), null);
				}
			}
			// FOR: IABP_Revision_Approved
			else if (oldStatus == 'Re-Reviewing Approved IABP' && newStatus == 'IABP Approved') {
				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						newIabp.EDM_Primary_AB_Lead_gne__c, newIabp.Id).
						replayToEmail(absManagerEmail).
						withSenderDisplayName(absManagerName).
						toAddresses(new List<String> {
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Secondary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Third_AB_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Admin_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_Vendor_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Second_Vendor_Lead_gne__r.email}).
						ccAddresses(new List<String> {
							newIabp.EDM_Cont_Vendor_Contact_Email_gne__c,
							newIabp.EDM_Log_Vendor_Contact_Email_gne__c}).
						build(getTemplate('IABP_Revision_Approved'));

				emailsManager.add(email);
			}
			// FOR: ExeSum_Submitted
			else if (oldStatus == 'Executive Summary in Progress' && newStatus == 'Executive Summary in Review') {
				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						absManagerId, newIabp.Id).
						replayToEmail(UserInfo.getUserEmail()).
						withSenderDisplayName(UserInfo.getName()).
						ccAddresses(new List<String> {
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Secondary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Third_AB_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Admin_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_Vendor_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Second_Vendor_Lead_gne__r.email,
							newIabp.EDM_Cont_Vendor_Contact_Email_gne__c,
							notificationsSettings.Exesum_notifications_Address_gne__c}).
						build(getTemplate('ExeSum_Submitted'));

				emailsManager.add(email);
			}
			// FOR: ExeSum_Returned_with_Comments
			else if (oldStatus == 'Executive Summary in Review' && newStatus == 'Executive Summary in Progress') {
				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						newIabp.EDM_Primary_AB_Lead_gne__c, newIabp.Id).
						replayToEmail(absManagerEmail).
						withSenderDisplayName(absManagerName).
						toAddresses(new List<String> {
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Secondary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Third_AB_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Admin_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_Vendor_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Second_Vendor_Lead_gne__r.email}).
						ccAddresses(new List<String> {
							newIabp.EDM_Cont_Vendor_Contact_Email_gne__c}).
						build(getTemplate('ExeSum_Returned_with_Comments'));

				emailsManager.add(email);
			}
			// FOR : ExeSum_Finalized 
			else if (oldStatus == 'Executive Summary in Review' && newStatus == 'PTD in Progress') {
				Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
						newIabp.EDM_Primary_AB_Lead_gne__c, newIabp.Id).
						replayToEmail(absManagerEmail).
						withSenderDisplayName(absManagerName).
						toAddresses(new List<String> {
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Secondary_AB_Lead_gne__r.email, 
							IABPwithRelatedInfo.get(iabp.Id).EDM_Third_AB_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Admin_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Primary_Vendor_Lead_gne__r.email,
							IABPwithRelatedInfo.get(iabp.Id).EDM_Second_Vendor_Lead_gne__r.email}).
						ccAddresses(new List<String> {
							newIabp.EDM_Cont_Vendor_Contact_Email_gne__c}).
						build(getTemplate('ExeSum_Finalized'));

				emailsManager.add(email);
			}

		}
		
		emailsManager.sendEmails();
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

	private static Boolean isRejected(EDM_IABP_gne__c iabp) {
		return (iabp.EDM_Approver_1_gne__c != null  && iabp.EDM_Approver_1_Status_gne__c.startsWith('Rejected')) || 
				(iabp.EDM_Approver_2_gne__c != null && iabp.EDM_Approver_2_Status_gne__c.startsWith('Rejected')) || 
				(iabp.EDM_Approver_3_gne__c != null && iabp.EDM_Approver_3_Status_gne__c.startsWith('Rejected')) || 
				(iabp.EDM_Approver_4_gne__c != null  && iabp.EDM_Approver_4_Status_gne__c.startsWith('Rejected'))|| 
				(iabp.EDM_Approver_5_gne__c != null && iabp.EDM_Approver_5_Status_gne__c.startsWith('Rejected'));
	}

	public static void sendNotificationsForApprovedIABP(Map<Id, List<EDM_Attachment_gne__c>> iabpIdsWithAllSystemGeneretedDocumentsReady) {
		if (IABP_APPROVED_NOTIFICATION_SENT_WHEN_ALL_DRAWLOOP_DOCS_GENERETED) {
			emailsManager = new EDM_ADM_Periodical_Notification.EmailManager();

			List<EDM_IABP_gne__c> iabps = [
					SELECT Id, OwnerId, EDM_Primary_AB_Lead_gne__c, EDM_Secondary_AB_Lead_gne__c, EDM_Third_AB_Lead_gne__c,
						EDM_Parent_AABP_gne__r.EDM_ABS_Manager_gne__c, EDM_Parent_AABP_gne__r.EDM_ABS_Manager_gne__r.email, 
						EDM_Primary_AB_Lead_gne__r.email, EDM_Secondary_AB_Lead_gne__r.email, EDM_Third_AB_Lead_gne__r.email,
						EDM_Approver_1_gne__r.email, EDM_Approver_1_gne__r.name,
						EDM_Cont_Vendor_Contact_Email_gne__c, EDM_Log_Vendor_Contact_Email_gne__c, EDM_MCS_Manager_gne__c
					FROM EDM_IABP_gne__c
					WHERE Id in :iabpIdsWithAllSystemGeneretedDocumentsReady.keySet()
					AND EDM_IABP_SendEmails_gne__c = true];

			Map<Id, List<Attachment>> attachmentsByIABPId = retrieveAttachmentsFor(iabpIdsWithAllSystemGeneretedDocumentsReady);

			for (EDM_IABP_gne__c iabp : iabps) {
				addEmailForIABPApproved(iabp, attachmentsByIABPId.get(iabp.Id));
			}
			
			emailsManager.sendEmails();
		}
	}

	private static void addEmailForIABPApproved(EDM_IABP_gne__c iabp, List<Attachment> attachments) {
		List<String> ccEmailAddresses = new List<String> {
					iabp.EDM_Cont_Vendor_Contact_Email_gne__c,
					iabp.EDM_Log_Vendor_Contact_Email_gne__c
				};
		ccEmailAddresses.addAll(getMCSManagerEmailAddresses(iabp.EDM_MCS_Manager_gne__c));

		Messaging.SingleEmailMessage email = new EDM_ADM_Periodical_Notification.EmailBuilder(
				absManagerId, iabp.Id).
				replayToEmail(UserInfo.getUserEmail()).
				withSenderDisplayName(UserInfo.getName()).
				toAddresses(new List<String> {
                    absManagerEmail,
					iabp.EDM_Primary_AB_Lead_gne__r.email, 
					iabp.EDM_Secondary_AB_Lead_gne__r.email, 
					iabp.EDM_Third_AB_Lead_gne__r.email,
					iabp.EDM_Admin_gne__r.email,
					iabp.EDM_Primary_Vendor_Lead_gne__r.email,
					iabp.EDM_Second_Vendor_Lead_gne__r.email}).
				ccAddresses(ccEmailAddresses).
				withAttachments(attachments).
				build(getTemplate('IABP_Approved'));

		emailsManager.add(email);
	}

	private static List<String> getMCSManagerEmailAddresses(String mcsEmailAddressListCSV) {
		List<String> addresses = new List<String>();
		if (String.isNotBlank(mcsEmailAddressListCSV)) {
			List<String> addressesSplit = mcsEmailAddressListCSV.split(',');
			for (String address : addressesSplit) {
				if (String.isNotBlank(address.trim())) {
					addresses.add(address.trim());
				}
			}
		}
		return addresses;
	}

	private static Map<Id, List<Attachment>> retrieveAttachmentsFor(Map<Id, List<EDM_Attachment_gne__c>> iabpIdsWithAllSystemGeneretedDocumentsReady) {
		Map<Id, List<Attachment>> results = new Map<Id, List<Attachment>>();
		Map<Id, Id> allEdmAttachmentIdsWithIABPsId = new Map<Id, Id>();
		for (Id iabpId : iabpIdsWithAllSystemGeneretedDocumentsReady.keySet()) {
			for (EDM_Attachment_gne__c edmAttach : iabpIdsWithAllSystemGeneretedDocumentsReady.get(iabpId)) {
				allEdmAttachmentIdsWithIABPsId.put(edmAttach.id, iabpId);
			}
		}
		for (Attachment attach : [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId in :allEdmAttachmentIdsWithIABPsId.keySet()])  {
			Id edmAttachmentId = attach.ParentId;
			Id iabpId = allEdmAttachmentIdsWithIABPsId.get(edmAttachmentId);

			if (results.get(iabpId) == null) {
				results.put(iabpId, new List<Attachment> {attach});
			} else {
				results.get(iabpId).add(attach);
			}
		}
		return results;
	}

}