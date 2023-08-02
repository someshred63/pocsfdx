/** @date 3/20/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Held Transaction Controller
*/
@isTest
private class AGS_ST_HeldTransaction_Ctrl_gne_Test {
	/** @date 3/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for getHeldTransactionStatusList() method
	*/
	/* HD Decommissioning
	@isTest static void shouldRetrieveGetters() {
		// GIVEN
		AGS_ST_HeldTransaction_Controller_gne ctrl = new AGS_ST_HeldTransaction_Controller_gne();

		// WHEN
		List<SelectOption> heldTransactionStatusList = ctrl.getHeldTransactionStatusList();

		// THEN
		System.assertEquals( 2, heldTransactionStatusList.size() );
	}
	*/

	/** @date 3/20/2014
	* @Author Konrad Malinowski
	* @description Test Method - Test for changeStatus() method
	*/
	/* HD Decommissioning
	@isTest static void shouldFailChangeStatus() {
		// GIVEN
		AGS_ST_Held_Transaction_gne__c heldTransaction = AGS_ST_TestUtils.createHeldTransaction();

		AGS_ST_HeldTransaction_Controller_gne ctrl = new AGS_ST_HeldTransaction_Controller_gne();

		// WHEN

		// fail with 'Ok to Process' status
		ApexPages.currentPage().getParameters().put('recordIds', heldTransaction.Id);
		PageReference failDueToOkToProcessStatus = ctrl.changeStatus();

		// fail with 'No Longer Valid' status
		update new AGS_ST_Held_Transaction_gne__c( Id = heldTransaction.Id, Held_Transaction_Process_Status_Code_gne__c = 'No Longer Valid' );
		PageReference failDueToNoLongerValidStatus = ctrl.changeStatus();

        // success with 'Cancel Processing' status
        String newStatus = 'No Longer Valid';
        ctrl.statusValue = newStatus;
        update new AGS_ST_Held_Transaction_gne__c( Id = heldTransaction.Id, Held_Transaction_Process_Status_Code_gne__c = 'Cancel Processing' );
        PageReference successStatusChange = ctrl.changeStatus();

		// THEN
		System.assertEquals( null, failDueToOkToProcessStatus );
		System.assertEquals( null, failDueToNoLongerValidStatus );
        System.assertEquals( newStatus, [SELECT Held_Transaction_Process_Status_Code_gne__c FROM AGS_ST_Held_Transaction_gne__c 
            WHERE Id = :heldTransaction.Id LIMIT 1].Held_Transaction_Process_Status_Code_gne__c );
        System.assertNotEquals( null, successStatusChange );
        System.assert( String.isNotBlank( successStatusChange.getUrl() ) );
	}
	*/

    /** @date 3/21/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for cancelAction() method
    */
    /* HD Decommissioning
    @isTest static void shouldCancelAction() {
        // GIVEN
        ApexPages.currentPage().getParameters().put('pr',       'pr'        );
        ApexPages.currentPage().getParameters().put('event',    'event'     );
        ApexPages.currentPage().getParameters().put('set',      'set'       );
        ApexPages.currentPage().getParameters().put('dispute',  'dispute'   );
        AGS_ST_HeldTransaction_Controller_gne ctrl = new AGS_ST_HeldTransaction_Controller_gne();

        // WHEN
        PageReference cancelPage = ctrl.cancelAction();

        // THEN
        System.assertNotEquals( null, cancelPage );
        System.assert( String.isNotBlank( cancelPage.getUrl() ) );
    }
    */
}