global class AGS_ST_HCP_Notification_Schedule implements Schedulable {
    
    global void execute(final SchedulableContext sc) {
        AGS_CaseUtility.abortCompletedJobs('AGS_ST_HCP_Notification_Schedule');
        AGS_CaseUtility.insertBatchStartedErrorLog(Database.executeBatch(
            (Database.Batchable<sObject>) Type.forName('AGS_ST_HCP_Notification_batch').newInstance(), 1
        ), 'AGS_ST_HCP_Notification_Schedule', 'AGS_ST_HCP_Notification_batch started: ');
    }
}