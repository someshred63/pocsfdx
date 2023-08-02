global class AGS_ST_DM_ChangingStatusScheduler_gne implements Schedulable {

    global void execute(SchedulableContext sc) {
        AGS_CaseUtility.abortCompletedJobs('AGS_ST_DM_ChangingStatusScheduler_gne');
        AGS_ST_DM_ChangingStatusBatch_gne changingStatusBatch = new AGS_ST_DM_ChangingStatusBatch_gne();
        ID batchprocessid = Database.executeBatch(changingStatusBatch, 100);
        AGS_CaseUtility.insertBatchStartedErrorLog(batchprocessid, 'AGS_ST_DM_ChangingStatusScheduler_gne', 'AGS_ST_DM_ChangingStatusBatch_gne started, Batch id :');
    }
}