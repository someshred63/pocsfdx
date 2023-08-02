/** @date 2/16/2013
* @Author Pawel Sprysak
* @description Event Detail Controller
*/
global without sharing class VDST_EventDetailController {

    private static final Logger log = Logger.getInstance(VDST_EventDetailController.class.getName());
    // Constants
    public static String TOTAL_SPEND_CONST { get {return 'Total Spend';} }
    // Classes and controllers
    public VDST_EventDetailController thisController { get; set; }
    public VDST_EventDetailPrtcpntUtils prtcpntUtils { get; set; }
    public VDST_EventDetailCommon commonUtils { get; set; }
    public VDST_Validator.ParticipantsValidationInput prtcpntValidObj { get; set; }
    // Editable objects
    public VDST_Event_gne__c eventCreateObject { get; set; }
    public VDST_EventSite_gne__c siteObject { get; set; }
    public VDST_Address_gne__c venueObject { get; set; }
    // Variables
    public Decimal ttlPlanAttCnt { get; set; }      // VF var for Total Planned Att Count
    public Boolean showMealStatus { get; set; }      // VF flag for wheater should show Meal Status
    public Integer eventCreateStep { get; set; }
    public List<SelectOption> drugNames { get; set; }
    public List<String> multiDrugNames { get; set; }
    public Boolean changeDrugName { get; set; }
    public String newDrugNames { get; set; }
    public String contentVendorCode { get; set; }
    public String contentVendorName { get; set; }
    public String appState { get; set; }
    public String editId { get; set; }
    public Boolean editableMode { get; set; }
    public List<EventHistoryWrapper> statusHistoryList { get; set; }
    public List<VDST_Utils.EventDateTransactions> evDateTransList { get; set; }
    private List<VDST_EventDateTransaction_gne__c> evDateTransObjList { get; set; }
    public List<SelectOption> vendorCodeList { get; set; }
    public List<VDST_EventProvider_gne__c> vendorCodeMappingList { get; set; }
    public VDST_EventProvider_gne__c actualContentVen { get; set; }
    public VDST_Event_gne__c eventInfoKeeper { get; set; }     // Event Create/Modified Date Info
    public String multiDrugNamesTxt { get; set; }
    public String multiDrugNamesIds { get; set; }
    public Boolean isValidURL { get; set; }
    // Attachment variables
    public Attachment eventAttachment { get; set; }
    public transient Blob fileBody { get; set; }
    public transient String fileName { get; set; }
    // Validation maps
    public Map<String, VDST_EventField_gne__c> actualMap { get; set; }     // Map for actual status requirements
    public Map<String, Map<String, VDST_EventField_gne__c>> statusFieldMap { get; set; }     // Map for all Event statuses requirements
    public Map<String, Map<String, VDST_EventPrtcpntField_gne__c>> prtcpntFieldMap { get; set; }  // Map for all Participant roles requirements
    // Event Spend Total Transactions
    public Map<String, VDST_EventField_gne__c> totalSpendMap { get; set; }     // Map for holding Summary Transactions
    // Provisioning
    public VDST_Utils.PrivilegesWrapper privileges { get; set; }
    public Boolean hasEditPriv { get; set; }
    // Messages
    public String editActionMessages { get; set; }     // Action message var on Event View
    public String editErrorMessages { get; set; }     // Error message var on Event View
    public Boolean criticalError { get; set; }
    public String creatorNameOfEventFromBatch { get; set; }
    // Flags
    public Boolean invalidatedTransaction { get; set; }
    public Boolean isEditable {                        // Flag for Editable
        get {
            if (editableMode || appState == 'Create') {
                return true;
            } else {
                return false;
            }
        }
        set;
    }
    public Boolean isVirtualAddress {                 // Flag for Event Virtual/Physician Address
        get {
            if ('Virtual'.equals(venueObject.AddressType_gne__c)) {
                return true;
            } else {
                return false;
            }
        }
        set {
            if (value == true) {
                venueObject.AddressType_gne__c = 'Virtual';
            } else {
                venueObject.AddressType_gne__c = 'Physical';
            }
        }
    }
    // State holders
    public String stateHolder {                 // Variable for getting state but not writing it
        get {
            return venueObject.StateProvince_gne__c;
        }
        set;
    }
    // String Mapping to Field
    public String avMapping {
        get {
            return String.valueOf(eventCreateObject.TotalAudioVisual_gne__c);
        }
        set {
            try {
                eventCreateObject.TotalAudioVisual_gne__c = Decimal.valueOf(value);
            } catch (TypeException te) {
                eventCreateObject.TotalAudioVisual_gne__c = null;
            }
        }
    }
    // Planned Participant Editable Flag
    public Boolean showPlannedFldEditable {
        get {
            if (!'CFF'.equals(eventCreateObject.EventType_gne__c) && !'MISCEVENT'.equals(eventCreateObject.EventType_gne__c)) {
                return false;
            } else {
                return true;
            }
        }
    }
    // Flag for Super Admin User
    public Boolean isSuperAdmin {
        get {
            if (Userinfo.getUserName().startsWithIgnoreCase(VDST_Utils.getCustomSettingsIntExt().Admin_Username__c)) {
                return true;
            } else {
                return false;
            }
        }
    }

    public Boolean isNoMoreThenOneEventHistoryRecord {
        get {
            setStatusHistory();
            return (statusHistoryList.size() <= 1);
        }
    }


    /** @date 2/16/2013
    * @Author Pawel Sprysak
    * @description Constructor for Controller
    */
    public VDST_EventDetailController() {
        //initData();
    }

    /** @date 2/16/2013
    * @Author Pawel Sprysak
    * @description Method for initiating data
    */
    public PageReference initData() {
        thisController = this;
        commonUtils = new VDST_EventDetailCommon();
        // Default values and instantate objects
        editId = ApexPages.currentPage().getParameters().get('event');
        String eventType = VDST_Utils.getEventTypeByEventId(editId);
        editId = (eventType != null ? editId : null);
        commonUtils.eventType = (eventType != null ? eventType : ApexPages.currentPage().getParameters().get('type'));
        commonUtils.eventType = (isValidEventType() ? commonUtils.eventType : null);
        appState = 'Create';
        editableMode = false;
        eventCreateStep = 1;
        changeDrugName = false;
        eventInfoKeeper = new VDST_Event_gne__c();
        multiDrugNames = new List<String>();
        drugNames = VDST_Utils.getDrugNames();
        privileges = new VDST_Utils.PrivilegesWrapper();
        privileges.hasPrivileges = false;

        // Validate URL
        if ('ADBOARD'.equals(commonUtils.eventType) && editId == null && !((privileges.isGene || privileges.isProxy) && privileges.isProvisioner)) {
            return goToListPage();
        }
        isValidURL = (eventType != null || commonUtils.eventType != null);
        if (!isValidURL) {
            return goToListPage();
        }

        // Set other values
        commonUtils.setEventTypeFlags();
        if (editId != null) {
            setEventToEdit();
        } else if (commonUtils.eventType != null) {
            selectEvent();
        }
        if (eventCreateObject.IsABMevent_gne__c && !((privileges.isGene || privileges.isProxy) && privileges.isProvisioner)) {
            return goToListPage();
        }
        prepareEventData();

        // Check privileges
        hasEditPriv = false;
        if (privileges != null) {
            Boolean creatingEvent = (('Provisioner'.equals(privileges.userRole) || 'Proxy Submitter'.equals(privileges.userRole) || 'Vendor'.equals(privileges.userRole)) && 'Create'.equals(appState));
            Boolean editEvent = ('Provisioner'.equals(privileges.userRole) || 'Proxy Submitter'.equals(privileges.userRole) || 'Vendor'.equals(privileges.userRole)) && ((eventCreateObject != null && eventCreateObject.LogisticVendor_gne__c == privileges.providerId) || eventCreateObject == null || ('Genentech'.equals(privileges.providerName) && 'GNE'.equals(privileges.providerCode)));
            Boolean monitorEvent = ('Monitoring'.equals(privileges.userRole) && eventCreateObject != null && (eventCreateObject.LogisticVendor_gne__c == privileges.providerId || ('Genentech'.equals(privileges.providerName) && 'GNE'.equals(privileges.providerCode))));
            if (creatingEvent || editEvent || monitorEvent) {
                privileges.hasPrivileges = true;
                if (eventCreateObject != null && eventCreateObject.LogisticVendorCode_gne__c != null) {
                    commonUtils.vendorLoggedVal = eventCreateObject.LogisticVendorCode_gne__c;
                } else {
                    commonUtils.vendorLoggedVal = privileges.providerCode;
                }
            }
            if (creatingEvent || editEvent) {
                hasEditPriv = true;
            }
        }
        setPrtcpntValidObj();
        commonUtils.setEventRoles();
        setPrtcpntUtils();
        setEventAttachment();

        if (
                editId == null && (
                        commonUtils.eventType == null ||
                                (VDST_Utils.getOnlyGenentechEventTypes().containsKey(commonUtils.eventType) && !privileges.isGene && !privileges.isProxy)
                )
        ) {
            privileges.hasPrivileges = false;
        }
        if (editId != null && commonUtils.isNonResearchEvent) {
            commonUtils.nonResTransaction = new VDST_EventDetailCommon.NonResearchPayments(editId, eventCreateObject.ItemAmount_gne__c, commonUtils.eventType, eventCreateObject.ItemCode_gne__c);
        }
        // AGGSPENDME-196: handle new URL parameter representing source transaction ID
        final String srcTxnId = ApexPages.currentPage().getParameters().get('srcTxnId');

        if (String.isNotBlank(srcTxnId)) {
            eventCreateObject.SourceTransactionID_gne__c = srcTxnId;
            eventCreateObject.TransactionID_gne__c = srcTxnId.indexOf('~') > 0 ?
                    srcTxnId.substring(0, srcTxnId.indexOf('~')) : srcTxnId;
        }
        // AGGSPENDME-196: end of URL parameter handler
        creatorNameOfEventFromBatch = null;
        return null;
    }

    /** @date 2/21/2013
    * @Author Pawel Sprysak
    * @description Method for showing Create Event form, after selecting Event Type // TODO: remove
    * @return PageReference
    */
    public PageReference selectEvent() {
        eventCreateObject = new VDST_Event_gne__c(CurrentStatus_gne__c = 'PENDING', CurrentStatusDate_gne__c = Date.today());
        ttlPlanAttCnt = 0;
        venueObject = new VDST_Address_gne__c();
        siteObject = new VDST_EventSite_gne__c();
        if (commonUtils.isNonResearchEvent) {
            venueObject.AddressType_gne__c = 'Virtual';
            venueObject.City_gne__c = 'South San Francisco';
            venueObject.Country_gne__c = 'USA';
            venueObject.PostalCode_gne__c = '94080';
            venueObject.StateProvince_gne__c = 'CA';
            venueObject.StreetAddress_gne__c = '1 DNA Way';
            siteObject.EventSiteName_gne__c = 'Virtual';
        }
        eventCreateStep = 2;
        return null;
    }

    /** @date 2/5/2014
    * @Author Pawel Sprysak
    * @description Preparing event data
    */
    public void prepareEventData() {
        onEventTypeSet();
        statusFieldMap = VDST_Utils.setStatusFieldsMap(commonUtils.eventType);
        if (statusFieldMap.containsKey('AttMealStatus') && statusFieldMap.get('AttMealStatus').containsKey('MealStatus')) {
            showMealStatus = statusFieldMap.get('AttMealStatus').get('MealStatus').IsVisible_gne__c;
        }
        prtcpntFieldMap = VDST_Utils.setPrtcpntRoleFieldsMap(commonUtils.eventType);
        setActualStatusMap();
    }

    /** @date 28/10/2013
    * @Author Konrad Malinowski
    * @description Method valid Event Type
    */
    public Boolean isValidEventType() {
        if (String.isBlank(commonUtils.eventType)) {
            return false;
        }
        commonUtils.eventType = commonUtils.eventType.trim().toUpperCase();
        for (SelectOption so : VDST_Utils.getPickListValues(VDST_Event_gne__c.EventType_gne__c.getDescribe())) {
            if (so.getValue().toUpperCase() == commonUtils.eventType) {
                return true;
            }
        }
        return false;
    }

    /** @date 7/4/2014
    * @Author Konrad Malinowski
    * @description Method creating and setting properties for ParticipantsValidationInput
    */
    public void setPrtcpntValidObj() {
        prtcpntValidObj = new VDST_Validator.ParticipantsValidationInput();
        prtcpntValidObj.eventCreateObject = eventCreateObject;
        prtcpntValidObj.venueObject = venueObject;
        prtcpntValidObj.siteObject = siteObject;
        prtcpntValidObj.prtcpntFieldMap = prtcpntFieldMap;
    }

    /** @date 5/10/2013
    * @Author Pawel Sprysak
    * @description Method creating and setting properties for Participant Utils
    */
    public void setPrtcpntUtils() {
        prtcpntUtils = new VDST_EventDetailPrtcpntUtils(editId);
        prtcpntUtils.commonUtils = commonUtils;
        prtcpntUtils.privileges = privileges;
        prtcpntUtils.itemAmount = eventCreateObject.ItemAmount_gne__c;
        prtcpntUtils.prtcpntValidObj = prtcpntValidObj;
        if (evDateTransObjList != null && evDateTransObjList.size() > 0) {
            prtcpntUtils.eventDates = evDateTransObjList.size();
        } else {
            prtcpntUtils.eventDates = 0;
        }
    }

    /** @date 4/6/2013
    * @Author Pawel Sprysak
    * @description Method for clearing messages
    */
    public void clearMessages() {
        editActionMessages = '';
        editErrorMessages = '';
    }

    /** @date 3/13/2013
    * @Author Pawel Sprysak
    * @description VF Method for redirecting to Event List
    * @return PageReference
    */
    public PageReference goToListPage() {
        PageReference pr = new PageReference('/apex/VDST_EventList');
        pr.setRedirect(true);
        return pr;
    }

    /** @date 4/3/2013
    * @Author Pawel Sprysak
    * @description Method invoked when Event Type is known
    */
    public void onEventTypeSet() {
        setVendorCodes();
        setSummaryMap();
    }

    /** @date 4/3/2013
    * @Author Pawel Sprysak
    * @description Method for setting values to Vendor Codes Select Options and JS mapping
    */
    public void setVendorCodes() {
        vendorCodeList = new List<SelectOption>{
                new SelectOption('', '-Select-')
        };
        vendorCodeMappingList = new List<VDST_EventProvider_gne__c>();
        actualContentVen = new VDST_EventProvider_gne__c();
        for (VDST_EventProvider_gne__c ep : VDST_Utils.getVendorCodeMappings()) {
            vendorCodeList.add(new SelectOption(ep.Id, ep.VendorCode_gne__c));
            vendorCodeMappingList.add(ep);
            if (eventCreateObject.ContentVendor_gne__c == ep.Id) {
                actualContentVen.VendorCode_gne__c = ep.VendorCode_gne__c;
                actualContentVen.VendorName_gne__c = ep.VendorName_gne__c;
            }
        }
    }

    /** @date 4/3/2013
    * @Author Pawel Sprysak
    * @description Method for setting Map with Transaction Summary values
    */
    public void setSummaryMap() {
        totalSpendMap = new Map<String, VDST_EventField_gne__c>();
        for (VDST_EventField_gne__c ef : VDST_Utils.getTransCodesFromEvField(commonUtils.eventType)) {
            totalSpendMap.put(ef.FieldName_gne__c, ef);
        }
        if (eventCreateObject.Id != null) {
            for (VDST_EventTransactionSummary_gne__c ets : VDST_Utils.getEvTransSummaryByEventId(eventCreateObject.Id)) {
                if (totalSpendMap.containsKey(ets.EventTransactionTypeCode_gne__c)) {
                    totalSpendMap.get(ets.EventTransactionTypeCode_gne__c).DefaultValue_gne__c = String.valueOf(ets.EventTransactionAmount_gne__c);
                }
            }
        }
    }

    /** @date 6/20/2013
    * @Author Pawel Sprysak
    * @description Get already occurred flag
    * @reuturn Boolean
    */
    public Boolean getIsAlreadyOccurred() {
        if (Date.today().isSameDay(eventCreateObject.EventEndDate_gne__c) || eventCreateObject.EventEndDate_gne__c < Date.today()) {
            return true;
        } else {
            return false;
        }
    }

    /** @date 5/21/2013
    * @Author Pawel Sprysak
    * @description Get Event Type Label
    * @reuturn String
    */
    public String getEventTypeLabel() {
        return commonUtils.getLabel(commonUtils.eventType);
    }

    /** @date 5/21/2013
    * @Author Pawel Sprysak
    * @description Get Function Label
    * @reuturn String
    */
    public String getCurrentStatusLabel() {
        return commonUtils.getLabel(eventCreateObject.CurrentStatus_gne__c);
    }

    /** @date 5/21/2013
    * @Author Pawel Sprysak
    * @description Get Function Label
    * @reuturn String
    */
    public String getFunctionLabel() {
        return commonUtils.getLabel(eventCreateObject.Function_gne__c);
    }

    /** @date 10/28/2013
    * @Author Pawel Sprysak
    * @description Get Supplement Label
    * @reuturn String
    */
    public String getSupplementStatusLabel() {
        return commonUtils.getLabel(eventCreateObject.SupplementStatusCode_gne__c);
    }

    /** @date 5/22/2013
    * @Author Pawel Sprysak
    * @description Get Venue State Label
    * @reuturn String
    */
    public String getVenueStateLabel() {
        String returnValue = '';
        if (!String.isBlank(venueObject.Country_gne__c) && 'USA'.equals(venueObject.Country_gne__c)) {
            returnValue = VDST_Utils.getStatesMap().get(venueObject.StateProvince_gne__c);
        }
        if (!String.isBlank(venueObject.StatesNameHolder_gne__c) && String.isBlank(returnValue)) {
            returnValue = venueObject.StatesNameHolder_gne__c;
        }
        return returnValue;
    }

    /** @date 5/22/2013
    * @Author Pawel Sprysak
    * @description Get Venue State Label
    * @reuturn String
    */
    public String getVenueCountryLabel() {
        return commonUtils.getLabel(venueObject.Country_gne__c);
    }

    /** @date 4/3/2013
    * @Author Pawel Sprysak
    * @description Method for getting values from Summary Transaction Map
    * @return List<VDST_EventField_gne__c>
    */
    public List<VDST_EventField_gne__c> getSummaryTransactions() {
        if (totalSpendMap != null) {
            List<VDST_EventField_gne__c> result = new List<VDST_EventField_gne__c>();
            // Srting - Spend Total should be last one
            VDST_EventField_gne__c efSpendTotal;
            for (VDST_EventField_gne__c ef : totalSpendMap.values()) {
                if (TOTAL_SPEND_CONST.equals(ef.FieldLabel_gne__c)) {
                    efSpendTotal = ef;
                } else {
                    result.add(ef);
                }
            }
            result.sort();
            result.add(efSpendTotal); // Now it will be last one
            return result;
        } else {
            return new List<VDST_EventField_gne__c>();
        }
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Event Types
    * @return List<SelectOption>
    */
    public List<SelectOption> getEventTypes() {
        List<SelectOption> optionList = new List<SelectOption>();
        List<SelectOption> tmpList = VDST_Utils.getMappedSelectOption(VDST_Event_gne__c.EventType_gne__c.getDescribe(), commonUtils.mappingMap);
        for (SelectOption tmp : tmpList) {
            optionList.add(tmp);
        }
        optionList.sort();
        return optionList;
    }

    /** @date 5/21/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Functions
    * @return List<SelectOption>
    */
    public List<SelectOption> getFunctions() {
        List<SelectOption> optionList = new List<SelectOption>{
                new SelectOption('', '-Select-')
        };
        optionList.addAll(VDST_Utils.getMappedSelectOption(VDST_Event_gne__c.Function_gne__c.getDescribe(), commonUtils.mappingMap));
        optionList.sort();
        return optionList;
    }

    public List<SelectOption> getMealLocations() {
        List<SelectOption> optionList = new List<SelectOption>{
                new SelectOption('', '-Select-')
        };
        optionList.addAll(VDST_Utils.getMappedSelectOption(VDST_Event_gne__c.MealLoc_gne__c.getDescribe(), commonUtils.mappingMap));
        optionList.sort();
        return optionList;
    }

    /** @date 5/17/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Consumption Status
    * @return List<SelectOption>
    */
    public List<SelectOption> getConsumptionStatus() {
        List<SelectOption> optionList = VDST_Utils.getMappedSelectOption(VDST_EventPrtcpntAttendance_gne__c.ParticipantMealConsumptionStatus_gne__c.getDescribe(), commonUtils.mappingMap);
        return VDST_Utils.selectOptionSortByLabel(optionList);
    }

    /** @date 5/17/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Source Expense Types
    * @return List<SelectOption>
    */
    public List<SelectOption> getSourceExpenseTypes() {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('', '-Select-'));
        optionList.add(new SelectOption('Charitable Contributions', 'Charitable Contributions'));
        optionList.add(new SelectOption('Consulting Fee', 'Consulting Fee'));
        optionList.add(new SelectOption('Facility Fee', 'Facility Fee'));
        optionList.add(new SelectOption('Food', 'Food'));
        optionList.add(new SelectOption('Grant', 'Grant'));
        optionList.add(new SelectOption('Non-Consulting Compensation', 'Non-Consulting Compensation'));
        optionList.add(new SelectOption('Non-Accredited Ed.', 'Non-Accredited Ed.'));
        optionList.add(new SelectOption('OOP Travel', 'OOP Travel'));
        optionList.add(new SelectOption('OOP Lodging', 'OOP Lodging'));
        optionList.add(new SelectOption('OOP Meals', 'OOP Meals'));
        optionList.add(new SelectOption('OOP Other', 'OOP Other'));
        optionList.add(new SelectOption('Royalty/License Fee', 'Royalty/License Fee'));
        optionList.add(new SelectOption('Unknown Expense Type', 'Unknown Expense Type'));
        return optionList;
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Countries
    * @return List<SelectOption>
    */
    public List<SelectOption> getCountries() {
        List<SelectOption> result = new List<SelectOption>{
                new SelectOption('', '-Select-')
        };
        result.addAll(VDST_Utils.getSortedSOListByLabel(VDST_Utils.getMappedSelectOption(VDST_Address_gne__c.Country_gne__c.getDescribe(), commonUtils.mappingMap)));
        return result;
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting States
    * @return List<SelectOption>
    */
    public List<SelectOption> getStates() {
        return VDST_Utils.getStatesNames();
    }


    /** @date 28/10/2013
    * @Author Konrad Malinowski
    * @description Method for VF - getting Research Payment Types
    * @return List<SelectOption>
    */
    public List<SelectOption> getResearchPaymentTypes() {
        List<SelectOption> result = new List<SelectOption>{
                new SelectOption('', '-Select-'),
                new SelectOption('PRECLINICAL', 'Pre-Clinical'),
                new SelectOption('CLINICAL', 'Clinical')
        };
        return result;
    }

    /** @date 31/10/2013
    * @Author Konrad Malinowski
    * @description Method for VF - getting Research Payment Types Map Code To Name
    * @return Map<String, String>
    */
    public Map<String, String> getResearchPaymentTypesMap() {
        Map<String, String> researchPaymentTypesCodeToNameMap = new Map<String, String>();
        List<SelectOption> selOpts = getResearchPaymentTypes();
        for (SelectOption so : selOpts) {
            researchPaymentTypesCodeToNameMap.put(so.getValue(), so.getLabel());
        }
        researchPaymentTypesCodeToNameMap.put('', '');
        researchPaymentTypesCodeToNameMap.put(null, '');
        return researchPaymentTypesCodeToNameMap;
    }

    /** @date 28/10/2013
    * @Author Konrad Malinowski
    * @description Method for VF - getting Trial Statuses
    * @return List<SelectOption>
    */
    public List<SelectOption> getTrialStatus() {
        List<SelectOption> result = new List<SelectOption>{
                new SelectOption('', '-Select-'),
                new SelectOption('ACTIVE', 'ACTIVE'),
                new SelectOption('CANCELLED', 'CANCELLED'),
                new SelectOption('CLINICAL CLOSURE', 'CLINICAL CLOSURE'),
                new SelectOption('FOLLOW UP', 'FOLLOW UP'),
                new SelectOption('MANAGEMENT APPROVED', 'MANAGEMENT APPROVED'),
                new SelectOption('PREMATURELY TERMINATED', 'PREMATURELY TERMINATED'),
                new SelectOption('SIGNED PROTOCOL', 'SIGNED PROTOCOL')
        };
        return result;
    }

    /** @date 9/19/2014
    * @Author Konrad Malinowski
    * @description Method for getting Delayed Payment Indicators
    * @return List<SelectOption>
    */
    public static List<SelectOption> getDelayedPaymentIndicators() {
        List<SelectOption> result = new List<SelectOption>{
                new SelectOption('', '-Select-')
        };
        result.addAll(
                VDST_Utils.getPickListValues(
                        AGS_Spend_Expense_Transaction_gne__c.Delayed_Reporting_Code_gne__c.getDescribe()
                )
        );
        return result;
    }

    /** @date 4/23/2015
    * @Author Konrad Malinowski
    * @description Method for getting Numbers Of Meals
    * @return List<SelectOption>
    */
    public static List<SelectOption> getNumbersOfMeals() {
        List<SelectOption> result = new List<SelectOption>{
                new SelectOption('', '-Select-')
        };
        result.addAll(
                VDST_Utils.getPickListValues(
                        VDST_EventDateTransaction_gne__c.NumberOfMeals_gne__c.getDescribe()
                )
        );
        return result;
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description Method for VF - setting Status History List for event
    * @return PageReference
    */
    public PageReference setStatusHistory() {
        List<VDST_Event_gne__History> shList = VDST_Utils.getEventHistoryByEventId(eventCreateObject.Id);
        statusHistoryList = new List<EventHistoryWrapper>();
        for (VDST_Event_gne__History sh : shList) {
            statusHistoryList.add(new EventHistoryWrapper(sh, commonUtils));
        }
        checkIfEventIsCreatedFromBigBatch();
        return null;
    }

    /** @date 4/14/2015
    * @Author Konrad Malinowski
    * @description Method for checking if Event is created from Big Batch
    */
    private void checkIfEventIsCreatedFromBigBatch() {
        VDST_Event_gne__c event = [
                SELECT IsBatch_gne__c, VDST_BatchFile_gne__r.Id,
                        VDST_BatchFile_gne__r.ProcessStartDate_gne__c, VDST_BatchFile_gne__r.ProcessEndDate_gne__c,
                        VDST_BatchFile_gne__r.BatchFileSaver_gne__r.Name, VDST_BatchFile_gne__r.CreatedBy.Name
                FROM VDST_Event_gne__c
                WHERE Id = :eventCreateObject.Id
        ];
        if (
                event.IsBatch_gne__c && event.VDST_BatchFile_gne__r.Id != null &&
                        event.VDST_BatchFile_gne__r.ProcessStartDate_gne__c != event.VDST_BatchFile_gne__r.ProcessEndDate_gne__c
        ) {
            String creator = event.VDST_BatchFile_gne__r.BatchFileSaver_gne__r.Name;
            creatorNameOfEventFromBatch = (creator != null ? creator : event.VDST_BatchFile_gne__r.CreatedBy.Name);
        } else {
            creatorNameOfEventFromBatch = null;
        }
    }

    /** @date 2/21/2013
    * @Author Pawel Sprysak
    * @description Method for showing Brand List
    * @return PageReference
    */
    public PageReference selectBrands() {
        eventCreateStep = 3;
        return null;
    }

    /** @date 2/21/2013
    * @Author Pawel Sprysak
    * @description VF Method for setting Drug Names
    * @return PageReference
    */
    public PageReference setBrands() {
        eventCreateStep = 2;
        setBrandValues();
        changeDrugName = true;

        return null;
    }

    /** @date 5/7/2013
    * @Author Pawel Sprysak
    * @description VF Method for canceling Drug Name Select
    * @return PageReference
    */
    public PageReference cancelBrands() {
        eventCreateStep = 2;
        return null;
    }

    /** @date 2/21/2013
    * @Author Pawel Sprysak
    * @description Method for setting Drug Name values
    * @return PageReference
    */
    public void setBrandValues() {
        newDrugNames = '';
        for (String newDrugName : multiDrugNames) {
            for (SelectOption so : drugNames) {
                if (so.getValue() == newDrugName) {
                    if (newDrugNames.equals('')) {
                        newDrugNames = so.getLabel();
                    } else {
                        newDrugNames += ', ' + so.getLabel();
                    }
                }
            }
        }
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description VF Method for saving Event
    * @return PageReference
    */
    public PageReference onlySaveEvent() {
        saveEvent();
        editableMode = true;
        eventCreateStep = 2;
        return null;
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description VF Method for saving Event
    * @return PageReference
    */
    public PageReference saveAndCloseEvent() {
        saveEvent();
        eventCreateStep = 2;
        return null;
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description VF Method for saving and closing Event
    * @return PageReference
    */
    public PageReference saveEvent() {
        clearMessages();
        trimEventFieldValues();
        if ('OCCURRED'.equalsIgnoreCase(eventCreateObject.CurrentStatus_gne__c)) {
            String status = (commonUtils.isSSEvent || commonUtils.isResearchEvent || commonUtils.isNonResearchEvent ? 'CLOSED' : 'OCCURRED');
            Boolean isValidationEventSuccess = validateEventOnStatusChange(status);
            Boolean isValidationParticipantsSuccess = validateParticipantsOnStatusChange(status);
            if (!isValidationEventSuccess || !isValidationParticipantsSuccess) {
                return null;
            }
        }
        if (showPlannedFldEditable) {
            ttlPlanAttCnt = eventCreateObject.TotPlanAttCntUser_gne__c;
        }
        Savepoint sp = Database.setSavepoint();
        if (commonUtils.isSSEvent) {
            eventCreateObject.EventMeetingName_gne__c = eventCreateObject.ItemName_gne__c;
        }
        if (!commonUtils.isStdEvent) {
            eventCreateObject.EventEndDate_gne__c = eventCreateObject.EventStartDate_gne__c;
        }
        if (appState.equals('Edit')) {
            try {
                if (evDateTransObjList.size() > 0) {
                    for (VDST_EventDateTransaction_gne__c edt : evDateTransObjList) {
                        for (VDST_Utils.EventDateTransactions edtWrap : evDateTransList) {
                            Datetime dt = edt.VDST_EventDate_gne__r.EventDate_gne__c;
                            if (dt.formatGmt('MMM dd, yyyy').equals(edtWrap.eventDate) && edt.EventDateTransactionTypeCode_gne__c.equals(edtWrap.eventType)) {
                                try {
                                    edt.EventDateTransactionAmount_gne__c = Decimal.valueOf(edtWrap.inputTotalFaB);
                                } catch (TypeException te) {
                                    edt.EventDateTransactionAmount_gne__c = 0.0;
                                    edtWrap.inputTotalFaB = '0.00';
                                }
                                edt.NumberOfMeals_gne__c = edtWrap.numberOfMeals;
                                break;
                            }
                        }
                    }
                    update evDateTransObjList;
                }
                if (eventCreateObject.VendorEventID_gne__c != null) {
                    eventCreateObject.VendorEventID_gne__c = eventCreateObject.VendorEventID_gne__c.toUpperCase();
                }
                update eventCreateObject;
                venueObject.VDST_Event_gne__c = eventCreateObject.Id;
                if (venueObject.PostalCode_gne__c != null) {
                    venueObject.PostalCode_gne__c = venueObject.PostalCode_gne__c.toUpperCase();
                }
                update venueObject;
                update siteObject;
                insertBrandTopic();
                if (commonUtils.isNonResearchEvent) {
                    commonUtils.nonResTransaction.setItemAmount(eventCreateObject.ItemAmount_gne__c);
                    commonUtils.nonResTransaction.sourceExpType = eventCreateObject.ItemCode_gne__c;
                }
                editActionMessages = 'Event Saved successfully';
            } catch (QueryException e) {
                log.logException('saveEvent', e);
                editErrorMessages = 'Error while updating event';
                Database.rollback(sp);
                return null;
            } catch (DmlException dml) {
                log.logException('saveEvent', dml);
                if (dml.getMessage().contains('earlier')) {
                    editErrorMessages = 'Update failed. Event Start Date must be earlier than Event End Date';
                } else if (dml.getMessage().contains('could')) {
                    editErrorMessages = 'Update failed. Event End Date could be max 4 days after Event Start Date';
                } else if (dml.getMessage().contains('VendorEventID_gne__c duplicates')) {
                    editErrorMessages = 'Update failed. Vendor Event Id value must be unique';
                } else if (dml.getMessage().contains('GNE_EventID_gne__c duplicates')) {
                    editErrorMessages = 'An Event with this Genentech Event ID currently exists. Genentech Event ID field must be unique.';
                } else {
                    editErrorMessages = dml.getMessage();
                }
                Database.rollback(sp);
                return null;
            }
        } else {
            try {
                if (commonUtils.isSSEvent || commonUtils.isResearchEvent) {
                    // Address data
                    venueObject.AddressType_gne__c = 'Virtual';
                    venueObject.City_gne__c = 'South San Francisco';
                    venueObject.Country_gne__c = 'USA';
                    venueObject.PostalCode_gne__c = '94080';
                    venueObject.StateProvince_gne__c = 'CA';
                    venueObject.StreetAddress_gne__c = '1 DNA Way';
                    siteObject.EventSiteName_gne__c = 'Virtual';
                    venueObject.StatesNameHolder_gne__c = null;
                    venueObject.StreetAddress2_gne__c = null;
                }
                if (commonUtils.isSSEvent || commonUtils.isNonResearchEvent) {
                    eventCreateObject.ResearchPaymentTypeCode_gne__c = 'NON-CLINICAL';
                }
                eventCreateObject.EventType_gne__c = commonUtils.eventType;
                eventCreateObject.isBatch_gne__c = false;
                eventCreateObject.CurrentStatus_gne__c = 'PENDING';
                eventCreateObject.CurrentStatusDate_gne__c = Date.today();
                eventCreateObject.LogisticVendor_gne__c = privileges.providerId;
                if (eventCreateObject.VendorEventID_gne__c != null) {
                    eventCreateObject.VendorEventID_gne__c = eventCreateObject.VendorEventID_gne__c.toUpperCase();
                }
                insert eventCreateObject;
                venueObject.VDST_Event_gne__c = eventCreateObject.Id;
                if (venueObject.PostalCode_gne__c != null) {
                    venueObject.PostalCode_gne__c = venueObject.PostalCode_gne__c.toUpperCase();
                }
                insert venueObject;
                siteObject.VDST_Event_gne__c = eventCreateObject.Id;
                siteObject.VDST_Address_gne__c = venueObject.Id;
                insert siteObject;
                insertBrandTopic();
                editId = eventCreateObject.Id;
                insertSupplementedParticipants();
                if (commonUtils.isNonResearchEvent) {
                    commonUtils.nonResTransaction = new VDST_EventDetailCommon.NonResearchPayments(editId, eventCreateObject.ItemAmount_gne__c, commonUtils.eventType, eventCreateObject.ItemCode_gne__c);
                    commonUtils.nonResTransaction.setItemAmount(eventCreateObject.ItemAmount_gne__c);
                    commonUtils.nonResTransaction.sourceExpType = eventCreateObject.ItemCode_gne__c;
                }
                appState = 'Edit';
                editActionMessages = 'Event Created successfully';
            } catch (QueryException e) {
                log.logException('saveEvent', e);
                editErrorMessages = 'Error while creating event';
                Database.rollback(sp);
                return null;
            } catch (DmlException dml) {
                if (dml.getMessage().contains('earlier')) {
                    editErrorMessages = 'Create failed. Event Start Date must be earlier than EventEndDate.';
                } else if (dml.getMessage().contains('could')) {
                    editErrorMessages = 'Create failed. Event End Date could be max 4 days after EventStartDate.';
                } else if (dml.getMessage().contains('VendorEventID_gne__c duplicates')) {
                    editErrorMessages = 'Create failed. Vendor Event Id value must be unique.';
                } else if (dml.getMessage().contains('GNE_EventID_gne__c duplicates')) {
                    editErrorMessages = 'An Event with this Genentech Event ID currently exists. Genentech Event ID field must be unique.';
                } else {
                    editErrorMessages = dml.getMessage();
                }
                log.logException('saveEvent', dml);
                Database.rollback(sp);
                return null;
            }
        }
        updateLastModifiedDate();
        editableMode = false;
        setDataEventTransactionData();
        setPrtcpntUtils();
        for (VDST_EventProvider_gne__c ep : vendorCodeMappingList) {
            if (eventCreateObject.ContentVendor_gne__c == ep.Id) {
                actualContentVen.VendorCode_gne__c = ep.VendorCode_gne__c;
                actualContentVen.VendorName_gne__c = ep.VendorName_gne__c;
                break;
            }
        }
        setSummaryMap();
        return null;
    }

    /** @date 6/24/2014
    * @Author Konrad Malinowski
    * @description Trim Event field values
    */
    public void trimEventFieldValues() {
        if (eventCreateObject != null) {
            eventCreateObject.VendorEventID_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.VendorEventID_gne__c);
            eventCreateObject.AccountableGNE_UnixID_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.AccountableGNE_UnixID_gne__c);
            eventCreateObject.Comment_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.Comment_gne__c);
            eventCreateObject.GNE_EventID_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.GNE_EventID_gne__c);
            eventCreateObject.EventMeetingName_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.EventMeetingName_gne__c);
            //eventCreateObject.OtherIDs_gne__c               = VDST_Utils.getTrimValFromStr(eventCreateObject.OtherIDs_gne__c); //Deprecated
            eventCreateObject.StudyDescription_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.StudyDescription_gne__c);
            eventCreateObject.ThemeNumber_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.ThemeNumber_gne__c);
            eventCreateObject.ProtocolID_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.ProtocolID_gne__c);
            eventCreateObject.ItemName_gne__c = VDST_Utils.getTrimValFromStr(eventCreateObject.ItemName_gne__c);
        }
        if (siteObject != null) {
            siteObject.EventSiteName_gne__c = VDST_Utils.getTrimValFromStr(siteObject.EventSiteName_gne__c);
        }
        if (venueObject != null) {
            venueObject.StreetAddress_gne__c = VDST_Utils.getTrimValFromStr(venueObject.StreetAddress_gne__c);
            venueObject.City_gne__c = VDST_Utils.getTrimValFromStr(venueObject.City_gne__c);
            venueObject.StatesNameHolder_gne__c = VDST_Utils.getTrimValFromStr(venueObject.StatesNameHolder_gne__c);
            venueObject.StateProvince_gne__c = VDST_Utils.getTrimValFromStr(venueObject.StateProvince_gne__c);
            venueObject.PostalCode_gne__c = VDST_Utils.getTrimValFromStr(venueObject.PostalCode_gne__c);
        }
    }

    /** @date 6/12/2013
    * @Author Pawel Sprysak
    * @description Update Event Last Modified Date
    */
    public void updateLastModifiedDate() {
        eventInfoKeeper = VDST_Utils.getEventInfo(eventCreateObject.Id);
    }

    /** @date 2/26/2013
    * @Author Pawel Sprysak
    * @description Method for inserting Brands
    * @return PageReference
    */
    public void insertBrandTopic() {
        if (multiDrugNames.size() > 0 && (appState.equals('Create') || changeDrugName == true)) {
            // Create maps by Product Catalog Id
            Map<String, VDST_EventBrandTopic_gne__c> brandMapToDelete = new Map<String, VDST_EventBrandTopic_gne__c>();
            Map<String, VDST_EventBrandTopic_gne__c> brandMapToInsert = new Map<String, VDST_EventBrandTopic_gne__c>();
            for (VDST_EventBrandTopic_gne__c ebt : VDST_Utils.getBrandTopicList(eventCreateObject.Id)) {
                brandMapToDelete.put(ebt.Product_Catalog_gne__c, ebt);
            }
            // Check is there any need to create new Brand and delete unused Brands
            Integer counter = 0;
            for (String brandId : multiDrugNames) {
                if (brandMapToDelete.containsKey(brandId)) {
                    brandMapToDelete.remove(brandId);
                    counter++;
                } else {
                    brandMapToInsert.put(brandId, new VDST_EventBrandTopic_gne__c(VDST_Event_gne__c = eventCreateObject.Id, Product_Catalog_gne__c = (Id) brandId));
                }
            }
            if (brandMapToDelete.values().size() > 0) {
                delete brandMapToDelete.values();
            }
            // Insert new Brands
            List<VDST_EventBrandTopic_gne__c> brandListToIns = new List<VDST_EventBrandTopic_gne__c>();
            for (VDST_EventBrandTopic_gne__c ebt : brandMapToInsert.values()) {
                if (counter < 5) {
                    brandListToIns.add(ebt);
                    counter++;
                }
            }
            insert brandListToIns;
            changeDrugName = false;
        }
    }

    /** @date 10/31/2013
    * @Author Pawel Sprysak
    * @description Inserting supplemented Participants
    * @return PageReference
    */
    public PageReference insertSupplementedParticipants() {
        if ('SUPPLMT'.equals(eventCreateObject.SupplementStatusCode_gne__c)) {
            VDST_SuplementData.SuplementedParticipants sp = VDST_SuplementData.getSuplementedParticipants(eventCreateObject.TransactionID_gne__c, commonUtils.eventType);
            if (sp.status) {
                List<VDST_EventPrtcpntRole_gne__c> role = VDST_Utils.getVendorCodeList(commonUtils.eventType);
                if (sp.directParticipant != null) {
                    setParticipantData(sp.directParticipant, role);
                    ttlPlanAttCnt++;
                }
                if (sp.indirectParticipant != null) {
                    setParticipantData(sp.indirectParticipant, role);
                    ttlPlanAttCnt++;
                }
            }
        }
        return null;
    }

    /** @date 10/31/2013
    * @Author Pawel Sprysak
    * @description Method for setting data for Participants
    * @return PageReference
    */
    public void setParticipantData(VDST_SuplementData.Participant sp, List<VDST_EventPrtcpntRole_gne__c> roleList) {
        String partyType = 'INDV';
        if (!String.isBlank(sp.LegalName)) {
            partyType = 'ORG';
        }
        Id prtcpntRole;
        for (VDST_EventPrtcpntRole_gne__c role : roleList) {
            if (role.EventParticipantRoleName__c.equals(sp.ParticipantRole) && (!commonUtils.isNonResearchEvent || (role.EventParticipantRoleCode_gne__c.equals('PAYEE') && 'INDV'.equals(partyType)) || (role.EventParticipantRoleCode_gne__c.equals('ORG') && 'ORG'.equals(partyType)))) {
                prtcpntRole = role.Id;
            }
        }
        String stateValue = sp.StateProvince;
        if (!String.isBlank(stateValue) && VDST_Utils.getInverseStatesMap().get(stateValue.toLowerCase()) != null) {
            stateValue = VDST_Utils.getInverseStatesMap().get(stateValue.toLowerCase());
        }
        VDST_Address_gne__c addressData = new VDST_Address_gne__c(
                City_gne__c = sp.City,
                Country_gne__c = sp.Country,
                PostalCode_gne__c = sp.PostalCode,
                StateProvince_gne__c = stateValue,
                StreetAddress_gne__c = sp.StreetAddress,
                StreetAddress2_gne__c = sp.StreetAddress2,
                AddressType_gne__c = 'Physical'
        );
        VDST_EventPrtcpntAccnt_gne__c prtcpntData = new VDST_EventPrtcpntAccnt_gne__c(
                Credential_gne__c = sp.Credential,
                FirstName_gne__c = sp.FirstName,
                isBatch_gne__c = false,
                LastName_gne__c = sp.LastName,
                LegalName_gne__c = sp.LegalName,
                LicenseNumber_gne__c = sp.LicenseNumber,
                LicenseState_gne__c = sp.LicenseState,
                MDMID_gne__c = sp.MDMID,
                NPI_gne__c = sp.NPI,
                ParticipantContractStatus_gne__c = 'CNTRCTD',
                TIN_gne__c = sp.TIN,
                ParticipantAffiliation_gne__c = 'N/A',
                PartyType_gne__c = partyType,
                EventParticipantRole_gne__c = prtcpntRole
        );
        createSupplementedParticipants(prtcpntData, addressData);
    }

    /** @date 10/31/2013
    * @Author Pawel Sprysak
    * @description Inserting supplemented Participants
    * @return PageReference
    */
    public void createSupplementedParticipants(VDST_EventPrtcpntAccnt_gne__c prtcpntData, VDST_Address_gne__c addressData) {
        try {
            // Participant
            addressData.VDST_Event_gne__c = (Id) editId;
            if (addressData.PostalCode_gne__c != null) {
                addressData.PostalCode_gne__c = addressData.PostalCode_gne__c.toUpperCase();
            }
            insert addressData;
            prtcpntData.VDST_Address_gne__c = addressData.Id;
            prtcpntData.VDST_Event_gne__c = (Id) editId;
            if (prtcpntData.VendorParticipantID_gne__c != null) {
                prtcpntData.VendorParticipantID_gne__c = prtcpntData.VendorParticipantID_gne__c.toUpperCase();
            }
            insert prtcpntData;
            if (commonUtils.isResearchEvent) {
                VDST_EventPrtcpntAccnt_gne__c evPrtcpnt = [SELECT ParticipantRole_gne__c, VDST_Event_gne__r.ItemAmount_gne__c, VDST_Event_gne__r.ResearchPaymentTypeCode_gne__c FROM VDST_EventPrtcpntAccnt_gne__c WHERE Id = :prtcpntData.Id LIMIT 1];
                List<VDST_PrtcpntTransaction_gne__c> exTransactions = [SELECT Id, VDST_PaidToParty_gne__c, VDST_EventPrtcpntAccnt_gne__c FROM VDST_PrtcpntTransaction_gne__c WHERE VDST_EventPrtcpntAccnt_gne__r.VDST_Event_gne__c = :(Id) editId LIMIT 1];
                VDST_PrtcpntTransaction_gne__c newTransaction = new VDST_PrtcpntTransaction_gne__c(
                        VDST_EventPrtcpntAccnt_gne__c = prtcpntData.Id,
                        FeePayToPartyType_gne__c = prtcpntData.PartyType_gne__c,
                        TransactionAmount_gne__c = evPrtcpnt.VDST_Event_gne__r.ItemAmount_gne__c,
                        TransactionLevel_gne__c = 'INDV'
                );
                if ('PI'.equals(evPrtcpnt.ParticipantRole_gne__c)) {
                    newTransaction.TransactionAllocationType_gne__c = 'INDIRECT';
                } else {
                    newTransaction.TransactionAllocationType_gne__c = 'DIRECT';
                }
                if ('PRECLINICAL'.equals(evPrtcpnt.VDST_Event_gne__r.ResearchPaymentTypeCode_gne__c)) {
                    newTransaction.TransactionTypeCode_gne__c = 'PRECLINCL';
                } else {
                    newTransaction.TransactionTypeCode_gne__c = 'RSCH';
                }
                if ('PI'.equals(evPrtcpnt.ParticipantRole_gne__c)) {
                    if (exTransactions.size() > 0) {
                        newTransaction.VDST_PaidToParty_gne__c = exTransactions.get(0).VDST_EventPrtcpntAccnt_gne__c;
                    }
                } else {
                    newTransaction.VDST_PaidToParty_gne__c = prtcpntData.Id;
                    if (exTransactions.size() > 0) {
                        exTransactions.get(0).VDST_PaidToParty_gne__c = prtcpntData.Id;
                    }
                }
                if (String.isNotBlank(eventCreateObject.Home_Payment_ID_gne__c)) {
                    newTransaction.Home_Payment_ID_flag_gne__c = true;
                }
                insert newTransaction;
                if (exTransactions.size() > 0) {
                    update exTransactions;
                }
            }
        } catch (QueryException e) {
            log.logException('createSupplementedParticipants', e);
            // ERROR
        }
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description VF Method for canceling Event
    * @return PageReference
    */
    public PageReference cancelEvent() {
        if (appState.equals('Edit')) {
            setEventToEdit();
            clearMessages();
        } else {
            return new PageReference('/apex/VDST_EventList');
        }
        return null;
    }

    /** @date 2/26/2013
    * @Author Pawel Sprysak
    * @description VF Method for changing Event to editable state
    * @return PageReference
    */
    public PageReference editEvent() {
        editableMode = true;
        clearMessages();
        return null;
    }

    /** @date 2/22/2013
    * @Author Pawel Sprysak
    * @description VF Method for showing edit event form
    * @return PageReference
    */
    public PageReference setEventToEdit() {
        eventCreateStep = 2;
        editableMode = false;
        appState = 'Edit';
        eventCreateObject = VDST_Utils.getEventById(editId);
        ttlPlanAttCnt = eventCreateObject.TotalPlannedAttendeeCount_gne__c;
        siteObject = VDST_Utils.getEventSiteByEventId(editId);
        if (siteObject != null) {
            venueObject = VDST_Utils.getAddressById(siteObject.VDST_Address_gne__c);
        } else {
            criticalError = true;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error. No site object associated with event.'));
        }
        multiDrugNames.clear();
        for (VDST_EventBrandTopic_gne__c topic : VDST_Utils.getBrandTopicList(editId)) {
            multiDrugNames.add(topic.Product_Catalog_gne__c);
        }
        setBrandValues();
        commonUtils.eventType = eventCreateObject.EventType_gne__c;
        setDataEventTransactionData();
        updateLastModifiedDate();
        return null;
    }

    /** @date 2/28/2013
    * @Author Pawel Sprysak
    * @description Method for setting data for Event Date Transactions
    * @return PageReference
    */
    public PageReference setDataEventTransactionData() {
        evDateTransObjList = VDST_Utils.getEventDateTransactions(editId);
        evDateTransList = VDST_Utils.convertEventDateTransactionsToWrapper(evDateTransObjList);
        return null;
    }

    /** @date 6/6/2013
    * @Author Pawel Sprysak
    * @description Method for updating Participant data for Event Date Transactions
    * @return PageReference
    */
    public PageReference updateDataEventTransactionData() {
        for (VDST_EventDateTransaction_gne__c edt : VDST_Utils.getEventDateTransactions(editId)) {
            for (VDST_Utils.EventDateTransactions oldEdt : evDateTransList) {
                Datetime dt = edt.VDST_EventDate_gne__r.EventDate_gne__c;
                if (oldEdt.eventDate.equals(dt.formatGmt('MMM dd, yyyy'))) {
                    oldEdt.attendeesCount = Integer.valueOf(edt.VDST_EventDate_gne__r.ActualAttendeeRollup_gne__c);
                    break;
                }
            }
        }
        return null;
    }

    /** @date 4/6/2013
    * @Author Pawel Sprysak
    * @description Method for refreshing transaction views
    * @return PageReference
    */
    public PageReference updateTransactionViews() {
        updateDataEventTransactionData();
        setSummaryMap();
        ttlPlanAttCnt = VDST_Utils.getTotalPlannedAttCount(eventCreateObject.Id);
        updateLastModifiedDate();
        prtcpntUtils.showParticipantList = false;
        return null;
    }

    /** @date 4/2/2013
    * @Author Pawel Sprysak
    * @description VF Methof - Open Participant List view
    * @return PageReference
    */
    public PageReference showParticipantList() {
        clearMessages();
        prtcpntUtils.prtcpntListMsg = '';
        prtcpntUtils.prtcpntListMsgErr = '';
        prtcpntUtils.showParticipantList = true;
        return null;
    }

    /** @date 3/15/2013
    * @Author Pawel Sprysak
    * @description Universal method for changing status
    * @param String statusVal (Status value)
    */
    private void setStatusMethod(String statusVal) {
        eventCreateObject.CurrentStatus_gne__c = statusVal;
        eventCreateObject.CurrentStatusDate_gne__c = Date.today();
        update eventCreateObject;
    }

    /** @date 3/15/2013
    * @Author Pawel Sprysak
    * @description Method for changing status to DROPPED
    * @return PageReference
    */
    public PageReference setStatusToDropped() {
        clearMessages();
        setStatusMethod('DROPPED');
        setActualStatusMap();
        return goToListPage();
    }

    /** @date 3/15/2013
    * @Author Pawel Sprysak
    * @description Method for changing status to CANCEL
    * @return PageReference
    */
    public PageReference setStatusToCanceled() {
        clearMessages();
        String status = 'CANCEL';
        Boolean isValidationEventSuccess = validateEventOnStatusChange(status);
        Boolean isValidationParticipantsSuccess = validateParticipantsOnStatusChange(status);
        if (isValidationEventSuccess && isValidationParticipantsSuccess) {
            setStatusMethod(status);
            setActualStatusMap();
        }
        return null;
    }

    /** @date 3/15/2013
    * @Author Pawel Sprysak
    * @description Method for changing status to OCCURRED
    * @return PageReference
    */
    public PageReference setStatusToOccurred() {
        clearMessages();
        String status = 'OCCURRED';
        Boolean isValidationEventSuccess = validateEventOnStatusChange(status);
        Boolean isValidationParticipantsSuccess = validateParticipantsOnStatusChange(status);
        if (isValidationEventSuccess && isValidationParticipantsSuccess) {
            setStatusMethod(status);
            setActualStatusMap();
        }
        return null;
    }

    /** @date 3/15/2013
    * @Author Pawel Sprysak
    * @description Method for changing status to CLOSED
    * @return PageReference
    */
    public PageReference setStatusToClosed() {
        try {
            clearMessages();
            String status = 'CLOSED';
            Boolean wasTransactionInvalidated = [SELECT COUNT() FROM VDST_Event_gne__c WHERE Id = :eventCreateObject.Id AND AGS_ST_Dispute_Management_gne__c != null AND AGS_ST_Dispute_Management_gne__c != ''] > 0 ? true : false;
            Boolean isValidationEventSuccess = validateEventOnStatusChange(status);
            Boolean isValidationParticipantsSuccess = validateParticipantsOnStatusChange(status);
            if (isValidationEventSuccess && isValidationParticipantsSuccess) {
                setStatusMethod(status);
                setActualStatusMap();
            }
            Boolean isTransactionInvalidated = [SELECT COUNT() FROM VDST_Event_gne__c WHERE Id = :eventCreateObject.Id AND AGS_ST_Dispute_Management_gne__c != null AND AGS_ST_Dispute_Management_gne__c != ''] > 0 ? true : false;
            invalidatedTransaction = isTransactionInvalidated && isTransactionInvalidated != wasTransactionInvalidated ? true : false;
        } catch (Exception ex) {
            log.logException('setStatusToClosed', ex);
            editErrorMessages = ex.getMessage() + ' .Transaction have not been invalidated';
        }
        return null;
    }

    /** @date 3/15/2013
    * @Author Pawel Sprysak
    * @description Method for changing status to Reopened
    * @return PageReference
    */
    public PageReference setStatusToReopened() {
        if (!privileges.isGene && !privileges.isProxy && commonUtils.cutoffDate != null &&
                (commonUtils.cutoffDate <= System.now() && eventCreateObject.EventStartDate_gne__c.year() < commonUtils.cutoffDate.year()
                || commonUtils.cutoffDate > System.now() && eventCreateObject.EventStartDate_gne__c.year() < commonUtils.cutoffDate.year() - 1)) {
            editErrorMessages = 'The event date falls outside the reporting cycle period. Please reach out to the Transparency & Aggregate Spend team at taggops-d@gene.com for further directives on how to proceed.';
        } else {
            clearMessages();
            if ('CLOSED'.equals(eventCreateObject.CurrentStatus_gne__c)) {
                setStatusMethod('OCCURRED');
            } else {
                setStatusMethod('PENDING');
            }
            setActualStatusMap();
            editableMode = true;
        }
        return null;
    }

    /** @date 3/21/2013
    * @Author Pawel Sprysak
    * @description Setting actual status map for visibility/required fields
    */
    public void setActualStatusMap() {
        if ('OCCURRED'.equals(eventCreateObject.CurrentStatus_gne__c) || commonUtils.isSSEvent || commonUtils.isResearchEvent || commonUtils.isNonResearchEvent) {
            actualMap = statusFieldMap.get('CLOSED');
        } else {
            actualMap = statusFieldMap.get('OCCURRED');
        }
    }

    /** @date 4/4/2013
    * @Author Pawel Sprysak
    * @description Internal method for returning First and Last Name in validation
    * @param String status (Value of checking status)
    * @return Boolean
    */
    private Boolean validateEventOnStatusChange(String status) {
        // Validate event data
        List<VDST_EventTransactionSummary_gne__c> etsSummary;
        if (commonUtils.isSSEvent || commonUtils.isNonResearchEvent || commonUtils.isResearchEvent) {
            etsSummary = VDST_Utils.getTotalSummaryTransactions(eventCreateObject.Id);
        }
        editErrorMessages = VDST_Validator.validateEventOnStatusChange(commonUtils.eventType, commonUtils.vendorLoggedVal, statusFieldMap,
                status, eventCreateObject, siteObject, venueObject, newDrugNames, etsSummary,
                VDST_Utils.hasTravelAndLodgingExpenses(eventCreateObject.Id), evDateTransList);
        // Show message if error
        if (!String.isBlank(editErrorMessages)) {
            return false;
        } else {
            return true;
        }

    }

    /** @date 7/2/2014
    * @Author Konrad Malinowski
    * @description Method for validating Participants during status change
    * @return PageReference
    */
    private Boolean validateParticipantsOnStatusChange(String status) {
        prtcpntValidObj.status = status;
        prtcpntValidObj.participantObject = null;
        VDST_Validator.ParticipantsValidationOutput result = VDST_Validator.validateParticipantsOnStatusChange(commonUtils.eventType,
                commonUtils.vendorLoggedVal, prtcpntValidObj, null, null, commonUtils.eventRolesMapById);
        if (!result.isSuccess) {
            editErrorMessages += result.editErrorMessages;
        }
        return result.isSuccess;
    }

    /** @date 9/27/2013
    * @Author Bartłomiej Dejnega
    * @description Method for setting Event Attachment Id
    * @return Boolean
    */
    public PageReference setEventAttachment() {
        if (eventCreateObject == null) {
            eventAttachment = null;
            return null;
        }
        List<Attachment> aList = [SELECT Id, Name FROM Attachment WHERE ParentId = :eventCreateObject.Id];
        if (aList.size() != 1) {
            eventAttachment = null;
        } else {
            eventAttachment = aList.get(0);
        }
        return null;
    }

    /** @date 9/27/2013
    * @Author Bartłomiej Dejnega
    * @description Method for inserting Attachment from JavaScript
    * @return PageReference
    */
    public PageReference insertAttachmentJS() {
        String fileContent = Apexpages.currentPage().getParameters().get('fileContent');
        system.debug(LoggingLevel.INFO, 'fileContent ' + fileContent);
        fileContent = fileContent.substring(fileContent.indexOf(',') + 1);
        Blob b = EncodingUtil.base64Decode(fileContent);
        String fName = Apexpages.currentPage().getParameters().get('fileName');
        Attachment att = new Attachment();
        att.Body = b;
        att.parentId = eventCreateObject.Id;
        att.Name = fName;
        insert att;
        setEventAttachment();
        return null;
    }

    /** @date 9/27/2013
    * @Author Bartłomiej Dejnega
    * @description Method for overwriting Attachment from JavaScript
    * @return PageReference
    */
    public PageReference overwriteAttachmentJS() {
        String fileContent = Apexpages.currentPage().getParameters().get('fileContent');
        system.debug(LoggingLevel.INFO, 'fileContent ' + fileContent);
        fileContent = fileContent.substring(fileContent.indexOf(',') + 1);
        Blob b = EncodingUtil.base64Decode(fileContent);
        String fName = Apexpages.currentPage().getParameters().get('fileName');
        Attachment att = new Attachment();
        att.Body = b;
        att.parentId = eventCreateObject.Id;
        att.Name = fName;
        att.Id = eventAttachment.Id;
        update att;
        setEventAttachment();
        return null;
    }

    /** @date 9/27/2013
    * @Author Bartłomiej Dejnega
    * @description Method for inserting Attachment
    * @return PageReference
    */
    public PageReference insertAttachmentController() {
        Attachment att = new Attachment();
        att.Body = fileBody;
        att.parentId = eventCreateObject.Id;
        att.Name = fileName;
        insert att;
        setEventAttachment();
        return null;
    }

    /** @date 9/27/2013
    * @Author Bartłomiej Dejnega
    * @description Method for overwriting Attachment
    * @return PageReference
    */
    public PageReference overwriteAttachmentController() {
        Attachment att = new Attachment();
        att.Body = fileBody;
        att.parentId = eventCreateObject.Id;
        att.Name = fileName;
        att.Id = eventAttachment.Id;
        update att;
        setEventAttachment();
        return null;
    }

    /** @date 9/27/2013
    * @Author Bartłomiej Dejnega
    * @description Method for deleting Attachment
    * @return PageReference
    */
    public PageReference deleteAttachment() {
        delete eventAttachment;
        setEventAttachment();
        return null;
    }

    /** @date 10/31/2013
    * @Author Konrad Malinowski
    * @description Method for setting Brand Ids from JS
    * @return PageReference
    */
    public PageReference setBrandIds() {
        newDrugNames = multiDrugNamesTxt;
        if (String.isBlank(multiDrugNamesIds)) {
            return null;
        }
        multiDrugNames = new List<String>();
        List<String> multiDrugNamesIdsSplitted = multiDrugNamesIds.split(',');
        for (String drug : multiDrugNamesIdsSplitted) {
            if (!String.isBlank(drug.trim())) {
                multiDrugNames.add(drug.trim());
            }
        }
        return null;
    }

    /** @date 4/18/2013
    * @Author Pawel Sprysak
    * @description Method for getting User First Name and Last Name by Unix Id
    * @param String unixId
    * @return UserWrapper
    */
    @RemoteAction
    global static UserWrapper getUserData(String unixId) {
        if (!''.equals(unixId)) {
            All_User_Hierarchy_gne__c auh = VDST_Utils.getUserData(unixId);
            if (auh != null) {
                return new UserWrapper(auh.FirstName_gne__c, auh.LastName_gne__c);
            } else {
                return null;
            }
        } else {
            return new UserWrapper('', '');
        }
    }

    /** @date 8/25/2014
    * @Author Konrad Malinowski
    * @description Method for checking if Participant Unix Id is Unique In Event
    * @param String eventId
    * @param String participantId
    * @param String unixId
    * @return Boolean
    */
    @RemoteAction
    global static Boolean isParticipantUnixIdUniqueInEvent(String eventId, String participantId, String unixId) {
        if (String.isNotBlank(eventId) && String.isNotBlank(unixId)) {
            return VDST_Utils.isParticipantUnixIdUniqueInEvent(eventId, participantId, unixId);
        } else {
            return true;
        }
    }

    /** @date 4/18/2013
    * @Author Pawel Sprysak
    * @description Method for checking Vendor Event Id uniqueness
    * @param String vendorEventId
    * @param String eventId
    * @param String logisticVendorCode
    * @param String alterLogisticVendorCode
    * @return Boolean
    */
    @RemoteAction
    global static Boolean isVendorEventIdUnique(String vendorEventId, String eventId, String logisticVendorCode, String alterLogisticVendorCode) { // TODO: remove - alterLogisticVendorCode not in use
        return VDST_Utils.isVendorEventIdUnique(logisticVendorCode, vendorEventId, eventId);
    }

    /** @date 4/18/2013
    * @Author Pawel Sprysak
    * @description Method for checking Vendor Participant Id uniqueness
    * @param String parId
    * @param String vendorParticpantId
    * @param String logisticVendorCode
    * @param String alterLogisticVendorCode
    * @return Boolean
    */
    @RemoteAction
    global static Boolean isVendorParticipantIdUnique(String parId, String vendorParticpantId, String logisticVendorCode, String alterLogisticVendorCode) { // TODO: remove - alterLogisticVendorCode not in use
        return VDST_Utils.isVendorParticipantIdUnique(logisticVendorCode, vendorParticpantId, parId);
    }

    /** @date 4/18/2013
    * @Author Pawel Sprysak
    * @description Method for getting Transaction Data from Transaction Id
    * @param String transactionId
    * @param String eventType
    * @return VDST_SuplementData.SuplementedTransaction
    */
    @RemoteAction
    global static VDST_SuplementData.SuplementedTransaction getTransactionData(String transactionId, String eventType) {
        transactionId = transactionId.trim();
        return VDST_SuplementData.getSuplementTransaction(transactionId, eventType);
    }

    /** @date 4/18/2013
    * @Author Pawel Sprysak
    * @description Wrapper for sending First Name and Last Name to UI
    */
    global class UserWrapper {
        public String firstName { get; set; }
        public String lastName { get; set; }

        public UserWrapper(String fn, String ln) {
            firstName = fn;
            lastName = ln;
        }
    }

    /** @date 11/22/2013
    * @Author Konrad Malinowski
    * @description Wrapper for sending Event History to UI
    */
    public class EventHistoryWrapper {
        public String status { get; set; }
        public VDST_Event_gne__History eventHistory { get; set; }

        public EventHistoryWrapper(VDST_Event_gne__History eh, VDST_EventDetailCommon common) {
            eventHistory = eh;
            status = (eventHistory.NewValue == null ? 'Pending' : common.mappingMap.get((String) eventHistory.NewValue).LabelValue_gne__c);
        }
    }
}