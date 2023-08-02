@isTest(seeAllData=false)
private class AGS_EX_Account_Section_SFDC_Ext_Test{

	static testMethod void ccoAnalystTest(){

		Profile p = [select id from profile where name='GNE-AGS-CCO-Analyst'];
        User u = new User(alias = 'ccoAnaly', email='ccoAnalyst@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='ccoAnalyst@gene.com');

        System.runAs(u){
			Account acc = new Account(name = 'Test Account',AGS_EX_Exclusion_Status_base_gne__c = 'Not checked');
			insert acc;
			acc = [Select name,AGS_EX_Exclusion_Status_gne__c from Account where name='Test Account' limit 1];
			
			ApexPages.StandardController sc = new ApexPages.StandardController(acc);

			AGS_EX_Account_Section_SFDC_Ext ext = new AGS_EX_Account_Section_SFDC_Ext(sc);

			System.assertEquals(true,ext.isUserCCOAnalyst);
			System.assertEquals('Not Checked',acc.AGS_EX_Exclusion_Status_gne__c);
			System.assertEquals(true,ext.isExclusionNotChecked);
		}
	}

	static testMethod void notAnalystTest(){

		Account acc = new Account(name = 'Test Account');
		ApexPages.StandardController sc = new ApexPages.StandardController(acc);

		AGS_EX_Account_Section_SFDC_Ext ext = new AGS_EX_Account_Section_SFDC_Ext(sc);

		System.assertEquals(false,ext.isUserCCOAnalyst);

		ext.createExclusionCheck();
		System.assertEquals('/apex/AGS_EX_Exclusion_Update_SFDC?accId=' + acc.Id,ext.redirectUrl);
	}

	static testMethod void exclusionRequestTest(){

		Account acc = new Account(
            AGS_EX_Exclusion_Status_base_gne__c='Not Checked',Firstname='Exclusion',Lastname = 'Check',PersonEmail='test@roche.com', 
            recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Professional_vod').getRecordTypeId()
         );
		insert acc;
		insert new Contact(
			Firstname='Exclusion',
			Lastname = 'Check',
			Account = acc,
			Email='test@roche.com'
		);

		ApexPages.StandardController sc = new ApexPages.StandardController(acc);

		AGS_EX_Account_Section_SFDC_Ext ext = new AGS_EX_Account_Section_SFDC_Ext(sc);

		List<AGS_EX_Exclusion_Request_gne__c> exReq = new List<AGS_EX_Exclusion_Request_gne__c>([Select id from AGS_EX_Exclusion_Request_gne__c where AGS_EX_Account_Name_gne__c = :acc.Id]);
		System.assertEquals(0,exReq.size());

		System.assertEquals('',ext.getSubmittedDate());

		PageReference p = ext.createRequest();

		exReq = new List<AGS_EX_Exclusion_Request_gne__c>([Select id from AGS_EX_Exclusion_Request_gne__c where AGS_EX_Account_Name_gne__c = :acc.Id]);
		System.assertEquals(1,exReq.size());

		acc = [Select name,AGS_EX_Exclusion_Status_gne__c from Account where Id = :acc.Id limit 1];
		sc = new ApexPages.StandardController(acc);
		ext = new AGS_EX_Account_Section_SFDC_Ext(sc);

		System.assertEquals('Request Pending',[Select AGS_EX_Exclusion_Status_gne__c From Account where id=:acc.Id].AGS_EX_Exclusion_Status_gne__c);
		System.assertEquals('(Submitted on ' + Datetime.now().format('MM/dd/YYYY') +')',ext.getSubmittedDate());
	}
}