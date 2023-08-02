/**
* @author GFRS Dev Team
* @date 14/10/2016
* @description gFRS_DemographicGroupsControllerTestclass - test class for gFRS_DemographicGroupsController
*/
@isTest
private class gFRS_DemographicGroupsControllerTest {
    class TestSettings {
        Account acc;
        GFRS_Organization__c org;
        GFRS_Funding_Request__c fundingRequest; 
        GFRS_Location__c loc;
        GFRS_Demographic_Group__c demographic;
        Apexpages.Standardcontroller stdController;
        gFRS_DemographicGroupsController controller;

         public TestSettings(Boolean createDemographic){
            this.acc = gFRS_TestCreationUtils.createAccount('gFRS_FundingRequestReadControllerTesterAcc');
            insert acc;

            this.org = gFRS_TestCreationUtils.createOrganization('TestOrg1', acc);
            insert org;

            this.loc = gFRS_TestCreationUtils.createLocation('gFRS_FundingRequestReadControllerTesterLoc',org.id);
            insert loc;

            this.fundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, '', org.Id, loc.Id);
            this.fundingRequest.Will_You_be_Working_With_a_3rd_Party__c = 'No';
            insert fundingRequest;
            this.fundingRequest = [select id, RecordTypeId, Status__c,Sub_Status__c,Will_You_be_Working_With_a_3rd_Party__c,External_Sub_status__c,Organization__c,Location__c from GFRS_Funding_Request__c where id=:fundingRequest.Id];

            if (createDemographic){
                this.demographic = gFRS_TestCreationUtils.createDemographicData(fundingRequest);
                insert demographic;
                this.demographic = [ select id, name, gFRS_Funding_Request__c, Age__c, Sexual_Identity__c, Race_and_Ethnicity__c, Social_and_Economic_Status__c, Health_and_Insurance_Status__c, Work_Status__c, Support_ESL_NonEnglish__c from GFRS_Demographic_Group__c where Id =:demographic.Id];                
            } else {
                GFRS_Funding_Request__c temporaryFundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, '', org.Id, loc.Id);
                insert temporaryFundingRequest;
                temporaryFundingRequest = [select id, RecordTypeId, Status__c,Sub_Status__c,External_Sub_status__c,Organization__c,Location__c from GFRS_Funding_Request__c where id=:temporaryFundingRequest.Id];

                this.demographic = gFRS_TestCreationUtils.createDemographicData(temporaryFundingRequest);
                insert demographic;
                this.demographic = [ select id, name, gFRS_Funding_Request__c, Age__c, Sexual_Identity__c, Race_and_Ethnicity__c, Social_and_Economic_Status__c, Health_and_Insurance_Status__c, Work_Status__c, Support_ESL_NonEnglish__c from GFRS_Demographic_Group__c where Id =:demographic.Id];                
            }

            
         }

         public void setupControllerVariables(){
            this.stdController = new Apexpages.Standardcontroller(this.demographic);
            this.controller = new gFRS_DemographicGroupsController(stdController);
            controller.fundReq = this.fundingRequest;
            controller.ageValue = 'Adults (40-60)';
            controller.sexualIdentityValue = 'Males';
            controller.raceEthnicityValue = 'Asian';
            controller.socialEconomicStatusValue = 'At-risk youth';
            controller.healthInsuranceValue = 'Uninsured';
            controller.workStatusValue = 'Veterans';
            controller.supportESLValue = 'Yes';
            controller.demographicGroup = [ select id, name, gFRS_Funding_Request__c, Age__c, Sexual_Identity__c, Race_and_Ethnicity__c, Social_and_Economic_Status__c, Health_and_Insurance_Status__c, Work_Status__c, Support_ESL_NonEnglish__c from GFRS_Demographic_Group__c where Id =:this.demographic.Id];
         }
    }
    
    static testmethod void testDemographicGroupsControllerWithDemo(){

        TestSettings ts = new TestSettings(true);
        List<Apexpages.Message> messages = ApexPages.getMessages();
        Boolean hasFundingRequestId = true;
        ApexPages.currentPage().getParameters().put('request_id',ts.fundingRequest.Id);
        ts.setupControllerVariables();
        ts.controller.setDemographicGroupItemsValues();
        messages = ApexPages.getMessages();
        for(Apexpages.Message msg:messages){
            if (msg.getDetail().contains('Error occurred while loading the funding request')) hasFundingRequestId = false; 
        }

        System.assert(hasFundingRequestId == true); 
        System.assertEquals(ts.fundingRequest.Id,ts.demographic.GFRS_Funding_Request__c);
        System.assertEquals(ts.fundingRequest.Id,ApexPages.currentPage().getParameters().get('request_id'));
        System.assert(ts.controller.demographicGroup!=null);        
    }

    static testmethod void testDemographicGroupsControllerWithoutDemo(){

        TestSettings ts = new TestSettings(false);
        ApexPages.currentPage().getParameters().put('request_id',ts.fundingRequest.Id);
        ts.setupControllerVariables();
        ts.controller.setDemographicGroupItemsValues();
        System.assertEquals(ts.fundingRequest.GFRS_Demographic_Groups1__r.size(),0);

    }

    static testmethod void testDemographicWithoutFundingRequestID(){

        TestSettings ts = new TestSettings(true);
        ts.setupControllerVariables();
        System.assertEquals(ApexPages.currentPage().getParameters().get('request_id'),null);
    }

    static testmethod void testSavePageWithException(){

        TestSettings ts = new TestSettings(true);
        ts.setupControllerVariables();       
        ts.controller.sexualIdentityValue ='General Public (Gender Identity and Sexual Orientation);Females';
        ts.controller.setDemographicGroupItemsValues();        
        ts.controller.savePage();
    }
    static testmethod void testNextBackButtons(){

        TestSettings ts = new TestSettings(true);
        ts.setupControllerVariables();
        ApexPages.PageReference nextPage = new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAM, ts.fundingRequest, '' ) );
        ApexPages.PageReference backPageApplication = new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_APPLICATION, ts.fundingRequest, '' ) );
        ApexPages.PageReference backPageThirdParty = new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_THIRDPARTY, ts.fundingRequest, '' ) );

        System.assertEquals(nextPage.getURL(), ts.controller.next().getURL());
        System.assertEquals(backPageApplication.getURL(), ts.controller.back().getURL());

        ts.fundingRequest.Will_You_be_Working_With_a_3rd_Party__c = 'Yes';
        ts.controller.savePage();
        
        upsert ts.fundingRequest;
        System.assertEquals(backPageThirdParty.getURL(), ts.controller.back().getURL()); 
    }
}