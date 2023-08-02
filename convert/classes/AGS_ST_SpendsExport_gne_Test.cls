/** @date 5/12/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Spends Export Class
*/
@isTest
private class AGS_ST_SpendsExport_gne_Test {
	
	/** @date 5/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for initiating class instance
	*/
	@isTest static void shouldInitiateClassInstanceNonResearch() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);

		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);

		System.runAs(testUser) {
			AGS_ST_SpendsExport_gne ctrl = new AGS_ST_SpendsExport_gne();

			// WHEN
			ctrl.spendIds.add(agsTransaction.Id);
			ctrl.init();
			Boolean showResearch = ctrl.showResearch;

			// THEN
			System.assert( !showResearch );
		}
	}

	/** @date 5/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for initiating class instance
	*/
	@isTest static void shouldInitiateClassInstanceResearch() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient, true);

		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);

		System.runAs(testUser) {
			ApexPages.currentPage().getParameters().put('spendIds', agsTransaction.Id);
			ApexPages.currentPage().getParameters().put('spendtype', 'research');
			AGS_ST_SpendsExport_gne ctrl = new AGS_ST_SpendsExport_gne();
			
			// WHEN
			ctrl.spendIds.add(agsTransaction.Id);
			ctrl.init();
			Boolean showResearch = ctrl.showResearch;

			// THEN
			System.assert( showResearch );
		}
	}
}