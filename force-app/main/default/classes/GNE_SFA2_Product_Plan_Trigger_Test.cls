/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-03
*  Description: This is a test class for GNE_SFA2_Product_Plan_Trigger trigger
*  
*  Modification History
*  Date        	Name        		Description
*  2014-02-21   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Product_Plan_Trigger_Test {
	
	public static Integer BATCH_SIZE = 201; 
	
	private static List<Product_Strategy_vod__c> prepareTestProductStrategies(List<Product_Plan_vod__c> testProductPlans) {
		List<Product_Strategy_vod__c> stratiegies = new List<Product_Strategy_vod__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			Product_Strategy_vod__c ps = GNE_SFA2_Triggers_Test_Util.prepareProduct_Strategy_vod();
			ps.Product_Plan_vod__c = testProductPlans[i].Id;
			stratiegies.add(ps);
		}
		insert stratiegies;
		return stratiegies;
	}
	
	private static List<Product_Plan_vod__c> prepareTestProductPlans() {
		List<Product_Plan_vod__c> productPlan = new List<Product_Plan_vod__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			productPlan.add(new Product_Plan_vod__c());
		}
		insert productPlan;
		return productPlan;
	}
	
	public static testMethod void testProductPlanValidationRulesOnDelete() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				List<Product_Plan_vod__c> testProductPlans = prepareTestProductPlans();
				prepareTestProductStrategies(testProductPlans);
				Test.startTest();
				try {
					delete testProductPlans;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.GNE_SFA2_Product_Plan_Cannot_Delete), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
				Test.stopTest();
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
}