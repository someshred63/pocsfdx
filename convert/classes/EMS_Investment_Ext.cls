global with sharing class EMS_Investment_Ext {
    private EMS_Event__c event;

    public EMS_Investment_Ext(ApexPages.standardController stdController) {
        event = (EMS_Event__c) stdController.getRecord();
    }

    public String getEventId() {
        return event.Id;
    }

    public Boolean getCanEdit() {
        return EMS_Access.isInvestmentEditable(event);
    }

    public String getHCOS() {
        return JSON.serialize([SELECT Id, HCO_gne__c, HCO_gne__r.Name FROM EMS_Investment_gne__c WHERE EMS_Event_gne__c = :event.Id]);
    }

    @RemoteAction
    public static EMS_Remote_Response addHCOs(Id eventID, List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> hcos) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        try {
            List<EMS_Investment_gne__c> investments = new List<EMS_Investment_gne__c>();
            for (GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper hco :hcos) {
                investments.add(new EMS_Investment_gne__c(EMS_Event_gne__c = eventID, HCO_gne__c = hco.accountId));
            }
            insert investments;
            response.isSuccess = true;
            response.objectList1 = investments;
        } catch (Exception e) {
            response.addError(e.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response removeInvestment(Id investmentID) {
    	EMS_Remote_Response response = new EMS_Remote_Response();
        try {
            delete [SELECT Id FROM EMS_Investment_gne__c WHERE Id = :investmentID];
            response.isSuccess = true;
        } catch (Exception e) {
        	response.isSuccess = false;
            response.addError(e.getMessage());
        }
        return response;
    }

    @RemoteAction
    global static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> searchHCOs(String searchString, Integer recordLimit, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean myTargetsOnly, Id callAccountId) {
        return GNE_SFA2_SearchAccounts_Controller.searchHCOs(searchString, recordLimit, myTargetsOnly);
    }

    @RemoteAction
    global static List<EMS_SearchUtils.AccountWrapper> getAffiliatedHCOs(List<Id> selectedHCOIds) {
        return EMS_SearchUtils.searchAffiliatedHCOs(selectedHCOIds, 100);
    }

}