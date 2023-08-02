@isTest
private class EDM_Spend_Drawloop_Test {

	@isTest static void itShouldValidateSpendDrawloopDefinition() {
		// Given

		// When
		EDM_Spend_Drawloop spendDrawloop = new EDM_Spend_Drawloop();

		// Then
		System.assert(spendDrawloop.getGlobalDescribe().contains('SpendInfo'));
		System.assert(spendDrawloop.getChildRelationships('HCPParticipantsInfo').contains('HCPParticipantsAttendance'));
		System.assertEquals(spendDrawloop.getGlobalDescribe().size(), spendDrawloop.describeObjects(new List<String>(spendDrawloop.getGlobalDescribe())).size());
	}

	@isTest static void itShouldGetData() {
		// Given
		EDM_IABP_gne__c testIABP = (EDM_IABP_gne__c)EDM_ABM_Test_Utils.insertABMStructure()[1];
		EDM_Spend_gne__c edmSpend = new EDM_Spend_gne__c(EDM_Parent_IABP_gne__c = testIABP.Id);
		insert edmSpend;

		Account acc = new Account(Name = 'testAcc');
		insert acc;

		insertAttendee(testIABP, acc.Id);

		Test.setCurrentPage(Page.EDM_Spend_Edit_Create);
		EDM_Spend_Drawloop spendDrawloop = new EDM_Spend_Drawloop();
		Loop.ExternalData.QueryRequestInfo requestInfo = new Loop.ExternalData.QueryRequestInfo();
		requestInfo.RecordId = edmSpend.Id;

		// When
		Loop.ExternalData.QueryResultSet resultSet = spendDrawloop.query(requestInfo);

		//then
		System.assertEquals('SpendInfo', resultSet.results.get(0).objectName);
	}

	private static void insertAttendee(EDM_IABP_gne__c parentIABP, Id accId) {
		List<EDM_Attendee_gne__c> atts = new List<EDM_Attendee_gne__c>();
		atts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_System_Type_gne__c = 'Advisor',
			Originate_from_ExeSum_gne__c = true,
			EDM_Account_gne__c = accId
		));
		atts.add(new EDM_Attendee_gne__c(
			EDM_Parent_IABP_gne__c = parentIABP.Id,
			EDM_System_Type_gne__c = 'Genentech',
			Originate_from_ExeSum_gne__c = true,
			EDM_Account_gne__c = accId
		));
		insert atts;
	}
}