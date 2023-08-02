/**
* @author GFRS Dev Team
* @date 05/10/2017
* @description gFRS_DemographicGroupsControllerTestclass - test class for gFRS_DemographicGroupsController
*/
@isTest
private class gFRS_FundingRequestExtensionTest {
    
    static testMethod void testFundingRequestsChangeOwner() {
        // given
        Account testAccountA = gFRS_UnitTestHelper.createAccount('TestAccount');
        Contact testContactA = gFRS_UnitTestHelper.createContact(testAccountA.Id);
        User testUserA = gFRS_UnitTestHelper.createPortalUser(testContactA);
        Account testAccountB = gFRS_UnitTestHelper.createAccount('TestAccount');
        Contact testContactB = gFRS_UnitTestHelper.createContact(testAccountB.Id);
        User testUserB = gFRS_UnitTestHelper.createPortalUserWithoutSaving(testContactB);
        testUserB.username = 'TestPortalB.TestPortal@gene.com';
        testUserB.Email = 'TestPortalB.TestPortal@gene.com';
        insert testUserB;
        GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccountA.Id);
        GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
        GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createIMEDFundingRequestObjectWithoutSaving(
            testOrganization.Id,
            testLocation.Id,
            'Processing & Disposition',
            'Process Payment',
            'Process Payment',
            'Cardiology',
            'Acromegaly',
            'Organization;Location;Application;Third Party;Program;Budget;Attachments'
        );
        fundingRequest.OwnerId = testUserA.Id;
        insert fundingRequest;
        System.currentPageReference().getParameters().put('orgId', testOrganization.Id);
        System.currentPageReference().getParameters().put('isInternalUser', 'false');
        // when
        Test.startTest();
        final ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new GFRS_Funding_Request__c());
        final gFRS_FundingRequestExtension extUnderTest = new gFRS_FundingRequestExtension(stdCtrl);
        extUnderTest.selectedOwner.User__c = testUserB.Id;
        extUnderTest.findRequests();
        System.assertNotEquals(null, extUnderTest.requests);
        extUnderTest.requests[0].isSelected = true;
        System.assertEquals(testUserA.Id, extUnderTest.requests[0].fundingRequest.OwnerId);
        extUnderTest.changeOwner();
        Test.stopTest();
        // then
        System.assertNotEquals(null, extUnderTest.orgTypeOptions);
        System.assertEquals(4, extUnderTest.orgTypeOptions.size(), extUnderTest.orgTypeOptions);
        System.assertEquals('Copay', extUnderTest.orgTypeOptions[0].getValue(), extUnderTest.orgTypeOptions);
        System.assertEquals('External', extUnderTest.orgTypeOptions[1].getValue(), extUnderTest.orgTypeOptions);
        System.assertEquals('Internal', extUnderTest.orgTypeOptions[2].getValue(), extUnderTest.orgTypeOptions);
        System.assertEquals('Master', extUnderTest.orgTypeOptions[3].getValue(), extUnderTest.orgTypeOptions);
        System.assertNotEquals(null, extUnderTest.org);
        System.assertEquals(testOrganization.Id, extUnderTest.org.Id, extUnderTest.org);
        System.assertEquals(testUserB.Id, extUnderTest.requests[0].fundingRequest.OwnerId);
    }
}