@isTest
public class gFRS_FundingRequestDenialBatchTest {

    @isTest
    static void processDenialBatchTest(){
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        myOrgCS.Funding_Request_Trigger_Enabled__c = true;
        myOrgCS.DenialBatchSize__c = 500;
        myOrgCS.DenialBatchExecuteSize__c = 200;
        myOrgCS.Org_Wide_Email_Address__c = 'fundingrequestsystem-donotreply-d@gene.com';
        myOrgCS.gFRS_Inbound_Email__c = 'fundingrequestsystem-donotreply-d@gene.com';
        insert myOrgCS;
        Account testAccountA = gFRS_UnitTestHelper.createAccount('TestAccount');
        Contact testContactA = gFRS_UnitTestHelper.createContact(testAccountA.Id);
        User testUserA = gFRS_UnitTestHelper.createPortalUser(testContactA);
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccountA.Id);
        GFRS_Location__c loc = new GFRS_Location__c(
                Vendor_Name__c = 'TestLocation',
                Organization__c = testOrganization.Id,
                Vendor_ID__c = '10110000',
                Vendor_Account_Group__c = 'PC01',
                Department_Chapter_Country__c = 'United States',
                State__c = 'IL',
                Zip__c = '60516');
        insert loc;
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(
                testOrganization.Id,
                loc.Id,
                'HC Compliance',
                'New',
                'Under Review',
                'Cardiology',
                'Acromegaly',
                'Organization;Location;Application;Third Party;Program;Budget;Attachments'
        );
        fundingRequest.OwnerId = testUserA.Id;
        insert fundingRequest;

        Test.startTest();
        gFRS_BatchDenialsController.processDenialBatch(new List<String>{fundingRequest.Id}, true, null);
        Test.stopTest();

        GFRS_Funding_Request__c fundingRequestClosed = [SELECT Id, Status__c, Sub_Status__c, External_Sub_status__c
                                                        FROM GFRS_Funding_Request__c
                                                        WHERE Id =: fundingRequest.Id];
        System.assertEquals('Closed', fundingRequestClosed.Status__c);
        System.assertEquals('Denied', fundingRequestClosed.Sub_Status__c);
        System.assertEquals('Denied', fundingRequestClosed.External_Sub_status__c);
    }
}