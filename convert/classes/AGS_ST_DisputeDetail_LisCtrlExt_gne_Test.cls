/** @date 3/10/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Dispute Detail Lists Extension Controller
*/
@isTest
private class AGS_ST_DisputeDetail_LisCtrlExt_gne_Test {
	/** @date 3/10/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for controller for retrieving getters
    */
    @isTest static void shouldRetrieveGetters() {
        // GIVEN
        AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
        AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
        AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
        String disputeInternalStatus = 'In Progress';
        AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);

        ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
        AGS_ST_DisputeDetail_ListsCtrlExt_gne ctrlExt = new AGS_ST_DisputeDetail_ListsCtrlExt_gne(standardCtrl);

        // WHEN
        ctrlExt.physicianDisputeUtil.sortField      = 'Internal_Status_gne__c';
        ctrlExt.disputeCollisionUtil.sortField      = 'Internal_Status_gne__c';
        ctrlExt.otherDisputeUtil.sortField          = 'Internal_Status_gne__c';
        ctrlExt.otherDisputeCollisionUtil.sortField = 'Internal_Status_gne__c';
        ctrlExt.physicianDisputeUtil.sortOrder      = 'asc';
        ctrlExt.disputeCollisionUtil.sortOrder      = 'asc';
        ctrlExt.otherDisputeUtil.sortOrder          = 'asc';
        ctrlExt.otherDisputeCollisionUtil.sortOrder = 'asc';
        List<AGS_ST_DMPagingAndSortingUtils.Dispute> physicianDispute =  ctrlExt.getPhysicianDispute(); 
        List<AGS_ST_DMPagingAndSortingUtils.Dispute> modalPhysicianDispute = ctrlExt.getModalPhysicianDispute();
        List<AGS_ST_DMPagingAndSortingUtils.Dispute> otherDisputes = ctrlExt.getOtherDisputes();
        List<AGS_ST_DMPagingAndSortingUtils.Dispute> modalOtherDisputes = ctrlExt.getModalOtherDisputes();

        // THEN
        System.assertEquals( 1, physicianDispute.size() );
        System.assertEquals( 1, modalPhysicianDispute.size() );
        System.assertEquals( 0, otherDisputes.size() );
        System.assertEquals( 0, modalOtherDisputes.size() );
    }
}