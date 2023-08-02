@isTest
private class GNE_SFA2_List_View_Util_Test {
    static Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();

    @isTest
    static void test_getUserPreferences(){
        User afrmManager = GNE_FRM_TestUtilities.createUser('frmManager', ids2ProfilesMap.get('GNE-Field'), true); 
        
        System.runAs(afrmManager){
            GNE_SFA2_List_View_Util.getUserPreferences('My Accounts');
        }
        SFA2_View_Config_gne__c viewConfig = new SFA2_View_Config_gne__c(
            Object_Type_gne__c = 'Account',
            Records_Visibility__c = 'All Records',
            Page_Name_gne__c = 'My Accounts',
            View_Name_gne__c = 'My HCO Accounts'
        );
        insert viewConfig;
        SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c(
            User_gne__c = afrmManager.Id,
            Last_View_Used_gne__c = viewConfig.Id
        );
        insert userPref;
        SFA2_User_Preferences_gne__c testUserPref;
        System.runAs(afrmManager){
            Test.startTest();
            	testUserPref = GNE_SFA2_List_View_Util.getUserPreferences('My Accounts');
            Test.stopTest();
        }
        System.assertEquals(userPref.Id, testUserPref.Id);    
    }
    
    @isTest
    static void test_updateViewPreference() {
        User afrmManager = GNE_FRM_TestUtilities.createUser('frmManager', ids2ProfilesMap.get('GNE-Field'), true); 
        SFA2_View_Config_gne__c viewConfig = new SFA2_View_Config_gne__c(
            Object_Type_gne__c = 'Account',
            Records_Visibility__c = 'All Records',
            Page_Name_gne__c = 'My Accounts',
            View_Name_gne__c = 'My HCO Accounts'
        );
        insert viewConfig;
        SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c(
            User_gne__c = afrmManager.Id,
            Last_View_Used_gne__c = viewConfig.Id
        );
        insert userPref;
        Boolean updateSuccesed;
        
        System.runAs(afrmManager){
            Test.startTest();
            	updateSuccesed = GNE_SFA2_List_View_Util.updateViewPreference(viewConfig.Id, 'My Accounts');
            Test.stopTest();
        }     
        System.assertEquals(true, updateSuccesed);  
    }
    
    @isTest
    static void test_getViews() {
        User afrmManager = GNE_FRM_TestUtilities.createUser('frmManager', ids2ProfilesMap.get('GNE-Field'), true); 
        List<SFA2_View_Config_gne__c> listViews;
        GNE_SFA2_User_App_Context_gne__c userContext = new GNE_SFA2_User_App_Context_gne__c(App_Name_gne__c = 'SFA-US', Brand_gne__c = 'Rheumatoid', Role_gne__c = 'CC');
        insert userContext;

        System.runAs(afrmManager){
            Test.startTest();
            	listViews = GNE_SFA2_List_View_Util.getViews('Account', 'My Accounts', userContext);
            Test.stopTest();
        }  
        System.assertEquals(0, listViews.size());  
    }
    
    @isTest
    static void test_getLastSeenOrFirstAvailableView() { 
        User afrmManager = GNE_FRM_TestUtilities.createUser('frmManager', ids2ProfilesMap.get('GNE-Field'), true); 
        SFA2_View_Config_gne__c viewConfig = new SFA2_View_Config_gne__c(
            Object_Type_gne__c = 'Account',
            Records_Visibility__c = 'All Records',
            Page_Name_gne__c = 'My Accounts',
            View_Name_gne__c = 'My HCO Accounts'
        );
        insert viewConfig;
        SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c(
            User_gne__c = afrmManager.Id,
            Last_View_Used_gne__c = viewConfig.Id
        );
        insert userPref;
        SFA2_View_Config_gne__c testRecord;

        System.runAs(afrmManager){
            Test.startTest();
            	testRecord = GNE_SFA2_List_View_Util.getLastSeenOrFirstAvailableView(new List<SFA2_View_Config_gne__c>{viewConfig}, userPref);
            Test.stopTest();
        }   
        
        System.assertEquals(viewConfig.Id, testRecord.Id);  
    }
    
    @isTest
    static void test_prepareSelectOptions() {//List<SFA2_View_Config_gne__c> views
        User afrmManager = GNE_FRM_TestUtilities.createUser('frmManager', ids2ProfilesMap.get('GNE-Field'), true); 
        SFA2_View_Config_gne__c viewConfig = new SFA2_View_Config_gne__c(
            Object_Type_gne__c = 'Account',
            Records_Visibility__c = 'All Records',
            Page_Name_gne__c = 'My Accounts',
            View_Name_gne__c = 'My HCO Accounts'
        );
        insert viewConfig;
        SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c(
            User_gne__c = afrmManager.Id,
            Last_View_Used_gne__c = viewConfig.Id
        );
        insert userPref;
        List<SelectOption> testListOpts;

        System.runAs(afrmManager){
            Test.startTest();
            	testListOpts = GNE_SFA2_List_View_Util.prepareSelectOptions(new List<SFA2_View_Config_gne__c>{viewConfig});
            Test.stopTest();
        } 
        
        System.assertEquals(1, testListOpts.size());  
    }
    
    @isTest
    static void test_getFiltersBySelectedView() {//SFA2_View_Config_gne__c selectedView, GNE_SFA2_List_View_Base_Controller baseListController
        //GNE_SFA2_List_View_Base_Controller baseListController = new GNE_SFA2_List_View_Base_Controller();
    }
}