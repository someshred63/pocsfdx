/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-20
*  Description: Helper class for Sharing Management tests
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
@isTest
public class GNE_SFA2_SharingMgmt_Test_Helper {

	private static final String TEST_FIRST_NAME = 'firstName';
	private static final String TEST_LAST_NAME = 'lastName';
	public static final String TEST_MDM_ID = 'testMdmId';
	public static final String TEST_NAME = 'sharing_management_test_user@roche.com';
	public static final String TEST_TERRITORY_NAME = 'testTerritoryName';
	public static Integer BATCH_SIZE = 201;	// 201 to test agains governor limits
	private static Territory2Model terrModel;
    private static Territory2Type terrType;

	public static User prepareTestUser(String testusername, String profileName) {
		Profile p = [ SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
		User u = new User(
				alias = 'shr',
				email='sharing_management_test_user@roche.com',
				emailencodingkey='UTF-8',
				firstname=TEST_FIRST_NAME,
				lastname=TEST_LAST_NAME,
				languagelocalekey='en_US',
				localesidkey='en_US',
				profileid = p.Id,
				timezonesidkey='America/Los_Angeles',
				username=testusername
			);

		User currentUser = [ SELECT Id FROM User WHERE Id = :Userinfo.getUserID() LIMIT 1 ];
		System.runAs(currentUser) {
			insert u;
		}
		return u;
	}

	public static List<User> prepareTestUsers() {
		List<User> testUsers = new List<User>();
		Profile p = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			User u = new User(
				alias = 'shr' + String.valueOf(i),
				email='sharing_management_test_user@roche.com',
				emailencodingkey='UTF-8',
				firstname=TEST_FIRST_NAME,
				lastname=TEST_LAST_NAME + String.valueOf(i),
				languagelocalekey='en_US',
				localesidkey='en_US',
				profileid = p.Id,
				timezonesidkey='America/Los_Angeles',
				username='sharing_management_test_user@roche.com' + String.valueOf(i)
			);
			testUsers.add(u);
		}

		User currentUser = [ SELECT Id FROM User WHERE Id = :Userinfo.getUserID() LIMIT 1 ];
		System.runAs(currentUser) {
			insert testUsers;
		}
		return testUsers;
	}

	public static Territory2 prepareTestTerritory() {
		Territory2 testTerritory = new Territory2(
			Name = TEST_TERRITORY_NAME, 
			CaseAccessLevel = 'None', 
			AccountAccessLevel = 'Read',
			OpportunityAccessLevel = 'Read',
			DeveloperName = 'DM_' + TEST_TERRITORY_NAME.replaceAll('[|\\,|\\.|\\,||"||\\:|\\~|\\!|\\@|\\#|\\$|\\%|\\^|\\&|\\*|\\-|\\_| |\\+|\\=|\\<|\\>|\\?|\\(|\\)|\\{|\\}|\\;|\\\'"]', ''),
			Territory2ModelId = getTerrModelId(),
            Territory2TypeId = getTerrTypeId(),
            Parent_External_Id_gne__c = 'Root',
            external_id_gne__c = 'Root;'+TEST_TERRITORY_NAME
		);
		Profile adminProfile = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1 ];
		User adminUser = [ SELECT Id FROM User WHERE ProfileId = :adminProfile.Id AND isActive = true LIMIT 1 ];
		System.runAs(adminUser) {
			insert testTerritory;
		}

		return testTerritory;
	}
    
    private static Id getTerrModelId() {
    	Id result;
    	if (terrModel == null) {
    		terrModel = [SELECT Id FROM Territory2Model LIMIT 1];
    	}
    	
    	result = terrModel.Id;
    	return result;
    }
    
    private static Id getTerrTypeId() {
    	Id result;
    	if (terrType == null) {
    		terrType = [SELECT Id FROM Territory2Type LIMIT 1];
    	}
    	
    	result = terrType.Id;
    	return result;
    }

	public static List<Account> prepareTestAccounts() {

		List<Account> testAccounts = new List<Account>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			testAccounts.add(new Account(FirstName = TEST_FIRST_NAME, LastName = TEST_LAST_NAME, MDMID_gne__c = TEST_MDM_ID + String.valueOf(i)));
		}

		insert testAccounts;
		return testAccounts;
	}

	public static Case prepareTestCase(Account account) {
		GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_case_create_tasks');
    	GNE_CM_UnitTestConfig.skipTriggerForTests('GNE_CM_Infusion_patient_prepopulate');

		Case testCase = GNE_CM_Test_Helper.addTestCase('Avastin', 'GATCF - Standard Case', account);
		Case updatedTestCase = [ SELECT CaseNumber FROM Case WHERE Id = :testCase.Id LIMIT 1 ];
		return updatedTestCase;
	}

	/* helper method used for preparing test data */
	public static List<Sharing_Mgmt_gne__c> prepareTestData(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
		List<Sharing_Mgmt_gne__c> testData = new List<Sharing_Mgmt_gne__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			Sharing_Mgmt_gne__c shareMgmt = new Sharing_Mgmt_gne__c();

			// populate Object_Name_gne__c field
			shareMgmt.Object_Name_gne__c = getFieldValue('Object_Name_gne__c', emptyFieldNames, testFieldValues);
			// populate External_Id_gne__c field
			shareMgmt.External_Id_gne__c = getUniqueFieldValue('External_Id_gne__c', emptyFieldNames, testFieldValues, i);
			// populate Operation_gne__c field
			shareMgmt.Operation_gne__c = getFieldValue('Operation_gne__c', emptyFieldNames, testFieldValues);
			// populate Schedule_Date_Time_gne__c field
			if(emptyFieldNames != null && emptyFieldNames.contains('Schedule_Date_Time_gne__c')) {
				shareMgmt.Schedule_Date_Time_gne__c = null;
			} else if(testFieldValues != null && testFieldValues.containsKey('Schedule_Date_Time_gne__c')) {
				shareMgmt.Schedule_Date_Time_gne__c = (DateTime) testFieldValues.get('Schedule_Date_Time_gne__c');
			} else {
				shareMgmt.Schedule_Date_Time_gne__c = System.today();
			}
			// populate Status_gne__c field
			shareMgmt.Status_gne__c = getFieldValue('Status_gne__c', emptyFieldNames, testFieldValues);
			// populate Territory_Name_gne__c field
			shareMgmt.Territory_Name_gne__c = getFieldValue('Territory_Name_gne__c', emptyFieldNames, testFieldValues);
			// populate User_Name_gne__c field
			shareMgmt.User_Name_gne__c = getFieldValue('User_Name_gne__c', emptyFieldNames, testFieldValues);
			// populate Case_Access_Level_gne__c field
			shareMgmt.Case_Access_Level_gne__c = getFieldValue('Case_Access_Level_gne__c', emptyFieldNames, testFieldValues);
			// populate User_Id_gne__c field
			shareMgmt.User_Id_gne__c = getFieldValue('User_Id_gne__c', emptyFieldNames, testFieldValues);
			// populate Account_Access_Level_gne__c field
			shareMgmt.Account_Access_Level_gne__c = getFieldValue('Account_Access_Level_gne__c', emptyFieldNames, testFieldValues);
			// populate Opportunity_Access_Level_gne__c field
			shareMgmt.Opportunity_Access_Level_gne__c = getFieldValue('Opportunity_Access_Level_gne__c', emptyFieldNames, testFieldValues);

			testData.add(shareMgmt);
		}

		return testData;
	}

	public static List<Sharing_Mgmt_gne__c> prepareCaseShareTestData(Set<String> emptyFieldNames, Map<String, Object> testFieldValues, List<User> testUsers) {
		List<Sharing_Mgmt_gne__c> testData = new List<Sharing_Mgmt_gne__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {		// 201 to test agains Governor Limits
			Sharing_Mgmt_gne__c shareMgmt = new Sharing_Mgmt_gne__c();

			// populate Object_Name_gne__c field
			shareMgmt.Object_Name_gne__c = getFieldValue('Object_Name_gne__c', emptyFieldNames, testFieldValues);
			// populate External_Id_gne__c field
			shareMgmt.External_Id_gne__c = getFieldValue('External_Id_gne__c', emptyFieldNames, testFieldValues);
			// populate Operation_gne__c field
			shareMgmt.Operation_gne__c = getFieldValue('Operation_gne__c', emptyFieldNames, testFieldValues);
			// populate Schedule_Date_Time_gne__c field
			if(emptyFieldNames != null && emptyFieldNames.contains('Schedule_Date_Time_gne__c')) {
				shareMgmt.Schedule_Date_Time_gne__c = null;
			} else if(testFieldValues != null && testFieldValues.containsKey('Schedule_Date_Time_gne__c')) {
				shareMgmt.Schedule_Date_Time_gne__c = (DateTime) testFieldValues.get('Schedule_Date_Time_gne__c');
			} else {
				shareMgmt.Schedule_Date_Time_gne__c = System.today();
			}
			// populate Status_gne__c field
			shareMgmt.Status_gne__c = getFieldValue('Status_gne__c', emptyFieldNames, testFieldValues);

			if(testUsers != null) {
				shareMgmt.User_Id_gne__c = testUsers[i].Id;
			} else {
				shareMgmt.User_Id_gne__c = null;
			}
			// populate Case_Access_Level_gne__c field
			shareMgmt.Case_Access_Level_gne__c = getFieldValue('Case_Access_Level_gne__c', emptyFieldNames, testFieldValues);

			testData.add(shareMgmt);
		}

		return testData;
	}

	public static void insertTestAccountShares(List<Account> testAccounts, Territory2 testTerritory) {
		List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();
		for(Account acc : testAccounts) {
			ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = acc.Id, Territory2Id = testTerritory.Id, AssociationCause='Territory2Manual');
    		territoryAssociations.add(territoryAssociation);
		}
		insert territoryAssociations;
	}

	public static void insertTestUserAccountShares(List<Account> testAccounts, User testUser) {
		List<AccountShare> accountSharesToAdd = new List<AccountShare>();
		for(Account acc : testAccounts) {
			accountSharesToAdd.add(new AccountShare(AccountId = acc.Id, UserOrGroupId = testUser.Id, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'None'));
		}
		insert accountSharesToAdd;
	}

	public static void insertTestCaseShares(List<User> testUsers, Case testCase) {
		List<CaseShare> caseSharesToAdd = new List<CaseShare>();
		/*
		Map<String, String> terrToGroup = new Map<String, String>();
		for(Group g : [ SELECT RelatedId, Id FROM Group ]) {
			terrToGroup.put(g.RelatedId, g.Id);
		}
		*/
		for (User usr : testUsers) {
			caseSharesToAdd.add(new CaseShare(CaseId = testCase.Id, UserOrGroupId = usr.Id, CaseAccessLevel = 'Edit'));
		}
		insert caseSharesToAdd;
	}

	/* helper method for getting field value */
	public static String getFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues){
		String result = null;
		if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
			result = '';
		} else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
			result = (String) testFieldValues.get(fieldName);
		} else {
			result = 'Read';
		}
		return result;
	}

	/* helper method for getting field value which has to be unique */
	public static String getUniqueFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues, Integer i){
		String result = null;
		if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
			result = '';
		} else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
			result = (String) testFieldValues.get(fieldName) + String.valueOf(i);
		} else {
			result = 'testValue' + String.valueOf(i);
		}
		return result;
	}
}