/** @date 5/5/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Contact Us Class
*/
@isTest
private class AGS_ST_ContactUs_gne_Test {
	
	/** @date 5/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for sendContactUsEmail() method
	*/
	@isTest static void shouldSuccessfullySendContactUsEmail() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);

		System.runAs(testUser) {
			AGS_ST_ContactUs_gne ctrl = new AGS_ST_ContactUs_gne();
			ctrl.hcpName = 'HCP Name';
			ctrl.hcpEmailAddress = 'test@gmail.com';
			ctrl.emailSubject = 'Email Subject';
			ctrl.emailBody = 'Email Body';

			// WHEN
			ctrl.sendContactUsEmail();

			// THEN
			System.assert(ctrl.inPortal);
			
			ApexPages.Message[] apexPageMessages = ApexPages.getMessages();
			System.assertEquals( 1, apexPageMessages.size() );
			System.assert( apexPageMessages[0].getSummary().contains('Thank you. Your message has been sent.') );
		}
	}

	/** @date 5/5/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for sendContactUsEmail() method
	*/
	@isTest static void shouldFailSendContactUsEmail() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		User testUser = AGS_ST_TestUtils.createUser('System Administrator');
		
		System.runAs(testUser) {
			AGS_ST_ContactUs_gne ctrl = new AGS_ST_ContactUs_gne();

			// WHEN
			ctrl.sendContactUsEmail();

			// THEN
			System.assert(!ctrl.inPortal);
			
			ApexPages.Message[] apexPageMessages = ApexPages.getMessages();
			System.assertEquals( 1, apexPageMessages.size() );
			System.assert( apexPageMessages[0].getSummary().contains('There is an unexpected error.') );
		}
	}
}