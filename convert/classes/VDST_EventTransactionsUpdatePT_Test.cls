/** @date 6/21/2017
* @Author Gabriel Juriewicz
* @description Test Class for VDST_EventTransactionsUpdatePT TRIGGER
*/
@isTest
private class VDST_EventTransactionsUpdatePT_Test {
    
    @testSetup
    static void testSetup() {
        final VDST_Event_gne__c evnt = new VDST_Event_gne__c(
            EventStartDate_gne__c = Date.today().addDays(-2),
            EventEndDate_gne__c = Date.today().addDays(-2),
            CurrentStatusDate_gne__c = Date.today(),
            CurrentStatus_gne__c = 'PENDING',
            EventType_gne__c = 'ADBOARD',
            IsABMEvent_gne__c = true
        );
        insert evnt;
        insert new VDST_EventPrtcpntAccnt_gne__c(
            ParticipantContractStatus_gne__c = 'CNTRCTD',
            VDST_Event_gne__c = evnt.Id
        );
    }
    /** @date 6/21/2017
    * @Author Gabriel Juriewicz
    * @description Test Method for VDST_Utils_updateEventsTransactionsPT
    */
    @isTest
    static void VDST_Utils_updateEventsTransactionsPT_ShouldCreateTransactionSummary() {
        // given
        final VDST_EventPrtcpntAccnt_gne__c prtcpnt = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c LIMIT 1];
        delete [SELECT Id FROM VDST_EventTransactionSummary_gne__c];
        // when
        Test.startTest();
        final VDST_PrtcpntTransaction_gne__c txn = new VDST_PrtcpntTransaction_gne__c(
            VDST_EventPrtcpntAccnt_gne__c = prtcpnt.Id,
            TransactionTypeCode_gne__c = 'HCPMEALS',
            FeePayToPartyType_gne__c = 'INDV',
            TransactionAmount_gne__c = 10
        );
        insert txn;
        Test.stopTest();
        // then
        final VDST_EventTransactionSummary_gne__c[] actualTxns = [
            SELECT EventTransactionAmount_gne__c FROM VDST_EventTransactionSummary_gne__c
            WHERE EventTransactionTypeCode_gne__c = :VDST_Utils.EVT_HCP_MEALS_TXN
        ];
        System.assertEquals(false, actualTxns.isEmpty());
        System.assertEquals(txn.TransactionAmount_gne__c, actualTxns[0].EventTransactionAmount_gne__c);
    }

    /** @date 6/21/2017
    * @Author Gabriel Juriewicz
    * @description Test Method for VDST_Utils_updateEventsTransactionsPT
    */
    @isTest
    static void VDST_Utils_updateEventsTransactionsPT_ShouldUpdateTransactionSummary() {
        // given
        final VDST_EventPrtcpntAccnt_gne__c prtcpnt = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c LIMIT 1];
        // when
        Test.startTest();
        final VDST_PrtcpntTransaction_gne__c txn = new VDST_PrtcpntTransaction_gne__c(
            VDST_EventPrtcpntAccnt_gne__c = prtcpnt.Id,
            TransactionTypeCode_gne__c = 'HCPMEALS',
            FeePayToPartyType_gne__c = 'INDV',
            TransactionAmount_gne__c = 10
        );
        insert txn;
        Test.stopTest();
        // then
        final VDST_EventTransactionSummary_gne__c[] actualTxns = [
            SELECT EventTransactionAmount_gne__c FROM VDST_EventTransactionSummary_gne__c
            WHERE EventTransactionTypeCode_gne__c = :VDST_Utils.EVT_HCP_MEALS_TXN
        ];
        System.assertEquals(false, actualTxns.isEmpty());
        System.assertEquals(txn.TransactionAmount_gne__c, actualTxns[0].EventTransactionAmount_gne__c);
    }
}