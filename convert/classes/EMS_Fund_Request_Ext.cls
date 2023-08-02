public without sharing class EMS_Fund_Request_Ext extends EMS_DynamicVFLoader {

    public EMS_Fund_Request_gne__c fundRequest { get; set; }
    public Id processInstanceWorkitemId { get; set; }

    private Id submittedBy;
    public List<sObject> fundRequests { get; set; }

    public EMS_Fund_Request_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Fund_Request_Layout');
        fundRequest = (EMS_Fund_Request_gne__c) myObject;
        fundRequests = new List<sObject>{
                myObject
        };
        fetchApprovalProcessItems();
    }

    private void fetchApprovalProcessItems() {
        List<ProcessInstance> processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, CreatedById, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                WHERE TargetObject.Id = :fundRequest.Id
                ORDER BY CreatedDate DESC
        ];

        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    submittedBy = piw.CreatedById;
                    processInstanceWorkitemId = piw.Id;
                }
            }
        }
    }

    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/EMS_Fund_Request_Edit_Create_Layout?id=' + fundRequest.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public boolean getCanSubmit() {
        if (fundRequest.Status_gne__c != 'Rejected' && fundRequest.Status_gne__c != 'Submitted' && fundRequest.Status_gne__c != 'Approved' && (fundRequest.OwnerId == UserInfo.getUserId() || EMS_Util.isAdmin())) {
            return true;
        } else {
            return false;
        }
    }

    public boolean getCanRecall() {
        return fundRequest.Status_gne__c == 'Submitted' && (submittedBy == UserInfo.getUserId() || EMS_Util.isAdmin());
    }

    public boolean getCanApprove() {
        return fundRequest.Status_gne__c == 'Submitted' && (fundRequest.Approver_gne__c == UserInfo.getUserId() || EMS_Util.isAdmin());
    }

    public boolean getCanResubmit() {
        return fundRequest.Status_gne__c == 'Rejected' && (fundRequest.OwnerId == UserInfo.getUserId() || EMS_Util.isAdmin());
    }

    public boolean getCanEdit() {
        if (EMS_Util.isReadOnly()) {
            return false;
        }
        return fundRequest.Status_gne__c != 'Submitted' && fundRequest.Status_gne__c != 'Rejected' && fundRequest.Status_gne__c != 'Approved';
    }

    public boolean getCanDelete() {
        return EMS_Util.isAdmin();
    }

    public PageReference recallItem() {
        PageReference ref = new PageReference('/apex/EMS_Approve_Reject_FR?Id=' + fundRequest.Id + '&ProcessInstanceWorkitemId=' + processInstanceWorkitemId + '&recall=true');
        ref.setRedirect(true);
        return ref;
    }

    public PageReference submitForApproval() {
        System.Savepoint initialState = Database.setSavepoint();
        try {
            pagePositiveMessage = null;
            fundRequest.Submitted_By_gne__c = UserInfo.getUserId();
            update fundRequest;
            pagePositiveMessage = 'Fund request was submitted successfully';

            Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
            request.setObjectId(fundRequest.id);
            Approval.ProcessResult result = Approval.process(request);
            fetchApprovalProcessItems();
        } catch (Exception ex) {
            Database.rollback(initialState);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured while submitting the fund request: ' + ex.getMessage()));
        }
        init();
        fundRequest = (EMS_Fund_Request_gne__c) myObject;
        return null;
    }

    public PageReference resubmit() {
        PageReference pref = new PageReference('/apex/EMS_Fund_Request_Edit_Create_Layout?isResubmit=true&resubmitId=' + fundRequest.Id);
        pref.setRedirect(true);

        return pref;
    }

    @RemoteAction
    public static EMS_Remote_Response approveRejectRecallFundRequest(String action, String frId, String processInstanceWorkitemId, String comments) {
        EMS_Remote_Response response = new EMS_Remote_Response();

        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
        request.setComments(comments);
        request.setAction(action);
        request.setWorkitemId(processInstanceWorkitemId);

        Savepoint sp = Database.setSavepoint();
        try {
            EMS_Fund_Request_gne__c fr = new EMS_Fund_Request_gne__c(Id = frId);
            fr.Approval_Rejection_Comments_gne__c = comments;
            update fr;

            Approval.ProcessResult result = Approval.process(request);
            response.isSuccess = true;
        } catch (Exception ex) {
            Database.rollback(sp);
            response.isSuccess = false;
            response.addError(ex.getMessage());
        }

        return response;
    }
}