/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Batch class for deleting Batch Files
*/
global class VDST_FileUploadDeleteBatchFile implements Database.Batchable<sObject>, Database.Stateful {
    global List<VDST_BatchFile_gne__c> filesToDelete;

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for initiating batch and returning records to process
    * @param Database.BatchableContext BC
    * @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        filesToDelete = [
            SELECT Id
            FROM VDST_BatchFile_gne__c
            WHERE isDeleted_gne__c = true
            AND IsDeleted = false
            ORDER BY LastModifiedDate
            LIMIT 4000
        ];
        List<Id> fileIds = new List<Id>();
        for(VDST_BatchFile_gne__c bf : filesToDelete) {
            fileIds.add(bf.Id);
        }
        return Database.getQueryLocator([
            SELECT Id
            FROM VDST_BatchRecord_gne__c
            WHERE VDST_BatchFile_gne__c IN :fileIds
            AND IsDeleted = false
        ]);
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for executing batch
    * @param Database.BatchableContext BC
    * @param List<sObject> scope
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
        Database.emptyRecycleBin( scope );
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for invocation when batch processing is finished
    * @param Database.BatchableContext BC
    */
    global void finish(Database.BatchableContext BC){
        // remain batch files for Event and Participant Created By custom fields
        /*delete filesToDelete;
        Boolean thereAreFilesToDelete = ( filesToDelete != null && filesToDelete.size() > 0 );
        if(thereAreFilesToDelete) {
            Database.emptyRecycleBin( filesToDelete );
        }*/
    }
}