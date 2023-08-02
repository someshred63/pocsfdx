/** @date 3/25/2014
* @Author Pawel Sprysak
* @description Test Class for VDST_UpdateAttendanceObj TRIGGER
*/
@isTest
private class VDST_UpdateAttendanceObj_Test {
    /** @date 3/25/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger BEFORE UPDATE 
    */
    @IsTest(SeeAllData=false)
    static void beforeUpdate_Test() {
		// Prepare data
		VDST_Event_gne__c ev = prepareEvent('ADBOARD'); // Standard Event
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD', 
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        insert epr;
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
        	VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList.add(epa1);
        VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
        	VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList.add(epa2);
        insert epaList; // TotBiggerPlanAttCnt_gne__c should be equal 2
        List<VDST_EventDateTransaction_gne__c> edtList = [SELECT Id, EventDateTransactionAmount_gne__c FROM VDST_EventDateTransaction_gne__c];
        System.assertEquals(edtList.size(), 1);
        edtList.get(0).EventDateTransactionAmount_gne__c = 10;
        update edtList.get(0);
        List<VDST_EventPrtcpntAttendance_gne__c> epaSoqlList = [SELECT Id, AttendanceStatus_gne__c, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaSoqlList.size(), 2);

        // Test first case - normal behaviour
        epaSoqlList.get(0).AttendanceStatus_gne__c = 'ATND';
        epaSoqlList.get(0).ParticipantMealConsumptionStatus_gne__c = 'CONSUMED';
        update epaSoqlList.get(0);
        System.assertEquals(epaSoqlList.get(0).MealAmount_gne__c, 5);

        // Test second case - do not attandee
        epaSoqlList.get(0).AttendanceStatus_gne__c = 'DNS';
        update epaSoqlList.get(0);
        epaSoqlList = [SELECT Id, AttendanceStatus_gne__c, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaSoqlList.get(0).MealAmount_gne__c, 0);

        // Test third case - move back to ATND
        epaSoqlList.get(0).AttendanceStatus_gne__c = 'ATND';
        update epaSoqlList.get(0);
        epaSoqlList = [SELECT Id, AttendanceStatus_gne__c, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaSoqlList.get(0).MealAmount_gne__c, 5);
	}

    /** @date 3/25/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger AFTER UPDATE/INSERT/DELETE
    */
    @IsTest(SeeAllData=false)
    static void afterAction_Test() {
		// Prepare data
		VDST_Event_gne__c ev = prepareEvent('ADBOARD'); // Standard Event
		ev.EventStartDate_gne__c = Date.today().addDays(-3);
		update ev;
        VDST_EventPrtcpntRole_gne__c epr = new VDST_EventPrtcpntRole_gne__c(EventType_gne__c = 'ADBOARD', 
            EventParticipantRoleCode_gne__c = 'ATND', EventParticipantRoleName__c = 'Attendee');
        insert epr;
        // Accounts for Event
        List<VDST_EventPrtcpntAccnt_gne__c> epaList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa1 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
        	VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList.add(epa1);
        VDST_EventPrtcpntAccnt_gne__c epa2 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
        	VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList.add(epa2);
        insert epaList; // TotBiggerPlanAttCnt_gne__c should be equal 2
        List<VDST_EventDateTransaction_gne__c> edtList = [SELECT Id, VDST_EventDate_gne__r.EventDate_gne__c, EventDateTransactionAmount_gne__c FROM VDST_EventDateTransaction_gne__c];
        System.assertEquals(edtList.size(), 2);
        for(VDST_EventDateTransaction_gne__c edt : edtList) {
        	if(edt.VDST_EventDate_gne__r.EventDate_gne__c.format() == Date.today().addDays(-2).format()) {
        		edt.EventDateTransactionAmount_gne__c = 10;
        	} else if(edt.VDST_EventDate_gne__r.EventDate_gne__c.format() == Date.today().addDays(-3).format()) {
        		edt.EventDateTransactionAmount_gne__c = 20;
        	}
        }
        update edtList;

        // Pre-test
        List<VDST_EventPrtcpntAttendance_gne__c> epaSoqlList = [SELECT Id, VDST_EventDate_gne__r.EventDate_gne__c, AttendanceStatus_gne__c, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaSoqlList.size(), 4);
        for(VDST_EventPrtcpntAttendance_gne__c att : epaSoqlList) {
        	if(att.VDST_EventDate_gne__r.EventDate_gne__c.format() == Date.today().addDays(-3).format()) {
        		System.assertEquals(att.MealAmount_gne__c, 10);
        	} else {
        		System.assertEquals(att.MealAmount_gne__c, 5);
        	}
        }

		// Test first case - are HCPMEALS transactions created?
		List<VDST_PrtcpntTransaction_gne__c> ptList1 = [SELECT Id FROM VDST_PrtcpntTransaction_gne__c WHERE TransactionLevel_gne__c = 'INDV' AND TransactionTypeCode_gne__c = 'HCPMEALS'];
		System.assertEquals(ptList1.size(), 2);

        // Update date and run trigger
        ev.EventStartDate_gne__c = Date.today().addDays(-4);
		update ev; // Should be 3 days after this update, so insert one new attandace for each Participant
		// After runing again trigger, size of Participant Transaction List should remain the same
		ptList1 = [SELECT Id FROM VDST_PrtcpntTransaction_gne__c WHERE TransactionLevel_gne__c = 'INDV' AND TransactionTypeCode_gne__c = 'HCPMEALS'];
		System.assertEquals(ptList1.size(), 2); // TODO 2

        // Test second case - add two new Participant and check, does Amount change on Attendance
		List<VDST_EventPrtcpntAccnt_gne__c> epaList2 = new List<VDST_EventPrtcpntAccnt_gne__c>();
        VDST_EventPrtcpntAccnt_gne__c epa3 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
        	VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList2.add(epa3);
        VDST_EventPrtcpntAccnt_gne__c epa4 = new VDST_EventPrtcpntAccnt_gne__c(EventParticipantRole_gne__c = epr.Id, 
        	VDST_Event_gne__c = ev.Id, PartyType_gne__c = 'INDV');
        epaList2.add(epa4);
        insert epaList2;
        epaSoqlList = [SELECT Id, VDST_EventDate_gne__r.EventDate_gne__c, AttendanceStatus_gne__c, MealAmount_gne__c FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaSoqlList.size(), 12); // 4 Participants * 3 days
        for(VDST_EventPrtcpntAttendance_gne__c att : epaSoqlList) {
        	if(att.VDST_EventDate_gne__r.EventDate_gne__c.format() == Date.today().addDays(-2).format()) {
        		System.assertEquals(att.MealAmount_gne__c, 2.5); // 10/4
        	} else if(att.VDST_EventDate_gne__r.EventDate_gne__c.format() == Date.today().addDays(-3).format()) {
        		System.assertEquals(att.MealAmount_gne__c, 5); // 5/4
        	} else {
        		System.assertEquals(att.MealAmount_gne__c, 0);
        	}
        }
	}

    /** @date 3/25/2014
    * @Author Pawel Sprysak
    * @description Internal method for preparing event data
    */
    private static VDST_Event_gne__c prepareEvent(String eventType) {
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', 
            CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = eventType,
            EventStartDate_gne__c = Date.today().addDays(-2), EventEndDate_gne__c = Date.today().addDays(-2));
        insert ev;
        return ev;
    }
}