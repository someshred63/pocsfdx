@isTest
private class gFRS_Vendor_Block_WS_Test {


	class TestSettings {

		Account testAccount;
		GFRS_Organization__c testOrganization;
		GFRS_Location__c testLocation;
		GFRS_Funding_Request__c FundingRequest;

    public TestSettings(Boolean addAtt){
    	gFRS_UnitTestHelper.setGfrsCustomSettings(false);
		GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
		myOrgCS.Validation_Rules_Enabled__c = false;
		update myOrgCS;

			this.testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
			this.testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
			if (addAtt) {
				this.testOrganization.W9_Form_W_8BEN_Form__c = addAttachmentToParent(this.testOrganization.Id).Id;
			} else {
				this.testOrganization.W9_Form_W_8BEN_Form__c = 'someidtocauseerror';
			}
			update this.testOrganization;
			this.testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
			List<gFRS_Settings__c> settings = new List<gFRS_Settings__c>{
					new gFRS_Settings__c(
						Name = 'Vendor Block External Recipient',
						Value__c = 'gfrspaymentblock-sqa-d@gene.com'),
					new gFRS_Settings__c(
						Name = 'Vendor Block Internal Recipient',
						Value__c = 'fpopaymentfail-sqa-d@gene.com')
			};
			upsert settings;
    }

		private Attachment addAttachmentToParent(Id parentId) {
    	Blob b = Blob.valueOf('Test Data');

    	Attachment att = new Attachment();
    	att.ParentId = parentId;
    	att.Name = 'W9_Form_W_8BEN_Form';
    	att.Body = b;

    	insert(att);
			return att;
    }

		private void setLocationBlock(Boolean blocked) {
			if (blocked!=null && blocked) {
				this.testLocation.Vendor_Id__c = 'blockedId';
			} else if (blocked!=null && !blocked){
				this.testLocation.Vendor_Id__c = 'notblockedId';
			} else {
				this.testLocation.Vendor_Id__c = null;
			}
			update this.testLocation;
		}

		private void setLocationNameToCauseWSError(Boolean throwException) {
			if (!throwException) {
				this.testLocation.Vendor_Id__c = 'causeError';
			} else {
				this.testLocation.Vendor_Id__c = 'throwExcepti';
			}
			update this.testLocation;
		}

    private GFRS_Funding_Request__c setUpInternalFundingRequest(String stat,String substat){
					this.FundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS,stat, substat, 'Under Review','',testOrganization.Id, testLocation.Id);
					if (substat.equals(gFRS_Util.REQUEST_SUB_STATUS_FINANCIAL_APPROVAL)) {
						this.FundingRequest.Financial_Approver_2_Decision__c=gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
					}
					User testUser = gFRS_UnitTestHelper.createUserWithSpecificProfile([select Id, Name from Profile where Name='GNE-GFRS-Grant Coordinator'].Id);
					this.FundingRequest.Legal_Reviewer_1__c = testUser.Id;
        	//this.FundingRequest.Financial_Approver_2_Decision__c = gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
        	insert FundingRequest;
        	this.FundingRequest = [select id from GFRS_Funding_Request__c where id=:FundingRequest.Id];
					return this.FundingRequest;
		}
		private GFRS_Funding_Request__c setUpFIEFundingRequest(){
				this.FundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS, gFRS_Util.REQUEST_STATUS_DECISION, gFRS_Util.REQUEST_SUB_STATUS_BUSINESS_REV, 'Under Review','',testOrganization.Id, testLocation.Id);
				this.FundingRequest.Legal_Decision__c=gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
				User testUser = gFRS_UnitTestHelper.createUserWithSpecificProfile([select Id, Name from Profile where Name='GNE-GFRS-Grant Coordinator'].Id);
				//this.FundingRequest.Legal_Reviewer_1__c = testUser.Id;
				//this.FundingRequest.Financial_Approver_2_Decision__c = gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
				insert FundingRequest;
				this.FundingRequest = [select id from GFRS_Funding_Request__c where id=:FundingRequest.Id];
				return this.FundingRequest;
		}
		private GFRS_Funding_Request__c setUpExternalFundingRequest(String stat,String substat){
				this.FundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_PHILANTHROPIC, stat, substat, 'Under Review','',testOrganization.Id, testLocation.Id);
				//this.FundingRequest.Legal_Decision__c=gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
				//User testUser = gFRS_UnitTestHelper.createUserWithSpecificProfile([select Id, Name from Profile where Name='GNE-GFRS-Grant Coordinator'].Id);
				this.FundingRequest.Financial_Approver_1_Decision__c=gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
				//this.FundingRequest.Legal_Reviewer_1__c = testUser.Id;
				//this.FundingRequest.Financial_Approver_2_Decision__c = gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED;
				insert FundingRequest;
				this.FundingRequest = [select id from GFRS_Funding_Request__c where id=:FundingRequest.Id];
				return this.FundingRequest;
		}
	}



    static testMethod void testCheckVendorBlockInternalBlocked() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpInternalFundingRequest(gFRS_Util.REQUEST_STATUS_HC_COMPLIANCE,gFRS_Util.REQUEST_SUB_STATUS_CCO);
				settings.setLocationBlock(true);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('Warning: Vendor ID blockedId, Vendor company Name TestLocation is blocked. An automated email will be sent to fpopaymentfail-sqa-d@gene.com with additional information about this vendor. Please follow up with vendor finance team.',resposne);
				Test.stopTest();
    }

		static testMethod void testCheckVendorBlockInternalBlockedFA3() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpInternalFundingRequest(gFRS_Util.REQUEST_STATUS_DECISION,gFRS_Util.REQUEST_SUB_STATUS_FINANCIAL_APPROVAL);
				settings.setLocationBlock(true);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('',resposne);
				Test.stopTest();
    }

		static testMethod void testCheckVendorBlockInternalNotBlockedFA3() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpInternalFundingRequest(gFRS_Util.REQUEST_STATUS_DECISION,gFRS_Util.REQUEST_SUB_STATUS_FINANCIAL_APPROVAL);
				settings.setLocationBlock(false);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('',resposne);
				Test.stopTest();
		}

		static testMethod void testCheckVendorBlockWSError() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpInternalFundingRequest(gFRS_Util.REQUEST_STATUS_HC_COMPLIANCE,gFRS_Util.REQUEST_SUB_STATUS_CCO);
				settings.setLocationBlock(true);
				settings.setLocationNameToCauseWSError(false);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem',resposne);
				Test.stopTest();
		}
		static testMethod void testCheckVendorBlockWSException() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpInternalFundingRequest(gFRS_Util.REQUEST_STATUS_HC_COMPLIANCE,gFRS_Util.REQUEST_SUB_STATUS_CCO);
				settings.setLocationBlock(true);
				settings.setLocationNameToCauseWSError(true);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('Vendor Lookup is currently not available. Please try again later. We have notified our System Administrator of this problem',resposne);
				Test.stopTest();
		}
		static testMethod void testCheckVendorBlockInternalNotBlocked() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpInternalFundingRequest(gFRS_Util.REQUEST_STATUS_HC_COMPLIANCE,gFRS_Util.REQUEST_SUB_STATUS_CCO);
				settings.setLocationBlock(false);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('',resposne);
				Test.stopTest();
		}

		static testMethod void testCheckVendorBlockInternalNotBlockedNoVendorId() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpInternalFundingRequest(gFRS_Util.REQUEST_STATUS_HC_COMPLIANCE,gFRS_Util.REQUEST_SUB_STATUS_CCO);
				settings.setLocationBlock(null);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('Vendor is not added',resposne);
				Test.stopTest();
		}

		static testMethod void testCheckVendorBlockFIEBlocked() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpFIEFundingRequest();
				settings.setLocationBlock(true);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('',resposne);
				Test.stopTest();
		}
		static testMethod void testCheckVendorBlockFIENotBlocked() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpFIEFundingRequest();
				settings.setLocationBlock(false);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('',resposne);
				Test.stopTest();
		}
		static testMethod void testCheckVendorBlockExternalBlocked() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpExternalFundingRequest(gFRS_Util.REQUEST_STATUS_DECISION,gFRS_Util.REQUEST_SUB_STATUS_GC);
				settings.setLocationBlock(true);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('Warning: Vendor ID blockedId, Vendor company Name TestLocation is blocked. An automated email will be sent to gfrspaymentblock-sqa-d@gene.com with additional information about this vendor. Please follow up with vendor finance team.',resposne);
				Test.stopTest();
		}
		static testMethod void testCheckVendorNoAtt() {
				TestSettings settings = new TestSettings(false);
				GFRS_Funding_Request__c fundreq = settings.setUpExternalFundingRequest(gFRS_Util.REQUEST_STATUS_DECISION,gFRS_Util.REQUEST_SUB_STATUS_GC);
				settings.setLocationBlock(true);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('Warning: Vendor ID blockedId, Vendor company Name TestLocation is blocked. An automated email will be sent to gfrspaymentblock-sqa-d@gene.com with additional information about this vendor. Please follow up with vendor finance team.',resposne);
				Test.stopTest();
		}

		static testMethod void testCheckVendorBlockExternalNotBlocked() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpExternalFundingRequest(gFRS_Util.REQUEST_STATUS_DECISION,gFRS_Util.REQUEST_SUB_STATUS_GC);
				settings.setLocationBlock(false);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('',resposne);
				Test.stopTest();
		}

		static testMethod void testCheckVendorBlockExternalBlockedAfterSubmit() {
				TestSettings settings = new TestSettings(true);
				GFRS_Funding_Request__c fundreq = settings.setUpExternalFundingRequest(gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION,gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA);
				settings.setLocationBlock(true);
				Test.setMock(WebServiceMock.class, new gFRS_Vendor_Lookup_WS_Mock());
				Test.startTest();
					String resposne = gFRS_Vendor_Block_WS.checkVendorBlock(settings.FundingRequest.Id);
					System.assertEquals('Warning: Vendor ID blockedId, Vendor company Name TestLocation is blocked. An automated email will be sent to gfrspaymentblock-sqa-d@gene.com with additional information about this vendor. Please follow up with vendor finance team.',resposne);
				Test.stopTest();
		}
}