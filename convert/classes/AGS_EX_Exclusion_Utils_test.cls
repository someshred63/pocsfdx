@isTest(seeAllData=false)
private class AGS_EX_Exclusion_Utils_test{

	static testMethod void multipleRequestsTest(){

		List<Account> accounts = new List<Account>();
		List<Contact> contacts = new List<Contact>();
		for(Integer i=0;i<=4;i++){
			Account a = new Account(AGS_EX_Exclusion_Status_base_gne__c='Not Checked',Firstname='Exclusion',Lastname = 'Check',PersonEmail='test@roche.com',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Professional_vod').getRecordTypeId());
			accounts.add(a);
		}
		insert accounts;	

		for(Account a : accounts){
			Contact c = new Contact(Firstname='Exclusion',Lastname = 'Check',Account = a,Email='test@roche.com');
			contacts.add(c);
		}
		insert contacts;

		List<String> ids = new List<String>();
		for(Account a : accounts){
			ids.add(a.Id);
		}
		List<AGS_EX_Exclusion_Request_gne__c> req = new List<AGS_EX_Exclusion_Request_gne__c>([Select id from AGS_EX_Exclusion_Request_gne__c 
			                                                                                   where AGS_EX_Account_Name_gne__c in :accounts]);
		System.assertEquals(0,req.size());

		AGS_EX_Exclusion_Utils.createMultipleRequests(ids);

		req = new List<AGS_EX_Exclusion_Request_gne__c>([Select id from AGS_EX_Exclusion_Request_gne__c 
			                                             where AGS_EX_Account_Name_gne__c in :accounts]);
		System.assertEquals(5,req.size());
	}
}