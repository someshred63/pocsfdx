/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Scheduler for VDST_FileUploadProcessBatchRecords class
*/
global class VDST_FileUploadProcBatchRecsScheduler implements Schedulable {
    /** @date 12/2/2013
	* @Author Konrad Malinowski
    * @description Method for executing scheduler
    * @param SchedulableContext sc
    */
    global void execute(SchedulableContext sc) {
        if(VDST_FileUpload_Utils.getNumberOfActiveBatchApexJobs() > VDST_FileUpload_Utils.MAX_ACTIVE_BATCH_APEX_JOBS) {
            return;
        }

        VDST_FileUploadProcessBatchRecords fileUploadProcessBatchRecords = new VDST_FileUploadProcessBatchRecords();
        ID batchProcessId = Database.executeBatch(fileUploadProcessBatchRecords, 200);
        System.debug(batchProcessId);
    }
}