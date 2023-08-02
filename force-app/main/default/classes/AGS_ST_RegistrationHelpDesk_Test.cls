/** @date 3/21/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Registration Help Desk Controller
*/
@isTest
private class AGS_ST_RegistrationHelpDesk_Test {
	
	/** @date 3/21/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for retrieving getters
    */
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);
		AGS_ST_AssistRx_Management_gne__c assistRxManagement = AGS_ST_TestUtils.createAssistRxManagement(agsUser);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			List<SelectOption> genders = ctrl.genders;
			List<SelectOption> states = ctrl.states;
			PageReference redirectDestinURL = ctrl.redirectDestinURL();

			ApexPages.currentPage().getParameters().put('id', null);
			ApexPages.currentPage().getParameters().put('agsStUsrId', agsUser.Id);
			ctrl.goToDetailsAction();

			ApexPages.currentPage().getParameters().put('arxId', 'arxId');
			ApexPages.currentPage().getParameters().put('errorId', 'errorId');
			ApexPages.currentPage().getParameters().put('ihcpId', 'ihcpId');
			PageReference axDetailsActionPage = ctrl.goToArxDetailsAction();
			PageReference errorDetailsActionPage = ctrl.goToErrorDetailsAction();
			PageReference ihcpUserPage = ctrl.goToIhcpUser();
			PageReference arxPage = ctrl.goToArxPage();

			// THEN
			System.assertEquals( 3, genders.size() );
			System.assertEquals( 52, states.size() );
			System.assert( (redirectDestinURL != null) && String.isNotBlank( redirectDestinURL.getUrl() ) );

			System.assert( (axDetailsActionPage != null) && String.isNotBlank( axDetailsActionPage.getUrl() ) );
			System.assert( (errorDetailsActionPage != null) && String.isNotBlank( errorDetailsActionPage.getUrl() ) );
			System.assert( (ihcpUserPage != null) && String.isNotBlank( ihcpUserPage.getUrl() ) );
			System.assert( (arxPage != null) && String.isNotBlank( arxPage.getUrl() ) );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for searchAgsStUserAction() method
    */
	@isTest static void shouldFailSearchAgsStUserAction() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.npiSearch				= ''; 
			ctrl.firstNameSearch		= ''; 
			ctrl.lastNameSearch			= ''; 
			ctrl.usernameSearch			= ''; 
			ctrl.citySearch				= ''; 
			ctrl.zipSearch				= ''; 
			ctrl.stateLicenseNoSearch	= ''; 
			ctrl.stateLicenseStateSearch = ''; 
			ctrl.state 					= null;
			ctrl.searchAgsStUserAction();
			ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

			// THEN
			System.assertEquals( 1, apexPageMessages.size() );
			System.assert( apexPageMessages[0].getSummary().contains('Please define your search') );

		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for searchAgsStUserAction() method
    */
	@isTest static void shouldSuccessfullySearchAgsStUserAction() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.npiSearch				= '*'; 
			ctrl.firstNameSearch		= '*'; 
			ctrl.lastNameSearch			= '*'; 
			ctrl.usernameSearch			= '*'; 
			ctrl.citySearch				= '*'; 
			ctrl.zipSearch				= '*'; 
			ctrl.stateLicenseNoSearch	= '*'; 
			ctrl.stateLicenseStateSearch = 'CA'; 
			ctrl.state 					= 'CA';
			ctrl.gender 				= 'Male';
			ctrl.searchAgsStUserAction();
			List<AGS_ST_User_gne__c> agsStUsers = ctrl.agsStUsers;

			// THEN
			System.assertEquals( 1, agsStUsers.size() );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for showCreateSunUserForm() and hideCreateSunUserForm() methods
    */
	@isTest static void shouldShowAndHideSunUserForm() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.showCreateSunUserForm();
			Boolean isCreationModeShow = ctrl.isCreationMode;

			ctrl.hideCreateSunUserForm();
			Boolean isCreationModeHide = ctrl.isCreationMode;

			// THEN
			System.assert( isCreationModeShow );
			System.assert( !isCreationModeHide );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for createSunUserForm() method
    */
	@isTest static void shouldFailCreateSunUserForm() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);
			ctrl.showCreateSunUserForm();

			// WHEN
			PageReference createSunUserFormPage = ctrl.createSunUserForm();

			// THEN
			System.assertEquals( null, createSunUserFormPage );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for createSunUserForm() method
    */
	@isTest static void shouldSuccessfullyCreateSunUserForm() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);
			ctrl.showCreateSunUserForm();

			// WHEN
			ctrl.newRegistration.Ssn_gne__c 			= '1242';
			ctrl.newAgsStUser.NPI_gne__c 				= '4444111103';
			ctrl.newAgsStUser.State_License_State_gne__c = 'CA';
			ctrl.newAgsStUser.First_name__c 			= 'FirstName';
			ctrl.newAgsStUser.Last_name__c 				= 'LastName';
			ctrl.newAgsStUser.Email_address__c 			= 'email@gmail.com';
			ctrl.newRegistration.City_gne__c 			= 'Los Angeles';
			ctrl.newRegistration.State_gne__c 			= 'CA';
			ctrl.newRegistration.Street_Address_gne__c 	= 'StateAddress';
			ctrl.newRegistration.Zip_gne__c 			= '90028';
			PageReference createSunUserFormPage = ctrl.createSunUserForm();

			// THEN
			System.assertNotEquals( null, createSunUserFormPage );
			System.assertEquals( 1, [SELECT COUNT() FROM AGS_ST_Registration_gne__c] );
			System.assertEquals( 1, [SELECT COUNT() FROM AGS_ST_User_gne__c] );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for editStUser() method
    */
	@isTest static void shouldEditStUser() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.editStUser();

			// THEN
			System.assert( ctrl.isEdit );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for checkCheckSeqQuestions() method
    */
	@isTest static void shouldCheckCheckSeqQuestions() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.checkCheckSeqQuestions();
			ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

			// THEN
			System.assertEquals( 1, apexPageMessages.size() );
			System.assert( apexPageMessages[0].getSummary().contains('Answers for security questions are correct') );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for cancelSecurityQuestions() method
    */
	@isTest static void shouldCancelSecurityQuestions() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.cancelSecurityQuestions();

			// THEN
			System.assert( !ctrl.isSecurityCheck );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for editCheckSeqQuestions() method
    */
	@isTest static void shouldEditCheckSeqQuestions() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.editCheckSeqQuestions();

			// THEN
			System.assert( ctrl.isSecurityCheck );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for saveSeqQuestions() method
    */
	@isTest static void shouldSaveSeqQuestions() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			String newCityOfBirth = 'New York';
			ctrl.iHcpUser.Security_Question_Answer_City_Of_Birth__c = newCityOfBirth;
			ctrl.saveSeqQuestions();

			// THEN
			GNE_CM_IHCP_User__c updatedIhcpUser = [SELECT Security_Question_Answer_City_Of_Birth__c FROM GNE_CM_IHCP_User__c WHERE Id = :ihcpUser.Id LIMIT 1];
			System.assertEquals( newCityOfBirth, updatedIhcpUser.Security_Question_Answer_City_Of_Birth__c );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for saveStUser() method
    */
	@isTest static void shouldSaveStUser() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);
			ctrl.cancelUpdateStUser();

			// WHEN
			String newFirstName = 'NewFirstName';
			ctrl.agsStUserDetail.First_name__c = newFirstName;
			String newCityOfBirth = 'New York';
			ctrl.iHcpUser.Security_Question_Answer_City_Of_Birth__c = newCityOfBirth;
			ctrl.saveStUser();

			// THEN
			AGS_ST_User_gne__c updatedAgsStUser = [SELECT First_name__c FROM AGS_ST_User_gne__c WHERE Id = :agsUser.Id LIMIT 1];
			System.assertEquals( newFirstName, updatedAgsStUser.First_name__c );
			GNE_CM_IHCP_User__c updatedIhcpUser = [SELECT Security_Question_Answer_City_Of_Birth__c FROM GNE_CM_IHCP_User__c WHERE Id = :ihcpUser.Id LIMIT 1];
			System.assertEquals( newCityOfBirth, updatedIhcpUser.Security_Question_Answer_City_Of_Birth__c );
		}
	}

	/** @date 3/24/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for sendArxLink() method
    */
	@isTest static void shouldSendArxLink() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			Integer emailsSendedBefore = Limits.getEmailInvocations();
			ctrl.sendArxLink();
			Integer emailsSendedAfter = Limits.getEmailInvocations();

			// THEN
			System.assertNotEquals(emailsSendedBefore, emailsSendedAfter);
		}
	}

	/** @date 3/25/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for createUserAction() method
    */
	@isTest static void shouldFailCreateUserActionDueToMappedOrgAccountToAgsUser() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.createUserAction();
			ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

			// THEN
			System.assertEquals( 0, apexPageMessages.size() );
		}
	}

	/** @date 3/25/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for createUserAction() method
    */
	@isTest static void shouldCreateUserActionAndGetExistingUserId() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		agsUser.Email_address__c = userWithContact.Username;
		update agsUser;
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			PageReference registrationFinishRef = ctrl.createUserAction();

			// THEN
			System.assertNotEquals( null, registrationFinishRef );
		}
	}

	/** @date 3/25/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for createUserAction() method
    */
	@isTest static void shouldFailCreateUserActionDueToMismatchBetweenUserAccountAndMappedAccount() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		Account personAccount = AGS_ST_TestUtils.createPersonAccount();
		agsUser.Mapped_Account__c = personAccount.Id;
		agsUser.Email_address__c = userWithContact.Username;
		update agsUser;
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.createUserAction();
			ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

			// THEN
			System.assertEquals( 1, apexPageMessages.size() );
			System.assert( apexPageMessages[0].getSummary().contains('SFDC User already exist') );
		}
	}

	/** @date 3/25/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for createUserAction() method
    */
	@isTest static void shouldSuccessfullyCreateUserAction() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		Account personAccount = AGS_ST_TestUtils.createPersonAccount();
		agsUser.Mapped_Account__c = personAccount.Id;
		agsUser.Email_address__c = 'other' + userWithContact.Email;
		update agsUser;
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			PageReference registrationFinishRef = ctrl.createUserAction();

			// THEN
			System.assertNotEquals( null, registrationFinishRef );
		}
	}

	/** @date 3/25/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for sendActivationEmail() method
    */
	@isTest static void shouldSendActivationEmail() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			Integer emailsSendedBefore = Limits.getEmailInvocations();
			ctrl.sendActivationEmail();
			Integer emailsSendedAfter = Limits.getEmailInvocations();

			// THEN
			System.assertNotEquals(emailsSendedBefore, emailsSendedAfter);
		}
	}

	/** @date 3/25/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for unlockSTUserAction() method
    */
	@isTest static void shouldUnlockSTUserAction() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		agsUser.IsLocked_gne__c = true;
		update agsUser;
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.unlockSTUserAction();

			// THEN
			System.assertEquals('STUser unlocked.', ctrl.buttonMsg);
			AGS_ST_User_gne__c agsUserUnlocked = [SELECT IsLocked_gne__c FROM AGS_ST_User_gne__c WHERE Id = :agsUser.Id LIMIT 1]; 
			System.assert( !agsUserUnlocked.IsLocked_gne__c );
		}
	}

	/** @date 3/25/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for saveCommunication() method
    */
	@isTest static void shouldSaveCommunication() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		agsUser.IsLocked_gne__c = true;
		update agsUser;
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			ApexPages.currentPage().getParameters().put('id', agsUser.Id);
			AGS_ST_RegistrationHelpDesk ctrl = new AGS_ST_RegistrationHelpDesk(null);

			// WHEN
			ctrl.saveCommunication();

			// THEN
			List<AGS_ST_HCP_HelpDesk_Comm_gne__c> helpDeskCommunications = [SELECT AGS_ST_User_gne__c FROM AGS_ST_HCP_HelpDesk_Comm_gne__c];
			System.assertEquals( 1, helpDeskCommunications.size() );
			System.assertEquals( agsUser.Id, helpDeskCommunications[0].AGS_ST_User_gne__c );
		}
	}
}