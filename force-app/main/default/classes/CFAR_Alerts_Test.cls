@isTest(seeAllData=false)
private class CFAR_Alerts_Test {

	@testSetup
	static void setup() {
		User testAvgUser = CFAR_TestUtils.createTestAverageUser();
		User testMSLuser = CFAR_TestUtils.createTestMSLUser();
		User readOnlyUser = CFAR_TestUtils.createTestReadOnlyUser();

		System.RunAs(testAvgUser) {
			CFAR_Contact_Address_gne__c address = CFAR_TestUtils.createTestAddress();
			List<sObject> testRecords = new List<sObject>();
			Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
			Map<String, object> fieldsConfig = new Map<String, object>();
			fieldsConfig.put('First_Name_gne__c', 'Program');
			fieldsConfig.put('Last_Name_gne__c', 'Manager');
			fieldsConfig.put('Primary_Role_Function_gne__c', 'CPL = Clinical Program Leader');
			fieldsConfig.put('Active_Date_gne__c', System.today());
			fieldsConfig.put('User_ref_gne__c', testAvgUser.Id);
			objectConfig.put(new CFAR_Contact_gne__c(), fieldsConfig);
			sObject cfarPrimaryInvestigator = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarPrimaryInvestigator);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('First_Name_gne__c', 'Primary');
			fieldsConfig.put('Last_Name_gne__c', 'Investigator');
			fieldsConfig.put('Primary_Role_Function_gne__c', 'PI = Primary (or Principal) Investigator');
			fieldsConfig.put('Active_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Contact_gne__c(), fieldsConfig);
			sObject cfarInvestigator = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarInvestigator);
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('First_Name_gne__c', 'Medical');
			fieldsConfig.put('Last_Name_gne__c', 'Liaison');
			fieldsConfig.put('Primary_Role_Function_gne__c', 'MSL = Medical Science Liaison');
			fieldsConfig.put('Active_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Contact_gne__c(), fieldsConfig);
			sObject cfarMSL = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarMSL);
			insert testRecords;

			CFAR_Contact_Address_JO_gne__c joinAddress = new CFAR_Contact_Address_JO_gne__c();
			joinAddress.Name = 'test';
			joinAddress.CFAR_Contact_ref_gne__c = cfarPrimaryInvestigator.Id;
			joinAddress.Contact_Address_ref_gne__c = address.Id;
			insert joinAddress;

			testRecords = new List<sObject>();
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			//Trial Type
			fieldsConfig.put('Name', 'Trial Type');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Trial_Type_gne__c(), fieldsConfig);
			sObject cfarTrialType = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTrialType);
			//Therapeutic Area
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Ther Area');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Therapeutic_Area_gne__c(), fieldsConfig);
			sObject cfarTherapeuticArea = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTherapeuticArea);
			//General Indication
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'General Indication');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_General_Indication_gne__c(), fieldsConfig);
			sObject cfarGeneralIndication = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarGeneralIndication);
			//Specific Indication
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Spec Indication');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Specific_Indication_gne__c(), fieldsConfig);
			sObject cfarSpecificIndication = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarSpecificIndication);
			//Theme
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'TH');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Theme_gne__c(), fieldsConfig);
			sObject cfarTheme = CFAR_TestUtils.createRecord(objectConfig);
			testRecords.add(cfarTheme);
			insert testRecords;
			//Product
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Test Product');
			fieldsConfig.put('Description_gne__c', 'ABCD');
			fieldsConfig.put('Generic_Name_gne__c', 'GenName');
			fieldsConfig.put('Other_GNE_Agent_Active_gne__c', true);
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('Theme_ref_gne__c', cfarTheme.get('Id'));
			objectConfig.put(new CFAR_Product_gne__c(), fieldsConfig);
			sObject cfarProduct = CFAR_TestUtils.createRecord(objectConfig);
			insert cfarProduct;
			//create Trial 1
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Product_ref_gne__c', cfarProduct.get('Id'));
			fieldsConfig.put('Trial_Type_ref_gne__c', cfarTrialType.get('Id'));
			fieldsConfig.put('Genentech_Primary_Contact_ref_gne__c', cfarPrimaryInvestigator.get('Id'));
			fieldsConfig.put('Therapeutic_Area_ref_gne__c', cfarTherapeuticArea.get('Id'));
			fieldsConfig.put('Study_Phase_gne__c', 'Phase I');
			fieldsConfig.put('Subject_Type__c', 'Animal');
			fieldsConfig.put('CFAR_General_Indication_ref_gne__c', cfarGeneralIndication.get('Id'));
			fieldsConfig.put('CFAR_Specific_Indication_ref_gne__c', cfarSpecificIndication.get('Id'));
			fieldsConfig.put('Planned_Enrollment_gne__c', 1);
			fieldsConfig.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
			fieldsConfig.put('Investigator_ref_gne__c', cfarInvestigator.get('Id'));
			fieldsConfig.put('MSL_ref_gne__c', cfarMSL.get('Id'));
			fieldsConfig.put('Received_Date_gne__c', System.today());
			objectConfig.put(new CFAR_Trial_gne__c(), fieldsConfig);
			sObject cfarTrial = CFAR_TestUtils.createRecord(objectConfig);
			insert cfarTrial;
		}
		System.assert(true);
	}

	@isTest
	static void testNewTrialButton(){
		User testAvgUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
		CFAR_Home_Controller hController = new CFAR_Home_Controller();
		System.RunAs(testAvgUser){
			System.assertEquals(true, hController.getRenderNewButton());
			System.assertEquals(true, String.valueOf(hController.createTrial()).containsIgnoreCase('CFAR_newTrial'));
		}
	}

	@isTest
	static void testNewTrialButtonReadOnlyUser(){
		User readOnlyUser = [SELECT Id FROM User WHERE alias = 'testRO' LIMIT 1];
		System.RunAs(readOnlyUser){
		CFAR_Home_Controller hController = new CFAR_Home_Controller();
			System.assertEquals(false, hController.getRenderNewButton());
		}
	}

	@isTest static void testMilestoneActivityAlerts() {
		User testAvgUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
		system.runAs(testAvgUser) {
			CFAR_Trial_gne__c cfarTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			//create Milestone Activity
			Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
			Map<String, object> fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'Test Milestone Activity');
			fieldsConfig.put('Actual_Date_gne__c', null);
			fieldsConfig.put('Baselined_Date_gne__c', System.today());
			fieldsConfig.put('CFAR_Trial_ref_gne__c', cfarTrial.get('Id'));
			fieldsConfig.put('Comments_gne__c', 'ABCD');
			fieldsConfig.put('Planned_Date_gne__c', System.today());
			fieldsConfig.put('sfdc_Type_gne__c', 'Activation');
			objectConfig.put(new CFAR_Milestone_Activity_gne__c(), fieldsConfig);
			sObject cfarMilestoneActivity = CFAR_TestUtils.createRecord(objectConfig);
			insert cfarMilestoneActivity;

			//create Milestone Activity
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'TRAC Protocol Approval');
			fieldsConfig.put('Actual_Date_gne__c', null);
			fieldsConfig.put('Baselined_Date_gne__c', System.today());
			fieldsConfig.put('CFAR_Trial_ref_gne__c', cfarTrial.id);
			fieldsConfig.put('Comments_gne__c', 'ABCD');
			fieldsConfig.put('Planned_Date_gne__c', System.today());
			fieldsConfig.put('sfdc_Type_gne__c', 'Activation');
			objectConfig.put(new CFAR_Milestone_Activity_gne__c(), fieldsConfig);
			sObject tracMilestoneActivity = CFAR_TestUtils.createRecord(objectConfig);
			insert tracMilestoneActivity;

			CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate teamMemberStr = new CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate([SELECT ID FROM CFAR_Trial_gne__c].get(0));
			teamMemberStr.createTeamMemberWithRandomStructure();

			CFAR_Team_Member_gne__c tm = [SELECT ID, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, alerts_gne__c FROM CFAR_Team_Member_gne__c Limit 1];
			tm.Contact_address_ref_gne__c = [SELECT ID FROM CFAR_Contact_Address_JO_gne__c WHERE Name = 'test'].id;
			tm.Alerts_gne__c = true;
			update tm;

			Date oneBusinessWeekcompareDate = System.today().addDays(7);

			//start test
			test.startTest();
			CFAR_Home_Controller hController = new CFAR_Home_Controller();
			hController.sortExpression = 'Investigator';
			hController.sortDirection = 'desc';
			String trialId = String.valueOf(cfarTrial.get('Id'));
			CFAR_Trial_gne__c trial = [Select frm_Investigator_ref_gne__c, Name from CFAR_Trial_gne__c where Id = : trialId];
			List<CFAR_Home_Controller.AlertWrapper> wrappers = hController.createAlertWrappers();
			system.assertEquals(1, wrappers.size(), 'Wrapper should contain 1 alert, since alert for TRAC Protocol Approval MA should be omitted.');
			system.assertEquals('You have approaching Test Milestone Activity Milestone today', wrappers[0].alert);
			system.assertEquals(wrappers[0].investigator, trial.frm_Investigator_ref_gne__c);
			system.assertEquals(wrappers[0].trialId, trialId);
			system.assertEquals(wrappers[0].trialNumber, trial.Name);
			test.stopTest();
		}
	}
	
	@isTest static void testRegDocTrackingAlert() {
		User testAvgUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
		system.runAs(testAvgUser) {
			Map<sObject, Map<String, object>> objectConfig = new Map<sObject, Map<String, object>>();
			Map<String,object> fieldsConfig = new Map<String, object>();
			CFAR_Trial_gne__c cfarTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			//create Regulatory Tracking Activity
			fieldsConfig.put('Name', 'IB Signature Page');
			fieldsConfig.put('Active_gne__c', true);
			objectConfig.put(new CFAR_Tracking_Activity_gne__c(), fieldsConfig);
			sObject cfarRegTrackActivity = CFAR_TestUtils.createRecord(objectConfig);
			insert cfarRegTrackActivity;
			//create Regulatory Document Tracking
			objectConfig = new Map<sObject, Map<String, object>>();
			fieldsConfig = new Map<String, object>();
			fieldsConfig.put('Name', 'RegDocTrack');
			fieldsConfig.put('Active_gne__c', true);
			fieldsConfig.put('CFAR_Trial_gne__c', cfarTrial.get('Id'));
			fieldsConfig.put('Expiry_Date_gne__c',System.today());
			fieldsConfig.put('Regulatory_Tracking_Activity_gne__c',cfarRegTrackActivity.get('Id'));
			//fieldsConfig.put('Activity_gne__c', 'Cross Reference Letter');
			fieldsConfig.put('Activity_gne__c', 'IB Signature Page');
			objectConfig.put(new CFAR_Regulatory_Document_Tracking_gne__c(), fieldsConfig);
			sObject cfarRegDocTrack = CFAR_TestUtils.createRecord(objectConfig);
			insert cfarRegDocTrack;

			CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate teamMemberStr = new CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate([SELECT ID FROM CFAR_Trial_gne__c].get(0));
			teamMemberStr.createTeamMemberWithRandomStructure();

			CFAR_Team_Member_gne__c tm = [SELECT ID, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, alerts_gne__c FROM CFAR_Team_Member_gne__c Limit 1];
			tm.Contact_address_ref_gne__c = [SELECT ID FROM CFAR_Contact_Address_JO_gne__c WHERE Name = 'test'].id;
			tm.Alerts_gne__c = true;
			update tm;

			//start test
			test.startTest();
				CFAR_Home_Controller hController = new CFAR_Home_Controller();
				hController.sortExpression = 'Investigator';
				hController.sortDirection = 'asc';
				String trialId = String.valueOf(cfarTrial.get('Id'));
				CFAR_Trial_gne__c trial = [Select frm_Investigator_ref_gne__c, Name from CFAR_Trial_gne__c where Id =: trialId];
				List<CFAR_Home_Controller.AlertWrapper> wrappers = hController.createAlertWrappers();
				System.assertNotEquals(null, wrappers);
				System.assertEquals(1,wrappers.size());
				system.assertEquals(wrappers[0].alert, 'You have a Reg Doc IB Signature Page expiring today');
				system.assertEquals(wrappers[0].investigator, trial.frm_Investigator_ref_gne__c);
				system.assertEquals(wrappers[0].trialId, trialId);
				system.assertEquals(wrappers[0].trialNumber, trial.Name);
			test.stopTest();
		}
	}

	@isTest static void testContractEndDateAlert() {
		User testAvgUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
		system.runAs(testAvgUser) {
			CFAR_Trial_gne__c cfarTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate teamMemberStr = new CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate([SELECT ID FROM CFAR_Trial_gne__c].get(0));
			teamMemberStr.createTeamMemberWithRandomStructure();

			CFAR_Team_Member_gne__c tm = [SELECT ID, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, alerts_gne__c FROM CFAR_Team_Member_gne__c Limit 1];
			tm.Contact_address_ref_gne__c = [SELECT ID FROM CFAR_Contact_Address_JO_gne__c WHERE Name = 'test'].id;
			tm.Alerts_gne__c = true;
			update tm;

			CFAR_Budget_Contract_Type_gne__c bct = new CFAR_Budget_Contract_Type_gne__c();
			bct.Name = 'test';
			bct.Active_gne__c = true;
			insert bct;
			System.assertEquals(1, [SELECT ID FROM CFAR_Budget_Contract_Type_gne__c].size());

			CFAR_Budget_Contract_gne__c bc = new CFAR_Budget_Contract_gne__C();
			bc.Team_Member_ref_gne__c = tm.id;
			bc.Next_Payment_Due_gne__c = System.Today().addDays(15);
			insert bc;
			System.assertEquals(1, [SELECT ID FROM CFAR_Budget_Contract_gne__c].size());

			CFAR_Budget_Contract_Tracking_gne__c bctr = new CFAR_Budget_Contract_Tracking_gne__c();
			bctr.Amount_gne__c = 3000;
			bctr.Budget_Contract_ref_gne__c = bc.id;
			bctr.Type_ref_gne__c = bct.id;
			bctr.Contract_ID_gne__c = '1234';
			bctr.Fully_Executed_Date_gne__c = System.today();
			bctr.Contract_Expiry_Date_gne__c = System.Today().addYears(3);
			insert bctr;
			System.assertEquals(1, [SELECT ID FROM CFAR_Budget_Contract_Tracking_gne__c].size());
			
			//start test
			test.startTest();
				CFAR_Home_Controller hController = new CFAR_Home_Controller();
				hController.sortExpression = 'TrialNumber';
				hController.sortDirection = 'desc';
				String trialId = String.valueOf(cfarTrial.get('Id'));
				CFAR_Trial_gne__c trial = [Select frm_Investigator_ref_gne__c, frm_Genentech_Primary_Contact_ref_gne__c, Name from CFAR_Trial_gne__c where Id =: trialId];
				List<CFAR_Home_Controller.AlertWrapper> wrappers = hController.createAlertWrappers();
				System.assertNotEquals(0, wrappers.size());
				system.assertEquals(wrappers[0].alert, 'You have a payment due in 15 days');
				system.assertEquals(wrappers[0].investigator, trial.frm_Genentech_Primary_Contact_ref_gne__c);
			test.stopTest();
		}
	}

	@isTest static void testContactAlerts() {
		User testAvgUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
		system.runAs(testAvgUser) {
			CFAR_Contact_gne__c cfarInvestigator =  [SELECT Id FROM CFAR_Contact_gne__c WHERE First_Name_gne__c = 'Primary'];
			cfarInvestigator.InActive_Date_gne__c = System.Today();
			cfarInvestigator.Active_Date_gne__c = System.today()-1;
			update cfarInvestigator;

			CFAR_Trial_gne__c cfarTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			test.startTest();
				CFAR_Home_Controller hController = new CFAR_Home_Controller();
				hController.sortExpression = 'TrialNumber';
				hController.sortDirection = 'desc';
				String trialId = String.valueOf(cfarTrial.get('Id'));
				CFAR_Trial_gne__c trial = [Select frm_Investigator_ref_gne__c, Name from CFAR_Trial_gne__c where Id =: trialId];
				List<CFAR_Home_Controller.AlertWrapper> wrappers = hController.createAlertWrappers();

				system.assertEquals('Investigator, Primary is no longer active in our data base please update team information accordingly', wrappers[0].alert);
				system.assertEquals(trial.frm_Investigator_ref_gne__c, wrappers[0].investigator);
				system.assertEquals(trial.Id, wrappers[0].trialId);
				system.assertEquals(trial.Name, wrappers[0].trialNumber);
			test.stopTest();
		}
	}
	
	@isTest static void testTeamInfoAlerts() {
		User testAvgUser = [SELECT Id FROM User WHERE alias = 'testAvg' LIMIT 1];
		User itAdm = CFAR_TestUtils.createTestITAdminUser();
		System.runAs(itAdm) {
			CFAR_TestUtils.createRolesToUsersMapping();
		}
		system.runAs(testAvgUser) {
			CFAR_Trial_gne__c cfarTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate teamMemberStr = new CFAR_DataFactory.TeamMemberWithOrgInstAddrAggregate([SELECT ID FROM CFAR_Trial_gne__c].get(0));
			teamMemberStr.createTeamMemberWithRandomStructure();

			CFAR_Team_Member_gne__c teamMember = [SELECT ID, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c, alerts_gne__c FROM CFAR_Team_Member_gne__c Limit 1];
			teamMember.Contact_address_ref_gne__c = [SELECT ID FROM CFAR_Contact_Address_JO_gne__c WHERE Name = 'test'].id;
			teamMember.Alerts_gne__c = true;
			update teamMember;

			List<CFAR_Team_Member_gne__c> teamMembers = [Select Id, frm_Is_Inactive_gne__c, Inactive_On_gne__c, Is_Trial_Primary_Contact_gne__c, Is_Trial_MSL_gne__c
														 from CFAR_Team_Member_gne__c where CFAR_Trial_ref_gne__c =: String.valueOf(cfarTrial.get('Id')) and frm_Name_gne__c != 'Manager, Program'];
			for(CFAR_Team_Member_gne__c tm : teamMembers)
			{
				tm.Inactive_On_gne__c = Date.today();
			}
			update teamMembers;

			test.startTest();
				CFAR_Home_Controller hController = new CFAR_Home_Controller();
				hController.sortExpression = 'TrialNumber';
				hController.sortDirection = 'desc';
				String trialId = String.valueOf(cfarTrial.get('Id'));
				CFAR_Trial_gne__c trial = [Select frm_Investigator_ref_gne__c, Name from CFAR_Trial_gne__c where Id =: trialId];
				teamMembers = [Select Id, frm_Is_Inactive_gne__c, Inactive_On_gne__c, Is_Trial_Primary_Contact_gne__c, Is_Trial_MSL_gne__c
							 from CFAR_Team_Member_gne__c where CFAR_Trial_ref_gne__c =: String.valueOf(cfarTrial.get('Id')) and frm_Name_gne__c != 'Manager, Program'];
														 
			for(CFAR_Team_Member_gne__c tm : teamMembers)
			{
				System.assertNotEquals(null, tm.Inactive_On_gne__c);
				System.assertEquals(true, tm.frm_Is_Inactive_gne__c);
			}
				List<CFAR_Home_Controller.AlertWrapper> wrappers = hController.createAlertWrappers();
				System.assertNotEquals(null, wrappers);
				System.assertEquals(1,wrappers.size());
				system.assertEquals(wrappers[0].alert, 'LastName, FirstName is no longer active in  team information');
				system.assertEquals(wrappers[0].investigator, trial.frm_Investigator_ref_gne__c);
				system.assertEquals(wrappers[0].trialId, trial.Id);
				system.assertEquals(wrappers[0].trialNumber, trial.Name);
			test.stopTest();
		}
	}

	@isTest static void validateSortingAndPagination() {
		//GIVEN
		CFAR_Home_Controller hController = new CFAR_Home_Controller();
		hController.alerts = new List<CFAR_Home_Controller.AlertWrapper>();

		for (Integer i = 0; i <= 40; i++) {
			CFAR_Home_Controller.AlertWrapper alert = new CFAR_Home_Controller.AlertWrapper(
				'test alert message ' + i,
				'testInv' + i,
				'1234' + i,
				'aClS000000002wkKAA');
			hController.alerts.add(alert);
		}
		//WHEN
		hController.initializePagination();
		hController.sortAlerts();

		//THEN
		System.assertEquals(true, hController.hasNextAlert);
		System.assertEquals(false, hController.hasPreviousAlert);

		hController.nextAlert();
		System.assertEquals(true, hController.hasPreviousAlert);
		System.assertEquals(true, hController.hasNextAlert);

		hController.lastAlert();
		System.assertEquals(true, hController.hasPreviousAlert);
		System.assertEquals(false, hController.hasNextAlert);

		hController.previousAlert();
		System.assertEquals(true, hController.hasPreviousAlert);
		System.assertEquals(true, hController.hasNextAlert);

		hController.firstAlert();
		System.assertEquals(false, hController.hasPreviousAlert);
		System.assertEquals(true, hController.hasNextAlert);
	}
}