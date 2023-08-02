/** @date 4/30/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Change User Data Controller
*/
@isTest
private class AGS_ST_ChangeUserDataController_gne_Test {
	
	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters
	*/
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsObjectsMap = AGS_ST_TestUtils.createCmsObjects();

		AGS_ST_ChangeUserDataController_gne ctrl = new AGS_ST_ChangeUserDataController_gne();

		// WHEN
		String toolTipsJson = ctrl.toolTips;
		PageReference goToHomePage = ctrl.goToHomePage();
		PageReference sysLogout = ctrl.sysLogout();

		// THEN
		List<AGS_ST_FAQ_DYK_gne__c> toolTipsList = (List<AGS_ST_FAQ_DYK_gne__c>)JSON.deserialize(toolTipsJson, List<AGS_ST_FAQ_DYK_gne__c>.class);
		System.assertNotEquals( 0, toolTipsList.size() );
		System.assertNotEquals( null, goToHomePage );
		System.assertNotEquals( null, sysLogout );
	}

	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for pageOnLoadAction() method
	*/
	@isTest static void shouldInvokePageOnLoadAction() {
		// GIVEN
		User thisUser = AGS_ST_TestUtils.getCurrentUser();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(thisUser);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(thisUser);

		AGS_ST_ChangeUserDataController_gne ctrl = new AGS_ST_ChangeUserDataController_gne();

		// WHEN
		ctrl.pageOnLoadAction();

		agsUser.Phone_number__c = null;
		agsUser.Phone_number_ext__c = '123456789';
		update agsUser;
		ctrl.pageOnLoadAction();

		// THEN
		System.assert(ctrl.isMPSusr);
		System.assert(ctrl.isLWOusr);
	}
	
	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeCommData(String, Boolean, String, String) method
	*/
	@isTest static void shouldSuccessfullyChangeCommData() {
		// GIVEN
		User thisUser = AGS_ST_TestUtils.getCurrentUser();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(thisUser);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(thisUser);

		// WHEN
		String phoneNo 			= '123456789';
		Boolean isMobile 		= true;
		String email 			= 'test@gmail.com';
		String communication 	= 'Phone';
		String result1 = AGS_ST_ChangeUserDataController_gne.changeCommData(phoneNo, isMobile, email, communication);

		isMobile = false;
		String result2 = AGS_ST_ChangeUserDataController_gne.changeCommData(phoneNo, isMobile, email, communication);

		// THEN
		System.assertEquals( 'Success', result1 );
		System.assertEquals( 'Success', result2 );
	}

	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeCommData(String, Boolean, String, String) method
	*/
	@isTest static void shouldFailChangeCommDataDueToNoAgsUser() {
		// GIVEN
		String phoneNo 			= '123456789';
		Boolean isMobile 		= true;
		String email 			= 'test@gmail.com';
		String communication 	= 'Phone';

		// WHEN
		String result = AGS_ST_ChangeUserDataController_gne.changeCommData(phoneNo, isMobile, email, communication);

		// THEN
		System.assert( result.startsWith('Failed') );
	}

	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changePassword(String, String) method
	*/
	@isTest static void shouldChangePassword() {
		// GIVEN
		String newPassword = 'newPassword1';
		String invalidPassword = 'newPassword';

		// WHEN

		// verification fail
		String resultVerificationFail = AGS_ST_ChangeUserDataController_gne.changePassword(newPassword, newPassword + '1');

		// invalid password
		String resultInvalidPassword = AGS_ST_ChangeUserDataController_gne.changePassword(invalidPassword, invalidPassword);

		// success
		String resultSuccess = AGS_ST_ChangeUserDataController_gne.changePassword(newPassword, newPassword);

		// THEN
		System.assertEquals('Failed', resultVerificationFail);
		System.assertEquals('Failed', resultInvalidPassword);
		System.assertEquals('Success', resultSuccess);
	}

	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeUserNameAction(String) method
	*/
	@isTest static void shouldSuccessfullyChangeUserNameAction() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);

		String newUsername = 'test@nonexistingemail.com';

		System.runAs(userWithContact) {
			// WHEN
			String result = AGS_ST_ChangeUserDataController_gne.changeUserNameAction(newUsername);

			// THEN
			System.assertEquals('Your user name has been successfully changed.', result);
		}
	}

	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeUserNameAction(String) method
	*/
	@isTest static void shouldFailChangeUserNameAction() {
		// GIVEN
		User userWithContact = AGS_ST_TestUtils.createUserWithContact();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(userWithContact);

		System.runAs(userWithContact) {
			// WHEN
			String resultEmptyUsername = AGS_ST_ChangeUserDataController_gne.changeUserNameAction(null);

			String existingUsername = [SELECT Username FROM User LIMIT 1].Username;
			String resultUsernameExists = AGS_ST_ChangeUserDataController_gne.changeUserNameAction(existingUsername);

			// THEN
			System.assertEquals('User name must not be empty! User name is a required field.', resultEmptyUsername);
			System.assertEquals('The username is already used by another user!', resultUsernameExists);
		}
	}

	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updatePaymentActivityAlert(Boolean, Decimal) method
	*/
	@isTest static void shouldUpdatePaymentActivityAlert() {
		// GIVEN
		Boolean isNewPaymentAlert = true;
		Decimal newPaymentAmount = 1;

		// WHEN
		String resultFail = AGS_ST_ChangeUserDataController_gne.updatePaymentActivityAlert(isNewPaymentAlert, newPaymentAmount);

		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		String resultSuccess = AGS_ST_ChangeUserDataController_gne.updatePaymentActivityAlert(isNewPaymentAlert, newPaymentAmount);

		// THEN
		System.assertEquals('Failed', resultFail);
		System.assertEquals('Success', resultSuccess);
	}

	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updateActivityDigest(String) method
	*/
	@isTest static void shouldUpdateActivityDigest() {
		// GIVEN
		String alertFreq = 'Weekly Digest';

		// WHEN
		String resultFail = AGS_ST_ChangeUserDataController_gne.updateActivityDigest(alertFreq);

		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		String resultSuccess = AGS_ST_ChangeUserDataController_gne.updateActivityDigest(alertFreq);

		// THEN
		System.assertEquals('Failed', resultFail);
		System.assertEquals('Success', resultSuccess);
	}

	/** @date 4/30/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for updateDisputeActivityAlert(Boolean) method
	*/
	@isTest static void shouldUpdateDisputeActivityAlert() {
		// GIVEN
		Boolean isAlertDisputes = true;

		// WHEN
		String resultFail = AGS_ST_ChangeUserDataController_gne.updateDisputeActivityAlert(isAlertDisputes);

		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(AGS_ST_TestUtils.getCurrentUser());
		String resultSuccess = AGS_ST_ChangeUserDataController_gne.updateDisputeActivityAlert(isAlertDisputes);

		// THEN
		System.assertEquals('Failed', resultFail);
		System.assertEquals('Success', resultSuccess);
	}

	/** @date 5/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for edit Sequrity Question Date Of Birth
	*/
	@isTest static void shouldEditSecurityQuestionDateOfBirth() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.getCurrentUser();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);

		AGS_ST_ChangeUserDataController_gne ctrl = new AGS_ST_ChangeUserDataController_gne();

		// WHEN
		ctrl.dobEditAction();
		Boolean isEdit = ctrl.isDobEdit;

		ctrl.cancelDobEdit();
		Boolean isEditAfterCancel = ctrl.isDobEdit;

		ctrl.dobEditAction();
		String sqText = 'sqText';
		ctrl.dobTxt = sqText;
		ctrl.dobSave();

		// THEN
		GNE_CM_IHCP_User__c ihcpUsr = AGS_ST_DbUtils.getIHCPUser(testUser.Id);
		System.assert(isEdit);
		System.assert(!isEditAfterCancel);
		System.assertEquals(sqText, ihcpUsr.Security_Question_Answer_Day_Of_Birth__c);
	}

	/** @date 5/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for edit Sequrity Question City Of Birth
	*/
	@isTest static void shouldEditSecurityQuestionCityOfBirth() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.getCurrentUser();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);

		AGS_ST_ChangeUserDataController_gne ctrl = new AGS_ST_ChangeUserDataController_gne();

		// WHEN
		ctrl.cobEditAction();
		Boolean isEdit = ctrl.isCobEdit;

		ctrl.cancelCobEdit();
		Boolean isEditAfterCancel = ctrl.isCobEdit;

		ctrl.cobEditAction();
		String sqText = 'sqText';
		ctrl.cobTxt = sqText;
		ctrl.cobSave();

		// THEN
		GNE_CM_IHCP_User__c ihcpUsr = AGS_ST_DbUtils.getIHCPUser(testUser.Id);
		System.assert(isEdit);
		System.assert(!isEditAfterCancel);
		System.assertEquals(sqText, ihcpUsr.Security_Question_Answer_City_Of_Birth__c);
	}

	/** @date 5/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for edit Sequrity Question City Of Job
	*/
	@isTest static void shouldEditSecurityQuestionCityOfJob() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.getCurrentUser();
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);

		AGS_ST_ChangeUserDataController_gne ctrl = new AGS_ST_ChangeUserDataController_gne();

		// WHEN
		ctrl.cojEditAction();
		Boolean isEdit = ctrl.isCojEdit;

		ctrl.cancelCojEdit();
		Boolean isEditAfterCancel = ctrl.isCojEdit;

		ctrl.cojEditAction();
		String sqText = 'sqText';
		ctrl.cojTxt = sqText;
		ctrl.cojSave();

		// THEN
		GNE_CM_IHCP_User__c ihcpUsr = AGS_ST_DbUtils.getIHCPUser(testUser.Id);
		System.assert(isEdit);
		System.assert(!isEditAfterCancel);
		System.assertEquals(sqText, ihcpUsr.Security_Question_Answer_City_Of_Job__c);
	}
}