/**
* @author ADMD Team
* @date 2/04/2013
* @description gFRS_PaymentProcessTest class - Unit test class for payment/refund process.
*
*/
@isTest
private class gFRS_PaymentProcessTest {

    static testMethod void testRefundableDepositPayment() {
        ID LegalReviewerID = UserInfo.getUserId();
        Boolean hasProcess;

        List<ProcessInstance> processInstance;
        List<ProcessInstanceHistory> stepOrWorkItem;
        Approval.ProcessWorkitemRequest req;
        Approval.ProcessResult result;

        SetUpTestObjects testObjects = new SetUpTestObjects();
        system.assertEquals((testObjects.frId != null) ? true : false, true);

        test.StartTest();

        GFRS_OrgSettings__c myOrgCS = new GFRS_OrgSettings__c();
        myOrgCS.Funding_Request_Trigger_Enabled__c = true;
        myOrgCS.Validation_Rules_Enabled__c = true;
        myOrgCS.Workflow_Rules_Enabled__c = true;
        insert myOrgCS;

        system.debug('### Push request in to approval process.###');
        testObjects.objRequest.Sub_Status__c = 'CCO Review';
        testObjects.objRequest.Legal_Reviewer_1__c = LegalReviewerID;

        update testObjects.objRequest;

        //Check the request is in approval process.   
        processInstance = getCurrentProcessInstance(testObjects.frId);

        hasProcess = !(processInstance.isEmpty());
        system.assertEquals(hasProcess ? 'Request in approval process' : 'Request not in approval process', 'Request in approval process');

        //Approve Step: CCO Review. Get process instance work item.
        system.debug('Approve Step: CCO Review');
        result = processRequest(getWorkItemIds(testObjects.objRequest.Id)[0], 'CCO Review request approved.');
        system.assertEquals(result.isSuccess() ? 'CCO Review approved' : 'CCO Review approval error', 'CCO Review approved');

        //Get next approve step Legal Reviewer:
        system.debug('Approve Step: Legal Reviewer');
        result = processRequest(getWorkItemIds(testObjects.objRequest.Id)[0], 'Legal Reviewer request approved.');
        system.assertEquals(result.isSuccess() ? 'Legal Reviewer approved' : 'Legal Reviewer approval error', 'Legal Reviewer approved');


        //Get next approve step Financial Approver
        system.debug('Approve Step: Financial Approver');
        result = processRequest(getWorkItemIds(testObjects.objRequest.Id)[0], 'Financial Approver request approved.');
        system.assertEquals(result.isSuccess() ? 'Financial Approver approved' : 'Financial Approver approval error', 'Financial Approver approved');
        test.StopTest();
    }

    private static List<ProcessInstance> getCurrentProcessInstance(Id TargetObjectId) {
        return [
                Select Id, TargetObjectId, isDeleted, Status, (
                        Select Id, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments
                        From StepsAndWorkItems
                        Where
                        StepStatus = 'Pending' and
                        isDeleted = false
                        Order By
                                Createddate Desc
                        Limit 1
                )
                From ProcessInstance
                Where
                isDeleted = false and
                TargetObjectId = :TargetObjectId and
                Status = 'Pending'
                Order By
                        Createddate Desc
                Limit 1
        ];
    }

    private static List < Id > getWorkItemIds(Id targetObjectId) {
        List < Id > workitemIdList = new List < Id >();
        for (ProcessInstanceWorkitem workItem : [Select Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :targetObjectId]) {
            workitemIdList.add(workItem.Id);
        }
        return workitemIdList;
    }

    public static Approval.ProcessResult processRequest(Id workItemId, String comment) {
        Approval.ProcessResult process_result = null;
        try {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setAction('Approve');
            request.setWorkitemId(workItemId);
            request.setComments(comment);
            process_result = Approval.process(request);
        } catch (Exception ex) {
            System.debug('Error occurred while approving record');
        }
        return process_result;
    }

    private class SetUpTestObjects {
        public Account objAccount;
        public Contact objContact;
        public User objUser;
        public GFRS_Organization__c objOrg;
        public GFRS_Location__c objLoc;
        public GFRS_Funding_Request__c objRequest;

        public id frId; // Funding Request ID

        public SetUpTestObjects() {
            this.objAccount = gFRS_UnitTestHelper.CreateAccount('accTest');
            //this.objContact = gFRS_UnitTestHelper.CreateContact(this.objAccount.Id); -> contact not needed.
            this.objUser = gFRS_UnitTestHelper.CreateInternalGFRSUser();

            System.runAs(this.objUser) {
                this.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', this.objAccount.id);
                this.objLoc = gFRS_UnitTestHelper.CreateLocation('accTestLocation', this.objOrg.id);
                this.frId = gFRS_UnitTestHelperCorporateMembership.CreateCorpMemberRequestInStatusNew(objOrg.id, objLoc.id, this.objUser);
                this.objRequest = [SELECT Id, Sub_Status__c, Legal_Review__c FROM GFRS_Funding_Request__c WHERE Id = :this.frId];
            }
        }
    }

}