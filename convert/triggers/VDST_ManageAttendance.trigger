/** @date 3/5/2013
* @Author Pawel Sprysak
* @description Trigger for create new Attendance objects
*/
trigger VDST_ManageAttendance on VDST_EventPrtcpntAccnt_gne__c (after insert, before delete, after delete) {
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_ManageAttendance => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
    Map<String, Integer> insertedPrtcpnts = new Map<String, Integer>();
    // Delete Event Transactions before Participants are deleted (because relation to Event is needed)
    if(Trigger.isDelete && Trigger.isBefore) {
        delete VDST_Utils.getPrtcpntTransByAccounts(Trigger.oldMap.keySet());
    }
    // Creates Attendance records on Participant Account insert
    if(Trigger.isInsert) {
        // Generate Event Map with Participant Account Id List
        Map<String, List<Id>> epaMap = new Map<String, List<Id>>();
        String eventType = Trigger.new.get(0).EventType_gne__c;
        for(VDST_EventPrtcpntAccnt_gne__c epa : Trigger.New) {
            if( 'INDV'.equals(epa.PartyType_gne__c) || !VDST_Utils.isStdEventType(eventType) ) {
                if(insertedPrtcpnts.containsKey(epa.VDST_Event_gne__c)) {
                    insertedPrtcpnts.put(epa.VDST_Event_gne__c, insertedPrtcpnts.get(epa.VDST_Event_gne__c)+1);
                } else {
                    insertedPrtcpnts.put(epa.VDST_Event_gne__c, 1);
                }
                if(!epaMap.containsKey(epa.VDST_Event_gne__c)) {
                    epaMap.put(epa.VDST_Event_gne__c, new List<Id>{epa.Id});
                } else {
                    epaMap.get(epa.VDST_Event_gne__c).add(epa.Id);
                }
            }
        }
        // Generate Event Map with Event Date Id List
        Map<String, List<Id>> edMap = new Map<String, List<Id>>();
        for(VDST_EventDate_gne__c ed : [SELECT Id, VDST_Event_gne__c FROM VDST_EventDate_gne__c WHERE VDST_Event_gne__c IN :epaMap.keySet()]) {
            if(!edMap.containsKey(ed.VDST_Event_gne__c)) {
                edMap.put(ed.VDST_Event_gne__c, new List<Id>{ed.Id});
            } else {
                edMap.get(ed.VDST_Event_gne__c).add(ed.Id);
            }
        }
        // Generate Event Participant Attendance List to create
        List<VDST_EventPrtcpntAttendance_gne__c> newAttendance = new List<VDST_EventPrtcpntAttendance_gne__c>();
        for(String eventId : epaMap.keySet()) {
            for(String prtcpntId: epaMap.get(eventId)) {
                for(String eventDateId : edMap.get(eventId)) {
                    newAttendance.add(new VDST_EventPrtcpntAttendance_gne__c(VDST_EventDate_gne__c = eventDateId, Event_PrtcpntAccnt_gne__c = prtcpntId, MealAmount_gne__c = 0, AttendanceStatus_gne__c = 'ATND', ParticipantMealConsumptionStatus_gne__c = 'CONSUMED'));
                }
            }
        }
        insert newAttendance;
    }
    if(Trigger.isAfter) {
        System.debug('EPA > START');
        // Creating Daily-Meal Transaction
        String evType;
        if(Trigger.isInsert) {
            evType = Trigger.New.get(0).EventType_gne__c;
        } else {
            evType = Trigger.Old.get(0).EventType_gne__c;
        }
        if(VDST_Utils.isStdEventType(evType)) {
            Set<String> evntIds = new Set<String>();
            if(Trigger.isInsert) {
                for(VDST_EventPrtcpntAccnt_gne__c epa : Trigger.New) {
                    if( 'INDV'.equals(epa.PartyType_gne__c) ) {
                        evntIds.add(epa.VDST_Event_gne__c);
                    }
                }
            } else {
                for(VDST_EventPrtcpntAccnt_gne__c epa : Trigger.Old) {
                    if( 'INDV'.equals(epa.PartyType_gne__c) ) {
                        evntIds.add(epa.VDST_Event_gne__c);
                    }
                }
            }
            List<VDST_EventPrtcpntAttendance_gne__c> epaList = [SELECT Id, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE VDST_EventDate_gne__r.VDST_Event_gne__c IN :evntIds];
            List<VDST_EventDateTransaction_gne__c> edtList = [SELECT Id, EventDateTransactionAmount_gne__c, VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntRollUp_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c, VDST_EventDate_gne__r.VDST_Event_gne__c FROM VDST_EventDateTransaction_gne__c WHERE VDST_EventDate_gne__r.VDST_Event_gne__c IN :evntIds];
            if(edtList.size() > 0 && epaList.size() > 0) {
                Integer attCount = 1;
                for(VDST_EventDateTransaction_gne__c edt : edtList) {
                    for(VDST_EventPrtcpntAttendance_gne__c epa : epaList) {
                        if(epa.VDST_EventDate_gne__c == edt.VDST_EventDate_gne__c) {
                            Integer TotPlanAttCntUser = 1;
                            if(edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c != null) {
                                TotPlanAttCntUser = Integer.valueOf(edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c);
                            }
                            if(TotPlanAttCntUser == null) {
                                TotPlanAttCntUser = 1;
                            }
                            if (edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c) {
                                Integer EventDateActualAttendeeCount = 0;
                                if(edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c != null) {
                                    EventDateActualAttendeeCount = Integer.valueOf(edt.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c);
                                }
                                if(Trigger.isDelete) { // we can delete only one participant
                                    Integer numberToRemove = 1;
                                    EventDateActualAttendeeCount = EventDateActualAttendeeCount - numberToRemove;
                                } /*
                                else { //we can add more than one participant
                                    Integer insertedCount = (insertedPrtcpnts.get(edt.VDST_EventDate_gne__r.VDST_Event_gne__c) == null) ? 0 : insertedPrtcpnts.get(edt.VDST_EventDate_gne__r.VDST_Event_gne__c);
                                    EventDateActualAttendeeCount = EventDateActualAttendeeCount + insertedCount;
                                }
                                */
                                if( EventDateActualAttendeeCount > TotPlanAttCntUser) {
                                    attCount = EventDateActualAttendeeCount;
                                } else {
                                    attCount = TotPlanAttCntUser;
                                }
                                System.debug('CALC_MA, CHG: ' + edt.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c + '; ' + edt.EventDateTransactionAmount_gne__c + ' / ' + EventDateActualAttendeeCount + ' vs ' + TotPlanAttCntUser + ' for ' + epa.VDST_EventDate_gne__c);
                            } else {
                                Integer TotPlanAttCntRollUp = 0;
                                if(edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntRollUp_gne__c != null) {
                                    TotPlanAttCntRollUp = Integer.valueOf(edt.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntRollUp_gne__c);
                                }
                                if(Trigger.isDelete) { // we can delete only one participant
                                    Integer numberToRemove = 1;
                                    TotPlanAttCntRollUp = TotPlanAttCntRollUp - numberToRemove;
                                } else { //we can add more than one participant
                                    Integer insertedCount = (insertedPrtcpnts.get(edt.VDST_EventDate_gne__r.VDST_Event_gne__c) == null) ? 0 : insertedPrtcpnts.get(edt.VDST_EventDate_gne__r.VDST_Event_gne__c);
                                    TotPlanAttCntRollUp = TotPlanAttCntRollUp + insertedCount;
                                }
                                if(TotPlanAttCntRollUp >= TotPlanAttCntUser) {
                                    attCount = TotPlanAttCntRollUp;
                                } else {
                                    attCount = TotPlanAttCntUser;
                                }
                                System.debug('CALC_MA, BEG: false; ' + edt.EventDateTransactionAmount_gne__c + ' / ' + TotPlanAttCntRollUp + ' vs ' + TotPlanAttCntUser + ' for ' + epa.VDST_EventDate_gne__c);
                            }
                            if('ATND'.equals(epa.AttendanceStatus_gne__c) && 'CONSUMED'.equals(epa.ParticipantMealConsumptionStatus_gne__c)) {
                                if(attCount > 0) {
                                    epa.MealAmount_gne__c = edt.EventDateTransactionAmount_gne__c / attCount;
                                } else {
                                    epa.MealAmount_gne__c = edt.EventDateTransactionAmount_gne__c;
                                }
                            } else {
                                epa.MealAmount_gne__c = 0;
                            }
                        }
                    }
                }
                update epaList;
            }
        }
    }
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_ManageAttendance => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
}