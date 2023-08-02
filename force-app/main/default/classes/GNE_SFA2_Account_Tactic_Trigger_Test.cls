/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-03
*  Description: This is a test class for GNE_SFA2_Account_Tactic_Trigger trigger
*  
*  Modification History
*  Date        Name        		Description
*  2014-02-18  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Account_Tactic_Trigger_Test {
	
	public static Integer BATCH_SIZE = 201;
	
	private static List<Account_Tactic_vod__c> prepareTestAccountTactics(Account testAccount) {
		List<Account_Tactic_vod__c> accountTactics = new List<Account_Tactic_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			accountTactics.add(GNE_SFA2_Triggers_Test_Util.prepareAccount_Tactic_vod(testAccount.Id));
		}
		insert accountTactics;
		return accountTactics;
	}
	
	private static Account insertTestAccount() {
		Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('test');
		testAccount.FirstName = 'test';
		insert testAccount;
		return testAccount;
	}
	
	public static testMethod void testAccountTacticChildRecordUpdatesOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account testAccount = insertTestAccount();
				List<Account_Tactic_vod__c> testAccountTactics = prepareTestAccountTactics(testAccount);
				Set<String> testAccountTecticIds = new Set<String>();
				for(Account_Tactic_vod__c testAccountTactic : testAccountTactics) {
					testAccountTecticIds.add(testAccountTactic.Id);
				}
				
				Test.startTest();
				delete testAccountTactics;
				Test.stopTest();
				
				List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedAccountTactics = [ SELECT Id FROM FRM_Deleted_Account_Plan_Tactic_gne__c WHERE Object_Name_gne__c = 'Account_Tactic_vod__c' AND Record_Id_gne__c IN :testAccountTecticIds ]; 
				
				System.assertNotEquals(null, deletedAccountTactics);									  
				System.assertEquals(BATCH_SIZE, deletedAccountTactics.size());									 
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
}