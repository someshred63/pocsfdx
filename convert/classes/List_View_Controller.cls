public with sharing class List_View_Controller {

    public String selectedViewId { get; set; }
    private View_Config_gne__c selectedView;
    private List_View_Settings_gne__c settings;

    public String objectType {
        get;
        set {
            objectType = value;
            initView();
        }
    }

    public String deleteRecordId { get; set; }
    public String referenceField { get; set; }
    public String nameOfThePage { get; set; }
    public Boolean sortingEnabled { get; set; }
    public Boolean checkboxesEnabled { get; set; }
    public Boolean editEnabled { get; set; }
    public Boolean deleteEnabled { get; set; }
    public Boolean cancelEnabled { get; set; }
    public Boolean duplicateEnabled { get; set; }
    public Boolean editViewEnabled { get; set; }
    public Boolean editEnabledCalc { get; set; }
    public Boolean deleteEnabledCalc { get; set; }
    public Boolean isActivity { get; set; }
    public String editURL { get; set; }
    public Boolean renderSelectViews {
        get {
            return String.isBlank(idsString);
        }
    }

    public List<SelectOption> views { get; set; }
    private List<View_Config_gne__c> visibleViews { get; set; }
    private String queryString { get; set; }

    public Map<String, String> columnHeaders { get; set; }
    public Map<String, Boolean> columnSortable { get; set; }
    public List<ListItemWrapper> records { get; set; }
    public List<String> visibleColumns { get; set; }
    public List<String> filterStatements { get; set; }

    //sorting related variables
    public String sortColumn { get; set; }
    public String sortDirection { get; set; }

    private String oldSortColumn { get; set; }
    private String defaultSortOrder = 'ASC';
    public Set<Id> selectedRecords;

    // override user reference fields
    public Map<String, String> fieldOfUserReferenceMap { get; set; }
    public Map<String, Boolean> userReferenceHasExist { get; set; }
    public String userIdToViewLink { get; set; }

    public Map<Integer, Boolean> pageNumberButtons { get; set; } // Reflects page number buttons
    public Integer pageNumber { get; set; }
    public Integer pageNumbers { get; set; }
    public Integer recordsCount { get; private set; }

    public Boolean hasNext { get; set; }
    public Boolean hasPrevious { get; set; }

    public Boolean maxRecordsReached { get; set; }
    public List_View_Base_Controller baseListController { get; set; }

    public String idsString { get; set; }
    private List<String> cachedObjectsIds; // explicit for CUSTOM_FILTER used in EMS_Search_Output page

    private static User_Views_History_gne__c userViewsHistory;
    private static Integer PAGE_SIZE = 50;
    private static Integer MAX_RECORDS_COUNT = 1000;

    private Object customFilterVariable_1;
    private Object customFilterVariable_2;
    private Object customFilterVariable_3;
    private Object customFilterVariable_4;
    private Object customFilterVariable_5;
    private Object customFilterVariable_6;
    private Object customFilterVariable_7;
    private Object customFilterVariable_8;
    private Object customFilterVariable_9;
    private Object customFilterVariable_10;

    // Excel export variables
    public String selectedRecordsString { get; set; }
    public String sortOrderField { get; set; }
    public String sortOrder { get; set; }

    private void initView() {
        visibleViews = getViews();
        views = prepareSelectOptions(visibleViews);
        getuserViewsHistory();
        if (visibleViews.size() == 1) {
            selectedViewId = visibleViews[0].Id;
        }
        if (selectedViewId == null) {
            checkLastSeenView();
        }
        checkEditViewEnabled();
        editEnabledCalc = editEnabled && Schema.getGlobalDescribe().get(objectType).getDescribe().isUpdateable();
        deleteEnabledCalc = deleteEnabled && Schema.getGlobalDescribe().get(objectType).getDescribe().isDeletable();
    }

    public Component.Apex.Outputpanel getButtons() {
        return Configuration_Util.getCustomBootstrapButtonsOutputPanel('baseListController', objectType, 'List Page', 'Button');
    }

    private void getuserViewsHistory() {
        try {
            if (userViewsHistory == null) {
                userViewsHistory = [SELECT Last_View_Used_gne__c FROM User_Views_History_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = :nameOfThePage AND User_gne__c = :Userinfo.getUserId() limit 1];
            }
        } catch (Exception e) {
            userViewsHistory = new User_Views_History_gne__c(User_gne__c = UserInfo.getUserId());
        }
    }

    public String getPageNumberInfo() {
        return 'Page <b>' + pageNumber + '</b> of <b>' + pageNumbers + '</b> (' + recordsCount + ' Total)';
    }

    private void getColumnHeadersAndSortable(List<String> columns) {
        for (String column : columns) {
            if (column.equalsIgnoreCase('recordtypeid')) {
                columnHeaders.put(column, 'Record Type');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('owner.firstname')) {
                columnHeaders.put(column, 'Owner First Name');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('owner.lastname')) {
                columnHeaders.put(column, 'Owner Last Name');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('owner.alias')) {
                columnHeaders.put(column, 'Owner Alias');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('createdby.alias')) {
                columnHeaders.put(column, 'Created By Alias');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('createdbyid')) {
                columnHeaders.put(column, 'Created By');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('lastmodifiedby.alias')) {
                columnHeaders.put(column, 'Last Modified By Alias');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('lastmodifiedbyId')) {
                columnHeaders.put(column, 'Last Modified By');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('account.name')) {
                columnHeaders.put(column, 'Name');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('accountid')) {
                columnHeaders.put(column, 'Account ID');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('account.parentid')) {
                columnHeaders.put(column, 'Account Parent Account');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('reportstoid')) {
                columnHeaders.put(column, 'Reports To');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('reportsto.lastname')) {
                columnHeaders.put(column, 'Reports To Last Name');
                columnSortable.put(column, true);
                continue;
            } else if (column.equalsIgnoreCase('reportsto.firstname')) {
                columnHeaders.put(column, 'Reports To First Name');
                columnSortable.put(column, true);
                continue;
            }
            Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap().get(column).getDescribe();
            columnHeaders.put(column, fieldDescribe.getLabel());
            Schema.DisplayType fieldType = fieldDescribe.getType();
            if (fieldType == Schema.Displaytype.Multipicklist || fieldType == Schema.Displaytype.Textarea) {
                columnSortable.put(column, false);
            } else {
                columnSortable.put(column, true);
            }
        }
    }

    private void checkEditViewEnabled() {
        if (selectedViewId != null) {
            selectedView = getView(selectedViewId);
            if (selectedView != null && selectedView.OwnerId == Userinfo.getUserId()) {
                editViewEnabled = true;
            } else {
                try {
                    String[] privilegedProfiles = null;
                    if (settings != null && settings.Privileged_Profiles_gne__c != null) {
                        privilegedProfiles = settings.Privileged_Profiles_gne__c.split(',');
                    }
                    String profileName = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()].Name;
                    if (privilegedProfiles != null) {
                        for (String name: privilegedProfiles) {
                            if (profileName == name) {
                                editViewEnabled = true;
                            }
                        }
                    }
                } catch (Exception e) {
                    editViewEnabled = false;
                }
            }
        }
    }


    public List_View_Controller() {
        maxRecordsReached = false;
        sortDirection = null;
        pageNumber = 1;
        pageNumbers = 1;
        recordsCount = 0;
        columnHeaders = new Map<String, String>();
        columnSortable = new Map<String, Boolean>();
        isActivity = false;
        pageNumberButtons = new Map<Integer, Boolean>();
        try {
            if (settings == null) {
                settings = [SELECT Page_Size_gne__c, Privileged_Profiles_gne__c FROM List_View_Settings_gne__c LIMIT 1];
            }
        } catch (Exception e) {
            settings = new List_View_Settings_gne__c(Page_Size_gne__c = 50, Privileged_Profiles_gne__c = '');
        }
        PAGE_SIZE = settings.Page_Size_gne__c.intValue();
    }

    public PageReference exportToExcel() {
        PageReference pageref = new PageReference('/apex/EMS_List_Excel_Export');
        String whereclauses = String.join(getFiltersBySelectedView(selectedView), ' AND ');

        if (selectedRecordsString == null) selectedRecordsString = '';

        if (String.isBlank(selectedRecordsString)) {
            selectedRecordsString += ',' + String.valueOf(idsString);
        }

        selectedRecordsString = selectedRecordsString.removeEnd(',null').removeEnd(',').remove('null');

        pageref.getParameters().put('ids', selectedRecordsString);
        pageref.getParameters().put('viewId', selectedViewId);
        pageref.getParameters().put('where', whereclauses);
        pageref.getParameters().put('fn', baseListController.getListPageName());
        pageref.getParameters().put('srtf', sortOrderField);
        pageref.getParameters().put('srto', sortOrder);

        pageref.setredirect(true);
        return pageref;
    }

    private void updateLastSeenView() {
        userViewsHistory.Last_View_Used_gne__c = selectedViewId;
        upsert userViewsHistory;
    }

    public PageReference changeSelectedView() {
        editViewEnabled = false;
        sortColumn = null;
        oldSortColumn = null;
        sortDirection = null;
        pageNumber = 1;
        selectedView = getView(selectedViewId);
        loadRecords();
        updateLastSeenView();
        checkEditViewEnabled();
        baseListController.setSelectedView(selectedViewId);
        return null;
    }

    private View_Config_gne__c getView(String viewId) {
        if (selectedViewId != null && selectedViewId != '') {
            return [SELECT OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Records_Visibility__c, Object_Type_gne__c FROM View_Config_gne__c WHERE Id = :selectedViewId];
        } else {
            return null;
        }
    }

    public static Map<String, Id> costCenterMap {
        get {
            if (costCenterMap == null) {
                costCenterMap = new Map<String, Id>();
                for (EMS_Cost_Center_gne__c cc : [SELECT Name FROM EMS_Cost_Center_gne__c LIMIT 5000]) {
                    costCenterMap.put(cc.Name, cc.Id);
                }
            }
            return costCenterMap;
        }
    }

    private String buildCountQueryString(View_Config_gne__c view) {
        visibleColumns = getViewColumnsByselectedView(view);
        filterStatements = getFiltersBySelectedView(view);
        getColumnHeadersAndSortable(visibleColumns);
        String countQueryString = 'SELECT COUNT() FROM ' + objectType;
        if (filterStatements.size() > 0 || view.Records_Visibility__c == 'My Records') {
            countQueryString += ' WHERE ';
            if (objectType.equals('Speaker_Bureau_Membership_gne__c') && view.Records_Visibility__c == 'My Records') {
                countQueryString += ' Speaker_Bureau_ID_gne__r.ownerid = \'' + UserInfo.getUserId() + '\' AND ';
            }
            if (objectType.equals('ART_Issue_gne__c') && view.Records_Visibility__c == 'My Records') {
                countQueryString += ' ART_Site_Local_gne__r.ownerid = \'' + UserInfo.getUserId() + '\' AND ';
            }
            if ((!objectType.equals('Speaker_Bureau_Membership_gne__c') && !objectType.equals('ART_Issue_gne__c')) && view.Records_Visibility__c == 'My Records') {
                countQueryString += ' OwnerId = \'' + UserInfo.getUserId() + '\' AND ';
            }
            for (String filterColumn : filterStatements) {
                countQueryString += getFilterStatement(filterColumn);
            }
            countQueryString = countQueryString.removeEnd(' AND ');
        }

        if ((objectType.equals('Task') || objectType.equals('Event')) && (view.Records_Visibility__c == 'All Records')) {
            isActivity = true;
            if (!countQueryString.contains('WHERE')) {
                countQueryString += ' WHERE OwnerId =\'' + UserInfo.getUserId() + '\' ';
            } else {
                countQueryString += 'AND OwnerId = \'' + UserInfo.getUserId() + '\' ';
            }
        }
        countQueryString += ' LIMIT ' + MAX_RECORDS_COUNT;
        return countQueryString;
    }

    private String buildQueryString(View_Config_gne__c view) {
        Map<String, Schema.SObjectField> sObjectFieldMap = prepareObjectTypeFieldsMap(objectType);
        Set<String> uniqueViewColumns = new Set<String>();
        fieldOfUserReferenceMap = new Map<String, String>();
        userReferenceHasExist = new Map<String, Boolean>();

        visibleColumns = getViewColumnsByselectedView(view);
        uniqueViewColumns.addAll(visibleColumns);
        filterStatements = getFiltersBySelectedView(view);
        getColumnHeadersAndSortable(visibleColumns);
        queryString = 'SELECT ';

        for (String viewField : visibleColumns) {
            queryString += viewField + ', ';
            prepareFieldOfUserReferenceMaps(sObjectFieldMap, viewField);
        }

        if (!uniqueViewColumns.contains('CreatedDate') && !uniqueViewColumns.contains('createddate')) {
            queryString += 'CreatedDate, ';
        }
        if (!uniqueViewColumns.contains('LastModifiedDate') && !uniqueViewColumns.contains('lastmodifieddate')) {
            queryString += 'LastModifiedDate, ';
        }

        if (queryString == 'SELECT ') {
            queryString += 'Id, ';
        }
        queryString = queryString.removeEnd(', ');
        queryString += ' FROM ' + objectType;

        if (filterStatements.size() > 0 || view.Records_Visibility__c == 'My Records') {
            queryString += ' WHERE ';
            if (objectType.equals('Speaker_Bureau_Membership_gne__c') && view.Records_Visibility__c == 'My Records') {
                queryString += ' Speaker_Bureau_ID_gne__r.ownerid = \'' + UserInfo.getUserId() + '\' AND ';
            }
            if (objectType.equals('ART_Issue_gne__c') && view.Records_Visibility__c == 'My Records') {
                queryString += ' ART_Site_Local_gne__r.ownerid = \'' + UserInfo.getUserId() + '\' AND ';
            }
            if ((!objectType.equals('Speaker_Bureau_Membership_gne__c') && !objectType.equals('ART_Issue_gne__c')) && view.Records_Visibility__c == 'My Records') {
                queryString += ' OwnerId = \'' + UserInfo.getUserId() + '\' AND ';
            }
            for (String filterColumn : filterStatements) {
                queryString += getFilterStatement(filterColumn);
            }
            queryString = queryString.removeEnd(' AND ');
        }

        if ((objectType.equals('Task') || objectType.equals('Event')) && (view.Records_Visibility__c == 'All Records')) {
            if (!queryString.contains('WHERE')) {
                queryString += ' WHERE OwnerId =\'' + UserInfo.getUserId() + '\' ';
            } else {
                queryString += 'AND OwnerId = \'' + UserInfo.getUserId() + '\' ';
            }
        }

        String sortColumnSoql = sortColumn;
        if (sortColumnSoql.toLowerCase().equalsIgnoreCase('id')) {
            sortColumnSoql = 'id';
        } else if (sortColumnSoql.toLowerCase().endsWith('id') && !sortColumnSoql.contains('.')) {
            sortColumnSoql = sortColumnSoql.toLowerCase().removeEnd('id') + '.Name';
        } else if (!sortColumnSoql.contains('.')) {
            Schema.DisplayType sortColumnType = Schema.getGlobalDescribe().get(view.Object_Type_gne__c).getDescribe().fields.getMap().get(sortColumn).getDescribe().getType();
            if (sortColumnType == Schema.DisplayType.Reference && sortColumnSoql.toLowerCase().endsWith('__c')) {
                sortColumnSoql = sortColumnSoql.toLowerCase().removeEnd('__c') + '__r.Name';
            }
        }
        queryString += ' ORDER BY ' + sortColumnSoql + ' ' + sortDirection + ' NULLS LAST LIMIT ' + PAGE_SIZE + ' OFFSET ' + ((pageNumber - 1) * PAGE_SIZE);
        return queryString;
    }

    // Override Link When Field Has User Reference
    public Map<String, Schema.SObjectField> prepareObjectTypeFieldsMap(String objectType) {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType sObjectType = globalDescribeMap.get(objectType);
        Schema.DescribeSObjectResult result = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> sObjectFieldMap = result.fields.getMap();

        return sObjectFieldMap;
    }

    public void prepareFieldOfUserReferenceMaps(Map<String, Schema.SObjectField> sObjectFieldMap, String viewField) {
        if (viewField.contains('.')) {
            userReferenceHasExist.put(viewField, false);
        } else {
            try {
                Schema.SObjectField sObjectField = sObjectFieldMap.get(viewField);
                List<Schema.sObjectType> fieldReference = sObjectField.getDescribe().getReferenceTo();
                if (fieldReference.size() > 0) {
                    Set<String> referenceSet = new Set<String>();
                    for (Integer i = 0; i < fieldReference.size(); i++) {
                        referenceSet.add(String.valueOf(fieldReference[i]));
                    }
                    if (referenceSet.contains('User')) {
                        String relationName = sObjectField.getDescribe().getRelationshipName();
                        fieldOfUserReferenceMap.put(viewField, relationName + '.Name');
                        userReferenceHasExist.put(viewField, true);
                        queryString += relationName + '.Name, ';
                    } else {
                        userReferenceHasExist.put(viewField, false);
                    }
                } else {
                    userReferenceHasExist.put(viewField, false);
                }
            } catch (Exception ex) {

            }
        }
    }

    public PageReference overrideUserViewLink() {
        PageReference pageref = new PageReference('/apex/EMS_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference loadRecords() {
        try {
            if (selectedViewId != null) {
                selectedView = getView(selectedViewId);
                Set<String> columnsSet = new Set<String>(getViewColumnsByselectedView(selectedView));
                if (String.isBlank(sortColumn) || !columnsSet.contains(sortColumn)) {
                    sortColumn = selectedView.Sorting_Field_gne__c;
                }
                if (String.isBlank(oldSortColumn)) {
                    oldSortColumn = sortColumn;
                }
                if (String.isBlank(sortDirection)) {
                    if (String.isNotBlank(selectedView.Sorting_Order_gne__c)) {
                        sortDirection = selectedView.Sorting_Order_gne__c;
                    } else {
                        sortDirection = defaultSortOrder;
                    }
                }

                if (String.isNotBlank(idsString)) {
                    cachedObjectsIds = idsString.split(',');
                }

                records = wrapResults(Database.query(buildQueryString(selectedView)));
                recordsCount = countRecords(selectedView);
                pageNumbers = countPageNumbers();

                // Set page number buttons
                pupulatePageNumberButtons();

                hasNext = (pageNumber < pageNumbers);
                hasPrevious = (pageNumber > 1);
            }
        } catch (Exception e) {
            records = new List<ListItemWrapper>();
            recordsCount = 0;
            pageNumbers = 1;
            pageNumberButtons = new Map<Integer, Boolean>{
                    pageNumbers => false
            };
            hasNext = false;
            hasPrevious = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during record loading. Please redefine selected view'));
            ApexPages.addMessages(e);
            System.debug(e);
        }
        return null;
    }

    private void pupulatePageNumberButtons() {
        pageNumberButtons.clear();
        Boolean renderNext = false;
        for (Integer bNumber = 1; bNumber <= pageNumbers; bNumber++) {
            if (bNumber == 1) {
                pageNumberButtons.put(bNumber, true);// always render first page button

                if (pageNumber == 1) { // if current page is the first page, render next one to it
                    renderNext = true;
                } else {
                    renderNext = false;
                }
            } else if (bNumber == pageNumbers) {
                pageNumberButtons.put(bNumber, true);// always render last page button

                if (pageNumber == pageNumbers) { // if current page is the last page, render previous two before it
                    if (pageNumbers > 1) { // if there are more then 2 pages, render previous one
                        pageNumberButtons.put(bNumber - 1, true); // replace existing map data
                    }
                }
            } else {
                if (bNumber == pageNumber) { // if buttonNumber is currentPage (pageNumber), then render it
                    pageNumberButtons.put(bNumber, true); // always render first page button
                    renderNext = true; // next one should be rendered
                    if (pageNumbers > 1) { // render previous one
                        pageNumberButtons.put(bNumber - 1, true); // replace existing map data
                    }
                } else {
                    if (renderNext) {
                        pageNumberButtons.put(bNumber, true);
                        renderNext = false;
                    } else {
                        pageNumberButtons.put(bNumber, false);
                    }
                }
            }
        }
    }

    private String getFilterStatement(String filterColumn) {
        String query = filterColumn + ' AND ';
        return query;
    }

    private Integer countRecords(View_Config_gne__c selectedView) {
        Integer recordsCount = 0;
        if (selectedView != null) {
            recordsCount = Database.countQuery(buildCountQueryString(selectedView));
            if (recordsCount == MAX_RECORDS_COUNT) {
                maxRecordsReached = true;
            } else {
                maxRecordsReached = false;
            }

            if (recordsCount == 0) {
                pageNumber = 1;
            }
        } else {
            maxRecordsReached = false;
            pageNumber = 1;
        }
        return recordsCount;
    }

    public Integer countPageNumbers() {
        return recordsCount == 0 ? 1 : Math.ceil(recordsCount / (PAGE_SIZE * 1.0)).intValue();
    }

    // get view columns basing on the selected view
    private List<String> getViewColumnsBySelectedView(View_Config_gne__c selectedView) {
        List<String> columns = new List<String>();
        if (selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != '') {
            columns = selectedView.View_Fields_gne__c.split(';', 0);
        }
        return columns;
    }

    // get filters basing on the selected view
    private List<String> getFiltersBySelectedView(View_Config_gne__c selectedView) {
        List<String> filters = new List<String>();
        if (selectedView.Filter_Statement_gne__c != null && selectedView.Filter_Statement_gne__c != '') {
            List<List_View_Setup_Ext.ConditionItem>conditionItems = (List<List_View_Setup_Ext.ConditionItem>) JSON.deserializeStrict(selectedView.Filter_Statement_gne__c, List<List_View_Setup_Ext.ConditionItem>.class);
            for (Integer i = 0; i < conditionItems.size(); i++) {
                List_View_Setup_Ext.ConditionItem conditionItem = conditionItems.get(i);
                String fieldName = conditionItem.field;
                String filterExpr = fieldName;
                String datePeriod = '';

                // Decode next and last filters
                if (conditionItem.operator.startsWith('next_') || conditionItem.operator.startsWith('last_')) {
                    List<String> split = conditionItem.operator.split('_');
                    conditionItem.operator = split.get(0);
                    datePeriod = split.get(1);
                }

                if (conditionItem.valueType == 'PICKLIST') {
                    if (conditionItem.operator == 'inc') {
                        filterExpr += ' IN ' + Configuration_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    } else if (conditionItem.operator == 'ecl') {
                        filterExpr += ' NOT IN ' + Configuration_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    }
                } else if (conditionItem.valueType == 'MULTIPICKLIST') {
                    if (conditionItem.operator == 'inc') {
                        filterExpr += ' INCLUDES ' + Configuration_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    } else if (conditionItem.operator == 'ecl') {
                        filterExpr += ' EXCLUDES ' + Configuration_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    }
                } else if (conditionItem.valueType == 'BOOLEAN') {
                    if (conditionItem.operator == 'eq') {
                        filterExpr += ' = ' + conditionItem.value;
                    } else if (conditionItem.operator == 'ne') {
                        filterExpr += ' != ' + conditionItem.value;
                    }

                } else if (conditionItem.valueType == 'STRING' || conditionItem.valueType == 'EMAIL' || conditionItem.valueType == 'URL' || conditionItem.valueType == 'PHONE' || conditionItem.valueType == 'REFERENCE' || conditionItem.valueType == 'COMBOBOX') {
                    if (conditionItem.valueType == 'REFERENCE' && conditionItem.value == 'CURRENT_USER') {
                        conditionItem.value = UserInfo.getUserId();
                    }

                    if (conditionItem.operator == 'eq') {
                        filterExpr += ' = \'' + String.escapeSingleQuotes(conditionItem.value) + '\'';
                    } else if (conditionItem.operator == 'ne') {
                        filterExpr += ' != \'' + String.escapeSingleQuotes(conditionItem.value) + '\'';
                    } else if (conditionItem.operator == 'lt') {
                        filterExpr += ' < \'' + String.escapeSingleQuotes(conditionItem.value) + '\'';
                    } else if (conditionItem.operator == 'lte') {
                        filterExpr += ' <= \'' + String.escapeSingleQuotes(conditionItem.value) + '\'';
                    } else if (conditionItem.operator == 'gt') {
                        filterExpr += ' > \'' + String.escapeSingleQuotes(conditionItem.value) + '\'';
                    } else if (conditionItem.operator == 'gte') {
                        filterExpr += ' >= \'' + String.escapeSingleQuotes(conditionItem.value) + '\'';
                    } else if (conditionItem.operator == 'c') {
                        filterExpr += ' LIKE \'%' + String.escapeSingleQuotes(conditionItem.value) + '%\'';
                    } else if (conditionItem.operator == 'nc') {
                        filterExpr = '(NOT ' + +conditionItem.field + ' LIKE \'%' + String.escapeSingleQuotes(conditionItem.value) + '%\')';
                    } else if (conditionItem.operator == 'sw') {
                        filterExpr += ' LIKE \'' + String.escapeSingleQuotes(conditionItem.value) + '%\'';
                    }
                } else if (conditionItem.valueType == 'CUSTOM_FILTER') {
                    filterExpr = baseListController.getCustomFilterExpression(conditionItem);
                    if (String.isBlank(filterExpr)) {
                        continue;
                    }
                } else {
                    String value = '';
                    boolean do_not_split = false;
                    Boolean needQuotes = true;
                    try {
                        if (conditionItem.valueType == 'DOUBLE' || conditionItem.valueType == 'PERCENT') {
                            value = Double.valueOf(conditionItem.value).format();
                            needQuotes = false;
                        } else if (conditionItem.valueType == 'CURRENCY') {
                            value = conditionItem.value;
                            needQuotes = false;
                        } else if (conditionItem.valueType == 'INTEGER') {
                            value = Integer.valueOf(conditionItem.value).format();
                            needQuotes = false;
                        } else if (conditionItem.valueType == 'DATE' && (conditionItem.operator == 'next' || conditionItem.operator == 'last')) {
                            value = Integer.valueOf(conditionItem.value).format();
                            needQuotes = false;
                        } else if (conditionItem.valueType == 'DATETIME' && (conditionItem.operator == 'next' || conditionItem.operator == 'last')) {
                            value = Integer.valueOf(conditionItem.value).format();
                            needQuotes = false;
                        } else if (conditionItem.valueType == 'DATE') {
                            if (conditionItem.value.equals('TODAY')) {
                                String currentDate_T = String.valueOf(System.today());
                                String[] today_Parts = currentDate_T.split('-');
                                conditionItem.value = today_Parts[1] + '/' + today_Parts[2] + '/' + today_Parts[0];
                            }

                            String[] dateParts = conditionItem.value.split('/');
                            DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                            value = dtime.format('yyyy-MM-dd');
                            needQuotes = false;
                        } else if (conditionItem.valueType == 'DATETIME') {
                            if (conditionItem.value.equals('TODAY')) {
                                String currentDate_T = String.valueOf(System.today());
                                String[] today_Parts = currentDate_T.split('-');
                                conditionItem.value = today_Parts[1] + '/' + today_Parts[2] + '/' + today_Parts[0];
                            } else if (conditionItem.value.contains('_N_DAYS')) {
                                //do not split
                                do_not_split = true;
                            }
                            String[] dateParts = conditionItem.value.split('/');
                            //if field is datetime only date part is compared

                            filterExpr = String.format('DAY_ONLY(CONVERTTIMEZONE({0}))', new String[]{
                                    filterExpr
                            });
                            if (!do_not_split) {
                                DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 0, 0, 0);
                                value = dtime.format('yyyy-MM-dd');
                            } else {
                                value = conditionItem.value;
                            }
                            needQuotes = false;
                        } else if (conditionItem.valueType == 'ID') {
                            Id tmpId = conditionItem.value;
                            value = tmpId;
                        } else {
                            value = conditionItem.value;
                        }
                    } catch (Exception e) {
                        //TODO: implement
                    }

                    if (conditionItem.operator == 'eq') {
                        filterExpr += ' = ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'ne') {
                        filterExpr += ' != ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'lt') {
                        filterExpr += ' < ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'lte') {
                        filterExpr += ' <= ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'gt') {
                        filterExpr += ' > ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'gte') {
                        filterExpr += ' >= ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'next') {
                        if (datePeriod == 'days') {
                            filterExpr += ' = NEXT_N_DAYS:' + (needQuotes ? ('\'' + value + '\'') : value);
                        } else if (datePeriod == 'months') {
                            if (conditionItem.valueType == 'DATE') {
                                Date today = Date.today();
                                Date limitDate = today.addMonths(Integer.valueOf(conditionItem.value));
                                filterExpr += ' > ' + String.valueOf(today) + ' AND ' + fieldName + ' < ' + String.valueOf(limitDate); // Greter than today but less than limitDate
                            } else if (conditionItem.valueType == 'DATETIME') {
                                Datetime now = Datetime.now();
                                Datetime limitDateTime = now.addMonths(Integer.valueOf(conditionItem.value));
                                filterExpr += ' > ' + now.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' AND ' + fieldName + ' < ' + limitDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                            }
                        } else if (datePeriod == 'years') {
                            if (conditionItem.valueType == 'DATE') {
                                Date today = Date.today();
                                Date limitDate = today.addYears(Integer.valueOf(conditionItem.value));
                                filterExpr += ' > ' + String.valueOf(today) + ' AND ' + fieldName + ' < ' + String.valueOf(limitDate);
                            } else if (conditionItem.valueType == 'DATETIME') {
                                Datetime now = Datetime.now();
                                Datetime limitDateTime = now.addYears(Integer.valueOf(conditionItem.value));
                                filterExpr += ' > ' + now.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' AND ' + fieldName + ' < ' + limitDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                            }
                        }
                    } else if (conditionItem.operator == 'last') {
                        if (datePeriod == 'days') {
                            filterExpr += ' = LAST_N_DAYS:' + (needQuotes ? ('\'' + value + '\'') : value);
                        } else if (datePeriod == 'months') {
                            if (conditionItem.valueType == 'DATE') {
                                Date today = Date.today();
                                Date limitDate = today.addMonths(Integer.valueOf(conditionItem.value));
                                filterExpr += ' < ' + String.valueOf(today) + ' AND ' + fieldName + ' > ' + String.valueOf(limitDate); // Less than today but greater than limitDate
                            } else if (conditionItem.valueType == 'DATETIME') {
                                Datetime now = Datetime.now();
                                Datetime limitDateTime = now.addMonths(Integer.valueOf(conditionItem.value) * -1);
                                filterExpr += ' < ' + now.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' AND ' + fieldName + ' > ' + limitDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                            }
                        } else if (datePeriod == 'years') {
                            if (conditionItem.valueType == 'DATE') {
                                Date today = Date.today();
                                Date limitDate = today.addYears(Integer.valueOf(conditionItem.value));
                                filterExpr += ' < ' + String.valueOf(today) + ' AND ' + fieldName + ' > ' + String.valueOf(limitDate);
                            } else if (conditionItem.valueType == 'DATETIME') {
                                Datetime now = Datetime.now();
                                Datetime limitDateTime = now.addYears(Integer.valueOf(conditionItem.value) * -1);
                                filterExpr += ' < ' + now.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') + ' AND ' + fieldName + ' > ' + limitDateTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
                            }
                        }
                    }
                }
                filters.add(filterExpr);
            }
        }

        populateCustomFilterVariables();
        return filters;
    }

    private void populateCustomFilterVariables() {
        customFilterVariable_1 = baseListController.customFilterVariable_1;
        customFilterVariable_2 = baseListController.customFilterVariable_2;
        customFilterVariable_3 = baseListController.customFilterVariable_3;
        customFilterVariable_4 = baseListController.customFilterVariable_4;
        customFilterVariable_5 = baseListController.customFilterVariable_5;
        customFilterVariable_6 = baseListController.customFilterVariable_6;
        customFilterVariable_7 = baseListController.customFilterVariable_7;
        customFilterVariable_8 = baseListController.customFilterVariable_8;
        customFilterVariable_9 = baseListController.customFilterVariable_9;
        customFilterVariable_10 = baseListController.customFilterVariable_10;
    }

    static Set<Id> groupsCache = new Set<Id>();
    static Id userId;

    private static Set<Id> getUserOrGroupIdsForCurrentUser() {
        if (userId != UserInfo.getUserId()) {
            userId = UserInfo.getUserId();

            Map<Id, SObject> territories = new Map<Id, SObject>(GNE_SFA2_Util.getUserTerritories(userId));
            Map<Id, Id> groups = EMS_Util.getTerritoriesGroups(territories.keySet());

            groupsCache.clear();
            groupsCache.addAll(groups.values());
            groupsCache.add(UserInfo.getUserId());
        }

        return groupsCache;
    }

    private List<ListItemWrapper> wrapResults(List<sObject> sObjectsList) {
        String objectName = sObjectsList.getSObjectType().getDescribe().getName();
        String objectShareName = objectName.replace('__c', '__Share');

        List<ListItemWrapper> result = new List<ListItemWrapper>();

        // check if Share is enable for an Object
        if (Schema.getGlobalDescribe().containsKey(objectShareName)) {
            Set<Id> userOrGroupIds = getUserOrGroupIdsForCurrentUser();
            List<sObject> objShares = Database.query('SELECT RowCause, ParentId, AccessLevel, UserOrGroupId FROM ' + objectShareName
                    + ' WHERE ParentId IN : sObjectsList AND UserOrGroupId IN : userOrGroupIds');

            Map<Id, sObject> parentId_objSharesMap = new Map<Id, sObject>();
            for (sObject objShare : objShares) {
                String key = (String) objShare.get('ParentId');
                if (parentId_objSharesMap.containsKey(key)) {
                    String currentAccessLevel = (String) parentId_objSharesMap.get(key).get('AccessLevel');
                    String newAccessLevel = (String) objShare.get('AccessLevel');
                    if (newAccessLevel == 'All' && currentAccessLevel != 'All') {
                        // hight level of Sharing
                        parentId_objSharesMap.put(key, objShare);
                    } else if (newAccessLevel == 'Edit' && currentAccessLevel == 'Read') {
                        parentId_objSharesMap.put(key, objShare);
                    }
                } else {
                    parentId_objSharesMap.put(key, objShare);
                }
            }

            for (sObject objItem : sObjectsList) {
                if (parentId_objSharesMap.containsKey(objItem.Id)) {
                    String currentAccessLevel = (String) parentId_objSharesMap.get(objItem.Id).get('AccessLevel');
                    if (currentAccessLevel == 'All' || currentAccessLevel == 'Edit') {
                        result.add(new ListItemWrapper(objItem, false, true));
                    } else {
                        result.add(new ListItemWrapper(objItem, false, false));
                    }
                } else {
                    // this case might not exist
                    result.add(new ListItemWrapper(objItem, false));
                }
            }
        } else {
            // Sobject without share
            for (sObject objItem : sObjectsList) {
                result.add(new ListItemWrapper(objItem, false));
            }
        }

        return result;
    }

    public PageReference previousPage() {
        pageNumber--;
        return loadRecords();
    }

    public PageReference nextPage() {
        pageNumber++;
        return loadRecords();
    }

    public void goToPage() {
        // pageNumber is being set on the page
        loadRecords();
    }

    public PageReference changeSorting() {
        pageNumber = 1;
        if (sortColumn == oldSortColumn) {
            if (sortDirection == 'ASC') {
                sortDirection = 'DESC';
            } else {
                sortDirection = 'ASC';
            }
        } else {
            sortDirection = defaultSortOrder;
            oldSortColumn = sortColumn;
        }
        return loadRecords();
    }

    // prepare select options for views
    private List<SelectOption> prepareSelectOptions(List<View_Config_gne__c> views) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        if (views == null || views.isEmpty()) {
            selectOptions.add(new SelectOption('', 'No Views Defined'));
        } else {
            for (View_Config_gne__c view: views) {
                selectOptions.add(new SelectOption(view.Id, view.View_Name_gne__c));
            }
        }
        return selectOptions;
    }

    // get views defined for user
    private List<View_Config_gne__c> getViews() {
        // select all public views
        List<View_Config_gne__c> result = [
                SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c
                FROM View_Config_gne__c
                WHERE ((Visibility_gne__c = 'private' AND OwnerId = :UserInfo.getUserId()) OR Visibility_gne__c = 'public') AND Page_Name_gne__c = :nameOfThePage
                ORDER BY View_Name_gne__c
        ];

        //select all views available for user based on sales roster
        List<View_Config_gne__c> restricetedViews = [
                SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Application_Type_gne__c, Brand_gne__c, Role_gne__c
                FROM View_Config_gne__c
                WHERE Visibility_gne__c = 'restricted' AND Page_Name_gne__c = :nameOfThePage
                ORDER BY View_Name_gne__c
        ];

        // check all restricted views
        Set<String> restrictedViewNames = new Set<String>();
        for (View_Config_gne__c restrictedView : restricetedViews) {
            if (restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c == null && restrictedView.Role_gne__c == null) {   // app wide view
                if (GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c) {
                    result.add(restrictedView);
                }
            }
            if (restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c != null && restrictedView.Role_gne__c == null) {   // brand wide view
                if (GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c == restrictedView.Brand_gne__c) {
                    result.add(restrictedView);
                }
            }
            if (restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c != null && restrictedView.Role_gne__c != null) {   // role wide view
                if (GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c == restrictedView.Brand_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c == restrictedView.Role_gne__c) {
                    result.add(restrictedView);
                }
            }
            if (restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c == null && restrictedView.Role_gne__c != null) {   // app + role wide view
                if (GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c == restrictedView.Role_gne__c) {
                    result.add(restrictedView);
                }
            }
        }
        restrictedViewNames.clear();

        Configuration_Util.sortList(result, 'View_Name_gne__c', true);
        return result;
    }

    private void checkLastSeenView() {
        if (visibleViews != null && visibleViews.size() > 0 && userViewsHistory != null) {
            if (userViewsHistory.Last_View_Used_gne__c == null) {
                userViewsHistory.Last_View_Used_gne__c = visibleViews.get(0).id;
            }
            selectedViewId = userViewsHistory.Last_View_Used_gne__c;
            baseListController.setSelectedView(selectedViewId);
        }
    }

    public Pagereference deleteRecord() {
        //Delete the selected object
        try {
            if (deleteRecordId != null) {
                for (integer i = 0; i < records.size(); i++) {
                    if (records[i].obj.id == deleteRecordId) {
                        delete records[i].obj;
                        records.remove(i);
                        deleteRecordId = null;
                    }
                }
            }
            return null;
        } catch (Exception e) {
            PageReference pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
            pageref.setredirect(true);
            return pageref;
        }
    }

    public Pagereference deleteRecords() {
        //Delete the selected object
        try {
            Set<String> recordIds = new Set<String>(selectedRecordsString.split(','));
            List<sObject> recordsToDelete = new List<sObject>();


            // loop through records to add them to DML
            for (Integer i = 0; i < records.size(); i++) {
                if (recordIds.contains(records[i].obj.id)) {
                    recordsToDelete.add(records[i].obj);
                }
            }

            // second loop to remove from view
            for (Integer i = 0; i < records.size(); i++) {
                if (recordIds.contains(records[i].obj.id)) {
                    records.remove(i);
                }
            }

            delete recordsToDelete;
            return null;
        } catch (Exception e) {
            PageReference pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
            pageref.setredirect(true);
            return pageref;
        }
    }

    public class ListItemWrapper {
        public sObject obj { get; set; }
        public Boolean selected { get; set; }
        public Boolean isEditable { get; private set; }

        public ListItemWrapper(sObject obj, Boolean selected) {
            this.obj = obj;
            this.selected = selected;
            isEditable = true;
        }

        public ListItemWrapper(sObject obj, Boolean selected, Boolean isEditable) {
            this.obj = obj;
            this.selected = selected;
            this.isEditable = isEditable;
        }
    }
}