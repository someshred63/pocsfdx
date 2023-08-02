public with sharing class EMS_Ariba_Payment_Queue_Ext extends List_View_Base_Controller {

    public List_View_Base_Controller thisController { get; set; }
    public Integer currentBatchID { get; set; }
    public Boolean isFailure { get; set; }
    public String idsToExclude { get; set; }

    public String pagePositiveMessage { get; set; }
    public String pageErrorMessage { get; set; }

    public EMS_Ariba_Payment_Queue_Ext() {
        super(EMS_Speaker_Role_gne__c.sObjectType.getDescribe().getName());
        thisController = this;

        List<aggregateResult> results = [SELECT Max(Batch_ID_gne__c) maximum FROM EMS_Speaker_Role_gne__c WHERE Batch_ID_gne__c != null];
        for (AggregateResult ar : results) {
            if (ar.get('maximum') == null) {
                currentBatchID = 0;
            } else {
                currentBatchID = Integer.valueOf(ar.get('maximum'));
            }
        }
        isFailure = false;
        idsToExclude = '';
        pageErrorMessage = null;
        pagePositiveMessage = null;
    }

    public PageReference submitBatch() {
        String ids = System.CurrentPageReference().getParameters().get('ids');
        Boolean isResubmit = Boolean.valueOf(System.CurrentPageReference().getParameters().get('isresubmit'));
        isFailure = true;

        List<String> idsList = ids.split(',');
        List<EMS_Speaker_Role_gne__c> paymentQueues = [SELECT Batch_ID_gne__c, Status_gne__c, On_Hold_Comment_gne__c FROM EMS_Speaker_Role_gne__c WHERE Id IN :idsList];

        List<AggregateResult> trans = [
                SELECT COUNT(Id) c, EMS_Speaker_Role_gne__c pId
                FROM EMS_Transaction_gne__c
                WHERE EMS_Speaker_Role_gne__c IN :idsList AND RecordTypeId != null
                GROUP BY EMS_Speaker_Role_gne__c
        ];
        Map<Id, Integer> paymentIdToTransactionsCount = new Map<Id, Integer>();
        for (AggregateResult t :trans) {
            Integer count = (Integer) t.get('c');
            Id parentId = (Id) t.get('pId');
            if (paymentIdToTransactionsCount.containsKey(parentId)) {
                Integer temp = paymentIdToTransactionsCount.get(parentId);
                paymentIdToTransactionsCount.put(parentId, temp + count);
            } else {
                paymentIdToTransactionsCount.put(parentId, count);
            }
        }

        currentBatchID = currentBatchID + 1; // set incremented ID of the Batch

        try {
            pageErrorMessage = null;
            pagePositiveMessage = null;
            List<EMS_Speaker_Role_gne__c> recordsToUpdate = new List<EMS_Speaker_Role_gne__c>();
            for (EMS_Speaker_Role_gne__c paymentQueue : paymentQueues) {
                if (paymentQueue.Status_gne__c == 'On-hold') {
                    throw new QueueException('Payment request On-hold, can not submit batch.');
                } else if (paymentQueue.Status_gne__c == 'Draft') {
                    throw new QueueException('Payment request Draft, can not submit batch.');
                } else if (paymentQueue.Status_gne__c == 'Completed' && !isResubmit) {
                    throw new QueueException('Payment request Completed, can not submit batch.');
                } else if (paymentIdToTransactionsCount.containsKey(paymentQueue.Id) && paymentIdToTransactionsCount.get(paymentQueue.Id) == 0) {
                    // The number of proper transactions is 0
                    throw new QueueException('Batch cannot be submitted for current record(s). Reason: Payment Request needs to be submitted manually.');
                } else if (!paymentIdToTransactionsCount.containsKey(paymentQueue.Id)) {
                    // Problem! there are no transactions to run the batch
                    throw new QueueException('Batch cannot be submitted for current record(s). Reason: Payment Request doesn\'t contain any transactions.');
                }

                if (paymentQueue.Batch_ID_gne__c != currentBatchID) {
                    paymentQueue.Batch_ID_gne__c = currentBatchID;
                    paymentQueue.Status_gne__c = 'Completed';
                    recordsToUpdate.add(paymentQueue);
                }
            }
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
                isFailure = false;
            }
        } catch (DmlException ex) {
            currentBatchID = currentBatchID - 1;
        } catch (Exception ex) {
            pageErrorMessage = ex.getMessage();
            currentBatchID = currentBatchID - 1;
        }

        if (pageErrorMessage == null && !isFailure) {
            pagePositiveMessage = 'Your payment batch was completed successfully';
        }
        return null;
    }

    public PageReference putOnHold() {
        String ids = System.CurrentPageReference().getParameters().get('ids');
        String comment = System.CurrentPageReference().getParameters().get('comment');
        isFailure = true;

        List<String> idsList = ids.split(',');
        List<EMS_Speaker_Role_gne__c> paymentQueues = [SELECT Batch_ID_gne__c, Status_gne__c, On_Hold_Comment_gne__c, EMS_Event_gne__r.Assigned_AARC_gne__c FROM EMS_Speaker_Role_gne__c WHERE Id IN :idsList /*AND Status_gne__c != 'Completed' AND Status_gne__c != 'On-hold'*/];

        Map<String, String> whatIDs_recipientIDs = new Map<String, String>();
        SavePoint sp = Database.setSavePoint();
        try {
            for (EMS_Speaker_Role_gne__c paymentQueue :paymentQueues) {
                paymentQueue.On_Hold_Comment_gne__c = (String.isBlank(comment) ? '' : comment);
                paymentQueue.Status_gne__c = 'On-hold';
                EMS_Email.prepareSingleEmail('EMS_AARC_Notification_OnHold', paymentQueue.Id, paymentQueue.EMS_Event_gne__r.Assigned_AARC_gne__c);
            }
            update paymentQueues;
            EMS_Email.send();
            isFailure = false;
        } catch (Exception ex) {
            Database.rollback(sp);
            pageErrorMessage = ex.getMessage();
        }
        return null;
    }

    public Boolean getIsAPUser() {
        return EMS_Util.getUserRole() == 'AP';
    }

    private class QueueException extends Exception {
    }
}