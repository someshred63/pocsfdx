public with sharing class GNE_SFA2_MyInteractions_Controller extends GNE_SFA2_List_View_Base_Controller {   
    private SFA2_User_Preferences_gne__c myPreferences;
    private String defaultSortOrder = 'ASC';  
    private Set<Id> accountsIdsBasedOnTSF;
    private Map<String, String> fieldOfUserReferenceMap;
    private Map<String, Boolean> userReferenceHasExist;
    private String queryString = 'SELECT ';
    private static Integer MAX_RECORDS_COUNT = 1000;
    
    public String sortColumn {get; set;}
    public String sortDirection {get; set;}
    public List<String> filterStatements { get; set; }
    public String selectedViewId {get; set;}
    public Map<String, String> columnHeaders { get;set; }
    public Map<String, Boolean> columnSortable { get;set; }
    public List<Call2_vod__c> viewWrappersInExport {get; set;}
    public transient List<String> viewColumnsInExport {get; set;}
    public SFA2_View_Config_gne__c selectedView {get; set;}
    
    

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
	
	public PageReference newClick() {
        PageReference searchBeforeCreate = Page.GNE_SFA2_SBC;
        searchBeforeCreate.getParameters().put('retURL', '/apex/GNE_SFA2_MyInteractions');
        if(GNE_SFA2_Util.isCanadaINFUUser()) {
            searchBeforeCreate.getParameters().put('allowType', 'HCP');
        }
        return searchBeforeCreate ;
    }
     
    public GNE_SFA2_MyInteractions_Controller () {
        super('Call2_vod__c');
        thisController = this;
    }
    
    public Boolean getIsMenuVisible() {
        return !GNE_SFA2_Util.isCanadaINFUUser();
    }
    
    public PageReference exportToExcelClick(){
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyInteraction_Export');
        return pageRef;
	}
    
    public void exportToExcel() {
        try{
			myPreferences = [
                SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c 
                FROM  SFA2_User_Preferences_gne__c 
                WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Interactions' AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
		} catch(Exception e){
			myPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = UserInfo.getUserId());
		}
        columnHeaders = new Map<String, String>();
        columnSortable = new Map<String, Boolean> ();
        List<SFA2_View_Config_gne__c> myViews = getViews();
        if(!myViews.isEmpty()){
			if(myPreferences.Last_View_Used_gne__c == null){
				myPreferences.Last_View_Used_gne__c = myViews.get(0).id;
			}
            selectedView = getView(myPreferences.Last_View_Used_gne__c);
            if(String.isBlank(sortColumn)) {
                sortColumn = selectedView.Sorting_Field_gne__c;
            } 
            if (String.isBlank(sortDirection)){
                if (String.isNotBlank(selectedView.Sorting_Order_gne__c)){
                    sortDirection = selectedView.Sorting_Order_gne__c;
                } else {
                    sortDirection = defaultSortOrder;
                }
            }
            
            String finalString = '';
            List<String> newSubstrings = new List<String>();
            for(String fieldName : selectedView.View_Fields_gne__c.split(';')){
                if(!fieldName.startsWith('BrandAffiliation.')){
                    newSubstrings.add(fieldName+';');
                    finalString += fieldName+';';
                }
            }
            finalString = finalString.removeEnd(';');
            selectedView.View_Fields_gne__c = finalString;
			
			selectedViewId = selectedView.Id;
            
            
            viewColumnsInExport = getViewColumnsBySelectedView(selectedView);
            getColumnHeadersAndSortable(viewColumnsInExport);
            
            String query = buildQueryString(selectedView);
            System.debug('QUERY::EXPORT '+query);
            viewWrappersInExport = Database.query(query) ;
		}        
    }
    
    public String getFileName() {
		String fileName = selectedView.View_Name_gne__c + ' - ' + String.valueOf(Date.Today());
		fileName = fileName.replaceAll('[^a-zA-Z0-9\\s-]', '');
		return fileName ;
	}
    
    private String getFilterStatement(String filterColumn){
        String query = filterColumn + ' AND ';
        return query;
    }
    
    private List<SFA2_View_Config_gne__c> getViews(){
		// select all public views
		List<SFA2_View_Config_gne__c> result = [
            SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Visibility_gne__c, Sorting_Order_gne__c, Records_Visibility__c  
			FROM SFA2_View_Config_gne__c
			WHERE ((Visibility_gne__c='private' AND OwnerId = :UserInfo.getUserId()) OR Visibility_gne__c='public') AND Page_Name_gne__c = 'My Interactions' ORDER BY View_Name_gne__c
        ];

		//select all views available for user based on sales roster
		List<SFA2_View_Config_gne__c> restricetedViews = [
            SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Application_Type_gne__c,
				Brand_gne__c, Role_gne__c, Visibility_gne__c, Records_Visibility__c  
			FROM SFA2_View_Config_gne__c
			WHERE Visibility_gne__c = 'restricted' AND Page_Name_gne__c = 'My Interactions' ORDER BY View_Name_gne__c 
        ];

        for(SFA2_View_Config_gne__c restrictedView : restricetedViews) {
            result.add(restrictedView);
        }

		GNE_SFA2_Util.sortList(result, 'View_Name_gne__c', true);
		return result;
	}
    
    private SFA2_View_Config_gne__c getView(Id viewId){
		return [
            SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Visibility_gne__c, Sorting_Order_gne__c, Records_Visibility__c  
			FROM SFA2_View_Config_gne__c
			WHERE Id =:viewId
        ];
	}
    
    public String getWorkbookProperties() {
		String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + selectedView.View_Name_gne__c + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
		return workbook;
	}    

	private List<String> getViewColumnsBySelectedView(SFA2_View_Config_gne__c selectedView){
		List<String> columns = new List<String>();
		if(selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != ''){
			columns = selectedView.View_Fields_gne__c.split(';', 0);
		}
        System.debug(columns);
		return columns;
	}
    
    public String getHostName() {
		String host = ApexPages.CurrentPage().getHeaders().get('host');
		return host;
	}
    
    private String buildQueryString(SFA2_View_Config_gne__c view) {
        String objectType ='Call2_vod__c';
        
        Map<String,Schema.SObjectField> sObjectFieldMap = prepareObjectTypeFieldsMap();
        Set<String> uniqueViewColumns = new Set<String>();
        fieldOfUserReferenceMap = new Map<String, String>();
        userReferenceHasExist = new Map<String, Boolean>();

        uniqueViewColumns.addAll(viewColumnsInExport);
        filterStatements = getFiltersBySelectedView(view);        
        
        for(String viewField : viewColumnsInExport) {
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
        
        if (view.Records_Visibility__c == 'My Records' && (GNE_SFA2_Util.isCanadaDirectorUser() || GNE_SFA2_Util.isCanadaRMLUser() || GNE_SFA2_Util.isCanadaOpsUser())){
        	view.Records_Visibility__c = 'All Records';
        }

        if(filterStatements.size() > 0 || view.Records_Visibility__c =='My Records') {
            queryString += ' WHERE ';
            
            if(GNE_SFA2_Util.isCanadaINFUUser() ) {
                accountsIdsBasedOnTSF = fetchAccountIdsBasedOnUserTerritories();
                queryString +=  ' (OwnerId = \''+UserInfo.getUserId()+'\' OR Account_vod__c IN : accountsIdsBasedOnTSF) AND (CreatedDate = LAST_N_MONTHS:12 OR CreatedDate = TODAY) AND ' ;
            }
            for(String filterColumn : filterStatements){
                queryString += getFilterStatement(filterColumn);
            }
            queryString = queryString.removeEnd(' AND ');
        }
        
        String sortColumnSoql = sortColumn;
        if(sortColumnSoql.toLowerCase().equalsIgnoreCase('id')){
            sortColumnSoql = 'id';
        }else if(sortColumnSoql.toLowerCase().endsWith('id') && !sortColumnSoql.contains('.')){
            sortColumnSoql = sortColumnSoql.toLowerCase().removeEnd('id') + '.Name';
        }else if(!sortColumnSoql.contains('.')){
            Schema.DisplayType sortColumnType = Call2_vod__c.sObjectType.getDescribe().fields.getMap().get(sortColumn).getDescribe().getType();
            //Schema.DisplayType sortColumnType = Schema.getGlobalDescribe().get(view.Object_Type_gne__c).getDescribe().fields.getMap().get(sortColumn).getDescribe().getType();
            if(sortColumnType == Schema.DisplayType.Reference && sortColumnSoql.toLowerCase().endsWith('__c')){
                sortColumnSoql = sortColumnSoql.toLowerCase().removeEnd('__c') + '__r.Name';
            }
        }
        
        queryString += ' ORDER BY ' + sortColumnSoql + ' ' +sortDirection+ ' NULLS LAST LIMIT ' + MAX_RECORDS_COUNT ;
        
        System.debug('List view query: '+queryString);
        return queryString;  
    }
    
    public Map<String,Schema.SObjectField> prepareObjectTypeFieldsMap () {        
        Schema.DescribeSObjectResult result = Call2_vod__c.sObjectType.getDescribe();  
        Map<String,Schema.SObjectField> sObjectFieldMap = result.fields.getMap();        
        return sObjectFieldMap;
    }
    
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
        
        return filters;
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
            } 
            Schema.DescribeFieldResult fieldDescribe = Call2_vod__c.sObjectType.getDescribe().fields.getMap().get(column).getDescribe();
            columnHeaders.put(column, fieldDescribe.getLabel());
            Schema.DisplayType fieldType = fieldDescribe.getType();
            if(fieldType == Schema.Displaytype.Multipicklist || fieldType == Schema.Displaytype.Textarea) {
                columnSortable.put(column, false);
            } else {
                columnSortable.put(column, true);
            }
        }        
    }
    
    private void prepareFieldOfUserReferenceMaps(Map<String,Schema.SObjectField> sObjectFieldMap, String viewField) {
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
    
    private Set<Id> fetchAccountIdsBasedOnUserTerritories() {
        if(accountsIdsBasedOnTSF != null) return accountsIdsBasedOnTSF;
        List<String> terNames = new List<String>();
        
        for (Territory2 terr : GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())) {
            terNames.add(terr.Name);
        }

        if(terNames.isEmpty()) return new Set<Id>();
        
        Set<Id> result = new Set<Id>();
        Integer queryLimit = Limits.getLimitQueryRows() - Limits.getQueryRows() > 40000 ? 40000 : Limits.getLimitQueryRows() - Limits.getQueryRows();
        if (queryLimit < 1000) queryLimit = 0;
        for(TSF_vod__c tsf : [
            SELECT Account_vod__c FROM TSF_vod__c WHERE Territory_vod__c IN :terNames AND External_Id_vod__c <> null AND Account_vod__r.IsPersonAccount = true LIMIT : queryLimit
        ]){
            result.add(tsf.Account_vod__c);
        }        

        return result;
    }

}