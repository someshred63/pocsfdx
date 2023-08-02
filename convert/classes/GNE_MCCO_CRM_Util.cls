/*
 * GNE_MCCO_CRM_Util
 */
public with sharing class GNE_MCCO_CRM_Util {

    private static Set<String> possibleTerritorySalesforceCodes = null;
    private static Map<Id, Set<String>> currentUserSalesforceCodes = null;
    public static final Integer PAGE_SIZE = 25;
    public static final Integer RECORDS_LIMIT = 40000;

    public static List<SFA2_Configuration_Object_Detail_gne__c> getButtonsList(String objName) {
        try {
            SFA2_Configuration_Object_gne__c pageConfiguration = GNE_SFA2_Util.getListPageConfiguration(objName);
            Id pageConfigurationId = pageConfiguration.Id;
            return [SELECT Attributes_gne__c, Label_gne__c FROM SFA2_Configuration_Object_Detail_gne__c WHERE Configuration_Object_ref_gne__c = :pageConfigurationId AND Is_Active_gne__c = true ORDER BY Order_gne__c ];
        } catch (Exception ex) {
            return new List<SFA2_Configuration_Object_Detail_gne__c>();
        }
    }

    public static GNE_SFA2_My_Accounts_Setttings__c getUserSettings() {
        try {
            return [ SELECT PageSize_gne__c, Roles_With_Territory_Hierarchy_gne__c FROM GNE_SFA2_My_Accounts_Setttings__c WHERE Application_Type__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c AND Brand_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c AND Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c ];
        } catch (Exception e) {
            return new GNE_SFA2_My_Accounts_Setttings__c( PageSize_gne__c = PAGE_SIZE, Privileged_Profiles_gne__c = '' );
        }
    }

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

    public static List<SFA2_View_Config_gne__c> getViews(String objName, String applicationName, String brand, String role, String subTeamCode) {
    	GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_Util.getUserApplicationContext();
        List<SFA2_View_Config_gne__c> result = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Records_Visibility__c, Object_Type_gne__c, Fields_Labels_gne__c FROM SFA2_View_Config_gne__c WHERE ((Visibility_gne__c = 'private' AND OwnerId = :UserInfo.getUserId()) OR Visibility_gne__c = 'public') AND Page_Name_gne__c = :objName ORDER BY View_Name_gne__c];
        List<SFA2_View_Config_gne__c> restricetedViews = [SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c, Account_Record_Types_gne__c, Product_gne__c, Application_Type_gne__c, Brand_gne__c, Role_gne__c, Records_Visibility__c, Object_Type_gne__c, Fields_Labels_gne__c FROM SFA2_View_Config_gne__c WHERE Visibility_gne__c = 'restricted' AND Page_Name_gne__c = :objName AND Team_gne__c =: subTeamCode ORDER BY View_Name_gne__c ];

        for (SFA2_View_Config_gne__c restrictedView : restricetedViews) {
            if (applicationName == restrictedView.Application_Type_gne__c && brand == restrictedView.Brand_gne__c && (role == restrictedView.Role_gne__c || restrictedView.Role_gne__c == null)) {
                result.add(restrictedView);
            }
        }

        GNE_SFA2_Util.sortList(result, 'View_Name_gne__c', true);
        return result;
    }

    public static List<SFA2_View_Config_gne__c> getViews(String objName) {
    	GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_Util.getUserApplicationContext();
        return getViews(objName, userAppContext.App_Name_gne__c, userAppContext.Brand_gne__c, userAppContext.Role_gne__c, '');
    }

    public static List<SFA2_View_Config_gne__c> getViews(String objName, String subTeamCode) {
        GNE_SFA2_User_App_Context_gne__c userAppContext = GNE_SFA2_Util.getUserApplicationContext();
        return getViews(objName, userAppContext.App_Name_gne__c, userAppContext.Brand_gne__c, userAppContext.Role_gne__c, subTeamCode);
    }

    public static SFA2_View_Config_gne__c getView(String viewId) {
        return [
            SELECT Id, OwnerId, View_Name_gne__c, View_Fields_gne__c, Sorting_Field_gne__c, Sorting_Order_gne__c, Filter_Statement_gne__c, Person_Record_Types_gne__c,
                Account_Record_Types_gne__c, Product_gne__c, Records_Visibility__c, Fields_Labels_gne__c
            FROM SFA2_View_Config_gne__c
            WHERE Id = :viewId LIMIT 1][0];
    }

    public static String getFilterStatement(String filterColumn) {
        String query = filterColumn + ' AND ';
        return query;
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

    public static Map<Id, DateTime> getRecentylViewedMap(String objectName) {
        Map<Id, DateTime> result = new Map<Id, DateTime>();
        for (RecentlyViewed rv : [SELECT Id, LastViewedDate FROM RecentlyViewed WHERE Type = :objectName ORDER BY LastViewedDate DESC LIMIT 100]) {
            result.put(rv.Id, rv.LastViewedDate);
        }
        return result;
    }

    public static String getDocumentBase64(String name) {
    	try{
        	return EncodingUtil.base64Encode([SELECT Body FROM document WHERE DeveloperName = :name LIMIT 1].Body);
    	}catch(Exception e){
    		return '';
    	}
    }

    @RemoteAction
    @ReadOnly
    public static Set<Id> getAccountsIdsFromTSFsBasedOnTerritories() {
        Set<Id> result = new Set<Id>();
        List<String> territories = new List<String>();
        for(Territory2 t : GNE_SFA2_Util.getUserTerritories(UserInfo.getUserId())) {
            territories.add(t.Name);
        }

        Set<String> rt = new Set<String>();
        for(TSF_vod__c tsf : GNE_MCCO_CRM_DAO.getAccountsIdsFromTSFs(territories)) {
            result.add(tsf.Account_vod__c);
            rt.add(tsf.Account_vod__r.RecordType.Name);
        }
        return result;
    }

    public static Set<String> getPossibleTerritorySalesforceCodes(){
        if(possibleTerritorySalesforceCodes == null){
	    	List<AggregateResult> codes;
	    	if(GNE_SFA2_Util.isBamCrmUser()){
	    		codes = [SELECT Salesforce_Code_gne__c FROM Territory2 WHERE external_id_gne__c LIKE 'GNE-US;SFA;0B5-BAM%' GROUP BY Salesforce_Code_gne__c ];
	    	}else if(GNE_SFA2_Util.isMccoCrmUser()){
	    		codes = [SELECT Salesforce_Code_gne__c FROM Territory2 WHERE External_id_gne__c Like 'GNE-US;MCCO%' AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%') AND (NOT External_id_gne__c Like 'GNE-US;MCCO;FRM%') GROUP BY Salesforce_Code_gne__c ];
	    	}else if(GNE_SFA2_Util.isFrmUser()){
	    		codes = [SELECT Salesforce_Code_gne__c FROM Territory2 WHERE External_id_gne__c Like 'GNE-US;MCCO;FRM%' AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%') GROUP BY Salesforce_Code_gne__c ];
            } else if(GNE_SFA2_Util.isSfaCCUser()) {
                codes = [SELECT Salesforce_Code_gne__c FROM Territory2 WHERE External_id_gne__c Like 'GNE-US;CLINCAL-COORDINATOR%' AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%') GROUP BY Salesforce_Code_gne__c ];
	    	}
            if(codes == null) codes = new List<AggregateResult>();

            possibleTerritorySalesforceCodes = new Set<String>();
            for(AggregateResult ar : codes){
                String sfdcCode = String.valueOf(ar.get('Salesforce_Code_gne__c'));
                if(String.isNotBlank(sfdcCode)){
                    possibleTerritorySalesforceCodes.add(sfdcCode);
                }
            }
        }
        return possibleTerritorySalesforceCodes;
    }

    public static Set<String> getCurrentUserSalesforceCodes(){
        if(currentUserSalesforceCodes == null){
            currentUserSalesforceCodes = new Map<Id, Set<String>>();
        }
        if (!currentUserSalesforceCodes.containsKey(UserInfo.getUserId())){
            Set<String> userCodes = new Set<String>();
            for(Territory2 ut : [SELECT Salesforce_Code_gne__c FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :UserInfo.getUserId()) AND Salesforce_Code_gne__c != null]) {
                userCodes.add(ut.Salesforce_Code_gne__c);
            }
            if(userCodes.isEmpty()){
                userCodes.addAll(getPossibleTerritorySalesforceCodes());
            }
            currentUserSalesforceCodes.put(UserInfo.getUserId(), userCodes);
        }

        return currentUserSalesforceCodes.get(UserInfo.getUserId());
    }

    public static List<GNE_MCCO_CRM_Link__c> getSubsetOfLinks(List<GNE_MCCO_CRM_Link__c> mccoLinks){
        Set<String> userCodes = getCurrentUserSalesforceCodes();
        List<GNE_MCCO_CRM_Link__c> linksToReturn = getSubsetOfLinks(mccoLinks, userCodes);
        if(linksToReturn.isEmpty()){
        	linksToReturn = getSubsetOfLinks(mccoLinks, getPossibleTerritorySalesforceCodes());
        }

        return linksToReturn;
    }

    private static List<GNE_MCCO_CRM_Link__c> getSubsetOfLinks(List<GNE_MCCO_CRM_Link__c> mccoLinks, Set<String> userCodes){
        List<GNE_MCCO_CRM_Link__c> linksToReturn = new List<GNE_MCCO_CRM_Link__c>();
        for(GNE_MCCO_CRM_Link__c link :mccoLinks){
            if(String.isNotBlank(link.Available_for_gne__c)){
                for(String code :link.Available_for_gne__c.split(',')){
                    if(userCodes.contains(code)){
                        linksToReturn.add(link);
                        break;
                    }
                }
            }
        }
        return linksToReturn;
    }

}