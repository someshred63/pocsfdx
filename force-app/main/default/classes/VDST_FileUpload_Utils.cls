/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Util Class for FIle Upload functionality
*/
public without sharing class VDST_FileUpload_Utils {
    private static final Logger log = Logger.getInstance(VDST_FileUpload_Utils.class.getName());

    // -------------------------------------------------------------------------
    // ----------------------------- VARIABLES ---------------------------------
    // -------------------------------------------------------------------------
    public static Integer MAX_ACTIVE_BATCH_APEX_JOBS = 5;
    public static VDST_EventDetailCommon commonUtils = new VDST_EventDetailCommon();

    // -------------------------------------------------------------------------
    // --------------------------- UTILITY METHODS -----------------------------
    // -------------------------------------------------------------------------
    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting countries
    */
    public static List<SelectOption> getCountries() {
        List<SelectOption> result = new List<SelectOption>{ new SelectOption('', '-Select-') };
        result.addAll(
            VDST_Utils.getMappedSelectOption(
                VDST_Address_gne__c.Country_gne__c.getDescribe(),
                VDST_Mapping_gne__c.getAll()
            )
        );
        return result;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting expense types
    */
    public static List<SelectOption> getExpenseTypes() {
        List<SelectOption> result = new List<SelectOption>{ new SelectOption('', '-Select-') };
        result.addAll(
            VDST_Utils.getPickListValues(
                VDST_BatchRecord_gne__c.TOVType_gne__c.getDescribe()
            )
        );
        return result;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting venue types
    */
    public static List<SelectOption> getVenueTypes() {
        List<SelectOption> result = new List<SelectOption>{ new SelectOption('', '-Select-') };
        result.addAll(
            VDST_Utils.getPickListValues(
                VDST_BatchRecord_gne__c.VenueType_gne__c.getDescribe()
            )
        );
        return result;
    }

    public static List<SelectOption> getMealTypes() {
        List<SelectOption> result = new List<SelectOption>{ new SelectOption('', '-Select-') };
        result.addAll(
                VDST_Utils.getPickListValues(
                        VDST_BatchRecord_gne__c.TOVMealLoc_gne__c.getDescribe()
                )
        );
        return result;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting participant roles by batch event id
    */
    public static List<SelectOption> getParticipantRoles(String btchEventId) {
        String eventType = getEventTypeByBatchEventId(btchEventId);
        List<SelectOption> prtcpntRoles = new List<SelectOption>{new SelectOption('', '-Select-')};
        for(VDST_EventPrtcpntRole_gne__c roles : VDST_Utils.getVendorCodeList(eventType)) {
            if(roles.EventParticipantRoleCode_gne__c != 'INTRNL') {
                prtcpntRoles.add(new SelectOption(roles.EventParticipantRoleCode_gne__c, roles.EventParticipantRoleName__c));
            }
        }
        return prtcpntRoles;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting map of event type to participant roles list
    */
    public static Map<String, List<SelectOption>> getEventTypeToParticipantRolesSelOptsMap() {
        try {
            Map<String, List<SelectOption>> mapEvToPartRoles = new Map<String, List<SelectOption>>();
            List<VDST_EventPrtcpntRole_gne__c> prtcpRoles = [
                SELECT EventType_gne__c, EventParticipantRoleCode_gne__c, EventParticipantRoleName__c
                FROM VDST_EventPrtcpntRole_gne__c
            ];
            List<SelectOption> selOpts;
            SelectOption so;
            for(VDST_EventPrtcpntRole_gne__c prtcpRole : prtcpRoles) {
                if(prtcpRole.EventParticipantRoleCode_gne__c != 'INTRNL') {
                    so = new SelectOption(prtcpRole.EventParticipantRoleCode_gne__c, prtcpRole.EventParticipantRoleName__c);
                    if(mapEvToPartRoles.containsKey(prtcpRole.EventType_gne__c)) {
                        selOpts = mapEvToPartRoles.get(prtcpRole.EventType_gne__c);
                        if(!selectOptionsContainsValue(selOpts, so)) {
                            selOpts.add(so);
                        }
                    } else {
                        mapEvToPartRoles.put(prtcpRole.EventType_gne__c, new List<SelectOption>{ so });
                    }
                }
            }
            return mapEvToPartRoles;
        } catch(Exception ex) {
            return new Map<String, List<SelectOption>>();
        }
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for checking if select options list contains select option
    */
    public static Boolean selectOptionsContainsValue(List<SelectOption> selOpts, SelectOption val) {
        for(SelectOption so : selOpts) {
            if(so.getValue() == val.getValue()) {
                return true;
            }
        }
        return false;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting suffixes
    */
    public static List<SelectOption> getSuffixes() {
        List<SelectOption> result = new List<SelectOption>{ new SelectOption('', '-Select-') };
        result.addAll(
            VDST_Utils.getPickListValues(
                VDST_BatchRecord_gne__c.Suffix_gne__c.getDescribe()
            )
        );
        return result;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting event type by batch event id
    */
    public static String getEventTypeByBatchEventId(String btchEventId) {
        try {
            return [
                SELECT  EventType_gne__c
                FROM    VDST_BatchRecord_gne__c
                WHERE   Id = :btchEventId
                LIMIT   1
            ].EventType_gne__c;
        } catch(QueryException e) {
            return '';
        }
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting professions
    */
    public static List<SelectOption> getProfessions() {
        return commonUtils.getProfessionSO();
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting credentials
    */
    public static List<SelectOption> getCredentials() {
        return commonUtils.getCredentialCodeMappingsSO();
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for creating map of drug names labels to drug name values
    */
    public static Map<String, String> createMapDrugNameUpperCaseToId() {
        Map<String, String> drugNameMap = new Map<String, String>();
        for(SelectOption so : VDST_Utils.getDrugNames()) {
            drugNameMap.put(so.getLabel().toUpperCase(), so.getValue());
        }
        return drugNameMap;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for checking if select options list contains value
    */
    public static SelectOption whenSelectOptionListContainsValueThenReturn(List<SelectOption> selOpts, String val) {
        if(selOpts == null || val == null) {
            return null;
        }
        for(SelectOption selOpt : selOpts) {
            if(selOpt.getLabel().toUpperCase().equals(val.toUpperCase())
            || selOpt.getValue().toUpperCase().equals(val.toUpperCase())) {
                return selOpt;
            }
        }
        return null;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting number of active apex jobs
    */
    public static Integer getNumberOfActiveBatchApexJobs() {
        try {
            return [
                SELECT  Id
                FROM    AsyncApexJob
                WHERE   Status IN ( 'Queued', 'Processing', 'Preparing' )
                AND     JobType = 'BatchApex'
            ].size();
        } catch(QueryException ex) {
            return 0;
        }
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Method for getting error info as string from Exception object
    */
    public static String getErrorMessageFromException(Exception ex) {
        return '[Line Nr: ' + ex.getLineNumber() + '], [Message: ' + ex.getMessage() + ']';
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for wrapping Batch Files objects into wrappers
    * @param List<VDST_BatchFile_gne__c> batchFileSObjs
    * @return List<BatchFileWrapper>
    */
    public static List<BatchFileWrapper> wrapBatchFileList(List<VDST_BatchFile_gne__c> batchFileSObjs) {
        List<BatchFileWrapper> batchFilesWrapped = new List<BatchFileWrapper>();
        for(VDST_BatchFile_gne__c btchFile : batchFileSObjs) {
            batchFilesWrapped.add( new BatchFileWrapper( btchFile ) );
        }
        return batchFilesWrapped;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for wrapping Batch Record objects into wrappers
    * @param List<VDST_BatchRecord_gne__c> batchRecSObjs
    * @return List<BatchRecordWrapper>
    */
    public static List<BatchRecordWrapper> wrapBatchRecordList(List<VDST_BatchRecord_gne__c> batchRecSObjs) {
        List<BatchRecordWrapper> batchRecordsWrapped = new List<BatchRecordWrapper>();
        for(VDST_BatchRecord_gne__c btchRec : batchRecSObjs) {
            batchRecordsWrapped.add( new BatchRecordWrapper( btchRec ) );
        }
        return batchRecordsWrapped;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for getting Batch Record object with Event data by Id
    * @param Id eventId
    * @return VDST_BatchRecord_gne__c
    */
    public static VDST_BatchRecord_gne__c getBatchRecordEvent(Id eventId) {
        VDST_BatchRecord_gne__c btchRec;
        try {
            btchRec = [
                SELECT  Id, AccountablePartyID_gne__c, FirstName_gne__c, LastName_gne__c, Brands_gne__c, EventStartDate_gne__c,
                        VenueType_gne__c, VenueCountry_gne__c, VenueName_gne__c, VenueStreetAddress_gne__c,
                        VenueCity_gne__c, VenueState_gne__c, VenuePostalCode_gne__c, TOVType_gne__c,
                        TOVAmount_gne__c, TOVMealLoc_gne__c, TOVItemName_gne__c, MeetingName_gne__c, EventStartDate_txt_gne__c,
                        VenueType_txt_gne__c, TOVType_txt_gne__c, TOVAmount_txt_gne__c, TOVMealLoc_txt_gne__c, EventType_gne__c,
                        BrandsId_gne__c, AccountablePartyFirstName_gne__c, AccountablePartyLastName_gne__c,
                        VDST_BatchFile_gne__r.Status_gne__c, isValidWithChildren_gne__c,
                        TotPlanAttCntUser_gne__c, TotPlanAttCntUser_txt_gne__c
                FROM    VDST_BatchRecord_gne__c
                WHERE   Id = :eventId
                LIMIT   1
            ];
        } catch(Exception ex) {
            btchRec = new VDST_BatchRecord_gne__c();
        }
        return btchRec;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for getting Batch Record object with Participant data by Id
    * @param Id participantId
    * @return VDST_BatchRecord_gne__c
    */
    public static VDST_BatchRecord_gne__c getBatchRecordParticipant(Id participantId) {
        VDST_BatchRecord_gne__c btchRec;
        try {
            btchRec = [
                SELECT  Id, ParticipantID_gne__c, ParticipantRole_gne__c, LastName_gne__c, FirstName_gne__c, MiddleName_gne__c,
                        Suffix_gne__c, Phone_gne__c, Email_gne__c, Affiliation_gne__c, Profession_gne__c,
                        Credential_gne__c, NPI_gne__c, StateLicenseNumber_gne__c, LicenseState_gne__c,
                        Quantity_gne__c, ParticipantCountry_gne__c, ParticipantStreetAddress_gne__c,
                        ParticipantStreetAddress2_gne__c, ParticipantCity_gne__c, ParticipantState_gne__c,
                        ParticipantPostalCode_gne__c, Suffix_txt_gne__c, Email_txt_gne__c,
                        Quantity_txt_gne__c, VDST_ParentEvent_gne__c, EventType_gne__c, VDST_BatchFile_gne__r.Status_gne__c
                FROM    VDST_BatchRecord_gne__c
                WHERE   Id = :participantId
                LIMIT   1
            ];
        } catch(Exception ex) {
            btchRec = new VDST_BatchRecord_gne__c();
        }
        return btchRec;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for getting status value by boolean variable
    * @param Boolean status
    * @return String
    */
    public static String getStatusName(Boolean status) {
        return (status ? 'Passed' : 'Failed');
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for getting Accountable Party data by Accountable Party Unix Id
    * @param String unixId
    * @return UserWrapper
    */
    public static UserWrapper getUserData(String unixId) {
        if(!''.equals(unixId)) {
            All_User_Hierarchy_gne__c auh = VDST_Utils.getUserData(unixId);
            if(auh != null) {
                return new UserWrapper(auh.FirstName_gne__c, auh.LastName_gne__c);
            } else {
                    return null;
            }
        } else {
            return new UserWrapper('', '');
        }
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for getting Batch File Wrapper from Batch File Id
    * @param Id batchFileId
    * @return BatchFileWrapper
    */
    public static BatchFileWrapper getBatchFileWrapperFromId(Id batchFileId) {
        List<VDST_BatchFile_gne__c> wrapFiles = new List<VDST_BatchFile_gne__c>();
        try {
            wrapFiles = [
                SELECT  Id, CreatedDate, Filename_gne__c, ProcessStartDate_gne__c,
                    ProcessEndDate_gne__c, Status_gne__c, BatchRecords_gne__c,
                    Status_frm_gne__c, AllBatchRecords_frm_gne__c, EventType_gne__c,
                    BatchEvents_frm_gne__c, PassedValidations_frm_gne__c, FailedValidations_frm_gne__c,
                    TransferedRecords_gne__c
                FROM    VDST_BatchFile_gne__c
                WHERE   Id = :batchFileId
            ];
        } catch(Exception ex) {}
        return ( ( wrapFiles.size() == 1 ) ? wrapBatchFileList(wrapFiles)[0] : new BatchFileWrapper(new VDST_BatchFile_gne__c() ) );
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for getting Batch File Wrappers
    * @param VDST_PagingUtils filePaginationUtil
    * @return List<BatchFileWrapper>
    */
    public static List<BatchFileWrapper> getBatchFileWrappers(VDST_PagingUtils filePaginationUtil) {
        List<VDST_FileUpload_Utils.BatchFileWrapper> bfw;
        try {
                ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(
                    Database.query(
                        'SELECT  Id ' +
                        'FROM    VDST_BatchFile_gne__c ' +
                        'WHERE   isDeleted_gne__c = false AND OwnerId = \'' + UserInfo.getUserId() + '\' ' +
                        'ORDER BY CreatedDate DESC LIMIT 10000 '
                    )
                );
                // Get File Id's for particular page
                filePaginationUtil.setParameters(setCon.getResultSize());
                setCon.setPageSize(filePaginationUtil.perPage);
                setCon.first();
                for(Integer i = 1; i < filePaginationUtil.actualPage; i++) {
                    setCon.next();
                }
                List<Id> idList = new List<Id>();
                for(VDST_BatchFile_gne__c bf : (List<VDST_BatchFile_gne__c>)setCon.getRecords()) {
                    idList.add(bf.Id);
                }
                setCon = null;
                // Get all Batch File records by Id's
                bfw = VDST_FileUpload_Utils.wrapBatchFileList([
                    SELECT  Id, CreatedDate, Filename_gne__c, ProcessStartDate_gne__c,
                            ProcessEndDate_gne__c, Status_gne__c, BatchRecords_gne__c,
                            Status_frm_gne__c, AllBatchRecords_frm_gne__c,
                            BatchEvents_frm_gne__c, PassedValidations_frm_gne__c, FailedValidations_frm_gne__c,
                            TransferedRecords_gne__c
                    FROM    VDST_BatchFile_gne__c
                    WHERE   Id IN :idList
                    ORDER BY CreatedDate DESC
                ]);
                idList = null;
        } catch(Exception ex) {
            bfw = wrapBatchFileList(new List<VDST_BatchFile_gne__c>());
        }
        return bfw;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description get Batch Event Records method
    * @param Id batchFileIdForRec
    * @param VDST_PagingUtils filePaginationUtil
    * @return List<BatchRecordWrapper>
    */
    public static List<BatchRecordWrapper> getBatchRecordWrappers(Id batchFileIdForRec, VDST_PagingUtils eventPaginationUtil) {
        List<VDST_FileUpload_Utils.BatchRecordWrapper> brw;
        try {
                String apostrophe = (batchFileIdForRec == null ? '' : '\'');
                ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(
                    Database.query(
                        'SELECT  Id ' +
                        'FROM    VDST_BatchRecord_gne__c ' +
                        'WHERE   VDST_BatchFile_gne__c = ' + apostrophe + batchFileIdForRec + apostrophe + ' ' +
                        'AND     VDST_ParentEvent_gne__c = null '
                    )
                );
                // Get Batch Records Id's for particular page
                eventPaginationUtil.setParameters(setCon.getResultSize());
                setCon.setPageSize(eventPaginationUtil.perPage);
                setCon.first();
                for(Integer i = 1; i < eventPaginationUtil.actualPage; i++) {
                    setCon.next();
                }
                List<Id> idList = new List<Id>();
                for(VDST_BatchRecord_gne__c br : (List<VDST_BatchRecord_gne__c>)setCon.getRecords()) {
                    idList.add(br.Id);
                }
                setCon = null;
                // Get all Batch Records rows by Id's
                brw = VDST_FileUpload_Utils.wrapBatchRecordList([
                    SELECT  Id, EventId_gne__c, MeetingName_gne__c, isValid__c,
                            ValidParticipants_gne__c, InvalidParticipants_gne__c,
                            EventType_gne__c, VDST_BatchFile_gne__r.Status_gne__c,
                            isValidWithChildren_gne__c
                    FROM    VDST_BatchRecord_gne__c
                    WHERE   VDST_BatchFile_gne__c = :batchFileIdForRec
                    AND     VDST_ParentEvent_gne__c = null
                    AND     Id IN :idList
                ]);
                idList = null;
        } catch(Exception ex) {
            brw = wrapBatchRecordList(new List<VDST_BatchRecord_gne__c>());
        }
        return brw;
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description get Batch Event Records for save method
    * @param Id batchFileId
    * @param Boolean isEvent
    * @return List<VDST_BatchRecord_gne__c>
    */
    public static List<VDST_BatchRecord_gne__c> getBatchRecordsForSave(Id batchFileId, Boolean isEvent) {
        try {
            return Database.query(
                'SELECT Id, Name, AccountablePartyFirstName_gne__c, AccountablePartyID_gne__c, ' +
                    'AccountablePartyLastName_gne__c, Affiliation_gne__c, Brands_gne__c, BrandsId_gne__c, Credential_gne__c, ' +
                    'Email_gne__c, Email_txt_gne__c, EventId_gne__c, EventStartDate_gne__c, EventStartDate_txt_gne__c, ' +
                    'EventType_gne__c, FirstName_gne__c, InvalidParticipants_gne__c, IsAfterBatchProcessing_gne__c, ' +
                    'isEvent_gne__c, isValid__c, LastName_gne__c, LicenseState_gne__c, MeetingName_gne__c, MiddleName_gne__c, ' +
                    'NPI_gne__c, NumberOfRecs__c, ParticipantCity_gne__c, ParticipantCountry_gne__c, ParticipantID_gne__c, ' +
                    'ParticipantPostalCode_gne__c, ParticipantRole_gne__c, ParticipantState_gne__c, ParticipantStreetAddress2_gne__c, ' +
                    'ParticipantStreetAddress_gne__c, Phone_gne__c, Profession_gne__c, Quantity_gne__c, Quantity_txt_gne__c, ' +
                    'StateLicenseNumber_gne__c, Suffix_gne__c, Suffix_txt_gne__c, TOVAmount_gne__c, TOVAmount_txt_gne__c, ' +
                    'TOVItemName_gne__c, TOVType_gne__c, TOVType_txt_gne__c, TOVMealLoc_gne__c, TOVMealLoc_txt_gne__c, ValidParticipants_gne__c, VDST_BatchFile_gne__c, ' +
                    'VDST_ParentEvent_gne__c, VenueCity_gne__c, VenueCountry_gne__c, VenueName_gne__c, VenuePostalCode_gne__c, ' +
                    'VenueState_gne__c, VenueStreetAddress2_gne__c, VenueStreetAddress_gne__c, VenueType_gne__c, VenueType_txt_gne__c, ' +
                    'VDST_ParentEvent_gne__r.TOVAmount_gne__c, VDST_BatchFile_gne__r.VDST_EventProvider_gne__c, ' +
                    'TotPlanAttCntUser_gne__c, TotPlanAttCntUser_txt_gne__c ' +
                'FROM VDST_BatchRecord_gne__c  ' +
                'WHERE VDST_BatchFile_gne__c = \'' + batchFileId + '\' AND isEvent_gne__c = ' + isEvent
            );
        } catch(Exception ex) {
            return new List<VDST_BatchRecord_gne__c>();
        }
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description get Batch File method
    * @param Id batchFileId
    * @return VDST_BatchFile_gne__c
    */
    public static VDST_BatchFile_gne__c getBatchFile(Id batchFileId) {
        List<VDST_BatchFile_gne__c> batchFiles = getBatchFiles(new List<Id>{ batchFileId });
        return ( batchFiles.size() == 1 ? batchFiles[0] : null );
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description get Batch Files method
    * @param List<Id> batchFileIds
    * @return List<VDST_BatchFile_gne__c>
    */
    public static List<VDST_BatchFile_gne__c> getBatchFiles(List<Id> batchFileIds) {
        try {
            return [ SELECT Id, isDeleted_gne__c FROM VDST_BatchFile_gne__c WHERE Id IN :batchFileIds ];
        } catch(Exception ex) {
            return new List<VDST_BatchFile_gne__c>();
        }
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description get Batch Participant method
    * @param Id participantId
    * @return VDST_BatchRecord_gne__c
    */
    public static VDST_BatchRecord_gne__c getBatchParticipant(Id participantId) {
        try {
            List<VDST_BatchRecord_gne__c> batchParticipants = [ SELECT Id, VDST_ParentEvent_gne__c FROM VDST_BatchRecord_gne__c WHERE Id = :participantId ];
            return ( batchParticipants.size() == 1 ? batchParticipants[0] : null );
        } catch(Exception ex) {
            return null;
        }
    }

    // -------------------------------------------------------------------------
    // -------------------------- CLASS DECLARATIONS ---------------------------
    // -------------------------------------------------------------------------
    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Batch Records Processor
    */
    public class BatchRecordsProcessorBeforeDML {
        public List<VDST_BatchRecord_gne__c> allRecords;
        public List<VDST_BatchRecord_gne__c> events;
        public List<VDST_BatchRecord_gne__c> participants;

        public BatchRecordsProcessorBeforeDML() {
            allRecords = new List<VDST_BatchRecord_gne__c>();
            events = new List<VDST_BatchRecord_gne__c>();
            participants = new List<VDST_BatchRecord_gne__c>();
        }

        public BatchRecordsProcessorBeforeDML(List<VDST_BatchRecord_gne__c> recs) {
            this();
            allRecords.addAll(recs);
            for(VDST_BatchRecord_gne__c rec : recs) {
                if(rec.isEvent_gne__c) {
                    events.add(rec);
                } else {
                    participants.add(rec);
                }
            }
        }

        public void process() {
            Defaultable defaulter;
            EventEditValidator eventValidator = new EventEditValidator();
            eventValidator.setMapAccountIdToUserByBatchEvents( events );
            ParticipantEditValidator participantValidator = new ParticipantEditValidator();

            BatchRecordsTrimmer trimmer = new BatchRecordsTrimmer(allRecords);
            trimmer.trim();

            for(VDST_BatchRecord_gne__c rec : allRecords) {
                if(rec.isEvent_gne__c) {
                    defaulter = new EventDefaulter(rec);
                } else {
                    defaulter = new ParticipantDefaulter(rec);
                }
                defaulter.setDefaults();

                rec.IsAfterBatchProcessing_gne__c = true;
            }
            for(VDST_BatchRecord_gne__c rec : events) {
                eventValidator.assignNewSObject(rec);
                eventValidator.validate();
            }
            for(VDST_BatchRecord_gne__c rec : participants) {
                participantValidator.assignNewSObject(rec);
                participantValidator.validate();
            }
        }
    }

    /** @date 11/26/2013
    * @Author Konrad Malinowski
    * @description Batch Records Trimmer
    */
    public class BatchRecordsTrimmer {
        private List<VDST_BatchRecord_gne__c>   sObjs             { get; set; }
        private Map<String, Integer>            fieldToLengthMap  { get; set; }

        public BatchRecordsTrimmer(List<VDST_BatchRecord_gne__c> sObjs) {
            this.sObjs = sObjs;
            getMapFieldToLength();
        }

        private void getMapFieldToLength() {
            fieldToLengthMap = new Map<String, Integer>{
                'accPartyId'                => VDST_BatchRecord_gne__c.AccountablePartyID_gne__c.getDescribe().getLength(),
                'affiliation'               => VDST_BatchRecord_gne__c.Affiliation_gne__c.getDescribe().getLength(),
                'brands'                    => VDST_BatchRecord_gne__c.Brands_gne__c.getDescribe().getLength(),
                'credential'                => VDST_BatchRecord_gne__c.Credential_gne__c.getDescribe().getLength(),
                'email'                     => VDST_BatchRecord_gne__c.Email_txt_gne__c.getDescribe().getLength(),
                'startDate'                 => VDST_BatchRecord_gne__c.EventStartDate_txt_gne__c.getDescribe().getLength(),
                'licenseState'              => VDST_BatchRecord_gne__c.LicenseState_gne__c.getDescribe().getLength(),
                'meetingName'               => VDST_BatchRecord_gne__c.MeetingName_gne__c.getDescribe().getLength(),
                'middleName'                => VDST_BatchRecord_gne__c.MiddleName_gne__c.getDescribe().getLength(),
                'npi'                       => VDST_BatchRecord_gne__c.NPI_gne__c.getDescribe().getLength(),
                'participantCity'           => VDST_BatchRecord_gne__c.ParticipantCity_gne__c.getDescribe().getLength(),
                'participantCountry'        => VDST_BatchRecord_gne__c.ParticipantCountry_gne__c.getDescribe().getLength(),
                'participantPostalCode'     => VDST_BatchRecord_gne__c.ParticipantPostalCode_gne__c.getDescribe().getLength(),
                'participantRole'           => VDST_BatchRecord_gne__c.ParticipantRole_gne__c.getDescribe().getLength(),
                'participantState'          => VDST_BatchRecord_gne__c.ParticipantState_gne__c.getDescribe().getLength(),
                'participantStreetAddr2'    => VDST_BatchRecord_gne__c.ParticipantStreetAddress2_gne__c.getDescribe().getLength(),
                'participantStreetAddr'     => VDST_BatchRecord_gne__c.ParticipantStreetAddress_gne__c.getDescribe().getLength(),
                'phone'                     => VDST_BatchRecord_gne__c.Phone_gne__c.getDescribe().getLength(),
                'profession'                => VDST_BatchRecord_gne__c.Profession_gne__c.getDescribe().getLength(),
                'quantity'                  => VDST_BatchRecord_gne__c.Quantity_txt_gne__c.getDescribe().getLength(),
                'stateLicenseNumber'        => VDST_BatchRecord_gne__c.StateLicenseNumber_gne__c.getDescribe().getLength(),
                'suffix'                    => VDST_BatchRecord_gne__c.Suffix_txt_gne__c.getDescribe().getLength(),
                'tovAmount'                 => VDST_BatchRecord_gne__c.TOVAmount_txt_gne__c.getDescribe().getLength(),
                'tovItemName'               => VDST_BatchRecord_gne__c.TOVItemName_gne__c.getDescribe().getLength(),
                'tovType'                   => VDST_BatchRecord_gne__c.TOVType_txt_gne__c.getDescribe().getLength(),
                'tovMealLoc'                => VDST_BatchRecord_gne__c.TOVMealLoc_txt_gne__c.getDescribe().getLength(),
                'venueCity'                 => VDST_BatchRecord_gne__c.VenueCity_gne__c.getDescribe().getLength(),
                'venueCountry'              => VDST_BatchRecord_gne__c.VenueCountry_gne__c.getDescribe().getLength(),
                'venueName'                 => VDST_BatchRecord_gne__c.VenueName_gne__c.getDescribe().getLength(),
                'venuePostalCode'           => VDST_BatchRecord_gne__c.VenuePostalCode_gne__c.getDescribe().getLength(),
                'venueState'                => VDST_BatchRecord_gne__c.VenueState_gne__c.getDescribe().getLength(),
                'venueStreetAddress'        => VDST_BatchRecord_gne__c.VenueStreetAddress_gne__c.getDescribe().getLength(),
                'venueType'                 => VDST_BatchRecord_gne__c.VenueType_txt_gne__c.getDescribe().getLength(),
                'totPlanAttCntUser'         => VDST_BatchRecord_gne__c.TotPlanAttCntUser_txt_gne__c.getDescribe().getLength()
            };
        }

        public void trim() {
            for(VDST_BatchRecord_gne__c rec : sObjs) {
                rec.AccountablePartyID_gne__c         = getTrimValue(rec.AccountablePartyID_gne__c,        'accPartyId');
                rec.Affiliation_gne__c                = getTrimValue(rec.Affiliation_gne__c,               'affiliation');
                rec.Brands_gne__c                     = getTrimValue(rec.Brands_gne__c,                    'brands');
                rec.Credential_gne__c                 = getTrimValue(rec.Credential_gne__c,                'credential');
                rec.Email_txt_gne__c                  = getTrimValue(rec.Email_txt_gne__c,                 'email');
                rec.EventStartDate_txt_gne__c         = getTrimValue(rec.EventStartDate_txt_gne__c,        'startDate');
                rec.LicenseState_gne__c               = getTrimValue(rec.LicenseState_gne__c,              'licenseState');
                rec.MeetingName_gne__c                = getTrimValue(rec.MeetingName_gne__c,               'meetingName');
                rec.MiddleName_gne__c                 = getTrimValue(rec.MiddleName_gne__c,                'middleName');
                rec.NPI_gne__c                        = getTrimValue(rec.NPI_gne__c,                       'npi');
                rec.ParticipantCity_gne__c            = getTrimValue(rec.ParticipantCity_gne__c,           'participantCity');
                rec.ParticipantCountry_gne__c         = getTrimValue(rec.ParticipantCountry_gne__c,        'participantCountry');
                rec.ParticipantPostalCode_gne__c      = getTrimValue(rec.ParticipantPostalCode_gne__c,     'participantPostalCode');
                rec.ParticipantRole_gne__c            = getTrimValue(rec.ParticipantRole_gne__c,           'participantRole');
                rec.ParticipantState_gne__c           = getTrimValue(rec.ParticipantState_gne__c,          'participantState');
                rec.ParticipantStreetAddress2_gne__c  = getTrimValue(rec.ParticipantStreetAddress2_gne__c, 'participantStreetAddr2');
                rec.ParticipantStreetAddress_gne__c   = getTrimValue(rec.ParticipantStreetAddress_gne__c,  'participantStreetAddr');
                rec.Phone_gne__c                      = getTrimValue(rec.Phone_gne__c,                     'phone');
                rec.Profession_gne__c                 = getTrimValue(rec.Profession_gne__c,                'profession');
                rec.Quantity_txt_gne__c               = getTrimValue(rec.Quantity_txt_gne__c,              'quantity');
                rec.StateLicenseNumber_gne__c         = getTrimValue(rec.StateLicenseNumber_gne__c,        'stateLicenseNumber');
                rec.Suffix_txt_gne__c                 = getTrimValue(rec.Suffix_txt_gne__c,                'suffix');
                rec.TOVAmount_txt_gne__c              = getTrimValue(rec.TOVAmount_txt_gne__c,             'tovAmount');
                rec.TOVItemName_gne__c                = getTrimValue(rec.TOVItemName_gne__c,               'tovItemName');
                rec.TOVType_txt_gne__c                = getTrimValue(rec.TOVType_txt_gne__c,               'tovType');
                rec.TOVMealLoc_txt_gne__c             = getTrimValue(rec.TOVMealLoc_txt_gne__c,            'tovMealLoc');
                rec.VenueCity_gne__c                  = getTrimValue(rec.VenueCity_gne__c,                 'venueCity');
                rec.VenueCountry_gne__c               = getTrimValue(rec.VenueCountry_gne__c,              'venueCountry');
                rec.VenueName_gne__c                  = getTrimValue(rec.VenueName_gne__c,                 'venueName');
                rec.VenuePostalCode_gne__c            = getTrimValue(rec.VenuePostalCode_gne__c,           'venuePostalCode');
                rec.VenueState_gne__c                 = getTrimValue(rec.VenueState_gne__c,                'venueState');
                rec.VenueStreetAddress_gne__c         = getTrimValue(rec.VenueStreetAddress_gne__c,        'venueStreetAddress');
                rec.VenueType_txt_gne__c              = getTrimValue(rec.VenueType_txt_gne__c,             'venueType');
                rec.TotPlanAttCntUser_txt_gne__c      = getTrimValue(rec.TotPlanAttCntUser_txt_gne__c,     'totPlanAttCntUser');
            }
        }

        private String getTrimValue(String val, String mapKey) {
            if(!String.isBlank(val) && val.length() > fieldToLengthMap.get(mapKey)) {
                return val.substring(0, fieldToLengthMap.get(mapKey));
            }
            return val;
        }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Exception Wrapper
    */
    public class VdstException extends Exception { }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Batch File wrapper
    */
    public class BatchFileWrapper {
        public Boolean flag                         { get; set; }
        public VDST_BatchFile_gne__c batchFileSObj  { get; set; }

        public Boolean isLink                       { get; set; }
        public String  percentCompleted             { get; set; }
        public String  fileName                     { get; set; }

        public BatchFileWrapper(VDST_BatchFile_gne__c batchFileSObj) {
            this.batchFileSObj = batchFileSObj;

            Set<String> notLinkableStatuses = new Set<String>{'New', 'Uploading', 'Processing'};
            isLink = !notLinkableStatuses.contains(batchFileSObj.Status_frm_gne__c);
            setPercentCompletedValue();

            String createdDate = batchFileSObj.CreatedDate != null ? ' (' + batchFileSObj.CreatedDate.format('MM/dd/yyyy hh:mm a') + ')' : '';
            fileName = batchFileSObj.Filename_gne__c + createdDate;
        }

        private void setPercentCompletedValue() {
            percentCompleted = '';
            if(String.isBlank(batchFileSObj.Status_gne__c)) {
                if(batchFileSObj.ProcessStartDate_gne__c == null) {
                    percentCompleted = '';
                } else if(batchFileSObj.ProcessEndDate_gne__c != null) {
                    percentCompleted = '100';
                } else {
                    if(batchFileSObj.AllBatchRecords_frm_gne__c > 0) {
                        percentCompleted = String.valueOf( ( ( (batchFileSObj.PassedValidations_frm_gne__c + batchFileSObj.FailedValidations_frm_gne__c) / batchFileSObj.AllBatchRecords_frm_gne__c) * 100 ).round() );
                    }
                    if(percentCompleted == '100' && batchFileSObj.ProcessEndDate_gne__c == null) {
                        percentCompleted = '99';
                    }
                }
            } else {
                if(batchFileSObj.ProcessStartDate_gne__c == null) {
                    percentCompleted = '';
                } else if(batchFileSObj.ProcessEndDate_gne__c != null) {
                    percentCompleted = '100';
                } else {
                    if(batchFileSObj.TransferedRecords_gne__c > 0) {
                        percentCompleted = String.valueOf( ( ( batchFileSObj.TransferedRecords_gne__c / batchFileSObj.AllBatchRecords_frm_gne__c) * 100 ).round() );
                    }
                    if(percentCompleted == '100' && batchFileSObj.ProcessEndDate_gne__c == null) {
                        percentCompleted = '99';
                    }
                }
            }
        }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Batch Record wrapper
    */
    public class BatchRecordWrapper {
        public VDST_BatchRecord_gne__c  batchRecSObj        { get; set; }
        public String                   status              { get; set; }
        public String                   statusWithChildren  { get; set; }
        public Boolean                  isEditeable         { get; set; }

        public BatchRecordWrapper(VDST_BatchRecord_gne__c batchRecSObj) {
            this.batchRecSObj = batchRecSObj;
            this.status = getStatusName(this.batchRecSObj.isValid__c);
            this.statusWithChildren = getStatusName(this.batchRecSObj.isValidWithChildren_gne__c);
            this.isEditeable = String.isBlank(batchRecSObj.VDST_BatchFile_gne__r.Status_gne__c);
        }
    }

    // ************************** EVENT EDIT **************************
    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Batch Event Record wrapper
    */
    public class EventEditWrapper {
        public VDST_BatchRecord_gne__c         sObj                       { get; set; }
        public String                          stateUSA                   { get; set; }
        public EventValidationResult           validResult                { get; set; }
        public EventEditValidator              validator                  { get; set; }
        public VDST_PagingUtils                participantPaginationUtil  { get; set; }
        public Boolean                         isEditeable                { get; set; }
        public String                          expenseTypeName            { get; set; }
        public Boolean                         isPOC                      { get; set; }

        public String venueCountry           { get; set; }
        public String venueStateProvince     { get; set; }

        public List<BatchRecordWrapper>        participants {
            get {
                if (isPOC) {
                    return participants;
                }
                List<BatchRecordWrapper> brw;
                try {
                        String apostrophe = (sObj.Id == null ? '' : '\'');
                        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(
                            Database.query(
                                'SELECT  Id ' +
                                'FROM    VDST_BatchRecord_gne__c ' +
                                'WHERE   VDST_ParentEvent_gne__c = ' + apostrophe + sObj.Id + apostrophe + ' '
                            )
                        );

                        participantPaginationUtil.setParameters(setCon.getResultSize());
                        setCon.setPageSize(participantPaginationUtil.perPage);
                        setCon.first();
                        for(Integer i = 1; i < participantPaginationUtil.actualPage; i++) {
                            setCon.next();
                        }
                        List<Id> idList = new List<Id>();
                        for(VDST_BatchRecord_gne__c br : (List<VDST_BatchRecord_gne__c>)setCon.getRecords()) {
                            idList.add(br.Id);
                        }
                        setCon = null;
                        brw = wrapBatchRecordList([
                            SELECT  isValid__c, LastName_gne__c, FirstName_gne__c, VDST_BatchFile_gne__r.Status_gne__c,
                                    isValidWithChildren_gne__c
                            FROM    VDST_BatchRecord_gne__c
                            WHERE   VDST_ParentEvent_gne__c = :sObj.Id
                            AND     Id IN :idList
                        ]);
                        idList = null;
                } catch(Exception ex) {
                    brw = wrapBatchRecordList(new List<VDST_BatchRecord_gne__c>());
                }
                return brw;
            }
            set;
        }

        public EventEditWrapper(VDST_BatchRecord_gne__c sObj) {
            isPOC = false;
            this.sObj= sObj;
            if(sObj.VenueCountry_gne__c == 'USA') {
                stateUSA = this.sObj.VenueState_gne__c;
            }
            validResult = new EventValidationResult();
            validator = new EventEditValidator(this);
            participantPaginationUtil = new VDST_PagingUtils(10);
            isEditeable = String.isBlank(sObj.VDST_BatchFile_gne__r.Status_gne__c);

            setNonEditeableFieldValues();
            getExpenseTypeName();
        }

        private void getExpenseTypeName() {
            if( VDST_Utils.expenseTypeCodeToNameMap().containsKey( sObj.TOVType_gne__c ) ) {
                expenseTypeName = VDST_Utils.expenseTypeCodeToNameMap().get( sObj.TOVType_gne__c );
            }
        }

        private void setNonEditeableFieldValues() {
            SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(validator.selOptCountries, sObj.VenueCountry_gne__c);
            if(selOpt != null) {
                venueCountry = selOpt.getLabel();
            }

            selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(validator.selOptStates, sObj.VenueState_gne__c);
            if(selOpt != null) {
                venueStateProvince = selOpt.getLabel();
            } else {
                venueStateProvince = sObj.VenueState_gne__c;
            }
        }

        public SaveResult save() {
            Savepoint sp = Database.setSavepoint();
            SaveResult result = new SaveResult();
            revalidate();
            if(validResult.isError('meetingName')) {
                result.errorMsg = 'Meeting name is required to save';
                return result;
            }
            try {
                update sObj;
                result.actionMsg = 'Event Saved successfully';
            } catch(QueryException e) {
                log.logException('save', e);
                result.errorMsg = 'Error while updating event';
                Database.rollback(sp);
            } catch(DmlException dml) {
                log.logException('save', dml);
                result.errorMsg = dml.getMessage();
                Database.rollback(sp);
            }
            return result;
        }

        public void revalidate() {
            trim();
            additionalAssignations();
            if(sObj.VenueCountry_gne__c == 'USA' && !String.isBlank(this.sObj.VenueState_gne__c)) {
                stateUSA = this.sObj.VenueState_gne__c;
            }
            validate();
        }

        public void additionalAssignations() {
            if(sObj.VenueCountry_gne__c == 'USA') {
                sObj.VenueState_gne__c = stateUSA;
            }
        }

        public void trim() {
            VDST_FileUpload_Utils.BatchRecordsTrimmer trimmer = new VDST_FileUpload_Utils.BatchRecordsTrimmer(new List<VDST_BatchRecord_gne__c>{ sObj });
            trimmer.trim();
        }

        public void validate() {
            validResult = (EventValidationResult)(validator.validate());
        }

        public PageReference fetchUserDataFromUnixId() {
            validResult = (EventValidationResult)(validator.validateAccountableId());
            return null;
        }

        public List<String> getDrugsFromStringList() {
            if(String.isBlank(sObj.Brands_gne__c)) {
                return new List<String>();
            }
            List<String> drugList = new List<String>();
            Map<String, String> drugNameUpperCaseMap = VDST_FileUpload_Utils.createMapDrugNameUpperCaseToId();
            String drugName;
            for(String drug : sObj.Brands_gne__c.split(',')) {
                drugName = drug.toUpperCase().trim();
                if(drugNameUpperCaseMap.containsKey(drugName)) {
                    drugList.add( drugNameUpperCaseMap.get( drugName ) );
                }
            }
            return drugList;
        }

        public void setBrandFromList(List<String> selectedDrugList, List<SelectOption> drugList) {
            sObj.Brands_gne__c = '';
            for(String drug : selectedDrugList) {
                for(SelectOption so : drugList) {
                    if(so.getValue() == drug) {
                        sObj.Brands_gne__c += so.getLabel() + ', ';
                    }
                }
            }
            sObj.Brands_gne__c = sObj.Brands_gne__c.removeEnd(', ');
        }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Event Validation Result wrapper
    */
    public class EventValidationResult extends ValidationResult {
        public EventValidationResult() {
            errMap = new Map<String, String>{
                'meetingName'       => '',
                'accPartyID'        => '',
                'brands'            => '',
                'date'              => '',
                'venType'           => '',
                'venTypeBlank'      => '',
                'venCountry'        => '',
                'venCountryBlank'   => '',
                'venName'           => '',
                'venAddr'           => '',
                'venCity'           => '',
                'venState'          => '',
                'venStateBlank'     => '',
                'venZipCode'        => '',
                'expType'           => '',
                'expTypeBlank'      => '',
                'expAmount'         => '',
                'expItem'           => '',
                'totPlanAttCntUser' => '',
                'mealType'          => '',
                'mealTypeBlank'     => ''
            };
        }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Event Validation wrapper
    */
    public class EventEditValidator implements Validateable {
        public VDST_BatchRecord_gne__c        sObj                    { get; set; }
        public EventValidationResult          validResult             { get; set; }
        public EventEditWrapper               wrapper                 { get; set; }

        public List<SelectOption>         selOptDrugNames      = VDST_Utils.getDrugNames();
        public List<SelectOption>         selOptStates         = VDST_Utils.getStatesNames();
        public List<SelectOption>         selOptCountries      = VDST_FileUpload_Utils.getCountries();
        public List<SelectOption>         selOptVenueTypes     = VDST_FileUpload_Utils.getVenueTypes();
        public List<SelectOption>         selOptExpenseTypes   = VDST_FileUpload_Utils.getExpenseTypes();
        public List<SelectOption>         selOptMealTypes     = VDST_FileUpload_Utils.getMealTypes();

        private Map<String, All_User_Hierarchy_gne__c> accIdToUserMap { get; set; }

        public EventEditValidator() {
            constructorAssignations(new VDST_BatchRecord_gne__c());
        }

        public EventEditValidator(VDST_BatchRecord_gne__c sObj) {
            constructorAssignations(sObj);
        }

        public EventEditValidator(EventEditWrapper wrapper) {
            this.wrapper = wrapper;
            constructorAssignations(wrapper.sObj);
        }

        private void constructorAssignations(VDST_BatchRecord_gne__c sObj) {
            this.sObj = sObj;
            this.validResult = new EventValidationResult();
            accIdToUserMap = null;
        }

        public void assignNewSObject(sObject sObj) {
            this.sObj = (VDST_BatchRecord_gne__c)sObj ;
            this.validResult = new EventValidationResult();
        }

        public void setMapAccountIdToUserByBatchEvents(List<VDST_BatchRecord_gne__c> evnts) {
            List<String> accountableIds = new List<String>();
            for(VDST_BatchRecord_gne__c ev : evnts) {
                accountableIds.add( ev.AccountablePartyID_gne__c );
            }
            accIdToUserMap = VDST_Utils.getUsersData(accountableIds);
        }

        public ValidationResult validate() {
            validResult.clearAllErrors();
            // Accountable Unix ID
            validateAccountableId();
            // Meeting Name/Item Name
            if(sObj.EventType_gne__c == 'CFF') {
                sObj.TOVItemName_gne__c = '';
                if(String.isBlank(sObj.MeetingName_gne__c)) {
                    validResult.setError('meetingName', 'Meeting Name is required');
                }
            } else {
                sObj.MeetingName_gne__c = sObj.TOVItemName_gne__c;
                if(String.isBlank(sObj.TOVItemName_gne__c)) {
                    validResult.setError('expItem', 'Item Name is required');
                }
            }
            // Brand(s)
            if(String.isBlank(sObj.Brands_gne__c)) {
                validResult.setError('brands', 'At least one Brand is required');
            } else {
                validateBrandList();
            }
            // Event Date
            if(String.isBlank(sObj.EventStartDate_txt_gne__c)) {
                validResult.setError('date', 'Event Date is required');
            } else {
                Date startDate;
                try {
                    startDate = Date.parse(sObj.EventStartDate_txt_gne__c);
                    if(startDate.year() < 1970 || startDate.year() > 2100) {
                        validResult.setError('date', 'Invalid Event Date');
                    } else if(startDate > Date.today()) {
                        validResult.setError('date', 'Event Date cannot be later than today\'s');
                    } else {
                        sObj.EventStartDate_gne__c = startDate;
                    }
                } catch(Exception ex) {
                    validResult.setError('date', 'Invalid Event Date');
                }
            }

            Boolean isRequired = ( sObj.EventType_gne__c == 'CFF' );
            // Venue Type
            if(!String.isBlank(sObj.VenueType_txt_gne__c)) {
                sObj.VenueType_txt_gne__c = sObj.VenueType_txt_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptVenueTypes, sObj.VenueType_txt_gne__c);
                if(selOpt != null) {
                    sObj.VenueType_gne__c = selOpt.getValue();
                    sObj.VenueType_txt_gne__c = null;
                } else {
                    validResult.setError('venType', 'Invalid Venue Type');
                }
            }
            // Venue Name
            if(isRequired && String.isBlank(sObj.VenueName_gne__c)) {
                validResult.setError('venName', 'Venue Name field is required');
            }
            // Venue Country
            if(isRequired && String.isBlank(sObj.VenueCountry_gne__c)) {
                validResult.setError('venCountryBlank', 'Venue Country field is required');
            } else if(!String.isBlank(sObj.VenueCountry_gne__c)) {
                sObj.VenueCountry_gne__c = sObj.VenueCountry_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptCountries, sObj.VenueCountry_gne__c);
                if(selOpt != null) {
                    sObj.VenueCountry_gne__c = selOpt.getValue();
                } else {
                    validResult.setError('venCountry', 'Invalid Venue Country');
                }
            }
            // Venue Address
            if(isRequired && String.isBlank(sObj.VenueStreetAddress_gne__c)) {
                validResult.setError('venAddr', 'Venue Address field is required');
            }
            // Venue City
            if(isRequired && String.isBlank(sObj.VenueCity_gne__c)) {
                validResult.setError('venCity', 'Venue City field is required');
            }
            // Venue State
            if(isRequired && String.isBlank(sObj.VenueState_gne__c)) {
                validResult.setError('venStateBlank', 'Venue State/Province field is required');
            } else if(!String.isBlank(sObj.VenueState_gne__c) && 'USA'.equals(sObj.VenueCountry_gne__c)) {
                sObj.VenueState_gne__c = sObj.VenueState_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptStates, sObj.VenueState_gne__c);
                if(selOpt != null) {
                    sObj.VenueState_gne__c = selOpt.getValue();
                } else {
                    validResult.setError('venState', 'Invalid Venue State');
                }
            }
            // Venue Postal Code
            if(isRequired && String.isBlank(sObj.VenuePostalCode_gne__c)) {
                validResult.setError('venZipCode', 'Postal Code field is required');
            } else if(!String.isBlank(sObj.VenuePostalCode_gne__c)) {
                sObj.VenuePostalCode_gne__c = sObj.VenuePostalCode_gne__c.toUpperCase();
                if('USA'.equals(sObj.VenueCountry_gne__c) && !Pattern.matches('^[0-9]{5}||[0-9]{5}-{1}[0-9]{4}$', sObj.VenuePostalCode_gne__c)) {
                    validResult.setError('venZipCode', 'Invalid Postal Code format');
                } else if(!Pattern.matches('^[0-9a-zA-Z\\-\\s]+$', sObj.VenuePostalCode_gne__c)) {
                    validResult.setError('venZipCode', 'Invalid Postal Code format');
                }
            }
            // Expense Amount
            if(String.isBlank(sObj.TOVAmount_txt_gne__c)) {
                validResult.setError('expAmount', 'Expense Amount field is required');
            } else {
                try {
                    sObj.TOVAmount_txt_gne__c = sObj.TOVAmount_txt_gne__c.replace(' ', '');
                    Decimal tovAmount = Decimal.valueOf(sObj.TOVAmount_txt_gne__c);
                    sObj.TOVAmount_gne__c = tovAmount;
                    if( !Pattern.matches('^[0-9]{0,7}\\.?[0-9]{0,2}$', sObj.TOVAmount_txt_gne__c) ||
                    (!sObj.TOVAmount_txt_gne__c.contains('.') && !Pattern.matches('^[0-9]{0,7}$', sObj.TOVAmount_txt_gne__c) ) ) {
                        validResult.setError('expAmount', 'Expense Amount should be not greater than 9999999,99');
                    }
                    if(tovAmount < 0) {
                        validResult.setError('expAmount', 'Expense Amount cannot be negative');
                    }
                } catch(Exception ex) {
                    validResult.setError('expAmount', 'Invalid Expense Amount');
                }
            }
            // Planned Attendee Count
            if(isRequired && String.isBlank(sObj.TotPlanAttCntUser_txt_gne__c)) {
                validResult.setError('totPlanAttCntUser', 'Planned Attendee Count field is required');
            } else if(!String.isBlank(sObj.TotPlanAttCntUser_txt_gne__c)) {
                try {
                    sObj.TotPlanAttCntUser_txt_gne__c = sObj.TotPlanAttCntUser_txt_gne__c.replace(' ', '');
                    Integer participantCount = Integer.valueOf(sObj.TotPlanAttCntUser_txt_gne__c);
                    sObj.TotPlanAttCntUser_gne__c = participantCount;
                    if( !Pattern.matches('^[0-9]{0,5}$', sObj.TotPlanAttCntUser_txt_gne__c ) ) {
                        validResult.setError('totPlanAttCntUser', 'Planned Attendee Count should have a maximum of 5 digits');
                    }
                    if(participantCount < 0) {
                        validResult.setError('totPlanAttCntUser', 'Planned Attendee Count cannot be negative');
                    }
                } catch(Exception ex) {
                    validResult.setError('totPlanAttCntUser', 'Invalid Planned Attendee Count');
                }
            }
            if(!String.isBlank(sObj.TOVMealLoc_txt_gne__c)) {
                sObj.TOVMealLoc_txt_gne__c = sObj.TOVMealLoc_txt_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptMealTypes, sObj.TOVMealLoc_txt_gne__c);
                if(selOpt != null) {
                    sObj.TOVMealLoc_gne__c = selOpt.getValue();
                    sObj.TOVMealLoc_txt_gne__c = null;
                } else {
                    validResult.setError('mealType', 'Invalid Meal Type');
                }
            }

            sObj.isValid__c = validResult.isValid();
            return validResult;
        }

        public ValidationResult validateAccountableId() {
            validResult.clearError('accPartyID');
            setFirstLastName( '', '' );
            if(String.isBlank(sObj.AccountablePartyID_gne__c)) {
                validResult.setError('accPartyID', 'Accountable Party Unix ID is required');
            } else {
                UserWrapper userWrap = null;
                if(accIdToUserMap == null) {
                    userWrap = getUserData( sObj.AccountablePartyID_gne__c );
                } else {
                    if( accIdToUserMap.containsKey( sObj.AccountablePartyID_gne__c.toLowerCase() ) ) {
                        All_User_Hierarchy_gne__c userH = accIdToUserMap.get( sObj.AccountablePartyID_gne__c.toLowerCase() );
                        userWrap = new UserWrapper( userH.FirstName_gne__c, userH.LastName_gne__c );
                    }
                }
                if( userWrap == null ) {
                    validResult.setError('accPartyID', 'Incorrect Accountable Party Unix ID');
                } else {
                    setFirstLastName( userWrap.firstName, userWrap.lastName );
                }
            }
            return validResult;
        }

        public void setFirstLastName(String fn, String ln) {
            sObj.AccountablePartyFirstName_gne__c = fn;
            sObj.AccountablePartyLastName_gne__c = ln;
        }

        public void validateBrandList() {
            Integer numberOfBrands = 0;
            List<String> brandsList = sObj.Brands_gne__c.split(',');
            for(String b : brandsList) {
                numberOfBrands++;
                if(numberOfBrands > 5) {
                    String brandsTruncated = '';
                    for(Integer i = 0; i < 5; i++) {
                        brandsTruncated += brandsList[i] + ',';
                    }
                    sObj.Brands_gne__c = brandsTruncated;
                    break;
                }
            }

            String invalidBrands = '';
            String brand;
            String brands = sObj.Brands_gne__c;
            sObj.Brands_gne__c = '';
            sObj.BrandsId_gne__c = '';
            for(String b : brands.split(',')) {
                brand = b.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptDrugNames, brand);
                if(selOpt == null) {
                    invalidBrands += brand + ', ';
                } else {
                    brand = selOpt.getLabel();
                    sObj.BrandsId_gne__c += selOpt.getValue() + ',';
                }
                sObj.Brands_gne__c += brand + ', ';
            }
            sObj.Brands_gne__c = sObj.Brands_gne__c.removeEnd(', ');
            sObj.BrandsId_gne__c = sObj.BrandsId_gne__c.removeEnd(',');
            invalidBrands = invalidBrands.removeEnd(', ');
            if(!String.isBlank(invalidBrands)) {
                String startMsg = 'Could not match ', stopMsg = ' Brand(s).';
                String invalidBrandsMsg = startMsg + invalidBrands + stopMsg;
                Integer invalidBrandsFieldLength = 255;
                validResult.setError( 'brands', ( invalidBrandsMsg.length() <= invalidBrandsFieldLength ? invalidBrandsMsg : invalidBrandsMsg.substring(0, 255) ) );
            }
        }
    }

    // ************************** PARTICIPANT EDIT **************************
    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Batch Participant Record wrapper
    */
    public class ParticipantEditdWrapper {
        public VDST_BatchRecord_gne__c      sObj             { get; set; }
        public String                       stateUSA         { get; set; }
        public ParticipantEditValidator     validator        { get; set; }
        public ParticipantValidationResult  validResult      { get; set; }
        public Boolean                      isEditeable      { get; set; }

        public String role              { get; set; }
        public String licenseState      { get; set; }
        public String suffix            { get; set; }
        public String profession        { get; set; }
        public String credential        { get; set; }
        public String country           { get; set; }
        public String stateProvince     { get; set; }

        public ParticipantEditdWrapper (VDST_BatchRecord_gne__c sObj) {
            this.sObj = sObj;
            if(sObj.ParticipantCountry_gne__c == 'USA') {
                stateUSA = this.sObj.ParticipantState_gne__c;
            }
            validResult = new ParticipantValidationResult();
            validator = new ParticipantEditValidator(this.sObj);
            isEditeable = String.isBlank(sObj.VDST_BatchFile_gne__r.Status_gne__c);

            setNonEditeableFieldValues();
        }

        private void setNonEditeableFieldValues() {
            SelectOption selOpt;

            selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn( VDST_FileUpload_Utils.getParticipantRoles( sObj.VDST_ParentEvent_gne__c ), sObj.ParticipantRole_gne__c );
            if(selOpt != null) {
                role = selOpt.getLabel();
            }

            selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(validator.selOptStates, sObj.LicenseState_gne__c);
            if(selOpt != null) {
                licenseState = selOpt.getLabel();
            }

            selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(validator.selOptSuffixes, sObj.Suffix_gne__c);
            if(selOpt != null) {
                suffix = selOpt.getLabel();
            }

            selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(validator.selOptProfessions, sObj.Profession_gne__c);
            if(selOpt != null) {
                profession = selOpt.getLabel();
            }

            selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(validator.selOptCredentials, sObj.Credential_gne__c);
            if(selOpt != null) {
                credential = selOpt.getLabel();
            }

            selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(validator.selOptCountries, sObj.ParticipantCountry_gne__c);
            if(selOpt != null) {
                country = selOpt.getLabel();
            }

            selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(validator.selOptStates, sObj.ParticipantState_gne__c);
            if(selOpt != null) {
                stateProvince = selOpt.getLabel();
            } else {
                stateProvince = sObj.ParticipantState_gne__c;
            }
        }

        public SaveResult save() {
            Savepoint sp = Database.setSavepoint();
            SaveResult result = new SaveResult();
            revalidate();
            if(validResult.isError('fname')) {
                result.errorMsg = 'First name is required to save';
                return result;
            }
            if(validResult.isError('lname')) {
                result.errorMsg = 'Last name is required to save';
                return result;
            }
            try {
                update sObj;
                result.actionMsg = 'Participant Saved successfully';
            } catch(QueryException e) {
                log.logException('save', e);
                result.errorMsg = 'Error while updating participant';
                Database.rollback(sp);
            } catch(DmlException dml) {
                log.logException('save', dml);
                result.errorMsg = dml.getMessage();
                Database.rollback(sp);
            }
            return result;
        }

        public void revalidate() {
            trim();
            additionalAssignations();
            if(sObj.ParticipantCountry_gne__c == 'USA' && !String.isBlank(this.sObj.ParticipantState_gne__c)) {
                stateUSA = this.sObj.ParticipantState_gne__c;
            }
            validate();
        }

        public void additionalAssignations() {
            if(sObj.ParticipantCountry_gne__c == 'USA') {
                sObj.ParticipantState_gne__c = stateUSA;
            }
        }

        public void trim() {
            VDST_FileUpload_Utils.BatchRecordsTrimmer trimmer = new VDST_FileUpload_Utils.BatchRecordsTrimmer(new List<VDST_BatchRecord_gne__c>{ sObj });
            trimmer.trim();
        }

        public void validate() {
            validResult = (ParticipantValidationResult)(validator.validate());
        }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Participant Validation Result wrapper
    */
    public class ParticipantValidationResult extends ValidationResult {
        public ParticipantValidationResult() {
            errMap = new Map<String, String>{
                'role'             => '',
                'roleBlank'        => '',
                'fname'            => '',
                'lname'            => '',
                'suffix'           => '',
                'suffixBlank'      => '',
                'email'            => '',
                'affiliation'      => '',
                'profession'       => '',
                'professionBlank'  => '',
                'credential'       => '',
                'credentialBlank'  => '',
                'npi'              => '',
                'dea'              => '',
                'licenseSta'       => '',
                'licenseStaBlank'  => '',
                'licenseNum'       => '',
                'quantity'         => '',
                'country'          => '',
                'countryBlank'     => '',
                'street1'          => '',
                'street2'          => '',
                'city'             => '',
                'state'            => '',
                'stateBlank'       => '',
                'zipCode'          => ''
            };
        }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST Participant Validation wrapper
    */
    public class ParticipantEditValidator implements Validateable {
        public VDST_BatchRecord_gne__c sObj { get; set; }
        public ParticipantValidationResult validResult { get; set; }

        public Map<String, List<SelectOption>> selOptRolesMap       = VDST_FileUpload_Utils.getEventTypeToParticipantRolesSelOptsMap();
        public List<SelectOption>              selOptStates         = VDST_Utils.getStatesNames();
        public List<SelectOption>              selOptSuffixes       = VDST_FileUpload_Utils.getSuffixes();
        public List<SelectOption>              selOptProfessions    = VDST_FileUpload_Utils.getProfessions();
        public List<SelectOption>              selOptCredentials    = VDST_FileUpload_Utils.getCredentials();
        public List<SelectOption>              selOptCountries      = VDST_FileUpload_Utils.getCountries();

        public ParticipantEditValidator () {
            this.sObj = new VDST_BatchRecord_gne__c();
            this.validResult = new ParticipantValidationResult();
        }

        public ParticipantEditValidator (VDST_BatchRecord_gne__c sObj) {
            this.sObj = sObj;
            this.validResult = new ParticipantValidationResult();
        }

        public void assignNewSObject(sObject sObj) {
            this.sObj = (VDST_BatchRecord_gne__c)sObj ;
            this.validResult = new ParticipantValidationResult();
        }

        public ValidationResult validate() {
            validResult.clearAllErrors();
            // Participant Role
            if(String.isBlank(sObj.ParticipantRole_gne__c)) {
                validResult.setError('roleBlank', 'Participant Role field is required');
            } else {
                if( selOptRolesMap.containsKey( sObj.EventType_gne__c ) ) {
                    sObj.ParticipantRole_gne__c = sObj.ParticipantRole_gne__c.trim();
                    SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn( selOptRolesMap.get( sObj.EventType_gne__c ), sObj.ParticipantRole_gne__c );
                    if(selOpt != null) {
                        sObj.ParticipantRole_gne__c = selOpt.getValue();
                    } else {
                        validResult.setError('role', 'Invalid Participant Role');
                    }
                } else {
                    validResult.setError('role', 'Participant Role is invalid due to invalid parent Event Type');
                }

            }
            // First Name field
            if(String.isBlank(sObj.FirstName_gne__c)) {
                validResult.setError('fname', 'First Name field is required');
            }
            // Last Name field
            if(String.isBlank(sObj.LastName_gne__c)) {
                validResult.setError('lname', 'Last Name field is required');
            }
            // Suffix
            if(!String.isBlank(sObj.Suffix_txt_gne__c)) {
                sObj.Suffix_txt_gne__c = sObj.Suffix_txt_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptSuffixes, sObj.Suffix_txt_gne__c);
                if(selOpt != null) {
                    sObj.Suffix_gne__c = selOpt.getValue();
                    sObj.Suffix_txt_gne__c = null;
                } else {
                    validResult.setError('suffix', 'Invalid Suffix');
                }
            }
            // Email field
            if(!String.isBlank(sObj.Email_txt_gne__c) && VDST_Utils.validateEmail(sObj.Email_txt_gne__c)) {
                sObj.Email_gne__c = sObj.Email_txt_gne__c;
            } else if(!String.isBlank(sObj.Email_txt_gne__c)) {
                validResult.setError('email', 'Invalid email format');
            }
            // Participant Affiliation field
            if(String.isBlank(sObj.Affiliation_gne__c)) {
                validResult.setError('affiliation', 'Participant Affiliation field is required');
            }
            // Participant Profession field
            if(String.isBlank(sObj.Profession_gne__c)) {
                validResult.setError('professionBlank', 'Participant Profession field is required');
            } else {
                sObj.Profession_gne__c = sObj.Profession_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptProfessions, sObj.Profession_gne__c);
                if(selOpt != null) {
                    sObj.Profession_gne__c = selOpt.getValue();
                } else {
                    validResult.setError('profession', 'Invalid Participant Profession');
                }
            }
            // Credential field
            if(String.isBlank(sObj.Credential_gne__c)) {
               validResult.setError('credentialBlank', 'Credential field is required');
            } else {
                sObj.Credential_gne__c = sObj.Credential_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptCredentials, sObj.Credential_gne__c);
                if(selOpt != null) {
                    sObj.Credential_gne__c = selOpt.getValue();
                } else {
                    validResult.setError('credential', 'Invalid Participant Credential');
                }
            }
            // NPI field
            if(!String.isBlank(sObj.NPI_gne__c) && !Pattern.matches('^[0-9]{10}$', sObj.NPI_gne__c)) {
                validResult.setError('npi', 'Invalid NPI format');
            }
            // License
            if(!String.isBlank(sObj.StateLicenseNumber_gne__c)) {
                sObj.StateLicenseNumber_gne__c = sObj.StateLicenseNumber_gne__c.toUpperCase();
            }
            if(!String.isBlank(sObj.StateLicenseNumber_gne__c) && String.isBlank(sObj.LicenseState_gne__c)) {
                validResult.setError('licenseStaBlank', 'License State is required for License Number');
            } else if(!String.isBlank(sObj.LicenseState_gne__c)) {
                sObj.LicenseState_gne__c = sObj.LicenseState_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptStates, sObj.LicenseState_gne__c);
                if(selOpt != null) {
                    sObj.LicenseState_gne__c = selOpt.getValue();
                } else {
                    validResult.setError('licenseSta', 'Invalid License State');
                }
            }
            if(String.isBlank(sObj.StateLicenseNumber_gne__c) && !String.isBlank(sObj.LicenseState_gne__c)) {
                validResult.setError('licenseNum', 'License Number is required for License State');
            }
            // Item Quantity
            if(!String.isBlank(sObj.Quantity_txt_gne__c)) {
                try {
                    sObj.Quantity_txt_gne__c = sObj.Quantity_txt_gne__c.replace(' ', '');
                    Integer quantity = Integer.valueOf(sObj.Quantity_txt_gne__c);
                    sObj.Quantity_gne__c = quantity;
                    if( !Pattern.matches('^[0-9]{0,3}$', sObj.Quantity_txt_gne__c ) ) {
                        validResult.setError('quantity', 'Item Quantity should have a maximum of 3 digits');
                    }
                    if(quantity < 0) {
                        validResult.setError('quantity', 'Item Quantity cannot be negative');
                    }
                } catch(Exception ex) {
                    validResult.setError('quantity', 'Invalid Item Quantity');
                }
            }

            Boolean isRoleOtherThanVendor = ( sObj.ParticipantRole_gne__c != 'VNDSTAFF' );
            // Country
            if(isRoleOtherThanVendor && String.isBlank(sObj.ParticipantCountry_gne__c)) {
                validResult.setError('countryBlank', 'Country field is required for current Participant Role');
            } else if(!String.isBlank(sObj.ParticipantCountry_gne__c)) {
                sObj.ParticipantCountry_gne__c = sObj.ParticipantCountry_gne__c.trim();
                SelectOption selOpt = VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptCountries, sObj.ParticipantCountry_gne__c);
                if(selOpt != null) {
                    sObj.ParticipantCountry_gne__c = selOpt.getValue();
                } else {
                    validResult.setError('country', 'Invalid Country');
                }
            }
            // Street Address 1 field
            if(isRoleOtherThanVendor && String.isBlank(sObj.ParticipantStreetAddress_gne__c)) {
                validResult.setError('street1', 'Street Address field is required for current Participant Role');
            }

            if(String.isNotBlank(sObj.ParticipantStreetAddress_gne__c) && !VDST_Utils.validateAddress(sObj.ParticipantStreetAddress_gne__c)) {
                validResult.setError('street1', 'Street Address contains illegal characters');
            }
            if(String.isNotBlank(sObj.ParticipantStreetAddress2_gne__c) && !VDST_Utils.validateAddress(sObj.ParticipantStreetAddress2_gne__c)) {
                validResult.setError('street2', 'Street Address2 contains illegal characters');
            }

            // City field
            if(isRoleOtherThanVendor && String.isBlank(sObj.ParticipantCity_gne__c)) {
                validResult.setError('city', 'City field is required for current Participant Role');
            }
            // City field
            if(String.isNotBlank(sObj.ParticipantCity_gne__c) && (sObj.ParticipantCity_gne__c.equalsIgnoreCase('unk') || sObj.ParticipantCity_gne__c.equalsIgnoreCase('unknown'))) {
                validResult.setError('city', 'City cannot be equal to "UNK" or "UNKNOW"');
            }
            if(String.isNotBlank(sObj.ParticipantCity_gne__c) && !VDST_Utils.validateCity(sObj.ParticipantCity_gne__c)) {
                validResult.setError('city', 'City name contains illegal characters');
            }
            // State field
            if(isRoleOtherThanVendor && String.isBlank(sObj.ParticipantState_gne__c)) {
                validResult.setError('stateBlank', 'State Province field is required for current Participant Role');
            } else if(!String.isBlank(sObj.ParticipantState_gne__c) && 'USA'.equals(sObj.ParticipantCountry_gne__c)) {
                sObj.ParticipantState_gne__c = sObj.ParticipantState_gne__c.trim();
                SelectOption selOpt= VDST_FileUpload_Utils.whenSelectOptionListContainsValueThenReturn(selOptStates, sObj.ParticipantState_gne__c);
                if(selOpt != null) {
                    sObj.ParticipantState_gne__c = selOpt.getValue();
                } else {
                    validResult.setError('state', 'Invalid State');
                }
            } else if(String.isNotBlank(sObj.ParticipantState_gne__c) && !VDST_Utils.validateState(sObj.ParticipantState_gne__c)) {
                validResult.setError('state', 'State name contains illegal characters');
            }
            // Postal Code
            if(isRoleOtherThanVendor && String.isBlank(sObj.ParticipantPostalCode_gne__c)) {
                validResult.setError('zipCode', 'Postal Code field is required for current Participant Role');
            } else if(!String.isBlank(sObj.ParticipantPostalCode_gne__c)) {
                sObj.ParticipantPostalCode_gne__c = sObj.ParticipantPostalCode_gne__c.toUpperCase();
                if(('USA'.equals(sObj.ParticipantCountry_gne__c) || 'PRI'.equals(sObj.ParticipantCountry_gne__c)) && !Pattern.matches('^[0-9]{5}||[0-9]{5}-{1}[0-9]{4}$', sObj.ParticipantPostalCode_gne__c)) {
                    validResult.setError('zipCode', 'Invalid Postal Code format');
                } else if(!Pattern.matches('^[0-9a-zA-Z\\-\\s]+$', sObj.ParticipantPostalCode_gne__c)) {
                    validResult.setError('zipCode', 'Invalid Postal Code format');
                }
            }
            sObj.isValid__c = validResult.isValid();
            return validResult;
        }
    }

    // ****************************** DEFAULTERS ******************************
    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Class helper for setting default values for Events
    */
    public class EventDefaulter implements Defaultable {
        private VDST_BatchRecord_gne__c sObj { get; set; }

        public EventDefaulter(VDST_BatchRecord_gne__c sObj) {
            this.sObj = sObj;
        }

        public void setDefaults() {
            Boolean isTypeCFF = (sObj.EventType_gne__c == 'CFF');
            if(String.isBlank(sObj.VenueType_gne__c)){
                if(isTypeCFF) {
                    sObj.VenueType_gne__c = 'Physical';
                } else {
                    sObj.VenueType_gne__c = 'Virtual';
                }
            }
            if(VDST_Utils.eventToExpenseTypeMap().containsKey(sObj.EventType_gne__c)) {
                sObj.TOVType_gne__c = VDST_Utils.eventToExpenseTypeMap().get(sObj.EventType_gne__c);
            }
            if(!isTypeCFF) {
                setVenueAddress();
            }
        }

        public void setVenueAddress() {
            if(String.isBlank(sObj.VenueName_gne__c)){
                sObj.VenueName_gne__c = 'Virtual';
            }
            if(String.isBlank(sObj.VenueCountry_gne__c)){
                sObj.VenueCountry_gne__c = 'USA';
            }
            if(String.isBlank(sObj.VenueState_gne__c)){
                sObj.VenueState_gne__c = 'CA';
            }
            if(String.isBlank(sObj.VenueStreetAddress_gne__c)){
                sObj.VenueStreetAddress_gne__c = '1 DNA Way';
            }
            if(String.isBlank(sObj.VenueCity_gne__c)){
                sObj.VenueCity_gne__c = 'South San Francisco';
            }
            if(String.isBlank(sObj.VenuePostalCode_gne__c)){
                sObj.VenuePostalCode_gne__c = '94080';
            }
        }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Class helper for setting default values for Participants
    */
    public class ParticipantDefaulter implements Defaultable {
        private VDST_BatchRecord_gne__c sObj { get; set; }

        public ParticipantDefaulter(VDST_BatchRecord_gne__c sObj) {
            this.sObj = sObj;
        }

        public void setDefaults() {
            if(String.isBlank(sObj.ParticipantRole_gne__c)){
                sObj.ParticipantRole_gne__c = 'ATND';
            }
            if(String.isBlank(sObj.Quantity_txt_gne__c)){
                sObj.Quantity_gne__c = 1;
                sObj.Quantity_txt_gne__c = '1';
            }
            if(String.isBlank(sObj.ParticipantCountry_gne__c)){
                sObj.ParticipantCountry_gne__c = 'USA';
            }
            /*
            if(sObj.ParticipantCountry_gne__c == 'USA' && String.isBlank(sObj.ParticipantState_gne__c)) {
                sObj.ParticipantState_gne__c = 'CA';
            }
            if(String.isBlank(sObj.ParticipantCity_gne__c)) {
                sObj.ParticipantCity_gne__c = 'South San Francisco';
            }
            if(String.isBlank(sObj.ParticipantStreetAddress_gne__c)) {
                sObj.ParticipantStreetAddress_gne__c = '1 DNA Way';
            }
            if(String.isBlank(sObj.ParticipantPostalCode_gne__c)) {
                sObj.ParticipantPostalCode_gne__c = '94080';
            }
            */
        }
    }

    // -------------------------------------------------------------------------
    // ------------------------ ROOT CLASS DECLARATIONS ------------------------
    // -------------------------------------------------------------------------
    /** @date 10/26/2013
    * @Author Konrad Malinowski
    * @description Interface Defaultable
    */
    public interface Defaultable {
        void setDefaults();
    }

    /** @date 10/26/2013
    * @Author Konrad Malinowski
    * @description Interface Validateable
    */
    public interface Validateable {
        ValidationResult validate();
        void assignNewSObject(sObject sObj);
    }

    /** @date 10/26/2013
    * @Author Konrad Malinowski
    * @description Class ValidationResult
    */
    public virtual class ValidationResult {
        public Map<String, String> errMap { get; set; }

        public ValidationResult() {
            errMap = new Map<String, String>();
        }

        public Boolean isError(String key) {
            return ( ( ( String )errMap.get( key ) ).length() > 0 );
        }

        public void setError(String key, String value) {
            errMap.put(key, value);
        }

        public void clearError(String key) {
            errMap.put(key, '');
        }

        public void clearAllErrors() {
            for(String key : errMap.keySet()) {
                errMap.put(key, '');
            }
        }

        public Boolean isValid() {
            for(String key : errMap.keySet()) {
                if( ( ( String )errMap.get( key ) ).length() > 0 ) {
                    return false;
                }
            }
            return true;
        }
    }

    /** @date 10/26/2013
    * @Author Konrad Malinowski
    * @description Class UserWrapper
    */
    public class UserWrapper {
        public String          firstName   { get; set; }
        public String          lastName    { get; set; }

        public UserWrapper(String fn, String ln) {
            firstName = fn;
            lastName = ln;
        }
    }

    /** @date 10/26/2013
    * @Author Konrad Malinowski
    * @description Class SaveResult
    */
    public class SaveResult {
        public Boolean isSuccess { get; set; }
        public String  actionMsg { get; set { isSuccess = true;  actionMsg = value; } }
        public String  errorMsg  { get; set { isSuccess = false; errorMsg = value;  } }

        public void clearMessages() {
            actionMsg = '';
            errorMsg = '';
            isSuccess = null;
        }
    }

    // -------------------------------------------------------------------------
    // ------------------------- SAVE BATCH METHODS ----------------------------
    // -------------------------------------------------------------------------
    /** @date 10/1/2013
    * @Author Pawel Sprysak
    * @description Validate Participant and Event Id's
    * @param List<VDST_BatchRecord_gne__c> eventsBatchRecord (list of Batch Record events)
    * @param List<VDST_BatchRecord_gne__c> participantsBatchRecord (list of Batch Record participants)
    * @return Boolean
    */
    public static Boolean isEventAndParticipantIdUnique(List<VDST_BatchRecord_gne__c> eventsBatchRecord, List<VDST_BatchRecord_gne__c> participantsBatchRecord) {
        Set<String> eventId = new Set<String>();
        Set<String> prtcpntId = new Set<String>();
        if(eventsBatchRecord != null) {
            for(VDST_BatchRecord_gne__c br : eventsBatchRecord) {
                eventId.add(br.EventId_gne__c);
            }
        }
        for(VDST_BatchRecord_gne__c br : participantsBatchRecord) {
            prtcpntId.add(br.ParticipantID_gne__c);
        }
        List<VDST_Event_gne__c> eventList;
        List<VDST_EventPrtcpntAccnt_gne__c> prtcpntList;
        List<VDST_DeletedParticipantsId_gne__c> removedPrtcpntsList;
        try {
            eventList = [SELECT Id, VendorEventID_gne__c
                FROM VDST_Event_gne__c WHERE VendorEventID_gne__c IN :eventId];
            prtcpntList = [SELECT Id, VendorParticipantID_gne__c
                FROM VDST_EventPrtcpntAccnt_gne__c WHERE VendorParticipantID_gne__c IN :prtcpntId];
            removedPrtcpntsList = [ SELECT Id, VendorParticipantId_gne__c
                FROM VDST_DeletedParticipantsId_gne__c WHERE VendorParticipantId_gne__c IN :prtcpntId ];
        } catch (QueryException ex) {
            eventList = new List<VDST_Event_gne__c>();
            prtcpntList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        }

        if(eventList.size() > 0) {
            Set<String> duplicateSet = new Set<String>();
            for(VDST_Event_gne__c ev : eventList) {
                duplicateSet.add(ev.VendorEventID_gne__c);
            }
            for(VDST_BatchRecord_gne__c br : eventsBatchRecord) {
                if(duplicateSet.contains(br.EventId_gne__c)) {
                    br.isValid__c = false;
                }
            }
            return false;
        } else if(prtcpntList.size() > 0 || removedPrtcpntsList.size() > 0) {
            Set<String> duplicateSet = new Set<String>();
            for(VDST_EventPrtcpntAccnt_gne__c prtcpnt : prtcpntList) {
                duplicateSet.add(prtcpnt.VendorParticipantID_gne__c);
            }
            for(VDST_DeletedParticipantsId_gne__c prtcpnt : removedPrtcpntsList) {
                duplicateSet.add(prtcpnt.VendorParticipantID_gne__c);
            }
            List<VDST_BatchRecord_gne__c> brList = new List<VDST_BatchRecord_gne__c>();
            for(VDST_BatchRecord_gne__c br : participantsBatchRecord) {
                if(duplicateSet.contains(br.ParticipantID_gne__c)) {
                    br.ParticipantID_gne__c += String.valueOf(Integer.valueOf(Math.random()*1000));
                    brList.add(br);
                }
            }
            isEventAndParticipantIdUnique(null, brList);
            return true;
        } else {
            return true;
        }
    }

    /** @date 10/1/2013
    * @Author Pawel Sprysak
    * @description Create Event objects from Batch Record
    * @param List<VDST_BatchRecord_gne__c> eventsBatchRecord (list of Event batch records to handle)
    * @param Id usrPrivilages (user groupd Id)
    * @return Map<String, String>
    */
    public static Map<String, String> createEventObjects(List<VDST_BatchRecord_gne__c> eventsBatchRecord) {
        // Event Management
        Savepoint sp = Database.setSavepoint();
        try {
            List<VDST_Event_gne__c> eventList = new List<VDST_Event_gne__c>();
            for(VDST_BatchRecord_gne__c br : eventsBatchRecord) {
                eventList.add(new VDST_Event_gne__c(
                    AccountableGNE_UnixID_gne__c    = br.AccountablePartyID_gne__c,
                    AccountableGNE_LastName_gne__c  = br.AccountablePartyLastName_gne__c,
                    AccountableGNE_FirstName_gne__c = br.AccountablePartyFirstName_gne__c,
                    CurrentStatus_gne__c            = 'CLOSED',
                    CurrentStatusDate_gne__c        = Date.today(),
                    EventEndDate_gne__c             = br.EventStartDate_gne__c,
                    EventStartDate_gne__c           = br.EventStartDate_gne__c,
                    EventMeetingName_gne__c         = br.MeetingName_gne__c,
                    EventType_gne__c                = br.EventType_gne__c,
                    isBatch_gne__c                  = true,
                    ItemAmount_gne__c               = br.TOVAmount_gne__c,
                    ItemName_gne__c                 = br.TOVItemName_gne__c,
                    LogisticVendor_gne__c           = br.VDST_BatchFile_gne__r.VDST_EventProvider_gne__c,
                    ResearchPaymentTypeCode_gne__c  = 'Non-Clinical',
                    VendorEventID_gne__c            = br.EventId_gne__c,
                    TotalAudioVisual_gne__c         = 0,
                    VDST_BatchFile_gne__c           = br.VDST_BatchFile_gne__c,
                    MealLoc_gne__c                 = br.TOVMealLoc_gne__c,
                    TotPlanAttCntUser_gne__c        = (
                        'CFF'.equals(br.EventType_gne__c) ?
                        br.TotPlanAttCntUser_gne__c :
                        br.InvalidParticipants_gne__c + br.ValidParticipants_gne__c
                    )
                ));
            }

            insert eventList;

            Map<String, String> idMapping = new Map<String, String>();
            for(VDST_Event_gne__c ev : eventList) {
                idMapping.put(ev.VendorEventID_gne__c, ev.Id);
            }
            eventList = null;
            // Address and Brand Management
            List<VDST_Address_gne__c> addressList = new List<VDST_Address_gne__c>();
            List<VDST_EventBrandTopic_gne__c> brandList = new List<VDST_EventBrandTopic_gne__c>();
            for(VDST_BatchRecord_gne__c br : eventsBatchRecord) {
                String StatesNameHolder = '';
                String StatesNameCode = 'ANY';
                if('USA'.equals(br.VenueCountry_gne__c)) {
                    StatesNameCode = br.VenueState_gne__c;
                } else {
                    StatesNameHolder = br.VenueState_gne__c;
                }
                addressList.add(new VDST_Address_gne__c(
                    VDST_Event_gne__c       = idMapping.get(br.EventId_gne__c),
                    AddressType_gne__c      = br.VenueType_gne__c,
                    City_gne__c             = br.VenueCity_gne__c,
                    Country_gne__c          = br.VenueCountry_gne__c,
                    PostalCode_gne__c       = br.VenuePostalCode_gne__c,
                    StateProvince_gne__c    = StatesNameCode,
                    StatesNameHolder_gne__c = StatesNameHolder,
                    StreetAddress_gne__c    = br.VenueStreetAddress_gne__c,
                    StreetAddress2_gne__c   = null
                ));
                for(String brandId : br.BrandsId_gne__c.split(',')) {
                    brandList.add(new VDST_EventBrandTopic_gne__c(
                        Product_Catalog_gne__c  = brandId.trim(),
                        VDST_Event_gne__c       = idMapping.get(br.EventId_gne__c)
                    ));
                }
            }
            insert addressList;
            insert brandList;
            Map<String, String> idAddMapping = new Map<String, String>();
            for(VDST_Address_gne__c add : addressList) {
                idAddMapping.put(add.VDST_Event_gne__c, add.Id);
            }
            // Site Management
            List<VDST_EventSite_gne__c> siteList = new List<VDST_EventSite_gne__c>();
            for(VDST_BatchRecord_gne__c br : eventsBatchRecord) {
                siteList.add(new VDST_EventSite_gne__c(
                    VDST_Event_gne__c       = idMapping.get(br.EventId_gne__c),
                    VDST_Address_gne__c     = idAddMapping.get(idMapping.get(br.EventId_gne__c)),
                    EventSiteName_gne__c    = br.VenueName_gne__c
                ));
            }
            insert siteList;
            return idMapping;
        } catch(Exception ex) {
            log.logException('createEventObjects', ex);
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, 'VDST_FileUpload_Utils.createEventObjects exception: ' + getErrorMessageFromException(ex));
            return new Map<String, String>();
        }
    }

    /** @date 10/1/2013
    * @Author Pawel Sprysak
    * @description Create Participats objects from Batch Record
    * @param List<VDST_BatchRecord_gne__c> prtpcntsBatchRecord (list of Participants batch records to handle)
    * @param Map<String, String> eventIdMapping (map of Events Codes to Id's)
    * @param Map<String, Id> roleMap (map with mapping from role codes to role id's)
    * @param Map<String, String> eventToExpenseTypeMap (map with mapping with event types to event expenses)
    */
    public static void createPrtcpntObjects(List<VDST_BatchRecord_gne__c> prtpcntsBatchRecord, Map<String, String> eventIdMapping, Map<String, Id> roleMap, Map<String, String> eventToExpenseTypeMap) {
        Savepoint sp = Database.setSavepoint();
        try {
            List<VDST_Address_gne__c> addressList = new List<VDST_Address_gne__c>();
            for(VDST_BatchRecord_gne__c br : prtpcntsBatchRecord) {
                String StatesNameHolder = '';
                String StatesNameCode = 'ANY';
                if('USA'.equals(br.ParticipantCountry_gne__c)) {
                    StatesNameCode = br.ParticipantState_gne__c;
                } else {
                    StatesNameHolder = br.ParticipantState_gne__c;
                }
                addressList.add(new VDST_Address_gne__c(
                    VDST_Event_gne__c       = eventIdMapping.get(br.EventId_gne__c),
                    AddressType_gne__c      = 'Physical',
                    City_gne__c             = br.ParticipantCity_gne__c,
                    Country_gne__c          = br.ParticipantCountry_gne__c,
                    PostalCode_gne__c       = br.ParticipantPostalCode_gne__c,
                    StateProvince_gne__c    = StatesNameCode,
                    StatesNameHolder_gne__c = StatesNameHolder,
                    StreetAddress_gne__c    = br.ParticipantStreetAddress_gne__c,
                    StreetAddress2_gne__c   = br.ParticipantStreetAddress2_gne__c
                ));
            }
            insert addressList;
            Integer i = 0;
            List<VDST_EventPrtcpntAccnt_gne__c> prtcpntList = new List<VDST_EventPrtcpntAccnt_gne__c>();
            for(VDST_BatchRecord_gne__c br : prtpcntsBatchRecord) {
                String contractedStatus = 'NTCNTRCTD';
                if('MEDWRTG'.equals(br.EventType_gne__c)) {
                    contractedStatus = 'CNTRCTD';
                }
                prtcpntList.add(new VDST_EventPrtcpntAccnt_gne__c(
                    VDST_Event_gne__c                   = eventIdMapping.get(br.EventId_gne__c),
                    VDST_Address_gne__c                 = addressList.get(i).Id,
                    BusinessPhone_gne__c                = br.Phone_gne__c,
                    Credential_gne__c                   = br.Credential_gne__c,
                    Email_gne__c                        = br.Email_gne__c,
                    FirstName_gne__c                    = br.FirstName_gne__c,
                    isBatch_gne__c                      = true,
                    LastName_gne__c                     = br.LastName_gne__c,
                    LicenseNumber_gne__c                = br.StateLicenseNumber_gne__c,
                    LicenseState_gne__c                 = br.LicenseState_gne__c,
                    MiddleName_gne__c                   = br.MiddleName_gne__c,
                    NPI_gne__c                          = br.NPI_gne__c,
                    ParticipantAffiliation_gne__c       = br.Affiliation_gne__c,
                    ParticipantProfession_gne__c        = br.Profession_gne__c,
                    EventParticipantRole_gne__c         = roleMap.get(br.ParticipantRole_gne__c),
                    Suffix_gne__c                       = br.Suffix_gne__c,
                    VendorParticipantID_gne__c          = br.ParticipantID_gne__c,
                    PartyType_gne__c                    = 'INDV',
                    ParticipantContractStatus_gne__c    = contractedStatus
                ));
                i++;
            }
            insert prtcpntList;
            addressList = null;
            if(!'CFF'.equals(prtpcntsBatchRecord.get(0).EventType_gne__c)) {
                List<VDST_PrtcpntTransaction_gne__c> prtcpntTxnList = new List<VDST_PrtcpntTransaction_gne__c>();
                i = 0;
                for(VDST_BatchRecord_gne__c br : prtpcntsBatchRecord) {
                    Double itemAount = 0;
                    if('MEDWRTG'.equals(br.EventType_gne__c)) {
                        itemAount = br.VDST_ParentEvent_gne__r.TOVAmount_gne__c;
                    } else {
                        itemAount = br.VDST_ParentEvent_gne__r.TOVAmount_gne__c * br.Quantity_gne__c;
                    }
                    prtcpntTxnList.add(new VDST_PrtcpntTransaction_gne__c(
                        VDST_EventPrtcpntAccnt_gne__c       = prtcpntList.get(i).Id,
                        VDST_PaidToParty_gne__c             = prtcpntList.get(i).Id,
                        FeePayToPartyType_gne__c            = 'INDV',
                        ItemQuantity_gne__c                 = br.Quantity_gne__c,
                        TransactionAllocationType_gne__c    = 'DIRECT',
                        TransactionAmount_gne__c            = itemAount,
                        TransactionLevel_gne__c             = 'INDV',
                        TransactionTypeCode_gne__c          = eventToExpenseTypeMap.get(br.EventType_gne__c)
                    ));
                    i++;
                }
                insert prtcpntTxnList;
            }
        } catch(Exception ex) {
            log.logException('createPrtcpntObjects', ex);
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, 'VDST_FileUpload_Utils.createPrtcpntObjects exception: ' + getErrorMessageFromException(ex));
        }
    }
}