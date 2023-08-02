public with sharing class EMS_EventsToApproveWrapper extends EMS_Wrapper {
    public EMS_Event__c eventRequest { get; set; }
    public String eventRequestNameLink { get; set; }
    public String eventRequestOwnerIdLink { get; set; }
    public String eventRequestRequestorIdLink { get; set; }
    public String approveRejectLink { get; set; }
    public Id workItemId { get; set; }

    public EMS_EventsToApproveWrapper(EMS_Event__c eventRequest, Id workItemId) {
        this.eventRequest = eventRequest;
        this.eventRequestNameLink = '/apex/EMS_Event_Layout?id=' + eventRequest.Id;
        this.eventRequestOwnerIdLink = '/apex/EMS_User_Layout?id=' + eventRequest.Event_Owner_gne__c;
        this.eventRequestRequestorIdLink = '/apex/EMS_User_Layout?id=' + eventRequest.Event_Requestor_gne__c;
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
        EMS_EventsToApproveWrapper eventToApprove = (EMS_EventsToApproveWrapper) compareTo;
        if (compareBy == 'eventRequest.Name') {
            return eventRequest.Name.compareTo(eventToApprove.eventRequest.Name);
        } else if (compareBy == 'eventRequest.Owner.Name') {
            return eventRequest.Owner.Name.compareTo(eventToApprove.eventRequest.Owner.Name);
        } else if (compareBy == 'eventRequest.Status_gne__c') {
            return eventRequest.Status_gne__c.compareTo(eventToApprove.eventRequest.Status_gne__c);
        }
        return -1;
    }

    public Integer compareToDescending(Object compareTo) {
        EMS_EventsToApproveWrapper eventToApprove = (EMS_EventsToApproveWrapper) compareTo;
        if (compareBy == 'eventRequest.Name') {
            return eventRequest.Name.compareTo(eventToApprove.eventRequest.Name) * (-1);
        } else if (compareBy == 'eventRequest.Owner.Name') {
            return eventRequest.Owner.Name.compareTo(eventToApprove.eventRequest.Owner.Name) * (-1);
        } else if (compareBy == 'eventRequest.Status_gne__c') {
            return eventRequest.Status_gne__c.compareTo(eventToApprove.eventRequest.Status_gne__c) * (-1);
        }
        return 1;
    }
}