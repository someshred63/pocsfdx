/** 
 * @date 10/28/2016
 * @author Grzegorz Laskowski
 * @description Trigger for AGS_ST_DisputeManagement_gne__c insert to prepopulate original values on disputed items
 */
trigger AGS_ST_DrugNameIndicatorUpdate on AGS_ST_DisputeManagement_gne__c (before insert) {
    final Map<Id, AGS_Spend_Expense_Transaction_gne__c> txs = new Map<Id, AGS_Spend_Expense_Transaction_gne__c>();
    // collect identifiers of all related transactions
    for (AGS_ST_DisputeManagement_gne__c dm : Trigger.new) {
        txs.put(dm.AGS_Spend_Expense_Transaction_gne__c, new AGS_Spend_Expense_Transaction_gne__c());
    }
    txs.remove(null);
    // collect data of all related transactions
    txs.putAll(txs.isEmpty() ? new AGS_Spend_Expense_Transaction_gne__c[]{ } : [
        SELECT
            Form_Of_Payment_gne__c,
            Nature_Of_Payment_gne__c,
            Source_Transaction_Amount_gne__c,
            Event_Actual_Attendee_Count_gne__c,
            Allocated_Transaction_Amount_gne__c,
            Event_Planned_Attendee_Count_gne__c,
            (SELECT AGS_Brand__c FROM AGS_expense_products_intercations1__r ORDER BY AGS_Brand__c)
        FROM AGS_Spend_Expense_Transaction_gne__c WHERE Id IN :txs.keySet()
    ]);
    // populate original values for disputed items
    for (AGS_ST_DisputeManagement_gne__c dm : Trigger.new) {
        if (txs.containsKey(dm.AGS_Spend_Expense_Transaction_gne__c)) {
            final AGS_Spend_Expense_Transaction_gne__c tx = txs.get(dm.AGS_Spend_Expense_Transaction_gne__c);
            final String[] brands = new String[]{ };
            // concatenate original brand names
            for (AGS_Expense_Products_Interaction__c brand : tx.AGS_expense_products_intercations1__r) {
                if (String.isNotBlank(brand.AGS_Brand__c)) {
                    brands.add(brand.AGS_Brand__c.trim());
                }
            }
            // prepopulate all original values
            dm.Orig_Drug_Name_gne__c = String.join(brands, ',');
            dm.Orig_Form_Of_Payment_gne__c = tx.Form_Of_Payment_gne__c;
            dm.Orig_Nature_Of_Payment_gne__c = tx.Nature_Of_Payment_gne__c;
            dm.Orig_Source_Transaction_Amount_gne__c = tx.Source_Transaction_Amount_gne__c;
            dm.Orig_Event_Actual_Attendee_Count_gne__c = tx.Event_Actual_Attendee_Count_gne__c;
            dm.Orig_Allocated_Transaction_Amount_gne__c = tx.Allocated_Transaction_Amount_gne__c;
            dm.Orig_Event_Planned_Attendee_Count_gne__c = tx.Event_Planned_Attendee_Count_gne__c;
        }
    }
}