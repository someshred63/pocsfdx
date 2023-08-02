public with sharing class GNE_SFA2_List_View_Util {
	
	public static SFA2_User_Preferences_gne__c getUserPreferences(String pageName) {
        try {
            return [ SELECT Last_View_Used_gne__c, Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = :pageName AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
        } catch (Exception e) {
            return new SFA2_User_Preferences_gne__c( User_gne__c = UserInfo.getUserId() );
        }
    }
    
    public static Boolean updateViewPreference(String viewId, String pageName) {
        List<SFA2_User_Preferences_gne__c> userPreferences = [ SELECT Last_View_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = :pageName AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
        SFA2_User_Preferences_gne__c userPreference;
        if(userPreferences.isEmpty()){
          userPreference = new SFA2_User_Preferences_gne__c( User_gne__c = UserInfo.getUserId(), Last_View_Used_gne__c = viewId );
        } else {
        	userPreference = userPreferences.get(0);
            userPreference.Last_View_Used_gne__c = viewId;
        }
        try {
            upsert userPreference;
            return true;
        } catch(DMLException e) {
            return false;
        }
    }
    
    public static List<SFA2_View_Config_gne__c> getViews(String objName, String pageName, GNE_SFA2_User_App_Context_gne__c userContext) {
    	return getViews(objName, pageName, userContext.App_Name_gne__c, userContext.Brand_gne__c, userContext.Role_gne__c);
    }

    public static List<SFA2_View_Config_gne__c> getViews(String objName, String pageName, String applicationName, String brand, String role) {
        List<SFA2_View_Config_gne__c> result = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Records_Visibility__c, Object_Type_gne__c, Fields_Labels_gne__c FROM SFA2_View_Config_gne__c WHERE ((Visibility_gne__c = 'private' AND OwnerId = :UserInfo.getUserId()) OR Visibility_gne__c = 'public') AND Page_Name_gne__c = :pageName AND Object_Type_gne__c = :objName ORDER BY View_Name_gne__c];
        List<SFA2_View_Config_gne__c> restricetedViews = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Application_Type_gne__c, Brand_gne__c, Role_gne__c, Records_Visibility__c, Object_Type_gne__c, Fields_Labels_gne__c FROM SFA2_View_Config_gne__c WHERE Visibility_gne__c = 'restricted' AND Page_Name_gne__c = :pageName AND Object_Type_gne__c = :objName ORDER BY View_Name_gne__c ];

        for (SFA2_View_Config_gne__c restrictedView : restricetedViews) {
        	if (applicationName == restrictedView.Application_Type_gne__c && (brand == restrictedView.Brand_gne__c || (String.isEmpty(restrictedView.Brand_gne__c) &&  String.isEmpty(brand))) && (role == restrictedView.Role_gne__c || (String.isEmpty(restrictedView.Role_gne__c) && String.isEmpty(role)))) {
                result.add(restrictedView);
            }
        }

        GNE_SFA2_Util.sortList(result, 'View_Name_gne__c', true);
        return result;
    }
    
    public static SFA2_View_Config_gne__c getLastSeenOrFirstAvailableView(List<SFA2_View_Config_gne__c> visibleViews, SFA2_User_Preferences_gne__c userPreferences) {
		SFA2_View_Config_gne__c result;
		if(visibleViews.isEmpty()){
			result = null;
		} else{
			result = visibleViews.get(0);
			if(userPreferences != null && userPreferences.Last_View_Used_gne__c != null){
				for(SFA2_View_Config_gne__c view : visibleViews){
					if(view.Id == userPreferences.Last_View_Used_gne__c){
						result = view;
						break;
					}
				}
			}
		}
		return result;
	}
 
    public static List<SelectOption> prepareSelectOptions(List<SFA2_View_Config_gne__c> views){
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
    /* Query records base on view */
    public static List<Sobject> queryRecords(SFA2_View_Config_gne__c view){
    	return Database.query(buildQueryString(view));
    }
    
   	public static List<String> getFiltersBySelectedView(SFA2_View_Config_gne__c selectedView) {
    	return getFiltersBySelectedView(selectedView, null);
    }

    public static List<String> getFiltersBySelectedView(SFA2_View_Config_gne__c selectedView, GNE_SFA2_List_View_Base_Controller baseListController) {
        List<String> filters = new List<String>();
        if (selectedView.Filter_Statement_gne__c != null && selectedView.Filter_Statement_gne__c != '') {
            List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>conditionItems = (List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>)JSON.deserializeStrict(selectedView.Filter_Statement_gne__c,  List<GNE_SFA2_List_View_Setup_Ext.ConditionItem>.class);
            for (Integer i = 0; i < conditionItems.size(); i++) {
                GNE_SFA2_List_View_Setup_Ext.ConditionItem conditionItem = conditionItems.get(i);
                String filterExpr = conditionItem.field;

                if (conditionItem.valueType == 'PICKLIST') {
                    if (conditionItem.operator == 'inc') {
                        filterExpr += ' IN ' + GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    } else if (conditionItem.operator == 'ecl') {
                        filterExpr += ' NOT IN ' + GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    }
                } else if (conditionItem.valueType == 'MULTIPICKLIST') {
                    if (conditionItem.operator == 'inc') {
                        filterExpr += ' INCLUDES ' + GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
                    } else if (conditionItem.operator == 'ecl') {
                        filterExpr += ' EXCLUDES ' + GNE_SFA2_Util.createInListForQueryNotEscaping(conditionItem.multiValue);
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
                        filterExpr =  '(NOT ' + +conditionItem.field + ' LIKE \'%' + String.escapeSingleQuotes(conditionItem.value) + '%\')';
                    } else if (conditionItem.operator == 'sw') {
                        filterExpr += ' LIKE \'' + String.escapeSingleQuotes(conditionItem.value) + '%\'';
                    }
                } else if(baseListController != null && conditionItem.valueType=='CUSTOM_FILTER') {
                	filterExpr = baseListController.getCustomFilterExpression(conditionItem);
                	if(String.isBlank(filterExpr)) {
                		continue;
                	}
                } else {
                    String value = '';
                    boolean do_not_split = false;
                    Boolean needQuotes = true;
                    try {
                        if (conditionItem.valueType == 'DOUBLE' || conditionItem.valueType == 'CURRENCY' || conditionItem.valueType == 'PERCENT') {
                            value = Double.valueOf(conditionItem.value).format();
                            needQuotes = false;
                        } else if (conditionItem.valueType == 'INTEGER') {
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
                            if (do_not_split) {
                                filterExpr = String.format('{0}', new String[] {filterExpr});
                            } else {
                                filterExpr = String.format('DAY_ONLY(CONVERTTIMEZONE({0}))', new String[] {filterExpr});
                            }
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
                        filterExpr +=  ' = ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'ne') {
                        filterExpr +=  ' != ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'lt') {
                        filterExpr +=  ' < ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'lte') {
                        filterExpr +=  ' <= ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'gt') {
                        filterExpr +=  ' > ' + (needQuotes ? ('\'' + value + '\'') : value);
                    } else if (conditionItem.operator == 'gte') {
                        filterExpr +=  ' >= ' + (needQuotes ? ('\'' + value + '\'') : value);
                    }
                }
                filters.add(filterExpr);
            }
        }

        return filters;
    }
    
    // get view columns basing on the selected view
    private static List<String> getViewColumnsBySelectedView(SFA2_View_Config_gne__c selectedView){
        List<String> columns = new List<String>();
        if(selectedView.View_Fields_gne__c != null && selectedView.View_Fields_gne__c != ''){
           columns = selectedView.View_Fields_gne__c.split(';', 0);
        }
        return columns;
    }
    	
    public static String buildQueryString(SFA2_View_Config_gne__c view) {	
        List<String> visibleColumns = getViewColumnsBySelectedView(view);
        Set<String> uniqueViewColumns = new Set<String>();
        uniqueViewColumns.addAll(visibleColumns);
        List<String> filterStatements = getFiltersBySelectedView(view);
        String queryString = 'SELECT ';
        
        for(String viewField : visibleColumns) {
            queryString += viewField + ', ';
        }        
        
        if(queryString == 'SELECT '){
            queryString += 'Id, ';
        }
        queryString = queryString.removeEnd(', ');
        
        queryString += ' FROM ' + view.Object_Type_gne__c; 

        if(filterStatements.size() > 0) {
            queryString += ' WHERE ';
           
            for(String filterColumn : filterStatements){
                queryString += filterColumn + ' AND ';
            }
            queryString = queryString.removeEnd(' AND ');
        }
        
        if(filterStatements.size() > 0 && view.Records_Visibility__c=='My Records') {
        	queryString += 'AND OwnerId = \''+UserInfo.getUserId()+'\' ';
        }else if(filterStatements.size() == 0 && view.Records_Visibility__c == 'My Records') {
        	queryString += ' OwnerId = \''+UserInfo.getUserId()+'\' ';
        }
        
        System.debug('List view query: '+queryString);
        return queryString;  
    }
    
    
    public class History {
        public String theDate {get; set;}
        public String userName {get; set;}
        public String userId {get; set;}
        public String description {get; set;}
    }
      
    public static List<History> getHistories(List<sObject>historyRecords, String sobjectName) {
	    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    Schema.SObjectType leadSchema = schemaMap.get(sobjectName);
	    Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        List<History> result = new List<History>();
        for(sObject hist : historyRecords){           
            History ch = new History();       
            ch.theDate = String.valueOf(hist.get('CreatedDate'));
            ch.userName = String.valueOf(hist.getSObject('CreatedBy').get('Name'));
            ch.userId = String.valueOf(hist.getSObject('CreatedBy').get('Id'));

            if (String.valueOf(hist.get('Field')) == 'created') {            
                ch.description = 'Created.';       
            } else if (hist.get('OldValue') != null && hist.get('NewValue') == null){        
                try {
                    ch.description = 'Deleted ' + Date.valueOf(hist.get('OldValue')).format() + ' in <b>' + String.valueOf(hist.get('Field')) + '</b>.';
               } catch (Exception e){
                   String fValue = String.valueOf(hist.get('OldValue'));
                   if(!(fValue instanceof Id)){
                       ch.description = 'Deleted ' + fValue + ' in <b>' + String.valueOf(hist.get('Field')) + '</b>.';
                   } else {
                       continue;
                   }
               }       
           } else {
               String fromText = '';
               if (hist.get('OldValue') != null) {
                   try {
                       fromText = ' from ' + Date.valueOf(hist.get('OldValue')).format();
                   } catch (Exception e) {
                       String fValue = String.valueOf(hist.get('OldValue'));
                       if(!(fValue instanceof Id)){
                           fromText = ' from ' + fValue;
                       } else {
                           continue;
                       }
                   }
              	}
        
              	String toText = '';
              	try {
                 	toText = Date.valueOf(hist.get('NewValue')).format();
              	} catch (Exception e) {
                    String fValue = String.valueOf(hist.get('NewValue'));
                    if(!(fValue instanceof Id)){
                 	    toText = fValue;
                    } else {
                        continue;
                    }    
              	}              
            	ch.description = 'Changed <b>' + String.valueOf(fieldMap.get(String.valueOf(hist.get('Field'))).getDescribe().getLabel()) + '</b>' + fromText + ' to <b>' + toText + '</b>.';        
			}            
      		result.add(ch);
        }
        return result;
    }
  
  
}