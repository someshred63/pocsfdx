@isTest
private class EDM_IABP_Trigger_Test {
	private static EDM_AABP_gne__c testAABP;
	private static List<EDM_IABP_gne__c> iabps;

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
			EDM_Final_Approval_Received_gne__c = Date.today(),
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		return newAABP;
	}

	private static EDM_IABP_gne__c getNewIABP(EDM_AABP_gne__c parentAABP, Boolean isExsum, String detail) {
		EDM_IABP_gne__c newIABP = new EDM_IABP_gne__c(
			EDM_Parent_AABP_gne__c = parentAABP.Id,
			EDM_Executive_Summary_gne__c = isExsum,
			EDM_Type_of_Event_gne__c = 'test event type',
			EDM_IABP_Version_gne__c = 199,
			EDM_Optional_Detail_gne__c = detail,
			EDM_ABS_Manager_gne__c = UserInfo.getUserId()
		);
		if (isExsum) {
			newIABP.EDM_Explanation_of_Att_Changes_gne__c = 'change 1';
		}
		return newIABP;
	}

	private static void forcePDTSnapshot() {
		iabps[1].EDM_ExeSum_Status_gne__c = 'In Review';
		update iabps[1];
		iabps[1].EDM_ExeSum_Status_gne__c = 'Finalized';
		update iabps[1];
	}

	private static void createPTDs() {
		List<EDM_Attachment_gne__c> ptds = new List<EDM_Attachment_gne__c>();
		ptds.add(
				new EDM_Attachment_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'abc',
					EDM_Description_gne__c = 'desc 1',
					EDM_Pull_Through_Doc_gne__c = true
				)
			);

		ptds.add(
				new EDM_Attachment_gne__c(
					EDM_Parent_IABP_gne__c = iabps[1].Id,
					EDM_ID_For_Comparator_gne__c = 'cde',
					EDM_Description_gne__c = 'desc 2',
					EDM_Pull_Through_Doc_gne__c = true
				)
			);

		insert ptds;
	}

	@isTest
	public static void shouldCreateSnapsOfNotSnappedPTD() {
		//given
		createTestData();
		createPTDs();
		

		//when
		forcePDTSnapshot();

		//then
		List<EDM_Attachment_gne__c> snaps = [SELECT Id FROM EDM_Attachment_gne__c WHERE EDM_System_Type_gne__c = 'PTD_Snapshot'];
		System.assertEquals(2, snaps.size());

		//when
		delete snaps[0];
		forcePDTSnapshot();

		//then
		snaps = [SELECT Id FROM EDM_Attachment_gne__c WHERE EDM_System_Type_gne__c = 'PTD_Snapshot'];
		System.assertEquals(2, snaps.size());
	}
}