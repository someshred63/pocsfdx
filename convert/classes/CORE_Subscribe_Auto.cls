global without sharing class CORE_Subscribe_Auto implements Schedulable {

    global void execute(SchedulableContext sc) {
        Map<String, CORE_Found_Misc_Config__c> coreFoundMiscConfig = CORE_Found_Misc_Config__c.getAll();
        Datetime publishLastSynch = coreFoundMiscConfig.containsKey('PublishLastSynchDateTime') && coreFoundMiscConfig.get('PublishLastSynchDateTime').Configuration_Value_gne__c != null ? Datetime.valueOf(coreFoundMiscConfig.get('PublishLastSynchDateTime').Configuration_Value_gne__c) : null;
        Datetime autoSubLastSynch = coreFoundMiscConfig.containsKey('AutoSubscribeLastSynchDateTime') && coreFoundMiscConfig.get('AutoSubscribeLastSynchDateTime').Configuration_Value_gne__c != null ? Datetime.valueOf(coreFoundMiscConfig.get('AutoSubscribeLastSynchDateTime').Configuration_Value_gne__c) : null;
        Integer batchSize = coreFoundMiscConfig.containsKey('AutoSubscribeBatchSize') && coreFoundMiscConfig.get('AutoSubscribeBatchSize').Configuration_Value_gne__c != null ? Integer.valueOf(coreFoundMiscConfig.get('AutoSubscribeBatchSize').Configuration_Value_gne__c) : 50;

        if (publishLastSynch != null && Datetime.now() > publishLastSynch && (autoSubLastSynch == null || publishLastSynch > autoSubLastSynch) && !isAutoSubRanning()) {
            runAutoSubscribe(autoSubLastSynch, publishLastSynch, batchSize);
        }
    }

    private void runAutoSubscribe(Datetime autoSubLastSynch, Datetime publishLastSynch, Integer batchSize) {
        Integer numberOfBatches = CORE_Subscribe_Util.getNumberOfAutoSubBatches();
        Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId('SUB_AUTO');
        CORE_Subscribe_Object__c subscribeObject = [SELECT Id FROM CORE_Subscribe_Object__c LIMIT 1];
        for (Integer i = 0; i < numberOfBatches; i++) {
            CORE_Subscribe_Batch subscribeBatch = new CORE_Subscribe_Batch();
            subscribeBatch.initBatch(subscribeObject.Id, jobId, i, autoSubLastSynch, publishLastSynch);

            Id batchId = Database.executeBatch(subscribeBatch, batchSize);
            CORE_Subscribe_Util.addIdToJSONBatchIds(jobId, batchId);
        }
    }

    private Boolean isAutoSubRanning() {
        List<CORE_Subscribe_Job__c> sJob = [SELECT Batch_Ids_json_gne__c FROM CORE_Subscribe_Job__c WHERE Name LIKE 'SUB_AUTO%' ORDER BY LastModifiedDate DESC LIMIT 1];
        if (!sJob.isEmpty()) {
            List<String> bIds = (List<String>) JSON.deserialize(sJob.get(0).Batch_Ids_json_gne__c, List<String>.class);
            List<AsyncApexJob> apexJobs = [SELECT Id FROM AsyncApexJob WHERE Id IN :bIds AND Status NOT IN ('Aborted', 'Completed', 'Failed')];
            return !apexJobs.isEmpty();
        } else {
            return false;
        }
    }

}