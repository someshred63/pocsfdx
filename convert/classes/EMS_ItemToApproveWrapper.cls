public with sharing class EMS_ItemToApproveWrapper extends EMS_Wrapper {
    public EMS_Fund_Request_gne__c fundRequest { get; set; }
    public String fundRequestNameLink { get; set; }
    public String fundRequestOwnerIdLink { get; set; }
    public String requiredByDateValue { get; set; }
    public String requestedAmountValue { get; set; }
    public String approveRejectLink { get; set; }
    public Id workItemId { get; set; }

    public EMS_ItemToApproveWrapper(EMS_Fund_Request_gne__c fundRequest, Id workItemId) {
        this.fundRequest = fundRequest;
        this.fundRequestNameLink = '/apex/EMS_Fund_Request_Layout?id=' + fundRequest.Id;
        this.fundRequestOwnerIdLink = '/apex/EMS_User_Layout?id=' + fundRequest.OwnerId;
        this.requiredByDateValue = fundRequest.Required_By_Date_gne__c.format();
        this.requestedAmountValue = fundRequest.Requested_Amount_gne__c >= 0 ? '$' + String.valueOf(fundRequest.Requested_Amount_gne__c) : '$(' + String.valueOf(fundRequest.Requested_Amount_gne__c) + ')';
        this.approveRejectLink = '/apex/EMS_Approve_Reject_FR?id=' + fundRequest.Id + '&ProcessInstanceWorkitemId=' + workItemId + '&retURL=/apex/EMS_Home';
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
        EMS_ItemToApproveWrapper itemToApprove = (EMS_ItemToApproveWrapper) compareTo;
        if (compareBy == 'fundRequest.Name') {
            return fundRequest.Name.compareTo(itemToApprove.fundRequest.Name);
        } else if (compareBy == 'fundRequest.Owner.Name') {
            return fundRequest.Owner.Name.compareTo(itemToApprove.fundRequest.Owner.Name);
        } else if (compareBy == 'requestedAmountValue') {
            if (itemToApprove.fundRequest.Requested_Amount_gne__c == this.fundRequest.Requested_Amount_gne__c) return 0;
            if (itemToApprove.fundRequest.Requested_Amount_gne__c > this.fundRequest.Requested_Amount_gne__c) return 1;
        } else if (compareBy == 'fundRequest.Status_gne__c') {
            return fundRequest.Status_gne__c.compareTo(itemToApprove.fundRequest.Status_gne__c);
        } else if (compareBy == 'fundRequest.Product_Indication_gne__c') {
            return fundRequest.Product_Indication_gne__c.compareTo(itemToApprove.fundRequest.Product_Indication_gne__c);
        } else if (compareBy == 'requiredByDateValue') {
            if (itemToApprove.fundRequest.Required_By_Date_gne__c == this.fundRequest.Required_By_Date_gne__c) return 0;
            if (itemToApprove.fundRequest.Required_By_Date_gne__c > this.fundRequest.Required_By_Date_gne__c) return 1;
        }
        return -1;
    }

    public Integer compareToDescending(Object compareTo) {
        EMS_ItemToApproveWrapper itemToApprove = (EMS_ItemToApproveWrapper) compareTo;
        if (compareBy == 'fundRequest.Name') {
            return fundRequest.Name.compareTo(itemToApprove.fundRequest.Name) * (-1);
        } else if (compareBy == 'fundRequest.Owner.Name') {
            return fundRequest.Owner.Name.compareTo(itemToApprove.fundRequest.Owner.Name) * (-1);
        } else if (compareBy == 'requestedAmountValue') {
            if (itemToApprove.fundRequest.Requested_Amount_gne__c == this.fundRequest.Requested_Amount_gne__c) return 0;
            if (itemToApprove.fundRequest.Requested_Amount_gne__c > this.fundRequest.Requested_Amount_gne__c) return -1;
        } else if (compareBy == 'fundRequest.Status_gne__c') {
            return fundRequest.Status_gne__c.compareTo(itemToApprove.fundRequest.Status_gne__c) * (-1);
        } else if (compareBy == 'fundRequest.Product_Indication_gne__c') {
            return fundRequest.Product_Indication_gne__c.compareTo(itemToApprove.fundRequest.Product_Indication_gne__c) * (-1);
        } else if (compareBy == 'requiredByDateValue') {
            if (itemToApprove.fundRequest.Required_By_Date_gne__c == this.fundRequest.Required_By_Date_gne__c) return 0;
            if (itemToApprove.fundRequest.Required_By_Date_gne__c > this.fundRequest.Required_By_Date_gne__c) return -1;
        }
        return 1;
    }
}