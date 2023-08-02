public without sharing class EMS_Concur_Custom_Connector_Ext {

    public Integer matchesFound { get; set; }
    public Boolean isError { get; set; }
    public List<SelectOption> types { get; set; }
    public List<SelectOption> periods { get; set; }

    private static final Integer BUFFER = 1000;
    private String sobjectAPIName;
    private String expenseType;

    public String type {
        get {
            if (String.isBlank(type)) {
                type = types[0].getValue();
            }
            return type;
        }
        set;
    }

    public String period {
        get {
            if (String.isBlank(period)) {
                // get current month
                period = Datetime.newInstance(Datetime.now().year(), Datetime.now().month(), 1).format();
            }
            return period;
        }
        set;
    }

    public Date periodEnd { get; set; }          // Start Date
    public Date periodStart { get; set; }        // End Date

    private Map<String, CommonObject> recordsMap {
        get {
            if (recordsMap == null) {
                recordsMap = new Map<String, CommonObject>();
            }
            return recordsMap;
        }
        set;
    }

    private static String eventAPIName = EMS_Event__c.SObjectType.getDescribe().getName();
    private static String interactionAPIName = Call2_vod__c.SObjectType.getDescribe().getName();

    private static Map<String, Schema.SObjectField> eventFieldsMap = EMS_Event__c.SObjectType.getDescribe().fields.getMap();
    private static Map<String, Schema.SObjectField> interactionFieldsMap = Call2_vod__c.SObjectType.getDescribe().fields.getMap();
    private static Map<String, List<String>> sobjectNameToFields = new Map<String, List<String>>{
            eventAPIName => new List<String>{
                    Schema.SObjectType.EMS_Event__c.fields.Start_Date_gne__c.getName(),
                    Schema.SObjectType.EMS_Event__c.fields.Name.getName(),
                    Schema.SObjectType.EMS_Event__c.fields.Event_Name_gne__c.getName(),
                    Schema.SObjectType.EMS_Event__c.fields.HCP_Attendees_gne__c.getName(),
                    Schema.SObjectType.EMS_Event__c.fields.Event_Sub_Type_gne__c.getName(),
                    Schema.SObjectType.EMS_Event__c.fields.Product_Indication_gne__c.getName(),
                    '(SELECT ' + Schema.SObjectType.EMS_Budget_Allocation_gne__c.fields.Cost_Center_gne__c.getName() + ',' + Schema.SObjectType.EMS_Budget_Allocation_gne__c.fields.Percentage_Contribution_gne__c.getName() + ', ' + Schema.SObjectType.EMS_Budget_Allocation_gne__c.fields.Cost_Center_Type_gne__c.getName() + ' FROM EMS_Budget_Allocations__r)',
                    '(SELECT Name, User_gne__c FROM EMS_Roche_Attendees__r)',
                    'Event_Owner_gne__c',
                    'Event_Requestor_gne__c'
            },
            interactionAPIName => new List<String>{
                    Schema.SObjectType.Call2_vod__c.fields.Call_Date_vod__c.getName(),
                    Schema.SObjectType.Call2_vod__c.fields.Name.getName(),
                    'Account_vod__r.Name',
                    Schema.SObjectType.Call2_vod__c.fields.Attendees_vod__c.getName()
            }
    };

    private Map<String, String> typesToAllowedStatuses = new Map<String, String>();

    public EMS_Concur_Custom_Connector_Ext() {
        isError = false;
        matchesFound = 0;
        currentPage = 1;
        countPages = 0;

        String pageUrl = ApexPages.currentPage().getUrl().toLowerCase();
        if (pageUrl.contains(Page.EMS_Concur_Event_Connector.getUrl().toLowerCase())) {
            sobjectAPIName = eventAPIName;
            expenseType = ApexPages.currentPage().getParameters().get('expenseType');
        }
        if (pageUrl.contains(Page.EMS_Concur_Interaction_Connector.getUrl().toLowerCase())) {
            sobjectAPIName = interactionAPIName;
        }
    }

    public void prepare() {
        getPeriodLength();
        preparePeriods();
        prepareTypes();
        prepareRecords();

        if (isError == true) {
            return;
        }

        countPages = (Math.mod(matchesFound, BUFFER) == 0) ? (matchesFound / BUFFER) : ((matchesFound / BUFFER) + 1);
        fetchFirstPage();
    }

    public void refreshData() {

        prepareRecords();
        countPages = (Math.mod(matchesFound, BUFFER) == 0) ? (matchesFound / BUFFER) : ((matchesFound / BUFFER) + 1);
        fetchFirstPage();
    }

    private void prepareTypes() {
        types = new List<SelectOption>();
        Set<String> subtypesSet = new Set<String>();

        if (sobjectAPIName == eventAPIName) {
            // read mapping
            Set<String> allowedSubTypes = new Set<String>();
            for (EMS_Concur_Expense_Type_Mapping_gne__c concurMapping : [SELECT Event_Sub_Type__c FROM EMS_Concur_Expense_Type_Mapping_gne__c WHERE Expense_Type_gne__c = :expenseType]) {
                for (String eventSubType : concurMapping.Event_Sub_Type__c.split(';')) {
                    allowedSubTypes.add(eventSubType);
                }
            }
            for (EMS_Event_Configuration_gne__c evConfig : [SELECT Event_Sub_Type_gne__c, Concur_Allowed_Event_Statuses_gne__c FROM EMS_Event_Configuration_gne__c WHERE Is_Visible_in_Concur_gne__c = TRUE]) {
                if (allowedSubTypes.contains(evConfig.Event_Sub_Type_gne__c) && !subtypesSet.contains(evConfig.Event_Sub_Type_gne__c)) {
                    types.add(new SelectOption(evConfig.Event_Sub_Type_gne__c, evConfig.Event_Sub_Type_gne__c));
                    typesToAllowedStatuses.put(evConfig.Event_Sub_Type_gne__c, evConfig.Concur_Allowed_Event_Statuses_gne__c);

                    subtypesSet.add(evConfig.Event_Sub_Type_gne__c);
                }
            }
        }
        if (sobjectAPIName == interactionAPIName) {
            EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettings();
            for (String type : concurSettings.Interaction_Type_gne__c.split(';')) {
                types.add(new SelectOption(type, type));
            }
        }

        types.sort();
    }

    private void preparePeriods() {
        periods = new List<SelectOption>();
        EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettings();
        Integer periodLength;

        if (sobjectAPIName == eventAPIName) {
            periodLength = Integer.valueOf(concurSettings.Event_Period_Length_gne__c);
        } else if (sobjectAPIName == interactionAPIName) {
            periodLength = Integer.valueOf(concurSettings.Interaction_Period_Length_gne__c);
        }

        for (Integer i = 0; i < periodLength; i++) {
            Date tempdate = periodStart.addMonths(i);
            Datetime dt = Datetime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
            periods.add(new SelectOption(dt.format(), dt.format('MMMM yyyy')));
        }
    }

    private void getPeriodLength() {
        Integer periodLength = 3; // Default period is 3

        EMS_Concur_Settings_gne__c concurSettings = EMS_Concur_Util.getConcurSettings();

        if (concurSettings != null) {
            if (sobjectAPIName == eventAPIName && concurSettings.Event_Period_Length_gne__c != null && (Integer) concurSettings.Event_Period_Length_gne__c > 0) {
                periodLength = (Integer) concurSettings.Event_Period_Length_gne__c;
            }
            if (sobjectAPIName == interactionAPIName && concurSettings.Interaction_Period_Length_gne__c != null && (Integer) concurSettings.Interaction_Period_Length_gne__c > 0) {
                periodLength = (Integer) concurSettings.Interaction_Period_Length_gne__c;
            }
        }

        Integer dayInMonth = Date.daysInMonth(Date.today().year(), Date.today().month());
        Integer halfMonth = Integer.valueOf(Decimal.valueOf(dayInMonth / 2).round(System.RoundingMode.DOWN));

        if (sobjectAPIName == eventAPIName) {
            Date centerDate = (Math.mod(periodLength, 2) == 0) ? Date.today().toStartOfMonth() : Date.today().toStartOfMonth().addDays(halfMonth);

            Decimal monthOffset = periodLength / 2;
            Decimal daysOffset = Math.mod(periodLength, 2) * halfMonth;

            periodStart = centerDate.addMonths(Integer.valueOf(-monthOffset)).addDays(Integer.valueOf(-daysOffset)).toStartOfMonth();
            periodEnd = periodStart.addMonths(periodLength);
        }
        if (sobjectAPIName == interactionAPIName) {
            Decimal offset = periodLength;
            Date centerDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);

            periodStart = centerDate.addMonths(-1 * (Integer) (offset - 1));
            periodEnd = centerDate.addMonths(1);
        }
    }

    public PageReference recordNewCall() {
        PageReference pr = Page.GNE_SFA2_SBC;
        pr.getParameters().put('retURL', '/apex/EMS_Concur_Interaction_Connector');
        pr.getParameters().put('expenseType', System.currentPageReference().getParameters().get('expenseType'));
        pr.getParameters().put('expKey', System.currentPageReference().getParameters().get('expKey'));
        pr.getParameters().put('transactionAmount', System.currentPageReference().getParameters().get('transactionAmount'));
        pr.getParameters().put('itemUrl', System.currentPageReference().getParameters().get('itemUrl'));
        pr.getParameters().put('allowType', 'HCP');
        pr.setRedirect(true);
        return pr;
    }

    public Boolean getIsNewCallButtonVisible() {
        return GNE_SFA2_Util.isCanadaINFUUser();
    }

    private void prepareRecords() {
        String selectCondition = 'SELECT ' + getFields() + ' FROM ' + sobjectAPIName;

        String whereCondition = '';

        // Type WHERE conditions
        if (String.isNotBlank(type)) {
            String condition = ' ';
            if (sobjectAPIName == eventAPIName) {
                condition += 'Event_Sub_Type_gne__c = \'' + type + '\'';
            }
            if (sobjectAPIName == interactionAPIName) {
                condition += 'Interaction_Type_gne__c = \'' + type + '\'';
            }
            whereCondition += (String.isBlank(whereCondition)) ? ' WHERE' + condition : ' AND' + condition;
        }

        String condition;
        String fieldName = '';
        Date startDate;
        Date endDate;
        Datetime startDateTime;
        Datetime endDateTime;

        if (sobjectAPIName == eventAPIName) {
            fieldName = Schema.SObjectType.EMS_Event__c.fields.End_Date_gne__c.getName(); // Date type
            startDate = Datetime.parse(period).date();
            endDate = startDate.addMonths(1);
            condition = ' ' + fieldName + ' >= :startDate AND ' + fieldName + ' < :endDate';
        }
        if (sobjectAPIName == interactionAPIName) {
            fieldName = Schema.SObjectType.Call2_vod__c.fields.Call_Datetime_vod__c.getName(); // DateTime type
            startDateTime = Datetime.parse(period);
            endDateTime = startDateTime.addMonths(1);
            condition = ' ' + fieldName + ' >= :startDateTime AND ' + fieldName + ' < :endDateTime';
        }

        whereCondition += (String.isBlank(whereCondition)) ? ' WHERE' + condition : ' AND' + condition;

        // Special WHERE conditions
        if (sobjectAPIName == eventAPIName && typesToAllowedStatuses.containsKey(type) && typesToAllowedStatuses.get(type) != null) {
            List<String> statuses = typesToAllowedStatuses.get(type).split(';');
            for (Integer i = 0; i < statuses.size(); i++) {
                statuses[i] = '\'' + statuses[i] + '\'';
            }

            condition = ' Status_gne__c IN (' + String.join(statuses, ',') + ')';
            whereCondition += (String.isBlank(whereCondition)) ? ' WHERE' + condition : ' AND' + condition;
        }
        if (sobjectAPIName == interactionAPIName) {
            condition = ' OwnerId = \'' + UserInfo.getUserId() + '\' AND Region_Code_gne__c = 2 AND Parent_Call_vod__c = null AND IsDeleted = false AND Interaction_Status_gne__c = \'Completed\'';
            whereCondition += (String.isBlank(whereCondition)) ? ' WHERE' + condition : ' AND' + condition;
        }

        String limitCondition = ' LIMIT 1000';
        String soqlQuery = selectCondition + whereCondition + limitCondition;

        List<SObject> objectList;
        try {
            objectList = Database.query(soqlQuery);
        } catch (Exception ex) {
            isError = true;
            System.debug(LoggingLevel.ERROR, '### message : ' + ex.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A temporary application error has occurred.'));
            return;
        }

        // eliminating some events, leaving ones for which current user is either Owner/Requestor, either Attendees member
        if (sobjectAPIName == eventAPIName) {
            Integer i = 0;
            while (i < objectList.size()) {
                EMS_Event__c tempEvent = (EMS_Event__c) objectList.get(i);

                Boolean isOneOfAttendees = false;
                for (EMS_Roche_Attendee_gne__c attendee : tempEvent.EMS_Roche_Attendees__r) {
                    if (attendee.User_gne__c == UserInfo.getUserId()) {
                        isOneOfAttendees = true;
                    }
                }

                if (tempEvent.Event_Owner_gne__c != UserInfo.getUserId() && tempEvent.Event_Requestor_gne__c != UserInfo.getUserId() && !isOneOfAttendees) {
                    objectList.remove(i);
                } else {
                    i++;
                }
            }
        }

        recordsMap.clear();
        for (SObject sobj : objectList) {

            if (sobjectAPIName == eventAPIName) {
                EMS_Event__c tempEvent = (EMS_Event__c) sobj;

                // Aggregating by Cost Center Name happens below
                Map<String, CostCenter> ccAggregatedMap = new Map<String, CostCenter>();
                for (EMS_Budget_Allocation_gne__c ba : tempEvent.EMS_Budget_Allocations__r) {
                    Decimal percentage = (ba.Percentage_Contribution_gne__c == null) ? 0 : ba.Percentage_Contribution_gne__c;

                    if (ccAggregatedMap.containsKey(ba.Cost_Center_gne__c)) {
                        CostCenter existingRecord = ccAggregatedMap.get(ba.Cost_Center_gne__c);
                        // Changing current "% Contribution"
                        existingRecord.percentageContribution += percentage;
                        ccAggregatedMap.put(existingRecord.code, existingRecord);
                    } else {
                        CostCenter newRecord = new CostCenter(percentage, ba.Cost_Center_gne__c, ba.Cost_Center_Type_gne__c);
                        newRecord.description = (costCenterDescription.containsKey(ba.Cost_Center_gne__c)) ? costCenterDescription.get(ba.Cost_Center_gne__c) : '';
                        ccAggregatedMap.put(ba.Cost_Center_gne__c, newRecord);
                    }
                }

                for (String ccName : ccAggregatedMap.keySet()) {
                    String uniqueID = tempEvent.Id + ccName;
                    CommonObject newRecord = new CommonObject(sobj, sobjectAPIName, uniqueID);
                    newRecord.costCenterInfo = ccAggregatedMap.get(ccName);
                    recordsMap.put(newRecord.internalID, newRecord);
                }
            } else {
                recordsMap.put(sobj.Id, new CommonObject(sobj, sobjectAPIName, sobj.Id));
            }
        }

        matchesFound = recordsMap.size();
    }

    private String getFields() {
        String fields = '';
        if (sobjectNameToFields.containsKey(sobjectAPIName)) {
            fields = String.join(sobjectNameToFields.get(sobjectAPIName), ',');
        }
        return fields;
    }

    // returns only ACTIVE Cost Center records
    private static Map<String, String> costCenterDescription {
        get {
            List<EMS_Cost_Center_gne__c> ccList = [SELECT Product_Indication_Department_gne__c, Name FROM EMS_Cost_Center_gne__c WHERE Is_Active_gne__c = TRUE];
            Map<String, String> results = new Map<String, String>();
            for (EMS_Cost_Center_gne__c cc : ccList) {
                if (results.containsKey(cc.Name)) {
                    String oldDescription = results.get(cc.Name);
                    results.put(cc.Name, oldDescription + ' ' + cc.Product_Indication_Department_gne__c);
                } else {
                    results.put(cc.Name, cc.Product_Indication_Department_gne__c);
                }
            }
            return results;
        }
    }

    // Save
    public String selectedId { get; set; }
    public String concurStatus { get; set; }
    public String concurError { get; set; }

    public void save() {
        try {
            if (recordsMap.containsKey(selectedId)) {
                String reportId = '';
                String entryId = '';
                String expenseKey = '';
                String transactionAmount = '';
                String recordName = '';

                expenseKey = String.valueOf(ApexPages.currentPage().getParameters().get('expKey'));
                transactionAmount = String.valueOf(ApexPages.currentPage().getParameters().get('transactionAmount'));

                String itemURL = String.valueOf(ApexPages.currentPage().getParameters().get('itemUrl'));
                List<String> itemsURL = itemURL.split('/');
                for (Integer i = 0; i < itemsURL.size(); i++) {
                    if (i != 0 && itemsURL.get(i - 1) == 'report') {
                        reportId = itemsURL.get(i);
                    }
                    if (i != 0 && itemsURL.get(i - 1) == 'entry') {
                        entryId = itemsURL.get(i);
                    }
                }
                String response = '';

                if (recordsMap.get(selectedId).e != null) { // Events
                    recordName = (String) recordsMap.get(selectedId).e.Name;
                    String costCenter = (String) recordsMap.get(selectedId).costCenterInfo.code;
                    String eventName = (String) recordsMap.get(selectedId).e.Event_Name_gne__c;
                    response = EMS_Concur_Webservice.postExpense(reportId, entryId, expenseKey, Decimal.valueOf(transactionAmount), recordName, costCenter, eventName, null, null);
                }
                if (recordsMap.get(selectedId).i != null) { // Interactions
                    recordName = (String) recordsMap.get(selectedId).i.Name;
                    String hcpName = (String) recordsMap.get(selectedId).i.Account_vod__r.Name;
                    Integer attendeeCount = (Integer) recordsMap.get(selectedId).i.Attendees_vod__c;
                    response = EMS_Concur_Webservice.postExpense(reportId, entryId, expenseKey, Decimal.valueOf(transactionAmount), recordName, null, null, hcpName, attendeeCount);
                }

                if (String.isNotBlank(response)) {
                    XmlStreamReader reader = new XmlStreamReader(response);
                    while (reader.hasNext()) {
                        if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Status') {
                            reader.next();
                            if (reader.getEventType() == XmlTag.CHARACTERS) {
                                concurStatus = reader.getText().toUpperCase();
                            }
                        }

                        if (reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Message') {
                            reader.next();
                            if (reader.getEventType() == XmlTag.CHARACTERS) {
                                concurError = reader.getText();
                            }
                        }
                        reader.next();
                    }
                }
            }
        } catch (Exception e) {
            concurError = e.getMessage();
            concurStatus = 'ERROR';
            return;
        }
    }

// PAGINATION
    public Integer getAmountRecordsOnPage() {
        return BUFFER;
    }

    public Integer currentPage { get; set; }
    public transient List<CommonObject> records { get; set; }
    public Integer countPages { get; set; }

    public void showFirstPage() {
        fetchFirstPage();
        currentPage = 1;
    }

    private void fetchFirstPage() {
        records = new List<CommonObject>();

        Integer size = (recordsMap.size() < BUFFER) ? recordsMap.size() : BUFFER;
        for (Integer i = 0; i < size; i++) {
            records.add(recordsMap.values()[i]);
        }
    }

    public void showLastPage() {
        fetchLastPage();
        currentPage = countPages;
    }

    private void fetchLastPage() {
        records = new List<CommonObject>();

        for (Integer i = ((countPages - 1) * BUFFER); i < recordsMap.size(); i++) {
            records.add(recordsMap.values()[i]);
        }
    }

    public void showPreviousPage() {
        currentPage--;
        if (currentPage <= 1) {
            fetchFirstPage();
        } else {
            fetchPreviousOrNextPage();
        }
    }

    public void showNextPage() {
        currentPage++;
        if (currentPage >= countPages) {
            fetchLastPage();
        } else {
            fetchPreviousOrNextPage();
        }
    }

    private void fetchPreviousOrNextPage() {
        records = new List<CommonObject>();

        for (Integer i = ((currentPage - 1) * BUFFER) + 1; i <= (currentPage * BUFFER); i++) {
            records.add(recordsMap.values()[i]);
        }
    }

    public class CommonObject {
        public EMS_Event__c e { get; set; }
        public Call2_vod__c i { get; set; }
        public Boolean selected { get; set; }
        public String internalID { get; set; }
        public CostCenter costCenterInfo { get; set; }

        CommonObject(SObject record, String sobjectAPIName, String internalID) {
            this.internalID = internalID;

            if (sobjectAPIName == interactionAPIName) {
                this.i = (Call2_vod__c) record;
            }
            if (sobjectAPIName == eventAPIName) {
                this.e = (EMS_Event__c) record;
            }
        }
    }

    class CostCenter {
        public Decimal percentageContribution { get; set; }
        public String description { get; set; }
        public String code { get; set; }
        public String type { get; set; }

        CostCenter(Decimal percentage, String code, String type) {
            this.percentageContribution = percentage;
            this.code = code;
            this.type = type;
        }
    }
}