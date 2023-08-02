/**
* @author GFRS Dev Team
* @date 29/10/2013
* @description gFRS_UtilTest class - test class for gFRS_Util
*/
@isTest
private class gFRS_UtilTest {

	static testmethod void testGetUserContactWithContact(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('testAccount');
		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
		User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
		
		Test.startTest();
			Contact resultContact = gFRS_Util_NoShare.getUserContact(testUser.Id);
			System.assert(resultContact != null);
		Test.stopTest();
		
	}
	
	static testmethod void testGetUserContactWithoutContact(){
		
		//prepare data
		User testUser = gFRS_UnitTestHelper.createInternalGFRSUser();
		
		Test.startTest();
			Contact resultContact = gFRS_Util_NoShare.getUserContact(testUser.Id);
			System.assert(resultContact == null);
		Test.stopTest();
		
	}
	
	static testmethod void testCreateFundingRequestPrograms(){

		//prepare data
    	Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest = gFRS_DAO.getFundingRequestById(fundingRequest.Id).get(0);
        GFRS_Funding_Request__c[] testRequests = new GFRS_Funding_Request__c[]{fundingRequest};
        createContentAndTranslation();        
		Test.startTest();
			GFRS_Program__c[] programsList = gFRS_Util.createDefaultFRPrograms(testRequests);
			System.assert(programsList.size() == 1);
		Test.stopTest();
	}
	
	static testmethod void testGetAccountOrganizationNegative1(){
		
		//Zero Organizations for given Account
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		
		Test.startTest();
			GFRS_Organization__c resultOrganization = gFRS_Util.getAccountOrganization(testAccount.Id);
			System.assert(resultOrganization == null);	
		Test.stopTest();
	}
	
	static testmethod void testGetAccountOrganizationNegative2(){
		
		//Two Organizations for one Account - error
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
		GFRS_Organization__c testOrganization2 = gFRS_UnitTestHelper.createOrganization('99-9999998', testAccount.Id);
		
		Test.startTest();
			GFRS_Organization__c resultOrganization = gFRS_Util.getAccountOrganization(testAccount.Id);
			System.assert(resultOrganization == null);	
		Test.stopTest();
	}
	
	static testmethod void testGetAccountOrganizationPositive(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
		
		Test.startTest();
			GFRS_Organization__c resultOrganization = gFRS_Util.getAccountOrganization(testAccount.Id);
			System.assert(resultOrganization != null);	
		Test.stopTest();
	}
	
	
	static testmethod void testIsBlacklistedOrganizationScenario1(){
		
		//Organization blacklisted for IMED
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
		testOrganization.Funding_Type_Specific_Blacklist__c = 'IMED';
		
		upsert testOrganization;
		
		Test.startTest();
			Boolean result = gFRS_Util.isBlacklistedOrganization('99-9999999', null, 'IMED');
			System.assert(result == true);
		Test.stopTest();	
	}
	
	
	static testmethod void testIsBlacklistedOrganizationScenario2(){
	
		
		//Organizstion blackisted because 'Exclusion_Blacklist_Reasons__c' is not null
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
		testOrganization.Exclusion_Blacklist_Reasons__c = 'Declared bankruptcy';
		
		upsert testOrganization;
		
		Test.startTest();
			Boolean result = gFRS_Util.isBlacklistedOrganization('99-9999999', null, 'IMED');
			System.assert(result == true);
		Test.stopTest();
	}
	
	
	static testmethod void testIsBlacklistedOrganizationScenario3(){
	
		
		//Organizstion not blacklisted
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
		
		Test.startTest();
			Boolean result = gFRS_Util.isBlacklistedOrganization('99-9999999', null, 'IMED');
			System.assert(result == false);
		Test.stopTest();
		
	}
	
	
	static testmethod void testCreateDefaultFRPrograms(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        GFRS_Funding_Request__c fundingRequest2 = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget');
        fundingRequest = gFRS_DAO.getFundingRequestById(fundingRequest.Id).get(0);
        fundingRequest2 = gFRS_DAO.getFundingRequestById(fundingRequest2.Id).get(0);
        List<GFRS_Funding_Request__c> requestsList = new List<GFRS_Funding_Request__c>{fundingRequest, fundingRequest2};
        createContentAndTranslation();
        
        Test.startTest();
        	List<gFRS_Program__c> listOfProgram = gFRS_Util.createDefaultFRPrograms(requestsList);	
        	System.assert(listOfProgram.size() == 2);
        Test.stopTest();
        
	}
	
	
	static testmethod void testCreateFundingRequestProgram(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest = gFRS_DAO.getFundingRequestById(fundingRequest.Id).get(0);

        
        Test.startTest();
        	gFRS_Program__c resultProgram = gFRS_Util.createFundingRequestProgram(fundingRequest);	
        	System.assert(resultProgram != null);
        Test.stopTest();
        
	}
	
	
	static testmethod void testMultiSelectHasItem(){
		
		String testString = 'Organization;Location;Application;Third Party;Program;Budget;Attachments';
		
		Test.startTest();
		
			Boolean result = gFRS_Util.multiSelectHasItem(null, 'Application');
			System.assert(result == null);
			
			result = gFRS_Util.multiSelectHasItem(testString, 'Application');
			System.assert(result == true);
			
		Test.stopTest();
	}
	
	
	static testmethod void testAddMultiSelectItem(){
		
		String testString = 'Organization';
		
		Test.startTest();
		
			String result = gFRS_Util.addMultiSelectItem(null, 'Application');
			System.assert(result == 'Application');
			
			result = gFRS_Util.addMultiSelectItem(testString, 'Organization');
			System.assert(result == 'Organization');
			
			result = gFRS_Util.addMultiSelectItem(testString, 'Application');
			System.assert(result == 'Organization;Application');
			
		Test.stopTest();
		
	}
	
	static testmethod void testRemoveMultiSelectItem(){
		
		//prepare data
		String testString = 'Organization;Location;Application;Third Party;Program;Budget;Attachments';
		
		Test.startTest();
		
			String result = gFRS_Util.removeMultiSelectItem(null, 'Application');
			System.assert(result == null);
			
			result = gFRS_Util.removeMultiSelectItem(testString, 'Application');
			System.assert(result == 'Organization;Location;Third Party;Program;Budget;Attachments', 'Result: ' + result);
			
		Test.stopTest();
		
	}
	
	static testmethod void testUnescapeHTML(){
		
		String testString = '&quot;test&amp;test&quot;';
		
		Test.startTest();
		
			String result = gFRS_Util.unescapeHTML(null);		
			System.assert(result == null);
			
			result = gFRS_Util.unescapeHTML(testString);
			System.assert(result == '"test&test"', 'Result: ' + result);	
			
		Test.stopTest();
		
	}
	
	static testmethod void testBlankValue(){
		
		String testString = 'test';	
		String defaultString = 'default';
		
		Test.startTest();
		
			String result = gFRS_Util.blankValue(null, defaultString);
			System.assert(result == defaultString);
			
			result = gFRS_Util.blankValue(testString, defaultString);
			System.assert(result == testString);
			
		Test.stopTest();	
	}
	
	static testmethod void testGetRecordTypeDescription(){
		
		String resultString = '';
		
		Test.startTest();
		
			resultString = gFRS_Util.getRecordTypeDescription(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME);
			System.assert(resultString == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_DESCRIPTION);
			
			resultString = gFRS_Util.getRecordTypeDescription(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME);
			System.assert(resultString == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_DESCRIPTION);
			
			resultString = gFRS_Util.getRecordTypeDescription(gFRS_Util.TYPE_FELLOWSHIPS_NAME);
			System.assert(resultString == gFRS_Util.TYPE_FELLOWSHIPS_DESCRIPTION);
			
			resultString = gFRS_Util.getRecordTypeDescription(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME);
			System.assert(resultString == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_DESCRIPTION);
			
			resultString = gFRS_Util.getRecordTypeDescription(gFRS_Util.TYPE_HC_CHAR_NAME);
			System.assert(resultString == gFRS_Util.TYPE_HC_CHAR_DESCRIPTION);
			
			resultString = gFRS_Util.getRecordTypeDescription(gFRS_Util.TYPE_IMED_NAME);
			System.assert(resultString == gFRS_Util.TYPE_IMED_DESCRIPTION);
			
			resultString = gFRS_Util.getRecordTypeDescription(gFRS_Util.TYPE_PHILANTHROPIC_NAME);
			System.assert(resultString == gFRS_Util.TYPE_PHILANTHROPIC_DESCRIPTION);
			
			resultString = gFRS_Util.getRecordTypeDescription(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME);
			System.assert(resultString == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_DESCRIPTION);
			
		Test.stopTest();
	}
	
	static testmethod void testReplaceContentVariable(){
		
		String testText = 'This is a test of one of the methods from gFRS_Util class';
		String valueToBeChanged = 'test';
		String valueToBeSet = 'unit test';
		
		Test.startTest();
			String resultText = gFRS_Util.replaceContentVariable(valueToBeChanged, valueToBeSet, testText);
			System.assert(resultText == 'This is a unit test of one of the methods from gFRS_Util class' );
		Test.stopTest();
		
	}
	
	static testmethod void testUpdateStatusLastModifiedDate2(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        GFRS_Funding_Request__c fundingRequest2 = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget');

        List<GFRS_Funding_Request__c> requestsListOld = new List<GFRS_Funding_Request__c>{fundingRequest, fundingRequest2};
        
        List<GFRS_Funding_Request__c> requestsListNew = [SELECT Status_Last_Modified_Date__c, Status__c FROM GFRS_Funding_Request__c];
        
		for(GFRS_Funding_Request__c request : requestsListNew){
			request.Status__c = 'Decision';	
		}
		
        
        Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>(requestsListOld); 
		
		Test.startTest();
			List<GFRS_Funding_Request__c> resultList = [SELECT Status_Last_Modified_Date__c, Status__c FROM GFRS_Funding_Request__c];
			
			System.assert(resultList.get(0).Status_Last_Modified_Date__c == null);
			System.assert(resultList.get(1).Status_Last_Modified_Date__c == null);

			GFRS_Funding_Request__c[] testResultList = gFRS_Util.updateStatusLastModifiedDate2(requestsListNew, oldMap);

			System.assert(testResultList.get(0).Status_Last_Modified_Date__c != null);
			System.assert(testResultList.get(1).Status_Last_Modified_Date__c != null);
			
		Test.stopTest();
	}
	
	static testmethod void testCanAccessPage(){
		
		String corporateMembershipFundingType = gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME;
		String programPageName = gFRS_Util.PROGRAM_PAGE;
		String budgetPageName = gFRS_Util.BUDGET_PAGE;
		
		Test.startTest();
			Boolean result = gFRS_Util.canAccessPage('test', 'test');
			System.assert(result == true);
			
			result = gFRS_Util.canAccessPage('test', programPageName);
			System.assert(result == true);
			
			result = gFRS_Util.canAccessPage(corporateMembershipFundingType, programPageName);
			System.assert(result == false);
			
			result = gFRS_Util.canAccessPage(corporateMembershipFundingType, budgetPageName);
			System.assert(result == false);
			
			result = gFRS_Util.canAccessPage('test', budgetPageName);
			System.assert(result == true);
			
		Test.stopTest();
		
	}
	
	static testmethod void testIsInternalRequest(){
		

		String corporateMembershipsFundingType = gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME;
		String otherPromosFundingType = gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME;
		String fellowshipsFundingType = gFRS_Util.TYPE_FELLOWSHIPS_NAME;
		String fieldInitiatedExhibitsFundingType = gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME;
		String hcFundingType = gFRS_Util.TYPE_HC_CHAR_NAME;
		String imedFundingType = gFRS_Util.TYPE_IMED_NAME;
		String philantrophicFundingType = gFRS_Util.TYPE_PHILANTHROPIC_NAME;
		String scientificProjectsFundingType = gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME;
		
		Test.startTest();
			Boolean result = gFRS_Util.isInternalRequest(corporateMembershipsFundingType);
			System.assert(result == true);
			result = gFRS_Util.isInternalRequest(otherPromosFundingType);
			System.assert(result == true);
			result = gFRS_Util.isInternalRequest(fieldInitiatedExhibitsFundingType);
			System.assert(result == true);
			
			result = gFRS_Util.isInternalRequest(imedFundingType);
			System.assert(result == false);
			result = gFRS_Util.isInternalRequest(fellowshipsFundingType);
			System.assert(result == false);
			result = gFRS_Util.isInternalRequest(hcFundingType);
			System.assert(result == false);
			result = gFRS_Util.isInternalRequest(philantrophicFundingType);
			System.assert(result == false);
			result = gFRS_Util.isInternalRequest(scientificProjectsFundingType);
			System.assert(result == false);
		Test.stopTest();
		
	}
	
	
	static testmethod void testCreateAuthenticationHeaderMap(){
		
        Test.startTest();
			Map<String,String> resultMap = gFRS_Util.createAuthenticationHeaderMap();
			System.debug(resultMap.size()>0);
        Test.stopTest();
	}
	
	
	static testmethod void testPrepareXmlMessageToParse(){
		
		String result = gFRS_Util.prepareXmlMessageToParse('<?xml version="1.0"?>test');
		
		Test.startTest();
			System.assert(result == '<errorMessages>test</errorMessages>');
		Test.stopTest();
	}
	
	
	static testmethod void testTranslateDeliveryMethodToESB(){
		
		String deliveryMethodOrange = gFRS_Util.SFDC_ORANGE_POUCH;
		String deliveryMethodVendor = gFRS_Util.SFDC_VENDOR;
		String deliveryMethodSalesRep = gFRS_Util.SFDC_SALES_REP;
		
		Test.startTest();
			String result = gFRS_Util.translateDeliveryMethodToESB(deliveryMethodOrange);
			System.assert(result == gFRS_Util.ESB_ORANGE_POUCH);
			
			result = gFRS_Util.translateDeliveryMethodToESB(deliveryMethodVendor);
			System.assert(result == gFRS_Util.ESB_VENDOR);
			
			result = gFRS_Util.translateDeliveryMethodToESB(deliveryMethodSalesRep);
			System.assert(result == gFRS_Util.ESB_SALES_REP);
			
			result = gFRS_Util.translateDeliveryMethodToESB('test');
			System.assert(result == 'test');
		Test.stopTest();
	}
	
	static testmethod void testIsCMEOShown(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        
        
        fundingRequest = [SELECT Benefits_Exchanged_for_Funding__c, Record_Type_Name__c FROM GFRS_Funding_Request__c];
		
		Test.startTest();
			Boolean result = gFRS_Util.isCMEOShown(fundingRequest);
			System.assert(result == false);
			
			fundingRequest.Benefits_Exchanged_for_Funding__c = gFRS_Util.EXHIBIT_SPACE;
        
        	upsert fundingRequest;
        	
        	result = gFRS_Util.isCMEOShown(fundingRequest);
			System.assert(result == true);
        
		Test.stopTest();	
		
	}
	
	
	static testmethod void testRfiResetInformationNeeded(){
	
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        GFRS_Funding_Request__c[] requestsList = new GFRS_Funding_Request__c[1];
        requestsList[0] = fundingRequest;
        
        Test.startTest();
        	System.assert(fundingRequest.Information_Needed__c != null);
        	
        	gFRS_Util.RfiResetInformationNeeded(requestsList);
        	
        	System.assert(fundingRequest.Information_Needed__c == null);
        Test.stopTest();
        	
		
	}
	
	static testmethod void testLinkBudgetLIsToFMV(){
		//ToDo: we need to add Boolean flag for GFRS_Request_Budget_Line_Item__c triggers, because now we are not albe to prepare test data without launching
		//GFRS_Request_Budget_Line_Item__c triggers, which launch linkBudgetLIsToFMV method
       //prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        createContentAndTranslation();
        
        GFRS_Program__c program = gFRS_UnitTestHelper.createProgram(fundingRequest.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_HC_RECTYPE);
        insert program;

		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
       	User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
       	
       	GFRS_FMV__c fmv = gFRS_UnitTestHelper.createFmv('Venue', 'Activity Marketing', 1, 5, 'Enduring Materials', 10);
       	insert fmv;
       	
       	GFRS_RequestBudget__c testRequestBudget = gFRS_UnitTestHelper.createRequestBudget('test summary description', 5, 5, 5 ,5, fundingRequest.Id, program.Id, 5, 'Live', 5);
       	insert testRequestBudget;

       	GFRS_Request_Budget_Line_Item__c testRequestBudgetLineItem = gFRS_UnitTestHelper.createRequestBudgetLineItem(5, testRequestBudget.Id, 'Venue', 'Activity Marketing', 7, null, null, 5);
       	insert testRequestBudgetLineItem;
       	
       	GFRS_Request_Budget_Line_Item__c[] newValues = [SELECT Id, Name, FMV_Lower__c, FMV_Median__c, FMV_Upper__c , Budget__r.Budget_Summary_Description__c, Budget_Category__c, Budget_Subcategory__c, Budget__r.Grant_Request__c  from GFRS_Request_Budget_Line_Item__c ];
       	
       	Map<Id, GFRS_Request_Budget_Line_Item__c> oldValues = new Map<Id, GFRS_Request_Budget_Line_Item__c>([SELECT Id, Name, FMV_Lower__c, FMV_Median__c, FMV_Upper__c, Budget__r.Budget_Summary_Description__c, Budget_Category__c, Budget_Subcategory__c, Budget__r.Grant_Request__c from GFRS_Request_Budget_Line_Item__c]);
       	GFRS_Request_Budget_Line_Item__c tempLineItem = oldValues.get(testRequestBudgetLineItem.Id);
       	tempLineItem.Budget_Subcategory__c = 'Certificate Fees';


       	Test.startTest();
       		
       		GFRS_Request_Budget_Line_Item__c[] resultValues = [SELECT FMV_Lower__c, FMV_Median__c, FMV_Upper__c FROM GFRS_Request_Budget_Line_Item__c WHERE Id =:testRequestBudgetLineItem.Id];
       	
       		System.assert(resultValues[0].FMV_Lower__c == 1);
       		System.assert(resultValues[0].FMV_Median__c == 5);
       		System.assert(resultValues[0].FMV_Upper__c == 10);
       		
       		fmv.Budget_Category__c = 'Accreditation';
       		upsert fmv;
       		
       		gFRS_Util.linkBudgetLIsToFMV(newValues, oldValues);
       		
       		resultValues = [SELECT FMV_Lower__c, FMV_Median__c, FMV_Upper__c FROM GFRS_Request_Budget_Line_Item__c WHERE Id =:testRequestBudgetLineItem.Id];
       		
       		System.assert(resultValues[0].FMV_Lower__c == null);
       		System.assert(resultValues[0].FMV_Median__c == null);
       		System.assert(resultValues[0].FMV_Upper__c == null);
       	Test.stopTest();
       	
	}
	
	static testmethod void testCheckIfUserHaveSharing(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        
        Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
       	User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
       	

		gFRS_Funding_Request__Share sharingObject  = new gFRS_Funding_Request__Share();
        sharingObject.ParentId = fundingRequest.Id;
        sharingObject.UserOrGroupId = testUser.Id;
        sharingObject.AccessLevel  = 'Edit';
        sharingObject.RowCause = Schema.gFRS_Funding_Request__Share.RowCause.Manual;    
        insert sharingObject;   	


        Test.startTest();
        
        	gFRS_Funding_Request__Share result = gFRS_Util.getUserSharing(fundingRequest.Id, testUser.Id, new List<gFRS_Funding_Request__Share>{sharingObject});
        	System.assert(result != null);
        	
        	result = gFRS_Util.getUserSharing(fundingRequest.Id, null, new List<gFRS_Funding_Request__Share>{sharingObject});
        	System.assert(result == null);

        	
		Test.stopTest();	
	}



	static testmethod void testSetRecallDate(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'New', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        
		List<GFRS_Funding_Request__c> newList = new List<GFRS_Funding_Request__c>{fundingRequest};
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, Sub_Status__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
		GFRS_Funding_Request__c tempRequest = oldMap.get(fundingRequest.Id);
		tempRequest.Sub_Status__c = 'CCO Review';

        Test.startTest();
        
        	GFRS_Funding_Request__c result = [SELECT Recall_Date__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id];
        	System.assert(result.Recall_Date__c == null);
        	
        	gFRS_Util.setRecallDate(newList, oldMap);
        	
        	System.assert(newList.get(0).Recall_Date__c != null, 'MESSAGES: ' + newList);
        	
        
        Test.stopTest();	
		
	}
	
		

	static testmethod void testShowFoundation(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'Canceled', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        
        GFRS_Funding_Request__c fundingRequest2 = gFRS_UnitTestHelper.createHCFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'Canceled', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest2.Pediatric_Cancer_Assistance__c = 'Yes';
        upsert fundingRequest2;
        
        GFRS_Funding_Request__c fundingRequest3 = gFRS_UnitTestHelper.createPhilantrophicFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'Canceled', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest3.Students_of_Color_Scholarships__c = 'Yes';
        upsert fundingRequest3;
        
        GFRS_Funding_Request__c fundingRequest4 = gFRS_UnitTestHelper.createFellowshipsFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'Canceled', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest4.Basic_Research_Fellow__c = 'Yes';
        upsert fundingRequest4;
        
        GFRS_Funding_Request__c fundingRequest5 = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'Canceled', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        upsert fundingRequest5;
        
        Test.startTest();

        	Boolean result = gFRS_Util.showFoundation(null);
        	System.assert(result == false);
        	
        	//Corporate Membership part
        	result = gFRS_Util.showFoundation(fundingRequest.Id);
        	System.assert(result == false);
        	
        	//HC Char part
        	result = gFRS_Util.showFoundation(fundingRequest2.Id);
        	System.assert(result == true);
        	
        	
        	//Philantrpophic part
        	result = gFRS_Util.showFoundation(fundingRequest3.Id);
        	System.assert(result == true);
        	
        	fundingRequest3.Students_of_Color_Scholarships__c = 'No';
        	fundingRequest3.Hunger__c = 'No';
        	fundingRequest3.Requested_Amount__c = 25001;
        	upsert fundingRequest3;
        	result = gFRS_Util.showFoundation(fundingRequest3.Id);
        	System.assert(result == true);
        	
        	fundingRequest3.Requested_Amount__c = 25000;
        	upsert fundingRequest3;
        	result = gFRS_Util.showFoundation(fundingRequest3.Id);
        	System.assert(result == false);
        	
        	
        	//Fellowships part
        	result = gFRS_Util.showFoundation(fundingRequest4.Id);
        	System.assert(result == true);
        	fundingRequest4.Basic_Research_Fellow__c = 'No';
        	upsert fundingRequest4;
        	result = gFRS_Util.showFoundation(fundingRequest4.Id);
        	System.assert(result == false);
        	
        	
        	//Other Fundig Type - IMED
        	result = gFRS_Util.showFoundation(fundingRequest5.Id);
        	System.assert(result == false);
        	
        
        Test.stopTest();	
        
        
	}
	

	static testmethod void testGetFundingRequestsByLocationId(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'New', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        
		
		
		Test.startTest();
		
			List<GFRS_Funding_Request__c> result = gFRS_Util.getFundingRequestsByLocationId(testLocation.Id);
			System.assert(result != null);
		
		Test.stopTest();	
			
	}
	
	static testmethod void testSubmitHC_Programs(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createHCFundingRequestObject(testOrganization.Id, testLocation.Id, 'HC Compliance', 'New', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        insert fundingRequest;
        createContentAndTranslation();
        
        GFRS_Program__c program = gFRS_UnitTestHelper.createProgram(fundingRequest.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_HC_RECTYPE);
        program.Program_Status__c = 'Planned';
        insert program;
        
		List<GFRS_Funding_Request__c> newList = [SELECT Id, Status__c, Sub_Status__c, Record_Type_Name__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id];
		
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, Status__c, Sub_Status__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
			oldMap.get(fundingRequest.Id).Status__c = 'Intake';
			
			
		Test.startTest();

			gFRS_Util.submitHC_Programs(newList, oldMap);
			GFRS_Program__c result = [SELECT Id, Program_Status__c FROM gFRS_Program__c WHERE Funding_Request__c = :fundingRequest.Id];
			
			System.assert(result.Program_Status__c == 'Confirmed');
			
			
			program.Program_Status__c = 'Submitted';
			update program;
			
			gFRS_Util.submitHC_Programs(newList, oldMap);
			result = [SELECT Id, Program_Status__c FROM gFRS_Program__c WHERE Funding_Request__c = :fundingRequest.Id];
			
			System.assert(result.Program_Status__c == 'Submitted');
			
		Test.stopTest();
		
	}

	static testmethod void testAutoPopulateCCOOwnerIfNeeded(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
		User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
		testUser = [SELECT Name FROM User WHERE Id =:testUser.Id];
		
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createHCFundingRequestObject(testOrganization.Id, testLocation.Id, 'HC Compliance', 'CCO Review', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest.CCO_Owner__c = null;
        insert fundingRequest;
        createContentAndTranslation();
        
        GFRS_Program__c program = gFRS_UnitTestHelper.createProgram(fundingRequest.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_HC_RECTYPE);
        program.Program_Status__c = 'Planned';
        insert program;
        
		List<GFRS_Funding_Request__c> newList = [SELECT Id, CCO_Owner__c, Status__c, Sub_Status__c, Record_Type_Name__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id];
		
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, CCO_Owner__c, Status__c, Sub_Status__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
	
		//We have to add sharing for test user
		gFRS_Funding_Request__Share fundingRequestSharing = gFRS_Util.createRequestShare(fundingRequest.Id, testUser.Id, 'Edit');
		insert fundingRequestSharing;

		System.runAs(testUser) {
			Test.startTest();
				
				gFRS_Util.autoPopulateCCOOwnerIfNeeded(newList, oldMap);
				upsert fundingRequest;
					
				GFRS_Funding_Request__c result = [SELECT CCO_Owner__c FROM GFRS_Funding_Request__c WHERE Id =:fundingRequest.Id];
				System.assert(newList.get(0).CCO_Owner__c == null);
				
				GFRS_Funding_Request__c tmpRequest = oldMap.get(fundingRequest.Id);
				tmpRequest.Sub_Status__c = 'RFI';
				tmpRequest.External_Sub_status__c = 'RFI';

				
				gFRS_Util.autoPopulateCCOOwnerIfNeeded(newList, oldMap);
				upsert fundingRequest;
				
				result = [SELECT CCO_Owner__c FROM GFRS_Funding_Request__c WHERE Id =:fundingRequest.Id];
				System.assert(newList.get(0).CCO_Owner__c != null, 'MESSAGE: ' + newList.get(0));

			Test.stopTest();
		}
			
	}


	static testmethod void testResetFieldsAfterRecallCAPP(){
		
	//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
		User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
		testUser = [SELECT Name FROM User WHERE Id =:testUser.Id];
		
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createHCFundingRequestObject(testOrganization.Id, testLocation.Id, 'HC Compliance', 'CCO Review', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest.Legal_Reviewer_1__c = testUser.Id;
        fundingRequest.Business_Reviewer_Decision_Date__c = Date.today();
        fundingRequest.Business_Reviewer_Decision__c = 'Approved';
        fundingRequest.CCO_Decision__c = 'Approved';
        fundingRequest.CCO_Decision_Date__c = Date.today();
        fundingRequest.Decision_Date__c = Date.today();
        fundingRequest.Financial_Approver_1_Decision__c = 'Approved';
        fundingRequest.Financial_Approver_1_Decision_Date__c = Date.today();
        fundingRequest.Financial_Approver_2_Decision__c = 'Approved';
        fundingRequest.Financial_Approver_2_Decision_Date__c = Date.today();
        fundingRequest.Financial_Approver_3_Decision__c = 'Approved';
        fundingRequest.Financial_Approver_3_Decision_Date__c = Date.today();
        fundingRequest.GC_Decision__c = 'Approved';
        fundingRequest.GC_Review_Decision_Date__c = Date.today();
        fundingRequest.HC_Compliance_Date__c = Date.today();
        fundingRequest.Legal_Decision__c = 'Approved';
        fundingRequest.Legal_Decision_Date__c = Date.today();
        fundingRequest.Legal_Review_Status_Date__c = Date.today();
        fundingRequest.Business_Approver_Decision_Date__c = Date.today();
        fundingRequest.Business_Approver_Decision__c = 'Approved';
        fundingRequest.SYS_Request_Approved__c = 'Approved';
        insert fundingRequest;

		List<GFRS_Funding_Request__c> newList = [SELECT Id, CCO_Owner__c, Foundation_Classified__c, Status__c, Sub_Status__c, Record_Type_Name__c, Business_Reviewer_Decision_Date__c, Recall_Approval_Type__c, Business_Reviewer_Decision__c, CCO_Decision__c, CCO_Decision_Date__c, Decision_Date__c, Financial_Approver_1_Decision__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision__c, Financial_Approver_2_Decision_Date__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c, GC_Decision__c, GC_Review_Decision_Date__c, HC_Compliance_Date__c, Legal_Decision__c, Legal_Decision_Date__c, Legal_Review_Status_Date__c, Business_Approver_Decision_Date__c, Business_Approver_Decision__c, SYS_Request_Approved__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id];
		
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, CCO_Owner__c, Foundation_Classified__c, Status__c, Sub_Status__c, Record_Type_Name__c, Business_Reviewer_Decision_Date__c, Recall_Approval_Type__c, Business_Reviewer_Decision__c, CCO_Decision__c, CCO_Decision_Date__c, Decision_Date__c, Financial_Approver_1_Decision__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision__c, Financial_Approver_2_Decision_Date__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c, GC_Decision__c, GC_Review_Decision_Date__c, HC_Compliance_Date__c, Legal_Decision__c, Legal_Decision_Date__c, Legal_Review_Status_Date__c, Business_Approver_Decision_Date__c, Business_Approver_Decision__c, SYS_Request_Approved__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
		GFRS_Funding_Request__c tmpRequest = oldMap.get(fundingRequest.Id);
		tmpRequest.Sub_Status__c = 'RFI';
		
		Test.startTest();	
			
			System.assert(newList.get(0).Business_Reviewer_Decision_Date__c != null); 
			System.assert(newList.get(0).Business_Reviewer_Decision__c != null); 
			System.assert(newList.get(0).CCO_Decision__c != null); 
			System.assert(newList.get(0).CCO_Decision_Date__c != null); 
			System.assert(newList.get(0).Decision_Date__c != null); 
			System.assert(newList.get(0).Financial_Approver_1_Decision__c != null); 
			System.assert(newList.get(0).Financial_Approver_1_Decision_Date__c != null); 
			System.assert(newList.get(0).Financial_Approver_2_Decision__c != null); 
			System.assert(newList.get(0).Financial_Approver_2_Decision_Date__c != null); 
			System.assert(newList.get(0).Financial_Approver_3_Decision__c != null); 
			System.assert(newList.get(0).Financial_Approver_3_Decision_Date__c != null); 
			System.assert(newList.get(0).GC_Decision__c != null); 
			System.assert(newList.get(0).GC_Review_Decision_Date__c != null); 
			System.assert(newList.get(0).HC_Compliance_Date__c != null); 
			System.assert(newList.get(0).Legal_Decision__c != null); 
			System.assert(newList.get(0).Legal_Decision_Date__c != null); 
			System.assert(newList.get(0).Legal_Review_Status_Date__c != null); 
			System.assert(newList.get(0).Business_Approver_Decision_Date__c != null);  
			System.assert(newList.get(0).Business_Approver_Decision__c != null);  
			System.assert(newList.get(0).SYS_Request_Approved__c != null); 
			
			gFRS_Util.resetFieldsAfterRecall(newList, oldMap);
			
			System.assert(newList.get(0).Recall_Approval_Type__c == null); 
			System.assert(newList.get(0).Business_Reviewer_Decision_Date__c == null); 
			System.assert(newList.get(0).Business_Reviewer_Decision__c == null); 
			System.assert(newList.get(0).CCO_Decision__c == null); 
			System.assert(newList.get(0).CCO_Decision_Date__c == null); 
			System.assert(newList.get(0).Decision_Date__c == null); 
			System.assert(newList.get(0).Financial_Approver_1_Decision__c == null); 
			System.assert(newList.get(0).Financial_Approver_1_Decision_Date__c == null); 
			System.assert(newList.get(0).Financial_Approver_2_Decision__c == null); 
			System.assert(newList.get(0).Financial_Approver_2_Decision_Date__c == null); 
			System.assert(newList.get(0).Financial_Approver_3_Decision__c == null); 
			System.assert(newList.get(0).Financial_Approver_3_Decision_Date__c == null); 
			System.assert(newList.get(0).GC_Decision__c == null); 
			System.assert(newList.get(0).GC_Review_Decision_Date__c == null); 
			System.assert(newList.get(0).HC_Compliance_Date__c == null); 
			System.assert(newList.get(0).Legal_Decision__c == null); 
			System.assert(newList.get(0).Legal_Decision_Date__c == null); 
			System.assert(newList.get(0).Legal_Review_Status_Date__c == null); 
			System.assert(newList.get(0).Business_Approver_Decision_Date__c == null); 
			System.assert(newList.get(0).Business_Approver_Decision_Date__c == null);  
			System.assert(newList.get(0).SYS_Request_Approved__c == null); 
		Test.stopTest();
	
	}
	
	
	static testmethod void testResetFieldsAfterRecallIMED(){
		
	//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
		User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
		testUser = [SELECT Name FROM User WHERE Id =:testUser.Id];
		
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(testOrganization.Id, testLocation.Id, 'HC Compliance', 'CCO Review', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
		fundingRequest.Business_Approver_Decision__c = 'Approved';
		fundingRequest.Business_Approver_Decision_Date__c = Date.today();
		fundingRequest.CCO_Decision__c = 'Approved';
		fundingRequest.CCO_Decision_Date__c = Date.today();
		fundingRequest.Decision_Date__c = Date.today();
		fundingRequest.Financial_Approver_1_Decision__c = 'Approved';
		fundingRequest.Financial_Approver_1_Decision_Date__c = Date.today();
		fundingRequest.Financial_Approver_2_Decision__c = 'Approved';
		fundingRequest.Financial_Approver_2_Decision_Date__c = Date.today();
		fundingRequest.Financial_Approver_3_Decision__c = 'Approved';
		fundingRequest.Financial_Approver_3_Decision_Date__c = Date.today();
		fundingRequest.Financial_Approver_4_Decision__c = 'Approved';
		fundingRequest.Financial_Approver_4_Decision_Date__c = Date.today();
		fundingRequest.Financial_Approver_5_Decision__c = 'Approved';
		fundingRequest.Financial_Approver_5_Decision_Date__c = Date.today();
		fundingRequest.GC_Decision__c = 'Approved';
		fundingRequest.GC_Review_Decision_Date__c = Date.today();
		fundingRequest.HC_Compliance_Date__c = Date.today();
		fundingRequest.Legal_Review_Status_Date__c = Date.today();
		fundingRequest.Business_Approver_Decision__c = 'Approved';
		fundingRequest.SYS_Request_Approved__c = 'Approved';
		
        insert fundingRequest;

		List<GFRS_Funding_Request__c> newList = [SELECT Id, CCO_Owner__c, Status__c, Sub_Status__c, Record_Type_Name__c, Business_Approver_Decision__c, Business_Approver_Decision_Date__c, CCO_Decision__c, CCO_Decision_Date__c, Decision_Date__c, Financial_Approver_1_Decision__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision__c, Financial_Approver_2_Decision_Date__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c, Financial_Approver_4_Decision__c, Financial_Approver_4_Decision_Date__c, Financial_Approver_5_Decision__c, Financial_Approver_5_Decision_Date__c, GC_Decision__c, GC_Review_Decision_Date__c, HC_Compliance_Date__c, Legal_Review_Status_Date__c,   Recall_Approval_Type__c, SYS_Request_Approved__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id];
		
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, CCO_Owner__c, Status__c, Sub_Status__c, Record_Type_Name__c,  Business_Approver_Decision_Date__c, CCO_Decision__c, CCO_Decision_Date__c, Decision_Date__c, Financial_Approver_1_Decision__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision__c, Financial_Approver_2_Decision_Date__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c, Financial_Approver_4_Decision__c, Financial_Approver_4_Decision_Date__c, Financial_Approver_5_Decision__c, Financial_Approver_5_Decision_Date__c, GC_Decision__c, GC_Review_Decision_Date__c, HC_Compliance_Date__c, Legal_Review_Status_Date__c, Business_Approver_Decision__c,  Recall_Approval_Type__c, SYS_Request_Approved__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
		GFRS_Funding_Request__c tmpRequest = oldMap.get(fundingRequest.Id);
		tmpRequest.Sub_Status__c = 'RFI';
		
		Test.startTest();	
			
			System.assert(newList.get(0).Business_Approver_Decision__c != null);  
			System.assert(newList.get(0).Business_Approver_Decision_Date__c != null);  
			System.assert(newList.get(0).CCO_Decision__c != null);  
			System.assert(newList.get(0).CCO_Decision_Date__c != null);  
			System.assert(newList.get(0).Decision_Date__c != null);  
			System.assert(newList.get(0).Financial_Approver_1_Decision__c != null);  
			System.assert(newList.get(0).Financial_Approver_1_Decision_Date__c != null);  
			System.assert(newList.get(0).Financial_Approver_2_Decision__c != null);  
			System.assert(newList.get(0).Financial_Approver_2_Decision_Date__c != null);  
			System.assert(newList.get(0).Financial_Approver_3_Decision__c != null);  
			System.assert(newList.get(0).Financial_Approver_3_Decision_Date__c != null);  
			System.assert(newList.get(0).Financial_Approver_4_Decision__c != null);  
			System.assert(newList.get(0).Financial_Approver_4_Decision_Date__c != null);  
			System.assert(newList.get(0).Financial_Approver_5_Decision__c != null);  
			System.assert(newList.get(0).Financial_Approver_5_Decision_Date__c != null);  
			System.assert(newList.get(0).GC_Decision__c != null);  
			System.assert(newList.get(0).GC_Review_Decision_Date__c != null);  
			System.assert(newList.get(0).HC_Compliance_Date__c != null);  
			System.assert(newList.get(0).Legal_Review_Status_Date__c != null);  
			System.assert(newList.get(0).Business_Approver_Decision__c != null);     
			System.assert(newList.get(0).SYS_Request_Approved__c != null); 

			gFRS_Util.resetFieldsAfterRecall(newList, oldMap);
			
			System.assert(newList.get(0).Business_Approver_Decision__c == null);  
			System.assert(newList.get(0).Business_Approver_Decision_Date__c == null);  
			System.assert(newList.get(0).CCO_Decision__c == null);  
			System.assert(newList.get(0).CCO_Decision_Date__c == null);  
			System.assert(newList.get(0).Decision_Date__c == null);  
			System.assert(newList.get(0).Financial_Approver_1_Decision__c == null);  
			System.assert(newList.get(0).Financial_Approver_1_Decision_Date__c == null);  
			System.assert(newList.get(0).Financial_Approver_2_Decision__c == null);  
			System.assert(newList.get(0).Financial_Approver_2_Decision_Date__c == null);  
			System.assert(newList.get(0).Financial_Approver_3_Decision__c == null);  
			System.assert(newList.get(0).Financial_Approver_3_Decision_Date__c == null);  
			System.assert(newList.get(0).Financial_Approver_4_Decision__c == null);  
			System.assert(newList.get(0).Financial_Approver_4_Decision_Date__c == null);  
			System.assert(newList.get(0).Financial_Approver_5_Decision__c == null);  
			System.assert(newList.get(0).Financial_Approver_5_Decision_Date__c == null);  
			System.assert(newList.get(0).GC_Decision__c == null);  
			System.assert(newList.get(0).GC_Review_Decision_Date__c == null);  
			System.assert(newList.get(0).HC_Compliance_Date__c == null);  
			System.assert(newList.get(0).Legal_Review_Status_Date__c == null);  
			System.assert(newList.get(0).Business_Approver_Decision__c == null);    
			System.assert(newList.get(0).Recall_Approval_Type__c == null);  
			System.assert(newList.get(0).SYS_Request_Approved__c == null); 

		Test.stopTest();	
	}

	
	static testmethod void testResetFieldsAfterRecallFoundation(){
		
	//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
		User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
		testUser = [SELECT Name FROM User WHERE Id =:testUser.Id];
		
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createHCFundingRequestObject(testOrganization.Id, testLocation.Id, 'HC Compliance', 'CCO Review', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest.Legal_Reviewer_1__c = testUser.Id;       
		fundingRequest.Business_Approver_Decision__c = 'Approved';
		fundingRequest.Business_Approver_Decision_Date__c = Date.today();
		fundingRequest.Business_Approver_2_Decision__c = 'Approved';
		fundingRequest.Business_Approver_2_Decision_Date__c = Date.today();			
		fundingRequest.Business_Approver_3_Decision__c = 'Approved';
		fundingRequest.Business_Approver_3_Decision_Date__c = Date.today();
		fundingRequest.GC_Decision__c = 'Approved';
		fundingRequest.GC_Review_Decision_Date__c = Date.today();
		fundingRequest.Business_Reviewer_Decision__c = 'Approved';
		fundingRequest.Business_Reviewer_Decision_Date__c = Date.today();
		fundingRequest.Recall_Approval_Type__c = 'Foundation';
		fundingRequest.SYS_Request_Approved__c = 'Approved';
        fundingRequest.Recall_Approval_Type__c = 'Foundation';
        fundingRequest.Foundation_Eligible__c = 'Yes';
        insert fundingRequest;

		List<GFRS_Funding_Request__c> newList = [SELECT Id, Business_Approver_2_Decision__c, Business_Approver_2_Decision_Date__c, Business_Approver_3_Decision__c, Business_Approver_3_Decision_Date__c, CCO_Owner__c, Foundation_Classified__c, Status__c, Sub_Status__c, Record_Type_Name__c, Business_Reviewer_Decision_Date__c, Recall_Approval_Type__c, Business_Reviewer_Decision__c, CCO_Decision__c, CCO_Decision_Date__c, Decision_Date__c, Financial_Approver_1_Decision__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision__c, Financial_Approver_2_Decision_Date__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c, GC_Decision__c, GC_Review_Decision_Date__c, HC_Compliance_Date__c, Legal_Decision__c, Legal_Decision_Date__c, Legal_Review_Status_Date__c, Business_Approver_Decision_Date__c, Business_Approver_Decision__c, SYS_Request_Approved__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id];
		
		System.debug('PN: IS REQUEST FOUNDATION?::::: ' + newList.get(0).Foundation_Classified__c);
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, CCO_Owner__c, Business_Approver_2_Decision__c, Business_Approver_2_Decision_Date__c, Business_Approver_3_Decision__c, Business_Approver_3_Decision_Date__c, Foundation_Classified__c, Status__c, Sub_Status__c, Record_Type_Name__c, Business_Reviewer_Decision_Date__c, Recall_Approval_Type__c, Business_Reviewer_Decision__c, CCO_Decision__c, CCO_Decision_Date__c, Decision_Date__c, Financial_Approver_1_Decision__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision__c, Financial_Approver_2_Decision_Date__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c, GC_Decision__c, GC_Review_Decision_Date__c, HC_Compliance_Date__c, Legal_Decision__c, Legal_Decision_Date__c, Legal_Review_Status_Date__c, Business_Approver_Decision_Date__c, Business_Approver_Decision__c, SYS_Request_Approved__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
		GFRS_Funding_Request__c tmpRequest = oldMap.get(fundingRequest.Id);
		tmpRequest.Sub_Status__c = 'RFI';
		tmpRequest.Recall_Approval_Type__c = null;
		
		Test.startTest();	
			
			System.assert(newList.get(0).Business_Approver_Decision__c != null); 
			System.assert(newList.get(0).Business_Approver_Decision_Date__c != null); 
			System.assert(newList.get(0).Business_Approver_2_Decision__c != null); 
			System.assert(newList.get(0).Business_Approver_2_Decision_Date__c != null); 			
			System.assert(newList.get(0).Business_Approver_3_Decision__c != null); 
			System.assert(newList.get(0).Business_Approver_3_Decision_Date__c != null); 
			System.assert(newList.get(0).GC_Decision__c != null); 
			System.assert(newList.get(0).GC_Review_Decision_Date__c != null); 
			System.assert(newList.get(0).Business_Reviewer_Decision__c != null); 
			System.assert(newList.get(0).Business_Reviewer_Decision_Date__c != null); 
			System.assert(newList.get(0).Recall_Approval_Type__c != null); 
			System.assert(newList.get(0).SYS_Request_Approved__c != null); 
			
			gFRS_Util.resetFieldsAfterRecall(newList, oldMap);
			
			System.assert(newList.get(0).Business_Approver_Decision__c == null); 
			System.assert(newList.get(0).Business_Approver_Decision_Date__c == null); 
			System.assert(newList.get(0).Business_Approver_2_Decision__c == null); 
			System.assert(newList.get(0).Business_Approver_2_Decision_Date__c == null); 			
			System.assert(newList.get(0).Business_Approver_3_Decision__c == null); 
			System.assert(newList.get(0).Business_Approver_3_Decision_Date__c == null); 
			System.assert(newList.get(0).GC_Decision__c == null); 
			System.assert(newList.get(0).GC_Review_Decision_Date__c == null); 
			System.assert(newList.get(0).Business_Reviewer_Decision__c == null); 
			System.assert(newList.get(0).Business_Reviewer_Decision_Date__c == null); 
			System.assert(newList.get(0).Recall_Approval_Type__c == null); 
			System.assert(newList.get(0).SYS_Request_Approved__c == null); 

		Test.stopTest();
	
	}
	
	static testmethod void testResetFieldsAfterRecallCorpMemb(){
		
	//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
		User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
		testUser = [SELECT Name FROM User WHERE Id =:testUser.Id];
		
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObjectWithoutSaving(testOrganization.Id, testLocation.Id, 'HC Compliance', 'CCO Review', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest.Legal_Reviewer_1__c = testUser.Id;
        fundingRequest.CCO_Decision__c = 'Approved';
		fundingRequest.CCO_Decision_Date__c = Date.today();
		fundingRequest.Decision_Date__c = Date.today();
		fundingRequest.Decision_Reasons__c = 'Approved';
		fundingRequest.Financial_Approver_1_Decision__c = 'Approved';
		fundingRequest.Financial_Approver_1_Decision_Date__c = Date.today();
		fundingRequest.Financial_Approver_2_Decision__c = 'Approved';
		fundingRequest.Financial_Approver_2_Decision_Date__c = Date.today();
		fundingRequest.Financial_Approver_3_Decision__c = 'Approved';
		fundingRequest.Financial_Approver_3_Decision_Date__c = Date.today();
		fundingRequest.HC_Compliance_Date__c = Date.today();
		fundingRequest.Legal_Decision__c = 'Approved';
		fundingRequest.Legal_Decision_Date__c = Date.today();
		fundingRequest.Legal_Review_Status_Date__c = Date.today();
		fundingRequest.LOA_Signed__c = 'Approved';
		fundingRequest.Process_Disposition_Date__c = Date.today();
		fundingRequest.SYS_Request_Approved__c = 'Approved';
        insert fundingRequest;

		List<GFRS_Funding_Request__c> newList = [SELECT Id, CCO_Owner__c, Status__c, Sub_Status__c, Record_Type_Name__c, CCO_Decision__c, CCO_Decision_Date__c, Decision_Date__c, Decision_Reasons__c, Financial_Approver_1_Decision__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision__c, Financial_Approver_2_Decision_Date__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c, HC_Compliance_Date__c, Legal_Decision__c, Legal_Decision_Date__c, Legal_Review_Status_Date__c, LOA_Signed__c, Process_Disposition_Date__c,  Business_Approver_Decision__c, Recall_Approval_Type__c, SYS_Request_Approved__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id];
		
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, CCO_Owner__c, Status__c, Sub_Status__c, Record_Type_Name__c, CCO_Decision__c, CCO_Decision_Date__c, Decision_Date__c, Decision_Reasons__c, Financial_Approver_1_Decision__c, Financial_Approver_1_Decision_Date__c, Financial_Approver_2_Decision__c, Financial_Approver_2_Decision_Date__c, Financial_Approver_3_Decision__c, Financial_Approver_3_Decision_Date__c, HC_Compliance_Date__c, Legal_Decision__c, Legal_Decision_Date__c, Legal_Review_Status_Date__c, LOA_Signed__c, Process_Disposition_Date__c, Business_Approver_Decision__c, Recall_Approval_Type__c, SYS_Request_Approved__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
		GFRS_Funding_Request__c tmpRequest = oldMap.get(fundingRequest.Id);
		tmpRequest.Sub_Status__c = 'RFI';
		
		Test.startTest();	
			
			System.assert(newList.get(0).CCO_Decision__c != null); 
			System.assert(newList.get(0).CCO_Decision_Date__c != null); 
			System.assert(newList.get(0).Decision_Date__c != null); 
			System.assert(newList.get(0).Decision_Reasons__c != null); 
			System.assert(newList.get(0).Financial_Approver_1_Decision__c != null); 
			System.assert(newList.get(0).Financial_Approver_1_Decision_Date__c != null); 
			System.assert(newList.get(0).Financial_Approver_2_Decision__c != null); 
			System.assert(newList.get(0).Financial_Approver_2_Decision_Date__c != null); 
			System.assert(newList.get(0).Financial_Approver_3_Decision__c != null); 
			System.assert(newList.get(0).Financial_Approver_3_Decision_Date__c != null); 
			System.assert(newList.get(0).HC_Compliance_Date__c != null); 
			System.assert(newList.get(0).Legal_Decision__c != null); 
			System.assert(newList.get(0).Legal_Decision_Date__c != null); 
			System.assert(newList.get(0).Legal_Review_Status_Date__c != null); 
			System.assert(newList.get(0).LOA_Signed__c != null); 
			System.assert(newList.get(0).Process_Disposition_Date__c != null); 
			System.assert(newList.get(0).SYS_Request_Approved__c != null); 
			
			gFRS_Util.resetFieldsAfterRecall(newList, oldMap);
			
			System.assert(newList.get(0).CCO_Decision__c == null); 
			System.assert(newList.get(0).CCO_Decision_Date__c == null); 
			System.assert(newList.get(0).Decision_Date__c == null); 
			System.assert(newList.get(0).Decision_Reasons__c == null); 
			System.assert(newList.get(0).Financial_Approver_1_Decision__c == null); 
			System.assert(newList.get(0).Financial_Approver_1_Decision_Date__c == null); 
			System.assert(newList.get(0).Financial_Approver_2_Decision__c == null); 
			System.assert(newList.get(0).Financial_Approver_2_Decision_Date__c == null); 
			System.assert(newList.get(0).Financial_Approver_3_Decision__c == null); 
			System.assert(newList.get(0).Financial_Approver_3_Decision_Date__c == null); 
			System.assert(newList.get(0).HC_Compliance_Date__c == null); 
			System.assert(newList.get(0).Legal_Decision__c == null); 
			System.assert(newList.get(0).Legal_Decision_Date__c == null); 
			System.assert(newList.get(0).Legal_Review_Status_Date__c == null); 
			System.assert(newList.get(0).LOA_Signed__c == null); 
			System.assert(newList.get(0).Process_Disposition_Date__c == null); 
			System.assert(newList.get(0).Recall_Approval_Type__c == null); 
			System.assert(newList.get(0).SYS_Request_Approved__c == null); 
			  
		Test.stopTest();
	
	}

	static testmethod void testAssignRequestBudgetFMV(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
		User testUser = gFRS_UnitTestHelper.createPortalUserWithoutSaving(testContact);
		insert testUser;
		testUser = [SELECT Id, Name, Alias FROM User WHERE Id =:testUser.Id];
		
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'HC Compliance', 'CCO Review', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        createContentAndTranslation();
        
        GFRS_Program__c program = gFRS_UnitTestHelper.createProgram(fundingRequest.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_HC_RECTYPE);
        insert program;
        
        GFRS_FMV__c fmv = gFRS_UnitTestHelper.createFmv('Total Management Fees', 'Activity Marketing', 1, 5, 'Enduring Materials', 10);
       	insert fmv;
       	
       	GFRS_RequestBudget__c testRequestBudget = gFRS_UnitTestHelper.createRequestBudget('test summary description', 10, 10, 10 ,10, fundingRequest.Id, program.Id, 5, 'Live', 5);
       	insert testRequestBudget;

		List<GFRS_RequestBudget__c> newList = [SELECT Id, Budget_Summary_Description__c, Grant_Request__c  FROM GFRS_RequestBudget__c WHERE Id = :testRequestBudget.Id];
				
		Map<Id, GFRS_RequestBudget__c> oldMap = new Map<Id, GFRS_RequestBudget__c>([SELECT Id, Budget_Summary_Description__c, Grant_Request__c  FROM GFRS_RequestBudget__c WHERE Id = :testRequestBudget.Id]);
		oldMap.get(testRequestBudget.Id).Budget_Summary_Description__c = 'test2';
		
		
		Test.startTest();
		
			gFRS_Util.assignRequestBudgetFMV(newList, oldMap);
			GFRS_RequestBudget__c result = [SELECT FMV_Median_Total_Management_Fees__c FROM GFRS_RequestBudget__c WHERE Id =:testRequestBudget.Id];
			System.assert(result.FMV_Median_Total_Management_Fees__c == 5);
		
		Test.stopTest();
		
	}
	

	static testmethod void testUpdateOrganizationAccreditationStatus(){
		
		//prepare data
		Account testAccount1 = gFRS_UnitTestHelper.createAccount('TestAccount1');
		Account testAccount2 = gFRS_UnitTestHelper.createAccount('TestAccount2');
		Account testAccount3 = gFRS_UnitTestHelper.createAccount('TestAccount3');

		
        GFRS_Organization__c testOrganization1 = gFRS_UnitTestHelper.createOrganization('99-9999991', testAccount1.Id);
        testOrganization1 = [SELECT ACCME_Accreditations__c, Tax_Id__c FROM GFRS_Organization__c WHERE Id = :testOrganization1.Id];
        GFRS_Organization__c testOrganization2 = gFRS_UnitTestHelper.createOrganization('99-9999992', testAccount2.Id);
        testOrganization2 = [SELECT ACCME_Accreditations__c, Tax_Id__c FROM GFRS_Organization__c WHERE Id = :testOrganization2.Id];
        
        gFRS_ACCME__c testAccme1 = gFRS_UnitTestHelper.createACCME('Accreditation', '99-9999991');
        insert testAccme1;
        
        List<GFRS_Organization__c> organizationList = new List<GFRS_Organization__c>{testOrganization1, testOrganization2};
        
        Test.startTest();
        
        	gFRS_Organization__c[] resultList = gFRS_Util.updateOrganizationAccreditationStatus(organizationList);
        	
        	System.assert(resultList.get(0).ACCME_Accreditations__c == 'Accreditation');
        
        Test.stopTest();
		
	}
	
		
	static testmethod void testAssignSObjectValue(){
		
		Account testAccount1 = gFRS_UnitTestHelper.createAccount('TestAccount1');
		
		Test.startTest();
			
			Boolean result = gFRS_Util.assignSObjectValue(testAccount1, 'Assistance_Profile_City_gne__c', 'test');
			System.assert(result);
			System.assert(testAccount1.Assistance_Profile_City_gne__c == 'test');
		
		Test.stopTest();
	}
	
	static testmethod void testSetBusinessUnit(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'New', 'Not Submitted', null, 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        fundingRequest.Business_Unit_2__c = 'BIOONC';
        
        
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        myOrgCS.BIOONC_BU_TA_Mapping__c = 'Oncology';
		myOrgCS.GIO_BU_TA_Mapping__c = 'Immunology|Ophthalmology|Respiratory';
		myOrgCS.IMPACT_BU_TA_Mapping__c = 'Cardiology|Endocrinology|Neuroscience|Pulmonary|Transplantation|Virology /Infectious Diseases|';
		myOrgCS.OTHER_BU_TA_Mapping__c = 'Other';
		myOrgCS.gFRS_HC_Compliance_Flag_Start_Date__c = Date.today();
        myOrgCS.Field_Initiated_Exhibits_WBS_1000__c='309.01006';
        myOrgCS.Field_Initiated_Exhibits_WBS_1010__c='309.07076';    
        upsert myOrgCS;

        
		List<GFRS_Funding_Request__c> newList = new List<GFRS_Funding_Request__c>{fundingRequest};
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, Sub_Status__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
		
		Test.startTest();
		
			gFRS_Util.SetBusinessUnit(newList,oldMap);
			System.assert(newList.get(0).Business_Unit_2__c == null);
			
			newList.get(0).Therapeutic_Area_Parent__c = 'Cardiology';
			oldMap.get(fundingRequest.Id).Therapeutic_Area_Parent__c = 'Endocrinology';
			gFRS_Util.SetBusinessUnit(newList, oldMap);
			System.assert(newList.get(0).Business_Unit_2__c == 'IMPACT', 'MESSAGE: ' + fundingRequest);
		
		Test.stopTest();
		
	}
	
	
	static testmethod void testBeforeUpdateFundingRequestLogic(){
		
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'New', 'Not Submitted', null, 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
        
		List<GFRS_Funding_Request__c> newList = new List<GFRS_Funding_Request__c>{fundingRequest};
		
		Map<Id, GFRS_Funding_Request__c> oldMap = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, Sub_Status__c FROM GFRS_Funding_Request__c WHERE Id = :fundingRequest.Id]);
		
		
		Test.startTest();
		
			//gFRS_Util.beforeUpdateFundingRequestLogic();
		
		Test.stopTest();
	}
	
	static testmethod void testIsRequestFoundationTypeNegative(){
		
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObject(testOrganization.Id, testLocation.Id, 'Decision', 'New', 'Not Submitted', null, 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
		
		
		Test.startTest();
		
			Boolean isFoundationType = gFRS_Util.isRequestFoundationType(fundingRequest.Id);
			System.assert(!isFoundationType);
		
		Test.stopTest();
		
	}
	
	
 	static testmethod void testIsRequestFoundationTypePositive(){
		
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createHCFundingRequestObject(testOrganization.Id, testLocation.Id, 'HC Compliance', 'CCO Review', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
 
		insert fundingRequest;
	
		Test.startTest();
		
			Boolean isFoundationType = gFRS_Util.isRequestFoundationType(fundingRequest.Id);
			System.assert(isFoundationType);
		
		Test.stopTest();
		
	}
	
	
	static testmethod void testFloatEqualsPositive(){
			
			Decimal var1 = 1.0;
			Decimal var2 = 1.0001;
			
			Test.startTest();
			
				Boolean result = gFRS_Util.floatEquals(var1, var2);
				System.assert(result);
			
			Test.stopTest(); 
		
	}
        
        
   static testmethod void testFloatEqualsNegative(){
			
			Decimal var1 = 1.0;
			Decimal var2 = 1.0002;
			
			Test.startTest();
			
				Boolean result = gFRS_Util.floatEquals(var1, var2);
				System.assert(!result);
			
			Test.stopTest(); 
		
	} 
	
	static testmethod void testInitializeLinkById(){
		
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
	
		String targetPage = 'testPage';
		Id requestId = testAccount.Id;
		String parameters = 'test=1';
		
		Test.startTest();
		
			String result = gFRS_Util.initializeLinkById(targetPage, requestId, parameters);
			System.assertEquals(result, 'testPage?t=t&id=' + requestId + '&test=1');
		
		Test.stopTest();	
		
	}
	
	static testmethod void testGetSentIdPositive(){
		
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		
		String URL = '/GFRS_Funding_Request_Read?id=' + testAccount.Id + '&sfdc.override=1';
		
		PageReference pageRef = new PageReference(URL);
		
		Test.setCurrentPage(pageRef);
		
		Test.startTest();
		
			Id result = gFRS_Util.getSentId('id');
			System.assertEquals(testAccount.Id, result);
		
		Test.stopTest();
	}
	
	static testmethod void testGetSentIdNegaitive1(){
		
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		
		String URL = '/GFRS_Funding_Request_Read?id=' + testAccount.Id + '&sfdc.override=1';
		
		PageReference pageRef = new PageReference(URL);
		
		Test.setCurrentPage(pageRef);
		
		Test.startTest();
		
			Id result = gFRS_Util.getSentId('fakeParam');
			System.assertEquals(null, result);
		
		Test.stopTest();
	}
	
	
	static testmethod void testGetSentIdNegaitive2(){
		
		Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
		
		String URL = '/GFRS_Funding_Request_Read?id=' + 'fakeId' + '&sfdc.override=1';
		
		PageReference pageRef = new PageReference(URL);
		
		Test.setCurrentPage(pageRef);
		
		Test.startTest();
		
			Id result = gFRS_Util.getSentId('id');
			System.assertEquals(null, result);
		
		Test.stopTest();
	}
	
	
	static testmethod void testIsUserInternal(){
	
		//prepare data
		Account testAccount = gFRS_UnitTestHelper.createAccount('testAccount');
		Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
		User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
		
		Test.startTest();	
		
			Boolean result = gFRS_Util_NoShare.isUserInternal(testUser.Id);
			System.assert(result);
		
		Test.stopTest();
	}

	static void createContentAndTranslation(){
		GFRS_Content__c content = new GFRS_Content__c(Name='Gcal_Header',Filter__c='Test_Gcal_Header'); 
        insert content;
        GFRS_Content_Translation__c translation = new GFRS_Content_Translation__c(GFRS_Content__c = content.Id, TextBlock__c = 'testTranslation', Language__c ='en_US');
        insert translation;
	}

    @IsTest
	static void testGetPicklistValues() {
        // Focus area picklist contains 5 items. If picklist is changed change also this value in test.
        Integer numberOfItems = 6;
        System.assertEquals(numberOfItems, gFRS_Util.getPicklistValues('GFRS_Funding_Request__c', 'Focus_Area__c').size());
    }

    @IsTest
    static void testUpdateFocusAreaField() {
        createFellowshipsFundingRequest();
        GFRS_Funding_Request__c fundingRequest = getRequestAfterUpdateOfSocialImpactGoals();

        System.assertEquals(null, fundingRequest.Focus_Area__c);

        gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        List<String> goals = gFRS_Util.getPicklistValues('GFRS_Funding_Request__c', 'Social_Impact_Goals_CEG__c');
        List<String> focus = gFRS_Util.getPicklistValues('GFRS_Funding_Request__c', 'Focus_Area__c');

        fundingRequest = setUpdatedSocialGoals('Strengthen pathways for STEM careers');
        System.assertEquals('STEM Pathways', fundingRequest.Focus_Area__c);

        fundingRequest = setUpdatedSocialGoals('Foster scientific innovation and exchange of ideas');
        System.assertEquals('Scientific Innovation', fundingRequest.Focus_Area__c);

        fundingRequest = setUpdatedSocialGoals('Advance local community development');
        System.assertEquals('Community development', fundingRequest.Focus_Area__c);

        fundingRequest = setUpdatedSocialGoals('Other');
        System.assertEquals('Others', fundingRequest.Focus_Area__c);

		fundingRequest = setUpdatedSocialGoals('Promote, test, and scale models to prevent disease');
        System.assertEquals('Health outcomes', fundingRequest.Focus_Area__c);

        fundingRequest = setUpdatedSocialGoals('Strengthen general disease awareness' + ';' + 'Improve awareness, access, and rates of early detection and diagnosis' + ';' + 'Support the enabling environment for patient care');
        System.assertEquals('Health outcomes', fundingRequest.Focus_Area__c);

        fundingRequest = setUpdatedSocialGoals('');
        System.assertEquals(null, fundingRequest.Focus_Area__c);

        try {
            fundingRequest = setUpdatedSocialGoals('Strengthen pathways for STEM careers' + ';' + 'Strengthen general disease awareness');
        } catch (DmlException e) {
            System.assert(true);
        }
    }

    @IsTest
    static void testGetListOfFundingRequestsWithFocusAreaField() {
        createFellowshipsFundingRequest();
        List<GFRS_Funding_Request__c> requests = new List<GFRS_Funding_Request__c>();

        gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        List<String> goals = gFRS_Util.getPicklistValues('GFRS_Funding_Request__c', 'Social_Impact_Goals_CEG__c');
        List<String> focus = gFRS_Util.getPicklistValues('GFRS_Funding_Request__c', 'Focus_Area__c');
        GFRS_Funding_Request__c fundingRequest = getRequestAfterUpdateOfSocialImpactGoals();

        fundingRequest = setUpdatedSocialGoals('Strengthen pathways for STEM careers');
        requests.add(fundingRequest);
        System.assertEquals('STEM Pathways', gFRS_Util.getListOfFundingRequestsWithFocusAreaField(requests)[0].Focus_Area__c);

    }
    static GFRS_Funding_Request__c setUpdatedSocialGoals(String goals) {
        GFRS_Funding_Request__c fundingRequest = getRequestAfterUpdateOfSocialImpactGoals();
        fundingRequest.Social_Impact_Goals_CEG__c = goals;
        if (goals.equals('Other')) {
            fundingRequest.If_other_please_specify_SocialImpact_goa__c = 'Other';
        }
        update fundingRequest;
        return getRequestAfterUpdateOfSocialImpactGoals();
    }

    static GFRS_Funding_Request__c getRequestAfterUpdateOfSocialImpactGoals() {
        return [SELECT Id, Name, Focus_Area__c, RecordTypeId, Social_Impact_Goals_CEG__c, If_other_please_specify_SocialImpact_goa__c FROM GFRS_Funding_Request__c LIMIT 1];
    }

    static void createFellowshipsFundingRequest() {
        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('34-8905643', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        insert(gFRS_UnitTestHelper.createFellowshipsFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments'));
    }

}