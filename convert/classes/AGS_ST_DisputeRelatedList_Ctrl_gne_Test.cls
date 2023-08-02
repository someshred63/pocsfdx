/** @date 3/13/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Dispute Related List Controller
*/
@isTest
private class AGS_ST_DisputeRelatedList_Ctrl_gne_Test {
	/** @date 3/13/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for retrieving getters
	*/
	/* HD Decommissioning
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');
  		System.runAs(ccoAnalyst) {
  			AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
			AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
			recipient.Name = heldTransaction.MDM_ID_GNE__c;
			update recipient;
			AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
			AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
			AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
			AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

			AGS_ST_Held_Transaction_gne__c heldTransactionSecond = AGS_ST_TestUtils.createHeldTransaction();
			heldTransactionSecond.MDM_ID_GNE__c = 'Other MDM_ID';
			update heldTransactionSecond;
			AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunctionSecond = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransactionSecond, dispute);

			ApexPages.currentPage().getParameters().put('pr'		, recipient.Id);
	        ApexPages.currentPage().getParameters().put('event'		, agsTransaction.Event_ID_gne__c);
	        ApexPages.currentPage().getParameters().put('set'		, '');
	        ApexPages.currentPage().getParameters().put('dispute'	, dispute.Id);
	        ApexPages.currentPage().getParameters().put('com'		, '2');
	        AGS_ST_DisputeRelatedList_Controller_gne ctrl = new AGS_ST_DisputeRelatedList_Controller_gne();

			// WHEN
			Boolean isCorrectableUser = ctrl.isCorrectableUser;
			Boolean isCCOUser = ctrl.isCCOUser;
			List<SelectOption> heldTransactionStatusList = ctrl.getHeldTransactionStatusList();
			List<AGS_Spend_Expense_Transaction_gne__c> expenseList  = ctrl.getExpenseList();
			List<AGS_ST_DisputeRelatedList_Controller_gne.HeldTransactionContainer> directRelatedHTList = ctrl.getDirectRelatedHTList();
			List<AGS_ST_DisputeRelatedList_Controller_gne.HeldTransactionContainer> indirectRelatedHTList = ctrl.getIndirectRelatedHTList();
			List<AGS_ST_Held_And_Dispute_Junction_gne__c> historicalHTList  = ctrl.getHistoricalHTList();

			// THEN
			System.assert( isCorrectableUser );
			System.assert( isCCOUser );
			System.assertEquals( 2, heldTransactionStatusList.size() );
			System.assertEquals( 1, expenseList.size() );
			System.assertEquals( 1, directRelatedHTList.size() );
			System.assertEquals( 1, indirectRelatedHTList.size() );
  		}
	}
	*/

	/** @date 3/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeStatus() method
	*/
	/* HD Decommissioning
	@isTest static void shouldChangeStatus() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = heldTransaction.MDM_ID_GNE__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

		AGS_ST_Held_Transaction_gne__c heldTransactionSecond = AGS_ST_TestUtils.createHeldTransaction();
		heldTransactionSecond.MDM_ID_GNE__c = 'Other MDM_ID';
		update heldTransactionSecond;
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunctionSecond = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransactionSecond, dispute);

		ApexPages.currentPage().getParameters().put('pr'		, recipient.Id);
        ApexPages.currentPage().getParameters().put('event'		, agsTransaction.Event_ID_gne__c);
        ApexPages.currentPage().getParameters().put('set'		, '');
        ApexPages.currentPage().getParameters().put('dispute'	, dispute.Id);
        ApexPages.currentPage().getParameters().put('com'		, '2');
        AGS_ST_DisputeRelatedList_Controller_gne ctrl = new AGS_ST_DisputeRelatedList_Controller_gne();
        System.assertEquals( 1, ctrl.directRelatedHeldList.size() );
        System.assertEquals( 1, ctrl.indirectRelatedHeldList.size() );
		ctrl.directRelatedHeldList.get(0).isSelected = true;
		ctrl.indirectRelatedHeldList.get(0).isSelected = true;

		// WHEN
		ctrl.changeStatus();

		// THEN
		List<Id> selectedHeldTransactionIds = ctrl.selectedIds;
		System.assertEquals( 2, selectedHeldTransactionIds.size() );
	}
	*/

	/** @date 3/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeAllStatus() method
	*/
	/* HD Decommissioning
	@isTest static void shouldChangeAllStatus() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = heldTransaction.MDM_ID_GNE__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

		AGS_ST_Held_Transaction_gne__c heldTransactionSecond = AGS_ST_TestUtils.createHeldTransaction();
		heldTransactionSecond.MDM_ID_GNE__c = 'Other MDM_ID';
		update heldTransactionSecond;
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunctionSecond = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransactionSecond, dispute);

		ApexPages.currentPage().getParameters().put('pr'		, recipient.Id);
        ApexPages.currentPage().getParameters().put('event'		, agsTransaction.Event_ID_gne__c);
        ApexPages.currentPage().getParameters().put('set'		, '');
        ApexPages.currentPage().getParameters().put('dispute'	, dispute.Id);
        ApexPages.currentPage().getParameters().put('com'		, '2');
        AGS_ST_DisputeRelatedList_Controller_gne ctrl = new AGS_ST_DisputeRelatedList_Controller_gne();

		// WHEN
		ctrl.changeAllStatus();

		// THEN
		List<Id> selectedHeldTransactionIds = ctrl.selectedIds;
		System.assertEquals( 2, selectedHeldTransactionIds.size() );
	}
	*/

	/** @date 3/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for confirmStatusChange() method
	*/
	/* HD Decommissioning
	@isTest static void shouldConfirmStatusChange() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = heldTransaction.MDM_ID_GNE__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

		ApexPages.currentPage().getParameters().put('pr'		, recipient.Id);
        ApexPages.currentPage().getParameters().put('event'		, agsTransaction.Event_ID_gne__c);
        ApexPages.currentPage().getParameters().put('set'		, '');
        ApexPages.currentPage().getParameters().put('dispute'	, dispute.Id);
        ApexPages.currentPage().getParameters().put('com'		, '2');
        AGS_ST_DisputeRelatedList_Controller_gne ctrl = new AGS_ST_DisputeRelatedList_Controller_gne();
        System.assertEquals( 1, ctrl.directRelatedHeldList.size() );
        System.assertEquals( 'Ok to Process', ctrl.directRelatedHeldList.get(0).heldTransaction.AGS_ST_Held_Transaction_gne__r.Held_Transaction_Process_Status_Code_gne__c );
		ctrl.directRelatedHeldList.get(0).isSelected = true;
		String heldStatus = 'Cancel Processing';
		ctrl.statusValue = heldStatus;
		ctrl.changeStatus();

		// WHEN
		ctrl.confirmStatusChange();

		// THEN
		System.assertEquals( 1, ctrl.directRelatedHeldList.size() );
        System.assertEquals( heldStatus, ctrl.directRelatedHeldList.get(0).heldTransaction.AGS_ST_Held_Transaction_gne__r.Held_Transaction_Process_Status_Code_gne__c );
	}
	*/

	/** @date 3/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for cancelAction() method
	*/
	/* HD Decommissioning
	@isTest static void shouldCancelAction() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = heldTransaction.MDM_ID_GNE__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

		AGS_ST_Held_Transaction_gne__c heldTransactionSecond = AGS_ST_TestUtils.createHeldTransaction();
		heldTransactionSecond.MDM_ID_GNE__c = 'Other MDM_ID';
		update heldTransactionSecond;
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunctionSecond = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransactionSecond, dispute);

		ApexPages.currentPage().getParameters().put('pr'		, recipient.Id);
        ApexPages.currentPage().getParameters().put('event'		, agsTransaction.Event_ID_gne__c);
        ApexPages.currentPage().getParameters().put('set'		, '');
        ApexPages.currentPage().getParameters().put('dispute'	, dispute.Id);
        ApexPages.currentPage().getParameters().put('com'		, '2');
        AGS_ST_DisputeRelatedList_Controller_gne ctrl = new AGS_ST_DisputeRelatedList_Controller_gne();
        ctrl.changeAllStatus();
        System.assertEquals( 2, ctrl.selectedIds.size() );

		// WHEN
		ctrl.cancelAction();

		// THEN
		System.assertEquals( 0, ctrl.selectedIds.size() );
	}
	*/

	/** @date 3/17/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for setHistorical() method
	*/
	/* HD Decommissioning
	@isTest static void shouldSetHistorical() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		heldTransaction.Held_Transaction_Process_Status_Code_gne__c = 'No Longer Valid';
		update heldTransaction;
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = heldTransaction.MDM_ID_GNE__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

		ApexPages.currentPage().getParameters().put('pr'		, recipient.Id);
        ApexPages.currentPage().getParameters().put('event'		, agsTransaction.Event_ID_gne__c);
        ApexPages.currentPage().getParameters().put('set'		, '');
        ApexPages.currentPage().getParameters().put('dispute'	, dispute.Id);
        ApexPages.currentPage().getParameters().put('com'		, '2');
        AGS_ST_DisputeRelatedList_Controller_gne ctrl = new AGS_ST_DisputeRelatedList_Controller_gne();
        ctrl.disputeManId = dispute.Id;
        ctrl.heldKey = heldTransaction.SRC_EXP_KEY_GNE__c;

		// WHEN
		ctrl.setHistorical();

		// THEN
		System.assertEquals( 1, ctrl.historicalHeldList.size() );
	}
	*/
}