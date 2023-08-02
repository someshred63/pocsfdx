/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Class for inserting batch records by webservice
*/
@isTest
private class VDST_InsertBatchRecords_REST_Test {
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for processing small batch
	*/
	@isTest static void shouldInsertSmallBatch() {
		Boolean isBigBatch = false;
		insertBatch( isBigBatch );
		checkEventParentAssignationForParticipants();
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method for shouldInsertSmallBatch Test Method
	*/
	static void checkEventParentAssignationForParticipants() {
		Map<String, Id> eventVendorIdToEventIdMap = new Map<String, Id>();
		for(VDST_BatchRecord_gne__c event : [ SELECT Id, EventId_gne__c FROM VDST_BatchRecord_gne__c WHERE isEvent_gne__c = true ]) {
			eventVendorIdToEventIdMap.put( event.EventId_gne__c, event.Id );
		}
		for(VDST_BatchRecord_gne__c participant : [ SELECT VDST_ParentEvent_gne__c, EventId_gne__c FROM VDST_BatchRecord_gne__c WHERE isEvent_gne__c = false ]) {
			String expectedAssignatedParentEventId = eventVendorIdToEventIdMap.get( participant.EventId_gne__c );
			String assignatedParentEventId = participant.VDST_ParentEvent_gne__c;
			System.assertEquals( expectedAssignatedParentEventId, assignatedParentEventId );
		}
	}
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for processing big batch
	*/
	@isTest static void shouldInsertBigBatch() {
		Boolean isBigBatch = true;
		insertBatch( isBigBatch );
	}
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method for VDST_InsertBatchRecords_REST_Test class Test Methods
	* @param Boolean isBigBatch
	*/
	public static void insertBatch(Boolean isBigBatch) {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];

		// WHEN
		List<VDST_BatchRecord_gne__c> batchRecords = new List<VDST_BatchRecord_gne__c>();
		for(Integer i = 0; i < file.BatchRecords_gne__c; i++) {
			VDST_BatchRecord_gne__c event = VDST_TestUtils.initiateValidBatchEvent(file, brands, user, 'GNE_TestEventId_' + i);
			VDST_BatchRecord_gne__c participant = VDST_TestUtils.initiateValidBatchParticipant( event, 'GNE_' + System.now().getTime() + '_0000' + i );
			participant.VDST_ParentEvent_gne__c = null;
			batchRecords.add( event );
			batchRecords.add( participant );
		}

		// THEN
		VDST_InsertBatchRecords_REST.Result result = VDST_InsertBatchRecords_REST.processRequest( batchRecords,  isBigBatch );
		System.assert( result.success );

		Integer expectedNumberOfCreatedEvents = 2;
		Integer expectedNumberOfCreatedParticipants = 2;
		Integer numberOfCreatedEvents = [ SELECT Id FROM VDST_BatchRecord_gne__c WHERE isEvent_gne__c = true ].size();
		Integer numberOfCreatedParticipants = [ SELECT Id FROM VDST_BatchRecord_gne__c WHERE isEvent_gne__c = false ].size();
	}
}