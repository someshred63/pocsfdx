public without sharing class GNE_SFA2_PFG_IC_Child_Record_Updates {
    
    public static void onAfterInsert(List<SFA2_PFG_Inventory_Count_gne__c> triggerNew) {
    }
    
    public static void onAfterUpdate(List<SFA2_PFG_Inventory_Count_gne__c> triggerNew, List<SFA2_PFG_Inventory_Count_gne__c> triggerOld) {
        if(GNE_SFA2_PFG_IC_Field_Updates.getIsCreationMode()) {
            createTransactionRecords(triggerNew);
            GNE_SFA2_PFG_IC_Field_Updates.setIsCreationMode(false);
        }

    }
    
    private static void createTransactionRecords(List<SFA2_PFG_Inventory_Count_gne__c> triggerNew){
        List<SFA2_PFG_Transaction_gne__c> transactionList = new List<SFA2_PFG_Transaction_gne__c>();
        Map<Integer,Integer> invTrxIdxToIncCountIdxMap = new Map<Integer,Integer>();
        
        Id adjRecTypeId = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT);
        
        Integer invIdx = 0;
        Integer trxIdx = 0;
        for(SFA2_PFG_Inventory_Count_gne__c invCount : triggerNew){
            if(invCount.Difference_gne__c!=0 && invCount.Inventory_Ref_Number_gne__c!=null) {
                SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(
                    RecordTypeId = adjRecTypeId,
                    Lot_No_gne__c = invCount.Lot_gne__c,
                    Product_gne__c = invCount.Product_gne__c,
                    Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC,
                    Transaction_Reason_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_REASON_OTHER,
                    Requested_Quantity_gne__c = invCount.Difference_gne__c,
                    To_User_gne__c = invCount.Inventory_For_gne__c,
                    Inventory_Count_Flag_gne__c = true,
                    Transaction_Ref_Number_gne__c = invCount.Inventory_Ref_Number_gne__c
                );
                transactionList.add(trx);
                invTrxIdxToIncCountIdxMap.put(trxIdx,invIdx);
                trxIdx++;
            }
            invIdx++;   
        }
        
        if(!transactionList.isEmpty()) {
            Database.SaveResult[] results = Database.insert(transactionList,false);
            trxIdx = 0;
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    SFA2_PFG_Inventory_Count_gne__c matchingInvCount = triggerNew[invTrxIdxToIncCountIdxMap.get(trxIdx)];
                    for(Database.Error err : result.getErrors()) {
                        matchingInvCount.addError(err.getMessage());
                    }
                }
                trxIdx++;
            }
        } 
    }
}