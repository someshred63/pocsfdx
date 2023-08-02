/** @date 4/14/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Login Controller
*/
@isTest
private class AGS_ST_LoginController_gne_Test {
	
	/** @date 4/14/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters
	*/
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjects = AGS_ST_TestUtils.createCmsObjects();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();

			// WHEN
			PageReference sysLogout = ctrl.sysLogout();
			String didYouKnow = ctrl.didYouKnow;
			Boolean isUserLoggedIn = ctrl.isUserLoggedIn;
			String faq_terms = ctrl.faq_terms;
			String termsAndCoditions = ctrl.termsAndCoditions;
			try {
				PageReference goToRegistration = ctrl.goToRegistration();
			} catch(Exception ex) {}
			PageReference goToLoginPage = ctrl.goToLoginPage();
			PageReference goToPaymentsList = ctrl.goToPaymentsList();

			// THEN
			System.assertNotEquals( null, sysLogout );
			System.assert( String.isNotBlank(didYouKnow) );
			System.assert( !isUserLoggedIn );
			System.assert( String.isNotBlank(faq_terms) );
			System.assert( String.isNotBlank(termsAndCoditions) );
			System.assertNotEquals( null, goToLoginPage );
			System.assertNotEquals( null, goToPaymentsList );
		}
	}

	/** @date 4/14/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for activateUser() method
	*/
	@isTest static void shouldFailActivateUser() {
		// GIVEN
		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();

		// WHEN
		PageReference urlParamsDoesNotExist = ctrl.activateUser();

		System.currentPageReference().getParameters().put('agsStUserId', 'wrongId');
		System.currentPageReference().getParameters().put('hash', 'wrongHash');
		PageReference wrongAgsUser = ctrl.activateUser();

		// THEN
		System.assert( urlParamsDoesNotExist.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
		System.assert( wrongAgsUser.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
	}

	/** @date 4/14/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for activateUser() method
	*/
	@isTest static void shouldSuccessfullyActivateUser() {
		// GIVEN
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(ccoAnalyst);

		System.currentPageReference().getParameters().put('agsStUserId', agsUser.Id);
		System.currentPageReference().getParameters().put('hash', agsUser.Activation_Hash_Number__c);

		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();

		// WHEN
		PageReference activateUserPage = ctrl.activateUser();

		// THEN
		System.assertEquals( null, activateUserPage );
	}

	/** @date 4/14/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setPasswordAndLogon() method
	*/
	@isTest static void setFailSetPasswordAndLogon() {
		// GIVEN
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(ccoAnalyst);

		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();

		// WHEN
		ctrl.stUser = new AGS_ST_User_gne__c();
		PageReference noAgsUserPage = ctrl.setPasswordAndLogon();

		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		ctrl.stUser = agsUser;
		ctrl.password = null;
		PageReference passwordNullPage = ctrl.setPasswordAndLogon();

		ctrl.password = '';
		PageReference passwordBlankPage = ctrl.setPasswordAndLogon();

		ctrl.password = 'pass';
		ctrl.passwordConfirm = '';
		PageReference passwordConfirmBlankPage = ctrl.setPasswordAndLogon();

		ctrl.passwordConfirm = 'notMatch';
		PageReference passwordDoNotMatchPage = ctrl.setPasswordAndLogon();

		ctrl.password = 'pass';
		ctrl.passwordConfirm = 'pass';
		PageReference passwordTooShortPage = ctrl.setPasswordAndLogon();

		ctrl.password = 'thisIsPassword';
		ctrl.passwordConfirm = 'thisIsPassword';
		PageReference passwordInvalidNoNumbersPage = ctrl.setPasswordAndLogon();

		ctrl.password = 'thisIsPassword1';
		ctrl.passwordConfirm = 'thisIsPassword1';
		PageReference isTCacceptedNullErrorPage = ctrl.setPasswordAndLogon();

		// THEN
		System.assert( noAgsUserPage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
		System.assertEquals( null, passwordNullPage );
		System.assertEquals( null, passwordBlankPage );
		System.assertEquals( null, passwordConfirmBlankPage );
		System.assertEquals( null, passwordTooShortPage );
		System.assertEquals( null, passwordInvalidNoNumbersPage );
		System.assert( isTCacceptedNullErrorPage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
	}

	/** @date 4/14/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setPasswordAndLogon() method
	*/
	@isTest static void shouldSuccessfullySetPasswordAndLogon() {
		// GIVEN
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(ccoAnalyst);

		String password = 'thisIsPassword1';
		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();
		ctrl.stUser = agsUser;
		ctrl.password = password;
		ctrl.passwordConfirm = password;
		ctrl.isTCaccepted = agsUser.IsTCaccepted__c;
		ctrl.ihcpActivationUsr = AGS_ST_Dbutils.findIHcpUserByUserName(ccoAnalyst.Username); 

		// WHEN
		PageReference setPasswordAndLogonPage = ctrl.setPasswordAndLogon();

		// THEN
		System.assertEquals( null, setPasswordAndLogonPage );
	}

	/** @date 4/15/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for cancelRegistration() method
	*/
	@isTest static void shouldCancelRegistrationNoStatus() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);
		ihcpUser.LWO_Status__c = null;
		ihcpUser.MPS_Status__c = null;
		update ihcpUser;

		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();
		ctrl.stUser = agsUser;

		// WHEN
		try {
			Test.startTest();
			ctrl.cancelRegistration();
			Test.stopTest();
		} catch(Exception ex) {}
	}

	/** @date 4/15/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for cancelRegistration() method
	*/
	@isTest static void shouldCancelRegistrationWithStatus() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);
		ihcpUser.LWO_Status__c = 'Submitted';
		ihcpUser.MPS_Status__c = 'Submitted';
		update ihcpUser;

		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();
		ctrl.stUser = agsUser;

		// WHEN
		try {
			Test.startTest();
			ctrl.cancelRegistration();
			Test.stopTest();
		} catch(Exception ex) {}
	}

	/** @date 4/15/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for usrLogin() method
	*/
	@isTest static void shouldFailUserLogin() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();

		// WHEN
		PageReference nullPasswordErrorPage = ctrl.usrLogin();

		ctrl.password = '';
		PageReference blankPasswordErrorPage = ctrl.usrLogin();

		ctrl.password = 'password';
		ctrl.usrname = '';
		PageReference noIhcpUserErrorPage = ctrl.usrLogin();

		ctrl.usrname = userWithContact.Username;
		ihcpUser.IsLocked__c = true;
		update ihcpUser;
		PageReference ihcpUserIsLockedErrorPage = ctrl.usrLogin();

		ihcpUser.IsLocked__c = false;
		ihcpUser.AGS_ST_Status__c = 'No Access';
		update ihcpUser;
		PageReference ihcpUserNotApprovedErrorPage = ctrl.usrLogin();

		ihcpUser.AGS_ST_Status__c = 'Approved';
		update ihcpUser;
		PageReference ihcpUserFirstWrongAttmeptErrorPage = ctrl.usrLogin();

		ihcpUser.Login_Failed__c = 2;
		update ihcpUser;
		PageReference ihcpUserThirdWrongAttmeptErrorPage = ctrl.usrLogin();

		// THEN
		System.assertEquals( null, nullPasswordErrorPage );
		System.assertEquals( null, blankPasswordErrorPage );
		System.assertEquals( null, noIhcpUserErrorPage );
		System.assertEquals( null, ihcpUserIsLockedErrorPage );
		System.assertEquals( null, ihcpUserNotApprovedErrorPage );
		System.assertEquals( null, ihcpUserFirstWrongAttmeptErrorPage );
		System.assertEquals( null, ihcpUserThirdWrongAttmeptErrorPage );
	}

	/** @date 4/15/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for forgotPassword(String) method
	*/
	@isTest static void shouldSuccessfullyForgotPassword() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		String emailParam = userWithContact.Username;
		
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			// WHEN
			AGS_ST_LoginController_gne.StatusMessage result = AGS_ST_LoginController_gne.forgotPassword(emailParam);

			// THEN
			System.assertEquals( 'Success', result.status );
		}
	}

	/** @date 4/15/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for forgotPassword(String) method
	*/
	@isTest static void shouldFailForgotPassword() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(userWithContact);

		// WHEN
		AGS_ST_LoginController_gne.StatusMessage resultNullParam = AGS_ST_LoginController_gne.forgotPassword(null);

		AGS_ST_LoginController_gne.StatusMessage resultEmptyParam = AGS_ST_LoginController_gne.forgotPassword('');

		ihcpUser.IsLocked__c = true;
		update ihcpUser;
		AGS_ST_LoginController_gne.StatusMessage resultLockedUser = AGS_ST_LoginController_gne.forgotPassword(userWithContact.Username);

		ihcpUser.IsLocked__c = false;
		update ihcpUser;
		delete new AGS_ST_User_gne__c(Id = agsUser.Id);
		AGS_ST_LoginController_gne.StatusMessage resultAgsUserDoesNotExist = AGS_ST_LoginController_gne.forgotPassword(userWithContact.Username);

		// THEN
		System.assertEquals( 'Failure', resultNullParam.status );
		System.assertEquals( 'Failure', resultEmptyParam.status );
		System.assertEquals( 'Failure', resultLockedUser.status );
		System.assertEquals( 'Failure', resultAgsUserDoesNotExist.status );
	}

	/** @date 4/15/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for resetPasswordEmailSending() method
	*/
	@isTest static void shouldResetPasswordEmailSending() {
		// GIVEN
		AGS_ST_TestUtils.createAgsSetting();
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);

		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');
		System.runAs(ccoAnalyst) {
			// WHEN
			PageReference noParamsPage = ctrl.resetPasswordEmailSending();

			System.currentPageReference().getParameters().put('agsStUserId', agsUser.Id);
			System.currentPageReference().getParameters().put('confEmail', 'test@gmail.com');
			PageReference currentPage = ctrl.resetPasswordEmailSending();

			// THEN
			System.assert( noParamsPage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
			System.assertEquals( System.currentPageReference(), currentPage );
		}
	}

	/** @date 4/15/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for checkResetPassword() method
	*/
	@isTest static void shouldSuccessfullyCheckResetPassword() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);

		String activationHashNumber = 'activationHashNumber';
		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();		

		// WHEN
		agsUser.Reset_Password_Email_Sent_Date__c = DateTime.now();
		agsUser.Activation_Hash_Number__c = activationHashNumber;
		update agsUser;

		System.currentPageReference().getParameters().put('agsStUserId', agsUser.Id);
		System.currentPageReference().getParameters().put('hash', activationHashNumber);

		PageReference resultPage = ctrl.checkResetPassword();

		// THEN
		System.assertEquals( null, resultPage );
	}

	/** @date 4/15/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for checkResetPassword() method
	*/
	@isTest static void shouldFailCheckResetPassword() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);

		String activationHashNumber = 'activationHashNumber';
		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();
		System.currentPageReference().getParameters().put('agsStUserId', agsUser.Id);		

		// WHEN
		agsUser.Reset_Password_Email_Sent_Date__c = null;
		update agsUser;
		PageReference nullResetDateErrorPage = ctrl.checkResetPassword();

		agsUser.Reset_Password_Email_Sent_Date__c = DateTime.now().addDays(-1);
		agsUser.Activation_Hash_Number__c = activationHashNumber;
		update agsUser;
		System.currentPageReference().getParameters().put('hash', 'otherHash');
		PageReference otherHashErrorPage = ctrl.checkResetPassword();

		agsUser.Last_Password_Modified_Date__c = DateTime.now();
		agsUser.Activation_Hash_Number__c = activationHashNumber;
		update agsUser;
		System.currentPageReference().getParameters().put('hash', activationHashNumber);
		PageReference notMatchResetDatePage = ctrl.checkResetPassword();

		// THEN
		System.assert( nullResetDateErrorPage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
		System.assert( otherHashErrorPage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
		System.assert( notMatchResetDatePage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
	}

	/** @date 4/16/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changePasswordAfterResetPassword() method
	*/
	@isTest static void shouldFailChangePasswordAfterResetPassword() {
		// GIVEN
		String activationHashNumber = 'activationHashNumber';
		String password = 'thisIsPassword';
		String cityOfBirth = 'cityOfBirth';
		String cityOfJob = 'cityOfJob';
		String dayOfBirth = 'dayOfBirth';

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');

		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(ccoAnalyst);
		ihcpUser.Security_Question_Answer_City_Of_Birth__c = cityOfBirth;
		ihcpUser.Security_Question_Answer_City_Of_Job__c = cityOfJob;
		ihcpUser.Security_Question_Answer_Day_Of_Birth__c = dayOfBirth;
		update ihcpUser;
		
		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();

		// WHEN
		PageReference noParamsErrorPage = ctrl.changePasswordAfterResetPassword();

		System.currentPageReference().getParameters().put('agsStUserId', 'wrongId');
		System.currentPageReference().getParameters().put('hash', 'otherHash');
		PageReference noAgsUserErrorPage = ctrl.changePasswordAfterResetPassword();


		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		agsUser.Activation_Hash_Number__c = activationHashNumber;
		update agsUser;
		System.currentPageReference().getParameters().put('agsStUserId', agsUser.Id);
		PageReference hashDoesNotMatchErrorPage = ctrl.changePasswordAfterResetPassword();

		System.currentPageReference().getParameters().put('hash', activationHashNumber);
		PageReference invalidPasswordErrorPage = ctrl.changePasswordAfterResetPassword();

		ctrl.newPassword = password;
		ctrl.verifyNewPassword = password;
		PageReference noCorrectAnswersErrorPage = ctrl.changePasswordAfterResetPassword();

		ctrl.cobAnswer = cityOfBirth;
		ctrl.cojAnswer = cityOfJob;
		ctrl.dobAnswer = dayOfBirth;
		PageReference setPasswordErrorPage = ctrl.changePasswordAfterResetPassword();

		// THEN
		System.assert( noParamsErrorPage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
		System.assert( noAgsUserErrorPage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
		System.assert( hashDoesNotMatchErrorPage.getUrl().contains( Page.AGS_ST_RegisterError_gne.getUrl() ) );
		System.assertEquals( null, invalidPasswordErrorPage );
		System.assertEquals( null, noCorrectAnswersErrorPage );
		System.assertEquals( null, setPasswordErrorPage );
	}

	/** @date 4/16/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changePasswordAfterResetPassword() method
	*/
	@isTest static void shouldSuccessfullyChangePasswordAfterResetPassword() {
		// GIVEN
		String activationHashNumber = 'activationHashNumber';
		String password = 'thisIsPassword1';
		String cityOfBirth = 'cityOfBirth';
		String cityOfJob = 'cityOfJob';
		String dayOfBirth = 'dayOfBirth';

		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuser@gene.com.test');

		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(ccoAnalyst);
		agsUser.Activation_Hash_Number__c = activationHashNumber;
		update agsUser;

		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(ccoAnalyst);
		ihcpUser.Security_Question_Answer_City_Of_Birth__c = cityOfBirth;
		ihcpUser.Security_Question_Answer_City_Of_Job__c = cityOfJob;
		ihcpUser.Security_Question_Answer_Day_Of_Birth__c = dayOfBirth;
		update ihcpUser;

		
		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();
		ctrl.newPassword = password;
		ctrl.verifyNewPassword = password;
		ctrl.cobAnswer = cityOfBirth;
		ctrl.cojAnswer = cityOfJob;
		ctrl.dobAnswer = dayOfBirth;

		System.currentPageReference().getParameters().put('agsStUserId', agsUser.Id);
		System.currentPageReference().getParameters().put('hash', activationHashNumber);

		// WHEN
		PageReference resultPage = ctrl.changePasswordAfterResetPassword();

		// THEN
		AGS_ST_User_gne__c agsUserUpdated = [SELECT Activation_Hash_Number__c FROM AGS_ST_User_gne__c WHERE Id = :agsUser.Id LIMIT 1];
		System.assertEquals( null, agsUserUpdated.Activation_Hash_Number__c );
	}

	/** @date 4/16/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changePassword() method
	*/
	@isTest static void shouldFailChangePassword() {
		// GIVEN
		AGS_ST_LoginController_gne ctrl = new AGS_ST_LoginController_gne();
		ctrl.newPassword = 'pass';
		ctrl.verifyNewPassword = 'pass';
		ctrl.oldpassword = 'oldPass';

		// WHEN
		PageReference resultPage = ctrl.changePassword();

		// THEN
		System.assertEquals( null, resultPage );
	}
}