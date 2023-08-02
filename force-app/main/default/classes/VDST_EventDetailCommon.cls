/** @date 5/21/2013
* @Author Pawel Sprysak
* @description Common Utils for Event Detail
*/
public without sharing class VDST_EventDetailCommon {
    // STATIC Map validation Lists
    public static List<String>                                  EVENT_VALIDATION_STATUSES = new List<String> { 'OCCURRED', 'CLOSED' };
    public static List<String>                                  EVENT_VALIDATION_FIELDS = new List<String> { 'InvitationSentDate_gne', 'PlAttCnt', 'GNE_EventID_gne', 'TotalAudioVisual_gne', 'ContentVendor_gne' };
    // Mappings
    public Map<String, VDST_Mapping_gne__c>                     mappingMap        { get; set; }
    public Map<String, String>                                  inverseMap        { get; set; }
    public Map<String, String>                                  inverseStatesMap  { get; set; }
    public Map<String, String>                                  credentialMap     { get; set; }
    public Map<String, VDST_EventPrtcpntRole_gne__c>            eventRolesMap     { get; set; }
    public Map<String, VDST_EventPrtcpntRole_gne__c>            eventRolesMapById { get; set; }
    // Page Type
    public Boolean                                              isStdEvent        { get; set; }
    public Boolean                                              isNewStdEvent     { get; set; }
    public Boolean                                              isSSEvent         { get; set; }
    public Boolean                                              isResearchEvent   { get; set; }
    public Boolean                                              isNonResearchEvent{ get; set; }
    // NonResearch Transaction - transaction data holder
    public NonResearchPayments                                  nonResTransaction { get; set; }
    // Others
    public String                                               vendorLoggedVal   { get; set; } // Vendor Logged code
    public String                                               eventType         { get; set; } // Event type code
    public Boolean                                              hasMCS            { // Flag - wheather Meal Consumption Status is available
        get {
            if( 'CFF'.equals(eventType) || 'MISCEVENT'.equals(eventType) ) {
                return true;
            } else {
                return false;
            }
        }
    }
    public Date cutoffDate { get; set; }

    /** @date 5/21/2013
    * @Author Pawel Sprysak
    * @description Constructor for Common Class
    */
    public VDST_EventDetailCommon() {
        // Page type initialization
        cutoffDate = VDST_Utils.getCustomSettingsIntExt().GSSP_Cutoff_Date__c;
        isStdEvent = false;
        isNewStdEvent = false;
        isSSEvent = false;
        isResearchEvent = false;
        isNonResearchEvent = false;
        // Mapping initialization
        mappingMap = new Map<String, VDST_Mapping_gne__c>();
        for(VDST_Mapping_gne__c mapValue : VDST_Mapping_gne__c.getAll().values()) {
            mappingMap.put(mapValue.Name, new VDST_Mapping_gne__c(LabelValue_gne__c = mapValue.LabelValue_gne__c));
        }
        inverseMap = new Map<String, String>();
        inverseStatesMap = VDST_Utils.getInverseStatesMap();
        credentialMap = VDST_Utils.getPickListMap(VDST_EventPrtcpntAccnt_gne__c.Credential_gne__c.getDescribe());
        for(String keyVal : mappingMap.keySet()) {
            inverseMap.put(mappingMap.get(keyVal).LabelValue_gne__c.toLowerCase(), keyVal);
        }
    }

    /** @date 3/29/2016
    * @Author Pawel Sprysak
    * @description Constructor for Common Class
    */
    public VDST_EventDetailCommon(String evType) {
        this();
        eventType = evType;
        setEventTypeFlags();
        setEventRoles();
    }

    /** @date 4/27/2015
    * @Author Konrad Malinowski
    * @description Method for setting event type flags
    * @param String eventType
    */
    public void setEventTypeFlags() {
        isStdEvent          = VDST_Utils.isStdEventType(eventType);
        isNewStdEvent       = VDST_Utils.isNewStdEventType(eventType);
        isSSEvent           = VDST_Utils.isSSEventType(eventType);
        isResearchEvent     = VDST_Utils.isResearchEventType(eventType);
        isNonResearchEvent  = VDST_Utils.isNonResearchEventType(eventType);
    }

    /** @date 3/26/2013
    * @Author Pawel Sprysak
    * @description Set Event Roles methods
    * @param String eventType
    */
    public void setEventRoles() {
        eventRolesMap = new Map<String, VDST_EventPrtcpntRole_gne__c>();
        eventRolesMapById = new Map<String, VDST_EventPrtcpntRole_gne__c>();
        for(VDST_EventPrtcpntRole_gne__c epr : VDST_Utils.getVendorCodeList(eventType)) {
            eventRolesMap.put(epr.EventParticipantRoleCode_gne__c, epr);
            eventRolesMapById.put(String.valueOf(epr.Id), epr);
        }
    }

    /** @date 5/21/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Label value for code
    * @param String code
    * @return String
    */
    public String getLabel(String code) {
        if(mappingMap.get(code) != null) {
            return mappingMap.get(code).LabelValue_gne__c;
        } else {
            return '';
        }
    }

//////////////////////////
// SELECT LISTS - BEGIN //
//////////////////////////
    /** @date 5/21/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Consumption Status
    * @return List<SelectOption>
    */
    public List<SelectOption> getProfessionSO() {
        List<SelectOption> optionList = new List<SelectOption>{new SelectOption('', '-Select-')};
        optionList.addAll(VDST_Utils.selectOptionSortByLabel(VDST_Utils.getMappedSelectOption(VDST_EventPrtcpntAccnt_gne__c.ParticipantProfession_gne__c.getDescribe(), mappingMap)));
        return optionList;
    }

    /** @date 5/21/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Consumption Status
    * @return List<SelectOption>
    */
    public List<SelectOption> getCredentialCodeMappingsSO() {
        List<SelectOption> optionList = new List<SelectOption>{new SelectOption('', '-Select-')};
        optionList.addAll(VDST_Utils.selectOptionSortByLabel(VDST_Utils.getPickListValues(VDST_EventPrtcpntAccnt_gne__c.Credential_gne__c.getDescribe())));
        return optionList;
    }


    /** @date 5/22/2013
    * @Author Pawel Sprysak
    * @description Method for VF - getting Suffix
    * @return List<SelectOption>
    */
    public List<SelectOption> getSuffixMappingsSO() {
        List<SelectOption> optionList = new List<SelectOption>{new SelectOption('', '-Select-')};
        optionList.addAll(VDST_Utils.selectOptionSortByLabel(VDST_Utils.getMappedSelectOption(VDST_EventPrtcpntAccnt_gne__c.Suffix_gne__c.getDescribe(), mappingMap)));
        return optionList;
    }
////////////////////////
// SELECT LISTS - END //
////////////////////////

///////////////////////////
// INNER CLASSES - BEGIN //
///////////////////////////
    /** @date 10/30/2013
    * @Author Pawel Sprysak
    * @description Wrapper Class for Non-Research Payments
    */
    public class NonResearchPayments {
        public NonResearchTransaction       sourceBalance  { get; set; }
        public NonResearchTransaction       totalSpends    { get; set; }
        public List<NonResearchTransaction> attendanceList { get; set; }
        public Map<String, String>          transactionMap { get; set; }
        public String                       sourceExpType  { get; set; }
        public Decimal                      nonResPayment  {
            get {
                if(nonResPayment == null) {
                    return 0;
                }
                return nonResPayment;
            }
            set;
        }
        public String                       eventId        { get; set; }

        /** @date 10/30/2013
        * @Author Pawel Sprysak
        * @description Constructor for Wrapper Class Class
        */
        public NonResearchPayments(String eventId, Decimal itemAmount, String eventType, String sourceExpType) {
            this.eventId = eventId;
            this.sourceExpType = sourceExpType;
            this.nonResPayment = itemAmount;
            transactionMap = VDST_Utils.getTransacionCodeToLabelMap(eventType);
            totalSpends = new NonResearchTransaction('Total Spend', 0);
            sourceBalance = new NonResearchTransaction('Source Balance', 0);
            setTransactionList();
        }

        /** @date 10/30/2013
        * @Author Pawel Sprysak
        * @description Method setting Item Amount
        * @param Decimal newAmount
        */
        public void setItemAmount(Decimal newAmount) {
            this.nonResPayment = newAmount;
            if(attendanceList.size() > 0) {
                this.sourceBalance.spendAmount = newAmount - totalSpends.spendAmount;
            } else {
                this.sourceBalance.spendAmount = newAmount;
            }
        }

        /** @date 10/30/2013
        * @Author Pawel Sprysak
        * @description Method setting Transaction List
        */
        public void setTransactionList() {
            attendanceList = new List<NonResearchTransaction>();
            for(VDST_EventTransactionSummary_gne__c ets : VDST_Utils.getSummaryTransactionsList(eventId) ) {
                if('TOTALEVENT'.equals(ets.EventTransactionTypeCode_gne__c)) {
                    totalSpends.spendAmount = ets.EventTransactionAmount_gne__c;
                } else {
                    if(transactionMap.get(ets.EventTransactionTypeCode_gne__c) != null) {
                        attendanceList.add(new NonResearchTransaction(transactionMap.get(ets.EventTransactionTypeCode_gne__c), ets.EventTransactionAmount_gne__c));
                    }
                }
            }
            if(attendanceList.size() > 0) {
                sourceBalance.spendAmount = nonResPayment - totalSpends.spendAmount;
            } else {
                sourceBalance.spendAmount = nonResPayment;
            }
        }
    }

    /** @date 10/30/2013
    * @Author Pawel Sprysak
    * @description Wrapper Class for Non-Research Transaction
    */
    public class NonResearchTransaction {
        public String               spendName   { get; set; }
        public Decimal              spendAmount {
            get {
                if(spendAmount == null) {
                    return 0;
                }
                return spendAmount;
            }
            set;
        }

        /** @date 10/30/2013
        * @Author Pawel Sprysak
        * @description Constructor for Wrapper Class
        */
        public NonResearchTransaction(String spendName, Decimal spendAmount) {
            this.spendName = spendName;
            this.spendAmount = spendAmount;
        }
    }
/////////////////////////
// INNER CLASSES - END //
/////////////////////////
}