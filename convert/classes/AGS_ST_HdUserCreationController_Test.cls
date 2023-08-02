/** @date 5/6/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Hd User Creation Controller
*/
@isTest
private class AGS_ST_HdUserCreationController_Test {
	
	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for finishUserCreation() method
	*/
	@isTest static void shouldFinishUserCreationIhcpUserExists() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);

		ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
        ApexPages.currentPage().getParameters().put('usr', testUser.Id);
		AGS_ST_HdUserCreationController ctrl = new AGS_ST_HdUserCreationController();

		// WHEN
		PageReference resultPage = ctrl.finishUserCreation();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for finishUserCreation() method
	*/
	@isTest static void shouldFinishUserCreationIhcpUserDoesNotExist() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);

		ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
        ApexPages.currentPage().getParameters().put('usr', testUser.Id);
		AGS_ST_HdUserCreationController ctrl = new AGS_ST_HdUserCreationController();

		// WHEN
		PageReference resultPage = ctrl.finishUserCreation();

		// THEN
		System.assertNotEquals( null, resultPage );
	}

	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for finishUserCreation() method
	*/
	@isTest static void shouldFinishUserCreationIhcpUserApproved() {
		// GIVEN
		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);
		GNE_CM_IHCP_User__c ihcpUser = AGS_ST_TestUtils.createIhcpUser(testUser);
		ihcpUser.AGS_ST_Status__c = 'Approved';
		update ihcpUser;

		ApexPages.currentPage().getParameters().put('agsstuserid', agsUser.Id);
        ApexPages.currentPage().getParameters().put('usr', testUser.Id);
		AGS_ST_HdUserCreationController ctrl = new AGS_ST_HdUserCreationController();

		// WHEN
		PageReference resultPage = ctrl.finishUserCreation();

		// THEN
		System.assertEquals( null, resultPage );
	}

	/** @date 5/6/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for finishUserCreation() method
	*/
	@isTest static void shouldFailFinishUserCreationDueToNoApexPageParameters() {
		// GIVEN
		AGS_ST_HdUserCreationController ctrl = new AGS_ST_HdUserCreationController();

		// WHEN
		PageReference resultPage = ctrl.finishUserCreation();

		// THEN
		System.assertEquals( null, resultPage );
	}
}