@isTest
private class gFRS_ApprovalFundingRequestSharingTest {
    
    @testSetup
    public static void setup() {
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'GNE-GFRS-User'].Id,
            LastName = 'last',
            Email = 'puser000@contractors.roche.com',
            Username = 'puser000@contractors.roche.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        GFRS_Funding_Request__c fundingRequest = new GFRS_Funding_Request__c();
        fundingRequest.Sub_Status__c = 'CCO Review';
        fundingRequest.RecordType = [select id,Name from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='IMED' LIMIT 1];
        fundingRequest.Business_Approver__c    = UserInfo.getUserId();
        fundingRequest.Financial_Approver_1__c = UserInfo.getUserId();
        fundingRequest.Financial_Approver_2__c = UserInfo.getUserId();
        fundingRequest.Financial_Approver_3__c = UserInfo.getUserId();
        fundingRequest.Financial_Approver_4__c = UserInfo.getUserId();
        fundingRequest.Financial_Approver_5__c = UserInfo.getUserId();
        fundingRequest.Business_Approver_2__c  = UserInfo.getUserId();
        fundingRequest.Business_Approver_3__c  = UserInfo.getUserId();
        fundingRequest.Legal_Reviewer_1__c     = UserInfo.getUserId();
        fundingRequest.Business_Reviewer_1__c  = UserInfo.getUserId();
        insert fundingRequest;
    }
    
    static testMethod void testSharingForReadApproverIMEDBussinesApprover() {
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name from GFRS_Funding_Request__c LIMIT 1];
        
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,1);
        UserRecordAccess usAcc = [
            SELECT RecordId,HasReadAccess FROM UserRecordAccess
            WHERE RecordId = :fundingRequest.id
            AND UserId = :u.id
            LIMIT 1
        ];

        
        System.assertEquals(usAcc.HasReadAccess, false);
        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        fundingRequest.Business_Approver__c = u.id;
        Test.startTest();
        update fundingRequest;
        Test.stopTest();
        usAcc = [
            SELECT RecordId,HasReadAccess FROM UserRecordAccess
            WHERE RecordId = :fundingRequest.id
            AND UserId = :u.id
            LIMIT 1
        ];

        System.assertEquals(usAcc.HasReadAccess, true);
    }
    
    static testMethod void testSharingForReadApproverIMEDFinancialApprover() {
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name from GFRS_Funding_Request__c LIMIT 1];
        fundingRequest.Approved_Amount__c = 12000;
        fundingRequest.Was_grant_taken_to_Grant_Review_Committe__c = 'Yes';
        fundingRequest.Peer_Reviewed__c = 'Yes';
        fundingRequest.GRC_Recommendation__c = 'Approved at full amount';
        fundingRequest.Input__c='Medical';
        update fundingRequest;

        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;

        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,2);
        UserRecordAccess usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,false);
        // when
        Test.startTest();
        fundingRequest.Financial_Approver_1__c = u.id;
        System.debug('fundingRequest.Financial_Approver_1__c = ' + fundingRequest.Financial_Approver_1__c);
        update fundingRequest;
        Test.stopTest();
        // then
        usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,true);
    }
    
    static testMethod void testSharingForReadApproverIMEDFinancialApprover2() {
        // given
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name from GFRS_Funding_Request__c LIMIT 1];
        fundingRequest.Approved_Amount__c = 60000;
        fundingRequest.Was_grant_taken_to_Grant_Review_Committe__c = 'Yes';
        fundingRequest.Peer_Reviewed__c='Yes';
        fundingRequest.GRC_Recommendation__c='Approved at full amount';
        fundingRequest.Input__c='Medical';
        update fundingRequest;
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,3);
        UserRecordAccess usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,false);
        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        // when
        Test.startTest();
        System.debug('Current number of queries = ' + Limits.getQueries());
        fundingRequest.Financial_Approver_2__c = u.id;
        update fundingRequest;
        Test.stopTest();
        // then
        usAcc = [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,true);
    }
    
    static testMethod void testSharingForReadApproverIMEDFinancialApprover3() {
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name from GFRS_Funding_Request__c LIMIT 1];
        List<RecordType> rcType = [select id,Name from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Corporate_Memberships' LIMIT 1];
        fundingRequest.RecordTypeId = rcType[0].id;
        fundingRequest.Approved_Amount__c = 600000;
        fundingRequest.Requested_Amount__c = 600000;
        fundingRequest.Was_grant_taken_to_Grant_Review_Committe__c = 'Yes';
        fundingRequest.Peer_Reviewed__c='Yes';
        fundingRequest.GRC_Recommendation__c='Approved at full amount';
        fundingRequest.Input__c='Medical';

        update fundingRequest;
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,3);
        UserRecordAccess usAcc =  [SELECT RecordId,HasReadAccess,HasEditAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
                System.debug('HasEditAccess = ' + usAcc.HasEditAccess);
        System.assertEquals(usAcc.HasEditAccess,false);
       
       List<ProcessInstance> node = [SELECT TargetObjectId, (
                SELECT ActorId, ProcessInstanceId FROM Workitems
            ), (
                SELECT ProcessNodeName FROM Nodes
                WHERE NodeStatus = 'Pending'
            ) FROM ProcessInstance WHERE TargetObjectId = :fundingRequest.id
        ];

        System.debug('node[0] = ' + node[0]);
        System.debug('node[0].WorkItems[0] = ' + node[0].WorkItems[0]);
        System.debug('node[0].Nodes = ' + node[0].Nodes);


        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        // when
        Test.startTest();
        System.debug('Current number of queries = ' + Limits.getQueries());
        fundingRequest.Financial_Approver_3__c = u.id;
        update fundingRequest;
        System.debug('fundingRequest = ' + fundingRequest);
        Test.stopTest();
        // then
        System.debug('After test stop = ');
        usAcc = [SELECT RecordId,HasReadAccess,HasEditAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.debug('usAcc.HasReadAccess = ' + usAcc.HasReadAccess);
        System.debug('usAcc.HasEditAccess = ' + usAcc.HasEditAccess);
        System.debug('HasEditAccess = ' + usAcc.HasEditAccess);

        System.assertEquals(usAcc.HasEditAccess,true);
    }
    
    static testMethod void testSharingForReadApproverIMEDFinancialApprover4() {
        // given
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name from GFRS_Funding_Request__c LIMIT 1];
        fundingRequest.Approved_Amount__c = 1000001;
        fundingRequest.Was_grant_taken_to_Grant_Review_Committe__c = 'Yes';
        fundingRequest.Peer_Reviewed__c='Yes';
        fundingRequest.GRC_Recommendation__c='Approved at full amount';
        fundingRequest.Input__c='Medical';
        update fundingRequest;
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,5);
        UserRecordAccess usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,false);
        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        // when
        Test.startTest();
        System.debug('Current number of queries = ' + Limits.getQueries());
        fundingRequest.Financial_Approver_4__c = u.id;
        update fundingRequest;
        Test.stopTest();
        // then
        usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];



        System.assertEquals(usAcc.HasReadAccess,true);
    }
    
    static testMethod void testSharingForReadApproverIMEDFinancialApprover5() {
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name from GFRS_Funding_Request__c LIMIT 1];
        fundingRequest.Approved_Amount__c = 4000001;
        fundingRequest.Was_grant_taken_to_Grant_Review_Committe__c = 'Yes';
        fundingRequest.Peer_Reviewed__c='Yes';
        fundingRequest.GRC_Recommendation__c='Approved at full amount';
        fundingRequest.Input__c='Medical';
        update fundingRequest;
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,6);
        UserRecordAccess usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,false);
        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        // when
        Test.startTest();
        System.debug('Current number of queries = ' + Limits.getQueries());
        fundingRequest.Financial_Approver_5__c = u.id;
        update fundingRequest;
        Test.stopTest();
        // then
        usAcc = [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,true);
    }
    
    static testMethod void testSharingForReadApproverHCCHARBussinesReviewer() {
        // given
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name,Foundation_Classified__c from GFRS_Funding_Request__c LIMIT 1];
        List<RecordType> rcType = [select id,Name from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='HC_CHAR' LIMIT 1];
        System.debug('rcType = ' + rcType);
        fundingRequest.RecordTypeId = rcType[0].id;
        fundingRequest.Status__c = 'HC Compliance';
        fundingRequest.Sub_Status__c = 'New';
        fundingRequest.Foundation_Eligible__c = 'Yes';
        fundingRequest.Students_of_Color_Scholarships__c = 'Yes';
        fundingRequest.Hunger__c = 'Yes';
        fundingRequest.Pediatric_Cancer_Assistance__c = 'Yes';
        fundingRequest.Basic_Research_Fellow__c = 'Yes';
        update fundingRequest;
        fundingRequest = [select id,Name,Foundation_Classified__c,RecordType.Name,Status__c,Sub_Status__c from GFRS_Funding_Request__c LIMIT 1];
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,0);
        UserRecordAccess usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,false);
        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        // when
        Test.startTest();
        System.debug('Current number of queries = ' + Limits.getQueries());
        fundingRequest.Business_Reviewer_1__c = u.id;
        update fundingRequest;
        Test.stopTest();
        // then
        usAcc = [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,true);
    }
    
    static testMethod void testSharingForReadApproverHCCHARLegalReviewer() {
        // given
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name,Foundation_Classified__c from GFRS_Funding_Request__c LIMIT 1];
        List<RecordType> rcType = [select id,Name from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='HC_CHAR' LIMIT 1];
        fundingRequest.RecordTypeId = rcType[0].id;
        fundingRequest.Status__c = 'HC Compliance';
        fundingRequest.Sub_Status__c = 'New';
        fundingRequest.Foundation_Eligible__c = 'Yes';
        fundingRequest.Students_of_Color_Scholarships__c = 'Yes';
        fundingRequest.Hunger__c = 'Yes';
        fundingRequest.Pediatric_Cancer_Assistance__c = 'Yes';
        fundingRequest.Basic_Research_Fellow__c = 'Yes';
        update fundingRequest;
        fundingRequest = [select id,Name,Foundation_Classified__c,RecordType.Name,Status__c,Sub_Status__c from GFRS_Funding_Request__c LIMIT 1];
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,2);
        UserRecordAccess usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,false);
        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        // when
        Test.startTest();
        System.debug('Current number of queries = ' + Limits.getQueries());
        fundingRequest.Legal_Reviewer_1__c = u.id;
        update fundingRequest;
        Test.stopTest();
        // then
        usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,true);
    }
    
    static testMethod void testSharingForReadApproverHCCHARBussinesApprover2() {
        // given
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name,Foundation_Classified__c from GFRS_Funding_Request__c LIMIT 1];
        List<RecordType> rcType = [select id,Name from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='HC_CHAR' LIMIT 1];
        System.debug('rcType = ' + rcType);
        fundingRequest.RecordTypeId = rcType[0].id;
        fundingRequest.Status__c = 'HC Compliance';
        fundingRequest.Sub_Status__c = 'New';
        fundingRequest.Foundation_Eligible__c = 'Yes';
        fundingRequest.Students_of_Color_Scholarships__c = 'Yes';
        fundingRequest.Hunger__c = 'Yes';
        fundingRequest.Pediatric_Cancer_Assistance__c = 'Yes';
        fundingRequest.Basic_Research_Fellow__c = 'Yes';
        update fundingRequest;
        fundingRequest = [select id,Name,Foundation_Classified__c,RecordType.Name,Status__c,Sub_Status__c from GFRS_Funding_Request__c LIMIT 1];
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,3);
        UserRecordAccess usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,false);
        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        // when
        Test.startTest();
        System.debug('Current number of queries = ' + Limits.getQueries());
        fundingRequest.Business_Approver_2__c = u.id;
        update fundingRequest;
        Test.stopTest();
        // then
        usAcc = [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,true);
    }
    
    static testMethod void testSharingForReadApproverHCCHARBussinesApprover3() {
        // given
        User u = [Select id FROM User limit 1];
        GFRS_Funding_Request__c fundingRequest = [select id,Name,Foundation_Classified__c from GFRS_Funding_Request__c LIMIT 1];
        List<RecordType> rcType = [select id,Name from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='HC_CHAR' LIMIT 1];
        System.debug('rcType = ' + rcType);
        fundingRequest.RecordTypeId = rcType[0].id;
        fundingRequest.Status__c = 'HC Compliance';
        fundingRequest.Sub_Status__c = 'New';
        fundingRequest.Foundation_Eligible__c = 'Yes';
        fundingRequest.Students_of_Color_Scholarships__c = 'Yes';
        fundingRequest.Hunger__c = 'Yes';
        fundingRequest.Pediatric_Cancer_Assistance__c = 'Yes';
        fundingRequest.Basic_Research_Fellow__c = 'Yes';
        update fundingRequest;
        fundingRequest = [select id,Name,Foundation_Classified__c,RecordType.Name,Status__c,Sub_Status__c from GFRS_Funding_Request__c LIMIT 1];
        gFRS_UnitTestHelper.GotoApprovalStep(fundingRequest,4);
        UserRecordAccess usAcc = [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,false);
        GFRS_OrgSettings__c settings2 = GFRS_OrgSettings__c.getOrgDefaults();
        settings2.Funding_Request_Trigger_Enabled__c = true;
        upsert settings2;
        // when
        Test.startTest();
        System.debug('Current number of queries = ' + Limits.getQueries());
        fundingRequest.Business_Approver_3__c = u.id;
        update fundingRequest;
        Test.stopTest();
        // then
        usAcc =  [SELECT RecordId,HasReadAccess FROM UserRecordAccess
                WHERE RecordId = :fundingRequest.id
                AND UserId = :u.id
                LIMIT 1];
        System.assertEquals(usAcc.HasReadAccess,true);
    }
}