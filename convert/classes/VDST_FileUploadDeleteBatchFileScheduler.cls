/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Scheduler for VDST_FileUploadDeleteBatchFile class
*/
global class VDST_FileUploadDeleteBatchFileScheduler implements Schedulable {
    
    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for executing scheduler
    * @param SchedulableContext sc
    */
    global void execute(SchedulableContext sc) {
        if(VDST_FileUpload_Utils.getNumberOfActiveBatchApexJobs() > VDST_FileUpload_Utils.MAX_ACTIVE_BATCH_APEX_JOBS) {
            return;
        }

        ID batchProcessId = Database.executeBatch(
            new VDST_FileUploadDeleteBatchFile(),
            200
        );
        System.debug(batchProcessId);
    }
}