public with sharing class EMS_Remote_Response {

    //Standard Remote Response fields
    public Boolean isSuccess;
    public List<String> errorMessages;

    //Lists of SObjects returned by response
    public List<SObject> objectList1;
    public List<SObject> objectList2;

    //Map for userTerritories, used in Event_Ext
    public Map<String, List<SelectOption>> userTerritories;

    //Map for Ids hooked with their objects
    public Map<Id, List<Sobject>> customMapIDList;

    //Map used in Related_List_Component
    public Map<String, String> sucessMap;

    //Helper fields
    public SObject responseObject;
    public String message;
    public String recordId;

    public EMS_Event_Ext.ComplianceRecord acknowledgementStatement;
    public List<EMS_Event_Ext.ComplianceRecord> supportDocumentation;

    public EMS_Remote_Response() {
        errorMessages = new List<String>();

        isSuccess = true;
        message = '';
    }

    public EMS_Remote_Response(Boolean success, List<String> errors) {
        isSuccess = success;
        errorMessages = errors;

        message = '';
    }

    public EMS_Remote_Response(Boolean success, String error) {
        isSuccess = success;
        message = error;

        errorMessages = new List<String>();
    }

    public EMS_Remote_Response(Boolean success, String message, List<SObject> objectList) {
        isSuccess = success;
        message = message;
        objectList1 = objectList;
    }

    public void addError(String error) {
        isSuccess = false;
        errorMessages.add(error);
    }

    public void addErrors(List<Database.Error> errors) {
        for(Database.Error error : errors) {
            addError(error.getMessage());
        }
    }

    public void addSaveResult(Database.SaveResult saveResult, String successMessage) {
        if(saveResult.success) {
            addSuccessMessage(successMessage);
            recordId = saveResult.getId();
        } else {
            addErrors(saveResult.errors);
        }
    }

    public void addUpsertResult(Database.UpsertResult upsertResult, String successMessage) {
        if(upsertResult.success) {
            addSuccessMessage(successMessage);
            recordId = upsertResult.getId();
        } else {
            addErrors(upsertResult.errors);
        }
    }

    public void addDeleteResult(Database.DeleteResult deleteResult, String successMessage) {
        if(deleteResult.success) {
            addSuccessMessage(successMessage);
        } else {
            addErrors(deleteResult.errors);
        }
    }

    public void addSuccessMessage(String successMessage) {
        isSuccess = true;
        message = successMessage;
    }
}