/**
* @author ADMD Team
* @date 13/12/2013
* @description gFRS_PaymentUtil_Test class - test class for gFRS_PaymentUtil.
*/
@isTest
private class gFRS_PaymentUtil_Test {


	/**
	* @author ADMD Team
	* @date 13/12/2013
	* @description testWebserviceMock method - Test method for gFRS_SubmitGrantWS.
	*/
    static testMethod void testWebserviceMock() {
        
        gFRS_SubmitGrantWS.GneCOMM_Grants_SFDC_O_1Port0 sapGrant = new gFRS_SubmitGrantWS.GneCOMM_Grants_SFDC_O_1Port0();
        
		gFRS_SubmitGrantWS_Mock mock = new gFRS_SubmitGrantWS_Mock();
        mock.responseElement = new gFRS_SubmitGrantSAP.submitGrantResponse_element();
        mock.responseElement.Status = 'testStatusOK';
        Test.setMock(WebServiceMock.class, mock);
        
        Test.startTest();
        
        	gFRS_SubmitGrantSAP.submitGrantResponse_element response = sapGrant.submitGrant(null, null, null, null, null, null, null, null);
        	System.assert(response.Status == 'testStatusOK');
        	
        Test.stopTest();
    }
    
    
    /**
	* @author ADMD Team
	* @date 13/12/2013
	* @description testCanSubmitFundingAllocationPayment method - Test method for canSubmitFundingAllocationPayment method.
	*/
    static testmethod void testCanSubmitFundingAllocationPayment(){
    	
    	//prepare data
    	Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
    	Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
    	User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
    	
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(testOrganization.Id, testLocation.Id, 'Processing & Disposition', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest.Approved_Amount__c = 10;
        fundingRequest.Refundable_Deposit_Amount_if_any__c = 5;
        insert fundingRequest;
        
        GFRS_Cost_Center_Code__c costCenter = gFRS_UnitTestHelper.createCostCenterCode('testName', '1010');
        
        GFRS_WBS_Codes__c wbsCode = gFRS_UnitTestHelper.createWBSCodeWithoutSaving('1010', true, 'Autism', 20, 'IMED', '1010', Date.today()+1, 'Biogen-Idec', '1010', '1010 Description');

        insert wbsCode;
        
        
        GFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocationWithoutSaving(gFRS_UnitTestHelper.ID_FUNDING_ALLOCATION_PAYMENT_RECTYPE, fundingRequest, 'Genentech');
		fundingAllocation.Refund_Amount__c = 20;
		insert fundingAllocation;
		
		fundingAllocation = [ SELECT Refund_Amount__c, Payment_Amount__c, Grant_Request__c  FROM GFRS_Funding_Allocation__c WHERE id =:fundingAllocation.Id];

        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItemWithoutSaving(testUser, costCenter, fundingAllocation, wbsCode);
        fundingAllocationLineItem.Amount__c = 5;
        insert fundingAllocationLineItem;
        
        fundingAllocationLineItem = [ SELECT Line_Item_Total__c, Amount__c, Funding_Allocation__c, Funding_Record_Type__c, WBS_Code_Lookup__c, Accountable_Employee__c, Cost_Center_Lookup__c  FROM GFRS_Funding_Allocation_Line_Item__c WHERE Id =:fundingAllocationLineItem.Id ];
        
        Test.startTest();
        	Boolean result = gFRS_PaymentUtil.canSubmitFundingAllocationPayment(false, null, fundingRequest, fundingAllocation, new GFRS_Funding_Allocation_Line_Item__c[]{fundingAllocationLineItem});
        	System.assert(result == true);
        Test.stopTest();
        
    }
    
    
    /**
	* @author ADMD Team
	* @date 13/12/2013
	* @description testCreateActivePaymentHistoryUI method - Test method for createActivePaymentHistoryUI method.
	*/
    static testmethod void testCreateActivePaymentHistoryUI(){
    	
    	
    	//prepare data
    	Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
    	Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
    	User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
    	
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(testOrganization.Id, testLocation.Id, 'Processing & Disposition', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest.Payment_Call_Counter__c = 1;
        fundingRequest.Approved_Amount__c = 15;
        fundingRequest.Refundable_Deposit_Amount_if_any__c = 13;
        insert fundingRequest;
        
        
    	
    	Test.startTest();
    	
    		GFRS_Payment_History__c paymentHistory = gFRS_PaymentUtil.createActivePaymentHistoryUI(fundingRequest);
    		System.assert(fundingRequest.Payment_Call_Counter__c == 2);
    		System.assert(paymentHistory != null);
    		System.assert(paymentHistory.SAP_Request_ID__c != null);
    		System.assert(paymentHistory.Date__c != null);
    		System.assert(paymentHistory.Grant__c == fundingRequest.Id);
    		System.assert(paymentHistory.Amount__c == 2);
    		System.assert(paymentHistory.Payment_Type__c == 'Payment');
    		System.assert(paymentHistory.Action__c == 'Payment Sent');
    		System.assert(paymentHistory.Status__c == 'Initialized');
    		System.assert(paymentHistory.InvokeType__c == 'UI');
    		
    		
    	Test.stopTest();
    }

    
    
    /**
	* @author ADMD Team
	* @date 13/12/2013
	* @description testCleanupActivePaymentHistory method - Test method for cleanupActivePaymentHistory method.
	*/
    static testmethod void testCleanupActivePaymentHistory(){
    	
    	//prepare data
    	Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
    	Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
    	User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
    	
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(testOrganization.Id, testLocation.Id, 'Processing & Disposition', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        insert fundingRequest;
        
    	GFRS_Payment_History__c paymentHistory = new GFRS_Payment_History__c();	
    	paymentHistory.ESB_Error__c = 'testtesttesttesttesttesttesttesttesttesttesttesttesttest';
    	paymentHistory.Grant__c = fundingRequest.Id;

    	
    	Test.startTest();
    		GFRS_Payment_History__c result = gFRS_PaymentUtil.cleanupActivePaymentHistory(paymentHistory);
    		System.assert(paymentHistory == result);
    		
    		//change data for positive path
    		paymentHistory.ESB_Error__c = null;
    		insert paymentHistory;
    		
    		result = gFRS_PaymentUtil.cleanupActivePaymentHistory(paymentHistory);
    		List<GFRS_Payment_History__c> resultList = [SELECT Id FROM GFRS_Payment_History__c ];
    		System.assert(resultList.size() == 0 , resultList);
    		
    	Test.stopTest();
    	
    }

    
   
   	/**
	* @author ADMD Team
	* @date 13/12/2013
	* @description testSendFundingAllocationPaymentToESB method - Test method for sendFundingAllocationPaymentToESB method.
	*/
    static testmethod void testSendFundingAllocationPaymentToESB(){
    	
    	
    	//prepare data
    	Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
    	Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
    	User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
    	
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(testOrganization.Id, testLocation.Id, 'Processing & Disposition', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest.Approved_Amount__c = 10;
        fundingRequest.Refundable_Deposit_Amount_if_any__c = 7;
        insert fundingRequest;
        
        
        GFRS_Cost_Center_Code__c costCenter = gFRS_UnitTestHelper.createCostCenterCode('testName', '1010');
        
        GFRS_WBS_Codes__c wbsCode = gFRS_UnitTestHelper.createWBSCodeWithoutSaving('1010', true, 'Autism', 20, 'IMED', '1010', Date.today()+1, 'Biogen-Idec', '1010', '1010 Description');
        insert wbsCode;
        
        
        GFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocationWithoutSaving(gFRS_UnitTestHelper.ID_FUNDING_ALLOCATION_PAYMENT_RECTYPE, fundingRequest, 'Genentech');
		fundingAllocation.Refund_Amount__c = 20;
		insert fundingAllocation;
		
		fundingAllocation = [ SELECT Refund_Amount__c, Payment_Amount__c, Grant_Request__c  FROM GFRS_Funding_Allocation__c WHERE id =:fundingAllocation.Id];

        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItemWithoutSaving(testUser, costCenter, fundingAllocation, wbsCode);
        fundingAllocationLineItem.Amount__c = 5;
        insert fundingAllocationLineItem;
        
        
        fundingAllocationLineItem = [ SELECT Line_Item_Total__c, Amount__c, Funding_Allocation__c, Funding_Record_Type__c, WBS_Code_Lookup__c, Accountable_Employee__c, Cost_Center_Lookup__c  FROM GFRS_Funding_Allocation_Line_Item__c WHERE Id =:fundingAllocationLineItem.Id ];
        
        GFRS_Payment_History__c paymentHistory = new GFRS_Payment_History__c();	
    	paymentHistory.ESB_Error__c = 'testtesttesttesttesttesttesttesttesttesttesttesttesttest';
    	paymentHistory.Grant__c = fundingRequest.Id;
    	insert paymentHistory;
        
        //set appropriate custom settings
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        myOrgCS.ESBWebServiceTimeOut__c = 0;
        myOrgCS.gFRS_HC_Compliance_Flag_Start_Date__c=Date.today();
        myOrgCS.Field_Initiated_Exhibits_WBS_1000__c='309.01006';
		myOrgCS.Field_Initiated_Exhibits_WBS_1010__c='309.07076'; 
        upsert myOrgCS;
        
        
        gFRS_SubmitGrantWS_Mock mock = new gFRS_SubmitGrantWS_Mock();
        mock.responseElement = new gFRS_SubmitGrantSAP.submitGrantResponse_element();
        mock.responseElement.Status = 'successful';
        Test.setMock(WebServiceMock.class, mock);
    	
    	Test.startTest();
    	    createContentAndTranslation();
    		Boolean result = gFRS_PaymentUtil.sendFundingAllocationPaymentToESB(fundingRequest.Id, fundingAllocation.Id, paymentHistory);
    		
    		GFRS_Payment_History__c paymentResult = [ SELECT Amount__c, Date__c, Payment_Type__c, Action__c, Funding_Allocation__c FROM GFRS_Payment_History__c WHERE Id =: paymentHistory.Id ];
    		System.assert(paymentResult.Amount__c == 3);
    		System.assert(paymentResult.Date__c == Date.today());
    		System.assert(paymentResult.Payment_Type__c == 'Payment');
    		System.assert(paymentResult.Action__c == 'Payment Sent');
    		System.assert(paymentResult.Funding_Allocation__c == fundingAllocation.Id);
    	
    	Test.stopTest();
    	
    }
    
    
    /**
	* @author ADMD Team
	* @date 13/12/2013
	* @description testGetGrantSubmitSplitLines method - Test method for getGrantSubmitSplitLines method.
	*/
    static testmethod void testGetGrantSubmitSplitLines(){
    	
    	//prepare data
    	Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
    	Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
    	User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
    	
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(testOrganization.Id, testLocation.Id, 'Processing & Disposition', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        insert fundingRequest;
        fundingRequest = [ SELECT Id, Name, Approved_Amount__c, Record_Type_Name__c FROM GFRS_Funding_Request__c WHERE Id =:fundingRequest.Id ];
        
        GFRS_Cost_Center_Code__c costCenter = gFRS_UnitTestHelper.createCostCenterCode('testName', '1010');
        
        GFRS_WBS_Codes__c wbsCode = gFRS_UnitTestHelper.createWBSCodeWithoutSaving('1010', true, 'Autism', 20, 'IMED', '1010', Date.today()+1, 'Biogen-Idec', '1010', '1010 Description');
        insert wbsCode;
        
        
        GFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocationWithoutSaving(gFRS_UnitTestHelper.ID_FUNDING_ALLOCATION_PAYMENT_RECTYPE, fundingRequest, 'Genentech');
		fundingAllocation.Refund_Amount__c = 20;
	
		insert fundingAllocation;
		
		fundingAllocation = [ SELECT Refund_Amount__c, Payment_Amount__c, Grant_Request__c  FROM GFRS_Funding_Allocation__c WHERE id =:fundingAllocation.Id];

        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem = gFRS_UnitTestHelper.createFundingAllocationLineItemWithoutSaving(testUser, costCenter, fundingAllocation, wbsCode);
        fundingAllocationLineItem.Amount__c = 5;
        fundingAllocationLineItem.Commercial_Activity_ID__c='021 Sponsorships';
        insert fundingAllocationLineItem;
        
        fundingAllocationLineItem = [SELECT Line_Item_Total__c,Commercial_Activity_ID__c, Funding_Allocation__r.GL_Account__c, Cost_Center__c, WBS__c  FROM GFRS_Funding_Allocation_Line_Item__c WHERE Id=:fundingAllocationLineItem.Id];
        
        
        Test.startTest();
        
        	gFRS_SubmitGrantSAP.Split_element[] result = gFRS_PaymentUtil.getGrantSubmitSplitLines(fundingRequest, new GFRS_Funding_Allocation_Line_Item__c[]{fundingAllocationLineItem});
        	System.assert(result.size()>0);
        	System.assert(result.get(0).fundingType == 'Independent Medical Education', result );
        	System.assert(result.get(0).costCenter == 'testName' );
        	System.assert(result.get(0).wbsCode == '1010' );
        
        Test.stopTest();
        
    }
    
    
    
    /**
	* @author ADMD Team
	* @date 13/12/2013
	* @description testHandleSubmitGrantResponse method - Test method for handleSubmitGrantResponse method.
	*/
    static testmethod void testHandleSubmitGrantResponse(){
    	
    	//prepare data
    	Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
    	Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
    	User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
    	
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(testOrganization.Id, testLocation.Id, 'Processing & Disposition', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        insert fundingRequest;
        
    	
    	gFRS_SubmitGrantSAP.submitGrantResponse_element responseElement = new gFRS_SubmitGrantSAP.submitGrantResponse_element();
    	responseElement.Status = 'dump status';
    	
    	
    	GFRS_Payment_History__c paymentHistory = new GFRS_Payment_History__c();	
    	paymentHistory.ESB_Error__c = 'testtesttesttesttesttesttesttesttesttesttesttesttesttest';
    	paymentHistory.Grant__c = fundingRequest.Id;
    	paymentHistory.Status__c = 'Initialized';
    	insert paymentHistory;
    	
    	
    	Test.startTest();
    	
    		Boolean result = gFRS_PaymentUtil.handleSubmitGrantResponse(responseElement, null, paymentHistory, fundingRequest);
    		System.assert(result == false);
    		System.assert(paymentHistory.Status__c == 'Error');
    		
    		responseElement.Status = 'successful';
    		result = gFRS_PaymentUtil.handleSubmitGrantResponse(responseElement, null, paymentHistory, fundingRequest);
    		System.assert(result == true);
    		System.assert(paymentHistory.Status__c == 'Submitted');
    		
    	Test.stopTest();
    	
    	
    }
    static void createContentAndTranslation(){
        GFRS_Content__c content = new GFRS_Content__c(Name='Gcal_Header',Filter__c='Test_Gcal_Header'); 
        insert content;
        GFRS_Content_Translation__c translation = new GFRS_Content_Translation__c(GFRS_Content__c = content.Id, TextBlock__c = 'testTranslation', Language__c ='en_US');
        insert translation;
    }
}