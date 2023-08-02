@isTest
private class EDM_Spend_Ex_Test {

	@isTest static void shouldCreateExtensionForVirtual() {
		Test.setCurrentPage(Page.EDM_Spend_View_Layout);
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		System.assert(ext.spend != null);
		System.assertEquals('94080', ext.currentIABP.EDM_Zip_gne__c);
	}

	@isTest static void shouldCreateExtensionFace2Face() {
		final Integer numberOfEventDays = 5;
		Test.setCurrentPage(Page.EDM_Spend_View_Layout);
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c(
				EDM_Meeting_Approach_gne__c = 'Face to Face',
				EDM_Start_Date_gne__c = System.Today(),
				EDM_End_Date_gne__c = System.Today() + (numberOfEventDays - 1));
		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);

		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		System.assert(ext.spend != null);
		System.assertEquals(numberOfEventDays, ext.edmSpendAttendance.size());
	}

	@isTest static void shouldCalculatePlannedAttendeeCount() {
		//given
		final Integer numberOfEventDays = 3;
		Test.setCurrentPage(Page.EDM_Spend_View_Layout);
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c(
				EDM_Meeting_Approach_gne__c = 'Face to Face',
				EDM_Start_Date_gne__c = System.Today(),
				EDM_End_Date_gne__c = System.Today() + (numberOfEventDays - 1));
		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);

		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);
		ext.edmSpendAttendance.get(0).EDM_Planned_Attendee_HCP_Count_gne__c = 7;
		ext.edmSpendAttendance.get(0).EDM_Planned_Attendee_Other_Count_gne__c = 1;
		ext.edmSpendAttendance.get(1).EDM_Planned_Attendee_HCP_Count_gne__c = 5;
		ext.edmSpendAttendance.get(1).EDM_Planned_Attendee_Other_Count_gne__c = 5;
		ext.edmSpendAttendance.get(2).EDM_Planned_Attendee_HCP_Count_gne__c = 1;
		ext.edmSpendAttendance.get(2).EDM_Planned_Attendee_Other_Count_gne__c = 8;

		//when
		Integer plannedAttendeeCount = ext.getPlannedAttendeeCount();

		//then
		System.assertEquals(10, plannedAttendeeCount);
	}

	@isTest static void shouldGetNewAttachment() {
		Test.setCurrentPage(Page.EDM_Spend_View_Layout);
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		//when
		EDM_Attachment_gne__c attach = ext.getAttachment();

		System.assertEquals(null, attach.Id);
	}

	@isTest static void shouldGetExistingAttachment() {
		Test.setCurrentPage(Page.EDM_Spend_View_Layout);
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		EDM_Attachment_gne__c edmAttachment = new EDM_Attachment_gne__c (EDM_Parent_IABP_gne__c = testIABP.Id,
				EDM_System_Type_gne__c = 'Spend');
		insert edmAttachment;

		//when
		EDM_Attachment_gne__c attach = ext.getAttachment();

		System.assertEquals(edmAttachment.Id, attach.Id);
	}

	@isTest static void shouldNotSaveSpendWhenRequiredDataIsMissing() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		//when
		ext.goBackAfterSave = false;
		ext.save();

		//then
		System.assert(ApexPages.hasMessages());
	}

	@isTest static void shouldRedirectToViewIfFinalized() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);
		ext.edmSpend.EDM_Spend_Status_gne__c = 'Save & Finalize';

		//when
		PageReference pr = ext.redirectToViewIfFinalized();

		//then
		system.assertNotEquals(null, pr);
		system.assert(pr.getURL().StartsWith(Page.EDM_Spend_View_Layout.getURL()));
	}

	@isTest static void shouldNotRedirectToViewIfNotFinalized() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);
		ext.edmSpend.EDM_Spend_Status_gne__c = 'Save';

		//when
		PageReference pr =ext.redirectToViewIfFinalized();

		//then
		system.assertEquals(null, pr);
	}

	@isTest static void shouldReopenAndEdit() {
		Test.setCurrentPage(Page.EDM_Spend_View_Layout);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];
		testIABP.EDM_Canceled_gne__c = true;
		update testIABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);
		ext.edmSpend.EDM_Spend_Status_gne__c = 'Save & Finalize';
		insert ext.edmSpend;

		//when
		PageReference pr = ext.reopenAndEdit();
		String spendStatusWithModDate = ext.getCurrentSpendStatusWithModDate();

		//then
		system.assert(pr.getURL().StartsWith(Page.EDM_Spend_Edit_Create.getURL()));
		//system.assertEquals(null, pr);
		EDM_Spend_gne__c edmSpend = [SELECT EDM_Spend_Status_gne__c FROM EDM_Spend_gne__c WHERE EDM_Parent_IABP_gne__c = :testIABP.Id LIMIT 1];
		system.assertEquals('Save', edmSpend.EDM_Spend_Status_gne__c);
		system.assert(spendStatusWithModDate.startsWith('Save&emsp;'));
	}

	@isTest static void shouldReturnLinkToEditIABPWhenMissingRequiredDataOnCancledEvent() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);
		ext.currentIABP.EDM_Canceled_gne__c = true;
		ext.edmSpend.EDM_Cancellation_Type_gne__c = 'Cancel w/ Spend';
		ext.currentIABP.EDM_Start_Date_gne__c = null;
		ext.currentIABP.EDM_End_Date_gne__c = null;

		//when
		ext.onChangeEventCancellationType();

		//then
		System.assert(existsLinkToEditIABP());
	}

	private static Boolean existsLinkToEditIABP() {
		for (Apexpages.Message msg : ApexPages.getMessages()) {
			if (msg.getDetail().contains(Page.EDM_IABP_Edit_Create.getURL())) {
				System.debug(msg);
				return true;
			}
		}

		return false;
	}


	@isTest static void shouldNotCreateSecondEDMSpendRecordWhenRecordIsCreatedMeanwhile() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		EDM_Spend_gne__c edmSpend = new EDM_Spend_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id);
		insert edmSpend;

		System.assertEquals(null, ext.edmSpend.Id);

		//when
		ext.suppressEDMSpendDuplicates();

		//then
		System.assertEquals(edmSpend.Id, ext.edmSpend.Id);
	}

	@isTest static void shouldRetrieveExistingEDMSpendRecordWhenExists() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];

		EDM_Spend_gne__c edmSpend = new EDM_Spend_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id);
		insert edmSpend;

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);

		//when
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		//then
		System.assertEquals(edmSpend.Id, ext.edmSpend.Id);
	}

	@isTest static void shouldNotCreateDuplicatesAttendanceWhenRecordsAreCreatedMeanwhile() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];
		testIABP.EDM_Meeting_Approach_gne__c = 'Face to Face';
		testIABP.EDM_Start_Date_gne__c = System.Today();
		testIABP.EDM_Meeting_Date_gne__c = System.Today();
		testIABP.EDM_End_Date_gne__c = System.Today() + 1;
		update testIABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);

		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		List<EDM_Spend_Attendance_gne__c> attendance = new List<EDM_Spend_Attendance_gne__c> {
			new EDM_Spend_Attendance_gne__c(
					EDM_Event_Date_gne__c = System.Today(),
					EDM_Parent_IABP_gne__c = testIABP.Id),
			new EDM_Spend_Attendance_gne__c(
					EDM_Event_Date_gne__c = System.Today() + 1,
					EDM_Parent_IABP_gne__c = testIABP.Id)};

		insert attendance;
		//when
		ext.suppressEdmSpendAttendanceDuplicates();

		//then
		System.assertEquals(2, ext.edmSpendAttendance.size());
		for (EDM_Spend_Attendance_gne__c att : ext.edmSpendAttendance) {
			System.assertNotEquals(null, att.Id);
		}
	}

	@isTest static void shouldReadFinancials() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];

		List<EDM_Spend_Financial_gne__c> spendFin = new List<EDM_Spend_Financial_gne__c> {
			new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id, EDM_Type_gne__c = 'Content', EDM_HCP_Fees_gne__c = true, EDM_Total_Cost_gne__c = 1),
			new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id, EDM_Type_gne__c = 'Logistics', EDM_Hotel_gne__c = true, EDM_Total_Cost_gne__c = 2),
			new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id, EDM_Type_gne__c = 'Genentech', EDM_Meals_gne__c = true, EDM_Travel_gne__c = true, EDM_Total_Cost_gne__c = 3)};
		insert spendFin;

		//when
		EDM_Spend_Ex.Financials fin = new EDM_Spend_Ex.Financials(testIABP.Id);

		//then
		System.assertEquals(6, fin.getTotalAdvisoryBoardCost());
	}

	@isTest static void shouldSaveFinancials() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];

		EDM_Spend_Ex.Financials fin = new EDM_Spend_Ex.Financials(testIABP.Id);

		//when
		fin.save();

		//then
		List<EDM_Spend_Financial_gne__c> spendFinResults = [SELECT Id, EDM_Type_gne__c, EDM_HCP_Fees_gne__c, EDM_Hotel_gne__c, EDM_Meals_gne__c, EDM_Travel_gne__c FROM EDM_Spend_Financial_gne__c order by EDM_Type_gne__c];
		System.assertEquals(3, spendFinResults.size());
		System.assertEquals('Content', spendFinResults.get(0).EDM_Type_gne__c);
		System.assertEquals(false, spendFinResults.get(0).EDM_Travel_gne__c);
		System.assertEquals('Logistics', spendFinResults.get(1).EDM_Type_gne__c);
		System.assertEquals(false, spendFinResults.get(1).EDM_HCP_Fees_gne__c || spendFinResults.get(1).EDM_Hotel_gne__c || spendFinResults.get(1).EDM_Meals_gne__c);
	}

	@isTest static void shouldSaveFinancialsAndSuppressDuplicates() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];

		EDM_Spend_Ex.Financials fin = new EDM_Spend_Ex.Financials(testIABP.Id);

		List<EDM_Spend_Financial_gne__c> spendFin = new List<EDM_Spend_Financial_gne__c> {
			new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id, EDM_Type_gne__c = 'Content', EDM_HCP_Fees_gne__c = true, EDM_Total_Cost_gne__c = 1),
			new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id, EDM_Type_gne__c = 'Logistics', EDM_Hotel_gne__c = true, EDM_Total_Cost_gne__c = 2),
			new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id, EDM_Type_gne__c = 'Genentech', EDM_Meals_gne__c = true, EDM_Travel_gne__c = true, EDM_Total_Cost_gne__c = 3)};
		insert spendFin;

		//when
		fin.save();

		//then
		List<EDM_Spend_Financial_gne__c> spendFinResults = [SELECT Id, EDM_Type_gne__c, EDM_HCP_Fees_gne__c, EDM_Hotel_gne__c, EDM_Meals_gne__c, EDM_Travel_gne__c FROM EDM_Spend_Financial_gne__c order by EDM_Type_gne__c];
		System.assertEquals(3, spendFinResults.size());
		System.assertEquals('Content', spendFinResults.get(0).EDM_Type_gne__c);
		System.assertEquals(false, spendFinResults.get(0).EDM_Travel_gne__c);
		System.assertEquals('Logistics', spendFinResults.get(1).EDM_Type_gne__c);
		System.assertEquals(false, spendFinResults.get(1).EDM_HCP_Fees_gne__c);
		System.assertEquals(true, spendFinResults.get(1).EDM_Hotel_gne__c);
		System.assertEquals(false, spendFinResults.get(1).EDM_Meals_gne__c);


	}

	@isTest static void shouldSetLastNonVendorABLead() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];
		testIABP.EDM_Primary_AB_Lead_gne__c = getVDSTABMs()[0].Id;
		testIABP.EDM_Secondary_AB_Lead_gne__c = getVDSTABMs()[0].Id;
		testIABP.EDM_Third_AB_Lead_gne__c = EDM_ABM_Test_Utils.getABLs()[0].Id;
		update testIABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);

		//when
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		//then
		System.assertEquals(testIABP.EDM_Third_AB_Lead_gne__c, ext.nonVendorABLead.Id);
	}

	@isTest static void shouldNotSetNonVendorABLead() {
		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];
		testIABP.EDM_Primary_AB_Lead_gne__c = getVDSTABMs()[0].Id;
		testIABP.EDM_Secondary_AB_Lead_gne__c = getVDSTABMs()[0].Id;
		testIABP.EDM_Third_AB_Lead_gne__c = getVDSTABMs()[0].Id;
		update testIABP;

		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);

		//when
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		//then
		System.assertEquals(null, ext.nonVendorABLead.Id);
	}

	private static List<User> getVDSTABMs() {
		return EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.VDST_ABM);
	}

	@isTest static void coverageTestForProxyMethod() {
		Test.setCurrentPage(Page.EDM_Spend_View_Layout);
		EDM_IABP_gne__c testIABP = new EDM_IABP_gne__c();
		ApexPages.StandardController sc = new ApexPages.StandardController(testIABP);
		EDM_Spend_Ex ext = new EDM_Spend_Ex(sc, false);

		Boolean isContentOrLogisticsUser = ext.getIsContentOrLogisticsUser();
		Boolean isGeneUser = ext.getIsGeneUser();
		Boolean isABMSuperUser = ext.getIsABMSuperUser();

		System.assert(isContentOrLogisticsUser != isGeneUser);

		System.assertEquals(null, ext.getNonVendorABLeadName());
		System.assertEquals(null, ext.getNonVendorABLeadExternalId());

		System.assert(ext.getNumberOfMealsSelectOptions().size() > 0);
		System.assert(ext.getMealStatusSelectOptions().size() > 0);
		System.assert(ext.getFeePaidToSelectOptions().size() > 0);
		System.assert(ext.getCountries().size() > 0);
		System.assert(ext.getStates().size() > 0);
		System.assert(ext.getProvinces().size() > 0);
		System.assert(ext.getCancellationTypes().size() > 0);

		System.assertNotEquals(null, ext.goBack());
		System.assertEquals(null, ext.initParticipantPopup());
		System.assertEquals(null, ext.startDownloadDocuments());
		System.assertEquals(null, ext.closeDownloadDocuments());
		
	}

}