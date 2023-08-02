public with sharing class GNE_SFA2_ListViewConfig {
	private String nameOfThePage;

	public GNE_SFA2_ListViewConfig(String nameOfThePage) {
		this.nameOfThePage = nameOfThePage;
	}

	public SFA2_View_Config_gne__c getCurrentView() {
		SFA2_User_Preferences_gne__c userPreferences = getUserPreferences();
		List<SFA2_View_Config_gne__c> visibleViews = getViews();
		String selectedViewId = getLastSeenOrFirstAvailableViewId(visibleViews, userPreferences);
		return [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, 
						Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, 
						Records_Visibility__c, Object_Type_gne__c 
				FROM SFA2_View_Config_gne__c 
				WHERE Id = :selectedViewId];
	}

	public List<SFA2_View_Config_gne__c> getViews() {
		// select all public views
		List<SFA2_View_Config_gne__c> result = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Object_Type_gne__c,
														Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Records_Visibility__c,
														Visibility_gne__c
												FROM SFA2_View_Config_gne__c
												WHERE 
													((Visibility_gne__c='private' AND OwnerId = :UserInfo.getUserId()) OR Visibility_gne__c='public') 
													AND Page_Name_gne__c = :nameOfThePage 
												ORDER BY View_Name_gne__c];
															
		//select all views available for user based on sales roster
		List<SFA2_View_Config_gne__c> restricetedViews = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Object_Type_gne__c,
																Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Records_Visibility__c,
																Application_Type_gne__c, Brand_gne__c, Role_gne__c, Visibility_gne__c
															FROM SFA2_View_Config_gne__c
															WHERE Visibility_gne__c = 'restricted' AND Page_Name_gne__c = :nameOfThePage 
															ORDER BY View_Name_gne__c];
															
		// check all restricted views
		Set<String> restrictedViewNames = new Set<String>();
		for(SFA2_View_Config_gne__c restrictedView : restricetedViews) {
			if (!restrictedViewNames.contains(restrictedView.View_Name_gne__c) && restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c == null && restrictedView.Role_gne__c == null) {   // app wide view
				if (GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c) {
					result.add(restrictedView);
					restrictedViewNames.add(restrictedView.View_Name_gne__c);
				}
			}
			if (!restrictedViewNames.contains(restrictedView.View_Name_gne__c) && restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c != null && restrictedView.Role_gne__c == null) {   // brand wide view
				if (GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c == restrictedView.Brand_gne__c) {
					result.add(restrictedView);
					restrictedViewNames.add(restrictedView.View_Name_gne__c);
				}
			}
			if (!restrictedViewNames.contains(restrictedView.View_Name_gne__c) && restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c != null && restrictedView.Role_gne__c != null) {   // role wide view
				if (GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c == restrictedView.Brand_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c == restrictedView.Role_gne__c) {
					result.add(restrictedView);
					restrictedViewNames.add(restrictedView.View_Name_gne__c);
				}
			}
			
			if (!restrictedViewNames.contains(restrictedView.View_Name_gne__c) && restrictedView.Application_Type_gne__c != null && restrictedView.Brand_gne__c == null && restrictedView.Role_gne__c != null) {   // app + role wide view
				if (GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c == restrictedView.Application_Type_gne__c && GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c == restrictedView.Role_gne__c) {
					result.add(restrictedView);
					restrictedViewNames.add(restrictedView.View_Name_gne__c);
				}
			}
		}
		restrictedViewNames.clear();

		GNE_SFA2_Util.sortList(result, 'View_Name_gne__c', true);
		return result; 
	}

	private SFA2_User_Preferences_gne__c getUserPreferences() {
		SFA2_User_Preferences_gne__c userPreferences;
		try{
			userPreferences = [SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c 
								FROM  SFA2_User_Preferences_gne__c 
								WHERE Last_View_Used_gne__r.Page_Name_gne__c = :nameOfThePage 
									AND User_gne__c = :Userinfo.getUserId() LIMIT 1];
		} catch(Exception e) {
			userPreferences = new SFA2_User_Preferences_gne__c(User_gne__c = UserInfo.getUserId());
		}
		return userPreferences;
	}

	private String getLastSeenOrFirstAvailableViewId(List<SFA2_View_Config_gne__c> visibleViews, SFA2_User_Preferences_gne__c userPreferences) {
		String selectedViewId;
		if (visibleViews != null && visibleViews.size() > 0 && userPreferences != null ) {
			if (userPreferences.Last_View_Used_gne__c == null) {
				userPreferences.Last_View_Used_gne__c = visibleViews.get(0).Id;
			}
			selectedViewId = userPreferences.Last_View_Used_gne__c; 
		}
		return selectedViewId;
	}

	public String getQueryString(SFA2_View_Config_gne__c viewConfig) {
		String objectType = viewConfig.Object_Type_gne__c;
				
		List<String> visibleColumns = getViewColumnsBySelectedView(viewConfig);
		Set<String> uniqueViewColumns = new Set<String>();
		uniqueViewColumns.addAll(visibleColumns);
		List<String> filterStatements = getFiltersBySelectedView(viewConfig);
		String queryString = 'SELECT ';
		
		for(String viewField : visibleColumns) {
			queryString += viewField + ', ';
		}

		for (GNE_SFA2_Base_Ctrl.Field selectedField : getFieldList(viewConfig)) {
			if (selectedField.describe.type == 'reference') {
				queryString += (selectedField.describe.relationshipName + '.Name, ');
			}
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

		if (filterStatements.size() > 0 || viewConfig.Records_Visibility__c=='My Records') {
			queryString += ' WHERE ';
			if (objectType.equals('Speaker_Bureau_Membership_gne__c') && viewConfig.Records_Visibility__c=='My Records') {
				queryString += ' Speaker_Bureau_ID_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
			}
			if (objectType.equals('ART_Issue_gne__c') && viewConfig.Records_Visibility__c=='My Records') {
				queryString += ' ART_Site_Local_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
			}
			if ((!objectType.equals('Speaker_Bureau_Membership_gne__c') && !objectType.equals('ART_Issue_gne__c')) && viewConfig.Records_Visibility__c=='My Records') {
				queryString += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
			}
			for(String filterColumn : filterStatements) {
				queryString += getFilterStatement(filterColumn);
			}
			queryString = queryString.removeEnd(' AND ');
		}
		
		if ((objectType.equals('Task') || objectType.equals('Event')) && (viewConfig.Records_Visibility__c=='All Records') ) {
			 if (!queryString.contains('WHERE')) {
				queryString += ' WHERE OwnerId =\'' + UserInfo.getUserId()+'\' ';
			}else{
				queryString += 'AND OwnerId = \''+UserInfo.getUserId()+'\' ';
			}
		}
		
		return queryString;  
	}

	public String getCountQueryString(SFA2_View_Config_gne__c viewConfig, Integer maxRecordCount) {
		String objectType = viewConfig.Object_Type_gne__c;
		List<String> visibleColumns = getViewColumnsByselectedView(viewConfig);
		List<String> filterStatements = getFiltersBySelectedView(viewConfig);
		String countQueryString = 'SELECT COUNT() FROM ' + objectType;
		if (filterStatements.size() > 0 || viewConfig.Records_Visibility__c=='My Records') {
			countQueryString += ' WHERE ';
			if (objectType.equals('Speaker_Bureau_Membership_gne__c') && viewConfig.Records_Visibility__c=='My Records') {
				countQueryString += ' Speaker_Bureau_ID_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
			}
			if (objectType.equals('ART_Issue_gne__c') && viewConfig.Records_Visibility__c=='My Records') {
				countQueryString += ' ART_Site_Local_gne__r.ownerid = \''+UserInfo.getUserId()+'\' AND ';
			}
			if ((!objectType.equals('Speaker_Bureau_Membership_gne__c') && !objectType.equals('ART_Issue_gne__c')) && viewConfig.Records_Visibility__c=='My Records') {
				countQueryString += ' OwnerId = \''+UserInfo.getUserId()+'\' AND ';
			}
			for(String filterColumn : filterStatements) {
				countQueryString += getFilterStatement(filterColumn);
			}
			countQueryString = countQueryString.removeEnd(' AND ');
		}
		
		 if ( (objectType.equals('Task') || objectType.equals('Event')) && (viewConfig.Records_Visibility__c=='All Records') ) {
			if (!countQueryString.contains('WHERE')) {
				countQueryString += ' WHERE OwnerId =\'' + UserInfo.getUserId()+'\' ';
			}else{
				countQueryString += 'AND OwnerId = \''+UserInfo.getUserId()+'\' ';
			}
		}
		countQueryString += ' LIMIT ' + String.valueOf(maxRecordCount);
		return countQueryString;  
	}
	
	public List<GNE_SFA2_Base_Ctrl.Field> getFieldList(SFA2_View_Config_gne__c viewConfig) {
		String sObjectType = viewConfig.Object_Type_gne__c;
		Map<String,Schema.SObjectField> sObjectFieldMap = prepareObjectTypeFieldsMap(sObjectType);
		List<String> columns = getViewColumnsBySelectedView(viewConfig);

		List<GNE_SFA2_Base_Ctrl.Field> result = new List<GNE_SFA2_Base_Ctrl.Field>();

		for (String field : columns) {
			Schema.DescribeFieldResult fldDescribe = sObjectFieldMap.get(field).getDescribe();
			GNE_SFA2_Base_Ctrl.Field fieldToAdd = new GNE_SFA2_Base_Ctrl.Field('', true, false, fldDescribe, sObjectType);
			if (fieldToAdd.name == 'CreatedById') {
				fieldToAdd.label = 'Created By';
			}
			else if (fieldToAdd.name == 'LastModifiedById') {
				fieldToAdd.label = 'Last Modified By';
			}
			result.add(fieldToAdd);
		}
		return result;
	}

	private Map<String,Schema.SObjectField> prepareObjectTypeFieldsMap(String objectType) {
		Map<String,Schema.SObjectType> globalDescribeMap = GNE_SFA2_Util.getGlobalDescribe();
		Schema.SObjectType sObjectType = globalDescribeMap.get(objectType);  
		Schema.DescribeSObjectResult result = sObjectType.getDescribe();  
		Map<String,Schema.SObjectField> sObjectFieldMap = result.fields.getMap();
		
		return sObjectFieldMap;
	}

	private List<String> getViewColumnsBySelectedView(SFA2_View_Config_gne__c selectedView) {
		List<String> columns = new List<String>();
		if (selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != '') {
		   columns = selectedView.View_Fields_gne__c.split(';', 0);
		}
		return columns;
	}
	
	private List<String> getFiltersBySelectedView(SFA2_View_Config_gne__c selectedView) {
		List<String> filters = new List<String>();
		if (selectedView.Filter_Statement_gne__c != null && selectedView.Filter_Statement_gne__c != '') {
			List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>conditionItems = (List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>)JSON.deserializeStrict(selectedView.Filter_Statement_gne__c,  List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>.class);
			for(Integer i=0; i<conditionItems.size(); i++) {
				GNE_SFA2_List_View_Setup_Ext.ConditionItem conditionItem = conditionItems.get(i);
				String filterExpr = conditionItem.field;
				
				if (conditionItem.valueType == 'PICKLIST') {
					if (conditionItem.operator=='inc') {
						filterExpr += ' IN '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
					}
					else if (conditionItem.operator=='ecl') {
						filterExpr += ' NOT IN '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
					}
				}
				else if (conditionItem.valueType == 'MULTIPICKLIST') {
					if (conditionItem.operator == 'inc') {
						filterExpr += ' INCLUDES '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
					}
					else if (conditionItem.operator=='ecl') {
						filterExpr += ' EXCLUDES '+GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
					}
				}
				else if (conditionItem.valueType == 'BOOLEAN') {
					if (conditionItem.operator == 'eq') {
						filterExpr += ' = '+conditionItem.value;
					}
					else if (conditionItem.operator == 'ne') {
						filterExpr += ' != '+conditionItem.value;
					}
				   
				}
				else if (conditionItem.valueType=='STRING' || conditionItem.valueType=='EMAIL' || conditionItem.valueType=='URL' 
						|| conditionItem.valueType=='PHONE' || conditionItem.valueType=='REFERENCE' || conditionItem.valueType=='COMBOBOX') {
					if (conditionItem.valueType=='REFERENCE' && conditionItem.value=='CURRENT_USER') {
						conditionItem.value = UserInfo.getUserId();
					}
									
					if (conditionItem.operator=='eq') {
						filterExpr += ' = \''+ String.escapeSingleQuotes(conditionItem.value) +'\'';
					}
					else if (conditionItem.operator=='ne') {
						filterExpr += ' != \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
					}
					else if (conditionItem.operator=='lt') {
						filterExpr += ' < \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
					}
					else if (conditionItem.operator=='lte') {
						filterExpr += ' <= \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
					}
					else if (conditionItem.operator=='gt') {
						filterExpr += ' > \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
					}
					else if (conditionItem.operator=='gte') {
						filterExpr += ' >= \''+String.escapeSingleQuotes(conditionItem.value)+'\'';
					}
					else if (conditionItem.operator=='c') {
						filterExpr += ' LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\'';
					}
					else if (conditionItem.operator=='nc') {
						filterExpr =  '(NOT ' + +conditionItem.field + ' LIKE \'%'+String.escapeSingleQuotes(conditionItem.value)+'%\')';
					}
					else if (conditionItem.operator=='sw') {
						filterExpr += ' LIKE \''+String.escapeSingleQuotes(conditionItem.value)+'%\'';
					}
				} 
				else {
					String value = '';
					boolean do_not_split = false;
					Boolean needQuotes = true;

					if (conditionItem.valueType=='DOUBLE'||conditionItem.valueType=='CURRENCY'||conditionItem.valueType=='PERCENT') {
						value = Double.valueOf(conditionItem.value).format();
						needQuotes = false;
					} 
					else if (conditionItem.valueType=='INTEGER') {
						value = Integer.valueOf(conditionItem.value).format();
						needQuotes = false;
					} 
					else if (conditionItem.valueType=='DATE') {
						
						if (conditionItem.value.equals('TODAY')) {
							String currentDate_T=String.valueOf(System.today());
							System.debug('**date today value'+currentDate_T);
							String[] today_Parts = currentDate_T.split('-');
							conditionItem.value=today_Parts[1]+'/'+today_Parts[2]+'/'+today_Parts[0];                                   
						}
						
						
						String[] dateParts = conditionItem.value.split('/');
						DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
						value = dtime.format('yyyy-MM-dd');
						needQuotes = false;
					} 
					else if (conditionItem.valueType=='DATETIME') {
						
						if (conditionItem.value.equals('TODAY')) {
							String currentDate_T=String.valueOf(System.today());
							String[] today_Parts = currentDate_T.split('-');
							conditionItem.value=today_Parts[1]+'/'+today_Parts[2]+'/'+today_Parts[0];                                   
						}
						else if (conditionItem.value.contains('_N_DAYS')) {
						  //do not split 
						  do_not_split = true;
						}
						String[] dateParts = conditionItem.value.split('/');
						//if field is datetime only date part is compared    
													 
						filterExpr = String.format('DAY_ONLY(CONVERTTIMEZONE({0}))', new String[]{filterExpr});
						if (!do_not_split) {
							DateTime dtime = DateTime.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]), 0, 0, 0);
							value = dtime.format('yyyy-MM-dd');
						}
						else {
						  value = conditionItem.value;
						}
						needQuotes = false;
					} 
					else if (conditionItem.valueType=='ID') {
						Id tmpId = conditionItem.value;
						value = tmpId;
					} 
					else {
						value = conditionItem.value;
					}

					if (conditionItem.operator=='eq') {
						filterExpr +=  ' = ' + (needQuotes ? ('\''+value+'\'') : value);
					}
					else if (conditionItem.operator=='ne') {
						filterExpr +=  ' != ' + (needQuotes ? ('\''+value+'\'') : value);
					}
					else if (conditionItem.operator=='lt') {
						filterExpr +=  ' < ' + (needQuotes ? ('\''+value+'\'') : value);
					}
					else if (conditionItem.operator=='lte') {
						filterExpr +=  ' <= ' + (needQuotes ? ('\''+value+'\'') : value);
					}
					else if (conditionItem.operator=='gt') {
						filterExpr +=  ' > ' + (needQuotes ? ('\''+value+'\'') : value);
					}
					else if (conditionItem.operator=='gte') {
						filterExpr +=  ' >= ' + (needQuotes ? ('\''+value+'\'') : value);
					}
				}
				filters.add(filterExpr);                    
			}
		}
		
		return filters;
	}

	private String getFilterStatement(String filterColumn) {
		String query = filterColumn + ' AND ';
		return query;
	}


	public Boolean checkIfViewEditable(SFA2_View_Config_gne__c view) {
		return (view != null && view.OwnerId == Userinfo.getUserId());
	}
}