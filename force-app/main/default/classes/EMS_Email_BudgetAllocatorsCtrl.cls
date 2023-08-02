public with sharing class EMS_Email_BudgetAllocatorsCtrl {
    public Id eventId { get; set; }

    public EMS_Email_BudgetAllocatorsCtrl() {
    }

    public List<EMS_Budget_Allocation_gne__c> gbudgets {
        get {
            return [SELECT Id, Budget_Owner_gne__c, Budget_Owner_gne__r.Name FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :eventId];
        }
    }
}