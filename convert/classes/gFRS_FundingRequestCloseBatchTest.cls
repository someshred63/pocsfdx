/**
 * Created by kozminsl on 24.01.2019.
 */
@IsTest
private class gFRS_FundingRequestCloseBatchTest {

    @TestSetup
    private static void setup() {
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        insert myOrgCS;

        Account testAccountA = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccountA.Id);
        GFRS_Location__c location = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);

        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, location.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
    }

    @IsTest
    static void processDenialBatchTest() {

        Test.startTest();
        Database.executeBatch(new gFRS_FundingRequestCloseBatch());
        Test.stopTest();
    }
}