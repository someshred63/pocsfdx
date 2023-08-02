/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Class for File Upload Controller
*/
@isTest
public class VDST_FileUploadController_Test {
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getting batch files, batch events and batch participants lists
	*/
	@isTest static void shouldGetBatchFilesEventAndParticipantsLists() {
		// GIVEN
		List<VDST_EventProvider_gne__c> providers = VDST_TestUtils.createEventProviders();
		VDST_EventProvider_gne__c geneProvider = providers[0];
		VDST_TestUtils.createVdstUser(geneProvider);

		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);

		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();

		// WHEN
		List<VDST_FileUpload_Utils.BatchFileWrapper> fileWrappers = fileUploadCtrl.batchFileWrappers;
		
		fileUploadCtrl.batchFileIdForRec = file.Id;
		List<VDST_FileUpload_Utils.BatchRecordWrapper> eventWrappers = fileUploadCtrl.batchRecordWrappers;

		VDST_BatchRecord_gne__c selectedEvent = events[0];
		fileUploadCtrl.batchRecEventIdForEdit = selectedEvent.Id;
		fileUploadCtrl.editEventBatchRec();
		List<VDST_FileUpload_Utils.BatchRecordWrapper> participantWrappers = fileUploadCtrl.eventEditWrap.participants;

		Boolean canAccessPage = fileUploadCtrl.canAccessPage;

		List<String> drugNames = new List<String>{ brands[0].Id, brands[1].Id };
		fileUploadCtrl.multiDrugNames = drugNames;
		fileUploadCtrl.selectBrands();

		fileUploadCtrl.multiDrugNames = null;
		fileUploadCtrl.goToSelectBrands();

		// THEN
		Integer numberOfCreatedFiles = 1;
		System.assertEquals( numberOfCreatedFiles, fileWrappers.size() );

		Integer numberOfCreatedEventsForSelectedFile = 2;
		System.assertEquals( numberOfCreatedEventsForSelectedFile, eventWrappers.size() );

		Integer numberOfCreatedParticipantsForSelectedEvent = 2;
		System.assertEquals( numberOfCreatedParticipantsForSelectedEvent, participantWrappers.size() );

		System.assert( canAccessPage );

		System.assertEquals( 'Avastin, Herceptin', fileUploadCtrl.eventEditWrap.sObj.Brands_gne__c );

		System.assertEquals( 2, fileUploadCtrl.multiDrugNames.size() );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for deleting files
	*/
	@isTest static void shouldDeleteFiles() {
		// GIVEN
		Integer numberOfCreatedFiles = 2;
		List<VDST_BatchFile_gne__c> files = VDST_TestUtils.createBatchFiles('MEDWRTG', numberOfCreatedFiles);
		List<Id> filesIds = new List<Id>{ files[0].Id, files[1].Id };
		for(VDST_BatchFile_gne__c bf : [ SELECT isDeleted_gne__c FROM VDST_BatchFile_gne__c WHERE Id IN :filesIds ] ) {
			Boolean fileIsNotDeleted = !bf.isDeleted_gne__c;
			System.assert(fileIsNotDeleted);
		}
		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();
		
		// WHEN
		fileUploadCtrl.deleteFileIds = files[0].Id + ',' + files[1].Id;
		fileUploadCtrl.deleteLoad();

		// THEN
		List<VDST_BatchFile_gne__c> deletedFiles = [ SELECT isDeleted_gne__c FROM VDST_BatchFile_gne__c WHERE Id IN :filesIds ];
		System.assertEquals( numberOfCreatedFiles, deletedFiles.size() );
		for(VDST_BatchFile_gne__c bf : deletedFiles ) {
			System.assert(bf.isDeleted_gne__c);
		}
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for validating Medical Editing Support batch event - event should be valid
	*/
	@isTest static void shouldAllEventFieldsBeValid() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();
		VDST_TestUtils.createMappings();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);

		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();
		fileUploadCtrl.batchFileIdForRec = file.Id;
		List<VDST_FileUpload_Utils.BatchRecordWrapper> eventWrappers = fileUploadCtrl.batchRecordWrappers;
		VDST_BatchRecord_gne__c selectedEvent = events[0];
		fileUploadCtrl.batchRecEventIdForEdit = selectedEvent.Id;
		fileUploadCtrl.editEventBatchRec();

		// WHEN
		fileUploadCtrl.revalildateEditEvent();
		VDST_FileUpload_Utils.EventValidationResult eventValidationResult = fileUploadCtrl.eventEditWrap.validResult;

		// THEN
		System.assert( eventValidationResult.isValid() );
		for( String errorCode : eventValidationResult.errMap.keySet() ) {
			System.assert( !eventValidationResult.isError( errorCode ) );
		}
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for validating Medical Editing Support batch event - event should be invalid
	*/
	@isTest static void shouldAllEventFieldsBeInvalid() {
		// GIVEN
		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		VDST_BatchRecord_gne__c invalidEvent = VDST_TestUtils.createInvalidBatchEvent(file);

		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();
		fileUploadCtrl.batchFileIdForRec = file.Id;
		List<VDST_FileUpload_Utils.BatchRecordWrapper> eventWrappers = fileUploadCtrl.batchRecordWrappers;
		fileUploadCtrl.batchRecEventIdForEdit = invalidEvent.Id;
		fileUploadCtrl.editEventBatchRec();

		// WHEN
		fileUploadCtrl.eventEditWrap.validate();
		VDST_FileUpload_Utils.EventValidationResult eventValidationResult = fileUploadCtrl.eventEditWrap.validResult;
		// THEN
		System.assert( !eventValidationResult.isValid() );

		// WHEN
		fileUploadCtrl.eventEditWrap.sObj.AccountablePartyID_gne__c = null;
		fileUploadCtrl.eventEditWrap.sObj.Brands_gne__c 			= null;
		fileUploadCtrl.eventEditWrap.sObj.EventStartDate_txt_gne__c = null;
		fileUploadCtrl.eventEditWrap.sObj.TOVAmount_txt_gne__c 		= null;
		fileUploadCtrl.eventEditWrap.validate();
		eventValidationResult = fileUploadCtrl.eventEditWrap.validResult;
		// THEN
		System.assert( !eventValidationResult.isValid() );

		// WHEN
		String exceededNumberOfBrands = '1,2,3,4,5,6';
		fileUploadCtrl.eventEditWrap.sObj.Brands_gne__c = exceededNumberOfBrands;
		fileUploadCtrl.eventEditWrap.validate();
		eventValidationResult = fileUploadCtrl.eventEditWrap.validResult;
		// THEN
		System.assert( !eventValidationResult.isValid() );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for validating Contracted Field Force batch event - event should be valid
	*/
	@isTest static void shouldAllCffEventFieldsBeValid() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();
		VDST_TestUtils.createMappings();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('CFF', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);

		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();
		fileUploadCtrl.batchFileIdForRec = file.Id;
		List<VDST_FileUpload_Utils.BatchRecordWrapper> eventWrappers = fileUploadCtrl.batchRecordWrappers;
		VDST_BatchRecord_gne__c selectedEvent = events[0];
		fileUploadCtrl.batchRecEventIdForEdit = selectedEvent.Id;
		fileUploadCtrl.editEventBatchRec();

		// WHEN
		fileUploadCtrl.eventEditWrap.validate();
		VDST_FileUpload_Utils.EventValidationResult eventValidationResult = fileUploadCtrl.eventEditWrap.validResult;

		// THEN
		System.assert( eventValidationResult.isValid() );
		for( String errorCode : eventValidationResult.errMap.keySet() ) {
			System.assert( !eventValidationResult.isError( errorCode ) );
		}
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for validating Contracted Field Force batch event - event should be invalid
	*/
	@isTest static void shouldAllCffEventFieldsBeInvalid() {
		// GIVEN
		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('CFF', 1)[0];
		VDST_BatchRecord_gne__c invalidEvent = VDST_TestUtils.createInvalidBatchEvent(file);

		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();
		fileUploadCtrl.batchFileIdForRec = file.Id;
		List<VDST_FileUpload_Utils.BatchRecordWrapper> eventWrappers = fileUploadCtrl.batchRecordWrappers;
		fileUploadCtrl.batchRecEventIdForEdit = invalidEvent.Id;
		fileUploadCtrl.editEventBatchRec();

		// WHEN
		fileUploadCtrl.eventEditWrap.sObj.VenueName_gne__c 				= null;
		fileUploadCtrl.eventEditWrap.sObj.VenueCountry_gne__c 			= null;
		fileUploadCtrl.eventEditWrap.sObj.VenueStreetAddress_gne__c 	= null;
		fileUploadCtrl.eventEditWrap.sObj.VenueCity_gne__c 				= null;
		fileUploadCtrl.eventEditWrap.sObj.VenueState_gne__c 			= null;
		fileUploadCtrl.eventEditWrap.sObj.VenuePostalCode_gne__c 		= null;
		fileUploadCtrl.eventEditWrap.sObj.TotPlanAttCntUser_txt_gne__c 	= null;
		fileUploadCtrl.eventEditWrap.validate();
		VDST_FileUpload_Utils.EventValidationResult eventValidationResult = fileUploadCtrl.eventEditWrap.validResult;
		// THEN
		System.assert( !eventValidationResult.isValid() );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for validating batch participant - participant should be valid
	*/
	@isTest static void shouldAllParticipantFieldsBeValid() {
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

		VDST_BatchRecord_gne__c selectedEvent = events[0];
		fileUploadCtrl.batchRecEventIdForEdit = selectedEvent.Id;
		fileUploadCtrl.editEventBatchRec();
		List<VDST_FileUpload_Utils.BatchRecordWrapper> participantWrappers = fileUploadCtrl.eventEditWrap.participants;

		VDST_BatchRecord_gne__c selectedParticipant = participants[0];
		fileUploadCtrl.batchRecParticipantIdForEdit = selectedParticipant.Id;
		fileUploadCtrl.editParticipantBatchRec();
		
		// WHEN
		fileUploadCtrl.revalildateParticipantEvent();
		VDST_FileUpload_Utils.ParticipantValidationResult participantValidationResult = fileUploadCtrl.participantEditWrap.validResult;

		// THEN
		for( String errorCode : participantValidationResult.errMap.keySet() ) {
			System.assertEquals( errorCode, errorCode + participantValidationResult.errMap.get( errorCode ) );
			System.assert( !participantValidationResult.isError( errorCode ) );
		}
		System.assert( participantValidationResult.isValid() );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for validating batch participant - participant should be invalid
	*/
	@isTest static void shouldAllParticipantFieldsBeInvalid() {
		// GIVEN
		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		VDST_BatchRecord_gne__c event = VDST_TestUtils.createInvalidBatchEvent(file);
		VDST_BatchRecord_gne__c invalidParticipant = VDST_TestUtils.createInvalidBatchParticipant(event);

		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();

		List<VDST_FileUpload_Utils.BatchFileWrapper> fileWrappers = fileUploadCtrl.batchFileWrappers;
		
		fileUploadCtrl.batchFileIdForRec = file.Id;
		List<VDST_FileUpload_Utils.BatchRecordWrapper> eventWrappers = fileUploadCtrl.batchRecordWrappers;

		fileUploadCtrl.batchRecEventIdForEdit = event.Id;
		fileUploadCtrl.editEventBatchRec();
		List<VDST_FileUpload_Utils.BatchRecordWrapper> participantWrappers = fileUploadCtrl.eventEditWrap.participants;

		fileUploadCtrl.batchRecParticipantIdForEdit = invalidParticipant.Id;
		fileUploadCtrl.editParticipantBatchRec();
		
		// WHEN
		fileUploadCtrl.participantEditWrap.validate();
		VDST_FileUpload_Utils.ParticipantValidationResult participantValidationResult = fileUploadCtrl.participantEditWrap.validResult;
		// THEN
		System.assert( !participantValidationResult.isValid() );

		// WHEN
		fileUploadCtrl.participantEditWrap.sObj.ParticipantRole_gne__c 		= null;
		fileUploadCtrl.participantEditWrap.sObj.Profession_gne__c 			= null;
		fileUploadCtrl.participantEditWrap.sObj.Credential_gne__c 			= null;
		fileUploadCtrl.participantEditWrap.sObj.StateLicenseNumber_gne__c 	= 'Invalid';
		fileUploadCtrl.participantEditWrap.sObj.LicenseState_gne__c 		= 'Invalid';
		fileUploadCtrl.participantEditWrap.sObj.Quantity_txt_gne__c 		= '1234';
		fileUploadCtrl.participantEditWrap.validate();
		participantValidationResult = fileUploadCtrl.participantEditWrap.validResult;
		// THEN
		System.assert( !participantValidationResult.isValid() );

		// WHEN
		fileUploadCtrl.participantEditWrap.sObj.ParticipantRole_gne__c 			= 'OtherThanVendor';
		fileUploadCtrl.participantEditWrap.sObj.ParticipantCountry_gne__c 		= null;
		fileUploadCtrl.participantEditWrap.sObj.ParticipantState_gne__c 		= null;
		fileUploadCtrl.participantEditWrap.sObj.ParticipantPostalCode_gne__c 	= 'Invalid';
		fileUploadCtrl.participantEditWrap.validate();
		participantValidationResult = fileUploadCtrl.participantEditWrap.validResult;
		// THEN
		System.assert( !participantValidationResult.isValid() );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for edit batch event - event should be edited successfully
	*/
	@isTest static void shouldEditEventSuccessfully() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();
		VDST_TestUtils.createMappings();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);

		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();
		fileUploadCtrl.batchFileIdForRec = file.Id;
		List<VDST_FileUpload_Utils.BatchRecordWrapper> eventWrappers = fileUploadCtrl.batchRecordWrappers;
		VDST_BatchRecord_gne__c selectedEvent = events[0];
		fileUploadCtrl.batchRecEventIdForEdit = selectedEvent.Id;
		fileUploadCtrl.editEventBatchRec();

		// WHEN
		String newFirstName = 'Edited First Name';
		String newLastName = 'Edited Last Name';
		fileUploadCtrl.eventEditWrap.sObj.FirstName_gne__c = newFirstName;
		fileUploadCtrl.eventEditWrap.sObj.LastName_gne__c = newLastName;
		VDST_FileUpload_Utils.SaveResult  saveResult = fileUploadCtrl.eventEditWrap.save();

		// THEN
		System.assert( saveResult.isSuccess );
		VDST_BatchRecord_gne__c updatedEvent = [ SELECT FirstName_gne__c, LastName_gne__c 
			FROM VDST_BatchRecord_gne__c WHERE Id = :fileUploadCtrl.eventEditWrap.sObj.Id ];
		System.assertEquals( newFirstName, updatedEvent.FirstName_gne__c );
		System.assertEquals( newLastName, updatedEvent.LastName_gne__c );

	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for edit batch participant - participant should be edited successfully
	*/
	@isTest static void shouldEditParticipantSuccessfully() {
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

		VDST_BatchRecord_gne__c selectedEvent = events[0];
		fileUploadCtrl.batchRecEventIdForEdit = selectedEvent.Id;
		fileUploadCtrl.editEventBatchRec();
		List<VDST_FileUpload_Utils.BatchRecordWrapper> participantWrappers = fileUploadCtrl.eventEditWrap.participants;

		VDST_BatchRecord_gne__c selectedParticipant = participants[0];
		fileUploadCtrl.batchRecParticipantIdForEdit = selectedParticipant.Id;
		fileUploadCtrl.editParticipantBatchRec();

		// WHEN
		String newFirstName = 'Edited First Name';
		String newLastName = 'Edited Last Name';
		fileUploadCtrl.participantEditWrap.sObj.FirstName_gne__c = newFirstName;
		fileUploadCtrl.participantEditWrap.sObj.LastName_gne__c = newLastName;
		VDST_FileUpload_Utils.SaveResult  saveResult = fileUploadCtrl.participantEditWrap.save();

		// THEN
		System.assert( saveResult.isSuccess );
		VDST_BatchRecord_gne__c updatedParticipant = [ SELECT FirstName_gne__c, LastName_gne__c 
			FROM VDST_BatchRecord_gne__c WHERE Id = :fileUploadCtrl.participantEditWrap.sObj.Id ];
		System.assertEquals( newFirstName, updatedParticipant.FirstName_gne__c );
		System.assertEquals( newLastName, updatedParticipant.LastName_gne__c );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Testing save batch - finally it should be stored
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
			fileUploadCtrl.saveEvent();
			for(VDST_FileUpload_Utils.BatchRecordWrapper p : fileUploadCtrl.eventEditWrap.participants) {
				fileUploadCtrl.batchRecParticipantIdForEdit = p.batchRecSObj.Id;
				fileUploadCtrl.editParticipantBatchRec();
				fileUploadCtrl.saveParticipant();
			}
		}
		
		// WHEN
		fileUploadCtrl.saveBatch();

		// THEN
		VDST_BatchFile_gne__c savedFile = [ SELECT Status_gne__c FROM VDST_BatchFile_gne__c WHERE Id = :file.Id LIMIT 1 ];
		System.assertEquals( 'Stored', savedFile.Status_gne__c );

		Integer numberOfCreatedEvents = [ SELECT Id FROM VDST_Event_gne__c ].size();
		Integer numberOfCreatedParticipants = [ SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c ].size();
		System.assertEquals( events.size(), numberOfCreatedEvents );
		System.assertEquals( participants.size(), numberOfCreatedParticipants );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Testing save batch - finally it should be stored
	*/
	@isTest static void shouldGetTimeZoneOffsetMilisecs() {
		// GIVEN
		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();

		// WHEN
		String timeZoneOffsetMilisecs = fileUploadCtrl.timeZoneOffsetMilisecs;

		// THEN
		System.assert( String.isNotBlank( timeZoneOffsetMilisecs ) );
		Boolean isInteger = true;
		try{
			Integer i = Integer.valueOf(timeZoneOffsetMilisecs);
		} catch(Exception e) {
			isInteger = false;
		}
		System.assert(isInteger);
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Testing apex page parameters - null parameters should be invalid 
	*/
	@isTest static void shouldApexPageParameterIdsBeNull() {
		// GIVEN
		// WHEN
		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();

		// THEN
		System.assert( !fileUploadCtrl.isBatchFileIdParamValid );
		System.assert( !fileUploadCtrl.isBatchParticipantIdParamValid );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Testing apex page parameters - wrong ids parameters should be invalid 
	*/
	@isTest static void shouldApexPageParameterIdsBeWrongObjectType() {
		// GIVEN
		All_User_Hierarchy_gne__c wrongObject = VDST_TestUtils.createUser();
		ApexPages.currentPage().getParameters().put( 'id', wrongObject.Id );
		ApexPages.currentPage().getParameters().put( 'participantId', wrongObject.Id );

		// WHEN
		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();

		// THEN
		System.assert( !fileUploadCtrl.isBatchFileIdParamValid );
		System.assert( !fileUploadCtrl.isBatchParticipantIdParamValid );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Testing apex page parameters - non-existing ids parameters should be invalid 
	*/
	@isTest static void shouldApexPageParameterIdsBeNonExisting() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);
		
		ApexPages.currentPage().getParameters().put( 'id', file.Id );
		ApexPages.currentPage().getParameters().put( 'participantId', participants[0].Id );

		delete file;

		// WHEN
		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();

		// THEN
		System.assert( !fileUploadCtrl.isBatchFileIdParamValid );
		System.assert( !fileUploadCtrl.isBatchParticipantIdParamValid );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Testing apex page parameters - parameters should be valid 
	*/
	@isTest static void shouldApexPageParameterIdsBeValid() {
		// GIVEN
		All_User_Hierarchy_gne__c user = VDST_TestUtils.createUser();
		List<Product_vod__c> brands = VDST_TestUtils.createBrands();
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = VDST_TestUtils.createParticipantRoles();

		VDST_BatchFile_gne__c file = VDST_TestUtils.createBatchFiles('MEDWRTG', 1)[0];
		List<VDST_BatchRecord_gne__c> events = VDST_TestUtils.createBatchEvents(file, brands, user);
		List<VDST_BatchRecord_gne__c> participants = VDST_TestUtils.createBatchParticipants(events);
		
		ApexPages.currentPage().getParameters().put( 'id', file.Id );
		ApexPages.currentPage().getParameters().put( 'participantId', participants[0].Id );

		// WHEN
		VDST_FileUploadController fileUploadCtrl = new VDST_FileUploadController();

		// THEN
		System.assert( fileUploadCtrl.isBatchFileIdParamValid );
		System.assert( fileUploadCtrl.isBatchParticipantIdParamValid );
	}
}