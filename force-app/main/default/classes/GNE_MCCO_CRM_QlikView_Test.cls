@isTest
public without sharing class GNE_MCCO_CRM_QlikView_Test {
	
    public static testMethod void testEnv() {
		
		List<String> envs = new List<String>{'dev', 'sqa', 'uat', 'prod'};
		List<Environment_Variables__c> envsToInsert = new List<Environment_Variables__c>();
		
		for (String s : envs) {
			envsToInsert.add(
				new Environment_Variables__c(
					Description_Name__c = 'Dashboard URL',
					Environment__c = s,
					Key__c = 'GNE_MCCO_CRM_QlikView_Url',
					Type__c = 'Other',
					Value__c = 'sampleURL'
				)
			);
		}
		insert envsToInsert;
		
		GNE_MCCO_CRM_QlikView qv = new GNE_MCCO_CRM_QlikView();
		Test.startTest();
			System.assertEquals(qv.dashboardUrl, 'sampleURL');
		Test.stopTest();
	}
}