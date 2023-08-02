public without sharing class EMS_Approve_Reject_Budget_Allocation_Ext {

    public EMS_Event__c event { get; set; }
    public EMS_Budget_Allocation_gne__c budgetAllocation { get; set; }
    public Boolean recall { get; set; }
    public String eventId { get; set; }
    public Decimal approvedAmount { get; set; }
    public EMS_Budget_Allocation_gne__c budgetAllocationTemp { get; set; }

    private ApexPages.StandardController controller;
    private String processInstanceWorkitemId { get; set; } // ProcessInstanceWorkitem object id

    public EMS_Approve_Reject_Budget_Allocation_Ext(ApexPages.StandardController ctrl) {
        this.controller = ctrl;
        budgetAllocation = (EMS_Budget_Allocation_gne__c) controller.getRecord();
        eventId = budgetAllocation.EMS_Event_gne__c;
        processInstanceWorkitemId = System.currentPagereference().getParameters().get('ProcessInstanceWorkitemId');
        budgetAllocationTemp = new EMS_Budget_Allocation_gne__c();

        recall = (System.currentPagereference().getParameters().get('recall') == 'true') ? true : false;
    }

    public PageReference approveEvent() {
        Approval.ProcessWorkitemRequest request = constructApprovalRequest('Approve');
        Savepoint sp = Database.setSavepoint();
        try {
            budgetAllocation.Comments_gne__c = budgetAllocationTemp.Comments_gne__c;
            update budgetAllocation;

            Approval.ProcessResult result = Approval.process(request);
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception occured while approving the event: ' + ex.getMessage()));
            return null;
        }
        Pagereference pageRef = new Pagereference('/' + eventId);
        return pageRef;
    }

    public PageReference rejectEvent() {
        Approval.ProcessWorkitemRequest request = constructApprovalRequest('Reject');
        Savepoint sp = Database.setSavepoint();
        try {
            budgetAllocation.Comments_gne__c = budgetAllocationTemp.Comments_gne__c;
            update budgetAllocation;

            Approval.ProcessResult result = Approval.process(request);
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception occured while rejecting the event: ' + ex.getMessage()));
            return null;
        }
        Pagereference pageRef = new Pagereference('/' + eventId);
        return pageRef;
    }

    public PageReference recallEvent() {
        Approval.ProcessWorkitemRequest request = constructApprovalRequest('Removed');
        Savepoint sp = Database.setSavepoint();
        try {
            budgetAllocation.Comments_gne__c = budgetAllocationTemp.Comments_gne__c;
            update budgetAllocation;

            Approval.ProcessResult result = Approval.process(request);
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception occured while recalling the event: ' + ex.getMessage()));
            return null;
        }
        Pagereference pageRef = new Pagereference('/' + eventId);
        return pageRef;
    }

    public PageReference checkParams() {
        if (recall == false && (processInstanceWorkitemId == null || processInstanceWorkitemId == '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No processInstanceWorkitemId passed'));
        }
        if (eventId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Event passed'));
        }
        return null;
    }

    private Approval.ProcessWorkitemRequest constructApprovalRequest(String action) {
        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
        request.setComments(budgetAllocationTemp.Comments_gne__c);
        request.setAction(action);
        request.setWorkitemId(ProcessInstanceWorkitemId);
        return request;
    }
}