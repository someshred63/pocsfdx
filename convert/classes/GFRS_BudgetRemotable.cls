global class GFRS_BudgetRemotable {

    public GFRS_BudgetRemotable(ApexPages.StandardController std) {

    }

    @RemoteAction
    global static Boolean validBudgetLIs(String budgetId, String FundingRequestId) {
        Set<Id> budgetIds = new Set<Id>();
        if (FundingRequestId != '') {
            Map<Id, GFRS_RequestBudget__c> budgets = new Map<Id, GFRS_RequestBudget__c>([SELECT Id FROM GFRS_RequestBudget__c WHERE Grant_Request__c = :Id.valueOf(FundingRequestId)]);
            budgetIds = budgets.keySet();
        } else {
            budgetIds.add(Id.valueOf(budgetId));
        }

        GFRS_Request_Budget_Line_Item__c[] budgetLines = [
                SELECT Id, Name, Count__c, Comments_Clarification__c, Budget_Subcategory__c, Budget_Category__c, Amount__c
                FROM GFRS_Request_Budget_Line_Item__c
                WHERE Budget__c IN :budgetIds
        ];

        for (GFRS_Request_Budget_Line_Item__c budLI : budgetLines) {
            if (budLI.Budget_Category__c == null || budLI.Budget_Category__c.trim() == '' ||
                    budLI.Budget_Subcategory__c == null || budLI.Budget_Subcategory__c.trim() == '' ||
                    budLI.Amount__c == null || budLI.Amount__c < 0.01 ||
                    budLI.Count__c == null || Integer.valueOf(budLI.Count__c) < 1 ||
                    budLI.Comments_Clarification__c == null || budLI.Comments_Clarification__c.trim() == '') {
                return false;
            }
        }
        return true;
    }

    @RemoteAction
    global static Boolean validBudgetLIsEmpty(String budgetId, String FundingRequestId) {
        Set<Id> budgetIds = new Set<Id>();
        if (FundingRequestId != '') {
            Map<Id, GFRS_RequestBudget__c> budgets = new Map<Id, GFRS_RequestBudget__c>([SELECT Id FROM GFRS_RequestBudget__c WHERE Grant_Request__c = :Id.valueOf(FundingRequestId)]);
            budgetIds = budgets.keySet();
        } else {
            budgetIds.add(Id.valueOf(budgetId));
        }

        List<GFRS_Request_Budget_Line_Item__c> budgetLines = [
                SELECT Id, Name, Count__c, Comments_Clarification__c, Budget_Subcategory__c, Budget_Category__c, Amount__c
                FROM GFRS_Request_Budget_Line_Item__c
                WHERE Budget__c IN :budgetIds
        ];
        if (budgetLines == null || budgetLines.size() < 1) {
            return false;
        }
        return true;
    }

    @RemoteAction
    global static GFRS_Request_Budget_Line_Item__c addBudgetLine(String budgetId) {

        GFRS_Request_Budget_Line_Item__c budget = new GFRS_Request_Budget_Line_Item__c(Budget__c = Id.valueOf(budgetId), Count__c = 1);
        gFRS_Util_NoShare.saveLockedBudgetLIs(new GFRS_Request_Budget_Line_Item__c[]{
                budget
        });
        return budget;
    }

    @RemoteAction
    global static GFRS_Request_Budget_Line_Item__c removeBudgetLine(String budgetLineId) {
        Id newId = Id.valueOf(budgetLineId);
        GFRS_Request_Budget_Line_Item__c obj = [SELECT Id FROM GFRS_Request_Budget_Line_Item__c WHERE Id = :newId];
        gFRS_Util_NoShare.removeLockedBudgetLIs(new GFRS_Request_Budget_Line_Item__c[]{
                obj
        });
        return obj;
    }

    /**
     *  Remoting method that updates a single specific budget line field.
     *  <p>Instead of updating all objects, this updates each field as the field is changed,
     *  to avoid requiring to hit save</p>
     *  @param stringId (String) - the string representation of the budget line id
     *  @param fieldName (String) - the name of the field to update on the budget line
     *  @param value (Stirng) - the string representation of the value to update
     *  @return GFRS_Request_Budget_Line_Item__c - the updated budget object or NULL if it could not be updated
     **/
    @RemoteAction
    global static GFRS_Request_Budget_Line_Item__c updateBudgetLineField(String stringId, String fieldName, String value) {
        Id newId = Id.valueOf(stringId);
        //System.debug( 'budgetLineItem[' + stringId + '] id[' + newId + '] value[' + value + ']');
        GFRS_Request_Budget_Line_Item__c obj = [SELECT Id FROM GFRS_Request_Budget_Line_Item__c WHERE Id = :newId];

        if (!gFRS_Util.assignSObjectValue(obj, fieldName, value)) {
            //-- unable to assign
            return(null);
        }
        if (fieldName == 'Budget_Category__c') {
            gFRS_Util.assignSObjectValue(obj, 'Budget_Subcategory__c', '');
        }

        gFRS_Util_NoShare.saveLockedBudgetLIs(new GFRS_Request_Budget_Line_Item__c[]{
                obj
        });

        return obj;
    }

    /**
     *  Remoting method that returns all remoting budget lines
     *  @return GFRS_Request_Budget_Line_Item__c[] - list of budget lines
     **/
    @RemoteAction
    global static GFRS_Request_Budget_Line_Item__c[] fetchBudgetLines(String budgetId) {
        GFRS_Request_Budget_Line_Item__c[] budgetLines = [
                SELECT Id, Name, Count__c, Comments_Clarification__c, Budget_Subcategory__c, Budget_Category__c, Amount__c
                FROM GFRS_Request_Budget_Line_Item__c
                WHERE Budget__c = :budgetId
        ];
        return budgetLines;
    }

    @RemoteAction
    global static String getBudgetLinesTotalAmount(String FundingRequestId) {
        AggregateResult result = [SELECT SUM(Amount__c) amountSoFar FROM GFRS_RequestBudget__c WHERE Grant_Request__c = :Id.valueOf(FundingRequestId)];
        return String.valueOf(result.get('amountSoFar'));
    }
}