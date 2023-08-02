global class updateBudgetDeductionBatch implements Database.Batchable<sObject>, Database.Stateful {
    String query;
    Map<String, Id> costCentersMap;

    global updateBudgetDeductionBatch() {
        query = 'SELECT Id FROM EMS_Event__c';

        costCentersMap = new Map<String, Id>();
        for (EMS_Cost_Center_gne__c cc : [SELECT Id, Name FROM EMS_Cost_Center_gne__c]) {
            costCentersMap.put(cc.Name, cc.Id);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> eventIDs = new Set<Id>();
        for (EMS_Event__c event : (List<EMS_Event__c>) scope) {
            eventIDs.add(event.Id);
        }

        Map<String, List<EMS_Budget_Allocation_gne__c>> budgetAllocationsMap = new Map<String, List<EMS_Budget_Allocation_gne__c>>();
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Id, EMS_Event_gne__c, Cost_Center_gne__c, Budget_Deductions_gne__c, Percentage_Contribution_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :eventIds ORDER BY Id]) {
            if (!budgetAllocationsMap.containsKey(String.valueOf(ba.EMS_Event_gne__c) + String.valueOf(ba.Cost_Center_gne__c))) {
                budgetAllocationsMap.put(String.valueOf(ba.EMS_Event_gne__c) + String.valueOf(ba.Cost_Center_gne__c), new List<EMS_Budget_Allocation_gne__c>());
            }
            budgetAllocationsMap.get(String.valueOf(ba.EMS_Event_gne__c) + String.valueOf(ba.Cost_Center_gne__c)).add(ba);
        }

        Map<String, Decimal> budgetAllocationsByCostCenter = new Map<String, Decimal>();
        // select budget allocations
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Cost_Center_gne__c, EMS_Event_gne__c, Percentage_Contribution_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN :eventIds]) {
            String costCenterName = ba.Cost_Center_gne__c;
            String eventId = ba.EMS_Event_gne__c;


            if (!budgetAllocationsByCostCenter.containsKey(eventId + costCenterName)) {
                budgetAllocationsByCostCenter.put(eventId + costCenterName, ba.Percentage_Contribution_gne__c);
            } else {
                Double currentPercentage = budgetAllocationsByCostCenter.get(eventId + costCenterName);
                budgetAllocationsByCostCenter.put(eventId + costCenterName, currentPercentage + ba.Percentage_Contribution_gne__c);
            }
        }

        List<EMS_Expense_gne__c> expenses = [SELECT Id, EMS_Cost_Center_gne__r.Name, EMS_Event_gne__c, Country_Expense_Amount_gne__c FROM EMS_Expense_gne__c WHERE EMS_Event_gne__c IN :eventIDs];

        Map<String, Decimal> expensesByCostCenter = new Map<String, Decimal>();
        for (EMS_Expense_gne__c exp : expenses) {
            String costCenterName = exp.EMS_Cost_Center_gne__r.Name;
            String eventId = exp.EMS_Event_gne__c;

            String key = eventId + costCenterName;

            if (!expensesByCostCenter.containsKey(key)) {
                expensesByCostCenter.put(key, 0);
            }
            Decimal currentExpenses = expensesByCostCenter.get(key);
            if (budgetAllocationsByCostCenter.containsKey(key)) {
                expensesByCostCenter.put(key, currentExpenses + exp.Country_Expense_Amount_gne__c);
            }
        }

        for (String baKey : budgetAllocationsByCostCenter.keySet()) {
            System.debug('budgetAllocationsByCostCenter ' + baKey + ': ' + budgetAllocationsByCostCenter.get(baKey));
        }

        for (String exKey : expensesByCostCenter.keySet()) {
            System.debug('expensesByCostCenter ' + exKey + ': ' + expensesByCostCenter.get(exKey));
        }

        Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocationsToUpdate = new Map<Id, EMS_Budget_Allocation_gne__c>();

        Map<String, Decimal> deductionsSum = new Map<String, Decimal>();
        for (String key : budgetAllocationsMap.keySet()) {
            Integer lastElementIndex = budgetAllocationsMap.get(key).size() - 1;
            for (Integer i = 0; i < budgetAllocationsMap.get(key).size(); i++) {
                EMS_Budget_Allocation_gne__c ba = budgetAllocationsMap.get(key)[i];
                Decimal expensesForCC = expensesByCostCenter.containsKey(key) ? expensesByCostCenter.get(key) : 0;

                if (!budgetAllocationsToUpdate.containsKey(ba.Id) && budgetAllocationsByCostCenter.get(key) != 0) {
                    if (lastElementIndex == 0 || i != lastElementIndex) {
                        Decimal toBeDeducted = expensesForCC * (ba.Percentage_Contribution_gne__c / budgetAllocationsByCostCenter.get(key));
                        Decimal currentDeductions = deductionsSum.containsKey(key) ? deductionsSum.get(key) : 0;
                        deductionsSum.put(key, currentDeductions + toBeDeducted.setScale(2));
                        ba.Budget_Deductions_gne__c = toBeDeducted.setScale(2); // round to 2 decimal places

                    } else {
                        ba.Budget_Deductions_gne__c = (expensesForCC - deductionsSum.get(key)).setScale(2); // round to 2 decimal places
                    }
                    budgetAllocationsToUpdate.put(ba.Id, ba);
                } else if (budgetAllocationsByCostCenter.get(key) != 0) {
                    if (lastElementIndex == 0 || i != lastElementIndex) {
                        Decimal toBeDeducted = expensesForCC * (ba.Percentage_Contribution_gne__c / budgetAllocationsByCostCenter.get(key));
                        Decimal currentDeductions = deductionsSum.containsKey(key) ? deductionsSum.get(key) : 0;
                        deductionsSum.put(key, currentDeductions + toBeDeducted.setScale(2));
                        budgetAllocationsToUpdate.get(ba.Id).Budget_Deductions_gne__c += toBeDeducted.setScale(2); // round to 2 decimal places
                    } else {
                        budgetAllocationsToUpdate.get(ba.Id).Budget_Deductions_gne__c += (expensesForCC - deductionsSum.get(key)).setScale(2); // round to 2 decimal places
                    }
                }
            }
        }
        for (EMS_Budget_Allocation_gne__c ba : budgetAllocationsToUpdate.values()) {
            System.debug('budgetAllocationsToUpdate: ' + ba);
        }


        if (!budgetAllocationsToUpdate.isEmpty()) {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            EMS_Budget_Allocation_Trigger_Helper.skipTriggerValidationRules = true;
            EMS_Product_Budget_Helper.skipTriggerValidationRules = true;
            EMS_Region_Budget_Helper.skipTriggerValidationRules = true;
            EMS_Territory_Budget_Helper.skipTriggerValidationRules = true;
            update budgetAllocationsToUpdate.values();
        }
    }

    global void finish(Database.BatchableContext BC) {
		AsyncApexJob a = [SELECT Id FROM AsyncApexJob WHERE Id =:BC.getJobId()];
		
		List<String> mails = EMS_Util.getApplicationAdminsEmails();
    	
    	EMS_Email.prepareSingleEmail('EMS_Batch_Job_Notification', a.Id, mails);
    	
    	EMS_Email.Send();
    }
}