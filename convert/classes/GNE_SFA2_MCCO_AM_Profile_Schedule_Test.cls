@isTest
private class GNE_SFA2_MCCO_AM_Profile_Schedule_Test {
    static String CRON_EXP = '0 0 0 ? * 1,2,3,4,5,6,7';

    static testmethod void mccoAmTestMethod() {
        Test.startTest();
        String jobId = System.schedule('mccoAmTestMethod', CRON_EXP, new GNE_SFA2_MCCO_AM_Profile_Schedule());
        Test.stopTest();
    }

    static testmethod void testCheckMCCOUserDiscrepancy() {
        Test.startTest();
        GNE_SFA2_MCCO_AM_Profile_Utility mccoCheck = new GNE_SFA2_MCCO_AM_Profile_Utility();
        mccoCheck.checkMCCOUserDiscrepancy();
        //System.assertEquals(0, mccoCheck.lContacts.size(), 'MCCO AM Users have correct permissions.');
        Test.stopTest();
    }

    static testmethod void testCreateExcelFromUserData() {
        Test.startTest();
        GNE_SFA2_MCCO_AM_Profile_Utility mccoCheck = new GNE_SFA2_MCCO_AM_Profile_Utility();
        mccoCheck.createExcelFromUserData();
        System.assertNotEquals(null, mccoCheck.generatedCSVFile, 'All MCCO AM User Information succesfully captured.');
        Test.stopTest();
    }

    static testmethod void testEmailUserData() {
        Test.startTest();
        GNE_SFA2_MCCO_AM_Profile_Utility mccoCheck = new GNE_SFA2_MCCO_AM_Profile_Utility();
        mccoCheck.createExcelFromUserData();
        Messaging.SendEmailResult[] result = mccoCheck.emailUserData();
        for(Messaging.SendEmailResult r : result) {
            System.assert(r.IsSuccess(), 'Email was sent successfully.');
        }
        Test.stopTest();
    }
}