@isTest
private class EDM_Documents_Notification_Ctrl_Test {
	private static EDM_AABP_gne__c testAABP;
	private static List<EDM_IABP_gne__c> iabps;
	
	@isTest static void getDocumentsTest() {
		EDM_Documents_Notification_Ctrl ctrl = new EDM_Documents_Notification_Ctrl();
		
		createTestData();
		createPTDs();

		Test.startTest();

		ctrl.eventId = iabps[1].Id;

		ctrl.tempName = 'Action_Item_Due';
		ctrl.recipientId = UserInfo.getUserId();
		System.assertEquals(1, ctrl.getDocuments().size());
		ctrl.recipientId = null;
		System.assertEquals(2, ctrl.getDocuments().size());

		ctrl.tempName = 'Action_Item_Past_Due_Today';
		System.assertEquals(1, ctrl.getDocuments().size());

		ctrl.tempName = 'Action_Item_Past_Due';
		System.assertEquals(1, ctrl.getDocuments().size());

		ctrl.tempName = 'Pull_Through_Documentation_Submitted';
		System.assertEquals(1, ctrl.getDocuments().size());		

		Test.stopTest();

	}
	
	private static void createTestData() {
		testAABP = getNewAAPB();
		insert testAABP;

		iabps = new List<EDM_IABP_gne__c>();
		iabps.add(getNewIABP(testAABP, false, 'IABP 1'));
		iabps.add(getNewIABP(testAABP, true, 'ExeSum 1'));

		insert iabps;
	}

	private static EDM_AABP_gne__c getNewAAPB() {
		EDM_AABP_gne__c newAABP = new EDM_AABP_gne__c(
			EDM_Plan_Year_gne__c = '2015',
			EDM_Plan_Received_gne__c = Date.today(),
			EDM_Final_Approval_Received_gne__c = Date.today()
		);
		return newAABP;
	}

	private static EDM_IABP_gne__c getNewIABP(EDM_AABP_gne__c parentAABP, Boolean isExsum, String detail) {
		EDM_IABP_gne__c newIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = parentAABP.Id,
			EDM_Executive_Summary_gne__c = isExsum,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_Optional_Detail_gne__c = detail
		);
		if (isExsum) {
			newIABP.EDM_Explanation_of_Att_Changes_gne__c = 'change 1';
		}
		return newIABP;
	}

	private static void createPTDs() {
		List<EDM_Attachment_gne__c> ptds = new List<EDM_Attachment_gne__c>();
		ptds.add(
				new EDM_Attachment_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'abc',
					EDM_Description_gne__c = 'desc 1',
					EDM_Pull_Through_Doc_gne__c = true,
					EDM_Due_Date_gne__c = System.today().addDays(28)
				)
			);

		ptds.add(
				new EDM_Attachment_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'abc',
					EDM_Description_gne__c = 'desc 1',
					EDM_Pull_Through_Doc_gne__c = true,
					EDM_Due_Date_gne__c = System.today()
				)
			);

		ptds.add(
				new EDM_Attachment_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'cde',
					EDM_Description_gne__c = 'desc 2',
					EDM_Pull_Through_Doc_gne__c = true,
					EDM_Due_Date_gne__c = System.today().addDays(-60)
				)
			);

		ptds.add(
				new EDM_Attachment_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'cde',
					EDM_Description_gne__c = 'desc 2',
					EDM_Pull_Through_Doc_gne__c = true,
					EDM_Upload_Date_gne__c = System.today()
				)
			);

		ptds.add(
				new EDM_Attachment_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'cde',
					EDM_Description_gne__c = 'desc 2',
					EDM_Pull_Through_Doc_gne__c = true,
					EDM_Due_Date_gne__c = System.today().addDays(28),
					EDM_Responsible_Party_gne__c = UserInfo.getUserId()
				)
			);


		insert ptds;

	}
	
}