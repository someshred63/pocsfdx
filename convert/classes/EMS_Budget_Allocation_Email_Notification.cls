public without sharing class EMS_Budget_Allocation_Email_Notification {

    public static void onAfterInsertUpdate(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        notifyBudgetOwner(triggerOld, triggerNew);

        EMS_Email.send();
    }

    private static void notifyBudgetOwner(Map<Id, EMS_Budget_Allocation_gne__c> triggerOld, Map<Id, EMS_Budget_Allocation_gne__c> triggerNew) {
        for (Id baID :triggerNew.keySet()) {
            Boolean diffBudgetOwner = (String.valueOf(triggerNew.get(baID).Budget_Owner_gne__c) != UserInfo.getUserId());
            if (!diffBudgetOwner) {
                continue;
            }

            Boolean isNewBudget = (triggerOld == null || !triggerOld.containsKey(baID));
            Boolean budgetHasChanged = (isNewBudget) ? false : (triggerOld.get(baID).Allocated_Budget_gne__c != triggerNew.get(baID).Allocated_Budget_gne__c);
            if (isNewBudget || budgetHasChanged) {
                EMS_Email.prepareSingleEmail('EMS_Budget_Allocation_Notification', baID, triggerNew.get(baID).Budget_Owner_gne__c);
            }
        }
    }

}