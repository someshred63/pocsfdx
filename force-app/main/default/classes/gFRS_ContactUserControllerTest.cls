@isTest
private class gFRS_ContactUserControllerTest {

    @testSetup
    private static void setup() {
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;

        gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
    }

    @isTest
    private static void constructorTestContactEmpty() {
        Contact contactTest = [SELECT Id, Email, Phone
                               FROM Contact];
        ApexPages.StandardController sc = new ApexPages.StandardController(contactTest);

        Test.startTest();
        gFRS_ContactUserController testBudgetController = new gFRS_ContactUserController(sc);
        Test.stopTest();

        System.assertEquals(1, testBudgetController.userDetail.size());
    }
}