public with sharing class EMS_Home_Controller {
    public List<EMS_Fund_Request_gne__c> fundingRequestsToApprove { get; set; }
    public List<EMS_Event__c> eventRequestsToApprove { get; set; }
    public List<EMS_Budget_Allocation_gne__c> budgetAllocationRequestsToApprove { get; set; }

    public List<EMS_ItemToApproveWrapper> itemsToApprove { get; set; }
    public List<EMS_Data_Change_Request_gne__c> dataChangeRequests { get; private set; }
    public List<EMS_EventsToApproveWrapper> eventsToApprove { get; set; }
    public List<EMS_BudgetAllocationToApproveWrapper> budgetAllocationsToApprove { get; set; }

    public String pagePositiveMessage { get; set; }

    private Set<Id> workItemTargetIds = new Set<Id>();
    private Map<Id, Id> workItemsIdsByIds = new Map<Id, Id>();

    public static Boolean isAdmin { get {return EMS_Util.isAdmin();} }
    public Integer taskCount { get {return EMS_Main_Menu_Ctrl.tasksCount;} }
    public Boolean noRedirect { get {return System.currentPageReference().getParameters().containsKey('nr');} }

    public EMS_Home_Controller() {
        eventRequestsToApprove = new List<EMS_Event__c>();
        budgetAllocationRequestsToApprove = new List<EMS_Budget_Allocation_gne__c>();
        fundingRequestsToApprove = new List<EMS_Fund_Request_gne__c>();
        dataChangeRequests = new List<EMS_Data_Change_Request_gne__c>();

        if (System.currentPageReference().getParameters().containsKey('msg')) {
            pagePositiveMessage = System.currentPageReference().getParameters().get('msg');
        } else {
            pagePositiveMessage = null;
        }
    }

    public PageReference initialize() {
        if (taskCount > 0 || noRedirect) {
            if (EMS_Util.isAdmin()) {
                fetchAdminDataChangeRequests();
            }

            fetchFundRequests();
            fetchEvents();
            fetchBudgetAllocations();
            fetchDataChangeRequests();

            fetchApprovalWorkItems();

            createFundRequestsWrapperLiist();
            createEventsWrapperList();
            createBudgetAllocationsWrapperList();

            return null;
        } else {
            return EMS_Util.getUserRole() == 'FC' ? Page.EMS_Product_Budget : Page.EMS_Event;
        }
    }

    private void fetchAdminDataChangeRequests() {
        dataChangeRequests.addAll([
                SELECT Id, Comment__c, Status_gne__c, Name, Event_Name_gne__r.Name, CreatedById, CreatedBy.Name, RecordType.Name, EMS_Territory_Budget_gne__c, EMS_Territory_Budget_gne__r.Name, EMS_Region_Budget_gne__c, EMS_Region_Budget_gne__r.Name, EMS_Product_Budget_gne__c, EMS_Product_Budget_gne__r.Name
                FROM EMS_Data_Change_Request_gne__c
                WHERE Status_gne__c IN ('Submitted', 'New')
        ]);
    }

    private void fetchDataChangeRequests() {
        dataChangeRequests.addAll([
                SELECT Id, Comment__c, Status_gne__c, Name, Event_Name_gne__r.Name, CreatedById, CreatedBy.Name, RecordType.Name, EMS_Territory_Budget_gne__c, EMS_Territory_Budget_gne__r.Name, EMS_Region_Budget_gne__c, EMS_Region_Budget_gne__r.Name, EMS_Product_Budget_gne__c, EMS_Product_Budget_gne__r.Name
                FROM EMS_Data_Change_Request_gne__c
                WHERE Assigned_BPS_gne__c = :UserInfo.getUserId()
                AND Status_gne__c = 'Submitted'
        ]);
    }

    private void fetchFundRequests() {
        Map<Id, EMS_Fund_Request_gne__c> result = new Map<Id, EMS_Fund_Request_gne__c>([
                SELECT Id, Name, Status_gne__c, Requested_Amount_gne__c, Product_Indication_gne__c, OwnerId, Owner.Name, Required_By_Date_gne__c, RecordType.Name
                FROM EMS_Fund_Request_gne__c
                WHERE Status_gne__c = 'Submitted'
                AND Approver_gne__c = :UserInfo.getUserId()
        ]);

        fundingRequestsToApprove = result.values();

        workItemTargetIds.addAll(result.keySet());
    }

    private void fetchEvents() {
        Map<Id, EMS_Event__c> result = new Map<Id, EMS_Event__c>();

        if (EMS_Util.getUserRole() == 'MedOps') {
            result.putAll([
                    SELECT Id, Name, Overall_Status_gne__c, Event_Name_gne__c, Status_gne__c, Event_Requestor_gne__c, Event_Requestor_gne__r.Name, Event_Owner_gne__c, Event_Owner_gne__r.Name
                    FROM EMS_Event__c
                    WHERE (Approver_gne__c = :UserInfo.getUserId() AND (Status_gne__c = 'Pending Committee Review' OR Status_gne__c = 'Pending Approval'))
                    OR Status_gne__c = 'Pending Med Ops Review'
            ]);
        } else {
            result.putAll([
                    SELECT Id, Name, Overall_Status_gne__c, Event_Name_gne__c, Status_gne__c, Event_Requestor_gne__c, Event_Requestor_gne__r.Name, Event_Owner_gne__c, Event_Owner_gne__r.Name
                    FROM EMS_Event__c
                    WHERE Status_gne__c LIKE '%Pending%'
                    AND Status_gne__c != 'Pending Med Ops Review'
                    AND Approver_gne__c = :UserInfo.getUserId()
                    AND Pending_Budget_Approval_gne__c = false
            ]);
        }

        eventRequestsToApprove = result.values();

        workItemTargetIds.addAll(result.keySet());
    }

    private void fetchBudgetAllocations() {
        Map<Id, EMS_Budget_Allocation_gne__c> result = new Map<Id, EMS_Budget_Allocation_gne__c>([
                SELECT Id, Name, EMS_Event_gne__c, EMS_Event_gne__r.Name, EMS_Event_gne__r.Overall_Status_gne__c, EMS_Event_gne__r.Event_Name_gne__c, EMS_Event_gne__r.Status_gne__c, EMS_Event_gne__r.Event_Requestor_gne__c, EMS_Event_gne__r.Event_Requestor_gne__r.Name, EMS_Event_gne__r.Event_Owner_gne__c, EMS_Event_gne__r.Event_Owner_gne__r.Name, Allocated_Budget_gne__c
                FROM EMS_Budget_Allocation_gne__c
                WHERE Status_gne__c = 'Submitted'
                AND Approver_gne__c = :UserInfo.getUserId()
        ]);

        budgetAllocationRequestsToApprove = result.values();

        workItemTargetIds.addAll(result.keySet());
    }

    private void fetchApprovalWorkItems() {
        Map<Id, ProcessInstance> processInstanceMap = new Map<Id, ProcessInstance>([
                SELECT Id, TargetObject.Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, Actor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                WHERE (TargetObjectID IN :workItemTargetIds)
                ORDER BY CreatedDate DESC
        ]);

        for (ProcessInstance pi : processInstanceMap.values()) {
            for (ProcessInstanceWorkitem wi : pi.Workitems) {
                workItemsIdsByIds.put(pi.TargetObjectID, wi.Id);
            }
        }
    }

    /* Fund Request */
    private void createFundRequestsWrapperLiist() {
        itemsToApprove = new List<EMS_ItemToApproveWrapper>();
        for (EMS_Fund_Request_gne__c fr : fundingRequestsToApprove) {
            itemsToApprove.add(new EMS_ItemToApproveWrapper(fr, workItemsIdsByIds.get(fr.Id)));
        }
    }

    /* Events Approval */
    private void createEventsWrapperList() {
        eventsToApprove = new List<EMS_EventsToApproveWrapper>();
        for (EMS_Event__c er : eventRequestsToApprove) {
            eventsToApprove.add(new EMS_EventsToApproveWrapper(er, workItemsIdsByIds.get(er.Id)));
        }
    }

    /* Budget Allocations Approval */
    private void createBudgetAllocationsWrapperList() {
        budgetAllocationsToApprove = new List<EMS_BudgetAllocationToApproveWrapper>();
        for (EMS_Budget_Allocation_gne__c er : budgetAllocationRequestsToApprove) {
            budgetAllocationsToApprove.add(new EMS_BudgetAllocationToApproveWrapper(er, workItemsIdsByIds.get(er.Id)));
        }
    }

    @RemoteAction
    public static EMS_Remote_Response approveRejectRecallFundRequest(String action, String frId, String processInstanceWorkitemId, String comments) {
        return EMS_Fund_Request_Ext.approveRejectRecallFundRequest(action, frId, processInstanceWorkitemId, comments);
    }

    @RemoteAction
    public static EMS_Remote_Response approveRejectRecallBudgetAllocations(String action, List<String> baIds, List<String> processInstanceWorkitemIds, List<String> amounts, String comments) {
        return EMS_Event_Ext.approveRejectRecallBudgetAllocations(action, baIds, processInstanceWorkitemIds, amounts, comments);
    }

    @RemoteAction
    public static EMS_Remote_Response approveRejectRecallEvent(String action, String eventId, String processInstanceWorkitemId, String comments) {
        return EMS_Event_Ext.approveRejectRecallEvent(action, eventId, processInstanceWorkitemId, comments);
    }

    @remoteAction
    public static EMS_Event__c getEvent(Id eventId) {
        return [
                SELECT Id, Name, Status_gne__c, Event_Name_gne__c, Event_Type_gne__c, Event_Sub_Type_gne__c, Event_Requestor_gne__c, Event_Requestor_gne__r.Name, Event_Owner_gne__c, Event_Owner_gne__r.Name, Start_Date_gne__c, End_Date_gne__c, (select Id, Name from EMS_Budget_Allocations__r)
                FROM EMS_Event__c
                WHERE Id = :eventId
        ];
    }
}