/** @date 3/13/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Create Dispute by CCO Controller
*/
@isTest
private class AGS_ST_CreateDisputeByCCO_Ctrl_gne_Test {

	/** @date 3/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters
	*/
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);

		ApexPages.currentPage().getParameters().put('id', agsTransaction.Id);
		AGS_ST_CreateDisputeByCCO_Controller_gne ctrl = new AGS_ST_CreateDisputeByCCO_Controller_gne();
		ctrl.isAlreadyCreated = false;

		// WHEN
		ctrl.amountFromStr = null;
		Decimal amountFromNull = ctrl.amountFrom;
		ctrl.amountFromStr = '1';
		Decimal amountFromOne = ctrl.amountFrom;
		ctrl.amountFromStr = 'invalid';
		Decimal amountFromWrong = ctrl.amountFrom;
		ctrl.amountToStr = null;
		Decimal amountToNull = ctrl.amountTo;
		ctrl.amountToStr = '1';
		Decimal amountToOne = ctrl.amountTo;
		ctrl.amountToStr = 'invalid';
		Decimal amountToWrong = ctrl.amountTo;

		Boolean isMaxDisputes = ctrl.isMaxDisputes;

		List<SelectOption> formsOfPayment = ctrl.getFormsOfPayment();
		List<SelectOption> naturesOfPayment = ctrl.getNaturesOfPayment();
		List<SelectOption> drugNames = ctrl.getDrugNames();
		List<SelectOption> disputeStatus = ctrl.getDisputeStatus();
		List<SelectOption> prefferedCommunicationMethods = ctrl.getPrefferedCommunicationMethods();

		// THEN
		System.assertEquals( null, amountFromNull );
		System.assertEquals( 1, amountFromOne );
		System.assertEquals( -9999999999999.99, amountFromWrong );
		System.assertEquals( null, amountToNull );
		System.assertEquals( 1, amountToOne );
		System.assertEquals( 9999999999999.99, amountToWrong );

		System.assert( !isMaxDisputes );

		System.assertNotEquals( 0, formsOfPayment.size() );
		System.assertNotEquals( 0, naturesOfPayment.size() );
		System.assertNotEquals( 0, drugNames.size() );
		System.assertNotEquals( 0, disputeStatus.size() );
		System.assertNotEquals( 0, prefferedCommunicationMethods.size() );
	}

	/** @date 3/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for searchSpends() method
	*/
	@isTest static void shouldSearchSpends() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);

		ApexPages.currentPage().getParameters().put('id', 'invalidId');
		AGS_ST_CreateDisputeByCCO_Controller_gne ctrl = new AGS_ST_CreateDisputeByCCO_Controller_gne();

		// WHEN
		ctrl.searchSpends();

		// THEN
		System.assertEquals( 1, ctrl.getSpendList().size() );
	}

	/** @date 3/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setDisputeValues() method
	*/
	@isTest static void shouldSuccessfullySetDisputeValuesWithoutInteractions() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		agsTransaction.Form_Of_Payment_gne__c = null;
		agsTransaction.Nature_Of_Payment_gne__c = null;
		update agsTransaction;

		ApexPages.currentPage().getParameters().put('id', agsTransaction.Id);
		AGS_ST_CreateDisputeByCCO_Controller_gne ctrl = new AGS_ST_CreateDisputeByCCO_Controller_gne();

		// WHEN
		ctrl.setDisputeValues();

		// THEN
		System.assertEquals( 'UNCLASSIFIED', ctrl.formValue );
		System.assertEquals( 'UNCLASSIFIED', ctrl.natureValue );
		System.assert( String.isBlank(ctrl.drugValue) );
	}

	/** @date 3/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setDisputeValues() method
	*/
	@isTest static void shouldSuccessfullySetDisputeValuesWithInteractions() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		Decimal allocatedTransactionAmount = 5;
		String formOfPayment = 'Cash or cash equivalent';
		String natureOfPayment = 'Consulting Fee';
		agsTransaction.Allocated_Transaction_Amount_gne__c 	= allocatedTransactionAmount;
		agsTransaction.Form_Of_Payment_gne__c 				= formOfPayment;
		agsTransaction.Nature_Of_Payment_gne__c 			= natureOfPayment;
		update agsTransaction;

		ApexPages.currentPage().getParameters().put('id', agsTransaction.Id);
		AGS_ST_CreateDisputeByCCO_Controller_gne ctrl = new AGS_ST_CreateDisputeByCCO_Controller_gne();

		// WHEN
		ctrl.setDisputeValues();

		// THEN
		System.assertEquals( allocatedTransactionAmount, Decimal.valueOf(ctrl.amountSpend) );
		System.assertEquals( formOfPayment, ctrl.formValue );
		System.assertEquals( natureOfPayment, ctrl.natureValue );
		System.assert( String.isNotBlank(ctrl.drugValue) );
	}

	/** @date 3/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveNewDispute() method
	*/
	@isTest static void shouldFailSaveNewDispute() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		agsTransaction.Allocated_Transaction_Amount_gne__c 	= 5;
		agsTransaction.Form_Of_Payment_gne__c 				= 'Cash or cash equivalent';
		agsTransaction.Nature_Of_Payment_gne__c 			= 'Consulting Fee';
		update agsTransaction;

		AGS_ST_CreateDisputeByCCO_Controller_gne ctrl = new AGS_ST_CreateDisputeByCCO_Controller_gne();
		ctrl.setDisputeValues();
		ctrl.internalDispute 	= 'true';
		ctrl.preferredMethod 	= 'Email';
        ctrl.preferredValue 	= 'invalidEmail';

		// WHEN
		ctrl.saveNewDispute();

		// THEN
		System.assert( String.isNotBlank(ctrl.actionMessages) );
		System.assert( ctrl.actionMessages.contains('Dispute has NOT been created') );
	}


	/** @date 3/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for saveNewDispute() method
	*/
	@isTest static void shouldSuccessfullySaveNewDispute() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		agsTransaction.Allocated_Transaction_Amount_gne__c 	= 5;
		agsTransaction.Form_Of_Payment_gne__c 				= null;
		agsTransaction.Nature_Of_Payment_gne__c 			= null;
		update agsTransaction;

		ApexPages.currentPage().getParameters().put('id', agsTransaction.Id);
		AGS_ST_CreateDisputeByCCO_Controller_gne ctrl = new AGS_ST_CreateDisputeByCCO_Controller_gne();
		ctrl.setDisputeValues();
		ctrl.internalDispute 	= 'false';
		ctrl.preferredMethod 	= 'Email';
        ctrl.preferredValue 	= 'invalidEmail';
        ctrl.drugValue 			= 'otherDrugValue';
        ctrl.amountSpend 		= '6';
        ctrl.formValue 			= 'otherFormValue';
        ctrl.natureValue 		= 'otherNatureValue';
        ctrl.explanation		= 'explanation';
        ctrl.isCmsDispute 		= true;
        ctrl.isCmsDisputeOnChange();
        ctrl.cmsDisputeId 		= 'uniqueCmsDisputeId';
        Boolean isCmsDisputeIdUnique = AGS_ST_CreateDisputeByCCO_Controller_gne.isCmsDisputeIdUnique(ctrl.cmsDisputeId);
        // WHEN
        Test.startTest();
        ctrl.saveNewDispute();
        Test.stopTest();
        // THEN
        final Integer disputeIdIdx = ctrl.actionMessages.indexOf('?id=');
        final String disputeId = disputeIdIdx < 0 || disputeIdIdx + 18 > ctrl.actionMessages.length() ?
            null : ctrl.actionMessages.mid(disputeIdIdx + 4, 18);
        final AGS_ST_DisputeManagement_gne__c[] actualDisputes = disputeId == null ? new AGS_ST_DisputeManagement_gne__c[]{ } : [
            SELECT Attendees_gne__c, Attendees_Indicator_gne__c
            FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :disputeId LIMIT 1
        ];
		System.assert(isCmsDisputeIdUnique);
		System.assert( String.isNotBlank(ctrl.actionMessages) );
		System.assert( ctrl.actionMessages.contains('New dispute') && ctrl.actionMessages.contains('has been created') );
		System.assertEquals(1, actualDisputes.size(), actualDisputes);
		System.assertEquals(null, actualDisputes[0].Attendees_gne__c, actualDisputes);
		System.assertEquals('false', actualDisputes[0].Attendees_Indicator_gne__c, actualDisputes);
	}
}