/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Class for Save Batch
*/
@isTest
private class VDST_FileUploadSaveBatch_Test {
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for save batch file
	*/
	@isTest static void shouldSaveBatchFileSuccessfully() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();
		VDST_TestUtils.createMappings();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);

		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();

		List<VDST_FileUpload_Utils.BatchFileWrapper> fileWrappers = fileUploadCtrl.batchFileWrappers;
		
		fileUploadCtrl.batchFileIdForRec = file.Id;
		List<VDST_FileUpload_Utils.BatchRecordWrapper> eventWrappers = fileUploadCtrl.batchRecordWrappers;
		
		for(VDST_BatchRecord_gne__c e : events) {
			fileUploadCtrl.batchRecEventIdForEdit = e.Id;
			fileUploadCtrl.editEventBatchRec();
			fileUploadCtrl.eventEditWrap.save();
			for(VDST_FileUpload_Utils.BatchRecordWrapper p : fileUploadCtrl.eventEditWrap.participants) {
				fileUploadCtrl.batchRecParticipantIdForEdit = p.batchRecSObj.Id;
				fileUploadCtrl.editParticipantBatchRec();
				fileUploadCtrl.participantEditWrap.save();
			}
		}
		
		update new VDST_BatchFile_gne__c(
            Id 						= file.Id,
            Status_gne__c 			= 'To process',
	        ProcessStartDate_gne__c = null,
	        ProcessEndDate_gne__c 	= null
        );

		VDST_FileUploadSaveBatch saveBatch = new VDST_FileUploadSaveBatch();

		// WHEN
		Test.startTest();
		Database.executeBatch(saveBatch, 200);
		Test.stopTest();

		// THEN
		VDST_BatchFile_gne__c savedFile = [ SELECT Status_gne__c FROM VDST_BatchFile_gne__c WHERE Id = :file.Id LIMIT 1 ];
		System.assertEquals( 'Stored', savedFile.Status_gne__c );

		Integer numberOfCreatedEvents = [ SELECT Id FROM VDST_Event_gne__c ].size();
		Integer numberOfCreatedParticipants = [ SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c ].size();
		System.assertEquals( events.size(), numberOfCreatedEvents );
		System.assertEquals( participants.size(), numberOfCreatedParticipants );
	}
	
	/** @date 2/24/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for fail save batch file due to duplicate event id
	*/
	@isTest static void shouldFailSaveBatchFileDueToDuplicateEventId() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();
		VDST_TestUtils.createMappings();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);

		for(VDST_BatchRecord_gne__c e : events) {
			e.EventId_gne__c = 'sameEventId';
		}
		update events;

		insert new VDST_Event_gne__c( 
			VendorEventID_gne__c 	= 'sameEventId',
			EventStartDate_gne__c 	= Date.today().addDays(-2), 
			EventEndDate_gne__c 	= Date.today()
		);

		update new VDST_BatchFile_gne__c(
            Id 						= file.Id,
            Status_gne__c 			= 'To process',
	        ProcessStartDate_gne__c = null,
	        ProcessEndDate_gne__c 	= null
        );

		VDST_FileUploadSaveBatch saveBatch = new VDST_FileUploadSaveBatch();

		// WHEN
		Test.startTest();
		Database.executeBatch(saveBatch, 200);
		Test.stopTest();

		// THEN
		VDST_BatchFile_gne__c notSavedFile = [ SELECT Status_gne__c FROM VDST_BatchFile_gne__c WHERE Id = :file.Id LIMIT 1 ];
		System.assertEquals( 'To process', notSavedFile.Status_gne__c );
	}

	/** @date 2/24/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for fail save batch file due to duplicate participant id
	*/
	@isTest static void shouldFailSaveBatchFileDueToDuplicateParticipantId() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();
		VDST_TestUtils.createMappings();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);

		for(VDST_BatchRecord_gne__c p : participants) {
			p.ParticipantID_gne__c = 'sameParticipantId';
		}
		update participants;

		update new VDST_BatchFile_gne__c(
            Id 						= file.Id,
            Status_gne__c 			= 'To process',
	        ProcessStartDate_gne__c = null,
	        ProcessEndDate_gne__c 	= null
        );

		VDST_FileUploadSaveBatch saveBatch = new VDST_FileUploadSaveBatch();

		// WHEN
		Test.startTest();
		Database.executeBatch(saveBatch, 200);
		Test.stopTest();

		// THEN
		VDST_BatchFile_gne__c notSavedFile = [ SELECT Status_gne__c FROM VDST_BatchFile_gne__c WHERE Id = :file.Id LIMIT 1 ];
		System.assertEquals( 'To process', notSavedFile.Status_gne__c );
	}
}