/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Class with methods for creating test objects
*/
@isTest
public class VDST_TestUtils {
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create batch files
	* @param String eventType
	* @param Integer numberOfFiles
    * @return List<VDST_BatchFile_gne__c>
	*/
	public static List<VDST_BatchFile_gne__c> createBatchFiles(String eventType, Integer numberOfFiles) {
		List<VDST_BatchFile_gne__c> batchFiles = new List<VDST_BatchFile_gne__c>();

		for(Integer i = 0; i < numberOfFiles; i++) {
			batchFiles.add(
				new VDST_BatchFile_gne__c(
					Filename_gne__c 		= 'test file name',
					BatchRecords_gne__c 	= 2,
					EventType_gne__c 		= eventType,
					ProcessStartDate_gne__c = System.now(),
					ProcessEndDate_gne__c 	= System.now(),
					isFullyUploaded_gne__c 	= true
				)
			);
		}
		insert batchFiles;
		checkIfIdExistsAfterInsert( batchFiles );
		return batchFiles;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create batch events
	* @param VDST_BatchFile_gne__c batchFile
	* @param List<Product_vod__c> brands
	* @param All_User_Hierarchy_gne__c user
	* @return List<VDST_BatchRecord_gne__c>
	*/
	public static List<VDST_BatchRecord_gne__c> createBatchEvents(VDST_BatchFile_gne__c batchFile, List<Product_vod__c> brands, All_User_Hierarchy_gne__c user) {
		List<VDST_BatchRecord_gne__c> batchEvents = new List<VDST_BatchRecord_gne__c>();
		for(Integer i = 0; i < batchFile.BatchRecords_gne__c; i++) {
			batchEvents.add( initiateValidBatchEvent(batchFile, brands, user, 'GNE_TestEventId_' + i) );
		}
		insert batchEvents;

		Integer numberOfCreatedEvents = 2;
		System.assertEquals( numberOfCreatedEvents, batchEvents.size() );
		checkIfIdExistsAfterInsert( batchEvents );

		return batchEvents;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Initiate valid batch event
	* @param VDST_BatchFile_gne__c batchFile
	* @param List<Product_vod__c> brands
	* @param All_User_Hierarchy_gne__c user
	* @param String eventId
	* @return VDST_BatchRecord_gne__c
	*/
	public static VDST_BatchRecord_gne__c initiateValidBatchEvent(VDST_BatchFile_gne__c batchFile, List<Product_vod__c> brands, All_User_Hierarchy_gne__c user, String eventId) {
		VDST_BatchRecord_gne__c event = new VDST_BatchRecord_gne__c(
			isEvent_gne__c 					= true,
			VDST_BatchFile_gne__c 			= batchFile.Id,
			EventType_gne__c 				= batchFile.EventType_gne__c,
			EventId_gne__c 					= eventId,
			AccountablePartyID_gne__c 		= user.User_External_Id_gne__c,
			MeetingName_gne__c 				= 'test meeting name',
			Brands_gne__c 					= brands[0].Name + ', ' + brands[1].Name,
			EventStartDate_txt_gne__c 		= '01/24/2014',
			VenueType_txt_gne__c 			= 'Virtual',
			VenueName_gne__c 				= 'Doctor Office',
			VenueCountry_gne__c 			= 'USA',
			VenueStreetAddress_gne__c 		= '208 MACCORKLE AVE SE',
			VenueCity_gne__c 				= 'CHARLESTON',
			VenueState_gne__c 				= 'WV',
			VenuePostalCode_gne__c 			= '33308',
			TotPlanAttCntUser_txt_gne__c	= '1',
			TOVItemName_gne__c 				= 'test item name',
			TOVAmount_txt_gne__c 			= '10'
		);
		return event;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create invalid batch event
	* @param VDST_BatchFile_gne__c batchFile
	* @return VDST_BatchRecord_gne__c
	*/
	public static VDST_BatchRecord_gne__c createInvalidBatchEvent(VDST_BatchFile_gne__c batchFile) {
		VDST_BatchRecord_gne__c event = new VDST_BatchRecord_gne__c(
			isEvent_gne__c 					= true,
			VDST_BatchFile_gne__c 			= batchFile.Id,
			EventType_gne__c 				= batchFile.EventType_gne__c,
			EventId_gne__c 					= 'GNE_TestEventId_1',
			AccountablePartyID_gne__c 		= 'NonExistingAccPartyId',
			MeetingName_gne__c 				= null,
			Brands_gne__c 					= 'NonExistingBrandName',
			EventStartDate_txt_gne__c 		= 'WrongDate',
			VenueType_txt_gne__c 			= 'NonExistingVenueType',
			VenueName_gne__c 				= null,
			VenueCountry_gne__c 			= 'InvalidCountry',
			VenueStreetAddress_gne__c 		= null,
			VenueCity_gne__c 				= null,
			VenueState_gne__c 				= 'InvalidState',
			VenuePostalCode_gne__c 			= 'InvalidPostCode',
			TotPlanAttCntUser_txt_gne__c	= 'Inval',
			TOVItemName_gne__c 				= null,
			TOVAmount_txt_gne__c 			= 'InvalAmount'
		);
		insert event;
		checkIfIdExistsAfterInsert( event );
		return event;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create batch participants
	* @param List<VDST_BatchRecord_gne__c> batchEvents
	* @return List<VDST_BatchRecord_gne__c>
	*/
	public static List<VDST_BatchRecord_gne__c> createBatchParticipants(List<VDST_BatchRecord_gne__c> batchEvents) {
		Integer numberOfParticipantsForEvent = 2;
		List<VDST_BatchRecord_gne__c> batchParticipants = new List<VDST_BatchRecord_gne__c>();
		Integer idx = 0;
		for(VDST_BatchRecord_gne__c event : batchEvents) {
			for(Integer i = 0; i < numberOfParticipantsForEvent; i++) {
				batchParticipants.add( initiateValidBatchParticipant( event, 'GNE_' + System.now().getTime() + '_0000' + idx ) );
				idx++;
			}
		}
		insert batchParticipants;

		Integer numberOfAllCreatedParticipants = 4;
		System.assertEquals( numberOfAllCreatedParticipants, numberOfParticipantsForEvent * batchEvents.size() );
		checkIfIdExistsAfterInsert( batchParticipants );

		return batchParticipants;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Initiate valid batch participant
	* @param VDST_BatchRecord_gne__c event
	* @param String participantId
	* @return VDST_BatchRecord_gne__c
	*/
	public static VDST_BatchRecord_gne__c initiateValidBatchParticipant(VDST_BatchRecord_gne__c event, String participantId) {
		VDST_BatchRecord_gne__c participant = new VDST_BatchRecord_gne__c(
			ParticipantID_gne__c 			= participantId,
			isEvent_gne__c 					= false,
			VDST_BatchFile_gne__c 			= event.VDST_BatchFile_gne__c,
			EventType_gne__c 				= event.EventType_gne__c,
			EventId_gne__c 					= event.EventId_gne__c,
			VDST_ParentEvent_gne__c 		= event.Id,
			ParticipantRole_gne__c 			= 'ATND',
			LastName_gne__c					= 'Smith',
			FirstName_gne__c 				= 'Kevin',
			MiddleName_gne__c 				= 'John',
			Suffix_txt_gne__c 				= 'SR',
			Phone_gne__c 					= '123 456 789',
			Email_txt_gne__c 				= 'kevinsmith@gmail.com',
			Affiliation_gne__c 				= 'Joe\'s Clinic',
			Profession_gne__c 				= 'FCLTY',
			Credential_gne__c 				= 'MD',
			NPI_gne__c 						= '1548402886',
			Quantity_txt_gne__c 			= '1',
			ParticipantCountry_gne__c 		= 'USA',
			ParticipantStreetAddress_gne__c = '4077 5th Ave',
			ParticipantCity_gne__c 			= 'San Diego',
			ParticipantState_gne__c 		= 'California',
			ParticipantPostalCode_gne__c 	= '92103'
		);
		return participant;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create invalid batch participant
	* @param VDST_BatchRecord_gne__c event
	* @return VDST_BatchRecord_gne__c
	*/
	public static VDST_BatchRecord_gne__c createInvalidBatchParticipant(VDST_BatchRecord_gne__c event) {
		VDST_BatchRecord_gne__c batchParticipant = new VDST_BatchRecord_gne__c(
			ParticipantID_gne__c 			= 'GNE_' + System.now().getTime() + '_00000',
			isEvent_gne__c 					= false,
			VDST_BatchFile_gne__c 			= event.VDST_BatchFile_gne__c,
			EventType_gne__c 				= event.EventType_gne__c,
			EventId_gne__c 					= event.EventId_gne__c,
			VDST_ParentEvent_gne__c 		= event.Id,
			ParticipantRole_gne__c 			= 'InvalidRole',
			LastName_gne__c					= null,
			FirstName_gne__c 				= null,
			MiddleName_gne__c 				= null,
			Suffix_txt_gne__c 				= 'InvSuff',
			Phone_gne__c 					= '123 456 789',
			Email_txt_gne__c 				= 'InvalidEmail',
			Affiliation_gne__c 				= null,
			Profession_gne__c 				= 'InvProff',
			Credential_gne__c 				= 'InvCred',
			NPI_gne__c 						= 'InvNPI',
			Quantity_txt_gne__c 			= 'InvQ',
			ParticipantCountry_gne__c 		= 'InvalidCountry',
			ParticipantStreetAddress_gne__c = null,
			ParticipantCity_gne__c 			= null,
			ParticipantState_gne__c 		= 'InvalidState',
			ParticipantPostalCode_gne__c 	= 'InvalidPostCode'
		);
		insert batchParticipant;
		checkIfIdExistsAfterInsert( batchParticipant );
		return batchParticipant;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create all hierarchy user
	* @return All_User_Hierarchy_gne__c
	*/
	public static All_User_Hierarchy_gne__c createUser() {
		return createUser('John', 'Brown', '00001');
	}

	/** @date 2/21/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create all hierarchy user
	* @param String firstName
	* @param String lastName
	* @param String persistentId
	* @return All_User_Hierarchy_gne__c
	*/
	public static All_User_Hierarchy_gne__c createUser(String firstName, String lastName, String persistentId) {
		All_User_Hierarchy_gne__c user 	= new All_User_Hierarchy_gne__c(
			Name 						= firstName + ' ' + lastName,
			Active_gne__c 				= true,
			Email_Id__c 				= firstName.toLowerCase() + lastName.toLowerCase() + '@gmail.com',
			FirstName_gne__c 			= firstName,
			LastName_gne__c 			= lastName,
			Persistent_Id_gne__c 		= persistentId,
			User_External_Id_gne__c 	= lastName.toLowerCase() + firstName.toLowerCase().substring(0, 1)
		);
		insert user;
		checkIfIdExistsAfterInsert( user );
		return user;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create brands
	* @return List<Product_vod__c>
	*/
	public static List<Product_vod__c> createBrands() {
		List<Product_vod__c> brands = new List<Product_vod__c>{
			new Product_vod__c(
				Name 				= 'Avastin',
				Brand_Code_gne__c 	= 'AVASTIN'
			),
			new Product_vod__c(
				Name 				= 'Herceptin',
				Brand_Code_gne__c 	= 'HERCEPTIN'
			),
			new Product_vod__c(
				Name 				= 'Lucentis',
				Brand_Code_gne__c 	= 'LUCENTIS'
			)
		};
		for(Product_vod__c b : brands) {
			b.Product_Type_vod__c 					= 'Detail';
			b.Detail_Product_Subtype_Code_gne__c 	= 'Brand';
		}
		insert brands;

		Integer numberOfCreatedBrands = 3;
		System.assertEquals( numberOfCreatedBrands, brands.size() );
		checkIfIdExistsAfterInsert( brands );

		return brands;
	}
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create participant roles
	* @return List<VDST_EventPrtcpntRole_gne__c>
	*/
	public static List<VDST_EventPrtcpntRole_gne__c> createParticipantRoles() {
		List<VDST_EventPrtcpntRole_gne__c> participantRoles = new List<VDST_EventPrtcpntRole_gne__c>{
			new VDST_EventPrtcpntRole_gne__c(
				EventType_gne__c 				= 'CFF',
				EventParticipantRoleCode_gne__c = 'ATND',
				EventParticipantRoleName__c		= 'Attendee'
			),
			new VDST_EventPrtcpntRole_gne__c(
				EventType_gne__c 				= 'CFF',
				EventParticipantRoleCode_gne__c = 'VNDSTAFF',
				EventParticipantRoleName__c		= 'Vendor Staff'
			),
			new VDST_EventPrtcpntRole_gne__c(
				EventType_gne__c 				= 'MEDWRTG',
				EventParticipantRoleCode_gne__c = 'ATND',
				EventParticipantRoleName__c		= 'Attendee'
			)
		};
		insert participantRoles;

		Integer numberOfCreatedParticipantRoles = 3;
		System.assertEquals( numberOfCreatedParticipantRoles, participantRoles.size() );
		checkIfIdExistsAfterInsert( participantRoles );

		return participantRoles;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create country mapping
	*/
	public static void createMappings() {
		VDST_Mapping_gne__c mapping = new VDST_Mapping_gne__c(
			Name = 'USA',
			LabelValue_gne__c = 'USA'
		);
		insert mapping;
		checkIfIdExistsAfterInsert( mapping );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method for validating existence of sObject
	* @param sObject obj
	*/
	public static void checkIfIdExistsAfterInsert(sObject obj) {
		System.assertNotEquals( null, obj.Id );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method for validating existence of list of sObjects
	* @param List<sObject> objs
	*/
	public static void checkIfIdExistsAfterInsert(List<sObject> objs) {
		for(sObject obj : objs) {
			System.assertNotEquals( null, obj.Id );
		}
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create user
	* @param String profileName
	* @return User
	*/
	public static User createUser(String profileName) {
		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User u = new User(
        	FirstName 			= 'AGGS',
        	Alias 				= 'gssptest', 
        	Email 				= 'gssptestuser@gene.com',
            EmailEncodingKey 	= 'UTF-8', 
            LastName 			= 'Case Monitor', 
            LanguageLocaleKey 	= 'en_US',
            LocaleSidKey 		= 'en_US', 
            ProfileId 			= p.Id, 
            TimeZoneSidKey 		= 'America/Los_Angeles', 
            Username 			= 'gssptestuser@gene.com'
        );
       	return u;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create event providers
	* @return List<VDST_EventProvider_gne__c>
	*/
	public static List<VDST_EventProvider_gne__c> createEventProviders() {
		List<VDST_EventProvider_gne__c> providers = new List<VDST_EventProvider_gne__c>{
			new VDST_EventProvider_gne__c(
				VendorCode_gne__c 			= 'GNE',
				VendorName_gne__c 			= 'Genentech',
				EventTypeProvideCode_gne__c = 'AdBoard'
			),
			new VDST_EventProvider_gne__c(
				VendorCode_gne__c 			= 'CDNT',
				VendorName_gne__c 			= 'Cadent',
				EventTypeProvideCode_gne__c = 'AdBoard'
			)
		};
		insert providers;
		checkIfIdExistsAfterInsert( providers );
		System.assertEquals( 'GNE', providers[0].VendorCode_gne__c );
		System.assertEquals( 'CDNT', providers[1].VendorCode_gne__c );
		return providers;
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create VDST user
	* @param VDST_EventProvider_gne__c provider
	* @return VDST_User_gne__c
	*/
	public static VDST_User_gne__c createVdstUser(VDST_EventProvider_gne__c provider) {
		VDST_User_gne__c user = new VDST_User_gne__c(
			Role_gne__c 			= 'Provisioner',
			User_gne__c 			= UserInfo.getUserId(),
			VDST_Event_Provider__c 	= provider.Id
		);
		insert user;
		checkIfIdExistsAfterInsert( user );
		return user;
	}

	/** @date 2/12/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create VDST setting
	* @return VDST_Settings__c
	*/
	public static VDST_Settings__c createVdstSetting() {
		VDST_Settings__c setting = new VDST_Settings__c(
			Name 				= VDST_Utils.getEnvName(),
			Admin_Username__c 	= 'marra@gene.com',
			SIMS_Endpoint__c 	= 'https://extsimsit.gene.com/idm/ext/mvc/ext/users',
			SIMS_Password__c 	= 'W0nP@sC#',
			SIMS_Username__c 	= 'ctx_rest_user@yopmail.com',
			SSO_Domain__c 		= 'https://gene.force.com',
			Site_Domain__c 		= 'genentech.my.salesforce.com',
			Username_Postfix__c = '@gene.com'
		);
		insert setting;
		checkIfIdExistsAfterInsert( setting );
		return setting;
	}

	/** @date 2/14/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create VDST events
	* @param String eventType
	* @param String status
	* @param VDST_EventProvider_gne__c provider
	* @return List<VDST_Event_gne__c>
	*/
	public static List<VDST_Event_gne__c> createVdstEvents(String eventType, String status, VDST_EventProvider_gne__c provider) {
		Integer numberOfEvents = 2;
		List<VDST_Event_gne__c> evnts = new List<VDST_Event_gne__c>();
		for(Integer i = 0; i < numberOfEvents; i++) {
			evnts.add( 
				new VDST_Event_gne__c(
					CurrentStatus_gne__c		= status, 
		            CurrentStatusDate_gne__c 	= Date.today(), 
		            EventType_gne__c 			= eventType, 
		            EventStartDate_gne__c 		= Date.today(), 
		            EventEndDate_gne__c 		= Date.today(), 
		            ContentVendor_gne__c 		= provider.Id, 
		            LogisticVendor_gne__c 		= provider.Id
		        )
			);
        }
        insert evnts;
        checkIfIdExistsAfterInsert( evnts );
        return evnts;
	}

	/** @date 2/14/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create VDST addresses
	* @param List<VDST_Event_gne__c> events
	* @return List<VDST_Address_gne__c>
	*/
	public static List<VDST_Address_gne__c> createVdstAddresses(List<VDST_Event_gne__c> events) {
		List<VDST_Address_gne__c> addrs = new List<VDST_Address_gne__c>();
		for(VDST_Event_gne__c ev : events) {
			addrs.add(
				new VDST_Address_gne__c(
					VDST_Event_gne__c 	= ev.Id, 
					City_gne__c 		= 'Lublin'
				)
			);
		}
		insert addrs;
		checkIfIdExistsAfterInsert( addrs );
		return addrs;
	}

	/** @date 2/14/2014
	* @Author Konrad Malinowski
	* @description Util Method - Initiate VDST site
	* @param VDST_Event_gne__c event
	* @param VDST_Address_gne__c address
	* @return VDST_EventSite_gne__c
	*/ 
	public static VDST_EventSite_gne__c initiateVdstSite(VDST_Event_gne__c event, VDST_Address_gne__c address) {
		VDST_EventSite_gne__c site = new VDST_EventSite_gne__c(
			VDST_Event_gne__c 	= event.Id,
			VDST_Address_gne__c = address.Id
		);
		return site;
	}

	/** @date 2/17/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create VDST filter
	* @return VDST_Filter_gne__c
	*/
	public static VDST_Filter_gne__c createFilter() {
		VDST_Filter_gne__c filter = new VDST_Filter_gne__c(
			FilterName_gne__c 	= 'Test Filter',
			FilterOwner_gne__c 	= UserInfo.getUserId(),
			SortBy_gne__c 		= 'EventType_gne',
			SortOrder_gne__c	= 'ASC'
		);
		insert filter;
		checkIfIdExistsAfterInsert( filter );
		return filter;
	}

	/** @date 2/17/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create VDST filter data
	* @return List<VDST_FilterData_gne__c>
	*/
	public static List<VDST_FilterData_gne__c> createFilterData(Id filterId) {
		List<VDST_FilterData_gne__c> filterData = new List<VDST_FilterData_gne__c>();
		List<String> filterNames = new List<String>{ 'LogisticVendorCode_gne', 'VendorEventID_gne', 'LastModifiedDate',
			'LastModifiedByName', 'EventType_gne', 'EventMeetingName_gne', 'EventSiteName_gne', 'CurrentStatus_gne',
			'EventStartDate_gne', 'MasterDate_gne', 'TransactionDate_gne', 'CreatedDate' };
		for(String name : filterNames) {
			filterData.add(
				new VDST_FilterData_gne__c(
					VDST_Filter_gne__c = filterId,
					FilterField_gne__c = name,
					FilterValue_gne__c = (name == 'LastModifiedByName' ? UserInfo.getName() : '' )
				)
			);
		}
		insert filterData;
		checkIfIdExistsAfterInsert( filterData );
		return filterData;
	}

	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Spend Expense Transaction
	* @param String transId
	* @param String rschPaymentTypeCode
	* @param Boolean ifCreateUser
	* @return AGS_Spend_Expense_Transaction_gne__c
	*/
	public static AGS_Spend_Expense_Transaction_gne__c createSpendExpenseTrans(String transId, String rschPaymentTypeCode, Boolean ifCreateUser) {
		AGS_Spend_Expense_Transaction_gne__c t = new AGS_Spend_Expense_Transaction_gne__c(
			Source_Transaction_ID_gne__c 	= transId,
			Report_Code_gne__c 				= 'XC_MON',
			LogicalDeleteFlag_gne__c		= false,
			Research_Pymt_Typ_Cd_gne__c 	= rschPaymentTypeCode,
			Spend_User_Unix_ID_gne__c 		= (ifCreateUser ? createUser().User_External_Id_gne__c : null),
			Event_Date_gne__c 				= Date.today()
		);
		insert t;
		checkIfIdExistsAfterInsert( t );
		createExpenseProductsInteraction( t.Id );
		return t;
	}

	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Spend Expense Transaction
	* @param String transId
	* @param String rschPaymentTypeCode
	* @return AGS_Spend_Expense_Transaction_gne__c
	*/
	public static AGS_Spend_Expense_Transaction_gne__c createSpendExpenseTrans(String transId, String rschPaymentTypeCode) {
		return createSpendExpenseTrans(transId, rschPaymentTypeCode, true);
	}

	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Spend Recipient
	* @return AGS_CCO_Case_Recipient_gne__c
	*/
	public static AGS_CCO_Case_Recipient_gne__c createSpendRecipient() {
		AGS_CCO_Case_Recipient_gne__c  r = new AGS_CCO_Case_Recipient_gne__c(
			First_Name_gne__c 	= 'FirstName',
			Last_Name_gne__c 	= 'LastName',
			Tax_Id_gne__c 		= '123456789'
		);
		insert r;
		checkIfIdExistsAfterInsert( r );
		return r;
	}

	/** @date 2/20/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Expense Products Interaction
	* @param Id spendExpenseTransId
	* @return AGS_Expense_Products_Interaction__c
	*/
	public static AGS_Expense_Products_Interaction__c createExpenseProductsInteraction(Id spendExpenseTransId) {
		createBrands();
		List<String> brandNames = new List<String>{ 'Avastin', 'Herceptin', 'Lucentis' };
		String brandName;
		for(String b : brandNames) {
			if([SELECT Id FROM AGS_Brand_gne__c WHERE Brand_Name__c = :b].size() == 0) {
				brandName = b;
				break;
			}
		}
		AGS_Brand_gne__c b = new AGS_Brand_gne__c( Brand_Name__c = brandName );
		insert b;

		AGS_Expense_Products_Interaction__c ept = new AGS_Expense_Products_Interaction__c(
			Expense_Transaction_ID_gne__c 		= spendExpenseTransId,
			AGS_Brand_gne__c 					= b.Id
		);
		insert ept;
		checkIfIdExistsAfterInsert( ept );
		return ept;
	}
}