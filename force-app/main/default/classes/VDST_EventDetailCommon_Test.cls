/** @date 2/4/2014
* @Author Pawel Sprysak
* @description Test Class with methods for Common Utils for Event Detail
*/
@isTest
private class VDST_EventDetailCommon_Test {
    /** @date 2/4/2014
    * @Author Pawel Sprysak
    * @description Test Method - testing hasMCS flag
    */
    @IsTest(SeeAllData=true)
    static void hasMCS_Test() {
        VDST_EventDetailCommon edc = new VDST_EventDetailCommon();
        // Test value for MCS (Meal Consumption Status) events
        edc.eventType = 'CFF';
        System.assertEquals(true, edc.hasMCS);
        edc.eventType = 'MISCEVENT';
        System.assertEquals(true, edc.hasMCS);
        // Test value for other events
        edc.eventType = 'ADBOARD';
        System.assertEquals(false, edc.hasMCS);
    }

    /** @date 2/4/2014
    * @Author Pawel Sprysak
    * @description Test Method - testing getLabel() method
    */
    @IsTest(SeeAllData=true)
    static void getLabel_Test() {
        VDST_EventDetailCommon edc = new VDST_EventDetailCommon();
        // Check existing values
        String str1 = edc.getLabel('POL');
        System.assertEquals('Poland', str1);
        // Check unexisting values
        String str2 = edc.getLabel('XXX');
        System.assertEquals('', str2);
    }

    /** @date 2/4/2014
    * @Author Pawel Sprysak
    * @description Test Method - testing getProfessionSO() method
    */
    @IsTest(SeeAllData=true)
    static void getProfession_Test() {
        VDST_EventDetailCommon edc = new VDST_EventDetailCommon();
        // Check first value
        System.assertEquals('', edc.getProfessionSO().get(0).getValue());
        System.assertEquals('-Select-', edc.getProfessionSO().get(0).getLabel());
        // Check list size
        System.assert(edc.getProfessionSO().size() > 1);
    }

    /** @date 2/4/2014
    * @Author Pawel Sprysak
    * @description Test Method - testing getCredentialCodeMappingsSO() method
    */
    @IsTest(SeeAllData=true)
    static void getCredentialCodeMappingsSO_Test() {
        VDST_EventDetailCommon edc = new VDST_EventDetailCommon();
        // Check first value
        System.assertEquals('', edc.getCredentialCodeMappingsSO().get(0).getValue());
        System.assertEquals('-Select-', edc.getCredentialCodeMappingsSO().get(0).getLabel());
        // Check list size
        System.assert(edc.getCredentialCodeMappingsSO().size() > 1);
    }

    /** @date 2/4/2014
    * @Author Pawel Sprysak
    * @description Test Method - testing getSuffixMappingsSO() method
    */
    @IsTest(SeeAllData=true)
    static void getSuffixMappingsSO_Test() {
        VDST_EventDetailCommon edc = new VDST_EventDetailCommon();
        // Check first value
        System.assertEquals('', edc.getSuffixMappingsSO().get(0).getValue());
        System.assertEquals('-Select-', edc.getSuffixMappingsSO().get(0).getLabel());
        // Check list size
        System.assert(edc.getSuffixMappingsSO().size() > 1);
    }

    /** @date 2/4/2014
    * @Author Pawel Sprysak
    * @description Test Method - testing NonResearchPayments and NonResearchTransaction inner classes
    */
    @IsTest(SeeAllData=false)
    static void innerClasses_Test() {
        System.Test.startTest();

        // Prepare data - No transaction List
        insert new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'Transactions', FieldName_gne__c = 'TOTALEVENT', FieldLabel_gne__c = 'Total Event Spend Amount');
        insert new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'Transactions', FieldName_gne__c = 'TOTALAMOUNT', FieldLabel_gne__c = 'Total Amount');
        insert new VDST_EventField_gne__c(EventType_gne__c = 'CFF', EventStatus_gne__c = 'Transactions', FieldName_gne__c = 'TOTEVAMOUNT', FieldLabel_gne__c = 'Total Event Amount');
        VDST_Event_gne__c ev = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', CurrentStatusDate_gne__c = Date.today(), EventType_gne__c = 'CFF', EventStartDate_gne__c = Date.today(), EventEndDate_gne__c = Date.today());
        insert ev;
        // Constructor and transaction list test
        VDST_EventDetailCommon edc = new VDST_EventDetailCommon();
        edc.nonResTransaction = new VDST_EventDetailCommon.NonResearchPayments(ev.Id, null, 'CFF', 'RSCH');
        System.assertEquals(edc.nonResTransaction.sourceExpType, 'RSCH');
        System.assertEquals(edc.nonResTransaction.eventId, ev.Id);
        System.assertEquals(edc.nonResTransaction.nonResPayment, 0);
        System.assertEquals(edc.nonResTransaction.transactionMap.size(), 3);
        System.assertEquals(edc.nonResTransaction.attendanceList.size(), 0);
        System.assertEquals(edc.nonResTransaction.sourceBalance.spendAmount, 0);
        System.assertEquals(edc.nonResTransaction.totalSpends.spendAmount, 0);
        // Method: change Item Amount
        edc.nonResTransaction.setItemAmount(100);
        System.assertEquals(edc.nonResTransaction.nonResPayment, 100);
        System.assertEquals(edc.nonResTransaction.sourceBalance.spendAmount, 100);
        // prepare data - With transaction List
        insert new VDST_EventTransactionSummary_gne__c(EventTransactionTypeCode_gne__c = 'TOTALAMOUNT', VDST_Event_gne__c = ev.Id, EventTransactionAmount_gne__c = 400);
        insert new VDST_EventTransactionSummary_gne__c(EventTransactionTypeCode_gne__c = 'TOTEVAMOUNT', VDST_Event_gne__c = ev.Id, EventTransactionAmount_gne__c = 200);
        //insert new VDST_EventTransactionSummary_gne__c(EventTransactionTypeCode_gne__c = 'TOTALEVENT', VDST_Event_gne__c = ev.Id, EventTransactionAmount_gne__c = 600); // Will be setted via trigger
        edc.nonResTransaction = new VDST_EventDetailCommon.NonResearchPayments(ev.Id, 1100, 'CFF', 'RSCH');
        System.assertEquals(edc.nonResTransaction.nonResPayment, 1100);
        System.assertEquals(edc.nonResTransaction.transactionMap.size(), 3);
        System.assertEquals(edc.nonResTransaction.attendanceList.size(), 2);
        System.assertEquals(edc.nonResTransaction.attendanceList.get(0).spendName, 'Total Amount');
        System.assertEquals(edc.nonResTransaction.sourceBalance.spendAmount, 500);
        System.assertEquals(edc.nonResTransaction.totalSpends.spendAmount, 600);
        // Method: change Item Amount
        edc.nonResTransaction.setItemAmount(1200);
        System.assertEquals(edc.nonResTransaction.nonResPayment, 1200);
        System.assertEquals(edc.nonResTransaction.sourceBalance.spendAmount, 600);

        System.Test.stopTest();

        // Testing amount getter
        VDST_EventDetailCommon.NonResearchTransaction nrt = new VDST_EventDetailCommon.NonResearchTransaction('TEST', null);
        System.assertEquals(nrt.spendAmount, 0);
    }
}