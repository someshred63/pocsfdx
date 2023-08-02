public without sharing class GNE_SFA2_Util {

    private final static String FRM_DATA_STEWARD_TOOL_PERMISSION_SET = 'Data_Stewardship_Tool';

    // static list of triggers to be skipped
    private static Set<String> triggerNames;
    // If set to true, triggers are set only when code is run as a test.
    // If false, triggers are always skipped.
    private static Boolean skipTriggersOnlyInTests = true;

    // static variable used to reduce the number of SOQL queries needed
    private static Map<Id, String> userIdToProfileNameMap = null;
    private static Map<Id, String> userIdToTitleNameMap = null;
    private static User currentUser = null;
    private static DatabaseWithSharingExecutor dbWithSharingExecutor;
    private static DatabaseWithoutSharingExecutor dbWithoutSharingExecutor;
    @TestVisible
    private static Map<Id, List<Territory2>> userTerritoriesMap;
    private static Map<Id, List<Product_vod__c>> userSetupProductsMap;
    public static final String BRAND_USER_PATTERN = '(?i)^GNE-SFA-(?!(CC|BAM|PREP|FPM|Ops|Ops2|InternalUser))\\w+(|-HEM|-RA)(|-CS|-CS-ReadOnly|-DM|-Manager)$';


    /* method used for turning all admin mode on and off */
    public static void switchAllAdminMode(Boolean isAdminMode) {
        if (GNE_SFA2_ALL_Admin_Mode__c.getInstance('GNE_SFA2_ALL_Admin_Mode') == null) {
            upsert new GNE_SFA2_ALL_Admin_Mode__c(Name = 'GNE_SFA2_ALL_Admin_Mode', GNE_SFA2_ALL_Admin_Mode__c = isAdminMode);
        } else {
            GNE_SFA2_ALL_Admin_Mode__c adminModeCustomSetting = GNE_SFA2_ALL_Admin_Mode__c.getInstance('GNE_SFA2_ALL_Admin_Mode');
            adminModeCustomSetting.GNE_SFA2_ALL_Admin_Mode__c = isAdminMode;
            update adminModeCustomSetting;
        }
    }

    public static void setSkipTriggersOnlyInTests (Boolean value) {
        skipTriggersOnlyInTests = value != null ? value : false;
    }

    /**
    * Mark the trigger as skipped so that it is not executed in tests
    */
    public static void skipTrigger (String triggerName) {
        if (triggerNames == null) {
            triggerNames = new Set<String>();
        }
        triggerNames.add(triggerName);
    }

    /**
    * Remove the mark that trigger is skipped
    */
    public static void stopSkipingTrigger(String triggerName){
        if (triggerNames == null) {
            return;
        }
        triggerNames.remove(triggerName);
    }

    /*
    * Method used for turning admin mode on and off.
    */
    public static void switchAdminMode(Boolean isAdminMode) {
        if(currentUser == null) {
            currentUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
        }
        List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId =: currentUser.Id LIMIT 1];

        System.runAs(currentUser){
            if (adminModeSetting.isEmpty()) {
                insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = currentUser.Id, GNE_SFA2_Is_Admin_Mode__c = isAdminMode);
            } else {
                adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = isAdminMode;
                update adminModeSetting;
            }
        }

    }

    /*
    * Checks if Admin Mode is enabled.
    */
    public static Boolean isAdminMode() {
        Boolean result = false;
        GNE_SFA2_Admin_Mode__c adminModeSetting = GNE_SFA2_Admin_Mode__c.getInstance();
        if (adminModeSetting != null) {
            result = adminModeSetting.GNE_SFA2_Is_Admin_Mode__c;
        }
        return result;
    }

    /*
    * Checks if Merge Mode is enabled.
    */
    public static Boolean isMergeMode(){
        Boolean mergeMode = false;
        GNE_SFA2_Merge_Mode_gne__c mergeModeSetting = GNE_SFA2_Merge_Mode_gne__c.getInstance();
        if (mergeModeSetting != null) {
            mergeMode = mergeModeSetting.GNE_SFA2_Is_Merge_Mode__c;
        }
        return mergeMode;
    }

    public static void switchMergeMode(Boolean newValue) {
        Boolean result = false;
        GNE_SFA2_Merge_Mode_gne__c mergeModeSetting = GNE_SFA2_Merge_Mode_gne__c.getInstance();

        if(mergeModeSetting == null) {
            mergeModeSetting = new GNE_SFA2_Merge_Mode_gne__c(SetupOwnerId = UserInfo.getUserId());
        } else {
            result = mergeModeSetting.GNE_SFA2_Is_Merge_Mode__c;
        }

        if(result != newValue) {
            if(newValue == false) {
                Boolean mergeJobsForCanadaCompleted = true;
                for(Merge_Type_Apex_Job_gne__c mergeTypeApexJob : [SELECT Id, Completed_gne__c
                FROM Merge_Type_Apex_Job_gne__c
                WHERE Completed_gne__c = false
                AND (Apex_Job_Type_gne__c='Merge' OR Apex_Job_Type_gne__c='Insert Candidates')
                AND Merge_Type_ref_gne__r.Region_Code_gne__c = 2
                AND createdDate=TODAY Limit 1]) {
                    mergeJobsForCanadaCompleted = false;
                }
                if(mergeJobsForCanadaCompleted) {
                    mergeModeSetting.GNE_SFA2_Is_Merge_Mode__c = newValue;
                    upsert mergeModeSetting;
                }
            } else {
                mergeModeSetting.GNE_SFA2_Is_Merge_Mode__c = newValue;
                upsert mergeModeSetting;
            }
        }
    }

    /*
    * Checks if given trigger is disabled.
    */
    public static Boolean isTriggerDisabled(String triggerName) {
        Boolean result = false;
        try {
            GNE_SFA2_Trigger_Execution_Exception_gne__c triggerSettings = GNE_SFA2_Trigger_Execution_Exception_gne__c.getValues(UserInfo.getOrganizationId());

            if(triggerSettings != null) {
                if(triggerSettings.None__c) {
                    // all the triggers are disabled
                    result = true;
                } else {
                    result = Boolean.valueOf(String.valueOf(triggerSettings.get(triggerName)));
                }
            }
        } catch (SObjectException exSO) {
            // Do nothing field not defined in settings
        } catch (Exception ex) {
            System.debug('Error while determining if trigger ' + triggerName + ' should be skipped: ' + ex.getMessage());
        }
        return result;
    }

    /**
    * Tells if the trigger should be skipped.
    */
    public static Boolean isAdminMode(String triggerName) {
        return triggerNames != null && triggerNames.contains(triggerName) && (Test.isRunningTest() || skipTriggersOnlyInTests == false);
    }

    /*
    * Enables or disables given trigger.
    */
    public static void setTriggerDisabled(String triggerName, Boolean isDisabled) {
        try {
            if(currentUser == null) {
                currentUser = [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() ];
            }
            System.runAs(currentUser) {
                GNE_SFA2_Trigger_Execution_Exception_gne__c triggerSettings = GNE_SFA2_Trigger_Execution_Exception_gne__c.getValues(UserInfo.getOrganizationId());
                if(triggerSettings == null) {
                    triggerSettings = new GNE_SFA2_Trigger_Execution_Exception_gne__c(SetupOwnerId = Userinfo.getOrganizationId());
                    insert triggerSettings;
                }
                triggerSettings.put(triggerName + '__c', isDisabled);
                update triggerSettings;
            }
        } catch (SObjectException exSO) {
            // Do nothing field not defined in settings
        } catch (Exception ex) {
            System.debug('Error while setting trigger ' + triggerName + ' to be skipped: ' + ex.getMessage());
        }
    }

    /*
    * Enables or disables given trigger.
    */
    public static void setTriggerDisabledForCurrentUser(String triggerName, Boolean isDisabled) {
        try {
            GNE_SFA2_Trigger_Execution_Exception_gne__c triggerSettings = GNE_SFA2_Trigger_Execution_Exception_gne__c.getValues(UserInfo.getUserId());
            if(triggerSettings == null) {
                triggerSettings = new GNE_SFA2_Trigger_Execution_Exception_gne__c(SetupOwnerId = Userinfo.getUserId());
                insert triggerSettings;
            }
            triggerSettings.put(triggerName + '__c', isDisabled);
            update triggerSettings;
        } catch (SObjectException exSO) {
            // Do nothing field not defined in settings
        } catch (Exception ex) {
            System.debug('Error while setting trigger ' + triggerName + ' to be skipped: ' + ex.getMessage());
        }
    }

    /*
    * Checks if context user's profile has a specific permission.
    */
    public static Boolean isPermitted(Id UserId, String Permission){
        Boolean isPermitted = false;
        User user = [Select Id, ProfileId from User where Id =: userId LIMIT 1];
        String query = 'select '+Permission+' from Profile where id=\''+user.profileId+'\' LIMIT 1';
        Profile prof = Database.query(query);
        isPermitted = (Boolean)prof.get(permission);
        return isPermitted;
    }

    /*
    *Methods create string "('id1', 'id2')" base on argument.
    */
    public static String createInListForQuery(Set<Id> ids){
        if (ids==null || ids.isEmpty()){
            return '(\'\')';
        }else{
            String queryList='(';
            for(Id tkdId: ids){
                queryList+='\''+tkdId+'\', ';
            }
            queryList = queryList.subString(0,queryList.Length()-2);
            queryList+=')';
            return queryList;
        }
    }

    /*
    *Methods create string "('id1', 'id2')" base on argument.
    */
    public static String createInListForQuery(List<Id> ids){
        if (ids==null || ids.isEmpty()){
            return '(\'\')';
        }else{
            String queryList='(';
            for(Id tkdId: ids){
                queryList+='\''+tkdId+'\', ';
            }
            queryList = queryList.subString(0,queryList.Length()-2);
            queryList+=')';
            return queryList;
        }
    }

    /*
    *Methods create string "('string1', 'string2')" base on argument.
    */
    public static String createInListForQuery(List<String> expressions){
        if (expressions==null || expressions.isEmpty()){
            return '(\'\')';
        }else{
            String queryList='(';
            for(String expression: expressions){
                if (String.isBlank(expression)){
                    queryList+='null, ';
                } else {
                    queryList+='\''+String.escapeSingleQuotes(expression).escapeEcmaScript() +'\', ';
                }
            }
            queryList = queryList.subString(0,queryList.Length()-2);
            queryList+=')';
            return queryList;
        }
    }

    public static String createInListForQueryNotEscaping(Set<String> expressions){
        return createInListForQueryNotEscaping(new List<String>(expressions));
    }

    /**
    *   Methods create string "('string1', 'string2')" base on argument.
    */
    public static String createInListForQueryNotEscaping(List<String> expressions){
        if (expressions==null || expressions.isEmpty()){
            return '(\'\')';
        }else{
            String queryList='(';
            for(String expression: expressions){
                if(expression.contains('\'')) {
                    expression = expression.replace('\'', '\\'+'\'');
                    queryList+='\''+expression+'\', ';
                }else{
                    queryList+='\''+expression+'\', ';
                }
            }
            queryList = queryList.subString(0,queryList.Length()-2);
            queryList+=')';
            return queryList;
        }
    }

    /**
    *    Methods return Profile Name of Current User
    */
    public static String getCurrentUserProfileName() {
        return getUserProfileName(UserInfo.getUserId());
    }

    public static String getUserProfileName(Id userId) {
        if (userIdToProfileNameMap == null){
            userIdToProfileNameMap = new Map<Id, String>();
        }
        if (!userIdToProfileNameMap.containsKey(userId)){
            String userProfileName = [SELECT Profile.Name FROM User WHERE Id = :userId LIMIT 1].Profile.Name;
            userIdToProfileNameMap.put(userId, userProfileName);
        }
        return userIdToProfileNameMap.get(userId);
    }

    public static String getUserTitleName(Id userId){
        if (userIdToTitleNameMap == null){
            userIdToTitleNameMap = new Map<Id, String>();
        }
        if (!userIdToTitleNameMap.containsKey(userId)){
            String userTitleName = null;
            for (User u : [SELECT Title FROM User WHERE Id = :userId LIMIT 1]){
                userTitleName = u.Title;
            }
            userIdToTitleNameMap.put(userId, userTitleName);
        }
        return userIdToTitleNameMap.get(userId);
    }

    public static Boolean isCanadaRMLUser(){
        return isCanadaRMLUser(UserInfo.getUserId());
    }

    public static Boolean isCanadaRMLUser(Id userId){
        Boolean result = false;
        if (!isCanadaUser(userId)){
            return result;
        }
        String userTitle = getUserTitleName(userId);
        if (String.isBlank(userTitle)){
            return result;
        }
        result = userTitle == 'Regional Medical Lead';
        return result;
    }

    public static Boolean isCanadaDirectorUser(){
        return isCanadaDirectorUser(UserInfo.getUserId());
    }

    public static Boolean isCanadaDirectorUser(Id userId){
        Boolean result = false;
        if (!isCanadaUser(userId)){
            return result;
        }
        String userTitle = getUserTitleName(userId);
        if (String.isBlank(userTitle)){
            return result;
        }
        result = userTitle == 'Director KE & ME';
        return result;
    }

    public static Boolean isCanadaOpsUser(){
        return isCanadaOpsUser(UserInfo.getUserId());
    }

    public static Boolean isCanadaOpsUser(Id userId){
        Boolean result = false;
        if (!isCanadaUser(userId)){
            return result;
        }
        String userProfileName = getUserProfileName(userId);
        result = userProfileName == 'RCanada-SFA-Ops';
        return result;
    }

    public static Boolean isCanadaSAMUser(){
        return isCanadaSAMUser(UserInfo.getUserId());
    }

    public static Boolean isCanadaSAMUser(Id userId){
        Boolean result = false;
        String userProfileName = getUserProfileName(userId);
        result = userProfileName == 'RCanada-SFA-SAM';
        return result;
    }

    public static Boolean isCanadaRAMAUser(){
        return isCanadaRAMAUser(UserInfo.getUserId());
    }

    public static Boolean isCanadaRAMAUser(Id userId){
        return getUserProfileName(userId) == 'RCanada-SFA-RAMA';
    }

    public static Boolean isCanadaINFUUser(){
        return isCanadaINFUUser(UserInfo.getUserId());
    }
    
    public static Boolean isCanadaINFUUser(Id userId){
        return getUserProfileName(userId) == 'RCanada-SFA-INFU';
    }
    
    public static Boolean isGneINFUUser(){
        return isGneINFUUser(UserInfo.getUserId());
    }
    
    public static Boolean isGneINFUUser(Id userId){
        return getUserProfileName(userId) == 'GNE-INFREQUENT-USER';
    }
    
    public static Boolean isBamOrAMUser(){
        return isBamOrAMUser(UserInfo.getUserId());
    }
    
    public static Boolean isAMUser(Id userId){
        return getUserProfileName(userId) == 'GNE-MCCO-AM';
    }
    
    public static Boolean isAMUser(){
        return isAMUser(UserInfo.getUserId());
    }
    
    public static Boolean isBamOrAMUser(Id userId){
        return getUserProfileName(userId) == 'GNE-MCCO-AM' || getUserProfileName(userId) == 'GNE-SFA-BAM';
    }

    public static Boolean isSfaCCUser(){
        return isSfaCCUser(UserInfo.getUserId());
    }
    
    public static Boolean isSfaCCUser(Id userId){
        return getUserProfileName(userId) == 'GNE-SFA-CC';
    }

    public static Boolean isNotCanadaUser(Id userId) {
        return !getUserProfileName(userId).startsWithIgnoreCase('RCanada-');
    }
    
    public static Boolean isNotCanadaUser() {
        return isNotCanadaUser(UserInfo.getUserId());
    }

    /**
    *    Methods checks if current user has SFA2 profile
    */
    public static Boolean isSFA2User() {
        Boolean isSFA2User = false;
        GNE_SFA2_User_App_Context_gne__c appContext = GNE_SFA2_User_App_Context_gne__c.getInstance();
        if (appContext != null) {
            isSFA2User = appContext.SFA2_Mode_gne__c;
        }
        return isSFA2User;
    }

    /**
    *    Methods checks if the the current user has SFA2 enabled this method is used in GNE_SFA2_View_Dispatcher_Ext and
    *    GNE_SFA2_Edit_Dispatcher_Ext
    */
    public static Boolean isSFA2UserForUI() {
        Boolean isSFA2User = false;
        GNE_SFA2_User_App_Context_gne__c appContext = GNE_SFA2_User_App_Context_gne__c.getValues(UserInfo.getUserId());
        if (appContext != null) {
            isSFA2User = appContext.SFA2_Mode_gne__c && appContext.Run_in_SFA2_UI_gne__c;
        }
        return isSFA2User;
    }

    /**
    *    Methods checks if current user has Canadia profile
    */
    public static Boolean isCanadaUser() {
        return isCanadaUser(getCurrentUserProfileName());
    }

    public static Boolean isCanadaUser(Id userId) {
        return isCanadaUser(getUserProfileName(userId));
    }

    public static Boolean isCanadaUser(String profileName) {
        Map<String, GNE_SFA2_Canadian_Users__c> canadianProfiles = GNE_SFA2_Canadian_Users__c.getAll();
        return canadianProfiles!=null && canadianProfiles.containsKey(profileName);
    }

    /**
    *    Methods checks if current user SFA-US brand user (CtD user)
    */
    public static Boolean isBrandUser() {
        return isBrandUser(getCurrentUserProfileName());
    }

    public static Boolean isBrandUser(String profileName) {
        return Pattern.matches(BRAND_USER_PATTERN, profileName);
    }

    /**
    *    Methods select user with SFA2 profile
    */
    public static User selectSFA2User() {
        List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-Field' AND (NOT Name LIKE 'GNE-SFA-Ops%') ];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id, External_ID_gne__c FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
    }

    /**
    *    Methods select user with SFA2 CS profile
    */
    public static User selectSFA2CSUser() {
        List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-SFA%-CS' ];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
    }

    /**
    *   Method inserts SFA2 profile prefix to the custom setting
    */
    /*public static void insertSFA2ProfileNamesCustomSetting(String sfa2ProfilePrefix) {
        GNE_SFA2_ALL_Profiles_Prefix__c prefixCustomSetting = GNE_SFA2_ALL_Profiles_Prefix__c.getInstance();
        if(prefixCustomSetting == null || prefixCustomSetting.GNE_SFA2_ALL_Profiles_Prefix__c == null) {
            GNE_SFA2_ALL_Profiles_Prefix__c prefix = new GNE_SFA2_ALL_Profiles_Prefix__c();
            prefix.GNE_SFA2_ALL_Profiles_Prefix__c = sfa2ProfilePrefix;

            insert prefix;
        }
    }*/

    /**
    *   Method inserts Canadian profile names to the custom setting
    */
    public static void insertCanadianProfileNamesCustomSetting() {
        Map<String, GNE_SFA2_Canadian_Users__c> canadianProfilesCustomSetting = GNE_SFA2_Canadian_Users__c.getAll();
        if(canadianProfilesCustomSetting == null || canadianProfilesCustomSetting.isEmpty()) {
            List<GNE_SFA2_Canadian_Users__c> profileNames = new List<GNE_SFA2_Canadian_Users__c>();
            profileNames.add(new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SFA-Manager', GNE_SFA2_Profile_Name__c = 'RCanada-SFA-Manager'));
            profileNames.add(new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SFA-MSL', GNE_SFA2_Profile_Name__c = 'RCanada-SFA-MSL'));
            profileNames.add(new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SFA-MSL-Manager', GNE_SFA2_Profile_Name__c = 'RCanada-SFA-MSL-Manager'));
            profileNames.add(new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SFA-Ops', GNE_SFA2_Profile_Name__c = 'RCanada-SFA-Ops'));
            profileNames.add(new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SFA-ReadOnly', GNE_SFA2_Profile_Name__c = 'RCanada-SFA-ReadOnly'));
            profileNames.add(new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SFA-TS', GNE_SFA2_Profile_Name__c = 'RCanada-SFA-TS'));
            profileNames.add(new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SYS-AutomatedJob', GNE_SFA2_Profile_Name__c = 'RCanada-SYS-AutomatedJob'));
            insert profileNames;
        }
    }

    /**
    *   Method inserts MCCO profile names to the custom setting
    */
    /*public static void insertMCCOProfileNamesCustomSetting() {
        Map<String, GNE_SFA2_MCCO_Profiles__c> mccoProfilesCustomSetting = GNE_SFA2_MCCO_Profiles__c.getAll();
        if(mccoProfilesCustomSetting == null || mccoProfilesCustomSetting.isEmpty()) {
            List<GNE_SFA2_MCCO_Profiles__c> profileNames = new List<GNE_SFA2_MCCO_Profiles__c>();
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-AM', Profile_name__c = 'GNE-MCCO-AM'));
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-Kaiser', Profile_name__c = 'GNE-MCCO-Kaiser'));
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-FRM-AFRM-nonSSO', Profile_name__c = 'GNE-MCCO-FRM-AFRM-nonSSO'));
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-FRM-BFRM', Profile_name__c = 'GNE-MCCO-FRM-BFRM'));
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-FRM-EFRM', Profile_name__c = 'GNE-MCCO-FRM-EFRM'));
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-FRM-GFRM', Profile_name__c = 'GNE-MCCO-FRM-GFRM'));
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-FRM-IFRM', Profile_name__c = 'GNE-MCCO-FRM-IFRM'));
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-FRM-RFRM', Profile_name__c = 'GNE-MCCO-FRM-RFRM'));
            profileNames.add(new GNE_SFA2_MCCO_Profiles__c(Name = 'GNE-MCCO-FRM-NFRM', Profile_name__c = 'GNE-MCCO-FRM-NFRM'));
            insert profileNames;
        }
    }*/

    /**
    *   Method inserts user count notification settings to the custom setting
    */
    public static void insertUserCountNotificationCustomSettings(Integer userCount, Integer maxUserCount, String notificationEmail) {
        GNE_SFA2_User_Count_Notification__c userCountCustomSetting = GNE_SFA2_User_Count_Notification__c.getInstance();
        if(userCountCustomSetting == null || userCountCustomSetting.User_count__c == null) {
            userCountCustomSetting = new GNE_SFA2_User_Count_Notification__c();
            userCountCustomSetting.Name = 'Default';
            userCountCustomSetting.User_count__c = userCount;
            insert userCountCustomSetting;
        }

        GNE_SFA2_User_Max_Count__c userMaxCountCustomSetting = GNE_SFA2_User_Max_Count__c.getInstance();
        if(userMaxCountCustomSetting == null || userMaxCountCustomSetting.User_count__c == null) {
            userMaxCountCustomSetting = new GNE_SFA2_User_Max_Count__c();
            userMaxCountCustomSetting.Name = 'Default';
            userMaxCountCustomSetting.User_count__c = maxUserCount;
            insert userMaxCountCustomSetting;
        }

        GNE_SFA2_User_Notification_Email__c notificationEmailCustomSetting = GNE_SFA2_User_Notification_Email__c.getInstance();
        if(notificationEmailCustomSetting == null || notificationEmailCustomSetting.Email__c == null) {
            notificationEmailCustomSetting = new GNE_SFA2_User_Notification_Email__c();
            notificationEmailCustomSetting.Name = 'Default';
            notificationEmailCustomSetting.Email__c = notificationEmail;
            insert notificationEmailCustomSetting;
        }
    }

    public static void sortList(List<Sobject> items, String sortField, Boolean sortAscending){
        List<Sobject> resultList = new List<Sobject>();
        //Create a map that can be used for sorting
        Map<object, List<Sobject>> objectMap = new Map<object, List<Sobject>>();
        for(Sobject ob : items){
            if(objectMap.get(ob.get(sortField)) == null){  // For non Sobject use obj.ProperyName
                objectMap.put(ob.get(sortField), new List<Sobject>());
            }
            objectMap.get(ob.get(sortField)).add(ob);
        }
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();

        for(object key : keys){
            resultList.addAll(objectMap.get(key));
        }

        //Apply the sorted values to the source list
        items.clear();
        if(sortAscending){
            for(Sobject ob : resultList){
                items.add(ob);
            }
        }else{
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i]);
            }
        }
    }

    //  This is a simple quicksort algorithm to sort a SelectOption list (dropdown) by label alphabetically. Select option with --None-- label option is set on 1 place.
    public static List<SelectOption> sortOptionList(List<SelectOption> listToSort)  {
        if(listToSort == null || listToSort.size() <= 1) {
            return listToSort;
        }

        List<SelectOption> less = new List<SelectOption>();
        List<SelectOption> greater = new List<SelectOption>();

        Integer pivot = 0;
        // save the pivot and remove it from the list
        SelectOption pivotValue = listToSort[pivot];
        listToSort.remove(pivot);
        for(SelectOption x : listToSort) {
            if(x.getLabel().compareTo(pivotValue.getLabel()) <= 0) {
                less.add(x);
            } else if(x.getLabel().compareTo(pivotValue.getLabel()) > 0) {
                greater.add(x);
            }
        }
        List<SelectOption> returnList = new List<SelectOption> ();
        returnList.addAll(sortOptionList(less));
        returnList.add(pivotValue);
        returnList.addAll(sortOptionList(greater));

        SelectOption noneOption = null;
        for(Integer i = 0; i< returnList.size(); i++){
            if(returnList.get(i).getLabel()=='--None--'){
                noneOption = returnList.remove(i);
            }
        }
        if(noneOption != null){
            returnList.add(0, noneOption);
        }
        return returnList;
    }

    /**
    *   This is a helper function used for checking UI components visibility on VF pages
    */
    public static Map<String, Boolean> getUiComponentsVisibility(String componentType, String pageName){

        Map<String, Boolean> buttonsVisibilityMap = new Map<String, Boolean>();
        List<SFA2_Configuration_Object_Detail_gne__c> buttonConfigurations = [SELECT API_Name_gne__c, Is_Read_Only_gne__c, Order_gne__c, Type_gne__c
        FROM SFA2_Configuration_Object_Detail_gne__c
        WHERE Type_gne__c = :componentType
        AND Configuration_Object_ref_gne__r.Object_Name_gne__c = :pageName
        AND Is_Active_gne__c = true];
        if(buttonConfigurations != null && buttonConfigurations.size() > 0){
            for(SFA2_Configuration_Object_Detail_gne__c btnConfig : buttonConfigurations){
                buttonsVisibilityMap.put(btnConfig.API_Name_gne__c, btnConfig.Is_Read_Only_gne__c);
            }
        }
        return buttonsVisibilityMap;
    }

    public static List<SFA2_Configuration_Object_Detail_gne__c> getUIComponentsConfiguration(String pageName, String configurationType, String componentType){
        GNE_SFA2_User_App_Context_gne__c userContext = GNE_SFA2_Util.getUserApplicationContext();
        List<SFA2_Configuration_Object_Detail_gne__c> result = [SELECT API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Required_gne__c, Is_Read_Only_gne__c, Order_gne__c, Type_gne__c, Style_gne__c
        FROM SFA2_Configuration_Object_Detail_gne__c
        WHERE Type_gne__c = :componentType AND Configuration_Object_ref_gne__r.Object_Name_gne__c = :pageName AND Configuration_Object_ref_gne__r.Application_Type__c =:userContext.App_Name_gne__c
        AND Configuration_Object_ref_gne__r.Role_gne__c =:userContext.Role_gne__c AND Configuration_Object_ref_gne__r.Brand_gne__c =:userContext.Brand_gne__c AND Configuration_Object_ref_gne__r.Is_Active_gne__c = true
        AND Configuration_Object_ref_gne__r.Configuration_Type_gne__c = :configurationType AND Is_Active_gne__c = true order by Order_gne__c];
        return result;
    }

    // method for dynamic button rendering basing on button configuration record(s)
    public static Component.Apex.PageBlockButtons getCustomButtons(String pageName, String configurationType, String componentType) {
        List<SFA2_Configuration_Object_Detail_gne__c> buttonConfigurations = getUIComponentsConfiguration(pageName, configurationType, componentType);

        Component.Apex.PageBlockButtons dynamicPageBlockButtons = new Component.Apex.PageBlockButtons();
        dynamicPageBlockButtons.location = 'top';

        if(buttonConfigurations != null && buttonConfigurations.size() >= 0){
            for(SFA2_Configuration_Object_Detail_gne__c buttonConfiguration : buttonConfigurations) {
                Component.Apex.CommandButton dynamicButton = new Component.Apex.CommandButton();

                dynamicButton.value = buttonConfiguration.Label_gne__c;
                dynamicButton.disabled = buttonConfiguration.Is_Read_Only_gne__c;
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('action')){
                    dynamicButton.expressions.action = '{!'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}';
                    System.debug( '****actionin***'+'{!'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}');
                    System.debug('**action***'+dynamicButton.expressions.action);
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('styleClass')){
                    dynamicButton.styleClass = buttonConfiguration.Attributes_gne__c.substringBetween('styleClass=',';');
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('dir')){
                    dynamicButton.dir = buttonConfiguration.Attributes_gne__c.substringBetween('dir=',';');
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('onclick')){
                    dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=',';');
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('rerender')){
                    dynamicButton.rerender = new Set<String>(buttonConfiguration.Attributes_gne__c.substringBetween('rerender=',';').split(','));
                }
                if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.contains('immediate')){
                    if(buttonConfiguration.Attributes_gne__c!=null && buttonConfiguration.Attributes_gne__c.substringBetween('immediate=',';') == 'true'){
                        System.debug('setting immediate to true');
                        dynamicButton.immediate = true;
                    } else {
                        System.debug('setting immediate to false');
                        dynamicButton.immediate = false;
                    }
                }
                System.debug('dynamic button: '+dynamicButton);
                dynamicPageBlockButtons.childComponents.add(dynamicButton);
            }
        }
        return dynamicPageBlockButtons;
    }

    public static SFA2_Configuration_Object_gne__c getListPageConfiguration(String objectName) {
        GNE_SFA2_User_App_Context_gne__c userContext = GNE_SFA2_Util.getUserApplicationContext();
        List<SFA2_Configuration_Object_gne__c>  config = [ SELECT Name, Attributes_gne__c, Section_Header_gne__c FROM SFA2_Configuration_Object_gne__c
        WHERE Configuration_Type_gne__c = 'List Page' AND Is_Active_gne__c = true AND Application_Type__c = :userContext.App_Name_gne__c
        AND Role_gne__c = :userContext.Role_gne__c AND Brand_gne__c = :userContext.Brand_gne__c AND Object_Name_gne__c = :objectName ORDER BY Name LIMIT 1 ];

        if(config != null && config.size() > 0){
            return config[0];
        } else {
            return null;
        }
    }

    public static String getAddressAsString(Address_vod__c addr) {
        Address_vod__c address = addr.clone();
        Boolean usOrCanada = String.isNotBlank(address.State_vod__c);
        return getAddressAsString(address.Name, address.Address_line_2_vod__c, address.City_vod__c,
                (usOrCanada ? address.State_vod__c : address.Province_can_gne__c),
                (usOrCanada ? address.Zip_vod__c : address.Postal_Code_can_gne__c),
                (usOrCanada && String.isNotBlank(address.Zip_vod__c) ? address.Zip_4_vod__c : null));
    }

    public static String getAddressAsString(String addrName, String addrLine2, String city, String state, String zip, String zip4) {
        return String.format('{0}{1}, {2}, {3} {4}{5}', new String[]{
                addrName, 
                (String.isNotBlank(addrLine2) ? ' ' + addrLine2 : ''),
                (String.isNotBlank(city) ? city: ''),
                (String.isNotBlank(state) ? state : ''),
                (String.isNotBlank(zip) ? zip : ''),
                (String.isNotBlank(zip4) ? '-' + zip4 : '')
        });
    }

    public static List<SFA2_User_Sales_Roster_gne__c> getUserSalesRosters(Id userId){
        List<SFA2_User_Sales_Roster_gne__c> result = [ SELECT role_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Sales_Roster_gne__r.type_gne__c, Sales_Roster_gne__r.Is_SFA2_Available_gne__c
        FROM SFA2_User_Sales_Roster_gne__c WHERE User_gne__c=:userId AND Is_Active_gne__c = true AND Sales_Roster_gne__r.Runs_in_SFA2_Mode_gne__c = true
        ORDER BY Sales_Roster_gne__r.type_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, role_gne__c ];
        return result;
    }

    /**
    *   New method for checking user sales roster based on the selected application
    */
    public static List<SFA2_User_Sales_Roster_gne__c> getUserSalesRostersForCurrentApp(Id userId){
        List<SFA2_User_Sales_Roster_gne__c> result = new List<SFA2_User_Sales_Roster_gne__c>();
        GNE_SFA2_User_App_Context_gne__c applicationContext = GNE_SFA2_User_App_Context_gne__c.getInstance();
        if(applicationContext != null) {
            result = [ SELECT role_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Sales_Roster_gne__r.type_gne__c, Sales_Roster_gne__r.Is_SFA2_Available_gne__c
            FROM SFA2_User_Sales_Roster_gne__c WHERE User_gne__c = :userId AND Is_Active_gne__c = true AND Sales_Roster_gne__r.Is_SFA2_Available_gne__c = true AND Sales_Roster_gne__r.Type_gne__c = :applicationContext.App_Name_gne__c
            AND Role_gne__c = :applicationContext.Role_gne__c AND Sales_Roster_gne__r.Brand_Name_gne__c = :applicationContext.Brand_gne__c ];

        }

        return result;
    }

    public static GNE_SFA2_User_App_Context_gne__c getUserApplicationContext() {
        GNE_SFA2_User_App_Context_gne__c applicationContext = !isCanadaINFUUser() ? GNE_SFA2_User_App_Context_gne__c.getInstance() : new GNE_SFA2_User_App_Context_gne__c(App_Name_gne__c = 'SFA-Canada', Brand_gne__c = null, Role_gne__c = 'INFU', SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = true);
        return applicationContext;
    }

    public static GNE_SFA2_User_App_Context_gne__c getApplicationContextByRecordOwner(String callId) {
        List<Call2_vod__c> call2vod = [SELECT Owner.Profile.Name, RecordType.DeveloperName from Call2_vod__c WHERE Id = :callId];
        GNE_SFA2_User_App_Context_gne__c appContext = null;

        if (call2vod.size() > 0) {
            String ownerProfileName = call2vod[0].Owner.Profile.Name;
            String recordTypeName = call2vod[0].RecordType.DeveloperName;
            List<SFA2_User_Group_Mapping_gne__c> avApps = [SELECT Application_gne__c, Brand_gne__c, Role_gne__c FROM SFA2_User_Group_Mapping_gne__c
            WHERE Profile_Name_gne__c = :ownerProfileName];

            String queryStr = 'SELECT Application_Type__c, Brand_gne__c, Role_gne__c FROM SFA2_Configuration_Object_gne__c ';
            queryStr += 'WHERE Is_Active_gne__c = true AND Object_Name_gne__c = \'Call2_vod__c\' AND Record_type_gne__c = :recordTypeName AND (';

            for (SFA2_User_Group_Mapping_gne__c gm : avApps) {
                if (queryStr.contains('AND Application_Type__c')) {
                    queryStr += ' OR ';
                }

                String gmRole = (gm.Role_gne__c == null) ? 'NULL' : '\'' + gm.Role_gne__c + '\'';
                String gmBrand = (gm.Brand_gne__c == null) ? 'NULL' : '\'' + gm.Brand_gne__c + '\'';
                String gmApp = (gm.Application_gne__c == null) ? 'NULL' : '\'' + gm.Application_gne__c + '\'';

                queryStr += '(Role_gne__c = ' + gmRole +' AND Brand_gne__c = ' + gmBrand + ' AND Application_Type__c =' + gmApp +')';
            }

            queryStr += ') LIMIT 1';

            if (avApps.size() > 0) {
                List<SFA2_Configuration_Object_gne__c> confObjs = Database.query(queryStr);

                if (confObjs.size() > 0) {
                    SFA2_Configuration_Object_gne__c cObj = confObjs[0];
                    List<IC_Calc_Sales_Roster_gne__c> sfa2Accesses = [SELECT Is_SFA2_Available_gne__c, Runs_in_SFA2_Mode_gne__c FROM IC_Calc_Sales_Roster_gne__c
                    WHERE Type_gne__c = :cObj.Application_Type__c AND Brand_Name_gne__c = :cObj.Brand_gne__c];

                    appContext = new GNE_SFA2_User_App_Context_gne__c();
                    appContext.App_Name_gne__c = cObj.Application_Type__c;
                    appContext.Brand_gne__c = cObj.Brand_gne__c;
                    appContext.Role_gne__c = cObj.Role_gne__c;

                    if (sfa2Accesses.size() > 0) {
                        appContext.SFA2_Mode_gne__c = sfa2Accesses[0].Is_SFA2_Available_gne__c;
                        appContext.Run_in_SFA2_UI_gne__c = sfa2Accesses[0].Runs_in_SFA2_Mode_gne__c;
                    }
                }
            }
        }

        return appContext;
    }

    /* DEPRECATED getUserSalesRosters should be in use */
    public static List<SFA2_User_Sales_Roster_gne__c> getBrandRoleAppType(Id userId){
        return getUserSalesRosters(userId);
    }

    public static String getUserBrandName(List<SFA2_User_Sales_Roster_gne__c> userSalesRosters){
        String result = null;
        if (userSalesRosters != null && userSalesRosters.size() > 0){
            if (userSalesRosters.size() == 1){
                result = userSalesRosters[0].Sales_Roster_gne__r.Brand_Name_gne__c;
            } else {
                List<String> listOfBrands = new List<String>();
                for (SFA2_User_Sales_Roster_gne__c userSalesRoster : userSalesRosters){
                    listOfBrands.add(userSalesRoster.Sales_Roster_gne__r.Brand_Name_gne__c);
                }
                // sort list ascending
                listOfBrands.sort();
                result = String.join(listOfBrands, '_');
            }
        }
        return result;
    }

    public static PageReference redirectToErrorPage(String errorMessage, String currentURL, String developerMessage) {
        PageReference pageref = Page.GNE_SFA2_Exception_Layout;
        pageref.setredirect(true);
        pageref.getParameters().put('exMessage', errorMessage);
        pageref.getParameters().put('exUrl', currentURL);
        pageref.getParameters().put('developerMessage', developerMessage);
        return pageref;
    }

    public static PageReference redirectToAccessDeniedPage() {
        PageReference pageref = Page.GNE_SFA2_Access_Denied;
        pageref.setredirect(true);

        if (ApexPages.currentPage() != null){
            Map<String, String> parameters = ApexPages.currentPage().getParameters();
            if (parameters != null && parameters.size() > 0){
                if (parameters.containsKey('retURL')){
                    pageref.getParameters().put('retURL', parameters.get('retURL'));
                }
            }
        }
        return pageref;
    }

    public static String getDefaultRecordType(String objectName){
        String sRecordTypeId = '';
        DescribeSObjectResult oObjectResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        List<RecordTypeInfo> oRecTypeInfos = oObjectResult.getRecordTypeInfos();
        for(RecordTypeInfo oRecTypeInfo : oRecTypeInfos){
            if(oRecTypeInfo.defaultRecordTypeMapping){
                sRecordTypeId = oRecTypeInfo.recordTypeId;
            }
        }
        return sRecordTypeId;
    }

    /*Return default recordt type name for object, application, brand and role */
    public static String getDefaultRecordType(String objectName, String applicationType, String brand, String role){
        List<SFA2_Configuration_Object_gne__c>confObjects = [SELECT id, Record_Type_gne__c FROM SFA2_Configuration_Object_gne__c
        WHERE Object_Name_gne__c = :objectName AND Application_Type__c = :applicationType
        AND Brand_gne__c = :brand AND Role_gne__c = :role AND Is_Active_gne__c = true
        AND Is_Default_Record_Type_gne__c = true LIMIT 1];
        if(confObjects.size()==1){
            return confObjects.get(0).Record_Type_gne__c;
        }else{
            return '';
        }
    }

    public static String getDefaultRecordType(String objectName, SFA2_User_Sales_Roster_gne__c userSalesRooster){
        return getDefaultRecordType(objectName, userSalesRooster.Sales_Roster_gne__r.Type_gne__c , userSalesRooster.Sales_Roster_gne__r.Brand_Name_gne__c, userSalesRooster.Role_gne__c);
    }

    public static String getEnvironment(){
        String env ='';
        String userName = Userinfo.getUsername();
        if(userName !=''){
            if(userName.indexOf('@gene.com') > 0 && userName.indexOf('@gene.com.') <0){
                env = 'prod';
            }else if(userName.indexOf('@gene.com.') >0){
                env = userName.substring(userName.indexOf('@gene.com.')+10, userName.length());
            }
        }
        return env;
    }

    public static List<Environment_Variables__c> getAllEnvVariables(String variable){
        List<Environment_Variables__c> query = new List<Environment_Variables__c>();
        List<String> Environment = new List<String>{'ALL'};
        string userName = Userinfo.getUsername();
        if(userName != null && userName != ''){
            String environmentName = getEnvironment();
            if(environmentName != null && environmentName.length() > 0){
                Environment.add(environmentName);
            }
        }

        if(variable != null){
            query = [select Environment__c, Key__c, Value__c from Environment_Variables__c where Environment__c IN :Environment and Key__c =:variable];
        }
        return (query);
    }


    /* Get user access to the specific record */
    public static UserRecordAccess getUserRecordAccess(String userId, String recordId){
        if (!String.isBlank(userId) && !String.isBlank(recordId)){
            return [SELECT RecordId, HasEditAccess, HasReadAccess, HasTransferAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId];
        } else {
            return null;
        }
    }

    public static Boolean getUserCanDeleteRecordAccess(String userId, String recordId){
        Boolean result = false;
        UserRecordAccess recAccess = getUserRecordAccess(userId, recordId);
        if (recAccess != null){
            result = recAccess.HasDeleteAccess;
        }
        return result;
    }

    public static List<Product_vod__c> getUserSetupProducts(Id userId){
        return getUserSetupProducts(userId, null);
    }

    public static List<Product_vod__c> getUserSetupProducts(Id userId, String whereAddExpr){
        if (userSetupProductsMap == null){
            userSetupProductsMap = new Map<Id, List<Product_vod__c>>();
        }
        if (!userSetupProductsMap.containsKey(userId)){
            Set<String> inactiveProdQueueNames = new Set<String>{'GNE-CANADA-INACTIVE-PROD-QUEUE', 'GNE-INACTIVE-PROD-QUEUE'};
            String query = 'SELECT Id, Name From Product_vod__c Where Id In (Select Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = :userId) AND OwnerId NOT IN (Select Id From Group Where Name In :inactiveProdQueueNames) ';
            if (String.isNotBlank(whereAddExpr)){
                query += ' AND ' + whereAddExpr;
            }
            List<Product_vod__c> userProductList = Database.query(query);
            userSetupProductsMap.put(userId, userProductList);
        }
        return userSetupProductsMap.get(userId);
    }

    /* method returns Territory2 records except root and inactive records */
    public static List<Territory2> getAllAvailableTerritories() {

        List<Territory2> territoriesList = [
                SELECT Id, Name, External_id_gne__c, ParentTerritory2Id
                FROM Territory2
                WHERE (ParentTerritory2Id != '') AND (NOT External_id_gne__c LIKE '%INACTIVE TERRITORIES%')
                ORDER BY Name
        ];

        return territoriesList;

    }
	
    /* method returns root Territory2 record based on Territory2.DeveloperName */
    public static List<Territory2> getTerritoriesBasedOnProfileName(String territoryDeveloperName) {
        List<Territory2> territoriesList = [
                SELECT Id, Name, DeveloperName, External_id_gne__c, ParentTerritory2Id
                FROM Territory2
                WHERE ParentTerritory2Id = ''
                AND DeveloperName =: territoryDeveloperName
                ORDER BY Name
        ];

        return territoriesList;
    }

    /* Get user territories */
    public static List<Territory2> getUserTerritories(Id userId){
        if (userTerritoriesMap == null){
            userTerritoriesMap = new Map<Id, List<Territory2>>();
        }

        if (!userTerritoriesMap.containsKey(userId)){
            userTerritoriesMap.put(userId, new List<Territory2>());
            Map<Id, Territory2> userTerritories = new Map<Id, Territory2>([
                    SELECT Id, Name, External_id_gne__c, ParentTerritory2Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c
                    FROM Territory2
                    WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :userId)
                    ORDER BY Name
            ]);
            if(!userTerritories.isEmpty()) {
                userTerritoriesMap.get(userId).addAll(getAllUserTerritoriesBasedOnHierarchy(userTerritories));
            }
        }
        return userTerritoriesMap.get(userId);
    }

    /* Get all user territories based on hierarchy */
    public static List<Territory2> getAllUserTerritoriesBasedOnHierarchy(Map<Id, Territory2> userTerritories) {
        Set<Id> userTerritoriesIds = userTerritories.keySet();
        String queryString = 'SELECT Id, Name, External_id_gne__c, ParentTerritory2Id, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c FROM Territory2 WHERE (External_id_gne__c Like \'GNE-US%\' OR External_id_gne__c Like \'ROCHE-CANADA%\') AND (NOT External_id_gne__c Like \'INACTIVE TERRITORIES%\')';
        String conditions = ' AND (';
        for(Territory2 t : userTerritories.values()) {
            conditions += 'External_id_gne__c Like \'' + t.External_id_gne__c.replaceAll('\'', '\\\\\'') + '%\' OR ';
        }
        queryString += conditions + 'Id IN : userTerritoriesIds) ORDER BY External_id_gne__c';
        return (List<Territory2>)Database.query(queryString);
    }

    /* Get child territories based on Parent Id */
    public static void getChildrenTerritories(List<Territory2> parentTerritories, Set<Territory2> result) {
        List<Territory2> childrenTerritories = [ SELECT Id, Name, External_id_gne__c, ParentTerritory2Id FROM Territory2 WHERE ParentTerritory2Id in :parentTerritories ORDER BY ParentTerritory2Id ];
        if(childrenTerritories.size() > 0) {
            result.addAll(childrenTerritories);
            getChildrenTerritories(childrenTerritories, result);
        }
    }

    public static List<Territory2> sortTerritoriesHierarchical(Set<Territory2> territories){
        if (territories == null){
            return null;
        }
        List<TerritoryWrapper> wrappers = new List<TerritoryWrapper>();
        for (Territory2 territory : territories){
            wrappers.add(new TerritoryWrapper(territory));
        }
        wrappers.sort();
        List<Territory2> result = new List<Territory2>();
        for (TerritoryWrapper tw : wrappers){
            result.add(tw.territory);
        }
        return result;
    }

    private class TerritoryWrapper implements Comparable {
        public Territory2 territory;
        public Id terrId;
        public String externalId;
        public Id parentId;

        public TerritoryWrapper(Territory2 terr){
            this.territory = terr;
            this.terrId = terr.Id;
            this.externalId = terr.external_id_gne__c;
            this.parentId = terr.ParentTerritory2Id;
        }

        public Integer compareTo(Object compareTo){
            TerritoryWrapper comparableTerr = (TerritoryWrapper)compareTo;
            Integer result = 0;
            // if top level territory
            if (this.terrId == comparableTerr.parentId){
                result = -1;
            } else if (String.isBlank(this.externalId)) {
                // set nulls last
                result = 1;
            } else {
                // else compare by external_id_gne__c
                if (comparableTerr.externalId != null) {
                    result = this.externalId.compareTo(comparableTerr.externalId);
                }
            }
            return result;
        }
    }

    public static Set<Id> findMatchingTerritories(List<Territory2> userTerritories, List<Id> accountTerritories){
        Set<Id> result = new Set<Id>();

        Map<Id,Territory2> idToTerritory = getAllTerritories();
        SFA2_User_Preferences_gne__c userPreferences = [SELECT Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND OwnerId = :Userinfo.getUserId() LIMIT 1];
        Id preferedTerritory = (Id)userPreferences.Last_Territory_Used_gne__c;

        Set<Id> matchingTerritories = new Set<Id>();
        Set<Id> allFromBranch = new Set<Id>();
        Set<Id> directMatch = new Set<Id>();
        Set<Id> userTerritoriesIds = new Set<Id>();
        for(Territory2 t :userTerritories){
            userTerritoriesIds.add(t.Id);
        }

        for(Id accountTerritory :accountTerritories){
            if(userTerritoriesIds.contains(accountTerritory)){
                directMatch.add(accountTerritory);
            }
        }
        /*first case - we found exact match*/
        if(directMatch.contains(preferedTerritory)){
            result.add(preferedTerritory);
            return result;
        }
        /*we dont have exact match - we have to find all matching childs*/
        for(Id accountTerritory :accountTerritories){
            Territory2 accountTerr = idToTerritory.get(accountTerritory);
            List<Id> tempInBranch = new List<Id>();
            Boolean highEnough = false;
            while(accountTerr.ParentTerritory2Id!=null && !highEnough){
                if(checkIfMatch(userTerritories, accountTerr.ParentTerritory2Id)){
                    tempInBranch.add(accountTerr.ParentTerritory2Id);
                }
                if(accountTerr.ParentTerritory2Id==preferedTerritory){
                    highEnough=true;
                }
                accountTerr=idToTerritory.get(accountTerr.ParentTerritory2Id);
            }
            if(highEnough){
                allFromBranch.add(accountTerritory);
                if(directMatch.contains(accountTerritory)){
                    matchingTerritories.add(accountTerritory);
                }
            }
        }
        /*second case - we have some child territories of prefered one, where account territory matches with user territory*/
        if(matchingTerritories.size()>0){
            return matchingTerritories;
        }
        /*third case - we don't have user territory, that matches account territory, so we return account territories that are child territories of prefered one*/
        if(allFromBranch.size()>0){
            return allFromBranch;
        }
        /*and if this line is executed it means, that none of account territories matches user prefered territory and its childs - this shouldn't happen*/
        return null;
    }

    public static Id findFirstMatchForSingleTerritory(List<Territory2> userTerritories, Id accountTerritory){
        Set<Id> userTerritoriesIds = new Set<Id>();
        for(Territory2 t :userTerritories){
            userTerritoriesIds.add(t.Id);
        }
        /*1st case - user is assigned to the same territory as account*/
        if(userTerritoriesIds.contains(accountTerritory)){
            return accountTerritory;
        }
        /*2nd case - user is assigned to parent of account territory or it's parent or it's parent ...*/
        Map<Id,Territory2> idToTerritory = getAllTerritories();
        Territory2 accountTerr = idToTerritory.get(accountTerritory);
        while(accountTerr.ParentTerritory2Id!=null){
            if(checkIfMatch(userTerritories, accountTerr.ParentTerritory2Id)){
                return accountTerr.ParentTerritory2Id;
            }
            accountTerr=idToTerritory.get(accountTerr.ParentTerritory2Id);
        }
        /*if we havent found match yet, it means that user shoudln't have access to this account by this territory*/
        return null;
    }

    private static Boolean checkIfMatch(List<Territory2> userTerritories, Id parentToCheck){
        for(Territory2 t : userTerritories){
            if(t.Id==parentToCheck){
                return true;
            }
        }
        return false;
    }

    private static Map<Id,Territory2> getAllTerritories(){
        return new Map<Id,Territory2>([SELECT Id, Name, External_id_gne__c, ParentTerritory2Id FROM Territory2]);
    }

    /*This methods are used to get and compare OTR version from iPhone Request Id field*/
    public static Boolean isOldOTRVersion(String iPhoneRequestId, Integer OTRVersionToCompare){
        Boolean isOldOTRVer = false;
        String OtrVersionString = getOTRVersion(iPhoneRequestId);
        if(String.isNotBlank(OtrVersionString)){
            if(Integer.valueOf(OtrVersionString) < OTRVersionToCompare){
                isOldOTRVer = true;
            }
        }
        return isOldOTRVer;
    }

    public static String getOTRVersion(String iPhoneRequestId){
        String OtrVersionString = '';
        if(String.isNotBlank(iPhoneRequestId) && (iPhoneRequestId.startsWith('iPad') || iPhoneRequestId.startsWith('iPhone'))){
            List<String> iPhoneRequestIdList = iPhoneRequestId.split('_');
            Pattern OTRVerPattern = Pattern.compile('[0-9]+(\\.+[0-9])?+(\\.+[0-9])?');
            if(iPhoneRequestIdList.size() == 4){
                Matcher OTRVerMatcher = OTRVerPattern.matcher(iPhoneRequestIdList[2]);
                if(OTRVerMatcher.matches()){
                    List<String> OTRVersionList = iPhoneRequestIdList[2].split('\\.');
                    for(String d : OTRVersionList){
                        OtrVersionString += d;
                    }
                    while(OtrVersionString.length()<3){
                        OtrVersionString += '0';
                    }
                }
            }
        }
        return OtrVersionString;
    }

    /*
     * This methods are used to check if user is MCCO CRM
     */
    public static Boolean isMccoCrmUser(){
        return isMccoCrmUser(getCurrentUserProfileName());
    }
    public static Boolean isMccoCrmUser(User user){
        return isMccoCrmUser(user.Profile_Name_gne__c);
    }
    public static Boolean isMccoCrmUser(String userProfileName){
        return GNE_SFA2_MCCO_CRM_Profiles__c.getAll().containsKey(userProfileName);
    }

    public static Boolean isBamCrmUser(){
        return isBamCrmUser(getCurrentUserProfileName());
    }
    public static Boolean isBamCrmUser(String userProfileName){
        return GNE_SFA2_BAM_CRM_Profiles__c.getAll().containsKey(userProfileName);
    }
    
    public static Boolean isEsbrietCrmUser(){
        return isEsbrietCrmUser(getCurrentUserProfileName());
    }
    public static Boolean isEsbrietCrmUser(String userProfileName){
        return  getCurrentUserProfileName().toUpperCase().equals('GNE-SFA-CC-ESBRIET');
    }
    
    public static Boolean isCrmFrmUser(){
        return isCrmFrmUser(getCurrentUserProfileName());
    }    
    
    public static Boolean isCrmFrmUser(String userProfileName){
        return  getCurrentUserProfileName().toUpperCase().equals('GNE-CRM') || userProfileName.toUpperCase().equals('GNE-CRM-MANAGER');
    }

    public static Boolean isCCCrmUser(){
        return isCCCrmUser(getCurrentUserProfileName());
    }
    
    public static Boolean isCCCrmUser(String userProfileName){
        return  getCurrentUserProfileName().toUpperCase().equals('GNE-SFA-CC');
    }
    
    public static Boolean isTLSCrmUser() {
        return isTLSCrmUser(getCurrentUserProfileName());
    }
    
    public static Boolean isTLSCrmUser(String userProfileName){
        return  userProfileName.toUpperCase().equals('GNE-TLS-MANAGER') || userProfileName.toUpperCase().equals('GNE-TLS');
    }

    public static Boolean isCrmUser(){
        return isMccoCrmUser() || isBamCrmUser() || isEsbrietCrmUser() || isCCCrmUser() || isTLSCrmUser() ;
    }
    
    public static Boolean isCrmUser(String userProfileName){
        return isMccoCrmUser(userProfileName) || isBamCrmUser(userProfileName) || isEsbrietCrmUser() || isCCCrmUser(userProfileName) || isTLSCrmUser(userProfileName) ;
    }

    /*
     * This methods are used to check if user has chatter permission
     */
    public static Boolean isChatterUser(){
        Set<String> avaibleAppsSet = new Set<String>();
        for (Schema.DescribeTabSetResult sch : Schema.describeTabs()) {
            avaibleAppsSet.add(sch.getLabel());
        }
        if(avaibleAppsSet.contains('Chatter')) {
            return true;
        }
        Set<String> chatterPermissionSetNames = GNE_Chatter_Permission_Set_Name__c.getAll().keySet();
        List<PermissionSetAssignment> permissionSetAssignment = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = : UserInfo.getUserId() AND PermissionSet.Name IN : chatterPermissionSetNames];
        return !permissionSetAssignment.isEmpty() ? true : false;
    }

    /*
     * This methods are used to check if user has chatter free profile
     */
    public static Boolean isChatterFreeUser(){
        return getCurrentUserProfileName().toLowerCase().contains('chatter') ? true : false;
    }

    /*
     * This methods are used to check if profile has access to chatter
     */
    public static Boolean isUserHasAccessToChatter(String profileName, String userId){
        if(profileName.contains('FRM') || profileName.contains('GNE-SFA-BAM')) {
            return true;
        } else {
            return false;
        }
    }

    /*
     * This methods are used to check if user is Medaffairs user
     */
    public static Boolean isMedAffairsUser(){
        return getCurrentUserProfileName().startsWith('GNE-MedAffairs') || getCurrentUserProfileName().equalsIgnoreCase('RCanada-SFA-MSL');
    }

    /*
    * This methods are used to check if user is FRM user
    */
    public static Boolean isFrmUser(){
        return isFrmUser(getCurrentUserProfileName());
    }

    /*
    * This methods are used to check if user is FRM user
    */
    public static Boolean isFrmUser(String profileName){
        return profileName.contains('-FRM-') || profileName.contains('GNE-CRM');
    }

    public static Boolean isSBMUser() {
        String profileName = getCurrentUserProfileName();
        return profileName.startsWithIgnoreCase('GNE-SFA-CC')
                || profileName.startsWithIgnoreCase('GNE-SFA-OCC')
                || profileName.startsWithIgnoreCase('GNE-TLS');
    }

    public static Boolean isTLSUser() {
        String profileName = getCurrentUserProfileName();
        return profileName.startsWithIgnoreCase('GNE-TLS');
    }

    public static List<User> getUserByExternalId(String extId) {
        return [SELECT Id FROM User WHERE External_ID_gne__c = :extId LIMIT 1];
    }

    public static Map<String,Schema.SObjectType> getGlobalDescribe() {
        return Schema.getGlobalDescribe();
    }

    public static Map<String, Schema.DescribeFieldResult> getFieldDescribeMap(String objectName) {
        Schema.DescribeSObjectResult sObjectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> objectFields = sObjectDescribe.fields.getMap();
        Map<String, Schema.DescribeFieldResult> sObjectFieldsDescribe = new Map<String, Schema.DescribeFieldResult>();
        for (String fName : objectFields.keySet()) {
            Schema.DescribeFieldResult fieldDescribe = objectFields.get(fName).getDescribe();
            sObjectFieldsDescribe.put(fieldDescribe.getName().toLowerCase(), fieldDescribe);
        }
        return sObjectFieldsDescribe;
    }

    public static DatabaseWithSharingExecutor getDbWithSharingExecutor() {
        if (dbWithSharingExecutor == null) {
            dbWithSharingExecutor = new DatabaseWithSharingExecutor();
        }
        return dbWithSharingExecutor;
    }

    public static DatabaseWithoutSharingExecutor getDbWithoutSharingExecutor() {
        if (dbWithoutSharingExecutor == null) {
            dbWithoutSharingExecutor = new DatabaseWithoutSharingExecutor();
        }
        return dbWithoutSharingExecutor;
    }

    public with sharing class DatabaseWithSharingExecutor {
        public DatabaseWithSharingExecutor(){}
        public List<SObject> executeQuery(String query){
            return Database.query(query);
        }
    }

    public without sharing class DatabaseWithoutSharingExecutor {
        public DatabaseWithoutSharingExecutor(){}
        public List<SObject> executeQuery(String query){
            return Database.query(query);
        }
    }

    public static String getPactUrl(){
        return GNE_SFA2_S2S_Config_Items_gne__c.getValues('PACTBaseUrl') != null ? GNE_SFA2_S2S_Config_Items_gne__c.getValues('PACTBaseUrl').Value_gne__c : '';
    }
    
    public static String getPaceUrl(){
        return GNE_SFA2_S2S_Config_Items_gne__c.getValues('PaceBaseUrl') != null ? GNE_SFA2_S2S_Config_Items_gne__c.getValues('PaceBaseUrl').Value_gne__c : '';
    }

    public static Boolean isPactUser(){
        return isFrmUser();
    }

    public static Boolean isFrmDataSteward(Id userId){
        List<PermissionSetAssignment> assigments = [ SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :FRM_DATA_STEWARD_TOOL_PERMISSION_SET and AssigneeId = :userId];
        return !assigments.isEmpty();
    }

    public static List<SelectOption> getAvailableFrmDataStewards(){
        List<SelectOption> result = new List<SelectOption>();
        for(User u : [
                SELECT Id, Name
                FROM User
                WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = :FRM_DATA_STEWARD_TOOL_PERMISSION_SET)
                AND IsActive = true
                ORDER BY Name
        ]){
            result.add(new SelectOption(u.Id, u.Name));
        }
        return result;
    }

    /*This methods works only in visualforce context. */
    private static String getUserIPAddress() {
        // True-Client-IP has the value when the request is coming via the caching integration.
        String ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
        // X-Salesforce-SIP has the value when no caching integration or via secure URL.
        if (String.isBlank(ipAddress)) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        } // get IP address when no caching (sandbox, dev, secure urls)
        if (String.isBlank(ipAddress)) {
            ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
        } // get IP address from standard header if proxy in use
        return ipAddress;
    }

    public static Boolean isUserConnectedToCorporateNetwork() {
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues('IpRanges') == null){
            return true;
        }
        String ipRanges = GNE_Foun_Misc_Config_Items_gne__c.getValues('IpRanges').Configuration_Value_gne__c;
        String userIp = getUserIPAddress();
        if(String.isNotBlank(ipRanges)){
            for(String ipRange : ipRanges.split(';')){
                List<String> ipAddresses = ipRange.split('-');
                if(isIpAddressInRange(ipAddresses.get(0), ipAddresses.get(1), userIp)){
                    return true;
                }
            }
        }
        return false;
    }

    private static Long ipToLong(String ipAddress) {
        List<String> ipAddressInArray = ipAddress.split('\\.');
        Double result = 0;
        for (Integer i = 0; i < ipAddressInArray.size(); i++) {

            Integer power = 3 - i;
            Integer ip = Integer.valueOf(ipAddressInArray[i]);
            result += ip * Math.pow(256, power);
        }
        return result.longValue();
    }

    private static Boolean isIpAddressInRange(String startIp, String endIp, String ip){
        Long ipLo = ipToLong(startIp);
        Long ipHi = ipToLong(endIp);
        Long ipToTest = ipToLong(ip);
        return (ipToTest >= ipLo && ipToTest <= ipHi);
    }

    /*
    * Method is useful to switch off trigger during some creating testd data in test
    * or during some administrator's operations in DB
    */
    public static void updateAdminSetings(Boolean adminMode) {
        List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [
                SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c
                FROM GNE_SFA2_Admin_Mode__c
                WHERE SetupOwnerId =: UserInfo.getUserId()  LIMIT 1
        ];

        if (adminModeSetting.isEmpty()) {
            insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = UserInfo.getUserId() , GNE_SFA2_Is_Admin_Mode__c = adminMode);
        } else {
            adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = adminMode;
            update adminModeSetting;
        }
    }

    public static Id getFrmHcoAccountRecordTypeId(){
        return [SELECT Id, DeveloperName FROM RecordType WHERE isActive=true AND SobjectType = 'Account' AND DeveloperName = :GNE_SFA2_Account_Trigger_Helper.REC_TYPE_FRM_HCO].Id;
    }

    public static Boolean isCanadaMSL() {
        Set<String> mslProfiles = new Set<String> {'RCanada-SFA-MSL'};
        if(mslProfiles.contains(GNE_SFA2_Util.getCurrentUserProfileName())) {
            return true;
        }
        return false;
    }

    public static Boolean isCanadaRAMA() {
        if(getCurrentUserProfileName() == 'RCanada-SFA-RAMA') {
            return true;
        }
        return false;
    }

    public static Boolean isPREPUser() {
        if(getCurrentUserProfileName().startsWithIgnoreCase('GNE-SFA-PREP-')) {
            return true;
        }
        return false;
    }
    
    public static Map<Id, Id> getTerritoriesGroups(Set<Id> territoryIds) {
        Map<Id, Id> terrGroupMapping = new Map<Id, Id>();
        for (Territory_Group_Mapping_gne__c mapping : [SELECT Group_Id_gne__c, Territory_Id_gne__c FROM Territory_Group_Mapping_gne__c WHERE Territory_Id_gne__c IN :territoryIds AND Type_gne__c = :GNE_SFA2_Territory2_Trigger_Logic.TERRITORY_GROUP_TYPE]) {
            terrGroupMapping.put(mapping.Territory_Id_gne__c, mapping.Group_Id_gne__c);
        }
        return terrGroupMapping;
    }
    
    public static Id getTerritoryGroup(Id territoryId) {
        List<Territory_Group_Mapping_gne__c> mappings = [SELECT Group_Id_gne__c, Territory_Id_gne__c FROM Territory_Group_Mapping_gne__c WHERE Territory_Id_gne__c = :territoryId AND Type_gne__c = :GNE_SFA2_Territory2_Trigger_Logic.TERRITORY_GROUP_TYPE];
        if (mappings.isEmpty()) {
            return null;
		} 
        return mappings.get(0).Group_Id_gne__c;
    }
}