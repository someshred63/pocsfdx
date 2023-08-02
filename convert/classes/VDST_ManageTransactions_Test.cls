/** @date 3/25/2014
* @Author Pawel Sprysak
* @description Test Class for VDST_ManageTransactions_Test TRIGGER
*/
@isTest
public class VDST_ManageTransactions_Test {
    /** @date 3/25/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger BEFORE DELETE 
    */
    @IsTest(SeeAllData=false)
    static void beforeDelete_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');

        // Clear data
        List<VDST_EventDate_gne__c> edListToRemove = [SELECT Id FROM VDST_EventDate_gne__c];
        delete edListToRemove;
        List<VDST_EventDateTransaction_gne__c> edtListToRemove = [SELECT Id FROM VDST_EventDateTransaction_gne__c];
        delete edtListToRemove;

        // Create data
        VDST_EventDate_gne__c ed = new VDST_EventDate_gne__c(VDST_Event_gne__c = ev.Id, EventDate_gne__c = Date.today());
		insert ed;
        VDST_EventDateTransaction_gne__c edt = new VDST_EventDateTransaction_gne__c(VDST_EventDate_gne__c = ed.Id, EventDateTransactionAmount_gne__c = 10);
        insert edt;

        // Check pre-conditions
        List<VDST_EventDate_gne__c> edList = [SELECT Id FROM VDST_EventDate_gne__c];
        List<VDST_EventDateTransaction_gne__c> edtList = [SELECT Id FROM VDST_EventDateTransaction_gne__c];
        System.assertEquals(edList.size(), 1);
        System.assertEquals(edtList.size(), 1);

        // Run trigger
        delete ed;

        // Test values
        edList = [SELECT Id FROM VDST_EventDate_gne__c];
        edtList = [SELECT Id FROM VDST_EventDateTransaction_gne__c];
        System.assertEquals(edList.size(), 0);
        System.assertEquals(edtList.size(), 0); // This should be also deleted
    }

    /** @date 3/25/2014
    * @Author Pawel Sprysak
    * @description Test Method for Trigger BEFORE DELETE 
    */
    @IsTest(SeeAllData=false)
    static void afterInsert_Test() {
        // Prepare test data
        VDST_Event_gne__c ev = prepareEvent('ADBOARD');
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
        insert epaList;
        List<VDST_EventDate_gne__c> edList = new List<VDST_EventDate_gne__c>();
        VDST_EventDate_gne__c ed1 = new VDST_EventDate_gne__c(VDST_Event_gne__c = ev.Id, EventDate_gne__c = Date.today());
        edList.add(ed1);
        VDST_EventDate_gne__c ed2 = new VDST_EventDate_gne__c(VDST_Event_gne__c = ev.Id, EventDate_gne__c = Date.today().addDays(-1));
        edList.add(ed2);

        // Clear data
        List<VDST_EventDate_gne__c> edListToRemove = [SELECT Id FROM VDST_EventDate_gne__c];
        delete edListToRemove;
        List<VDST_EventDateTransaction_gne__c> edtListToRemove = [SELECT Id FROM VDST_EventDateTransaction_gne__c];
        delete edtListToRemove;

        // Run trigger
        insert edList;

        // Test values
        List<VDST_EventDate_gne__c> edSoqlList = [SELECT Id FROM VDST_EventDate_gne__c];
        System.assertEquals(edSoqlList.size(), 2);
        List<VDST_EventPrtcpntAccnt_gne__c> epaSqolList = [SELECT Id FROM VDST_EventPrtcpntAccnt_gne__c];
        System.assertEquals(epaSqolList.size(), 2);
        List<VDST_EventPrtcpntAttendance_gne__c> epaSoqlList = [SELECT Id FROM VDST_EventPrtcpntAttendance_gne__c];
        System.assertEquals(epaSoqlList.size(), 4); // This should be equal attendance * event dates
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