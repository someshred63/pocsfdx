/** @date 3/21/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Links Controller
*/
@isTest
private class AGS_ST_Links_Controller_Test {
	/** @date 3/21/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for target_url getter
    */
    @isTest static void shouldGetTargetUrl() {
        // GIVEN
        AGS_ST_TestUtils.createAgsSetting();
        AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
        AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
        AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
        AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

        AGS_ST_Links_Controller ctrl = new AGS_ST_Links_Controller();

        // WHEN
        ctrl.recordId = dispute.Id;
        String target_url = ctrl.target_url;

        // THEN
        System.assert( String.isNotBlank(target_url) );
        System.assertNotEquals( null, dispute.Name );
        System.assertEquals( dispute.Name, ctrl.recordName );
    }
}