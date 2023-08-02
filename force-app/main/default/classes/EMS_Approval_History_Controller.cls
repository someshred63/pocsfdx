public without sharing class EMS_Approval_History_Controller {

    public List<ApprovalItem> approvalItemList { get; set; }
    public List<ProcessInstance> processInstanceList { get; set; }
    public List<sObject> records {
        get;
        set {
            records = value;
            fetchApprovalProcessItems();
        }
    }

    private Map<Id, sObject> recordsMap = new Map<Id, sObject>();
    private Id ProcessInstanceWorkitemId;

    public EMS_Approval_History_Controller() {
        approvalItemList = new List<ApprovalItem>();
    }

    private void fetchApprovalProcessItems() {
        if (processInstanceList == null || processInstanceList.isEmpty()) {
            recordsMap = new Map<Id, SObject>(records);

            processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, TargetObject.RecordType.Name, (SELECT Id, CreatedDate, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC, Id DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC, Id DESC)
                FROM ProcessInstance
                WHERE TargetObjectId IN :recordsMap.keySet()
                ORDER BY CreatedDate DESC, Id DESC
            ];
        }

        for (ProcessInstance pi : processInstanceList) {
            if (recordsMap.containsKey(pi.TargetObjectId)) {
                addApprovalItemsFromProcessInstance(pi);
            }
        }
    }

    private void addApprovalItemsFromProcessInstance(ProcessInstance pi) {
        if (pi.Workitems != null && pi.Workitems.size() != 0) {
            for (ProcessInstanceWorkitem piw : pi.Workitems) {
                ApprovalItem ai = new ApprovalItem();
                ai.actionDate = piw.CreatedDate.format('M/d/yyyy hh:mm a', UserInfo.getTimeZone().getID());
                ai.assignedTo = piw.OriginalActor.Name;
                ai.actualApprover = piw.Actor.Name;
                ai.overallStatus = 'Pending';
                ai.status = 'Pending';
                ai.record = recordsMap.get(pi.TargetObjectId);
                ai.objectName = pi.TargetObjectId.getSObjectType().getDescribe().getName();

                ai.processInstanceWorkitemId = piw.Id; //Only one item can be in pending status.
                approvalItemList.add(ai);
            }
        }
        String medOpsReviewRecalledPrefix = 'Med Ops Review Recalled: ';
        if (pi.Steps != null && pi.Steps.size() != 0) {
            for (ProcessInstanceStep pis : pi.Steps) {
                ApprovalItem ai = new ApprovalItem();
                ai.actionDate = pis.CreatedDate.format('M/d/yyyy hh:mm a', UserInfo.getTimeZone().getID());
                if (pis.StepStatus == 'Started') {
                    ai.status = 'Submitted';
                } else if (pis.StepStatus == 'Removed') {
                    ai.status = 'Recalled';
                } else if (pis.StepStatus == 'Rejected' && pis.Comments == 'User Delegation Change.') {
                    ai.status = 'Reassigned';
                } else if (pis.StepStatus == 'Rejected' && pis.Comments != null && pis.Comments.startsWith(medOpsReviewRecalledPrefix)) {
                    ai.status = 'Recalled';
                } else {
                    ai.status = pis.StepStatus;
                }

                if (pis.StepStatus == 'Started') {
                    ai.overallStatus = 'Pending';
                } else if (pis.StepStatus == 'Removed') {
                    ai.overallStatus = 'Recalled';
                } else if (pis.StepStatus == 'Rejected' && pis.Comments == 'User Delegation Change.') {
                    ai.overallStatus = 'Reassigned';
                } else if (pis.StepStatus == 'Rejected' && pis.Comments != null && pis.Comments.startsWith(medOpsReviewRecalledPrefix)) {
                    ai.overallStatus = 'Recalled';
                } else if (pis.StepStatus == 'Approved' && pi.TargetObject.RecordType.Name.containsIgnoreCase('transfer')) {
                    ai.overallStatus = 'Acknowledged';
                } else {
                    ai.overallStatus = pis.StepStatus;
                }

                ai.assignedTo = pis.OriginalActor.Name;
                ai.actualApprover = pis.Actor.Name;

                if (pis.StepStatus == 'Rejected' && pis.Comments != null && pis.Comments.startsWith(medOpsReviewRecalledPrefix)) {
                    ai.comments = pis.Comments.substring(medOpsReviewRecalledPrefix.length(), pis.Comments.length());
                } else {
                    ai.comments = pis.Comments;
                }
                ai.isStep = true;
                approvalItemList.add(ai);
            }
        }
    }

    public class ApprovalItem {
        public String actionDate { get; set; }
        public String status { get; set; }
        public String assignedTo { get; set; }
        public String actualApprover { get; set; }
        public String comments { get; set; }
        public String overallStatus { get; set; }
        public String objectName { get; set; }
        public sObject record { get; set; }
        public Boolean isStep { get; set; }
        public Id processInstanceWorkitemId { get; set; }
    }
}