trigger CFAR_RateTableTrigger on CFAR_Rate_Table_gne__c (after delete, after insert, after update, before insert, before update) {
    if (CFAR_ConfigUtil.isTriggerEnabled(new List<String>{'CFAR_RateTableTrigger','CFAR_Rate_Table_gne__c'})){
        Set<String> contractIds = new Set<String>();
        List<CFAR_Rate_Table_gne__c> rateTables = trigger.isUpdate || trigger.isInsert ? trigger.new : trigger.old;
        
        for(CFAR_Rate_Table_gne__c rt : rateTables) {
            if(!'Total'.equals(rt.Payment_Type_gne__c)){
                contractIds.add(rt.Budget_Contract_ref_gne__c);
            }
        }
        
        if(trigger.isBefore && (trigger.isUpdate || trigger.isInsert))
            //DONE: ITERATION2
            CFAR_Budget_Utils.updateTotalPaidAmountOnRateTable(contractIds,rateTables);
            //for(CFAR_Rate_Table_gne__c rt : trigger.new) {
            //  if(String.isBlank(rt.WithHold_Type_gne__c))
            //      rt.Withhold_Value_gne__c = null;
            //}
            
        if (trigger.isBefore && trigger.isUpdate) {
            //CFAR_Budget_Utils.updateWithholdIndicatorOnPayments(trigger.oldMap, trigger.newMap);
            CFAR_Budget_Utils.updatePaidUnitsAndPaidWithheldUnitsOnRateTable(rateTables);
        }
        
        if(trigger.isAfter)
            //DONE: ITERATION2 
            CFAR_Budget_Utils.updateRateTableTotals(contractIds);
        
        /** 
        if (trigger.isAfter && trigger.isUpdate)
            CFAR_Budget_Utils.updateWithholdIndicatorOnPayments(trigger.oldMap, trigger.newMap);
        */  
    }
}