@isTest
private class CFAR_TrialReassign_Controller_Test {
	@testSetup
	static void setup() {
		CFAR_TestUtils.createRolesToUsersMapping();

		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger','CFAR_Trial_gne__c', 'CFAR_ContactTrigger'});

		CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
		CFAR_Trial_gne__c trial2 = CFAR_TestUtils.createTestTrial2();
		CFAR_Trial_gne__c trial3 = CFAR_TestUtils.createTestTrial3('RO-IIS-2017-22222');

		CFAR_Contact_gne__c contact = CFAR_DataFactory.createContact('contact1', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		contact.Last_Name_gne__c = 'contact1';
		contact.User_ref_gne__c = userInfo.getUserId();
		contact.Active_Date_gne__c = System.Today();
		contact.Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_CLINICAL_PROGRAM_LEADER;
		contact.Tertiary_Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR;

		CFAR_Contact_gne__c contact2 = CFAR_DataFactory.createContact('contact2', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		contact2.Last_Name_gne__c = 'contact2';
		contact2.Active_Date_gne__c = System.Today();
		contact2.User_ref_gne__c = [SELECT Id FROM User WHERE Id != :userInfo.getUserId() LIMIT 1].Id;
		contact2.Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_CLINICAL_PROGRAM_LEADER;

		CFAR_Contact_gne__c contact3 = CFAR_DataFactory.createContact('contact3', CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		contact3.Last_Name_gne__c = 'contact3';
		contact3.Active_Date_gne__c = System.Today();

		insert new List<CFAR_Contact_gne__c>{contact, contact2, contact3};

		CFAR_Parent_Organization_gne__c parentOrg = CFAR_DataFactory.createParentOrganization();
		insert parentOrg;
		CFAR_Institution_gne__c institution = CFAR_DataFactory.createInstitution(parentOrg, 'testName123xx');
		insert institution;
		CFAR_Contact_Address_gne__c contactAddress  = CFAR_DataFactory.createContactAddress(institution);
		insert contactAddress;

		CFAR_Contact_Address_JO_gne__c caJO = CFAR_DataFactory.createContactAddressJO(contact, contactAddress);
		CFAR_Contact_Address_JO_gne__c caJO2 = CFAR_DataFactory.createContactAddressJO(contact2, contactAddress);
		CFAR_Contact_Address_JO_gne__c caJO3 = CFAR_DataFactory.createContactAddressJO(contact3, contactAddress);
		insert new List<CFAR_Contact_Address_JO_gne__c>{caJO, caJO2, caJO3};

		CFAR_Team_Member_gne__c tm = CFAR_DataFactory.createTeamMember(trial, 'teamMember1', caJO, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		tm.Is_Trial_Primary_Contact_gne__c = true;
		tm.Active_On_gne__c = System.Today();
		CFAR_Team_Member_gne__c tm2 = CFAR_DataFactory.createTeamMember(trial2, 'teamMember1', caJO, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		tm2.Is_Trial_Primary_Contact_gne__c = true;
		tm2.Active_On_gne__c = System.Today();
		CFAR_Team_Member_gne__c tm3 = CFAR_DataFactory.createTeamMember(trial3, 'teamMember1', caJO, CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);
		tm3.Is_Trial_Primary_Contact_gne__c = true;
		tm3.Active_On_gne__c = System.Today();

		insert new List<CFAR_Team_Member_gne__c>{tm,tm2,tm3};

		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{});
	}


	static testMethod void initContactOptions_shouldReturnErrorIfNoTrialsSelected() {
		//GIVEN
		CFAR_Contact_gne__c gStarsContact = [SELECT Id FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact1'];
		ApexPages.currentPage().getParameters().put('id', gStarsContact.Id);
		CFAR_TrialReassign_Controller ctrl = new CFAR_TrialReassign_Controller();

		//WHEN
		ctrl.selectedRole = CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER;
		ctrl.initContactOptions();

		//THEN
		System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_SELECT_TRIALS_TO_REASSIGN), ApexPages.getMessages().get(0),
			'Should return error message if user tries to reassign Trials, but no Trials were selected');
	}

	static testMethod void populateTrialTable_shouldDetectIfRoleIsExternal() {
		//GIVEN
		CFAR_Contact_gne__c gStarsContact = [SELECT Id FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact1'];
		ApexPages.currentPage().getParameters().put('id', gStarsContact.Id);
		CFAR_TrialReassign_Controller ctrl = new CFAR_TrialReassign_Controller();

		//WHEN
		ctrl.selectedRole = CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR;
		ctrl.populateTrialTable();

		//THEN
		System.assertEquals(true, ctrl.isExternalRole, 
			'Should detect if a Contact Role selected by user is External');
		System.assertEquals(0, ctrl.teamMembers.size(), 
			'Should return 0 records, since Team Member of selected user of selected role is not assigned to any Trial');
	}

	static testMethod void populateTrialTable_ShouldNotPopulateWithNotActiveTrials() {
		//GIVEN
		CFAR_Contact_gne__c gStarsContact = [SELECT Id FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact1'];
		ApexPages.currentPage().getParameters().put('id', gStarsContact.Id);
		CFAR_TrialReassign_Controller ctrl = new CFAR_TrialReassign_Controller();

		ctrl.selectedRole = CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER;
		ctrl.populateTrialTable();
		System.assertEquals(3, ctrl.teamMembers.size(), 'If Trials assigned to Team Member are active, should return trials.');

		//WHEN
		CFAR_Trial_Status_gne__c statusCancelled = new CFAR_Trial_Status_gne__c(Name = Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED);
		CFAR_Trial_Status_gne__c statusTerminated = new CFAR_Trial_Status_gne__c(Name = Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION);
		CFAR_Trial_Status_gne__c statusConcluded = new CFAR_Trial_Status_gne__c(Name = Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED);

		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger','CFAR_Trial_gne__c', 'CFAR_ContactTrigger'});
		CFAR_ConfigUtil.setDisabled('Disabled_Validation_Rules_gne__c', new List<String>{'CFAR_Trial_gne__c.Trial_Status_Changed_Latest_Comment'});

		insert new List<CFAR_Trial_Status_gne__c>{statusConcluded, statusCancelled, statusTerminated};

		CFAR_Trial_gne__c[] existingTrials = [SELECT Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c];
		existingTrials[0].Trial_Status_ref_gne__c = statusCancelled.Id;
		existingTrials[1].Trial_Status_ref_gne__c = statusTerminated.Id;
		existingTrials[2].Trial_Status_ref_gne__c = statusConcluded.Id;

		update existingTrials;
		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{});
		CFAR_ConfigUtil.setDisabled('Disabled_Validation_Rules_gne__c', new List<String>());

		//THEN
		ctrl.populateTrialTable();
		System.assertEquals(0, ctrl.teamMembers.size(), 
			'If Trials assigned to Team Member are inactive, should not return these trials.');
	}

	static testMethod void reassignSelectedTrials_ShouldReassignSelectedTrials() {
		//GIVEN
		CFAR_Contact_gne__c gStarsContact = [SELECT Id FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact1'];
		CFAR_Contact_gne__c gStarsContact2 = [SELECT Last_Name_gne__c FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact2'];

		ApexPages.currentPage().getParameters().put('id', gStarsContact.Id);
		CFAR_TrialReassign_Controller ctrl = new CFAR_TrialReassign_Controller();
		System.assertEquals(CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER, ctrl.selectedRole,
			'On Load, Contacts Primary role should be selected by default');

		System.assertEquals(3, ctrl.currentContactRoles.size(),
			'Since Contact to reassign Trials from has populated primary, secondary, and tertiary roles, currentContactRoles should contain 3 options.');

		//WHEN - select trials to reassign
		for (CFAR_Team_Member_gne__c tm : ctrl.teamMembers) {
			tm.Alerts_gne__c = true;
		}

		//THEN - display Contacts to reassign Trials to
		ctrl.initContactOptions();
		System.assertEquals(2, ctrl.getContactSearchList1().size(),
			'Should return other Contacts with primary, secondary, or tertiary role, as currently selected role: '
			+ CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);

		//WHEN - reassign trials to selected Contact
		ctrl.contactToReassignId = gStarsContact2.Id;
		ctrl.reassignSelectedTrials();

		//THEN - assert trials
		CFAR_Trial_gne__c[] existingTrials = [SELECT Genentech_Primary_Contact_ref_gne__r.Last_Name_gne__c FROM CFAR_Trial_gne__c];
		System.assertEquals(3, existingTrials.size(),
			'There should be 3 existing trials');

		Set<Id> existingTrialIds = new Set<Id>();
		for(CFAR_Trial_gne__c trial : existingTrials){
			System.assertEquals(gStarsContact2.Last_Name_gne__c, trial.Genentech_Primary_Contact_ref_gne__r.Last_Name_gne__c,
				'If Contact that Trials were reassigned from, was these trials primary contact, Contact these trials were reassigned to should be now their primary Contact.');
			existingTrialIds.add(trial.Id);
		}

		//THEN - assert reassigned from team members
		CFAR_Team_Member_gne__c[] reassignedFromTeamMembers = [SELECT Is_Trial_Primary_Contact_gne__c, Inactive_On_gne__c, CFAR_Trial_ref_gne__c
			FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c IN :existingTrialIds
			AND contact_address_ref_gne__r.CFAR_Contact_ref_gne__c =: gStarsContact.Id];

		System.assertEquals(3, reassignedFromTeamMembers.size(), 'There should be 3 team memers of reassigned from Contact on existing trials.');
		for(CFAR_Team_Member_gne__c reassignedFromTeamMember : reassignedFromTeamMembers) {
			System.assertEquals(false, reassignedFromTeamMember.Is_Trial_Primary_Contact_gne__c,
				'Reassigned From team members, previously being Trial Primary Contact, now should have this field set to false');
			System.assertEquals(System.Today(), reassignedFromTeamMember.Inactive_On_gne__c,
				'Reassigned From team members, previously active, should now be inactive.');
		}

		//THEN - assert reassigned to team members
		CFAR_Team_Member_gne__c[] reassignedToTeamMembers = [SELECT Is_Trial_Primary_Contact_gne__c, Inactive_On_gne__c, Active_On_gne__c, Alerts_gne__c, CFAR_Trial_ref_gne__c
			FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c IN :existingTrialIds
			AND contact_address_ref_gne__r.CFAR_Contact_ref_gne__c =: gStarsContact2.Id];

		System.assertEquals(3, reassignedToTeamMembers.size(), 'There should be 3 team memers of reassigned To Contact on existing trials.');
		for(CFAR_Team_Member_gne__c reassignedToTeamMember : reassignedToTeamMembers) {
			System.assertEquals(true, reassignedToTeamMember.Is_Trial_Primary_Contact_gne__c,
				'Reassigned To team members, should inherit Is_Trial_Primary_Contact_gne__c value set to true from Reassigned From Team members.');
			System.assertEquals(null, reassignedToTeamMember.Inactive_On_gne__c,
				'Reassigned To team members should have Inactive_On_gne__c value empty.');
			System.assertEquals(System.Today(), reassignedToTeamMember.Active_On_gne__c,
				'Reassigned To team members should have Active_On_gne__c value set to Today.');
			System.assertEquals(true, reassignedToTeamMember.Alerts_gne__c,
				'Reassigned To team members should have Alerts_gne__c set to true by workflow field update, '
				+ 'if their are Primary Contact for trial, and thier gstars Contact have User_ref_gne__c field populated.');
		}

		//THEN - assert reassignment history
		CFAR_Team_Member_Reassign_History_gne__c[] historyRecords = [SELECT CFAR_Trial_ref_gne__c, Reassigned_From_ref_gne__c, Reassigned_To_ref_gne__c FROM CFAR_Team_Member_Reassign_History_gne__c];
		System.assertEquals(3, historyRecords.size(),
			'Function should create 3 new CFAR_Team_Member_Reassign_History_gne__c records for each trial that was reassigned.');

		for(CFAR_Team_Member_Reassign_History_gne__c hr : historyRecords){
			System.assertEquals(true, existingTrialIds.contains(hr.CFAR_Trial_ref_gne__c));
			existingTrialIds.remove(String.valueOf(hr.CFAR_Trial_ref_gne__c));

			for(CFAR_Team_Member_gne__c reassignedToTeamMember : reassignedToTeamMembers) {
				if(reassignedToTeamMember.CFAR_Trial_ref_gne__c == hr.CFAR_Trial_ref_gne__c){
					System.assertEquals(reassignedToTeamMember.Id, hr.Reassigned_To_ref_gne__c);
				}
			}

			for(CFAR_Team_Member_gne__c reassignedFromTeamMember : reassignedFromTeamMembers) {
				if(reassignedFromTeamMember.CFAR_Trial_ref_gne__c == hr.CFAR_Trial_ref_gne__c){
					System.assertEquals(reassignedFromTeamMember.Id, hr.Reassigned_From_ref_gne__c);
				}
			}
		}
	}

	static testMethod void reassignSelectedTrials_ShouldNotSetPrimaryContact() {
		//GIVEN
		CFAR_Contact_gne__c gStarsContact = [SELECT Id FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact1'];
		CFAR_Contact_gne__c gStarsContact2 = [SELECT Last_Name_gne__c FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact2'];
		CFAR_Team_Member_gne__c[] existingTeamMembers = [SELECT Is_Trial_Primary_Contact_gne__c FROM CFAR_Team_Member_gne__c];
		for(CFAR_Team_Member_gne__c tm : existingTeamMembers){
			tm.Is_Trial_Primary_Contact_gne__c = false;
		}

		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger','CFAR_Trial_gne__c', 'CFAR_ContactTrigger'});
		update existingTeamMembers;
		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{});
		ApexPages.currentPage().getParameters().put('id', gStarsContact.Id);
		CFAR_TrialReassign_Controller ctrl = new CFAR_TrialReassign_Controller();

		//WHEN
		for (CFAR_Team_Member_gne__c tm : ctrl.teamMembers) {
			tm.Alerts_gne__c = true;
		}

		ctrl.contactToReassignId = gStarsContact2.Id;
		ctrl.reassignSelectedTrials();

		//THEN - assert trials
		CFAR_Trial_gne__c[] existingTrials = [SELECT Genentech_Primary_Contact_ref_gne__r.Last_Name_gne__c FROM CFAR_Trial_gne__c];
		System.assertEquals(3, existingTrials.size(),'There should be 3 existing trials');

		Set<Id> existingTrialIds = new Set<Id>();
		for(CFAR_Trial_gne__c trial : existingTrials){
			System.assertNotEquals(gStarsContact2.Last_Name_gne__c, trial.Genentech_Primary_Contact_ref_gne__r.Last_Name_gne__c,
				'If Contact that Trials were reassigned from, was not these trials primary contact, Contact these trials were reassigned to should also not be their primary Contact.');
			existingTrialIds.add(trial.Id);
		}

		//THEN - assert reassigned to team members
		CFAR_Team_Member_gne__c[] reassignedToTeamMembers = [SELECT Is_Trial_Primary_Contact_gne__c, Inactive_On_gne__c, Active_On_gne__c, Alerts_gne__c
			FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c IN :existingTrialIds
			AND contact_address_ref_gne__r.CFAR_Contact_ref_gne__c =: gStarsContact2.Id];

		System.assertEquals(3, reassignedToTeamMembers.size(), 'There should be 3 team memers of reassigned To Contact on existing trials.');
		for(CFAR_Team_Member_gne__c reassignedToTeamMember : reassignedToTeamMembers) {
			System.assertEquals(false, reassignedToTeamMember.Is_Trial_Primary_Contact_gne__c,
				'Reassigned To team members, should inherit Is_Trial_Primary_Contact_gne__c value set to false from Reassigned From Team members.');
			System.assertEquals(null, reassignedToTeamMember.Inactive_On_gne__c,
				'Reassigned To team members should have Inactive_On_gne__c value empty.');
			System.assertEquals(System.Today(), reassignedToTeamMember.Active_On_gne__c,
				'Reassigned To team members should have Active_On_gne__c value set to Today.');
			System.assertEquals(false, reassignedToTeamMember.Alerts_gne__c,
				'Reassigned To team members should have Alerts_gne__c set to false, if their are not Primary Contact for trial');
		}
	}

	static testMethod void reassignSelectedTrials_ShouldSetMSLOnTrial() {
		//GIVEN
		CFAR_Contact_gne__c gStarsContact = [SELECT Id FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact1'];
		CFAR_Contact_gne__c gStarsContact2 = [SELECT Last_Name_gne__c FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact2'];
		CFAR_Team_Member_gne__c[] existingTeamMembers = [SELECT Is_Trial_Primary_Contact_gne__c FROM CFAR_Team_Member_gne__c];
		for(CFAR_Team_Member_gne__c tm : existingTeamMembers){
			tm.Is_Trial_Primary_Contact_gne__c = false;
			tm.Is_Trial_MSL_gne__c = true;
		}

		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger','CFAR_Trial_gne__c', 'CFAR_ContactTrigger'});
		update existingTeamMembers;
		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{});
		ApexPages.currentPage().getParameters().put('id', gStarsContact.Id);
		CFAR_TrialReassign_Controller ctrl = new CFAR_TrialReassign_Controller();

		//WHEN
		for (CFAR_Team_Member_gne__c tm : ctrl.teamMembers) {
			tm.Alerts_gne__c = true;
		}

		ctrl.contactToReassignId = gStarsContact2.Id;
		ctrl.reassignSelectedTrials();

		//THEN - assert trials
		CFAR_Trial_gne__c[] existingTrials = [SELECT MSL_ref_gne__r.Last_Name_gne__c FROM CFAR_Trial_gne__c];
		Set<Id> existingTrialIds = new Set<Id>();
		for(CFAR_Trial_gne__c trial : existingTrials){
			System.assertEquals(gStarsContact2.Last_Name_gne__c, trial.MSL_ref_gne__r.Last_Name_gne__c,
				'If Contact that Trials were reassigned from, was these trials msl, Contact these trials were reassigned to should be their new MSL.');
			existingTrialIds.add(trial.Id);
		}

		//THEN - assert reassigned to team members
		CFAR_Team_Member_gne__c[] reassignedToTeamMembers = [SELECT Is_Trial_MSL_gne__c, Inactive_On_gne__c, Active_On_gne__c, Alerts_gne__c
			FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c IN :existingTrialIds
			AND contact_address_ref_gne__r.CFAR_Contact_ref_gne__c =: gStarsContact2.Id];

		CFAR_Team_Member_gne__c[] reassignedFromTeamMembers = [SELECT Is_Trial_MSL_gne__c, Inactive_On_gne__c
			FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c IN :existingTrialIds
			AND contact_address_ref_gne__r.CFAR_Contact_ref_gne__c =: gStarsContact.Id];

		System.assertEquals(3, reassignedToTeamMembers.size(), 'There should be 3 team memers of reassigned To Contact on existing trials.');
		for(CFAR_Team_Member_gne__c reassignedToTeamMember : reassignedToTeamMembers) {
			System.assertEquals(true, reassignedToTeamMember.Is_Trial_MSL_gne__c,
				'Reassigned To team members, should inherit Is_Trial_MSL_gne__c value set to true from Reassigned From Team members.');
			System.assertEquals(null, reassignedToTeamMember.Inactive_On_gne__c,
				'Reassigned To team members should have Inactive_On_gne__c value empty.');
			System.assertEquals(System.Today(), reassignedToTeamMember.Active_On_gne__c,
				'Reassigned To team members should have Active_On_gne__c value set to Today.');
			System.assertEquals(false, reassignedToTeamMember.Alerts_gne__c,
				'Reassigned To team members should have Alerts_gne__c set to false, if their are not Primary Contact for trial');
		}

		for(CFAR_Team_Member_gne__c reassignedFromTeamMember : reassignedFromTeamMembers) {
			System.assertEquals(false, reassignedFromTeamMember.Is_Trial_MSL_gne__c,
				'Reassigned From team members, should have Is_Trial_MSL_gne__c value set to false.');
			System.assertEquals(System.Today(), reassignedFromTeamMember.Inactive_On_gne__c,
				'Reassigned From team members should have Inactive_On_gne__c populated');
		}
	}

	static testMethod void reassignSelectedTrials_ShouldThrowExceptionIfNoContactsToReassignSelected() {
		//GIVEN
		CFAR_Contact_gne__c gStarsContact = [SELECT Id FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact1'];
		delete [SELECT Id FROM CFAR_Contact_gne__c WHERE Id != :gStarsContact.Id];
		ApexPages.currentPage().getParameters().put('id', gStarsContact.Id);
		CFAR_TrialReassign_Controller ctrl = new CFAR_TrialReassign_Controller();

		//WHEN - select trials to reassign
		for (CFAR_Team_Member_gne__c tm : ctrl.teamMembers) {
			tm.Alerts_gne__c = true;
		}

		//THEN - display Contacts to reassign Trials to
		ctrl.initContactOptions();
		System.assertEquals(0, ctrl.getContactSearchList1().size(),
			'Should return 0 options if there are no other Contacts with primary, secondary, or tertiary role, as currently selected role: '
			+ CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER);

		//WHEN - select no Cotnact and attempt to reassign selected Trials
		ctrl.reassignSelectedTrials();

		//THEN
		System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, Label.CFAR_SELECT_CONTACT_TO_REASSIGN), ApexPages.getMessages().get(0),
			'Should return error message if user tries to reassign Trials, but no Contact to reassign To was selected');
	}


	static testMethod void reassignSelectedTrials_ShouldNotReassignIfTeamMemberExistOnTrial() {
		//GIVEN
		CFAR_Contact_gne__c gStarsContact = [SELECT Id FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact1'];
		CFAR_Contact_gne__c gStarsContact2 = [SELECT Last_Name_gne__c FROM CFAR_Contact_gne__c WHERE Last_Name_gne__c = 'contact2'];
		CFAR_Trial_gne__c existingTrial = [SELECT Name FROM CFAR_Trial_gne__c LIMIT 1];
		CFAR_Contact_Address_JO_gne__c caJo = [SELECT Id FROM CFAR_Contact_Address_JO_gne__c WHERE CFAR_Contact_ref_gne__c =:gStarsContact2.Id];
		ApexPages.currentPage().getParameters().put('id', gStarsContact.Id);
		CFAR_TrialReassign_Controller ctrl = new CFAR_TrialReassign_Controller();

		for (CFAR_Team_Member_gne__c tm : ctrl.teamMembers) {
			tm.Alerts_gne__c = true;
		}

		CFAR_Team_Member_gne__c tm = CFAR_DataFactory.createTeamMember(existingTrial, 'teamMember2', caJo, CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR);
		tm.Is_Trial_Primary_Contact_gne__c = true;
		tm.Active_On_gne__c = System.Today();
		insert tm;

		//WHEN
		ctrl.contactToReassignId = gStarsContact2.Id;
		ctrl.reassignSelectedTrials();

		//THEN
		System.assertEquals(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot update the contact because the replacement contact already exists in the following studies: ' 
				+ existingTrial.Name + '. Please un-select those studies and try again.'), ApexPages.getMessages().get(0),
			'Should return error message if user tries to reassign Trials To a different Contact, but Team Member of that Contact already exists on one of these trials.');

		CFAR_Team_Member_Reassign_History_gne__c[] historyRecords = [SELECT CFAR_Trial_ref_gne__c, Reassigned_From_ref_gne__c, Reassigned_To_ref_gne__c FROM CFAR_Team_Member_Reassign_History_gne__c];
		System.assertEquals(0, historyRecords.size(), 'Should not create any CFAR_Team_Member_Reassign_History_gne__c, because no Trials should be reassigned');
	}
}