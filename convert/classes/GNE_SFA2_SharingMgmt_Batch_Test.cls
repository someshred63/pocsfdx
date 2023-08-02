/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-20
*  Description: This is a test class for GNE_SFA2_SharingMgmt_Batch
*
*  Modification History
*  Date        Name        Description
*  2012-10-17  kwiatkol    Added changes related to adding AccountShares for User Id
*  2014-02-11  przesmyp	   Fixed unit test failing due to validation on Case.GATCF_Status_gne__c field
*************************************************************/
@isTest()
private without sharing class GNE_SFA2_SharingMgmt_Batch_Test {

	private static final String TEST_PROFILE = 'GNE-SYS-Support';	// should be a profile which has GNE_SFA2_SharingMgmt_Trigger disabled
	private static final String TEST_USER_NAME = 'shareMgmtUsr@roche.com';

	 public static void turnOffTrigger(User u) {
        System.runAs(u) {
	        if (GNE_SFA2_Trigger_Execution_Exception_gne__c.getInstance() == null) {
	            upsert new GNE_SFA2_Trigger_Execution_Exception_gne__c(SetupOwnerId = u.Id, Name = 'GNE_SFA2_SharingMgmt_Trigger', GNE_SFA2_SharingMgmt_Trigger__c = true);
	        } else {
	            GNE_SFA2_Trigger_Execution_Exception_gne__c triggerExecutionSettings = GNE_SFA2_Trigger_Execution_Exception_gne__c.getInstance();
	            triggerExecutionSettings.GNE_SFA2_SharingMgmt_Trigger__c = true;
	        }
        }
    }

    static testMethod void testAccountShareInsert() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_SharingMgmt_Trigger', true);
    	Test.startTest();
    	List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();
		User testUser;
        system.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]){
        	GNE_SFA2_Util.switchAdminMode(true);
        	testUser = prepareTestUser(TEST_USER_NAME, TEST_PROFILE);
        	GNE_SFA2_Util.switchAdminMode(false);
    	}
        turnOffTrigger(testUser);
        
        List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'User_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'Territory_Name_gne__c' => testTerritory.Name, 'Operation_gne__c' => 'Insert', 'Status_gne__c' => 'New',
															'Account_Access_Level_gne__c' => 'Read', 'Opportunity_Access_Level_gne__c' => 'Read'});

		List<Sharing_Mgmt_gne__c> scope;
		System.runAs(testUser){
			insert testData;


			GNE_SFA2_SharingMgmt_Batch batch = new GNE_SFA2_SharingMgmt_Batch(' AND CreatedById = \'' + testUser.Id + '\' LIMIT 200');
			Database.Querylocator queryLocator = batch.start(null);
			//System.assert(false, 'query ' + queryLocator.getQuery());
			scope = (List<Sharing_Mgmt_gne__c>) Database.query(queryLocator.getQuery());

	        System.assertEquals(200, scope.size());

			batch.execute(null, scope);
			batch.finish(null);


		}
		Test.stopTest();

		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> terrIdsSet = new Set<Id>();
		// check if Sharing Managements were updated
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :scope ]) {
			System.assertNotEquals(null, shareMgmt.Account_Id_gne__c);
			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
			System.assertEquals(testTerritory.Id, shareMgmt.Territory_Id_gne__c);
		}
    }

    static testMethod void testInvalidAccountShareInsert() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_SharingMgmt_Trigger', true);
    	Test.startTest();
    	List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();
        User testUser;
        system.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]){
        	GNE_SFA2_Util.switchAdminMode(true);
        	testUser = prepareTestUser(TEST_USER_NAME, TEST_PROFILE);
        	GNE_SFA2_Util.switchAdminMode(false);
    	}
        turnOffTrigger(testUser);

        List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'Territory_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare',
        																						'Status_gne__c' => 'New'});
		List<Sharing_Mgmt_gne__c> scope;
		System.runAs(testUser){

			insert testData;

			GNE_SFA2_SharingMgmt_Batch batch = new GNE_SFA2_SharingMgmt_Batch(' AND CreatedById = \'' + testUser.Id + '\' LIMIT 200');
			Database.Querylocator queryLocator = batch.start(null);
			scope = (List<Sharing_Mgmt_gne__c>) Database.query(queryLocator.getQuery());

	        System.assertEquals(200, scope.size());

			batch.execute(null, scope);
			batch.finish(null);


		}
		Test.stopTest();

		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> terrIdsSet = new Set<Id>();
		// check if Sharing Managements were updated
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :scope ]) {
			System.assertEquals(null, shareMgmt.Account_Id_gne__c);
			System.assertEquals(null, shareMgmt.Record_Id_gne__c);
			System.assertEquals('Error', shareMgmt.Status_gne__c);
			System.assertEquals(null, shareMgmt.Territory_Id_gne__c);
		}
    }

    public static testMethod void testAccountShareDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_SharingMgmt_Trigger', true);
		Test.startTest();
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Territory2 testTerritory = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestTerritory();
		User testUser;
        system.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]){
        	GNE_SFA2_Util.switchAdminMode(true);
        	testUser = prepareTestUser(TEST_USER_NAME, TEST_PROFILE);
        	GNE_SFA2_Util.switchAdminMode(false);
    	}
		turnOffTrigger(testUser);
		// insert sample AccountShares to test deletion
		GNE_SFA2_SharingMgmt_Test_Helper.insertTestAccountShares(testAccounts, testTerritory);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestData(new Set<String>{'User_Id_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'AccountShare', 'External_Id_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_MDM_ID,
															'Territory_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_TERRITORY_NAME, 'Operation_gne__c' => 'Delete', 'Status_gne__c' => 'New',
															'Account_Access_Level_gne__c' => 'Read', 'Opportunity_Access_Level_gne__c' => 'Read'});
		List<Sharing_Mgmt_gne__c> scope;
		System.runAs(testUser){
			insert testData;

			GNE_SFA2_SharingMgmt_Batch batch = new GNE_SFA2_SharingMgmt_Batch(' AND CreatedById = \'' + testUser.Id + '\' LIMIT 200');
			Database.Querylocator queryLocator = batch.start(null);
			scope = (List<Sharing_Mgmt_gne__c>) Database.query(queryLocator.getQuery());

	        System.assertEquals(200, scope.size());

			batch.execute(null, scope);
			batch.finish(null);


		}
		Test.stopTest();

		// select inserted data
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Account_Id_gne__c, Territory_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :scope ]) {
			System.assertNotEquals(null, shareMgmt.Account_Id_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
		}
	}

    static testMethod void testCaseShareInsert() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_SharingMgmt_Trigger', true);
    	User testUser;
    	List<User> testUsers;
    	system.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]){
    		GNE_SFA2_Util.switchAdminMode(true);
    		testUser = prepareTestUser(TEST_USER_NAME, TEST_PROFILE);
    		testUsers = prepareTestUsers();
    		GNE_SFA2_Util.switchAdminMode(false);
    	}
    	turnOffTrigger(testUser);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Test.startTest();
		Case testCase = prepareTestCase2(testAccounts[0]);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare', 'External_Id_gne__c' => testCase.CaseNumber,
															'User_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_NAME, 'Operation_gne__c' => 'Insert', 'Status_gne__c' => 'New',
															'Case_Access_Level_gne__c' => 'Edit'}, testUsers);
		List<Sharing_Mgmt_gne__c> scope;

		System.runAs(testUser){
			insert testData;

			GNE_SFA2_SharingMgmt_Batch batch = new GNE_SFA2_SharingMgmt_Batch(' AND CreatedById = \'' + testUser.Id + '\' LIMIT 200');
			Database.Querylocator queryLocator = batch.start(null);
			scope = (List<Sharing_Mgmt_gne__c>) Database.query(queryLocator.getQuery());

	        System.assertEquals(200, scope.size());

			batch.execute(null, scope);
			batch.finish(null);
		}

		Test.stopTest();

		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> terrIdsSet = new Set<Id>();
		// check if Sharing Managements were updated
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT User_Id_gne__c, Case_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :scope ]) {
			System.assertNotEquals(null, shareMgmt.User_Id_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertEquals(testCase.Id, shareMgmt.Case_Id_gne__c);
		}
    }

    public static testMethod void testCaseShareDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_SharingMgmt_Trigger', true);
		User testUser;
    	List<User> testUsers;
    	system.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]){
    		GNE_SFA2_Util.switchAdminMode(true);
    		testUser = prepareTestUser(TEST_USER_NAME, TEST_PROFILE);
    		testUsers = prepareTestUsers();
    		GNE_SFA2_Util.switchAdminMode(false);
    	}
		turnOffTrigger(testUser);
		List<Account> testAccounts = GNE_SFA2_SharingMgmt_Test_Helper.prepareTestAccounts();
		Test.startTest();
		Case testCase = prepareTestCase2(testAccounts[0]);

		GNE_SFA2_SharingMgmt_Test_Helper.insertTestCaseShares(testUsers, testCase);

		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(null, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare', 'External_Id_gne__c' => testCase.CaseNumber,
															'User_Name_gne__c' => GNE_SFA2_SharingMgmt_Test_Helper.TEST_NAME, 'Operation_gne__c' => 'Delete', 'Status_gne__c' => 'New',
															'Case_Access_Level_gne__c' => 'Edit'}, testUsers);


		List<Sharing_Mgmt_gne__c> scope;
		System.runAs(testUser){
			insert testData;

			GNE_SFA2_SharingMgmt_Batch batch = new GNE_SFA2_SharingMgmt_Batch(' AND CreatedById = \'' + testUser.Id + '\' LIMIT 200');
			Database.Querylocator queryLocator = batch.start(null);
			scope = (List<Sharing_Mgmt_gne__c>) Database.query(queryLocator.getQuery());

	        System.assertEquals(200, scope.size());

			batch.execute(null, scope);
			batch.finish(null);
		}

		Test.stopTest();
		// select inserted data
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT Case_Id_gne__c, User_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :scope ]) {
			System.assertNotEquals(null, shareMgmt.User_Id_gne__c);
			System.assertNotEquals(null, shareMgmt.Case_Id_gne__c);
			System.assertEquals('Completed', shareMgmt.Status_gne__c);
			System.assertNotEquals(null, shareMgmt.Record_Id_gne__c);
		}
	}

    static testMethod void testInvalidCaseShareInsert() {
    	GNE_SFA2_Util.switchAdminMode(false);
    	GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_SharingMgmt_Trigger', true);
		Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('testName');
		testAccount.MDMID_gne__c='test';
		insert testAccount;
    	List<User> testUsers;
    	system.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]){
    		testUsers = prepareTestUsers();
    	}
		Test.startTest();
		Case testCase = prepareTestCase2(testAccount);
		List<Sharing_Mgmt_gne__c> testData = GNE_SFA2_SharingMgmt_Test_Helper.prepareCaseShareTestData(new Set<String>{'User_Name_gne__c'}, new Map<String, Object>{'Object_Name_gne__c' => 'CaseShare',
																										'Status_gne__c' => 'New'}, testUsers);

		List<Sharing_Mgmt_gne__c> scope;
		insert testData;

		GNE_SFA2_SharingMgmt_Batch batch = new GNE_SFA2_SharingMgmt_Batch(' AND CreatedById = \'' + UserInfo.getUserId() + '\' LIMIT 200');
		Database.Querylocator queryLocator = batch.start(null);
		scope = (List<Sharing_Mgmt_gne__c>) Database.query(queryLocator.getQuery());

        System.assertEquals(200, scope.size());

		batch.execute(null, scope);
		batch.finish(null);
		Test.stopTest();

		Set<Id> accIdsSet = new Set<Id>();
		Set<Id> terrIdsSet = new Set<Id>();
		// check if Sharing Managements were updated
		for(Sharing_Mgmt_gne__c shareMgmt : [ SELECT User_Name_gne__c, Case_Id_gne__c, Status_gne__c, Record_Id_gne__c FROM Sharing_Mgmt_gne__c WHERE Id in :scope ]) {
			System.assertEquals(null, shareMgmt.User_Name_gne__c);
			System.assertEquals(null, shareMgmt.Record_Id_gne__c);
			System.assertEquals('Error', shareMgmt.Status_gne__c);
			System.assertEquals(null, shareMgmt.Case_Id_gne__c);
		}
    }

    public static Case prepareTestCase(Account account) {
		GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_case_create_tasks');
    	GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_Infusion_patient_prepopulate');

		Case testCase = GNE_CM_Test_Helper.createTestCase('Avastin', 'GATCF - Standard Case', account.Id);
		testCase.Ins_Eligibility_Determination_gne__c='Approved';
		insert testCase;
		Case updatedTestCase = [ SELECT CaseNumber FROM Case WHERE Id = :testCase.Id LIMIT 1 ];
		return updatedTestCase;
	}

	public static Case prepareTestCase2(Account account) {
		GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_case_create_tasks');
    	GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_Infusion_patient_prepopulate');

		Case testCase = new Case(Case_Treating_Physician_gne__c = account.Id, Product_gne__c = 'Avastin', Case_Referral_Reason_gne__c = 'New Treating MD');
		insert testCase;
		Case updatedTestCase = [ SELECT CaseNumber FROM Case WHERE Id = :testCase.Id LIMIT 1 ];
		return updatedTestCase;
	}

	public static User prepareTestUser(String testusername, String profileName) {
		Profile p = [ SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
		User u = new User(
				alias = 'shr',
				email='sharing_management_test_user@roche.com',
				emailencodingkey='UTF-8',
				firstname='sampleFirst',
				lastname='sampleLast',
				languagelocalekey='en_US',
				localesidkey='en_US',
				profileid = p.Id,
				timezonesidkey='America/Los_Angeles',
				username=testusername
			);

		insert u;
		return u;
	}

	public static List<User> prepareTestUsers() {
		List<User> testUsers = new List<User>();
		Profile p = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		for(Integer i = 0; i < 201; i++) {
			User u = new User(
				alias = 'shr' + String.valueOf(i),
				email = 'sharing_management_test_user@roche.com',
				emailencodingkey = 'UTF-8',
				firstname = 'TEST_FIRST_NAME',
				lastname = 'TEST_LAST_NAME' + String.valueOf(i),
				languagelocalekey = 'en_US',
				localesidkey = 'en_US',
				profileid = p.Id,
				timezonesidkey = 'America/Los_Angeles',
				username = 'sharing_management_test_user@roche.com' + String.valueOf(i),
				CommunityNickname = 'testSharingNickname' + String.valueOf(i)
			);
			testUsers.add(u);
		}
		insert testUsers;
		return testUsers;
	}
}