public without sharing class EMS_Transaction_Child_Record_Updates {

    public static void onAfterDelete(List<EMS_Transaction_gne__c> triggerOld) {
        deletePaymentRequests(triggerOld);
    }

    public static void onAfterUpdate(List<EMS_Transaction_gne__c> triggerNew) {
        closePaymentRequestWhenAllTransactionsAreClosed(triggerNew);
    }

    // After Delete
    private static void deletePaymentRequests(List<EMS_Transaction_gne__c> triggerOld) {
        Set<Id> paymentRequestIds = new Set<Id>();
        for (EMS_Transaction_gne__c trans : triggerOld) {
            paymentRequestIds.add(trans.EMS_Speaker_Role_gne__c);
        }
        List<EMS_Speaker_Role_gne__c> paymentRequestsToDelete = new List<EMS_Speaker_Role_gne__c>();
        for (EMS_Speaker_Role_gne__c paymentRequest : [SELECT Id, (select name from EMS_Transactions__r) FROM EMS_Speaker_Role_gne__c WHERE Id IN :paymentRequestIds]) {
            if (paymentRequest.EMS_Transactions__r.size() == 0) {
                paymentRequestsToDelete.add(paymentRequest);
            }
        }
        if (!paymentRequestsToDelete.isEmpty()) {
            delete paymentRequestsToDelete;
        }
    }


    // After Update
    private static void closePaymentRequestWhenAllTransactionsAreClosed(List<EMS_Transaction_gne__c> triggerTransactions) {

        Set<Id> allPRIds = new Set<Id>();
        for (EMS_Transaction_gne__c tr : triggerTransactions) {
            allPRIds.add(tr.EMS_Speaker_Role_gne__c);
        }

        List<EMS_Speaker_Role_gne__c> allPayementRequests = [SELECT Id, Status_gne__c FROM EMS_Speaker_Role_gne__c WHERE Id IN :allPRIds];
        List<EMS_Speaker_Role_gne__c> prToUpdate = new List<EMS_Speaker_Role_gne__c>();
        List<EMS_Transaction_gne__c> allTransactions = [SELECT Id, Status_gne__c, EMS_Speaker_Role_gne__c FROM EMS_Transaction_gne__c WHERE EMS_Speaker_Role_gne__c IN :allPRIds];
        Integer transactionsCount = 0;
        Integer completedTrCount = 0;

        for (EMS_Speaker_Role_gne__c pr : allPayementRequests) {
            for (EMS_Transaction_gne__c tr : allTransactions) {
                if (tr.EMS_Speaker_Role_gne__c == pr.Id) {
                    transactionsCount++;
                    if (tr.Status_gne__c == 'Completed') {
                        completedTrCount++;
                    }
                }
            }
            if (transactionsCount == completedTrCount) {
                pr.Status_gne__c = 'Completed';
                prToUpdate.add(pr);
            }
            transactionsCount = 0;
            completedTrCount = 0;
        }

        update prToUpdate;
    }
}