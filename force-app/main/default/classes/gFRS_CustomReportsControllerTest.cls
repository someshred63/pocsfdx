@isTest
private class gFRS_CustomReportsControllerTest {

    @testSetup
    static void setup() {
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        Profile myProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = gFRS_UnitTestHelper.createUserWithSpecificProfile(myProfile.Id);
    }

    @isTest
    private static void constructorTest() {
        User user = [SELECT Id FROM User LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            gFRS_CustomReportsController testBudgetController = new gFRS_CustomReportsController();
            Test.stopTest();
            System.assertEquals(false, testBudgetController.masterReportVisible);
        }
    }
}