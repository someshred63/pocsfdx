/**
 * Created by kozminsl on 23.02.2022.
 */
global class VDST_FileUploadSaveAttendeesBatch implements Database.Batchable<SObject>, Database.Stateful {
    global List<VDST_BatchFile_gne__c> batchFilesList;
    global List<Id> fileIds;
    global Map<String, String> eventToExpenseTypeMap;
    global Map<String, String> mapson;
    global Map<String, Map<String, String>> mappingFileIdToRoleMap;

    public VDST_FileUploadSaveAttendeesBatch(List<VDST_BatchFile_gne__c> batchFilesList, List<Id> fileIds, Map<String, String> eventToExpenseTypeMap, Map<String, String> mapson, Map<String, Map<String, String>> mappingFileIdToRoleMap) {
        this.batchFilesList = batchFilesList;
        this.fileIds = fileIds;
        this.eventToExpenseTypeMap = eventToExpenseTypeMap;
        this.mapson = mapson;
        this.mappingFileIdToRoleMap = mappingFileIdToRoleMap;
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for initiating batch and returning records to process
    * @param Database.BatchableContext BC
    * @return Database.QueryLocator
    */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
        [
                SELECT Id, Name, AccountablePartyFirstName_gne__c, AccountablePartyID_gne__c, AccountablePartyLastName_gne__c,
                        Affiliation_gne__c, Brands_gne__c, BrandsId_gne__c, CreatedById, CreatedDate, Credential_gne__c,
                        Email_gne__c, EventId_gne__c, EventStartDate_gne__c, EventStartDate_txt_gne__c, EventType_gne__c,
                        FirstName_gne__c, InvalidParticipants_gne__c, IsAfterBatchProcessing_gne__c, IsDeleted, isEvent_gne__c,
                        IsLocked, isValid__c, LastModifiedById, LastModifiedDate, LastName_gne__c, LicenseState_gne__c,
                        MayEdit, MeetingName_gne__c, MiddleName_gne__c, NPI_gne__c, NumberOfRecs__c, ParticipantCity_gne__c,
                        ParticipantCountry_gne__c, ParticipantID_gne__c, ParticipantPostalCode_gne__c, ParticipantRole_gne__c,
                        ParticipantState_gne__c, ParticipantStreetAddress2_gne__c, ParticipantStreetAddress_gne__c, Phone_gne__c,
                        Profession_gne__c, Quantity_gne__c, Quantity_txt_gne__c, StateLicenseNumber_gne__c, Suffix_gne__c,
                        Suffix_txt_gne__c, SystemModstamp, TOVAmount_gne__c, TOVAmount_txt_gne__c, TOVItemName_gne__c,
                        TOVType_gne__c, TOVType_txt_gne__c, ValidParticipants_gne__c, VDST_BatchFile_gne__c, VDST_ParentEvent_gne__c,
                        VDST_ParentEvent_gne__r.TOVAmount_gne__c, VenueCity_gne__c, VenueCountry_gne__c, VenueName_gne__c,
                        VenuePostalCode_gne__c, VenueState_gne__c, VenueStreetAddress2_gne__c, VenueStreetAddress_gne__c,
                        VenueType_gne__c, VenueType_txt_gne__c, VDST_BatchFile_gne__r.VDST_EventProvider_gne__c, isTransfered_gne__c,
                        TotPlanAttCntUser_gne__c, TotPlanAttCntUser_txt_gne__c, TOVMealLoc_gne__c, TOVMealLoc_txt_gne__c
                FROM VDST_BatchRecord_gne__c
                WHERE (VDST_BatchFile_gne__c IN :fileIds AND VDST_BatchFile_gne__c != NULL )
                AND IsDeleted = FALSE
                AND isEvent_gne__c = FALSE
        ]);
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for executing batch
    * @param Database.BatchableContext BC
    * @param List<sObject> scope
    */
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        System.debug(LoggingLevel.ERROR,
                'DML Rows: ' + Limits.getDmlRows() + ', ' +
                        'DML Statements: ' + Limits.getDmlStatements() + ', ' +
                        'SOQL Rows: ' + Limits.getQueryRows() + ', ' +
                        'SOQL Queries: ' + Limits.getQueries() + ', '
        );

        Map<String, List<VDST_BatchRecord_gne__c>> mappingFileIdToBatchRecords = new Map<String, List<VDST_BatchRecord_gne__c>>();
        List<VDST_BatchRecord_gne__c> batchRecList;
        for (VDST_BatchRecord_gne__c br : (List<VDST_BatchRecord_gne__c>) scope) {
            if (mappingFileIdToBatchRecords.containsKey(br.VDST_BatchFile_gne__c)) {
                batchRecList = mappingFileIdToBatchRecords.get(br.VDST_BatchFile_gne__c);
                batchRecList.add(br);
            } else {
                mappingFileIdToBatchRecords.put(br.VDST_BatchFile_gne__c, new List<VDST_BatchRecord_gne__c>{
                        br
                });
            }
        }

        for (String fileId : mappingFileIdToBatchRecords.keySet()) {
            List<VDST_BatchRecord_gne__c> brRecords = mappingFileIdToBatchRecords.get(fileId);
            VDST_FileUpload_Utils.createPrtcpntObjects(brRecords, mapson, mappingFileIdToRoleMap.get(fileId), eventToExpenseTypeMap);
        }
        for (VDST_BatchRecord_gne__c br : (List<VDST_BatchRecord_gne__c>) scope) {
            br.isTransfered_gne__c = true;
        }
        update (List<VDST_BatchRecord_gne__c>) scope;

        System.debug(LoggingLevel.ERROR,
                'DML Rows: ' + Limits.getDmlRows() + ', ' +
                        'DML Statements: ' + Limits.getDmlStatements() + ', ' +
                        'SOQL Rows: ' + Limits.getQueryRows() + ', ' +
                        'SOQL Queries: ' + Limits.getQueries() + ', '
        );
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for invocation when batch processing is finished
    * @param Database.BatchableContext BC
    */
    global void finish(Database.BatchableContext BC) {
        setFilesStatusAfterProcessing();
    }

    /** @date 12/2/2013
    * @Author Konrad Malinowski
    * @description Method for setting Batch Files status after processing
    */
    global void setFilesStatusAfterProcessing() {
        for (VDST_BatchFile_gne__c bf : batchFilesList) {
            bf.Status_gne__c = 'Stored';
            bf.ProcessEndDate_gne__c = Datetime.now();
        }
        update batchFilesList;
    }
}