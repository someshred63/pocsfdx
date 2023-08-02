/**
 * Created by GFRS Dev Team on 27.06.2018.
 */

public with sharing class GFRS_BudgetExceededController {

    public Id requestId { get {return ApexPages.currentPage().getParameters().get('id');} private set; }
    public Boolean isHybridOrg {
        get {
            String org = ApexPages.currentPage().getParameters().get('org');
            if (org == 'hybrid') return true;
            return false;
        }
        private set;
    }
    public GFRS_Funding_Request__c request { get; private set; }
    public String message { get; set; }
    public Boolean renderPageBlock { get; set; }

    public GFRS_BudgetExceededController(ApexPages.StandardController standardController) {
        try {
            renderPageBlock = true;
            if (String.isNotBlank(requestId)) {
                List<GFRS_Funding_Request__c> requests = [SELECT Id, Name, Acknowledge_Current_Revenue_33__c, Approved_Amount__c, Approval_Reason__c FROM GFRS_Funding_Request__c WHERE Id = :requestId LIMIT 1];
                request = (requests.size() == 1) ? requests.get(0) : null;
                message = parseMessage(isHybridOrg, request.Id);
            } else {
                renderPageBlock = false;
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private String parseMessage(Boolean isHybridOrg, String requestId) {
        String outputErrorMessage = System.Label.gFRS_ExceedApprovalAmountError;
        outputErrorMessage = outputErrorMessage.replace('{!ID}', requestId);
        outputErrorMessage = outputErrorMessage.replace('{!BudgetOrRevenue1}', isHybridOrg ? 'fiscal revenue' : 'budget');
        outputErrorMessage = outputErrorMessage.replace('{!BudgetOrRevenue2}', isHybridOrg ? 'revenue' : 'annual budget');
        return outputErrorMessage.replaceAll('<[^>]*>', '').replace('Click HERE to lower ', 'Lower ');
    }

    public PageReference back() {
        PageReference pageRef = new PageReference('/' + request.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference saveChanges() {
        try {
            update request;
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return null;
        }
        return back();
    }
}