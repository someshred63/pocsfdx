public with sharing class EMS_Fund_Request_Approval_Process_Ext {

    public List<ApprovalItem> approvalItemList { get; set; }
    public Boolean canRecall { get; set; }
    public EMS_Fund_Request_gne__c record { get; set; }
    private Id ProcessInstanceWorkitemId;

    public EMS_Fund_Request_Approval_Process_Ext(ApexPages.StandardController controller) {
        record = (EMS_Fund_Request_gne__c) controller.getRecord();
        canRecall = false;
        fetchApprovalProcessItems();
    }

    private void fetchApprovalProcessItems() {
        approvalItemList = new List<ApprovalItem>();
        List<ProcessInstance> processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                where TargetObject.Id = :record.Id
                ORDER BY CreatedDate DESC
        ];

        for (ProcessInstance pi : processInstanceList) {
            addApprovalItemsFromProcessInstance(pi);
        }
    }

    private void addApprovalItemsFromProcessInstance(ProcessInstance pi) {
        if (pi.Workitems != null && pi.Workitems.size() != 0) {
            for (ProcessInstanceWorkitem piw : pi.Workitems) {
                ApprovalItem ai = new ApprovalItem();
                ai.step = null;
                ai.workitem = piw;
                ProcessInstanceWorkitemId = piw.Id; //Only one item can be in pending status.
                canRecall = (record.OwnerId == UserInfo.getUserId() || EMS_Util.isAdmin()) ? true : false;
                approvalItemList.add(ai);
            }
        }
        if (pi.Steps != null && pi.Steps.size() != 0) {
            for (ProcessInstanceStep pis : pi.Steps) {
                ApprovalItem ai = new ApprovalItem();
                ai.step = pis;
                ai.workitem = null;
                approvalItemList.add(ai);
            }
        }
    }

    public void submitForApproval() {
        try {
            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(record.id);
            Approval.ProcessResult result = Approval.process(request);
            fetchApprovalProcessItems();
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured while submitting the fund request: ' + ex.getMessage()));
        }
    }

    public PageReference approvalOrReject() {
        PageReference ref = new PageReference('/apex/EMS_Approve_Reject_FR?Id=' + record.Id + '&ProcessInstanceWorkitemId=' + ProcessInstanceWorkitemId + '&recall=false');
        ref.setRedirect(true);
        return ref;
    }

    public PageReference recallItem() {
        PageReference ref = new PageReference('/apex/EMS_Approve_Reject_FR?Id=' + record.Id + '&ProcessInstanceWorkitemId=' + ProcessInstanceWorkitemId + '&recall=true');
        ref.setRedirect(true);
        return ref;
    }

    public boolean getCanApprove() {
        if ((record.Approver_gne__c == UserInfo.getUserId()) || EMS_Util.isAdmin()) {
            return true;
        } else {
            return false;
        }
    }

    public boolean getCanSubmit() {
        if ((record.OwnerId == UserInfo.getUserId()) || EMS_Util.isAdmin()) {
            return true;
        } else {
            return false;
        }
    }

    public class ApprovalItem {
        public ProcessInstanceStep step { get; set; }
        public ProcessInstanceWorkitem workitem { get; set; }
        public String getStatus() {
            if (step == null) {
                return 'Pending';
            } else if (step.StepStatus == 'Started') {
                return 'Approval Request Submitted';
            } else if (step.StepStatus == 'Removed') {
                return 'Recalled';
            } else {
                return step.StepStatus;
            }
        }
        public String getStyle() {
            if (step == null) {
                return 'Pending';
            } else {
                return step.StepStatus;
            }
        }
    }
}