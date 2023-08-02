/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-12-11
*  Description: This is a controller class for SFA2 List View component.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class SFA2_List_View_Controller {
    
   /*public String selectedViewId { get; set; }
    private GNE_SFA2_My_Accounts_View_Setup__c selectedView;
    private GNE_SFA2_My_Accounts_Setttings__c settings;
    
    public String objectType { get; set {
           objectType = value;
           initView();
    }}
    
    public String nameOfThePage { get; set; }
    
    public Boolean sortingEnabled { get; set; }
    public Boolean checkboxesEnabled { get; set; }
    public Boolean editEnabled { get; set; }
    public Boolean deleteEnabled { get; set; }
    public Boolean editViewEnabled { get; set; }
    public List<SelectOption> views { get; set; }
    public List<GNE_SFA2_My_Accounts_View_Setup__c> visibleViews { get; set; }
        
    private Map<String, Schema.SObjectType> globalDescribe;
    public Map<String, String> columnHeaders { get;set; }
    public List<ListItemWrapper> records { get; set; }
    public List<String> visibleColumns { get; set; }
    public List<String> filterStatements { get; set; }
    
    //sorting related variables
    public String sortColumn {get; set;}
    public String sortDirection {get; set;}
    private String oldSortColumn {get; set;}
    
    //paging related variables
    public Integer recordsCount { get; set; }
    public Integer pageNumber { get; set; }
    
    public Integer pageNumbers { get; set; }
    public Boolean hasNext { get; set; }
    public Boolean hasPrevious { get; set; }
    
    public Boolean maxRecordsReached { get; set; }
    public GNE_SFA2_List_View_Base_Controller baseListController { get; set; }
    
    private List<SFA2_User_Preferences_gne__c> userPreferences;
    private Integer PAGE_SIZE = 50;
    private Integer MAX_RECORDS_COUNT = 1000;
    
    private void initView() {
        visibleViews = getViews();
        views = prepareSelectOptions(visibleViews);
        getUserPreferences();
        if(selectedViewId == null) {
            checkLastSeenView();
        }
        checkEditViewEnabled();
        editEnabled = editEnabled && globalDescribe.get(objectType).getDescribe().isUpdateable();
        deleteEnabled = deleteEnabled && globalDescribe.get(objectType).getDescribe().isDeletable();
    }
    
    private void getUserPreferences() {
        userPreferences = [ SELECT Last_Account_View_Used_gne__c FROM SFA2_User_Preferences_gne__c WHERE Last_Account_View_Used_gne__r.Page_Name_gne__c = :nameOfThePage AND CreatedById = :Userinfo.getUserId() LIMIT 1 ];
        if(userPreferences == null || userPreferences.isEmpty()){
            userPreferences = new List<SFA2_User_Preferences_gne__c>{new SFA2_User_Preferences_gne__c(Last_Account_View_Used_gne__c = selectedViewId)};
            insert userPreferences;
        }
    }
    
    private void getColumnHeaders(List<String> columns) {
        for(String column : columns) {
            columnHeaders.put(column, globalDescribe.get(objectType).getDescribe().fields.getMap().get(column).getDescribe().getLabel());
        }
    }
    
    private void checkEditViewEnabled() {
        selectedView = getView(selectedViewId);
        if(selectedView.OwnerId == UserInfo.getUserId()) {
            editViewEnabled = true;
        } else {
            editViewEnabled = false;
        }
    }
    */
    public SFA2_List_View_Controller() {
        /*maxRecordsReached = false;
        sortDirection = 'ASC';
        pageNumber = 1;
        pageNumbers = 1;
        recordsCount = 0;
        globalDescribe = Schema.getGlobalDescribe();
        columnHeaders  = new Map<String, String>();
        try{
            settings = [ SELECT PageSize_gne__c, Privileged_Profiles_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c LIMIT 1 ];
        } catch(Exception e){
            settings = new GNE_SFA2_My_Accounts_Setttings__c(PageSize_gne__c = 50, Privileged_Profiles_gne__c = '');
        }
        PAGE_SIZE = settings.PageSize_gne__c.intValue();*/
    }
    
    /*private void updateLastSeenView() {
        userPreferences[0].Last_Account_View_Used_gne__c = selectedViewId;
        update userPreferences;
    }
    
    public PageReference changeSelectedView(){
        pageNumber = 1;
        selectedView = getView(selectedViewId);
        loadRecords();
        updateLastSeenView();
        checkEditViewEnabled();
        return null;
    }
    
    private GNE_SFA2_My_Accounts_View_Setup__c getView(String viewId) {
        return [ SELECT Id, View_Fields_gne__c, Filter_Statement_gne__c, Sorting_Field_gne__c, ObjectType_gne__c, OwnerId FROM GNE_SFA2_My_Accounts_View_Setup__c WHERE Id = :selectedViewId ];
    }
    
    private String buildQueryString(GNE_SFA2_My_Accounts_View_Setup__c view) {
        visibleColumns = getViewColumnsByselectedView(view);
        filterStatements = getFiltersBySelectedView(view);
        getColumnHeaders(visibleColumns);
            String queryString = 'SELECT ';
            for(String viewField : visibleColumns) {
                queryString += viewField + ', ';
            }
            queryString = queryString.substring(0, queryString.length() - 2);
            queryString += ' FROM ' + objectType; 
            
            if(filterStatements.size() > 0) {
                queryString += ' WHERE ';
                for(String filterColumn : filterStatements){
                    queryString += getFilterStatement(filterColumn);
                }
                // remove last AND
                queryString = queryString.substring(0, queryString.lastIndexOf(' AND '));
            }
            
            queryString += ' ORDER BY ' + sortColumn + ' ' +sortDirection+ ' LIMIT ' + PAGE_SIZE + ' OFFSET ' + ((pageNumber-1)*PAGE_SIZE);
          return queryString;  
    }
    
    private String buildCountQueryString(GNE_SFA2_My_Accounts_View_Setup__c view) {
        visibleColumns = getViewColumnsByselectedView(view);
        filterStatements = getFiltersBySelectedView(view);
        getColumnHeaders(visibleColumns);
            String queryString = 'SELECT COUNT() FROM ' + objectType;
            if(filterStatements.size() > 0) {
                queryString += ' WHERE ';
                for(String filterColumn : filterStatements){
                    queryString += getFilterStatement(filterColumn);
                }
                // remove last AND
                System.debug(queryString);
                queryString = queryString.substring(0, queryString.lastIndexOf(' AND '));
                System.debug(queryString);
            }
            
            queryString += ' LIMIT ' + MAX_RECORDS_COUNT;
          return queryString;  
    }
    
    public PageReference loadRecords() {
        if(selectedViewId != null) {
            selectedView = getView(selectedViewId);
            sortColumn = selectedView.Sorting_Field_gne__c;
            if(oldSortColumn == null) {
                oldSortColumn = sortColumn;
            }
            visibleColumns = getViewColumnsByselectedView(selectedView);
            filterStatements = getFiltersBySelectedView(selectedView);
            getColumnHeaders(visibleColumns);
            String queryString = 'SELECT ';
            for(String viewField : visibleColumns) {
                queryString += viewField + ', ';
            }
            queryString = queryString.substring(0, queryString.length() - 2);
            queryString += ' FROM ' + objectType; 
            
            if(filterStatements.size() > 0) {
                queryString += ' WHERE ';
                for(String filterColumn : filterStatements){
                    queryString += getFilterStatement(filterColumn);
                }
                // remove last AND
                System.debug(queryString);
                queryString = queryString.substring(0, queryString.lastIndexOf(' AND '));
                System.debug(queryString);
            }
            
            queryString += ' ORDER BY ' + sortColumn + ' ' +sortDirection+ ' LIMIT ' + PAGE_SIZE + ' OFFSET ' + ((pageNumber-1)*PAGE_SIZE);
            System.debug('kwiatkol ' + queryString);
            records = wrapResults(Database.query(queryString));
            
            recordsCount = countRecords();
            pageNumbers = countPageNumbers();
            hasNext = checkIfHasNext();
            hasPrevious = checkIfHasPrevious();
        }
        return null;
    }
    
    private String getFilterStatement(String filterColumn){
        String query;
        if(filterColumn.startsWith('(NOT')){
            query = '(NOT ' +filterColumn + ' AND ';
        }else{
            query = filterColumn + ' AND ';
        }
        return query;
    }
    
    private Integer countRecords() {
        selectedView = getView(selectedViewId);
        Integer recordsCount = 0;
        if(selectedView != null) {
            recordsCount = Database.countQuery(buildCountQueryString(selectedView));
            if(recordsCount == MAX_RECORDS_COUNT) {
                maxRecordsReached = true;
            } else {
                maxRecordsReached = false;
            }
            if(recordsCount == 0) {
                pageNumber = 0;
            }
        } else {
            maxRecordsReached = false;
            pageNumber = 0;
        }
        return recordsCount;
    }
    
    public PageReference getSelected() {
        Set<Id> result = new Set<Id>();
        for(ListItemWrapper record : records) {
            if(record.selected) {
                result.add(record.obj.Id);
            }
        }
        baseListController.setSelectedRecords(result);
        return null;
    }
    
    public Integer countPageNumbers(){
        return Math.ceil(recordsCount / (PAGE_SIZE * 1.0)).intValue();
    }
    
    // get view columns basing on the selected view
    private List<String> getViewColumnsBySelectedView(GNE_SFA2_My_Accounts_View_Setup__c selectedView){
        List<String> columns = new List<String>();
        if(selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != ''){
           columns = selectedView.View_Fields_gne__c.split(';', 0);
        }
        return columns;
    }
    
    // get filters basing on the selected view
    private List<String> getFiltersBySelectedView(GNE_SFA2_My_Accounts_View_Setup__c selectedView){
        List<String> filters = new List<String>();
        if(selectedView.Filter_Statement_gne__c != null && selectedView.Filter_Statement_gne__c != ''){
           filters = selectedView.Filter_Statement_gne__c.split(';', 0);
        }
        return filters;
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
            sortDirection = 'ASC';
            oldSortColumn = sortColumn;
        }
        return loadRecords();
    }
    
    // prepare select options for views
    private List<SelectOption> prepareSelectOptions(List<GNE_SFA2_My_Accounts_View_Setup__c> views){
        List<SelectOption> selectOptions = new List<SelectOption>();
        if(views == null || views.isEmpty()){
            selectOptions.add(new SelectOption('','No Views Defined'));
        } else {
            for(GNE_SFA2_My_Accounts_View_Setup__c view: views){
                selectOptions.add(new SelectOption(view.Id, view.View_Name_gne__c));
            }
        }
        return selectOptions;
    }
    
    // get views defined for user   
    //priviledged profies can see all views
    //normal users can see own views, public views or views enabled for user profile
    private List<GNE_SFA2_My_Accounts_View_Setup__c> getViews(){
        String[] privilegedProfiles = settings.Privileged_Profiles_gne__c.split(',');
        String profileName = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()].Name;
        for(String name: privilegedProfiles){
            if(profileName == name){
                return [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c
                        FROM GNE_SFA2_My_Accounts_View_Setup__c WHERE Page_Name_gne__c = :nameOfThePage 
                        ORDER BY View_Name_gne__c];
            }
        }
        
        List<GNE_SFA2_My_Accounts_View_Setup__c> result = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c
                                                            FROM GNE_SFA2_My_Accounts_View_Setup__c
                                                            WHERE (OwnerId = :UserInfo.getUserId() OR Visibility_gne__c='public') AND Page_Name_gne__c = :nameOfThePage  ORDER BY View_Name_gne__c];
        //get all views available for user profile
        for(GNE_SFA2_My_Accounts_View_Setup__c view: [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Profiles_gne__c
                                                            FROM GNE_SFA2_My_Accounts_View_Setup__c
                                                            WHERE Visibility_gne__c='restricted' AND Page_Name_gne__c = :nameOfThePage ORDER BY View_Name_gne__c]){
            for(Id profileId: view.Profiles_gne__c.split(',')){
                if(UserInfo.getProfileId()==profileId){
                    result.add(view);
                    break;
                }
            }                                                       
        }
        GNE_SFA2_Util.sortList(result, 'View_Name_gne__c', true);
        return result; 
    }
    
    private void checkLastSeenView() {
       if(visibleViews != null && visibleViews.size() > 0 &&  userPreferences != null && userPreferences.size() > 0){
            if(userPreferences[0].Last_Account_View_Used_gne__c == null){
                userPreferences[0].Last_Account_View_Used_gne__c = visibleViews.get(0).id;
            }
            selectedViewId = userPreferences[0].Last_Account_View_Used_gne__c; 
        }
    }
    
    public class ListItemWrapper {
        public sObject obj { get; set; }
        public Boolean selected { get; set; }
        
        public ListItemWrapper(sObject obj, Boolean selected) {
            this.obj = obj;
            this.selected = selected;
        }
        
    }*/
}