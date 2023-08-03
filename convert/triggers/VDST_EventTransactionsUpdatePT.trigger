/** @date 3/15/2013
* @Author Pawel Sprysak
* @description Trigger for updating Participant transactions on summary object
*/
trigger VDST_EventTransactionsUpdatePT on VDST_PrtcpntTransaction_gne__c (before update, after insert, after update, after delete) {
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_EventTransactionsUpdatePT => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
    if (Trigger.isAfter) {
        final Set<String> eventIds = new Set<String>();
        // Add Events Id's from Participant Transaction when deleted
        if (Trigger.isDelete) {
            for (VDST_PrtcpntTransaction_gne__c pt : Trigger.old) {
                if ((pt.FeePayToPartyType_gne__c != 'ORG' || !VDST_Utils.isStdEventType(pt.EventType_gne__c)) &&
                    pt.TransactionAmount_gne__c != null &&
                    pt.TransactionAmount_gne__c != 0
                ) {
                    eventIds.add(pt.VDST_Event_gne__c); //NEW
                }
            }
        }
        // Add Events Id's from Participant Transaction when inserted/updated
        if (Trigger.isUpdate || Trigger.isInsert) {
            for (VDST_PrtcpntTransaction_gne__c pt : Trigger.new) {
                if (Trigger.isUpdate && (
                    Trigger.oldMap.get(pt.Id).TransactionAmount_gne__c != Trigger.newMap.get(pt.Id).TransactionAmount_gne__c ||
                    Trigger.oldMap.get(pt.Id).TransactionTypeCode_gne__c != Trigger.newMap.get(pt.Id).TransactionTypeCode_gne__c
                ) || Trigger.isInsert && pt.TransactionAmount_gne__c != null && pt.TransactionAmount_gne__c != 0
                ) {
                    eventIds.add(pt.VDST_Event_gne__c); 
                }
            }
        }
        // Update transaction method
        VDST_Utils.updateEventsTransactionsPT(eventIds);
    } else { // is Before
        for (VDST_PrtcpntTransaction_gne__c txn : Trigger.new) {
            if (VDST_Utils.isSSEventType(txn.EventType_gne__c)) {
                txn.TransactionAmount_gne__c = txn.ItemAmount_gne__c * (txn.EventType_gne__c == 'MEDWRTG' ? 1 :
                    txn.ItemQuantity_gne__c == null ? 0 : Integer.valueOf(txn.ItemQuantity_gne__c)
                );
            }
        }
    }
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_EventTransactionsUpdatePT => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
}