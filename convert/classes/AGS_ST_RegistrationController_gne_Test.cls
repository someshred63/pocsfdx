/** @date 5/6/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Registration Controller
*/
@isTest
private class AGS_ST_RegistrationController_gne_Test {
	
	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters
	*/
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_ST_TestUtils.createCmsObjects();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();

		// WHEN
		String dyksText = ctrl.didYouKnow;
		AGS_ST_Settings_gne__c stSetting = AGS_ST_RegistrationController_gne.stSetting;
		String sunshineTrackOrgWideAddress = AGS_ST_RegistrationController_gne.sunshineTrackOrgWideAddress;
		PageReference loginPage = ctrl.goToLoginPage();
		List<SelectOption> states = ctrl.states;
		PageReference registerCancelActionPage = ctrl.registerCancelAction();

		// THEN
		List<AGS_ST_FAQ_DYK_gne__c> dyks = (List<AGS_ST_FAQ_DYK_gne__c>)JSON.deserialize(
			dyksText, List<AGS_ST_FAQ_DYK_gne__c>.class
		);
		System.assertEquals( 1, dyks.size() );
		System.assertNotEquals( null, stSetting );
		System.assertNotEquals( null, loginPage );
		System.assertNotEquals( 0, states.size() );
		System.assertNotEquals( null, registerCancelActionPage );
	}

	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for landingRegistrationSubmitEmailAction() method
	*/
	@isTest static void shouldInvokeLandingRegistrationSubmitEmailAction() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();

		// WHEN
		ctrl.landingRegistrationSubmitEmailAction();
		Boolean isToolUsrNoRegEmail = ctrl.isToolUsr;
		String availablePortalsNoRegEmail = ctrl.availablePortals;

		ApexPages.currentPage().getParameters().put('regEmail', testUser.Username);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);
		ihcpUser.AGS_ST_Status__c = 'Approved';
		update ihcpUser;
		ctrl.landingRegistrationSubmitEmailAction();
		Boolean isToolUsrApprovedIhcpUser = ctrl.isToolUsr;
		String availablePortalsApprovedIhcpUser = ctrl.availablePortals;

		ihcpUser.AGS_ST_Status__c = 'Submitted';
		update ihcpUser;
		ctrl.landingRegistrationSubmitEmailAction();
		Boolean isToolUsrSubmittedIhcpUser = ctrl.isToolUsr;
		String availablePortalsSubmittedIhcpUser = ctrl.availablePortals;

		// THEN
		System.assert(!isToolUsrNoRegEmail);
		System.assert( String.isBlank(availablePortalsNoRegEmail) );

		System.assert(isToolUsrApprovedIhcpUser);
		System.assert( String.isBlank(availablePortalsApprovedIhcpUser) );

		System.assert(!isToolUsrSubmittedIhcpUser);
		System.assert( String.isNotBlank(availablePortalsSubmittedIhcpUser) );
	}

	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for findAccountByNpiRemote(String, String) method
	*/
	@isTest static void shouldFindAccountByNpiRemote() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.createUserWithContact();

		// WHEN
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawNoAccountsFound = 
			AGS_ST_RegistrationController_gne.findAccountByNpiRemote('non-existing npi', '');

		String npiParamNoMdmId = 'NPI No MDMID';
		insert new List<Account>{
			new Account(LastName = 'test account 1', NPI_vod__c = npiParamNoMdmId),
			new Account(LastName = 'test account 2', NPI_vod__c = npiParamNoMdmId)
		};
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawMoreThanOneAccountWithoutMdmId = 
			AGS_ST_RegistrationController_gne.findAccountByNpiRemote(npiParamNoMdmId, '');

		Account userAccount = [SELECT Id, NPI_vod__c FROM Account WHERE Id = :testUser.AccountId];
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawNoIhcpUser = 
			AGS_ST_RegistrationController_gne.findAccountByNpiRemote(userAccount.NPI_vod__c, testUser.Username);

		AGS_ST_RegistrationController_gne.SearchAcctWrap sawMismatchBetweenUsernameAndEmail = 
			AGS_ST_RegistrationController_gne.findAccountByNpiRemote(userAccount.NPI_vod__c, 'other' + testUser.Username);

		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawNoError = 
			AGS_ST_RegistrationController_gne.findAccountByNpiRemote(userAccount.NPI_vod__c, testUser.Username);

		// THEN
		System.assert( sawNoAccountsFound.errorMsg.startsWith('We could not find data account for provided NPI') );
		System.assert( sawMoreThanOneAccountWithoutMdmId.errorMsg.startsWith('We could not find the correct data') );
		System.assert( sawNoIhcpUser.errorMsg.startsWith('User already exists for provided NPI') );
		System.assert( sawMismatchBetweenUsernameAndEmail.errorMsg.startsWith('User already exists for provided NPI') );
		System.assertEquals( userAccount.Id, sawNoError.id );
	}

	/** @date 5/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for findAccountByStateLicenseRemote(String, String, String) method
	*/
	@isTest static void shouldFindAccountByStateLicenseRemote() {
		Test.startTest();
		// GIVEN
		User testUser = AGS_ST_TestUtils.createUserWithContact();

		// WHEN
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawNoAccountsFound = 
			AGS_ST_RegistrationController_gne.findAccountByStateLicenseRemote('', '', '');

		Account acc1 = new Account(LastName = 'test account 1');
		Account acc2 = new Account(LastName = 'test account 2');
		insert new List<Account>{acc1, acc2};
		Test.stopTest();
		String license = 'license';
		String state = 'CA';
		String city = 'New York';
		String zip = '91731';
		Address_vod__c addr1 = new Address_vod__c(
		    Name = 'street1',
		    License_vod__c = license, 
		    State_vod__c = state, 
		    Account_vod__c = acc1.Id,
		    City_vod__c = city,
		    Zip_vod__c = zip
		);
		Address_vod__c addr2 = new Address_vod__c(
		    Name = 'street2',
		    License_vod__c = license, 
		    State_vod__c = state, 
		    Account_vod__c = acc2.Id,
            City_vod__c = city,
            Zip_vod__c = zip
		);
		insert new List<Address_vod__c>{addr1, addr2};
		Test.setFixedSearchResults(new List<String>{addr1.Id, addr2.Id});
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawMoreThanOneAccountWithoutMdmId = 
			AGS_ST_RegistrationController_gne.findAccountByStateLicenseRemote(license, state, '');

		Account userAccount = [SELECT Id, NPI_vod__c FROM Account WHERE Id = :testUser.AccountId];
		Address_vod__c userAccountAddress = new Address_vod__c(
		    Name = 'street3',
		    License_vod__c = license, 
		    State_vod__c = state, 
		    Account_vod__c = userAccount.Id,
            City_vod__c = city,
            Zip_vod__c = zip
		);
		insert userAccountAddress;
		Test.setFixedSearchResults(new List<String>{userAccountAddress.Id});
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawNoIhcpUser = 
			AGS_ST_RegistrationController_gne.findAccountByStateLicenseRemote(license, state, testUser.Username);
		
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawMismatchBetweenUsernameAndEmail = 
			AGS_ST_RegistrationController_gne.findAccountByStateLicenseRemote(license, state, 'other' + testUser.Username);

		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawNoError = 
			AGS_ST_RegistrationController_gne.findAccountByStateLicenseRemote(license, state, testUser.Username);

		// THEN
		System.assert( sawNoAccountsFound.errorMsg.startsWith('We could not find data for provided State License details') );
		System.assert( sawMoreThanOneAccountWithoutMdmId.errorMsg.startsWith('We could not find the correct data') );
		System.assert( sawNoIhcpUser.errorMsg.startsWith('User already exists for data provided') );
		System.assert( sawMismatchBetweenUsernameAndEmail.errorMsg.startsWith('User already exists for data provided') );
		System.assertEquals( userAccount.Id, sawNoError.id );
	}

	/** @date 5/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for cleanAccounts(List<Account>, String) method
	*/
	@isTest static void shouldCleanAccounts() {
		// GIVEN
		Account account1 = new Account(LastName = 'test account 1', MDMID_gne__c = 'MDM_ID1', DCH_Action_gne__c = '');
		Account account2 = new Account(LastName = 'test account 2', MDMID_gne__c = 'MDM_ID2', DCH_Action_gne__c = '');
		insert new List<Account>{account1, account2};

		// WHEN
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawOneCleanedAccount = 
			AGS_ST_RegistrationController_gne.cleanAccounts(getAccountsFromIds(new List<Id>{account1.Id}), '');

		AGS_ST_RegistrationController_gne.SearchAcctWrap sawTwoCleanedAccountNoWinner = 
			AGS_ST_RegistrationController_gne.cleanAccounts(getAccountsFromIds(new List<Id>{account1.Id, account2.Id}), '');

		account2.DCH_Action_gne__c = 'Winner';
		account2.DCH_Merge_Exceptions_gne__c = 'No Exceptions';
		account2.DCH_Action_Date_gne__c = DateTime.now();
		update account2;
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawTwoCleanedAccountOneWinner = 
			AGS_ST_RegistrationController_gne.cleanAccounts(getAccountsFromIds(new List<Id>{account1.Id, account2.Id}), '');

		account1.DCH_Action_gne__c = 'Winner';
		account1.DCH_Merge_Exceptions_gne__c = 'No Exceptions';
		account1.DCH_Action_Date_gne__c = DateTime.now();
		update account1;
		AGS_ST_RegistrationController_gne.SearchAcctWrap sawTwoCleanedAccountTwoWinners = 
			AGS_ST_RegistrationController_gne.cleanAccounts(getAccountsFromIds(new List<Id>{account1.Id, account2.Id}), '');

		// THEN
		System.assertEquals(account1.Id, sawOneCleanedAccount.id);
		System.assert( sawTwoCleanedAccountNoWinner.errorMsg.startsWith('We could not find the correct data') );
		System.assertEquals(account2.Id, sawTwoCleanedAccountOneWinner.id);
		System.assert( sawTwoCleanedAccountTwoWinners.errorMsg.startsWith('We could not find the correct data') );
	}

	/** @date 5/7/2014
	* @description Util Method - Get Account List from Id List
	* @param List<Id> accIds
	* @return List<Account>
	*/
	private static List<Account> getAccountsFromIds(List<Id> accIds) {
		return [
			SELECT 	Id, LastName, MDMID_gne__c, DCH_Action_gne__c, DCH_Merge_Status_gne__c
			FROM 	Account
			WHERE 	Id IN :accIds
		];
	}

	/** @date 5/7/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for registerGoToAssistRxAction() method
	*/
	@isTest static void shouldRegisterGoToAssistRxAction() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.getCurrentUser();
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();
		ctrl.regUser = AGS_ST_TestUtils.initiateValidAgsStUser();
		ctrl.regUser.firstName = null;

		// WHEN
		PageReference invalidAgsUserDueToNoFirstNamePage = ctrl.registerGoToAssistRxAction();

		ctrl.regUser.firstName = 'Adam';
		ctrl.email = 'other' + ctrl.regUser.email;
		PageReference mismatchBetweenControllerEmailAndAgsUserEmailPage = ctrl.registerGoToAssistRxAction();

		ctrl.email = ctrl.regUser.email;
		PageReference createAgsUserNoIhcpUserPage = ctrl.registerGoToAssistRxAction();

		ApexPages.currentPage().getParameters().put('regEmail', testUser.Username);
		ctrl.landingRegistrationSubmitEmailAction();
		PageReference createAgsUserWithIhcpUserPage = ctrl.registerGoToAssistRxAction();

		ctrl.regUser.email = 'wrong email format';
		ctrl.email = ctrl.regUser.email;
		try {
			Test.startTest();
			PageReference createAgsUserErrorDueToInvalidEmailFormatPage = ctrl.registerGoToAssistRxAction();
			Test.stopTest();
		} catch(Exception e) {}

		// THEN
		System.assertNotEquals( null, invalidAgsUserDueToNoFirstNamePage );
		System.assertNotEquals( null, mismatchBetweenControllerEmailAndAgsUserEmailPage );
		System.assertNotEquals( null, createAgsUserNoIhcpUserPage );
		System.assertNotEquals( null, createAgsUserWithIhcpUserPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationLoadData() method
	*/
	@isTest static void shouldFailAssistRxVerificationLoadDataIsArxSkipTrueUserIdNotNullWhileRegistering() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User testUser = AGS_ST_TestUtils.getCurrentUser();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();
		ctrl.regUser = AGS_ST_TestUtils.initiateValidAgsStUser();
		ctrl.regUser.email = testUser.Username;
		ctrl.email = ctrl.regUser.email;
		ctrl.registerGoToAssistRxAction();
		AGS_ST_User_gne__c agsUser = [SELECT Id FROM AGS_ST_User_gne__c LIMIT 1];

		// WHEN
		ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
		PageReference resultPage = ctrl.assistRxVerificationLoadData();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationLoadData() method
	*/
	@isTest static void shouldFailAssistRxVerificationLoadDataIsArxSkipTrueUserIdNullWhileRegistering() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();

		Account personAccount = AGS_ST_TestUtils.createPersonAccount();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();
		ctrl.regUser = AGS_ST_TestUtils.initiateValidAgsStUser();
		ctrl.email = ctrl.regUser.email;
		ctrl.registerGoToAssistRxAction();
		AGS_ST_User_gne__c agsUser = [SELECT Id FROM AGS_ST_User_gne__c LIMIT 1];

		// WHEN
		ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
		ApexPages.currentPage().getParameters().put('accountId', personAccount.Id);
		PageReference resultPage = ctrl.assistRxVerificationLoadData();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationLoadData() method
	*/
	@isTest static void shouldFailAssistRxVerificationLoadDataIsArxSkipTrueErrorWithCreatingUserWhileRegistering() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();

		Account businessAccount = AGS_ST_TestUtils.createBusinessAccount();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();
		ctrl.regUser = AGS_ST_TestUtils.initiateValidAgsStUser();
		ctrl.email = ctrl.regUser.email;
		ctrl.registerGoToAssistRxAction();
		AGS_ST_User_gne__c agsUser = [SELECT Id FROM AGS_ST_User_gne__c LIMIT 1];

		// WHEN
		ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
		ApexPages.currentPage().getParameters().put('accountId', businessAccount.Id);
		PageReference resultPage = ctrl.assistRxVerificationLoadData();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationLoadData() method
	*/
	@isTest static void shouldFailAssistRxVerificationLoadDataIsArxSkipTrueNoAgsUserId() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();

		// WHEN
		PageReference resultPage = (new AGS_ST_RegistrationController_gne()).assistRxVerificationLoadData();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationLoadData() method
	*/
	@isTest static void shouldFailAssistRxVerificationLoadDataIsArxSkipFalseNoAgsUserIdAsParam() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		agsSettings.Is_Arx_Skip_gne__c = false;
		update agsSettings;

		// WHEN
		PageReference resultPage = (new AGS_ST_RegistrationController_gne()).assistRxVerificationLoadData();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationLoadData() method
	*/
	@isTest static void shouldFailAssistRxVerificationLoadDataIsArxSkipFalseAgsUserLocked() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		agsSettings.Is_Arx_Skip_gne__c = false;
		update agsSettings;

		Account personAccount = AGS_ST_TestUtils.createPersonAccount();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();
		ctrl.regUser = AGS_ST_TestUtils.initiateValidAgsStUser();
		ctrl.email = ctrl.regUser.email;
		ctrl.registerGoToAssistRxAction();
		AGS_ST_User_gne__c agsUser = [SELECT Id, IsLocked_gne__c FROM AGS_ST_User_gne__c LIMIT 1];
		agsUser.IsLocked_gne__c = true;
		update agsUser;

		// WHEN
		ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
		ApexPages.currentPage().getParameters().put('accountId', personAccount.Id);
		PageReference resultPage = ctrl.assistRxVerificationLoadData();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationLoadData() method
	*/
	@isTest static void shouldFailAssistRxVerificationLoadDataIsArxSkipFalseWebServiceError() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		agsSettings.Is_Arx_Skip_gne__c = false;
		update agsSettings;

		Account personAccount = AGS_ST_TestUtils.createPersonAccount();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();
		ctrl.regUser = AGS_ST_TestUtils.initiateValidAgsStUser();
		ctrl.email = ctrl.regUser.email;
		ctrl.registerGoToAssistRxAction();
		AGS_ST_User_gne__c agsUser = [SELECT Id, IsLocked_gne__c FROM AGS_ST_User_gne__c LIMIT 1];

		// WHEN
		ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
		ApexPages.currentPage().getParameters().put('accountId', personAccount.Id);
		PageReference resultPage = ctrl.assistRxVerificationLoadData();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationCheckAndRegisterUserAction() method
	*/
	@isTest static void shouldFailAssistRxVerificationCheckAndRegisterUserActionCheckQuizError() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();
		ctrl.regUser = AGS_ST_TestUtils.initiateValidAgsStUser();
		ctrl.email = ctrl.regUser.email;
		ctrl.registerGoToAssistRxAction();

		// WHEN
		PageReference resultPage = ctrl.assistRxVerificationCheckAndRegisterUserAction();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationCheckAndRegisterUserAction() method
	*/
	@isTest static void shouldFailAssistRxVerificationCheckAndRegisterUserActionCheckQuizTriesMoreThanTwo() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();

		// WHEN
		ctrl.quizTries = 2;
		PageReference resultPage = ctrl.assistRxVerificationCheckAndRegisterUserAction();

		// THEN
		System.assertEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationCheckAndRegisterUserAction() method
	*/
	@isTest static void shouldFailAssistRxVerificationCheckAndRegisterUserActionCheckQuizTriesTwo() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();

		// WHEN
		ctrl.quizTries = 1;
		PageReference resultPage = ctrl.assistRxVerificationCheckAndRegisterUserAction();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for assistRxVerificationCheckAndRegisterUserAction() method
	*/
	@isTest static void shouldFailAssistRxVerificationCheckAndRegisterUserActionCheckQuizTriesOne() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();

		AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();

		// WHEN
		ctrl.quizTries = 0;
		PageReference resultPage = ctrl.assistRxVerificationCheckAndRegisterUserAction();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for sendToActivate() method
	*/
	@isTest static void shouldSuccessfullySendToActivate() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');

		System.runAs(testUser) {
			Account businessAccount = AGS_ST_TestUtils.createBusinessAccount();

			AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();
			ctrl.regUser = AGS_ST_TestUtils.initiateValidAgsStUser();
			ctrl.email = ctrl.regUser.email;
			ctrl.registerGoToAssistRxAction();
			AGS_ST_User_gne__c agsUser = [SELECT Id FROM AGS_ST_User_gne__c LIMIT 1];

			ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
			ApexPages.currentPage().getParameters().put('accountId', businessAccount.Id);
			ctrl.assistRxVerificationLoadData();

			// WHEN
			ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
			ApexPages.currentPage().getParameters().put('usr', testUser.Id);
			ApexPages.currentPage().getParameters().put('ihcpUserId', '000');
			PageReference resultPage = ctrl.sendToActivate();

			// THEN
			System.assertNotEquals( null, resultPage );
		}
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for sendToActivate() method
	*/
	@isTest static void shouldFailSendToActivateDueToNullIhcpUserIdParameter() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);

		System.runAs(testUser) {
			AGS_ST_RegistrationController_gne ctrl = new AGS_ST_RegistrationController_gne();

			// WHEN
			ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
			ApexPages.currentPage().getParameters().put('usr', testUser.Id);
			PageReference resultPage = ctrl.sendToActivate();

			// THEN
			System.assertNotEquals( null, resultPage );
		}
	}
}