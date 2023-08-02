public with sharing class EDM_Classif_Requests_Log_Controller extends GNE_SFA2_List_View_Base_Controller {

	public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
	public String accountId {get; set;}
	public Boolean hasAccountFilter {get;set;}

	public List<String> selectedColumns { get; set; }
    public Map<String,String> columnHeaders { get; set; }
    public Map<String,String> columnHeadersType { get; set; }
    public Map<String,Boolean> fieldReferenceToExportHasExist {get;set;}

	private SFA2_User_Preferences_gne__c userPreferences;
    private String nameOfThePage = 'Classification Log';

	public EDM_Classif_Requests_Log_Controller() {
		super('EDM_Classification_Request_gne__c');
		thisController = this;
		GNE_SFA2_User_App_Context_gne__c userContext = GNE_SFA2_Util.getUserApplicationContext();
		try {
			SFA2_Configuration_Object_gne__c config = [ SELECT Name, Attributes_gne__c, Section_Header_gne__c 
														FROM SFA2_Configuration_Object_gne__c
														WHERE Configuration_Type_gne__c = 'List Page'
														 AND Is_Active_gne__c = true
														 AND Application_Type__c = :userContext.App_Name_gne__c
														 AND Role_gne__c = :userContext.Role_gne__c 
														 AND Brand_gne__c = :userContext.Brand_gne__c 
														 AND Object_Name_gne__c = 'EDM_Classification_Request_gne__c'
														 AND Section_Header_gne__c = 'Classification Log'
														 ORDER BY Name LIMIT 1 ];
			super.setPageConfiguration(config);
		}
		catch (Exception ex) {
			System.debug('EDM_Classif_Requests_Log_Controller: Configuration Object not found');
		}
		accountId = ApexPages.currentPage().getParameters().get('accountId');
		if(accountId != null && accountId !=''){
			hasAccountFilter = true;
		} else {
			hasAccountFilter = false;
		}
	}

	public pageReference init(){
		if(!EDM_Classification_Request_gne__c.sObjectType.getDescribe().isUpdateable()){
            return GNE_SFA2_Util.redirectToAccessDeniedPage();
        }
        return null;
	}

	public PageReference exportToExcel() {
		try{
			userPreferences = [SELECT Last_View_Used_gne__c
							FROM  SFA2_User_Preferences_gne__c 
							WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'Classification Log' 
							AND User_gne__c = :Userinfo.getUserId() LIMIT 1];
		} 
		catch(Exception e) {
			userPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = UserInfo.getUserId());
		}

		if(!String.isEmpty(userPreferences.Last_View_Used_gne__c)) {
			PageReference pageRef = new PageReference('/apex/EDM_Classif_Requests_Log_Export');
			pageRef.setredirect(false);
			pageRef.getParameters().put('viewId', userPreferences.Last_View_Used_gne__c);
			return pageRef;
		} 
		else {
            PageReference pageRef = new PageReference('/apex/EDM_Classif_Requests_Log_Export');
            pageRef.setredirect(false);
            String viewId = getViews()[0].Id;
            pageRef.getParameters().put('viewId', viewId);
			return pageRef;
		}
	}

	public List<EDM_Classification_Request_gne__c> getLogViewRecords() {

		String viewId = ApexPages.currentPage().getParameters().get('viewId');


		List<SFA2_View_Config_gne__c> viewConf = [SELECT View_Fields_gne__c, Filter_Statement_gne__c, Object_Type_gne__c, 
														Sorting_Field_gne__c, Sorting_Order_gne__c, Records_Visibility__c
												FROM SFA2_View_Config_gne__c
												WHERE Id = :viewId];

		selectedColumns = viewConf[0].View_Fields_gne__c.replace('EDM_CV_Link_Formula_gne__c', 'EDM_CV_Attachment_Link_gne__c').split(';');
        columnHeaders = getColumnHeaders(selectedColumns);
        columnHeadersType = getColumnHeadersType(selectedColumns);

		String query = 'SELECT ';

		query += viewConf[0].View_Fields_gne__c.replace(';', ', ');
		query = query.replace('EDM_Account_gne__c', 'EDM_Account_gne__r.Name');
        query = query.replace('CreatedById', 'CreatedBy.Name');
		query = query.replace('EDM_Requestor_gne__c', 'EDM_Requestor_gne__r.Name');
		query = query.replace('LastModifiedById', 'LastModifiedBy.Name');
        query = query.replace('EDM_CV_Link_Formula_gne__c', 'EDM_CV_Attachment_Link_gne__c');
		query += ' FROM ' + viewConf[0].Object_Type_gne__c;

		List<String> whereStatementList = getFiltersBySelectedView(viewConf[0]);
		String whereStatement = String.join(whereStatementList, ' AND ');

		//if from account
		if (hasAccountFilter == true) {
			query += ' WHERE EDM_Status_gne__c=\'Completed\' AND EDM_Account_gne__c =\'' + accountId + '\'';
		} 
		//not from account
		else if (whereStatementList.size() > 0 && viewConf[0].Records_Visibility__c == 'My Records') { 
			query += ' WHERE ' + whereStatement + ' AND OwnerId = \'' + UserInfo.getUserId() + '\'';
		}
		else if (whereStatementList.size() == 0 && viewConf[0].Records_Visibility__c == 'My Records') {
			query += ' WHERE OwnerId = \'' + UserInfo.getUserId() + '\'';
		}
		else if (whereStatementList.size() > 0 && viewConf[0].Records_Visibility__c == 'All Records') {
			query += ' WHERE ' + whereStatement;
		}

		if (viewConf[0].Sorting_Field_gne__c != null && viewConf[0].Sorting_Field_gne__c  != '') {
			query += ' ORDER BY ' + viewConf[0].Sorting_Field_gne__c;

			if (viewConf[0].Sorting_Order_gne__c != null && viewConf[0].Sorting_Order_gne__c  != '') {
				query += ' ' + viewConf[0].Sorting_Order_gne__c;
			}
		}	
        query += ' LIMIT 1000';	

		List<EDM_Classification_Request_gne__c> requestList = Database.query(query);

		return requestList;
	}

    private Map<String, String> getColumnHeaders(List<String>columnsNames){
        Map<String, String> result = new Map<String, String>();
        for(String columnName: columnsNames){
            String fieldName = columnName.substring(columnName.indexOf('.')+1);
            String label = Schema.SObjectType.EDM_Classification_Request_gne__c.fields.getMap().get(fieldName).getDescribe().getLabel();
            result.put(columnName, label);
        }
        return result;
    }

    private Map<String, String> getColumnHeadersType(List<String>columnsNames){
        Map<String, String> result = new Map<String, String>();
        for(String columnName: columnsNames){
            String fieldName = columnName.substring(columnName.indexOf('.')+1);
            Schema.DisplayType type = Schema.SObjectType.EDM_Classification_Request_gne__c.fields.getMap().get(fieldName).getDescribe().getType();
            result.put(columnName, type.Name());
        }
        return result;
    }

	private void populateCustomFilterVariables() {
		customFilterVariable_1	= thisController.customFilterVariable_1;
		customFilterVariable_2	= thisController.customFilterVariable_2;
		customFilterVariable_3	= thisController.customFilterVariable_3;
		customFilterVariable_4	= thisController.customFilterVariable_4;
		customFilterVariable_5	= thisController.customFilterVariable_5;
		customFilterVariable_6	= thisController.customFilterVariable_6;
		customFilterVariable_7	= thisController.customFilterVariable_7;
		customFilterVariable_8	= thisController.customFilterVariable_8;
		customFilterVariable_9	= thisController.customFilterVariable_9;
		customFilterVariable_10	= thisController.customFilterVariable_10;
    }

	private List<String> getFiltersBySelectedView(SFA2_View_Config_gne__c selectedView) {
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
                	filterExpr = thisController.getCustomFilterExpression(conditionItem);
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

    public String getHostName() {
        String host = ApexPages.CurrentPage().getHeaders().get('host');
        return host;
    }
}