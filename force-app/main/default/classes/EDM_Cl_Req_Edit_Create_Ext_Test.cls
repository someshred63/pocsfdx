@isTest(seeAllData=false)
private class EDM_Cl_Req_Edit_Create_Ext_Test{
	
	static testMethod void crSaveAlreadySubmittedRequestTest(){
		
		Account acc = new Account(Name='testAccount');
		insert acc;
		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id,EDM_Type_of_Classification_gne__c = 'Business');
		insert req;

		ApexPages.StandardController sc = new ApexPages.StandardController(req);

		Test.setCurrentPage(new PageReference('apex/EDM_Classification_Request_gne__c'));
		ApexPages.currentPage().getParameters().put('accountId',acc.Id);
		ApexPages.currentPage().getParameters().put('typeOfClassification','Business');

		EDM_Cl_Req_Edit_Create_Ext ext = new EDM_Cl_Req_Edit_Create_Ext(sc);

		ext.save();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size(),msgs);
		System.assert(msgs[0].getDetail().contains('Request for this Account has already been submitted'));
	}

	static testMethod void crSaveNoCVTest(){
		
		Account acc = new Account(Name='testAccount');
		insert acc;
		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(req);

		Test.setCurrentPage(new PageReference('apex/EDM_Classification_Request_gne__c'));
		ApexPages.currentPage().getParameters().put('accountId',acc.Id);
		ApexPages.currentPage().getParameters().put('typeOfClassification','Business');

		EDM_Cl_Req_Edit_Create_Ext ext = new EDM_Cl_Req_Edit_Create_Ext(sc);

		ext.save();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size(),msgs);
		System.assert(msgs[0].getDetail().contains('Please choose a CV to upload'));
	}

	static testMethod void crUnknownAccountTest(){
		
		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(req);

		Test.setCurrentPage(new PageReference('apex/EDM_Classification_Request_gne__c'));
		ApexPages.currentPage().getParameters().put('typeOfClassification','Business');

		EDM_Cl_Req_Edit_Create_Ext ext = new EDM_Cl_Req_Edit_Create_Ext(sc);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size(),msgs);
		System.assert(msgs[0].getDetail().contains('Account need to be provided by URL'));
	}

	static testMethod void crUnknownTypeOfClassificationTest(){
		
		Account acc = new Account(Name='testAccount');
		insert acc;
		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(req);

		Test.setCurrentPage(new PageReference('apex/EDM_Classification_Request_gne__c'));
		ApexPages.currentPage().getParameters().put('accountId',acc.Id);

		EDM_Cl_Req_Edit_Create_Ext ext = new EDM_Cl_Req_Edit_Create_Ext(sc);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size(),msgs);
		System.assert(msgs[0].getDetail().contains('Unknown record type:'));
	}

	static testMethod void crSaveWithCVTest(){
		
		Account acc = new Account(Name='testAccount');
		insert acc;
		Address_vod__c address = new Address_vod__c(City_vod__c = 'Test City',Account_vod__c = acc.Id);
		insert address;
		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(req);

		Test.setCurrentPage(new PageReference('apex/EDM_Classification_Request_gne__c'));
		ApexPages.currentPage().getParameters().put('accountId',acc.Id);
		ApexPages.currentPage().getParameters().put('typeOfClassification','Business');

		EDM_Cl_Req_Edit_Create_Ext ext = new EDM_Cl_Req_Edit_Create_Ext(sc);

		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		ext.attachmentCV = new Attachment(Body = b, Name='testFile.txt');

		ext.save();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		System.assertEquals(1,msgs.size(),msgs);
		System.assert(msgs[0].getDetail().contains('Classification request has been submitted'));

		List<EDM_Classification_Request_gne__c> crs = new List<EDM_Classification_Request_gne__c>([SELECT id FROM EDM_Classification_Request_gne__c WHERE EDM_Account_gne__c = :acc.Id]);
		System.assertEquals(1,crs.size());
	}

	static testMethod void crCancelTest(){
		
		Account acc = new Account(Name='testAccount');
		insert acc;
		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

		ApexPages.StandardController sc = new ApexPages.StandardController(req);

		Test.setCurrentPage(new PageReference('apex/EDM_Classification_Request_gne__c'));
		ApexPages.currentPage().getParameters().put('accountId',acc.Id);
		ApexPages.currentPage().getParameters().put('typeOfClassification','Business');

		EDM_Cl_Req_Edit_Create_Ext ext = new EDM_Cl_Req_Edit_Create_Ext(sc);

		PageReference pr = ext.cancel();

		System.assertEquals('/'+acc.Id,pr.getUrl());
	}
	
	static testMethod void crInNominationProcessTest(){
		
		Account acc = new Account(Name='testAccount');
		insert acc;
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Type_gne__c = 'Business', Speaker_Category_gne__c = 'Physicians');
		insert sb;
		Questionnaire_gne__c q = new Questionnaire_gne__c(Category_gne__c = 'Physicians', Ready_for_use_gne__c = true);
		insert q;
		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();

		EDM_Classification_Request_gne__c request = new EDM_Classification_Request_gne__c(EDM_Account_gne__c = acc.Id, 
																						  EDM_Status_gne__c = 'Completed', 
																						  EDM_Type_of_Classification_gne__c='Business');
		insert request;

		ApexPages.StandardController sc = new ApexPages.StandardController(req);

		Test.setCurrentPage(new PageReference('apex/EDM_Classification_Request_gne__c'));
		ApexPages.currentPage().getParameters().put('accountId',acc.Id);
		ApexPages.currentPage().getParameters().put('typeOfClassification','Business');
		ApexPages.currentPage().getParameters().put('nomination','true');
		ApexPages.currentPage().getParameters().put('bureauId',sb.Id);
		EDM_Cl_Req_Edit_Create_Ext ext = new EDM_Cl_Req_Edit_Create_Ext(sc);
		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		ext.attachmentCV = new Attachment(Body = b, Name='testFile.txt');

		PageReference pr = ext.save();

		System.assertEquals('/apex/GNE_SFA2_Account_Dispatcher?id='+acc.Id+'&nomination=true',pr.getURL());
	}

	@isTest 
	public static void shouldSaveSBMWithClassifRequest() {
		//given
		Account verifiedAccount = createVerifiedAndClearAccountWithoutClassification();
		Speaker_Bureau_gne__c clinicalBureau = createClinicalBuerau();
		createQuestionnaire();

		EDM_Classification_Request_gne__c req = new EDM_Classification_Request_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(req);
		Test.setCurrentPage(new PageReference('apex/EDM_Classification_Request_Edit_Create'));
		ApexPages.currentPage().getParameters().put('accountId', verifiedAccount.Id);
		ApexPages.currentPage().getParameters().put('typeOfClassification','Clinical');
		ApexPages.currentPage().getParameters().put('nomination','true');
		ApexPages.currentPage().getParameters().put('bureauId', clinicalBureau.Id);
		EDM_Cl_Req_Edit_Create_Ext ext = new EDM_Cl_Req_Edit_Create_Ext(stdCtrl);
		ext.attachmentCV = createAttachment();


		//when
		ext.save();

		//then
		System.assertEquals(1, [SELECT Id FROM Speaker_Bureau_Membership_gne__c WHERE Bureau_Member_gne__c = :verifiedAccount.Id].size());
		System.assertEquals(1, [SELECT Id FROM EDM_Classification_Request_gne__c WHERE EDM_Account_gne__c = :verifiedAccount.Id].size());
	}

	private static Account createVerifiedAndClearAccountWithoutClassification() {
		Account acc = new Account(Name='testAccount', 
									AGS_EX_Exclusion_Status_base_gne__c = 'Verified and clear', 
									EDM_Clinical_Classification_gne__c = 'Not Classified',
									EDM_Business_Classification_gne__c = 'Not Classified');
		insert acc;
		return acc;
	}

	private static Speaker_Bureau_gne__c createClinicalBuerau() {
		Speaker_Bureau_gne__c sb = new Speaker_Bureau_gne__c(Speaker_Bureau_Type_gne__c = 'Clinical', Speaker_Category_gne__c = 'Physicians');
		insert sb;
		return sb;
	}

	private static Questionnaire_gne__c createQuestionnaire() {
		Questionnaire_gne__c q = new Questionnaire_gne__c(Category_gne__c = 'Physicians', Ready_for_use_gne__c = true);
		insert q;
		return q;
	}

	private static Attachment createAttachment() {
		String body = 'Test Method Call';
		Blob b = Blob.valueOf(body);
		return new Attachment(Body = b, Name='testFile.txt');
	}
}