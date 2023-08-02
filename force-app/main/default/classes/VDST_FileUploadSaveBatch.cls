/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Batch class for saving Batch Records
*/
global class VDST_FileUploadSaveBatch implements Database.Batchable<sObject>, Database.Stateful {
        private static final Logger log = Logger.getInstance(VDST_FileUpload_Utils.class.getName());
        global Integer MAX_NUMBER_OF_PROCESSED_FILES = 10;
        global Decimal MAX_RECORDS_TO_TRANSFER = 30000;

        global List<VDST_BatchFile_gne__c>      batchFilesList;
        global List<Id>                         fileIds;
        global Map<String, String>              eventToExpenseTypeMap;
        global Map<String, String>              mapson;

        global Map<String, Map<String, String>> mappingFileIdToRoleMap;

        /** @date 12/2/2013
        * @Author Konrad Malinowski
        * @description Method for initiating batch and returning records to process
        * @param Database.BatchableContext BC
        * @return Database.QueryLocator
        */
        global Database.QueryLocator start(Database.BatchableContext BC) {
            getBatchFilesToProcess();
            checkEventAndParticipantIdUniqueness();
            setAdditionalObjects();
            setFilesStatusBeforeProcessing();

            return Database.getQueryLocator(
            [SELECT Id, Name, AccountablePartyFirstName_gne__c, AccountablePartyID_gne__c, AccountablePartyLastName_gne__c,
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
            FROM    VDST_BatchRecord_gne__c
            WHERE   ( VDST_BatchFile_gne__c IN :fileIds AND VDST_BatchFile_gne__c != null )
            AND     IsDeleted = false]);
        }

        /** @date 12/2/2013
        * @Author Konrad Malinowski
        * @description Method for getting list of Batch Files to process
        */
        global void getBatchFilesToProcess() {
            List<VDST_BatchFile_gne__c> batchFilesInit =
            [SELECT   Id, VDST_EventProvider_gne__c, EventType_gne__c, Status_gne__c, AllBatchRecords_frm_gne__c
            FROM     VDST_BatchFile_gne__c
            WHERE    Status_frm_gne__c = 'To process'
            AND      isDeleted_gne__c = false
            AND      IsDeleted = false
            ORDER BY LastModifiedDate
            LIMIT    :MAX_NUMBER_OF_PROCESSED_FILES];

            batchFilesList = new List<VDST_BatchFile_gne__c>();
            fileIds = new List<String>();
            Decimal allRecords = 0;
            for(VDST_BatchFile_gne__c bf : batchFilesInit) {
                allRecords += bf.AllBatchRecords_frm_gne__c;
                if(allRecords > MAX_RECORDS_TO_TRANSFER) {
                    break;
                }
                batchFilesList.add(bf);
                fileIds.add(bf.Id);
            }
        }

        /** @date 12/2/2013
        * @Author Konrad Malinowski
        * @description Method for checking Batch Events and Batch Participants uniqueness in database
        */
        global void checkEventAndParticipantIdUniqueness() {
            List<VDST_BatchRecord_gne__c> eventRecords =
            [SELECT Id, EventId_gne__c
            FROM VDST_BatchRecord_gne__c
            WHERE VDST_BatchFile_gne__c IN :fileIds AND isEvent_gne__c = true];
            List<VDST_BatchRecord_gne__c> prtcpntRecords =
            [SELECT Id, ParticipantID_gne__c
            FROM VDST_BatchRecord_gne__c
            WHERE VDST_BatchFile_gne__c IN :fileIds AND isEvent_gne__c = false];
            if(!VDST_FileUpload_Utils.isEventAndParticipantIdUnique(eventRecords, prtcpntRecords)) {
                System.debug(LoggingLevel.ERROR, 'Found existing Event or Participant Id');
                log.log('Found existing Event or Participant Id', 'duplicates found', 'duplicates found');
                clearFilesListToProcess();
                throw new VDST_FileUpload_Utils.VdstException('Found existing Event or Participant Id');
            }
            if(eventAndParticipantIdDuplicatesExistsInFiles(eventRecords, prtcpntRecords)) {
                clearFilesListToProcess();
                log.log('checkEventAndParticipantIdUniqueness', 'duplicates found', 'duplicates found');
                throw new VDST_FileUpload_Utils.VdstException('eventAndParticipantIdDuplicatesExistsInFiles');
            }
        }

        /** @date 12/2/2013
        * @Author Konrad Malinowski
        * @description Method for clearing list of Batch Files
        */
        global void clearFilesListToProcess() {
            batchFilesList = new List<VDST_BatchFile_gne__c>();
            fileIds = new List<String>();
        }

        /** @date 12/2/2013
        * @Author Konrad Malinowski
        * @description Method for checking Batch Events and Batch Participants uniqueness in file
        * @param List<VDST_BatchRecord_gne__c> events
        * @param List<VDST_BatchRecord_gne__c> participants
        * @return String
        */
        global Boolean eventAndParticipantIdDuplicatesExistsInFiles(List<VDST_BatchRecord_gne__c> events, List<VDST_BatchRecord_gne__c> participants) {
            Set<String> eventIdSet = new Set<String>();
            Set<String> participantIdSet = new Set<String>();
            for(VDST_BatchRecord_gne__c ev : events) {
                if(eventIdSet.contains(ev.EventId_gne__c)) {
                    System.debug(LoggingLevel.ERROR, 'Duplicate Event Id: ' + ev.EventId_gne__c);
                    log.log('eventAndParticipantIdDuplicatesExistsInFiles', 'Duplicate Event Id', 'Duplicate Event Id: ' + ev.EventId_gne__c);
                    return true;
                }
                eventIdSet.add(ev.EventId_gne__c);
            }
            for(VDST_BatchRecord_gne__c prt : participants) {
                if(participantIdSet.contains(prt.ParticipantID_gne__c)) {
                    log.log('eventAndParticipantIdDuplicatesExistsInFiles', 'Duplicate Participant Id', 'Duplicate Participant Id: ' + prt.ParticipantID_gne__c);
                    System.debug(LoggingLevel.ERROR, 'Duplicate Participant Id: ' + prt.ParticipantID_gne__c);
                    return true;
                }
                participantIdSet.add(prt.ParticipantID_gne__c);
            }
            return false;
        }

        /** @date 12/2/2013
        * @Author Konrad Malinowski
        * @description Method for setting Batch File status before start processing
        */
        global void setFilesStatusBeforeProcessing() {
            for(VDST_BatchFile_gne__c bf : batchFilesList) {
                bf.Status_gne__c = 'Transfering';
                bf.ProcessStartDate_gne__c = DateTime.now();
                bf.ProcessEndDate_gne__c = null;
            }
            update batchFilesList;
        }

        /** @date 12/2/2013
        * @Author Konrad Malinowski
        * @description Method for setting useful objects for processing
        */
        global void setAdditionalObjects() {
            eventToExpenseTypeMap = VDST_Utils.eventToExpenseTypeMap();
            mapson = new Map<String,String>();

            Map<String, Map<String, String>> mappingEventTypedToRoleMap  = new Map<String, Map<String, String>>();
            mappingFileIdToRoleMap      = new Map<String, Map<String, String>>();

            for(VDST_BatchFile_gne__c bf : batchFilesList) {
                if(!mappingEventTypedToRoleMap.containsKey(bf.EventType_gne__c)) {
                    mappingEventTypedToRoleMap.put(bf.EventType_gne__c, VDST_Utils.getBatchRoleMap(bf.EventType_gne__c));
                }
                mappingFileIdToRoleMap.put(bf.Id, mappingEventTypedToRoleMap.get(bf.EventType_gne__c));
            }
        }

        /** @date 12/2/2013
        * @Author Konrad Malinowski
        * @description Method for executing batch
        * @param Database.BatchableContext BC
        * @param List<sObject> scope
        */
        global void execute(Database.BatchableContext BC, List<sObject> scope) {
            System.debug(LoggingLevel.ERROR,
                    'DML Rows: ' + Limits.getDMLRows() + ', ' +
                            'DML Statements: ' + Limits.getDMLStatements() + ', ' +
                            'SOQL Rows: ' + Limits.getQueryRows() + ', ' +
                            'SOQL Queries: ' + Limits.getQueries() + ', '
            );

            List<VDST_BatchRecord_gne__c> evRecs = new List<VDST_BatchRecord_gne__c>();
            List<VDST_BatchRecord_gne__c> prtRecs = new List<VDST_BatchRecord_gne__c>();
            for(VDST_BatchRecord_gne__c br : (List<VDST_BatchRecord_gne__c>)scope) {
                if(br.isEvent_gne__c) {
                    evRecs.add(br);
                } else {
                    prtRecs.add(br);
                }
            }
            VDST_FileUpload_Utils.isEventAndParticipantIdUnique(evRecs, prtRecs);

            Map<String, List<VDST_BatchRecord_gne__c>> mappingFileIdToBatchRecords = new Map<String, List<VDST_BatchRecord_gne__c>>();
            List<VDST_BatchRecord_gne__c> batchRecList;
            for(VDST_BatchRecord_gne__c br : (List<VDST_BatchRecord_gne__c>)scope) {
                if(mappingFileIdToBatchRecords.containsKey(br.VDST_BatchFile_gne__c)) {
                    batchRecList = mappingFileIdToBatchRecords.get(br.VDST_BatchFile_gne__c);
                    batchRecList.add(br);
                } else {
                    mappingFileIdToBatchRecords.put(br.VDST_BatchFile_gne__c, new List<VDST_BatchRecord_gne__c>{ br });
                }
            }
            List<VDST_BatchRecord_gne__c> eventRecords = new List<VDST_BatchRecord_gne__c>();
            for(String fileId : mappingFileIdToBatchRecords.keySet()) {
                List<VDST_BatchRecord_gne__c> brRecords = mappingFileIdToBatchRecords.get(fileId);
                List<VDST_BatchRecord_gne__c> fileEvents = new List<VDST_BatchRecord_gne__c>();
                for(VDST_BatchRecord_gne__c brRecord: brRecords){
                    if(brRecord.isEvent_gne__c){
                        fileEvents.add(brRecord);
                        eventRecords.add(brRecord);
                    }
                }
                mapson.putAll(VDST_FileUpload_Utils.createEventObjects(fileEvents));
            }
            for(VDST_BatchRecord_gne__c br : eventRecords) {
                br.isTransfered_gne__c = true;
            }
            update eventRecords;

            System.debug(LoggingLevel.ERROR,
                    'DML Rows: ' + Limits.getDMLRows() + ', ' +
                            'DML Statements: ' + Limits.getDMLStatements() + ', ' +
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
            VDST_FileUploadSaveAttendeesBatch fileUploadSaveBatch = new VDST_FileUploadSaveAttendeesBatch(batchFilesList, fileIds, eventToExpenseTypeMap, mapson, mappingFileIdToRoleMap);
            ID batchProcessId = Database.executeBatch(fileUploadSaveBatch, 100);
            System.debug(batchProcessId);
        }

    }