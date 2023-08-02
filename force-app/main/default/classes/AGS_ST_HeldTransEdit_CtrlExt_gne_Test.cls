/** @date 3/11/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Held Transaction Extension Controller
*/
@isTest
private class AGS_ST_HeldTransEdit_CtrlExt_gne_Test {

	/** @date 3/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters
	*/
	/* HD Decommissioning
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		dispute.AGS_ST_Held_Transaction__c = heldTransaction.Id;
		update dispute;

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);

		// WHEN
		Boolean isMaxDisputes = ctrlExt.isMaxDisputes;
		List<AGS_ST_DisputeManagement_gne__c> disputes = ctrlExt.gethtDMList();
		List<SelectOption> formsOfPayment = ctrlExt.getFormsOfPayment();
		List<SelectOption> naturesOfPayment = ctrlExt.getNaturesOfPayment();
		List<SelectOption> drugNames = ctrlExt.getDrugNames();
		List<SelectOption> disputeStatuses = ctrlExt.getDisputeStatuses();
		List<SelectOption> heldTransactionStatusList = ctrlExt.getHeldTransactionStatusList();
		List<AGS_ST_Held_Transaction_gne__c> heldList = ctrlExt.getHeldList();
		List<AGS_ST_HeldTransactionEdit_CtrlExt_gne.DisputeWrapper> disputeList = ctrlExt.getDisputeList();

		ctrlExt.showCreatingForm();
		Boolean showCreationForm = ctrlExt.showCreationForm;

		ctrlExt.amountFromStr = null;
		Decimal amountFromNull = ctrlExt.amountFrom;
		ctrlExt.amountFromStr = '1';
		Decimal amountFromOne = ctrlExt.amountFrom;
		ctrlExt.amountFromStr = 'invalid';
		Decimal amountFromWrong = ctrlExt.amountFrom;
		ctrlExt.amountToStr = null;
		Decimal amountToNull = ctrlExt.amountTo;
		ctrlExt.amountToStr = '1';
		Decimal amountToOne = ctrlExt.amountTo;
		ctrlExt.amountToStr = 'invalid';
		Decimal amountToWrong = ctrlExt.amountTo;

		// THEN
		System.assert( !isMaxDisputes );
		System.assertEquals( 1, disputes.size() );
		System.assertNotEquals( 0, formsOfPayment.size() );
		System.assertNotEquals( 0, naturesOfPayment.size() );
		System.assertEquals( 3, drugNames.size() );
		System.assertNotEquals( 0, disputeStatuses.size() );
		System.assertNotEquals( 0, heldTransactionStatusList.size() );
		System.assertEquals( 1, heldList.size() );

		System.assert(showCreationForm);

		System.assertEquals( null, amountFromNull );
		System.assertEquals( 1, amountFromOne );
		System.assertEquals( -9999999999999.99, amountFromWrong );
		System.assertEquals( null, amountToNull );
		System.assertEquals( 1, amountToOne );
		System.assertEquals( 9999999999999.99, amountToWrong );
	}
	*/

	/** @date 3/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for createHTDispute() method
	*/
	/* HD Decommissioning
	@isTest static void shouldCreateHTDispute() {
		// GIVEN
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);

		// WHEN
		ctrlExt.dmWrapper.AGS_Spend_Expense_Transaction_gne__c = agsTransaction.Id;
		ctrlExt.createHTDispute();

		// THEN
		System.assertEquals( 1, [SELECT Id FROM AGS_ST_DisputeManagement_gne__c].size() );
		System.assertEquals( 'Dispute for Held Transaction has been created.', ctrlExt.actionMessages );
	}
	*/

	/** @date 3/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for linkDisputeToHeldTransaction() method
	*/
	/* HD Decommissioning
	@isTest static void shouldFailLinkDisputeToHeldTransactionDueToNoDispute() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);

		// WHEN
		ctrlExt.linkDisputeToHeldTransaction();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('Please fill correct dispute value') );
	}
	*/

	/** @date 3/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for linkDisputeToHeldTransaction() method
	*/
	/* HD Decommissioning
	@isTest static void shouldFailLinkDisputeToHeldTransactionDueToResolvedDispute() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'Resolved No Correction');

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);
		ctrlExt.disputeHolder.AGS_ST_Dispute_Management_gne__c = dispute.Id;

		// WHEN
		ctrlExt.linkDisputeToHeldTransaction();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('Cannot link disputes with status Resolved') );
	}
	*/

	/** @date 3/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for linkDisputeToHeldTransaction() method
	*/
	/* HD Decommissioning
	@isTest static void shouldFailLinkDisputeToHeldTransactionDueToExistingJunction() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);
		ctrlExt.disputeHolder.AGS_ST_Dispute_Management_gne__c = dispute.Id;
		ctrlExt.disputeListHolder.add( new AGS_ST_HeldTransactionEdit_CtrlExt_gne.DisputeWrapper(heldDisputeJunction) );

		// WHEN
		ctrlExt.linkDisputeToHeldTransaction();
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		// THEN
		System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('That relation allready exist') );
	}
	*/

	/** @date 3/11/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for linkDisputeToHeldTransaction() method
	*/
	/* HD Decommissioning
	@isTest static void shouldSuccessfullyLinkDisputeToHeldTransaction() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);
		ctrlExt.disputeHolder.AGS_ST_Dispute_Management_gne__c = dispute.Id;

		// WHEN
		ctrlExt.linkDisputeToHeldTransaction();

		// THEN
		System.assert( String.isNotBlank(ctrlExt.actionMessages) );
		System.assert( ctrlExt.actionMessages.contains('Dispute has been linked to this Held Transaction') );
		System.assertEquals( 1, [SELECT Id FROM AGS_ST_Held_And_Dispute_Junction_gne__c
			WHERE AGS_ST_Held_Transaction_gne__c = :heldTransaction.Id AND AGS_ST_Dispute_Management_gne__c = :dispute.Id].size() );
	}
	*/

	/** @date 3/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for unlinkDisputesFromHeldTransaction() method
	*/
	/* HD Decommissioning
	@isTest static void shouldFailUnlinkDisputeFromHeldTransaction() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);

		// WHEN
		ctrlExt.unlinkDisputesFromHeldTransaction();

		// THEN
		System.assert( String.isBlank(ctrlExt.actionMessages) );
	}
	*/

	/** @date 3/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for unlinkDisputesFromHeldTransaction() method
	*/
	/* HD Decommissioning
	@isTest static void shouldSuccessfullyUnlinkDisputeFromHeldTransaction() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);
		ctrlExt.disputeHolder.AGS_ST_Dispute_Management_gne__c = dispute.Id;
		ctrlExt.linkDisputeToHeldTransaction();
		System.assertEquals( 1, ctrlExt.disputeListHolder.size() );
		ctrlExt.disputeListHolder[0].selectedDispute = true;

		// WHEN
		ctrlExt.unlinkDisputesFromHeldTransaction();

		// THEN
		System.assert( String.isNotBlank(ctrlExt.actionMessages) );
		System.assert( ctrlExt.actionMessages.contains('Dispute has been unlinked from this Held Transaction') );
		System.assertEquals( 0, [SELECT COUNT() FROM AGS_ST_Held_And_Dispute_Junction_gne__c
			WHERE AGS_ST_Held_Transaction_gne__c = :heldTransaction.Id AND AGS_ST_Dispute_Management_gne__c = :dispute.Id] );
	}
	*/

	/** @date 3/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for searchSpends() method
	*/
	/* HD Decommissioning
	@isTest static void shouldSearchSpends() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);

		// WHEN
		ctrlExt.searchSpends();
		List<AGS_Spend_Expense_Transaction_gne__c> spendList = ctrlExt.getSpendList();

		// THEN
		System.assertEquals( 1, spendList.size() );
	}
	*/

	/** @date 3/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for selectDispute() method
	*/
	/* HD Decommissioning
	@isTest static void shouldSelectDisputeWithoutInteractions() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		agsTransaction.Form_Of_Payment_gne__c = null;
		agsTransaction.Nature_Of_Payment_gne__c = null;
		update agsTransaction;
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);
		ctrlExt.setId = agsTransaction.Id;

		// WHEN
		ctrlExt.selectDispute();

		// THEN
		System.assertEquals( '1', ctrlExt.attendeesValue );
		System.assert(ctrlExt.isAttendeeDisabled );
		System.assertEquals( 'UNCLASSIFIED', ctrlExt.formValue );
		System.assertEquals( 'UNCLASSIFIED', ctrlExt.natureValue );
		System.assert( String.isBlank(ctrlExt.drugValue) );
	}
	*/

	/** @date 3/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for selectDispute() method
	*/
	/* HD Decommissioning
	@isTest static void shouldSelectDisputeWithInteractions() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);

		Integer eventActualAttendeeCount = 5;
		String formOfPayment = 'Cash or cash equivalent';
		String natureOfPayment = 'Consulting Fee';
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		agsTransaction.Source_System_Code_gne__c 			= 'CRO';
		agsTransaction.Event_Actual_Attendee_Count_gne__c 	= eventActualAttendeeCount;
		agsTransaction.Form_Of_Payment_gne__c 				= formOfPayment;
		agsTransaction.Nature_Of_Payment_gne__c 			= natureOfPayment;
		update agsTransaction;

		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);
		ctrlExt.setId = agsTransaction.Id;

		// WHEN
		ctrlExt.selectDispute();

		// THEN
		System.assertEquals( String.valueOf(eventActualAttendeeCount), ctrlExt.attendeesValue );
		System.assertEquals( formOfPayment, ctrlExt.formValue );
		System.assertEquals( natureOfPayment, ctrlExt.natureValue );
		System.assert( String.isNotBlank(ctrlExt.drugValue) );
	}
	*/

	/** @date 3/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for createDispute() method
	*/
	/* HD Decommissioning
	@isTest static void shouldCreateDispute() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);

		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		List<AGS_Brand_gne__c> drugs = AGS_ST_TestUtils.createBrands();
		List<AGS_Expense_Products_Interaction__c> productsInteractions = AGS_ST_TestUtils.createExpenseProductsInteractions(drugs, agsTransaction.Id);
		agsTransaction.Source_System_Code_gne__c 			= 'CRO';
		agsTransaction.Event_Actual_Attendee_Count_gne__c 	= 5;
		agsTransaction.Form_Of_Payment_gne__c 				= 'Cash or cash equivalent';
		agsTransaction.Nature_Of_Payment_gne__c 			= 'Consulting Fee';
		update agsTransaction;

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);
		ctrlExt.setId = agsTransaction.Id;
		ctrlExt.disputeStatus = 'Resolved No Correction';
		ctrlExt.doNotReport = true;
		ctrlExt.selectDispute();

		// WHEN
		ctrlExt.createDispute();

		// THEN
		System.assertEquals( 1, [SELECT COUNT() FROM AGS_ST_DisputeManagement_gne__c] );
	}
	*/

	/** @date 3/12/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeStatus() method
	*/
	/* HD Decommissioning
	@isTest static void shouldChangeStatus() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);

		ApexPages.StandardController standardCtrl = new ApexPages.StandardController(heldTransaction);
		AGS_ST_HeldTransactionEdit_CtrlExt_gne ctrlExt = new AGS_ST_HeldTransactionEdit_CtrlExt_gne(standardCtrl);
		String newStatus = 'Cancel Processing';
		ctrlExt.statusValue = newStatus;

		// WHEN
		ctrlExt.changeStatus();

		// THEN
		System.assertEquals( newStatus, [SELECT Held_Transaction_Process_Status_Code_gne__c
			FROM AGS_ST_Held_Transaction_gne__c WHERE Id = :heldTransaction.Id LIMIT 1].Held_Transaction_Process_Status_Code_gne__c );
	}
	*/
}