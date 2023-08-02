@isTest
private class gFRS_AttachmentUploadUtilTest {

	class TestSettings {

			Account testAccount;
			GFRS_Organization__c testOrganization;
			GFRS_Location__c testLocation;
			GFRS_Funding_Request__c FundingRequest;

	    public TestSettings(Boolean isRFI){
	    	gFRS_UnitTestHelper.setGfrsCustomSettings(false);
				this.testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
				this.testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
				this.testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
				if (isRFI) {
					setUpFIEFundingRequestInRFI();
				}	else {
					setUpFIEFundingRequest();
				}
	    }

			private GFRS_Funding_Request__c setUpFIEFundingRequest(){
				this.FundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS, 'Intake', 'Not Submitted', 'Not Submitted','',testOrganization.Id, testLocation.Id);
				insert FundingRequest;
				this.FundingRequest = [select id from GFRS_Funding_Request__c where id=:FundingRequest.Id];
				return this.FundingRequest;
			}
			private GFRS_Funding_Request__c setUpFIEFundingRequestInRFI(){
				String infoNeeded = gFRS_Util.INFO_NEEDED_ORGANIZATION + ';' + gFRS_Util.INFO_NEEDED_LOCATION + ';' + gFRS_Util.INFO_NEEDED_APPLICATION + ';' + gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS;
				this.FundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS, 'Intake', 'Not Submitted', 'Not Submitted',infoNeeded,testOrganization.Id, testLocation.Id);
				insert FundingRequest;
				User testUser = gFRS_UnitTestHelper.createUserWithSpecificProfile([select Id, Name from Profile where Name='GNE-GFRS-Grant Coordinator'].Id);
				gFRS_Tasks__c t = gFRS_TestCreationUtils.createTask2(FundingRequest.id,'In Progress',testUser.id);
				t.Action_Type__c = gFRS_Util.REQUEST_STATUS_RFI;
				upsert t;
				this.FundingRequest = [select id from GFRS_Funding_Request__c where id=:FundingRequest.Id];
				return this.FundingRequest;
			}

			private Attachment createAttachment(Boolean toBeInserted) {
	    	Blob b = Blob.valueOf('Test Data');
	    	Attachment att = new Attachment();
				att.Body = b;
				att.Name = 'testName';
				if (toBeInserted) {
					att.ParentId = this.FundingRequest.Id;
	    	 	insert(att);
				}
				return att;
	    }

	}

	static testMethod void testUploadAttNew() {
			TestSettings settings = new TestSettings(false);
			Attachment att = settings.createAttachment(false);
			Test.startTest();
				Attachment newAtt = gFRS_AttachmentUploadUtil.uploadAttachment(settings.FundingRequest.Id, settings.FundingRequest.Id, 'Letter_of_Request__c', att, false);
				Id attId = [select id, Letter_of_Request__c from GFRS_Funding_Request__c where id = :settings.FundingRequest.Id].Letter_of_Request__c;
				Attachment newAttFull = [select id, Body from Attachment where id=:attId];
				System.assertEquals(attId,newAtt.id);
				System.assert(newAtt.Body==null);
				System.assert(newAttFull.Body.size()>0);
			Test.stopTest();
	}
	static testMethod void testUploadAttExist() {
			TestSettings settings = new TestSettings(false);
			Attachment att = settings.createAttachment(true);
			Test.startTest();
				Attachment newAtt = gFRS_AttachmentUploadUtil.uploadAttachment(settings.FundingRequest.Id, settings.FundingRequest.Id, 'Letter_of_Request__c', att, false);
				Id attId = [select id, Letter_of_Request__c from GFRS_Funding_Request__c where id = :settings.FundingRequest.Id].Letter_of_Request__c;
				Attachment newAttFull = [select id, Body from Attachment where id=:attId];
				System.assertEquals(attId,newAtt.id);
				System.assert(newAtt.Body==null);
				System.assert(newAttFull.Body.size()>0);
			Test.stopTest();
	}
	static testMethod void testUploadAttExistRFI() {
			TestSettings settings = new TestSettings(true);
			Attachment att = settings.createAttachment(true);
			Test.startTest();
				Attachment newAtt = gFRS_AttachmentUploadUtil.uploadAttachment(settings.FundingRequest.Id, settings.FundingRequest.Id, 'Letter_of_Request__c', att, true);
				Id attId = [select id, Letter_of_Request__c from GFRS_Funding_Request__c where id = :settings.FundingRequest.Id].Letter_of_Request__c;
				Attachment newAttFull = [select id, Body from Attachment where id=:attId];
				System.assertEquals(attId,newAtt.id);
				System.assert(newAtt.Body==null);
				System.assert(newAttFull.Body.size()>0);
			Test.stopTest();
	}
	static testMethod void testUploadAttNewRFI() {
			TestSettings settings = new TestSettings(true);
			Attachment att = settings.createAttachment(false);
			Test.startTest();
				Attachment newAtt = gFRS_AttachmentUploadUtil.uploadAttachment(settings.FundingRequest.Id, settings.FundingRequest.Id, 'Letter_of_Request__c', att, true);
				Id attId = [select id, Letter_of_Request__c from GFRS_Funding_Request__c where id = :settings.FundingRequest.Id].Letter_of_Request__c;
				Attachment newAttFull = [select id, Body from Attachment where id=:attId];
				System.assertEquals(attId,newAtt.id);
				System.assert(newAtt.Body==null);
				System.assert(newAttFull.Body.size()>0);
			Test.stopTest();
	}
	static testMethod void testUploadAttNewProg() {
			TestSettings settings = new TestSettings(false);
			Attachment att = settings.createAttachment(false);
			GFRS_Content__c cont = new GFRS_Content__c();
			cont.Filter__c = 'Gcal_Header';
			cont.Name = 'Gcal_Header';
			insert new List<GFRS_Content__c>{cont};
			GFRS_Content_Translation__c contTrans = new GFRS_Content_Translation__c();
			contTrans.GFRS_Content__c = cont.Id;
			contTrans.Language__c ='en_US';
			contTrans.TextBlock__c = 'test';
			insert new List<GFRS_Content_Translation__c>{contTrans};
			GFRS_Program__c testProgram = gFRS_TestCreationUtils.createProgram_min('Field_Initiated_Exhibits_Program',settings.FundingRequest);
			insert testProgram;
			testProgram = [Select Id, Name, Funding_Request__c from GFRS_Program__c where Funding_Request__c =: settings.FundingRequest.Id];
			Test.startTest();
				Attachment newAtt = gFRS_AttachmentUploadUtil.uploadAttachment(testProgram.Id, settings.FundingRequest.Id, 'Fellowship_Project_Description__c', att, false);
				Id attId = [select id, Fellowship_Project_Description__c from GFRS_Program__c where id = :testProgram.Id].Fellowship_Project_Description__c;
				Attachment newAttFull = [select id, Body from Attachment where id=:attId];
				System.assertEquals(attId,newAtt.id);
				System.assert(newAtt.Body==null);
				System.assert(newAttFull.Body.size()>0);
			Test.stopTest();
	}
	static testMethod void testUploadAttNewOrg() {
			TestSettings settings = new TestSettings(false);
			Attachment att = settings.createAttachment(false);
			Test.startTest();
				Attachment newAtt = gFRS_AttachmentUploadUtil.uploadAttachment(settings.testOrganization.Id, settings.FundingRequest.Id, 'W9_Form_W_8BEN_Form__c', att, false);
				Id attId = [select id, W9_Form_W_8BEN_Form__c from GFRS_Organization__c where id = :settings.testOrganization.Id].W9_Form_W_8BEN_Form__c;
				Attachment newAttFull = [select id, Body from Attachment where id=:attId];
				System.assertEquals(attId,newAtt.id);
				System.assert(newAtt.Body==null);
				System.assert(newAttFull.Body.size()>0);
			Test.stopTest();
	}
	static testMethod void testUploadAttNewOtherObj() {
			TestSettings settings = new TestSettings(false);
			Attachment att = settings.createAttachment(false);
			Test.startTest();
				Attachment newAtt = gFRS_AttachmentUploadUtil.uploadAttachment(settings.testLocation.Id, settings.FundingRequest.Id, 'W9_Form_W_8BEN_Form__c', att, false);
				Id attId = [select id, W9_Form_W_8BEN_Form__c from GFRS_Location__c where id = :settings.testLocation.Id].W9_Form_W_8BEN_Form__c;
				System.debug(newAtt);
				System.assert(attId==null);
			Test.stopTest();
	}
	static testMethod void testUploadAttExistError() {
			TestSettings settings = new TestSettings(false);
			Attachment att = settings.createAttachment(true);
			att.Name=null;
			Test.startTest();
				try {
					Attachment newAtt = gFRS_AttachmentUploadUtil.uploadAttachment(settings.FundingRequest.Id, settings.FundingRequest.Id, 'Letter_of_Request__c', att, false);
				} catch (Exception e) {
					System.assert(e!=null);
				}
			Test.stopTest();
	}
}