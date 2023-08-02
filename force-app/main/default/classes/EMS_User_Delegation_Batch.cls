global without sharing class EMS_User_Delegation_Batch implements Database.Batchable<SObject>, Database.Stateful {
    private static Map<Id, GNE_User_Delegation__c> userDelegations = EMS_Util.getUserDelegations();
    private static final String emsRecordTypeId = GNE_User_Delegation__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('EMS').getRecordTypeId();
    private static final String APPROVAL_COMMENT = 'User Delegation change.';
    private static final String REJECT_ACTION = 'Reject';

    private static String mainSOQL = 'SELECT Username__c, Delegated_User__c, Start_Date__c, End_Date__c, Is_Delegation_Active__c FROM GNE_User_Delegation__c WHERE RecordTypeId = :emsRecordTypeId';
    private static Map<String, EMS_Event_Configuration_gne__c> eventConfigurations = EMS_Util.getEventConfigurations();

    List<String> executionLog = new List<String>();

    global EMS_User_Delegation_Batch() {
        executionLog.add('Active user delegations found: ' + userDelegations.size());
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        executionLog.add('EMS User Delegation Batch start');
        return Database.getQueryLocator(mainSOQL);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        executionLog.add('User Delegation Batch size: ' + scope.size());

        Set<Id> approverIds = getApproverIds((List<GNE_User_Delegation__c>) scope);
        updateFundRequestsAssignment(approverIds, executionLog);
        updateEventsAssignment(approverIds, executionLog);
        updateBudgetAllocationsBudgetOwner(approverIds, executionLog);
    }

    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
                SELECT Id
                FROM AsyncApexJob
                WHERE Id = :BC.getJobId()
        ];

        sendEmailSummary(BC.getJobId(), executionLog);
    }

    private static void updateBudgetAllocationsBudgetOwner(Set<Id> approverIds, List<String> executionLog) {
        executionLog.add('\n======== Budget Allocations ========');

        Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocations = new Map<Id, EMS_Budget_Allocation_gne__c>();
        for (EMS_Budget_Allocation_gne__c budgetAllocation : [
                SELECT Id, EMS_Event_gne__c, Budget_Owner_gne__c, Approver_gne__c, Comments_gne__c, Status_gne__c, EMS_Event_gne__r.Overall_Status_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE Budget_Owner_gne__c IN :approverIds
                AND Status_gne__c = 'Submitted'
        ]) {
            Id newApproverId = getDelegatedUser(budgetAllocation.Budget_Owner_gne__c);
            if (budgetAllocation.Approver_gne__c != newApproverId) {
                budgetAllocations.put(budgetAllocation.Id, budgetAllocation);
            }
        }
        executionLog.add('Budget Allocations with changed approver: ' + budgetAllocations.size());

        List<ProcessInstanceWorkitem> workitems = [
                SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId IN :budgetAllocations.keySet()
        ];
        // Check which BudgetAllocations have approval process in progress
        budgetAllocations.keySet().retainAll(getWorkitemsTarget(workitems));

        // Change Budget Allocation Approver
        Set<Id> eventIds = new Set<Id>();
        executionLog.add('Update Budget Allocations: ' + budgetAllocations.size());
        for (EMS_Budget_Allocation_gne__c budgetAllocation : budgetAllocations.values()) {
            eventIds.add(budgetAllocation.EMS_Event_gne__c);
            // Approver also is being updated in "EMS_Budget_Allocation_Field_Updates.overrideApprover" method
            budgetAllocation.Approver_gne__c = getDelegatedUser(budgetAllocation.Budget_Owner_gne__c);
            budgetAllocation.Comments_gne__c = APPROVAL_COMMENT;

            executionLog.add('---- after update: ' + String.valueOf(budgetAllocation));
        }

        // Update Related Events
        Map<Id, EMS_Event__c> eventsToUpdate = new Map<Id, EMS_Event__c>([
                SELECT Name, Event_Type_gne__c, Event_Sub_Type_gne__c
                FROM EMS_Event__c
                WHERE Id IN :eventIds
        ]);
        executionLog.add('Update Events: ' + eventsToUpdate.size());
        for (EMS_Event__c event : eventsToUpdate.values()) {
            event.Status_gne__c = eventConfigurations.get(event.Event_Type_gne__c + event.Event_Sub_Type_gne__c).Pending_Budget_Approval_Label_gne__c;
            event.Pending_Budget_Approval_gne__c = true;
            event.RecordTypeId = Schema.SObjectType.EMS_Event__c.recordTypeInfosByName.get('EMS Locked Event').recordTypeId;
            event.Submitted_Date_gne__c = System.today();
            event.Submitted_By_gne__c = UserInfo.getUserId();

            executionLog.add('---- after update: ' + String.valueOf(event));
        }

        finalizeProcess(workitems, budgetAllocations, executionLog);

        executionLog.add('Save ' + eventsToUpdate.getSObjectType().getDescribe().getLabelPlural() + ': ' + eventsToUpdate.size());
        for (Database.SaveResult sr : Database.update(eventsToUpdate.values())) {
            executionLog.add('---- save result: ' + eventsToUpdate.get(sr.getId()).Name + ', success: ' + sr.isSuccess());
        }
    }

    private static void updateFundRequestsAssignment(Set<Id> approverIds, List<String> executionLog) {
        executionLog.add('\n======== Fund Requests ========');

        Map<Id, EMS_Fund_Request_gne__c> fundRequests = new Map<Id, EMS_Fund_Request_gne__c>();
        for (EMS_Fund_Request_gne__c fundRequest : [
                SELECT Name, Approver_gne__c, Budget_Owner_gne__c
                FROM EMS_Fund_Request_gne__c
                WHERE Approver_gne__c IN :approverIds AND Status_gne__c = 'Submitted'
        ]) {
            Id newApproverId = getDelegatedUser(fundRequest.Budget_Owner_gne__c);
            if (fundRequest.Approver_gne__c != newApproverId) {
                fundRequests.put(fundRequest.Id, fundRequest);
            }
        }
        executionLog.add('Fund Requests with changed approver: ' + fundRequests.size());

        List<ProcessInstanceWorkitem> workitems = [
                SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId IN :fundRequests.keySet()
        ];
        fundRequests.keySet().retainAll(getWorkitemsTarget(workitems));
        executionLog.add('Fund requests with approval process: ' + fundRequests.size());

        // Change approver and create new Approval Request
        for (EMS_Fund_Request_gne__c fundRequest : fundRequests.values()) {
            fundRequest.Approver_gne__c = getDelegatedUser(fundRequest.Budget_Owner_gne__c);
            fundRequest.Status_gne__c = 'New';
            fundRequest.Approval_Rejection_Comments_gne__c = APPROVAL_COMMENT;

            executionLog.add('---- after update: ' + String.valueOf(fundRequest));
        }

        finalizeProcess(workitems, fundRequests, executionLog);
    }

    private static void updateEventsAssignment(Set<Id> approverIds, List<String> executionLog) {
        executionLog.add('\n======== Events ========');

        Map<Id, EMS_Event__c> events = new Map<Id, EMS_Event__c>();
        for (EMS_Event__c event : [
                SELECT Name, Event_Owner_gne__c, Approver_gne__c
                FROM EMS_Event__c
                WHERE Approver_gne__c IN :approverIds
                AND Status_gne__c LIKE '%Pending%'
                AND Status_gne__c != 'Pending Med Ops Review'
        ]) {
            Id newApproverId = getDelegatedUser(event.Event_Owner_gne__c);
            if (event.Approver_gne__c != newApproverId) {
                events.put(event.Id, event);
            }
        }
        executionLog.add('Fund Requests with changed approver: ' + events.size());


        // Check which Events have approval process in progress
        List<ProcessInstanceWorkitem> workitems = [
                SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId
                FROM ProcessInstanceWorkitem
                WHERE ProcessInstance.TargetObjectId IN :events.keySet()
        ];
        events.keySet().retainAll(getWorkitemsTarget(workitems));
        executionLog.add('Fund requests with approval process: ' + events.size());

        // Assign events to previous Approvers
        for (EMS_Event__c event : events.values()) {
            event.Approval_Rejection_Comments_gne__c = APPROVAL_COMMENT;
            event.Approver_gne__c = getDelegatedUser(event.Event_Owner_gne__c);

            executionLog.add('---- after update: ' + String.valueOf(event));
        }

        finalizeProcess(workitems, events, executionLog);
    }

    private static void finalizeProcess(List<ProcessInstanceWorkitem> workitems, Map<Id, SObject> objects, List<String> executionLog) {
        executionLog.add('-------- Finalize');
        // Recall all current Approval processes
        executionLog.add('Rejecting approval processes: ' + rejectApproval(workitems).size());

        // Update sObjects
        executionLog.add('Save ' + objects.getSObjectType().getDescribe().getLabelPlural() + ': ' + objects.size());
        for (Database.SaveResult sr : Database.update(objects.values())) {
            executionLog.add('---- save result: ' + objects.get(sr.getId()).get('Name') + ', success: ' + sr.isSuccess());
        }

        // Resend for approval fund requests that had approval before
        executionLog.add('Initialize approval workflow: ' + initiateApproval(objects.keySet()).size());

    }

    // Triggers on Update/Insert a User Delegation record
    @Future
    public static void handleUserDelegationsFuture(List<Id> scope) {
        handleUserDelegations(scope);
    }

    // Triggers on Update/Insert a User Delegation record
    public static void handleUserDelegations(List<Id> scope) {
        List<String> executionLog = new List<String>{
                'EMS User Delegation on demand execution',
                'User delegation scope size: ' + scope.size()
        };
        Set<Id> approverIds = getApproverIds(Database.query(mainSOQL + ' AND Id IN :scope'));
        updateFundRequestsAssignment(approverIds, executionLog);
        updateEventsAssignment(approverIds, executionLog);
        updateBudgetAllocationsBudgetOwner(approverIds, executionLog);

        sendEmailSummary(null, executionLog);
    }

    private static List<Approval.ProcessResult> rejectApproval(List<ProcessInstanceWorkitem> workitems) {
        List<Approval.ProcessWorkitemRequest> rejectRequests = new List<Approval.ProcessWorkitemRequest>();

        for (ProcessInstanceWorkitem workitem : workitems) {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setComments(APPROVAL_COMMENT);
            request.setAction(REJECT_ACTION);
            request.setWorkitemId(workitem.Id);
            rejectRequests.add(request);
        }

        return Approval.process(rejectRequests);
    }

    private static List<Approval.ProcessResult> initiateApproval(Set<Id> objectIds) {
        List<Approval.ProcessSubmitRequest> submitRequests = new List<Approval.ProcessSubmitRequest>();
        for (Id objectId : objectIds) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(objectId);
            req.setComments(APPROVAL_COMMENT);
            submitRequests.add(req);
        }
        return Approval.process(submitRequests);
    }

    private static Set<Id> getWorkitemsTarget(List<ProcessInstanceWorkitem> workitems) {
        Set<Id> result = new Set<Id>();
        for (ProcessInstanceWorkitem workitem : workitems) {
            result.add(workitem.ProcessInstance.TargetObjectId);
        }
        return result;
    }

    private static Set<Id> getApproverIds(List<GNE_User_Delegation__c> userDelegationScope) {
        Set<Id> approverIds = new Set<Id>();
        for (GNE_User_Delegation__c userDelegationItem : userDelegationScope) {
            approverIds.add(userDelegationItem.Username__c);
            approverIds.add(userDelegationItem.Delegated_User__c);
        }
        return approverIds;
    }

    private static Id getDelegatedUser(Id mainUserId) {
        Id delegatedUserId = mainUserId;
        if (userDelegations.containsKey(mainUserId)) {
            delegatedUserId = userDelegations.get(mainUserId).Delegated_User__c;
        }
        return delegatedUserId;
    }

    private static void sendEmailSummary(Id jobId, List<String> executionLog) {
        List<String> mails = EMS_Util.getApplicationAdminsEmails();

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('execution_log.txt');
        attachment.setBody(Blob.valueOf(String.join(executionLog, '\n')));

        EMS_Email.prepareSingleEmail('EMS_Batch_Job_Notification', jobId, mails, attachment);

        EMS_Email.send();
    }

}