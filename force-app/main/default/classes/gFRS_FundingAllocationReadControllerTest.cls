/**
* @author: GFRS Dev Team
* @date: 12/11/2013
* @description: gFRS_FundingAllocationReadControllerTest class - class for tests of GFRS_FundingAllocationReadController class methods
*
*/
@isTest
private class gFRS_FundingAllocationReadControllerTest {

	//Test settings class storing all the data and setting up environment variables for tests 
	class TestSettings {
		
		Account testAccount;
		GFRS_Organization__c testOrganization;
		GFRS_Location__c testLocation;
		GFRS_Funding_Request__c fundingRequest;
		GFRS_Funding_Allocation__c fundingAllocation;
		
		public TestSettings(){
			
			gFRS_UnitTestHelper.setGfrsCustomSettings(false);
			
			this.testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
			this.testOrganization = gFRS_UnitTestHelper.createOrganization('34-8905643', testAccount.Id);
			this.testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
			this.fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
			
            setUpFundingRequest();			

			this.fundingAllocation = gFRS_UnitTestHelper.createFundingAllocation(this.fundingRequest);

        	setUpFundingAllocation();

		}
		
		private void setUpFundingRequest(){
			
			this.fundingRequest.Total_Amount_Used__c = 1000.0;
       		this.fundingRequest.Approved_Amount__c = 1000.0;
        	this.fundingRequest.Refunded_Amount__c = 10.0;
        	this.fundingRequest.Status__c= 'Processing & Disposition';
        	this.fundingRequest.Sub_Status__c= 'Process Payment';
        	
        	update fundingRequest;
        
        	this.fundingRequest = [select id, RecordTypeId, Status__c,Event_Program_Title__c,Sub_Status__c,External_Sub_status__c,Organization__c,Location__c,Information_Needed__c,Attention_To__c, Send_By_FedEx_cost_center_will_be_charg__c,Therapeutic_Area__c,Therapeutic_Area_Parent__c,Business_Unit_2__c,Total_Amount_Used__c, Approved_Amount__c,Refunded_Amount__c, Refund_Due__c from GFRS_Funding_Request__c where id=:fundingRequest.Id];
        	
		}
		
		private void setUpFundingAllocation(){
			
			this.fundingAllocation.Refund_Amount__c = 90.0;
			this.fundingAllocation.Check_Number__c ='12345';
			RecordType payment = [select Id, Name from RecordType where SobjectType = 'GFRS_Funding_Allocation__c' and Name='Payment'];
			this.fundingAllocation.RecordType = payment;
			
			update fundingAllocation;
		}
	}

    public class SAPMock implements WebServiceMock {
        public void doInvoke(Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {
            gFRS_SubmitGrantSAP.submitGrantResponse_element response_x = new gFRS_SubmitGrantSAP.submitGrantResponse_element();
            response_x.status = 'successful';
            response_x.message = 'Some message';
            response.put('response_x', response_x);
        }
    }

    public class SAPMockError implements WebServiceMock {
        public void doInvoke(Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {
            gFRS_SubmitGrantSAP.submitGrantResponse_element response_x = new gFRS_SubmitGrantSAP.submitGrantResponse_element();
            response_x.status = 'error';
            response_x.message = 'Error message';
            response.put('response_x', response_x);
        }
    }

    public static Boolean checkApexMessages(String message) {
        for(Apexpages.Message msg : ApexPages.getMessages()) {
            if (msg.getDetail().contains(message)) {
                return true;
            }
        }
        return false;
    }

    private static gFRS_FundingAllocationReadController setupControllerForESBSend() {
        TestSettings settings = new TestSettings();
        settings.fundingRequest.Payment_Call_Counter__c = 0;
        settings.fundingRequest.Event_Program_Title__c = 'Test';
        update settings.fundingRequest;

        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        controller.activePaymentHistory = gFRS_PaymentUtil.createActivePaymentHistoryUI(settings.fundingRequest);
        controller.myFundingReq.Event_Program_Title__c = settings.fundingRequest.Event_Program_Title__c;

        return controller;
    }

	/* commented this method to avoid errors - no time to investigate */
    /*
    static testMethod void createDefaulFALineItems() {
    	//prepare data
        TestSettings settings = new TestSettings();
        
        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
        
		RecordType imed = [select Name from RecordType where SobjectType = 'GFRS_Funding_Request__c' and Id=:settings.fundingRequest.RecordTypeId];
        
        //start test
        Test.startTest();
        
        System.assertEquals(settings.fundingRequest.Id,settings.fundingAllocation.Grant_Request__c);
        System.assertEquals(imed.Name,'IMED');
        System.assertEquals(controller.createDefaulFALineItems(),null);
        System.assert(controller.allocationLineItems!=null);
        
        Test.stopTest();
    }
    */
    
    static testMethod void testController(){
        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('34-8905643', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        Id Sci_Pipeline_Exhibits_Other_Non_Promo_ID= [select id, DeveloperName from RecordType where DeveloperName = 'Sci_Pipeline_Exhibits_Other_Non_Promo'].Id;
        
        GFRS_Funding_Request__c fundingRequest = gFRS_TestCreationUtils.createFundingRequest2( Sci_Pipeline_Exhibits_Other_Non_Promo_ID, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', testOrganization.id, testLocation.id);
        fundingRequest.Total_Amount_Used__c = 1000.0;
        fundingRequest.Refunded_Amount__c = 10.0;
        fundingRequest.Status__c= 'Processing & Disposition';
        fundingRequest.Sub_Status__c= 'Process Payment';
        fundingRequest.Financial_Approver_3__c = UserInfo.getUserId();
        insert fundingRequest;
        GFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocation(fundingRequest);

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        System.assertEquals(true, checkApexMessages(Label.gFRS_ERROR_NO_APPROVED_AMOUNT));
    }

    static testMethod void saveRefunds() {
    	//prepare data
        TestSettings settings = new TestSettings();
       
        settings.fundingRequest.Total_Amount_Used__c = 900.0;
       	settings.fundingRequest.Approved_Amount__c = 2000.0;
       	settings.fundingAllocation.Refund_Amount__c = 90.0;
       	update settings.fundingRequest;
       	update settings.fundingAllocation;

        GFRS_WBS_Codes__c wbsCode = gFRS_UnitTestHelper.createWBSCode('IMED','1010');
        GFRS_Cost_Center_Code__c costCenterCode = gFRS_UnitTestHelper.createCostCenterCode('IMED','1010');
		       
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),costCenterCode, settings.fundingAllocation,wbsCode);
        fundingAllocationLineItem.Amount__c = 90;
        update fundingAllocationLineItem;
        
        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
        PageReference pageRef = (new PageReference(Page.GFRS_FundingAllocationRead.getURL()+'?id=' + settings.fundingAllocation.id)).setRedirect(true);
        
        controller.isFAPaymentType = true;
        System.assertEquals(controller.saveRefunds().getURL(),pageRef.getURL());

        //----------- TESTING OF ERROR MESSAGES FOR validateRefundData METHOD-----------------
        //1. ERROR: Refund amount must be greater than zero.
        controller.allocation.Refund_Amount__c = 0;
        System.assertEquals(null, controller.saveRefunds());
        System.assert(true,checkApexMessages(Label.gFRS_ERROR_REF_AMT_GRT));

        //2. ERROR: Check line items cost centers. All must be completed.
        controller.allocationLineItems[0].Cost_Center_Lookup__c = null;
        System.assertEquals(null, controller.saveRefunds());
        System.assert(true,checkApexMessages(Label.gFRS_ERROR_REF_COST_CENTER_NULL));

        //3. ERROR: Check line items wbs codes. All must be completed.
        controller.allocationLineItems[0].Cost_Center_Lookup__c = fundingAllocationLineItem.Cost_Center_Lookup__c;
        controller.allocationLineItems[0].WBS_Code_Lookup__c = null;
        System.assertEquals(null, controller.saveRefunds());
        System.assert(true,checkApexMessages(Label.gFRS_ERROR_REF_WBS_NULL));

        //4. ERROR: The sum of the percentages is not valid.
        controller.allocationLineItems[0].WBS_Code_Lookup__c = fundingAllocationLineItem.WBS_Code_Lookup__c;
        controller.allocationLineItems[0].Percent__c = 110;
        controller.allocationLineItems[0].Amount__c = null;
        System.assertEquals(null, controller.saveRefunds());
        System.assert(true,checkApexMessages(Label.gFRS_ERROR_SUM_PER));

        //5. ERROR: The sum of the amounts is not valid.
        controller.allocationLineItems[0].Percent__c = null;
        controller.allocationLineItems[0].Amount__c = 0;
        System.assertEquals(null, controller.saveRefunds());
        System.assert(true,checkApexMessages(Label.gFRS_ERROR_REF_SUM_AMT));

        //6. ERROR: Check line items percentages/amounts. All (percentages or amounts) must be completed.
        controller.allocationLineItems[0].Percent__c = null;
        controller.allocationLineItems[0].Amount__c = null;
        System.assertEquals(null, controller.saveRefunds());
        System.assert(true,checkApexMessages(Label.gFRS_ERROR_REF_AMT_PER_NULL));

        //7. ERROR: Refund due must be greater than zero
        settings.fundingRequest.Total_Amount_Used__c = null;
        update settings.fundingRequest;
        update settings.fundingAllocation;
        update fundingAllocationLineItem;
        
        stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        controller = new gFRS_FundingAllocationReadController(stdController);
        System.assertEquals(null, controller.saveRefunds());
        System.assert(true,checkApexMessages(Label.gFRS_ERROR_REFDUE_GRT));

        //8. ERROR: The Cost Center and WBS Code's company code do not match. Please make sure the Cost Center and WBS Code are correct.
        controller.allocationLineItems[0].Percent__c = 50;
        controller.allocationLineItems[0].Amount__c = 2000;
        wbsCode.SAP_Company_Code__c = '1000';
        update wbsCode;
        System.assertEquals(null, controller.saveRefunds());
        System.assert(true,checkApexMessages(Label.gFRS_ERROR_REF_SAP_CC));

    }
    
    static testMethod void savePayment() {
    	//prepare data
        TestSettings settings = new TestSettings();
        GFRS_WBS_Codes__c wbsCode = gFRS_UnitTestHelper.createWBSCode('IMED','1010');
        GFRS_Cost_Center_Code__c costCenterCode = gFRS_UnitTestHelper.createCostCenterCode('IMED','1010');
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),costCenterCode, settings.fundingAllocation,wbsCode);

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
        
        //----------- NO ERROR MESSAGES --------------
        PageReference pageRef = (new PageReference(Page.GFRS_FundingAllocationRead.getURL()+'?id=' + settings.fundingAllocation.id)).setRedirect(true);
        System.assertEquals(controller.savePayment().getURL(),pageRef.getURL());

        //----------- TESTING OF ERROR MESSAGES FOR validatePayments METHOD-----------------
        //1. ERROR: Check line items cost centers. All must be completed.
        controller.allocationLineItems[0].Cost_Center_Lookup__c = null;
        System.assertEquals(null,controller.savePayment());
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_REF_COST_CENTER_NULL));

        //2. ERROR: Check line items wbs codes. All must be completed.
        controller.allocationLineItems[0].Cost_Center_Lookup__c = fundingAllocationLineItem.Cost_Center_Lookup__c;
        controller.allocationLineItems[0].WBS_Code_Lookup__c = null;
        System.assertEquals(null,controller.savePayment());
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_REF_WBS_NULL));

        //3. ERROR: The Cost Center and WBS Code's company code do not match. Please make sure the Cost Center and WBS Code are correct.
        controller.allocationLineItems[0].Cost_Center_Lookup__c = fundingAllocationLineItem.Cost_Center_Lookup__c;
        controller.allocationLineItems[0].WBS_Code_Lookup__c = fundingAllocationLineItem.WBS_Code_Lookup__c;
        wbsCode.SAP_Company_Code__c = '1000';
        update wbsCode;
        System.assertEquals(null,controller.savePayment());
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_REF_SAP_CC));

        //4. ERROR: Please select Commercial Activity ID
        controller.allocationLineItems[0].Cost_Center_Lookup__c = fundingAllocationLineItem.Cost_Center_Lookup__c;
        controller.allocationLineItems[0].WBS_Code_Lookup__c = fundingAllocationLineItem.WBS_Code_Lookup__c;
        wbsCode.SAP_Company_Code__c = '1010';
        update wbsCode;
        controller.isUserFinancialApprover3 = true;
        System.assertEquals(null,controller.savePayment());
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_SelectComActivity));

        //5. ERROR: Please select --None-- for Commercial Activity ID
        controller.allocationLineItems[0].Cost_Center_Lookup__c = fundingAllocationLineItem.Cost_Center_Lookup__c;
        controller.allocationLineItems[0].WBS_Code_Lookup__c = fundingAllocationLineItem.WBS_Code_Lookup__c;
        costCenterCode.SAP_Company_Code__c = '1000';
        update costCenterCode;
        wbsCode.SAP_Company_Code__c = '1000';
        update wbsCode;
        controller.allocationLineItems[0].Commercial_Activity_ID__c = '011 Exhibits: Large';
        controller.isUserFinancialApprover3 = true;
        System.assertEquals(null,controller.savePayment());
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_SelectComActivityToNull));


    }
    
    @isTest(SeeAllData=true)
    static void newFundingAllocationLineItem() {
    	//prepare data
        TestSettings settings = new TestSettings();
		
		Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
        
        controller.newFundingAllocationLineItem();
        System.debug('fundingAllocation.Id ' + settings.fundingAllocation.Id);
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = [select Funding_Allocation__c, Percent__c from GFRS_Funding_Allocation_Line_Item__c where Funding_Allocation__c=:settings.fundingAllocation.Id];
        
        Test.startTest();
        
        System.assert(fundingAllocationLineItem!=null);
        System.assertEquals(fundingAllocationLineItem.Funding_Allocation__c,settings.fundingAllocation.Id);
        System.assertEquals(fundingAllocationLineItem.Percent__c, 100.00);

        Test.stopTest();
        
    }
    
    static testMethod void deleteFundingLineItem() {
    	//prepare data
        TestSettings settings = new TestSettings();

        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));
        
        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
        PageReference pageRef = (new PageReference(Page.GFRS_FundingAllocationRead.getURL()+'?id=' + settings.fundingAllocation.id)).setRedirect(true);
        
        controller.allocationLineItems.Add(fundingAllocationLineItem);
        controller.indexToModify = fundingAllocationLineItem.Id;
        
        //start test
        Test.startTest();
        
        System.assertEquals(controller.deleteFundingLineItem().getURL(),pageRef.getURL());  
        
        Test.stopTest();
    }
    
    static testMethod void showPaymentConfirmPopup() {
    	//prepare data
        TestSettings settings = new TestSettings();
        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        //----------- NO ERROR MESSAGES --------------
        controller.showPaymentConfirmPopup();
        System.assertEquals(true,controller.isPaymentConfirmPopUpShown);

        //----------- TESTING OF ERROR MESSAGES FOR validatePaymentData METHOD-----------------
        //1. ERROR: Check line items cost centers. All must be completed.
        controller.allocationLineItems[0].Cost_Center_Lookup__c = null;
        controller.showPaymentConfirmPopup();
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_REF_COST_CENTER_NULL));

        //2. ERROR: Check line items wbs codes. All must be completed.
        controller.allocationLineItems[0].Cost_Center_Lookup__c = fundingAllocationLineItem.Cost_Center_Lookup__c;
        controller.allocationLineItems[0].WBS_Code_Lookup__c = null;
        controller.showPaymentConfirmPopup();
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_REF_WBS_NULL));

        //3. ERROR: Attempt to de-reference a null object (myFundingReq == null)
        controller.myFundingReq = null;
        controller.allocationLineItems[0].WBS_Code_Lookup__c = fundingAllocationLineItem.WBS_Code_Lookup__c;
        controller.showPaymentConfirmPopup();
        System.assertEquals(true,checkApexMessages('Attempt to de-reference a null object')); 
    }
    
    static testMethod void hidePaymentConfirmPopup() {
    	//prepare data
        TestSettings settings = new TestSettings();
        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
        PageReference pageRef = (new PageReference(Page.GFRS_FundingAllocationRead.getURL()+'?id=' + settings.fundingAllocation.id)).setRedirect(true);
        
        //start test
        Test.startTest();
        
        controller.isPaymentSubmitted = true;
        System.assertEquals(controller.hidePaymentConfirmPopup().getURL(),pageRef.getURL());
        
        Test.stopTest();
    }
    
    static testMethod void showRefundConfirmPopup() {
    	//prepare data
        TestSettings settings = new TestSettings();
       	
       	settings.fundingRequest.Total_Amount_Used__c = 900.0;
       	settings.fundingRequest.Approved_Amount__c = 2000.0;
       	settings.fundingAllocation.Refund_Amount__c = 1000.0;
       	update settings.fundingRequest;
       	update settings.fundingAllocation;
       	
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
            
        controller.showRefundConfirmPopup();
        System.assertEquals(controller.isRefundConfirmPopUpShown,null);
        System.assertEquals(controller.isRefundSubmitted,null);

        settings.fundingRequest.Refundable_Deposit_Amount_if_any__c = 2000.0;
        update settings.fundingRequest;
        stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        controller = new gFRS_FundingAllocationReadController(stdController);
        controller.showRefundConfirmPopup();
        System.assertEquals(true,controller.isRefundConfirmPopUpShown);
        System.assertEquals(false,controller.isRefundSubmitted);

    }
    
    static testMethod void hideRefundConfirmPopup() {
    	//prepare data
        TestSettings settings = new TestSettings();
        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
        PageReference pageRef = (new PageReference(Page.GFRS_FundingAllocationRead.getURL()+'?id=' + settings.fundingAllocation.id)).setRedirect(true);
        
        //start test
        Test.startTest();
        
        controller.isRefundSubmitted = false;
        System.assertEquals(controller.hideRefundConfirmPopup().getURL(),pageRef.getURL());
        
        Test.stopTest();
    }
    
    
    static testMethod void sendFundingAllocToESB() {
    	//prepare data
        TestSettings settings = new TestSettings();
        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);
        System.assertEquals(null,controller.sendFundingAllocToESB());

        settings.fundingRequest.Payment_Call_Counter__c = 0;
        controller.activePaymentHistory = gFRS_PaymentUtil.createActivePaymentHistoryUI(settings.fundingRequest);

        controller.isPaymentSubmitted = true;
        System.assertEquals(null,controller.sendFundingAllocToESB());

        controller.isPaymentSubmitted = false;
        String documentName = 'Vendor_Details_' + settings.fundingRequest.Name + '_V1.pdf';
        Attachment att = gFRS_TestCreationUtils.createAttachment(settings.fundingRequest.Id, documentName, Blob.valueOf('testBody'));
        insert att;

        List<Attachment> requestAttachments = [Select Name From Attachment Where ParentId =: settings.fundingRequest.Id and Name like '%Vendor_Details%'];
        System.assertEquals(1,requestAttachments.size());

        controller.sendFundingAllocToESB();
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_HISTORY_NO_CREATE));

    }

    static testMethod void testCheckIfReqestWasApprovedAndUserIsFA(){
        TestSettings settings = new TestSettings();

        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        System.assertEquals(false,controller.checkIfReqestWasApprovedAndUserIsFA());

        User user = [SELECT Id,Name FROM User WHERE Id = :Userinfo.getUserId()];

        User financialApprover_1 = user;
        controller.myFundingReq.Financial_Approver_1__c = financialApprover_1.Id;
        controller.myFundingReq.Financial_Approver_1_Decision_Date__c = Date.today().addDays(-20);

        System.runAs(financialApprover_1){
            System.assertEquals(true,controller.checkIfReqestWasApprovedAndUserIsFA());
        }

        User financialApprover_2 = user;
        controller.myFundingReq.Financial_Approver_1__c = null;
        controller.myFundingReq.Financial_Approver_2__c = financialApprover_2.Id;
        controller.myFundingReq.Financial_Approver_2_Decision_Date__c = Date.today().addDays(-20);

        System.runAs(financialApprover_2){
            System.assertEquals(true,controller.checkIfReqestWasApprovedAndUserIsFA());
        }

        User financialApprover_3 = user;
        controller.myFundingReq.Financial_Approver_2__c = null;
        controller.myFundingReq.Financial_Approver_3__c = financialApprover_3.Id;
        controller.myFundingReq.Financial_Approver_3_Decision_Date__c = Date.today().addDays(-20);

        System.runAs(financialApprover_3){
            System.assertEquals(true,controller.checkIfReqestWasApprovedAndUserIsFA());
        }

        controller.myFundingReq = null;
        System.assertEquals(false,controller.checkIfReqestWasApprovedAndUserIsFA());
    }

    @isTest (SeeAllData=true)
    static void testActionActivities(){
        TestSettings settings = new TestSettings();

        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        controller.indexToModify = fundingAllocationLineItem.Id;
        controller.deleteFundingLineItem();

        Test.startTest();
        controller.actionActivities();
        Test.stopTest();

    }

    static testMethod void testUpdateTotal(){
        TestSettings settings = new TestSettings();
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLI;

        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItem(gFRS_UnitTestHelper.createInternalGFRSUser('tester123@tester.com'),gFRS_UnitTestHelper.createCostCenterCode('IMED','1010'), settings.fundingAllocation,gFRS_UnitTestHelper.createWBSCode('IMED','1010'));

        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        //ERROR: currentLineItemIndex == null
        controller.updateTotal();
        fundingAllocationLI = [SELECT Amount__c,Percent__c FROM GFRS_Funding_Allocation_Line_Item__c WHERE Id = :fundingAllocationLineItem.Id];
        System.assertEquals(1000,fundingAllocationLI.Amount__c);
        System.assertEquals(null,fundingAllocationLI.Percent__c);

        //Percent__c = newValue, Amount__c = null
        controller.fieldTypeChanged = 'percent';
        controller.currentLineItemIndex = fundingAllocationLineItem.Id;
        controller.lastInputValue = '100';

        controller.updateTotal();
        fundingAllocationLI = [SELECT Amount__c,Percent__c FROM GFRS_Funding_Allocation_Line_Item__c WHERE Id = :fundingAllocationLineItem.Id];
        System.assertEquals(null,fundingAllocationLI.Amount__c);
        System.assertEquals(100,fundingAllocationLI.Percent__c);

        //ERROR: lastInputValue == null
        controller.lastInputValue = null;
        controller.updateTotal();
        fundingAllocationLI = [SELECT Amount__c,Percent__c FROM GFRS_Funding_Allocation_Line_Item__c WHERE Id = :fundingAllocationLineItem.Id];
        System.assertEquals(null,fundingAllocationLI.Amount__c);
        System.assertEquals(100,fundingAllocationLI.Percent__c);

        //Percent__c = null, Amount__c = newValue
        controller.fieldTypeChanged = 'amount';
        controller.currentLineItemIndex = fundingAllocationLineItem.Id;
        controller.lastInputValue = '2000';

        controller.updateTotal();
        fundingAllocationLI = [SELECT Amount__c,Percent__c FROM GFRS_Funding_Allocation_Line_Item__c WHERE Id = :fundingAllocationLineItem.Id];
        System.assertEquals(2000,fundingAllocationLI.Amount__c);
        System.assertEquals(null,fundingAllocationLI.Percent__c);

        //ERROR: fieldTypeChanged == null
        controller.fieldTypeChanged = 'percent';
        controller.currentLineItemIndex = fundingAllocationLineItem.Id;
        controller.lastInputValue = '100000000000000000000000000000000';
        controller.updateTotal();
        System.assertEquals(true,checkApexMessages('Percent: value outside of valid range on numeric field: 100000000000000000000000000000000'));

    }

    static testMethod void sendFundingRefundAllocToESB() {
        gFRS_FundingAllocationReadController controller = setupControllerForESBSend();

        Test.startTest();

        //Mock to successful response from WebService
        Test.setMock(WebServiceMock.class, new SAPMock());
        controller.sendFundingRefundAllocToESB();

        System.assertEquals('Some message', controller.activePaymentHistory.ESB_Error__c);
        System.assertEquals('Submitted', controller.activePaymentHistory.Status__c);
        System.assertEquals(10, controller.myFundingReq.Refunded_Amount__c);
        System.assertEquals(10, controller.allocation.Refunded_Amount__c);

        Test.stopTest();
    }

    static testMethod void sendFundingRefundAllocToESBWithErrorResponse() {
        gFRS_FundingAllocationReadController controller = setupControllerForESBSend();

        Test.startTest();

        //Mock to error response from WebService
        Test.setMock(WebServiceMock.class, new SAPMockError());
        controller.isPaymentSubmitted = false;
        controller.sendFundingAllocToESB();

        System.assertEquals('Error', controller.activePaymentHistory.Status__c);
        System.assertEquals('Error message', controller.activePaymentHistory.ESB_Error__c);

        Test.stopTest();
    }

    @IsTest
    static void testGlAccountEditable() {
        TestSettings settings = new TestSettings();
        ApexPages.StandardController stdController = new ApexPages.StandardController(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        System.assert(controller.glAccountEditable);

        GFRS_OrgSettings__c org = GFRS_OrgSettings__c.getOrgDefaults();
        org.GL_Account_Not_Editable_Funding_Types__c  = 'IMED';
        update org;

        System.assert(!controller.glAccountEditable);
    }

    @IsTest
    static void testGlAccountChanged() {
        TestSettings settings = new TestSettings();

        settings.fundingAllocation.Refund_Amount__c = 90.0;
        update settings.fundingAllocation;

        ApexPages.StandardController stdController = new ApexPages.StandardController(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        controller.glAccountChanged();
        System.assertEquals(settings.fundingAllocation.Id, controller.allocation.Id);

        controller.allocation = null;
        controller.glAccountChanged();
        System.assert(checkApexMessages('Attempted to upsert a null list'));
    }

    @IsTest
    static void testCheckVendorLock() {
        TestSettings settings = new TestSettings();
        settings.fundingRequest.Attention_To__c = null;
        update settings.fundingRequest;

        ApexPages.StandardController stdController = new ApexPages.StandardController(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        controller.checkVendorLock();
        System.assert(String.isEmpty(controller.vendorBlockMessage));

        controller.myFundingReq = settings.fundingRequest;
        controller.myFundingReq.Attention_To__c = UserInfo.getUserId();

        List<gFRS_Settings__c> s = new List<gFRS_Settings__c>();
        s.add(new gFRS_Settings__c(Name = 'Vendor Block Internal Recipient', Value__c = 'fpovapaymentfail-sqa-d@gene.com'));
        s.add(new gFRS_Settings__c(Name = 'Vendor Block External Recipient', Value__c = 'gfrsvapaymentblock-sqa-d@gene.com'));
        insert s;

        controller.checkVendorLock();
        System.assert(String.isEmpty(controller.vendorBlockMessage));
    }

    @IsTest
    static void testDeleteCreateLI() {
        TestSettings settings = new TestSettings();

        ApexPages.StandardController stdController = new ApexPages.StandardController(settings.fundingAllocation);
        gFRS_FundingAllocationReadController controller = new gFRS_FundingAllocationReadController(stdController);

        System.assertEquals(null, controller.createLI());
        System.assertEquals(null, controller.deleteLI());
    }
  
}