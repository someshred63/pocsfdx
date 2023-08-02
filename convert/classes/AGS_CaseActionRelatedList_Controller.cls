public with sharing class AGS_CaseActionRelatedList_Controller {
    
    public Id caseId { get; set; }
    
    public AGS_Case_Action_gne__c[] getActions() {
        final AGS_Case_Action_gne__c[] result = new AGS_Case_Action_gne__c[]{ };
        result.addAll(caseId == null ? new AGS_Case_Action_gne__c[]{ } : [
            SELECT Name, Action_gne__c FROM AGS_Case_Action_gne__c
            WHERE AGS_Case_gne__c = :caseId AND Action_Status_Internal_gne__c = 'Open' ORDER BY Name LIMIT 1000
        ]);
        return result;
    }
    
    public AGSSpendCCOCase_gne__c[] getExpenses() {
        final AGSSpendCCOCase_gne__c[] result = new AGSSpendCCOCase_gne__c[]{ };
        result.addAll(caseId == null ? new AGSSpendCCOCase_gne__c[]{ } : [
            SELECT
                Name,
                Event_ID_gne__c,
                Source_System_Code_gne__c,
                AGS_Spend_Recipient_gne__c,
                AGS_Spend_Event_Date_gne__c,
                AGS_Spend_Event_Name_gne__c,
                Source_Transaction_ID_gne__c,
                Source_Transaction_Amount_gne__c,
                Spend_Transaction_Amounts_gne__c,
                AGS_Spend_Expense_Transaction_gne__c,
                AGS_Spend_Event_Actual_Attendees_gne__c,
                AGS_Spend_Event_Planned_Attendees_gne__c,
                AGS_Spend_Expense_Trans_Spend_User_gne__c,
                AGS_Spend_Expense_Transaction_Amount_gne__c
            FROM AGSSpendCCOCase_gne__c WHERE AGS_Case_gne__c = :caseId ORDER BY Name LIMIT 1000
        ]);
        return result;
    }
    
    public AGS_Case_gne__c getCase() {
        return caseId == null ? new AGS_Case_gne__c() : [
            SELECT
                Name,
                AGS_CCO_Reason_Name_gne__c,
                Expense_Transaction_Total_gne__c,
                AGS_Case_Reason_Description_gne__c
            FROM AGS_Case_gne__c WHERE Id = :caseId LIMIT 1
        ];
    }
}