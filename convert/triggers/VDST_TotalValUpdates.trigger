/**
* @date 2/5/2013
* @Author Pawel Sprysak
* @description Trigger for updating Total value
*/
trigger VDST_TotalValUpdates on VDST_EventTransactionSummary_gne__c (after insert, after update) {
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_TotalValUpdates => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
    // Create Set of Id's for Event Summary objects
    final Set<Id> evtIds = new Set<Id>();
    for (VDST_EventTransactionSummary_gne__c sum : Trigger.new) {
        if (!(VDST_Utils.TOTAL_CALC_EXCLUDED_TXNS.containsKey(sum.EventTransactionTypeCode_gne__c) ||
            VDST_Utils.RECURSED_EVT_TXNS.containsKey(sum.VDST_Event_gne__c) &&
            VDST_Utils.RECURSED_EVT_TXNS.get(sum.VDST_Event_gne__c) == sum.EventTransactionTypeCode_gne__c
        )) {
            evtIds.add(sum.VDST_Event_gne__c);
        }
    }
    VDST_Utils.updateTotalSummaryValue(evtIds); // AGGSSPENDME-166
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_TotalValUpdates => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
}