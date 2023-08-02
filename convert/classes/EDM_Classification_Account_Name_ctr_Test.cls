@isTest(seeAllData=false)
private class EDM_Classification_Account_Name_ctr_Test{

	static testMethod void getAccountNameTest(){
		
		Account acc = new Account(Name='testAccount');
		insert acc;
		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id);
		insert req;

		EDM_Classification_Account_Name_ctrl ctrl = new EDM_Classification_Account_Name_ctrl();

		ctrl.requestId = req.Id;

		System.assertEquals('testAccount',ctrl.getAccountName());

		ctrl.requestId = 'wrong ID';

		System.assertEquals('',ctrl.getAccountName());
	}
}