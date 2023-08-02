public with sharing class EMS_Event_Helper {
    public static final List<String> COST_CENTER_TYPES = new List<String>{
            'commercial',
            'medical',
            'corporate'
    };

    /*Sending for Approval methods*/
    public static EMS_Event__c allBudgetApproved(EMS_Event__c event, String budgetLabel) {
        event.Status_gne__c = budgetLabel;
        event.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Owner Approved Event').RecordTypeId;
        event.Pending_Budget_Approval_gne__c = false;
        update event;
        return event;
    }

    public static EMS_Event__c notAllBudgetApproved(EMS_Event__c event, String budgetLabel) {
        event.Status_gne__c = budgetLabel;
        event.Pending_Budget_Approval_gne__c = true;
        event.RecordTypeId = Schema.SObjectType.EMS_Event__c.RecordTypeInfosByName.get('EMS Locked Event').RecordTypeId;
        event.Submitted_Date_gne__c = System.today();
        event.Submitted_By_gne__c = UserInfo.getUserId();
        update event;
        return event;
    }

    public static EMS_Event__c budgetApprovalNotRequired(EMS_Event__c event) {
        event.Submitted_Date_gne__c = System.today();
        event.Submitted_By_gne__c = UserInfo.getUserId();
        update event;

        Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
        request.setObjectId(event.id);
        Approval.ProcessResult result = Approval.process(request);

        return event;
    }
}