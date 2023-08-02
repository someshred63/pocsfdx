trigger VDST_UpdateAttendanceObj on VDST_EventPrtcpntAttendance_gne__c (after update, after insert, after delete) {
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_UpdateAttendanceObj => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
    final Set<String> accntToUpdate = new Set<String>();
    final VDST_EventPrtcpntAttendance_gne__c[] stdEvtAttendances = new VDST_EventPrtcpntAttendance_gne__c[]{ };
    // Trigger needed only for Standard event types
    for (VDST_EventPrtcpntAttendance_gne__c epa : Trigger.new) {
        if (VDST_Utils.isStdEventType(epa.EventType_gne__c)) {
            accntToUpdate.add(epa.Event_PrtcpntAccnt_gne__c);
            if (Trigger.isUpdate) {
                stdEvtAttendances.add(epa);
            }
        }
    }
    // manage Participant Transactions
    VDST_Utils.updatePrtcpntTransactionsDM(accntToUpdate);
    if (stdEvtAttendances.size() > 0) {
        // modify Meal Amount for Participant after update
        VDST_Utils.changeMealAmountForPrtcpntBeforeModification(stdEvtAttendances, Trigger.oldMap, Trigger.newMap);
    }
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_UpdateAttendanceObj => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
}