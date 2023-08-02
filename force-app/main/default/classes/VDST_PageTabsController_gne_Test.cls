/** @date 2/11/2014
* @Author Konrad Malinowski
* @description Test Class for Page Tabs Controller
*/
@isTest
private class VDST_PageTabsController_gne_Test {
	
	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for logging as CCO user
	*/
	@isTest static void shouldUserBeCCO() {
		// GIVEN
		User ccoUser = VDST_TestUtils.createUser('GNE-AGS-CCO-Analyst');
		
		System.runAs(ccoUser) {
			// WHEN
			VDST_PageTabsController_gne pageTabsController = new VDST_PageTabsController_gne();

			// THEN
			System.assert( pageTabsController.isCCO );
		}
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for logging as user other than CCO
	*/
	@isTest static void shouldUserNotBeCCO() {
		// GIVEN
		User ccoUser = VDST_TestUtils.createUser('Standard User');
		
		System.runAs(ccoUser) {
			// WHEN
			VDST_PageTabsController_gne pageTabsController = new VDST_PageTabsController_gne();

			// THEN
			System.assert( !pageTabsController.isCCO );
		}
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for going to apex pages
	*/
	@isTest static void shouldGoToPages() {
		// GIVEN
		VDST_PageTabsController_gne pageTabsController = new VDST_PageTabsController_gne();

		// WHEN
		PageReference prEventsList 		= pageTabsController.goToEventList();
		PageReference prLogOut 			= pageTabsController.logOut();
		PageReference prUserManagement 	= pageTabsController.goToUserManagement();
		PageReference prHomePage 		= pageTabsController.goToHomePage();
		PageReference prBatchPage 		= pageTabsController.goToBatchPage();

		// THEN
		System.assertEquals( '/apex/VDST_EventList', 		prEventsList.getUrl() );
		System.assertEquals( '/secur/logout.jsp', 			prLogOut.getUrl() );
		System.assertEquals( '/apex/VDST_Users_Management', prUserManagement.getUrl() );
		System.assertEquals( '/home/home.jsp', 				prHomePage.getUrl() );
		System.assertEquals( '/apex/VDST_FileUpload', 		prBatchPage.getUrl() );

		System.assert( prEventsList.getRedirect() && prLogOut.getRedirect() && prUserManagement.getRedirect() && 
			prHomePage.getRedirect() && prBatchPage.getRedirect() );
	}
}