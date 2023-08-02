/** @date 3/17/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Link Dispute Controller
*/
@isTest
private class AGS_ST_LinkDispute_Controller_gne_Test {
	/** @date 3/17/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for searchHelds() method
    */
    /* HD Decommissioning 
    @isTest static void shouldSearchHelds() {
    	// GIVEN
    	AGS_ST_LinkDispute_Controller_gne ctrl = new AGS_ST_LinkDispute_Controller_gne();
    	ctrl.clearVals();

    	// WHEN
    	ctrl.searchHelds();
    	Boolean srchResFalse = ctrl.srchRes;
		ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

		ctrl.spendName = 'spendName';
		ctrl.firstName = 'firstName';
		ctrl.lastName = 'lastName';
		ctrl.mdmId = 'mdmId';
		ctrl.amountFrom = 0;
		ctrl.amountTo = 0;
		ctrl.searchHelds();
		Boolean srchResTrue = ctrl.srchRes;

    	//THEN
    	System.assert( !srchResFalse );
    	System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('There is no search criteria') );

		System.assert( srchResTrue );
    }
    */

    /** @date 3/17/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for getHeldTrans() method
    */
    /* HD Decommissioning 
    @isTest static void shouldGetSearchHelds() {
    	// GIVEN
    	AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
    	String spendName = heldTransaction.Name;
    	String firstName = 'firstName';
    	String lastName = 'lastName';
    	String mdmId = 'mdmId';
    	Decimal transactionAmount = 5;
    	heldTransaction.RECEIPIENT_NAME_GNE__c = firstName + ' ' + lastName;
    	heldTransaction.MDM_ID_GNE__c = mdmId;
    	heldTransaction.Source_Transaction_Amount_gne__c = transactionAmount;
    	update heldTransaction;

    	AGS_ST_LinkDispute_Controller_gne ctrl = new AGS_ST_LinkDispute_Controller_gne();
    	ctrl.clearVals();

    	// WHEN
    	ctrl.spendName = spendName;
    	ctrl.firstName = firstName;
    	ctrl.mdmId = mdmId;
    	ctrl.amountFrom = transactionAmount - 1;
    	ctrl.amountTo = transactionAmount + 1;
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario1 = ctrl.getHeldTrans();

    	ctrl.clearVals();
    	ctrl.amountTo = transactionAmount + 1;
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario2 = ctrl.getHeldTrans();

    	ctrl.amountFrom = transactionAmount - 1;
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario3 = ctrl.getHeldTrans();
  	
    	ctrl.mdmId = mdmId;
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario4 = ctrl.getHeldTrans();

    	ctrl.clearVals();
    	ctrl.firstName = firstName;
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario5 = ctrl.getHeldTrans();

    	ctrl.clearVals();
    	ctrl.lastName = lastName;
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario6 = ctrl.getHeldTrans();

    	ctrl.spendName = spendName;
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario7 = ctrl.getHeldTrans();

    	ctrl.firstName = firstName;
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario8 = ctrl.getHeldTrans();

    	ctrl.spendName = '';
    	List<AGS_ST_Held_Transaction_gne__c> heldTransScenario9 = ctrl.getHeldTrans();

    	// THEN
    	System.assertEquals( 1, heldTransScenario1.size() );
    	System.assertEquals( 1, heldTransScenario2.size() );
    	System.assertEquals( 1, heldTransScenario3.size() );
    	System.assertEquals( 1, heldTransScenario4.size() );
    	System.assertEquals( 1, heldTransScenario5.size() );
    	System.assertEquals( 1, heldTransScenario6.size() );
    	System.assertEquals( 1, heldTransScenario7.size() );
    	System.assertEquals( 1, heldTransScenario8.size() );
    	System.assertEquals( 1, heldTransScenario9.size() );
    }
    */

    /** @date 3/18/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for linkDispute() method
    */
    /* HD Decommissioning 
    @isTest static void shouldFailLinkDisputeDueToDisputeStatus() {
    	// GIVEN
    	AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = heldTransaction.MDM_ID_GNE__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'Resolved No Correction');
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

		ApexPages.currentPage().getParameters().put('disputeId', dispute.Id);	
    	AGS_ST_LinkDispute_Controller_gne ctrl = new AGS_ST_LinkDispute_Controller_gne();

    	// WHEN
    	ctrl.heldTransId = heldTransaction.Id;
    	ctrl.linkDispute();
    	ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

    	// THEN
    	System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('Dispute cannot be in status') );
    }
    */

    /** @date 3/18/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for linkDispute() method
    */
    /* HD Decommissioning 
    @isTest static void shouldFailLinkDisputeDueToExistingJunction() {
    	// GIVEN
    	AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = heldTransaction.MDM_ID_GNE__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');
		AGS_ST_Held_And_Dispute_Junction_gne__c heldDisputeJunction = AGS_ST_TestUtils.createHeldAndDisputeJunction(heldTransaction, dispute);

		ApexPages.currentPage().getParameters().put('disputeId', dispute.Id);	
    	AGS_ST_LinkDispute_Controller_gne ctrl = new AGS_ST_LinkDispute_Controller_gne();

    	// WHEN
    	ctrl.heldTransId = heldTransaction.Id;
    	ctrl.linkDispute();
    	ApexPages.Message[] apexPageMessages = ApexPages.getMessages();

    	// THEN
    	System.assertEquals( 1, apexPageMessages.size() );
		System.assert( apexPageMessages[0].getSummary().contains('There is already connection') );
    }
    */

    /** @date 3/18/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for linkDispute() method
    */
    /* HD Decommissioning 
    @isTest static void shouldSuccessfullyLinkDispute() {
    	// GIVEN
    	AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();
		AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
		recipient.Name = heldTransaction.MDM_ID_GNE__c;
		update recipient;
		AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
		AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

		ApexPages.currentPage().getParameters().put('disputeId', dispute.Id);	
    	AGS_ST_LinkDispute_Controller_gne ctrl = new AGS_ST_LinkDispute_Controller_gne();

    	// WHEN
    	ctrl.heldTransId = heldTransaction.Id;
    	ctrl.linkDispute();

    	// THEN
    	Integer numberOfExistingJunctions = [SELECT COUNT() FROM AGS_ST_Held_And_Dispute_Junction_gne__c 
    		WHERE AGS_ST_Dispute_Management_gne__c = :dispute.Id AND AGS_ST_Held_Transaction_gne__c = :heldTransaction.Id];
    	System.assertEquals( 1, numberOfExistingJunctions );
    }
    */
}