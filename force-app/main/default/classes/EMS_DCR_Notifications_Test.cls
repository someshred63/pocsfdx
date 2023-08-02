@isTest
private class EMS_DCR_Notifications_Test {
    private static Integer BATCH_SIZE = 101;

    @isTest
    static void notifyAdminOnCreateTest() {
        Test.startTest();
        EMS_Test_Util.createDCRs(BATCH_SIZE);
        Test.stopTest();
    }

    @isTest
    static void notifyOnCompleteTest() {
        List<EMS_Data_Change_Request_gne__c> dcrs = EMS_Test_Util.createDCRs(BATCH_SIZE);

        Test.startTest();
        for (EMS_Data_Change_Request_gne__c dcr : dcrs) {
            dcr.Status_gne__c = 'Closed';
        }
        update dcrs;
        Test.stopTest();
    }
}