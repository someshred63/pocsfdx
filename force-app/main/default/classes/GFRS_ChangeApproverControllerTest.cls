/**
* @author GFRS DEV Team
* @date 26/04/2018
* @description Test class for Change Approver functionality
*/

@IsTest
private class GFRS_ChangeApproverControllerTest {

    public class TestSettings {
        public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        public Contact contact;
        public User user;

        public GFRS_ChangeApproverController controller;

        public TestSettings() {
        }

        public void initialSetup() {
            this.account = gFRS_TestCreationUtils.createAccount(gFRS_TestCreationUtils.makeUnique('acct'));
            insert this.account;

            this.organization = gFRS_TestCreationUtils.createInternalOrganization('20110101', this.account);
            insert this.organization;

            this.location = gFRS_TestCreationUtils.createLocation('SomeLocation', this.organization.Id);
            insert this.location;
        }

        public void setupIMED() {
            this.request = gFRS_TestCreationUtils.createFundingRequest2(gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.Id, this.location.Id);
            insert this.request;
        }

        public void setupUser() {
            Profile extProfile = [SELECT Id, Name FROM Profile WHERE Name = 'GNE-GFRS-Admin' LIMIT 1];
            this.user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', extProfile.Id, '1234');
            insert this.user;
        }

        public User getUser() {
            return [SELECT Id FROM User WHERE Id = :this.user.Id];
        }

        public void triggerApproval() {
            this.request.Status__c = gFRS_Util.REQUEST_STATUS_HC_COMPLIANCE;
            this.request.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_CCO;
            update this.request;

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setNextApproverIds(new Id[]{
                    this.user.Id
            });
            req.setObjectId(this.request.Id);

            Approval.ProcessResult result = Approval.process(req);

            List<Id> newWorkItemIds = result.getNewWorkitemIds();
            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Approve');
            req2.setNextApproverIds(new Id[]{
                    this.user.Id
            });
            req2.setWorkitemId(newWorkItemIds.get(0));

            Approval.ProcessResult result2 = Approval.process(req2);
        }

        public void setupController() {
            ApexPages.PageReference changeApproverPage = Page.GFRS_ChangeApprover;
            changeApproverPage.getParameters().put('id', this.request.Id);
            Test.setCurrentPage(changeApproverPage);

            this.controller = new GFRS_ChangeApproverController(new ApexPages.StandardController(this.request));
        }
    }

    static TestSettings testSetupMethod() {
        TestSettings testSettings = new TestSettings();
        testSettings.initialSetup();
        testSettings.setupUser();
        testSettings.setupIMED();
        return testSettings;
    }

    @IsTest
    static void testControllerSetup() {
        TestSettings testSettings = testSetupMethod();
        testSettings.setupController();

        // No process is running
        System.assert(!testSettings.controller.isProcessRunning);
        System.assert(!testSettings.controller.hasUserAccessToChangeApprover);
        System.assert(!testSettings.controller.wasApproverSaved);
        System.assertEquals(null, testSettings.controller.currentApprover);
        System.assertEquals(null, testSettings.controller.currentStatus);
        System.assertEquals(null, testSettings.controller.currentStep);
        System.assertEquals(null, testSettings.controller.currentStepStatus);

        // Controller has request assigned
        System.assertEquals(testSettings.request.Id, testSettings.controller.requestId);
        System.assertEquals(testSettings.request.Id, testSettings.controller.request.Id);
    }

    @IsTest
    static void testTriggerApproval() {
        TestSettings testSettings = testSetupMethod();
        System.runAs(testSettings.getUser()) {
            testSettings.triggerApproval();
            testSettings.setupController();

            System.assert(testSettings.controller.isProcessRunning);
            System.assertEquals(null, testSettings.controller.currentStepStatus);
            System.assertEquals('GC Review', testSettings.controller.currentStep);
            System.assertEquals('Pending', testSettings.controller.currentStatus);
            System.assertEquals('You don\'t have permission to change approver', testSettings.controller.message);
            System.assertEquals(null, testSettings.controller.currentApprover);
            System.assertNotEquals(null, testSettings.controller.currentApproverQueue);
            System.assertNotEquals(null, testSettings.controller.currentApproverId);
            System.assert(!testSettings.controller.wasApproverSaved);
            System.assert(!testSettings.controller.hasUserAccessToChangeApprover);
        }
    }

    @IsTest
    static void testBackAndSave() {
        TestSettings testSettings = testSetupMethod();
        System.runAs(testSettings.getUser()) {
            testSettings.triggerApproval();
            testSettings.setupController();

            testSettings.controller.dummyContact.OwnerId = UserInfo.getUserId();
            testSettings.controller.saveApprover();

            System.assert(testSettings.controller.wasApproverSaved);

            System.assertNotEquals(null, testSettings.controller.back());
        }
    }

    @IsTest
    static void testAssignToMe() {
        TestSettings testSettings = testSetupMethod();
        System.runAs(testSettings.getUser()) {
            testSettings.triggerApproval();
            testSettings.setupController();

            testSettings.controller.assignToMe();

            System.assert(testSettings.controller.wasApproverSaved);

            System.assertNotEquals(null, testSettings.controller.back());
        }
    }

    @IsTest
    static void testChangeApproverService() {
        TestSettings testSettings = testSetupMethod();
        System.runAs(testSettings.getUser()) {
            testSettings.triggerApproval();
            testSettings.setupController();

            testSettings.controller.dummyContact.OwnerId = UserInfo.getUserId();
            testSettings.controller.saveApprover();

            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

            email.subject = 'Change approver';
            Map<String, Object> parametersMap = new Map<String, Object>{
                    'Action' => 'Reassign',
                    'RecordId' => testSettings.controller.requestId,
                    'ApproverId' => UserInfo.getUserId()
            };
            email.plainTextBody = JSON.serialize(parametersMap);
            env.fromAddress = 'ilovenagpur@gmail.com';

            GFRS_ChangeApproverService service = new GFRS_ChangeApproverService();
            Messaging.InboundEmailResult result = service.handleInboundEmail(email, env);
            System.assert(result.success);
        }
    }
}