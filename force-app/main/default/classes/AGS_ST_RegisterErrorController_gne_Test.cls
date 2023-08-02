/** @date 5/6/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Register Error Controller
*/
@isTest
private class AGS_ST_RegisterErrorController_gne_Test {
	
	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters
	*/
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_ST_TestUtils.createCmsObjects();

		String errMsg = 'errMsg';
		ApexPages.currentPage().getParameters().put('errMsg', errMsg);
		AGS_ST_RegisterErrorController_gne ctrl = new AGS_ST_RegisterErrorController_gne();

		// WHEN
		String dyksText = ctrl.didYouKnow;
		AGS_ST_Settings_gne__c stSetting = AGS_ST_RegisterErrorController_gne.stSetting;
		PageReference loginPage = ctrl.goToLoginPage();
		ctrl.refreshWithMsg();

		// THEN
		List<AGS_ST_FAQ_DYK_gne__c> dyks = (List<AGS_ST_FAQ_DYK_gne__c>)JSON.deserialize(
			dyksText, List<AGS_ST_FAQ_DYK_gne__c>.class
		);
		System.assertEquals( 1, dyks.size() );
		System.assertNotEquals( null, stSetting );
		System.assertNotEquals( null, loginPage );
		System.assertEquals( errMsg, ctrl.errMsg );
	}

	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for sendCallRequest() method
	*/
	@isTest static void shouldSuccessfullySendCallRequest() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_ST_TestUtils.createCmsObjects();
		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);

		ApexPages.currentPage().getParameters().put('agsStUserId', agsUser.Id);
		AGS_ST_RegisterErrorController_gne ctrl = new AGS_ST_RegisterErrorController_gne();

		// WHEN
		ctrl.phoneNo = '123456789';
    	ctrl.prefferedDate = '2014-01-01';
    	ctrl.prefferedTime = '12:00';
		ctrl.sendCallRequest();

		// THEN
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('Your request has been sent.') );
	}

	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for sendCallRequest() method
	*/
	@isTest static void shouldFailSendCallRequest() {
		// GIVEN
		AGS_ST_RegisterErrorController_gne ctrl = new AGS_ST_RegisterErrorController_gne();

		// WHEN
		ctrl.sendCallRequest();

		// THEN
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('Your request could not been sent at this time.') );
	}
}