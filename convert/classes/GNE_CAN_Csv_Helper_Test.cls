@isTest
public class GNE_CAN_Csv_Helper_Test {

    public static testMethod void testCreateAttachmentForSubscribeProcess()
    {
        Test.startTest();
            GNE_CAN_Csv_Helper csvHelper = new GNE_CAN_Csv_Helper('Stg_SFA_Subscribe_Apex_Job_Error__c', '');
            System.assertNotEquals(null ,csvHelper.getAttachment());
        Test.stopTest();
    }

    public static testMethod void testCreateAttachmentForMergeProcess()
    {
        Test.startTest();
            GNE_CAN_Csv_Helper csvHelper = new GNE_CAN_Csv_Helper('Merge_Type_Error_Log_gne__c', '');
            System.assertNotEquals(null ,csvHelper.getAttachment());
        Test.stopTest();
    }

}