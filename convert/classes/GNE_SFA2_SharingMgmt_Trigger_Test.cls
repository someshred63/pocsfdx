/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-12
*  Description: This is a test class for GNE_SFA2_SharingMgmt_Trigger
*
*  Modification History
*  Date        Name        Description
*  2012-07-20  kwiatkol    Class annotated with SeeAllData flag, because of Salesforce bug when accessing the AccountShare objects in test
*						   see: http://boards.developerforce.com/t5/forums/forumtopicprintpage/board-id/apex/message-id/71497/print-single-message/false/page/1
*  201-10-17   kwiatkol    Added new test cases for inserting AccountShares with User Id specified
*  2014-02-11  przesmyp	   Fixed unit test failing due to validation on Case.GATCF_Status_gne__c field

GNE_SFA2_SharingMgmt_Validation_Rules
=====================================
Test cases:
1. Missing required fields:
	a) object name
	b) external id
	c) opertaion
	d) schedule datetime
	e) status
2. If object name equals "AccountShare":
	a) "Territory Name" is required
3. If object name equals "CaseShare":
	a) "User Name" is required
	b) "CaseAccessLevel" is required

GNE_SFA2_SharingMgmt_Field_Updates
==================================
Test cases:
1. If object name equals "Account" following fields are populated: Account Id, Territory2 Id, Reference Name
2. If object name equals "Case" following fields are populated: Case Id, User Id

GNE_SFA2_SharingMgmt_Child_Record_Update
========================================
Test cases:
1. Adding AccountShares
2. Deleteing AccountShares
3. Adding CaseShares
4. Removing CaseShares

Note: All of the above scenarios are executed both for Admin and Not Admin users
*************************************************************/
@isTest(SeeAllData=true)
public without sharing class GNE_SFA2_SharingMgmt_Trigger_Test {

	private static User testUser;

	/* method used for inserting test records and checking insert status */
	private static void insertRecordsAssertNotAdded(List<Sharing_Mgmt_gne__c> testData) {
		try {
			insert testData;
			System.assert(false, 'Sharing management objects should not be added.');
		} catch (DMLException ex) {
			System.assert(ex.getMessage().contains(System.Label.GNE_SFA2_ErrorMsg_ALL_Required_Fields), ex.getMessage());
			System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
		}
	}

	/* method used for inserting test records and checking insert status */
	private static void insertRecordsAssertAdded(List<Sharing_Mgmt_gne__c> testData) {
		try {
			insert testData;
		} catch (DMLException ex) {
			System.assert(false, 'Sharing management objects should be added: ' + ex.getMessage());
		}
	}

	public static testMethod void testValidationMissingObjectNameNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Object_Name_gne__c'}, null);
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingExternalIdAccountIdAccountShareNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'External_Id_gne__c', 'Account_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare'});
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationBothUserIdExternalIddAccountShareNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(null,
													new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'User_Id_gne__c' => 'test', 'Territory_Name_gne__c' => 'test'});
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingExternalIdCaseShareNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'External_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare'});
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingOpertationNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Operation_gne__c'}, null);
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingDateTimeNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Schedule_Date_Time_gne__c'}, null);
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingStatusNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Status_gne__c'}, null);
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingTerritoryNameUserIdForAccountNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Territory_Name_gne__c', 'User_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare'});
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingUserIdForCaseNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(new Set<String>{'User_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare'}, null);
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingSharingLevelsForCaseNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Case_Access_Level_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare'});
		insertRecordsAssertNotAdded(testData);
	}

	public static testMethod void testValidationMissingObjectNameAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Object_Name_gne__c'}, null);
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testValidationMissingExternalIdAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'External_Id_gne__c'}, null);
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testValidationMissingUserIdTerritoryNameAccountShareAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'User_Id_gne__c', 'Territory_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => 'test'});
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testValidationBothUserIdTerritoryNamedAccountShareAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(null,
													new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'Territory_Name_gne__c' => 'test', 'User_Id_gne__c' => 'test', 'External_Id_gne__c' => 'test'});
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testValidationMissingOpertationAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Operation_gne__c'}, null);
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testValidationMissingDateTimeAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Schedule_Date_Time_gne__c'}, null);
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testValidationMissingStatusAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Status_gne__c'}, null);
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testValidationMissingTerritoryNameForAccountAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Territory_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare'});
		insertRecordsAssertAdded(testData);
	}


	public static testMethod void testValidationMissingUserIdForCaseAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(new Set<String>{'User_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare'}, null);
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testValidationMissingSharingLevelsForCaseAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Case_Access_Level_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare'});
		insertRecordsAssertAdded(testData);
	}

	public static testMethod void testFieldUpdateOnAccountObjectNameNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String> {'User_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'Territory_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_TERRITORY_NAME});
		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> idsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : testData) {
			idsSet.add(shareMgmt.Id);
		}

		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Reference_Name_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :idsSet ]) {
			System.assertNotEquals(null, shareMgmt.Account_Id_gne__c);

			System.assertNotEquals(null, shareMgmt.Territory_Id_gne__c);
			System.assertEquals(testTerritory.Id, shareMgmt.Territory_Id_gne__c);

			System.assertNotEquals(null, shareMgmt.Reference_Name_gne__c);
		}
	}

	public static testMethod void testFieldUpdateOnAccountObjectNameAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'Territory_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_TERRITORY_NAME});

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> idsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : testData) {
			idsSet.add(shareMgmt.Id);
		}

		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Reference_Name_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :idsSet ]) {
			System.assertEquals(null, shareMgmt.Account_Id_gne__c);
			System.assertEquals(null, shareMgmt.Territory_Id_gne__c);
			System.assertEquals(null, shareMgmt.Reference_Name_gne__c);
		}
	}

	public static testMethod void testFieldUpdateOnCaseObjectNameNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<User> testUsers = prepareTestUsers();
		Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		testAccount.MDMID_gne__c='test' + String.valueOf(DateTime.now());
		insert testAccount;
		Case testCase = prepareTestCase2(testAccount);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare', 'External_Id_gne__c' => testCase.CaseNumber,
															'Case_Access_Level_gne__c' => 'Read'}, testUsers);

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> idsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : testData) {
			idsSet.add(shareMgmt.Id);
		}

		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Case_Id_gne__c, User_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :idsSet ]) {
			//System.assert(false, shareMgmt);
			System.assertNotEquals(null, shareMgmt.Case_Id_gne__c);
			System.assertEquals(testCase.Id, shareMgmt.Case_Id_gne__c);
			System.assertNotEquals(null, shareMgmt.User_Id_gne__c);
		}
	}

	public static testMethod void testFieldUpdateOnCaseObjectNameAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<User> testUsers = prepareTestUsers();
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Case testCase = prepareTestCase2(testAccounts[0]);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare', 'External_Id_gne__c' => testCase.CaseNumber,
															'User_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_NAME, 'Case_Access_Level_gne__c' => 'Read'}, testUsers);

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> idsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : testData) {
			idsSet.add(shareMgmt.Id);
		}

		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Reference_Name_gne__c, Case_Id_gne__c, User_Name_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :idsSet ]) {
			System.assertEquals(null, shareMgmt.Case_Id_gne__c);
			System.assertEquals(null, shareMgmt.User_Name_gne__c);
		}
	}

	public static testMethod void testAddAccountShareNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String> {'User_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'Territory_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_TERRITORY_NAME, 'Operation_gne__c' => 'Insert', 'Status_gne__c' => 'New'});
		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> terrIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Comments_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {
			System.assertNotEquals(null, shareMgmt.Account_Id_gne__c);
			System.assertNotEquals(null, shareMgmt.Territory_Id_gne__c);

			accIdsSet.add(shareMgmt.Account_Id_gne__c);
			terrIdsSet.add(shareMgmt.Territory_Id_gne__c);
			system.debug(shareMgmt.Comments_gne__c);
			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<Group> terrGroupIds = [ SELECT Id FROM Group WHERE RelatedId in :terrIdsSet];

		List<AccountShare> createdAccShares = [ SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId in :accIdsSet AND UserOrGroupId in :terrGroupIds ];
		System.assertEquals(GNE_SFA2_SharingMgmt_Test_Helper.BATCH_SIZE, createdAccShares.size());
	}


	public static testMethod void testAddAccountShareWithUserSpecifiedNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		User sampleUser = prepareTestUser('test_user@roche.com', 'System administrator');

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Territory_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'User_Id_gne__c' => sampleUser.Id, 'Operation_gne__c' => 'Insert', 'Status_gne__c' => 'New', 'Account_Access_Level' => 'Read', 'Opportunity_Access_Level_gne__c' => 'None'});

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> userIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, User_Id_gne__c, Status_gne__c, Record_Id_gne__c, Comments_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {
			System.assertNotEquals(null, shareMgmt.Account_Id_gne__c);
			System.assertNotEquals(null, shareMgmt.User_Id_gne__c);

			accIdsSet.add(shareMgmt.Account_Id_gne__c);
			userIdsSet.add(shareMgmt.User_Id_gne__c);

			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<AccountShare> createdAccShares = [ SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId in :accIdsSet AND UserOrGroupId = :sampleUser.Id ];
		System.assertEquals(GNE_SFA2_SharingMgmt_Test_Helper.BATCH_SIZE, createdAccShares.size());
	}

	public static testMethod void testAddAccountShareAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'User_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'Territory_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_TERRITORY_NAME, 'Operation_gne__c' => 'Insert', 'Status_gne__c' => 'New'});

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> terrIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {
			accIdsSet.add(shareMgmt.Account_Id_gne__c);
			terrIdsSet.add(shareMgmt.Territory_Id_gne__c);

			System.assertEquals('New', shareMgmt.Status_gne__c);
			System.assertEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<Group> terrGroupIds = [ SELECT Id FROM Group WHERE RelatedId in :terrIdsSet];

		List<AccountShare> createdAccShares = [ SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId in :accIdsSet AND UserOrGroupId in :terrGroupIds ];
		System.assertEquals(0, createdAccShares.size());
	}


	public static testMethod void testAddAccountShareWithUserSpecifiedAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		User sampleUser = prepareTestUser('test_user@roche.com', 'System administrator');

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Territory_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'User_Id_gne__c' => sampleUser.Id, 'Operation_gne__c' => 'Insert', 'Status_gne__c' => 'New', 'Account_Access_Level' => 'Read', 'Opportunity_Access_Level_gne__c' => 'None'});

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> userIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, User_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {
			accIdsSet.add(shareMgmt.Account_Id_gne__c);
			userIdsSet.add(shareMgmt.User_Id_gne__c);

			System.assertEquals('New', shareMgmt.Status_gne__c);
			System.assertEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<AccountShare> createdAccShares = [ SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId in :accIdsSet AND UserOrGroupId = :sampleUser.Id ];
		System.assertEquals(0, createdAccShares.size());
	}

	public static testMethod void testDeleteAccountShareNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();

		// insert sample AccountShares to test deletion
		GNE_SFA2_SharingMgmt_Test_Helper.insertTestAccountShares(testAccounts, testTerritory);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String> {'User_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'Territory_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_TERRITORY_NAME, 'Operation_gne__c' => 'Delete', 'Status_gne__c' => 'New'});

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> terrIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {
			accIdsSet.add(shareMgmt.Account_Id_gne__c);
			terrIdsSet.add(shareMgmt.Territory_Id_gne__c);

			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<Group> terrGroupIds = [ SELECT Id FROM Group WHERE RelatedId in :terrIdsSet];

		List<AccountShare> createdAccShares = [ SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId in :accIdsSet AND UserOrGroupId in :terrGroupIds ];
		System.assertEquals(0, createdAccShares.size());
	}

	public static testMethod void testDeleteAccountShareUserSpecifiedNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		User sampleUser = prepareTestUser('test_user@roche.com', 'System administrator');

		// insert sample AccountShares to test deletion
		GNE_SFA2_SharingMgmt_Test_Helper.insertTestUserAccountShares(testAccounts, sampleUser);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String> {'Territory_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'User_Id_gne__c' => sampleUser.Id, 'Operation_gne__c' => 'Delete', 'Status_gne__c' => 'New', 'Account_Access_Level_gne__c' => 'Write', 'Opportunity_Access_Level_gne__c' => 'None'});

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> accIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, User_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {
			accIdsSet.add(shareMgmt.Account_Id_gne__c);

			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<AccountShare> createdAccShares = [ SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId in :accIdsSet AND UserOrGroupId = :sampleUser.Id ];
		System.assertEquals(0, createdAccShares.size());
	}

	public static testMethod void testDeleteAccountShareAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();

		// insert sample AccountShares to test deletion
		GNE_SFA2_SharingMgmt_Test_Helper.insertTestAccountShares(testAccounts, testTerritory);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String> {'User_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'Territory_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_TERRITORY_NAME, 'Operation_gne__c' => 'Delete', 'Status_gne__c' => 'New'});

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {

			System.assertEquals('New', shareMgmt.Status_gne__c);
			System.assertEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<Group> terrGroupIds = [ SELECT Id FROM Group WHERE RelatedId = :testTerritory.Id];

		List<AccountShare> createdAccShares = [ SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId in :testAccounts AND UserOrGroupId in :terrGroupIds ];
		System.assertEquals(GNE_SFA2_SharingMgmt_Test_Helper.BATCH_SIZE, createdAccShares.size());
	}

	public static testMethod void testDeleteAccountShareUserSpecifiedAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		User sampleUser = prepareTestUser('test_user@roche.com', 'System administrator');

		// insert sample AccountShares to test deletion
		GNE_SFA2_SharingMgmt_Test_Helper.insertTestUserAccountShares(testAccounts, sampleUser);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String> {'Territory_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'User_Id_gne__c' => sampleUser.Id, 'Operation_gne__c' => 'Delete', 'Status_gne__c' => 'New', 'Account_Access_Level_gne__c' => 'Write', 'Opportunity_Access_Level_gne__c' => 'None'});

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> accIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, User_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {
			accIdsSet.add(shareMgmt.Account_Id_gne__c);

			System.assertEquals('New', shareMgmt.Status_gne__c);
			System.assertEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<AccountShare> createdAccShares = [ SELECT AccountId, UserOrGroupId, RowCause FROM AccountShare WHERE AccountId in :accIdsSet AND UserOrGroupId = :sampleUser.Id ];
		System.assertEquals(0, createdAccShares.size());
	}

	public static testMethod void testAddCaseShareNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);
		Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		testAccount.MDMID_gne__c='test' + String.valueOf(DateTime.now());
		insert testAccount;
		List<User> testUsers = prepareTestUsers();
		Test.startTest();
		Case testCase = prepareTestCase2(testAccount);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare', 'External_Id_gne__c' => testCase.CaseNumber,
															'User_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_NAME, 'Operation_gne__c' => 'Insert', 'Status_gne__c' => 'New',
															'Case_Access_Level_gne__c' => 'Edit'}, testUsers);

		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> caseIdsSet = new Set<Id>();
		Set<Id> userIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Case_Id_gne__c, User_Id_gne__c, Status_gne__c, Record_Id_gne__c, Comments_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {

			caseIdsSet.add(shareMgmt.Case_Id_gne__c);
			userIdsSet.add(shareMgmt.User_Id_gne__c);

			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<CaseShare> createdCaseShares = [ SELECT CaseId, UserOrGroupId, RowCause FROM CaseShare WHERE CaseId in :caseIdsSet AND UserOrGroupId in :userIdsSet ];
		System.assertEquals(GNE_SFA2_SharingMgmt_Test_Helper.BATCH_SIZE, createdCaseShares.size());
	}

	public static testMethod void testAddCaseShareAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		List<User> testUsers = prepareTestUsers();
		Case testCase = prepareTestCase2(testAccounts[0]);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare', 'External_Id_gne__c' => testCase.CaseNumber,
															'User_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_NAME, 'Operation_gne__c' => 'Insert', 'Status_gne__c' => 'New',
															'Case_Access_Level_gne__c' => 'Read'}, testUsers);

		Test.startTest();
		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> caseIdsSet = new Set<Id>();
		Set<Id> userIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {

			System.assertEquals('New', shareMgmt.Status_gne__c);
			System.assertEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<CaseShare> createdCaseShares = [ SELECT CaseId, UserOrGroupId, RowCause FROM CaseShare WHERE CaseId = :testCase.Id AND UserOrGroupId in :testUsers ];
		System.assertEquals(0, createdCaseShares.size());
	}

	public static testMethod void testDeleteCaseShareNotAdminUser() {
		GNE_SFA2_Util.switchAdminMode(false);

		Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		testAccount.MDMID_gne__c='test' + String.valueOf(DateTime.now());
		insert testAccount;
		List<User> testUsers = prepareTestUsers();
		Test.startTest();
		Case testCase = prepareTestCase2(testAccount);
		GNE_SFA2_SharingMgmt_Test_Helper.insertTestCaseShares(testUsers, testCase);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare', 'External_Id_gne__c' => testCase.CaseNumber,
															'User_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_NAME, 'Operation_gne__c' => 'Delete', 'Status_gne__c' => 'New',
															'Case_Access_Level_gne__c' => 'Edit'}, testUsers);


		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> caseIdsSet = new Set<Id>();
		Set<Id> userIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Case_Id_gne__c, User_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {

			caseIdsSet.add(shareMgmt.Case_Id_gne__c);
			userIdsSet.add(shareMgmt.User_Id_gne__c);

			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<CaseShare> createdCaseShares = [ SELECT CaseId, UserOrGroupId, RowCause FROM CaseShare WHERE CaseId in :caseIdsSet AND UserOrGroupId in :userIdsSet ];
		System.assertEquals(0, createdCaseShares.size());
	}

	public static testMethod void testDeleteCaseShareAdminUser() {
		GNE_SFA2_Util.switchAdminMode(true);
		Test.startTest();
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		List<User> testUsers = prepareTestUsers();
		Case testCase = prepareTestCase2(testAccounts[0]);

		GNE_SFA2_SharingMgmt_Test_Helper.insertTestCaseShares(testUsers, testCase);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare', 'External_Id_gne__c' => testCase.CaseNumber,
															'User_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_NAME, 'Operation_gne__c' => 'Delete', 'Status_gne__c' => 'New',
															'Case_Access_Level_gne__c' => 'Read'}, testUsers);


		insert testData;
		Test.stopTest();

		// select inserted data
		Set<Id> caseIdsSet = new Set<Id>();
		Set<Id> userIdsSet = new Set<Id>();
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :testData ]) {

			System.assertEquals('New', shareMgmt.Status_gne__c);
			System.assertEquals(null, shareMgmt.Record_Id_gne__c);
		}

		List<CaseShare> createdCaseShares = [ SELECT CaseId, UserOrGroupId, RowCause FROM CaseShare WHERE CaseId = :testCase.Id AND UserOrGroupId in :testUsers ];
		System.assertEquals(GNE_SFA2_SharingMgmt_Test_Helper.BATCH_SIZE, createdCaseShares.size());
	}

	public static Case prepareTestCase(Account account) {
		GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_case_create_tasks');
    	GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_Infusion_patient_prepopulate');

    	system.debug('isSkipped: '+ GNE_CM_UnitTestConfig.isSkipped('GNE_CM_case_create_tasks'));

		Case testCase = GNE_CM_Test_Helper.createTestCase('Avastin', 'GATCF - Standard Case', account.Id);
		testCase.Ins_Eligibility_Determination_gne__c='Approved';
		testCase.Verified_Income_gne__c = 1.0;
		testCase.Income_Source_gne__c = 'Income Letter';
		testCase.Tax_Return_Year_gne__c = '2014';
		insert testCase;
		Case updatedTestCase = [ SELECT CaseNumber FROM Case WHERE Id = :testCase.Id LIMIT 1 ];
		return updatedTestCase;
	}

	public static Case prepareTestCase2(Account account) {
		GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_case_create_tasks');
    	GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_Infusion_patient_prepopulate');

    	system.debug('isSkipped: '+ GNE_CM_UnitTestConfig.isSkipped('GNE_CM_case_create_tasks'));

		Case testCase = new Case(Case_Treating_Physician_gne__c = account.Id, Product_gne__c = 'Avastin', Case_Referral_Reason_gne__c = 'New Treating MD');
		//testCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('GATCF - Standard Case').getRecordTypeId();
		//testCase.Foundation_Specialist_gne__c =
		insert testCase;
		//GNE_CM_Test_Helper.createTestCase('Avastin', 'GATCF - Standard Case', account.Id);
		//testCase.Ins_Eligibility_Determination_gne__c='Approved';
		Case updatedTestCase = [ SELECT CaseNumber FROM Case WHERE Id = :testCase.Id LIMIT 1 ];
		return updatedTestCase;
	}

	public static List<User> prepareTestUsers() {
		List<User> testUsers = new List<User>();
		Profile p = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		for(Integer i = 0; i < 201; i++) {
			User u = new User(
				alias = 'shr' + String.valueOf(i),
				email='sharing_management_test_user@roche.com',
				emailencodingkey='UTF-8',
				firstname='TEST_FIRST_NAME',
				lastname='TEST_LAST_NAME' + String.valueOf(i),
				languagelocalekey='en_US',
				localesidkey='en_US',
				profileid = p.Id,
				timezonesidkey='America/Los_Angeles',
				username='sharing_management_test_user@roche.com' + String.valueOf(i)
			);
			testUsers.add(u);
		}
		insert testUsers;
		return testUsers;
	}

	public static User prepareTestUser(String testusername, String profileName) {
		Profile p = [ SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
		User u = new User(
				alias = 'shr',
				email='sharing_management_test_user@roche.com',
				emailencodingkey='UTF-8',
				firstname='TEST_FIRST_NAME',
				lastname='TEST_LAST_NAME',
				languagelocalekey='en_US',
				localesidkey='en_US',
				profileid = p.Id,
				timezonesidkey='America/Los_Angeles',
				username=testusername
			);
		insert u;
		return u;
	}
}