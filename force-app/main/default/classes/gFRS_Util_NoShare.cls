/**
*  Utility methods that DO NOT USE SHARING RULES.
*
*  <p>WARNING: be careful which methods are placed here and verify that they are necessary</p>
**/
public without sharing class gFRS_Util_NoShare {
    
    public static final String TIMESTAMP_FORMAT = 'MMddyyyy_HH_mm_ss';
    private static final String RECONCILIATION_PAGE_NAME = 'Reconciliation';
    public static final String PAYMENT_SUCCESSFULLY_SUBMITTED = 'Submitted';
    public static final String PAYMENT_SUCCESS = 'Success';
    public static Boolean trigBoolean = false;
    public static Boolean triggerBoolean = false;
    
    private static Map<String, Id> mapGNEUserDelegationCache;
    private static Map<Id, Id> mapPSStandardUserDelegationCache;
    
    public static final String PENDING = 'Pending';
    public static final String REJECTED = 'Rejected';
    public static final Set<String> BUSINESS_APPROVAL_STEPS = new Set<String>{
        'Business Approver', 'Financial Approver 1', 'Financial Approver 2', 'Financial Approver 3'
            };
                
                /**
* Create default line items for Funding Allocation
* <p>PostCondition: allocation Line Items are made for funding allocations of type IMED, based on the WBS Codes found that match the theraputic area</p>
* <p>PostCondition: 5 blank allocation Line Items are made for funding allocations for internal funding requests</p>
* <p>PostCondition: a single blank allocation line item is made for all other funding allocation types</p>
* @param fundingAllocation (GFRS_Funding_Allocation__c[])
* @param newMap (Map<Id,GFRS_Funding_Allocation__c>)
*/
                
                
                /**
*  Method to determine if there is a funding request that is outstanding on reconciliation for the past 91 days
*  @return GFRS_Funding_Request__c[] (list of funding requests that is outstanding reconciliation)
**/
                public static GFRS_Funding_Request__c[] findOverdueReconciliations() {
                    Set<Id> usersIds = new Set<Id>{UserInfo.getUserId()};
                        List<User> account = [SELECT Contact.AccountId FROM User WHERE Id IN : usersIds AND Contact.AccountId != null LIMIT 1];
                    if(!account.isEmpty()) {
                        for(User u : [SELECT Id FROM User WHERE Contact.AccountId =: account.get(0).Contact.AccountId]) {
                            usersIds.add(u.Id);
                        }
                    }
                    
                    Date lastValidDate = Date.today().addDays(-91);
                    GFRS_Funding_Request__c[] overdueRequests = [
                        SELECT Id, Record_Type_Name__c, Program_End_Date_max__c, Status__c,
                        Sub_Status__c,Refund_Request_Date__c
                        FROM GFRS_Funding_Request__c
                        WHERE (OwnerId IN : usersIds)
                        AND Record_Type_Name__c = :gFRS_Util.TYPE_IMED_NAME
                        AND Sub_Status__c = :gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ
                        AND Program_End_Date_max__c <= :lastValidDate
                    ];
                    
                    return(overdueRequests);
                }
    
    /**
*  Method to determine the funding requests WHERE the refund is delinquent.
*  <p>if 31 days has passed the reconciled date and refund has not been received and the sub-status = Refund Required</p>
*  @return GFRS_Funding_Request__c[] - list of funding requests the refund is overdue
**/
    public static GFRS_Funding_Request__c[] findOverdueRefunds() {
       // Id userId = UserInfo.getUserId();
        Set<Id> usersIds = new Set<Id>{UserInfo.getUserId()};
            List<User> account = [SELECT Contact.AccountId FROM User WHERE Id IN : usersIds AND Contact.AccountId != null LIMIT 1];
        if(!account.isEmpty()) {
            for(User u : [SELECT Id FROM User WHERE Contact.AccountId =: account.get(0).Contact.AccountId]) {
                usersIds.add(u.Id);
            }
        }       
        GFRS_Funding_Request__c[] overdueRequests = [
            SELECT Id, Record_Type_Name__c, Status__c, Sub_Status__c,Refund_Request_Date__c
            FROM GFRS_Funding_Request__c
            WHERE (OwnerId IN :usersIds )
            AND Record_Type_Name__c = :gFRS_Util.TYPE_IMED_NAME
            AND Sub_Status__c = :gFRS_Util.REQUEST_SUB_STATUS_REFUND_REQ
        ];
        
        return(overdueRequests);
    }
    
    /**
* @author GFRS Dev Team
* @date 09/02/2015
* @description findOverdueSunshineActDisclosures method - check whether User has live programs with End Date > 91 days
*/
    public static GFRS_Funding_Request__c[] findOverdueSunshineActDisclosures() {
        Id userId = UserInfo.getUserId();
        Date lastValidDate = Date.today().addDays(-91);
        GFRS_Funding_Request__c[] overdueRequests = [
            SELECT Id, Record_Type_Name__c, Last_Live_Program_End_Date__c
            FROM GFRS_Funding_Request__c
            WHERE (OwnerId = :userId )
            AND Record_Type_Name__c = :gFRS_Util.TYPE_IMED_NAME
            AND Last_Live_Program_End_Date__c <= :lastValidDate
            AND Sunshine_Act_Disclosure_Submitted__c = 'No'
        ];
        
        return(overdueRequests);
    }
    
    /**
* @author GFRS Dev Team
* @date 26/02/2015
* @description findOverdueEvaluations method - check whether User has live programs with End Date > 91 days
*/
    public static GFRS_Funding_Request__c[] findOverdueEvaluations() {
        Id userId = UserInfo.getUserId();
        Date lastValidDate = Date.today().addDays(-91);
        GFRS_Funding_Request__c[] overdueRequests = [
            SELECT Id, Record_Type_Name__c, Program_End_Date_max__c, Last_Live_Program_End_Date__c
            FROM GFRS_Funding_Request__c
            WHERE (OwnerId = :userId )
            AND Program_End_Date_max__c <= :lastValidDate
            AND Sub_Status__c = :gFRS_Util.REQUEST_SUB_STATUS_EVALUATIONS
            AND (Evaluation_Completed__c = 'No'
                 OR Evaluation_Completed__c = '')
        ];
        
        return(overdueRequests);
    }
    
    /**
*  Finds the tasks associated with an INTERNAL user
*  @param userId
*  @return gFRS_Tasks__c[]
**/ 
    //method modified for sfdc-1508 in sepc 4.02
    public static gFRS_Tasks__c[] fetchUserTasks(List<GFRS_Funding_Request__c> listFund, Id userId) {
        return([
            SELECT Id,Action_Type__c, Annual_Evaluation__c, User__c, User__r.Name, gFRS_Funding_Request__c,
            gFRS_Funding_Request__r.Name, Subject__c, Status__c, Description__c, IsDeleted, gFRS_Funding_Request__r.Record_Type_Name__c,
            CreatedDate,gFRS_Funding_Request__r.CreatedDate, CreatedBy.Name, LastModifiedBy.Name,
            gFRS_Funding_Request__r.Event_Program_Title__c, gFRS_Funding_Request__r.Sunshine_Act_Disclosure_Submitted__c,
            gFRS_Funding_Request__r.Requested_Amount__c,gFRS_Funding_Request__r.External_Sub_status__c,
            gFRS_Funding_Request__r.Information_Needed__c,gFRS_Funding_Request__r.Authorized_Signer__c,RFI_Link__c,
            gFRS_Funding_Request__r.CreatedById, Years_Before_Annual_Evaluation__c, gFRS_Funding_Request__r.OwnerId,
            gFRS_Funding_Request__r.Sunshine_Communication_Sent__c, gFRS_Funding_Request__r.Reconciliation_Required_Status_Date__c,
            gFRS_Funding_Request__r.Program_End_Date_max__c,gFRS_Funding_Request__r.Reconciliation_due_date__c,gFRS_Funding_Request__r.Refund_Request_Date__c
            FROM gFRS_Tasks__c
            WHERE gFRS_Funding_Request__c IN :listFund
            AND ((Action_Type__c != 'Status Report'
                  AND Action_Type__c != 'Outcomes'
                  AND Action_Type__c != 'Annual Evaluation'
                  AND Status__c != :gFRS_Util.TASK_COMPLETED)
                 OR (Action_Type__c = 'Annual Evaluation'
                     AND Status__c = :gFRS_Util.TASK_NOT_SUBMITTED)
                 OR (Action_Type__c = 'Status Report'
                     AND (gFRS_Funding_Request__r.Record_Type_Name__c = 'Exhibits & Other Promos'
                     OR gFRS_Funding_Request__r.Record_Type_Name__c = 'Sci/Pipeline Exhibits & Other Non-Promo')))
            ORDER BY gFRS_Funding_Request__r.Name DESC
            LIMIT 1000
        ]);
    }
    
    public static gFRS_Tasks__c[] fetchUserOngoingTasks(List<GFRS_Funding_Request__c> listFund, Id userId) {
        return([
            SELECT Id, Action_Type__c, User__c, User__r.Name, gFRS_Funding_Request__c, gFRS_Funding_Request__r.Name,
            Subject__c, Status__c, Description__c, IsDeleted, CreatedDate,gFRS_Funding_Request__r.CreatedDate,
            CreatedBy.Name, LastModifiedBy.Name, gFRS_Funding_Request__r.Event_Program_Title__c, gFRS_Funding_Request__r.Record_Type_Name__c,
            gFRS_Funding_Request__r.Requested_Amount__c,gFRS_Funding_Request__r.External_Sub_status__c,
            gFRS_Funding_Request__r.Information_Needed__c,gFRS_Funding_Request__r.Authorized_Signer__c,RFI_Link__c,
            gFRS_Funding_Request__r.CreatedById, gFRS_Funding_Request__r.OwnerId, gFRS_Funding_Request__r.Reconciliation_Required_Status_Date__c
            FROM gFRS_Tasks__c
            WHERE ((Action_Type__c = 'Status Report')
                   OR Action_Type__c = 'Outcomes')
            AND gFRS_Funding_Request__r.Record_Type_Name__c != 'Exhibits & Other Promos'
            AND gFRS_Funding_Request__r.Record_Type_Name__c != 'Sci/Pipeline Exhibits & Other Non-Promo'
            AND gFRS_Funding_Request__c IN :listFund
            ORDER BY gFRS_Funding_Request__r.Name DESC
            LIMIT 1000
        ]);
    }
    /**
*  Creates a 'Task' for a funding request.
*  <p>since Portal users CANNOT own an activity or task, we got put in a bind,
*  so this custom object is simply another implemntation of the task, to sidestep
*  that limitation.</p>
*  @param status (String)
*  @param subject (String)
*  @param description (String)
*  @param requestId (Id<GFRS_Funding_Request__c>) Id of the funding request - effectively whatId
*  @param ownerId (Id<User>) - Id of the owner
*  @throws DMLException - if a dml exception occurs
*  @return gFRS_Tasks__c - the task created
**/
    //SFDC-1508 spec 4.02 method changed
    public static void createTask(String status, String subject, String description, Id requestId, Id ownerId, String actionType) {
        gFRS_Tasks__c result = new gFRS_Tasks__c(
            Status__c = status,
            Subject__c = subject,
            Description__c = description,
            gFRS_Funding_Request__c = requestId,
            User__c = ownerId,
            Action_Type__c = actionType
        );
        insert result;
        
    }
    
    /**
*  Allows a portal user to complete a task
*  @param task Task
**/
    //public static void completeTask(  List<gFRS_Tasks__c> lTsk2complete ){
    //    /*
    //     *Method should have Status__c field in handled list
    //     *commented out due to fact its not used
    //     */
    //    try{
    //        if( lTsk2complete.size() > 0 ){
    
    //            for (gFRS_Tasks__c task : lTsk2complete){
    //                 task.Status__c = gFRS_Util.TASK_COMPLETED;
    //            }
    
    //            update lTsk2complete;
    //            }
    //        }
    //        catch (Exception e){
    //            System.debug('Error occured while updating tasks gFRS_Util_NoShare.completeTask > '+e.getMessage());
    //        }
    //}
    
    /**
* Creates an Account from an organization and associates a user with that account.
* @param organization GFRS_Organization__c
* @return Account - the account created
**/
    public static Account createAccountFromOrganization(GFRS_Organization__c organization) {
        if (organization == null || organization.Organization_Name__c == null) {
            return(null);
        }
        
        RecordType gfrAccountRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'gFRS' AND SobjectType = 'Account' LIMIT 1];
        Account targetAccount = new Account(Name = organization.Organization_Name__c, RecordTypeId = gfrAccountRT.Id);
        insert targetAccount;
        
        return(targetAccount);
    }
    
    /**
*  Associates a user with an account
*  @param userId (Id) the Id of the user
*  @param accountId (Id) the Id of the account
*  @param organizationId (Id) the Id of the organization
*  @return Boolean - whether the account could be associated (true) or not (false)
**/
    public static Boolean associateUserWithAccount(Id userId, Id accountId, Id organizationId) {
        User targetUser = null;
        try {
            targetUser = [
                SELECT Id, Contact.Id, Contact.Account.Id
                FROM User
                WHERE Id = :userId
            ];
        } catch (Exception err) {
            System.debug('could not find user:' + userId);
            return(false);
        }
        
        if (targetUser == null || targetUser.ContactId == null || targetUser.Contact.Id == null) {
            System.debug('not a portal user so stop');
            return(false);
        }
        
        targetUser.Contact.AccountId = accountId;
        targetUser.Contact.Organization__c = organizationId;
        update targetUser.Contact;
        
        return(true);
    }
    
    /**
*  Applies sharing rusles for newly created users.
*  @param String userEmail
*  @param Id userId
**/
    public static Boolean applySharingRulesForNewUser(String userEmail, Id userId) {
        try {
            GFRS_Funding_Request__c[] requests = [
                SELECT Id, Name, Organization__c
                FROM GFRS_Funding_Request__c
                WHERE Signing_Authority_Email__c = :userEmail AND Status__c != 'Closed'
            ];
            if (requests.size() > 0) {
                List<GFRS_Funding_Request__Share> requestShrs = new List<GFRS_Funding_Request__Share>();
                List<GFRS_Funding_Request__c> requestsToUpdate = new List<GFRS_Funding_Request__c>();
                for (GFRS_Funding_Request__c request : requests) {
                    GFRS_Funding_Request__Share requestShr = new GFRS_Funding_Request__Share();
                    requestShr.ParentId = request.Id;
                    requestShr.UserOrGroupId = userId;
                    requestShr.AccessLevel = 'Edit';
                    requestShr.RowCause = Schema.GFRS_Funding_Request__Share.RowCause.Manual;
                    requestShrs.add(requestShr);
                    
                    request.Authorized_Signer__c = userId;
                    requestsToUpdate.add(request);
                }
                
                Database.SaveResult[] lsr = Database.insert(requestShrs, false);
                System.debug(lsr);
                
                // Process the save results
                for (Database.SaveResult sr : lsr) {
                    
                    if (!sr.isSuccess()) {
                        Database.Error err = sr.getErrors()[0];
                        System.debug(err.getMessage());
                        return false;
                    }
                }
                update requestsToUpdate;
            }
            return true;
        } catch (Exception err) {
            //-- exception is not caught BY SIMMS, so we catch it here
            System.debug('exception caught:' + err.getMessage());
            return(false);
        }
        
    }
    
    /**
*  Applies sharing rules for selected Funding Request and specified users (after the Fund Reg is being submitted)
*  @param Id requestId
*  @param String targetEmail - email of the users to share the funding request with.
*  @return Boolean - success or failure
**/
    public static Boolean applySharingRulesForSelectedUsers(Id requestId, String targetEmail) {
        
        User[] users = [SELECT Id, Email FROM User WHERE Email = :targetEmail];
        
        if (requestId != null && users.size() > 0) {
            List<GFRS_Funding_Request__Share> requestShrs = new List<GFRS_Funding_Request__Share>();
            for (User us1 : users) {
                GFRS_Funding_Request__Share requestShr = new GFRS_Funding_Request__Share();
                requestShr.ParentId = requestId;
                requestShr.UserOrGroupId = us1.Id;
                requestShr.AccessLevel = 'Edit';
                requestShr.RowCause = Schema.GFRS_Funding_Request__Share.RowCause.Manual;
                requestShrs.add(requestShr);
            }
            
            Database.SaveResult[] lsr = Database.insert(requestShrs, false);
            //System.debug(lsr);
            
            // Process the save results
            for (Database.SaveResult sr : lsr) {
                //System.debug(sr.isSuccess());
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                    return false;
                }
            }
            
        }
        
        
        return true;
    }
    /*
commented for sfdc-1508 spec 4.02 tasked will be created in trigger before update FR
public static void createReconciliationTask( GFRS_Funding_Request__c[] requests, Map<Id,GFRS_Funding_Request__c> oldMap ){
GFRS_Funding_Request__c[] changedRequests = new GFRS_Funding_Request__c[]{};
gFRS_ObjectUtil.filterChangedObjects( requests, oldMap, 'Sub_Status__c', changedRequests );

System.debug(changedRequests);
if( changedRequests != null && changedRequests.size() > 0 ){
GFRS_Funding_Request__c[] changedRequestsDetailed = [SELECT Id, Name, ownerId, Sub_Status__c FROM GFRS_Funding_Request__c WHERE Id IN :changedRequests];
String taskSubject = 'Reconciliation Required';

for(GFRS_Funding_Request__c req : changedRequestsDetailed){
if(gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ.equals(req.Sub_Status__c)){
String taskBody = 'Please provide a reconciliation for Funding Request: '+req.Name;
gFRS_Tasks__c newTask = gFRS_Util_NoShare.createTask( gFRS_Util.TASK_NOT_STARTED, taskSubject, taskBody, req.Id, req.ownerId );
}
}
}
}
*/
    
    /**
*  Attempts to find a user Id based on a given SFDC Id
*  @param String user identifier
*  @return Id
**/
    public static User getUserById(final Id userId) {
        try {
            return [SELECT Name, External_ID_gne__c, Profile.Name FROM User WHERE Id = :userId LIMIT 1];
        } catch (Exception err) {
            System.debug('unable to find user:' + userId);
            return new User(Id = userId);
        }
    }
    
    /**
*  Attempts to find a user Id based on a given unixId
*  @param String unixId
*  @return Id
**/
    public static Id getUserByUnixId(String unixId) {
        try {
            return([SELECT Id FROM User WHERE External_ID_gne__c = :unixId LIMIT 1][0].Id);
        } catch (Exception err) {
            System.debug('unable to find user:' + unixId);
            return(null);
        }
    }
    
    /*--
<p>A problem came, WHERE the internal users want to RFI a request that is currently
in the approval process, which means that the record is locked. However, the RFI
is intended so the external user will provide more information (update the request).
This combines to become a problem since the request is not UNLOCKED, which requires
quite a bit of additional work to bypass the lock.</p>

<p>Multiple options were considered, but the two options that were viable were to
give the external users MODIFY ALL access to the funding requests (which bypasses
sharing and is considered a big risk), or to have the modifications in each of the
pages up to the confirmation be done in a WITHOUT SHARING context. The choice was
made to go with the second approach: below</p>
--*/
    
    /**
*  Attempts to UNLOCK a funding Request
*  @param Id<GFRS_Funding_Request__c> requestId
*  @return Boolean
**/
    public static void saveLockedFundingRequest(GFRS_Funding_Request__c request) {
        
        //--JIRA 159
        
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        
        
        if(request.Signing_Authority_Email__c !=null && request.Accountable_Employee_Approval__c!=null && userProfile.Name=='GNE-GFRS-Backoffice'){
            request.ownerId=request.Accountable_Employee_Approval__c;
            request.Payment_Delivery_Notifications__c=request.Accountable_Employee_Approval__c;
          /*  if(request.Payment_Delivery_Notifications__c==null){
              request.Payment_Delivery_Notifications__c=request.Accountable_Employee_Approval__c;
            } */
        }
        
        //--JIRA 159
        
        //POC of additionall field on funding request
        request.IsValidationExternalOnly__c = 'Yes';
        update request;
        
        //--JIRA 159
        
        
        if(request.Signing_Authority_Email__c !=null && request.Accountable_Employee_Approval__c!=null){
            List<GFRS_Funding_Request__Share> requestShrs = new List<GFRS_Funding_Request__Share>();
            GFRS_Funding_Request__Share requestShr = new GFRS_Funding_Request__Share();
            requestShr.ParentId = request.Id;
            requestShr.UserOrGroupId = Userinfo.getUserId();
            requestShr.AccessLevel = 'Read';
            requestShr.RowCause = Schema.GFRS_Funding_Request__Share.RowCause.Manual;
            requestShrs.add(requestShr);
            Database.SaveResult[] lsr = Database.insert(requestShrs, false);
        }
        //--JIRA 159
        

    }
    
    public static void saveLockedFundingRequestInternalPage(GFRS_Funding_Request__c request) {
        update request;
    }
    
    public static void saveLockedFundingRequests(GFRS_Funding_Request__c[] requests) {
        update requests;
    }
    
    public static void saveLockedOrganization(GFRS_Organization__c org) {
        org.IsValidationExternalOnly__c = 'Yes';
        upsert org;
    }
    
    public static void saveLockedLocation(GFRS_Location__c location) {
        upsert location;
    }
    
    public static void saveLockedAttachment(Attachment a) {
        upsert a;
    }
    
    public static void saveLockedTask(gFRS_Tasks__c tsk) {
        upsert tsk;
    }    
    
    public static void saveAchAttObject(CustomObject__c c){
        insert c;
    }    
    
    public static void deleteLockedAttachment(Attachment a) {
        delete a;
    }
    
    public static void deleteLockedAttachments(Attachment [] attachments) {
        delete attachments;
    }
    
    public static void saveLockedPaymentHistories(GFRS_Payment_History__c[] paymentHistories) {
        upsert paymentHistories;
    }
    
    public static void deleteLockedPaymentHistories(GFRS_Payment_History__c paymentHistory) {
        delete paymentHistory;
    }
    
    public static void saveLockedProgram(GFRS_Program__c program) {
        program.IsValidationExternalOnly__c = 'Yes';
        upsert program;
    }
    
    public static void saveLockedPrograms(GFRS_Program__c[] programs) {
        for (GFRS_Program__c prog : programs) {
            prog.IsValidationExternalOnly__c = 'Yes';
        }
        upsert programs;
    }
    
    public static void savePrograms(GFRS_Program__c[] programs) {
        update programs;
    }    
    
    public static void saveLockedProgramDesign(gFRS_Program_Design_and_Implementation__c program_Design) {
        upsert program_Design;
    }
    
    /**
*  Removes programs even if the request is currently locked.
*  <p>Requests are ONLY removed BY CMEO which is optional based on values on the funding request.</p>
**/
    public static void removeLockedPrograms(GFRS_Program__c[] programs) {
        delete programs;
    }
    
    public static void saveLockedProgramAudience(GFRS_Program_Audience_Group__c[] audience) {
        upsert audience;
    }
    
    public static void removeLockedProgramAudience(GFRS_Program_Audience_Group__c[] audience) {
        delete audience;
    }
    
    public static void saveLockedBudgets(GFRS_RequestBudget__c[] budgets) {
        upsert budgets;
    }
    
    public static void saveLockedBudgetLIs(GFRS_Request_Budget_Line_Item__c[] lineItems) {
        upsert lineItems;
    }
    
    public static void removeLockedBudget(GFRS_RequestBudget__c[] budgets) {
        delete budgets;
    }
    
    public static void removeLockedBudgetLIs(GFRS_Request_Budget_Line_Item__c[] lineItems) {
        delete lineItems;
    }
    
    public static void removeTasks(List<gFRS_Tasks__c> taskList) {
        delete taskList;
    }
    
    public static void removeTask(gFRS_Tasks__c task) {
        delete task;
    }        
    
    public static void saveLockedAllocationLI(GFRS_Funding_Allocation_Line_Item__c allocationLI) {
        update allocationLI;
    }
    
    public static void saveLockedAllocationLIs(GFRS_Funding_Allocation_Line_Item__c[] allocationLIs) {
        update allocationLIs;
    }
    
    public static void saveLockedThirdParties(gFRS_Third_Party__c[] thirdParties) {
        upsert thirdParties;
    }
    
    public static void saveLockedUserDelegation(GNE_User_Delegation__c userDelegation) {
        upsert userDelegation;
    }
    
    public static void removeLockedThirdParties(gFRS_Third_Party__c[] thirdParties) {
        delete thirdParties;
    }
    
    public static void saveLockedFundingAllocation(GFRS_Funding_Allocation__c fundingAllocation) {
        update fundingAllocation;
    }
    /**
*  inserts sharing records for funding requsts
**/
    public static Database.SaveResult[] insertRequestShares(GFRS_Funding_Request__Share[] requestShares) {
        return(Database.insert(requestShares, false));
    }
    
    /**
* @author GFRS Dev Team
* @date 21/11/2013
* @description method upsert manual sharing for funding requests
*/
    public static void upsertRequestShares(
        final GFRS_Funding_Request__Share[] shares,
        final Map<Id, GFRS_Funding_Request__c> reqs
    ) {
        if (shares.size() > 0) {
            final Database.UpsertResult[] results = Database.upsert(shares, !Trigger.isExecuting);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error err : results[i].getErrors()) {
                        // check if the error is related to a trivial access level;
                        // access levels equal or more permissive than the object's default access level are not allowed;
                        // these sharing records are not required and thus an insert exception is acceptable;
                        if (!(
                            err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&
                            err.getMessage().contains('AccessLevel')
                        ) && reqs.containsKey(shares[i].ParentId)) {
                            reqs.get(shares[i].ParentId).addError('Unable to grant access due to following error: ' + err.getMessage());
                        }
                        System.debug(LoggingLevel.ERROR, 'Unable to grant access due to following error: ' + err);
                    }
                }
            }
        }
    }
    
    public static User[] userByEmail(String p_email) {
        return [SELECT Id, FirstName, LastName, Email FROM User WHERE Email = :p_email LIMIT 1];
    }
    
    public static String getUserPIN(String p_Id) {
        return [SELECT Security_PIN__c FROM User WHERE Id = :p_Id].Security_PIN__c;
    }
    
    
    /**
* @author GFRS Dev Team - Melvin
* @date 17/08/2014
* @description createAppropriateTask method - creates gFRS Tasks.
*/
    public static void createAppropriateTask(GFRS_Funding_Request__c[] requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        
        List<GFRS_Funding_Request__c> changedRequests       = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> changedRequestsSecond = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> changedRequestsExternalSubStatus = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> changedSunshineRequests = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> changedSunshineRequests2 = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> changedFundingType = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> changedACHReq = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> changedStatusUpdSubmitted = new List<GFRS_Funding_Request__c>();
        
        Set<GFRS_Funding_Request__c> requestsToMerge = new Set<GFRS_Funding_Request__c>();
        
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'Sub_Status__c', changedRequests);
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'Status__c', changedRequestsSecond);
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'External_Sub_status__c', changedRequestsExternalSubStatus);
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'Sunshine_Act_Disclosure_Submitted__c', changedSunshineRequests);
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'Sunshine_Communication_Sent__c', changedSunshineRequests2);
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'RecordTypeId', changedFundingType);
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'ACH_Received__c', changedACHReq);
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'Status_Updates_Submitted__c', changedStatusUpdSubmitted);
        //
        requestsToMerge.addAll(changedRequestsSecond);
        requestsToMerge.addAll(changedRequestsExternalSubStatus);
        requestsToMerge.addAll(changedSunshineRequests);
        requestsToMerge.addAll(changedSunshineRequests2);
        requestsToMerge.addAll(changedFundingType);
        requestsToMerge.addAll(changedACHReq);
        requestsToMerge.addAll(changedStatusUpdSubmitted);
        
        for (GFRS_Funding_Request__c item : requestsToMerge) {
            Boolean isEqual = false;
            for (GFRS_Funding_Request__c tmpRequest : changedRequests) {
                if (tmpRequest.Id == item.Id) {
                    isEqual = true;
                    break;
                }
            }
            if (!isEqual) {
                changedRequests.add(item);
            }
        }
        
        
        Map<Id, GFRS_Funding_Request__c> lTasks = new Map<Id, GFRS_Funding_Request__c>();
        Map<Id, GFRS_Funding_Request__c> reqLoc = new Map<Id, GFRS_Funding_Request__c>(requests);
        if (changedRequests.size() > 0) {
            lTasks = new Map<Id, GFRS_Funding_Request__c>(
                [
                    SELECT
                    (
                        SELECT Subject__c,CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c
                        FROM gFRS_Tasks__r
                        WHERE Status__c != 'Closed'
                    ), Id, Sub_Status__c, Authorized_Signer__c, Signing_Authority_Email__c, Location__c, Location__r.Partner_Bank_Type__c 
                    FROM GFRS_Funding_Request__c
                    WHERE Id IN :changedRequests
                ]);
        }
        
        Set<gFRS_Tasks__c> tasksToClose = new Set<gFRS_Tasks__c>();
        Set<gFRS_Tasks__c> tasksToAdd = new Set<gFRS_Tasks__c>();
        Set<ID> reqUpd = new Set<ID>();
        Set<ID> reqUpd2 = new Set<ID>();
        Set<Id> reqIds = new Set<Id>();
        Id currentUser = UserInfo.getUserId();
        
        Map<String, List<GFRS_Funding_Request__c>> reqMap = new Map<String, List<GFRS_Funding_Request__c>>();
        List<GFRS_Funding_Request__c> reqsToUpd = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> reqsToUpd2 = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> reqList = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> reqSize = new List<GFRS_Funding_Request__c>();
        List<GFRS_Funding_Request__c> reqAuthSigner = new List<GFRS_Funding_Request__c>();
        List<String> authSigner = new List<String>();
        List<id> locIds = new List<id>();
        
        for(GFRS_Funding_Request__c req : changedRequests){
            authSigner.add(req.Signing_Authority_Email__c);
            locIds.add(req.Location__c);
        }
        
        if(!gFRS_Util.isExternalRequestor(UserInfo.getUserId()) && triggerBoolean == false){
            reqAuthSigner = [Select id, name, Signing_Authority_Email__c FROM GFRS_Funding_Request__c WHERE Location__c IN : locIds AND Signing_Authority_Email__c IN : authSigner AND ACH_Received__c = 'ACH'];
            
            if(reqAuthSigner.size() > 0){
                for(GFRS_Funding_Request__c req : reqAuthSigner){
                    if(reqMap.containsKey(req.Signing_Authority_Email__c)){
                        reqList = reqMap.get(req.Signing_Authority_Email__c);
                        reqList.add(req);
                        reqMap.put(req.Signing_Authority_Email__c, reqList);
                    }
                    else{
                        reqList.add(req);
                        reqMap.put(req.Signing_Authority_Email__c, reqList);
                    }
                }
            }
        }
        
        for (GFRS_Funding_Request__c item : changedRequests) {
            system.debug(item);
            system.debug(lTasks.get(item.Id).gFRS_Tasks__r);
            
            if(!gFRS_Util.isExternalRequestor(UserInfo.getUserId()) && triggerBoolean == false){
                triggerBoolean = true;
                if(reqMap.containsKey(item.Signing_Authority_Email__c)){
                    reqSize = reqMap.get(item.Signing_Authority_Email__c);
                }
                
                //Add ACH Tasks
                if(reqLoc.get(item.id).Sub_Status__c == 'New' && oldMap.get(item.id).Sub_Status__c == 'Not Submitted' && reqLoc.get(item.id).Sub_Status__c != oldMap.get(item.id).Sub_Status__c && lTasks.get(item.id).Location__r.Partner_Bank_Type__c != null){
                    
                    emailtemplate et = [SELECT Subject, Name, Id, Description, HtmlValue, Body,DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'gFRS_Templates' and DeveloperName = 'ACH_details_communication_email_US_vendors'];
                    
                    replaceEmailBodyFutureMethod(et.HtmlValue, et.Subject, item.Location__c, item.id, item.name, item.Signing_Authority_First_Name__c, item.Signing_Authority_Last_Name__c, item.Event_Program_Title__c, item.Partner_Bank_Type__c, item.Signing_Authority_Email__c);
                    
                }
                
                if(reqLoc.get(item.id).Sub_Status__c == 'New' && oldMap.get(item.id).Sub_Status__c == 'Not Submitted' && reqLoc.get(item.id).Sub_Status__c != oldMap.get(item.id).Sub_Status__c && lTasks.get(item.id).Location__r.Partner_Bank_Type__c == null && reqSize.size() == 0){
                    List<gFRS_Tasks__c> taskAS = new List<gFRS_Tasks__c>();
                    taskAS = [SELECT id, Name, gFRS_Funding_Request__c 
                              FROM gFRS_Tasks__c 
                              WHERE gFRS_Funding_Request__r.Location__c = :lTasks.get(item.id).Location__c AND gFRS_Funding_Request__r.Signing_Authority_Email__c = :lTasks.get(item.id).Signing_Authority_Email__c AND Action_Type__c = 'ACH' AND Status__c != 'Closed'];
                    if(taskAS.size() > 0){
                        reqUpd2.add(item.id);
                    }
                    else{
                        String RfiLink  = '/apex/gFRS_ACHData?id=' + item.Location__c + '&fundingreq=' + item.id;
                        
                        tasksToAdd.add(new gFRS_Tasks__c( 
                            Status__c               = 'Open',
                            Subject__c              = 'ACH Required',
                            RFI_Link__c             = RfiLink,
                            Description__c          = 'If approved, select the payment method via which you would prefer to receive the funds',
                            gFRS_Funding_Request__c = item.id,
                            User__c                 = currentUser,
                            Action_Type__c          = 'ACH' 
                        )); 
                        reqUpd.add(item.id);
                        
                        emailtemplate et = [SELECT Subject, Name, Id, Description, Body, HtmlValue, DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'gFRS_Templates' and DeveloperName = 'ACH_Task_generation_email'];
                        
                        String body = replaceEmailBodyNonFuture(et.HtmlValue, item);
                        body += '\n\n' + '[ref:' + item.id + ']';
                        body = body.replaceAll('<!\\[CDATA\\[', '');
                        body = body.replaceAll('\\]\\]>', '');
                        String subject = replaceEmailSubject(et.Subject, item);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{item.Signing_Authority_Email__c});
                        mail.setSubject(subject);
                        mail.setHtmlBody(body);
                        mail.setOrgWideEmailAddressId([SELECT Id, Address FROM OrgWideEmailAddress
                                                       WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
                        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
                        if (myOrgCS.gFRS_Inbound_Email__c != null) {
                            string bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;
                            mail.setBccAddresses(new List<String>{bccEmailAddress});                            
                        }                               
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });                                                       
                    }
                } 
                else if(reqLoc.get(item.id).Sub_Status__c == 'New' && oldMap.get(item.id).Sub_Status__c == 'Not Submitted' && reqLoc.get(item.id).Sub_Status__c != oldMap.get(item.id).Sub_Status__c && lTasks.get(item.id).Location__r.Partner_Bank_Type__c == null && reqSize.size() > 0){
                    reqUpd2.add(item.id);
                }
            }
            
            //Add LOA Tasks
            if (item.Sub_Status__c == 'RFI' ) {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && (taskItem.Action_Type__c == 'RFI' || taskItem.Action_Type__c == gFRS_Util.TASK_CHANGE_FUNDING_TYPE)) {
                        tasksToClose.add(taskItem);
                    }
                }
                if (item.External_Sub_status__c != gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_FUNDING_TYPE_CHANGED) {
                    String checkRfi = item.Information_Needed__c == null ? '' : item.Information_Needed__c;
                    String RfiLink = '';
                    if (checkRfi.contains(gFRS_Util.INFO_NEEDED_ORGANIZATION)) {
                        String parameters = 'org=' + item.Organization__c;
                        RfiLink = gFRS_Util.initializeLink('/apex/gFRS_Org_Info', item, parameters);
                    } else if (checkRfi.contains(gFRS_Util.INFO_NEEDED_LOCATION)) {
                        String parameters = 'org=' + item.Organization__c;
                        RfiLink = gFRS_Util.initializeLink('/apex/gFRS_Org_Info', item, parameters);
                    } else if (checkRfi.contains(gFRS_Util.INFO_NEEDED_APPLICATION)) {
                        String parameters = 'loc=' + item.Location__c + 'org=' + item.Organization__c;
                        RfiLink = gFRS_Util.initializeLink('/apex/GFRS_Application', item, parameters);
                    } else if (checkRfi.contains(gFRS_Util.INFO_NEEDED_THIRD_PARTY)) {
                        String parameters = 'loc=' + item.Location__c + 'org=' + item.Organization__c;
                        RfiLink = gFRS_Util.initializeLink('/apex/gFRS_ThirdParty', item, '');
                    } else if (checkRfi.contains(gFRS_Util.INFO_NEEDED_PROGRAM_DESIGN)) {
                        RfiLink = gFRS_Util.initializeLink('/apex/gFRS_ProgramDesign', item, '');
                    } else if (checkRfi.contains(gFRS_Util.INFO_NEEDED_PROGRAM)) {
                        RfiLink = gFRS_Util.initializeLink('/apex/gFRS_Program', item, '');
                    } else if (checkRfi.contains(gFRS_Util.INFO_NEEDED_BUDGET)) {
                        RfiLink = gFRS_Util.initializeLink('/apex/gFRS_Budget', item, '');
                    } else if (checkRfi.contains(gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS)) {
                        RfiLink = gFRS_Util.initializeLink('/apex/gFRS_FileAttachments', item, '');
                    } else if (checkRfi.contains(gFRS_Util.INFO_NEEDED_PAYMENT_METHOD)) {
                        RfiLink = '/apex/gFRS_ACHData?id=' + item.Location__c + '&fundingreq=' + item.id;
                    } else {
                        String parameters = 'org=' + item.Organization__c;
                        RfiLink = gFRS_Util.initializeLink('/apex/gFRS_Org_Info', item, parameters);
                    }
                    tasksToAdd.add(new gFRS_Tasks__c(
                        Status__c = 'Open',
                        Subject__c = 'RFI Required',
                        RFI_Link__c = RfiLink,
                        Description__c = 'Please respond to the RFI for Funding Request: ' + item.Name,
                        gFRS_Funding_Request__c = item.Id,
                        User__c = currentUser,
                        Action_Type__c = 'RFI'
                    ));
                }
            }
            System.debug(tasksToClose);
            if (item.Status__c == 'Processing & Disposition'
                && item.Sub_Status__c == 'Approved-Awaiting LOA'
                && item.Record_Type_Name__c != 'Field Initiated Exhibits') {
                    
                    for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                        if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'LOA') {
                            tasksToClose.add(taskItem);
                            
                        }
                        
                    }
                    tasksToAdd.add(new gFRS_Tasks__c(
                        Status__c = 'Open',
                        Subject__c = 'LOA Required',
                        Description__c = 'Please sign the LOA for Funding Request: ' + item.Name,
                        gFRS_Funding_Request__c = item.Id,
                        User__c = currentUser, Action_Type__c = 'LOA'
                    ));
                    
                }
                    
                if (item.Status__c == 'Processing & Disposition'
                    && item.Status_Updates_Submitted__c == 'No'
                    && item.StatusUpdate_Communication_Sent__c != true
                    && (item.Record_Type_Name__c == 'Sci/Pipeline Exhibits & Other Non-Promo' || item.Record_Type_Name__c == 'Exhibits & Other Promos')
                    && item.Number_of_Programs__c > 1) {
                        for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                            if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Status Report') {
                                tasksToClose.add(taskItem);
                                
                            }
                            
                        }
                        
                        tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Not Submitted', Subject__c = 'Status Report Required', Description__c = 'Please provide monthly Status Report/Scope Changes for Funding Request: ' + item.Name, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = 'Status Report'));
                        
                        reqIds.add(item.Id);
                        
                        emailtemplate et = [SELECT Subject, Name, Id, Description, HtmlValue, Body,DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'gFRS_RFI_Templates' and DeveloperName = 'Program_Status_Notification_email_Template'];

                        String body = replaceEmailBodyNonFuture(et.HtmlValue, item);
                        User userDetails = [SELECT Id, Name, Email FROM User WHERE Id =: item.OwnerId];
                        body = body.replace('xxOwner Namexx', userDetails.Name);
                        GFRS_Program__c Prog = [SELECT Id, Name,Start_Date__c,End_Date__c,Venue_Name__c FROM GFRS_Program__c WHERE Funding_Request__c =: item.Id and End_Date__c =: item.Program_End_Date_max__c Order By Start_Date__c desc limit 1];
                        string startDate = Prog.Start_Date__c.format();
                        startDate = startDate.replaceall('/','-');
                        string endDate = Prog.End_Date__c.format();
                        endDate = endDate.replaceall('/','-');
                        body = body.replace('xxLast program Venuexx', Prog.Venue_Name__c);
                        body = body.replace('xxLast program start datexx', startDate);
                        body = body.replace('xxlast program end datexx', endDate);
                        body += '\n\n' + '[ref:' + item.id + ']';
                        body = body.replaceAll('<!\\[CDATA\\[', '');
                        body = body.replaceAll('\\]\\]>', '');
                        String subject = replaceEmailSubject(et.Subject, item);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{userDetails.Email});
                        mail.setSubject(subject);
                        mail.setHtmlBody(body);
                        mail.setOrgWideEmailAddressId([SELECT Id, Address FROM OrgWideEmailAddress
                                                       WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
                        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
                        if (myOrgCS.gFRS_Inbound_Email__c != null) {
                            string bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;
                            mail.setBccAddresses(new List<String>{bccEmailAddress});                            
                        }                               
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                
            if (item.Status__c == 'Processing & Disposition'
                && item.Sub_Status__c == 'Approved-Status Updates/Outcomes'
                && (item.Record_Type_Name__c == 'IMED' || item.Record_Type_Name__c == 'Fellowships')) {
                    for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                        if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Status Report') {
                            tasksToClose.add(taskItem);
                            
                        }
                        
                    }
                    
                    tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Not Submitted', Subject__c = 'Status Report Required', Description__c = 'Please provide monthly Status Report/Scope Changes for Funding Request: ' + item.Name, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = 'Status Report'));
                    
                }
            
            if (item.Status__c == 'Processing & Disposition' && item.Sub_Status__c == 'Sunshine Act Disclosure' && item.Sunshine_Act_Disclosure_Submitted__c == gFRS_Util.NO && (item.Record_Type_Name__c == 'Scientific Projects' || item.Record_Type_Name__c == 'Fellowships')) {
                
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE) {
                        tasksToClose.add(taskItem);
                    }
                }
                tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Open', Subject__c = gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE, Description__c = 'Please complete the Sunshine Act Disclosure for Funding Request: ' + item.Name, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE));
                
            }
            
            if (item.Status__c == 'Processing & Disposition' && (item.Sub_Status__c == 'Approved-Status Updates/Outcomes' || item.Sub_Status__c == 'Approved-Program Evaluations') && (item.Record_Type_Name__c == 'IMED' || item.Record_Type_Name__c == 'Scientific Projects' || item.Record_Type_Name__c == 'Fellowships' || item.Record_Type_Name__c == 'Philanthropic' || item.Record_Type_Name__c == 'HC Char')) {
                
                if (item.Record_Type_Name__c == 'IMED') {
                    for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                        if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Outcomes') {
                            tasksToClose.add(taskItem);
                        }
                    }
                    
                    tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Not Submitted', Subject__c = 'Outcomes Required', Description__c = 'Please provide Outcomes for Funding Request: ' + item.Name, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = 'Outcomes'));
                    
                } else if (item.Foundation_Classified__c == 'true' && (item.Record_Type_Name__c == 'Philanthropic' || item.Record_Type_Name__c == 'HC Char')) {
                    for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                        if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Evaluations') {
                            tasksToClose.add(taskItem);
                        }
                    }
                    
                    if (item.Evaluation_Completed__c != 'Yes') {
                        tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Open', Subject__c = 'Evaluations Required', Description__c = 'Please provide the Evaluation for Funding Request: ' + item.Name + ' post first event/program start date.', gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = 'Evaluations'));
                    }
                    
                    //GFRS-435 added if HC Char and Phil Foundation eval post first program start date
                } else if (item.Record_Type_Name__c != 'Fellowships' || (item.Record_Type_Name__c == 'Fellowships' && [SELECT COUNT() FROM gFRS_Tasks__c WHERE Action_Type__c = 'Annual Evaluation' AND Status__c = 'Not Submitted' AND gFRS_Funding_Request__c = :item.Id] == 0)) {
                    
                    for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                        if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Evaluations') {
                            tasksToClose.add(taskItem);
                        }
                    }
                    
                    if (item.Evaluation_Completed__c != 'Yes') {
                        tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Open', Subject__c = 'Evaluations Required', Description__c = 'Please provide the Evaluation for Funding Request: ' + item.Name + ' post final event/program end date.', gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = 'Evaluations'));
                    }
                    //SFDC-3517 set Evaluation Completed to No when Status change to Approved-Program Evaluations
                    //item.Evaluation_Completed__c='No';
                }
            }
            if (item.Status__c == 'Processing & Disposition' && item.Sub_Status__c == 'Reconciliation Required') {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Reconciliation' && item.Reconciliation_Completed__c == 'Yes') {
                        tasksToClose.add(taskItem);
                    }
                }
                if (item.Reconciliation_Required_Status_Date__c == null) {
                    tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Open', Subject__c = 'Reconciliation Required', Description__c = 'Please complete the Reconciliation for Funding Request: ' + item.Name, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = 'Reconciliation'));
                }
            }
            
            /*
            //Commented JIRA: GFRS-211
            //Added JIRA: GFRS-270
            if (item.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME && ((item.Sunshine_Act_Disclosure_Submitted__c == gFRS_Util.NO && item.Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE) || item.Sunshine_Communication_Sent__c)) {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE) {
                        tasksToClose.add(taskItem);
                    }
                }
                tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Open', Subject__c = gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE, Description__c = 'Please complete the Sunshine Act Disclosure for Funding Request: ' + item.Name, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE));
            }*/
            
            if (item.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME && item.Sunshine_Act_Disclosure_Submitted__c == gFRS_Util.YES) {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE) {
                        tasksToClose.add(taskItem);
                    }
                    
                }
            }
            
            if (item.Status__c == 'Processing & Disposition' && item.Sub_Status__c == 'Reconciliation Required' && item.Record_Type_Name__c == 'IMED') {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Outcomes') {
                        tasksToClose.add(taskItem);
                    }
                }
                tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Not Submitted', Subject__c = 'Outcomes Required', Description__c = 'Please provide Outcomes for Funding Request: ' + item.Name, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = 'Outcomes'));
            }
            if (item.Sub_Status__c == 'Refund Required') {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Refund') {
                        tasksToClose.add(taskItem);
                    }
                }
                tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Open', Subject__c = 'Refund Required', Description__c = 'Please provide a Refund for Funding Request: ' + item.Name, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = 'Refund'));
            }
            if (item.LOA_Signed__c == 'Yes') {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'LOA') {
                        tasksToClose.add(taskItem);
                    }
                    
                }
            }
            if (item.Sub_Status__c != 'RFI') {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'RFI') {
                        tasksToClose.add(taskItem);
                    }
                }
            }
            
            if(item.ACH_Received__c != null && item.ACH_Received__c != ''){ 
                for(gFRS_Tasks__c taskItem: lTasks.get(item.id).gFRS_Tasks__r ){
                    if(taskItem.Action_Type__c!=null &&   taskItem.Action_Type__c=='ACH'){
                        tasksToClose.add(taskItem);
                    }
                }
            }
            
            if((item.Sub_Status__c == 'Canceled' && oldMap.get(item.id).Sub_Status__c != item.Sub_Status__c) || (item.Sub_Status__c == 'Denied' && oldMap.get(item.id).Sub_Status__c != item.Sub_Status__c)){ 
                for(gFRS_Tasks__c taskItem: lTasks.get(item.id).gFRS_Tasks__r ){
                    if(taskItem.Action_Type__c!=null &&   taskItem.Action_Type__c=='ACH'){
                        tasksToClose.add(taskItem);
                    }
                }
            }
            
            if (item.Sub_Status__c != 'Reconciliation Required' && item.Reconciliation_Completed__c == 'Yes') {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Reconciliation') {
                        tasksToClose.add(taskItem);
                    }
                }
            }
            if ((oldMap.get(item.Id)).Sub_Status__c == 'Refund Required' && item.Sub_Status__c != 'Refund Required') {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Refund') {
                        tasksToClose.add(taskItem);
                    }
                }
            }
            
            
            // If we close Funding Request we want also to close Tasks
            if (item.Status__c == gFRS_Util.REQUEST_STATUS_CLOSED) {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    
                    if (taskItem.Action_Type__c != null && (taskItem.Action_Type__c == 'Outcomes' || taskItem.Action_Type__c == 'Status Report' || taskItem.Action_Type__c == gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE)) {
                        tasksToClose.add(taskItem);
                    }
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Status Report' && (item.Record_Type_Name__c == 'Exhibits & Other Promos' || item.Record_Type_Name__c == 'Sci/Pipeline Exhibits & Other Non-Promo')) {
                        list<GFRS_Program__c> progs = new list<GFRS_Program__c>();
                        gFRS_Funding_Request__c requestRec = new gFRS_Funding_Request__c();
                        progs = [SELECT Id, name, Did_you_exhibit_sponsor_at_the_event__c FROM GFRS_Program__c WHERE Funding_Request__c =:item.Id];
                        
                        for(GFRS_Program__c prg : progs){
                            prg.Did_you_exhibit_sponsor_at_the_event__c = 'Yes';
                        }
                        savePrograms(progs);    
                        requestRec = [SELECT Id, name, Program_Status_Task_Override_By__c FROM gFRS_Funding_Request__c WHERE Id =: item.Id];
                        requestRec.Program_Status_Task_Override_By__c = 'System';
                        saveLockedFundingRequestInternalPage(requestRec);
                    }
                    
                }
            }
            
            if (item.External_Sub_status__c == gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED && item.Evaluation_Completed__c == 'Yes') {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Evaluations') {
                        tasksToClose.add(taskItem);
                    }
                }
            }
            //GFRSME2-3
            if (item.External_Sub_status__c == gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_FUNDING_TYPE_CHANGED && oldMap.get(item.Id).External_Sub_status__c != gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_FUNDING_TYPE_CHANGED) {
                String parameters = 'org=' + item.Organization__c;
                String RfiLink = gFRS_Util.initializeLink('/apex/gFRS_Org_Info', item, parameters);
                tasksToAdd.add(new gFRS_Tasks__c(Status__c = 'Open', Subject__c = gFRS_Util.TASK_CHANGE_FUNDING_TYPE, Description__c = Label.gFRS_ChangeFundingType_Task_Description, gFRS_Funding_Request__c = item.Id, User__c = currentUser, Action_Type__c = gFRS_Util.TASK_CHANGE_FUNDING_TYPE, RFI_Link__c = RfiLink));
            }
            
            if (item.External_Sub_status__c != gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_FUNDING_TYPE_CHANGED && oldMap.get(item.Id).External_Sub_status__c == gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_FUNDING_TYPE_CHANGED) {
                for (gFRS_Tasks__c taskItem : lTasks.get(item.Id).gFRS_Tasks__r) {
                    if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == gFRS_Util.TASK_CHANGE_FUNDING_TYPE) {
                        tasksToClose.add(taskItem);
                    }
                }
            }
        }
        /*
Map<Id,GFRS_Funding_Request__c> relatedTasks = getRequestsWithTasks(changedRequestsExternalSubStatus);

for(GFRS_Funding_Request__c item : changedRequestsExternalSubStatus){

if(item.External_Sub_status__c == gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED && item.Evaluation_Completed__c == 'Yes'){
for(gFRS_Tasks__c taskItem: relatedTasks.get(item.Id).gFRS_Tasks__r ){
if(taskItem.Action_Type__c != null && taskItem.Action_Type__c == 'Evaluations'){
tasksToClose.add(taskItem);
}

}
}

}*/
        
        if (tasksToClose.size() > 0) {
            List<gFRS_Tasks__c> taskToCloseWithoutDuplicates = new List<gFRS_Tasks__c>();
            taskToCloseWithoutDuplicates.addAll(tasksToClose);
            delete taskToCloseWithoutDuplicates;
        }
        if (tasksToAdd.size() > 0) {
            List<gFRS_Tasks__c> taskToAddWithoutDuplicates = new List<gFRS_Tasks__c>();
            taskToAddWithoutDuplicates.addAll(tasksToAdd);
            insert taskToAddWithoutDuplicates;
        }
        if((reqUpd.size() > 0 || reqUpd2.size() > 0) && trigBoolean == false){
            trigBoolean = true;
            reqsToUpd = [SELECT Id, name, ACH_Task_Open__c FROM gFRS_Funding_Request__c WHERE Id in : reqUpd OR Id in : reqUpd2];
            for(gFRS_Funding_Request__c reqUpdate : reqsToUpd){
                if(reqUpd.size() > 0){
                    if(reqUpd.contains(reqUpdate.Id)){
                        reqUpdate.ACH_Task_Open__c = 'Yes';
                    }
                }
                if(reqUpd2.size() > 0){
                    if(reqUpd2.contains(reqUpdate.Id)){
                        reqUpdate.Bank_Lookup_Required__c = 'Yes';
                    }
                }
            }
            saveLockedFundingRequests(reqsToUpd);
        }
        if(reqIds.size() > 0){
            date dt = date.today();
            date dt1 = dt.adddays(14);
            list<gFRS_Funding_Request__c> reqUpds = [SELECT Id, name, Program_Status_Task_Expiration_Date__c FROM gFRS_Funding_Request__c WHERE Id in : reqIds];
            for(gFRS_Funding_Request__c ru : reqUpds){
                ru.Program_Status_Task_Expiration_Date__c = dt1;
            }
            saveLockedFundingRequests(reqUpds);
        }
        /*  if(reqUpd2.size() > 0){
reqsToUpd2 = [SELECT Id, name, Bank_Lookup_Required__c FROM gFRS_Funding_Request__c WHERE Id in : reqUpd2];
for(gFRS_Funding_Request__c reqUpdate2 : reqsToUpd2){
reqUpdate2.Bank_Lookup_Required__c = 'Yes';
}
saveLockedFundingRequests(reqsToUpd2);
}  */
        
        
        //System.debug(changedRequests);
        
    }
    
    /** 
* @Author gFRS Dev Team
* @date 03/11/2019
* @description replaceEmailBody method set dynamic values in defined in body of emailTemplate
* 
*/
    public static String replaceEmailBody(String emailBody, GFRS_Funding_Request__c req) {
        
        String outputBody = '';
        
        if (emailBody != null) {
            string acctNbr = '';
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            String serverURL = myOrgCS.Server_URL__c;
            string ACHLink = serverURL + '/apex/gFRS_ACHData?id=' + req.Location__c + '&fundingreq=' + req.id;
            GFRS_Location__c LOC = [SELECT Id, Name, Vendor_ID__c, Partner_Bank_Type__c, Organization__r.US_Organization__c, Address__c, City__c, State__c, Zip__c, Department_Chapter_Country__c FROM GFRS_Location__c WHERE id = :req.Location__c];
            string location = '';
            string locationExt = '';
            location += '\n' + LOC.Address__c + ', ' + '\n' + LOC.City__c + ', ' + LOC.State__c + ', ' + '\n' + LOC.Department_Chapter_Country__c + ' ' + LOC.Zip__c;
            locationExt = 'via check to the below mailing address.' + '\n' + location;
            outputBody = emailBody.replace('<<Request Name>>', req.Name);
            outputBody = outputBody.replace('xxRequest Namexx', req.Name);
            outputBody = outputBody.replace('<<Authorized Signer FirstName>>', req.Signing_Authority_First_Name__c);
            outputBody = outputBody.replace('xxAuthorized Signer FirstNamexx', req.Signing_Authority_First_Name__c);
            outputBody = outputBody.replace('<<Authorized Signer LastName>>', req.Signing_Authority_Last_Name__c);
            outputBody = outputBody.replace('xxAuthorized Signer LastNamexx', req.Signing_Authority_Last_Name__c);
            outputBody = outputBody.replace('<<Event Program Title>>', checkNull(req.Event_Program_Title__c));
            outputBody = outputBody.replace('xxEvent Program Titlexx', checkNull(req.Event_Program_Title__c));
            outputBody = outputBody.replace('<<Click here>>', '<a href="https://www.gene.com/assets/frontend/pdf/content/good/grants/New_User_Registration_Tip_Sheet.pdf"> + Click here + </a>');
            Date dueDt = gFRS_Util_NoShare.getThreeWeekdaysLaterDate(Date.Today());
            string paymentDate = dueDt.format();
            paymentDate = paymentDate.replace('/', '-');
            outputBody = outputBody.replace('<<Task Due Date>>', paymentDate);
            outputBody = outputBody.replace('xxTask Due Datexx', paymentDate);
            outputBody = outputBody.replace('<<Mailing Address>>', location);
            outputBody = outputBody.replace('xxMailing Addressxx', location);
            outputBody = outputBody.replace('<<Click here - ACH Page>>', '<a href=ACHLink> + Click here + </a>');
            outputBody = outputBody.replace('xxClick here - ACH Pagexx', '<a href=ACHLink>' + 'Click here' + '</a>');
            
            if(string.isNotBlank(LOC.Vendor_ID__c) && string.isNotBlank(LOC.Partner_Bank_Type__c)){
                if(LOC.Organization__r.US_Organization__c == 'Yes'){
                    List<MatchedBank> matchedBanks = new List<MatchedBank>();
                    GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0 sapLookup = new GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0();
                    sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
                    GFRS_BankLookupSAP.BankInfoLookupResponse_element response;
                    try {
                        response = sapLookup.BankInfoLookup(LOC.Vendor_ID__c);
                        GFRS_BankLookupSAP.BankInfoDetails_element[] BankInfoDetailsvar = response.BankInfoDetails;
                        for(GFRS_BankLookupSAP.BankInfoDetails_element element : BankInfoDetailsvar){
                            if(outputBody.contains('<<Extension Declined>>')){
                                if(element.PartnerBankType == req.Partner_Bank_Type__c){
                                    acctNbr = element.BankAccountNumber.right(4);
                                    acctNbr = 'to the bank account ending in ' + acctNbr;
                                    outputBody = outputBody.replace('<<Extension Declined>>', acctNbr); 
                                    break;
                                }
                            }else{
                                if(element.PartnerBankType == LOC.Partner_Bank_Type__c){
                                    acctNbr = element.BankAccountNumber.right(4);
                                    acctNbr = 'ending in ' + acctNbr;
                                    break;
                                }
                            }
                        }
                    }catch(Exception err){
                        System.debug( 'ERROR OCCURRED:' + err.getMessage() );
                    }
                    outputBody = outputBody.replace('<<Account Number>>', acctNbr); 
                    outputBody = outputBody.replace('xxAccount Numberxx', acctNbr);
                }
                else{
                    outputBody = outputBody.replace('<<Account Number>>', 'we have on file');   
                    outputBody = outputBody.replace('xxAccount Numberxx', 'we have on file');   
                }
            }
            
            outputBody = outputBody.replace('<<Extension Declined>>', locationExt);
            
        }
        
        return outputBody;
    }
    
    /** 
* @Author gFRS Dev Team
* @date 03/11/2019
* @description replaceEmailBodyNonFuture method set dynamic values in defined in body of emailTemplate
* 
*/
    public static String replaceEmailBodyNonFuture(String emailBody, GFRS_Funding_Request__c req) {
        
        String outputBody = '';
        
        if (emailBody != null) {
            string acctNbr = '';
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            String serverURL = myOrgCS.Server_URL__c;
            string ACHLink = serverURL + '/apex/gFRS_ACHData?id=' + req.Location__c + '&fundingreq=' + req.id;
            GFRS_Location__c LOC = [SELECT Id, Name, Vendor_ID__c, Partner_Bank_Type__c, Organization__r.US_Organization__c, Address__c, City__c, State__c, Zip__c, Department_Chapter_Country__c FROM GFRS_Location__c WHERE id = :req.Location__c];
            string location = '';
            string locationExt = '';
            location += '\n' + LOC.Address__c + ', ' + '\n' + LOC.City__c + ', ' + LOC.State__c + ', ' + '\n' + LOC.Department_Chapter_Country__c + ' ' + LOC.Zip__c;
            locationExt = 'via check to the below mailing address.' + '\n' + location;
            outputBody = emailBody.replace('<<Request Name>>', req.Name);
            outputBody = outputBody.replace('xxRequest Namexx', req.Name);
            outputBody = outputBody.replace('<<Authorized Signer Email>>', req.Signing_Authority_Email__c);
            outputBody = outputBody.replace('xxAuthorized Signer Emailxx', req.Signing_Authority_Email__c);            
            outputBody = outputBody.replace(']]>', '');
            outputBody = outputBody.replace('<<Authorized Signer FirstName>>', req.Signing_Authority_First_Name__c);
            outputBody = outputBody.replace('xxAuthorized Signer FirstNamexx', req.Signing_Authority_First_Name__c);
            outputBody = outputBody.replace('<<Authorized Signer LastName>>', req.Signing_Authority_Last_Name__c);
            outputBody = outputBody.replace('xxAuthorized Signer LastNamexx', req.Signing_Authority_Last_Name__c);
            outputBody = outputBody.replace('<<Event Program Title>>', checkNull(req.Event_Program_Title__c));
            outputBody = outputBody.replace('xxEvent Program Titlexx', checkNull(req.Event_Program_Title__c));
            outputBody = outputBody.replace('<<Click here>>', '<a href="https://www.gene.com/assets/frontend/pdf/content/good/grants/New_User_Registration_Tip_Sheet.pdf"> + Click here + </a>');
            Date dueDt = gFRS_Util_NoShare.getThreeWeekdaysLaterDate(Date.Today());
            string paymentDate = dueDt.format();
            paymentDate = paymentDate.replace('/', '-');
            outputBody = outputBody.replace('<<Task Due Date>>', paymentDate);
            outputBody = outputBody.replace('xxTask Due Datexx', paymentDate);
            outputBody = outputBody.replace('<<Mailing Address>>', location);
            outputBody = outputBody.replace('xxMailing Addressxx', location);
            outputBody = outputBody.replace('<<Click here - ACH Page>>', '<a href=ACHLink> + Click here + </a>');
            outputBody = outputBody.replace('xxClick here - ACH Pagexx', '<a href=ACHLink>' + 'Click here' + '</a>');
            outputBody = outputBody.replace('<<Extension Declined>>', locationExt);
            
        }
        
        return outputBody;
    }
    
    /** 
* @Author gFRS Dev Team
* @date 03/11/2019
* @description replaceEmailBodyFutureMethod method set dynamic values in defined in body of emailTemplate
* 
*/  
    @future (callout=true)
    public static void replaceEmailBodyFutureMethod(String emailBody, String Subject, id locn, id reqId, string reqName, string firstName, string lastName, string progTitle, string PBT, string email) {
        
        String outputBody = '';
        
        if (emailBody != null) {
            string acctNbr = '';
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            String serverURL = myOrgCS.Server_URL__c;
            string ACHLink = serverURL + '/apex/gFRS_ACHData?id=' + locn + '&fundingreq=' + reqId;
            GFRS_Location__c LOC = [SELECT Id, Name, Vendor_ID__c, Partner_Bank_Type__c, Organization__r.US_Organization__c, Address__c, City__c, State__c, Zip__c, Department_Chapter_Country__c FROM GFRS_Location__c WHERE id = :locn];
            string location = '';
            string locationExt = '';
            location += '\n' + LOC.Address__c + ', ' + '\n' + LOC.City__c + ', ' + LOC.State__c + ', ' + '\n' + LOC.Department_Chapter_Country__c + ' ' + LOC.Zip__c;
            locationExt = 'via check to the below mailing address.' + '\n' + location;
            outputBody = emailBody.replace('<<Request Name>>', reqName);
            outputBody = outputBody.replace('xxRequest Namexx', reqName);
            outputBody = outputBody.replace('<<Authorized Signer Email>>', email);
            outputBody = outputBody.replace('xxAuthorized Signer Emailxx', email);             
            outputBody = outputBody.replace('<<Request Id>>', reqId);
            outputBody = outputBody.replace('xxRequest Idxx', reqId);
            outputBody = outputBody.replace(']]>', '');
            outputBody = outputBody.replace('<<Authorized Signer FirstName>>', firstName);
            outputBody = outputBody.replace('xxAuthorized Signer FirstNamexx', firstName);
            outputBody = outputBody.replace('<<Authorized Signer LastName>>', lastName);
            outputBody = outputBody.replace('xxAuthorized Signer LastNamexx', lastName);
            outputBody = outputBody.replace('<<Event Program Title>>', checkNull(progTitle));
            outputBody = outputBody.replace('xxEvent Program Titlexx', checkNull(progTitle));
            outputBody = outputBody.replace('<<Click here>>', '<a href="https://www.gene.com/assets/frontend/pdf/content/good/grants/New_User_Registration_Tip_Sheet.pdf"> + Click here + </a>');
            Date dueDt = gFRS_Util_NoShare.getThreeWeekdaysLaterDate(Date.Today());
            string paymentDate = dueDt.format();
            paymentDate = paymentDate.replace('/', '-');
            outputBody = outputBody.replace('<<Task Due Date>>', paymentDate);
            outputBody = outputBody.replace('xxTask Due Datexx', paymentDate);
            outputBody = outputBody.replace('<<Mailing Address>>', location);
            outputBody = outputBody.replace('xxMailing Addressxx', location);
            outputBody = outputBody.replace('<<Click here - ACH Page>>', ACHLink);
            outputBody = outputBody.replace('xxClick here - ACH Pagexx', ACHLink);
            
            if(string.isNotBlank(LOC.Vendor_ID__c) && string.isNotBlank(LOC.Partner_Bank_Type__c)){
                if(LOC.Organization__r.US_Organization__c == 'Yes'){
                    List<MatchedBank> matchedBanks = new List<MatchedBank>();
                    GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0 sapLookup = new GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0();
                    sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
                    GFRS_BankLookupSAP.BankInfoLookupResponse_element response;
                    try {
                        response = sapLookup.BankInfoLookup(LOC.Vendor_ID__c);
                        GFRS_BankLookupSAP.BankInfoDetails_element[] BankInfoDetailsvar = response.BankInfoDetails;
                        for(GFRS_BankLookupSAP.BankInfoDetails_element element : BankInfoDetailsvar){
                            if(outputBody.contains('<<Extension Declined>>')){
                                if(element.PartnerBankType == PBT){
                                    acctNbr = element.BankAccountNumber.right(4);
                                    acctNbr = 'to the bank account ending in ' + acctNbr;
                                    outputBody = outputBody.replace('<<Extension Declined>>', acctNbr); 
                                    break;
                                }
                            }else{
                                if(element.PartnerBankType == LOC.Partner_Bank_Type__c){
                                    acctNbr = element.BankAccountNumber.right(4);
                                    acctNbr = 'ending in ' + acctNbr;
                                    break;
                                }
                            }
                        }
                    }catch(Exception err){
                        System.debug( 'ERROR OCCURRED:' + err.getMessage() );
                    }
                    outputBody = outputBody.replace('<<Account Number>>', acctNbr); 
                    outputBody = outputBody.replace('xxAccount Numberxx', acctNbr);
                }
                else{
                    outputBody = outputBody.replace('<<Account Number>>', 'we have on file');   
                    outputBody = outputBody.replace('xxAccount Numberxx', 'we have on file');   
                }
            }
            
            outputBody = outputBody.replace('<<Extension Declined>>', locationExt);
            outputBody = outputBody.replaceAll('<!\\[CDATA\\[', '');
            outputBody = outputBody.replaceAll('\\]\\]>', '');
            
        }
        
        outputBody += '\n\n' + '[ref:' + reqId + ']';
        String sub = gFRS_Util_NoShare.replaceEmailSub(Subject, reqName);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{email});
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        if (myOrgCS.gFRS_Inbound_Email__c != null) {
            string bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;
            mail.setBccAddresses(new List<String>{bccEmailAddress});                            
        }           
        mail.setSubject(sub);
        mail.setHtmlBody(outputBody);
        //        mail.setPlainTextBody(outputBody);
        mail.setOrgWideEmailAddressId([SELECT Id, Address FROM OrgWideEmailAddress
                                       WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }   
    
    /**     
* @Author gFRS Dev Team
* @date 03/11/2019
* @description replaceEmailSubject method replace dynamic values defined in subject of emailTemplate
*/
    public static String replaceEmailSubject(String emailSub, GFRS_Funding_Request__c req) {
        if (emailSub != null) {
            return EmailSub.replace('<<Request Name>>', req.Name);
        }
        return '';
        
    } 
    
    public static String replaceEmailSub(String emailSub, string reqName) {
        if (emailSub != null) {
            return EmailSub.replace('<<Request Name>>', reqName);
        }
        return '';
        
    }   
    
    public static String checkNull(String v) {
        return(v == null || v == 'null' ? '' : v);
    }   
    
    public class MatchedBank {
        public boolean isselected{get; set;}
        public string BankId  {get; set;}
        public String BankAccountNumberString { get; set; }
        public String BankInfoKeyString { get; set; }
        public String PartnerBankTypeString { get; set; }
        public String CountryString { get; set; }
        public String bankInfoStringForUI {get; set;}
    }   
    
    public static void resetToSunshineAfterReconTaskStarted(GFRS_Funding_Request__c[] requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        Set<Id> frIdsToChange = new Set<Id>();
        
        for (GFRS_Funding_Request__c fr : requests) {
            if (fr.Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ && oldMap.get(fr.Id).Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE && fr.Sunshine_Act_Disclosure_Submitted__c != gFRS_Util.YES) {
                frIdsToChange.add(fr.Id);
            }
        }
        if (frIdsToChange.size() > 0) {
            List<GFRS_Funding_Request__c> frList = new List<GFRS_Funding_Request__c>();
            for (GFRS_Funding_Request__c fr : [SELECT Id, Sub_Status__c, External_Sub_status__c FROM GFRS_Funding_Request__c WHERE Id IN :frIdsToChange]) {
                fr.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE;
                fr.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE;
                if (fr.Reconciliation_Required_Status_Date__c == null) {
                    fr.Reconciliation_Required_Status_Date__c = Date.today(); //when creating reconciliation this should be set BY field update based on the substatus - here we changed the substatus so field update would not fire
                }
                frList.add(fr);
            }
            update frList;
        }
    }
    
    //GFRS-1083
    public static void calculateOrganizationTotalApprovedCurrentYear(
        Boolean isUpdate,
        Boolean isDelete,
        List<GFRS_Funding_Request__c> requests,
        Map<Id, GFRS_Funding_Request__c> oldMap) {
            
            Set<String> affectedFundingTypes = new Set<String>{
                'Health Care-Related Charitable', 'Fellowships', 'Scientific Project Support'
                    };
                        
                        Map<Id, GFRS_Organization__c> organizationsToCalculate = new Map<Id, GFRS_Organization__c>();
            Map<Id, ProcessInstanceNode> processInstanceNodes = new Map<Id, ProcessInstanceNode>();
            List<ProcessInstance> processInstances = new List<ProcessInstance>();
            
            if (isUpdate) {
                processInstances = gFRS_Util_NoShare.getProcessInstancesForAffectedSteps(new List<Id>(oldMap.keySet()), new List<String>{
                    PENDING
                        });
                
                if (processInstances.size() > 0) {
                    processInstanceNodes = gFRS_Util_NoShare.getProcessInstanceNodes(processInstances, new List<String>(BUSINESS_APPROVAL_STEPS));
                }
                
                for (GFRS_Funding_Request__c fundingRequest : requests) {
                    GFRS_Funding_Request__c oldFundingRequest = oldMap.get(fundingRequest.Id);
                    
                    if (isBusinessApprovalRejected(oldFundingRequest, fundingRequest)) {
                        if (affectedFundingTypes.contains(oldFundingRequest.Funding_Type__c) || affectedFundingTypes.contains(fundingRequest.Funding_Type__c)) {
                            organizationsToCalculate.put(fundingRequest.Organization__c, new GFRS_Organization__c(Id = fundingRequest.Organization__c));
                            continue;
                        }
                    }
                    
                    if (processInstanceNodes.keySet().contains(fundingRequest.Id)) {
                        if (affectedFundingTypes.contains(oldFundingRequest.Funding_Type__c) || affectedFundingTypes.contains(fundingRequest.Funding_Type__c)) {
                            organizationsToCalculate.put(fundingRequest.Organization__c, new GFRS_Organization__c(Id = fundingRequest.Organization__c));
                            continue;
                        }
                    }
                    
                    if (fundingRequest.SYS_Request_Approved__c != oldFundingRequest.SYS_Request_Approved__c) {
                        if (affectedFundingTypes.contains(oldFundingRequest.Funding_Type__c) || affectedFundingTypes.contains(fundingRequest.Funding_Type__c)) {
                            organizationsToCalculate.put(fundingRequest.Organization__c, new GFRS_Organization__c(Id = fundingRequest.Organization__c));
                            continue;
                        }
                    }
                    
                    if (fundingRequest.Funding_Type__c != oldFundingRequest.Funding_Type__c) {
                        if (affectedFundingTypes.contains(oldFundingRequest.Funding_Type__c) || affectedFundingTypes.contains(fundingRequest.Funding_Type__c)) {
                            organizationsToCalculate.put(fundingRequest.Organization__c, new GFRS_Organization__c(Id = fundingRequest.Organization__c));
                            continue;
                        }
                    }
                    
                    if (fundingRequest.Foundation_Classified__c != oldFundingRequest.Foundation_Classified__c) {
                        if (affectedFundingTypes.contains(oldFundingRequest.Funding_Type__c) || affectedFundingTypes.contains(fundingRequest.Funding_Type__c)) {
                            organizationsToCalculate.put(fundingRequest.Organization__c, new GFRS_Organization__c(Id = fundingRequest.Organization__c));
                            continue;
                        }
                    }
                    
                }
            } else if (isDelete) {
                for (GFRS_Funding_Request__c fundingRequest : oldMap.values()) {
                    if (affectedFundingTypes.contains(fundingRequest.Funding_Type__c)) {
                        organizationsToCalculate.put(fundingRequest.Organization__c, new GFRS_Organization__c(Id = fundingRequest.Organization__c));
                    }
                }
            }
            
            if (organizationsToCalculate.size() > 0) {
                calculateOrganizationTotalApprovedCurrentYear(organizationsToCalculate);
            }
        }
    
    private static Boolean isBusinessApprovalRejected(GFRS_Funding_Request__c oldFundingRequest, GFRS_Funding_Request__c fundingRequest) {
        if ((fundingRequest.Business_Approver_Decision__c != oldFundingRequest.Business_Approver_Decision__c && String.isNotBlank(fundingRequest.Business_Approver_Decision__c) && fundingRequest.Business_Approver_Decision__c == REJECTED) ||
            (fundingRequest.Financial_Approver_1_Decision__c != oldFundingRequest.Financial_Approver_1_Decision__c && String.isNotBlank(fundingRequest.Financial_Approver_1_Decision__c) && fundingRequest.Financial_Approver_1_Decision__c == REJECTED) ||
            (fundingRequest.Financial_Approver_2_Decision__c != oldFundingRequest.Financial_Approver_2_Decision__c && String.isNotBlank(fundingRequest.Financial_Approver_2_Decision__c) && fundingRequest.Financial_Approver_2_Decision__c == REJECTED) ||
            (fundingRequest.Financial_Approver_3_Decision__c != oldFundingRequest.Financial_Approver_3_Decision__c && String.isNotBlank(fundingRequest.Financial_Approver_3_Decision__c) && fundingRequest.Financial_Approver_3_Decision__c == REJECTED) ||
            (fundingRequest.Financial_Approver_4_Decision__c != oldFundingRequest.Financial_Approver_4_Decision__c && String.isNotBlank(fundingRequest.Financial_Approver_4_Decision__c) && fundingRequest.Financial_Approver_4_Decision__c == REJECTED) ||
            (fundingRequest.Financial_Approver_5_Decision__c != oldFundingRequest.Financial_Approver_5_Decision__c && String.isNotBlank(fundingRequest.Financial_Approver_5_Decision__c) && fundingRequest.Financial_Approver_5_Decision__c == REJECTED)) {
                return true;
            }
        return false;
    }
    
    /**
* @description Method to check if Founding Request was rejected on Business Approval level. It is used for foundation and non foundation Requests. Used on field change in trigger.
*
* @param oldFundingRequest Funding Request before status change on field.
* @param fundingRequest Funding Request after status change on field.
* @param foundation true for Foundation requests.
*
* @return true if Request was rejected.
*/
    public static Boolean isBusinessApprovalRejected(GFRS_Funding_Request__c oldFundingRequest, GFRS_Funding_Request__c fundingRequest, Boolean foundation) {
        if (foundation) {
            if ((fundingRequest.Business_Approver_2_Decision__c != oldFundingRequest.Business_Approver_2_Decision__c && String.isNotBlank(fundingRequest.Business_Approver_2_Decision__c) && fundingRequest.Business_Approver_2_Decision__c == REJECTED) ||
                (fundingRequest.Business_Approver_3_Decision__c != oldFundingRequest.Business_Approver_3_Decision__c && String.isNotBlank(fundingRequest.Business_Approver_3_Decision__c) && fundingRequest.Business_Approver_3_Decision__c == REJECTED)) {
                    return true;
                }
            return false;
        } else {
            return isBusinessApprovalRejected(oldFundingRequest, fundingRequest);
        }
    }
    
    public static void saveLockedOrganizations(List<GFRS_Organization__c> orgs) {
        for (GFRS_Organization__c org : orgs) {
            org.IsValidationExternalOnly__c = 'Yes';
        }
        upsert orgs;
    }
    
    public static void calculateOrganizationTotalApprovedCurrentYear(Map<Id, GFRS_Organization__c> organizations) {
        
        for (GFRS_Organization__c org : organizations.values()) {
            org.Total_Approved_Current_Year__c = 0;
        }
        
        List<ProcessInstance> processInstances = new List<ProcessInstance>();
        Map<Id, ProcessInstanceNode> processInstanceNodes = new Map<Id, ProcessInstanceNode>();
        Map<Id, GFRS_Funding_Request__c> requestsIdsFromOrg = gFRS_Util_NoShare.getRequestsFromOrganizations(new List<Id>(organizations.keySet()));
        
        processInstances = gFRS_Util_NoShare.getProcessInstancesForAffectedSteps(new List<Id>(requestsIdsFromOrg.keySet()), new List<String>{
            PENDING
                });
        
        List<GFRS_Funding_Request__c> requestsApproved = [
            SELECT Id, Approved_Amount__c, Organization__c
            FROM GFRS_Funding_Request__c
            WHERE
            Used_this_year__c > 0 AND
            Approved_Amount__c != NULL AND
            SYS_Request_Approved__c = 'Yes' AND
            Funding_Type__c IN ('Health Care-Related Charitable', 'Fellowships', 'Scientific Project Support') AND
            Foundation_Classified__c = 'FALSE' AND
            Organization__c IN :organizations.keySet()
        ];
        
        if (processInstances.size() > 0) {
            processInstanceNodes = gFRS_Util_NoShare.getProcessInstanceNodes(processInstances, new List<String>(BUSINESS_APPROVAL_STEPS));
            
            List<GFRS_Funding_Request__c> requestsInApprovalToCount = [
                SELECT Id, Approved_Amount__c, Organization__c
                FROM GFRS_Funding_Request__c
                WHERE Id IN :processInstanceNodes.keySet() AND
                Approved_Amount__c != NULL AND
                Funding_Type__c IN ('Health Care-Related Charitable', 'Fellowships', 'Scientific Project Support') AND
                Foundation_Classified__c = 'FALSE' AND
                Organization__c IN :organizations.keySet()
            ];
            requestsApproved.addAll(requestsInApprovalToCount);
        }
        
        for (GFRS_Funding_Request__c requestUsedThisYear : requestsApproved) {
            
            if (requestUsedThisYear.Approved_Amount__c != null) {
                organizations.get(requestUsedThisYear.Organization__c).Total_Approved_Current_Year__c += requestUsedThisYear.Approved_Amount__c;
            }
        }
        
        try {
            saveLockedOrganizations(organizations.values());
        } catch (Exception err) {
            System.debug('Exception occurred while updating organization budget:' + err.getMessage());
        }
    }
    
    //GFRS-1083
    private static Map<Id, GFRS_Organization__c> organizationsMap = new Map<Id, GFRS_Organization__c>();
    
    //GFRS-1083
    private static Map<Id, GFRS_Organization__c> getOrganizationsMap(List<GFRS_Funding_Request__c> fundingRequests) {
        Map<Id, GFRS_Organization__c> organizations = new Map<Id, GFRS_Organization__c>();
        Set<Id> organizationsToQuery = new Set<Id>();
        for (GFRS_Funding_Request__c fundingRequest : fundingRequests) {
            if (organizationsMap.containsKey(fundingRequest.Organization__c)) {
                organizations.put(fundingRequest.Organization__c, organizationsMap.get(fundingRequest.Organization__c));
            } else {
                organizationsToQuery.add(fundingRequest.Organization__c);
            }
        }
        
        if (organizationsToQuery.size() > 0) {
            for (GFRS_Organization__c org : [SELECT Id, (SELECT Id FROM gFRS_Copay_Funding_Request__r) FROM GFRS_Organization__c WHERE Id IN:organizationsToQuery]) {
                organizations.put(org.Id, org);
                organizationsMap.put(org.Id, org);
            }
        }
        return organizations;
    }
    
    //GFRS-1083
    public static void validateIfExceededOrganizationBudgetOrRevenue(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        List<String> approvalsOrder = new List<String>{
            'Business_Approver_Decision_Date__c',
                'Financial_Approver_1_Decision_Date__c',
                'Financial_Approver_2_Decision_Date__c',
                'Financial_Approver_3_Decision_Date__c',
                'Financial_Approver_4_Decision_Date__c'
                };
                    
                    Map<String, String> approvalFields = new Map<String, String>{
                        'Business_Approver_Decision_Date__c' => 'Business_Approver_Decision__c',
                            'Financial_Approver_1_Decision_Date__c' => 'Financial_Approver_1_Decision__c',
                            'Financial_Approver_2_Decision_Date__c' => 'Financial_Approver_2_Decision__c',
                            'Financial_Approver_3_Decision_Date__c' => 'Financial_Approver_3_Decision__c',
                            'Financial_Approver_4_Decision_Date__c' => 'Financial_Approver_4_Decision__c'
                            };
                                
                                Set<String> affectedFundingTypes = new Set<String>{
                                    'Health Care-Related Charitable', 'Fellowships', 'Scientific Project Support'
                                        };
                                            
                                            try {
                                                
                                                Map<Id, GFRS_Organization__c> organizations = getOrganizationsMap(newRequestsMap.values());
                                                
                                                for (GFRS_Funding_Request__c reqItem : newRequestsMap.values()) {
                                                    
                                                    GFRS_Funding_Request__c oldReq = oldRequestsMap.get(reqItem.Id);
                                                    
                                                    if (affectedFundingTypes.contains(reqItem.Funding_Type__c) && reqItem.Foundation_Classified__c == 'FALSE') {
                                                        
                                                        Map<String, Object> flags = String.isNotBlank(reqItem.Acknowledge_Current_Revenue_Flags__c) ?
                                                            (Map<String, Object>) JSON.deserializeUntyped(reqItem.Acknowledge_Current_Revenue_Flags__c) : new Map<String, Object>();
                                                        
                                                        Boolean isHybridOrg = organizations.get(reqItem.Organization__c).gFRS_Copay_Funding_Request__r.size() > 0 ? true : false;
                                                        
                                                        String percentValueField;
                                                        
                                                        if (isHybridOrg) {
                                                            percentValueField = 'Estimated_Current_Revenue_Percent__c';
                                                        } else {
                                                            percentValueField = 'Percent_of_Org_Operational_Budget__c';
                                                        }
                                                        
                                                        Boolean isError = false;
                                                        
                                                        for (String approvalField : approvalsOrder) {
                                                            if (oldReq.get(approvalField) != reqItem.get(approvalField) &&
                                                                (String) reqItem.get((String) approvalFields.get(approvalField)) == 'Approved' &&
                                                                reqItem.get(approvalField) != null) {
                                                                    
                                                                    if (approvalField == approvalsOrder[0] || flags.size() == 0) {
                                                                        for (String fieldName : approvalsOrder) {
                                                                            flags.put(fieldName, false);
                                                                        }
                                                                        reqItem.Acknowledge_Current_Revenue_Flags__c = JSON.serialize(flags).deleteWhitespace();
                                                                    }
                                                                    
                                                                    if ((Double) reqItem.get(percentValueField) > 33.0) {
                                                                        if (reqItem.Acknowledge_Current_Revenue_33__c == false) {
                                                                            isError = true;
                                                                        } else {
                                                                            reqItem.Acknowledge_Current_Revenue_33__c = false;
                                                                            flags.put(approvalField, true);
                                                                            //reset following flags
                                                                            Integer nextApprovalFieldIndex = approvalsOrder.indexOf(approvalField) + 1;
                                                                            for (Integer i = nextApprovalFieldIndex; nextApprovalFieldIndex < approvalsOrder.size() && i < approvalsOrder.size(); i++) {
                                                                                flags.put(approvalsOrder[i], false);
                                                                            }
                                                                            //update flags on object
                                                                            reqItem.Acknowledge_Current_Revenue_Flags__c = JSON.serialize(flags).deleteWhitespace();
                                                                        }
                                                                    } else {
                                                                        reqItem.Acknowledge_Current_Revenue_33__c = false;
                                                                    }
                                                                    
                                                                    break;
                                                                }
                                                        }
                                                        
                                                        if (isError) {
                                                            String outputErrorMessage = System.Label.gFRS_ExceedApprovalAmountError;
                                                            outputErrorMessage = outputErrorMessage.replace('{!ID}', reqItem.Id);
                                                            outputErrorMessage = outputErrorMessage.replace('{!Hybrid}', isHybridOrg ? '&org=hybrid' : '&org=non');
                                                            outputErrorMessage = outputErrorMessage.replace('{!BudgetOrRevenue1}', isHybridOrg ? 'fiscal revenue' : 'budget');
                                                            outputErrorMessage = outputErrorMessage.replace('{!BudgetOrRevenue2}', isHybridOrg ? 'revenue' : 'annual budget');
                                                            reqItem.addError(outputErrorMessage, false);
                                                        }
                                                    }
                                                }
                                            } catch (Exception ex) {
                                                System.debug(ex.getMessage());
                                            }
    }
    
    //GFRS-1083
    public static void populateAcknowledgeBudgetOrRevenueForApprovedRequests(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        try {
            Set<String> affectedFundingTypes = new Set<String>{
                'Health Care-Related Charitable', 'Fellowships', 'Scientific Project Support'
                    };
                        
                        Map<Id, GFRS_Funding_Request__c> fundingRequestsToQuery = new Map<Id, GFRS_Funding_Request__c>();
            
            Map<Id, GFRS_Organization__c> organizations = getOrganizationsMap(newRequestsMap.values());
            
            for (GFRS_Funding_Request__c reqItem : newRequestsMap.values()) {
                
                GFRS_Funding_Request__c oldReq = oldRequestsMap.get(reqItem.Id);
                
                if (affectedFundingTypes.contains(reqItem.Funding_Type__c) && reqItem.Foundation_Classified__c == 'FALSE') {
                    
                    Boolean isHybridOrg = organizations.get(reqItem.Organization__c).gFRS_Copay_Funding_Request__r.size() > 0 ? true : false;
                    
                    if (reqItem.SYS_Request_Approved__c != oldReq.SYS_Request_Approved__c &&
                        reqItem.SYS_Request_Approved__c != null && reqItem.SYS_Request_Approved__c == 'Yes') {
                            if (isHybridOrg && reqItem.Estimated_Current_Revenue_Percent__c > 33.0) {
                                reqItem.Acknowledge_Current_Revenue_33__c = true;
                            } else {
                                fundingRequestsToQuery.put(reqItem.Id, null);
                            }
                        }
                    
                }
            }
            
            if (fundingRequestsToQuery.size() > 0) {
                fundingRequestsToQuery = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, Percent_of_Org_Operational_Budget__c FROM GFRS_Funding_Request__c WHERE Id IN:fundingRequestsToQuery.keySet()]);
                for (GFRS_Funding_Request__c fundingRequest : fundingRequestsToQuery.values()) {
                    if (fundingRequest.Percent_of_Org_Operational_Budget__c > 33.0) {
                        newRequestsMap.get(fundingRequest.Id).Acknowledge_Current_Revenue_33__c = true;
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    //GFRSME2-11
    public static void checkForBAApprovalAndWBSCode(Map<Id, GFRS_Funding_Request__c> requestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        List<GFRS_Funding_Allocation_Line_Item__c> fundingAllocationLineItems = gFRS_DAO.getAllocationLineItemListByRequestIdsAndAllocationType(new List<Id>(requestsMap.keySet()), 'Payment');
        Map<Id, Id> itemsWithoutWBS = new Map<Id, Id>();
        
        for (GFRS_Funding_Request__c request : requestsMap.values()) {
            if ((request.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME
                 || request.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME
                 || request.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME
                 || request.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME)
                && request.Business_Approver_Decision__c == gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED
                && request.Business_Approver_Decision__c != oldRequestsMap.get(request.Id).Business_Approver_Decision__c
                && request.Foundation_Classified__c == 'FALSE') {
                    
                    itemsWithoutWBS = getItemsWithoutWBS(fundingAllocationLineItems);
                    
                    if (itemsWithoutWBS.size() > 0) {
                        request.addError(Label.gFRS_ERROR_WBS_CODE_MISSING
                                         .replace('{!REQUEST_ID}', request.Id)
                                         .replace('{!REQUEST_NAME}', request.Name)
                                         .replace('{!ALLOCATION_ID}', itemsWithoutWBS.get(request.Id)),
                                         false);
                    }
                }
        }
    }
    
    private static Map<Id, Id> getItemsWithoutWBS(List<GFRS_Funding_Allocation_Line_Item__c> sourceList) {
        Map<Id, Id> itemsWithoutWBS = new Map<Id, Id>();
        for (GFRS_Funding_Allocation_Line_Item__c lineItem : sourceList) {
            if (String.isBlank(lineItem.WBS__c)) {
                itemsWithoutWBS.put(lineItem.Funding_Allocation__r.Grant_Request__c, lineItem.Funding_Allocation__c);
            }
        }
        return itemsWithoutWBS;
    }
    
    //SFDC-1420-1720
    public static GFRS_Funding_Allocation_Line_Item__c insertFundingAllocLineItem(GFRS_Funding_Allocation_Line_Item__c li) {
        insert li;
        return li;
    }
    //SFDC-1420-1720
    public static void deleteFundingAllocLineItem(GFRS_Funding_Allocation_Line_Item__c li) {
        delete li;
    }
    
    //SFDC-1730
    
    
    @Future(Callout=true)
    public static void populateVenueCityFutureCall(Set<Id> programIds) {
        populateVenueCity([
            SELECT Id,RecordTypeId, Funding_Request__c, Venue_City__c,Program_Status__c
            FROM GFRS_Program__c
            WHERE Id IN:programIds
        ]);
    }
    
    public static void populateVenueCity(List<GFRS_Program__c> programsList) {
        List<GFRS_Funding_Request__c> fundingRequestToUpdate = new List<GFRS_Funding_Request__c>();
        Map<Id, List<GFRS_Program__c>> mapRequestToPrograms = new Map<Id, List<GFRS_Program__c>>();
        List<Id> programsIds = new List<Id>();
        
        for (GFRS_Program__c program : programsList) {
            programsIds.add(program.Funding_Request__c);
        }
        
        RecordType recordTypeItem = null;
        
        try {
            
            if (programsList.size() > 0 && programsList[0].RecordTypeId != null) {
                recordTypeItem = [SELECT DeveloperName FROM RecordType WHERE Id = :programsList[0].RecordTypeId];
            }
            if (recordTypeItem != null && recordTypeItem.DeveloperName.contains('HC_Char')) {
                programsList = [SELECT Id, Funding_Request__c, Venue_City__c,Program_Status__c FROM GFRS_Program__c WHERE Funding_Request__c IN :programsIds];
            } else {
                programsList = [SELECT Id, Funding_Request__c, Venue_City__c,Program_Status__c FROM GFRS_Program__c WHERE Funding_Request__c IN :programsIds];
            }
            
            for (GFRS_Program__c programFromList : programsList) {
                List<GFRS_Program__c> tempList = new List<GFRS_Program__c>();
                if (mapRequestToPrograms.containsKey(programFromList.Funding_Request__c)) {
                    tempList = mapRequestToPrograms.get(programFromList.Funding_Request__c);
                    tempList.add(programFromList);
                    mapRequestToPrograms.put(programFromList.Funding_Request__c, tempList);
                } else {
                    tempList.add(programFromList);
                    mapRequestToPrograms.put(programFromList.Funding_Request__c, tempList);
                }
            }
            
            Set<String> venueCities = null;
            List<String> listOfCities = null;
            //Added changes for HC Char program types
            Map<Id, String> venueCitiesForRequest = new Map<Id, String>();
            if (recordTypeItem != null && recordTypeItem.DeveloperName.contains('HC_Char')) {
                for (Id fundingRequest : mapRequestToPrograms.keySet()) {
                    String CitisForHCCHar = '';
                    if (mapRequestToPrograms.get(fundingRequest) != null) {
                        venueCities = new Set<String>();
                        for (GFRS_Program__c program : mapRequestToPrograms.get(fundingRequest)) {
                            if (program.Venue_City__c != null && program.Program_Status__c != 'Canceled' && program.Program_Status__c != 'Planned') {
                                if (CitisForHCCHar == '') {
                                    CitisForHCCHar += program.Venue_City__c;
                                    
                                } else {
                                    CitisForHCCHar += ',' + program.Venue_City__c;
                                }
                                
                            }
                        }
                        venueCitiesForRequest.put(fundingRequest, CitisForHCCHar);
                    }
                    //fundingRequestToUpdate.add(fundingRequest);
                }
            } else if (recordTypeItem != null && recordTypeItem.DeveloperName.contains('IMED')) {
                for (Id fundingRequest : mapRequestToPrograms.keySet()) {
                    if (mapRequestToPrograms.get(fundingRequest) != null) {
                        venueCities = new Set<String>();
                        for (GFRS_Program__c program : mapRequestToPrograms.get(fundingRequest)) {
                            if (program.Venue_City__c != null && program.Program_Status__c != 'Canceled' && program.Program_Status__c != 'Entered in Error') {
                                venueCities.add(program.Venue_City__c);
                            }
                        }
                        listOfCities = new List<String>();
                        listOfCities.addAll(venueCities);
                        if (listOfCities.size() > 1) {
                            venueCitiesForRequest.put(fundingRequest, listOfCities.get(0) + '+');
                        } else if (listOfCities.size() == 1) {
                            venueCitiesForRequest.put(fundingRequest, listOfCities.get(0));
                        } else if (listOfCities.size() == 0) {
                            venueCitiesForRequest.put(fundingRequest, '');
                        }
                    }
                    //fundingRequestToUpdate.add(fundingRequest);
                }
            } else {
                //Rest of funding types can have only one program so there is taken
                //City from first program if City isn't null
                for (Id fundingRequest : mapRequestToPrograms.keySet()) {
                    if (mapRequestToPrograms.get(fundingRequest) != null) {
                        venueCities = new Set<String>();
                        for (GFRS_Program__c program : mapRequestToPrograms.get(fundingRequest)) {
                            if (program.Venue_City__c != null) {
                                venueCities.add(program.Venue_City__c);
                            }
                        }
                        listOfCities = new List<String>();
                        listOfCities.addAll(venueCities);
                        if (listOfCities.size() > 0) {
                            venueCitiesForRequest.put(fundingRequest, listOfCities.get(0));
                        } else {
                            //There is no program with Venue City information so set field empty
                            venueCitiesForRequest.put(fundingRequest, '');
                        }
                        
                    }
                }
            }
            fundingRequestToUpdate = [SELECT Id, Venue_City__c FROM GFRS_Funding_Request__c WHERE Id IN :venueCitiesForRequest.keySet()];
            
            for (GFRS_Funding_Request__c fundReq : fundingRequestToUpdate) {
                fundReq.Venue_City__c = venueCitiesForRequest.get(fundReq.Id);
            }
            
            update fundingRequestToUpdate;
        } catch (System.DmlException dmlex) {
            
            System.debug('Exception from method populateVenueCity');
            for (Integer i = 0; i < dmlex.getNumDml(); i++) {
                System.debug(dmlex.getDmlMessage(i));
            }
            
            
        }
        
    }
    
    public static void populateVenueCityAfterDelete(List<GFRS_Program__c> programsList) {
        
        List<Id> fundingRequestsIdsList = new List<Id>();
        for (GFRS_Program__c program : programsList) {
            if (program.Funding_Request__c != null) {
                fundingRequestsIdsList.add(program.Funding_Request__c);
            }
        }
        
        
        Set<Id> affectedPrograms = new Map<Id, GFRS_Program__c>([
            SELECT Id,RecordTypeId, Funding_Request__c, Venue_City__c,Program_Status__c
            FROM GFRS_Program__c
            WHERE IsDeleted = FALSE
            AND Funding_Request__c IN :fundingRequestsIdsList
        ]).keySet();
        
        if (affectedPrograms.size() > 0) {
            populateVenueCityFutureCall(affectedPrograms);
        } else {
            List<GFRS_Funding_Request__c> requestWithBlankVenueCities = [
                SELECT Id, Venue_City__c
                FROM GFRS_Funding_Request__c
                WHERE Id IN :fundingRequestsIdsList
            ];
            for (GFRS_Funding_Request__c fundReq : requestWithBlankVenueCities) {
                fundReq.Venue_City__c = '';
            }
            update requestWithBlankVenueCities;
        }
        
    }
    
    /**
* @Author ADMD Team
* @date 01/11/2012
* @description insertLOAattachment method - create attachement for LOA
*/
    public static void insertLOAattachment(String attName, Blob attBody, GFRS_Funding_Request__c request) {
        Attachment tmpLOADock = new Attachment(Name = attName, Body = attBody, ParentId = request.Id);
        insert tmpLOADock;
        request.LOA_PDF__c = tmpLOADock.Id;
        update request;
    }
    
    /**
* @Author ADMD Team
* @date 01/03/2013
* @description insertComplianceAttachment method - create attachement under funding request with ComplianceChecksFlags
*/
    public static void insertComplianceAttachment(String attName, Blob attBody, GFRS_Funding_Request__c request) {
        Attachment tmpCompDock = new Attachment(Name = attName, Body = attBody, ParentId = request.Id);
        insert tmpCompDock;
        request.Compliance_flags_PDF__c = tmpCompDock.Id;
        update request;
    }
    
    /**
* @Author ADMD Team
* @date 07/02/2017
* @description insertVendorDetailsAttachmentInternal method - create attachment with Vendor Details for internal funding requests
*/
    @Future(Callout=true)
    public static void insertVendorDetailsAttachmentInternal(String attName, Id request) {
        PageReference pageRefPdf = null;
        pageRefPdf = Page.gFRS_VendorDetailsPDF;
        pageRefPdf.getParameters().put('Id', request);
        Blob attBody = pageRefPdf.getContent();
        Attachment tmpVendorDoc = new Attachment(Name = attName, Body = attBody, ParentId = request);
        upsert tmpVendorDoc;
        GFRS_Funding_Request__c req = [SELECT Vendor_Details_PDF__c FROM GFRS_Funding_Request__c WHERE Id = :request LIMIT 1];
        req.Vendor_Details_PDF__c = tmpVendorDoc.Id;
        update req;
    }
    
    /**
* @Author ADMD Team
* @date 07/02/2017
* @description insertVendorDetailsAttachmentExternal method - create attachment with Vendor Details for external funding requests
*/
    public static void insertVendorDetailsAttachmentExternal(String attName, Blob attBody, GFRS_Funding_Request__c request) {
        Attachment tmpVendorDoc = new Attachment(Name = attName, Body = attBody, ParentId = request.Id);
        insert tmpVendorDoc;
        request.Vendor_Details_PDF__c = tmpVendorDoc.Id;
        update request;
    }
    
    /**
* @Author ADMD Team
* @date 01/03/2013
* @description insertComplianceAttachment method - create attachement under funding request with ComplianceChecksFlags
*/
    public static void insertFundingRequestAttachment(String fieldName, String attachmentName, Blob attBody, GFRS_Funding_Request__c fundingRequest) {
        Attachment tempAttachment = new Attachment(Name = attachmentName, Body = attBody, ParentId = fundingRequest.Id);
        insert tempAttachment;
        fundingRequest.put(fieldName, tempAttachment.Id);
        update fundingRequest;
    }
    
    /**
* @Author ADMD Team
* @date 04/18/2013
* @description setLastGrantStatus method - set Grant Status moved from workflow
*/
    public static void setLastGrantStatus(List<GFRS_Funding_Request__c> requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        for (GFRS_Funding_Request__c item : requests) {
            if (item.Sub_Status__c != null && oldMap != null && oldMap.containsKey(item.Id)) {
                item.Last_Grant_Status__c = oldMap.get(item.Id).Sub_Status__c;
            }
        }
    }
    
    /**
* @Author ADMD Team
* @date 04/18/2013
* @description setProcessPaymentStatusDate method - set Process_Payment_Status_Date__c on date when request was last time in substatus Process Payment moved from workflow
*/
    public static void setProcessPaymentStatusDate(List<GFRS_Funding_Request__c> requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        for (GFRS_Funding_Request__c item : requests) {
            if (item.Sub_Status__c != null && item.Sub_Status__c == 'Process Payment') {
                item.Process_Payment_Status_Date__c = Date.today();
            }
        }
    }
    
    /**
* @Author ADMD Team
* @date 04/19/2013
* @description setClosedDate method - set Closed_Date__c on date when request get status Closed moved from workflow
*/
    public static void setClosedDate(List<GFRS_Funding_Request__c> requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        for (GFRS_Funding_Request__c item : requests) {
            if (item.Status__c != null && item.Status__c == gFRS_Util.REQUEST_STATUS_CLOSED
                && oldMap != null
                && oldMap.containsKey(item.Id)
                && oldMap.get(item.Id).Status__c != item.Status__c) {
                    item.Closed_Date__c = Date.today();
                }
        }
    }
    
    /**
* @Author ADMD Team
* @date 04/19/2013
* @description resetSysRequestApprovedToNo method - reset field SYS_Request_Approved__c to No moved from workflow
*/
    public static void resetSysRequestApprovedToNo(List<GFRS_Funding_Request__c> requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        for (GFRS_Funding_Request__c item : requests) {
            if (item.Sub_Status__c != null
                && item.Status__c != null
                && item.Status__c == 'Closed'
                && (item.Sub_Status__c == 'Canceled' || item.Sub_Status__c == 'Denied')
                && item.SYS_Request_Approved__c != null) {
                    
                    if (item.SYS_Request_Approved__c == 'Yes') {
                        item.Request_Approved__c = true;
                    }
                    item.SYS_Request_Approved__c = 'No';
                    
                }
        }
    }
    
    /**
* @Author ADMD Team
* @date 05/02/2013
* @description checkIfUserIsExternalRequester method - return true if user profile name is  GNE-GFRS-External Requestor
*/
    
    public static Boolean checkIfUserIsExternalRequester(Id profileId) {
        Profile profileItem = [SELECT Id, Name FROM Profile WHERE Name = 'GNE-GFRS-External Requestor' LIMIT 1];
        if (profileItem != null && profileItem.Id == profileId) {
            return true;
        }
        return false;
    }
    
    /**
* @author ADMD Team
* @date 07/05/2013
* @description checkIfVenueCityOrStatusUnderProgramChanged method - helper method which checks if program status or venueCity was changed.
*
*/
    
    public static Boolean checkIfVenueCityOrStatusUnderProgramChanged(List<GFRS_Program__c> newList, Map<Id, GFRS_Program__c> oldMap, List<String> fieldNames) {
        //if( resultList == null ) return;
        //resultList.clear();
        List<GFRS_Program__c> resultList = new List<GFRS_Program__c>();
        //-- if oldMap is null, then all items must be new
        if (oldMap == null) {
            resultList.addAll(newList);
            return resultList.size() > 0;
        }
        
        SObject old;
        for (GFRS_Program__c obj : newList) {
            if (obj.Id != null) {
                if (oldMap.containsKey(obj.Id)) {
                    old = oldMap.get(obj.Id);
                    //System.debug( 'old[' + fieldName + ']:' + old.get(fieldName) + ', ob[]:' + obj.get(fieldName) );
                    for (String fieldName : fieldNames) {
                        if (old.get(fieldName) != obj.get(fieldName)) {
                            resultList.add(obj);
                            break;
                        }
                    }
                } else {
                    resultList.add(obj);
                }
            } else {
                resultList.add(obj);
            }
        }
        return resultList.size() > 0;
    }
    
    /**
* @author ADMD Team
* @date 09/05/2013
* @description getSubmitedRequestUnderOrg method - retunr numer of request sumbmited under one org - veryfied BY tax Id.
*
*/
    
    public static Integer getSubmitedRequestUnderOrg(String taxId, String nonUSTaxId) {
        AggregateResult submitedRequestUnderOrg = null;
        if (taxId != null) {
            submitedRequestUnderOrg = [SELECT COUNT(Id) counter FROM GFRS_Funding_Request__c WHERE Organization__r.Tax_Id__c = :taxId AND Status__c != 'Intake'];
        } else if (nonUSTaxId != null) {
            submitedRequestUnderOrg = [SELECT COUNT(Id) counter FROM GFRS_Funding_Request__c WHERE Organization__r.Non_US_Organization_ID__c = :nonUSTaxId AND Status__c != 'Intake'];
        }
        if (submitedRequestUnderOrg == null) {
            return 0;
        }
        return Integer.valueOf(submitedRequestUnderOrg.get('counter'));
    }
    
    /**
* @author ADMD Team
* @date 17/05/2013
* @description resetExhibitOpportunity method - reset all fields to null in section exhibit opportunity under application page (Corp Membership - e.g benefit Exhibit Space)
*
*/
    public static void resetExhibitOpportunity(GFRS_Funding_Request__c request) {
        try {
            request.Total_Program_Budget__c = null;
            request.Event_Project_type__c = null;
            request.Intended_Audience__c = null;
            request.Other_Commercial_Supporters__c = null;
            request.If_known_List_Other_Supporters__c = null;
            Attachment att = [SELECT Id, ParentId, Name FROM Attachment WHERE Id = :request.Meeting_Agenda__c];
            request.Meeting_Agenda__c = null;
            
            if (att != null) {
                delete att;
            }
        } catch (Exception ex) {
            System.debug('EXCEPTION OCCURS IN METHOD resetExhibitOpportunity');
            System.debug(ex.getMessage());
        }
    }
    
    /**
* @author ADMD Team
* @date 17/05/2013
* @description preventUnifiedCalendarDuplicate method - method checks if record is uniq
*
*/
    
    public static void preventUnifiedCalendarDuplicate(List<UnifiedCalendar_gne__c> records) {
        List<String> uniqueValueList = new List<String>();
        for (UnifiedCalendar_gne__c item : records) {
            uniqueValueList.add(item.User_Unified_Calendar__c + item.Secondary_Calendar_Name__c);
        }
        
        List<UnifiedCalendar_gne__c> unifiedCalendarExistingList = [SELECT Id, UniqRecord__c FROM UnifiedCalendar_gne__c WHERE UniqRecord__c IN :uniqueValueList];
        Map<String, UnifiedCalendar_gne__c> uniqueValueMap = new Map<String, UnifiedCalendar_gne__c>();
        for (UnifiedCalendar_gne__c item : unifiedCalendarExistingList) {
            uniqueValueMap.put(item.UniqRecord__c, item);
        }
        for (UnifiedCalendar_gne__c item : records) {
            if (uniqueValueMap.containsKey(item.User_Unified_Calendar__c + item.Secondary_Calendar_Name__c)) {
                item.addError('There is already an existing secondary calendar with the same name for this user');
            }
        }
        
    }
    
    /**
* @author ADMD Team
* @date 17/05/2013
* @description submitHC_Programs method - change program status from planned to confirmed when request will be resubmited.
*
*/
    
    public static void submitHC_Programs(GFRS_Funding_Request__c[] newList, Map<Id, GFRS_Funding_Request__c> oldMap) {
        Id[] recentlySubmitedRequests = new Id[]{
        };
            
            //-- find all funding requests that have been recently approved
            GFRS_Funding_Request__c oldRequest = null;
        for (GFRS_Funding_Request__c newRequest : newList) {
            if (gFRS_Util.TYPE_HC_CHAR_NAME.equals(newRequest.Record_Type_Name__c) &&
                oldMap.containsKey(newRequest.Id)
               ) {
                   
                   oldRequest = oldMap.get(newRequest.Id);
                   
                if (oldRequest.Status__c == 'Intake' && newRequest.Status__c == 'HC Compliance') {
                        recentlySubmitedRequests.add(newRequest.Id);
                }else if(oldRequest.Sub_Status__c == 'RFI' && newRequest.Sub_Status__c == 'RFI Received'){
                      recentlySubmitedRequests.add(newRequest.Id);    
                }
            }
        }
        
        //-- update all programs for those funding requests to status confirmed.
        if (recentlySubmitedRequests.size() > 0) {
            GFRS_Program__c[] updatedPrograms = new GFRS_Program__c[]{
            };
                for (GFRS_Program__c program : [
                    SELECT Id, Program_Status__c
                    FROM GFRS_Program__c
                    WHERE Funding_Request__c IN :recentlySubmitedRequests
                ]
                    ) {
                        if (program.Program_Status__c == 'Planned') {
                            program.Program_Status__c = 'Confirmed';
                            updatedPrograms.add(program);
                        }
                    }
            if (updatedPrograms.size() > 0) update updatedPrograms;
        }
    }
    
    /* @Author ADMD Team
* @date 06/24/2013
* @description checkIfUserIsSuperUser method - return true if user is admin profile like
*/
    public static Boolean checkIfUserIsSuperUser(Id profileId) {
        for (Profile profileItem : [SELECT Id, Name FROM Profile WHERE Name IN('GNE-GFRS-Admin', 'GNE-GFRS-Super User', 'System Administrator')]) {
            if (profileItem != null && profileItem.Id == profileId) {
                return true;
            }
        }
        return false;
    }
    
    public static Boolean checkCustomPermission(String permissionName) {
        Set<Id> permissionSetIds = new Set<Id>();
        for (SetupEntityAccess access : [
            SELECT ParentId
            FROM SetupEntityAccess
            WHERE SetupEntityId IN (
                SELECT Id
                FROM CustomPermission
                WHERE DeveloperName = :permissionName
            )
        ]) {
            permissionSetIds.add(access.ParentId);
        }
        return permissionSetIds.isEmpty() ? false : ![
            SELECT Id
            FROM PermissionSetAssignment
            WHERE PermissionSetId IN :permissionSetIds AND AssigneeId = :UserInfo.getUserId()
        ].isEmpty();
    }
    
    /* @Author ADMD Team
* @date 23/07/2013
* @description deleteAppropriateHCProgramsIfExists method - updates needed program and deletes unneeded programs after change of funding type
*/
    public static void deleteAppropriateHCProgramsIfExists(Id fundReqId) {
        List<GFRS_Funding_Request__c> fundReqsList = gFRS_DAO.getFundingRequestById(fundReqId);
        if (fundReqsList == null || fundReqsList.size() < 1) {
            return;
        }
        
        GFRS_Funding_Request__c fundReq = fundReqsList.get(0);
        
        if ((fundReq.Event_Project_type__c == 'Patient education' || fundReq.Event_Project_type__c == 'Patient services') && fundReqsList != null && fundReqsList.size() > 0) {
            return;
        }
        
        List<GFRS_Program__c> programList = [
            SELECT Id, IsDeleted, Name, CreatedDate, CreatedById,
            LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit,
            IsLocked, Activities__c, Actual_Time_at_Display_Table_Hours__c,
            Audience_Non_US_Based__c, Audience_US_Based__c, Criteria_for_Fellow_Selection__c,
            End_Date__c, Enduring_Materials_Opt_Out_Description__c,
            Enduring_Materials_Opt_Out__c, Funding_Request__c, Funding_Request__r.Status__c,
            Geographic_Region__c, Is_CMEO__c, NCI_Designated_Cancer_Center__c, Number_of_Tables__c,
            Outstanding_Accounts_Payable__c, Product_being_Promoted__c, Program_Subtype__c,
            Publicity_Plan__c, Size_of_Exhibit__c, Speakers_Faculty__c, Start_Date__c,
            Status__c, Type__c, Venue_City__c, Venue_Country__c, Venue_Name__c,
            Venue_State__c, Venue_Type__c, Venue_Zip_Code__c, Verified__c, Web_URL__c,
            Expected_Number_of_Attendees__c, Expected_of_attendees_that_are_HCPs__c,
            Expected_of_Attendees_US_Based_HCPs__c, Event_Program_Type__c, Funding_Type__c,
            Support_Purpose_Program_Description__c, Booth_Type__c, Number_of_Activities__c,
            Alternate_Program_Title__c, Number_of_Learners_del__c,
            Number_of_Learners_Receiving_CME_Credits__c, Average_Years_in_Practice__c,
            Total_Number_of_Participants__c, Average_Number_of_Patients__c, Total_Visits__c,
            Number_of_Pages_Viewed__c, Total_Number_of_Pages__c, Results_were_Achieved__c,
            If_Results_Not_Achieved_State_Why__c, Letter_of_Request__c, Meeting_Agenda__c,
            Needs_Assessment_Document__c, Implementation_Plan__c, Fellowship_Project_Description__c,
            Educational_Objectives_Intended_Outcome__c, Program_Status__c,
            Did_Total_Budget_Amount_for_this_Program__c, If_Yes_New_Total_Budget_for_Program__c,
            Change_in_Number_of_Commercial_Supporter__c, If_Yes_How_Many_Commercial_Supporters__c,
            Did_Educational_Objectives_Change__c, If_Yes_New_Educational_Objectives__c,
            Other_Companies_Supporting_Meeting__c, Intended_Audience__c, Method_for_Measuring_Program_Success__c,
            Event_Meeting_Membership_Public__c, Does_Event_Have_Volunteering_Opportunity__c,
            Is_Volunteering_Opportunity_Public__c, ACGME_Program_Number__c,
            Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_this_Process__c,
            Outcomes_Review_Comments__c, Were_Learning_Objectives_Achieved_LOA__c,
            Number_of_Respondents_LOA__c, Percent_Responding_LOA__c,
            Did_Activity_Achieve_Objectives_ASA__c, Number_of_Respondents_ASA__c,
            Percent_Responding_ASA__c, Was_Material_Organized_Clearly_MOC__c,
            Number_of_Respondents_MOC__c, Percent_Responding_MOC__c, Format_Helpful_in_Achieving_Objective_FH__c,
            Number_of_Respondents_FH__c, Percent_Responding_FH__c, Did_Activity_Provide_Interactivity_APO__c,
            Number_of_Respondents_APO__c, Percent_Responding_APO__c, Did_You_Find_the_Format_to_be_Useful_AFU__c,
            Number_of_Respondents_AFU__c, Percent_Responding_AFU__c, Is_the_Content_Relevant_to_Practice_CR__c,
            Number_of_Respondents_CR__c, Promotional_Event_Advertising_URL__c, Percent_Responding_CR__c,
            Activity_Address_Overcoming_Barrier_AAS__c, Number_of_Respondents_AAS__c, Letter_of_Request_URL__c,
            Percent_Responding_AAS__c, Does_Content_Translate_Evidence_CTE__c,
            Number_of_Respondents_CTE__c, Meeting_Agenda_URL__c, Percent_Responding_CTE__c,
            Program_Reinforce_Current_Patterns_CPP__c, Number_of_Respondents_CPP__c,
            Needs_Assessment_Document_URL__c, Percent_Responding_CPP__c, Will_Content_Impact_Your_Practice_CIP__c,
            Number_of_Respondents_CIP__c, Implementation_Plan_URL__c, Percent_Responding_CIP__c,
            Did_Content_Contribute_Valuable_Info_CVI__c, Number_of_Respondents_CVI__c,
            Percent_Responding_CVI__c, Would_You_Recommend_to_Colleagues_RAC__c,
            Number_of_Respondents_RAC__c, Percent_Responding_RAC__c, Rating_Against_Other_CME_Activities_AR__c,
            Number_of_Respondents_AR__c, Percent_Responding_AR__c, Was_the_Activity_Fair_and_Balanced_FAB__c,
            Number_of_Respondents_FAB__c, Percent_Responding_FAB__c, Fellowship_Project_Description_URL__c,
            Venue_Province_Region__c, Benefits_Exchanged_for_Funding__c, Other_Commercial_Supporters__c,
            If_Known_List_Other_Supporters__c, Promotional_Event_Advertising__c, Additional_Document_Uploads__c,
            Additional_Document_Uploads_2__c, Additional_Document_Uploads_3__c, Additional_Document_Uploads_4__c,
            Additional_Document_Uploads_5__c, Exhibits_or_Displays_Allowed__c
            FROM GFRS_Program__c
            WHERE Funding_Request__c = :fundReq.Id
            ORDER BY CreatedDate DESC
        ];
        
        if (programList.size() > 0) {
            GFRS_Program__c programToSave = null;
            List<GFRS_Program__c> programsToDelete = new List<GFRS_Program__c>();
            if (fundReq.Event_Project_type__c == 'Financial assistance' || fundReq.Event_Project_type__c == 'General organizational support') {
                Boolean firsProgramFound = false;
                for (GFRS_Program__c item : programList) {
                    if (!firsProgramFound && item.Type__c == 'Ongoing') {
                        firsProgramFound = true;
                        continue;
                    } else {
                        programsToDelete.add(item);
                    }
                }
                if (programToSave == null && programsToDelete.size() == programList.size()) {
                    programToSave = programsToDelete[0];
                    programToSave.Type__c = 'Ongoing';
                    
                    resetUnusedFieldForHCChar(programToSave);
                    programsToDelete.remove(0);
                }
            } else if (fundReq.Event_Project_type__c == 'Fundraiser' || fundReq.Event_Project_type__c == 'Health Screenings') {
                for (GFRS_Program__c item : programList) {
                    if (item.Type__c == 'Live Activity') {
                        continue;
                    } else {
                        programsToDelete.add(item);
                    }
                }
                if (programToSave == null && programsToDelete.size() == programList.size()) {
                    
                    programToSave = programsToDelete[0];
                    programToSave.Type__c = 'Live Activity';
                    resetUnusedFieldForHCChar(programToSave);
                    programsToDelete.remove(0);
                }
            } else if (fundReq.Event_Project_type__c == 'Policy and Advocacy' && fundReq.Event_Project_sub_type__c  == 'Evidence generation in policy (e.g., issue briefs, info graphics)') {
                Boolean firsProgramFound = false;
                for (GFRS_Program__c item : programList) {
                    if (!firsProgramFound && (item.Type__c == 'Ongoing' || item.Type__c == 'Online Resources')) {
                        firsProgramFound = true;
                        continue;
                    } else {
                        programsToDelete.add(item);
                    }
                }
                if (programToSave == null && programsToDelete.size() == programList.size()) {
                    
                    programToSave = programsToDelete[0];
                    programToSave.Type__c = 'Ongoing';
                    resetUnusedFieldForHCChar(programToSave);
                    programsToDelete.remove(0);
                }
            } else if (fundReq.Event_Project_type__c == 'Patient Support' && fundReq.Event_Project_sub_type__c  == 'Financial Assistance') {
                Boolean firsProgramFound = false;
                for (GFRS_Program__c item : programList) {
                    if (!firsProgramFound && item.Type__c == 'Ongoing') {
                        firsProgramFound = true;
                        continue;
                    } else {
                        programsToDelete.add(item);
                    }
                }
                if (programToSave == null && programsToDelete.size() == programList.size()) {
                    
                    programToSave = programsToDelete[0];
                    programToSave.Type__c = 'Ongoing';
                    resetUnusedFieldForHCChar(programToSave);
                    programsToDelete.remove(0);
                }
            } else if (fundReq.Event_Project_type__c == 'International scientific/medical meeting'
                       || fundReq.Event_Project_type__c == 'National scientific/medical meetings'
                       || fundReq.Event_Project_type__c == 'Regional scientific/medical meetings'
                       || fundReq.Event_Project_type__c == 'Local scientific/medical meetings'
                       || fundReq.Event_Project_type__c == 'Scientific/medical meeting') {
                           Boolean firsProgramFound = false;
                           for (GFRS_Program__c item : programList) {
                               if (!firsProgramFound && item.Type__c == 'Live Activity') {
                                   firsProgramFound = true;
                                   continue;
                               } else {
                                   programsToDelete.add(item);
                               }
                           }
                           if (programToSave == null && programsToDelete.size() == programList.size()) {
                               programToSave = programsToDelete[0];
                               programToSave.Type__c = 'Live Activity';
                               resetUnusedFieldForHCChar(programToSave);
                               programsToDelete.remove(0);
                           }
                       }
            if (programsToDelete.size() > 0) {
                delete programsToDelete;
            }
            if (programToSave != null) {
                update programToSave;
            }
        }
        
        
    }
    
    /* @Author gFRS Dev Team
* @date 15/07/2019
* @description deleteAppropriateSciPipeandExhibitsProgramsIfExists method - updates needed program and deletes unneeded programs after change of program type
*/
    public static void deleteAppropriateSciPipeandExhibitsProgramsIfExists(Id fundReqId) {
        List<GFRS_Funding_Request__c> fundReqsList = gFRS_DAO.getFundingRequestById(fundReqId);
        if (fundReqsList == null || fundReqsList.size() < 1) {
            return;
        }
        
        GFRS_Funding_Request__c fundReq = fundReqsList.get(0);
        
        if ((fundReq.Event_Project_type__c == 'Patient education' && fundReq.Event_Project_type__c == 'Fundraiser' && fundReq.Event_Project_type__c == 'Vendor fair') && fundReqsList != null && fundReqsList.size() > 0) {
            return;
        }
        
        List<GFRS_Program__c> programList = [
            SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, Type__c
            FROM GFRS_Program__c
            WHERE Funding_Request__c = :fundReq.Id
            ORDER BY CreatedDate DESC
        ];
        
        if (programList.size() > 0) {
            GFRS_Program__c programToSave = null;
            List<GFRS_Program__c> programsToDelete = new List<GFRS_Program__c>();
            
            programsToDelete.addall(programList);
            programsToDelete.remove(0);
            
            if (programsToDelete.size() > 0) {
                delete programsToDelete;
            }
        }
        
    }   
    
    /**
* @author ADMD Team
* @date 20/03/2013
* @description resetUnusedFieldForHCChar method - reset fields for HC Char programs if field Type__c will be changed
*/
    public static void resetUnusedFieldForHCChar(GFRS_Program__c partial) {
        
        if (partial.Funding_Request__r.Status__c == 'Intake'
            && (partial.Type__c == 'Ongoing' || partial.Type__c == 'Online Resources')
            && partial.Meeting_Agenda__c != null
            && partial.Meeting_Agenda__c != '') {
                deleteAttachments(partial.Meeting_Agenda__c);
            }
        
        if (partial.Type__c == 'Live Activity') {
            partial.Web_URL__c = null;
            
        } else if (partial.Type__c == 'Ongoing') {
            partial.Web_URL__c = null;
            partial.Exhibits_or_Displays_Allowed__c = null;
            partial.Meeting_Agenda__c = null;
            
        } else if (partial.Type__c == 'Online Resources') {
            
            partial.Exhibits_or_Displays_Allowed__c = null;
            partial.Meeting_Agenda__c = null;
            partial.Venue_Name__c = null;
            partial.Venue_City__c = null;
            partial.Venue_State__c = null;
            partial.Venue_Province_Region__c = null;
            partial.Venue_Zip_Code__c = null;
            partial.Venue_Country__c = null;
        }
    }
    
    /**
* @author ADMD Team
* @date 15/10/2013
* @description deleteAttachments method - deletes unneeded attachments after changing Program Type for HC
*/
    public static void deleteAttachments(Id attachmentId) {
        Attachment attachmentToDelete = [SELECT Id FROM Attachment WHERE Id = :attachmentId];
        try {
            gFRS_Util_NoShare.deleteLockedAttachment(attachmentToDelete);
        } catch (Exception ex) {
            System.debug('Deletion of Attachment failed. Attachment Id: ' + attachmentId);
        }
    }
    
    /**
* @author ADMD Team
* @date 08/19/2013
* @description setDeliveryMethodForFundationOrNo method - check if Foundation Clasiified if yes and request isn't in Itake change Payment Delivery to Manual,
If Payment Delivery is set to Manual and Foundation  Clasiified change to No set Payment Delivery to Vendor. Logic moved from gFRS_Foundation_Eligible workflow rule
SFDC-3516
*/
    public static void setDeliveryMethodForFundationOrNo(List<GFRS_Funding_Request__c> requestList, Map<Id, GFRS_Funding_Request__c> oldRequestMap) {
        
        GFRS_Funding_Request__c[] changedFundingRequests = new GFRS_Funding_Request__c[]{
        };
            gFRS_ObjectUtil.filterChangedFieldsUnderRecord(requestList, oldRequestMap, new String[]{
                'Requested_Amount__c', 'Foundation_Eligible__c', 'Status__c'
                    }, changedFundingRequests);
        if (changedFundingRequests.size() > 0) {
            for (GFRS_Funding_Request__c req : changedFundingRequests) {
                if (req.Status__c != 'Intake' && (req.Record_Type_Name__c == 'Philanthropic')) {
                    if (req.Delivery_Method__c != 'Manual' && (req.Foundation_Classified__c == 'TRUE')) {
                        req.Delivery_Method__c = 'Manual';
                    } else if (req.Delivery_Method__c == 'Manual' && (req.Foundation_Classified__c == 'FALSE')) {
                        req.Delivery_Method__c = 'Vendor';
                    }
                }
            }
        }
    }
    
    
    /**
* @author GFRS Dev Team
* @date 22/08/2013
* @description getRfiDate method - Check whether given attachment already was added during current RFI.
*/
    public static Datetime getRfiDate(Id fundingRequestId) {
        
        List<gFRS_Tasks__c> listOfTasks = gFRS_DAO.getGfrsTaskByRequestId(fundingRequestId);
        if (listOfTasks.size() > 0) {
            return listOfTasks.get(0).CreatedDate;
        }
        
        return null;
        
    }
    
    /**
* @author GFRS Dev Team
* @date 22/08/2013
* @description getRfiDateByActionType method - Check whether given attachment already was added during current RFI.
*/
    public static Datetime getRfiDateByActionType(Id fundingRequestId, String actionType) {
        
        List<gFRS_Tasks__c> listOfTasks = gFRS_DAO.getGfrsTaskByRequestIdAndActionType(fundingRequestId, actionType);
        if (listOfTasks.size() > 0) {
            return listOfTasks.get(0).CreatedDate;
        }
        
        return null;
        
    }
    
    /**
* @author GFRS Dev Team
* @date 22/08/2013
* @description checkIsRFI method - Check whether 'File Attachments' page is in RFI state
*/
    public static Boolean checkIsRFI(Id fundingRequestId) {
        Boolean isRFI = false;
        List<GFRS_Funding_Request__c> listOfRequests = gFRS_DAO.getFundingRequestById(fundingRequestId);
        List<gFRS_Tasks__c> listOfTasks = gFRS_DAO.getGfrsTaskByRequestId(listOfRequests.get(0).Id);
        
        if (listOfTasks.size() > 0 && listOfRequests.size() > 0 && listOfRequests.get(0).Information_Needed__c != null && listOfRequests.get(0).Information_Needed__c.contains(gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS)) {
            isRFI = true;
        }
        return isRFI;
    }
    
    /**
* @author GFRS Dev Team
* @date 22/08/2013
* @description checkIsPageInRFIStatus method - Check whether specified page is in RFI state
*/
    public static Boolean checkIsPageInRFIStatus(Id fundingRequestId, String pageName) {
        Boolean isRFI = false;
        List<GFRS_Funding_Request__c> listOfRequests = gFRS_DAO.getFundingRequestById(fundingRequestId);
        List<gFRS_Tasks__c> listOfTasks = gFRS_DAO.getGfrsTaskByRequestId(listOfRequests.get(0).Id);
        
        if (listOfTasks.size() > 0 && listOfRequests.size() > 0 && listOfRequests.get(0).Information_Needed__c != null && listOfRequests.get(0).Information_Needed__c.contains(pageName)) {
            isRFI = true;
        }
        return isRFI;
    }
    
    
    /**
* @author GFRS Dev Team
* @date 26/08/2013
* @description checkIsReconciliationInRFI method - Check whether Reconciliation page is in RFI state
*/
    public static Boolean checkIsReconciliationPageInRFI(Id fundingRequestId) {
        Boolean isRFI = false;
        List<GFRS_Funding_Request__c> listOfRequests = gFRS_DAO.getFundingRequestById(fundingRequestId);
        
        if (listOfRequests == null || listOfRequests.size() == 0) {
            return isRFI;
        }
        
        List<gFRS_Tasks__c> listOfTasks = gFRS_DAO.getGfrsTaskByRequestIdAndActionType(listOfRequests.get(0).Id, RECONCILIATION_PAGE_NAME);
        
        System.debug('PN:DEBUG: listOfTasks: ' + listOfTasks);
        
        if (listOfRequests.get(0).Is_Reconciliation_In_RFI__c && listOfTasks.size() > 0 && listOfTasks.get(0).Action_Type__c != null) {
            isRFI = true;
        }
        return isRFI;
    }
    
    /**
* @author GFRS Dev Team
* @date 23/02/2015
* @description checkIsSunshineCommunicationSent method - Check whether Communicaiton was send for Sunshine.
*/
    public static Boolean checkIsSunshineCommunicationSent(Id fundingRequestId) {
        
        Boolean isCommunicationSent = false;
        List<GFRS_Funding_Request__c> listOfRequests = gFRS_DAO.getFundingRequestById(fundingRequestId);
        
        if (listOfRequests == null || listOfRequests.size() == 0) {
            return isCommunicationSent;
        }
        
        //List<gFRS_Tasks__c> listOfTasks = gFRS_DAO.getGfrsTaskByRequestIdAndActionType(listOfRequests.get(0).Id, RECONCILIATION_PAGE_NAME);
        
        //System.debug('PN:DEBUG: listOfTasks: ' + listOfTasks);
        
        if (listOfRequests.get(0).Sunshine_Communication_Sent__c) {
            isCommunicationSent = true;
        }
        return isCommunicationSent;
    }
    
    /**
* @author GFRS Dev Team
* @date 22/08/2013
* @description getFieldLabelsMap method - gets apiName <-> field label mapping
*/
    public static Map<String, String> getFieldLabelsMapForGivenObject(String objectApiName) {
        
        Map<String, String> apiNameToLabelMap = new Map<String, String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectApiName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        for (String fieldName : fieldMap.keySet()) {
            apiNameToLabelMap.put(fieldName.toLowerCase(), fieldMap.get(fieldName).getDescribe().getLabel());
            
        }
        
        return apiNameToLabelMap;
    }
    
    /**
* @author GFRS Dev Team
* @date 22/08/2013
* @description addTimestampToFileName method - functionality needed for SFDC-3529
*/
    public static String addTimestampToFileName(String fileName) {
        String attachmentName = fileName.substringBeforeLast('.');
        String attachmentExtension = fileName.substringAfterLast('.');
        Datetime myDT = Datetime.now();
        String timestamp = myDT.format(TIMESTAMP_FORMAT);
        String timestampedName = attachmentName + '_' + timestamp + '.' + attachmentExtension;
        return timestampedName;
    }
    
    
    /**
* @author GFRS Dev Team
* @date 05/09/2013
* @description method for checking is user has delegation record.
*/
    public static Boolean IsUserHasDelegationRecord(String userName, String recordTypeName) {
        cacheMapGNEUserDelegationCache();
        
        if (mapGNEUserDelegationCache.containsKey(userName + recordTypeName)) {
            return true;
        } else {
            return false;
        }
    }
    /**
* @author GFRS Dev Team
* @date 05/09/2013
* @description method for cache GNE User Delegation object.
*/
    private static void cacheMapGNEUserDelegationCache() {
        try {
            if (mapGNEUserDelegationCache != null && mapGNEUserDelegationCache.size() > 0) {
                return;
            }
        } catch (Exception ex) {
            System.debug('Need crete a new map');
        }
        
        mapGNEUserDelegationCache = new Map<String, Id>();
        for (GNE_User_Delegation__c u : [SELECT Name, Id, RecordType.Name FROM GNE_User_Delegation__c]) {
            String recType = u.RecordType.Name == null ? '' : u.RecordType.Name;
            mapGNEUserDelegationCache.put(u.Name + recType, u.Id); //i need name as a key
        }
    }
    
    
    /**
* @author GFRS Dev Team
* @date 05/09/2013
* @description method for checking is user has delegation record.
*/
    public static Boolean IsUserHasPSStandardUserDelegation(Id userId) {
        cacheMapPSStandardUserDelegationCache();
        if (mapPSStandardUserDelegationCache.containsKey(userId)) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 05/09/2013
* @description method for cache GNE_Standard_User_Delegation permission set object.
*/
    private static void cacheMapPSStandardUserDelegationCache() {
        if (mapPSStandardUserDelegationCache != null) {
            return;
        }
        
        mapPSStandardUserDelegationCache = new Map<Id, Id>();
        for (PermissionSetAssignment ps : [
            SELECT AssigneeId, PermissionSetId
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'GNE_Standard_User_Delegation'
        ]) {
            mapPSStandardUserDelegationCache.put(ps.AssigneeId, ps.PermissionSetId);
        }
    }
    
    
    /**
* @author GFRS Dev Team
* @date 05/09/2013
* @description checkIsPaymentSuccesfullySubmitted method - checks whether the payment was succesfully submitted.
*/
    public static Boolean checkIsPaymentSuccesfullySubmitted(GFRS_Funding_Allocation__c fundingAllocation) {
        
        if (fundingAllocation != null && fundingAllocation.Id != null) {
            List<GFRS_Payment_History__c> resultList = gFRS_DAO.getPaymentHistoryByFundingAllocation(fundingAllocation);
            for (GFRS_Payment_History__c item : resultList) {
                if (item.SAP_Doc_ID__c != null) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    
    /**
* @author GFRS Dev Team
* @date 02/12/2014
* @description stopApprovalProcessIFBADidntSetApprovedAmount method - method method stopping approval process if  BA didn't set Appoval Amount and approved request
*/
    
    public static void stopApprovalProcessIFBADidntSetApprovedAmount(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        
        for (GFRS_Funding_Request__c reqItem : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldReq = oldRequestsMap.get(reqItem.Id);
            
            //Check for Non Foundation Funding Types
            if (reqItem.Foundation_Classified__c == 'FALSE'
                && oldReq.Business_Approver_Decision_Date__c != reqItem.Business_Approver_Decision_Date__c
                && reqItem.Business_Approver_Decision_Date__c != null
                && (reqItem.Approved_Amount__c == null || reqItem.Approved_Amount__c <= 0)
                && reqItem.Business_Approver_Decision__c == 'Approved') {
                    
                    requestMeetingCriteria.add(reqItem.Id);
                }
            //Check for Foundation Funding Types
            if (reqItem.Foundation_Classified__c == 'TRUE'
                && oldReq.Business_Reviewer_Decision_Date__c != reqItem.Business_Reviewer_Decision_Date__c
                && reqItem.Business_Reviewer_Decision_Date__c != null
                && (reqItem.Approved_Amount__c == null || reqItem.Approved_Amount__c <= 0)
                && reqItem.Business_Reviewer_Decision__c == 'Approved') {
                    
                    requestMeetingCriteria.add(reqItem.Id);
                }
            
        }
        try {
            if (requestMeetingCriteria.size() > 0) {
                for (Id fundId : requestMeetingCriteria) {
                    
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    String outputErrorMessage = System.Label.gFRS_ApprovedAmtZeroError;
                    outputErrorMessage = outputErrorMessage.replace('{!ID}', currentRequest.Id);
                    outputErrorMessage = outputErrorMessage.replace('{!Name}', currentRequest.Name);
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
    }
    
    /**
* @author GFRS Dev Team
* @date 05/07/2019
* @description stopApprovalProcessIFBADidntSetFA4 method - method stopping approval process if  BA didn't set FA4 for approved amount > 3M and approved request
*/
    
    public static void stopApprovalProcessIFBADidntSetFA4(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        
        for (GFRS_Funding_Request__c reqItem : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldReq = oldRequestsMap.get(reqItem.Id);
            
            //Check for Non Foundation Funding Types
            if (reqItem.Foundation_Classified__c == 'FALSE'
                && (reqItem.Record_Type_Name__c == 'Fellowships' || reqItem.Record_Type_Name__c == 'HC Char' || reqItem.Record_Type_Name__c == 'Philanthropic' || reqItem.Record_Type_Name__c == 'Scientific Projects')
                && reqItem.Approved_Amount__c >= 3000000
                && reqItem.Financial_Approver_4__c == null){
                    
                    if(
                        (oldReq.Business_Approver_Decision_Date__c != reqItem.Business_Approver_Decision_Date__c
                         && reqItem.Business_Approver_Decision_Date__c != null
                         && reqItem.Business_Approver_Decision__c == 'Approved') 
                        ||
                        (oldReq.Financial_Approver_1_Decision_Date__c != reqItem.Financial_Approver_1_Decision_Date__c
                         && reqItem.Financial_Approver_1_Decision_Date__c != null
                         && reqItem.Financial_Approver_1_Decision__c == 'Approved')
                        ||
                        (oldReq.Financial_Approver_2_Decision_Date__c != reqItem.Financial_Approver_2_Decision_Date__c
                         && reqItem.Financial_Approver_2_Decision_Date__c != null
                         && reqItem.Financial_Approver_2_Decision__c == 'Approved') 
                        ||
                        (oldReq.Financial_Approver_3_Decision_Date__c != reqItem.Financial_Approver_3_Decision_Date__c
                         && reqItem.Financial_Approver_3_Decision_Date__c != null
                         && reqItem.Financial_Approver_3_Decision__c == 'Approved')) {
                             
                             requestMeetingCriteria.add(reqItem.Id);
                         }
                }   
        }
        try {
            if (requestMeetingCriteria.size() > 0) {
                for (Id fundId : requestMeetingCriteria) {
                    
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    String outputErrorMessage = System.Label.gFRS_FA4blankError;
                    outputErrorMessage = outputErrorMessage.replace('{!ID}', currentRequest.Id);
                    outputErrorMessage = outputErrorMessage.replace('{!Name}', currentRequest.Name);
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
    }   
    
    /**
* @author GFRS Dev Team
* @date 04/03/2014
* @description stopApprovalProcessIfGCDidntSetApprovers method -  validation method. Error message will occure when GC didn't set Business Reviewer, BA1 and BA2
*/
    
    public static void stopApprovalProcessIfGCDidntSetApprovers(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            
            if (newRequest.Foundation_Classified__c == 'TRUE'
                && oldRequest.GC_Review_Decision_Date__c != newRequest.GC_Review_Decision_Date__c
                && newRequest.GC_Review_Decision_Date__c != null
                && (newRequest.Business_Approver__c == null
                    || newRequest.Business_Approver_2__c == null
                    || newRequest.Business_Reviewer_1__c == null)
                && newRequest.GC_Decision__c == 'Approved') {
                    
                    requestMeetingCriteria.add(newRequest.Id);
                    
                }
            
            
        }
        try {
            if (requestMeetingCriteria.size() > 0) {
                for (Id fundId : requestMeetingCriteria) {
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    String outputErrorMessage = System.Label.gFRS_Foundation_BR_BA1_BA2_Required;
                    outputErrorMessage = outputErrorMessage.replace('{!ID}', currentRequest.Id);
                    outputErrorMessage = outputErrorMessage.replace('{!Name}', currentRequest.Name);
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
        
    }
    
    /**
* @author GFRS Dev Team
* @date 24/07/2014
* @description foundationBA1ApproveSubStatusUpdate method - method triggerd when BA1 for Foundation approve request -set proper sub status depneding if Legal Reviewer is set.
*/
    
    public static void foundationBA1ApproveSubStatusUpdate(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            
            if (newRequest.Foundation_Classified__c == 'TRUE'
                && oldRequest.Business_Approver_Decision_Date__c != newRequest.Business_Approver_Decision_Date__c
                && newRequest.Business_Approver_Decision_Date__c != null
                && newRequest.Business_Approver_Decision__c == 'Approved') {
                    
                    if (newRequest.Legal_Reviewer_1__c != null) {
                        newRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_LEGAL_REV;
                    } else {
                        newRequest.Sub_Status__c = gFRS_Util.APPROVAL_BUSINESS_APPROVER;
                    }
                }
        }
        
    }
    
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateBA1Approval method - method triggerd when BA1  approve request
*/
    public static void validateBA1Approval(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Map<Id, String> requestMeetingCriteria = new Map<Id, String>();
        List<Id> listOfFundingRequestIds = new List<Id>(newRequestsMap.keySet());
        Boolean checkValidation = false;
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            
            if (oldRequest.Business_Approver_Decision_Date__c != newRequest.Business_Approver_Decision_Date__c
                && newRequest.Business_Approver_Decision_Date__c != null
                && newRequest.Business_Approver_Decision__c == gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED) {
                    checkValidation = true;
                    break;
                }
        }
        
        if (checkValidation) {
            List<GFRS_Funding_Allocation__c> listOfFundingAllocation = gFRS_DAO.getFundingAllocationsByRequestIdsAndAllocationType(newRequestsMap.keySet(), gFRS_Util.PAYMENT_TYPE_PAYMENT);
            Map<String, List<GFRS_Funding_Allocation__c>> fundingIdtoFundingAllocationMap = gFRS_Util.getFundingIdtoFundingAllocationMap(listOfFundingAllocation);
            List<GFRS_Funding_Allocation_Line_Item__c> fundingAllocationLineItemsList = gFRS_DAO.getAllocationLineItemListByRequestIdsAndAllocationType(listOfFundingRequestIds, gFRS_Util.PAYMENT_TYPE_PAYMENT);
            Map<String, List<GFRS_Funding_Allocation_Line_Item__c>> fundingIdtoFaliMap = gFRS_Util.getFundingIdtoFaliMap(fundingAllocationLineItemsList);
            
            for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
                
                GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
                
                if (oldRequest.Business_Approver_Decision_Date__c != newRequest.Business_Approver_Decision_Date__c
                    && newRequest.Business_Approver_Decision_Date__c != null
                    && newRequest.Business_Approver_Decision__c == gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED) {
                        //BA1 approved the request
                        
                        if (fundingIdtoFundingAllocationMap.get(newRequest.Id) != null && fundingIdtoFundingAllocationMap.get(newRequest.Id).size() > 0 && !validateBA1PercentageOfLineItems(newRequest, fundingIdtoFaliMap.get(newRequest.Name))) {
                            
                            String outputErrorMessage = System.Label.gFRS_PaymentCoverageError;
                            outputErrorMessage = outputErrorMessage.replace('{!ID}', fundingIdtoFundingAllocationMap.get(newRequest.Id).get(0).Id);
                            requestMeetingCriteria.put(newRequest.Id, outputErrorMessage);
                        }
                        
                        if (fundingIdtoFundingAllocationMap.get(newRequest.Id) != null
                            && fundingIdtoFundingAllocationMap.get(newRequest.Id).size() > 0
                            && !validateBA1CoverageOfPayment(newRequest, fundingIdtoFundingAllocationMap.get(newRequest.Id))) {
                                
                                String outputErrorMessage = System.Label.gFRS_PaymentCoverageError;
                                outputErrorMessage = outputErrorMessage.replace('{!ID}', fundingIdtoFundingAllocationMap.get(newRequest.Id).get(0).Id);
                                requestMeetingCriteria.put(newRequest.Id, outputErrorMessage);
                            }
                        
                        // validation added for GFRS-676
                        if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME) {
                            if (newRequest.Was_grant_taken_to_Grant_Review_Committe__c == null || newRequest.Peer_Reviewed__c == null) {
                                String outputErrorMessage = System.Label.gFRS_GRCFieldsNotPopulated;
                                outputErrorMessage = outputErrorMessage.replace('{!ID}', newRequest.Id);
                                outputErrorMessage = outputErrorMessage.replace('{!Name}', newRequest.Name);
                                requestMeetingCriteria.put(newRequest.Id, outputErrorMessage);
                            }
                        }
                        
                        // validation added for GFRS-731
                        if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME
                            || ((newRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME
                                 || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME
                                 || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME)
                                && newRequest.Foundation_Classified__c == gFRS_Util.FOUNDATION_FALSE)) {
                                    if (newRequest.Social_Impact_Goals_CEG__c == null || newRequest.GNE_Alignment__c == null) {
                                        String outputErrorMessage = System.Label.gFRS_SocialImpactFieldNotPopulated;
                                        outputErrorMessage = outputErrorMessage.replace('{!ID}', newRequest.Id);
                                        outputErrorMessage = outputErrorMessage.replace('{!Name}', newRequest.Name);
                                        requestMeetingCriteria.put(newRequest.Id, outputErrorMessage);
                                    }
                                }
                    }
            }
            
            try {
                if (requestMeetingCriteria.size() > 0) {
                    for (Id fundId : requestMeetingCriteria.keySet()) {
                        GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                        currentRequest.addError(requestMeetingCriteria.get(fundId), false);
                    }
                }
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
        
    }
    
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateFA1Approval method - method triggerd when FA1  approve request
*/
    public static void validateFA1Approval(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Map<Id, String> requestMeetingCriteria = new Map<Id, String>();
        List<Id> listOfFundingRequestIds = new List<Id>(newRequestsMap.keySet());
        Boolean checkValidation = false;
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            
            
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            
            if (oldRequest.Financial_Approver_1_Decision_Date__c != newRequest.Financial_Approver_1_Decision_Date__c
                && newRequest.Financial_Approver_1_Decision_Date__c != null
                && newRequest.Financial_Approver_1_Decision__c == gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED) {
                    
                    checkValidation = true;
                    break;
                }
        }
        
        if (checkValidation) {
            
            List<GFRS_Funding_Allocation__c> listOfFundingAllocation = gFRS_DAO.getFundingAllocationsByRequestIdsAndAllocationType(newRequestsMap.keySet(), gFRS_Util.PAYMENT_TYPE_PAYMENT);
            Map<String, List<GFRS_Funding_Allocation__c>> fundingIdtoFundingAllocationMap = gFRS_Util.getFundingIdtoFundingAllocationMap(listOfFundingAllocation);
            List<GFRS_Funding_Allocation_Line_Item__c> fundingAllocationLineItemsList = gFRS_DAO.getAllocationLineItemListByRequestIdsAndAllocationType(listOfFundingRequestIds, gFRS_Util.PAYMENT_TYPE_PAYMENT);
            Map<String, List<GFRS_Funding_Allocation_Line_Item__c>> fundingIdtoFaliMap = gFRS_Util.getFundingIdtoFaliMap(fundingAllocationLineItemsList);
            
            for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
                
                GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
                
                if (oldRequest.Financial_Approver_1_Decision_Date__c != newRequest.Financial_Approver_1_Decision_Date__c
                    && newRequest.Financial_Approver_1_Decision_Date__c != null
                    && newRequest.Financial_Approver_1_Decision__c == gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED) {
                        //BA1 approved the request
                        
                        if (fundingIdtoFundingAllocationMap.get(newRequest.Id) != null && fundingIdtoFundingAllocationMap.get(newRequest.Id).size() > 0 && !validateFA1PercentageOfLineItems(newRequest, fundingIdtoFaliMap.get(newRequest.Name))) {
                            
                            String outputErrorMessage = System.Label.gFRS_PaymentCoverageError;
                            outputErrorMessage = outputErrorMessage.replace('{!ID}', fundingIdtoFundingAllocationMap.get(newRequest.Id).get(0).Id);
                            requestMeetingCriteria.put(newRequest.Id, outputErrorMessage);
                        }
                        
                        //Validation from GFRS-19
                        if (fundingIdtoFundingAllocationMap.get(newRequest.Id) != null && fundingIdtoFundingAllocationMap.get(newRequest.Id).size() > 0 && !validateFA1CoverageOfPayment(newRequest, fundingIdtoFundingAllocationMap.get(newRequest.Id))) {
                            //Request is invalid
                            String outputErrorMessage = System.Label.gFRS_PaymentCoverageError;
                            outputErrorMessage = outputErrorMessage.replace('{!ID}', fundingIdtoFundingAllocationMap.get(newRequest.Id).get(0).Id);
                            requestMeetingCriteria.put(newRequest.Id, outputErrorMessage);
                        }
                    }
            }
            
            try {
                if (requestMeetingCriteria.size() > 0) {
                    for (Id fundId : requestMeetingCriteria.keySet()) {
                        GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                        currentRequest.addError(requestMeetingCriteria.get(fundId), false);
                    }
                }
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
        
    }
    
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateFA3Approval method - method triggerd when FA3  approve request
*/
    public static void validateFA3Approval(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Map<Id, String> requestMeetingCriteria = new Map<Id, String>();
        List<Id> listOfFundingRequestIds = new List<Id>(newRequestsMap.keySet());
        Boolean checkValidation = false;
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            
            
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            
            if (oldRequest.Financial_Approver_3_Decision_Date__c != newRequest.Financial_Approver_3_Decision_Date__c
                && newRequest.Financial_Approver_3_Decision_Date__c != null
                && newRequest.Financial_Approver_3_Decision__c == gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED) {
                    
                    checkValidation = true;
                    break;
                }
        }
        if (checkValidation) {
            
            List<GFRS_Funding_Allocation__c> listOfFundingAllocation = gFRS_DAO.getFundingAllocationsByRequestIdsAndAllocationType(newRequestsMap.keySet(), gFRS_Util.PAYMENT_TYPE_PAYMENT);
            Map<String, List<GFRS_Funding_Allocation__c>> fundingIdtoFundingAllocationMap = gFRS_Util.getFundingIdtoFundingAllocationMap(listOfFundingAllocation);
            List<GFRS_Funding_Allocation_Line_Item__c> fundingAllocationLineItemsList = gFRS_DAO.getAllocationLineItemListByRequestIdsAndAllocationType(listOfFundingRequestIds, gFRS_Util.PAYMENT_TYPE_PAYMENT);
            Map<String, List<GFRS_Funding_Allocation_Line_Item__c>> fundingIdtoFaliMap = gFRS_Util.getFundingIdtoFaliMap(fundingAllocationLineItemsList);
            
            for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
                
                
                GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
                
                if (oldRequest.Financial_Approver_3_Decision_Date__c != newRequest.Financial_Approver_3_Decision_Date__c
                    && newRequest.Financial_Approver_3_Decision_Date__c != null
                    && newRequest.Financial_Approver_3_Decision__c == gFRS_Util.FUNDING_REQUEST_APPROVE_TYPE_APPROVED) {
                        //BA1 approved the request
                        
                        if (fundingIdtoFundingAllocationMap.get(newRequest.Id) != null
                            && fundingIdtoFundingAllocationMap.get(newRequest.Id).size() > 0
                            && !validateFA3PercentageOfLineItems(newRequest, fundingIdtoFaliMap.get(newRequest.Name))) {
                                
                                String outputErrorMessage = System.Label.gFRS_PaymentCoverageError;
                                outputErrorMessage = outputErrorMessage.replace('{!ID}', fundingIdtoFundingAllocationMap.get(newRequest.Id).get(0).Id);
                                requestMeetingCriteria.put(newRequest.Id, outputErrorMessage);
                            }
                        
                        //Validation from GFRS-19
                        if (fundingIdtoFundingAllocationMap.get(newRequest.Id) != null
                            && fundingIdtoFundingAllocationMap.get(newRequest.Id).size() > 0
                            && !validateFA3CoverageOfPayment(newRequest, fundingIdtoFundingAllocationMap.get(newRequest.Id))) {
                                //Request is invalid
                                
                                String outputErrorMessage = System.Label.gFRS_PaymentCoverageError;
                                outputErrorMessage = outputErrorMessage.replace('{!ID}', fundingIdtoFundingAllocationMap.get(newRequest.Id).get(0).Id);
                                requestMeetingCriteria.put(newRequest.Id, outputErrorMessage);
                            }
                    }
            }
            
            try {
                if (requestMeetingCriteria.size() > 0) {
                    for (Id fundId : requestMeetingCriteria.keySet()) {
                        GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                        currentRequest.addError(requestMeetingCriteria.get(fundId), false);
                    }
                }
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
        
    }
    
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateFA1CoverageOfPayment method - method triggerd when BA1  approve request - checking whether coverage is 100% for specified conditions
*/
    public static Boolean validateFA1CoverageOfPayment(GFRS_Funding_Request__c newRequest, List<GFRS_Funding_Allocation__c> listOfFundingAllocation) {
        
        if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) {
            
            return validateCoverageOfPayment(listOfFundingAllocation);
            
        }
        return true;
    }
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateFA1CoverageOfPayment method - method triggerd when BA1  approve request - checking whether coverage is 100% for specified conditions
*/
    public static Boolean validateFA1PercentageOfLineItems(GFRS_Funding_Request__c newRequest, List<GFRS_Funding_Allocation_Line_Item__c> listOfFundingAllocationLineItems) {
        
        if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) {
            
            return validatePercentageOfLineItems(listOfFundingAllocationLineItems);
            
        }
        return true;
    }
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateFA#CoverageOfPayment method - method triggerd when BA1  approve request - checking whether coverage is 100% for specified conditions
*/
    public static Boolean validateFA3CoverageOfPayment(GFRS_Funding_Request__c newRequest, List<GFRS_Funding_Allocation__c> listOfFundingAllocation) {
        
        Boolean result = true;
        if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME
            || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME
            || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
                
                result = validateCoverageOfPayment(listOfFundingAllocation);
                
            }
        
        
        /*
if( !result && newRequest.Approved_Amount__c == newRequest.Refundable_Deposit_Amount_if_any__c && (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)){

result = true;

}*/
        
        return result;
    }
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateFA3PercentageOfLineItems method - method triggerd when BA1  approve request
*/
    public static Boolean validateFA3PercentageOfLineItems(GFRS_Funding_Request__c newRequest, List<GFRS_Funding_Allocation_Line_Item__c> listOfFundingAllocationLineItems) {
        
        if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME
            || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME
            || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
                
                return validatePercentageOfLineItems(listOfFundingAllocationLineItems);
                
            }
        return true;
    }
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateBA1CoverageOfPayment method - method triggerd when BA1  approve request - checking whether coverage is 100% for specified conditions
*/
    public static Boolean validateBA1CoverageOfPayment(GFRS_Funding_Request__c newRequest, List<GFRS_Funding_Allocation__c> listOfFundingAllocation) {
        
        if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME
            || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME
            || ((newRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME
                 || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME
                 || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME)
                && newRequest.Foundation_Classified__c == gFRS_Util.FOUNDATION_FALSE)) {
                    
                    return validateCoverageOfPayment(listOfFundingAllocation);
                    
                }
        return true;
    }
    
    /**
* @author GFRS Dev Team
* @date 26/08/2014
* @description validateBA1PercentageOfLineItems method - method triggerd when BA1  approve request
*/
    public static Boolean validateBA1PercentageOfLineItems(GFRS_Funding_Request__c newRequest, List<GFRS_Funding_Allocation_Line_Item__c> listOfFundingAllocationLineItems) {
        
        if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_IMED_NAME
            || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME
            || ((newRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME
                 || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME
                 || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME)
                && newRequest.Foundation_Classified__c == gFRS_Util.FOUNDATION_FALSE)) {
                    
                    return validatePercentageOfLineItems(listOfFundingAllocationLineItems);
                    
                }
        return true;
    }
    
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validateCoverageOfPayment method - check payment coverage. Return false if is less than 100%
*/
    public static Boolean validateCoverageOfPayment(List<GFRS_Funding_Allocation__c> listOfFundingAllocation) {
        
        if (listOfFundingAllocation == null || listOfFundingAllocation.size() < 1) {
            return false;
        }
        
        for (GFRS_Funding_Allocation__c item : listOfFundingAllocation) {
            
            //if( item.Sum_of_Percents__c != 100 ||  item.Sum_of_Amounts__c < item.Payment_Amount__c ){
            System.debug('PN: TEST: item: ' + item);
            System.debug('PN: TEST: item.Pct_Covered__c: ' + item.Pct_Covered__c);
            if (item.Pct_Covered__c != 100) {
                if (item.Grant_Request__r.Approved_Amount__c == item.Grant_Request__r.Refundable_Deposit_Amount_if_any__c) {
                    return true;
                    
                }
                return false;
            }
            
        }
        return true;
        
    }
    
    /**
* @author GFRS Dev Team
* @date 21/08/2014
* @description validatePercentageOfLineItems method - check line item percents
*/
    public static Boolean validatePercentageOfLineItems(List<GFRS_Funding_Allocation_Line_Item__c> listOfFundingAllocationLineItems) {
        
        if (listOfFundingAllocationLineItems == null || listOfFundingAllocationLineItems.size() < 1) {
            return false;
        }
        
        for (GFRS_Funding_Allocation_Line_Item__c item : listOfFundingAllocationLineItems) {
            
            if ((item.Percent__c == null && item.Amount__c == 0.00) || (item.Percent__c == 0.00 && item.Amount__c == null)) {
                return false;
            }
        }
        
        return true;
        
    }
    
    /**
* @author GFRS Dev Team
* @date 05/15/2014
* @description addSharingForBrBaApproversForFoundation method -  add appropriate sharing for BR and BA's for Foundation requests
*/
    public static void addSharingForBrBaApproversForFoundation(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        final Set<Id> approverIds = new Set<Id>();
        List<GFRS_Funding_Request__Share> shrForBrAndBaApprovers = new List<GFRS_Funding_Request__Share>();
        List<GFRS_Funding_Request__c> requestMeetingCriteriaToAddSharing = new List<GFRS_Funding_Request__c>();
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            if (newRequest.Foundation_Classified__c == 'TRUE' && oldRequest.GC_Review_Decision_Date__c != newRequest.GC_Review_Decision_Date__c && newRequest.GC_Review_Decision_Date__c != null) {
                requestMeetingCriteriaToAddSharing.add(newRequest);
            }
        }
        
        for (GFRS_Funding_Request__c tmpRequest : requestMeetingCriteriaToAddSharing) {
            
            //Add Read/Write sharing for BR
            if (tmpRequest.Business_Reviewer_1__c != null) {
                if (APPROVER_IDS.add(tmpRequest.Business_Reviewer_1__c)) {
                    approverIds.add(tmpRequest.Business_Reviewer_1__c);
                }
                GFRS_Funding_Request__Share shrFundingRequest = new GFRS_Funding_Request__Share();
                shrFundingRequest.ParentId = tmpRequest.Id;
                shrFundingRequest.UserOrGroupId = tmpRequest.Business_Reviewer_1__c;
                shrFundingRequest.AccessLevel = gFRS_Util.SHARING_WRITE;
                shrFundingRequest.RowCause = 'Manual';
                shrForBrAndBaApprovers.add(shrFundingRequest);
            }
            
            //Add Read sharing for BA1
            if (tmpRequest.Business_Approver__c != null) {
                if (APPROVER_IDS.add(tmpRequest.Business_Approver__c)) {
                    approverIds.add(tmpRequest.Business_Approver__c);
                }
                GFRS_Funding_Request__Share shrFundingRequest = new GFRS_Funding_Request__Share();
                shrFundingRequest.ParentId = tmpRequest.Id;
                shrFundingRequest.UserOrGroupId = tmpRequest.Business_Approver__c;
                shrFundingRequest.AccessLevel = gFRS_Util.SHARING_READ;
                shrFundingRequest.RowCause = 'Manual';
                shrForBrAndBaApprovers.add(shrFundingRequest);
            }
            
            //Add Read sharing for Legal Reviewer
            if (tmpRequest.Legal_Reviewer_1__c != null) {
                if (APPROVER_IDS.add(tmpRequest.Legal_Reviewer_1__c)) {
                    approverIds.add(tmpRequest.Legal_Reviewer_1__c);
                }
                GFRS_Funding_Request__Share shrFundingRequest = new GFRS_Funding_Request__Share();
                shrFundingRequest.ParentId = tmpRequest.Id;
                shrFundingRequest.UserOrGroupId = tmpRequest.Legal_Reviewer_1__c;
                shrFundingRequest.AccessLevel = gFRS_Util.SHARING_READ;
                shrFundingRequest.RowCause = 'Manual';
                shrForBrAndBaApprovers.add(shrFundingRequest);
            }
            
            //Add Read/Write sharing for BA2
            if (tmpRequest.Business_Approver_2__c != null) {
                if (APPROVER_IDS.add(tmpRequest.Business_Approver_2__c)) {
                    approverIds.add(tmpRequest.Business_Approver_2__c);
                }
                GFRS_Funding_Request__Share shrFundingRequest = new GFRS_Funding_Request__Share();
                shrFundingRequest.ParentId = tmpRequest.Id;
                shrFundingRequest.UserOrGroupId = tmpRequest.Business_Approver_2__c;
                shrFundingRequest.AccessLevel = gFRS_Util.SHARING_WRITE;
                shrFundingRequest.RowCause = 'Manual';
                shrForBrAndBaApprovers.add(shrFundingRequest);
            }
            
            //Add Read/Write sharing for BA2
            if (tmpRequest.Business_Approver_3__c != null) {
                if (APPROVER_IDS.add(tmpRequest.Business_Approver_3__c)) {
                    approverIds.add(tmpRequest.Business_Approver_3__c);
                }
                GFRS_Funding_Request__Share shrFundingRequest = new GFRS_Funding_Request__Share();
                shrFundingRequest.ParentId = tmpRequest.Id;
                shrFundingRequest.UserOrGroupId = tmpRequest.Business_Approver_3__c;
                shrFundingRequest.AccessLevel = gFRS_Util.SHARING_WRITE;
                shrFundingRequest.RowCause = 'Manual';
                shrForBrAndBaApprovers.add(shrFundingRequest);
            }
            
        }
        
        if (!shrForBrAndBaApprovers.isEmpty()) {
            
            Database.SaveResult [] srList = Database.insert(shrForBrAndBaApprovers, false);
            String errorOutput = '';
            
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    if (errorOutput == '') {
                        errorOutput = 'Following errors occured while inserting sharings for BR and BAs';
                    }
                    for (Database.Error err : sr.getErrors()) {
                        errorOutput += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                    }
                }
            }
            System.debug(errorOutput);
        }
        if (!(approverIds.isEmpty() || System.isFuture() || System.isBatch()) &&
            Limits.getFutureCalls() < Limits.getLimitFutureCalls()
           ) {
               grantApproverAccessAsync(new List<Id>(approverIds));
           }
    }
    
    
    /**
* @author GFRS Dev Team
* @date 02/18/2014
* @description stopApprovalProcessIFFA3DidntSetComAcitvity method - method stopping approval process if FA3 for Corporate Membership and Exhibits and Other Promo
*  Didn't set Comercial Activity for Fundig AllocationLineItem
*/
    public static void stopApprovalProcessIFFA3DidntSetComAcitvity(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        
        for (GFRS_Funding_Request__c reqItem : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldReq = oldRequestsMap.get(reqItem.Id);
            if (reqItem.Status__c != gFRS_Util.REQUEST_STATUS_CLOSED
                &&
                (reqItem.Record_Type_Name__c == 'Corporate Memberships'
                 || reqItem.Record_Type_Name__c == 'Exhibits & Other Promos'
                 || reqItem.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME
                )
                &&
                (oldReq.Financial_Approver_3_Decision_Date__c != reqItem.Financial_Approver_3_Decision_Date__c
                 && reqItem.Financial_Approver_3_Decision_Date__c != null)
               ) {
                   requestMeetingCriteria.add(reqItem.Id);
               }
        }
        
        try {
            if (requestMeetingCriteria.size() > 0) {
                Map<Id, GFRS_Funding_Allocation_Line_Item__c> fliNotSetPropelyWhileFA3ApproveRquestMap = new Map<Id, GFRS_Funding_Allocation_Line_Item__c>();
                for (GFRS_Funding_Allocation_Line_Item__c fli : [
                    SELECT Request_Name__c, Funding_Allocation__r.Id, Commercial_Activity_ID__c,
                    Cost_Center_Lookup__r.SAP_Company_Code__c, Funding_Allocation__r.Grant_Request__c
                    FROM GFRS_Funding_Allocation_Line_Item__c
                    WHERE Cost_Center_Lookup__r.SAP_Company_Code__c = '1010'
                    AND Commercial_Activity_ID__c = NULL
                    AND Funding_Allocation__r.Grant_Request__c IN :requestMeetingCriteria
                ]) {
                    
                    
                    if (!fliNotSetPropelyWhileFA3ApproveRquestMap.containsKey(fli.Funding_Allocation__r.Grant_Request__c)) {
                        fliNotSetPropelyWhileFA3ApproveRquestMap.put(fli.Funding_Allocation__r.Grant_Request__c, fli);
                    }
                    
                }
                for (GFRS_Funding_Allocation_Line_Item__c fli : fliNotSetPropelyWhileFA3ApproveRquestMap.values()) {
                    
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fli.Funding_Allocation__r.Grant_Request__c);
                    String outputErrorMessage = System.Label.gFRS_ApprovalErrComActivityNeedToBeSet;
                    outputErrorMessage = outputErrorMessage.replace('{!Ali.Id}', fli.Funding_Allocation__r.Id);
                    outputErrorMessage = outputErrorMessage.replace('{!ReqId}', fli.Funding_Allocation__r.Grant_Request__c);
                    outputErrorMessage = outputErrorMessage.replace('{!ReqName}', fli.Request_Name__c);
                    
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug('Following error occurs while executing stopApprovalProcessIFFA3DidntSetComAcitvity method: ' + ex.getMessage());
        }
        
        
    }
    
    
    /**
* @author GFRS Dev Team
* @date 06/03/2014
* @description restrictBA1FromEditting method - method BA1 should not be able to edit Funding Request
*/
    public static void restrictBA1FromEditting(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        Id userId = UserInfo.getUserId();
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            
            if (newRequest.Foundation_Classified__c == 'TRUE' && userId == newRequest.Business_Approver__c) {
                if (newRequest.Business_Approver__c != newRequest.Business_Reviewer_1__c
                    && newRequest.Business_Approver__c != newRequest.Business_Approver_2__c
                    && newRequest.Business_Approver__c != newRequest.Business_Approver_3__c) {
                        
                        requestMeetingCriteria.add(newRequest.Id);
                    }
            }
            
            /*
if(newRequest.Foundation_Classified__c == 'TRUE' &&  newRequest.Business_Reviewer_Decision_Date__c != null &&  newRequest.Business_Reviewer_Decision__c == 'Approved' && newRequest.Business_Approver_Decision_Date__c == null && newRequest.Business_Reviewer_Decision_Date__c == oldRequest.Business_Reviewer_Decision_Date__c){

requestMeetingCriteria.add(newRequest.Id);
}
*/
        }
        
        try {
            if (requestMeetingCriteria.size() > 0) {
                for (Id fundId : requestMeetingCriteria) {
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    String outputErrorMessage = System.Label.gFRS_Foundation_BA1_Not_Allowed_To_Edit;
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    
    /**
* @author GFRS Dev Team
* @date 11/02/2019
* @description stopQCOApprovalIfTaskOpen method -  QCO should not be able to approve the request if there is any open task
*/
    public static void stopQCOApprovalIfTaskOpen(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        Boolean isInternalReq;
        Set<Id> reqIds = new Set<Id>();
        reqIds = newRequestsMap.keySet();
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            
            isInternalReq = gFRS_Util.isInternalRequest(newRequest.Record_Type_Name__c);
            if (isInternalReq && newRequest.CCO_Decision__c == 'Approved' && newRequest.CCO_Decision__c != oldRequestsMap.get(newRequest.Id).CCO_Decision__c) {
                List<gFRS_Tasks__c> reqTasks = [SELECT Id, Name FROM gFRS_Tasks__c WHERE Action_Type__c = 'ACH' AND gFRS_Funding_Request__c in :reqIds];
                if (reqTasks.size() > 0) {
                    requestMeetingCriteria.add(newRequest.Id);
                }
            }
        }
        
        try {
            if (requestMeetingCriteria.size() > 0) {
                for (Id fundId : requestMeetingCriteria) {
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    
                    String outputErrorMessage              = System.Label.gFRS_QCO_Approval_Error_ePayments;
                    outputErrorMessage                     = outputErrorMessage.replace('{!ID}', currentRequest.id);
                    outputErrorMessage                     = outputErrorMessage.replace('{!Name}', currentRequest.Name);
                    
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }   
    
    /**
* @author GFRS Dev Team
* @date 12/12/2014
* @description stopApprovalIfLRNotSpecified method - method block CCO approval when legal reviewer is not scpecified  GFRS-243
*/
    public static void stopApprovalIfLRNotSpecified(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            
            if ((newRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME
                 || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME)
                && (oldRequest.CCO_Decision_Date__c != newRequest.CCO_Decision_Date__c
                    && newRequest.CCO_Decision_Date__c != null)
                && newRequest.CCO_Decision__c == 'Approved'
                && newRequest.Organization_Medicare_Gudeline_Dev__c == 'Yes'
                && newRequest.Legal_Reviewer_1__c == null
                && newRequest.Legal_Review_Develops_Medicare_Notes__c == null) {
                    requestMeetingCriteria.add(newRequest.Id);
                    
                }
            
        }
        
        try {
            if (requestMeetingCriteria.size() > 0) {
                for (Id fundId : requestMeetingCriteria) {
                    
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    String outputErrorMessage = System.Label.gFRS_ApprovalVal_CCO_LegalReviewer;
                    outputErrorMessage = outputErrorMessage.replace('{!ID}', currentRequest.Id);
                    outputErrorMessage = outputErrorMessage.replace('{!Name}', currentRequest.Name);
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 24/02/2015
* @description stopApprovalIfLRNeedToBeSpecifiedWhenComplianceRed method - method block CCO approval when legal reviewer is not scpecified  GFRS-306
*/
    public static void stopApprovalIfLRNeedToBeSpecifiedWhenComplianceRed(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            //check Philantropic if flag is red and GC or BR did not specify Legal Reviewer
            if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME
                && newRequest.Organization_Develops_Medicare__c.contains('flag_red')
                && ((oldRequest.GC_Review_Decision_Date__c != newRequest.GC_Review_Decision_Date__c
                     && newRequest.GC_Review_Decision_Date__c != null
                     && newRequest.GC_Decision__c == 'Approved')
                    || (oldRequest.Business_Reviewer_Decision_Date__c != newRequest.Business_Reviewer_Decision_Date__c
                        && newRequest.Business_Reviewer_Decision_Date__c != null
                        && newRequest.Business_Reviewer_Decision__c == 'Approved'))
                && newRequest.Legal_Reviewer_1__c == null) {
                    requestMeetingCriteria.add(newRequest.Id);
                    
                }
            
            //check HC CHAR if flag is red and GC or BR did not specify Legal Reviewer
            if (newRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME
                && newRequest.Organization_Develops_Medicare__c.contains('flag_red')
                && ((oldRequest.GC_Review_Decision_Date__c != newRequest.GC_Review_Decision_Date__c
                     && newRequest.GC_Review_Decision_Date__c != null
                     && newRequest.GC_Decision__c == 'Approved')
                    || (oldRequest.Business_Reviewer_Decision_Date__c != newRequest.Business_Reviewer_Decision_Date__c
                        && newRequest.Business_Reviewer_Decision_Date__c != null
                        && newRequest.Business_Reviewer_Decision__c == 'Approved'))
                && newRequest.Legal_Reviewer_1__c == null) {
                    requestMeetingCriteria.add(newRequest.Id);
                    
                }
            
        }
        
        try {
            if (requestMeetingCriteria.size() > 0) {
                for (Id fundId : requestMeetingCriteria) {
                    
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    String outputErrorMessage = System.Label.gFRS_ApprovalVal_CCO_LegalReviewer;
                    outputErrorMessage = outputErrorMessage.replace('{!ID}', currentRequest.Id);
                    outputErrorMessage = outputErrorMessage.replace('{!Name}', currentRequest.Name);
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 24/02/2015
* @description stopApprovalIfLRNeedToBeSpecifiedWhenComplianceRed method - method block CCO approval when legal reviewer is not scpecified  GFRS-306
*/
    public static void stopApprovalIfBA1IsRequired(Map<Id, GFRS_Funding_Request__c> newRequestsMap, Map<Id, GFRS_Funding_Request__c> oldRequestsMap) {
        
        Set<Id> requestMeetingCriteria = new Set<Id>();
        for (GFRS_Funding_Request__c newRequest : newRequestsMap.values()) {
            GFRS_Funding_Request__c oldRequest = oldRequestsMap.get(newRequest.Id);
            //check Philantropic if flag is red ang GC or BR did not specify Legal Reviewer
            if ((newRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME
                 || newRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME)
                && ((oldRequest.GC_Review_Decision_Date__c != newRequest.GC_Review_Decision_Date__c
                     && newRequest.GC_Review_Decision_Date__c != null
                     && newRequest.GC_Decision__c == 'Approved'))
                && newRequest.Business_Approver__c == null) {
                    requestMeetingCriteria.add(newRequest.Id);
                    
                }
        }
        
        try {
            
            if (requestMeetingCriteria.size() > 0) {
                for (Id fundId : requestMeetingCriteria) {
                    
                    GFRS_Funding_Request__c currentRequest = newRequestsMap.get(fundId);
                    String outputErrorMessage = System.Label.gFRS_ApprovalVal_GC_BusinessApprover1;
                    outputErrorMessage = outputErrorMessage.replace('{!ID}', currentRequest.Id);
                    outputErrorMessage = outputErrorMessage.replace('{!Name}', currentRequest.Name);
                    currentRequest.addError(outputErrorMessage, false);
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 09/07/2015
* @description insertFinanceReportJunction method - Create new record for reporting purposes.
*/
    public static void insertFinanceReportJunction(GFRS_Funding_Allocation_Line_Item__c[] items) {
        List<gFRS_Finance_Report_Junction__c> financeJunctions = new List<gFRS_Finance_Report_Junction__c>();
        Map<Id, List<Id>> byAllocation = new Map<Id, List<Id>>();
        for (GFRS_Funding_Allocation_Line_Item__c item : items) {
            
            List<Id> l = byAllocation.get(item.Funding_Allocation__c);
            if (l != null) {
                l.add(item.Id);
            } else {
                byAllocation.put(item.Funding_Allocation__c, new List<Id>{
                    item.Id
                        });
            }
        }
        
        Integer totalAllocationsSize = byAllocation.keySet().size();
        Set<Id> allocationsWithPayment = new Set<Id>();
        
        for (GFRS_Payment_History__c gph : [
            SELECT Id, Funding_Allocation__c
            FROM GFRS_Payment_History__c
            WHERE Funding_Allocation__c IN :byAllocation.keySet() AND SAP_Doc_ID__c != NULL
        ]) {
            
            for (Id fai : byAllocation.get(gph.Funding_Allocation__c)) {
                gFRS_Finance_Report_Junction__c junction = new gFRS_Finance_Report_Junction__c();
                junction.PaymentRefundHistory__c = gph.Id;
                junction.FundingAllocationLine__c = fai;
                junction.FundingAllocation__c = gph.Funding_Allocation__c;
                financeJunctions.add(junction);
            }
            allocationsWithPayment.add(gph.Funding_Allocation__c);
        }
        insert financeJunctions;
        
        if (totalAllocationsSize > allocationsWithPayment.size()) {
            
            Set<Id> allocationsWithoutPayment = byAllocation.keySet();
            List<gFRS_Finance_Report_Junction__c> financeJunctionsWithoutPayment = new List<gFRS_Finance_Report_Junction__c>();
            allocationsWithoutPayment.removeAll(allocationsWithPayment);
            
            for (Id allocation : allocationsWithoutPayment) {
                for (Id allocationLineItem : byAllocation.get(allocation)) {
                    gFRS_Finance_Report_Junction__c junction = new gFRS_Finance_Report_Junction__c();
                    junction.FundingAllocationLine__c = allocationLineItem;
                    junction.FundingAllocation__c = allocation;
                    financeJunctionsWithoutPayment.add(junction);
                }
                
            }
            
            insert financeJunctionsWithoutPayment;
        }
        
    }
    
    /**
* @brief  Method to update gFRS_Finance_Report_Junction__c records after related GFRS_Payment_History__c records were changed and had FundingAllocation changed.
* @param  lPaymentHistories - list of GFRS_Payment_History__c records after change (Trigger.new)
* @param  mapOldPaymentHistories - map of GFRS_Payment_History__c records from before change (Trigger.oldMap)
* @author ADMD GFRS Dev Team
* @date   2015-10-09
*/
    public static void updateFinanceReportJunctionPaymentHistoryUpdate(GFRS_Payment_History__c[] lPaymentHistories, Map<Id, GFRS_Payment_History__c> mapOldPaymentHistories) {
        
        System.debug('KK start lPaymentHistories: ' + lPaymentHistories);
        System.debug('KK start mapOldPaymentHistories: ' + mapOldPaymentHistories);
        
        Map<String, List<gFRS_Finance_Report_Junction__c> > mapHashToFinanceReportsList = new Map<String, List<gFRS_Finance_Report_Junction__c> >();
        List<gFRS_Finance_Report_Junction__c> lReportsToUpdate = new List<gFRS_Finance_Report_Junction__c>();
        
        /* Map Finance Reports to hash which consist of PaymentRefundHistory Id and Funding Allocation Id */
        //{
        gFRS_Finance_Report_Junction__c[] lFinanceReportJunctions;
        Set<Id> setOldFundingAllocationIds = new Set<Id>();
        
        for (GFRS_Payment_History__c paymentHistory : lPaymentHistories) {
            GFRS_Payment_History__c oldPaymentHistory = mapOldPaymentHistories.get(paymentHistory.Id);
            
            //if (paymentHistory.Funding_Allocation__c != oldPaymentHistory.Funding_Allocation__c || paymentHistory.SAP_Doc_ID__c != oldPaymentHistory.SAP_Doc_ID__c) {
            setOldFundingAllocationIds.add(oldPaymentHistory.Funding_Allocation__c);
            //}
        }
        
        
        /*lFinanceReportJunctions = [SELECT Id, PaymentRefundHistory__c, FundingAllocation__c
FROM gFRS_Finance_Report_Junction__c
WHERE PaymentRefundHistory__c  IN :lPaymentHistories
AND FundingAllocation__c IN :setOldFundingAllocationIds];*/
        
        
        lFinanceReportJunctions = [
            SELECT Id, PaymentRefundHistory__c, FundingAllocation__c, PaymentRefundHistory__r.SAP_Doc_ID__c
            FROM gFRS_Finance_Report_Junction__c
            WHERE FundingAllocation__c IN :setOldFundingAllocationIds
        ];
        
        System.debug('KK after query lPaymentHistories: ' + lPaymentHistories);
        System.debug('KK after query setOldFundingAllocationIds: ' + setOldFundingAllocationIds);
        
        System.debug('KK after query lFinanceReportJunctions: ' + lFinanceReportJunctions);
        
        
        for (gFRS_Finance_Report_Junction__c financeReport : lFinanceReportJunctions) {
            String hash = '' + financeReport.PaymentRefundHistory__c + financeReport.FundingAllocation__c;
            
            if (!mapHashToFinanceReportsList.containsKey(hash)) {
                mapHashToFinanceReportsList.put(hash, new List<gFRS_Finance_Report_Junction__c>());
            }
            
            mapHashToFinanceReportsList.get(hash).add(financeReport);
            
            System.debug('KK mapHashToFinanceReportsList 1st: ' + mapHashToFinanceReportsList);
        }
        //}
        
        
        for (GFRS_Payment_History__c paymentHistory : lPaymentHistories) {
            
            GFRS_Payment_History__c oldPaymentHistory = mapOldPaymentHistories.get(paymentHistory.Id);
            String hash = '' + paymentHistory.Id + oldPaymentHistory.Funding_Allocation__c;
            List<gFRS_Finance_Report_Junction__c> financeReportsForHash = mapHashToFinanceReportsList.get(hash);
            
            List<gFRS_Finance_Report_Junction__c> financeReportsForHashNew = new List<gFRS_Finance_Report_Junction__c>();
            for (gFRS_Finance_Report_Junction__c financeReport : lFinanceReportJunctions) {
                if (financeReport.PaymentRefundHistory__r.SAP_Doc_ID__c != null) {
                    String hashNewPaymentHistory = '' + financeReport.PaymentRefundHistory__c + financeReport.FundingAllocation__c;
                    System.debug('KK mapHashToFinanceReportsList 2nd: ' + mapHashToFinanceReportsList);
                    financeReportsForHashNew.addAll(mapHashToFinanceReportsList.get(hashNewPaymentHistory));
                    System.debug('KK mapHashToFinanceReportsList 3rd: ' + mapHashToFinanceReportsList);
                    System.debug('KK hashNewPaymentHistory: ' + hashNewPaymentHistory);
                }
            }
            
            if (financeReportsForHash == null) {
                financeReportsForHash = financeReportsForHashNew;
            } else if (financeReportsForHashNew != null) {
                financeReportsForHash.addAll(financeReportsForHashNew);
            }
            
            System.debug('KK mapHashToFinanceReportsList 4th: ' + mapHashToFinanceReportsList);
            System.debug('KK hash: ' + hash);
            
            System.debug('KK financeReportsForHash: ' + financeReportsForHash);
            System.debug('KK financeReportsForHashNew: ' + financeReportsForHashNew);
            
            if (financeReportsForHash != null) {
                System.debug('KK financeReportsForHash: ' + financeReportsForHash);
                for (gFRS_Finance_Report_Junction__c financeReport : financeReportsForHash) {
                    financeReport.FundingAllocation__c = paymentHistory.Funding_Allocation__c;
                    financeReport.PaymentRefundHistory__c = paymentHistory.Id;
                    if (!(new Map<Id, gFRS_Finance_Report_Junction__c>(lReportsToUpdate).containsKey(financeReport.Id))) {
                        lReportsToUpdate.add(financeReport);
                    }
                    System.debug('KK financeReport: ' + financeReport);
                }
            }
        }
        
        update lReportsToUpdate;
    }
    
    
    /**
* @brief  Method to update gFRS_Finance_Report_Junction__c records with null PaymentRefundHistory__c after related GFRS_Payment_History__c records were inserted.
* @param  newPaymentHistories - list of inserted GFRS_Payment_History__c records (Trigger.new)
* @author ADMD GFRS Dev Team
* @date   2015-10-12
*/
    public static void updateFinanceReportJunctionPaymentHistoryOnInsert(GFRS_Payment_History__c[] newPaymentHistories) {
        
        List<gFRS_Finance_Report_Junction__c> reportsToUpdate = new List<gFRS_Finance_Report_Junction__c>();
        Map<Id, List<gFRS_Finance_Report_Junction__c> > mapChildIdToFinanceReports = new Map<Id, List<gFRS_Finance_Report_Junction__c> >();
        
        /* map Finance Reports to either Funding Allocation Id or Grant Request Id */
        {
            /* Gather Ids of Funding Allocations and Grant Requests */
            Set<Id> setFundingAllocationId = new Set<Id>();
            Set<Id> setGrantRequestIds = new Set<Id>();
            
            for (GFRS_Payment_History__c paymentHistory : newPaymentHistories) {
                setGrantRequestIds.add(paymentHistory.Grant__c);
                setFundingAllocationId.add(paymentHistory.Funding_Allocation__c);
            }
            setGrantRequestIds.remove(null);
            setFundingAllocationId.remove(null);
            
            List<gFRS_Finance_Report_Junction__c> reportsWithoutPaymentHistory = [
                SELECT Id, PaymentRefundHistory__c, FundingAllocation__c, FundingAllocation__r.Grant_Request__c
                FROM gFRS_Finance_Report_Junction__c
                WHERE PaymentRefundHistory__c = NULL
                AND (
                    FundingAllocation__c IN :setFundingAllocationId
                    OR
                    FundingAllocation__r.Grant_Request__c IN :setGrantRequestIds
                )
            ];
            
            for (gFRS_Finance_Report_Junction__c report : reportsWithoutPaymentHistory) {
                
                if (!mapChildIdToFinanceReports.containsKey(report.FundingAllocation__c)) {
                    mapChildIdToFinanceReports.put(report.FundingAllocation__c, new List<gFRS_Finance_Report_Junction__c>());
                }
                if (!mapChildIdToFinanceReports.containsKey(report.FundingAllocation__r.Grant_Request__c)) {
                    mapChildIdToFinanceReports.put(report.FundingAllocation__r.Grant_Request__c, new List<gFRS_Finance_Report_Junction__c>());
                }
                
                mapChildIdToFinanceReports.get(report.FundingAllocation__c).add(report);
                mapChildIdToFinanceReports.get(report.FundingAllocation__r.Grant_Request__c).add(report);
            }
            mapChildIdToFinanceReports.remove(null);
        }
        
        for (GFRS_Payment_History__c paymentHistory : newPaymentHistories) {
            List<gFRS_Finance_Report_Junction__c> financeReports = new List<gFRS_Finance_Report_Junction__c>();
            
            if (mapChildIdToFinanceReports.containsKey(paymentHistory.Funding_Allocation__c)) {
                financeReports = mapChildIdToFinanceReports.get(paymentHistory.Funding_Allocation__c);
            } else if (mapChildIdToFinanceReports.containsKey(paymentHistory.Grant__c)) {
                financeReports = mapChildIdToFinanceReports.get(paymentHistory.Grant__c);
            }
            
            for (gFRS_Finance_Report_Junction__c report : financeReports) {
                report.PaymentRefundHistory__c = paymentHistory.Id;
                reportsToUpdate.add(report);
            }
        }
        
        update reportsToUpdate;
    }
    
    /**
* @author GFRS Dev Team
* @date 04/08/2015
* @description updateOutcomesSubmisson method -  Outcomes submission status on close validation.
*/
    public static void updateOutcomesSubmisson(GFRS_Funding_Request__c[] items, Map<Id, GFRS_Funding_Request__c> oldRequests) {
        for (GFRS_Funding_Request__c item : items) {
            /*if('IMED'.equals(item.Record_Type_Name__c) & item.Outcomes_Submission_Status__c !=null && !item.Outcomes_Submission_Status__c.equals(oldRequests.get(item.Id).Outcomes_Submission_Status__c)){
changing if confition to fix saving of outcomes task when generated because of reconciliation */
            if ('IMED'.equals(item.Record_Type_Name__c) & item.Outcomes_Submission_Status__c != null) {
                List<gFRS_Tasks__c> tasks = [
                    SELECT Id, Status__c, Action_Type__c
                    FROM gFRS_Tasks__c
                    WHERE gFRS_Funding_Request__c = :item.Id
                    AND Action_Type__c = 'Outcomes'
                ];
                if (tasks.size() > 0) {
                    if ('Partial Outcomes'.equals(item.Outcomes_Submission_Status__c)) {
                        for (gFRS_Tasks__c t : tasks) {
                            t.Status__c = gFRS_Util.TASK_ONGOING;
                        }
                    } else if ('Final Outcomes'.equals(item.Outcomes_Submission_Status__c)) {
                        for (gFRS_Tasks__c t : tasks) {
                            t.Status__c = gFRS_Util.TASK_COMPLETED;
                        }
                    }
                    update tasks;
                }
            }
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 04/08/2015
* @description updateOutcomesSubmisson method -  Outcomes submission status on close validation (for new requests)
*/
    public static void updateOutcomesSubmisson(GFRS_Funding_Request__c[] items) {
        for (GFRS_Funding_Request__c item : items) {
            if ('IMED'.equals(item.Record_Type_Name__c) & item.Outcomes_Submission_Status__c != null) {
                List<gFRS_Tasks__c> tasks = [
                    SELECT Id, Status__c, Action_Type__c
                    FROM gFRS_Tasks__c
                    WHERE gFRS_Funding_Request__c = :item.Id
                    AND Action_Type__c = 'Outcomes'
                ];
                if (tasks.size() > 0) {
                    if ('Partial Outcomes'.equals(item.Outcomes_Submission_Status__c)) {
                        for (gFRS_Tasks__c t : tasks) {
                            t.Status__c = gFRS_Util.TASK_ONGOING;
                        }
                    } else if ('Final Outcomes'.equals(item.Outcomes_Submission_Status__c)) {
                        for (gFRS_Tasks__c t : tasks) {
                            t.Status__c = gFRS_Util.TASK_COMPLETED;
                        }
                    }
                    update tasks;
                }
            }
        }
    }
    
    /**
* Check if LPED or LLPED changed on Funding Request and update Substatus accordingly
*/
    public static void updateSubstatusOnProgramDatesChange(GFRS_Funding_Request__c[] requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        
        Set<SObject> changedRequestsForLPED = gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'Program_End_Date_max__c');
        Set<SObject> changedRequestsForLLPED = gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'Last_Live_Program_End_Date__c');
        Set<SObject> changedRequests = new Set<SObject>();
        changedRequests.addAll(changedRequestsForLPED);
        changedRequests.addAll(changedRequestsForLLPED);
        
        Map<Id, GFRS_Funding_Request__c> changedRequestsWithTasks = new Map<Id, GFRS_Funding_Request__c>();
        if (changedRequests.size() > 0) {
            changedRequestsWithTasks = new Map<Id, GFRS_Funding_Request__c>([
                SELECT
                Id, (
                    SELECT Id, Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c
                    FROM gFRS_Tasks__r
                    WHERE Action_Type__c IN :new List<String>{
                        gFRS_Util.TASK_RECONCILIATION, gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE
                            }
                )
                FROM GFRS_Funding_Request__c
                WHERE Id IN :changedRequests
            ]);
        }
        
        List<gFRS_Tasks__c> tasksToClose = new List<gFRS_Tasks__c>();
        
        for (SObject sObj : changedRequests) {
            
            GFRS_Funding_Request__c fundingRequest = (GFRS_Funding_Request__c) sObj;
            
            if (!(new Set<String>{
                gFRS_Util.REQUEST_SUB_STATUS_RECONCILE_REQ,
                    gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE
                    }).contains(fundingRequest.Sub_Status__c)) {
                        continue;
                    }
            
            Boolean LPEDChanged = false;
            Boolean LLPEDChanged = false;
            
            /* LLPED changed and Sunshine wasn't submittted */
            if (!fundingRequest.Sunshine_Communication_Sent__c && changedRequestsForLLPED.contains(fundingRequest) && (String.isBlank(fundingRequest.Sunshine_Act_Disclosure_Submitted__c) || fundingRequest.Sunshine_Act_Disclosure_Submitted__c.equals('No'))) {
                GFRS_Funding_Request__c oldRequest = oldMap.get(fundingRequest.Id);
                if (oldRequest.Last_Live_Program_End_Date__c != null &&
                    (fundingRequest.Last_Live_Program_End_Date__c == null || (Date.today() >= oldRequest.Last_Live_Program_End_Date__c && fundingRequest.Last_Live_Program_End_Date__c > Date.today()))) {
                        LLPEDChanged = true;
                        for (gFRS_Tasks__c task : changedRequestsWithTasks.get(fundingRequest.Id).gFRS_Tasks__r) {
                            if (task.Action_Type__c.equals(gFRS_Util.TASK_SUNSHINE_ACT_DISCLOSURE)) {
                                tasksToClose.add(task);
                            }
                        }
                    }
            }
            
            /* LPED changed and Reconciliation wasn't submittted */
            if (changedRequestsForLPED.contains(fundingRequest) && (String.isBlank(fundingRequest.Reconciliation_Completed__c) || fundingRequest.Reconciliation_Completed__c.equals('No'))) {
                GFRS_Funding_Request__c oldRequest = oldMap.get(fundingRequest.Id);
                if (oldRequest.Program_End_Date_max__c != null &&
                    (fundingRequest.Program_End_Date_max__c == null || (Date.today() >= oldRequest.Program_End_Date_max__c && fundingRequest.Program_End_Date_max__c > Date.today()))) {
                        fundingRequest.Reconciliation_Required_Status_Date__c = null;
                        LPEDChanged = true;
                        for (gFRS_Tasks__c task : changedRequestsWithTasks.get(fundingRequest.Id).gFRS_Tasks__r) {
                            if (task.Action_Type__c.equals(gFRS_Util.TASK_RECONCILIATION)) {
                                tasksToClose.add(task);
                            }
                        }
                    }
            }
            
            if (!LPEDChanged && !LLPEDChanged) {
                continue;
            }
            
            if (((LPEDChanged && LLPEDChanged) || LLPEDChanged) || (LPEDChanged && !fundingRequest.Sub_Status__c.equals(gFRS_Util.REQUEST_SUB_STATUS_SUNSHINE))) {
                fundingRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES;
                fundingRequest.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES;
            }
        }
        
        if (tasksToClose.size() > 0) {
            delete tasksToClose;
        }
        
    }
    
    private static final Map<String, String> USR_FLDS_BY_STEP = new Map<String, String>{
        'Business Reviewer' => 'Business_Reviewer_1__c',
            'Business Review' => 'Business_Reviewer_1__c',
            'Business Approver 1 Review' => 'Business_Approver__c',
            'Business Approver 2 Review' => 'Business_Approver_2__c',
            'Business Approver 3 Review' => 'Business_Approver_3__c',
            'Legal Reviewer' => 'Legal_Reviewer_1__c',
            'Business Approver' => 'Business_Approver__c',
            'Financial Approver 1' => 'Financial_Approver_1__c',
            'Financial Approver 2' => 'Financial_Approver_2__c',
            'Financial Approver 3' => 'Financial_Approver_3__c',
            //'Financial Approver 4' => 'Financial_Approver_4__c',
            'Financial Approver 5' => 'Financial_Approver_5__c',
            'Business/Financial Approver' => 'Financial_Approver_1__c',
            'Business / Financial Approver' => 'Financial_Approver_1__c'
            };
                
                public static void CreateSharingOnFundingRequest(GFRS_Funding_Request__c fndRequest) {
                    System.debug('In Create Sharing Funding Request');
                    try {
                        
                        List<ProcessInstance> prcIns = [
                            SELECT TargetObjectId, (
                                SELECT ActorId, ProcessInstanceId
                                FROM Workitems
                            ), (
                                SELECT ProcessNodeName
                                FROM Nodes
                                WHERE NodeStatus = 'Pending'
                            )
                            FROM ProcessInstance
                            WHERE TargetObjectId = :fndRequest.Id
                            LIMIT 1
                        ];
                        
                        if (prcIns.size() > 0) {
                            if (prcIns[0].Nodes.size() > 0 && prcIns[0].Workitems.size() > 0) {
                                
                                String us = prcIns[0].Workitems[0].ActorId;
                                
                                String field = USR_FLDS_BY_STEP.get(prcIns[0].Nodes[0].ProcessNodeName);
                                if (field != null) {
                                    List<Id> usId = new List<Id>();
                                    usId.add(us);
                                    List<Id> FNDId = new List<Id>();
                                    FNDId.add(fndRequest.Id);
                                    Map<Id, Schema.RecordTypeInfo> rt_Map = GFRS_Funding_Request__c.SObjectType.getDescribe().getRecordTypeInfosById();
                                    String recordTypeSt = rt_Map.get(fndRequest.RecordTypeId).getName();
                                    
                                    if (field == 'Financial_Approver_3__c' && (recordTypeSt == 'Corporate Memberships' || recordTypeSt == 'Exhibits AND Other Promos' || recordTypeSt == 'Scientific Pipeline')) {
                                        addManualSharingAsyncOneSharing(FNDId, usId);
                                    } else {
                                        addManualSharingAsync(FNDId, usId);
                                        
                                    }
                                    grantApproverAccessAsync(usId);
                                }
                            }
                        }
                    } catch (Exception ex) {
                        System.debug('Exception: ' + ex.getMessage());
                        System.debug('Exception Line Number: ' + ex.getLineNumber());
                    }
                }
    
    /**
* GFRS-978: Stores IDs of new or modified approvers to prevent their cyclic processing within single transaction.
*/
    public static final Set<Object> APPROVER_IDS = new Set<Object>{
        null
            };
                
                public static void addSharingForChangedApprovers(
                    final Map<Id, GFRS_Funding_Request__c> newRequests,
                    final Map<Id, GFRS_Funding_Request__c> oldRequests
                ) {
                    System.debug('Approval Sharing method');
                    final Id[] reqIds = new Id[]{
                    };
                        final List<Id> FNDId = new List<Id>();
                    final List<Id> usId = new List<Id>();
                    final Map<Id, Id> reqIdsByItemIdWriteSharing = new Map<Id, Id>();
                    final Map<Id, String> fldsByItemIdWriteSharing = new Map<Id, String>();
                    final Id[] newApproverIds = new Id[]{
                    };
                        final Set<Id> uniqueReqIds = new Set<Id>();
                    final Map<Id, Id> reqIdsByItemId = new Map<Id, Id>();
                    final Map<Id, String> fldsByItemId = new Map<Id, String>();
                    final ProcessInstanceWorkitem[] modifiedWorkItemsWriteSharing = new ProcessInstanceWorkitem[]{
                    };
                        final ProcessInstanceWorkitem[] modifiedWorkItems = new ProcessInstanceWorkitem[]{
                        };
                            Map<Id, Schema.RecordTypeInfo> rt_Map = GFRS_Funding_Request__c.SObjectType.getDescribe().getRecordTypeInfosById();
                    // collect all requests for which at least one approver has been modified
                    for (GFRS_Funding_Request__c req : newRequests.values()) {
                        for (String fld : new Set<String>(USR_FLDS_BY_STEP.values())) {
                            if (req.get(fld) != null && req.get(fld) != oldRequests.get(req.Id).get(fld)) {
                                if (APPROVER_IDS.add(req.get(fld))) {
                                    newApproverIds.add((Id) req.get(fld));
                                }
                                uniqueReqIds.add(req.Id);
                            }
                        }
                    }
                    final Map<Id, ProcessInstance> approvalProcesses = new Map<Id, ProcessInstance>(
                        uniqueReqIds.isEmpty() ? new ProcessInstance[]{
                        } : [
                            SELECT TargetObjectId, (
                                SELECT ActorId, ProcessInstanceId
                                FROM Workitems
                            ), (
                                SELECT ProcessNodeName
                                FROM Nodes
                                WHERE NodeStatus = 'Pending'
                            )
                            FROM ProcessInstance
                            WHERE TargetObjectId IN :uniqueReqIds
                        ]);
                    for (ProcessInstance proc : approvalProcesses.values()) {
                        for (ProcessInstanceWorkitem item : proc.Workitems) { // pending work item
                            for (ProcessInstanceNode node : proc.Nodes) { // pending nodes
                                final String fld = USR_FLDS_BY_STEP.get(node.ProcessNodeName);
                                final Id usrId = fld == null ? item.ActorId : (Id) newRequests.get(proc.TargetObjectId).get(fld);
                                GFRS_Funding_Request__c fndRequest = newRequests.get(proc.TargetObjectId);
                                
                                String fndType = rt_Map.get(fndRequest.RecordTypeId).getName();
                                if (usrId != item.ActorId) {
                                    if (fld == 'Financial_Approver_3__c' && (fndType == 'Corporate Memberships' || fndType == 'Exhibits AND Other Promos' || fndType == 'Scientific Pipeline')) {
                                        item.ActorId = usrId;
                                        reqIdsByItemIdWriteSharing.put(item.Id, proc.TargetObjectId);
                                        fldsByItemIdWriteSharing.put(item.Id, fld);
                                        modifiedWorkItemsWriteSharing.add(item);
                                    } else {
                                        item.ActorId = usrId;
                                        modifiedWorkItems.add(item);
                                        fldsByItemId.put(item.Id, fld);
                                        reqIdsByItemId.put(item.Id, proc.TargetObjectId);
                                    }
                                }
                            }
                        }
                    }
                    if (!(newApproverIds.isEmpty() || System.isFuture() || System.isBatch()) &&
                        Limits.getFutureCalls() < Limits.getLimitFutureCalls()
                       ) {
                           grantApproverAccessAsync(newApproverIds);
                       }
                    if (!(modifiedWorkItems.isEmpty() || System.isFuture() || System.isBatch()) &&
                        Limits.getFutureCalls() < Limits.getLimitFutureCalls()
                       ) {
                           reqIds.clear();
                           newApproverIds.clear();
                           for (ProcessInstanceWorkitem item : modifiedWorkItems) {
                               reqIds.add(approvalProcesses.get(item.ProcessInstanceId).TargetObjectId);
                               newApproverIds.add(item.ActorId);
                           }
                           System.debug('Execute Manaula Sharing Approve ');
                           addManualSharingAsync(reqIds, newApproverIds);
                       }
                    
                    if (!(modifiedWorkItemsWriteSharing.isEmpty() || System.isFuture() || System.isBatch()) &&
                        Limits.getFutureCalls() < Limits.getLimitFutureCalls()) {
                            
                            for (ProcessInstanceWorkitem item : modifiedWorkItemsWriteSharing) {
                                FNDId.add(approvalProcesses.get(item.ProcessInstanceId).TargetObjectId);
                                usId.add(item.ActorId);
                            }
                            addManualSharingAsyncOneSharing(FNDId, usId);
                            
                            
                            for (ProcessInstanceWorkitem item : modifiedWorkItemsWriteSharing) {
                                modifiedWorkItems.add(item);
                                fldsByItemId.put(item.Id, fldsByItemIdWriteSharing.get(item.Id));
                                reqIdsByItemId.put(item.Id, reqIdsByItemIdWriteSharing.get(item.Id));
                            }
                        }
                    
                    final Database.SaveResult[] results = modifiedWorkItems.isEmpty() ?
                        new Database.SaveResult[]{
                        } : Database.update(modifiedWorkItems, false);
                    for (Integer i = 0; i < results.size(); i++) {
                        if (!results[i].isSuccess()) {
                            final Id reqId = reqIdsByItemId.get(modifiedWorkItems[i].Id);
                            final String fld = fldsByItemId.get(modifiedWorkItems[i].Id);
                            final Map<String, Schema.SObjectField> flds = reqId.getSobjectType().getDescribe().fields.getMap();
                            newRequests.get(reqId).addError((
                                flds.containsKey(fld) ? flds.get(fld).getDescribe().getLabel() + ': ' : ''
                            ) + results[i].getErrors()[0].getMessage());
                        }
                    }
                }
    @Future
    public static void addManualSharingAsync(final Id[] reqIds, final Id[] usrIds) {
        final GFRS_Funding_Request__Share[] shares = new GFRS_Funding_Request__Share[]{
        };
            
            for (Integer i = 0; i < reqIds.size(); i++) {
                if (reqIds[i] != null && usrIds.size() > i && usrIds[i] != null && [
                    SELECT RecordId
                    FROM UserRecordAccess
                    WHERE RecordId = :reqIds[i]
                    AND HasReadAccess = TRUE
                    AND UserId = :usrIds[i]
                    LIMIT 1
                ].isEmpty()) {
                    shares.add(new GFRS_Funding_Request__Share(
                        AccessLevel = gFRS_Util.SHARING_READ,
                        UserOrGroupId = usrIds[i],
                        ParentId = reqIds[i],
                        RowCause = 'Manual'
                    ));
                }
            }
        Database.insert(shares, false); // to enable partial success if any error is encountered for any sharing
    }
    
    @Future
    public static void addManualSharingAsyncOneSharing(final Id[] reqIds, final Id[] usrIds) {
        final GFRS_Funding_Request__Share[] shares = new GFRS_Funding_Request__Share[]{
        };
            
            for (Integer i = 0; i < reqIds.size(); i++) {
                if (reqIds[i] != null && usrIds.size() > i && usrIds[i] != null && [
                    SELECT RecordId
                    FROM UserRecordAccess
                    WHERE RecordId = :reqIds[i]
                    AND HasEditAccess = TRUE
                    AND UserId = :usrIds[i]
                    LIMIT 1
                ].isEmpty()) {
                    shares.add(new GFRS_Funding_Request__Share(
                        AccessLevel = gFRS_Util.SHARING_WRITE,
                        UserOrGroupId = usrIds[i],
                        ParentId = reqIds[i],
                        RowCause = 'Manual'
                    ));
                }
            }
        Database.insert(shares, false); // to enable partial success if any error is encountered for any sharing
    }
    
    @Future
    public static void grantApproverAccessAsync(final Id[] usrIds) {
        final Set<Id> uniqueUsrIds = new Set<Id>(usrIds);
        uniqueUsrIds.remove(null);
        final PermissionSetAssignment[] assignments = new PermissionSetAssignment[]{
        };
            final PermissionSet[] approverPermissions = uniqueUsrIds.isEmpty() ? new PermissionSet[]{
            } : [
                SELECT Id
                FROM PermissionSet
                WHERE Name = 'gFRS_Request_Approver'
                LIMIT 1
            ];
        for (PermissionSetAssignment assignment : uniqueUsrIds.isEmpty() || approverPermissions.isEmpty() ?
             new PermissionSetAssignment[]{
             } : [
                 SELECT AssigneeId
                 FROM PermissionSetAssignment
                 WHERE AssigneeId IN :usrIds
                 AND PermissionSetId = :approverPermissions[0].Id
                 LIMIT :uniqueUsrIds.size()
             ]) {
                 uniqueUsrIds.remove(assignment.AssigneeId);
             }
        for (Id usrId : approverPermissions.isEmpty() ? new Set<Id>() : uniqueUsrIds) {
            assignments.add(new PermissionSetAssignment(AssigneeId = usrId, PermissionSetId = approverPermissions[0].Id));
        }
        Database.insert(assignments, false); // to enable partial success if any error is encountered for any assignment
    }
    
    /**
* @author GFRS Dev Team
* @date 26/11/2013
* @description getUserContact method - Determines the contact that represents the current user (and account they belong to).
*/
    public static Contact getUserContact(Id userId) {
        try {
            User u = [SELECT Contact.Id, Contact.AccountId, Contact.Account.Id, Contact.Account.Name, Contact.Organization__c, Contact.Organization__r.Id, Contact.Organization__r.Organization_Name__c FROM User WHERE Id = :userId];
            if (u.Contact == null || u.Contact.Account == null) {
                return(null);
            } else {
                return(u.Contact);
            }
        } catch (Exception err) {
            System.debug('unable to find user:' + userId);
            return(null);
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 26/11/2013
* @description isUserInternal method - Determines the contact record for the current user.
*/
    public static Boolean isUserInternal(Id userId) {
        User u = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        return(u != null);
    }
    
    /**
* @author GFRS Dev Team
* @date 23/11/2017
* @description checkByNameIfGLAccountExist - checks if GL account name is on the source list.
* @param accountName GL Account Name
* @param sourceList Source list of all GL Accounts
* @return true if account name is on source list, false if not.
*/
    public static Boolean checkByNameIfGLAccountExist(String accountName, List<GFRS_GL_Account__c> sourceList) {
        for (GFRS_GL_Account__c account : sourceList) {
            if (account.Name.equals(accountName)) {
                return true;
            }
        }
        return false;
    }
    
    /**
* @author GFRS Dev Team
* @date 17/04/2018
* @description For actual record Id method finds current approval step and change current approver to new approver.
*
* @param requestId funding request Id
* @param newApproverId new approver user Id
*/
    public static void forceReassignApprover(Id requestId, Id newApproverId) {
        List<ProcessInstance> processInstances = [
            SELECT Id, TargetObjectId, Status, (SELECT Id, Actor.Name FROM Workitems), (SELECT Id, StepStatus, Comments, Actor.Name FROM Steps)
            FROM ProcessInstance
            WHERE TargetObjectId = :requestId
        ];
        
        if (processInstances.size() > 0) {
            if (processInstances[0].Workitems.size() > 0) {
                ProcessInstanceWorkitem currentItem = processInstances[0].Workitems[0];
                Id currentApprover = processInstances[0].Workitems[0].ActorId;
                if (currentApprover != newApproverId) {
                    currentItem.ActorId = newApproverId;
                    update currentItem;
                }
            }
        }
    }
    
    public static Boolean checkIfUserHasCustomPermission(String permissionSetName) {
        return FeatureManagement.checkPermission(permissionSetName);
    }
    
    public static List<ProcessInstance> getProcessInstances(Id requestId) {
        List<ProcessInstance> processInstances = [
            SELECT Id, TargetObjectId, Status, (SELECT Id, Actor.Name FROM Workitems), (SELECT Id, StepStatus, Comments, Actor.Name FROM Steps)
            FROM ProcessInstance
            WHERE TargetObjectId = :requestId
        ];
        return processInstances.size() > 0 ? processInstances : new List<ProcessInstance>();
    }
    
    /**
* @author GFRS Dev Team
* @date 27/06/2018
* @description Method to query Process Instances based on request Ids and Statuses (ex. 'Pending').
*
* @param affectedRequestsIds List of funding requests Ids
* @param affectedApprovalStatuses List of Approval Process Statuses (Pending, Started etc.)
*
* @return List with Process Instances
*/
    public static List<ProcessInstance> getProcessInstancesForAffectedSteps(List<Id> requestsIds, List<String> approvalStatuses) {
        List<ProcessInstance> processInstances = [
            SELECT Id, TargetObjectId, Status, (SELECT Id, Actor.Name FROM Workitems), (SELECT Id, StepStatus, Comments, Actor.Name FROM Steps)
            FROM ProcessInstance
            WHERE TargetObjectId IN :requestsIds
            AND Status IN :approvalStatuses
        ];
        return processInstances.size() > 0 ? processInstances : new List<ProcessInstance>();
    }
    
    /**
* @author GFRS Dev Team
* @data 27/06/2018
* @description Method that query Process Instance Nodes based on List of Process Instances and Approval steps.
*
* @param processInstances List of Process Instances
* @param approvalSteps List of approval steps names
*
* @return Map with Id of request and Process Instance Node matching approval step name
*/
    public static Map<Id, ProcessInstanceNode> getProcessInstanceNodes(List<ProcessInstance> processInstances, List<String> approvalSteps) {
        Set<Id> processInstancesIds = new Set<Id>();
        for (ProcessInstance processInstance : processInstances) {
            processInstancesIds.add(processInstance.Id);
        }
        List<ProcessInstanceNode> processInstanceNodes = [
            SELECT Id, NodeStatus, ProcessNode.Name, ProcessInstanceId, ProcessInstance.TargetObjectId
            FROM ProcessInstanceNode
            WHERE ProcessInstanceId IN :processInstancesIds AND ProcessNode.Name IN :approvalSteps
        ];
        Map<Id, ProcessInstanceNode> resultMap = new Map<Id, ProcessInstanceNode>();
        for (ProcessInstanceNode processInstanceNode : processInstanceNodes) {
            resultMap.put(processInstanceNode.ProcessInstance.TargetObjectId, processInstanceNode);
        }
        return resultMap.size() > 0 ? resultMap : new Map<Id, ProcessInstanceNode>();
    }
    
    /**
* @author GFRS Dev Team
* @date 27/06/2018
* @description Method to query all Funding Requests that are related to Organization.
*
* @param organizationsIds List of Organizations Ids
*
* @return Map with Id of Organization and Organization object
*/
    public static Map<Id, GFRS_Funding_Request__c> getRequestsFromOrganizations(List<Id> organizationsIds) {
        Map<Id, GFRS_Funding_Request__c> requestsIdsFromOrg = new Map<Id, GFRS_Funding_Request__c>([SELECT Id, Organization__c FROM GFRS_Funding_Request__c WHERE Organization__c IN :organizationsIds]);
        return requestsIdsFromOrg.size() > 0 ? requestsIdsFromOrg : new Map<Id, GFRS_Funding_Request__c>();
    }
    
    /**
* @description Method to check if user is in queue or has Admin profile
*
* @param userId
* @param queueName
*
* @return true if user is in queue or Admin
*/
    public static Boolean isUserHasPermissionOrAdmin(String permissionName) {
        List<PermissionSetAssignment> permissionSetAssignments = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Name = :permissionName AND AssigneeId = :UserInfo.getUserId()];
        return permissionSetAssignments.size() > 0 ? true : [SELECT Id FROM Profile WHERE Name = :gFRS_Util.PROFILE_NAME_SYS_ADMIN].Id == UserInfo.getProfileId() ? true : false;
    }
    
    public static gFRS_Shutdown_Rule__c checkShutdownRule(String fundingRecordTypeName) {
        gFRS_Shutdown_Rule__c result = null;
        Date currentDate = Date.today();
        List<gFRS_Shutdown_Rule__c> shutdownRules = [SELECT Message__c, Funding_type__c FROM gFRS_Shutdown_Rule__c WHERE Start_date__c <= :currentDate AND End_date__c >= :currentDate AND Active__c = true];
        if (!shutdownRules.isEmpty()) {
            for (gFRS_Shutdown_Rule__c sdr : shutdownRules) {
                if (sdr.Funding_type__c.contains(fundingRecordTypeName)) {
                    sdr.Message__c = sdr.Message__c.replaceAll('<b>', '');
                    result = sdr;
                    break;
                }
            }
        }
        
        return result;
    }
    
    public static Date getThreeWeekdaysLaterDate(date inputDate){
        Date referenceDate = Date.newInstance(1900, 1, 7);
        Integer daysInBtwn = referenceDate.daysBetween(inputDate);
        Integer dayOfWeek = math.mod(daysInBtwn, 7);
        
        switch on dayOfWeek {
            when 0 {
                //Monday
                return inputDate.addDays(3);
            }  
            when 1 {
                //Tuesday
                return inputDate.addDays(3);
            }  
            when 2 {
                //Wednesday
                return inputDate.addDays(3);
            }
            when 3 {
                //Thursday
                return inputDate.addDays(5);
            }
            when 4 {
                //Friday
                return inputDate.addDays(5);
            }
            when 5{
                //Saturday
                return inputDate.addDays(5);
            }
            when 6{
                //Sunday
                return inputDate.addDays(4);
            }
        }
        
        return inputDate;
    }
    
    public static void setFiscalYear(List<GFRS_Funding_Request__c> requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        //   gFRS_Util.setFiscalYear(requests, oldMap);
        List<GFRS_Funding_Allocation__c> fundingAllocations = gFRS_DAO.getFundingAllocationsByRequestIds(gFRS_DAO.getFundingRequestsIds(requests));
        List<GFRS_Funding_Allocation__c> fundingAllocationsToUpdate = new List<GFRS_Funding_Allocation__c>();
        
        for (GFRS_Funding_Allocation__c fundingAllocation : fundingAllocations) {
            GFRS_Funding_Request__c oldFundingRequest = oldMap.get(fundingAllocation.Grant_Request__r.Id);
            
            if (gFRS_Util_NoShare.isBusinessApprovalRejected(oldFundingRequest, fundingAllocation.Grant_Request__r, true) ||
                gFRS_Util_NoShare.isBusinessApprovalRejected(oldFundingRequest, fundingAllocation.Grant_Request__r, false)) {
                    fundingAllocation.Approved_Fiscal_Year__c = null;
                    fundingAllocationsToUpdate.add(fundingAllocation);
                    continue;
                }
            
            if (gFRS_Util.checkRequestTypeForFiscalYearUpdate(oldFundingRequest) &&
                fundingAllocation.Grant_Request__r.Decision_Date__c != oldFundingRequest.Decision_Date__c) {
                    
                    Date decisionDate = fundingAllocation.Grant_Request__r.Decision_Date__c;
                    if (decisionDate != null) {
                        fundingAllocation.Approved_Fiscal_Year__c = String.valueOf(decisionDate.year());
                        fundingAllocationsToUpdate.add(fundingAllocation);
                        continue;
                    }
                }
        }
        
        if (fundingAllocationsToUpdate.size() > 0) {
            update fundingAllocationsToUpdate;
        }     
    }
    
    public static void recallRejection(string requestId) {
        List<ProcessInstance> instance = [SELECT Id FROM ProcessInstance WHERE TargetObjectId =: requestID AND Status = 'Pending' LIMIT 1];
        if(!instance.isEmpty()) {
            ProcessInstanceWorkitem workItem = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =: instance.get(0).Id LIMIT 1];
            Approval.ProcessWorkItemRequest workReq = new Approval.ProcessWorkItemRequest();
            workReq.setWorkItemId(workItem.Id);
            workReq.setAction('Reject');
            Approval.ProcessResult result = Approval.process(workReq);
        }       
    }    
    
    public static void deleteStatusUpdateTask(List<GFRS_Funding_Request__c> newReqList, map<Id,GFRS_Funding_Request__c> oldReqMap) {
        Set<Id> reqIds = new Set<Id>();
        list<gFRS_Funding_Request__c> updReq = new list<gFRS_Funding_Request__c>();
        for(GFRS_Funding_Request__c req : newReqList){
            if(req.StatusUpdate_Task_Deletion__c == true && req.StatusUpdate_Task_Deletion__c != oldReqMap.get(req.Id).StatusUpdate_Task_Deletion__c){
                reqIds.add(req.Id);
            }
        }
        
        if(reqIds.size() > 0){
            List<gFRS_Tasks__c> tasks = new List<gFRS_Tasks__c>();
            tasks = [SELECT Id FROM gFRS_Tasks__c WHERE gFRS_Funding_Request__c IN :reqIds AND Action_Type__c = 'Status Report'];
            if(tasks.size() > 0) {
                delete tasks;
            }     
            
            updReq = [SELECT Id, name, Program_Status_Task_Override_By__c FROM gFRS_Funding_Request__c WHERE Id IN : reqIds];
            for(gFRS_Funding_Request__c reqst : updReq){
                reqst.Program_Status_Task_Override_By__c = 'System';
            }
            saveLockedFundingRequests(updReq);

            list<GFRS_Program__c> progs = new list<GFRS_Program__c>();
            progs = [SELECT Id, name, Did_you_exhibit_sponsor_at_the_event__c FROM GFRS_Program__c WHERE Funding_Request__c in :reqIds];
            
            for(GFRS_Program__c prg : progs){
                prg.Did_you_exhibit_sponsor_at_the_event__c = 'Yes';
            }
            savePrograms(progs);
        }
    }    

    public static void statusUpdateTaskReminder(List<GFRS_Funding_Request__c> newReqList, map<Id,GFRS_Funding_Request__c> oldReqMap) {
        Set<Id> reqIds = new Set<Id>();
        list<gFRS_Funding_Request__c> updReq = new list<gFRS_Funding_Request__c>();
        for(GFRS_Funding_Request__c item : newReqList){
            if(item.Status_Update_Reminder__c != null && item.Status_Update_Reminder__c != '' && item.Status_Update_Reminder__c != oldReqMap.get(item.Id).Status_Update_Reminder__c && item.StatusUpdate_Communication_Sent__c != true){
                emailtemplate et;
                if(item.Status_Update_Reminder__c == 'Reminder One'){
                    et = [SELECT Subject, Name, Id, Description, HtmlValue, Body,DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'gFRS_RFI_Templates' and DeveloperName = 'Program_Status_Notification_1st_Reminder'];
                } else {
                    et = [SELECT Subject, Name, Id, Description, HtmlValue, Body,DeveloperName FROM EmailTemplate WHERE Folder.DeveloperName = 'gFRS_RFI_Templates' and DeveloperName = 'Program_Status_Notification_2nd_Reminder'];
                }

                String body = replaceEmailBodyNonFuture(et.HtmlValue, item);
                User userDetails = [SELECT Id, Name, Email FROM User WHERE Id =: item.OwnerId];
                body = body.replace('xxOwner Namexx', userDetails.Name);
                GFRS_Program__c Prog = [SELECT Id, Name, Start_Date__c, Venue_Name__c FROM GFRS_Program__c WHERE Funding_Request__c =: item.Id and End_Date__c =: item.Program_End_Date_max__c Order By Start_Date__c desc limit 1];
                string todaysDate = date.today().format();
                todaysDate = todaysDate.replaceall('/','-');
                string startDate = Prog.Start_Date__c.format();
                startDate = startDate.replaceall('/','-');
                body = body.replace('xxtodays datexx', todaysDate);
                body = body.replace('xxLast program Venuexx', Prog.Venue_Name__c);
                body = body.replace('xxLast program start datexx', startDate);
                body += '\n\n' + '[ref:' + item.id + ']';
                body = body.replaceAll('<!\\[CDATA\\[', '');
                body = body.replaceAll('\\]\\]>', '');
                String subject = replaceEmailSubject(et.Subject, item);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new List<String>{userDetails.Email});
                mail.setSubject(subject);
                mail.setHtmlBody(body);
                mail.setOrgWideEmailAddressId([SELECT Id, Address FROM OrgWideEmailAddress
                                               WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id);
                GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
                if (myOrgCS.gFRS_Inbound_Email__c != null) {
                    string bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;
                    mail.setBccAddresses(new List<String>{bccEmailAddress});                            
                }                               
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }       
    }
    
    public class CustomException extends Exception {
    }
    
}