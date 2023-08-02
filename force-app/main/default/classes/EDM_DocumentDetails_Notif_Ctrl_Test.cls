@isTest
private class EDM_DocumentDetails_Notif_Ctrl_Test {
    @isTest
    static void testController() {
        Test.startTest();
            EDM_DocumentDetails_Notification_Ctrl c = new EDM_DocumentDetails_Notification_Ctrl();
            c.eventID = null;
            c.getEventAttachments();
        Test.stopTest();
    }

}