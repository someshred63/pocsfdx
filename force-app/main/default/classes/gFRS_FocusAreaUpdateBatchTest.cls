/**
 * Created by golisk on 15.01.2018.
 */

@IsTest
private class gFRS_FocusAreaUpdateBatchTest {

    @TestSetup
    static void setupTestData() {
        List<String> goals = gFRS_Util.getPicklistValues('GFRS_Funding_Request__c', 'Social_Impact_Goals_CEG__c');
        List<String> focus = gFRS_Util.getPicklistValues('GFRS_Funding_Request__c', 'Focus_Area__c');

        Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('34-8905643', testAccount.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest;

        for (Integer i = 0; i < goals.size(); i++) {
            fundingRequest = gFRS_UnitTestHelper.createFellowshipsFundingRequestObject(testOrganization.Id, testLocation.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
            fundingRequest.Social_Impact_Goals_CEG__c = goals[i];
            if (goals[i].equals('Other')) {
                fundingRequest.If_other_please_specify_SocialImpact_goa__c = 'Other';
            }
            insert fundingRequest;
        }
    }

    @IsTest
    static void testBatchExecute() {
        gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        List<String> focus = gFRS_Util.getPicklistValues('GFRS_Funding_Request__c', 'Focus_Area__c');

        Test.startTest();
        gFRS_FocusAreaUpdateBatch focusAreaUpdateBatch = new gFRS_FocusAreaUpdateBatch();
        Id jobId = Database.executeBatch(focusAreaUpdateBatch);
        Test.stopTest();

        List<GFRS_Funding_Request__c> requests = [SELECT Id, Name, Social_Impact_Goals_CEG__c, If_other_please_specify_SocialImpact_goa__c, Focus_Area__c FROM GFRS_Funding_Request__c];
        for (GFRS_Funding_Request__c fundingRequest : requests) {
            System.assert(fundingRequest.Focus_Area__c != null);
        }
    }
}