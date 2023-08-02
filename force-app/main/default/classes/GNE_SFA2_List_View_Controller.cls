/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-12-11
*  Description: This is a controller class for SFA2 List View component.
*  
*  Modification History
*  Date        Name        Description
*  4/17/2013   osowiecb    Add handling for custom filter
*  8/05/2013   kozminsl    Remove unworked method getSelected() - this functionality is available from javascript only           
*  12/27/2018  lanieckj    Change API version from 24 to 42 because of Territory2
*************************************************************/
public with sharing class GNE_SFA2_List_View_Controller {
    
    public String selectedViewId { get; set; }
    private SFA2_View_Config_gne__c selectedView;
    private GNE_SFA2_My_Accounts_Setttings__c settings;
    
    public String objectType { get; set {
           objectType = value;
           initView();
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
    
    private SFA2_User_Preferences_gne__c userPreferences;
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
            userPreferences = [SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = :nameOfThePage AND User_gne__c = :Userinfo.getUserId() limit 1];
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
            } else if(column.equalsIgnoreCase('account.name')) {
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
    
    public GNE_SFA2_List_View_Controller() {
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
        PAGE_SIZE = settings.PageSize_gne__c.intValue();
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
        checkEditViewEnabled();
        return null;
    }
    
    private SFA2_View_Config_gne__c getView(String viewId) {
        return [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Records_Visibility__c, Object_Type_gne__c, Page_Name_gne__c FROM SFA2_View_Config_gne__c WHERE Id = :selectedViewId];
    }
    
    private String buildCountQueryString(SFA2_View_Config_gne__c view) {
        visibleColumns = getViewColumnsByselectedView(view);
        filterStatements = getFiltersBySelectedView(view);
        getColumnHeadersAndSortable(visibleColumns);
        String countQueryString = 'SELECT COUNT() FROM ' + objectType;
        
        if (view.Records_Visibility__c == 'My Records' && (GNE_SFA2_Util.isCanadaDirectorUser() || GNE_SFA2_Util.isCanadaRMLUser() || GNE_SFA2_Util.isCanadaOpsUser())){
        	view.Records_Visibility__c = 'All Records';
        }
        
        if(filterStatements.size() > 0 || view.Records_Visibility__c=='My Records' ) {
            countQueryString += ' WHERE ';
            if (objectType.equals('Speaker_Bureau_Membership_gne__c') && view.Records_Visibility__c=='My Records') {
                countQueryString += ' Speaker_Bureau_ID_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
            }
            if (objectType.equals('ART_Issue_gne__c') && view.Records_Visibility__c=='My Records') {
                countQueryString += ' ART_Site_Local_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
            }
            if (objectType.equals('Referral_Assignment_gne__c') && view.Records_Visibility__c=='My Records' && GNE_SFA2_Util.isCanadaUser()) {
                countQueryString += ' (Assigned_To_gne__c = \''+UserInfo.getUserId()+'\' OR OwnerId = \'' + UserInfo.getUserId() + '\') AND ';
            }
            if((!objectType.equals('Speaker_Bureau_Membership_gne__c') && !objectType.equals('ART_Issue_gne__c') && !(objectType.equals('Referral_Assignment_gne__c') && GNE_SFA2_Util.isCanadaUser())) && view.Records_Visibility__c=='My Records' && !GNE_SFA2_Util.isCanadaINFUUser()){
                countQueryString += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
            }
            if(objectType.equals('Call2_vod__c') && GNE_SFA2_Util.isCanadaINFUUser() ) {
                countQueryString +=  ' OwnerId = \''+UserInfo.getUserId()+'\' AND (CreatedDate = LAST_N_MONTHS:12 OR CreatedDate = TODAY) AND ' ;
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
        if((view.Page_Name_gne__c == 'Insights' || view.Page_Name_gne__c == 'My Insights') && view.Object_Type_gne__c != 'Independent_Insight_vod__c'){
        	queryString += 'Account_gne__r.Name, Account_gne__r.recordtype.developername, primary_payer_gne__r.Name, secondary_payer_gne__r.name ';
        }
        
        if(queryString == 'SELECT '){
            queryString += 'Id, ';
        }
        queryString = queryString.removeEnd(', ');
        
        queryString += ' FROM ' + objectType; 
        
        if (view.Records_Visibility__c == 'My Records' && (GNE_SFA2_Util.isCanadaDirectorUser() || GNE_SFA2_Util.isCanadaRMLUser() || GNE_SFA2_Util.isCanadaOpsUser())){
        	view.Records_Visibility__c = 'All Records';
        }

        if(filterStatements.size() > 0 || view.Records_Visibility__c=='My Records') {
            queryString += ' WHERE ';
            if (objectType.equals('Speaker_Bureau_Membership_gne__c') && view.Records_Visibility__c=='My Records') {
                queryString += ' Speaker_Bureau_ID_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
            }
            if (objectType.equals('ART_Issue_gne__c') && view.Records_Visibility__c=='My Records') {
                queryString += ' ART_Site_Local_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
            }
            if (objectType.equals('Referral_Assignment_gne__c') && view.Records_Visibility__c=='My Records' && GNE_SFA2_Util.isCanadaUser()) {
                queryString += ' (Assigned_To_gne__c = \''+UserInfo.getUserId()+'\' OR OwnerId = \'' + UserInfo.getUserId() + '\') AND ';
            }
            if((!objectType.equals('Speaker_Bureau_Membership_gne__c') && !objectType.equals('ART_Issue_gne__c') && !(objectType.equals('Referral_Assignment_gne__c') && GNE_SFA2_Util.isCanadaUser())) && view.Records_Visibility__c=='My Records' && !GNE_SFA2_Util.isCanadaINFUUser()){
                queryString += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
            }
            if(objectType.equals('Call2_vod__c') && GNE_SFA2_Util.isCanadaINFUUser() ) {
                queryString +=  ' OwnerId = \''+UserInfo.getUserId()+'\' AND (CreatedDate = LAST_N_MONTHS:12 OR CreatedDate = TODAY) AND ' ;
            }
            if(objectType.equals('Independent_Insight_vod__c') && view.Records_Visibility__c=='My Records' && GNE_SFA2_Util.isCanadaUser()) {
                queryString +=  ' OwnerId = \''+UserInfo.getUserId()+'\' AND Hide_Record_gne__c = false AND ';
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
        if(objectType.equals('Independent_Insight_vod__c') && view.Records_Visibility__c=='All Records' && GNE_SFA2_Util.isCanadaUser()) {
            if(!queryString.contains('WHERE')) {
                queryString += ' WHERE Hide_Record_gne__c = false ';
            } else {
                queryString += ' AND Hide_Record_gne__c = false ';
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
        
        queryString += ' ORDER BY ' + sortColumnSoql + ' ' +sortDirection+ ' NULLS LAST LIMIT ' + PAGE_SIZE + ' OFFSET ' + ((pageNumber-1)*PAGE_SIZE);
        
        System.debug('List view query: '+queryString);
        return queryString;  
    }
    
    // Override Link When Field Has User Reference
    public Map<String,Schema.SObjectField> prepareObjectTypeFieldsMap (String objectType) {
        Map<String,Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe();  
        Schema.SObjectType sObjectType = globalDescribeMap.get(objectType);  
        Schema.DescribeSObjectResult result = sObjectType.getDescribe();  
        Map<String,Schema.SObjectField> sObjectFieldMap = result.fields.getMap();
        
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
        PageReference pageref = new PageReference('/apex/GNE_SFA2_User_Layout?Id=' + userIdToViewLink);
        pageref.setredirect(true);
        return pageref; 
    }
    
    public PageReference loadRecords() {
        
        try{
            if(selectedViewId != null) {
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
                records = wrapResults(Database.query(buildQueryString(selectedView)));
                System.debug('##### Records === ' + records);
                recordsCount = countRecords(selectedView);
                pageNumbers = countPageNumbers();
                hasNext = checkIfHasNext();
                hasPrevious = checkIfHasPrevious();
                if(GNE_SFA2_Util.isCanadaUser() && selectedView.Object_Type_gne__c == 'Independent_Insight_vod__c') {
                    fetchRelatedAccounts();
                }
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

    private void fetchRelatedAccounts() {
        List<Id> accIds = new List<Id>();
        Map<String, List<Id>> relatedAccountIds = new Map<String, List<Id>>();

        for (ListItemWrapper rec : records) {
            if (rec.obj.get('Account_gne__c') != null) {
                String relatedAccString = (String) rec.obj.get('Account_gne__c');
                List<String> relatedAccList = relatedAccString.split(';');
                if (relatedAccList.size() > 0) {
                    accIds.addAll(relatedAccList);
                    relatedAccountIds.put((String)rec.obj.get('Id'), relatedAccList);
                    if(relatedAccList.size() > 1) {
                        rec.hasMultipleAccounts = true;
                    }
                }
            }
        }

        Map<String, Account> relatedAccounts = new Map<String, Account> ([SELECT Id, Name FROM Account WHERE Id IN :accIds]);
        for (ListItemWrapper rec : records) {
            if (rec.obj.get('Account_gne__c') != null) {
                rec.relatedAccounts = new List<Account>();

                for (String relatedAccId : relatedAccountIds.get((String) rec.obj.get('Id'))) {
                    rec.relatedAccounts.add(relatedAccounts.get(relatedAccId));
                }
            }
        }
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
    	customFilterVariable_1	= baseListController.customFilterVariable_1;
		customFilterVariable_2	= baseListController.customFilterVariable_2;
		customFilterVariable_3	= baseListController.customFilterVariable_3;
		customFilterVariable_4	= baseListController.customFilterVariable_4;
		customFilterVariable_5	= baseListController.customFilterVariable_5;
		customFilterVariable_6	= baseListController.customFilterVariable_6;
		customFilterVariable_7	= baseListController.customFilterVariable_7;
		customFilterVariable_8	= baseListController.customFilterVariable_8;
		customFilterVariable_9	= baseListController.customFilterVariable_9;
		customFilterVariable_10	= baseListController.customFilterVariable_10;
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
        return loadRecords();
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
            selectedViewId = userPreferences.Last_View_Used_gne__c; 
        }
    }
    
    public class ListItemWrapper {
        public sObject obj { get; set; }
        public Boolean selected { get; set; }
        public Boolean hasMultipleAccounts { get; set; }
        public List<Account> relatedAccounts { get; set; }
        public Boolean isOwner { get; set; }
        public Boolean isCallRelated { get; set; }

        public ListItemWrapper(sObject obj, Boolean selected) {
            this.obj = obj;
            this.selected = selected;
            if(obj.getSObjectType() == Independent_Insight_vod__c.sObjectType) {

                if(obj.isSet('CreatedById')) {
                    if(String.valueOf(obj.get('CreatedById')) == UserInfo.getUserId()) {
                        isOwner = true;
                    } else {
                        isOwner = false;
                    }
                } else {
                    isOwner = true;
                }

                if(String.valueOf(obj.get('Display_Name_gne__c')).substringBetween('<a href="','"').substringAfterLast('/').startsWith('a04')) {
                    isCallRelated = true;
                } else {
                    isCallRelated = false;
                }

            }
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
                        this.recordsCount -= 1;
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
}