public with sharing class EMS_BudgetAllocationToApproveWrapper extends EMS_Wrapper {

    public EMS_Budget_Allocation_gne__c budgetAllocation { get; set; }
    public String eventRequestNameLink { get; set; }
    public String eventRequestOwnerIdLink { get; set; }
    public String eventRequestRequestorIdLink { get; set; }
    public String approveRejectLink { get; set; }
    public Id workItemId { get; set; }

    public EMS_BudgetAllocationToApproveWrapper(EMS_Budget_Allocation_gne__c budgetAllocation, Id workItemId) {
        this.budgetAllocation = budgetAllocation;
        this.eventRequestNameLink = '/apex/EMS_Event_Layout?id=' + budgetAllocation.EMS_Event_gne__c;
        this.eventRequestOwnerIdLink = '/apex/EMS_User_Layout?id=' + budgetAllocation.EMS_Event_gne__r.Event_Owner_gne__c;
        this.eventRequestRequestorIdLink = '/apex/EMS_User_Layout?id=' + budgetAllocation.EMS_Event_gne__r.Event_Requestor_gne__c;
        this.approveRejectLink = '/apex/EMS_Approve_Reject_Budget_Allocation?id=' + budgetAllocation.Id + '&ProcessInstanceWorkitemId=' + workItemId + '&retURL=/apex/EMS_Home';
        this.workItemId = workItemId;
        ascending = true;
    }

    public override Integer compareTo(Object compareTo) {
        if (compareBy == null || compareBy == '') {
            return 0;
        } else if (!ascending) {
            return compareToDescending(compareTo);
        } else {
            return compareToAscending(compareTo);
        }
    }

    public Integer compareToAscending(Object compareTo) {
        EMS_BudgetAllocationToApproveWrapper otherBudgetAllocation = (EMS_BudgetAllocationToApproveWrapper) compareTo;
        if (compareBy == 'budgetAllocation.Name') {
            return budgetAllocation.Name.compareTo(otherBudgetAllocation.budgetAllocation.Name);
        } /*else if(compareBy == 'eventRequest.Owner.Name'){
            return eventRequest.Owner.Name.compareTo(eventToApprove.eventRequest.Owner.Name);
        } else if(compareBy == 'eventRequest.Status_gne__c'){
        	return eventRequest.Status_gne__c.compareTo(eventToApprove.eventRequest.Status_gne__c);
        }*/
        return -1;
    }

    public Integer compareToDescending(Object compareTo) {
        EMS_BudgetAllocationToApproveWrapper otherBudgetAllocation = (EMS_BudgetAllocationToApproveWrapper) compareTo;
        if (compareBy == 'budgetAllocation.Name') {
            return budgetAllocation.Name.compareTo(otherBudgetAllocation.budgetAllocation.Name) * (-1);
        } /*else if(compareBy == 'eventRequest.Owner.Name'){
            return eventRequest.Owner.Name.compareTo(eventToApprove.eventRequest.Owner.Name) *(-1);
        } else if(compareBy == 'eventRequest.Status_gne__c'){
            return eventRequest.Status_gne__c.compareTo(eventToApprove.eventRequest.Status_gne__c)*(-1);
        }*/
        return 1;
    }
}