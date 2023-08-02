@isTest
public with sharing class GNE_SFA2_Affiliation_Ext_Test {

	@isTest
	public static void testEdit() {
		Account fromAccount = createSampleAccount('fromAccount');
		Account toAccount = createSampleAccount('toAccount');
		Affiliation_vod__c affiliation = createAffiliation(fromAccount, toAccount);
		ApexPages.StandardController standardController = new ApexPages.StandardController(affiliation);
		GNE_SFA2_Affiliation_Ext customController = new GNE_SFA2_Affiliation_Ext(standardController);
		Test.startTest();
		PageReference pageReference = customController.edit();
		Test.stopTest();
		String retURL =  System.currentPageReference().getParameters().get('retURL');
		System.assertEquals('/apex/GNE_SFA2_Affiliation_Edit_Create_Layout?id='+customController.myObject.Id+'&retURL='+retURL, pageReference.getUrl());
	}

	private static Affiliation_vod__c createAffiliation(Account fromAccount, Account toAccount) {
		Affiliation_vod__c affiliation = new Affiliation_vod__c(From_Account_vod__c = fromAccount.Id, To_Account_vod__c = toAccount.Id);
	 	insert affiliation;
	 	return affiliation;
	}

	private static Account createSampleAccount(String name) {
		Account account = new Account(Name = name);
		insert account;
		return account;
	}
}