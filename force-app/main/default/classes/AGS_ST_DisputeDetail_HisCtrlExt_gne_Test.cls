/** @date 3/10/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Dispute Detail History Extension Controller
*/
@isTest
private class AGS_ST_DisputeDetail_HisCtrlExt_gne_Test {
	/** @date 3/10/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for getDisputeHistoryList() method
    */
    @isTest static void shouldGetDisputeHistoryList() {
         // GIVEN
        AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
        AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
        AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
        String disputeInternalStatus = 'In Progress';
        AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);

        User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');

        update new AGS_ST_DisputeResolver_gne__c(Id = dispute.Dispute_Resolver_gne__c, OwnerId = ccoAnalyst.Id);
        String newDisputeInternalStatus = 'Submitted';
        update new AGS_ST_DisputeManagement_gne__c(Id = dispute.Id, Internal_Status_gne__c = newDisputeInternalStatus);

        ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
        AGS_ST_DisputeDetail_HistoryCtrlExt_gne ctrlExt = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne(standardCtrl);

        // WHEN
        List<AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValueBase> disputeHistoryList = ctrlExt.getDisputeHistoryList();

        // THEN
        System.assertNotEquals( 0, disputeHistoryList.size() );
    }

	/** @date 3/10/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for HistoryValue class
    */
    @isTest static void shouldTestHistoryValueClass() {
        // GIVEN
        AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
        AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
        AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
        String disputeInternalStatus = 'In Progress';
        AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);

        AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue dmH = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue(
            createHistorySobject('AGS_ST_DisputeManagement_gne__History', dispute.Id, 'Internal_Status_gne__c'), false, 'AGS_ST_DisputeManagement_gne__History' );
        AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue drH = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue(
            createHistorySobject('AGS_ST_DisputeResolver_gne__History', dispute.Dispute_Resolver_gne__c, 'Owner'), false, 'AGS_ST_DisputeResolver_gne__History' );
		AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue dlH = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue(
            createHistorySobject('AGS_ST_Dispute_List_gne__History', dispute.Dispute_Resolver_gne__c, 'IsCmsDispute_gne__c'), false, 'AGS_ST_Dispute_List_gne__History' );

        AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue dmHOwner = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue(
            createHistorySobject('AGS_ST_DisputeManagement_gne__History', dispute.Id, 'Owner'), false, 'AGS_ST_DisputeManagement_gne__History' );
        AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue dmHIsPrivate = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue(
            createHistorySobject('AGS_ST_DisputeManagement_gne__History', dispute.Id, 'isPrivate__c'), false, 'AGS_ST_DisputeManagement_gne__History' );
        AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue dmHHeldTransaction = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue(
            createHistorySobject('AGS_ST_DisputeManagement_gne__History', dispute.Id, 'AGS_ST_Held_Transaction__c'), false, 'AGS_ST_DisputeManagement_gne__History' );
		AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue dmHPaymentDate = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValue(
            createHistorySobject('AGS_ST_DisputeManagement_gne__History', dispute.Id, 'Payment_Date_gne__c'), false, 'AGS_ST_DisputeManagement_gne__History' );

		AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValueBase hvBase = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValueBase();
		hvBase.activityDate = null;
		hvBase.activityUser = null;
        hvBase.activity = null;
        hvBase.oldValue = null;
        hvBase.newValue = null;

        // WHEN
        dlH.sfdc_oldValue = false;
        dlH.sfdc_newValue = false;

        String dmActivityDate = dmH.getActivityDate();
        String dmActivityUser = dmH.getActivityUser();
        String drActivityUser = drH.getActivityUser();
        String dlActivityUser = dlH.getActivityUser();
        String dmActivity = dmH.getActivity();
        String drActivity = drH.getActivity();
        String dlActivity = dlH.getActivity();
        String dmOldValue = dmH.getOldValue();
        String drOldValue = drH.getOldValue();
        String dlOldValue = dlH.getOldValue();
        String dmNewValue = dmH.getNewValue();
        String drNewValue = drH.getNewValue();
        String dlNewValue = dlH.getNewValue();

        String dmHOwnerActivity = dmHOwner.getActivity();
        String dmHIsPrivateActivity = dmHIsPrivate.getActivity();
        String dmHHeldTransactionActivity = dmHHeldTransaction.getActivity();

        dmHIsPrivate.sfdc_oldValue = false;
        dmHIsPrivate.sfdc_newValue = false;
        dmHPaymentDate.sfdc_oldValue = Date.today();
        dmHPaymentDate.sfdc_newValue = Date.today();
        String dmHIsPrivateOldValue = dmHIsPrivate.getOldValue();
        String dmHIsPrivateNewValue = dmHIsPrivate.getNewValue();
        String dmHPaymentDateOldValue = dmHPaymentDate.getOldValue();
        String dmHPaymentDateNewValue = dmHPaymentDate.getNewValue();

        String hvBaseActivityDate = hvBase.getActivityDate();
        String hvBaseActivityUser = hvBase.getActivityUser();
        String hvBaseActivity = hvBase.getActivity();
        String hvBaseOldValue = hvBase.getOldValue();
        String hvBaseNewValue = hvBase.getNewValue();

        // THEN
        System.assert( String.isNotBlank(dmActivityDate) );
        System.assert( String.isBlank(dmActivityUser) );
        System.assert( String.isBlank(drActivityUser) );
        System.assert( String.isBlank(dlActivityUser) );
        System.assert( String.isNotBlank(dmActivity) );
        System.assert( String.isNotBlank(drActivity) );
        System.assert( String.isNotBlank(dlActivity) );
        System.assert( String.isBlank(dmOldValue) );
        System.assert( String.isBlank(drOldValue) );
        System.assert( String.isNotBlank(dlOldValue) );
        System.assert( String.isBlank(dmNewValue) );
        System.assert( String.isBlank(drNewValue) );
        System.assert( String.isNotBlank(dlNewValue) );

        System.assert( String.isNotBlank(dmHOwnerActivity) );
        System.assert( String.isNotBlank(dmHIsPrivateActivity) );
        System.assert( String.isNotBlank(dmHHeldTransactionActivity) );

        System.assert( String.isNotBlank(dmHIsPrivateOldValue) );
        System.assert( String.isNotBlank(dmHIsPrivateNewValue) );
        System.assert( String.isNotBlank(dmHPaymentDateOldValue) );
        System.assert( String.isNotBlank(dmHPaymentDateNewValue) );

        System.assert( String.isBlank(hvBaseActivityDate) );
        System.assert( String.isBlank(hvBaseActivityUser) );
        System.assert( String.isBlank(hvBaseActivity) );
        System.assert( String.isBlank(hvBaseOldValue) );
        System.assert( String.isBlank(hvBaseNewValue) );
    }

    /** @date 6/18/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for getting Extra Dispute History Values methods
    */
    @isTest static void shouldGetExtraDisputeHistoryValues() {
    	// GIVEN
    	AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
        AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
        AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
        AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, 'In Progress');

    	AGS_ST_DisputeManagement_gne__History dmH = (AGS_ST_DisputeManagement_gne__History)
    		createHistorySobject('AGS_ST_DisputeManagement_gne__History', dispute.Id, 'Internal_Status_gne__c');

        ApexPages.StandardController standardCtrl = new ApexPages.standardController(dispute);
        AGS_ST_DisputeDetail_HistoryCtrlExt_gne ctrlExt = new AGS_ST_DisputeDetail_HistoryCtrlExt_gne(standardCtrl);

     	// WHEN
     	List<AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValueBase> extraDisputeHistoryValues
     		= ctrlExt.getExtraDisputeHistoryValues(dmH);
     	List<AGS_ST_DisputeDetail_HistoryCtrlExt_gne.HistoryValueBase> extraDisputeHistoryValuesOtherUserAssign
     		= ctrlExt.getExtraDisputeHistoryValuesOtherUserAssign(dmH);

     	// THEN
     	System.assertEquals(2, extraDisputeHistoryValues.size());
     	System.assertEquals(1, extraDisputeHistoryValuesOtherUserAssign.size());
    }

    /** @date 3/10/2014
    * @Author Konrad Malinowski
    * @description Util Test Method - Create Dispute Management History or Dispute Resolver History
    * @param String historyObjName
    * @param String fieldName
    * @return sObject
    */
    private static sObject createHistorySobject(String historyObjName, Id parentId, String fieldName) {
        return (sObject)JSON.deserialize(
            '{' +
                '"CreatedById"  : "' + UserInfo.getUserId()             + '",' +
                '"CreatedDate"  : "' + '2013-11-27T20:58:00.000+0000'   + '",' +
                '"ParentId"     : "' + parentId                         + '",' +
                '"Field"        : "' + fieldName                        + '"'  +
            '}',
            Type.forName(historyObjName)
        );
    }
}