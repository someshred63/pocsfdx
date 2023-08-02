/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-03
*  Description: This is a test class for GNE_SFA2_Account_Plan_Trigger trigger
*  
*  Modification History
*  Date        	Name       				Description
*  2014-02-18  	Piotr Przesmycki 		Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*  2015.07.09	Przemyslaw Giszczak		Modified Interaction_Type_gne__c in insertTestCalls
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Account_Plan_Trigger_Test {
	
	public static Integer BATCH_SIZE = 200;
	
	private static List<Account_Plan_vod__c> prepareTestAccountPlans(Account testAccount, String testTeam) {
		List<Account_Plan_vod__c> accountPlans = new List<Account_Plan_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			accountPlans.add(GNE_SFA2_Triggers_Test_Util.prepareAccount_Plan_vod(testAccount.Id, testTeam));
		}
		insert accountPlans;
		return accountPlans;
	}

	private static void insertTestCalls(List<Account_Plan_vod__c> accountPlans) {
		List<Call2_vod__c> testInteractions = new List<Call2_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			Call2_vod__c tempCall = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
			tempCall.Account_Plan_vod__c = accountPlans[i].Id;
			tempCall.Interaction_Type_gne__c = 'Planned';
			testInteractions.add(tempCall);
		}
		insert testInteractions;
	}
	
	private static Account insertTestAccount() {
		Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('test');
		testAccount.FirstName = 'test';
		insert testAccount;
		return testAccount;
	}
	
	public static testMethod void testAccountPlanValidationRulesOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account testAccount = insertTestAccount();
				Test.startTest();
				try {
					List<Account_Plan_vod__c> testAccountPlans = prepareTestAccountPlans(testAccount, null);
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Value_Required), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testAccountPlanValidationRulesOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account testAccount = insertTestAccount();
				List<Account_Plan_vod__c> testAccountPlans = prepareTestAccountPlans(testAccount, 'testTeam');
				insertTestCalls(testAccountPlans);

				Test.startTest();
				try {
					delete testAccountPlans;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Cannot_Delete_Object_Call_References), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();				
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testAccountPlanChildRecordUpdatesOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Account testAccount = insertTestAccount();
				List<Account_Plan_vod__c> testAccountPlans = prepareTestAccountPlans(testAccount, 'testTeam');
				Set<String> testAccountPlansIds = new Set<String>();
				for(Account_Plan_vod__c testAccountPlan : testAccountPlans) {
					testAccountPlansIds.add(testAccountPlan.Id);
				}
				
				Test.startTest();
				delete testAccountPlans;
				Test.stopTest();
				
				List<FRM_Deleted_Account_Plan_Tactic_gne__c> deletedAccountPlanes = [ SELECT Id FROM FRM_Deleted_Account_Plan_Tactic_gne__c WHERE Object_Name_gne__c = 'Account_Plan_vod__c' AND Record_Id_gne__c IN :testAccountPlansIds ]; 
				
				System.assertNotEquals(null, deletedAccountPlanes);									  
				System.assertEquals(BATCH_SIZE, deletedAccountPlanes.size());									 
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
}