/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Scheduler for VDST_FileUploadSaveBatch class
*/
global class VDST_FileUploadSaveScheduler implements Schedulable {
    
    /** @date 12/2/2013
	* @Author Konrad Malinowski
    * @description Method for executing scheduler
    * @param SchedulableContext sc
    */
    global void execute(SchedulableContext sc) {
        if(VDST_FileUpload_Utils.getNumberOfActiveBatchApexJobs() > VDST_FileUpload_Utils.MAX_ACTIVE_BATCH_APEX_JOBS) {
            return;
        }

        VDST_FileUploadSaveBatch fileUploadSaveBatch = new VDST_FileUploadSaveBatch();
        ID batchProcessId = Database.executeBatch(fileUploadSaveBatch, 100);
        System.debug(batchProcessId);
    }
}