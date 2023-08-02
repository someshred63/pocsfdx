public with sharing class EDM_SBM_List_View_Controller {
   
    public String selectedViewId { get; set; }
    private SFA2_View_Config_gne__c selectedView;
    private GNE_SFA2_My_Accounts_Setttings__c settings;
    public String additionalConditionForViews {get; set;}
    public String predefinedListOfColumns {get; set;}
    public Boolean showViewSelection {get; set {
            showViewSelection = value;
            if (objectType != null) initView();
        }
    }
    
    public String objectType { get; set {
           objectType = value;
           if (showViewSelection != null) initView();
    }}
    
    public String deleteRecordId {get; set;}
    public String referenceField {get;set;}
    public String nameOfThePage { get; set; }
    public Boolean sortingEnabled { get; set; }
    public Boolean checkboxesEnabled { get; set; }
    public Boolean editEnabled { get; set; }
    public Boolean deleteEnabled { get; set; }
    public Boolean editViewEnabled { get; set; }
    public Boolean editEnabledCalc { get; set; }
    public Boolean deleteEnabledCalc { get; set; }    
    public Boolean isActivity {get;set;}
    public List<SelectOption> views { get; set; }
    public List<SFA2_View_Config_gne__c> visibleViews { get; set; }
    public String editURL { get; set; }
    private String queryString {get;set;}
        
    public Map<String, String> columnHeaders { get;set; }
    public Map<String, Boolean> columnSortable { get;set; }
    public List<ListItemWrapper> records { get; set; }
    public List<String> visibleColumns { get; set; }
    public List<String> filterStatements { get; set; }
    
    //sorting related variables
    public String sortColumn {get; set;}
    public String sortDirection {get; set;}
    
    private String oldSortColumn {get; set;}
    private String defaultSortOrder = 'ASC';
    
    //paging related variables
    public Integer recordsCount { get; set; }
    public Integer pageNumber { get; set; }
    
    // override user reference fields
    public Map<String, String> fieldOfUserReferenceMap {get;set;}
    public Map<String, Boolean> userReferenceHasExist {get;set;}
    // temp
    public String userIdToViewLink {get;set;}
    
    public Integer pageNumbers { get; set; }
    public Boolean hasNext { get; set; }
    public Boolean hasPrevious { get; set; }
    
    public Boolean maxRecordsReached { get; set; }
    public GNE_SFA2_List_View_Base_Controller baseListController { get; set; }

    public String filterBy { get; set; }
    
    private SFA2_User_Preferences_gne__c userPreferences;
    public static Integer PAGE_SIZE {get; set;}
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
    
    private void initView() {
        visibleViews = getViews();
        views = prepareSelectOptions(visibleViews);
        getUserPreferences();
        if(selectedViewId == null) {
            checkLastSeenView();
        }

        checkEditViewEnabled();
        editEnabledCalc = editEnabled && Schema.getGlobalDescribe().get(objectType).getDescribe().isUpdateable();
        deleteEnabledCalc = deleteEnabled && Schema.getGlobalDescribe().get(objectType).getDescribe().isDeletable();
        System.debug('editEnabled'+editEnabled);
        System.debug('deleteEnabled****'+deleteEnabled);
    }
    
    private void getUserPreferences() {
        try{
            userPreferences = [SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c, Last_Sorting_Field_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = :nameOfThePage AND User_gne__c = :Userinfo.getUserId() limit 1];            
        } catch(Exception e){            
            userPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = UserInfo.getUserId());
        }
    }
    
    private void getColumnHeadersAndSortable(List<String> columns) {
        for(String column : columns) {
            if(column.equalsIgnoreCase('recordtypeid')){
                columnHeaders.put(column, 'Record Type');
                columnSortable.put(column, true);
                continue;
            }
            if(column.equalsIgnoreCase('Name') && ApexPages.currentPage().getUrl().substringAfter('apex/').Contains('GNE_SFA2_SBMembership')){
                columnHeaders.put(column, 'Membership Id');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('Name') ){
                columnHeaders.put(column, 'Event Id');
                columnSortable.put(column, true);
                continue;
            }else if(column.equalsIgnoreCase('owner.firstname')){
                columnHeaders.put(column, 'Owner First Name');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('owner.lastname')){
                columnHeaders.put(column, 'Owner Last Name');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('owner.alias')){
                columnHeaders.put(column, 'Owner Alias');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('createdby.alias')){
                columnHeaders.put(column, 'Created By Alias');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('createdbyid')){
                columnHeaders.put(column, 'Created By');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('lastmodifiedby.alias')){
                columnHeaders.put(column, 'Last Modified By Alias');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('lastmodifiedbyId')){
                columnHeaders.put(column, 'Last Modified By');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('account.name')){
                columnHeaders.put(column, 'Name');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('accountid')){
                columnHeaders.put(column, 'Account ID');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('account.parentid')){
                columnHeaders.put(column, 'Account Parent Account');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('reportstoid')){
                columnHeaders.put(column, 'Reports To');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('reportsto.lastname')){
                columnHeaders.put(column, 'Reports To Last Name');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('reportsto.firstname')){
                columnHeaders.put(column, 'Reports To First Name');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('EDM_Parent_AABP_gne__r.EDM_Group_gne__c')){
                columnHeaders.put(column, 'Group');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('EDM_Parent_AABP_gne__r.EDM_Unit_gne__c')){
                columnHeaders.put(column, 'Unit');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('EDM_Parent_AABP_gne__r.EDM_Team_gne__c')){
                columnHeaders.put(column, 'Team');
                columnSortable.put(column, true);
                continue;
            } else if(column.equalsIgnoreCase('EDM_Parent_AABP_gne__r.EDM_Plan_Year_gne__c')){
                columnHeaders.put(column, 'Year');
                columnSortable.put(column, true);
                continue;
            } 
            else if(column.equalsIgnoreCase('name') && nameOfThePage.equalsIgnoreCase('Individual Advisory Board Plans')) {
                columnHeaders.put(column, 'Event ID');
                columnSortable.put(column, true);
                continue;
            }
            Schema.DescribeFieldResult fieldDescribe = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap().get(column).getDescribe();
            columnHeaders.put(column, fieldDescribe.getLabel());
            Schema.DisplayType fieldType = fieldDescribe.getType();
            if(fieldType == Schema.Displaytype.Multipicklist || fieldType == Schema.Displaytype.Textarea) {
                columnSortable.put(column, false);
            } else {
                columnSortable.put(column, true);
            }
        }        
    }
    
    private void checkEditViewEnabled() {
        if(selectedViewId != null){
            selectedView = getView(selectedViewId);
            if(selectedView != null && selectedView.OwnerId == Userinfo.getUserId()){
                editViewEnabled = true;
            }else{
                try{
                    String[] privilegedProfiles = null;
                    if(settings != null && settings.Privileged_Profiles_gne__c != null){
                       privilegedProfiles = settings.Privileged_Profiles_gne__c.split(',');
                    }
                    String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
                    if(privilegedProfiles != null){
                    for(String name: privilegedProfiles){
                        if(profileName == name){
                            editViewEnabled = true;
                        }
                    }
                    }
                }catch(Exception e){
                   editViewEnabled = false;
                }
            }
        }
    }
    
    public EDM_SBM_List_View_Controller() {
        System.debug('***********reference field*******' + referenceField);
        maxRecordsReached = false;
        //sortDirection = defaultSortOrder;
        sortDirection = null;
        pageNumber = 1;
        pageNumbers = 1;
        recordsCount = 0;
        columnHeaders  = new Map<String, String>();
        columnSortable = new Map<String, Boolean>();
        isActivity=false;
        try{
            settings = [ SELECT PageSize_gne__c, Privileged_Profiles_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c LIMIT 1 ];
        } catch(Exception e){
            settings = new GNE_SFA2_My_Accounts_Setttings__c(PageSize_gne__c = 50, Privileged_Profiles_gne__c = '');
        }
        //PAGE_SIZE = settings.PageSize_gne__c.intValue();
    }
    
    private void updateLastSeenView() {
        userPreferences.Last_View_Used_gne__c = selectedViewId;
        upsert userPreferences;
    }
    
    public PageReference changeSelectedView(){
        editViewEnabled = false;
        sortColumn = null;
        oldSortColumn = null;
        sortDirection = null;
        pageNumber = 1;
        selectedView = getView(selectedViewId);
        loadRecords();
        updateLastSeenView();
        checkLastSeenView();
        checkEditViewEnabled();
        return null;
    }

    public PageReference filter() {
        pageNumber = 1;
        PageReference pr = loadRecords();
        return pr;
    }

    private SFA2_View_Config_gne__c getView(String viewId) {
        SFA2_View_Config_gne__c viewToReturn;
        if (showViewSelection) {
            viewToReturn = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Records_Visibility__c, Object_Type_gne__c FROM SFA2_View_Config_gne__c WHERE Id = :selectedViewId];
        } else if (String.isNotBlank(predefinedListOfColumns)) {
            viewToReturn = new SFA2_View_Config_gne__c(View_Fields_gne__c = predefinedListOfColumns.replace(',', ';'), Sorting_Field_gne__c = 'name', Filter_Statement_gne__c = '[]', Object_Type_gne__c = objectType);
        } else {
            String fieldsFromRelatedList = getViewFieldsFromRelatedList();
            viewToReturn = new SFA2_View_Config_gne__c(View_Fields_gne__c = fieldsFromRelatedList, Sorting_Field_gne__c = 'name', Filter_Statement_gne__c = '[]', Object_Type_gne__c = objectType);
        }
        System.debug('JL view: '+viewToReturn);

        return viewToReturn;
    }
    
    private String buildCountQueryString(SFA2_View_Config_gne__c view) {
        visibleColumns = getViewColumnsByselectedView(view);
        filterStatements = getFiltersBySelectedView(view);
        getColumnHeadersAndSortable(visibleColumns);
        String countQueryString = 'SELECT COUNT() FROM ' + objectType;
        if(filterStatements.size() > 0 || view.Records_Visibility__c=='My Records' || String.isNotBlank(additionalConditionForViews)) {
            countQueryString += ' WHERE ';
            if (String.isNotBlank(additionalConditionForViews)) {
                countQueryString += additionalConditionForViews + ' AND ';
            }
            if (objectType.equals('Speaker_Bureau_Membership_gne__c') && view.Records_Visibility__c=='My Records') {
                countQueryString += ' Speaker_Bureau_ID_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
            }
            if (objectType.equals('ART_Issue_gne__c') && view.Records_Visibility__c=='My Records') {
                countQueryString += ' ART_Site_Local_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
            }
            if((!objectType.equals('Speaker_Bureau_Membership_gne__c') && !objectType.equals('ART_Issue_gne__c')) && view.Records_Visibility__c=='My Records'){
                countQueryString += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
            }
            for(String filterColumn : filterStatements){
                countQueryString += getFilterStatement(filterColumn);
            }
            countQueryString = countQueryString.removeEnd(' AND ');
        }
        
         if( (objectType.equals('Task') || objectType.equals('Event')) && (view.Records_Visibility__c=='All Records') ){
            
            isActivity=true;
            if(!countQueryString.contains('WHERE')){
                countQueryString += ' WHERE OwnerId =\'' + UserInfo.getUserId()+'\' ';
            }else{
                countQueryString += 'AND OwnerId = \''+UserInfo.getUserId()+'\' ';
            }
        }

        if(String.isNotEmpty(filterBy)) {
            if(countQueryString.contains('WHERE')) {
                countQueryString += ' AND (' + createFilterByClause(visibleColumns);
            }
            else {
                countQueryString += ' WHERE (' + createFilterByClause(visibleColumns);
            }
        }

        countQueryString += ' LIMIT ' + MAX_RECORDS_COUNT;
        System.debug('List view count query: '+countQueryString);
        return countQueryString;  
    }
    
    private String buildQueryString(SFA2_View_Config_gne__c view) {
        Map<String,Schema.SObjectField> sObjectFieldMap = prepareObjectTypeFieldsMap(objectType);
        Set<String> uniqueViewColumns = new Set<String>();
        fieldOfUserReferenceMap = new Map<String, String>();
        userReferenceHasExist = new Map<String, Boolean>();
                
        visibleColumns = getViewColumnsBySelectedView(view);
        uniqueViewColumns.addAll(visibleColumns);
        filterStatements = getFiltersBySelectedView(view);
        getColumnHeadersAndSortable(visibleColumns);
        queryString = 'SELECT ';
        
        for(String viewField : visibleColumns) {
            queryString += viewField + ', ';
            prepareFieldOfUserReferenceMaps(sObjectFieldMap, viewField);
        }
        
        if(!uniqueViewColumns.contains('CreatedDate') && !uniqueViewColumns.contains('createddate')){
            queryString += 'CreatedDate, ';
        }
        if(!uniqueViewColumns.contains('LastModifiedDate') && !uniqueViewColumns.contains('lastmodifieddate')){
            queryString += 'LastModifiedDate, ';
        }
        
        if(queryString == 'SELECT '){
            queryString += 'Id, ';
        }
        queryString = queryString.removeEnd(', ');
        
        queryString += ' FROM ' + objectType; 

        if(filterStatements.size() > 0 || view.Records_Visibility__c=='My Records' || String.isNotBlank(additionalConditionForViews)) {
            queryString += ' WHERE ';
            if (String.isNotBlank(additionalConditionForViews)) {
                queryString += additionalConditionForViews + ' AND ';
            }
            if (objectType.equals('Speaker_Bureau_Membership_gne__c') && view.Records_Visibility__c=='My Records') {
                queryString += ' Speaker_Bureau_ID_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
            }
            if (objectType.equals('ART_Issue_gne__c') && view.Records_Visibility__c=='My Records') {
                queryString += ' ART_Site_Local_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
            }
            if((!objectType.equals('Speaker_Bureau_Membership_gne__c') && !objectType.equals('ART_Issue_gne__c')) && view.Records_Visibility__c=='My Records'){
                queryString += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
            }
            for(String filterColumn : filterStatements){
                queryString += getFilterStatement(filterColumn);
            }
            queryString = queryString.removeEnd(' AND ');
        }
        
        if( (objectType.equals('Task') || objectType.equals('Event')) && (view.Records_Visibility__c=='All Records') ){
             if(!queryString.contains('WHERE')){
                queryString += ' WHERE OwnerId =\'' + UserInfo.getUserId()+'\' ';
            }else{
                queryString += 'AND OwnerId = \''+UserInfo.getUserId()+'\' ';
            }
        }

        if(String.isNotEmpty(filterBy)) {
            if(queryString.contains('WHERE')) {
                queryString += ' AND (' + createFilterByClause(visibleColumns);
            }
            else {
                queryString += ' WHERE (' + createFilterByClause(visibleColumns);
            }
        }
        
        String sortColumnSoql = sortColumn;
        if(sortColumnSoql.toLowerCase().equalsIgnoreCase('id')){
            sortColumnSoql = 'id';
        }else if(sortColumnSoql.toLowerCase().endsWith('id') && !sortColumnSoql.contains('.')){
            sortColumnSoql = sortColumnSoql.toLowerCase().removeEnd('id') + '.Name';
        }else if(!sortColumnSoql.contains('.')){
            Schema.DisplayType sortColumnType = Schema.getGlobalDescribe().get(view.Object_Type_gne__c).getDescribe().fields.getMap().get(sortColumn).getDescribe().getType();
            if(sortColumnType == Schema.DisplayType.Reference && sortColumnSoql.toLowerCase().endsWith('__c')){
                sortColumnSoql = sortColumnSoql.toLowerCase().removeEnd('__c') + '__r.Name';
            }
        }
        
        Integer limitSize = String.isNotBlank(filterBy) ? MAX_RECORDS_COUNT : PAGE_SIZE;
        queryString += ' ORDER BY ' + sortColumnSoql + ' ' +sortDirection+ ' NULLS LAST LIMIT ' + limitSize + ' OFFSET ' + ((pageNumber-1)*PAGE_SIZE);
        
        System.debug('List view query: '+queryString);
        return queryString;  
    }

    private String createFilterByClause(List<String> fields) {
        Schema.DescribeFieldResult fieldDescribe;
        Schema.DescribeFieldResult parentFieldDescribe;
        Schema.DisplayType dType;
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();               
        String result = '';
        String sType = '';
        for(String field : fields) {
            if(!field.contains('__r')) {
                fieldDescribe = objectFields.get(field).getDescribe();
                dType = fieldDescribe.getType();
            }
            else {
                String rlObjectFieldName = field.split('\\.').get(0).replace('__r', '__c');
                String parentFieldName = field.split('\\.').get(1);
                fieldDescribe = objectFields.get(rlObjectFieldName).getDescribe();
                String parentObjectName = getParentObjectName(fieldDescribe);
                parentFieldDescribe = getParentFieldDescribe(parentObjectName, parentFieldName);
                dType = parentFieldDescribe.getType();
            }
            
            sType = String.valueOf(dType);

            if(sType == 'STRING' || sType == 'PICKLIST') {
                result += field + ' LIKE \'%' + filterBy + '%\' OR '; 
            }            
            else if(sType == 'REFERENCE') {
                String relationShipName = fieldDescribe.getRelationshipName();
                result += relationShipName + '.Name' + ' LIKE \'%' + filterBy + '%\' OR ';
            }
        }

        result = result.removeEnd('OR ');        
        result += ' ) ';
        
        return result;
    }    

    private String getParentObjectName(Schema.DescribeFieldResult fldDescribe) {
            return fldDescribe.getReferenceTo()[0].getDescribe().getName();
    }

    private Schema.DescribeFieldResult getParentFieldDescribe(String parentObjectName, String parentFieldName) {
            Schema.DescribeSObjectResult parentObjectDescribe = GNE_SFA2_Util.getGlobalDescribe().get(parentObjectName).getDescribe();
            Map<String, Schema.SObjectField> parentObjectFields = parentObjectDescribe.fields.getMap();
            return parentObjectFields.get(parentFieldName).getDescribe();
    }

    // Override Link When Field Has User Reference
    public Map<String,Schema.SObjectField> prepareObjectTypeFieldsMap (String objectType) {
        Map<String,Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();  
        Schema.SObjectType sObjectType = globalDescribeMap.get(objectType);  
        Schema.DescribeSObjectResult result = sObjectType.getDescribe();  
        Map<String,Schema.SObjectField> sObjectFieldMap = result.fields.getMap();
        
        return sObjectFieldMap;
    }
    
    public void prepareFieldOfUserReferenceMaps(Map<String,Schema.SObjectField> sObjectFieldMap, String viewField) {
        if (viewField.contains('.')) {
            userReferenceHasExist.put(viewField, false);    
        } else {
            try {    
                Schema.SObjectField sObjectField = sObjectFieldMap.get(viewField);
                List<Schema.sObjectType> fieldReference = sObjectField.getDescribe().getReferenceTo(); 
                if(fieldReference.size() > 0) {
                    Set<String> referenceSet = new Set<String>(); 
                    for(Integer i = 0; i < fieldReference.size(); i++) {
                        referenceSet.add(String.valueOf(fieldReference[i]));
                    }
                    if(referenceSet.contains('User')) {
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
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref; 
    }
    
    public PageReference loadRecords() {
 
        try{
            if(selectedViewId != null || !showViewSelection) {
                selectedView = getView(selectedViewId);
                if(String.isBlank(sortColumn)) {
                    sortColumn = selectedView.Sorting_Field_gne__c;
                }
                if(String.isBlank(oldSortColumn)) {
                    oldSortColumn = sortColumn;
                }
                if (String.isBlank(sortDirection)){
                    if (String.isNotBlank(selectedView.Sorting_Order_gne__c)){
                        sortDirection = selectedView.Sorting_Order_gne__c;
                    } else {
                        sortDirection = defaultSortOrder;
                    }
                }

                recordsCount = countRecords(selectedView);
                pageNumbers = countPageNumbers();
                if(pageNumber > pageNumbers) {
                    pageNumber = 1;
                }
                String generatedQuery = buildQueryString(selectedView);
                List<SObject> queriedRecords = Database.query(generatedQuery);
                QueryWithoutSharingToGetUserNames queryWithoutSharing = new QueryWithoutSharingToGetUserNames(generatedQuery, queriedRecords);
                records = wrapResults(queryWithoutSharing.getRecordsWithNames());
                System.debug('##### Records === ' + records);
                hasNext = checkIfHasNext();
                hasPrevious = checkIfHasPrevious();
                baseListController.setSelectedRecords(new Set<Id>());
            }
        }catch(Exception e){
            records = new List<ListItemWrapper>();
            recordsCount = 0;
            pageNumbers = 1;
            hasNext = false;
            hasPrevious = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error during record loading. Please redefine selected view'));
            ApexPages.addMessages(e);
            System.debug(e);
        }
        return null;
    }
    
    private String getFilterStatement(String filterColumn){
        String query = filterColumn + ' AND ';
        return query;
    }
    
    private Integer countRecords(SFA2_View_Config_gne__c selectedView) {
        Integer recordsCount = 0;
        if(selectedView != null) {
            recordsCount = Database.countQuery(buildCountQueryString(selectedView));
            if(recordsCount == MAX_RECORDS_COUNT) {
                maxRecordsReached = true;
            } else {
                maxRecordsReached = false;
            }
            if(recordsCount == 0) {
                pageNumber = 1;
            }
        } else {
            maxRecordsReached = false;
            pageNumber = 1;
        }
        return recordsCount;
    }
    
    public Integer countPageNumbers(){
        return recordsCount == 0 ? 1 : Math.ceil(recordsCount / (PAGE_SIZE * 1.0)).intValue();
    }
    
    // get view columns basing on the selected view
    private List<String> getViewColumnsBySelectedView(SFA2_View_Config_gne__c selectedView){
        List<String> columns = new List<String>();
        if(selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != ''){
           columns = selectedView.View_Fields_gne__c.split(';', 0);
        }
        return columns;
    }
    
    // get filters basing on the selected view
    private List<String> getFiltersBySelectedView(SFA2_View_Config_gne__c selectedView){
        List<String> filters = new List<String>();
        if(selectedView.Filter_Statement_gne__c != null && selectedView.Filter_Statement_gne__c != ''){
            List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>conditionItems = (List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>)JSON.deserializeStrict(selectedView.Filter_Statement_gne__c,  List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>.class);
            for(Integer i=0; i<conditionItems.size(); i++){
                GNE_SFA2_List_View_Setup_Ext.ConditionItem conditionItem = conditionItems.get(i);
                String filterExpr = conditionItem.field;
                
                if(conditionItem.valueType == 'PICKLIST'){
                    if(conditionItem.operator=='inc'){
                        filterExpr += ' IN '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    }else if(conditionItem.operator=='ecl'){
                        filterExpr += ' NOT IN '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    }
                }else if(conditionItem.valueType == 'MULTIPICKLIST'){
                    if(conditionItem.operator == 'inc'){
                        filterExpr += ' INCLUDES '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    }else if(conditionItem.operator=='ecl'){
                        filterExpr += ' EXCLUDES '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    }
                }else if(conditionItem.valueType == 'BOOLEAN') {
                    if(conditionItem.operator == 'eq'){
                        filterExpr += ' = '+conditionItem.value;
                    }else if(conditionItem.operator == 'ne'){
                        filterExpr += ' != '+conditionItem.value;
                    }
                   
                }else if(conditionItem.valueType=='STRING'||conditionItem.valueType=='EMAIL'||conditionItem.valueType=='URL' || conditionItem.valueType=='PHONE' || conditionItem.valueType=='REFERENCE' || conditionItem.valueType=='COMBOBOX') {
                    if(conditionItem.valueType=='REFERENCE' && conditionItem.value=='CURRENT_USER') {
                        conditionItem.value = UserInfo.getUserId();
                    }
                                    
                    if(conditionItem.operator=='eq'){
                        filterExpr += ' = \''+ String.escapeSingleQuotes(conditionItem.value) +'\'';
                    }else if(conditionItem.operator=='ne'){
                        filterExpr += ' != \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
                    }else if(conditionItem.operator=='lt'){
                        filterExpr += ' < \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
                    }else if(conditionItem.operator=='lte'){
                        filterExpr += ' <= \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
                    }else if(conditionItem.operator=='gt'){
                        filterExpr += ' > \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
                    }else if(conditionItem.operator=='gte'){
                        filterExpr += ' >= \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
                    }else if(conditionItem.operator=='c'){
                        filterExpr += ' LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\'';
                    }else if(conditionItem.operator=='nc'){
                        filterExpr =  '(NOT ' + +conditionItem.field + ' LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\')';
                    }else if(conditionItem.operator=='sw'){
                        filterExpr += ' LIKE \''+String.escapeSingleQuotes(conditionItem.value)+'%\'';
                    }
                } else if(conditionItem.valueType=='CUSTOM_FILTER') {
                    filterExpr = baseListController.getCustomFilterExpression(conditionItem);
                    if(String.isBlank(filterExpr)) {
                        continue;
                    }
                } else {
                    String value='';
                    boolean do_not_split=false;
                    Boolean needQuotes = true;                    
                        try{
                            if (conditionItem.valueType=='DOUBLE'||conditionItem.valueType=='CURRENCY'||conditionItem.valueType=='PERCENT'){
                                value = Double.valueOf(conditionItem.value).format();
                                needQuotes = false;
                            } else if(conditionItem.valueType=='INTEGER'){
                                value = Integer.valueOf(conditionItem.value).format();
                                needQuotes = false;
                            } else if(conditionItem.valueType=='DATE'){
                                
                                if(conditionItem.value.equals('TODAY'))
                                {
                                    String currentDate_T=String.valueOf(System.today());
                                    System.debug('**date today value'+currentDate_T);
                                    String[] today_Parts = currentDate_T.split('-');
                                    conditionItem.value=today_Parts[1]+'/'+today_Parts[2]+'/'+today_Parts[0];                                   
                                }
                                
                                
                                String[] dateParts = conditionItem.value.split('/');
                                DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
                                value = dtime.format('yyyy-MM-dd');
                                needQuotes = false;
                            } else if (conditionItem.valueType=='DATETIME'){
                                
                                if(conditionItem.value.equals('TODAY'))
                                {
                                    String currentDate_T=String.valueOf(System.today());
                                    String[] today_Parts = currentDate_T.split('-');
                                    conditionItem.value=today_Parts[1]+'/'+today_Parts[2]+'/'+today_Parts[0];                                   
                                }
                                else if(conditionItem.value.contains('_N_DAYS'))
                                {
                                  //do not split 
                                  do_not_split = true;
                                }
                                 String[] dateParts = conditionItem.value.split('/');
                                //if field is datetime only date part is compared    
                                                             
                                filterExpr = String.format('DAY_ONLY(CONVERTTIMEZONE({0}))', new String[]{filterExpr});
                                if(!do_not_split)
                                {
                                 DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 0, 0, 0);
                                 value = dtime.format('yyyy-MM-dd');
                                }
                                else{
                                  value=conditionItem.value;
                                }
                                 needQuotes = false;
                            } else if(conditionItem.valueType=='ID'){
                                Id tmpId = conditionItem.value;
                                value = tmpId;
                            } else{
                                value = conditionItem.value;
                            }
                        }catch(Exception e){
                            //TODO: implement
                        }
                    if(conditionItem.operator=='eq'){
                        filterExpr +=  ' = ' + (needQuotes ? ('\''+value+'\'') : value);
                    }else if(conditionItem.operator=='ne'){
                        filterExpr +=  ' != ' + (needQuotes ? ('\''+value+'\'') : value);
                    }else if(conditionItem.operator=='lt'){
                        filterExpr +=  ' < ' + (needQuotes ? ('\''+value+'\'') : value);
                    }else if(conditionItem.operator=='lte'){
                        filterExpr +=  ' <= ' + (needQuotes ? ('\''+value+'\'') : value);
                    }else if(conditionItem.operator=='gt'){
                        filterExpr +=  ' > ' + (needQuotes ? ('\''+value+'\'') : value);
                    }else if(conditionItem.operator=='gte'){
                        filterExpr +=  ' >= ' + (needQuotes ? ('\''+value+'\'') : value);
                    }
                }
                filters.add(filterExpr);                    
            }
        }
        
        populateCustomFilterVariables();
        
        return filters;
    }
    
    private void populateCustomFilterVariables() {
        customFilterVariable_1  = baseListController.customFilterVariable_1;
        customFilterVariable_2  = baseListController.customFilterVariable_2;
        customFilterVariable_3  = baseListController.customFilterVariable_3;
        customFilterVariable_4  = baseListController.customFilterVariable_4;
        customFilterVariable_5  = baseListController.customFilterVariable_5;
        customFilterVariable_6  = baseListController.customFilterVariable_6;
        customFilterVariable_7  = baseListController.customFilterVariable_7;
        customFilterVariable_8  = baseListController.customFilterVariable_8;
        customFilterVariable_9  = baseListController.customFilterVariable_9;
        customFilterVariable_10 = baseListController.customFilterVariable_10;
    }
    
    
    private List<ListItemWrapper> wrapResults(List<sObject> sObjectsList) {
        List<ListItemWrapper> result = new List<ListItemWrapper>();
        for(sObject o : sObjectsList) {
            result.add(new ListItemWrapper(o, false));
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
    
    public Boolean checkIfHasNext() {
        return (pageNumber < pageNumbers);
    }
    
    public Boolean checkIfHasPrevious() {
        return (pageNumber > 1);
    }
    
    public PageReference changeSorting() {
        pageNumber = 1;
        if(sortColumn == oldSortColumn){
            if(sortDirection == 'ASC'){
                sortDirection = 'DESC';
            }else{
                sortDirection = 'ASC';
            }
        }else{
            sortDirection = defaultSortOrder;
            oldSortColumn = sortColumn;
        }
        updateLastSortingFieldAndViewUsed();
        return loadRecords();
    }
    
    private void updateLastSortingFieldAndViewUsed() {
        userPreferences.Last_View_Used_gne__c = selectedViewId;
        userPreferences.Last_Sorting_Field_Used_gne__c = sortColumn + ' ' + sortDirection;
        upsert userPreferences;
    }

    // prepare select options for views
    private List<SelectOption> prepareSelectOptions(List<SFA2_View_Config_gne__c> views){
        List<SelectOption> selectOptions = new List<SelectOption>();
        if(views == null || views.isEmpty()){
            selectOptions.add(new SelectOption('','No Views Defined'));
        } else {
            for(SFA2_View_Config_gne__c view: views){
                selectOptions.add(new SelectOption(view.Id, view.View_Name_gne__c));
            }
        }
        return selectOptions;
    }
    
    // get views defined for user   
    private List<SFA2_View_Config_gne__c> getViews(){
        // select all public views
        List<SFA2_View_Config_gne__c> result = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c
                                                            FROM SFA2_View_Config_gne__c
                                                            WHERE ((Visibility_gne__c='private' AND OwnerId = :UserInfo.getUserId()) OR Visibility_gne__c='public') AND Page_Name_gne__c = :nameOfThePage ORDER BY View_Name_gne__c];
                                                            
        //select all views available for user based on sales roster
        List<SFA2_View_Config_gne__c> restricetedViews = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Application_Type_gne__c, 
                                                            Brand_gne__c, Role_gne__c
                                                            FROM SFA2_View_Config_gne__c
                                                            WHERE Visibility_gne__c = 'restricted' AND Page_Name_gne__c = :nameOfThePage ORDER BY View_Name_gne__c];
                                                            
        // check all restricted views
        Set<String> restrictedViewNames = new Set<String>();
        for(SFA2_View_Config_gne__c restrictedView : restricetedViews) {
            if(!restrictedViewNames.contains(restrictedView.View_Name_gne__c) && restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c == null && restrictedView.Role_gne__c == null) {   // app wide view
                if(GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c) {
                    result.add(restrictedView);
                    restrictedViewNames.add(restrictedView.View_Name_gne__c);
                }
            }
            if(!restrictedViewNames.contains(restrictedView.View_Name_gne__c) && restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c != null && restrictedView.Role_gne__c == null) {   // brand wide view
                if(GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c == restrictedView.Brand_gne__c) {
                    result.add(restrictedView);
                    restrictedViewNames.add(restrictedView.View_Name_gne__c);
                }
            }
            if(!restrictedViewNames.contains(restrictedView.View_Name_gne__c) && restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c != null && restrictedView.Role_gne__c != null) {   // role wide view
                if(GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c == restrictedView.Brand_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c == restrictedView.Role_gne__c) {
                    result.add(restrictedView);
                    restrictedViewNames.add(restrictedView.View_Name_gne__c);
                }
            }
            
            if(!restrictedViewNames.contains(restrictedView.View_Name_gne__c) && restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c == null && restrictedView.Role_gne__c != null) {   // app + role wide view
                if(GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c == restrictedView.Role_gne__c) {
                    result.add(restrictedView);
                    restrictedViewNames.add(restrictedView.View_Name_gne__c);
                }
            }
        }
        restrictedViewNames.clear();

        GNE_SFA2_Util.sortList(result, 'View_Name_gne__c', true);
        return result; 
    }
    
    private void checkLastSeenView() {
       if(visibleViews != null && visibleViews.size() > 0 && userPreferences != null ){
            if(userPreferences.Last_View_Used_gne__c == null){
                userPreferences.Last_View_Used_gne__c = visibleViews.get(0).id;
            }
            if(String.isEmpty(selectedViewId)) {
                selectedViewId = userPreferences.Last_View_Used_gne__c;
            }

            if(selectedViewId == userPreferences.Last_View_Used_gne__c) {
                if(String.isNotEmpty(userPreferences.Last_Sorting_Field_Used_gne__c)) {
                    String[] lastUsedSort = userPreferences.Last_Sorting_Field_Used_gne__c.split(' ');
                    if(lastUsedSort.size() == 2) {
                        sortColumn = lastUsedSort[0];
                        sortDirection = lastUsedSort[1];
                    }
                }
            }
        }
    }
    
    public class ListItemWrapper {
        public sObject obj { get; set; }
        public Boolean selected { get; set; }
        
        public ListItemWrapper(sObject obj, Boolean selected) {
            this.obj = obj;
            this.selected = selected;
        }
    }
    
    public Pagereference deleteRecord(){
        //Delete the selected object
        String interactionStatus = 'Planned';
        try{
            if(deleteRecordId != null){
                if(objectType.contains('Call2_vod__c'))
                    {
                        List<Call2_vod__c> getStatus = [SELECT Interaction_Status_gne__c FROM Call2_vod__c WHERE Id=: deleteRecordId];
                        if (getStatus.size()>0){
                            interactionStatus = getStatus[0].Interaction_Status_gne__c;
                        }                      
                    }
                for(integer idx = 0; idx <records.size(); idx++){
                    if(records[idx].obj.id == deleteRecordId){
                        delete records[idx].obj;
                        records.remove(idx);
                        deleteRecordId=null;
                        
                    }
                }
            }
            
            return null;
            
        }
        catch (Exception e){
            system.debug(e);
            PageReference pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
            pageref.setredirect(true);
            return pageref;        
        }
    }

    private String getViewFieldsFromRelatedList() {
        String results;

        String viewParentObjectName = ApexPages.currentPage().getParameters().get('parentObjectName');
        String viewRecordTypeName = ApexPages.currentPage().getParameters().get('parentRecordType');
        String viewObjectName = objectType;
        if (String.isNotBlank(viewParentObjectName)) {
            List<SFA2_Configuration_Object_Detail_gne__c> configurations = GNE_SFA2_ViewAll.getUIConfigurationObjectDetails(viewParentObjectName, viewRecordTypeName, viewObjectName);
            
            if (!configurations.isEmpty()) {
                System.debug('Configurations'+ configurations .get(0).Attributes_gne__c);
                GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(configurations.get(0).Attributes_gne__c);
                results = attributesWrapper.fieldsCSV.replace(',', ';').replace('#/', '');
            }
        }
        return String.isNotBlank(results) ? results : 'name';
    }

    public Boolean getIsUserVDST() {
        Boolean result;
        if (result == null) {
            result = EDM_ABM_Utils.hasPermissionSet('EDM_VDST_Partner_External_ABM');
        }
        return result;
    }

    private without sharing class QueryWithoutSharingToGetUserNames {
        private String query;
        private List<SObject> records;
        private Set<Id> recordIds;

        public QueryWithoutSharingToGetUserNames(String query, List<SObject> records) {
            this.query = query;
            this.records = records;
        }

        public List<SObject> getRecordsWithNames() {
            recordIds = getRecordsIds();
            injectIdFilterBeforeOrderBy();
            return Database.query(query);
        }

        private Set<Id> getRecordsIds() {
            Set<Id> result = new Set<Id>();
            for (SObject record : records) {
                result.add(record.Id);
            }
            return result;
        }

        private void injectIdFilterBeforeOrderBy() {
            query = injectIdFilter(query);
            query = stripOffset(query);
        }

        private String injectIdFilter(String query) {
            String filter;

            if (query.containsIgnoreCase('where')) {
                filter = ' AND Id IN :recordIds ';
            }
            else {
                filter = ' WHERE Id IN :recordIds ';
            }

            String part1 = query.substringBeforeLast('ORDER BY');
            String part2 = query.substringAfterLast('ORDER BY');
            return part1 + ' ' + filter + ' ' + ' ORDER BY ' + part2;
        }

        private String stripOffset(String query) {
            return query.substringBeforeLast('OFFSET');
        }
    }
}