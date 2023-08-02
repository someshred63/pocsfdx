/** @date 3/5/2013
* @Author Pawel Sprysak
* @description Controller for handling EDST Event List
*/
global without sharing class VDST_EventListController {
	// Static variables
	private static String                                     GENENTECH_CODE = 'GNE';
    private static Integer                                    EVENTS_LIST_SIZE = 1000;
    public transient static Map<String, VDST_Mapping_gne__c>  mappingMap = VDST_Mapping_gne__c.getAll();
    // User Data
    public String                                             usrName          { get; set; }
    public String                                             today            { get; set; }
    // Provisioning
    public static VDST_Utils.PrivilegesWrapper                staticPrivileges = new VDST_Utils.PrivilegesWrapper();

    /** @date 3/5/2013
    * @Author Pawel Sprysak
    * @description Constructor for Controller
    */
    public VDST_EventListController() {
        setPageFields();
    }

    /** @date 5/7/2015
    * @Author Konrad Malinowski
    * @description Check Permissions
    */
    public PageReference checkPermissionsForEdmLandingPage() {
        Boolean isGsspPermisssionSetAssigned = false;
        Boolean isEdmPermisssionSetAssigned = false;
        for(PermissionSetAssignment psa : [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId()
            AND (PermissionSet.Name = :VDST_Utils.VDST_PERMISSION_SET_NAME OR PermissionSet.Name LIKE 'EDM%')
        ]) {
            if (psa.PermissionSet.Name.equalsIgnoreCase(VDST_Utils.VDST_PERMISSION_SET_NAME)) {
                isGsspPermisssionSetAssigned = true;
            }
            if (psa.PermissionSet.Name.startsWithIgnoreCase('EDM')) {
                isEdmPermisssionSetAssigned = true;
            }
        }
        if (isEdmPermisssionSetAssigned) {
            if (!isGsspPermisssionSetAssigned) {
                VDST_Settings__c settings = VDST_Utils.getCustomSettingsIntExt();
                PageReference pr = new PageReference('/apex/' + settings.EDM_Landing_Page_gne__c);
                pr.setRedirect(true);
                return pr;
            }
        }
        return null;
    }

    /** @date 3/5/2013
    * @Author Marcin Pawlak
    * @description Set User Data variables
    */
    private void setPageFields() {
        usrName = UserInfo.getName();
        today = Date.today().format();
    }

    /** @date 10/11/2013
    * @Author Pawel Sprysak
    * @description Static getter for Privileges
    */
    public static VDST_Utils.PrivilegesWrapper getStaticPrivileges() {
        return staticPrivileges;
    }

    /** @date 3/5/2013
    * @Author Marcin Pawlak
    * @description Logout method
    * @return PageReference
    */
    public PageReference logOut() {
        PageReference pr = new PageReference('/secur/logout.jsp');
        return pr.setRedirect(true);
    }

    /** @date 6/13/2013
    * @Author Pawel Sprysak
    * @description Go to User Management Page
    * @return PageReference
    */
    public PageReference goToUserManagement() {
        PageReference pr = new PageReference('/apex/VDST_Users_Management');
        pr.setRedirect(true);
        return pr;
    }

/***** Data Management *****/
    /** @date 9/9/2013
    * @Author Pawel Sprysak
    * @description Data Management - Remote Method for removing Events by Id's
    * @return String
    */
    @RemoteAction
    global static Boolean removeEventsById(String jsonValue) {
        return VDST_Utils.getEventsFromJSONToRemove(jsonValue);
    }

    /** @date 8/29/2013
    * @Author Pawel Sprysak
    * @description Data Management - Remote method for getting Event Data (with no filter data)
    * @return List<EventDataWrapper>
    */
    @RemoteAction
    global static EventDataWrapper getDataWrapperRemote(){
        return new EventDataWrapper(querySites(new List<JSONParsedObject>()));
    }

    /** @date 8/29/2013
    * @Author Pawel Sprysak
    * @description Data Management - Remote method for getting Event Data
    * @return List<EventDataWrapper>
    */
    @RemoteAction
    global static EventDataWrapper getDataWrapperByFilterRemote(String filterJSONData) {
        return new EventDataWrapper(querySites(customDeserialize(filterJSONData)));
    }

    /** @date 9/10/2013
    * @Author Pawel Sprysak
    * @description Data Management - Method for converting JSON input to Parsed Objects
    * @param String inputJSON
    * @return List<JSONParsedObject>
    */
    private static List<JSONParsedObject> customDeserialize(String inputJSON){
        List<JSONParsedObject> returnList = new List<JSONParsedObject>();
        Map<String, Object> filterMap = (Map<String, Object>)JSON.deserializeUntyped(inputJSON);
        for(String key : filterMap.keySet()) {
            if(!(filterMap.get(key) instanceof String)){
                Map<String, Object> filterMap2 = (Map<String, Object>)filterMap.get(key);
                JSONParsedObject parsedObject = new JSONParsedObject(key, '', (String)filterMap2.get('from'), (String)filterMap2.get('to'));
                returnList.add(parsedObject);
            } else {
                JSONParsedObject parsedObject = new JSONParsedObject(key, (String)filterMap.get(key), '', '');
                returnList.add(parsedObject);
            }
        }
        return returnList;
    }

    /** @date 8/29/2013
    * @Author Pawel Sprysak
    * @description Data Management - Method for getting list of Events, Sites and Addresses
    * @param Map<String, String> queryCriteria (Map with citeria for query)
    * @return List<VDST_EventSite_gne__c>
    */
    private static List<VDST_EventSite_gne__c> querySites(List<JSONParsedObject> queryCriteria) {
        String queryString = 'SELECT Id, VDST_Event_gne__r.LastModifiedBy.Name, VDST_Event_gne__r.LastModifiedByName_gne__c, VDST_Event_gne__r.LastModifiedDate, ' +
	            'VDST_Event_gne__r.CreatedDate, VDST_Event_gne__c, EventSiteName_gne__c, VDST_Address_gne__r.AddressType_gne__c, ' +
	            'VDST_Address_gne__r.City_gne__c, VDST_Address_gne__r.Country_gne__c, VDST_Address_gne__r.PostalCode_gne__c, ' +
	            'VDST_Address_gne__r.StateProvince_gne__c, VDST_Address_gne__r.StreetAddress_gne__c, ' +
	            'VDST_Event_gne__r.VendorEventID_gne__c, VDST_Event_gne__r.TotalEventSpend_gne__c, ' +
	            'VDST_Event_gne__r.TotalPlannedAttendeeCount_gne__c, VDST_Event_gne__r.GNE_EventID_gne__c, ' +
	            'VDST_Event_gne__r.EventType_gne__c, VDST_Event_gne__r.EventMeetingName_gne__c, ' +
	            'VDST_Event_gne__r.InvitationSentDate_gne__c, VDST_Event_gne__r.EventStartDate_gne__c, ' +
	            'VDST_Event_gne__r.EventEndDate_gne__c, VDST_Event_gne__r.CurrentStatusDate_gne__c, ' +
	            'VDST_Event_gne__r.CurrentStatus_gne__c, VDST_Event_gne__r.LogisticVendorCode_gne__c, ' +
	            'VDST_Event_gne__r.ContentVendorCode_gne__c, VDST_Event_gne__r.MealLoc_gne__c ' +
            'FROM VDST_EventSite_gne__c ';
        String wherePart = 'WHERE VDST_Event_gne__r.Name != null AND VDST_Event_gne__r.CurrentStatus_gne__c != \'DROPPED\' ' +
            ' AND ( VDST_Event_gne__r.VDST_BatchFile_gne__c = null OR VDST_Event_gne__r.VDST_BatchFile_gne__r.Status_frm_gne__c = \'Stored\' ) AND VDST_Event_gne__r.IsABMevent_gne__c=FALSE ' ;
        if(!staticPrivileges.isGene) {
        	wherePart += ' AND VDST_Event_gne__r.LogisticVendorCode_gne__c = \'' + staticPrivileges.providerCode + '\' ';
        	if(!staticPrivileges.isProxy) {
                Map<String, String> excludeMap = VDST_Utils.getOnlyGenentechEventTypes();
	            for(String key : excludeMap.keySet()) {
	                wherePart += ' AND VDST_Event_gne__r.EventType_gne__c != \'' + excludeMap.get(key) + '\' ';
	            }
        	}
        }
        for(JSONParsedObject criteriaObject : queryCriteria) {
            if(!String.isBlank(criteriaObject.filterName)) {
                String preObject = createFieldToObjectMap().get(criteriaObject.filterName);
                String postField = '';
                String filterName = criteriaObject.filterName;
                String fromValue = criteriaObject.fromValue;
                String toValue = criteriaObject.toValue;
                if('TransactionDate_gne'.equals(filterName)) { // Transaction and Master Dates exception
                    if(!String.isBlank(fromValue)) {
                        fromValue = removeDays(fromValue, -45);
                    }
                    if(!String.isBlank(toValue)) {
                        toValue = removeDays(toValue, -45);
                    }
                    filterName = 'EventStartDate_gne';
                    postField = '__c';
                    preObject = createFieldToObjectMap().get(filterName);
                } else if('MasterDate_gne'.equals(filterName)) {
                    if(!String.isBlank(fromValue)) {
                        fromValue = removeDays(fromValue, -7);
                    }
                    if(!String.isBlank(toValue)) {
                        toValue = removeDays(toValue, -7);
                    }
                    filterName = 'EventStartDate_gne';
                    postField = '__c';
                    preObject = createFieldToObjectMap().get(filterName);
                } else if('LastModifiedByName'.equals(filterName)) { // Standard fields exception - names
                    filterName = 'LastModifiedByName_gne__c';
                } else if('LastModifiedDate'.equals(filterName) || 'CreatedDate'.equals(filterName)) { // Standard fields exception - datetimes
                    if(!String.isBlank(fromValue)) {
                        fromValue = Datetime.parse(fromValue).formatGmt('yyyy-MM-dd') + 'T' + Datetime.parse(fromValue).formatGmt('HH:mm:ss') + 'Z';
                    }
                    if(!String.isBlank(toValue)) {
                        toValue = Datetime.parse(toValue).formatGmt('yyyy-MM-dd') + 'T' + Datetime.parse(toValue).formatGmt('HH:mm:ss') + 'Z';
                    }

                } else {
                	postField = '__c';
                }
                // Add dot after object name if needed
                if(!String.isBlank(preObject)) {
                    preObject += '.';
                } else {
                    preObject = '';
                }
                if(!String.isBlank(criteriaObject.filterValue)) {
                	String replacedWildcardFilterValue = criteriaObject.filterValue.replace('*', '%');
                    wherePart += ' AND ' + preObject + filterName + postField + ' LIKE \'' + replacedWildcardFilterValue + '\'';
                }
                if(!String.isBlank(fromValue)) {
                    wherePart += ' AND ' + preObject + filterName + postField + ' >= ' + fromValue;
                }
                if(!String.isBlank(toValue)) {
                    wherePart += ' AND ' + preObject + filterName + postField + ' <= ' + toValue;
                }
            }
        }
        // We need one more record to check, wheather we have more records or not
        queryString += wherePart + ' ORDER BY VDST_Event_gne__r.EventStartDate_gne__c DESC LIMIT ' + (EVENTS_LIST_SIZE+1);
        try {
            return DataBase.query(queryString);
        } catch(QueryException e) {
            return new List<VDST_EventSite_gne__c>();
        }
    }

    /** @date 9/6/2013
    * @Author Pawel Sprysak
    * @description Method for converting date (add/remove days functionality)
    * @param String oldDate (Date to convert)
    * @param Integer days (Number of days to add or remove from date)
    * @return String
    */
    private static String removeDays(String oldDate, Integer days) {
        oldDate += ' 00:00:00';
        DateTime dt = DateTime.valueOf(oldDate);
        dt = dt.addDays(days);
        return dt.format('yyyy-MM-dd');
    }

    /** @date 9/6/2013
    * @Author Pawel Sprysak
    * @description Method for getting map with mapping fields to objects
    * @return Map<String, String>
    */
    private static Map<String, String> createFieldToObjectMap() {
        Map<String, String> helperMap = new Map<String, String>();
        helperMap.put('AddressType_gne','VDST_Address_gne__r');
        helperMap.put('City_gne','VDST_Address_gne__r');
        helperMap.put('Country_gne','VDST_Address_gne__r');
        helperMap.put('PostalCode_gne','VDST_Address_gne__r');
        helperMap.put('StateProvince_gne','VDST_Address_gne__r');
        helperMap.put('StreetAddress_gne','VDST_Address_gne__r');

        helperMap.put('VendorEventID_gne','VDST_Event_gne__r');
        helperMap.put('TotalEventSpend_gne','VDST_Event_gne__r');
        helperMap.put('TotalPlannedAttendeeCount_gne','VDST_Event_gne__r');
        helperMap.put('GNE_EventID_gne','VDST_Event_gne__r');
        helperMap.put('EventType_gne','VDST_Event_gne__r');
        helperMap.put('EventMeetingName_gne','VDST_Event_gne__r');
        helperMap.put('InvitationSentDate_gne','VDST_Event_gne__r');
        helperMap.put('EventStartDate_gne','VDST_Event_gne__r');
        helperMap.put('EventEndDate_gne','VDST_Event_gne__r');
        helperMap.put('CurrentStatusDate_gne','VDST_Event_gne__r');
        helperMap.put('CurrentStatus_gne','VDST_Event_gne__r');
        helperMap.put('LogisticVendorCode_gne','VDST_Event_gne__r');
        helperMap.put('ContentVendorCode_gne','VDST_Event_gne__r');
        helperMap.put('LastModifiedByName','VDST_Event_gne__r');
        helperMap.put('LastModifiedDate','VDST_Event_gne__r');
        helperMap.put('CreatedDate','VDST_Event_gne__r');
        helperMap.put('MealLoc_gne','VDST_Event_gne__r');

        helperMap.put('VDST_Event_gne','');
        helperMap.put('EventSiteName_gne','');
        return helperMap;
    }

    /** @date 9/6/2013
    * @Author Pawel Sprysak
    * @description Data Management - Wrapper class for handling converted JSON data from Page
    */
    private class JSONParsedObject {
        public String filterName;
        public String filterValue;
        public String fromValue;
        public String toValue;
        public Boolean columnVisibility;

        JSONParsedObject(String filterName, String filterValue, String fromValue, String toValue, Boolean columnVisibility) {
            this(filterName, filterValue, fromValue, toValue);
            this.columnVisibility = columnVisibility;
        }

        JSONParsedObject(String filterName, String filterValue, String fromValue, String toValue) {
            this.filterName = filterName;
            this.filterValue = filterValue;
            this.fromValue = fromValue;
            this.toValue = toValue;
        }
    }

    /** @date 8/29/2013
    * @Author Pawel Sprysak
    * @description Data Management - Data holder wrapper
    */
    global class EventDataWrapper {
        public Boolean                     moreRecords     { get; set; }
        public List<EventRecordWrapper>    fieldWrappers   { get; set; }

        public EventDataWrapper(List<VDST_EventSite_gne__c> siteList) {
            moreRecords = false;
            fieldWrappers = new List<EventRecordWrapper>();
            Map<Id, Integer> evIdToEvHistRecNumMap = VDST_Utils.getEventIdToHistoryRecordNumberMap(siteList);
            for(VDST_EventSite_gne__c s : siteList){
                fieldWrappers.add( new EventRecordWrapper( s, evIdToEvHistRecNumMap.get(s.VDST_Event_gne__c) ) );
            }
            if(siteList.size() > EVENTS_LIST_SIZE) {
                moreRecords = true;
                fieldWrappers.remove(EVENTS_LIST_SIZE);
            }
        }
    }

    /** @date 8/29/2013
    * @Author Pawel Sprysak
    * @description Data Management - Data wrapper
    */
    global class EventRecordWrapper {
        // Event values
        public String              EventId                     { get; set; }
        public String              ContentVendorCode_gne       { get; set; }
        public String              LogisticVendorCode_gne      { get; set; }
        public String              CurrentStatus_gne           { get; set; }
        public String              CurrentStatusDate_gne       { get; set; }
        public String              EventEndDate_gne            { get; set; }
        public String              EventStartDate_gne          { get; set; }
        public String              TransactionDate_gne         { get; set; }
        public String              MasterDate_gne              { get; set; }
        public String              InvitationSentDate_gne      { get; set; }
        public String              EventMeetingName_gne        { get; set; }
        public String              EventType_gne               { get; set; }
        public String              GNE_EventID_gne             { get; set; }
        public String              TotalPlannedAttendeeCount_gne { get; set; }
        public String              TotalEventSpend_gne         { get; set; }
        public String              VendorEventID_gne           { get; set; }
        public String              LastModifiedByName          { get; set; }
        public String              LastModifiedDate            { get; set; }
        public String              CreatedDate                 { get; set; }
        public String              MealLoc_gne                { get; set; }
        // Address values
        public String              EventSiteName_gne           { get; set; }
        public String              AddressType_gne             { get; set; }
        public String              City_gne                    { get; set; }
        public String              Country_gne                 { get; set; }
        public String              PostalCode_gne              { get; set; }
        public String              StateProvince_gne           { get; set; }
        public String              StreetAddress_gne           { get; set; }
        public String              NumberOfEventStatusChanges  { get; set; }


        global EventRecordWrapper(VDST_EventSite_gne__c site, Integer numberOfEventStatusChanges) {
            this.EventId = String.valueOf(site.VDST_Event_gne__r.Id);
            this.TransactionDate_gne = site.VDST_Event_gne__r.EventStartDate_gne__c == null ? '' : String.valueOf(site.VDST_Event_gne__r.EventStartDate_gne__c.addDays(45));
            this.MasterDate_gne = site.VDST_Event_gne__r.EventStartDate_gne__c == null ? '' : String.valueOf(site.VDST_Event_gne__r.EventStartDate_gne__c.addDays(7));
            this.ContentVendorCode_gne = site.VDST_Event_gne__r.ContentVendorCode_gne__c;
            this.LogisticVendorCode_gne = site.VDST_Event_gne__r.LogisticVendorCode_gne__c;
            this.CurrentStatus_gne = site.VDST_Event_gne__r.CurrentStatus_gne__c;
            this.CurrentStatusDate_gne = String.valueOf(site.VDST_Event_gne__r.CurrentStatusDate_gne__c);
            this.EventEndDate_gne = String.valueOf(site.VDST_Event_gne__r.EventEndDate_gne__c);
            this.EventStartDate_gne = String.valueOf(site.VDST_Event_gne__r.EventStartDate_gne__c);
            this.InvitationSentDate_gne = String.valueOf(site.VDST_Event_gne__r.InvitationSentDate_gne__c);
            this.EventMeetingName_gne = site.VDST_Event_gne__r.EventMeetingName_gne__c;
            this.EventType_gne = site.VDST_Event_gne__r.EventType_gne__c;
            this.GNE_EventID_gne = site.VDST_Event_gne__r.GNE_EventID_gne__c;
            this.TotalPlannedAttendeeCount_gne = String.valueOf(Integer.valueOf(site.VDST_Event_gne__r.TotalPlannedAttendeeCount_gne__c));
            this.TotalEventSpend_gne = String.valueOf(site.VDST_Event_gne__r.TotalEventSpend_gne__c);
            this.VendorEventID_gne = site.VDST_Event_gne__r.VendorEventID_gne__c;
            this.LastModifiedByName = site.VDST_Event_gne__r.LastModifiedByName_gne__c;
            this.LastModifiedDate = site.VDST_Event_gne__r.LastModifiedDate.format('yyyy-MM-dd h:mm a');
            this.CreatedDate = site.VDST_Event_gne__r.CreatedDate.format('yyyy-MM-dd h:mm a');
            this.EventSiteName_gne = site.EventSiteName_gne__c;
            this.MealLoc_gne = site.VDST_Event_gne__r.MealLoc_gne__c;
            if(site.VDST_Address_gne__c != null) {
                this.AddressType_gne = site.VDST_Address_gne__r.AddressType_gne__c;
                this.City_gne = site.VDST_Address_gne__r.City_gne__c;
                this.Country_gne = site.VDST_Address_gne__r.Country_gne__c;
                this.PostalCode_gne = site.VDST_Address_gne__r.PostalCode_gne__c;
                this.StateProvince_gne = VDST_Utils.getStatesMap().get(site.VDST_Address_gne__r.StateProvince_gne__c);
                this.StreetAddress_gne = site.VDST_Address_gne__r.StreetAddress_gne__c;
            }
            this.NumberOfEventStatusChanges = String.valueOf(numberOfEventStatusChanges != null ? numberOfEventStatusChanges : 0);
        }
    }

/***** Filter Management *****/
    /** @date 9/19/2013
    * @Author Pawel Sprysak
    * @description Remote method - get user filter list
    * @return List<FilterData>
    */
    @RemoteAction
    global static List<FilterData> getFilterList() {
        List<FilterData> fdList = new List<FilterData>();
        for(VDST_Filter_gne__c filter : VDST_Utils.getUserFiltersList()) {
            fdList.add(new FilterData(filter.Id, filter.FilterName_gne__c));
        }
        return fdList;
    }

    /** @date 9/19/2013
    * @Author Pawel Sprysak
    * @description Remote method - get user filter by Id method
    * @param String dataVal (Filter Id)
    * @return FilterHolder
    */
    @RemoteAction
    global static FilterHolder getFilterDataByFilterId(String dataVal) {
        if(!String.isBlank(dataVal)) {
            Id dataId = (Id)dataVal;
            VDST_Filter_gne__c filterToShow = VDST_Utils.getUserFilterById(dataId);
            if(filterToShow == null) {
            	return null;
            }
            FilterHolder fh = new FilterHolder(filterToShow.Id, filterToShow.FilterName_gne__c, filterToShow.SortBy_gne__c, filterToShow.SortOrder_gne__c);
            // Get Filter data
            fh.fieldList = new List<JSONParsedObject>();
            for(VDST_FilterData_gne__c fd : filterToShow.VDST_Filter_Data__r) {
                fh.fieldList.add(new JSONParsedObject(fd.FilterField_gne__c, fd.FilterValue_gne__c, fd.FilterValueFrom_gne__c, fd.FilterValueTo_gne__c, fd.ColumnVisibility_gne__c));
            }
            // Get data for filter
            fh.dataObject = new EventDataWrapper(querySites(fh.fieldList));
            return fh;
        }
        return null;
    }

    /** @date 9/19/2013
    * @Author Pawel Sprysak
    * @description Remote method - removing Filter by Id
    * @param String dataVal (Filter Id)
    * @return Boolean
    */
    @RemoteAction
    global static Boolean removeFilterDataByFilterId(String dataVal) {
        if(!String.isBlank(dataVal)) {
            Id dataId = (Id)dataVal;
            return VDST_Utils.removeFilterById(dataId);
        }
        return false;
    }

    /** @date 9/19/2013
    * @Author Pawel Sprysak
    * @description Remote method - save filter Data
    * @param String filterJSONData (JSON string with filter data)
    * @return FilterData
    */
    @RemoteAction
    global static FilterData saveFilterData(String filterJSONData) {
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(filterJSONData);
        FilterHolder newFH = new FilterHolder((String)jsonMap.get('filterId'), (String)jsonMap.get('filterName'), (String)jsonMap.get('sortBy'), (String)jsonMap.get('sortOrder'));
        List<JSONParsedObject> poList = new List<JSONParsedObject>();
        for(Object value : (List<Object>) jsonMap.get('fieldList')) {
            Map<String, Object> newValue = (Map<String, Object>)value;
            poList.add(new JSONParsedObject((String)newValue.get('filterName'), (String)newValue.get('filterValue'), (String)newValue.get('fromValue'), (String)newValue.get('toValue'), Boolean.valueOf(newValue.get('columnVisibility'))));
        }
        newFH.fieldList = poList;

        return newFH.createData();
    }

    /** @date 9/19/2013
    * @Author Pawel Sprysak
    * @description Wrapped class for holding filter data
    */
    global class FilterHolder {
        public String                  filterId        { get; set; }
        public String                  filterName      { get; set; }
        public String                  sortBy          { get; set; }
        public String                  sortOrder       { get; set; }
        public List<JSONParsedObject>  fieldList       { get; set; }
        public EventDataWrapper        dataObject      { get; set; }

        public FilterHolder(String filterId, String filterName, String sortBy, String sortOrder) {
            this.filterId = filterId;
            this.filterName = filterName;
            this.sortBy = sortBy;
            this.sortOrder = sortOrder;
        }

        public FilterData createData() {
        	try {
        	    VDST_Utils.removeFilterById((Id)filterId);
            } catch(Exception e) {
                // Do nothing
            }
        	try {
        		// Create Filter/Master object
	            VDST_Filter_gne__c newFilter = new VDST_Filter_gne__c(FilterName_gne__c = filterName, FilterOwner_gne__c = UserInfo.getUserId(), SortBy_gne__c = sortBy, SortOrder_gne__c = sortOrder);
	            insert newFilter;
	            // Create Data object
	            List<VDST_FilterData_gne__c> dataList = new List<VDST_FilterData_gne__c>();
	            for(JSONParsedObject dataObject : fieldList) {
	            	dataList.add(new VDST_FilterData_gne__c(ColumnVisibility_gne__c = Boolean.valueOf(dataObject.columnVisibility), FilterField_gne__c = dataObject.filterName, FilterValue_gne__c = dataObject.filterValue, FilterValueFrom_gne__c = dataObject.fromValue, FilterValueTo_gne__c = dataObject.toValue, VDST_Filter_gne__c = newFilter.Id));
	            }
	            insert dataList;

	            return new FilterData(newFilter.Id, newFilter.FilterName_gne__c);
	        } catch(QueryException e) {
	            return null;
	        }
        }
    }
/***** Column Management *****/

    /** @date 8/28/2013
    * @Author Pawel Sprysak
    * @description Column Management - Remote method for getting Column List from VF
    * @return String
    */
    @RemoteAction
    global static InitDataWrapper getColumnsWrapperRemote() {
    	Boolean showAdboard = (staticPrivileges.isGene || staticPrivileges.isProxy) && staticPrivileges.isProvisioner;
        return new InitDataWrapper(createColumnWrappers(), getEventStatuses(), getEventTypes(!showAdboard));
    }

    /** @date 8/28/2013
    * @Author Pawel Sprysak
    * @description Column Management - CONFIGURATION Method which creates Wrapped Columns List
    * @return List<EventColumnWrapper>
    */
    private static List<EventColumnWrapper> createColumnWrappers() {
        List<EventColumnWrapper> wrapperList = new List<EventColumnWrapper>();
        // Event values
        if(staticPrivileges.isGene) { // Configuration for Genentech Users
	        wrapperList.add(new EventColumnWrapper('Action',                    'Action_gne',           'Checkbox',   true,      'none',     '',     null));
	        wrapperList.add(new EventColumnWrapper('Logistic Vendor Name',      'LogisticVendorCode_gne','Picklist',  true,      'standard', '1',    getProviderGroups()));
	        wrapperList.add(new EventColumnWrapper('Content Vendor Name',       'ContentVendorCode_gne','Picklist',   false,     'standard', '2',    getProviderGroups()));
	        wrapperList.add(new EventColumnWrapper('Vendor Event Id',           'VendorEventID_gne',    'String',     true,      'standard', '5',    null));
            wrapperList.add(new EventColumnWrapper('Last Updated',              'LastModifiedDate',     'Datetime',   true,      'standard', '3',    null));
            wrapperList.add(new EventColumnWrapper('Last Updated By',           'LastModifiedByName',   'String',     true,      'standard', '4',    null));
            wrapperList.add(new EventColumnWrapper('Event Type',                'EventType_gne',        'Picklist',   true,      'standard', '6',    getEventTypes(false)));
            wrapperList.add(new EventColumnWrapper('Meeting Name',              'EventMeetingName_gne', 'String',     true,      'standard', '7',    null));
            wrapperList.add(new EventColumnWrapper('Venue Name',                'EventSiteName_gne',    'String',     true,      'standard', '8',    null));
            wrapperList.add(new EventColumnWrapper('Current Status',            'CurrentStatus_gne',    'Picklist',   true,      'standard', '13',   getEventStatuses()));
            wrapperList.add(new EventColumnWrapper('Event Start Date',          'EventStartDate_gne',   'Date',       true,      'standard', '9',    null));
            wrapperList.add(new EventColumnWrapper('Event End Date',            'EventEndDate_gne',     'Date',       false,     'standard', '10',   null));
            wrapperList.add(new EventColumnWrapper('Master Data Due Date',      'MasterDate_gne',       'Date',       true,      'standard', '11',   null, true, 'DESC'));
            wrapperList.add(new EventColumnWrapper('Transaction Data Due Date', 'TransactionDate_gne',  'Date',       true,      'standard', '12',   null));
            wrapperList.add(new EventColumnWrapper('Created Date',              'CreatedDate',          'Datetime',   true,      'standard', '14',   null));
	        wrapperList.add(new EventColumnWrapper('Status Change Date',        'CurrentStatusDate_gne','Date',       false,     'expanded', '1',    null));
	        wrapperList.add(new EventColumnWrapper('Invitation Sent Date',      'InvitationSentDate_gne','Date',      false,     'expanded', '2',    null));
	        wrapperList.add(new EventColumnWrapper('Genentech/Roche Event Id',  'GNE_EventID_gne',      'String',     false,     'expanded', '3',    null));
	        wrapperList.add(new EventColumnWrapper('Total Planned Attendee Count','TotalPlannedAttendeeCount_gne','Number',false,'expanded', '4',    null));
	        wrapperList.add(new EventColumnWrapper('Total Spend',               'TotalEventSpend_gne',  'Decimal',    false,     'expanded', '5',    null));
            wrapperList.add(new EventColumnWrapper('Meal Location',               'MealLoc_gne',  'Picklist',    false,     'expanded', '7',    getMealLocTypes()));
	        // Address values
	        //wrapperList.add(new EventColumnWrapper('Address Type',              'AddressType_gne',      'String',     false,     'none',     '',     null));
	        //wrapperList.add(new EventColumnWrapper('Venue City',                'City_gne',             'String',     false,     'none',     '',     null));
	        //wrapperList.add(new EventColumnWrapper('Venue Country',             'Country_gne',          'String',     false,     'none',     '',     null));
	        //wrapperList.add(new EventColumnWrapper('Venue Zip/Postal Code',     'PostalCode_gne',       'String',     false,     'none',     '',     null));
	        //wrapperList.add(new EventColumnWrapper('Venue State/Province',      'StateProvince_gne',    'String',     false,     'none',     '',     null));
	        //wrapperList.add(new EventColumnWrapper('Venue Street Address',      'StreetAddress_gne',    'String',     false,     'none',     '',     null));
        } else { // Configuration for NON-Genentech Users
            wrapperList.add(new EventColumnWrapper('Action',                    'Action_gne',           'Checkbox',   true,      'none',     '',     null));
            wrapperList.add(new EventColumnWrapper('Vendor Event Id',           'VendorEventID_gne',    'String',     true,      'standard', '1',    null));
            wrapperList.add(new EventColumnWrapper('Event Type',                'EventType_gne',        'Picklist',   true,      'standard', '2',    getEventTypes(false)));
            wrapperList.add(new EventColumnWrapper('Meeting Name',              'EventMeetingName_gne', 'String',     true,      'standard', '3',    null));
            wrapperList.add(new EventColumnWrapper('Venue Name',                'EventSiteName_gne',    'String',     true,      'standard', '12',   null));
            wrapperList.add(new EventColumnWrapper('Current Status',            'CurrentStatus_gne',    'Picklist',   true,      'standard', '4',    getEventStatuses()));
            wrapperList.add(new EventColumnWrapper('Event Start Date',          'EventStartDate_gne',   'Date',       true,      'standard', '5',    null));
            wrapperList.add(new EventColumnWrapper('Event End Date',            'EventEndDate_gne',     'Date',       false,     'standard', '6',    null));
            wrapperList.add(new EventColumnWrapper('Master Data Due Date',      'MasterDate_gne',       'Date',       true,      'standard', '7',    null, true, 'DESC'));
            wrapperList.add(new EventColumnWrapper('Transaction Data Due Date', 'TransactionDate_gne',  'Date',       true,      'standard', '8',    null));
            wrapperList.add(new EventColumnWrapper('Last Updated',              'LastModifiedDate',     'Datetime',   true,      'standard', '9',    null));
            wrapperList.add(new EventColumnWrapper('Last Updated By',           'LastModifiedByName',   'String',     true,      'standard', '10',   null));
            wrapperList.add(new EventColumnWrapper('Created Date',              'CreatedDate',          'Datetime',   true,      'standard', '11',   null));
            //wrapperList.add(new EventColumnWrapper('Logistic Vendor Name',      'LogisticVendorCode_gne','String',    false,     'none',     '',     null));
            wrapperList.add(new EventColumnWrapper('Content Vendor Name',       'ContentVendorCode_gne','Picklist',   false,     'expanded', '1',    getProviderGroups()));
            wrapperList.add(new EventColumnWrapper('Status Change Date',        'CurrentStatusDate_gne','Date',       false,     'expanded', '2',    null));
            wrapperList.add(new EventColumnWrapper('Invitation Sent Date',      'InvitationSentDate_gne','Date',      false,     'expanded', '3',    null));
            wrapperList.add(new EventColumnWrapper('Genentech/Roche Event Id',  'GNE_EventID_gne',      'String',     false,     'expanded', '4',    null));
            wrapperList.add(new EventColumnWrapper('Total Planned Attendee Count','TotalPlannedAttendeeCount_gne','Number',false,'expanded', '5',    null));
            wrapperList.add(new EventColumnWrapper('Total Spend',               'TotalEventSpend_gne',  'Decimal',    false,     'expanded', '6',    null));
            wrapperList.add(new EventColumnWrapper('Meal Location',               'MealLoc_gne',  'Picklist',    false,     'expanded', '7',    getMealLocTypes()));
            // Address values
            //wrapperList.add(new EventColumnWrapper('Address Type',              'AddressType_gne',      'String',     false,     'none',     '',     null));
            //wrapperList.add(new EventColumnWrapper('Venue City',                'City_gne',             'String',     false,     'none',     '',     null));
            //wrapperList.add(new EventColumnWrapper('Venue Country',             'Country_gne',          'String',     false,     'none',     '',     null));
            //wrapperList.add(new EventColumnWrapper('Venue Zip/Postal Code',     'PostalCode_gne',       'String',     false,     'none',     '',     null));
            //wrapperList.add(new EventColumnWrapper('Venue State/Province',      'StateProvince_gne',    'String',     false,     'none',     '',     null));
            //wrapperList.add(new EventColumnWrapper('Venue Street Address',      'StreetAddress_gne',    'String',     false,     'none',     '',     null));
        }
        return wrapperList;
    }

    /** @date 9/6/2013
    * @Author Pawel Sprysak
    * @description get list of event types for picklist
    */
    public static List<FilterData> getEventTypes(Boolean withoutAdboard) {
    	// Get Event Types Select Option
        List<SelectOption> tmpList = VDST_Utils.getMappedSelectOption(VDST_Event_gne__c.EventType_gne__c.getDescribe(), mappingMap);
        tmpList.sort();
        // Convert SelectOption List to FilterData list
        List<FilterData> optionList = new List<FilterData>();
        for(SelectOption tmp : tmpList) {
        	if( !(withoutAdboard && 'ADBOARD'.equals(tmp.getValue()) ) ) {
	        	if(!(VDST_Utils.getOnlyGenentechEventTypes().containsKey(tmp.getValue()) && !staticPrivileges.isGene ) || staticPrivileges.isProxy) {
	                optionList.add(new FilterData(tmp.getLabel(), tmp.getValue()));
	        	}
        	}
        }
        return optionList;
    }

    /** @date 9/12/2013
    * @Author Pawel Sprysak
    * @description Get list of event types for picklist
    */
    public static List<FilterData> getEventStatuses() {
        // Get Event Types Select Option
        List<SelectOption> tmpList = VDST_Utils.getMappedSelectOption(VDST_Event_gne__c.CurrentStatus_gne__c.getDescribe(), mappingMap);
        tmpList.sort();
        // Convert SelectOption List to FilterData list
        List<FilterData> optionList = new List<FilterData>();
        for(SelectOption tmp : tmpList) {
        	if(!'DROPPED'.equals(tmp.getValue())) {
                optionList.add(new FilterData(tmp.getLabel(), tmp.getValue()));
        	}
        }
        return optionList;
    }

    /** @date 10/11/2013
    * @Author Pawel Sprysak
    * @description Get list of provider groups
    */
    public static List<FilterData> getProviderGroups() {
        List<FilterData> filterList = new List<FilterData>();
        for(VDST_EventProvider_gne__c ep : VDST_Utils.getVendorCodeMappings()) {
            filterList.add(new FilterData(ep.VendorName_gne__c, ep.VendorCode_gne__c));
        }
        return filterList;
    }

    public static List<FilterData> getMealLocTypes() {
        List<SelectOption> tmpList = VDST_Utils.getMappedSelectOption(VDST_Event_gne__c.MealLoc_gne__c.getDescribe(), mappingMap);
        tmpList.sort();
        // Convert SelectOption List to FilterData list
        List<FilterData> optionList = new List<FilterData>();
        for(SelectOption tmp : tmpList) {
            if(!'DROPPED'.equals(tmp.getValue())) {
                optionList.add(new FilterData(tmp.getLabel(), tmp.getValue()));
            }
        }
        return optionList;
    }

    /** @date 9/6/2013
    * @Author Pawel Sprysak
    * @description Wrapper for Picklist values
    */
    global class FilterData {
        public String filterName;
        public String filterValue;

        public FilterData(String filterName, String filterValue) {
            this.filterName = filterName;
            this.filterValue = filterValue;
        }
    }

    /** @date 9/12/2013
    * @Author Pawel Sprysak
    * @description Wrapper for Picklist values
    */
    global class InitDataWrapper {
        public List<EventColumnWrapper> columnList;
        public List<FilterData> quickList;
        public List<FilterData> eventTypesList;

        public InitDataWrapper(List<EventColumnWrapper> columnList, List<FilterData> quickList, List<FilterData> eventTypesList) {
            this.columnList     = columnList;
            this.quickList      = quickList;
            this.eventTypesList = eventTypesList;
        }
    }

    /** @date 8/28/2013
    * @Author Pawel Sprysak
    * @description Column Management - Wrapped Class for keeping data about each column on Events List Page
    */
    global class EventColumnWrapper {
        public String      header          { get; set; }
        public String      apiName         { get; set; }
        public String      columnType      { get; set; }
        public Boolean     defaultVisible  { get; set; }
        public String      filterType      { get; set; }
        public String      filterOrder     { get; set; }
        public List<FilterData> picklist { get; set; }
        public Boolean     sortBy          { get; set; }
        public String      sortOrder       { get; set; }

        public EventColumnWrapper(String header, String apiName, String columnType, Boolean defaultVisible, String filterType, String filterOrder, List<FilterData> picklist) {
            this.header = header;
            this.apiName = apiName;
            this.columnType = columnType;
            this.defaultVisible = defaultVisible;
            this.filterType = filterType;
            this.filterOrder = filterOrder;
            this.picklist = picklist;
        }

        public EventColumnWrapper(String header, String apiName, String columnType, Boolean defaultVisible, String filterType, String filterOrder, List<FilterData> picklist, Boolean sortBy, String sortOrder) {
            this(header, apiName, columnType, defaultVisible, filterType, filterOrder, picklist);
            this.sortBy = sortBy;
            this.sortOrder = sortOrder;
        }
    }
}