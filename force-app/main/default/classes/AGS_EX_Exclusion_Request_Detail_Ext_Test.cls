@isTest(seeAllData=false)
private class AGS_EX_Exclusion_Request_Detail_Ext_Test{

	static testMethod void saveExclusionCheckWithoutAttachmentTest(){

		Account acc = new Account(AGS_EX_Exclusion_Status_base_gne__c='Not Checked',Firstname='Exclusion',Lastname = 'Check',PersonEmail='test@roche.com',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Professional_vod').getRecordTypeId());
		insert acc;
		insert new Contact(
			Firstname='Exclusion',
			Lastname = 'Check',
			Account = acc,
			Email='test@roche.com'
		);
		AGS_EX_Exclusion_Utils.createRequest(acc);

		AGS_EX_Exclusion_Request_gne__c exReq = [Select AGS_EX_Account_Name_gne__c,AGS_EX_Account_Primary_Address_gne__c from AGS_EX_Exclusion_Request_gne__c where AGS_EX_Account_Name_gne__c=:acc.Id];
		ApexPages.StandardController sc = new ApexPages.StandardController(exReq);

		AGS_EX_Exclusion_Request_Detail_Ext ext = new AGS_EX_Exclusion_Request_Detail_Ext(sc);

		List<AGS_EX_Exclusion_Check_gne__c> exCheck = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c 
																							   where AGS_EX_Exclusion_Request_gne__c = :exReq.Id]);
		System.assertEquals(0,exCheck.size());

		PageReference pr = ext.saveExclusionCheck();

		exCheck = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c where AGS_EX_Exclusion_Request_gne__c = :exReq.Id]);
		System.assertEquals(0,exCheck.size());
		
		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Please select an exclusion status'));
	}

	static testMethod void saveExclusionCheckWithAttachmentTest(){

		Account acc = new Account(AGS_EX_Exclusion_Status_base_gne__c='Not Checked',Firstname='Exclusion',Lastname = 'Check',PersonEmail='test@roche.com',recordtypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Professional_vod').getRecordTypeId());
		insert acc;
		insert new Contact(
			Firstname='Exclusion',
			Lastname = 'Check',
			Account = acc,
			Email='test@roche.com'
		);

		AGS_EX_Exclusion_Utils.createRequest(acc);
		AGS_EX_Exclusion_Request_gne__c exReq = [Select AGS_EX_Account_Name_gne__c,AGS_EX_Account_Primary_Address_gne__c from AGS_EX_Exclusion_Request_gne__c where AGS_EX_Account_Name_gne__c=:acc.Id];
		
		ApexPages.StandardController sc = new ApexPages.StandardController(exReq);

		AGS_EX_Exclusion_Request_Detail_Ext ext = new AGS_EX_Exclusion_Request_Detail_Ext(sc);

		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		ext.attachmentFile = new Attachment(Body = b, Name='testFile.txt');
		ext.excCheck.AGS_EX_Status_gne__c = 'Sanctioned but legal approved';
		ext.excCheck.AGS_EX_Exclusion_Request_gne__c = exReq.Id;

		List<AGS_EX_Exclusion_Check_gne__c> exCheck = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c 
																							   where AGS_EX_Exclusion_Request_gne__c = :exReq.Id]);
		System.assertEquals(0,exCheck.size());

		PageReference pr = ext.saveExclusionCheck();

		exCheck = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c where AGS_EX_Exclusion_Request_gne__c = :exReq.Id]);
		System.assertEquals(1,exCheck.size());

		acc = [Select AGS_EX_Exclusion_Status_base_gne__c from Account where Id = :acc.Id Limit 1];
		System.assertEquals('Sanctioned but legal approved',acc.AGS_EX_Exclusion_Status_base_gne__c);

		exReq = [Select Id,AGS_EX_Account_Name_gne__c,AGS_EX_Account_Primary_Address_gne__c from AGS_EX_Exclusion_Request_gne__c where id = :exReq.Id];
		sc = new ApexPages.StandardController(exReq);
		ext = new AGS_EX_Exclusion_Request_Detail_Ext(sc);

		System.assert(ext.attchmentExist);
		System.assertEquals(exCheck[0].Id,ext.excCheck.Id);
	}

	static testMethod void saveExclusionCheckInProcessTest(){

		Account acc = new Account(Name='testAccount');
		insert acc;
		AGS_EX_Exclusion_Request_gne__c exReq = new AGS_EX_Exclusion_Request_gne__c(AGS_EX_Account_Name_gne__c=acc.Id,AGS_EX_Account_Primary_Address_gne__c='test address');
		insert exReq;

		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		Attachment att = new Attachment(Body = b, Name='testFile.txt');

		ApexPages.StandardController sc = new ApexPages.StandardController(exReq);

		AGS_EX_Exclusion_Request_Detail_Ext ext = new AGS_EX_Exclusion_Request_Detail_Ext(sc);

		ext.attachmentFile = att;
		List<SelectOption> statuses = ext.getStatuses();
		ext.excCheck.AGS_EX_Status_gne__c = statuses[0].getValue();
		ext.excCheck.AGS_EX_Exclusion_Request_gne__c = exReq.Id;

		List<AGS_EX_Exclusion_Check_gne__c> exCheck = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c 
																							   where AGS_EX_Exclusion_Request_gne__c = :exReq.Id]);
		System.assertEquals(0,exCheck.size());

		PageReference pr = ext.saveExclusionCheckInProcess();

		exCheck = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c where AGS_EX_Exclusion_Request_gne__c = :exReq.Id]);
		System.assertEquals(1,exCheck.size());
		List<AGS_EX_Exclusion_Request_gne__c> exRList = new List<AGS_EX_Exclusion_Request_gne__c>([Select id From AGS_EX_Exclusion_Request_gne__c 
																								  where id=:exReq.Id and AGS_EX_Request_Status_gne__c='In Progress' Limit 1]);
		System.assertEquals(1,exRList.size());
		acc = [Select AGS_EX_Exclusion_Status_base_gne__c from Account where name='testAccount' Limit 1];
		System.assertEquals('In Process',acc.AGS_EX_Exclusion_Status_base_gne__c);

		List<Attachment> atList = new List<Attachment>([Select id from Attachment where ParentId in :exCheck]);
		System.assertEquals(1,atList.size());
		ext.deleteAttachment();
		atList = new List<Attachment>([Select id from Attachment where ParentId in :exCheck]);
		System.assertEquals(0,atList.size());
	}

	static testMethod void methodsTest(){

		Account acc = new Account(Name='testAccount');
		insert acc;
		AGS_EX_Exclusion_Request_gne__c exReq = new AGS_EX_Exclusion_Request_gne__c(AGS_EX_Account_Name_gne__c=acc.Id,AGS_EX_Account_Primary_Address_gne__c='test address');
		insert exReq;

		ApexPages.StandardController sc = new ApexPages.StandardController(exReq);

		AGS_EX_Exclusion_Request_Detail_Ext ext = new AGS_EX_Exclusion_Request_Detail_Ext(sc);

		System.assertEquals(acc.Id,ext.getAccountId());
		System.assertEquals(false,ext.getIsAnyAffiliation());
		System.assertEquals(false,ext.getIsAnyRequestor());
		System.assertEquals(false,ext.getIsAnyMRC());

		ext.cancelExclusionCheck();
	}

}