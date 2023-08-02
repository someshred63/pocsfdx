/** @date 5/12/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Spends Print Class
*/
@isTest
private class AGS_ST_SpendsPrint_gne_Test {
	
	/** @date 5/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSpends(List<String>) method
	*/
	@isTest static void shouldGetSpendsWithBlankSpendIdsParam() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);

		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);

		System.runAs(testUser) {
			// WHEN
			AGS_ST_SpendsPrint_gne ctrl = new AGS_ST_SpendsPrint_gne();

			// THEN
			System.assertEquals( 0, ctrl.spendIds.size() );
		}
	}

	/** @date 5/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSpends(List<String>) method
	*/
	@isTest static void shouldGetSpendsWithFilledSpendIdsParam() {
		// GIVEN
		AGS_ST_Settings_gne__c agsSettings = AGS_ST_TestUtils.createAgsSetting();

		User testUser = AGS_ST_TestUtils.createUserWithContact('GNE-CM-IHCP-PROFILE');
		AGS_ST_User_gne__c agsUser = AGS_ST_TestUtils.createAgsUser(testUser);

		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = agsUser.Mapped_Account__r.MDMID_gne__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		agsTransaction.Research_Pymt_Typ_Cd_gne__c = 'TEST';
		update agsTransaction;

		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		AGS_ST_Expense_Bookmark__c bookmark = AGS_ST_TestUtils.createExpenseBookmark(agsTransaction.Id);
		
		String formOfPayment = 'Cash or cash equivalent';
		String natureOfPayment = 'Consulting Fee';
		String drugName = 'AVASTIN';
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'Corrected Pending SSR');
		dispute.Form_Of_Payment_gne__c = formOfPayment;
		dispute.Nature_Of_Payment_gne__c = natureOfPayment;
		dispute.Drug_Name_gne__c = drugName;
		update dispute;

		System.runAs(testUser) {
			// WHEN
			ApexPages.currentPage().getParameters().put('spendIds', agsTransaction.Id);
			AGS_ST_SpendsPrint_gne ctrl;
			try{
				ctrl = new AGS_ST_SpendsPrint_gne();
			} catch(Exception ex) {}

			// THEN
			System.assertEquals( null, ctrl );
		}
	}

	/** @date 5/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getHistoryDescription(AGS_ST_DisputeManagement_gne__History) method
	*/
	@isTest static void shouldGetHistoryDescription() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		// WHEN
		AGS_ST_DisputeManagement_gne__History disputeHistoryFieldCreated = AGS_ST_TestUtils.createDisputeHistory(dispute, 'created');
		String histDescFieldCreated = AGS_ST_SpendsPrint_gne.getHistoryDescription(disputeHistoryFieldCreated);

		AGS_ST_DisputeManagement_gne__History disputeHistoryFieldExternalStatus = AGS_ST_TestUtils.createDisputeHistory(dispute, 'External_Status_gne__c');
		String histDescFieldExternalStatus = AGS_ST_SpendsPrint_gne.getHistoryDescription(disputeHistoryFieldExternalStatus);

		AGS_ST_DisputeManagement_gne__History disputeHistoryFieldAmount = AGS_ST_TestUtils.createDisputeHistory(dispute, 'Amount_gne__c');
		String histDescFieldAmount = AGS_ST_SpendsPrint_gne.getHistoryDescription(disputeHistoryFieldAmount);

		// THEN
		System.assert( String.isNotBlank(histDescFieldCreated) );
		System.assert( histDescFieldCreated.contains('Disputed on') );
		System.assert( String.isNotBlank(histDescFieldExternalStatus) );
		System.assert( histDescFieldExternalStatus.contains('Status changed to') );
		System.assertEquals( null, histDescFieldAmount );
	}

	/** @date 5/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getSpendDetails(AGS_Spend_Expense_Transaction_gne__c) method
	*/
	@isTest static void shouldGetSpendDetails() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		agsTransaction.SCh_Category_gne__c = 'APRIMO';
		update agsTransaction;

		// WHEN
		List<String> aprimoLocs = AGS_ST_SpendsPrint_gne.getSpendDetails(agsTransaction);

		agsTransaction.SCh_Category_gne__c = 'iHCP';
		update agsTransaction;
		List<String> ihcpLocs = AGS_ST_SpendsPrint_gne.getSpendDetails(agsTransaction);

		agsTransaction.SCh_Category_gne__c = 'CRO';
		update agsTransaction;
		List<String> croLocs = AGS_ST_SpendsPrint_gne.getSpendDetails(agsTransaction);

		agsTransaction.SCh_Category_gne__c = 'gFRS';
		update agsTransaction;
		List<String> gfrspLocs = AGS_ST_SpendsPrint_gne.getSpendDetails(agsTransaction);

		agsTransaction.SCh_Category_gne__c = 'SFDC';
		update agsTransaction;
		List<String> sfdcLocs = AGS_ST_SpendsPrint_gne.getSpendDetails(agsTransaction);

		// THEN
		System.assertEquals( 4, aprimoLocs.size() );
		System.assertEquals( 4, ihcpLocs.size() );
		System.assertEquals( 2, croLocs.size() );
		System.assertEquals( 2, gfrspLocs.size() );
		System.assertEquals( 2, sfdcLocs.size() );
	}
}