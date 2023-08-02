/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-08
*  Description: This is a test class for GNE_SFA2_Account_Team_Trigger trigger
*  
*  Modification History
*  Date        	Name        		Description
*  2014-01-30	Piotr Przesmycki    Moved prepareTestUsers method executions to run as system admin, removed seeAllData annotation
*  2014-02-18 	Piotr Przesmycki 	Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*************************************************************/
@isTest
private with sharing class GNE_SFA2_Account_Team_Trigger_Test {
	
	private static Integer BATCH_SIZE = 101;
	private static final String TEST_FIRST_NAME = 'firstName';
	private static final String TEST_LAST_NAME = 'lastName';
	
	private static List<Account_Team_gne__c> prepareTestAccountTeams(Account testAccount, List<User> testUsers) {
		List<Account_Team_gne__c> accountTeams = new List<Account_Team_gne__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			accountTeams.add(GNE_SFA2_Triggers_Test_Util.prepareAccount_Team_gne(testAccount.Id, testUsers[i].Id));
		}
		insert accountTeams;
		return accountTeams;
	}
	
	private static Account insertTestAccount() {
		Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('test');
		testAccount.FirstName = 'test';
		insert testAccount;
		return testAccount;
	}
	
	public static List<User> prepareTestUsers(Integer startIndex) {
		List<User> testUsers = new List<User>();
		Profile p = [ SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
		for(Integer i = startIndex; i < BATCH_SIZE + startIndex; i++) {
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
	
	public static testMethod void testAccountTeamChildRecordUpdatesOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		List<User> testUsers = prepareTestUsers(0);
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account testAccount = insertTestAccount();
				
				
				Test.startTest();
				List<Account_Team_gne__c> testAccountTeams = prepareTestAccountTeams(testAccount, testUsers);
				Test.stopTest();
				
				List<AccountShare> insertedAccountShares = [ SELECT Id FROM AccountShare WHERE AccountId = :testAccount.Id AND UserorGroupId IN :testUsers ]; 
				System.assertNotEquals(null, insertedAccountShares);									  
				System.assertEquals(BATCH_SIZE, insertedAccountShares.size());
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testAccountTeamChildRecordUpdatesOnUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		List<User> testUsers = prepareTestUsers(0);
		List<User> testUsers2 = prepareTestUsers(BATCH_SIZE);
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account testAccount = insertTestAccount();
				
				
				List<Account_Team_gne__c> testAccountTeams = prepareTestAccountTeams(testAccount, testUsers);
				
				List<AccountShare> insertedAccountShares = [ SELECT Id FROM AccountShare WHERE AccountId = :testAccount.Id AND UserorGroupId IN :testUsers ]; 
				System.assertNotEquals(null, insertedAccountShares);									  
				System.assertEquals(BATCH_SIZE, insertedAccountShares.size());
				
				for(Integer i = 0; i < BATCH_SIZE; i++) {
					testAccountTeams[i].Team_Member_gne__c = testUsers2[i].Id;
					testAccountTeams[i].Account_Access_gne__c = 'Read/ Write';
				}
				
				Test.startTest();
				update testAccountTeams;
				Test.stopTest();
				
				List<AccountShare> oldAccountShares = [ SELECT Id FROM AccountShare WHERE AccountId = :testAccount.Id AND UserorGroupId IN :testUsers ]; 
				System.assertNotEquals(null, oldAccountShares);									  
				System.assertEquals(0, oldAccountShares.size());
				
				List<AccountShare> newAccountShares = [ SELECT Id FROM AccountShare WHERE AccountId = :testAccount.Id AND UserorGroupId IN :testUsers2 ]; 
				System.assertNotEquals(null, newAccountShares);									  
				System.assertEquals(BATCH_SIZE, newAccountShares.size());										 
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testAccountTeamChildRecordUpdatesOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		List<User> testUsers = prepareTestUsers(0);
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account testAccount = insertTestAccount();
				
				
				List<Account_Team_gne__c> testAccountTeams = prepareTestAccountTeams(testAccount, testUsers);
				Set<String> testAccountTeamsMemberIds = new Set<String>();
				for(Account_Team_gne__c testAccountTeam : testAccountTeams) {
					testAccountTeamsMemberIds.add(testAccountTeam.Team_Member_gne__c);
				}
				List<AccountShare> insertedAccountShares = [ SELECT Id FROM AccountShare WHERE AccountId = :testAccount.Id AND UserorGroupId IN :testAccountTeamsMemberIds ]; 
				
				System.assertNotEquals(null, insertedAccountShares);									  
				System.assertEquals(BATCH_SIZE, insertedAccountShares.size());		
				
				Test.startTest();
				delete testAccountTeams;
				Test.stopTest();
				
				insertedAccountShares = [ SELECT Id FROM AccountShare WHERE AccountId = :testAccount.Id AND UserorGroupId IN :testAccountTeamsMemberIds ]; 
				
				System.assertNotEquals(null, insertedAccountShares);									  
				System.assertEquals(0, insertedAccountShares.size());									 
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
}