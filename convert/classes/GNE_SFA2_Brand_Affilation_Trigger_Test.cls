/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-12
*  Description: This is a test class for GNE_SFA2_Brand_Affiliation_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Brand_Affilation_Trigger_Test {
	public static testMethod void testUniqueKeyFieldUpdateOnInsert() {
		GNE_SFA2_Util.setTriggerDisabledForCurrentUser('GNE_SFA2_Account_Trigger', true);
		List<Account> testAccounts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestAccounts();		
		
		List<Product_vod__c> testProducts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestProducts();
		
        Test.startTest();
			List<Product_Metrics_vod__c> testBrandAffiliations = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestBrandAffiliations(testAccounts, testProducts);
		Test.stopTest();
        
		testBrandAffiliations = [ SELECT Unique_Key_gne__c FROM Product_Metrics_vod__c WHERE Id in :testBrandAffiliations ];
		
		for(Integer i = 0; i < testBrandAffiliations.size(); i++) {		
			System.assertNotEquals(null, testBrandAffiliations[i].Unique_Key_gne__c);
			String accountId = String.valueOf(testAccounts[i].Id);
			String productId =  String.valueOf(testProducts[i].Id);
			System.assertEquals(accountId + '-' + productId , testBrandAffiliations[i].Unique_Key_gne__c);
		}
	}
	
	public static testMethod void testUniqueKeyFieldUpdateOnUpdate() {
		GNE_SFA2_Util.setTriggerDisabledForCurrentUser('GNE_SFA2_Account_Trigger', true);
		List<Account> testAccounts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestAccounts();		
		
		List<Product_vod__c> testProducts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestProducts();
		List<Product_vod__c> testProducts2 = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestProducts();		
        
		List<Product_Metrics_vod__c> testBrandAffiliations = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestBrandAffiliations(testAccounts, testProducts);		
        
		testBrandAffiliations = [ SELECT Unique_Key_gne__c FROM Product_Metrics_vod__c WHERE Id in :testBrandAffiliations ];
		
		for(Integer i = 0; i < testBrandAffiliations.size(); i++) {		
			System.assertNotEquals(null, testBrandAffiliations[i].Unique_Key_gne__c);
			String accountId = String.valueOf(testAccounts[i].Id);
			String productId =  String.valueOf(testProducts[i].Id);
			System.assertEquals(accountId + '-' + productId , testBrandAffiliations[i].Unique_Key_gne__c);
		}
		
		for(Integer i = 0; i < testBrandAffiliations.size(); i++) {	
			testBrandAffiliations[i].Products_vod__c = testProducts2[i].Id;
		}
        
		Test.startTest();
			update testBrandAffiliations;
        Test.stopTest();
        
		testBrandAffiliations = [ SELECT Unique_Key_gne__c FROM Product_Metrics_vod__c WHERE Id in :testBrandAffiliations ];
		for(Integer i = 0; i < testBrandAffiliations.size(); i++) {		
			System.assertNotEquals(null, testBrandAffiliations[i].Unique_Key_gne__c);
			String accountId = String.valueOf(testAccounts[i].Id);
			String productId =  String.valueOf(testProducts2[i].Id);
			System.assertEquals(accountId + '-' + productId , testBrandAffiliations[i].Unique_Key_gne__c);
		}
	}
	
	public static testMethod void testSpeakerContractFieldUpdateOnInsert() {
		GNE_SFA2_Util.setTriggerDisabledForCurrentUser('GNE_SFA2_Account_Trigger', true);
		List<Account> testAccounts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestAccounts();		
		List<Product_vod__c> testProducts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestProducts();
		List<Speaker_Contract_gne__c> testSpeakerContracts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestSpeakerContracts(testAccounts);
		List<Speaker_Bureau_gne__c> testSpeakerBureaus = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestSpeakerBureaus();
		List<Speaker_Bureau_Membership_gne__c> testSpeakerBureauMemberships = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestSpeakerBureausMemberships(testSpeakerBureaus, testAccounts);
		List<Speaker_Bureau_Product_gne__c> testSpeakerBureauProducts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestSpeakerBureauProducts(testSpeakerBureaus, testProducts);
		
        Test.startTest();
		List<Product_Metrics_vod__c> testBrandAffiliations = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestBrandAffiliations(testAccounts, testProducts);
		Test.stopTest();
		testBrandAffiliations = [ SELECT Unique_Key_gne__c, Speaker_Contract__c FROM Product_Metrics_vod__c WHERE Id in :testBrandAffiliations ];
		
		for(Integer i = 0; i < testBrandAffiliations.size(); i++) {		
			System.assertNotEquals(null, testBrandAffiliations[i].Speaker_Contract__c);
			System.assertEquals(testSpeakerContracts[i].Id, testBrandAffiliations[i].Speaker_Contract__c);
		}
	}
	
	public static testMethod void testSpeakerContractFieldUpdateOnUpdate() {
		GNE_SFA2_Util.setTriggerDisabledForCurrentUser('GNE_SFA2_Account_Trigger', true);
		List<Account> testAccounts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestAccounts();		
		List<Product_vod__c> testProducts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestProducts();
		List<Speaker_Bureau_gne__c> testSpeakerBureaus = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestSpeakerBureaus();
		List<Speaker_Bureau_Membership_gne__c> testSpeakerBureauMemberships = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestSpeakerBureausMemberships(testSpeakerBureaus, testAccounts);
		List<Speaker_Bureau_Product_gne__c> testSpeakerBureauProducts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestSpeakerBureauProducts(testSpeakerBureaus, testProducts);
		
        Test.startTest();
		List<Product_Metrics_vod__c> testBrandAffiliations = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestBrandAffiliations(testAccounts, testProducts);
		Test.stopTest();
        
		testBrandAffiliations = [ SELECT Speaker_Contract__c FROM Product_Metrics_vod__c WHERE Id in :testBrandAffiliations ];
		
		for(Integer i = 0; i < testBrandAffiliations.size(); i++) {		
			System.assertEquals(null, testBrandAffiliations[i].Speaker_Contract__c);
		}
		
		List<Speaker_Contract_gne__c> testSpeakerContracts = GNE_SFA2_Brand_Affiliation_Test_Helper.prepareTestSpeakerContracts(testAccounts);
		update testBrandAffiliations;
		testBrandAffiliations = [ SELECT Speaker_Contract__c FROM Product_Metrics_vod__c WHERE Id in :testBrandAffiliations ];
		
		for(Integer i = 0; i < testBrandAffiliations.size(); i++) {		
			System.assertNotEquals(null, testBrandAffiliations[i].Speaker_Contract__c);
			System.assertEquals(testSpeakerContracts[i].Id, testBrandAffiliations[i].Speaker_Contract__c);
		}
	}
}