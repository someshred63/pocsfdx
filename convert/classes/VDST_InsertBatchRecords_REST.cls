/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Rest WebService for inserting batch records
*/
@RestResource(urlMapping='/VDST_InsertBatchRecords_REST/*')
global with sharing class VDST_InsertBatchRecords_REST {  
    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for processing REST request
    * @param List<VDST_BatchRecord_gne__c> sobjs
    * @param Boolean isBigBatch
    * @return Result
    */
    @HttpPost
    global static Result processRequest(List<VDST_BatchRecord_gne__c> sobjs, Boolean isBigBatch) {
        try {
            if(isBigBatch) {
                processBigBatch( sobjs );
            } else {
                processSmallBatch( sobjs );
            }
        } catch(Exception ex) {
            return new Result(
                false,
                VDST_FileUpload_Utils.getErrorMessageFromException(ex),
                ex.getStackTraceString()
            );
        }
        return new Result(true);
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for processing Big Batch (with at least 200 Batch Records)
    * @param List<VDST_BatchRecord_gne__c> sobjs
    */
    private static void processBigBatch(List<VDST_BatchRecord_gne__c> sobjs) {
        insert sobjs;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for processing Small Batch (with less 200 Batch Records)
    * @param List<VDST_BatchRecord_gne__c> sobjs
    */
    private static void processSmallBatch(List<VDST_BatchRecord_gne__c> sobjs) {
        VDST_FileUpload_Utils.BatchRecordsProcessorBeforeDML processor =
            new VDST_FileUpload_Utils.BatchRecordsProcessorBeforeDML( sobjs );
        processor.process();
        insert processor.events;

        Map<String, String> eventVendorIdToSfdcId = new Map<String, String>();
        for(VDST_BatchRecord_gne__c ev : processor.events) {
            eventVendorIdToSfdcId.put(ev.EventId_gne__c, ev.Id);
        }
        for(VDST_BatchRecord_gne__c prtcp : processor.participants) {
            if( eventVendorIdToSfdcId.containsKey( prtcp.EventId_gne__c ) ) {
                prtcp.VDST_ParentEvent_gne__c = eventVendorIdToSfdcId.get(prtcp.EventId_gne__c);
            }
        }
        insert processor.participants;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Wrapper class for result
    */
    global class Result {
        public Boolean success { get; set; }
        public String errorMsg { get; set; }
        public String stackTrace { get; set; }

        public Result(Boolean success) {
            this.success = success;
            this.errorMsg = '';
            this.stackTrace = '';
        }

        public Result(Boolean success, String errorMsg, String stackTrace) {
            this(success);
            this.errorMsg = errorMsg;
            this.stackTrace = stackTrace;
        }
    }
}