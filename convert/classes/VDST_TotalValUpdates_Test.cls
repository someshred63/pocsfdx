/** @date 3/31/2014
* @Author Pawel Sprysak
* @description Test Class for VDST_TotalValUpdates TRIGGER
*/
@IsTest
private class VDST_TotalValUpdates_Test {
    /** @date 3/25/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger AFTER INSERT/UPDATE 
    */
    @IsTest
    static void afterAction_Test() {
        // Prepare data
        VDST_Event_gne__c evnt = createEvent('RSCH');
        // Test pre-case
        List<VDST_EventTransactionSummary_gne__c> etsList1 = [SELECT Id FROM VDST_EventTransactionSummary_gne__c];
        System.assertEquals(etsList1.size(), 0);
        // Test first insert
        VDST_EventTransactionSummary_gne__c newEts1 = new VDST_EventTransactionSummary_gne__c(EventTransactionAmount_gne__c = 10, EventTransactionLevel_gne__c = 'EVNT', EventTransactionTypeCode_gne__c = 'CODE', VDST_Event_gne__c = evnt.Id);
        insert newEts1;
        etsList1 = [SELECT Id, EventTransactionAmount_gne__c FROM VDST_EventTransactionSummary_gne__c];
        System.assertEquals(etsList1.size(), 2); // CODE + TOTAL
        for(VDST_EventTransactionSummary_gne__c ets : etsList1) {
            System.assertEquals(ets.EventTransactionAmount_gne__c, 10);
        }
        // Test second insert
        VDST_EventTransactionSummary_gne__c newEts2 = new VDST_EventTransactionSummary_gne__c(EventTransactionAmount_gne__c = 15, EventTransactionLevel_gne__c = 'EVNT', EventTransactionTypeCode_gne__c = 'OTHERCODE', VDST_Event_gne__c = evnt.Id);
        insert newEts2;
        etsList1 = [SELECT Id, EventTransactionAmount_gne__c, EventTransactionTypeCode_gne__c FROM VDST_EventTransactionSummary_gne__c];
        System.assertEquals(etsList1.size(), 3); // CODE + OTHERCODE + TOTAL
        for(VDST_EventTransactionSummary_gne__c ets : etsList1) {
            if('TOTALEVENT'.equals(ets.EventTransactionTypeCode_gne__c)) {
                System.assertEquals(ets.EventTransactionAmount_gne__c, 25);
            } else if('CODE'.equals(ets.EventTransactionTypeCode_gne__c)) {
                System.assertEquals(ets.EventTransactionAmount_gne__c, 10);
            } else if('OTHERCODE'.equals(ets.EventTransactionTypeCode_gne__c)) {
                System.assertEquals(ets.EventTransactionAmount_gne__c, 15);
            } else {
                System.assertEquals(ets.EventTransactionTypeCode_gne__c, 'WRONGCODE'); // Should not be invoked
            }
        }
        // Test update
        newEts2.EventTransactionAmount_gne__c = 25;
        update newEts2;
        etsList1 = [SELECT Id, EventTransactionAmount_gne__c, EventTransactionTypeCode_gne__c FROM VDST_EventTransactionSummary_gne__c];
        System.assertEquals(etsList1.size(), 3); // CODE + OTHERCODE + TOTAL
        for(VDST_EventTransactionSummary_gne__c ets : etsList1) {
            if('TOTALEVENT'.equals(ets.EventTransactionTypeCode_gne__c)) {
                System.assertEquals(ets.EventTransactionAmount_gne__c, 35);
            } else if('CODE'.equals(ets.EventTransactionTypeCode_gne__c)) {
                System.assertEquals(ets.EventTransactionAmount_gne__c, 10);
            } else if('OTHERCODE'.equals(ets.EventTransactionTypeCode_gne__c)) {
                System.assertEquals(ets.EventTransactionAmount_gne__c, 25);
            } else {
                System.assertEquals(ets.EventTransactionTypeCode_gne__c, 'WRONGCODE'); // Should not be invoked
            }
        }
    }

    /** @date 6/20/2017
    * @Author Gabriel Juriewicz
    * @description Test Method for VDST_TotalValUpdates Trigger / VDST_Utils.updateTotalSummaryValue Method
    */
    @IsTest
    static void updateTotalSummaryValue_ShouldCreateTOTALHCPEVENT() {
        //WHEN
        VDST_Event_gne__c evnt = createEvent('ADBOARD');
        Set<String> pulledEventTransactionTypes = new Set<String>();
        for (VDST_EventTransactionSummary_gne__c type :
            [SELECT EventTransactionTypeCode_gne__c FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c = :evnt.Id]) {
            pulledEventTransactionTypes.add(type.EventTransactionTypeCode_gne__c);
        }
        //THEN
        System.assertEquals(true, pulledEventTransactionTypes.contains(VDST_Utils.EVT_HCP_TOTAL_TXN), 'Should create TOTALHCPEVENT VDST_EventTransactionSummary_gne__c if EventType_gne__c = ADBOARD');
        System.assertEquals(true, pulledEventTransactionTypes.contains(VDST_Utils.EVT_HCP_MEALS_TXN), 'Should create EVTHCPMEALS VDST_EventTransactionSummary_gne__c if there is TOTALHCPEVENT summary related to event.');
    }

    /** @date 6/20/2017
    * @Author Gabriel Juriewicz
    * @description Test Method for VDST_TotalValUpdates Trigger / VDST_Utils.updateTotalSummaryValue Method
    */
    @IsTest
    static void updateTotalSummaryValue_ShouldNotCreateTOTALHCPEVENT() {
        //WHEN
        VDST_Event_gne__c evnt = createEvent('RSCH');
        Set<String> pulledEventTransactionTypes = new Set<String>();
        for (VDST_EventTransactionSummary_gne__c type :
            [SELECT EventTransactionTypeCode_gne__c FROM VDST_EventTransactionSummary_gne__c WHERE VDST_Event_gne__c = :evnt.Id]) {
            pulledEventTransactionTypes.add(type.EventTransactionTypeCode_gne__c);
        }
        //THEN
        System.assertEquals(false, pulledEventTransactionTypes.contains(VDST_Utils.EVT_HCP_TOTAL_TXN), 'Should not create TOTALHCPEVENT VDST_EventTransactionSummary_gne__c if EventType_gne__c != ADBOARD');
        System.assertEquals(false, pulledEventTransactionTypes.contains(VDST_Utils.EVT_HCP_MEALS_TXN), 'Should not create EVTHCPMEALS VDST_EventTransactionSummary_gne__c if there is no TOTALHCPEVENT summary related to event.');
    }

    private static VDST_Event_gne__c createEvent(final String eventType) {
        VDST_Event_gne__c evnt = new VDST_Event_gne__c(
            EventStartDate_gne__c = Date.today().addDays(-2),
            EventEndDate_gne__c = Date.today().addDays(-2),
            IsABMEvent_gne__c = eventType == 'ADBOARD',
            CurrentStatusDate_gne__c = Date.today(),
            CurrentStatus_gne__c = 'PENDING',
            EventType_gne__c = eventType
        );
        insert evnt;
        return evnt;
    }
}