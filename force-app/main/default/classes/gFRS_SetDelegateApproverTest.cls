/**
* @author ADMD Team
* @date 03/09/2013
* @description Unit test class for testing user delegation. For approval process object need have SeeAllData
*
*/
@isTest(SeeAllData=true)
private class gFRS_SetDelegateApproverTest
{

    /**
    * @author ADMD Team
    * @date 03/09/2013
    * @description  
    */
    static testMethod void testSetDelegateApprover()
    {
        GFRS_Funding_Request__c objReq;
        List<ProcessInstance> processInstance;
        List<ProcessInstanceHistory> stepOrWorkItem;
        Approval.ProcessWorkitemRequest req;
        Approval.ProcessResult result;  
        
        Boolean hasProcess;
        
        id currentUserid = UserInfo.getUserId();
        id delegateRecordId;
        
        SetUpTestObjects testObjects = new SetUpTestObjects();
        system.assertEquals((testObjects.frId!=null) ? true : false , true);
        system.debug('Insert delegate record');
        
        
        test.StartTest();
        
        system.debug('### Create delegate record ###');
        delegateRecordId = gFRS_UnitTestHelper.createUserDelegateRecord(currentUserid,UserInfo.getUserName(), testObjects.objDelegatedUser.id );
        system.assertEquals((delegateRecordId!=null) ? 'Delegation inserted ok' : 'Delegation insert fails!' , 'Delegation inserted ok');
        
        system.debug('### Push request in to approval process.###');
        objReq = [Select Id, Legal_Reviewer_1__c, Sub_Status__c from GFRS_Funding_Request__c where id=: testObjects.frId];
        objReq.Sub_Status__c = 'CCO Review';
        objReq.Legal_Reviewer_1__c = currentUserid; // testObjects.objUser.Id;
        System.debug('objReq.Legal_Reviewer_1__c ->' + currentUserid);
        //testObjects.setFundingReqestTriggerMode(false);
        update objReq;
        //testObjects.setFundingReqestTriggerMode(true);
        system.debug('### Check is legal reviewer is set ###');
        objReq = [Select Id, Legal_Reviewer_1__c, Sub_Status__c from GFRS_Funding_Request__c where id=: testObjects.frId];
        system.assertEquals(objReq.Legal_Reviewer_1__c, currentUserid);
        
        system.debug('### Check the request is in approval process ###');   
        processInstance = getCurrentProcessInstance(testObjects.frId);
        hasProcess = ! (processInstance.isEmpty());
        system.assertEquals(hasProcess ? 'Request in approval proccess' : 'Request not in approval process' , 'Request in approval proccess');
        
        
        system.debug('### Push request into next step Legal Reviewer ###');
        stepOrWorkItem =  processInstance[0].StepsAndWorkItems;
        system.debug('Approve Step: Legal Reviewer');
        req = new Approval.ProcessWorkitemRequest();
        req.setNextApproverIds(null);  // No further approvals for this step needed.
        req.setWorkitemId(stepOrWorkItem[0].Id);                
        req.setComments('Legal Reviewer request approved.');
        req.setAction('Approve');
        result = Approval.process(req);        
        system.assertEquals(result.isSuccess() ? 'Legal Reviewer approved' : 'Legal Reviewer appoval error' , 'Legal Reviewer approved'); 
        
        system.debug('### Prepare re-assigment to delegate ###');
        processInstance = getCurrentProcessInstance(testObjects.frId);
        stepOrWorkItem =  processInstance[0].StepsAndWorkItems;
        User u = [select UserName from User where id=:stepOrWorkItem[0].ActorId];
        system.debug('User->' + u.UserName);  
          
        system.debug('###  Run re-assign to delegate backend functionality ###');
        List<GNE_User_Delegation__c> listUserDelegations = [select Id, Name, Delegated_User__c,Username__c, Is_Delegation_Active__c from GNE_User_Delegation__c where id=: delegateRecordId];
        system.debug('Is delegation active?->' + listUserDelegations[0].Is_Delegation_Active__c);
        system.assertEquals(listUserDelegations[0].Is_Delegation_Active__c, 'Yes');
        gFRS_SetDelegateApprover objSetDelegate = new gFRS_SetDelegateApprover();
        objSetDelegate.processDelegateApprovers(listUserDelegations);
        
        system.debug('### Check is process work item has been re assigned to delegate ###');
        processInstance = getCurrentProcessInstance(testObjects.frId);  
        stepOrWorkItem =  processInstance[0].StepsAndWorkItems;
        system.debug(processInstance);
        system.debug ('stepOrWorkItem[0].ActorId->' + stepOrWorkItem[0].ActorId + ' delegate id should be ->' + testObjects.objDelegatedUser.id);
        system.assertEquals(listUserDelegations[0].Delegated_User__c,stepOrWorkItem[0].ActorId);
        
        test.StopTest(); 
    }
    
    
    private static List<ProcessInstance> getCurrentProcessInstance(Id TargetObjectId)
    {
        return [Select Id, TargetObjectId, isDeleted, Status,
                    (
                        Select Id, ProcessInstanceId, ActorId, Actor.Name, StepStatus, Comments 
                        From StepsAndWorkItems
                        Where 
                            StepStatus = 'Pending'  and
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
    
     /**
    * @author ADMD Team
    * @date 03/09/2013
    * @description Private class for setting up test data
    * .
    */
    private class SetUpTestObjects
    {
        public Account objAccount;
        public Contact objContact;
        public User objUser;
        public User objDelegatedUser;
        public GFRS_Organization__c objOrg;
        public GFRS_Location__c objLoc;
        
        public id frId; // Funding Request ID
                
        public SetUpTestObjects()
        { 
            try
            {
                setFundingReqestTriggerMode(false);
        
                this.objAccount = gFRS_UnitTestHelper.CreateAccount('accTest'); 
                this.objDelegatedUser = gFRS_UnitTestHelper.CreateInternalGFRSUser('TestInternal.Delegate@gene.com');       
                this.objUser = gFRS_UnitTestHelper.CreateInternalGFRSUser();
            
                System.runAs(this.objUser)
                { 
                 this.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', this.objAccount.id );
                 this.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', this.objOrg.id );
                 this.frId = gFRS_UnitTestHelperCorporateMembership.CreateCorpMemberRequestInStatusNew(objOrg.id, objLoc.id,this.objUser);
                }
                setFundingReqestTriggerMode(true); 
            }
            catch(Exception ex)
            {
                system.debug('SetUpTestObjects exception->' + ex.getMessage());
            }
        }
        
        private void setFundingReqestTriggerMode(boolean mode)
        {
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            myOrgCS.Funding_Request_Trigger_Enabled__c = mode;
            upsert myOrgCS; 
        }
    }
}