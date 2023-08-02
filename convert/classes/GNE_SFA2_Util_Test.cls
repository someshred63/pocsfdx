/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-02-26
*  Description: This is a test class for GNE_SFA2_Util class.
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
@isTest
private class GNE_SFA2_Util_Test {
    private static Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();

    public static testMethod void test_switchAllAdminMode() {
        system.assertEquals(null, GNE_SFA2_ALL_Admin_Mode__c.getInstance('GNE_SFA2_ALL_Admin_Mode'));
        GNE_SFA2_Util.switchAllAdminMode(false);
        system.assertEquals(false, GNE_SFA2_ALL_Admin_Mode__c.getInstance('GNE_SFA2_ALL_Admin_Mode').GNE_SFA2_ALL_Admin_Mode__c);
        GNE_SFA2_Util.switchAllAdminMode(true);
        system.assertEquals(true, GNE_SFA2_ALL_Admin_Mode__c.getInstance('GNE_SFA2_ALL_Admin_Mode').GNE_SFA2_ALL_Admin_Mode__c);
    }

    public static testMethod void test_isAdminMode() {
        system.assertEquals(false, GNE_SFA2_Util.isAdminMode('test'));
        GNE_SFA2_Util.stopSkipingTrigger('test');
        system.assertEquals(false, GNE_SFA2_Util.isAdminMode('test'));
        GNE_SFA2_Util.skipTrigger('test');
        system.assertEquals(true, GNE_SFA2_Util.isAdminMode('test'));
        system.assertEquals(false, GNE_SFA2_Util.isAdminMode('test2'));
        GNE_SFA2_Util.skipTrigger('test2');
        GNE_SFA2_Util.stopSkipingTrigger('test');
        system.assertEquals(false, GNE_SFA2_Util.isAdminMode('test'));
        system.assertEquals(true, GNE_SFA2_Util.isAdminMode('test2'));

        system.assertEquals(false, GNE_SFA2_Util.isAdminMode());
        system.assertEquals(0, [SELECT COUNT() FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId =: UserInfo.getUserId()]);
        GNE_SFA2_Util.switchAdminMode(true);
        system.assertEquals(true, GNE_SFA2_Util.isAdminMode());
        GNE_SFA2_Util.switchAdminMode(false);
        system.assertEquals(false, GNE_SFA2_Util.isAdminMode());
    }

    public static testMethod void test_isMergeMode(){
        system.assertEquals(false, GNE_SFA2_Util.isMergeMode());
        insert new GNE_SFA2_Merge_Mode_gne__c(SetupOwnerId = UserInfo.getUserId(), GNE_SFA2_Is_Merge_Mode__c = true);
        system.assertEquals(true, GNE_SFA2_Util.isMergeMode());
    }

    public static testMethod void test_switchMergeMode() {
        test.startTest();
            GNE_SFA2_Util.switchMergeMode(true);
            system.assertEquals(true, GNE_SFA2_Merge_Mode_gne__c.getInstance().GNE_SFA2_Is_Merge_Mode__c);

            Merge_Type_gne__c mergeType = new  Merge_Type_gne__c( Name = 'Account', object_name_gne__c = 'Account', region_code_gne__c = 2, OwnerId = UserInfo.getUserId());
            insert mergeType;
            Merge_Type_Apex_Job_gne__c mergeTypeApexJob = new Merge_Type_Apex_Job_gne__c(Merge_Type_ref_gne__c = mergeType.Id, Apex_Job_Type_gne__c = 'Merge', Completed_gne__c = false);
            insert mergeTypeApexJob;
            GNE_SFA2_Util.switchMergeMode(false);
            system.assertEquals(true, GNE_SFA2_Merge_Mode_gne__c.getInstance().GNE_SFA2_Is_Merge_Mode__c);

            mergeTypeApexJob.Completed_gne__c = true;
            update mergeTypeApexJob;
            GNE_SFA2_Util.switchMergeMode(false);
            system.assertEquals(false, GNE_SFA2_Merge_Mode_gne__c.getInstance().GNE_SFA2_Is_Merge_Mode__c);
        test.stopTest();
    }

    public static testMethod void test_disableTrigger(){
        system.assertEquals(null, GNE_SFA2_Trigger_Execution_Exception_gne__c.getValues(UserInfo.getOrganizationId()));
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Account_Plan_Trigger',true);
        system.assertEquals(false, GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_Account_Plan_Trigger'));
        system.assertEquals(true, GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_Account_Plan_Trigger__c'));
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Account_Plan_Trigger',false);
        system.assertEquals(false, GNE_SFA2_Util.isTriggerDisabled('test__c'));
        GNE_SFA2_Trigger_Execution_Exception_gne__c triggerSettings = GNE_SFA2_Trigger_Execution_Exception_gne__c.getValues(UserInfo.getOrganizationId());
        triggerSettings.None__c=true;
        update triggerSettings;
        system.assertEquals(true, GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_Account_Plan_Trigger'));
        system.assertEquals(true, GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_Account_Plan_Trigger__c'));
    }

    public static testMethod void test_isPermitted(){
        system.assertEquals(true, GNE_SFA2_Util.isPermitted(UserInfo.getUserId(), 'PermissionsViewAllData'));
    }

    public static testMethod void test_createInListForQuery(){
        Id userId = UserInfo.getUserId();
        Id profileId = UserInfo.getProfileId();
        String emptyList = '(\'\')';
        String idList = '(\'' + (String)userId + '\', \'' + (String)profileId + '\')';
        String idListNotEscaped = '(\'\\\'' + (String)userId + '\\\'\', \'\\\'' + (String)profileId + '\\\'\')';

        system.assertEquals(emptyList, GNE_SFA2_Util.createInListForQuery(new Set<Id>()));
        Set<Id> setId = new Set<Id>{userId, profileId};
        String setResult = GNE_SFA2_Util.createInListForQuery(setId);
        system.assert(setResult.startsWith('('));
        system.assert(setResult.endsWith(')'));
        system.assert(setResult.contains('\'' + (String)userId + '\'') );
        system.assert(setResult.contains('\'' + (String)profileId + '\'') );
        system.assert(setResult.contains(', ') );

        system.assertEquals(emptyList, GNE_SFA2_Util.createInListForQuery(new List<Id>()));
        List<Id> listId = new List<Id>{userId, profileId};
        system.assertEquals(idList, GNE_SFA2_Util.createInListForQuery(listId));

        system.assertEquals(emptyList, GNE_SFA2_Util.createInListForQuery(new List<String>()));
        List<String> listString = new List<String>{ userId, profileId };
        system.assertEquals(idList, GNE_SFA2_Util.createInListForQuery(listString));


        system.assertEquals(emptyList, GNE_SFA2_Util.createInListForQueryNotEscaping(new List<String>()));
        system.assertEquals(idList, GNE_SFA2_Util.createInListForQueryNotEscaping(listString));
        List<String> unescapedList = new List<String>{'\'' + userId + '\'', '\'' + profileId + '\''};
        system.assertEquals(idListNotEscaped, GNE_SFA2_Util.createInListForQueryNotEscaping(unescapedList));
    }

    public static testMethod void test_getCurrentUserProfileName(){
        String profileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        system.assertEquals(profileName, GNE_SFA2_Util.getCurrentUserProfileName());
        system.assertEquals(profileName, GNE_SFA2_Util.getCurrentUserProfileName());
    }

    public static testMethod void test_isSFA2User(){
        system.assertEquals(false, GNE_SFA2_Util.isSFA2User());
        system.assertEquals(false, GNE_SFA2_Util.isSFA2UserForUI());

        GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = false, SetupOwnerId = UserInfo.getUserId());
        insert appContext;
        system.assertEquals(true, GNE_SFA2_Util.isSFA2User());
        system.assertEquals(false, GNE_SFA2_Util.isSFA2UserForUI());

        appContext.Run_in_SFA2_UI_gne__c = true;
        update appContext;
        system.assertEquals(true, GNE_SFA2_Util.isSFA2User());
        system.assertEquals(true, GNE_SFA2_Util.isSFA2UserForUI());

        appContext.SFA2_Mode_gne__c = false;
        update appContext;
        system.assertEquals(false, GNE_SFA2_Util.isSFA2User());
        system.assertEquals(false, GNE_SFA2_Util.isSFA2UserForUI());
    }

    public static testMethod void testIsCanadaUser(){
        system.assertEquals(false, GNE_SFA2_Util.isCanadaUser());
        Profile userProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
        GNE_SFA2_Canadian_Users__c prof = new GNE_SFA2_Canadian_Users__c(Name = userProfile.Name);
        insert prof;
        system.assertEquals(true, GNE_SFA2_Util.isCanadaUser());
    }

    public static testMethod void testSelectSFA2User(){
        system.assertNotEquals(null, GNE_SFA2_Util.selectSFA2User());
    }

    /*public static testMethod void testInsertProfileNamesCustomSettings(){
        Integer prefixesCountBefore = [SELECT Count() FROM GNE_SFA2_All_Profiles_Prefix__c];
        GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('testPrefix');
        Integer prefixesCountAfter = [SELECT Count() FROM GNE_SFA2_All_Profiles_Prefix__c];
        system.assertEquals(prefixesCountBefore + 1, prefixesCountAfter);

        system.assert(GNE_SFA2_Canadian_Users__c.getAll().isEmpty(), 'this should be empty');
        GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
        Map<String, GNE_SFA2_Canadian_Users__c> canadianProfilesCustomSetting = GNE_SFA2_Canadian_Users__c.getAll();
        system.assertNotEquals(null, canadianProfilesCustomSetting);
        Set<String> keySet = canadianProfilesCustomSetting.keySet();
        system.assert(keySet.contains('RCanada-SFA-Manager'),'Canadian profile not found');
        system.assert(keySet.contains('RCanada-SFA-MSL'),'Canadian profile not found');
        system.assert(keySet.contains('RCanada-SFA-MSL-Manager'),'Canadian profile not found');
        system.assert(keySet.contains('RCanada-SFA-Ops'),'Canadian profile not found');
        system.assert(keySet.contains('RCanada-SFA-ReadOnly'),'Canadian profile not found');
        system.assert(keySet.contains('RCanada-SFA-TS'),'Canadian profile not found');
        system.assert(keySet.contains('RCanada-SYS-AutomatedJob'),'Canadian profile not found');

        system.assert(GNE_SFA2_MCCO_Profiles__c.getAll().isEmpty(), 'this should be empty');
        GNE_SFA2_Util.insertMCCOProfileNamesCustomSetting();
        Map<String, GNE_SFA2_MCCO_Profiles__c> mccoProfilesCustomSetting = GNE_SFA2_MCCO_Profiles__c.getAll();
        system.assertNotEquals(null, mccoProfilesCustomSetting);
        keySet = mccoProfilesCustomSetting.keySet();
        //system.assert(keySet.contains('GNE-MCCO PFT'),'MCCO profile not found');
        //system.assert(keySet.contains('GNE-MCCO-CFT'),'MCCO profile not found');
        //system.assert(keySet.contains('GNE-MCCO-EFT'),'MCCO profile not found');
        system.assert(keySet.contains('GNE-MCCO-FRM-AFRM-nonSSO'),'MCCO profile not found');
        system.assert(keySet.contains('GNE-MCCO-FRM-BFRM'),'MCCO profile not found');
        system.assert(keySet.contains('GNE-MCCO-FRM-EFRM'),'MCCO profile not found');
        system.assert(keySet.contains('GNE-MCCO-FRM-GFRM'),'MCCO profile not found');
        system.assert(keySet.contains('GNE-MCCO-FRM-IFRM'),'MCCO profile not found');
        system.assert(keySet.contains('GNE-MCCO-FRM-RFRM'),'MCCO profile not found');
    }*/

    public static testMethod void testCountCustomSettings(){
        GNE_SFA2_User_Count_Notification__c userCountCustomSetting = GNE_SFA2_User_Count_Notification__c.getInstance();
        GNE_SFA2_User_Max_Count__c userMaxCountCustomSetting = GNE_SFA2_User_Max_Count__c.getInstance();
        GNE_SFA2_User_Notification_Email__c notificationEmailCustomSetting = GNE_SFA2_User_Notification_Email__c.getInstance();
        system.assertEquals(null, userCountCustomSetting.User_count__c);
        system.assertEquals(null, userMaxCountCustomSetting.User_count__c);
        system.assertEquals(null, notificationEmailCustomSetting.Email__c);

        try{
            GNE_SFA2_Util.insertUserCountNotificationCustomSettings(2, 3, 'test');
            system.assert(false, 'This line should not be reached due to validation');
        } catch(DmlException ex){
            system.assertEquals('INVALID_EMAIL_ADDRESS', ex.getDmlStatusCode(0));
        }

        GNE_SFA2_Util.insertUserCountNotificationCustomSettings(2, 3, 'test@roche.com');

        userCountCustomSetting = [SELECT Name, User_count__c FROM GNE_SFA2_User_Count_Notification__c LIMIT 1];
        system.assertEquals('Default', userCountCustomSetting.Name);
        system.assertEquals(2, userCountCustomSetting.User_count__c);

        userMaxCountCustomSetting = [SELECT Name, User_count__c FROM GNE_SFA2_User_Max_Count__c LIMIT 1];
        system.assertEquals('Default', userMaxCountCustomSetting.Name);
        system.assertEquals(3, userMaxCountCustomSetting.User_count__c);

        notificationEmailCustomSetting = [SELECT Name, Email__c FROM GNE_SFA2_User_Notification_Email__c LIMIT 1];
        system.assertEquals('Default', notificationEmailCustomSetting.Name);
        system.assertEquals('test@roche.com', notificationEmailCustomSetting.Email__c);
    }

    public static testMethod void testSortList(){
        List<Account> listToSort = new List<Account>();
        listToSort.add(new Account(Name = 'aTest'));
        listToSort.add(new Account(Name = 'eTest'));
        listToSort.add(new Account(Name = 'dTest'));
        listToSort.add(new Account(Name = 'cTest'));
        listToSort.add(new Account(Name = 'bTest'));

        GNE_SFA2_Util.sortList(listToSort, 'Name', true);
        system.assertEquals('aTest', listToSort[0].Name);
        system.assertEquals('bTest', listToSort[1].Name);
        system.assertEquals('cTest', listToSort[2].Name);
        system.assertEquals('dTest', listToSort[3].Name);
        system.assertEquals('eTest', listToSort[4].Name);

        GNE_SFA2_Util.sortList(listToSort, 'Name', false);
        system.assertEquals('eTest', listToSort[0].Name);
        system.assertEquals('dTest', listToSort[1].Name);
        system.assertEquals('cTest', listToSort[2].Name);
        system.assertEquals('bTest', listToSort[3].Name);
        system.assertEquals('aTest', listToSort[4].Name);

        List<SelectOption> selectOptionToSort = new List<SelectOption>();
        GNE_SFA2_Util.sortOptionList(selectOptionToSort);
        selectOptionToSort.add(new SelectOption('eValue', 'dLabel'));
        selectOptionToSort.add(new SelectOption('aValue', '--None--' ));
        selectOptionToSort.add(new SelectOption('dValue', 'cLabel'));
        selectOptionToSort.add(new SelectOption('--None--', 'aLabel'));
        selectOptionToSort.add(new SelectOption('bValue', 'eLabel'));
        selectOptionToSort.add(new SelectOption('cValue', 'bLabel'));

        selectOptionToSort = GNE_SFA2_Util.sortOptionList(selectOptionToSort);

        system.assertEquals('--None--', selectOptionToSort[0].getLabel());
        system.assertEquals('aValue', selectOptionToSort[0].getValue());

        system.assertEquals('aLabel', selectOptionToSort[1].getLabel());
        system.assertEquals('--None--', selectOptionToSort[1].getValue());

        system.assertEquals('bLabel', selectOptionToSort[2].getLabel());
        system.assertEquals('cValue', selectOptionToSort[2].getValue());

        system.assertEquals('cLabel', selectOptionToSort[3].getLabel());
        system.assertEquals('dValue', selectOptionToSort[3].getValue());

        system.assertEquals('dLabel', selectOptionToSort[4].getLabel());
        system.assertEquals('eValue', selectOptionToSort[4].getValue());

        system.assertEquals('eLabel', selectOptionToSort[5].getLabel());
        system.assertEquals('bValue', selectOptionToSort[5].getValue());
    }

    public static testMethod void testUIComponents(){
    	system.assertEquals(GNE_SFA2_User_App_Context_gne__c.getInstance(), GNE_SFA2_Util.getUserApplicationContext());
        insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = false, SetupOwnerId = UserInfo.getUserId());
        String objectName = 'testName';
        String componentType = 'testButtons';
        String configType = 'List Page';
        String attributes = 'action=test;styleClass=test;dir=test;onclick=test;rerender=test1,test2;immediate=true;';
        String attributes2 = 'immediate=false;';
        SFA2_Configuration_Object_gne__c master = GNE_SFA2_Triggers_Test_Util.prepareSFA2_Configuration_Object_gne();
        master.Object_Name_gne__c = objectName;
        master.Configuration_Type_gne__c = configType;
        master.Is_Active_gne__c = true;
        insert master;

        List<SFA2_Configuration_Object_Detail_gne__c> details = new List<SFA2_Configuration_Object_Detail_gne__c>();
        details.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'true', Is_Read_Only_gne__c = true,
                                                                Type_gne__c = componentType, Configuration_Object_ref_gne__c = master.Id,
                                                                Is_Active_gne__c = true
                                                                )
                    );
        details.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'false', Is_Read_Only_gne__c = false,
                                                                Type_gne__c = componentType, Configuration_Object_ref_gne__c = master.Id,
                                                                Is_Active_gne__c = true, Attributes_gne__c = attributes2
                                                                )
                    );
        details.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'false', Is_Read_Only_gne__c = false,
                                                                Type_gne__c = componentType, Configuration_Object_ref_gne__c = master.Id,
                                                                Is_Active_gne__c = true, Label_gne__c ='label', Attributes_gne__c = attributes
                                                                )
                    );
        insert details;

        Map<String, Boolean> result = GNE_SFA2_Util.getUiComponentsVisibility(componentType, objectName);
        system.assertNotEquals(null, result);
        system.assertEquals(true, result.get('true'));
        system.assertEquals(false, result.get('false'));

        List<SFA2_Configuration_Object_Detail_gne__c> result2 = GNE_SFA2_Util.getUIComponentsConfiguration(objectName, configType, componentType);
        system.assertEquals(3, result2.size());
        Component.Apex.PageBlockButtons pbb = GNE_SFA2_Util.getCustomButtons(objectName, configType, componentType);
        system.assertEquals('top', pbb.location);
        system.assertNotEquals(null, pbb.childComponents);
        system.assertNotEquals(null, GNE_SFA2_Util.getListPageConfiguration(objectName));

        master.Role_gne__c = 'test';
        update master;
        result2 = GNE_SFA2_Util.getUIComponentsConfiguration(objectName, configType, componentType);
        system.assertEquals(0, result2.size());
        pbb = GNE_SFA2_Util.getCustomButtons(objectName, configType, componentType);
        system.assertEquals('top', pbb.location);
        List<Component.Apex.CommandButton> test = new List<Component.Apex.CommandButton>();
        system.assertEquals(test, pbb.childComponents);
        system.assertEquals(null, GNE_SFA2_Util.getListPageConfiguration(objectName));
    }

    public static testMethod void testGetAddress(){
    	String resultAll = 'addrName addrLine2, city, state zip-zip4';
    	system.assert(resultAll.equalsIgnoreCase(GNE_SFA2_Util.getAddressAsString('addrName', 'addrLine2', 'city', 'state', 'zip', 'zip4')));
    	Address_vod__c addr = new Address_vod__c( Name 					= 'addrName',
    											  Address_Line_2_vod__c = 'addrLine2',
    											  City_vod__c 			= 'city',
    											  State_vod__c 			= 'state',
    											  Zip_vod__c 			= 'zip',
    											  Zip_4_vod__c 			= 'zip4',
    											  Province_can_gne__c 	= null,
    											  Postal_Code_can_gne__c= null
    											);
    	system.assert(resultAll.equalsIgnoreCase(GNE_SFA2_Util.getAddressAsString(addr)));
    	String resultCan = 'addrName addrLine2, city, province postal';
    	Address_vod__c addrCan = new Address_vod__c(Name 					= 'addrName',
    											  	Address_Line_2_vod__c 	= 'addrLine2',
    											  	City_vod__c 			= 'city',
    											  	State_vod__c 			= null,
    											  	Zip_vod__c 				= null,
    											  	Zip_4_vod__c 			= 'zip4',
    											  	Province_can_gne__c 	= 'province',
    											  	Postal_Code_can_gne__c 	= 'postal'
    											);
    	system.assert(resultCan.equalsIgnoreCase(GNE_SFA2_Util.getAddressAsString(addrCan)));
    }

    public static testMethod void testSalesRoster(){
    	insert new GNE_SFA2_User_App_Context_gne__c(Name = UserInfo.getUserId(), SFA2_Mode_gne__c = true, Run_in_SFA2_UI_gne__c = false, SetupOwnerId = UserInfo.getUserId(), Brand_gne__c = 'diff');
    	List<SFA2_User_Sales_Roster_gne__c> rosters = new List<SFA2_User_Sales_Roster_gne__c>();
    	system.assertEquals(0, GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId()).size());
    	system.assertEquals(0, GNE_SFA2_Util.getUserSalesRostersForCurrentApp(UserInfo.getUserId()).size());
    	system.assertEquals(null, GNE_SFA2_Util.getUserBrandName(GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId())));
    	List<IC_Calc_Sales_Roster_gne__c> masters = new List<IC_Calc_Sales_Roster_gne__c>();
    	masters.add(new IC_Calc_Sales_Roster_gne__c(Runs_in_SFA2_Mode_gne__c = true, Is_SFA2_Available_gne__c = true));
    	masters.add(new IC_Calc_Sales_Roster_gne__c(Runs_in_SFA2_Mode_gne__c = true, Is_SFA2_Available_gne__c = true, Brand_Name_gne__c = 'diff'));
    	insert masters;

    	rosters.add(new SFA2_User_Sales_Roster_gne__c(	User_gne__c = UserInfo.getUserId(),
    													Is_Active_gne__c = true,
    													Sales_Roster_gne__c = masters[0].Id
   													));
    	rosters.add(new SFA2_User_Sales_Roster_gne__c(	User_gne__c = UserInfo.getUserId(),
    													Is_Active_gne__c = true,
    													Sales_Roster_gne__c = masters[1].Id
   													));
    	insert rosters;
    	system.assertEquals(2, GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId()).size());
    	system.assertEquals('_diff', GNE_SFA2_Util.getUserBrandName(GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId())));
    	system.assertEquals(1, GNE_SFA2_Util.getUserSalesRostersForCurrentApp(UserInfo.getUserId()).size());
    	system.assertEquals('diff', GNE_SFA2_Util.getUserBrandName(GNE_SFA2_Util.getUserSalesRostersForCurrentApp(UserInfo.getUserId())));
    	masters[0].Brand_Name_gne__c = 'different';
    	masters[1].Brand_Name_gne__c = 'temp';
    	update masters;
    	system.assertEquals(2, GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId()).size());
    	system.assertEquals('different_temp', GNE_SFA2_Util.getUserBrandName(GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId())));
    	system.assertEquals(0, GNE_SFA2_Util.getUserSalesRostersForCurrentApp(UserInfo.getUserId()).size());
    	system.assertEquals(null, GNE_SFA2_Util.getUserBrandName(GNE_SFA2_Util.getUserSalesRostersForCurrentApp(UserInfo.getUserId())));

    	system.assertEquals(GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId()), GNE_SFA2_Util.getBrandRoleAppType(UserInfo.getUserId()));
    }

    public static testMethod void testRedirect(){
    	String message = 'message';
    	String currentUrl = 'url';
    	String devMsg = 'developerMessage';
    	String retUrl = 'retUrl';
    	PageReference pr = GNE_SFA2_Util.redirectToErrorPage(message, currentUrl, devMsg);
    	system.assertEquals(message, pr.getParameters().get('exMessage'));
    	system.assertEquals(currentUrl, pr.getParameters().get('exUrl'));
    	system.assertEquals(devMsg, pr.getParameters().get('developerMessage'));
    	system.assertEquals(true, pr.getRedirect());
    	system.assertEquals(Page.GNE_SFA2_Exception_Layout.getUrl(), pr.getUrl().split('\\?')[0]);

    	pr.getParameters().put('retURL', retUrl);
    	Test.setCurrentPage(pr);
    	PageReference accDenied = GNE_SFA2_Util.redirectToAccessDeniedPage();
    	system.assertEquals(retUrl, accDenied.getParameters().get('retURL'));
    	system.assertEquals(true, accDenied.getRedirect());
    	system.assertEquals(Page.GNE_SFA2_Access_Denied.getUrl(), accDenied.getUrl().split('\\?')[0]);
    }

    public static testMethod void testGetRecordType(){
    	String objectName = 'Account';
    	String applicationType = 'SFA-US';
    	String brand = 'Actemra';
    	String role = 'CS';
    	String recType = 'HCP';

    	system.assertEquals('', GNE_SFA2_Util.getDefaultRecordType(objectName, applicationType, brand, role));
    	SFA2_Configuration_Object_gne__c conf = GNE_SFA2_Triggers_Test_Util.prepareSFA2_Configuration_Object_gne();
        conf.Object_Name_gne__c = objectName;
        conf.Application_Type__c = applicationType;
        conf.Is_Active_gne__c = true;
        conf.Brand_gne__c = brand;
        conf.Role_gne__c = role;
        conf.Is_Default_Record_Type_gne__c = true;
        conf.Record_Type_gne__c = recType;
        insert conf;
        system.assertEquals(recType, GNE_SFA2_Util.getDefaultRecordType(objectName, applicationType, brand, role));

        IC_Calc_Sales_Roster_gne__c master = new IC_Calc_Sales_Roster_gne__c(Brand_Name_gne__c = null,
        																	 Type_gne__c = applicationType);
    	insert master;
    	SFA2_User_Sales_Roster_gne__c userSales = new SFA2_User_Sales_Roster_gne__c(Sales_Roster_gne__c = master.Id, Role_gne__c = role);
    	insert userSales;
    	userSales = [SELECT Sales_Roster_gne__r.Type_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Role_gne__c
    				 FROM SFA2_User_Sales_Roster_gne__c WHERE Id = :userSales.Id LIMIT 1
    				];
    	system.assertEquals('', GNE_SFA2_Util.getDefaultRecordType(objectName, userSales));
    	master.Brand_Name_gne__c=brand;
    	update master;
    	userSales = [SELECT Sales_Roster_gne__r.Type_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Role_gne__c
    				 FROM SFA2_User_Sales_Roster_gne__c WHERE Id = :userSales.Id LIMIT 1
    				];
    	system.assertEquals(recType, GNE_SFA2_Util.getDefaultRecordType(objectName, userSales));
    }

    public static testMethod void testGetEnvironment(){
    	Profile p = [SELECT Id FROM Profile LIMIT 1];
        User u = new User(
          	FirstName = 'John',
          	Alias = 'test',
          	Email = 'testuser@gene.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Brown',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'ENVtestuserPP@gene.com'
        );
        insert u;
        system.runAs(u){
        	system.assertEquals('prod', GNE_SFA2_Util.getEnvironment());
        }

        u = new User(
          	FirstName = 'John',
          	Alias = 'test',
          	Email = 'testuser@gene.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Brown',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'ENVtestuserPP@gene.com.dev'
        );
        insert u;
        system.runAs(u){
        	system.assertEquals('dev', GNE_SFA2_Util.getEnvironment());
        }

        insert new Environment_Variables__c(Key__c = 'test', Value__c = 'val', Environment__c = GNE_SFA2_Util.getEnvironment());
        system.assertEquals(GNE_SFA2_Util.getEnvironment() != '' ? 1 : 0, GNE_SFA2_Util.getAllEnvVariables('test').size());
    }

    public static testMethod void testUserRecordAccess(){
    	Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
    	insert acc;
    	system.assertEquals(null, GNE_SFA2_Util.getUserRecordAccess(null, null));
    	system.assertEquals(null, GNE_SFA2_Util.getUserRecordAccess('', null));
    	system.assertEquals(null, GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), null));
    	system.assertEquals(null, GNE_SFA2_Util.getUserRecordAccess(null, acc.Id));
    	system.assertEquals(null, GNE_SFA2_Util.getUserRecordAccess(null, ''));
    	system.assertEquals(null, GNE_SFA2_Util.getUserRecordAccess('', ''));
    	try{
			GNE_SFA2_Util.getUserRecordAccess('aaa', 'bbb');
			system.assert(false, 'this line should not be reached');
    	}catch(Exception ex){
    		system.assert(ex.getMessage().contains('List has no rows for assignment to SObject'));
    	}

    	system.assertEquals(acc.Id, GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), acc.Id).RecordId);
    }

    public static testMethod void testUserTerritories(){
		List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name LIKE 'GNE-Field' ];
		User userWithTerritory = [ 
            SELECT Id 
            FROM USER 
            WHERE ProfileId in :sfa2Profiles 
            	AND isActive = true 
            	AND Id IN (SELECT UserId FROM UserTerritory2Association WHERE  (NOT Territory2.External_id_gne__c LIKE 'INACTIVE TERRITORIES%')) LIMIT 1
        ];
		User userWithoutTerritory = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true AND Id NOT IN (SELECT UserId FROM UserTerritory2Association) LIMIT 1];
		system.assertEquals(0, GNE_SFA2_Util.getUserTerritories(userWithoutTerritory.Id).size());
		GNE_SFA2_Util.userTerritoriesMap = null;
		System.assert(GNE_SFA2_Util.getUserTerritories(userWithTerritory.Id).size() > 0);
    }

    @isTest
    private static void test_setSkipTriggersOnlyInTests() {
        Boolean value = null;
        Test.startTest();
            GNE_SFA2_Util.setSkipTriggersOnlyInTests(value);
            String testQuery = GNE_SFA2_Util.createInListForQueryNotEscaping(New Set<String>{'Test1', 'Test2'});
        Test.stopTest();

        System.assertEquals('(\'Test1\', \'Test2\')', testQuery);
    }

    @isTest
    private static void test_isBrandUser() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Boolean isBrandUser;
        Test.startTest();
            System.runAs(bfrmManager) {
                isBrandUser = GNE_SFA2_Util.isBrandUser();
            }
        Test.stopTest();
        System.assertEquals(false, isBrandUser);
    }

    @isTest
    private static void test_getDefaultRecordType() {
        String defaultRT = '';
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Practice_vod').getRecordTypeId();
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Test.startTest();
            System.runAs(bfrmManager) {
                defaultRT = GNE_SFA2_Util.getDefaultRecordType('Account');
            }
        Test.stopTest();
        System.assertEquals(devRecordTypeId, defaultRT);
    }

    @isTest
    private static void test_getUserCanDeleteRecordAccess() {
        Account account1 = GNE_FRM_TestUtilities.createAccount('Account 01', 'FRM_HCO','Clinic',true);
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Boolean canDelete;
        Test.startTest();
            System.runAs(bfrmManager) {
                canDelete = GNE_SFA2_Util.getUserCanDeleteRecordAccess(bfrmManager.Id, account1.Id);
            }
        Test.stopTest();
        System.assertEquals(false, canDelete);
    }

    @isTest
    private static void test_updateAdminSetings() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        System.runAs(bfrmManager) {
            Test.startTest();
                GNE_SFA2_Util.updateAdminSetings(true);
                GNE_SFA2_Util.updateAdminSetings(false);
            Test.stopTest();
            GNE_SFA2_Admin_Mode__c adminModeSetting = [
                SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c
                FROM GNE_SFA2_Admin_Mode__c
                WHERE SetupOwnerId =: UserInfo.getUserId()  LIMIT 1
            ];
            System.assertEquals(false, adminModeSetting.GNE_SFA2_Is_Admin_Mode__c);
        }
    }

    @isTest
    private static void test_getUserSetupProducts() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        List<Product_vod__c> prodList;
        Test.startTest();
            System.runAs(bfrmManager) {
                prodList = GNE_SFA2_Util.getUserSetupProducts(bfrmManager.Id);
            }
        Test.stopTest();
        System.assertEquals(0, prodList.size());
    }

    @isTest
    private static void test_isUserConnectedToCorporateNetwork() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Boolean isConnectedToCorporateNetwork;
        insert new GNE_Foun_Misc_Config_Items_gne__c(Name ='IpRanges', Configuration_Value_gne__c  = '198.0.0.1-198.0.0.2');
        PageReference pageRef = new PageReference('/apex/GNE_FRM_DST_MergeManagement');

        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP', '198.0.1.12');

        Test.startTest();
            System.runAs(bfrmManager) {
                isConnectedToCorporateNetwork = GNE_SFA2_Util.isUserConnectedToCorporateNetwork();
            }
        Test.stopTest();
        System.assertEquals(false, isConnectedToCorporateNetwork);
    }

    @isTest
    private static void test_findMatchingTerritories1() {
        
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), false);
        User admin = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), false);
        insert new List<User> {bfrmManager,admin};
        List<Id> accountTerritories;
        List<Territory2> userTerritories;
        Territory2 t3;
        System.runAs(admin) {
            GNE_SFA2_Util.updateAdminSetings(true);
            userTerritories = new List<Territory2>();
            Territory2 t1 = GNE_FRM_TestUtilities.createTerritory('Terr1', null, false);
            t1.External_Id_gne__c = 'Root;Terr1';
            t1.Parent_External_Id_gne__c ='Root';
            Territory2 t2 = GNE_FRM_TestUtilities.createTerritory('Terr2', null, false);
            t2.External_Id_gne__c = 'Root;Terr2';
            t2.Parent_External_Id_gne__c ='Root';
            t3 = GNE_FRM_TestUtilities.createTerritory('Terr3', null, false);
            t3.External_Id_gne__c = 'Root;Terr3';
            t3.Parent_External_Id_gne__c ='Root';
            userTerritories.add(t1);
            userTerritories.add(t2);
            userTerritories.add(t3);
            insert userTerritories;
            Territory2 childTerr = GNE_FRM_TestUtilities.createTerritory('Terr4', t3.Id, false);
            childTerr.External_Id_gne__c = 'Root;Terr3;Terr4';
            childTerr.Parent_External_Id_gne__c ='Root;Terr3';
            insert childTerr;

            SFA2_View_Config_gne__c viewConfig = new SFA2_View_Config_gne__c(
                Object_Type_gne__c = 'Account',
                Records_Visibility__c = 'All Records',
                Page_Name_gne__c = 'My Accounts',
                View_Name_gne__c = 'My HCO Accounts'
            );
            insert viewConfig;
            SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c(
                User_gne__c = bfrmManager.Id,
                Last_View_Used_gne__c = viewConfig.Id,
                Last_Territory_Used_gne__c = t3.Id,
                OwnerId = bfrmManager.Id
            );
            insert userPref;
            accountTerritories = new List<Id>{t1.Id,t3.Id};
        }
        Set<Id> result;

        Test.startTest();
            System.runAs(bfrmManager) {
                result = GNE_SFA2_Util.findMatchingTerritories(userTerritories, accountTerritories);
            }
        Test.stopTest();
        Set<Id> testData = new Set<Id>{t3.Id};
        System.assertEquals(testData, result);
    }

    @isTest
    private static void test_findMatchingTerritories2() {
        GNE_SFA2_Util.updateAdminSetings(true);
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), false);
        User admin = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), false);
        insert new List<User> {bfrmManager,admin};
        List<Id> accountTerritories;
        List<Territory2> userTerritories;
        Territory2 t3, childTerr1;
        System.runAs(admin) {
            GNE_SFA2_Util.updateAdminSetings(true);
            userTerritories = new List<Territory2>();
            Territory2 t1 = GNE_FRM_TestUtilities.createTerritory('Terr1', null, false);
            t1.External_Id_gne__c = 'Root;Terr1';
            t1.Parent_External_Id_gne__c ='Root';
            Territory2 t2 = GNE_FRM_TestUtilities.createTerritory('Terr2', null, false);
            t2.External_Id_gne__c = 'Root;Terr2';
            t2.Parent_External_Id_gne__c ='Root';
            t3 = GNE_FRM_TestUtilities.createTerritory('Terr3', null, false);
            t3.External_Id_gne__c = 'Root;Terr3';
            t3.Parent_External_Id_gne__c ='Root';
            userTerritories.add(t1);
            userTerritories.add(t2);
            userTerritories.add(t3);
            insert userTerritories;
            Territory2 childTerr = GNE_FRM_TestUtilities.createTerritory('Terr4', t3.Id, false);
            childTerr.External_Id_gne__c = 'Root;Terr3;Terr4';
            childTerr.Parent_External_Id_gne__c ='Root;Terr3';

            childTerr1 = GNE_FRM_TestUtilities.createTerritory('Terr5', t1.Id, false);
            childTerr1.External_Id_gne__c = 'Root;Terr1;Terr5';
            childTerr1.Parent_External_Id_gne__c ='Root;Terr1';
            insert new List<Territory2>{childTerr, childTerr1};

            SFA2_View_Config_gne__c viewConfig = new SFA2_View_Config_gne__c(
                Object_Type_gne__c = 'Account',
                Records_Visibility__c = 'All Records',
                Page_Name_gne__c = 'My Accounts',
                View_Name_gne__c = 'My HCO Accounts'
            );
            insert viewConfig;
            SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c(
                User_gne__c = bfrmManager.Id,
                Last_View_Used_gne__c = viewConfig.Id,
                Last_Territory_Used_gne__c = t1.Id,
                OwnerId = bfrmManager.Id
            );
            insert userPref;
            accountTerritories = new List<Id>{childTerr1.Id};
        }
        Set<Id> result;

        Test.startTest();
            System.runAs(bfrmManager) {
                result = GNE_SFA2_Util.findMatchingTerritories(userTerritories, accountTerritories);
            }
        Test.stopTest();
        Set<Id> testData = new Set<Id>{childTerr1.Id};
        System.assertEquals(testData, result);
    }

    @isTest
    private static void test_findFirstMatchForSingleTerritory1() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), false);
        User admin = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), false);
        insert new List<User> {bfrmManager,admin};

        Territory2 t1,childTerr1;
        System.runAs(admin) {
            GNE_SFA2_Util.updateAdminSetings(true);
    		Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
    		Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
            t1 = new Territory2(Name = 'GNE-US-SFA', DeveloperName = 'TEST', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, External_Id_gne__c = 'Root;GNE-US-SFA', Parent_External_Id_gne__c ='Root');
        	insert t1;
            childTerr1 = GNE_FRM_TestUtilities.createTerritory('Terr2', t1.Id, false);
            childTerr1.Salesforce_Code_gne__c = 'TEST';
            childTerr1.Salesforce_SubTeam_Code_gne__c = 'TEST';
            childTerr1.external_id_gne__c = 'Root;GNE-US-SFA;Terr2';
            childTerr1.Parent_External_Id_gne__c = 'Root;GNE-US-SFA';
            childTerr1.Territory2ModelId = terrModelId;
            childTerr1.Territory2TypeId = terrTypeId;
            insert childTerr1;
        }
        Id accountTerritoryId = childTerr1.Id;
        List<Territory2> userTerritories = new List<Territory2>{t1};

        Id result;

        Test.startTest();
            System.runAs(bfrmManager) {
                result = GNE_SFA2_Util.findFirstMatchForSingleTerritory(userTerritories, accountTerritoryId);
            }
        Test.stopTest();

        System.assertEquals(t1.Id, result);
    }

    @isTest
    private static void test_findFirstMatchForSingleTerritory2() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), false);
        User admin = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), false);
        insert new List<User> {bfrmManager,admin};

        Territory2 t1;
        System.runAs(admin) {
            GNE_SFA2_Util.updateAdminSetings(true);
    		Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
    		Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
            t1 = new Territory2(Name = 'GNE-US-SFA', DeveloperName = 'TEST', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, External_Id_gne__c = 'Root;GNE-US-SFA', Parent_External_Id_gne__c ='Root');
        	insert t1;
        }
        Id accountTerritoryId = t1.Id;
        List<Territory2> userTerritories = new List<Territory2>{t1};

        Id result;

        Test.startTest();
            System.runAs(bfrmManager) {
                result = GNE_SFA2_Util.findFirstMatchForSingleTerritory(userTerritories, accountTerritoryId);
            }
        Test.stopTest();

        System.assertEquals(accountTerritoryId, result);

    }

    @isTest
    private static void test_isOldOTRVersion() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Boolean isOldOTRVersion;
        System.runAs(bfrmManager) {
            isOldOTRVersion = GNE_SFA2_Util.isOldOTRVersion('iPhone00123_00123_00123_00123', 155);
        }
        System.assertEquals(true, isOldOTRVersion);
    }

    @isTest
    private static void test_isCrmUser() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Boolean isCrmUser;
        System.runAs(bfrmManager) {
            isCrmUser = GNE_SFA2_Util.isCrmUser();
        }
        System.assertEquals(false, isCrmUser);
    }

    @isTest
    private static void test_isChatterFreeUser() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Boolean isChatterFreeUser;
        System.runAs(bfrmManager) {
            isChatterFreeUser = GNE_SFA2_Util.isChatterFreeUser();
        }
        System.assertEquals(false, isChatterFreeUser);
    }

    @isTest
    private static void test_isFrmUser() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Boolean isFrmUser;
        System.runAs(bfrmManager) {
            isFrmUser = GNE_SFA2_Util.isFrmUser();
        }
        System.assertEquals(false, isFrmUser);
    }

    @isTest
    private static void test_getUserByExternalId() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        List<User> testUsers = new List<User>{bfrmManager};
        List<User> users;
        bfrmManager = [SELECT Id, External_ID_gne__c FROM User WHERE Id = :bfrmManager.Id];
        System.debug(bfrmManager);
        System.runAs(bfrmManager) {
            users = GNE_SFA2_Util.getUserByExternalId(bfrmManager.External_ID_gne__c);
        }
        System.assertEquals(testUsers.size(), users.size());
        System.assertEquals(testUsers[0].Id, users[0].Id);
    }

    @isTest
    private static void test_getDbWithSharingExecutor() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Account acc = new Account(Name = 'test 00001');
        insert acc;
        String query = 'SELECT Id, Name FROM Account';
        Account [] accounts;
        System.runAs(bfrmManager) {
            accounts = GNE_SFA2_Util.getDbWithoutSharingExecutor().executeQuery(query);
        }
        System.assertEquals(1, accounts.size());
    }

    @isTest
    private static void test_getDbWithoutSharingExecutor() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Account acc = new Account(Name = 'test 00001');
        insert acc;
        String query = 'SELECT Id, Name FROM Account';
        Account [] accounts;
        System.runAs(bfrmManager) {
            accounts = GNE_SFA2_Util.getDbWithSharingExecutor().executeQuery(query);
        }
        System.assertEquals(0, accounts.size());
    }

    @isTest
    private static void test_getPactUrl() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        insert new GNE_SFA2_S2S_Config_Items_gne__c(Name = 'PACTBaseUrl', Key_gne__c = 'PACTBaseUrl', Value_gne__c = 'https://genentech-pps--ppsstream1.cs41.my.salesforce.com');
        String pactUrl;
        System.runAs(bfrmManager) {
            pactUrl = GNE_SFA2_Util.getPactUrl();
        }

        System.assertEquals('https://genentech-pps--ppsstream1.cs41.my.salesforce.com', pactUrl);
    }

    @isTest
    private static void test_isPactUser() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), true);
        Boolean isPactUser;
        System.runAs(bfrmManager) {
            isPactUser = GNE_SFA2_Util.isPactUser();
        }
        System.assertEquals(false, isPactUser);
    }
}