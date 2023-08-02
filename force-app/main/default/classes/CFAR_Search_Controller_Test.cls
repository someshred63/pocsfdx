@isTest(seeAllData = false)
private class CFAR_Search_Controller_Test {

	@testSetup
	static void setup() {
		CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
		CFAR_Utils.setActualTrialId(trial.Id);

		// add roles
		CFAR_TestUtils.createRolesToUsersMapping();

		// add product
		CFAR_TestUtils.createProduct('test product', 'test abrev', 'test genName');

	}
	static testMethod void unitTest_simpleSearchByContact() {
		// prepare for test
		CFAR_Search_Controller searchCtrl = new CFAR_Search_Controller();
		searchCtrl.basicSearch = false;
		CFAR_Contact_gne__c[] contacts = [SELECT Id, Last_Name_gne__c FROM CFAR_Contact_gne__c];
		searchCtrl.selectedSearchContacts.add(contacts[0].Last_Name_gne__c);
		
		searchCtrl.switchSearchType();
		ApexPages.currentPage().getParameters().put('aosParam','Trial');
		searchCtrl.searchWrapper.areaOfSearch = 'Trial';
		searchCtrl.searchWrapper.searchString = 'ACC';

		// run test
		searchCtrl.search();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();
		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		myTrialsXLS.sortDirection = 'asc';
		myTrialsXLS.sortExpression = 'Name';
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrialXLS();
		myTrialsXLS.getWorkbookProperties();
		myTrialsXLS.getFileName();
		CFAR_Contact_gne__c[] primaryInvestigator = [SELECT Search_Name__c FROM CFAR_Contact_gne__c WHERE Primary_Role_Function_gne__c = 'PI = Primary (or Principal) Investigator' LIMIT 1];

		// assert
		System.Assert(resultList.size() > 0);
		System.AssertEquals(String.valueOf(resultList[0].innerObject.get('frm_Investigator_ref_gne__c')), primaryInvestigator[0].Search_Name__c);
		System.AssertEquals(String.valueOf(resultListXLS[0].innerObject.get('frm_Investigator_ref_gne__c')), primaryInvestigator[0].Search_Name__c);
	}

	static testMethod void unitTest_searchByMultipleFields() {
		CFAR_Trial_Status_gne__c testTrialStatus = new CFAR_Trial_Status_gne__c();
		insert testTrialStatus;
		CFAR_Dollar_and_Drug_gne__c testgneSupport = new CFAR_Dollar_and_Drug_gne__c();
		insert testgneSupport;
		CFAR_Picklist_Value_gne__c testSRTTeam = new CFAR_Picklist_Value_gne__c(RecordTypeId = Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('SRT Team').getRecordTypeId());
		CFAR_Picklist_Value_gne__c testImpact = new CFAR_Picklist_Value_gne__c(RecordTypeId = Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('Impact').getRecordTypeId());
		insert new List<CFAR_Picklist_Value_gne__c> {testSRTTeam, testImpact};
		CFAR_Trial_gne__c testTrial = CFAR_DAO.getTrialsLessFields(new CFAR_SearchParameters())[0];
		testTrial.Subject_Type__c = 'Animal';
		testTrial.Trial_Status_ref_gne__c = testTrialStatus.Id;
		testTrial.Pediatric_Study_gne__c = 'Yes';
		testTrial.Dollar_and_Drug_ref_gne__c = testgneSupport.id;
		testTrial.SRT_Team_ref_gne__c = testSRTTeam.Id;
		testTrial.Lab_Support_gne__c = 'YES';
		testTrial.Impacts_gne__c = testImpact.Id;
		update testTrial;
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;
		searchObject.selectedStudyStatus = new List<String>{testTrialStatus.Id};
		searchObject.selectedPediatricStudy = 'Yes';
		searchObject.selectedGNESupport = new List<String>{testgneSupport.Id};
		searchObject.selectedSRTTeam = new List<String>{testSRTTeam.Id};
		searchObject.selectedSubjectType = new List<String> {'Animal'};
		searchObject.selectedBOMSupport = 'YES';
		searchObject.selectedImpact = new List<String>{testImpact.Id};
		searchObject.search();

		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getObjectListTrial();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();

		System.AssertEquals(testTrial.Id, resultList[0].innerObject.get('Id'));
	}

	static testMethod void unitTest_searchByContact() {
		// prepare for test
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;
		CFAR_Contact_gne__c[] contacts = [SELECT Id FROM CFAR_Contact_gne__c];
		searchObject.selectedSearchContacts.add(contacts[0].Id);
		
		// run test
		searchObject.search();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();
		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();

		CFAR_Contact_gne__c[] primaryInvestigator = [SELECT Search_Name__c FROM CFAR_Contact_gne__c WHERE Primary_Role_Function_gne__c = 'PI = Primary (or Principal) Investigator' LIMIT 1];

		// assert
		System.Assert(resultList.size() > 0);
		System.AssertEquals(String.valueOf(resultList[0].innerObject.get('frm_Investigator_ref_gne__c')), primaryInvestigator[0].Search_Name__c);
	}

	static testMethod void unitTest_searchByRoles() {
		// prepare for test
		CFAR_Trial_gne__c testTrial = [SELECT Investigator_ref_gne__c, Genentech_Primary_Contact_ref_gne__c, MSL_ref_gne__c, Received_Date_gne__c FROM CFAR_Trial_gne__c];
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;

		CFAR_Contact_Address_gne__c testAddress = CFAR_TestUtils.createTestAddress();
		CFAR_Team_Member_gne__c PI = helperMethod_CreateTeamMember('PI = Primary (or Principal) Investigator', testTrial,testAddress);
		CFAR_Team_Member_gne__c MSL = helperMethod_CreateTeamMember('MSL = Medical Science Liaison', testTrial,testAddress);
		CFAR_Team_Member_gne__c PC = helperMethod_CreateTeamMember('CSA = Clinical Study Associate', testTrial,testAddress);

		searchObject.selectedSearchInvestigator.add(testTrial.Investigator_ref_gne__c);
		searchObject.selectedSearchCSA.add(testTrial.Genentech_Primary_Contact_ref_gne__c);
		searchObject.selectedSearchMSL.add(testTrial.MSL_ref_gne__c);

		// start test
		searchObject.search();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();
		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();

		CFAR_Contact_gne__c[] primaryInvestigator = [SELECT Search_Name__c FROM CFAR_Contact_gne__c WHERE Primary_Role_Function_gne__c = 'PI = Primary (or Principal) Investigator' LIMIT 1];

		// assert
		System.Assert(resultList.size() > 0);
		System.AssertEquals(primaryInvestigator[0].Search_Name__c,String.valueOf(resultList[0].innerObject.get('frm_Investigator_ref_gne__c')));
	}

	static testMethod void unitTest_searchByInstitution_searchByInstitution() {
		// prepare for test
		CFAR_Trial_gne__c testTrial = [SELECT Received_Date_gne__c FROM CFAR_Trial_gne__c];
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;

		CFAR_Contact_gne__c testContact = [SELECT Search_Name__c FROM CFAR_Contact_gne__c WHERE Primary_Role_Function_gne__c = 'PI = Primary (or Principal) Investigator' LIMIT 1];
		CFAR_Contact_Address_gne__c testAddress = CFAR_TestUtils.createTestAddress();

		CFAR_Contact_Address_JO_gne__c contactJoinAddress = new CFAR_Contact_Address_JO_gne__c(Contact_Address_ref_gne__c = testAddress.Id, CFAR_Contact_ref_gne__c = testContact.Id);
		insert contactJoinAddress;
		
		CFAR_Team_Member_gne__c trialMember = new CFAR_Team_Member_gne__c(CFAR_Trial_ref_gne__c = testTrial.Id, Active_On_gne__c = testTrial.Received_Date_gne__c,
		contact_address_ref_gne__c = contactJoinAddress.Id);
		insert trialMember;

		CFAR_Institution_gne__c testInstitution = [SELECT Name, Parent_Organization__c FROM CFAR_Institution_gne__c WHERE Id =: testAddress.Institution_gne__c];
		searchObject.institutionPrefix.add(testInstitution.Name);

		CFAR_Parent_Organization_gne__c testParentOrganization = [SELECT Name FROM CFAR_Parent_Organization_gne__c WHERE Id =: testInstitution.Parent_Organization__c];
		searchObject.parentOrganizationPrefix.add(testParentOrganization.Name);

		// start test
		searchObject.search();

		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();

		// assert
		System.Assert(resultList.size() > 0);
		System.AssertEquals(testTrial.Id,resultList[0].innerObject.get('Id'));
	}

	static testMethod void unitTest_otherFunctions() {
		// prepare for test
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;
	
		searchObject.search();
		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		myTrials.stdSetControllerTrial = new ApexPages.StandardSetController(CFAR_DAO.getTrialsLessFields(myTrials.searchParam));
		myTrials.previousTrial();
		myTrials.nextTrial();
		myTrials.firstTrial();
		myTrials.lastTrial();
		myTrials.getIsParentSearchPage();
		myTrials.getListPageName();
		Boolean hasNext = myTrials.hasNextTrial;
		Boolean hasPrevious = myTrials.hasPreviousTrial;
		myTrials.exportToExcelClick();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();
	}

	static testMethod void unitTest_searchByGneAgent() {
		// prepare for test
		CFAR_Trial_gne__c testTrial = [SELECT Product_ref_gne__c FROM CFAR_Trial_gne__c];
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;
		searchObject.selectedSearchProducts.add(String.ValueOf(testTrial.Product_ref_gne__c));

		// start test
		searchObject.search();

		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();

		// assert
		System.AssertEquals(testTrial.Id,resultList[0].innerObject.get('Id'));
	}

	static testMethod void unitTest_searchByOtherGNEAgents() {
		// prepare for test
		CFAR_Trial_gne__c testTrial = [SELECT Product_ref_gne__c FROM CFAR_Trial_gne__c];
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;

		searchObject.selectedSearchOtherGNEAgents.add(String.ValueOf(testTrial.Product_ref_gne__c));
		searchObject.otherGNEAgentsOrAndLogic = 'AND';

		CFAR_Trial_Other_GNE_Agent_gne__c trialOtherAgent = new CFAR_Trial_Other_GNE_Agent_gne__c (CFAR_Trial_ref_gne__c = testTrial.Id, 
			Other_GNE_Agent_ref_gne__c = testTrial.Product_ref_gne__c);
		insert trialOtherAgent;
		
		// start test
		searchObject.search();

		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();
		
		// assert
		System.AssertEquals(testTrial.Id,resultList[0].innerObject.get('Id'));
	}

	static testMethod void unitTest_searchByGeneralIndication() {
		// prepare for test
		CFAR_Trial_gne__c testTrial = [SELECT CFAR_General_Indication_ref_gne__c FROM CFAR_Trial_gne__c];
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;

		searchObject.selectedSearchGI.add(String.ValueOf(testTrial.CFAR_General_Indication_ref_gne__c));
		searchObject.GIOrAndLogic = 'AND';

		CFAR_General_Indication_for_Trial_gne__c trialsGeneralIndication = new CFAR_General_Indication_for_Trial_gne__c(
			CFAR_Trial_ref_gne__c = testTrial.Id,
			CFAR_General_Indication_ref_gne__c = testTrial.CFAR_General_Indication_ref_gne__c);
		insert trialsGeneralIndication;

		// start test
		searchObject.search();

		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();

		// assert
		System.AssertEquals(testTrial.Id,resultList[0].innerObject.get('Id'));
	}	

	static testMethod void unitTest_searchBySpecificIndication() {
		// prepare for test
		CFAR_Trial_gne__c testTrial = [SELECT CFAR_Specific_Indication_ref_gne__c FROM CFAR_Trial_gne__c LIMIT 1];
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;

		searchObject.selectedSearchSI.add(String.ValueOf(testTrial.CFAR_Specific_Indication_ref_gne__c));
		searchObject.SIOrAndLogic = 'AND';

		CFAR_Specific_Indication_for_Trial_gne__c trialsSpecificIndication = new CFAR_Specific_Indication_for_Trial_gne__c(
			CFAR_Trial_ref_gne__c = testTrial.Id,
			CFAR_Specific_Indication_ref_gne__c = testTrial.CFAR_Specific_Indication_ref_gne__c);
		insert trialsSpecificIndication;

		// start test
		searchObject.search();

		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();

		// assert
		System.Assert(resultList.size() > 0);
		System.AssertEquals(testTrial.Id,resultList[0].innerObject.get('Id'));
	}		

	static testMethod void unitTest_searchByPartnership() {
		// prepare for test
		CFAR_Trial_gne__c testTrial = CFAR_DAO.getTrialsLessFields(new CFAR_SearchParameters())[0];
		testTrial.Partnership_multi_gne__c = CFAR_TestUtils.createPartnership('testPartnership',true).Id;
		update testTrial;

		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;
		searchObject.selectedSearchPartnership.add(testTrial.Partnership_multi_gne__c);

		// start test
		searchObject.search();

		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();

		// assert
		System.AssertEquals(testTrial.Id,resultList[0].innerObject.get('Id'));
	}

	static testMethod void unitTest_SearchWrapper_getProductSelectOptions(){
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		SelectOption[] productSelectOptions = searchWrapper.getProductSelectOptions();
		System.Assert(productSelectOptions.size() == 1);
		System.AssertEquals('Accutane',productSelectOptions[0].getLabel());
	}

	static testMethod void unitTest_SearchWrapper_getGeneralIndicationSelectOptions(){
		CFAR_General_Indication_gne__c testGeneralIndication = CFAR_TestUtils.createGeneralIndication('testName');
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		SelectOption[] generalIndicationSelectOptions = searchWrapper.getGeneralIndicationSelectOptions();
		System.AssertEquals('Aerodigestive Tract',generalIndicationSelectOptions[0].getLabel());
		System.AssertEquals('testName',generalIndicationSelectOptions[1].getLabel());

	}

	static testMethod void unitTest_SearchWrapper_getSpecificIndicationSelectOptions(){
		CFAR_Specific_Indication_gne__c testSpecificIndication = CFAR_TestUtils.createSpecificIndication('testName');
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		SelectOption[] specificIndicationSelectOptions = searchWrapper.getSpecificIndicationSelectOptions();
		System.AssertEquals('Aerodigestive Tract',specificIndicationSelectOptions[0].getLabel());
		System.AssertEquals('testName',specificIndicationSelectOptions[1].getLabel());
	}

	static testMethod void unitTest_SearchWrapper_getWBSCodes(){
		CFAR_WBS_gne__c testWBSCode = CFAR_TestUtils.createTestWBS();
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		SelectOption[] wbsCodesSelectOptions = searchWrapper.getWBSCodes();
		System.AssertEquals(testWBSCode.GSR_WBS_gne__c, wbsCodesSelectOptions[0].getLabel());
	}

	static testMethod void unitTest_SearchWrapper_getInterventional(){
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		SelectOption[] interventionalSelectOptions = searchWrapper.getInterventional();
		List<Schema.PicklistEntry> entries =  CFAR_Trial_gne__c.Non_Interventional_gne__c.getDescribe().getPicklistValues();
		System.assert(interventionalSelectOptions.size() == entries.size());
		if (!entries.isEmpty()) {
			System.assert(interventionalSelectOptions.contains(new SelectOption(entries.get(0).value, entries.get(0).label)));
		}
	}

	static testMethod void unitTest_SearchWrapper_getAreaOfSearchToFieldMap(){
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		Map<String,String> areaOfSearchToFieldMap = searchWrapper.getAreaOfSearchToFieldMap();
		System.AssertEquals(7,areaOfSearchToFieldMap.size());
	}

	static testMethod void unitTest_SearchWrapper_getParentOrganizations(){
		CFAR_Parent_Organization_gne__c parentOrganization = CFAR_TestUtils.createTestParentOrganization();
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		SelectOption[] parentOrganizationSelectOptions = searchWrapper.getParentOrganizations();
		System.AssertEquals('Test Organization',parentOrganizationSelectOptions[0].getLabel());
	}

	static testMethod void unitTest_SearchWrapper_getInstitutions(){
		CFAR_Institution_gne__c institution = CFAR_TestUtils.createTestInstitution();
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		SelectOption[] institutionSelectOptions = searchWrapper.getInstitutions();
		System.AssertEquals('Test Institution',institutionSelectOptions[0].getLabel());
	}

	static testMethod void unitTest_SearchWrapper_getTherapeuticAreasSelectOptions(){
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> therapeuticAreasSelectOptions = searchWrapper.getTherapeuticAreasSelectOptions();
		System.Assert(therapeuticAreasSelectOptions.size()>0);
	}

	static testMethod void unitTest_SearchWrapper_getStudyStatusSelectOptions() {
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> studyStatusesSelectOptions = searchWrapper.getStudyStatuses();
		System.Assert(studyStatusesSelectOptions.size() > 0);
	}

	static testMethod void unitTest_SearchWrapper_getInterventionalSelectOptions() {
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> interventionalSelectOptions = searchWrapper.getInterventional();
		System.Assert(interventionalSelectOptions.size() > 0);
	}

	static testMethod void unitTest_SearchWrapper_getPediatricStudySelectOptions() {
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> pediatricStudySelectOptions = searchWrapper.getPediatricStudy();
		System.Assert(pediatricStudySelectOptions.size() > 0);
	}
	static testMethod void unitTest_SearchWrapper_getGNESupportSelectOptions() {
		insert new CFAR_Dollar_and_Drug_gne__c();
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> GNESupportSelectOptions = searchWrapper.getGNESupport();
		System.Assert(GNESupportSelectOptions.size() > 0);
	}

	static testMethod void unitTest_SearchWrapper_getSRTTeamSelectOptions() {
		insert new CFAR_Picklist_Value_gne__c(RecordTypeId = Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('SRT Team').getRecordTypeId());
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> SRTTeamSelectOptions = searchWrapper.getSRTTeam();
		System.Assert(SRTTeamSelectOptions.size() > 0);
	}

	static testMethod void unitTest_SearchWrapper_getSubjectTypeSelectOptions() {
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> subjectTypeSelectOptions = searchWrapper.getSubjectType();
		System.Assert(subjectTypeSelectOptions.size() > 0);
	}

	static testMethod void unitTest_SearchWrapper_getBOMSupportSelectOptions() {
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> BOMSupportSelectOptions = searchWrapper.getBOMSupport();
		System.Assert(BOMSupportSelectOptions.size() > 0);
	}

	static testMethod void unitTest_SearchWrapper_getImpactSelectOptions() {
		insert new CFAR_Picklist_Value_gne__c(RecordTypeId = Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('Impact').getRecordTypeId());
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> impactSelectOptions = searchWrapper.getImpactSelectOptionsSearch();
		System.Assert(impactSelectOptions.size() > 0);
	}

	static testMethod void unitTest_SearchWrapper_getPartnershipSelectOptions() {
		CFAR_TestUtils.createPartnership('testPartnership', true);
		CFAR_SearchWrapper searchWrapper = new CFAR_SearchWrapper();
		List<SelectOption> partnershipSelectOptions = searchWrapper.getPartnershipSelectOptions();
		System.Assert(partnershipSelectOptions.size() > 0);
	}

	static testMethod void unitTest_clear(){
		CFAR_Search_Controller searchObject = new CFAR_Search_Controller();
		searchObject.basicSearch = false;
		searchObject.clear();

		System.AssertEquals(0, searchObject.selectedSearchContacts.size());
		System.AssertEquals(0, searchObject.selectedSearchCSA.size());
		System.AssertEquals(0, searchObject.selectedSearchInvestigator.size());
		System.AssertEquals(0, searchObject.parentOrganizationPrefix.size());
		System.AssertEquals(0, searchObject.institutionPrefix.size());
		System.AssertEquals(0, searchObject.selectedSearchMSL.size());
		System.AssertEquals(0, searchObject.selectedSearchProducts.size());
		System.AssertEquals(0, searchObject.selectedSearchTherapeuticArea.size());
		System.AssertEquals(0, searchObject.selectedSearchOtherGNEAgents.size());
		System.AssertEquals(0, searchObject.selectedSearchGI.size());
		System.AssertEquals(0, searchObject.selectedSearchSI.size());
		System.AssertEquals(0, searchObject.selectedWBSCode.size());
		System.AssertEquals(0, searchObject.selectedInterventional.size());
		System.AssertEquals(0, searchObject.selectedStudyStatus.size());
		System.AssertEquals('', searchObject.selectedPediatricStudy);
		System.AssertEquals(0, searchObject.selectedGNESupport.size());
		System.AssertEquals(0, searchObject.selectedSRTTeam.size());
		System.AssertEquals(0, searchObject.selectedSubjectType.size());
		System.AssertEquals(0, searchObject.selectedWBSCode.size());
		System.AssertEquals(0, searchObject.selectedImpact.size());
 		
	}

	static testMethod void unitTest_SearchByTrialPrefix() {
		// prepare for test
		CFAR_Search_Controller searchCtrl = new CFAR_Search_Controller();
		searchCtrl.basicSearch = false;
		CFAR_Contact_gne__c[] contacts = [SELECT Id, Last_Name_gne__c FROM CFAR_Contact_gne__c];
		//searchCtrl.selectedSearchContacts.add(contacts[0].Last_Name_gne__c);
		
		// searchCtrl.switchSearchType();
		ApexPages.currentPage().getParameters().put('aosParam','Trial');
		searchCtrl.searchWrapper.areaOfSearch = 'Trial';
		searchCtrl.searchWrapper.searchString = 'ACC';
		searchCtrl.searchWrapper.trialPrefix = 'ACC';

		// run test
		searchCtrl.search();

		CFAR_MyTrialsController myTrials = new CFAR_MyTrialsController();
		List<CFAR_SObjectWrapper> resultList = myTrials.getobjectListTrial();
		CFAR_MyTrialsXLSController myTrialsXLS = new CFAR_MyTrialsXLSController();
		List<CFAR_SObjectWrapper> resultListXLS = myTrialsXLS.getobjectListTrial();
        myTrialsXLS.getWorkbookProperties();
        myTrialsXLS.getFileName();

		CFAR_Contact_gne__c[] primaryInvestigator = [SELECT Search_Name__c FROM CFAR_Contact_gne__c WHERE Primary_Role_Function_gne__c = 'PI = Primary (or Principal) Investigator' LIMIT 1];

		// assert
		System.Assert(resultList.size() > 0);
		System.AssertEquals(String.valueOf(resultList[0].innerObject.get('frm_Investigator_ref_gne__c')), primaryInvestigator[0].Search_Name__c);
	}
	
	static CFAR_Team_Member_gne__c helperMethod_CreateTeamMember(String role, CFAR_Trial_gne__c testTrial, CFAR_Contact_Address_gne__c testAddress){
		CFAR_Contact_gne__c testContact = [SELECT Search_Name__c FROM CFAR_Contact_gne__c WHERE Primary_Role_Function_gne__c = : role LIMIT 1];
		CFAR_Contact_Address_JO_gne__c contactJoinAddress = new CFAR_Contact_Address_JO_gne__c(Contact_Address_ref_gne__c = testAddress.Id, CFAR_Contact_ref_gne__c = testContact.Id);
		insert contactJoinAddress;
		
		CFAR_Team_Member_gne__c trialMember = new CFAR_Team_Member_gne__c(CFAR_Trial_ref_gne__c = testTrial.Id, Active_On_gne__c = testTrial.Received_Date_gne__c,
		contact_address_ref_gne__c = contactJoinAddress.Id);
		insert trialMember;	
		return trialMember;	
	}
}