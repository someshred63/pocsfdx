public without sharing class EMS_Expense_Child_Record_Updates {

    private static void increaseTotalExpensesAmount(List<EMS_Expense_gne__c> triggerNew) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Expense_gne__c exp : triggerNew) {
            eventIds.add(exp.EMS_Event_gne__c);
        }

        if (!System.isFuture() && !System.isBatch() && !Test.isRunningTest()) {
            EMS_Budget_Allocation_Child_Rec_Update.recalculateBudgetDeductionsFuture(eventIds);
        }
    }

    private static void decreaseTotalExpensesAmount(List<EMS_Expense_gne__c> triggerOld) {
        Set<Id> eventIds = new Set<Id>();
        for (EMS_Expense_gne__c exp : triggerOld) {
            eventIds.add(exp.EMS_Event_gne__c);
        }

        if (!System.isFuture() && !System.isBatch() && !Test.isRunningTest()) {
            EMS_Budget_Allocation_Child_Rec_Update.recalculateBudgetDeductionsFuture(eventIds);
        }
    }

    private static void updateTotalExpensesAmount(Map<Id, EMS_Expense_gne__c> triggerOld, Map<Id, EMS_Expense_gne__c> triggerNew) {
        Map<Id, List<EMS_Expense_gne__c>> eventToExpensesMap = new Map<Id, List<EMS_Expense_gne__c>>();
        Set<Id> eventIds = new Set<Id>();

        for (EMS_Expense_gne__c expense : triggerNew.values()) {
            eventIds.add(expense.EMS_Event_gne__c);
        }

        for (EMS_Expense_gne__c expense : triggerOld.values()) {
            eventIds.add(expense.EMS_Event_gne__c);
        }

        if (!System.isFuture() && !System.isBatch() && !Test.isRunningTest()) {
            EMS_Budget_Allocation_Child_Rec_Update.recalculateBudgetDeductionsFuture(eventIds);
        }
    }

    private static void changeEventTotalExpenseValue(Map<Id, EMS_Expense_gne__c> expensesOld, Map<Id, EMS_Expense_gne__c> expensesNew) {
        Set<String> relatedEventIDs = new Set<String>();
        if (expensesOld == null) {
            for (EMS_Expense_gne__c exp: expensesNew.values()) {
                relatedEventIDs.add(exp.EMS_Event_gne__c);
            }
        }

        if (expensesNew == null) {
            //delete
            for (EMS_Expense_gne__c exp: expensesOld.values()) {
                relatedEventIDs.add(exp.EMS_Event_gne__c);
            }
        }

        if (expensesOld != null && expensesNew != null) {
            List<EMS_Expense_gne__c> changedExpenses = new List<EMS_Expense_gne__c>();
            for (EMS_Expense_gne__c updExpsense : expensesNew.values()) {
                Decimal oldCountryExpenseAmount = expensesOld.get(updExpsense.Id).Country_Expense_Amount_gne__c;
                String oldEventRelation = (String) expensesOld.get(updExpsense.Id).EMS_Event_gne__c;
                if (oldCountryExpenseAmount != updExpsense.Country_Expense_Amount_gne__c || oldEventRelation != (String) updExpsense.EMS_Event_gne__c) {
                    // the value has been changed => update Event's Total Expense Value
                    changedExpenses.add(updExpsense);
                }
            }

            if (!changedExpenses.isEmpty()) {
                for (EMS_Expense_gne__c exp: changedExpenses) {
                    relatedEventIDs.add(exp.EMS_Event_gne__c);
                }
            }
        }

        if (!relatedEventIDs.isEmpty()) {
            Map<String, EMS_Event__c> eventsMap = new Map<String, EMS_Event__c>([SELECT Total_Expenses_gne__c FROM EMS_Event__c WHERE Id IN :relatedEventIDs]);
            List<EMS_Expense_gne__c> expenses = [SELECT Country_Expense_Amount_gne__c, EMS_Event_gne__c FROM EMS_Expense_gne__c WHERE EMS_Event_gne__c IN :eventsMap.keySet()];
            Map<String, Decimal> evId_totalExpenses_map = new Map<String, Decimal>();

            for (EMS_Expense_gne__c exp : expenses) {
                if (evId_totalExpenses_map.containsKey(exp.EMS_Event_gne__c)) {
                    Decimal sum = evId_totalExpenses_map.get(exp.EMS_Event_gne__c);
                    sum = sum + exp.Country_Expense_Amount_gne__c;
                    evId_totalExpenses_map.put(exp.EMS_Event_gne__c, sum);
                } else {
                    evId_totalExpenses_map.put(exp.EMS_Event_gne__c, exp.Country_Expense_Amount_gne__c);
                }
            }
            if (!evId_totalExpenses_map.isEmpty()) {
                for (String evID : evId_totalExpenses_map.keySet()) {
                    eventsMap.get(evID).Total_Expenses_gne__c = evId_totalExpenses_map.get(evID);
                }
                update eventsMap.values();
            }
        }
    }

    public static void onAfterInsert(List<EMS_Expense_gne__c> triggerNew) {
        increaseTotalExpensesAmount(triggerNew);

        Map<Id, EMS_Expense_gne__c> triggerNewMap = new Map<Id, EMS_Expense_gne__c>();
        for (EMS_Expense_gne__c newExpense : triggerNew) {
            triggerNewMap.put(newExpense.Id, newExpense);
        }
        changeEventTotalExpenseValue(null, triggerNewMap);
    }

    public static void onAfterUpdate(Map<Id, EMS_Expense_gne__c> triggerOld, Map<Id, EMS_Expense_gne__c> triggerNew) {
        updateTotalExpensesAmount(triggerOld, triggerNew);
        changeEventTotalExpenseValue(triggerOld, triggerNew);
    }

    public static void onAfterDelete(List<EMS_Expense_gne__c> triggerOld) {
        decreaseTotalExpensesAmount(triggerOld);

        Map<Id, EMS_Expense_gne__c> triggerOldMap = new Map<Id, EMS_Expense_gne__c>();
        for (EMS_Expense_gne__c oldExpense : triggerOld) {
            triggerOldMap.put(oldExpense.Id, oldExpense);
        }
        changeEventTotalExpenseValue(triggerOldMap, null);
    }

    public static void onAfterUndelete(List<EMS_Expense_gne__c> triggerNew) {
        increaseTotalExpensesAmount(triggerNew);
    }
}