/** @date 2/19/2014
* @Author Konrad Malinowski
* @description Test Class for VDST_BatchEventSetParticipantsNumber trigger
*/
@isTest
private class VDST_BatchEventSetParticipantsNum_Test {
	
	/** @date 2/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for inserting batch participants with no valid and invalid number assignations of participants to batch event
	*/
	@isTest static void shouldInsertParticipantsIsNotAfterBatchProcessing() {
		// GIVEN
		List<VDST_BatchRecord_gne__c> events = createUtilDataAndReturnEventList();

		// WHEN
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);

		// THEN
		VDST_BatchRecord_gne__c eventWithParticipants = [SELECT ValidParticipants_gne__c, InvalidParticipants_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :events[0].Id LIMIT 1];
		Integer noParticipantsNumberAssigned = 0;
		System.assertEquals( noParticipantsNumberAssigned, eventWithParticipants.ValidParticipants_gne__c );
		System.assertEquals( noParticipantsNumberAssigned, eventWithParticipants.InvalidParticipants_gne__c );
	}

	/** @date 2/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for inserting valid batch participants with assignations for valid and invalid number of participants to batch event
	*/
	@isTest static void shouldInsertValidParticipantsIsAfterBatchProcessing() {
		// GIVEN
		VDST_BatchRecord_gne__c event = createUtilDataAndReturnEventList()[0];
		
		// WHEN
		Integer numberOfParticipants = 2;
		List<VDST_BatchRecord_gne__c> participants = new List<VDST_BatchRecord_gne__c>();
		for(Integer i = 0; i < numberOfParticipants; i++) {
			VDST_BatchRecord_gne__c participant = VDST_TestUtils.initiateValidBatchParticipant(event, 'GNE_123456789' + i);
			participant.IsAfterBatchProcessing_gne__c = true;
			participant.isValid__c = true;
			participants.add( participant );
		}
		insert participants;

		// THEN
		VDST_BatchRecord_gne__c eventWithParticipants = [SELECT ValidParticipants_gne__c, InvalidParticipants_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :event.Id LIMIT 1];
		System.assertEquals( numberOfParticipants, eventWithParticipants.ValidParticipants_gne__c );
		System.assertEquals( 0, eventWithParticipants.InvalidParticipants_gne__c );
	}

	/** @date 2/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for inserting invalid batch participants with assignations for valid and invalid number of participants to batch event
	*/
	@isTest static void shouldInsertInvalidParticipantsIsAfterBatchProcessing() {
		// GIVEN
		VDST_BatchRecord_gne__c event = createUtilDataAndReturnEventList()[0];
		
		// WHEN
		Integer numberOfParticipants = 2;
		List<VDST_BatchRecord_gne__c> participants = new List<VDST_BatchRecord_gne__c>();
		for(Integer i = 0; i < numberOfParticipants; i++) {
			VDST_BatchRecord_gne__c participant = VDST_TestUtils.initiateValidBatchParticipant(event, 'GNE_123456789' + i);
			participant.IsAfterBatchProcessing_gne__c = true;
			participant.isValid__c = false;
			participants.add( participant );
		}
		insert participants;

		// THEN
		VDST_BatchRecord_gne__c eventWithParticipants = [SELECT ValidParticipants_gne__c, InvalidParticipants_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :event.Id LIMIT 1];
		System.assertEquals( 0, eventWithParticipants.ValidParticipants_gne__c );
		System.assertEquals( numberOfParticipants, eventWithParticipants.InvalidParticipants_gne__c );
	}

	/** @date 2/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updating valid batch participants with assignations for valid and invalid number of participants to batch event
	*/
	@isTest static void shouldUpdateValidParticipants() {
		// GIVEN
		VDST_BatchRecord_gne__c event = createUtilDataAndReturnEventList()[0];
			
		Integer numberOfParticipants = 2;
		List<VDST_BatchRecord_gne__c> participants = new List<VDST_BatchRecord_gne__c>();
		for(Integer i = 0; i < numberOfParticipants; i++) {
			VDST_BatchRecord_gne__c participant = VDST_TestUtils.initiateValidBatchParticipant(event, 'GNE_123456789' + i);
			participant.IsAfterBatchProcessing_gne__c = true;
			participant.isValid__c = true;
			participants.add( participant );
		}
		insert participants;

		// WHEN
		for(VDST_BatchRecord_gne__c p : participants) {
			p.FirstName_gne__c = 'Ted';
		}
		update participants;

		// THEN
		VDST_BatchRecord_gne__c eventWithParticipants = [SELECT ValidParticipants_gne__c, InvalidParticipants_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :event.Id LIMIT 1];
		System.assertEquals( numberOfParticipants, eventWithParticipants.ValidParticipants_gne__c );
		System.assertEquals( 0, eventWithParticipants.InvalidParticipants_gne__c );
	}

	/** @date 2/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updating invalid batch participants with assignations for valid and invalid number of participants to batch event
	*/
	@isTest static void shouldUpdateInvalidParticipants() {
		// GIVEN
		VDST_BatchRecord_gne__c event = createUtilDataAndReturnEventList()[0];
			
		Integer numberOfParticipants = 2;
		List<VDST_BatchRecord_gne__c> participants = new List<VDST_BatchRecord_gne__c>();
		for(Integer i = 0; i < numberOfParticipants; i++) {
			VDST_BatchRecord_gne__c participant = VDST_TestUtils.initiateValidBatchParticipant(event, 'GNE_123456789' + i);
			participant.IsAfterBatchProcessing_gne__c = true;
			participant.isValid__c = false;
			participants.add( participant );
		}
		insert participants;

		// WHEN
		for(VDST_BatchRecord_gne__c p : participants) {
			p.FirstName_gne__c = 'Ted';
		}
		update participants;

		// THEN
		VDST_BatchRecord_gne__c eventWithParticipants = [SELECT ValidParticipants_gne__c, InvalidParticipants_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :event.Id LIMIT 1];
		System.assertEquals( 0, eventWithParticipants.ValidParticipants_gne__c );
		System.assertEquals( numberOfParticipants, eventWithParticipants.InvalidParticipants_gne__c );
	}

	/** @date 2/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assigning parent for valid batch participants
	*/
	@isTest static void shouldUpdateValidParticipantsWithParentAssignment() {
		// GIVEN
		VDST_BatchRecord_gne__c event = createUtilDataAndReturnEventList()[0];
			
		Integer numberOfParticipants = 2;
		List<VDST_BatchRecord_gne__c> participants = new List<VDST_BatchRecord_gne__c>();
		for(Integer i = 0; i < numberOfParticipants; i++) {
			VDST_BatchRecord_gne__c participant = VDST_TestUtils.initiateValidBatchParticipant(event, 'GNE_123456789' + i);
			participant.IsAfterBatchProcessing_gne__c = true;
			participant.isValid__c = true;
			participant.VDST_ParentEvent_gne__c = null;
			participants.add( participant );
		}
		insert participants;

		// WHEN
		for(VDST_BatchRecord_gne__c p : participants) {
			p.VDST_ParentEvent_gne__c = event.Id;
		}
		update participants;

		// THEN
		VDST_BatchRecord_gne__c eventWithParticipants = [SELECT ValidParticipants_gne__c, InvalidParticipants_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :event.Id LIMIT 1];
		System.assertEquals( numberOfParticipants, eventWithParticipants.ValidParticipants_gne__c );
		System.assertEquals( 0, eventWithParticipants.InvalidParticipants_gne__c );
	}

	/** @date 2/19/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updating batch participants from valid to invalid
	*/
	@isTest static void shouldUpdateParticipantsFromValidToInvalid() {
		// GIVEN
		VDST_BatchRecord_gne__c event = createUtilDataAndReturnEventList()[0];
			
		Integer numberOfParticipants = 2;
		List<VDST_BatchRecord_gne__c> participants = new List<VDST_BatchRecord_gne__c>();
		for(Integer i = 0; i < numberOfParticipants; i++) {
			VDST_BatchRecord_gne__c participant = VDST_TestUtils.initiateValidBatchParticipant(event, 'GNE_123456789' + i);
			participant.IsAfterBatchProcessing_gne__c = true;
			participant.isValid__c = true;
			participants.add( participant );
		}
		insert participants;
		VDST_BatchRecord_gne__c eventWithParticipants = [SELECT ValidParticipants_gne__c, InvalidParticipants_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :event.Id LIMIT 1];
		System.assertEquals( numberOfParticipants, eventWithParticipants.ValidParticipants_gne__c );
		System.assertEquals( 0, eventWithParticipants.InvalidParticipants_gne__c );

		// WHEN
		for(VDST_BatchRecord_gne__c p : participants) {
			p.isValid__c = false;
		}
		update participants;

		// THEN
		eventWithParticipants = [SELECT ValidParticipants_gne__c, InvalidParticipants_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :event.Id LIMIT 1];
		System.assertEquals( 0, eventWithParticipants.ValidParticipants_gne__c );
		System.assertEquals( numberOfParticipants, eventWithParticipants.InvalidParticipants_gne__c );
	}

	/** @date 2/19/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create data for testing VDST_BatchEventSetParticipantsNumber trigger
	* @return VDST_BatchRecord_gne__c
	*/
	static List<VDST_BatchRecord_gne__c> createUtilDataAndReturnEventList() {
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();
		VDST_TestUtils.createMappings();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		return VDST_TestUtils.createBatchEvents(file, brands, user);
	}
	
}