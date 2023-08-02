public without sharing class GNE_SFA2_Application_Util {

    public static PageReference switchUserToApplication (String appName, String targetURL) {
        return switchToApplication (appName, UserInfo.getUserId(), targetURL);
    }
    
    public static List<SFA2_User_Sales_Roster_gne__c> getUserSalesRosters(String userId){
        return getUserSalesRosters(userId, null, false);
    }
    
    public static List<SFA2_User_Sales_Roster_gne__c> getUserSalesRosters(String userId, String applicationName){
        return getUserSalesRosters(userId, applicationName, false);
    }
    
    public static List<SFA2_User_Sales_Roster_gne__c> getUserSalesRosters(String userId, Boolean sfa2Mode){
        return getUserSalesRosters(userId, null, sfa2Mode);
    }
    
    public static List<SFA2_User_Sales_Roster_gne__c> getUserSalesRosters(String userId, String applicationName, Boolean sfa2Mode){
        String icCalcRelName = SFA2_User_Sales_Roster_gne__c.Sales_Roster_gne__c.getDescribe().getRelationshipName();
        userId = String.isNotBlank(userId) ? userId : UserInfo.getUserId();
        Set<String> fieldsToSelect = new Set<String>{
            icCalcRelName + '.' + String.valueOf(IC_Calc_Sales_Roster_gne__c.Type_gne__c),
            icCalcRelName + '.' + String.valueOf(IC_Calc_Sales_Roster_gne__c.Brand_Name_gne__c),
            icCalcRelName + '.' + String.valueOf(IC_Calc_Sales_Roster_gne__c.Is_SFA2_Available_gne__c),
            icCalcRelName + '.' + String.valueOf(IC_Calc_Sales_Roster_gne__c.Runs_in_SFA2_Mode_gne__c),             
            String.valueOf(SFA2_User_Sales_Roster_gne__c.Role_gne__c)
        };
        
        List<String> whereConditions = new List<String>{
           String.valueOf(SFA2_User_Sales_Roster_gne__c.Is_Active_gne__c) + ' = true',
           String.valueOf(SFA2_User_Sales_Roster_gne__c.User_gne__c) + ' = :userId' 
        };
        
        if (String.isNotBlank(applicationName)){
            whereConditions.add(icCalcRelName + '.' + String.valueOf(IC_Calc_Sales_Roster_gne__c.Type_gne__c) + ' = :applicationName');
        }
        system.debug(sfa2mode);
        if(sfa2Mode==true) {
            whereConditions.add(icCalcRelName + '.' + String.valueOf(IC_Calc_Sales_Roster_gne__c.Runs_in_SFA2_Mode_gne__c) + ' = true');
        }
        
        List<String> orderByFields = new String[]{
            icCalcRelName + '.' + String.valueOf(IC_Calc_Sales_Roster_gne__c.Type_gne__c),
            icCalcRelName + '.' + String.valueOf(IC_Calc_Sales_Roster_gne__c.Brand_Name_gne__c),
            String.valueOf(SFA2_User_Sales_Roster_gne__c.Role_gne__c)
        };
        
        String query = String.format('SELECT {0} FROM SFA2_User_Sales_Roster_gne__c WHERE {1} ORDER BY {2}',
            new String[]{
                String.join(new List<String>(fieldsToSelect), ','),
                String.join(whereConditions, ' AND '),
                String.join(orderByFields, ',')
            }
        );
        system.debug(query);
        
        return Database.query(query);        
    }
    
    private static void resetUserApplicationContext(GNE_SFA2_User_App_Context_gne__c userApplicationContext) {
        if(userApplicationContext != null) {
            userApplicationContext.App_Name_gne__c = null;
            userApplicationContext.Role_gne__c = null;
            userApplicationContext.Brand_gne__c = null;
            userApplicationContext.SFA2_Mode_gne__c = false;
            
            update userApplicationContext;
        }
    }

    public static PageReference switchToApplication (String appName, String userId, String targetURL) {
        List<SFA2_User_Sales_Roster_gne__c> rostersForApplication = getUserSalesRosters(userId, appName);
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();        
        List<IC_Calc_Sales_Roster_gne__c> icCalcSalesRosterList = [SELECT Id, App_URL_gne__c, Type_gne__c, Brand_Name_gne__c, User_Role_gne__c, Runs_in_SFA2_Mode_gne__c FROM IC_Calc_Sales_Roster_gne__c WHERE Type_gne__c = :appName AND Brand_Name_gne__c IN (:userApplicationContext.Brand_gne__c, null)];
        IC_Calc_Sales_Roster_gne__c icCalcSalesRoster = null;
        if (icCalcSalesRosterList.size() == 1){
            icCalcSalesRoster = icCalcSalesRosterList[0];
        } else if (icCalcSalesRosterList.size() > 1){
            Map<String, IC_Calc_Sales_Roster_gne__c> userContextToIcCalcMap = new Map<String, IC_Calc_Sales_Roster_gne__c>();
            String keyStr;
            for (IC_Calc_Sales_Roster_gne__c icCalc : icCalcSalesRosterList){
                keyStr = getUserContextString(appName, icCalc.Brand_Name_gne__c, icCalc.User_Role_gne__c);
                userContextToIcCalcMap.put(keyStr, icCalc);
            }            
            keyStr = getUserContextString(appName, userApplicationContext.Brand_gne__c, userApplicationContext.Role_gne__c);
            if (userContextToIcCalcMap.containsKey(keyStr)){
                icCalcSalesRoster = userContextToIcCalcMap.get(keyStr);
            } else {
                keyStr = getUserContextString(appName, userApplicationContext.Brand_gne__c, null);
                if (userContextToIcCalcMap.containsKey(keyStr)){
                   icCalcSalesRoster = userContextToIcCalcMap.get(keyStr);
                } else {
                    keyStr = getUserContextString(appName, null, null);
                    if (userContextToIcCalcMap.containsKey(keyStr)){
                        icCalcSalesRoster = userContextToIcCalcMap.get(keyStr);
                    }
                }
            }            
        } 
        if (icCalcSalesRoster == null){
            // coud not find an IC Calc Sales Rosters for given application and brand - configuration is invalid
            throw new GNE_SFA2_Exception();
        }
        
        if(rostersForApplication.size() == 0) {
            resetUserApplicationContext(userApplicationContext);
            throw new GNE_SFA2_Exception();
        } else if(!appName.equalsIgnoreCase('SFA-US') && rostersForApplication.size() > 1) {
            resetUserApplicationContext(userApplicationContext);
            throw new GNE_SFA2_Exception();
        }
        
        GNE_SFA2_Selected_Application selectedApp = new GNE_SFA2_Selected_Application(rostersForApplication);
        
        if (userApplicationContext == null || userApplicationContext.Id == null) {
            userApplicationContext = new GNE_SFA2_User_App_Context_gne__c (App_Name_gne__c = appName, Brand_gne__c = selectedApp.brand, Role_gne__c = selectedApp.role, SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = icCalcSalesRoster.Runs_in_SFA2_Mode_gne__c ? true : false, SetupOwnerId = userInfo.getUserId());
            insert userApplicationContext;   
        } else if(!appName.equalsIgnoreCase('gCollaboration')) {
            userApplicationContext.App_Name_gne__c = appName;
            userApplicationContext.Brand_gne__c = selectedApp.brand;
            userApplicationContext.Role_gne__c = selectedApp.role;
            userApplicationContext.SFA2_Mode_gne__c = true;
            userApplicationContext.Run_in_SFA2_UI_gne__c = icCalcSalesRoster.Runs_in_SFA2_Mode_gne__c ? true : false;
            update userApplicationContext;
        }
        
        // redirect to home page
        PageReference pageRef = null;
        system.debug(appName);
        system.debug(GNE_SFA2_Util.isBrandUser());              
        // special behaviour for PFG Management (Home Office) Users - redirect to My PFG page
        if(appName == GNE_SFA2_PFG_Util.SFA_APP_TYPE && String.isBlank(selectedApp.brand) && selectedApp.role!=null && selectedApp.role.equalsIgnoreCase(GNE_SFA2_PFG_Util.USER_ROLE_MANAGER)) {
            pageRef = new PageReference('/apex/' + GNE_SFA2_PFG_Config.DCR_MAIN_PAGE);
        } else if (appName == 'SFA-US' && GNE_SFA2_Util.isBrandUser()){
            pageRef = new PageReference('/apex/GNE_SFA2_HCPs');
        } else if (targetURL != null){
            pageRef = new PageReference(targetURL);
        } else {
            targetURL = icCalcSalesRoster.App_URL_gne__c;
            if(targetURL.contains('#') && targetURL.split('#').size() > 1) {
                List<String> splitURL = targetURL.split('#');
                pageRef = new PageReference(splitURL.get(0));
                pageRef.setAnchor(splitURL.get(1));
            } else {
                pageRef = new PageReference(targetURL);
            } 
        }
        
        pageRef.setRedirect(true);
        return pageRef;
    }

    private static String getUserContextString(String appName, String brandName, String roleName){
        String keyMask = '{0}-{1}-{2}';
        String blankStr = 'null';
        return String.format(keyMask, 
            new String[]{
                String.isBlank(appName) ? blankStr : appName,
                String.isBlank(brandName) ? blankStr : brandName,
                String.isBlank(roleName) ? blankStr : roleName
            }
        ).toUpperCase();
    }
}