global without sharing class GNE_Subscribe_Alignment_Auto {

    private static Integer DEFAULT_AUTO_SUB_BATCH_NUMBER = 8;
    private static Integer numberOfAutoSubBatches;

    public Id execute(Boolean prevMode) {
        return execute(prevMode, false);
    }

    public Id execute(Boolean prevMode, Boolean systemMode) {
        Integer batchSize = CORE_Found_Misc_Config__c.getValues('AutoSubscribeBatchSize') != null ? Integer.valueOf(CORE_Found_Misc_Config__c.getValues('AutoSubscribeBatchSize').Configuration_Value_gne__c) : 10;
        return runAutoSubscribe(batchSize, prevMode, systemMode);
    }

    private Id runAutoSubscribe(Integer batchSize, Boolean prevMode, Boolean systemMode) {
        String name = 'Auto_Alignment_';
        String subscribeJobName = 'ALIGNMENT_SUB_AUTO';
        if (prevMode) {
            name += '_PREVIEW_';
            subscribeJobName += '_PREVIEW_';
        }

        Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId(subscribeJobName);
        Alignment_Job_gne__c alignmentJob = new Alignment_Job_gne__c();
        alignmentJob.Name = name + Datetime.now().format('MM/dd/yyyy hh:mm a');
        alignmentJob.Subscribe_Job_gne__c = jobId;

        GNE_Foun_Misc_Config_Items_gne__c configItem = GNE_Foun_Misc_Config_Items_gne__c.getAll().get('AccountAlignmentETLLastSynchDateTime');
        String lastSyncAsString = configItem != null ? configItem.Configuration_Value_gne__c : null;
        alignmentJob.ETL_LastSynch_gne__c = String.isNotBlank(lastSyncAsString) ? Datetime.valueOfGmt(lastSyncAsString) : System.now();
        insert alignmentJob;

        for (Integer i = 0; i < getNumberOfAutoSubBatches(); i++) {
            GNE_Subscribe_Batch_Alignment subscribeBatch = new GNE_Subscribe_Batch_Alignment(alignmentJob.Id, prevMode, i, systemMode);
            Id batchId = Database.executeBatch(subscribeBatch, batchSize);
            addIdToJSONBatchIds(alignmentJob.Id, batchId);
        }
        return jobId;
    }

    /*Check how many subscribe auto batches is running. If only one than return true */
    public static Boolean isLastAutoBatch(Alignment_Job_gne__c sJob) {
        if (String.isNotBlank(sJob.Batch_Ids_json_gne__c)) {
            List<String> bIds = (List<String>) JSON.deserialize(sJob.Batch_Ids_json_gne__c, List<String>.class);
            List<AsyncApexJob> apexJobs = [SELECT Id FROM AsyncApexJob WHERE Id IN :bIds AND Status NOT IN ('Aborted', 'Completed', 'Failed')];
            return bIds.size() == getNumberOfAutoSubBatches() && apexJobs.isEmpty();
        } else {
            return false;
        }
    }

    public static Integer getNumberOfAutoSubBatches() {
        if (numberOfAutoSubBatches != null) {
            return numberOfAutoSubBatches;
        } else {
            numberOfAutoSubBatches = GNE_Foun_Misc_Config_Items_gne__c.getValues('NumberOfParallelAutoSubBatches') != null ? Integer.valueOf(GNE_Foun_Misc_Config_Items_gne__c.getValues('NumberOfParallelAutoSubBatches').Configuration_Value_gne__c) : DEFAULT_AUTO_SUB_BATCH_NUMBER;
            return numberOfAutoSubBatches;
        }
    }

    private static void addIdToJSONBatchIds(Id alignmentJobId, Id batchId) {
        Alignment_Job_gne__c sJob = [SELECT Batch_Ids_json_gne__c FROM Alignment_Job_gne__c WHERE Id = :alignmentJobId FOR UPDATE];

        if (String.isBlank(sJob.Batch_Ids_json_gne__c)) {
            sJob.Batch_Ids_json_gne__c = '["' + batchId + '"]';
        } else {
            List<String> bIds = (List<String>) JSON.deserialize(sJob.Batch_Ids_json_gne__c, List<String>.class);
            bIds.add(batchId);
            sJob.Batch_Ids_json_gne__c = JSON.serialize(bIds);
        }
        update sJob;
    }

}