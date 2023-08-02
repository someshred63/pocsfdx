/** @date 2/16/2013
* @Author Pawel Sprysak
* @description Utility Class for Participants
*/
public without sharing class VDST_EventDetailPrtcpntUtils {
    private static final Logger log = Logger.getInstance(VDST_EventDetailPrtcpntUtils.class.getName());

    private static String                                     CONVERT_TO_STRING = 'X1X2X';
    private static List<String>                               PRCTPNT_VAL_FIELDS = new List<String>{ 'hasTrans', 'hasFees', 'DEA_gne', 'NPI_gne', 'LicenseNumber_gne', 'LicenseState_gne', 'UnixID_gne', 'BusinessPhone_gne', 'Email_gne', 'ParticipantAffiliation_gne', 'VDST_Address_gne.StreetAddress_gne', 'VDST_Address_gne.City_gne', 'VDST_Address_gne.Country_gne', 'VDST_Address_gne.PostalCode_gne', 'VDST_Address_gne.StateProvince_gne', 'ParticipantProfession_gne', 'ParticipantContractStatus_gne', 'Credential_gne', 'GNE_SFDC_ID_gne', 'ParticipantRole_gne', 'attendeeBox', 'spendBox' };
    private static String                                     STATUS_OCCURRED_NAME = 'OCCURRED';

    public String                                             IDLE_TRANSACTION_TYPE                         { get { return 'N/A'; } }
    public List<SelectOption>                                 individualParticipantTransactionTypes         { get; set; }
    public List<SelectOption>                                 organizationParticipantTransactionTypes       { get; set; }
    public Map<String, String>                                individualParticipantTransactionTypesMap      { get; set; }
    public Map<String, String>                                organizationParticipantTransactionTypesMap    { get; set; }
    public String                                             individualParticipantTransactionTypesJSON     { get; set; }
    public String                                             organizationParticipantTransactionTypesJSON   { get; set; }
    public String                                             transactionType                               { get; set; }
    public Boolean                                            isAssignHomePaymentIdToEditable               { get; set; }

    private String                                            editId            { get; set; }
    public String                                             eventType         { get; set; }
    public Decimal                                            itemAmount        { get; set; }
    //public String                                             providerName      { get; set; }
    //public String                                             providerCode      { get; set; }
    public Integer                                            eventDates        { get; set; }
    public VDST_EventDetailCommon                             commonUtils       { get; set; }
    public VDST_Validator.ParticipantsValidationInput         prtcpntValidObj   { get; set; }
    // Privileges
    public VDST_Utils.PrivilegesWrapper                       privileges        { get; set; }
    // Participants
    private List<VDST_EventPrtcpntAccnt_gne__c>               evPrtcpntList     { get; set; }
    private List<VDST_EventPrtcpntAccnt_gne__c>               listPrtcpnts      { get; set; }
    // Adding Participants by CSV
    public transient Blob                                     importFile        { get; set; }
    public String                                             importFileName    { get; set; }
    public List<PrtcpntWrapper>                               importedWrappedRows { get; set; }
    public ImportValidationStatusWrapper                      importValidationStatus { get; set; }
    public Boolean                                            showPrtcpntModal  { get; set; }
    public Integer                                            wrapperEditId     { get; set; }
    public PrtcpntWrapper                                     wrapperToEdit     { get; set; }
    public VDST_Event_gne__c                                  eventStartDate    { get; set; }
    // Editing Pariticpant
    public PrtcpntWrapper                                     prtcpnt           { get; set; }
    public String                                             prtcpntId         { get; set; }
    public Boolean                                            editableMode      { get; set; }
    public String                                             editableState     { get; set; }
    public Map<String, VDST_EventPrtcpntField_gne__c>         actualMap         { get; set; }
    // Managing Attendance
    public Integer                                            attDays           { get; set; }
    public List<String>                                       dateList          { get; set; }
    // Messages
    public String                                             editActionMessages{ get; set; }
    public String                                             editErrorMessages { get; set; }
    public String                                             prtcpntListMsg    { get; set; }
    public String                                             prtcpntListMsgErr { get; set; }
    public VDST_PagingUtils                                   prtcpntPagingUtil { get; set; }
    public VDST_PagingUtils                                   attPrtcpntPagingUtil { get; set; }
    public PrtcpntWrapper                                     orgParticipant    { get; set; }

    /** @date 29/10/2013
    * @Author Konrad Malinowski
    * @description Set Add Participant Buttons Visibility For Research Type
    */
    // TODO: check
    public class AddPrtcpntBtnsVisibility {
        public Boolean showIndv { get; set; }
        public Boolean showOrg  { get; set; }
        public AddPrtcpntBtnsVisibility(Boolean showAll) {
            showIndv = showAll;
            showOrg = showAll;
        }
    }
    // TODO: check
    public AddPrtcpntBtnsVisibility                           getRschPrtcpntBtnVisib() {
        if(!commonUtils.isResearchEvent) {
            return new AddPrtcpntBtnsVisibility(true);
        }
        List<VDST_EventPrtcpntAccnt_gne__c> rschPrtcptns = [ SELECT ParticipantRole_gne__c
            FROM VDST_EventPrtcpntAccnt_gne__c WHERE VDST_Event_gne__c = :editId ];
        if(rschPrtcptns == null || rschPrtcptns.size() == 0) {
            return new AddPrtcpntBtnsVisibility(true);
        }

        AddPrtcpntBtnsVisibility prtcptVisib = new AddPrtcpntBtnsVisibility(true);
        Set<String> rolesForHideIndvBtn = new Set<String>{ 'PAYEEPI' };
        Set<String> rolesForHideOrgBtn = new Set<String>{ 'PAYEE', 'PAYEEPI' };
        for(VDST_EventPrtcpntAccnt_gne__c p : rschPrtcptns) {
            if( rolesForHideIndvBtn.contains( p.ParticipantRole_gne__c ) ) {
                prtcptVisib.showIndv = false;
            }
            if( rolesForHideOrgBtn.contains( p.ParticipantRole_gne__c ) ) {
                prtcptVisib.showOrg = false;
            }
        }
        if(rschPrtcptns.size() >= 2) {
            prtcptVisib.showIndv = false;
            prtcptVisib.showOrg = false;
        }

        return prtcptVisib;
    }

    /** @date 2/16/2013
    * @Author Pawel Sprysak
    * @description Utility constructor
    * @param String eventId (Event Id)
    */
    public VDST_EventDetailPrtcpntUtils(String eventId) {
        editId = eventId;
        eventType = VDST_Utils.getEventTypeByEventId(editId);
        importedWrappedRows = new List<PrtcpntWrapper>();
        importValidationStatus = new ImportValidationStatusWrapper(importedWrappedRows);
        importValidationStatus.clear();
        // CSV Participants
        showPrtcpntModal = false;
        prtcpntPagingUtil = new VDST_PagingUtils(10);
        attPrtcpntPagingUtil = new VDST_PagingUtils(10);
        setNonResearchParticipantTransactionTypes();
        isAssignHomePaymentIdToEditable = false;
    }

    public void setNonResearchParticipantTransactionTypes() {
        individualParticipantTransactionTypes = new List<SelectOption>{
            new SelectOption(IDLE_TRANSACTION_TYPE, IDLE_TRANSACTION_TYPE),
            new SelectOption('HONORARIA'    , 'Consulting Fee'),
            new SelectOption('SVCFEE'       , 'Non-Consulting Compensation'),
            new SelectOption('NONACRDFEE'   , 'Non-Accredited Ed.'),
            new SelectOption('ROYALTY'      , 'Royalty/License Fee'),
            new SelectOption('GRANT'        , 'Grant'),
            new SelectOption('OOPTRVL'      , 'OOP Travel'),
            new SelectOption('OOPLODGNG'    , 'OOP Lodging'),
            new SelectOption('OOPMEALS'     , 'OOP Meals'),
            new SelectOption('OOPOTHR'      , 'OOP Other')
        };
        organizationParticipantTransactionTypes = new List<SelectOption>{
            new SelectOption(IDLE_TRANSACTION_TYPE, IDLE_TRANSACTION_TYPE),
            new SelectOption('GRANT'        , 'Grant'),
            new SelectOption('HONORARIA'    , 'Consulting Fee'),
            new SelectOption('ROYALTY'      , 'Royalty/License Fee'),
            new SelectOption('FCLTYFEE'     , 'Facility Fee'),
            new SelectOption('HCPMEALS'     , 'Food'),
            new SelectOption('CHARITY'      , 'Charitable Contributions')
        };
        individualParticipantTransactionTypesMap = new Map<String, String>();
        organizationParticipantTransactionTypesMap = new Map<String, String>();
        for(SelectOption so : individualParticipantTransactionTypes) {
            individualParticipantTransactionTypesMap.put(so.getValue(), so.getLabel());
            so.setLabel( so.getLabel().toUpperCase() );
        }
        for(SelectOption so : organizationParticipantTransactionTypes) {
            organizationParticipantTransactionTypesMap.put(so.getValue(), so.getLabel());
            so.setLabel( so.getLabel().toUpperCase() );
        }
        individualParticipantTransactionTypesJSON = JSON.serialize(individualParticipantTransactionTypesMap);
        organizationParticipantTransactionTypesJSON = JSON.serialize(organizationParticipantTransactionTypesMap);
    }

//////////////////////////////
// CSV Participants - BEGIN //
//////////////////////////////
    /** @date 3/7/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - VF Method for importing and processing CSV file
    * @return PageReference
    */
    public PageReference addPariticipantAttachment() {
        importCSV();
        showPrtcpntModal = true;
        return null;
    }

    /** @date 2/19/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - VF Method for changing modal (from Participant info to select file)
    * @return PageReference
    */
    public PageReference backToSelect() {
        showPrtcpntModal = false;
        return null;
    }

    /** @date 2/19/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - VF Method for showing edit mode for Participant
    * @return PageReference
    */
    public PageReference setWrapperToEdit() {
        wrapperToEdit = importedWrappedRows.get(wrapperEditId-1);
        return null;
    }

    /** @date 2/19/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - VF Method for saving changes on Participant form
    * @return PageReference
    */
    public PageReference savePrtcpnt() {
        trimParticipantFieldValues();
        importedWrappedRows.get(wrapperEditId-1).setValues(wrapperToEdit);
        validateBatchUnixIds();
        prtcpntListMsg = 'Participant list has been imported.';
        return null;
    }

    /** @date 2/20/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - Saving Records
    * @return PageReference
    */
    public PageReference saveRecords() {
        Map<String, Map<String, VDST_EventPrtcpntField_gne__c>> transactionVisMap = new Map<String, Map<String, VDST_EventPrtcpntField_gne__c>>();
        for(VDST_EventPrtcpntField_gne__c epf : [SELECT VDST_EventPrtcpntRole__c, FieldName_gne__c, IsVisible_gne__c, DefaultValue_gne__c FROM VDST_EventPrtcpntField_gne__c WHERE VDST_EventPrtcpntRole__r.EventType_gne__c = :eventType]) {
            if(!transactionVisMap.containsKey(epf.VDST_EventPrtcpntRole__c)) {
                transactionVisMap.put(epf.VDST_EventPrtcpntRole__c, new Map<String, VDST_EventPrtcpntField_gne__c>());
            }
            transactionVisMap.get(epf.VDST_EventPrtcpntRole__c).put(epf.FieldName_gne__c, epf);
        }
        Map<String, VDST_EventPrtcpntAccnt_gne__c> prtcpntMap = new Map<String, VDST_EventPrtcpntAccnt_gne__c>();
        listPrtcpnts = VDST_Utils.getParticipantList((Id)editId);
        for(VDST_EventPrtcpntAccnt_gne__c epa : listPrtcpnts) {
            if(!String.isBlank(epa.VendorParticipantID_gne__c)) {
                if(!epa.VendorParticipantID_gne__c.startsWith(commonUtils.vendorLoggedVal + '_')) {
                    prtcpntMap.put(commonUtils.vendorLoggedVal + '_' + epa.VendorParticipantID_gne__c.toUpperCase(), epa);
                } else {
                    prtcpntMap.put(epa.VendorParticipantID_gne__c.toUpperCase(), epa);
                }
            }
        }
        List<VDST_Address_gne__c> addressList = new List<VDST_Address_gne__c>();
        List<VDST_EventPrtcpntAccnt_gne__c> eventPrtcpntList = new List<VDST_EventPrtcpntAccnt_gne__c>();
        List<List<VDST_PrtcpntTransaction_gne__c>> eventPrtcpntTransList = new List<List<VDST_PrtcpntTransaction_gne__c>>();
        List<Id> updateIds = new List<Id>();
        for(PrtcpntWrapper pw : importedWrappedRows) {
            if(pw.isValidRecord) {
                clearUnusedFields(pw, transactionVisMap);
                VDST_EventPrtcpntAccnt_gne__c newAccnt = pw.getPrtcpntAccnt();
                newAccnt.isBatch_gne__c = true;
                if(!String.isBlank(newAccnt.VendorParticipantID_gne__c)) {
                    if(!newAccnt.VendorParticipantID_gne__c.startsWith(commonUtils.vendorLoggedVal + '_')) {
                        newAccnt.VendorParticipantID_gne__c = commonUtils.vendorLoggedVal + '_' + newAccnt.VendorParticipantID_gne__c;
                    }
                }
                if(prtcpntMap.containsKey(newAccnt.VendorParticipantID_gne__c)) {
                    newAccnt.Id = prtcpntMap.get(newAccnt.VendorParticipantID_gne__c).Id;
                    newAccnt.VDST_Address_gne__c = prtcpntMap.get(newAccnt.VendorParticipantID_gne__c).VDST_Address_gne__c;
                    pw.evntPrtcpntAddress.Id = prtcpntMap.get(newAccnt.VendorParticipantID_gne__c).VDST_Address_gne__c;
                    updateIds.add(newAccnt.Id);
                }
                if(pw.evntPrtcpntAddress.PostalCode_gne__c != null) {
                    pw.evntPrtcpntAddress.PostalCode_gne__c = pw.evntPrtcpntAddress.PostalCode_gne__c.toUpperCase();
                }
                addressList.add(pw.evntPrtcpntAddress);
                if(newAccnt.VendorParticipantID_gne__c != null) {
                    newAccnt.VendorParticipantID_gne__c = newAccnt.VendorParticipantID_gne__c.toUpperCase();
                }
                eventPrtcpntList.add(newAccnt);
                // Transactions
                List<VDST_PrtcpntTransaction_gne__c> finalTransactions = new List<VDST_PrtcpntTransaction_gne__c>();
                for(VDST_PrtcpntTransaction_gne__c csvTransaction : pw.getPrtcpntTransactionList()) {
                    if(transactionVisMap.get(newAccnt.EventParticipantRole_gne__c) != null) {
                       if('HONORARIA'.equals(csvTransaction.TransactionTypeCode_gne__c) && transactionVisMap.get(newAccnt.EventParticipantRole_gne__c).get('hasFees') != null && transactionVisMap.get(newAccnt.EventParticipantRole_gne__c).get('hasFees').IsVisible_gne__c) {
                           finalTransactions.add(csvTransaction);
                       } else if(!'HONORARIA'.equals(csvTransaction.TransactionTypeCode_gne__c) && transactionVisMap.get(newAccnt.EventParticipantRole_gne__c).get('hasTrans') != null && transactionVisMap.get(newAccnt.EventParticipantRole_gne__c).get('hasTrans').IsVisible_gne__c) {
                           finalTransactions.add(csvTransaction);
                       }
                    }
                }
                eventPrtcpntTransList.add(finalTransactions);
            }
        }
        try {
            upsert addressList;
            for(Integer i=0; i<addressList.size(); i++) {
                if(eventPrtcpntList.get(i).VDST_Address_gne__c == null) {
                    eventPrtcpntList.get(i).VDST_Address_gne__c = addressList.get(i).Id;
                }
                if(eventPrtcpntList.get(i).VDST_Event_gne__c == null) {
                    eventPrtcpntList.get(i).VDST_Event_gne__c = (Id)editId;
                }
            }
            upsert eventPrtcpntList;
            addressList = null;
            List<VDST_PrtcpntTransaction_gne__c> transactionsToDelete = [SELECT Id FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__c IN :updateIds];
            delete transactionsToDelete;
            for(Integer i=0; i<eventPrtcpntList.size(); i++) {
                List<VDST_PrtcpntTransaction_gne__c> prtcpntTransactionList = eventPrtcpntTransList.get(i);
                for(VDST_PrtcpntTransaction_gne__c prtcpntTrans : prtcpntTransactionList) {
                    prtcpntTrans.VDST_EventPrtcpntAccnt_gne__c = eventPrtcpntList.get(i).Id;
                    prtcpntTrans.VDST_PaidToParty_gne__c = eventPrtcpntList.get(i).Id;
                }
            }
            List<VDST_PrtcpntTransaction_gne__c> allPrtcpntTransactionList = new List<VDST_PrtcpntTransaction_gne__c>();
            for(List<VDST_PrtcpntTransaction_gne__c> ptList : eventPrtcpntTransList) {
                allPrtcpntTransactionList.addAll(ptList);
            }
            eventPrtcpntTransList = null;
            insert allPrtcpntTransactionList;
            showPrtcpntModal = false;
            // Updating Attendance
            List<Id> prtcpntIds = new List<Id>();
            for(VDST_EventPrtcpntAccnt_gne__c accnt : eventPrtcpntList) {
                prtcpntIds.add(accnt.Id);
            }
            List<VDST_EventPrtcpntAttendance_gne__c> attList = [SELECT Id, AttendanceStatus_gne__c, ParticipantMealConsumptionStatus_gne__c, Event_PrtcpntAccnt_gne__r.VendorParticipantID_gne__c FROM VDST_EventPrtcpntAttendance_gne__c WHERE Event_PrtcpntAccnt_gne__c IN :prtcpntIds ORDER BY VDST_EventDate_gne__r.EventDate_gne__c ASC];
            for(PrtcpntWrapper pw : importedWrappedRows) {
                if(pw.isValidRecord) {
                    Integer dayNo = 0;
                    for(VDST_EventPrtcpntAttendance_gne__c att : attList) {
                        if(att.Event_PrtcpntAccnt_gne__r.VendorParticipantID_gne__c == pw.evntPrtcpnt.VendorParticipantID_gne__c) {
                            if(pw.attendanceList.get(dayNo).attendanceStatus) {
                                att.AttendanceStatus_gne__c = 'ATND';
                            } else {
                                att.AttendanceStatus_gne__c = 'DNS';
                            }
                            // TODO: improve usability
                            //if('CFF'.equals(eventType)) {
                            att.ParticipantMealConsumptionStatus_gne__c = pw.attendanceList.get(dayNo).attendance.ParticipantMealConsumptionStatus_gne__c;
                            //} else {
                            //   att.ParticipantMealConsumptionStatus_gne__c = 'CONSUMED';
                            //}
                            dayNo++;
                        }
                    }
                }
            }
            update attList;
            updateEventDate();
            // Clear values
            importedWrappedRows.clear();
            importValidationStatus.clear();
            eventPrtcpntList = null;
        } catch(QueryException e) {
            log.logException('saveRecords', e);
            importValidationStatus.clear();
            importValidationStatus.fileErrorMessage = e.getMessage();
        }
        return null;
    }

    /** @date 5/17/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - Clearing unused in Role fields
    * @param PageReference
    */
    public void clearUnusedFields(PrtcpntWrapper pw, Map<String, Map<String, VDST_EventPrtcpntField_gne__c>> transactionVisMap) {
        if(transactionVisMap.containsKey(pw.evntPrtcpnt.EventParticipantRole_gne__c)) {
            Map<String, VDST_EventPrtcpntField_gne__c> roleMap = transactionVisMap.get(pw.evntPrtcpnt.EventParticipantRole_gne__c);
            if(roleMap.containsKey('DEA_gne') && !roleMap.get('DEA_gne').IsVisible_gne__c) {
                pw.evntPrtcpnt.DEA_gne__c = null;
            }
            if(roleMap.containsKey('NPI_gne') && !roleMap.get('NPI_gne').IsVisible_gne__c) {
                pw.evntPrtcpnt.NPI_gne__c = null;
            }
            if(roleMap.containsKey('UnixID_gne') && !roleMap.get('UnixID_gne').IsVisible_gne__c) {
                pw.evntPrtcpnt.UnixID_gne__c = null;
            }
            if(roleMap.containsKey('ParticipantContractStatus_gne') && !roleMap.get('ParticipantContractStatus_gne').IsVisible_gne__c) {
                if('CNTRCTD'.equals(roleMap.get('ParticipantContractStatus_gne').DefaultValue_gne__c)) {
                    pw.evntPrtcpnt.ParticipantContractStatus_gne__c = 'CNTRCTD';
                } else {
                    pw.evntPrtcpnt.ParticipantContractStatus_gne__c = 'NTCNTRCTD';
                }
            }
        }
    }

    /** @date 2/19/2013
    * @Author Pawel Sprysak, Konrad Malinowski
    * @description CSV Participants - Method for importing and processing CSV file
    * @return PageReference
    */
    public PageReference importCSV() {
        Integer NUMBER_OF_HEADERS_IN_CSV                = 1;
        Integer MAX_NUMBER_OF_RECORDS_TO_PROCESS_IN_CSV = 200;
        Integer NUMBER_OF_COLUMNS_IN_CSV                = 40;
        Integer NUMBER_OF_INVALID_ROWS_TO_DISPLAY       = 10;
        importValidationStatus.clear();
        if(importFile == null) {
            importValidationStatus.fileErrorMessage += 'No file to proceed.<br/>';
            return null;
        }
        importedWrappedRows.clear();
        String fileRead = null;
        try {
            fileRead = importFile.toString();
        } catch(StringException se) {
            fileRead = VDST_Utils.convertBlobToString(importFile, 'Windows-1252');
            log.logException('importCSV', se);
            if(fileRead == null) {
                importValidationStatus.fileErrorMessage += 'Is not a valid file to proceed.<br/>';
                return null;
            }
        } finally {
            importFile = null;
        }
        eventStartDate = VDST_Utils.getEventStartEndDateById(editId);
        String[] fileLines = VDST_Utils.getValWithoutBlankLinesFromStr(fileRead).split('\n', -2);
        fileRead = null;
        Integer numberOfFileLinesToProcess = fileLines.size();
        if(numberOfFileLinesToProcess <= NUMBER_OF_HEADERS_IN_CSV) {
            importValidationStatus.fileErrorMessage += 'File has no records to proceed.<br/>';
            return null;
        }
        if(numberOfFileLinesToProcess > NUMBER_OF_HEADERS_IN_CSV + MAX_NUMBER_OF_RECORDS_TO_PROCESS_IN_CSV) {
            numberOfFileLinesToProcess = NUMBER_OF_HEADERS_IN_CSV + MAX_NUMBER_OF_RECORDS_TO_PROCESS_IN_CSV;
            importValidationStatus.fileWarningMessage += 'File truncated. You can upload up to ' + MAX_NUMBER_OF_RECORDS_TO_PROCESS_IN_CSV + ' Participants in one Batch file.<br/>';
        }
        List<String> wrapperValues = null;
        String rowsWithInvalidNumberOfColumnsMsg = '';
        Integer numberOfRowsWithInvalidNumberOfColumns = 0;
        for (Integer i = NUMBER_OF_HEADERS_IN_CSV; i < numberOfFileLinesToProcess; i++) {
            wrapperValues = getRowValues(fileLines[i]);
            if(wrapperValues.size() == NUMBER_OF_COLUMNS_IN_CSV) {
                PrtcpntWrapper newWrapper = new PrtcpntWrapper(this, wrapperValues, i, eventType, editId, commonUtils.eventRolesMap, eventDates, eventStartDate.EventStartDate_gne__c);
                if(!String.isBlank(newWrapper.evntPrtcpnt.VendorParticipantID_gne__c)) {
                    newWrapper.evntPrtcpnt.VendorParticipantID_gne__c = newWrapper.evntPrtcpnt.VendorParticipantID_gne__c.toUpperCase();
                    if(!newWrapper.evntPrtcpnt.VendorParticipantID_gne__c.startsWith(commonUtils.vendorLoggedVal + '_')) {
                        newWrapper.evntPrtcpnt.VendorParticipantID_gne__c = commonUtils.vendorLoggedVal + '_' + newWrapper.evntPrtcpnt.VendorParticipantID_gne__c;
                    }
                }
                validateWrapperValues(newWrapper);
                importedWrappedRows.add(newWrapper);
            } else {
                if(numberOfRowsWithInvalidNumberOfColumns < NUMBER_OF_INVALID_ROWS_TO_DISPLAY) {
                    String inflection = (wrapperValues.size() == 1 ? ' column' : ' columns');
                    rowsWithInvalidNumberOfColumnsMsg += 'Row number ' + i + ' has ' + wrapperValues.size() + inflection + '.<br/>';
                }
                numberOfRowsWithInvalidNumberOfColumns++;
            }
        }
        if( numberOfRowsWithInvalidNumberOfColumns > 0 ) {
            importedWrappedRows.clear();
            String inflection = (numberOfRowsWithInvalidNumberOfColumns == 1 ? ' row has ' : ' rows have ');
            rowsWithInvalidNumberOfColumnsMsg = 'Please ensure that the file is formatted correctly. Once this has been done, please re-load the file.<br/>' + numberOfRowsWithInvalidNumberOfColumns + inflection + 'invalid number of columns.<br/>' +
                'Correct number of columns is ' + NUMBER_OF_COLUMNS_IN_CSV + '<br/>' + rowsWithInvalidNumberOfColumnsMsg;
            rowsWithInvalidNumberOfColumnsMsg += (numberOfRowsWithInvalidNumberOfColumns > NUMBER_OF_INVALID_ROWS_TO_DISPLAY ? '...<br/>' : '');
            importValidationStatus.fileErrorMessage += rowsWithInvalidNumberOfColumnsMsg;
            return null;
        }
        if( !importedWrappedRows.isEmpty() ) {
            SuperSort.sortList(importedWrappedRows, 'LastFirstName', 'ASC');
            for (Integer i = 0; i < importedWrappedRows.size(); i++) {
                importedWrappedRows.get(i).wrapperNum = (i + 1);
            }
            validateBatchVendorIds();
            validateBatchUnixIds();
            showMissingParticipants();
        }
        fileLines = null;
        return null;
    }

    /** @date 5/17/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - Show in error message missing Participants
    */
    public void showMissingParticipants() {
        List<String> missingPrtpcnt = new List<String>();
        listPrtcpnts = VDST_Utils.getParticipantList((Id)editId);
        for(VDST_EventPrtcpntAccnt_gne__c accnt : listPrtcpnts) {
            Boolean prtcpntExist = false;
            for(PrtcpntWrapper pw : importedWrappedRows) {
                if(pw.evntPrtcpnt.VendorParticipantID_gne__c != null && pw.evntPrtcpnt.VendorParticipantID_gne__c.equalsIgnoreCase(accnt.VendorParticipantID_gne__c)) {
                    prtcpntExist = true;
                    break;
                }
            }
            if(!prtcpntExist) {
                missingPrtpcnt.add(accnt.LastName_gne__c + ' ' + accnt.FirstName_gne__c);
            }
        }
        if(missingPrtpcnt.size() > 0) {
            importValidationStatus.participantsWarningMessage += '<br/>The following Participants do not appear in the Batch Upload file. ' +
                'You may want to Delete them from the Participant List from this Event:<br/>';
            for(String prtspntFLN : missingPrtpcnt) {
                importValidationStatus.participantsWarningMessage += prtspntFLN + '<br/>';
            }
        }
    }

    /** @date 5/16/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - Validate Wrapper Vendor Participant Id's
    */
    public void validateBatchVendorIds() {
        Map<String, Integer> vendPrtcpntIdMap = new Map<String, Integer>();
        /* Only if we want to check already existing Participants
        for(VDST_EventPrtcpntAccnt_gne__c epa : listPrtcpnts) {
            if(vendPrtcpntIdMap.containsKey(epa.VendorParticipantID_gne__c)) {
                vendPrtcpntIdMap.put(epa.VendorParticipantID_gne__c, vendPrtcpntIdMap.get(epa.VendorParticipantID_gne__c)+1);
            } else {
                vendPrtcpntIdMap.put(epa.VendorParticipantID_gne__c, 1);
            }
        }
        */
        //VDST_Event_gne__c eventById = VDST_Utils.getEventCodesById(editId);
        for(PrtcpntWrapper wrap : importedWrappedRows) {
            if(!String.isBlank(wrap.evntPrtcpnt.VendorParticipantID_gne__c)) {
                wrap.evntPrtcpnt.VendorParticipantID_gne__c = wrap.evntPrtcpnt.VendorParticipantID_gne__c.toUpperCase();
                if(commonUtils.vendorLoggedVal == null) {
                    wrap.errorMsgList[1] = 'Creating Vendor Participant Id error';
                } else {
                    if(!wrap.evntPrtcpnt.VendorParticipantID_gne__c.startsWith(commonUtils.vendorLoggedVal + '_')) {
                        wrap.evntPrtcpnt.VendorParticipantID_gne__c = commonUtils.vendorLoggedVal + '_' + wrap.evntPrtcpnt.VendorParticipantID_gne__c;
                    }
                    if(vendPrtcpntIdMap.containsKey(wrap.evntPrtcpnt.VendorParticipantID_gne__c)) {
                        vendPrtcpntIdMap.put(wrap.evntPrtcpnt.VendorParticipantID_gne__c, vendPrtcpntIdMap.get(wrap.evntPrtcpnt.VendorParticipantID_gne__c)+1);
                    } else {
                        vendPrtcpntIdMap.put(wrap.evntPrtcpnt.VendorParticipantID_gne__c, 1);
                    }
                }
            } else {
                wrap.errorMsgList[1] = 'Vendor Participant Id field is required';
            }
        }
        List<String> duplicateList = VDST_Utils.notUniqueVendorParticipantIds(commonUtils.vendorLoggedVal, vendPrtcpntIdMap.keySet(), null, editId);
        Map<String, String> idsMap = new Map<String, String>();
        for(String str : duplicateList) {
            if(!str.startsWith(commonUtils.vendorLoggedVal + '_')) {
                str = commonUtils.vendorLoggedVal + '_' + str;
            }
            idsMap.put(str.toUpperCase(), str.toUpperCase());
        }
        for(PrtcpntWrapper wrap : importedWrappedRows) {
            if(!String.isBlank(wrap.evntPrtcpnt.VendorParticipantID_gne__c)) {
                if(idsMap.containsKey(wrap.evntPrtcpnt.VendorParticipantID_gne__c) || (vendPrtcpntIdMap.containsKey(wrap.evntPrtcpnt.VendorParticipantID_gne__c) && vendPrtcpntIdMap.get(wrap.evntPrtcpnt.VendorParticipantID_gne__c) > 1)) {
                    wrap.errorMsgList[1] = 'Vendor Participant Id must be unique';
                } else {
                    vendPrtcpntIdMap.put(wrap.evntPrtcpnt.VendorParticipantID_gne__c, 1);
                }
            }
        }
    }

    /** @date 8/14/2014
    * @Author Konrad Malinowski
    * @description CSV Participants - Validate Wrapper Unix Id's
    */
    public void validateBatchUnixIds() {
        String unixIdUniqueErrorMsg = 'Unix ID must be unique';
        Map<String, Boolean> unixIdUniquenessMap = new Map<String, Boolean>();
        for(PrtcpntWrapper pw : importedWrappedRows) {
            if( String.isNotBlank(pw.evntPrtcpnt.UnixID_gne__c) ) {
                if( !unixIdUniquenessMap.containsKey(pw.evntPrtcpnt.UnixID_gne__c) ) {
                    unixIdUniquenessMap.put(pw.evntPrtcpnt.UnixID_gne__c, true);
                } else {
                    unixIdUniquenessMap.put(pw.evntPrtcpnt.UnixID_gne__c, false);
                }
                if(pw.errorMsgList[13] == unixIdUniqueErrorMsg) {
                    pw.errorMsgList[13] = '';
                }
            }
        }
        Map<String, String> notUniqueUnixIdsWithVendorIdsForEvent = VDST_Utils.getNotUniqueParticipantUnixIdsWithVendorIdsForEvent(
            editId, new List<String>( unixIdUniquenessMap.keySet() )
        );
        Map<String, All_User_Hierarchy_gne__c> userMap = VDST_Utils.getUsersData( new List<String>( unixIdUniquenessMap.keySet() ) );
        if(userMap != null) {
            Boolean isUnixIdNotBlank = false, isUnixIdInvalid = false, isUnixIdDuplicatedForEvent = false, isUnixIdDuplicated = false;
            for(PrtcpntWrapper pw : importedWrappedRows) {
                isUnixIdNotBlank = String.isNotBlank(pw.evntPrtcpnt.UnixID_gne__c);
                isUnixIdInvalid = isUnixIdNotBlank && !userMap.containsKey(pw.evntPrtcpnt.UnixID_gne__c.toLowerCase());
                isUnixIdDuplicatedForEvent = notUniqueUnixIdsWithVendorIdsForEvent.containsKey(pw.evntPrtcpnt.UnixID_gne__c) &&
                    !(notUniqueUnixIdsWithVendorIdsForEvent.get(pw.evntPrtcpnt.UnixID_gne__c) == pw.evntPrtcpnt.VendorParticipantID_gne__c);
                isUnixIdDuplicated = !isUnixIdInvalid && isUnixIdNotBlank  && (
                    !unixIdUniquenessMap.get(pw.evntPrtcpnt.UnixID_gne__c) || isUnixIdDuplicatedForEvent
                );
                if(isUnixIdInvalid) {
                    pw.errorMsgList[13] = 'Invalid Unix ID';
                } else if(isUnixIdDuplicated) {
                    pw.errorMsgList[13] = unixIdUniqueErrorMsg;
                }
            }
        }
    }

    /** @date 5/16/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - Validate PickList values
    * @param PrtcpntWrapper wrapper (Wrapper to validate)
    */
    public void validateWrapperValues(PrtcpntWrapper wrapper) {
        // Check Participant Profession
        if(String.isBlank(commonUtils.getLabel(wrapper.evntPrtcpnt.ParticipantProfession_gne__c))) {
            wrapper.evntPrtcpnt.ParticipantProfession_gne__c = '';
        }
        // Check Credential
        if(!commonUtils.credentialMap.containsKey(wrapper.evntPrtcpnt.Credential_gne__c)) {
            wrapper.evntPrtcpnt.Credential_gne__c = '';
        }
        // Check License State
        if(String.isBlank(VDST_Utils.getStatesMap().get(wrapper.evntPrtcpnt.LicenseState_gne__c))) {
            wrapper.evntPrtcpnt.LicenseState_gne__c = '';
        }
        // Suffix
        if(String.isBlank(commonUtils.getLabel(wrapper.evntPrtcpnt.Suffix_gne__c))) {
            wrapper.evntPrtcpnt.Suffix_gne__c = '';
        }
        // Check State
        if('USA'.equals(wrapper.evntPrtcpntAddress.Country_gne__c) && String.isBlank(VDST_Utils.getStatesMap().get(wrapper.evntPrtcpntAddress.StateProvince_gne__c))) {
            wrapper.evntPrtcpntAddress.StateProvince_gne__c = '';
        }
        // Validate all fields
        wrapper.validateBatchFields();
    }

    /** @date 2/19/2013
    * @Author Pawel Sprysak
    * @description CSV Participants - Method for splitting CSV line to columns
    * @param String line
    * @return List<String>
    */
    public List<String> getRowValues(String line) {
        if(String.isBlank(line)) {
            return new List<String>();
        } else {
            List<String> finalValues = new List<String>();
            line = line.replace('\"\"', CONVERT_TO_STRING);
            List<String> newInputValues = line.split(',', -2);

            String temp = '';
            for(String sss : newInputValues) {
                if(temp.equals('')) {
                    if(sss.startsWith('\"') && sss.endsWith('\"')) {
                        finalValues.add(sss.remove('\"').replace(CONVERT_TO_STRING, '\"'));
                    } else if(sss.startsWith('\"')) {
                        temp = sss;
                    } else {
                        finalValues.add(sss.remove('\"').replace(CONVERT_TO_STRING, '\"'));
                    }
                } else {
                    temp += ',' + sss;
                    if(sss.endsWith('\"')) {
                        finalValues.add(temp.remove('\"').replace(CONVERT_TO_STRING, '\"'));
                        temp = '';
                    }
                }
            }
            return finalValues;
        }
    }
////////////////////////////
// CSV Participants - END //
////////////////////////////

///////////////////////////////
// Participants List - BEGIN //
///////////////////////////////
    public Boolean showParticipantList = true;

    /** @date 2/20/2013
    * @Author Pawel Sprysak, Konrad Malinowski
    * @description Getter for Participant List
    * @return List<VDST_EventPrtcpntAccnt_gne__c>
    */
    public List<WrappendAccnt> participantList {
        get {
            if(!showParticipantList) {
                participantList = null;
                return null;
            }

            try {
                ApexPages.StandardSetController setCon;
                if(commonUtils.isResearchEvent || commonUtils.isNonResearchEvent) {
                    setCon = new ApexPages.StandardSetController(
                        VDST_Utils.getParticipantList((Id)editId, 'ORG')
                    );
                } else {
                    setCon = new ApexPages.StandardSetController(
                        VDST_Utils.getParticipantList((Id)editId)
                    );
                }
                prtcpntPagingUtil.setParameters(setCon.getResultSize());
                setCon.setPageSize(prtcpntPagingUtil.perPage);
                setCon.first();
                for(Integer i = 1; i < prtcpntPagingUtil.actualPage; i++) {
                    setCon.next();
                }
                List<Id> idList = new List<Id>();
                for(VDST_EventPrtcpntAccnt_gne__c prtcpt : (List<VDST_EventPrtcpntAccnt_gne__c>)setCon.getRecords()) {
                    idList.add(prtcpt.Id);
                }
                setCon = null;
                List<WrappendAccnt> accntList = new List<WrappendAccnt>();
                for(VDST_EventPrtcpntAccnt_gne__c acnt : VDST_Utils.getParticipantList(idList)) {
                    accntList.add(new WrappendAccnt(acnt, commonUtils));
                }
                idList = null;
                return accntList;
            } catch(Exception ex) {
                log.logException('participantList', ex);
                return new List<WrappendAccnt>();
            }
        }
        set;
    }

    /** @date 5/22/2013
    * @Author Pawel Sprysak
    * @description Wrapped class for creating labels in list
    */
    public class WrappendAccnt {
        public VDST_EventPrtcpntAccnt_gne__c      accnt       { get; set; }
        public VDST_EventDetailCommon             commonUtils { get; set; }
        public WrappendAccnt(VDST_EventPrtcpntAccnt_gne__c accntObj, VDST_EventDetailCommon commonUtilsRef) {
            accnt = accntObj;
            commonUtils = commonUtilsRef;
        }

        public String getStateProvince() {
            if('USA'.equals(accnt.VDST_Address_gne__r.Country_gne__c)) {
                return VDST_Utils.getStatesMap().get(accnt.VDST_Address_gne__r.StateProvince_gne__c);
            } else {
                return accnt.VDST_Address_gne__r.StatesNameHolder_gne__c;
            }
        }
    }

/////////////////////////////
// Participants List - END //
/////////////////////////////

////////////////////////////////
// Manage Participant - BEGIN //
////////////////////////////////
    /** @date 10/28/2013
    * @Author Pawel Sprysak
    * @description VF Method for adding Participant Organization for Research/Non-Research
    */
    public PageReference addOrgParticipant() {
        addParticipant();
        prtcpnt.evntPrtcpnt.PartyType_gne__c = 'ORG';
        prtcpnt.evntPrtcpnt.ParticipantContractStatus_gne__c = 'CNTRCTD';
        return null;
    }

    /** @date 3/21/2013
    * @Author Pawel Sprysak
    * @description VF Method for adding Participant
    */
    public PageReference addParticipant() {
        clearParticipantListMessages();
        editActionMessages = '';
        editErrorMessages = '';
        editableState = 'Create';
        prtcpnt = new PrtcpntWrapper(this);
        if(commonUtils.isSSEvent) {
            List<VDST_EventPrtcpntRole_gne__c> prtcpntRoles = VDST_Utils.getVendorCodeList(eventType);
            if(prtcpntRoles.size() > 0) {
                prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c = prtcpntRoles.get(0).Id;
            }
        }
        changeFields(true);
        editableMode = true;
        setHomePaymentIdParticipantTransaction();
        return null;
    }

    /** @date 3/21/2013
    * @Author Pawel Sprysak
    * @description VF Method for editing Participant
    */
    public PageReference editParticipant() {
        clearParticipantListMessages();
        editActionMessages = '';
        editErrorMessages = '';
        editableState = 'Edit';
        prtcpnt = new PrtcpntWrapper(this, prtcpntId);
        changeFields(false);
        //editableMode = false; //should be false for Monitor users only
        editableMode = true;
        setHomePaymentIdParticipantTransaction();
        return null;
    }

    /** @date 3/21/2013
    * @Author Pawel Sprysak
    * @description VF Method for editing Participant
    */
    public PageReference showParticipant() {
        clearParticipantListMessages();
        editActionMessages = '';
        editErrorMessages = '';
        editableState = 'Edit';
        prtcpnt = new PrtcpntWrapper(this, prtcpntId);
        changeFields(false);
        editableMode = false;
        setHomePaymentIdParticipantTransaction();
        return null;
    }

    /** @date 23/9/2014
    * @Author Konrad Malinowski
    * @description Set Home Payment Id Participant Transaction
    */
    public void setHomePaymentIdParticipantTransaction() {
        transactionType = IDLE_TRANSACTION_TYPE;
        if(commonUtils.isNonResearchEvent &&
            prtcpntValidObj.eventCreateObject.SupplementStatusCode_gne__c == 'SUPPLMT' &&
            String.isNotBlank(prtcpntValidObj.eventCreateObject.Home_Payment_ID_gne__c)
        ) {
            VDST_PrtcpntTransaction_gne__c prtcpntTransWithHpi = VDST_Utils.getHomePaymentIdParticipantTransactionByEventId(prtcpntValidObj.eventCreateObject.Id);
            isAssignHomePaymentIdToEditable = (prtcpntTransWithHpi == null);
            if(editableState == 'Edit' && prtcpntTransWithHpi != null && prtcpntTransWithHpi.VDST_EventPrtcpntAccnt_gne__c == prtcpntId) {
                transactionType = prtcpntTransWithHpi.TransactionTypeCode_gne__c;
                isAssignHomePaymentIdToEditable = true;
            }
        }
    }

    /** @date 3/29/2013
    * @Author Pawel Sprysak
    * @description VF Method for deleting Participant
    */
    public PageReference deleteParticipant() {
        prtcpntListMsgErr = '';
        Savepoint sp = Database.setSavepoint();
        VDST_Utils.deleteParticipant(prtcpntId);
        if(commonUtils.isNonResearchEvent) {
            commonUtils.nonResTransaction.setTransactionList();
        }
        prtcpntListMsg = 'Participant has been deleted.';

        if( STATUS_OCCURRED_NAME.equalsIgnoreCase(prtcpntValidObj.eventCreateObject.CurrentStatus_gne__c) ) {
            prtcpntValidObj.status = STATUS_OCCURRED_NAME;
            prtcpntValidObj.participantObject = null;
            VDST_Validator.ParticipantsValidationOutput result = VDST_Validator.validateParticipantsOnStatusChange(commonUtils.eventType, 
                                                                             commonUtils.vendorLoggedVal, prtcpntValidObj, null, null, commonUtils.eventRolesMapById);
            if(!result.isSuccess) {
                prtcpntListMsg = '';
                prtcpntListMsgErr = result.editErrorMessages;
                Database.rollback(sp);
            }
        }
        return null;
    }

    /** @date 3/21/2013
    * @Author Pawel Sprysak
    * @description VF Method for changing Participant to Edit mode
    */
    public PageReference editParticipantMode() {
        editActionMessages = '';
        clearParticipantListMessages();
        editableMode = true;
        return null;
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description VF Method for changing Participant to Edit mode
    */
    public PageReference cancelParticipantMode() {
        editActionMessages = '';
        clearParticipantListMessages();
        editableMode = false;
        return null;
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description VF Method for only saving Participant
    */
    public PageReference onlySaveParticipant() {
        saveParticipant();
        editActionMessages = prtcpntListMsg;
        prtcpnt.setAttendanceBox();
        clearParticipantListMessages();
        editableMode = true;
        return null;
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description VF Method for saving Participant and going back to Read Only mode
    */
    public PageReference saveParticipant() {
        editErrorMessages = '';
        if( STATUS_OCCURRED_NAME.equalsIgnoreCase(prtcpntValidObj.eventCreateObject.CurrentStatus_gne__c) ) {
            prtcpntValidObj.status = STATUS_OCCURRED_NAME;
            VDST_EventPrtcpntAccnt_gne__c clonedParticipant = prtcpnt.evntPrtcpnt.clone(true, true, true, true);
            clonedParticipant.VDST_Address_gne__r = prtcpnt.evntPrtcpntAddress.clone(true, true, true, true);
            prtcpntValidObj.participantObject = clonedParticipant;
            VDST_Validator.ParticipantsValidationOutput result = VDST_Validator.validateParticipantsOnStatusChange(commonUtils.eventType, 
                                                                             commonUtils.vendorLoggedVal, prtcpntValidObj, null, null, commonUtils.eventRolesMapById);
            if(!result.isSuccess) {
                editErrorMessages = result.editErrorMessages;
                editActionMessages = '';
                clearParticipantListMessages();
                return null;
            }
        }

        VDST_EventPrtcpntAccnt_gne__c eventPrtcpntAccnt = prtcpnt.getPrtcpntAccnt();
        //VDST_Event_gne__c evnt = [Select Id, LogisticVendorCode_gne__c from VDST_Event_gne__c where Id =: eventPrtcpntAccnt.VDST_Event_gne__c];
        if(editableState.equals('Create')) {
            if(!setVendorId(eventPrtcpntAccnt)) {
                prtcpntListMsg = 'Error while creating Vendor Participant Id';
                editErrorMessages = 'Error while creating Vendor Participant Id';
                return null;
            }
        }
        //VDST_Event_gne__c eventById = VDST_Utils.getEventCodesById(editId);
        trimParticipantFieldValues();
        if(editableState.equals('Create')) {
            try {
                // Participant
                //eventPrtcpntAccnt = prtcpnt.getPrtcpntAccnt();
                prtcpnt.evntPrtcpntAddress.VDST_Event_gne__c = (Id)editId;
                if(prtcpnt.evntPrtcpntAddress.PostalCode_gne__c != null) {
                    prtcpnt.evntPrtcpntAddress.PostalCode_gne__c = prtcpnt.evntPrtcpntAddress.PostalCode_gne__c.toUpperCase();
                }
                insert prtcpnt.evntPrtcpntAddress;
                eventPrtcpntAccnt.VDST_Address_gne__c = prtcpnt.evntPrtcpntAddress.Id;
                eventPrtcpntAccnt.VDST_Event_gne__c = (Id)editId;
                if(eventPrtcpntAccnt.VendorParticipantID_gne__c != null) {
                    eventPrtcpntAccnt.VendorParticipantID_gne__c = eventPrtcpntAccnt.VendorParticipantID_gne__c.toUpperCase();
                }
                insert eventPrtcpntAccnt; //HERE
                if(commonUtils.isSSEvent) {
                    if(prtcpnt.singleSpendTrans.ItemQuantity_gne__c != null) {
                        prtcpnt.singleSpendTrans.TransactionAmount_gne__c = itemAmount * prtcpnt.singleSpendTrans.ItemQuantity_gne__c;
                    } else {
                        prtcpnt.singleSpendTrans.TransactionAmount_gne__c = 0;
                    }
                    prtcpnt.singleSpendTrans.VDST_EventPrtcpntAccnt_gne__c = eventPrtcpntAccnt.Id;
                    prtcpnt.singleSpendTrans.VDST_PaidToParty_gne__c = eventPrtcpntAccnt.Id;
                    insert prtcpnt.singleSpendTrans;
                }
                if(commonUtils.isResearchEvent) {
                    VDST_EventPrtcpntAccnt_gne__c evPrtcpnt = [SELECT ParticipantRole_gne__c, VDST_Event_gne__r.ItemAmount_gne__c, VDST_Event_gne__r.ResearchPaymentTypeCode_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id = :eventPrtcpntAccnt.Id LIMIT 1];
                    List<VDST_PrtcpntTransaction_gne__c> exTransactions = [SELECT Id, VDST_PaidToParty_gne__c, VDST_EventPrtcpntAccnt_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__c = :(Id)editId LIMIT 1];
                    VDST_PrtcpntTransaction_gne__c newTransaction = new VDST_PrtcpntTransaction_gne__c(
                            VDST_EventPrtcpntAccnt_gne__c = eventPrtcpntAccnt.Id,
                            FeePayToPartyType_gne__c = eventPrtcpntAccnt.PartyType_gne__c,
                            TransactionAmount_gne__c = evPrtcpnt.VDST_Event_gne__r.ItemAmount_gne__c,
                            TransactionLevel_gne__c = 'INDV'
                        );
                    if('PI'.equals(evPrtcpnt.ParticipantRole_gne__c)) {
                        newTransaction.TransactionAllocationType_gne__c = 'INDIRECT';
                    } else {
                        newTransaction.TransactionAllocationType_gne__c = 'DIRECT';
                    }
                    if('PRECLINICAL'.equals(evPrtcpnt.VDST_Event_gne__r.ResearchPaymentTypeCode_gne__c)) {
                        newTransaction.TransactionTypeCode_gne__c = 'PRECLINCL';
                    } else {
                        newTransaction.TransactionTypeCode_gne__c = 'RSCH';
                    }
                    if('PI'.equals(evPrtcpnt.ParticipantRole_gne__c)) {
                        if(exTransactions.size() > 0) {
                            newTransaction.VDST_PaidToParty_gne__c = exTransactions.get(0).VDST_EventPrtcpntAccnt_gne__c;
                        }
                    } else {
                        newTransaction.VDST_PaidToParty_gne__c = eventPrtcpntAccnt.Id;
                        if(exTransactions.size() > 0) {
                            exTransactions.get(0).VDST_PaidToParty_gne__c = eventPrtcpntAccnt.Id;
                        }
                    }
                    if( String.isNotBlank(prtcpntValidObj.eventCreateObject.Home_Payment_ID_gne__c) ) {
                        newTransaction.Home_Payment_ID_flag_gne__c = true;
                    }
                    insert newTransaction;
                    if(exTransactions.size() > 0) {
                        update exTransactions;
                    }
                }
                // Transactions
                Id paidToPartyId = null;
                if(commonUtils.isNonResearchEvent && commonUtils.eventRolesMapById.get(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c) != null && 'Attendee'.equals(commonUtils.eventRolesMapById.get(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c).EventParticipantRoleName__c)) {
                    VDST_EventPrtcpntAccnt_gne__c evPrtcpnt = VDST_Utils.getPrtcpntAccntByEventIdAndRole(editId, 'Payee');
                    if(evPrtcpnt != null) {
                        paidToPartyId = evPrtcpnt.Id;
                    }
                }
                if(actualMap.get('hasTrans').IsVisible_gne__c || commonUtils.isNonResearchEvent) {
                    List<VDST_PrtcpntTransaction_gne__c> eventPrtcpntTransList = new List<VDST_PrtcpntTransaction_gne__c>();
                    for(VDST_PrtcpntTransaction_gne__c prtcpntTrans : prtcpnt.getPrtcpntTransactionList()) {
                        prtcpntTrans.VDST_EventPrtcpntAccnt_gne__c = eventPrtcpntAccnt.Id;
                        if(paidToPartyId != null) {
                            prtcpntTrans.VDST_PaidToParty_gne__c = paidToPartyId;
                        } else {
                            prtcpntTrans.VDST_PaidToParty_gne__c = eventPrtcpntAccnt.Id;
                        }
                        if(!'HONORARIA'.equals(prtcpntTrans.TransactionTypeCode_gne__c) || actualMap.get('hasFees').IsVisible_gne__c || commonUtils.isNonResearchEvent) {
                            if(!commonUtils.isNonResearchEvent || (commonUtils.isNonResearchEvent && prtcpntTrans.TransactionAmount_gne__c > 0)) {
                                if(commonUtils.isNonResearchEvent && transactionType != IDLE_TRANSACTION_TYPE && transactionType == prtcpntTrans.TransactionTypeCode_gne__c) {
                                    prtcpntTrans.Home_Payment_ID_flag_gne__c = true;
                                }
                                eventPrtcpntTransList.add(prtcpntTrans);
                            }
                        }
                    }
                    insert eventPrtcpntTransList;
                    prtcpnt.setTransactionValues();
                }
                if(commonUtils.isNonResearchEvent) {
                    commonUtils.nonResTransaction.setTransactionList();
                    if(commonUtils.eventRolesMapById.get(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c) != null && 'Payee'.equals(commonUtils.eventRolesMapById.get(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c).EventParticipantRoleName__c)) {
                        VDST_Utils.updatePaidToPartyRef(editId, eventPrtcpntAccnt.Id);
                    }
                }

                // Reset values
                eventType = prtcpnt.eventTypeVal;
                editId = eventPrtcpntAccnt.VDST_Event_gne__c;
                prtcpnt = new PrtcpntWrapper(this, eventPrtcpntAccnt.Id);
                eventPrtcpntAccnt = null;

                prtcpntListMsg = 'Participant has been created.';
            } catch(QueryException e) {
                log.logException('saveParticipant', e);
                prtcpntListMsg = 'There was an error while trying to create participant.';
            }

        } else {
            try {
                // Participant
                update prtcpnt.getPrtcpntAccnt();
                prtcpnt.evntPrtcpntAddress.VDST_Event_gne__c = (Id)editId;
                if(prtcpnt.evntPrtcpntAddress.PostalCode_gne__c != null) {
                    prtcpnt.evntPrtcpntAddress.PostalCode_gne__c = prtcpnt.evntPrtcpntAddress.PostalCode_gne__c.toUpperCase();
                }
                update prtcpnt.evntPrtcpntAddress;
                if(commonUtils.isSSEvent) {
                    if(prtcpnt.singleSpendTrans.ItemQuantity_gne__c != null) {
                        prtcpnt.singleSpendTrans.TransactionAmount_gne__c = itemAmount * prtcpnt.singleSpendTrans.ItemQuantity_gne__c;
                    } else {
                        prtcpnt.singleSpendTrans.TransactionAmount_gne__c = 0;
                    }
                    update prtcpnt.singleSpendTrans;
                }

                // Transactions
                if(actualMap.get('hasTrans').IsVisible_gne__c || commonUtils.isNonResearchEvent) {
                    // Organization
                    if(!commonUtils.isNonResearchEvent) {
                        if(actualMap.get('hasFees').IsVisible_gne__c && prtcpnt.accountType.equals('Organization')) {
                            if(prtcpnt.evntOrg.VDST_Event_gne__c != prtcpnt.getPrtcpntAccnt().VDST_Event_gne__c) {
                                prtcpnt.evntOrg.VDST_Event_gne__c = prtcpnt.getPrtcpntAccnt().VDST_Event_gne__c;
                            }
                            if(prtcpnt.evntOrgAddress.PostalCode_gne__c != null) {
                                prtcpnt.evntOrgAddress.PostalCode_gne__c = prtcpnt.evntOrgAddress.PostalCode_gne__c.toUpperCase();
                            }
                            upsert prtcpnt.evntOrgAddress;
                            prtcpnt.evntOrg.VDST_Address_gne__c = prtcpnt.evntOrgAddress.Id;
                            upsert prtcpnt.evntOrg;
                        } else {
                            deleteParticipantOrganization();
                        }
                    }

                    // Transaction objects
                    Id paidToPartyId = null;
                    if(commonUtils.isNonResearchEvent && commonUtils.eventRolesMapById.get(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c) != null && 'Attendee'.equals(commonUtils.eventRolesMapById.get(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c).EventParticipantRoleName__c)) {
                        VDST_EventPrtcpntAccnt_gne__c evPrtcpnt = VDST_Utils.getPrtcpntAccntByEventIdAndRole(editId, 'Payee');
                        if(evPrtcpnt != null) {
                            paidToPartyId = evPrtcpnt.Id;
                        }
                    }
                    List<VDST_PrtcpntTransaction_gne__c> ptList = new List<VDST_PrtcpntTransaction_gne__c>();
                    List<VDST_PrtcpntTransaction_gne__c> remList = new List<VDST_PrtcpntTransaction_gne__c>();
                    for(VDST_PrtcpntTransaction_gne__c prtcpntTrans : prtcpnt.getPrtcpntTransactionList()) {
                        System.debug('XXXXX 931 -> ' + prtcpntTrans.TransactionTypeCode_gne__c);
                        if(prtcpntTrans.Id == null) {
                           prtcpntTrans.VDST_EventPrtcpntAccnt_gne__c = prtcpnt.getPrtcpntAccnt().Id;
                        }
                        if(paidToPartyId != null) {
                            prtcpntTrans.VDST_PaidToParty_gne__c = paidToPartyId;
                        } else {
                            prtcpntTrans.VDST_PaidToParty_gne__c = prtcpnt.getPrtcpntAccnt().Id;
                        }
                        // Change Paid To Part relation
                        if(!commonUtils.isNonResearchEvent && 'HONORARIA'.equals(prtcpntTrans.TransactionTypeCode_gne__c) && actualMap.get('hasFees').IsVisible_gne__c && 'Organization'.equals(prtcpnt.accountType)) {
                            ptList.add(cloneOrganization(prtcpntTrans, prtcpnt.evntOrgTrans));
                        }
                        if(commonUtils.isNonResearchEvent || !'HONORARIA'.equals(prtcpntTrans.TransactionTypeCode_gne__c) || actualMap.get('hasFees').IsVisible_gne__c) {
                            if(!commonUtils.isNonResearchEvent || prtcpntTrans.TransactionAmount_gne__c > 0) {
                                System.debug('XXXXX 946 -> ' + prtcpntTrans.TransactionTypeCode_gne__c);
                                if(commonUtils.isNonResearchEvent) {
                                    if(transactionType != IDLE_TRANSACTION_TYPE && transactionType == prtcpntTrans.TransactionTypeCode_gne__c) {
                                        prtcpntTrans.Home_Payment_ID_flag_gne__c = true;
                                    } else {
                                        prtcpntTrans.Home_Payment_ID_flag_gne__c = false;
                                    }
                                }
                                ptList.add(prtcpntTrans);
                            } else if(prtcpntTrans.Id != null) {
                                remList.add(prtcpntTrans);
                            }
                        }
                    }
                    upsert ptList;
                    delete remList;
                    prtcpnt.setRemovedValues(remList);
                    prtcpnt.setTransactionValues();
                    if(commonUtils.isNonResearchEvent) {
                        commonUtils.nonResTransaction.setTransactionList();
                        if(commonUtils.eventRolesMapById.get(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c) != null && 'Payee'.equals(commonUtils.eventRolesMapById.get(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c).EventParticipantRoleName__c)) {
                            VDST_Utils.updatePaidToPartyRef(editId, prtcpnt.getPrtcpntAccnt().Id);
                        }
                    }
                } else {
                    List<VDST_PrtcpntTransaction_gne__c> ptList = new List<VDST_PrtcpntTransaction_gne__c>();
                    for(VDST_PrtcpntTransaction_gne__c prtcpntTrans : prtcpnt.getPrtcpntTransactionList()) {
                        if(prtcpntTrans.Id != null) {
                            ptList.add(prtcpntTrans);
                        }
                    }
                    if(ptList.size() > 0) {
                        delete ptList;
                        prtcpnt.setNewPrtcpntTransactionList();
                    }
                    if(prtcpnt.evntOrg != null && prtcpnt.evntOrg.Id != null) {
                        deleteParticipantOrganization();
                    }
                }

                // Attendance
                update prtcpnt.getPrtcpntAttendanceList();
                prtcpntListMsg = 'Participant has been updated.';
            } catch(QueryException e) {
                log.logException('saveParticipant', e);
                prtcpntListMsg = 'There was an error while trying to updating participant.';
            }
        }
        updateEventDate();
        prtcpnt.lastModifiedDate = String.valueOf(Datetime.now().format());
        prtcpnt.lastModifiedBy = UserInfo.getName();
        editableState = 'Edit';
        editableMode = false;
        return null;
    }

    /** @date 6/24/2014
    * @Author Konrad Malinowski
    * @description Trim Participant field values
    */
    public void trimParticipantFieldValues() {
        if(prtcpnt != null && prtcpnt.evntPrtcpnt != null) {
            prtcpnt.evntPrtcpnt.FirstName_gne__c                = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.FirstName_gne__c);
            prtcpnt.evntPrtcpnt.MiddleName_gne__c               = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.MiddleName_gne__c);
            prtcpnt.evntPrtcpnt.LastName_gne__c                 = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.LastName_gne__c);
            prtcpnt.evntPrtcpnt.ParticipantAffiliation_gne__c   = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.ParticipantAffiliation_gne__c);
            prtcpnt.evntPrtcpnt.NPI_gne__c                      = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.NPI_gne__c);
            prtcpnt.evntPrtcpnt.DEA_gne__c                      = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.DEA_gne__c);
            prtcpnt.evntPrtcpnt.LicenseNumber_gne__c            = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.LicenseNumber_gne__c);
            prtcpnt.evntPrtcpnt.VendorParticipantID_gne__c      = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.VendorParticipantID_gne__c);
            prtcpnt.evntPrtcpnt.UnixID_gne__c                   = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.UnixID_gne__c);
            prtcpnt.evntPrtcpnt.BusinessPhone_gne__c            = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.BusinessPhone_gne__c);
            prtcpnt.evntPrtcpnt.Email_gne__c                    = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.Email_gne__c);
            prtcpnt.evntPrtcpnt.LegalName_gne__c                = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.LegalName_gne__c);
            prtcpnt.evntPrtcpnt.TIN_gne__c                      = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpnt.TIN_gne__c);
            prtcpnt.evntPrtcpnt.Charitable_Organization_gne__c  = prtcpnt.evntPrtcpnt.Charitable_Organization_gne__c;

        }
        if(prtcpnt != null && prtcpnt.evntPrtcpntAddress != null) {
            prtcpnt.evntPrtcpntAddress.StreetAddress_gne__c     = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpntAddress.StreetAddress_gne__c);
            prtcpnt.evntPrtcpntAddress.StreetAddress2_gne__c    = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpntAddress.StreetAddress2_gne__c);
            prtcpnt.evntPrtcpntAddress.City_gne__c              = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpntAddress.City_gne__c);
            prtcpnt.evntPrtcpntAddress.StateProvince_gne__c     = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpntAddress.StateProvince_gne__c);
            prtcpnt.evntPrtcpntAddress.StatesNameHolder_gne__c  = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpntAddress.StatesNameHolder_gne__c);
            prtcpnt.evntPrtcpntAddress.PostalCode_gne__c        = VDST_Utils.getTrimValFromStr(prtcpnt.evntPrtcpntAddress.PostalCode_gne__c);
        }
        if(prtcpnt != null && prtcpnt.evntOrg != null) {
            prtcpnt.evntOrg.LegalName_gne__c                    = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrg.LegalName_gne__c);
            prtcpnt.evntOrg.TIN_gne__c                          = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrg.TIN_gne__c);
            prtcpnt.evntOrg.Charitable_Organization_gne__c      = prtcpnt.evntOrg.Charitable_Organization_gne__c;
            prtcpnt.evntOrg.NPI_gne__c                          = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrg.NPI_gne__c);
            prtcpnt.evntOrg.DEA_gne__c                          = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrg.DEA_gne__c);
        }
        if(prtcpnt != null && prtcpnt.evntOrgAddress != null) {
            prtcpnt.evntOrgAddress.StreetAddress_gne__c     = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrgAddress.StreetAddress_gne__c);
            prtcpnt.evntOrgAddress.City_gne__c              = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrgAddress.City_gne__c);
            prtcpnt.evntOrgAddress.StateProvince_gne__c     = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrgAddress.StateProvince_gne__c);
            prtcpnt.evntOrgAddress.StatesNameHolder_gne__c  = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrgAddress.StatesNameHolder_gne__c);
            prtcpnt.evntOrgAddress.PostalCode_gne__c        = VDST_Utils.getTrimValFromStr(prtcpnt.evntOrgAddress.PostalCode_gne__c);
        }
        if(wrapperToEdit != null && wrapperToEdit.evntPrtcpnt != null) {
            wrapperToEdit.evntPrtcpnt.VendorParticipantID_gne__c    = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.VendorParticipantID_gne__c);
            wrapperToEdit.evntPrtcpnt.LastName_gne__c               = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.LastName_gne__c);
            wrapperToEdit.evntPrtcpnt.FirstName_gne__c              = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.FirstName_gne__c);
            wrapperToEdit.evntPrtcpnt.MiddleName_gne__c             = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.MiddleName_gne__c);
            wrapperToEdit.evntPrtcpnt.BusinessPhone_gne__c          = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.BusinessPhone_gne__c);
            wrapperToEdit.evntPrtcpnt.Email_gne__c                  = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.Email_gne__c);
            wrapperToEdit.evntPrtcpnt.ParticipantAffiliation_gne__c = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.ParticipantAffiliation_gne__c);
            wrapperToEdit.evntPrtcpnt.UnixID_gne__c                 = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.UnixID_gne__c);
            wrapperToEdit.evntPrtcpnt.NPI_gne__c                    = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.NPI_gne__c);
            wrapperToEdit.evntPrtcpnt.DEA_gne__c                    = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.DEA_gne__c);
            wrapperToEdit.evntPrtcpnt.LicenseNumber_gne__c          = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.LicenseNumber_gne__c);
            wrapperToEdit.evntPrtcpnt.LicenseState_gne__c           = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpnt.LicenseState_gne__c);
        }
        if(wrapperToEdit != null && wrapperToEdit.evntPrtcpntAddress != null) {
            wrapperToEdit.evntPrtcpntAddress.StreetAddress_gne__c       = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpntAddress.StreetAddress_gne__c);
            wrapperToEdit.evntPrtcpntAddress.City_gne__c                = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpntAddress.City_gne__c);
            wrapperToEdit.evntPrtcpntAddress.StatesNameHolder_gne__c    = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpntAddress.StatesNameHolder_gne__c);
            wrapperToEdit.evntPrtcpntAddress.StateProvince_gne__c       = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpntAddress.StateProvince_gne__c);
            wrapperToEdit.evntPrtcpntAddress.PostalCode_gne__c          = VDST_Utils.getTrimValFromStr(wrapperToEdit.evntPrtcpntAddress.PostalCode_gne__c);
        }
    }

    /** @date 6/14/2013
    * @Author Pawel Sprysak
    * @description Method for updating Vendor Participant Id
    * @param VDST_EventPrtcpntAccnt_gne__c prtcpntAccnt(Participant Account instance)
    */
    public Boolean setVendorId(VDST_EventPrtcpntAccnt_gne__c prtcpntAccnt) {
        VDST_Event_gne__c eventData = VDST_Utils.getEventCodesById(editId);
        if(!'PENDING'.equals(eventData.CurrentStatus_gne__c)) {
            if(!String.isBlank(prtcpntAccnt.VendorParticipantID_gne__c)) {
                // Add prefix if Vendor Participant id already exist
                if(commonUtils.vendorLoggedVal == null) {
                    return false;
                } else if( !prtcpntAccnt.VendorParticipantID_gne__c.startsWith(commonUtils.vendorLoggedVal + '_') ) {
                    prtcpntAccnt.VendorParticipantID_gne__c = commonUtils.vendorLoggedVal + '_' + prtcpntAccnt.VendorParticipantID_gne__c;
                }
                return true;
            } else if(commonUtils.vendorLoggedVal != null) {
                prtcpntAccnt.VendorParticipantID_gne__c = VDST_Utils.generateFirstFreeVendorParticipantId(commonUtils.vendorLoggedVal);
                return true;
            }
            return false;
        }
        return true;
    }

    /** @date 4/18/2013
    * @Author Pawel Sprysak
    * @description Method for deleting Participant Organization Values
    */
    private void deleteParticipantOrganization() {
        if(prtcpnt.evntOrg != null && prtcpnt.evntOrg.Id != null) {
            try {
                delete prtcpnt.evntOrg;
            } catch(QueryException e) {
                // Nothing to do
            }
        }
        if(prtcpnt.evntOrgAddress != null && prtcpnt.evntOrgAddress.Id != null) {
            try {
                delete prtcpnt.evntOrgAddress;
            } catch(QueryException e) {
                // Nothing to do
            }
        }
        prtcpnt.evntOrg = new VDST_EventPrtcpntAccnt_gne__c(PartyType_gne__c = 'ORG', VDST_Event_gne__c = editId, Credential_gne__c = 'PAIDTO', ParticipantProfession_gne__c = 'PAIDTO', ParticipantContractStatus_gne__c = 'CNTRCTD');
        prtcpnt.evntOrgAddress = new VDST_Address_gne__c(AddressType_gne__c = 'Physical', VDST_Event_gne__c = editId);
        prtcpnt.evntOrgTrans = new VDST_PrtcpntTransaction_gne__c(TransactionTypeCode_gne__c = 'HONORARIA', FeePayToPartyType_gne__c = 'ORG', TransactionAllocationType_gne__c = 'DIRECT', TransactionLevel_gne__c = 'INDV');
        updateEventDate();
    }

    /** @date 4/18/2013
    * @Author Pawel Sprysak
    * @description Method for cloning Participant Organization Values
    * @param VDST_PrtcpntTransaction_gne__c indvTrans, VDST_PrtcpntTransaction_gne__c orgTrans
    */
    private VDST_PrtcpntTransaction_gne__c cloneOrganization(VDST_PrtcpntTransaction_gne__c indvTrans, VDST_PrtcpntTransaction_gne__c orgTrans) {
        // Change Paid To Part relation
        if(indvTrans.Id == null) {
            indvTrans.VDST_EventPrtcpntAccnt_gne__c = prtcpnt.getPrtcpntAccnt().Id;
        }
        indvTrans.VDST_PaidToParty_gne__c = prtcpnt.evntOrg.Id;
        indvTrans.TransactionAllocationType_gne__c = 'INDIRECT';
        // Create clone for Organization
        if(orgTrans.Id == null) {
            orgTrans = indvTrans.clone(false, false, false, false);
            orgTrans.VDST_EventPrtcpntAccnt_gne__c = prtcpnt.evntOrg.Id;
        }
        orgTrans.VDST_PaidToParty_gne__c = prtcpnt.getPrtcpntAccnt().Id;
        orgTrans.TransactionAllocationType_gne__c = 'DIRECT';
        orgTrans.FeePayToPartyType_gne__c = 'ORG';
        return orgTrans;
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description Method for VF - Getter for Participant List Options
    * @return List<SelectOption>
    */
    // TODO: check
    public List<SelectOption> getPrtcpntRoles() {
        List<SelectOption> prtcpntRoles = new List<SelectOption>{new SelectOption('', '-Select-')};
        List<SelectOption> rolesToSort;
        if(commonUtils.isResearchEvent || commonUtils.isNonResearchEvent) {
            rolesToSort = getResearchPrtcpntRoles( commonUtils.eventRolesMap.values() );
        } else {
            rolesToSort = new List<SelectOption>();
            for(VDST_EventPrtcpntRole_gne__c roles : commonUtils.eventRolesMap.values()) {
                rolesToSort.add(new SelectOption(roles.Id, roles.EventParticipantRoleName__c));
            }
        }
        prtcpntRoles.addAll(VDST_Utils.selectOptionSortByLabel(rolesToSort));
        return prtcpntRoles;
    }

    /** @date 10/29/2013
    * @Author Konrad Malinowski
    * @description Method for getting Research And Non-Research Participant Roles
    * @return List<SelectOption>
    */
    // TODO: check
    private List<SelectOption> getResearchPrtcpntRoles(List<VDST_EventPrtcpntRole_gne__c> prtcpntRoles) {
        if( prtcpnt == null || prtcpnt.evntPrtcpnt == null || String.isBlank( prtcpnt.evntPrtcpnt.PartyType_gne__c ) ) {
            return new List<SelectOption>();
        }
        Boolean isIndvPrtcpnt = ( prtcpnt.evntPrtcpnt.PartyType_gne__c == 'INDV' );
        Boolean isOrgPrtcpnt = ( prtcpnt.evntPrtcpnt.PartyType_gne__c == 'ORG' );
        List<SelectOption> rolesToSort = new List<SelectOption>();
        List<String> payeeList = new List<String>();
        if(commonUtils.isResearchEvent) {
            payeeList.add('PAYEE');
            payeeList.add('PAYEEPI');
        } else if(commonUtils.isNonResearchEvent) {
            payeeList.add('PAYEE');
            payeeList.add('ORG');
        }
        if(isIndvPrtcpnt) {
            Set<String> validIndvRoles;
            List<VDST_EventPrtcpntAccnt_gne__c> rschPrtcptns =
              [ SELECT ParticipantRole_gne__c
                FROM VDST_EventPrtcpntAccnt_gne__c
                WHERE VDST_Event_gne__c = :editId
                AND ParticipantRole_gne__c IN :payeeList
                AND Id != :prtcpnt.evntPrtcpnt.Id ];
            Boolean payeeParticipantExists = ( rschPrtcptns.size() > 0 );
            if(payeeParticipantExists) {
                if(commonUtils.isResearchEvent) {
                    validIndvRoles = new Set<String>{ 'PI' };
                } else if(commonUtils.isNonResearchEvent) {
                    validIndvRoles = new Set<String>{ 'ATND' };
                }
            } else {
                if(commonUtils.isResearchEvent) {
                    rschPrtcptns =
                      [ SELECT ParticipantRole_gne__c
                        FROM VDST_EventPrtcpntAccnt_gne__c
                        WHERE VDST_Event_gne__c = :editId
                        AND ParticipantRole_gne__c IN ( 'PI' )
                        AND Id != :prtcpnt.evntPrtcpnt.Id ];
                    Boolean piParticipantExists = ( rschPrtcptns.size() > 0 );
                    if(piParticipantExists) {
                        validIndvRoles = new Set<String>{ 'PAYEE' };
                    } else {
                        validIndvRoles = new Set<String>{ 'PAYEE', 'PI', 'PAYEEPI' };
                    }
                } else if(commonUtils.isNonResearchEvent) {
                    validIndvRoles = new Set<String>{ 'ATND', 'PAYEE' };
                }
            }
            for(VDST_EventPrtcpntRole_gne__c role : prtcpntRoles) {
                if( validIndvRoles.contains( role.EventParticipantRoleCode_gne__c ) ) {
                    rolesToSort.add(new SelectOption(role.Id, role.EventParticipantRoleName__c));
                }
            }
        } else if(isOrgPrtcpnt) {
            Set<String> validOrgRoles;
            if(commonUtils.isResearchEvent) {
                validOrgRoles = new Set<String>{ 'PAYEE', 'PAYEEPI' };
            } else if(commonUtils.isNonResearchEvent) {
                List<VDST_EventPrtcpntAccnt_gne__c> rschPrtcptns =
                  [ SELECT ParticipantRole_gne__c
                    FROM VDST_EventPrtcpntAccnt_gne__c
                    WHERE VDST_Event_gne__c = :editId
                    AND ParticipantRole_gne__c IN :payeeList
                    AND Id != :prtcpnt.evntPrtcpnt.Id ];
                Boolean payeeParticipantExists = ( rschPrtcptns.size() > 0 );
                if(payeeParticipantExists) {
                    validOrgRoles = new Set<String>{ 'ATND' };
                } else {
                    validOrgRoles = new Set<String>{ 'ATND', 'ORG' };
                }
            }
            for(VDST_EventPrtcpntRole_gne__c role : prtcpntRoles) {
                if( validOrgRoles.contains( role.EventParticipantRoleCode_gne__c ) ) {
                    rolesToSort.add(new SelectOption(role.Id, role.EventParticipantRoleName__c));
                }
            }
        }
        return rolesToSort;
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description Method for VF - Invoking changeFields with param
    * @return PageReference
    */
    public PageReference changeFields() {
        changeFields(true);
        return null;
    }

    /** @date 3/22/2013
    * @Author Pawel Sprysak
    * @description Method for VF - Setting field mapping and values
    * @param Boolean setDetault (Whateher method should set default values)
    */
    private void changeFields(Boolean setDetault) {
        actualMap = new Map<String, VDST_EventPrtcpntField_gne__c>();
        if(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c != null) {
            for(VDST_EventPrtcpntField_gne__c epf : VDST_Utils.getFieldReqList(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__c)) {
                actualMap.put(epf.FieldName_gne__c.remove('PRE_INDV.').remove('PRE_ORG.'), epf);
            }
        }
        for(String value : PRCTPNT_VAL_FIELDS) {
            if(!actualMap.containsKey(value)) {
                actualMap.put(value, new VDST_EventPrtcpntField_gne__c(IsRequired_gne__c = false, IsVisible_gne__c = true, FieldLabel_gne__c = ''));
            }
        }
        if(setDetault) {
            List<String> PRCTPNT_FIELDS = new List<String>{'ParticipantProfession_gne', 'Credential_gne', 'ParticipantContractStatus_gne', 'ParticipantAffiliation_gne', 'ParticipantContractStatus_gne', 'UnixID_gne'};
            for(String field : PRCTPNT_FIELDS) {
                if(actualMap.get(field) != null) { // && actualMap.get(field).DefaultValue_gne__c != null // Removed to overwrite values
                    if('prvdrCode'.equals(actualMap.get(field).DefaultValue_gne__c)) {
                        // Exception for Affiliation Vendor Staff
                        prtcpnt.evntPrtcpnt.put(field+ '__c', privileges.providerName);
                    } else {
                        prtcpnt.evntPrtcpnt.put(field+ '__c', actualMap.get(field).DefaultValue_gne__c);
                    }
                } else if('ParticipantAffiliation_gne'.equals(field) && 'VNDSTAFF'.equals(prtcpnt.evntPrtcpnt.EventParticipantRole_gne__r.EventParticipantRoleCode_gne__c)) {
                    prtcpnt.evntPrtcpnt.put(field+ '__c', prtcpnt.evntPrtcpnt.EventParticipantRole_gne__r.EventParticipantRoleName__c);
                } else if('ParticipantContractStatus_gne'.equals(field)) {
                    prtcpnt.evntPrtcpnt.put(field+ '__c', actualMap.get(field).DefaultValue_gne__c);
                }
            }
            List<String> ADDRESS_FIELDS = new List<String>{'City_gne', 'Country_gne', 'PostalCode_gne', 'StateProvince_gne', 'StreetAddress_gne'};
            for(String field : ADDRESS_FIELDS) {
                if(actualMap.get('VDST_Address_gne.'+field) != null) { // && actualMap.get('VDST_Address_gne.'+field).DefaultValue_gne__c != null // Removed to overwrite values
                    prtcpnt.evntPrtcpntAddress.put(field+ '__c', actualMap.get('VDST_Address_gne.' + field).DefaultValue_gne__c);
                }
            }
        }
        if(commonUtils.isNonResearchEvent && 'Organization'.equals(prtcpnt.accountType) && (!actualMap.get('hasTrans').IsVisible_gne__c || !actualMap.get('hasFees').IsVisible_gne__c) ) {
            if(prtcpnt.transactions.containsKey('HONORARIA')) {
               prtcpnt.transactions.get('HONORARIA').transAmount = '0.0';
            }
            prtcpnt.accountType = 'Individual';
        }
    }

    /** @date 3/28/2013
    * @Author Pawel Sprysak
    * @description Method for VF - Getter for Paid To List Options
    * @return List<SelectOption>
    */
    public List<SelectOption> getPaidTo() {
        return new List<SelectOption>{new SelectOption('Individual', 'Individual'), new SelectOption('Organization', 'Organization')};
    }

    /** @date 9/7/2014
    * @Author Konrad Malinowski
    * @description Method for VF - Clear Participant List Messages
    */
    public void clearParticipantListMessages() {
        prtcpntListMsg = '';
        prtcpntListMsgErr = '';
    }
//////////////////////////////
// Manage Participant - END //
//////////////////////////////




//////////////////////
// Wrappers - BEGIN //
//////////////////////
    /** @date 2/19/2013
    * @Author Pawel Sprysak
    * @description Wrapper Class for Participants
    * !Important - PrtcpntWrapper fields name are associated with DB!
    */
    public class PrtcpntWrapper implements IReflection {
        private List<String>                                 transactionList { get; set; }
        public Integer                                       wrapperNum      { get; set; }
        public Boolean                                       isValidRecord   {
            get{
                for(String e : errorMsgList) {
                    if(String.isNotBlank(e)) {
                        return false;
                    }
                }
                return true;
            }
        }
        public String                                        eventTypeVal    { get; set; }
        public Decimal                                       itemAmount      { get; set; }
        public Integer                                       eventDates      { get; set; }
        public VDST_EventDetailCommon                        commonUtils     { get; set; }
        public VDST_Validator.ParticipantsValidationInput    prtcpntValidObj { get; set; }
        public Decimal                                       totalMealAmount { get; set; }
        // VDST_EventPrtcpntAccnt_gne__c object data
        public VDST_EventPrtcpntAccnt_gne__c                 evntPrtcpnt     { get; set; }    // VDST_EventPrtcpntAccnt_gne__c object
        public VDST_Address_gne__c                           evntPrtcpntAddress { get; set; } // VDST_Address_gne__c object
        public Map<String, ParticipantTransactionWrapper>    transactions    { get; set; }    // VDST_PrtcpntTransaction__c object
        public List<ParticipantAttendanceWrapper>            prtcpntAtt      { get; set; }    // VDST_EventPrtcpntAttendance_gne__c object
        // Extra values
        public List<AttendanceWrapper>                       attendanceList  { get; set; }
        public VDST_PrtcpntTransaction_gne__c                singleSpendTrans { get; set; }
        // Validation info fields
        public String                                        lastNameInfo    { get; set; }
        public List<String>                                  errorMsgList    { get; set; }
        // Organization objects
        public VDST_EventPrtcpntAccnt_gne__c                 evntOrg         { get; set; }    // VDST_EventPrtcpntAccnt_gne__c object for Organization
        public VDST_Address_gne__c                           evntOrgAddress  { get; set; }    // VDST_Address_gne__c object for Organization
        public VDST_PrtcpntTransaction_gne__c                evntOrgTrans    { get; set; }    // VDST_PrtcpntTransaction_gne__c object for Organization
        public String                                        accountType     { get; set; }
        // Role Map Reference
        private Map<String, VDST_EventPrtcpntRole_gne__c>    eventRolesMap   { get; set; }
        // Validation
        public String Id {
            get {
                return evntPrtcpnt.Id;
            }
            set;
        }
        public String lastModifiedDate {
            get {
                if(lastModifiedDate == null) {
                    return evntPrtcpnt.LastModifiedDate.format();
                } else {
                    return lastModifiedDate;
                }
            }
            set;
        }
        public String lastModifiedBy {
            get {
                if(lastModifiedBy == null) {
                    return evntPrtcpnt.LastModifiedByName_gne__c;
                } else {
                    return lastModifiedBy;
                }
            }
            set;
        }
        public Boolean contractStatus {
            get {
                if('CNTRCTD'.equals(evntPrtcpnt.ParticipantContractStatus_gne__c)) {
                    return true;
                } else {
                    return false;
                }
            }
            set {
                if(value == true) {
                    evntPrtcpnt.ParticipantContractStatus_gne__c = 'CNTRCTD';
                } else {
                    evntPrtcpnt.ParticipantContractStatus_gne__c = 'NTCNTRCTD';
                }
            }
        }
        // State holders
        public String                                               stateHolder    {                 // Variable for getting state but not writing it
            get {
                return evntPrtcpntAddress.StateProvince_gne__c;
            }
            set;
        }
        public String                                               orgStateHolder    {                 // Variable for getting state but not writing it
            get {
                return evntOrgAddress.StateProvince_gne__c;
            }
            set;
        }
        public String                                               expenseCodeTransaction {
            get {
                if(singleSpendTrans != null && singleSpendTrans.TransactionTypeCode_gne__c != null) {
                    return VDST_Utils.expenseTypeCodeToNameMap().get(singleSpendTrans.TransactionTypeCode_gne__c);
                }
                return '';
            }
        }
        // Label methods

        public String getProfessionRO() {
            return commonUtils.getLabel(evntPrtcpnt.ParticipantProfession_gne__c);
        }
        public String getParticipantStateLabel() {
            String returnValue = '';
            if(!String.isBlank(evntPrtcpntAddress.Country_gne__c) && 'USA'.equals(evntPrtcpntAddress.Country_gne__c)) {
                returnValue = VDST_Utils.getStatesMap().get(evntPrtcpntAddress.StateProvince_gne__c);
            }
            if(!String.isBlank(evntPrtcpntAddress.StatesNameHolder_gne__c) && String.isBlank(returnValue)) {
                returnValue = evntPrtcpntAddress.StatesNameHolder_gne__c;
            }
            return returnValue;
        }
        public String getParticipantCountryLabel() {
            return commonUtils.getLabel(evntPrtcpntAddress.Country_gne__c);
        }
        public String getLicenseStateLabel() {
            return VDST_Utils.getStatesMap().get(evntPrtcpnt.LicenseState_gne__c);
        }
        public String getOrganizationStateLabel() {
            if(evntOrgAddress != null) {
                String returnValue = '';
                if(!String.isBlank(evntOrgAddress.Country_gne__c) && 'USA'.equals(evntOrgAddress.Country_gne__c)) {
                    returnValue = VDST_Utils.getStatesMap().get(evntOrgAddress.StateProvince_gne__c);
                }
                if(!String.isBlank(evntOrgAddress.StatesNameHolder_gne__c) && String.isBlank(returnValue)) {
                    returnValue = evntOrgAddress.StatesNameHolder_gne__c;
                }
                return returnValue;
            }
            return '';
        }
        public String getOrganizationCountryLabel() {
            if(evntOrgAddress != null) {
                return commonUtils.getLabel(evntOrgAddress.Country_gne__c);
            }
            return '';
        }
        public String getPrtcpntOrgStateLabel() {
            if(evntPrtcpntAddress != null) {
                String returnValue = '';
                if(!String.isBlank(evntPrtcpntAddress.Country_gne__c) && 'USA'.equals(evntPrtcpntAddress.Country_gne__c)) {
                    returnValue = VDST_Utils.getStatesMap().get(evntPrtcpntAddress.StateProvince_gne__c);
                }
                if(!String.isBlank(evntPrtcpntAddress.StatesNameHolder_gne__c) && String.isBlank(returnValue)) {
                    returnValue = evntPrtcpntAddress.StatesNameHolder_gne__c;
                }
                return returnValue;
            }
            return '';
        }
        public String getPrtcpntOrgCountryLabel() {
            if(evntPrtcpntAddress != null) {
                return commonUtils.getLabel(evntPrtcpntAddress.Country_gne__c);
            }
            return '';
        }
        public String getSuffixLabel() {
            return commonUtils.getLabel(evntPrtcpnt.Suffix_gne__c);
        }

        // Constructor for Creating Events
        public PrtcpntWrapper(VDST_EventDetailPrtcpntUtils utilClass) { //Standard Controller
            eventTypeVal = utilClass.eventType;
            commonUtils = utilClass.commonUtils;
            prtcpntValidObj = utilClass.prtcpntValidObj;
            itemAmount = utilClass.itemAmount;
            totalMealAmount = 0;
            // Error messages list
            errorMsgList = new List<String>{'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''};
            /*
            for(Integer i=0; i<40; i++) {
                errorMsgList.add('');
            }
            */
            // Participant
            evntPrtcpnt = new VDST_EventPrtcpntAccnt_gne__c(ParticipantProfession_gne__c = '', PartyType_gne__c = 'INDV', VDST_Event_gne__c = utilClass.editId);
            evntPrtcpntAddress = new VDST_Address_gne__c(AddressType_gne__c = 'Physical', VDST_Event_gne__c = utilClass.editId);

            // Organization
            accountType = 'Individual';
            evntOrg = new VDST_EventPrtcpntAccnt_gne__c(PartyType_gne__c = 'ORG', VDST_Event_gne__c = utilClass.editId, Credential_gne__c = 'PAIDTO', ParticipantProfession_gne__c = 'PAIDTO', ParticipantContractStatus_gne__c = 'CNTRCTD');
            evntOrgAddress = new VDST_Address_gne__c(AddressType_gne__c = 'Physical', VDST_Event_gne__c = utilClass.editId);

            // Check what event type/transactions
            if(commonUtils.isNonResearchEvent) {
                transactionList = VDST_Utils.EVENT_NONRESEARCH_TRANSACTIONS;
            } else if(commonUtils.isStdEvent) {
                transactionList = VDST_Utils.EVENT_ADBOAD_TRANSACTIONS;
            } else {
                transactionList = new List<String>();
            }

            // Create defaul transactions
            setNewPrtcpntTransactionList();
            if(commonUtils.isSSEvent) {
                setSingleSpendTransaction();
            }
            evntOrgTrans = new VDST_PrtcpntTransaction_gne__c();

            // Attendance
            prtcpntAtt = new List<ParticipantAttendanceWrapper>();
        }
        // Constructor for Editing Events
        public PrtcpntWrapper(VDST_EventDetailPrtcpntUtils utilClass, String participantId) {
            this(utilClass);
            // Participant
            evntPrtcpnt = VDST_Utils.getPrtcpntById(participantId);
            if(evntPrtcpnt.ParticipantProfession_gne__c == null) {
                evntPrtcpnt.ParticipantProfession_gne__c = '';
            }
            evntPrtcpntAddress = VDST_Utils.getAddressById(evntPrtcpnt.VDST_Address_gne__c);

            // Transactions
            if(commonUtils.isSSEvent) {
                setSingleSpendTransaction();
            }
            setTransactionValues();
            if(evntOrgTrans.TransactionTypeCode_gne__c == null) {
                evntOrgTrans.TransactionTypeCode_gne__c = 'HONORARIA';
                evntOrgTrans.FeePayToPartyType_gne__c = 'ORG';
                evntOrgTrans.TransactionAllocationType_gne__c = 'DIRECT';
                evntOrgTrans.TransactionLevel_gne__c = 'INDV';
            }

            // Organization
            if('Organization'.equals(accountType) && !commonUtils.isNonResearchEvent) {
                evntOrg = VDST_Utils.getPrtcpntById(evntOrgTrans.VDST_EventPrtcpntAccnt_gne__c);
                evntOrgAddress = VDST_Utils.getAddressById(evntOrg.VDST_Address_gne__c);
            }

            // Attendance
            setAttendanceBox();
        }
        // CSV Constructor
        public PrtcpntWrapper(VDST_EventDetailPrtcpntUtils utilClass, List<String> values, Integer num, String eventType, String eventId, Map<String, VDST_EventPrtcpntRole_gne__c> eventRolesMapRef, Integer eventDatesRef, Date evStartDate) {
            this(utilClass);
            eventRolesMap = eventRolesMapRef;
            eventDates = eventDatesRef;
            wrapperNum = num;
            if(values != null && values.size() == 40) {
                List<String> newValues = new List<String>();
                for(String valToCheck : values) {
                    if(valToCheck == null) {
                        newValues.add('');
                    } else {
                        newValues.add(valToCheck.trim());
                    }
                }
                values = newValues;
                // Source Provide Use - index 0 - not in use
                evntPrtcpnt.VendorParticipantID_gne__c = values.get(1).left(45);
                evntPrtcpnt.EventParticipantRole_gne__c = null;
                if(!String.isBlank(values.get(2))) {
                    for(VDST_EventPrtcpntRole_gne__c roleObj : eventRolesMap.values()) {
                        if(values.get(2).equalsIgnoreCase(roleObj.EventParticipantRoleName__c)) {
                            evntPrtcpnt.EventParticipantRole_gne__c = roleObj.Id;
                            break;
                        }
                    }
                }
                evntPrtcpnt.LastName_gne__c = values.get(3).left(50);
                evntPrtcpnt.FirstName_gne__c = values.get(4).left(50);
                evntPrtcpnt.MiddleName_gne__c = values.get(5).left(255);
                evntPrtcpnt.Suffix_gne__c = values.get(6);
                if(evntPrtcpnt.Suffix_gne__c != null && commonUtils.inverseMap.get(evntPrtcpnt.Suffix_gne__c.toLowerCase()) != null) { // Change Label to Code
                    evntPrtcpnt.Suffix_gne__c = commonUtils.inverseMap.get(evntPrtcpnt.Suffix_gne__c.toLowerCase());
                }
                evntPrtcpnt.BusinessPhone_gne__c = values.get(7).left(20);
                evntPrtcpnt.Email_gne__c = values.get(8).left(80);
                evntPrtcpnt.ParticipantAffiliation_gne__c = values.get(9).left(100);
                evntPrtcpnt.ParticipantProfession_gne__c = values.get(10);
                if(evntPrtcpnt.ParticipantProfession_gne__c != null && commonUtils.inverseMap.get(evntPrtcpnt.ParticipantProfession_gne__c.toLowerCase()) != null) { // Change Label to Code
                    evntPrtcpnt.ParticipantProfession_gne__c = commonUtils.inverseMap.get(evntPrtcpnt.ParticipantProfession_gne__c.toLowerCase());
                }
                evntPrtcpnt.Credential_gne__c = values.get(11);
                evntPrtcpnt.ParticipantContractStatus_gne__c = values.get(12);
                evntPrtcpnt.UnixID_gne__c = values.get(13).left(20);
                evntPrtcpnt.NPI_gne__c = values.get(14).left(50);
                evntPrtcpnt.DEA_gne__c = values.get(15).left(50);
                if(values.get(16) != null) {
                    evntPrtcpnt.LicenseNumber_gne__c = values.get(16).toUpperCase();
                } else {
                    evntPrtcpnt.LicenseNumber_gne__c = '';
                }
                evntPrtcpnt.LicenseState_gne__c = VDST_Utils.convertStateToUpperCode( values.get(17) );
                evntPrtcpntAddress.StreetAddress_gne__c = values.get(18).left(100);
                evntPrtcpntAddress.City_gne__c = values.get(19).left(100);
                evntPrtcpntAddress.PostalCode_gne__c = values.get(21).left(15);
                evntPrtcpntAddress.Country_gne__c = values.get(22);
                if(evntPrtcpntAddress.Country_gne__c != null && commonUtils.inverseMap.get(evntPrtcpntAddress.Country_gne__c.toLowerCase()) != null) { // Change Label to Code
                    evntPrtcpntAddress.Country_gne__c = commonUtils.inverseMap.get(evntPrtcpntAddress.Country_gne__c.toLowerCase());
                }
                evntPrtcpntAddress.StateProvince_gne__c = values.get(20).left(40);
                if(evntPrtcpntAddress.StateProvince_gne__c != null) {
                    if('USA'.equalsIgnoreCase(evntPrtcpntAddress.Country_gne__c)) { // Change Label to Code
                        evntPrtcpntAddress.StateProvince_gne__c = VDST_Utils.convertStateToUpperCode(evntPrtcpntAddress.StateProvince_gne__c);
                    } else {
                        evntPrtcpntAddress.StatesNameHolder_gne__c = evntPrtcpntAddress.StateProvince_gne__c;
                        evntPrtcpntAddress.StateProvince_gne__c = 'ANY';
                    }
                }
                // Transactions
                Integer transactionStart = 23;
                for(String code : transactionList) { // Currency
                    if(values.get(transactionStart) != null) {
                        String transactionValue = values.get(transactionStart).replace('$', '').replace(',', '');
                        try {
                            if(Double.valueOf(transactionValue) <= 99999.99) {
                                transactions.get(code).transAmount = transactionValue;
                            } else {
                                transactions.get(code).transAmount = transactionValue.left(5);
                            }
                        } catch (TypeException te) {
                            transactions.get(code).transAmount = '0.00';
                        }
                        transactionStart++;
                    }
                }
                Integer statusStart = 30;
                attendanceList = new List<AttendanceWrapper>();
                for(Integer i = 0; i < eventDatesRef; i++) {
                    Date attDate = evStartDate;
                    if('Did Not Show'.equalsIgnoreCase(values.get(statusStart + i))) {
                        attendanceList.add(new AttendanceWrapper(new VDST_EventPrtcpntAttendance_gne__c(MealAmount_gne__c = 0), String.valueOf(attDate.addDays(i)), false));
                        attendanceList.get(i).mealField = 'NOTAPPLI';
                    } else {
                        attendanceList.add(new AttendanceWrapper(new VDST_EventPrtcpntAttendance_gne__c(MealAmount_gne__c = 0), String.valueOf(attDate.addDays(i)), true));
                        if('Consumed'.equalsIgnoreCase(values.get(statusStart + i + 5)) || 'Opted Out'.equalsIgnoreCase(values.get(statusStart + i + 5)) || 'Not Applicable'.equalsIgnoreCase(values.get(statusStart + i + 5)) || 'No Meal Provided'.equalsIgnoreCase(values.get(statusStart + i + 5))) {
                            //attendanceList.get(i).attendance = new VDST_EventPrtcpntAttendance_gne__c(MealAmount_gne__c = 0);
                            attendanceList.get(i).mealField = values.get(statusStart + i + 5);
                            if(attendanceList.get(i).attendance.ParticipantMealConsumptionStatus_gne__c != null && commonUtils.inverseMap.get(attendanceList.get(i).attendance.ParticipantMealConsumptionStatus_gne__c.toLowerCase()) != null) { // Change Label to Code
                                attendanceList.get(i).mealField = commonUtils.inverseMap.get(attendanceList.get(i).attendance.ParticipantMealConsumptionStatus_gne__c.toLowerCase());
                            }
                        } else {
                            //attendanceList.get(i).attendance = new VDST_EventPrtcpntAttendance_gne__c(MealAmount_gne__c = 0);
                            attendanceList.get(i).mealField = 'CONSUMED';
                        }
                    }
                }
            }
        }
        // CSV rewriting
        public void setValues(PrtcpntWrapper template) {
            evntPrtcpnt.VendorParticipantID_gne__c = template.evntPrtcpnt.VendorParticipantID_gne__c;
            evntPrtcpnt.EventParticipantRole_gne__c = template.evntPrtcpnt.EventParticipantRole_gne__c;
            evntPrtcpnt.LastName_gne__c = template.evntPrtcpnt.LastName_gne__c;
            evntPrtcpnt.FirstName_gne__c = template.evntPrtcpnt.FirstName_gne__c;
            evntPrtcpnt.MiddleName_gne__c = template.evntPrtcpnt.MiddleName_gne__c;
            evntPrtcpnt.Suffix_gne__c = template.evntPrtcpnt.Suffix_gne__c;
            evntPrtcpnt.BusinessPhone_gne__c = template.evntPrtcpnt.BusinessPhone_gne__c;
            evntPrtcpnt.Email_gne__c = template.evntPrtcpnt.Email_gne__c;
            evntPrtcpnt.ParticipantAffiliation_gne__c = template.evntPrtcpnt.ParticipantAffiliation_gne__c;
            evntPrtcpnt.ParticipantProfession_gne__c = template.evntPrtcpnt.ParticipantProfession_gne__c;
            evntPrtcpnt.Credential_gne__c = template.evntPrtcpnt.Credential_gne__c;
            evntPrtcpnt.ParticipantContractStatus_gne__c = template.evntPrtcpnt.ParticipantContractStatus_gne__c;
            evntPrtcpnt.UnixID_gne__c = template.evntPrtcpnt.UnixID_gne__c;
            evntPrtcpnt.NPI_gne__c = template.evntPrtcpnt.NPI_gne__c;
            evntPrtcpnt.DEA_gne__c = template.evntPrtcpnt.DEA_gne__c;
            evntPrtcpnt.LicenseState_gne__c = template.evntPrtcpnt.LicenseState_gne__c;
            evntPrtcpnt.LicenseNumber_gne__c = template.evntPrtcpnt.LicenseNumber_gne__c;
            evntPrtcpntAddress.StreetAddress_gne__c = template.evntPrtcpntAddress.StreetAddress_gne__c;
            evntPrtcpntAddress.City_gne__c = template.evntPrtcpntAddress.City_gne__c;
            evntPrtcpntAddress.StateProvince_gne__c = template.evntPrtcpntAddress.StateProvince_gne__c;
            evntPrtcpntAddress.PostalCode_gne__c = template.evntPrtcpntAddress.PostalCode_gne__c;
            evntPrtcpntAddress.Country_gne__c = template.evntPrtcpntAddress.Country_gne__c;
            for(String code : transactionList) {
                transactions.get(code).transAmount = template.transactions.get(code).transAmount;
            }
            // Other values // Attendee + Meal Status
            validateBatchFields();
        }
        // CSV Validation
        public void validateBatchFields() {
            // Clear previous validation
            for(Integer i=2; i<=22; i++) {
                errorMsgList[i] = '';
            }
            // Participant Role
            if(String.isBlank(evntPrtcpnt.EventParticipantRole_gne__c)) {
                errorMsgList[2] = 'Participant Role field is required';
            }
            // First Name field
            if(String.isBlank(evntPrtcpnt.FirstName_gne__c)) {
                errorMsgList[4] = 'First Name field is required';
            }
            // Last Name field
            if(String.isBlank(evntPrtcpnt.LastName_gne__c)) {
                errorMsgList[3] = 'Last Name field is required';
            }
            // Email field
            if(!String.isBlank(evntPrtcpnt.Email_gne__c) && !VDST_Utils.validateEmail(evntPrtcpnt.Email_gne__c)) {
                errorMsgList[8] = 'Invalid email format';
            }
            // Participant Affiliation field
            if(String.isBlank(evntPrtcpnt.ParticipantAffiliation_gne__c)) {
                errorMsgList[9] = 'Participant Affiliation field is required';
            }
            // Participant Profession field
            if(String.isBlank(evntPrtcpnt.ParticipantProfession_gne__c)) {
                errorMsgList[10] = 'Participant Profession field is required';
            }
            // Credential field
            if(String.isBlank(evntPrtcpnt.Credential_gne__c)) {
                errorMsgList[11] = 'Credential field is required';
            }
            // Contract Status
            if( String.isNotBlank(evntPrtcpnt.ParticipantContractStatus_gne__c) ) {
                Set<String> contractedSet = new Set<String>{'cntrctd', 'contracted'};
                Set<String> notContractedSet = new Set<String>{'ntcntrctd', 'not contracted'};
                String contractedStatus = evntPrtcpnt.ParticipantContractStatus_gne__c.toLowerCase();
                if( contractedSet.contains(contractedStatus) ) {
                    evntPrtcpnt.ParticipantContractStatus_gne__c = 'CNTRCTD';
                } else if( notContractedSet.contains(contractedStatus) ) {
                    evntPrtcpnt.ParticipantContractStatus_gne__c = 'NTCNTRCTD';
                } else {
                    errorMsgList[12] = 'Incorrect Contracted Status value';
                }
            }
            VDST_EventPrtcpntField_gne__c contractedStatusFieldSettings = (
                String.isNotBlank(evntPrtcpnt.EventParticipantRole_gne__c) ?
                prtcpntValidObj.prtcpntFieldMap.get(evntPrtcpnt.EventParticipantRole_gne__c).get('ParticipantContractStatus_gne') :
                null
            );
            if( String.isNotBlank(evntPrtcpnt.EventParticipantRole_gne__c) &&
                contractedStatusFieldSettings.IsRequired_gne__c &&
                String.isBlank(evntPrtcpnt.ParticipantContractStatus_gne__c)
            ) {
                if(contractedStatusFieldSettings.IsVisible_gne__c) {
                    errorMsgList[12] = 'Contracted Status field is required';
                } else {
                    evntPrtcpnt.ParticipantContractStatus_gne__c = contractedStatusFieldSettings.DefaultValue_gne__c;
                }
            }
            // Unix Id
            if(String.isBlank(evntPrtcpnt.UnixID_gne__c) && evntPrtcpnt.EventParticipantRole_gne__c != null) {
                for(VDST_EventPrtcpntRole_gne__c roleObj : eventRolesMap.values()) {
                    if(roleObj.Id == evntPrtcpnt.EventParticipantRole_gne__c) {
                        if('Genentech Employee'.equalsIgnoreCase(roleObj.EventParticipantRoleName__c)) {
                            errorMsgList[13] = 'Unix ID field is required';
                        } else {
                            evntPrtcpnt.UnixID_gne__c = null;
                        }
                        break;
                    }
                }
            }
            // NPI field
            if(!String.isBlank(evntPrtcpnt.NPI_gne__c) && !Pattern.matches('^[0-9]{10}$', evntPrtcpnt.NPI_gne__c)) {
                errorMsgList[14] = 'Invalid NPI format';
            }
            // DEA field
            if(!String.isBlank(evntPrtcpnt.DEA_gne__c) && !Pattern.matches('^[a-zA-Z]{2}[0-9]{7}$', evntPrtcpnt.DEA_gne__c)) {
                errorMsgList[15] = 'Invalid DEA format';
            }
            // License
            if(!String.isBlank(evntPrtcpnt.LicenseNumber_gne__c) && String.isBlank(evntPrtcpnt.LicenseState_gne__c)) {
                errorMsgList[17] = 'License State is required for License Number';
            } else if(String.isBlank(evntPrtcpnt.LicenseNumber_gne__c) && !String.isBlank(evntPrtcpnt.LicenseState_gne__c)) {
                errorMsgList[16] = 'License Number is required for License State';
            }
            // Country field
            if(String.isBlank(evntPrtcpntAddress.Country_gne__c)) {
                errorMsgList[22] = 'Country field is required';
            } else if(String.isBlank(commonUtils.getLabel(evntPrtcpntAddress.Country_gne__c))) {
                errorMsgList[22] = 'Country field is invalid';
            }

            // Street Address field
            if(String.isBlank(evntPrtcpntAddress.StreetAddress_gne__c)) {
                errorMsgList[18] = 'Street Address field is required';
            } else if (!VDST_Utils.validateAddress(evntPrtcpntAddress.StreetAddress_gne__c)) {
                errorMsgList[18] = 'Street Address contains illegal characters';
            }
            if (String.isNotBlank(evntPrtcpntAddress.StreetAddress2_gne__c) && !VDST_Utils.validateAddress(evntPrtcpntAddress.StreetAddress2_gne__c)) {
                errorMsgList[18] = 'Street Address 2 contains illegal characters';
            }

            // City field
            if(String.isBlank(evntPrtcpntAddress.City_gne__c)) {
                errorMsgList[19] = 'City field is required';
            }
            // City field
            if(String.isNotBlank(evntPrtcpntAddress.City_gne__c) && (evntPrtcpntAddress.City_gne__c.equalsIgnoreCase('unk') || evntPrtcpntAddress.City_gne__c.equalsIgnoreCase('unknown'))) {
                errorMsgList[19] = 'City cannot be equal to "UNK" or "UNKNOW"';
            }
            if(String.isNotBlank(evntPrtcpntAddress.City_gne__c) && !VDST_Utils.validateCity(evntPrtcpntAddress.City_gne__c)) {
                errorMsgList[19] = 'City name contains illegal characters';
            }

            // State field
            if( 'USA'.equals(evntPrtcpntAddress.Country_gne__c) && String.isBlank(evntPrtcpntAddress.StateProvince_gne__c) ||
                !'USA'.equals(evntPrtcpntAddress.Country_gne__c) && String.isBlank(evntPrtcpntAddress.StatesNameHolder_gne__c)
            ) {
                errorMsgList[20] = 'State Province field is required';
            }
            if(String.isNotBlank(evntPrtcpntAddress.StatesNameHolder_gne__c) && !VDST_Utils.validateState(evntPrtcpntAddress.StatesNameHolder_gne__c)) {
                errorMsgList[20] = 'State name contains illegal characters';
            }
            // Postal Code
            if(String.isBlank(evntPrtcpntAddress.PostalCode_gne__c)) {
                errorMsgList[21] = 'Postal Code field is required';
            } else if(('USA'.equals(evntPrtcpntAddress.Country_gne__c) || 'PRI'.equals(evntPrtcpntAddress.Country_gne__c)) && !Pattern.matches('^[0-9]{5}||[0-9]{5}-{1}[0-9]{4}$', evntPrtcpntAddress.PostalCode_gne__c)) {
                errorMsgList[21] = 'Invalid Postal Code format';
            } else if(!Pattern.matches('^[0-9a-zA-Z\\-\\s]+$', evntPrtcpntAddress.PostalCode_gne__c)) {
                errorMsgList[21] = 'Invalid Postal Code format';
            }
        }

        private void setAttendanceBox() {
            totalMealAmount = 0;
            prtcpntAtt.clear();
            for(VDST_EventPrtcpntAttendance_gne__c epa : VDST_Utils.getAttByPrtcpntId(evntPrtcpnt.Id)) {
                prtcpntAtt.add(new ParticipantAttendanceWrapper(epa, commonUtils));
                if(epa.MealAmount_gne__c != null) {
                    totalMealAmount += epa.MealAmount_gne__c;
                }
            }
        }

        public VDST_EventPrtcpntAccnt_gne__c getPrtcpntAccnt() {
            if(evntPrtcpnt.VendorParticipantID_gne__c != null) {
                evntPrtcpnt.VendorParticipantID_gne__c = evntPrtcpnt.VendorParticipantID_gne__c.toUpperCase();
            }
            return evntPrtcpnt;
        }

        public List<VDST_PrtcpntTransaction_gne__c> getPrtcpntTransactionList() {
            List<VDST_PrtcpntTransaction_gne__c> prtcpntTransList = new List<VDST_PrtcpntTransaction_gne__c>();
            // Exception for Non-Research transactions
            String partyType = 'INDV';
            String allocationType = 'DIRECT';
            if(commonUtils.isNonResearchEvent) {
                if('ORG'.equals(evntPrtcpnt.PartyType_gne__c)) {
                    partyType = 'ORG';
                }
                VDST_EventPrtcpntRole_gne__c prtcpntRole = VDST_Utils.getPrtcpntRoleById(evntPrtcpnt.EventParticipantRole_gne__c);
                if(prtcpntRole != null && 'Attendee'.equals(prtcpntRole.EventParticipantRoleName__c)) {
                    allocationType = 'INDIRECT';
                }
            }
            for(String code : transactionList) {
                if(transactions.get(code).transAmount == null) {
                    transactions.get(code).transAmount = '0.00';
                }
                if(commonUtils.isStdEvent || commonUtils.isNonResearchEvent) {
                    prtcpntTransList.add(new VDST_PrtcpntTransaction_gne__c(Id = transactions.get(code).transactionId, TransactionAmount_gne__c = Double.valueOf(transactions.get(code).transAmount), TransactionLevel_gne__c = 'INDV', TransactionTypeCode_gne__c = code, TransactionAllocationType_gne__c = allocationType, FeePayToPartyType_gne__c = partyType));
                }
                if('HONORARIA'.equals(code) && accountType.equals('Organization') && !commonUtils.isNonResearchEvent) {
                    evntOrgTrans.TransactionAmount_gne__c = Double.valueOf(transactions.get(code).transAmount);
                }
            }
            return prtcpntTransList;
        }

        public void setRemovedValues(List<VDST_PrtcpntTransaction_gne__c> removedValues) {
            for(VDST_PrtcpntTransaction_gne__c pt : removedValues) {
                transactions.get(pt.TransactionTypeCode_gne__c).transactionId = null;
                transactions.get(pt.TransactionTypeCode_gne__c).transAmount = '0.00';
            }
        }

        public void setNewPrtcpntTransactionList() {
            transactions = new Map<String, ParticipantTransactionWrapper>();
            for(String code : transactionList) {
               transactions.put(code, new ParticipantTransactionWrapper(null, 0));
            }
        }

        public void setSingleSpendTransaction() {
            if(evntPrtcpnt != null && evntPrtcpnt.Id != null) {
                for(VDST_PrtcpntTransaction_gne__c prtcpntTrasnaction : VDST_Utils.getPrtcpntTransByAccount(evntPrtcpnt.Id, true)) {
                    for(String eventTransactionCode : VDST_Utils.EVENT_SS_TRANSACTIONS) {
                        if(eventTransactionCode.equals(prtcpntTrasnaction.TransactionTypeCode_gne__c)) {
                            singleSpendTrans = prtcpntTrasnaction;
                        }
                    }
                }
            }
            if(singleSpendTrans == null) {
                singleSpendTrans = new VDST_PrtcpntTransaction_gne__c(
                        VDST_EventPrtcpntAccnt_gne__c = evntPrtcpnt.Id,
                        VDST_PaidToParty_gne__c = evntPrtcpnt.Id,
                        FeePayToPartyType_gne__c = 'INDV',
                        ItemQuantity_gne__c = 1,
                        TransactionAllocationType_gne__c = 'DIRECT',
                        TransactionAmount_gne__c = itemAmount,
                        TransactionLevel_gne__c = 'INDV',
                        TransactionTypeCode_gne__c = VDST_Utils.eventToExpenseTypeMap().get(eventTypeVal)
                    );
            }
        }

        public List<VDST_EventPrtcpntAttendance_gne__c> getPrtcpntAttendanceList() {
            List<VDST_EventPrtcpntAttendance_gne__c> newEpa = new List<VDST_EventPrtcpntAttendance_gne__c>();
            for(ParticipantAttendanceWrapper paw : prtcpntAtt) {
                newEpa.add(paw.prtcpntAtt);
            }
            return newEpa;
        }

        public void setTransactionValues() {
            for(VDST_PrtcpntTransaction_gne__c prtcpntTrasnaction : VDST_Utils.getPrtcpntTransByAccount(evntPrtcpnt.Id, (commonUtils.isResearchEvent || commonUtils.isNonResearchEvent))) {
                if('ORG'.equals(prtcpntTrasnaction.FeePayToPartyType_gne__c) && !commonUtils.isNonResearchEvent) {
                    evntOrgTrans = prtcpntTrasnaction;
                } else if(transactions.containsKey(prtcpntTrasnaction.TransactionTypeCode_gne__c)) {
                    transactions.get(prtcpntTrasnaction.TransactionTypeCode_gne__c).transactionId = String.valueOf(prtcpntTrasnaction.Id);
                    transactions.get(prtcpntTrasnaction.TransactionTypeCode_gne__c).transAmount = String.valueOf(prtcpntTrasnaction.TransactionAmount_gne__c);
                    // Check is Organization
                    if('HONORARIA'.equals(prtcpntTrasnaction.TransactionTypeCode_gne__c) && prtcpntTrasnaction.VDST_EventPrtcpntAccnt_gne__c != prtcpntTrasnaction.VDST_PaidToParty_gne__c) {
                        accountType = 'Organization';
                    }
                }
            }
        }

        public object getValue(String name) {
            String result = '';
            if(!String.isBlank(evntPrtcpnt.LastName_gne__c)) {
                result += evntPrtcpnt.LastName_gne__c;
            }
            if(!String.isBlank(evntPrtcpnt.FirstName_gne__c)) {
                result += evntPrtcpnt.FirstName_gne__c;
            }
            return result;
        }
    }

    /** @date 3/17/2013
    * @Author Pawel Sprysak
    * @description Wrapper Class for Participant Transactions
    */
    class ParticipantTransactionWrapper {
        public String transactionId { get; set; }
        public String transAmount { get;
            set {
                if(value != null && !String.isBlank(value)) {
                    try {
                        transAmount = value;
                    } catch (TypeException te) {
                        transAmount = '0.00';
                    }
                } else {
                    transAmount = '0.00';
                }
            }
        }

        public ParticipantTransactionWrapper(String transactionId, Double transAmount) {
            this.transactionId = transactionId;
            this.transAmount = String.valueOf(transAmount);
        }
    }

    /** @date 3/27/2013
    * @Author Pawel Sprysak
    * @description Wrapper Class for Participant Attendance
    */
    class ParticipantAttendanceWrapper {
        public VDST_EventPrtcpntAttendance_gne__c   prtcpntAtt   { get; set; }
        private VDST_EventDetailCommon              commonUtils  { get; set; }
        public Boolean attCheckbox {
            get {
                if(prtcpntAtt.AttendanceStatus_gne__c == null) {
                    prtcpntAtt.AttendanceStatus_gne__c = 'ATND';
                    return true;
                } else if(prtcpntAtt.AttendanceStatus_gne__c.equalsIgnoreCase('ATND')) {
                    return true;
                } else {
                    return false;
                }
            }
            set {
                if(value == true) {
                    prtcpntAtt.AttendanceStatus_gne__c = 'ATND';
                    prtcpntAtt.ParticipantMealConsumptionStatus_gne__c = 'CONSUMED';
                } else {
                    prtcpntAtt.AttendanceStatus_gne__c = 'DNS';
                    prtcpntAtt.ParticipantMealConsumptionStatus_gne__c = 'NOTAPPLI';
                }
            }
        }
        public String mealField {
            get {
                return prtcpntAtt.ParticipantMealConsumptionStatus_gne__c;
            }
            set {
                if( prtcpntAtt.AttendanceStatus_gne__c == 'DNS') {
                    prtcpntAtt.ParticipantMealConsumptionStatus_gne__c = 'NOTAPPLI';
                } else {
                    prtcpntAtt.ParticipantMealConsumptionStatus_gne__c = value;
                }
            }
        }
        public String getParticipantMealConsumptionStatus_gne() {
            return commonUtils.getLabel(prtcpntAtt.ParticipantMealConsumptionStatus_gne__c);
        }
        public ParticipantAttendanceWrapper(VDST_EventPrtcpntAttendance_gne__c epa, VDST_EventDetailCommon commonUtilsObj) {
            commonUtils = commonUtilsObj;
            prtcpntAtt = epa;
        }
    }

    /** @date 14/8/2014
    * @Author Konrad Malinowski
    * @description Wrapper Class for Import Validation Status
    */
    public class ImportValidationStatusWrapper {
        private List<PrtcpntWrapper> importWrapParticipants;
        public Boolean isValid {
            get {
                return (isFileValid && areParticipantsValid);
            }
        }
        public Boolean isFileValid {
            get {
                return (fileErrorMessage == '');
            }
        }
        public Boolean areParticipantsValid {
            get {
                for(PrtcpntWrapper pw : importWrapParticipants) {
                    if(!pw.isValidRecord) {
                        return false;
                    }
                }
                return true;
            }
        }
        public String message {
            get {
                return fileWarningMessage + fileErrorMessage + participantsWarningMessage +
                    (areParticipantsValid ? '' : 'Some of the records are not valid.<br/>');
            }
        }
        public String fileErrorMessage { get; set; }
        public String fileWarningMessage { get; set; }
        public String participantsWarningMessage { get; set; }

        public ImportValidationStatusWrapper(List<PrtcpntWrapper> importWrapParticipants) {
            this.importWrapParticipants = importWrapParticipants;
        }

        public void clear() {
            fileErrorMessage = '';
            fileWarningMessage = '';
            participantsWarningMessage = '';
        }
    }
////////////////////
// Wrappers - END //
////////////////////





/////////////////////////////////
// Managing Attendance - BEGIN //
/////////////////////////////////
    private Boolean refreshAttendancePrtcpntList = true;
    private Boolean showAttandanceList = true;

    /** @date 11/28/2013
    * @Author Pawel Sprysak, Konrad Malinowski
    * @description Getter for Attendance List
    * @return List<ParticipantAttWrapper>
    */
    public List<ParticipantAttWrapper> attPrtcpntList {
        get {
            if(!showAttandanceList) {
                attPrtcpntList = null;
                return null;
            }
            if(!refreshAttendancePrtcpntList) {
                return attPrtcpntList;
            }
            try {
                VDST_Event_gne__c event = VDST_Utils.getEventStartEndDateById(editId);
                if(event == null || event.EventStartDate_gne__c == null || event.EventEndDate_gne__c == null) {
                    return new List<ParticipantAttWrapper>();
                }

                Map<String, List<VDST_EventPrtcpntAttendance_gne__c>> participantAttendance = new Map<String, List<VDST_EventPrtcpntAttendance_gne__c>>();
                for(VDST_EventPrtcpntAttendance_gne__c partAttandance : VDST_Utils.getEvPrtpcntAttendanceByEventId(editId)) {
                    if(!participantAttendance.containsKey(partAttandance.Event_PrtcpntAccnt_gne__c)) {
                        participantAttendance.put(partAttandance.Event_PrtcpntAccnt_gne__c, new List<VDST_EventPrtcpntAttendance_gne__c>{partAttandance});
                    } else {
                        participantAttendance.get(partAttandance.Event_PrtcpntAccnt_gne__c).add(partAttandance);
                    }
                }

                attPrtcpntList = new List<ParticipantAttWrapper>();
                attDays = event.EventStartDate_gne__c.daysBetween(event.EventEndDate_gne__c)+1;
                dateList = new List<String>();
                for(Integer i=0; i<attDays; i++) {
                    dateList.add(String.valueOf(event.EventStartDate_gne__c.addDays(i)));
                }

                ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(
                    VDST_Utils.getParticipantList((Id)editId)
                );
                attPrtcpntPagingUtil.setParameters(setCon.getResultSize());
                setCon.setPageSize(attPrtcpntPagingUtil.perPage);
                setCon.first();
                for(Integer i = 1; i < attPrtcpntPagingUtil.actualPage; i++) {
                    setCon.next();
                }
                List<Id> idList = new List<Id>();
                for(VDST_EventPrtcpntAccnt_gne__c participant : (List<VDST_EventPrtcpntAccnt_gne__c>)setCon.getRecords()) {
                    idList.add(participant.Id);
                }
                setCon = null;
                for(VDST_EventPrtcpntAccnt_gne__c participant : VDST_Utils.getParticipantList(idList)) {
                    List<VDST_EventPrtcpntAttendance_gne__c> partAtt = participantAttendance.get(participant.Id);
                    List<AttendanceWrapper> aList = new List<AttendanceWrapper>();
                    for(Integer i=0; i<attDays; i++) {
                        if(partAtt.get(i) != null) {
                            aList.add(new AttendanceWrapper(partAtt.get(i), String.valueOf(event.EventStartDate_gne__c.addDays(i)), 'ATND'.equalsIgnoreCase(partAtt.get(i).AttendanceStatus_gne__c)));
                        }
                    }
                    attPrtcpntList.add(new ParticipantAttWrapper(participant.FirstName_gne__c, participant.LastName_gne__c, alist));
                }
                idList = null;
                return attPrtcpntList;
            } catch(Exception ex) {
                log.logException('attPrtcpntList', ex);
                return new List<ParticipantAttWrapper>();
            }
        }
        set;
    }

    /** @date 3/29/2013
    * @Author Pawel Sprysak
    * @description VF Method for initializing attendances
    * @return PageReference
    */
    public PageReference initAttendances() {
        prtcpntListMsg = '';
        prtcpntListMsgErr = '';
        showAttandanceList = true;
        showParticipantList = false;
        return null;
    }

    /** @date 11/29/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VF Method for saving attendances
    * @return PageReference
    */
    public PageReference onlySaveAttandance() {
        saveAttandanceProxy();
        return null;
    }

    /** @date 11/29/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description VF Method for saving attendances
    * @return PageReference
    */
    public PageReference saveAttandanceAndClose() {
        saveAttandanceProxy();
        showAttandanceList = false;
        showParticipantList = true;
        return null;
    }

    /** @date 3/29/2013
    * @Author Konrad Malinowski, Pawel Sprysak
    * @description Proxy Method for saving attendances
    */
    private void saveAttandanceProxy() {
        refreshAttendancePrtcpntList = false;
        saveAttandance();
        refreshAttendancePrtcpntList = true;
    }

    /** @date 3/29/2013
    * @Author Pawel Sprysak
    * @description Method for saving attendances
    */
    private void saveAttandance() {
        List<VDST_EventPrtcpntAttendance_gne__c> toUpdate = new List<VDST_EventPrtcpntAttendance_gne__c>();
        for(ParticipantAttWrapper pw : attPrtcpntList) {
            for(AttendanceWrapper aw : pw.attendanceList) {
                if(aw.attendanceStatus) {
                    aw.attendance.AttendanceStatus_gne__c = 'ATND';
                    if(!commonUtils.hasMCS) {
                        aw.attendance.ParticipantMealConsumptionStatus_gne__c = 'CONSUMED';
                    }
                } else {
                    aw.attendance.AttendanceStatus_gne__c = 'DNS';
                    aw.attendance.ParticipantMealConsumptionStatus_gne__c = 'NOTAPPLI';
                }
                toUpdate.add(aw.attendance);
            }
        }
        update toUpdate;
        updateEventDate();
        prtcpntListMsg = 'Attendance data has been saved.';
    }

    /** @date 6/12/2013
    * @Author Pawel Sprysak
    * @description Updating Event Last Modified Date
    */
    private void updateEventDate() {
        VDST_Event_gne__c evToUpdate = new VDST_Event_gne__c(Id = editId);
        upsert evToUpdate;
    }

    /** @date 11/29/2013
    * @Author Konrad Malinowski
    * @description VF Method for cancelling attendances
    * @return PageReference
    */
    public PageReference cancelAttandance() {
        showAttandanceList = false;
        showParticipantList = true;
        prtcpntListMsg = '';
        prtcpntListMsgErr = '';
        return null;
    }

    /** @date 3/29/2013
    * @Author Pawel Sprysak
    * @description Wrapper Class for Attendance
    */
    public class AttendanceWrapper {
        public VDST_EventPrtcpntAttendance_gne__c attendance {get; set;}
        public String eventDay {get; set;}
        public Boolean attendanceStatus {
            get {
                if(attendance.AttendanceStatus_gne__c == null) {
                    attendance.AttendanceStatus_gne__c = 'ATND';
                    return true;
                } else if(attendance.AttendanceStatus_gne__c.equalsIgnoreCase('ATND')) {
                    return true;
                } else {
                    return false;
                }
            }
            set {
                //attendanceStatus = value;
                if(value == true) {
                    attendance.AttendanceStatus_gne__c = 'ATND';
                    //attendance.ParticipantMealConsumptionStatus_gne__c = 'CONSUMED';
                } else {
                    attendance.AttendanceStatus_gne__c = 'DNS';
                    //attendance.ParticipantMealConsumptionStatus_gne__c = 'NOTAPPLI';
                }
            }
        }
        public String mealField {
            get {
                return attendance.ParticipantMealConsumptionStatus_gne__c;
            }
            set {
                if( attendance.AttendanceStatus_gne__c.equalsIgnoreCase('DNS') ) {
                    attendance.ParticipantMealConsumptionStatus_gne__c = 'NOTAPPLI';
                } else {
                    attendance.ParticipantMealConsumptionStatus_gne__c = value;
                }
            }
        }

        public AttendanceWrapper(VDST_EventPrtcpntAttendance_gne__c att, String eDate, Boolean aStatus) {
            eventDay = eDate;
            attendance = att;
            attendanceStatus = aStatus;
        }
    }

    /** @date 3/29/2013
    * @Author Pawel Sprysak
    * @description Wrapper Class for Participant Attendance
    */
    public class ParticipantAttWrapper {
        public String FirstName {get; set;}
        public String LastName {get; set;}
        public List<AttendanceWrapper> attendanceList {get; set;}

        public ParticipantAttWrapper(String fName, String lName, List<AttendanceWrapper> aList) {
            FirstName = fName;
            LastName = lName;
            attendanceList = aList;
        }
    }
///////////////////////////////
// Managing Attendance - END //
///////////////////////////////
}