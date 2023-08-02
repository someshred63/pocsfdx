public without sharing class EMS_Event_Watchers_Ext {
    public EMS_Event__c event { get; set; }

    public EMS_Event_Watchers_Ext(ApexPages.standardController stdController) {
        event = (EMS_Event__c) stdController.getRecord();
    }

    public String getWatchers() {
        return JSON.serialize([SELECT User_gne__c, User_gne__r.Name FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c = :event.Id AND Is_Watcher_gne__c = true ORDER BY CreatedDate ASC]);
    }

    public Boolean getIsEMSCanadaUser() {
        return (EMS_Util.getUserApplication() == 'EMS-Canada');
    }

    public Boolean getCanEdit() {
    	List<EMS_Budget_Allocation_gne__c> budgetAllocations = [SELECT Id, Name, Cost_Center_gne__c, Cost_Center_Type_gne__c, Percentage_Contribution_gne__c, Product_Indication_gne__c, Allocated_Budget_gne__c, Approver_gne__c, Budget_Owner_gne__c, Budget_Owner_gne__r.Name, Status_gne__c, Submitted_By_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :event.Id];
        return EMS_Access.isWatcherEditable(event, budgetAllocations);
    }

    @RemoteAction
    public static List<EMS_SearchUtils.AccountWrapper> searchEmployees(String searchString, Boolean allAccounts, Boolean onlyPersonAccounts, Boolean myTargetsOnly, Boolean tieredAccountsOnly) {
        return EMS_SearchUtils.searchEmployees(searchString, 50, 'EMS-Canada');
    }

    @RemoteAction
    public static EMS_Remote_Response removeWatcher(Id watcherID) {
    	EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            delete [SELECT Id FROM EMS_Roche_Attendee_gne__c WHERE Id = :watcherID];
            response.isSuccess = true;
        } catch (Exception e) {
            response.addError(e.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response saveWatchers(Id eventId, String eventWatchersParam) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        try {
            List<EMS_Roche_Attendee_gne__c> watchers = (List<EMS_Roche_Attendee_gne__c>) JSON.deserialize(eventWatchersParam, List<EMS_Roche_Attendee_gne__c>.class);
            for (EMS_Roche_Attendee_gne__c watcher : watchers) {
                watcher.EMS_Event_gne__c = eventId;
                watcher.Is_Watcher_gne__c = true;
            }
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            insert watchers;
            response.isSuccess = true;
            response.objectList1 = watchers;
        } catch (DMLException e) {
            // Display one error which is longer than others instead of many, because Message Area must contain only one row
            for (Integer i = 0; i < e.getNumDml(); i++) {
               	response.addError(e.getDmlMessage(i));
            }
        } catch (Exception e) {
            response.addError(e.getMessage());
        }
        return response;
    }

}