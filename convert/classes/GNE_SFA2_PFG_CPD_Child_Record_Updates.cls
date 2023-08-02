public without sharing class GNE_SFA2_PFG_CPD_Child_Record_Updates {
    
    private static void createTransactions(List<Call_PFG_Detail_gne__c> triggerOld, List<Call_PFG_Detail_gne__c> triggerNew) {
        List<SFA2_PFG_Transaction_gne__c> trxsToInsert = new List<SFA2_PFG_Transaction_gne__c>();
        Map<Integer,Integer> trxIdxToCallDetailIdxMap = new Map<Integer,Integer>();
        Integer idx = 0;
        Integer trxIdx = 0;
        for(Call_PFG_Detail_gne__c cpdNew : triggerNew) {
            Call_PFG_Detail_gne__c cpdOld = triggerOld!=null ? triggerOld[idx] : null;
            if(cpdNew.Is_Completed_gne__c && (cpdOld==null || !cpdOld.Is_Completed_gne__c)) {
                trxsToInsert.add(createTransaction(cpdNew));
                trxIdxToCallDetailIdxMap.put(trxIdx++,idx);
            }
            idx++;
        }
        
        if(!trxsToInsert.isEmpty()) {
            Database.SaveResult[] results = Database.insert(trxsToInsert,false);
            trxIdx = 0;
            for(Database.SaveResult result : results) {
                if(!result.isSuccess()) {
                    Call_PFG_Detail_gne__c matchingCallDetail = triggerNew[trxIdxToCallDetailIdxMap.get(trxIdx)];
                    for(Database.Error err : result.getErrors()) {
                        matchingCallDetail.addError(err.getMessage());
                    }
                }
                trxIdx++;
            }
        }
    }
    
    private static SFA2_PFG_Transaction_gne__c createTransaction(Call_PFG_Detail_gne__c cpdNew) {
        Boolean isDTP = cpdNew.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
        Id recordTypeId = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(
            isDTP ? GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF : GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT);
        SFA2_PFG_Transaction_gne__c trx = new SFA2_PFG_Transaction_gne__c(
            RecordTypeId = recordTypeId,
            Product_gne__c = cpdNew.Product_gne__c, 
            Distribution_Method_gne__c = cpdNew.Distribution_Method_gne__c,
            Lot_No_gne__c = (String.isBlank(cpdNew.Lot_No_gne__c) ? GNE_SFA2_PFG_Util.LOT_NO_NA_VALUE : cpdNew.Lot_No_gne__c),
            Requested_Quantity_gne__c = cpdNew.Quantity_gne__c,
            Call_PFG_Detail_ID_gne__c = cpdNew.Id,
            Transaction_Ref_Number_gne__c = cpdNew.Call_Name_gne__c);
        return trx; 
    }
    
    private static void signTransactionsFromOtr(List<Call_PFG_Detail_gne__c> triggerOld, List<Call_PFG_Detail_gne__c> triggerNew) {
        if(GNE_SFA2_PFG_CPD_Trigger_Helper.isOtrRequest()) {
            List<SFA2_PFG_Transaction_gne__c> trxsToUpdate = new List<SFA2_PFG_Transaction_gne__c>();
            List<Call_PFG_Detail_gne__c> cDetails = new List<Call_PFG_Detail_gne__c>();
            Integer idx = 0;
            
            for(Call_PFG_Detail_gne__c cpdNew : triggerNew) {
                Call_PFG_Detail_gne__c cpdOld = triggerOld[idx++];
                if(cpdNew.Distribution_Method_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP && 
                   cpdNew.DTP_AOC_Status_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE) {
                    cDetails.add(cpdNew);
                }
            }
            
            GNE_SFA2_PFG_Util.cacheTransactionsByCallDetailIds(new Map<Id,Call_PFG_Detail_gne__c>(cDetails).keySet());
            List<Call_PFG_Detail_gne__c> cDetailsHelperList = new List<Call_PFG_Detail_gne__c>();
            
            for(Call_PFG_Detail_gne__c cDetail : cDetails) {
                SFA2_PFG_Transaction_gne__c trx = GNE_SFA2_PFG_Util.getTransactionByCallDetailId(cDetail.Id);
                if(trx!=null && String.isBlank(trx.Signature_gne__c)) {
                    trxsToUpdate.add(trx);
                    cDetailsHelperList.add(cDetail);
                }
            }
        
            if(!trxsToUpdate.isEmpty()) {
                Database.SaveResult[] results = Database.update(trxsToUpdate,false);
                Integer trxIdx = 0;
                for(Database.SaveResult result : results) {
                    if(!result.isSuccess()) {
                        Call_PFG_Detail_gne__c matchingCallDetail = cDetailsHelperList.get(trxIdx);
                        for(Database.Error err : result.getErrors()) {
                            matchingCallDetail.addError(err.getMessage());
                        }
                    }
                    trxIdx++;
                }
            }
        }
    }
    
    public static void onAfterUpdate(List<Call_PFG_Detail_gne__c> triggerOld, List<Call_PFG_Detail_gne__c> triggerNew) {
        createTransactions(triggerOld, triggerNew);
        signTransactionsFromOtr(triggerOld, triggerNew);
    }

    public static void onAfterInsert(List<Call_PFG_Detail_gne__c> triggerNew) {
        createTransactions(null, triggerNew);
    }
    
    public static void onAfterDelete(List<Call_PFG_Detail_gne__c> triggerOld) {
    
    }
}