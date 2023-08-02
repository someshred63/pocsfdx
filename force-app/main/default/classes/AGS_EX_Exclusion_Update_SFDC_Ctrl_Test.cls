@isTest
private class AGS_EX_Exclusion_Update_SFDC_Ctrl_Test{

	static testMethod void notFoundAccount(){

		ApexPages.currentPage().getParameters().put('accId','wrongAccountID');

    	AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Did not find Account! Are you sure you came here from Account page?'));
	}

	static testMethod void missingAccountId(){

		
    	AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size());
		System.assert(msgs[0].getDetail().contains('Missing Account ID! Are you sure you came here from Account page?'));
	}

	static testMethod void errorWhileSavingExCheck(){

    	Account acc = new Account(Name='testAccount',AGS_EX_Exclusion_Status_base_gne__c='Not Checked');
		insert acc;		

    	ApexPages.currentPage().getParameters().put('accId',(String)acc.Id);
		AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();

		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		ext.attachmentFile = new Attachment(Body = b, Name='testFile.txt');

		ext.saveExclusionCheck();

		List<Apexpages.Message> msgs = ApexPages.getMessages();

		System.assertEquals(2,msgs.size(),msgs);
		System.assert(msgs[0].getDetail().contains('Please select an exclusion status'));
		System.assert(msgs[1].getDetail().contains('Could not save new Exclusion Check'));
	}

    static testMethod void saveExclusionCheckWithAttachment_Excluded(){

    	Account acc = new Account(Name='testAccount',AGS_EX_Exclusion_Status_base_gne__c='Not Checked');
		insert acc;		

    	ApexPages.currentPage().getParameters().put('accId',(String)acc.Id);
		AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();

		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		ext.attachmentFile = new Attachment(Body = b, Name='testFile.txt');

		List<SelectOption> statuses = ext.getStatuses();
		ext.checkStatus = statuses[0].getValue();
		System.assertEquals('Excluded',ext.checkStatus);

		ext.saveExclusionCheck();

		List<AGS_EX_Exclusion_Request_gne__c> exR = new List<AGS_EX_Exclusion_Request_gne__c>([Select id from AGS_EX_Exclusion_Request_gne__c where AGS_EX_Account_Name_gne__c = :acc.Id]);
		System.assertEquals(1,exR.size());
		List<AGS_EX_Exclusion_Check_gne__c> exC = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c where AGS_EX_Exclusion_Request_gne__c in :exR]);
		System.assertEquals(1,exC.size());

		acc = [Select AGS_EX_Exclusion_Status_base_gne__c from Account where name='testAccount' Limit 1];
		System.assertEquals('Excluded',acc.AGS_EX_Exclusion_Status_base_gne__c);

	}

	static testMethod void saveExclusionCheckWithAttachment_Sancioned(){

    	Account acc = new Account(Name='testAccount',AGS_EX_Exclusion_Status_base_gne__c='Not Checked');
		insert acc;		

    	ApexPages.currentPage().getParameters().put('accId',(String)acc.Id);
		AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();

		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		ext.attachmentFile = new Attachment(Body = b, Name='testFile.txt');

		List<SelectOption> statuses = ext.getStatuses();
		ext.checkStatus = statuses[1].getValue();
		System.assertEquals('Sanctioned but legal approved',ext.checkStatus);

		ext.saveExclusionCheck();

		List<AGS_EX_Exclusion_Request_gne__c> exR = new List<AGS_EX_Exclusion_Request_gne__c>([Select id from AGS_EX_Exclusion_Request_gne__c where AGS_EX_Account_Name_gne__c = :acc.Id]);
		System.assertEquals(1,exR.size());
		List<AGS_EX_Exclusion_Check_gne__c> exC = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c where AGS_EX_Exclusion_Request_gne__c in :exR]);
		System.assertEquals(1,exC.size());

		acc = [Select AGS_EX_Exclusion_Status_base_gne__c from Account where name='testAccount' Limit 1];
		System.assertEquals('Sanctioned but legal approved',acc.AGS_EX_Exclusion_Status_base_gne__c);

	}

	static testMethod void saveExclusionCheckWithAttachment_Verified(){

    	Account acc = new Account(Name='testAccount',AGS_EX_Exclusion_Status_base_gne__c='Not Checked');
		insert acc;		

    	ApexPages.currentPage().getParameters().put('accId',(String)acc.Id);
		AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();

		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		ext.attachmentFile = new Attachment(Body = b, Name='testFile.txt');

		List<SelectOption> statuses = ext.getStatuses();
		ext.checkStatus = statuses[2].getValue();
		System.assertEquals('Verified and clear',ext.checkStatus);

		ext.saveExclusionCheck();

		List<AGS_EX_Exclusion_Request_gne__c> exR = new List<AGS_EX_Exclusion_Request_gne__c>([Select id from AGS_EX_Exclusion_Request_gne__c where AGS_EX_Account_Name_gne__c = :acc.Id]);
		System.assertEquals(1,exR.size());
		List<AGS_EX_Exclusion_Check_gne__c> exC = new List<AGS_EX_Exclusion_Check_gne__c>([Select id from AGS_EX_Exclusion_Check_gne__c where AGS_EX_Exclusion_Request_gne__c in :exR]);
		System.assertEquals(1,exC.size());

		acc = [Select AGS_EX_Exclusion_Status_base_gne__c from Account where name='testAccount' Limit 1];
		System.assertEquals('Verified and clear',acc.AGS_EX_Exclusion_Status_base_gne__c);

	}

	/*static testMethod void saveExclusionCheckWithoutAttachmentTest(){

    	Account acc = new Account(Name='testAccount',AGS_EX_Exclusion_Status_base_gne__c='Not Checked');
		insert acc;		

    	ApexPages.currentPage().getParameters().put('accId',(String)acc.Id);
		AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();
		
		List<SelectOption> statuses = ext.getStatuses();
		ext.checkStatus = statuses[2].getValue();

		ext.saveExclusionCheck();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size(),msgs);
		System.assert(msgs[0].getDetail().contains('Please choose a file to upload'));
	}	*/

	static testMethod void methodsTest(){

		Account acc = new Account(Name='testAccount');
		insert acc;

		ApexPages.currentPage().getParameters().put('accId',(String)acc.Id);
		AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();

		System.assertEquals(false,ext.getIsAnyAffiliation());
		System.assertEquals(false,ext.getIsAnyMRC());

		ext.cancelExclusionCheck();
	}

	static testMethod void attachmentTest(){

		Account acc = new Account(Name='testAccount');
		insert acc;

		ApexPages.currentPage().getParameters().put('accId',(String)acc.Id);
		AGS_EX_Exclusion_Update_SFDC_Ctrl ext = new AGS_EX_Exclusion_Update_SFDC_Ctrl();

		System.assertEquals('',AGS_EX_Exclusion_Update_SFDC_Ctrl.insertCvAttachmentAndSaveURL(ext.newExCheck, ext.attachmentFile));
	}

}