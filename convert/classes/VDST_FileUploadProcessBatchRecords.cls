/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Batch class for processing Batch Records inserted from JavaScript as "Big Batch" (more then 200 Batch Records per file)
*/
global class VDST_FileUploadProcessBatchRecords implements Database.Batchable<sObject>, Database.Stateful {
    global Decimal PROCESSED_RECORDS_LIMIT = 30000;
    global Map<Id, VDST_BatchFile_gne__c> processedFilesMap;
    global Map<String, String> eventVendorIdToSfdcId;

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for initiating batch and returning records to process
    * @param Database.BatchableContext BC
    * @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC){
        setStartProcessFiles();
        createMapEventVendorIdToSfdcId();

        return Database.getQueryLocator([
            SELECT  isValid__c, isEvent_gne__c, VenueType_gne__c, VenueStreetAddress_gne__c,
                    VenueState_gne__c, VenuePostalCode_gne__c, VenueName_gne__c, VenueCountry_gne__c,
                    VenueCity_gne__c, ValidParticipants_gne__c, VDST_ParentEvent_gne__c, VDST_BatchFile_gne__c,
                    TOVType_gne__c, TOVItemName_gne__c, TOVAmount_gne__c, Suffix_gne__c,
                    StateLicenseNumber_gne__c, Quantity_gne__c, Profession_gne__c, Phone_gne__c,
                    ParticipantStreetAddress_gne__c,  ParticipantStreetAddress2_gne__c,
                    ParticipantState_gne__c, ParticipantRole_gne__c, ParticipantPostalCode_gne__c,
                    ParticipantCountry_gne__c, ParticipantCity_gne__c, NumberOfRecs__c, Name,
                    NPI_gne__c, MiddleName_gne__c, MeetingName_gne__c, LicenseState_gne__c,
                    LastName_gne__c, InvalidParticipants_gne__c, Id, FirstName_gne__c, EventType_gne__c,
                    EventStartDate_gne__c, EventId_gne__c, Email_gne__c, Credential_gne__c,
                    Brands_gne__c, Affiliation_gne__c, AccountablePartyID_gne__c,
                    AccountablePartyFirstName_gne__c, AccountablePartyLastName_gne__c, BrandsId_gne__c,
                    Email_txt_gne__c, EventStartDate_txt_gne__c, IsAfterBatchProcessing_gne__c,
                    Quantity_txt_gne__c, Suffix_txt_gne__c, TOVAmount_txt_gne__c, TOVType_txt_gne__c,
                    VenueType_txt_gne__c, TotPlanAttCntUser_gne__c, TotPlanAttCntUser_txt_gne__c,
                    TOVMealLoc_gne__c, TOVMealLoc_txt_gne__c
            FROM    VDST_BatchRecord_gne__c
            WHERE   VDST_BatchFile_gne__c IN :processedFilesMap.keySet()
            AND     IsDeleted = false
        ]);
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for getting list of Batch Files to process
    */
    private void setStartProcessFiles() {
        List<VDST_BatchFile_gne__c> allNewFilesToProcess = [
            SELECT  Id, AllBatchRecords_frm_gne__c
            FROM    VDST_BatchFile_gne__c
            WHERE   Status_frm_gne__c = 'New'
            AND     isFullyUploaded_gne__c = true
            AND     IsDeleted = false
            AND     isDeleted_gne__c = false
            ORDER BY CreatedDate
        ];
        Decimal numberOfRecordsToProcess = 0;
        Set<Id> filesIdToProcess = new Set<Id>();
        for(VDST_BatchFile_gne__c bFile : allNewFilesToProcess) {
            if( ( numberOfRecordsToProcess + bFile.AllBatchRecords_frm_gne__c ) <= PROCESSED_RECORDS_LIMIT ) {
                numberOfRecordsToProcess += bFile.AllBatchRecords_frm_gne__c;
                filesIdToProcess.add(bFile.Id);
            } else {
                break;
            }
        }

        processedFilesMap = new Map<Id, VDST_BatchFile_gne__c>([
            SELECT  Id, Status_gne__c, ProcessStartDate_gne__c, ProcessEndDate_gne__c
            FROM    VDST_BatchFile_gne__c
            WHERE   Id IN :filesIdToProcess
        ]);
        DateTime now = System.now();
        for(VDST_BatchFile_gne__c bf : processedFilesMap.values()) {
            bf.ProcessStartDate_gne__c = now;
        }
        update processedFilesMap.values();
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for creating map of Event Vendor Id to Event SFDC Id
    */
    private void createMapEventVendorIdToSfdcId() {
        eventVendorIdToSfdcId = new Map<String, String>();
        for(VDST_BatchRecord_gne__c event : [
            SELECT  Id, EventId_gne__c
            FROM    VDST_BatchRecord_gne__c
            WHERE   VDST_BatchFile_gne__c IN :processedFilesMap.keySet()
            AND     isEvent_gne__c = true
            AND     IsDeleted = false
        ]) {
            eventVendorIdToSfdcId.put(event.EventId_gne__c, event.Id);
        }
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for executing batch
    * @param Database.BatchableContext BC
    * @param List<sObject> scope
    */
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        VDST_FileUpload_Utils.BatchRecordsProcessorBeforeDML processor =
            new VDST_FileUpload_Utils.BatchRecordsProcessorBeforeDML( (List<VDST_BatchRecord_gne__c>)scope );
        processor.process();

        for(VDST_BatchRecord_gne__c rec : processor.participants) {
            setParticipantEventParent( rec );
        }

        update scope;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for setting Batch Event parent Id for Batch Participant 
    * @param Database.BatchableContext BC
    * @param List<sObject> scope
    */
    private void setParticipantEventParent(VDST_BatchRecord_gne__c rec) {
        if(eventVendorIdToSfdcId.containsKey(rec.EventId_gne__c)) {
            rec.VDST_ParentEvent_gne__c = eventVendorIdToSfdcId.get(rec.EventId_gne__c);
        }
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for invocation when batch processing is finished
    * @param Database.BatchableContext BC
    */
    global void finish(Database.BatchableContext BC){
        DateTime now = System.now();
        for(VDST_BatchFile_gne__c bf : processedFilesMap.values()) {
            bf.ProcessEndDate_gne__c = now;
        }
        update processedFilesMap.values();
    }
}