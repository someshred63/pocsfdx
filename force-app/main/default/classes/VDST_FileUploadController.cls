/** @date 12/2/2013
* @Author Konrad Malinowski
* @description Controller for handling File Upload page
*/
public with sharing class VDST_FileUploadController {
    private static final Logger log = Logger.getInstance(VDST_FileUploadController.class.getName());

    // -------------------------------------------------------------------------
    // ----------------------------- VARIABLES ---------------------------------
    // -------------------------------------------------------------------------
    // Provisioning
    public VDST_Utils.PrivilegesWrapper privileges                  { get; set; }

    public Boolean                  isBatchFileIdParamValid         { get; set; }
    public Boolean                  isBatchParticipantIdParamValid  { get; set; }
    public List<SelectOption>       countries                       { get { return VDST_FileUpload_Utils.getCountries();    } }
    public List<SelectOption>       states                          { get { return VDST_Utils.getStatesNames();             } }
    public List<SelectOption>       expenseTypes                    { get { return VDST_FileUpload_Utils.getExpenseTypes(); } }
    public List<SelectOption>       participantRoles                { get { return VDST_FileUpload_Utils.getParticipantRoles(batchRecEventIdForEdit);  } }
    public List<SelectOption>       suffixes                        { get { return VDST_FileUpload_Utils.getSuffixes();     } }
    public List<SelectOption>       professions                     { get { return VDST_FileUpload_Utils.getProfessions();  } }
    public List<SelectOption>       credentials                     { get { return VDST_FileUpload_Utils.getCredentials();  } }
    public List<SelectOption>       venueTypes                      { get { return VDST_FileUpload_Utils.getVenueTypes();   } }
    public List<SelectOption>       mealTypes                       { get { return VDST_FileUpload_Utils.getMealTypes();   } }
    public List<SelectOption>       drugNames                       { get { return VDST_Utils.getDrugNames();               } }

    public List<String>             multiDrugNames                  { get; set; }

    public VDST_FileUpload_Utils.SaveResult   eventSaveResult       { get; set; }
    public VDST_FileUpload_Utils.SaveResult   participantSaveResult { get; set; }

    public VDST_PagingUtils         filePaginationUtil              { get; set; }
    public VDST_PagingUtils         eventPaginationUtil             { get; set; }

    public String                   deleteFileIds                   { get; set; }
    public String                   nowDateTimeAsString             { get { return DateTime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); } }
    public String                   timeZoneOffsetMilisecs          {
        get {
            String nowTxt = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
            DateTime now = DateTime.valueOfGmt(nowTxt);
            TimeZone timeZone = UserInfo.getTimeZone();
            Integer offset = timeZone.getOffset(now);
            return String.valueOf(offset);
        }
    }
    public String                   salesforceBaseURL               { get { return URL.getSalesforceBaseUrl().toExternalForm();     } }
    public String                   vendorCode                      { get { return privileges.providerCode;                         } }
    public String                   vendorCodeId                    { get { return privileges.providerId;                           } }
    public Map<String, VDST_Mapping_gne__c> mappingMap              { get { return VDST_FileUpload_Utils.commonUtils.mappingMap;    } }

    public Boolean                  canAccessPage                   {
        get {
            if( privileges.hasPrivileges && (privileges.isGene || privileges.isProxy) && !privileges.userRole.equals('Monitoring') ) {
                return true;
            } else {
                return false;
            }
        }
    }
    public String                   fileListErrorMsg                { get; set; }

    public Id                                               batchFileIdForRec               { get; set; }
    public VDST_FileUpload_Utils.BatchFileWrapper           batchFileWrapperForRec {
        get { return VDST_FileUpload_Utils.getBatchFileWrapperFromId(batchFileIdForRec); }
    }
    public Id                                               batchRecEventIdForEdit          { get; set; }
    public VDST_FileUpload_Utils.BatchRecordWrapper         batchRecEventWrapperForEdit     { get; set; }
    public VDST_FileUpload_Utils.EventEditWrapper           eventEditWrap                   { get; set; }
    public Id                                               batchRecParticipantIdForEdit    { get; set; }
    public VDST_FileUpload_Utils.ParticipantEditdWrapper    participantEditWrap             { get; set; }
    public List<VDST_FileUpload_Utils.BatchFileWrapper>     batchFileWrappers {
        get { return VDST_FileUpload_Utils.getBatchFileWrappers(filePaginationUtil); }
    }
    public List<VDST_FileUpload_Utils.BatchRecordWrapper>   batchRecordWrappers {
        get { return VDST_FileUpload_Utils.getBatchRecordWrappers(batchFileIdForRec, eventPaginationUtil); }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VDST_FileUploadController constructor
    */
    public VDST_FileUploadController() {
        privileges =            new VDST_Utils.PrivilegesWrapper();
        multiDrugNames =        new List<String>();
        eventSaveResult =       new VDST_FileUpload_Utils.SaveResult();
        participantSaveResult = new VDST_FileUpload_Utils.SaveResult();
        filePaginationUtil =    new VDST_PagingUtils(10);
        eventPaginationUtil =   new VDST_PagingUtils(10);
        showFileDetailsIfIdIsValid();
        showParticipantEditIfIdIsValid();
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for checking is id in getter for Batch File correct
    */
    private void showFileDetailsIfIdIsValid() {
        isBatchFileIdParamValid = false;
        try {
            Id batchFileId = ApexPages.currentPage().getParameters().get('id');
            if(batchFileId == null) {
                throw new VDST_FileUpload_Utils.VdstException();
            }
            String batchFileObjName = batchFileId.getSObjectType().getDescribe().getName();
            if(batchFileObjName != 'VDST_BatchFile_gne__c') {
                throw new VDST_FileUpload_Utils.VdstException();
            }
            if( VDST_FileUpload_Utils.getBatchFile(batchFileId) == null ) {
                throw new VDST_FileUpload_Utils.VdstException();
            }

            batchFileIdForRec = batchFileId;
            isBatchFileIdParamValid = true;
        } catch(Exception ex) {
            log.logException('showFileDetailsIfIdIsValid', ex);
        }
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for checking is id in getter for Batch Participant Record correct
    */
    // For debugging purposes, method shows modal edit participant if given participantId parameter is valid
    private void showParticipantEditIfIdIsValid() {
        isBatchParticipantIdParamValid = false;
        try {
            Id participantId = ApexPages.currentPage().getParameters().get('participantId');
            if(participantId == null) {
                throw new VDST_FileUpload_Utils.VdstException();
            }
            String batchParticipantObjName = participantId.getSObjectType().getDescribe().getName();
            if(batchParticipantObjName != 'VDST_BatchRecord_gne__c') {
                throw new VDST_FileUpload_Utils.VdstException();
            }
            VDST_BatchRecord_gne__c batchParticipant = VDST_FileUpload_Utils.getBatchParticipant(participantId);
            if( batchParticipant == null ) {
                throw new VDST_FileUpload_Utils.VdstException();
            }

            batchRecEventIdForEdit = batchParticipant.VDST_ParentEvent_gne__c;
            batchRecParticipantIdForEdit = participantId;
            editParticipantBatchRec();
            isBatchParticipantIdParamValid = true;
        } catch(Exception ex) {
            log.logException('showParticipantEditIfIdIsValid', ex);
        }
    }

    // -------------------------------------------------------------------------
    // --------------------------- ACTION METHODS ------------------------------
    // -------------------------------------------------------------------------

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for deleting Batch File (changing Batch File isDeleted flag)
    * @return PageReference
    */
    public PageReference deleteLoad() {
        fileListErrorMsg = '';
        try {
            if(!String.isBlank(deleteFileIds)) {
                List<String> fileIdsToDelete = deleteFileIds.split(',');
                List<VDST_BatchFile_gne__c> filesToDelete = VDST_FileUpload_Utils.getBatchFiles(fileIdsToDelete);
                for(VDST_BatchFile_gne__c bf : filesToDelete) {
                    bf.isDeleted_gne__c = true;
                }
                update filesToDelete;
            }
        } catch(Exception ex) {
            fileListErrorMsg = 'An error occurred while deleting load';
        }
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Setting data for editing Batch Event Record and validate data
    * @return PageReference
    */
    public PageReference editEventBatchRec() {
        for(VDST_FileUpload_Utils.BatchRecordWrapper btchRecWrap : batchRecordWrappers) {
            if(btchRecWrap.batchRecSObj.Id == batchRecEventIdForEdit) {
                batchRecEventWrapperForEdit = btchRecWrap;
                eventEditWrap = new VDST_FileUpload_Utils.EventEditWrapper( VDST_FileUpload_Utils.getBatchRecordEvent( batchRecEventIdForEdit ) );
                eventSaveResult.clearMessages();
                if(eventEditWrap.isEditeable) {
                    eventEditWrap.validate();
                }
                break;
            }
        }
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Setting data for editing Batch Participant Record and validate data
    * @return PageReference
    */
    public PageReference editParticipantBatchRec() {
        participantSaveResult.clearMessages();
        participantEditWrap = new VDST_FileUpload_Utils.ParticipantEditdWrapper( VDST_FileUpload_Utils.getBatchRecordParticipant( batchRecParticipantIdForEdit ) );
        if(participantEditWrap.isEditeable) {
            participantEditWrap.validate();
        }
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for triggering save method on Event Edit
    * @return PageReference
    */
    public PageReference saveEvent() {
        eventSaveResult.clearMessages();
        eventSaveResult = eventEditWrap.save();
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for triggering revalidation method on Event Edit
    * @return PageReference
    */
    public PageReference revalildateEditEvent() {
        eventSaveResult.clearMessages();
        eventEditWrap.revalidate();
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for triggering save method on Participant Edit
    * @return PageReference
    */
    public PageReference saveParticipant() {
        participantSaveResult.clearMessages();
        participantSaveResult = participantEditWrap.save();
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for triggering revalidation method on Participant Edit
    * @return PageReference
    */
    public PageReference revalildateParticipantEvent() {
        participantSaveResult.clearMessages();
        participantEditWrap.revalidate();
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for setting list of Brands into Brands list before opening modal window
    * @return PageReference
    */
    public PageReference goToSelectBrands() {
        multiDrugNames = eventEditWrap.getDrugsFromStringList();
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for setting brands variable from Brands modal window
    * @return PageReference
    */
    public PageReference selectBrands() {
        eventEditWrap.setBrandFromList(multiDrugNames, drugNames);
        return null;
    }

    /** @date 10/16/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Method for saving batch
    * @return PageReference
    */
    public PageReference saveBatch() {
        try {
            if(batchFileWrapperForRec.batchFileSObj.BatchRecords_gne__c <= 100) {
                Map<String, String> eventToExpenseTypeMap = VDST_Utils.eventToExpenseTypeMap();
                Map<String, Id> roleMap = VDST_Utils.getBatchRoleMap(batchFileWrapperForRec.batchFileSObj.EventType_gne__c);

                List<VDST_BatchRecord_gne__c> brE = VDST_FileUpload_Utils.getBatchRecordsForSave(batchFileWrapperForRec.batchFileSObj.Id, true);
                List<VDST_BatchRecord_gne__c> brP = VDST_FileUpload_Utils.getBatchRecordsForSave(batchFileWrapperForRec.batchFileSObj.Id, false);

                if(VDST_FileUpload_Utils.isEventAndParticipantIdUnique(brE, brP)) {
                    update new VDST_BatchFile_gne__c(
                        Id = batchFileWrapperForRec.batchFileSObj.Id,
                        Status_gne__c = 'Stored',
                        ProcessStartDate_gne__c = DateTime.now(),
                        ProcessEndDate_gne__c = DateTime.now()
                    );
                    Map<String,String> mapson = VDST_FileUpload_Utils.createEventObjects(brE);
                    VDST_FileUpload_Utils.createPrtcpntObjects(brP, mapson, roleMap, eventToExpenseTypeMap);
                } else {
                    throw new VDST_FileUpload_Utils.VdstException();
                }
            } else {
                update new VDST_BatchFile_gne__c(
                    Id = batchFileWrapperForRec.batchFileSObj.Id,
                    Status_gne__c = 'To process',
                    ProcessStartDate_gne__c = null,
                    ProcessEndDate_gne__c = null,
                    BatchFileSaver_gne__c = UserInfo.getUserId()
                );
            }
        } catch(Exception ex) {
            fileListErrorMsg = 'An error occurred while saving batch';
            System.debug(LoggingLevel.ERROR, VDST_FileUpload_Utils.getErrorMessageFromException(ex));
        }
        return null;
    }
}