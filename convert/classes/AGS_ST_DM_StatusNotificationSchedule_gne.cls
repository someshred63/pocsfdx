global class AGS_ST_DM_StatusNotificationSchedule_gne implements Schedulable {

    global void execute(SchedulableContext sc) {
        AGS_CaseUtility.abortCompletedJobs('AGS_ST_DM_StatusNotificationSchedule_gne');
        AGS_ST_DM_StatusNotificationBatch_gne statusNotificationBatch = new AGS_ST_DM_StatusNotificationBatch_gne();
        ID batchprocessid = Database.executeBatch(statusNotificationBatch, 100);
        AGS_CaseUtility.insertBatchStartedErrorLog(batchprocessid, 'AGS_ST_DM_StatusNotificationSchedule_gne', 'AGS_ST_DM_StatusNotificationBatch_gne started, Batch id :');
    }
}