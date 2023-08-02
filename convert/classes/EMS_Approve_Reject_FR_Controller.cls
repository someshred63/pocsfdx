public without sharing class EMS_Approve_Reject_FR_Controller {

    public EMS_Fund_Request_gne__c fundRequest { get; set; }
    private ApexPages.StandardController controller;
    public String suggestionRemarks { get; set; }
    public Boolean recall { get; set; }

    private String fundRequestId { get; set; }
    private String processInstanceWorkitemId { get; set; }

    public Boolean renderProductBudget {
        get {
            return regionAllocation;
        }
    }

    public Boolean renderRegionBudget {
        get {
            return renderTargetRegionBudget || regionAllocation || territoryAllocation;
        }
    }

    public Boolean renderTerritoryBudget {
        get {
            return renderTargetTerritoryBudget || territoryAllocation;
        }
    }

    public Boolean renderTargetRegionBudget {
        get {
            return fundRequest.Record_Type_Name_gne__c == EMS_Consts.RT_TRANSFER_REGION_FUNDS;
        }
    }

    public Boolean renderTargetTerritoryBudget {
        get {
            return fundRequest.Record_Type_Name_gne__c == EMS_Consts.RT_TRANSFER_TERRITORY_FUNDS;
        }
    }

    public Boolean territoryAllocation {
        get {
            return fundRequest.Record_Type_Name_gne__c.containsIgnoreCase('territory')
                    && fundRequest.Record_Type_Name_gne__c.containsIgnoreCase('allocation');
        }
    }

    public Boolean regionAllocation {
        get {
            return fundRequest.Record_Type_Name_gne__c.containsIgnoreCase('region')
                    && fundRequest.Record_Type_Name_gne__c.containsIgnoreCase('allocation');
        }
    }

    public EMS_Approve_Reject_FR_Controller(ApexPages.StandardController ctrl) {
        ApexPages.Message pageMsg;
        this.controller = ctrl;
        if (!Test.isRunningTest()) {
            controller.addFields(new List<String>{
                    'Id', 'OwnerId', 'Record_Type_Name_gne__c', 'lastModifiedById', 'Status_gne__c', 'Required_By_Date_gne__c', 'Product_Indication_gne__c', 'Related_Territory_Budget_gne__c', 'Related_Region_Budget_gne__c', 'Related_Product_Budget_gne__c', 'Region_Code_gne__c', 'Reason_gne__c', 'Assigned_To_gne__c', 'Approver_gne__c', 'Approval_Rejection_Date_gne__c', 'Approval_Rejection_Comments_gne__c', 'Name', 'Requested_Amount_gne__c', 'createdById'
            });
        }
        fundRequest = (EMS_Fund_Request_gne__c) controller.getRecord();
        fundRequest.Approval_Rejection_Date_gne__c = Datetime.now();
        fundRequestId = System.currentPagereference().getParameters().get('id');
        recall = (System.currentPagereference().getParameters().get('recall') == 'true') ? true : false;
        processInstanceWorkitemId = System.currentPagereference().getParameters().get('ProcessInstanceWorkitemId');
    }

    public String approveButtonLabel {
        get {
            return fundRequest.Record_Type_Name_gne__c.containsIgnoreCase('transfer') ? 'Acknowledge' : 'Approve';
        }
    }

    public PageReference approveFundRequest() {
        Approval.ProcessWorkitemRequest request = constructApprovalRequest('Approve');
        try {
            fundRequest.Approval_Rejection_Comments_gne__c = suggestionRemarks;
            update fundRequest;

            Approval.ProcessResult result = Approval.process(request);
        } catch (Exception e) {
            return null;
        }
        Pagereference pageRef = new Pagereference('/' + fundRequest.id);
        return pageRef;
    }

    public PageReference rejectFundRequest() {
        Approval.ProcessWorkitemRequest request = constructApprovalRequest('Reject');
        try {
            fundRequest.Approval_Rejection_Comments_gne__c = suggestionRemarks;
            update fundRequest;

            Approval.ProcessResult result = Approval.process(request);
        } catch (Exception e) {
            return null;
        }
        Pagereference pageRef = new Pagereference('/' + fundRequest.id);
        return pageRef;
    }

    public PageReference recallFundRequest() {
        Approval.ProcessWorkitemRequest request = constructApprovalRequest('Removed');
        try {
            fundRequest.Approval_Rejection_Comments_gne__c = suggestionRemarks;
            update fundRequest;

            Approval.ProcessResult result = Approval.process(request);
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        Pagereference pageRef = new Pagereference('/' + fundRequest.id);
        return pageRef;
    }

    public PageReference checkParams() {
        // checks parameters and conditions just after constructor and before page loading
        Pagereference pageRef = null;
        if (recall == false && (processInstanceWorkitemId == null || processInstanceWorkitemId == '')) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No processInstanceWorkitemId passed'));
        }
        if (fundRequestId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'No Fund Request passed'));
        }
        return pageRef;
    }

    private Approval.ProcessWorkitemRequest constructApprovalRequest(String action) {
        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
        request.setComments(suggestionRemarks);
        request.setAction(action);
        request.setWorkitemId(ProcessInstanceWorkitemId);
        return request;
    }

}