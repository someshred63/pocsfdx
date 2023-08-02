@isTest
private class EDM_ABM_Email_Notifications_Test {

	@testSetup static void setup() {
		insert new EDM_Notifications_gne__c(Name = 'Default', 
			Escalation_Address_gne__c = 'EscalationAddress@example.com', Test_CC_Address_gne__c = 'TestCCAddress@example.com',
			Exesum_notifications_Address_gne__c = 'ExesumNotificationsAddress@example.com');
	}
	
	@isTest static void shouldSendMailWhenAABPIsCreatedFinalized() {
		//given
		EDM_AABP_gne__c aapb = getNewTestAABP();
		aapb.EDM_Finalized_gne__c = true;

		//when
		insert aapb;

		//then
		assertMailSend(1, 'AABP_Created');
	}

	@isTest static void shouldNotSendMailWhenAABPIsCreatedFinalizedHasNoLead() {
		//given
		EDM_AABP_gne__c aapb = getNewTestAABP();
		aapb.EDM_Finalized_gne__c = true;
		aapb.EDM_AB_Lead_gne__c = null;

		//when
		insert aapb;

		//then
		assertMailSend(0, 'AABP_Created');
	}

	@isTest static void shouldSendMailWhenAABPIsFinalized() {
		//given
		EDM_AABP_gne__c aapb = getNewTestAABP();
		insert aapb;
		
		//when
		aapb.EDM_Finalized_gne__c = true;
		update aapb;

		//then
		System.assertEquals(1, EDM_ABM_Email_Notifications.emailsManager.emails.size());
		assertMailSend(1, 'AABP_Created');
	}

	@isTest static void shouldSendMailWhenAABPIsShared() {
		//given
		List<User> abls = EDM_ABM_Test_Utils.getABLs();
		EDM_AABP_gne__c aapb = getNewTestAABP();
		insert aapb;
		
		//when
		EDM_ABM_Email_Notifications.onAABPShare(aapb, new List<Id> {abls[0].Id});

		//then
		assertMailSend(1, 'AABP_Shared');
	}

	@isTest static void shouldSendMailWhenIABPIsShared() {
		//given
		List<User> abls = EDM_ABM_Test_Utils.getABLs();
		EDM_IABP_gne__c iapb = getNewTestIABP('');
		insert iapb;
		EDM_IABP_gne__c iabpFromDatabase = [SELECT Id, Name, EDM_IABP_SendEmails_gne__c FROM EDM_IABP_gne__c WHERE Id =: iapb.Id];

		//when
		EDM_ABM_Email_Notifications.onIABPShare(iabpFromDatabase, new List<Id> {abls[0].Id});

		//then
		assertMailSend(1, 'IABP_Shared');
	}

	@isTest static void shouldSendMailWhenIABPIsSendForReview() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('IABP Not Started'),
			getNewTestIABP('IABP In Progress'),
			getNewTestIABP('Revising Approved IABP') };

		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'IABP Under Review';
		iabps[1].EDM_Status_gne__c = 'IABP Under Review';
		iabps[2].EDM_Status_gne__c = 'Re-Reviewing Approved IABP';
		update iabps;

		//then
		assertMailSend(3, 'IABP_Sent_for_Review');
	}

	@isTest static void shouldSendMailWhenIABPIsReturnedWithComments() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('IABP Under Review'),
			getNewTestIABP('Re-Reviewing Approved IABP') };
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'IABP In Progress';
		iabps[1].EDM_Status_gne__c = 'Revising Approved IABP';
		update iabps;

		//then
		assertMailSend(2, 'IABP_Returned_with_Comments');
	}

	@isTest static void shouldSendMailWhenIABPIsSentForApproval() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('IABP Under Review'),
			getNewTestIABP('IABP In Progress') };
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'IABP Submitted for Approval';
		iabps[1].EDM_Status_gne__c = 'IABP Submitted for Approval';
		update iabps;

		//then
		assertMailSend(2, 'IABP_Sent_for_Approval_ABL');
	}

	@isTest static void shouldSendMailWhenApprovalWithdrawn() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('IABP Submitted for Approval')};
		iabps[0].EDM_Approver_1_gne__c = UserInfo.getUserId();
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'IABP Under Review';
		iabps[0].EDM_Approval_Status_gne__c = 'Canceled';
		update iabps;

		//then
		assertMailSend(1, 'IABP_Approval_Withdrawn');
	}

	@isTest static void shouldSendMailWhenIABPRejected() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('IABP Submitted for Approval')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'IABP In Progress';
		iabps[0].EDM_Approver_5_gne__c = UserInfo.getUserId();
		iabps[0].EDM_Approver_5_Status_gne__c = 'Rejected';
		update iabps;

		//then
		assertMailSend(1, 'IABP_Rejected');
	}

	@isTest static void shouldSendMailWhenIABPRevisionApproved() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('Re-Reviewing Approved IABP')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'IABP Approved';
		update iabps;

		//then
		assertMailSend(1, 'IABP_Revision_Approved');
	}


	@isTest static void shouldSendMailWhenIABPIsApproved() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('IABP Submitted for Approval')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'IABP Approved';
		update iabps;

		//then
		assertMailSend(1, 'IABP_Approved');
	}

	@isTest static void shouldSendMCSManagerCCWhenIABPIsApproved() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('IABP Submitted for Approval')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'IABP Approved';
		iabps[0].EDM_MCS_Manager_gne__c = 'ala@makota.pl, krol-macius@pierwszy.com';
		update iabps;

		//then
		assertMailSend(1, 'IABP_Approved');
		assertMailSendForGivenCC(EDM_ABM_Email_Notifications.emailsManager.emails.get(0), 'ala@makota.pl');
		assertMailSendForGivenCC(EDM_ABM_Email_Notifications.emailsManager.emails.get(0), 'krol-macius@pierwszy.com');
	}

	@isTest static void shouldSendMailWhenExeSumSubmitted() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('Executive Summary in Progress')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'Executive Summary in Review';
		update iabps;

		//then
		assertMailSend(1, 'ExeSum_Submitted');
	}

	@isTest static void shouldSendMailWhenExeSumSubmittedWithCCToExesumNotificationsAddress() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('Executive Summary in Progress')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'Executive Summary in Review';
		update iabps;

		//then
		assertMailSend(1, 'ExeSum_Submitted');
		assertMailSendForGivenCC(EDM_ABM_Email_Notifications.emailsManager.emails.get(0), 'ExesumNotificationsAddress@example.com');
	}

	@isTest static void shouldSendMailWhenExeSumReturnedWithComments() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('Executive Summary in Review')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'Executive Summary in Progress';
		update iabps;

		//then
		assertMailSend(1, 'ExeSum_Returned_with_Comments');
	}

	@isTest static void shouldNotSendMailWhenExeSumReturnedWithCommentsHasNoLead() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('Executive Summary in Review')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'Executive Summary in Progress';
		iabps[0].EDM_Primary_AB_Lead_gne__c = null;
		iabps[0].EDM_Secondary_AB_Lead_gne__c = null;
		iabps[0].EDM_Third_AB_Lead_gne__c = null;
		update iabps;

		//then
		assertMailSend(0, 'ExeSum_Returned_with_Comments');
	}

	@isTest static void shouldSendMailWhenExeSumFinalized() {
		//given
		List<EDM_IABP_gne__c> iabps = new List<EDM_IABP_gne__c> {
			getNewTestIABP('Executive Summary in Review')};
		insert iabps;

		//when
		iabps[0].EDM_Status_gne__c = 'PTD in Progress';
		update iabps;

		//then
		assertMailSend(1, 'ExeSum_Finalized');
	}


	private static void assertMailSend(Integer numberOfMailSend, String templateName) {
		System.assertEquals(numberOfMailSend, EDM_ABM_Email_Notifications.emailsManager.emails.size());

		for (Messaging.SingleEmailMessage email : EDM_ABM_Email_Notifications.emailsManager.emails) {
			System.assertEquals(EDM_ABM_Email_Notifications.getTemplate(templateName).TemplateId, email.TemplateId);
		}
	}

	private static void assertMailSendForGivenCC(Messaging.SingleEmailMessage email, String ccAddressToCheck) {
		for (String ccAddress : EDM_ABM_Email_Notifications.emailsManager.emails.get(0).ccAddresses) {
			if (ccAddress == ccAddressToCheck) {
				return;
			}
		}
		
		System.assert(false, 'Not sent to ' + ccAddressToCheck + '. ccAddresses = ' + EDM_ABM_Email_Notifications.emailsManager.emails.get(0).ccAddresses);
	}

	private static EDM_AABP_gne__c getNewTestAABP() {
		return new EDM_AABP_gne__c(
				EDM_AB_Lead_gne__c =  UserInfo.getUserId(),
				EDM_Plan_Year_gne__c = '2015',
				EDM_ABS_Manager_gne__c = UserInfo.getUserId(),
				EDM_SendEmails_gne__c = true
		);
	}

	private static EDM_IABP_gne__c getNewTestIABP(String iabpStatus) {
		List<User> abls = EDM_ABM_Test_Utils.getABLs();
		EDM_AABP_gne__c aapb = getNewTestAABP();
		insert aapb;

		return new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = aapb.Id,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_Historical_gne__c = false,
			EDM_Secondary_AB_Lead_gne__c = abls[2].Id,
			EDM_Third_AB_Lead_gne__c = abls[1].Id,
			EDM_Primary_AB_Lead_gne__c = abls[0].Id,
			EDM_Cont_Vendor_Contact_Email_gne__c = 'vendor@example.com',
			EDM_Status_gne__c = iabpStatus,
			EDM_MCS_Manager_gne__c = '',
			EDM_Parent_AABP_gne__r = aapb
		);
	}
}