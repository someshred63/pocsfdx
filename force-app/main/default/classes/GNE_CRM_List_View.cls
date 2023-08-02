/* 
 * GNE_CRM_List_View
 * This class is used as Util class for other list view controllers.
 *
 * Created By :         Lukasz Kozminski (lukasz.kozminski@contractors.roche.com)
 * Last Modified By :   Lukasz Kozminski (lukasz.kozminski@contractors.roche.com)
 * Last Modified Date : 05/30/2016
 */
 
public virtual with sharing class GNE_CRM_List_View {
	
	public static final String DEFAULT_SORT_ORDER = 'ASC';
	private static Integer PAGE_SIZE = 50;
	private static Integer MAX_RECORDS_COUNT = 1000;
	
	public GNE_SFA2_List_View_Base_Controller baseListController { get; set; }
	public String referenceField {get;set;}
	
	public Boolean hasViews { get; set; }
	
	private String selectedSortColumn { get; set; }
	private String selectedSortDirection { get; set; }
	private String searchValue { get; set; }
	
	public String userTimeZone { get; private set; }
	public String objectName { get; set; }
	public String nameOfThePage { get; set; }
	public Boolean checkboxesEnabled { get; set; }
	public Boolean editEnabled { get; set; }
	public Boolean deleteEnabled { get; set; }
	public Boolean sortingEnabled { get; set; }
	public String editURL { get; set; }
	
	public GNE_CRM_List_View() {
		userTimeZone = String.valueOf(UserInfo.getTimeZone());
	}
	
	public Boolean getEditEnabledCalc(){
		return editEnabled && Schema.getGlobalDescribe().get(objectName).getDescribe().isUpdateable();
	}
	
	public Boolean getDeleteEnabledCalc(){
        return deleteEnabled && Schema.getGlobalDescribe().get(objectName).getDescribe().isDeletable();
	}
	
	public String getSettingsJson(){
		return JSON.serializePretty(GNE_MCCO_CRM_Util.getUserSettings());
	}
	
	public String getPreferencesJson(){
		SFA2_User_Preferences_gne__c preferences = GNE_MCCO_CRM_Util.getUserPreferences(nameOfThePage);
		return JSON.serializePretty(preferences);
	}
	
	public String getViewsJson(){	
		List<SFA2_View_Config_gne__c> viewsList = getViews();
		return JSON.serializePretty(viewsList);
	}
	
	protected virtual List<SFA2_View_Config_gne__c> getViews(){
		return GNE_MCCO_CRM_Util.getViews(nameOfThePage);
	}
	
	public String getButtonsListJson(){	 
		return JSON.serializePretty(GNE_MCCO_CRM_Util.getButtonsList(objectName));
	}
	
	public String getSelectedViewJson(){
		SFA2_User_Preferences_gne__c preferences = GNE_MCCO_CRM_Util.getUserPreferences(nameOfThePage);
		List<SFA2_View_Config_gne__c> viewsList = getViews();	
		String selectedViewId = String.isNotEmpty(ApexPages.currentPage().getParameters().get('selectedViewId')) ? ApexPages.currentPage().getParameters().get('selectedViewId') : preferences.Last_View_Used_gne__c;
		if(selectedViewId == null){
			selectedViewId = viewsList.get(0).Id;
		}
		return JSON.serializePretty(GNE_MCCO_CRM_Util.getView(selectedViewId));
	}
	
	 /* 
     * updateViewPreference(String viewId)
     *
     * Update user preference with new last view
     *
     * return boolean
     */
    @RemoteAction
    public static Boolean updateViewPreference(String viewId, String pageName) {
        SFA2_User_Preferences_gne__c preference;
        List<SFA2_User_Preferences_gne__c> preferences = [ SELECT Last_View_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = :pageName AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
        if(preferences.isEmpty()){
          preference = new SFA2_User_Preferences_gne__c( User_gne__c = UserInfo.getUserId());
        }else{
        	preference = preferences.get(0);
        }
        preference.Last_View_Used_gne__c = viewId;
        try {
            upsert preference;
        } catch(DMLException e) {
            return false;
        }
        return true;
    }
	
	
	@RemoteAction
	public static void deleteRecord(String recordId){
		Database.delete(recordId);
	}
	
	@RemoteAction
	@ReadOnly
	public static ViewWrapper loadRecords(String selectedViewJson, Integer page, Integer pageSize, String sortColumn, String sortDirection, String searchValue) {
		SFA2_View_Config_gne__c selectedView = encodeSelectedView(selectedViewJson);
		List<String> viewColumns = getViewColumns(selectedView);
		Map<String, String> columnsTypes = getColumnsTypes(selectedView.Object_Type_gne__c, viewColumns);
		Map<String, Boolean> columnsSortable = getColumnsSortable(selectedView.Object_Type_gne__c, viewColumns);
		
		String queryString = buildQueryString(selectedView, viewColumns, columnsTypes, page, pageSize, sortColumn, sortDirection, searchValue);
		List<RecordWrapper> records = wrapResults(Database.query(queryString));
		Integer recordsCount = countRecords(selectedView);
		Map<String, String> columnsHeaders = getColumnsHeaders(selectedView.Object_Type_gne__c, viewColumns);
		ViewWrapper wrapper = new ViewWrapper(recordsCount, records, columnsHeaders, columnsTypes, columnsSortable);
		return wrapper;
	}
	
	public static Integer countRecords(SFA2_View_Config_gne__c selectedView) {
		Integer recordsCount = 0;
		if(selectedView != null) {
			recordsCount = Database.countQuery(buildCountQueryString(selectedView));
		}
		return recordsCount;
	}
	
	private static String buildCountQueryString(SFA2_View_Config_gne__c view) {
		List<String> visibleColumns = getViewColumns(view);
		List<String> filterStatements = GNE_MCCO_CRM_Util.getFiltersBySelectedView(view);
		String countQueryString = 'SELECT COUNT() FROM ' + view.Object_Type_gne__c;
		if(filterStatements.size() > 0 || view.Records_Visibility__c=='My Records') {
			countQueryString += ' WHERE ';
			if (view.Object_Type_gne__c.equals('Speaker_Bureau_Membership_gne__c') && view.Records_Visibility__c=='My Records') {
				countQueryString += ' Speaker_Bureau_ID_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
			}
			if (view.Object_Type_gne__c.equals('ART_Issue_gne__c') && view.Records_Visibility__c=='My Records') {
				countQueryString += ' ART_Site_Local_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
			}
			if((!view.Object_Type_gne__c.equals('Speaker_Bureau_Membership_gne__c') && !view.Object_Type_gne__c.equals('ART_Issue_gne__c')) && view.Records_Visibility__c=='My Records'){
				countQueryString += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
			}
			for(String filterColumn : filterStatements){
				countQueryString += filterColumn +' AND ';
			}
			countQueryString = countQueryString.removeEnd(' AND ');
		}
		
		if( (view.Object_Type_gne__c.equals('Task') || view.Object_Type_gne__c.equals('Event')) && (view.Records_Visibility__c=='All Records') ){
			if(!countQueryString.contains('WHERE')){
				countQueryString += ' WHERE OwnerId =\'' + UserInfo.getUserId()+'\' ';
			}else{
				countQueryString += 'AND OwnerId = \''+UserInfo.getUserId()+'\' ';
			}
		}
		countQueryString += ' LIMIT ' + MAX_RECORDS_COUNT;
		return countQueryString; 
	}
	
	public static String buildQueryString(SFA2_View_Config_gne__c view, List<String> visibleColumns, Map<String, String> columnsTypes, Integer page, Integer pageSize, String sortColumn, String sortDirection, String searchValue) {
		Map<String, String> fieldOfUserReferenceMap = new Map<String, String>();
		Map<String, Boolean> userReferenceHasExist = new Map<String, Boolean>();
		
		Set<String> uniqueViewColumns = new Set<String>(visibleColumns);
		List<String> filterStatements = GNE_MCCO_CRM_Util.getFiltersBySelectedView(view);
		String queryString = 'SELECT ';
		
		for(String column : visibleColumns) {
			if(columnsTypes.get(column)=='REFERENCE'){
				if(column.endsWithIgnoreCase('__c')){
					queryString += column + ', ';
					queryString += column.replace('__c', '__r.Name') + ', ';
				}else if(column.endsWithIgnoreCase('Id')){
					queryString += column + ', ';
					queryString += column.removeEndIgnoreCase('id') + '.Name' + ', ';
				}
			}else{
				queryString += column + ', ';
			}
		}
		
		
		if(!uniqueViewColumns.contains('createddate')){
			queryString += 'CreatedDate, ';
		}
		if(!uniqueViewColumns.contains('lastmodifieddate')){
			queryString += 'LastModifiedDate, ';
		}
		
		if(queryString == 'SELECT '){
			queryString += 'Id, ';
		}
		queryString = queryString.removeEnd(', ');
		
		queryString += ' FROM ' + view.Object_Type_gne__c; 

		if(filterStatements.size() > 0 || view.Records_Visibility__c=='My Records') {
			queryString += ' WHERE ';
			if (view.Object_Type_gne__c.equals('Speaker_Bureau_Membership_gne__c') && view.Records_Visibility__c=='My Records') {
				queryString += ' Speaker_Bureau_ID_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
			}
			if (view.Object_Type_gne__c.equals('ART_Issue_gne__c') && view.Records_Visibility__c=='My Records') {
				queryString += ' ART_Site_Local_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
			}
			if((!view.Object_Type_gne__c.equals('Speaker_Bureau_Membership_gne__c') && !view.Object_Type_gne__c.equals('ART_Issue_gne__c')) && view.Records_Visibility__c=='My Records'){
				queryString += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
			}
			for(String filterColumn : filterStatements){
				queryString += filterColumn + ' AND ';
			}
			queryString = queryString.removeEnd(' AND ');
		}
		
		if( (view.Object_Type_gne__c.equals('Task') || view.Object_Type_gne__c.equals('Event')) && (view.Records_Visibility__c=='All Records') ){
			if(!queryString.contains('WHERE')){
				queryString += ' WHERE OwnerId =\'' + UserInfo.getUserId()+'\' ';
			}else{
				queryString += 'AND OwnerId = \''+UserInfo.getUserId()+'\' ';
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
		
		queryString += ' ORDER BY ' + sortColumnSoql + ' ' +sortDirection+ ' NULLS LAST LIMIT ' + PAGE_SIZE + ' OFFSET ' + ((page-1)*PAGE_SIZE);
		system.debug(queryString);
		return queryString; 
	}
	
	// get view columns basing on the selected view
	public static List<String> getViewColumns(SFA2_View_Config_gne__c selectedView){
		List<String> columns = new List<String>();
		if(selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != ''){
			for(String column : selectedView.View_Fields_gne__c.split(';', 0)){
				columns.add(column.toLowerCase());
			}
		}
		return columns;
	}
	
	public static Map<String, String> getColumnsHeaders(String objectType, List<String> columns) {
		Map<String, Schema.SObjectField> fieldsDescribe = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
		Map<String, String> columnHeaders = new Map<String, String>();
		for(String column : columns) {
			if(column.equalsIgnoreCase('recordtypeid')) {
				columnHeaders.put(column, 'Record Type');
			}else if(column.equalsIgnoreCase('owner.firstname')) {
				columnHeaders.put(column, 'Owner First Name');
			} else if(column.equalsIgnoreCase('owner.lastname')){
				columnHeaders.put(column, 'Owner Last Name');
			} else if(column.equalsIgnoreCase('owner.alias')){
				columnHeaders.put(column, 'Owner Alias');
			} else if(column.equalsIgnoreCase('createdby.alias')){
				columnHeaders.put(column, 'Created By Alias');
			} else if(column.equalsIgnoreCase('createdbyid')){
				columnHeaders.put(column, 'Created By');
			} else if(column.equalsIgnoreCase('lastmodifiedby.alias')){
				columnHeaders.put(column, 'Last Modified By Alias');
			} else if(column.equalsIgnoreCase('lastmodifiedbyId')){
				columnHeaders.put(column, 'Last Modified By');
			} else if(column.equalsIgnoreCase('account.name')){
				columnHeaders.put(column, 'Name');
			} else if(column.equalsIgnoreCase('accountid')){
				columnHeaders.put(column, 'Account ID');
			} else if(column.equalsIgnoreCase('account.parentid')){
				columnHeaders.put(column, 'Account Parent Account');
			} else if(column.equalsIgnoreCase('reportstoid')){
				columnHeaders.put(column, 'Reports To');
			} else if(column.equalsIgnoreCase('reportsto.lastname')){
				columnHeaders.put(column, 'Reports To Last Name');
			} else if(column.equalsIgnoreCase('reportsto.firstname')){
				columnHeaders.put(column, 'Reports To First Name');
			}else{ 
				Schema.DescribeFieldResult fieldDescribe = fieldsDescribe.get(column).getDescribe();
				columnHeaders.put(column, fieldDescribe.getLabel());
			}
		} 
		return columnHeaders;
	}
	
	public static Map<String, Boolean> getColumnsSortable(String objectType, List<String>columnsNames){
		Map<String, Boolean> result = new Map<String, Boolean>();
		Map<String, Schema.SObjectField> fieldsDescribe = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
		
		for(String columnName: columnsNames){
			if(fieldsDescribe.containsKey(columnName)){
				result.put(columnName.toLowerCase(), fieldsDescribe.get(columnName).getDescribe().isSortable());
			}else{
				result.put(columnName.toLowerCase(), true);
			}
		}
		return result;
	}
	
	public static Map<String, String> getColumnsTypes(String objectType, List<String>columnsNames){
		Map<String, String> result = new Map<String, String>();
		Map<String, Schema.SObjectField> fieldsDescribe = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
		for(String columnName: columnsNames){
			if(fieldsDescribe.containsKey(columnName)){
				result.put(columnName.toLowerCase(), fieldsDescribe.get(columnName).getDescribe().getType().Name());
			}else{
				result.put(columnName.toLowerCase(), 'STRING');
			}
		}
		return result;
	}
	
	public static SFA2_View_Config_gne__c encodeSelectedView(String jsonString) {
		JSONParser parser = JSON.createParser(jsonString);
		SFA2_View_Config_gne__c result = (SFA2_View_Config_gne__c)parser.readValueAs(SFA2_View_Config_gne__c.class);
		return result;
	} 
	
	public static List<RecordWrapper> wrapResults(List<sObject> sObjectsList) {
		List<RecordWrapper> result = new List<RecordWrapper>();
		for(sObject o : sObjectsList) {
			result.add(new RecordWrapper(o));
		}
		return result;
	}
	
	
	/* 
	* WrapperClass AccountWrapper
	*
	*/
	public class ViewWrapper {

		public Integer countItems { get; private set; }
		public List<RecordWrapper> items { get; private set; }
		public Map<String, String> columnsHeaders { get; private set; }
		public Map<String, String> columnsHeadersType { get; private set; }
		public Map<String, Boolean> columnsSortable { get; private set; }

		public ViewWrapper(Integer countItems, List<RecordWrapper> items, Map<String, String> columnsHeaders, Map<String, String> columnsTypes, Map<String, Boolean> columnsSortable){
			this.countItems = countItems;
			this.items = items;
			this.columnsHeaders = columnsHeaders;
			this.columnsHeadersType = columnsTypes;
			this.columnsSortable = columnsSortable;
		}

	}
	
	/* 
	* WrapperClass RecordWrapper
	*
	* It keeps
	*/
	public class RecordWrapper {
		public Boolean selected {get; set;}
		public Id recordId {get; set;}
		public sObject record {get; set;}

		public RecordWrapper(){}
		
		public RecordWrapper(Sobject record){
			this.selected = false;
			this.recordId = (Id)record.get('Id');
			this.record = record;
		}
	}
}