/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-05
*  Description: This is a test class for GNE_SFA2_Product_Tactic_Trigger trigger
*  
*  Modification History
*  Date        	Name        		Description
*  2014-02-21   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Product_Tactic_Trigger_Test {
	
	public static Integer BATCH_SIZE = 201; 
	
	private static void insertTestCallsWithDiscussions(List<Product_Tactic_vod__c> tactics) {
		List<Call2_vod__c> testInteractions = new List<Call2_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			testInteractions.add(GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral'));
		}
		insert testInteractions;
		
		List<Call2_Discussion_vod__c> testDiscussions = new List<Call2_Discussion_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			Call2_Discussion_vod__c callD = GNE_SFA2_Triggers_Test_Util.prepareCall2_Discussion_vod(testInteractions[i].Id);
			callD.Product_Tactic_vod__c = tactics[i].Id;
			testDiscussions.add(callD);
		}
		insert testDiscussions;
	}
	
	private static List<Product_Tactic_vod__c> prepareTestProductTactics() {
		List<Product_Tactic_vod__c> tactics = new List<Product_Tactic_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			tactics.add(new Product_Tactic_vod__c());
		}
		insert tactics;
		return tactics;
	}
	
	public static testMethod void testProductTacticValidationRulesOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				List<Product_Tactic_vod__c> testTactics = prepareTestProductTactics();
				insertTestCallsWithDiscussions(testTactics);
				
				Test.startTest();
				try {
					delete testTactics;
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
}