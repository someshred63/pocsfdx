/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-01
*  Description: This is a test class for GNE_SFA2_Product_Strategy_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*  2014-02-21   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Product_Strategy_Trigger_Test {
	
	public static Integer BATCH_SIZE = 201; 
	
	private static void insertTestCallsWithDiscussions(List<Product_Strategy_vod__c> strategies) {
		List<Call2_vod__c> testInteractions = new List<Call2_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			testInteractions.add(GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral'));
		}
		insert testInteractions;
		
		List<Call2_Discussion_vod__c> testDiscussions = new List<Call2_Discussion_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			Call2_Discussion_vod__c callD = GNE_SFA2_Triggers_Test_Util.prepareCall2_Discussion_vod(testInteractions[i].Id);
			callD.Product_Strategy_vod__c = strategies[i].Id;
			testDiscussions.add(callD);
		}
		insert testDiscussions;
	}
	
	private static List<Product_Strategy_vod__c> prepareTestProductStrategies() {
		List<Product_Strategy_vod__c> stratiegies = new List<Product_Strategy_vod__c>();
		for(Integer i =0; i < BATCH_SIZE; i++) {
			stratiegies.add(new Product_Strategy_vod__c());
		}
		insert stratiegies;
		return stratiegies;
	}
	
	public static testMethod void testProductStrategyValidationRulesOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				List<Product_Strategy_vod__c> testStrategies = prepareTestProductStrategies();
				insertTestCallsWithDiscussions(testStrategies);
				
				Test.startTest();
				try {
					delete testStrategies;
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