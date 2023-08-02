public with sharing class EMS_Assignment_Error_Controller extends List_View_Base_Controller {
    public List_View_Base_Controller thisController { get; set; }

    public EMS_Assignment_Error_Controller() {
        super(EMS_Assignment_Error_gne__c.sObjectType.getDescribe().getName());
        thisController = this;
    }

    public PageReference ignoreFunction() {
        List<EMS_Assignment_Error_gne__c> assignmentErrorsToUpdate = new List<EMS_Assignment_Error_gne__c>();
        for (String id : getSelectedRecords()) {
            assignmentErrorsToUpdate.add(new EMS_Assignment_Error_gne__c(Id = id, Status_gne__c = 'Ignored'));
        }
        if (assignmentErrorsToUpdate.size() > 0) {
            update assignmentErrorsToUpdate;
        }
        return null;
    }

    public PageReference resolveFunction() {
        List<EMS_Assignment_Error_gne__c> assignmentErrorsToUpdate = new List<EMS_Assignment_Error_gne__c>();
        for (String id : getSelectedRecords()) {
            assignmentErrorsToUpdate.add(new EMS_Assignment_Error_gne__c(Id = id, Status_gne__c = 'Resolved'));
        }
        if (assignmentErrorsToUpdate.size() > 0) {
            update assignmentErrorsToUpdate;
        }
        return null;
    }
}