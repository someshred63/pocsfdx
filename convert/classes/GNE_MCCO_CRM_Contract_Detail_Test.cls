@isTest
public without sharing class GNE_MCCO_CRM_Contract_Detail_Test {
	
    public static testMethod void testCreateContractDate() {
		
		Id rt = [Select Id From RecordType Where sObjectType='Account' AND DeveloperName ='Professional_vod' Limit 1].Id;
		Account hcp1 = new Account(FirstName = 'John', LastName = 'Smith', RecordTypeId = rt);
		insert hcp1;
		
		Test.startTest();
			insert new GNE_CRM_Contract_Detail__c(Account__c = hcp1.Id);
			System.assertEquals(1, [ SELECT Id, (SELECT Id FROM GNE_CRM_Contract_Details__r ) FROM Account WHERE Id = :hcp1.Id ].GNE_CRM_Contract_Details__r.size());

			insert new GNE_CRM_Contract_Detail__c(Account__c = hcp1.Id);
			System.assertEquals(2, [ SELECT Id, (SELECT Id FROM GNE_CRM_Contract_Details__r ) FROM Account WHERE Id = :hcp1.Id ].GNE_CRM_Contract_Details__r.size());

			insert new GNE_CRM_Contract_Detail__c(Account__c = hcp1.Id);
			System.assertEquals(3, [ SELECT Id, (SELECT Id FROM GNE_CRM_Contract_Details__r ) FROM Account WHERE Id = :hcp1.Id ].GNE_CRM_Contract_Details__r.size());

			DMLException ex = null;
			try {
				insert new GNE_CRM_Contract_Detail__c(Account__c = hcp1.Id);
			} catch(DMLException e) {
				ex = e;
			}
			System.assertNotEquals(null,ex);
			System.assert(ex.getMessage().contains(System.Label.GNE_SFA2_MCCO_AM_Max_3_Contract_Details), ex.getMessage());
			System.assertEquals(3, [ SELECT Id, (SELECT Id FROM GNE_CRM_Contract_Details__r ) FROM Account WHERE Id = :hcp1.Id ].GNE_CRM_Contract_Details__r.size());
		Test.stopTest();
	}
}