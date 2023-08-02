/** @date 3/5/2013
* @Author Pawel Sprysak
* @description Trigger for updating Event Transaction Summary objects when Event Date Transaction has been changed
*/
trigger VDST_EventTransactionsUpdateDT on VDST_EventDateTransaction_gne__c (after insert, after update, after delete) {
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_EventTransactionsUpdateDT => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
    String eventType;
    if(Trigger.isDelete) {
        eventType = Trigger.Old.get(0).EventType_gne__c;
    } else {
        eventType = Trigger.New.get(0).EventType_gne__c;
    }
    if (!String.isBlank(eventType) && VDST_Utils.isStdEventType(eventType)) { // Trigger needed only for Standard event types
        if(Trigger.isInsert) {
            // Get Event Id's of changed transacion Amounts
            Set<String> eventIds = new Set<String>();
            for(VDST_EventDateTransaction_gne__c dt : Trigger.new) {
                eventIds.add(dt.VDST_Event_gne__c);
            }
            VDST_Utils.updateEventsTransactionsDT(eventIds);
        } else {
            System.debug('EDT > Start');
            Set<String> eventIds = new Set<String>();
            Set<String> eventDatesIds = new Set<String>();
            
            // Get Id's of transaction where Amount was changed
            for(VDST_EventDateTransaction_gne__c edt : Trigger.old) {
                if( (Trigger.isUpdate && Trigger.oldMap.get(edt.Id).EventDateTransactionAmount_gne__c != Trigger.newMap.get(edt.Id).EventDateTransactionAmount_gne__c)
                        || (Trigger.isDelete && edt.EventDateTransactionAmount_gne__c != null && edt.EventDateTransactionAmount_gne__c != 0) ) {
                    eventIds.add(edt.VDST_Event_gne__c);
                    eventDatesIds.add(edt.VDST_EventDate_gne__c);
                }
            }
            
            // Update summary transactions
            VDST_Utils.updateEventsTransactionsDT(eventIds);
            
            // Update Prtcpnt transactions
            List<VDST_EventPrtcpntAttendance_gne__c> epaList = [SELECT Id, MealAmount_gne__c, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, 
                                                                      VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c , VDST_EventDate_gne__r.VDST_Event_gne__c, 
                                                                      VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c, VDST_EventDate_gne__c, 
                                                                      VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c, 
                                                                      VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c 
                                                                  FROM VDST_EventPrtcpntAttendance_gne__c 
                                                                  WHERE VDST_EventDate_gne__c IN :eventDatesIds];
            if(epaList.size() > 0) {
                Integer attCount;
                for(VDST_EventPrtcpntAttendance_gne__c apa : epaList) {
                    attCount = Integer.valueOf(apa.VDST_EventDate_gne__r.VDST_Event_gne__r.TotBiggerPlanAttCnt_gne__c);
                    for(VDST_EventDateTransaction_gne__c edt : Trigger.old) {
                        if(edt.VDST_EventDate_gne__c == apa.VDST_EventDate_gne__c) {
                            if('ATND'.equals(apa.AttendanceStatus_gne__c) && 'CONSUMED'.equals(apa.ParticipantMealConsumptionStatus_gne__c) && !Trigger.isDelete) {
                                System.debug('CALC_ETUDT, BEG: ' + apa.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c + '; ' + Trigger.newMap.get(edt.Id).EventDateTransactionAmount_gne__c + ' / ' + attCount + ' for ' + apa.VDST_EventDate_gne__c);
                                if (apa.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c) {
                                    if( apa.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c > apa.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c ) {
                                        attCount = Integer.valueOf( apa.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c );
                                    } else {
                                        attCount = Integer.valueOf( apa.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c );
                                    }
                                    System.debug('CALC_ETUDT, CHG: ' + apa.VDST_EventDate_gne__r.VDST_Event_gne__r.IsABMevent_gne__c + '; ' + Trigger.newMap.get(edt.Id).EventDateTransactionAmount_gne__c + ' / ' + apa.VDST_EventDate_gne__r.EventDateActualAttendeeCount_gne__c + ' vs ' + apa.VDST_EventDate_gne__r.VDST_Event_gne__r.TotPlanAttCntUser_gne__c + ' for ' + apa.VDST_EventDate_gne__c);
                                }
                                if(attCount > 0) {
                                    apa.MealAmount_gne__c = Trigger.newMap.get(edt.Id).EventDateTransactionAmount_gne__c / attCount;
                                } else {
                                    apa.MealAmount_gne__c = Trigger.newMap.get(edt.Id).EventDateTransactionAmount_gne__c;
                                }
                            } else {
                                apa.MealAmount_gne__c = 0;
                            }
                            break;
                        }
                    }
                }
                upsert epaList;
            }
        }
    }
    System.debug(LoggingLevel.ERROR, 'XXXX VDST_EventTransactionsUpdateDT => ' + Limits.getDMLRows() + ' AND ' + Limits.getQueries() + ' of ' + Limits.getLimitQueries());
}