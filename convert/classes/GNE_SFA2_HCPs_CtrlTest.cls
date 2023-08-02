@isTest
private class GNE_SFA2_HCPs_CtrlTest {
    static List<Profile> sfa2Profiles = [SELECT Id FROM Profile WHERE Name = 'GNE-FIELD' ];   
    static Map<String, Id> profile2Id = GNE_FRM_TestUtilities.getProfiles();
    
    @future
    static void futureDML(){
    	GNE_SFA2_Admin_Mode__c adminModeSetting = GNE_SFA2_Admin_Mode__c.getInstance();

        if (adminModeSetting==null) {
            adminModeSetting = new GNE_SFA2_Admin_Mode__c(SetupOwnerId = UserInfo.getUserId(), GNE_SFA2_Is_Admin_Mode__c = false);
        }

        adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = true;
        upsert adminModeSetting; 
        Territory2 territory = [Select Id, Name From Territory2 Where external_id_gne__c = 'GNE-US;SFA;0B31-NORTHWEST_2;0B312-CHICAGO-INDIANAPOLIS_2'];

        List<Account> lAccounts = new List<Account>();
        for (Integer i = 0; i < 20; i++) {
            lAccounts.add(
                new Account(FirstName = 'First#' + i, LastName = 'Last#' + i)
            );
        }
        insert lAccounts;

        List<Address_vod__c> lAddresses = new List<Address_vod__c>();
        for (Account acc : lAccounts) {
            lAddresses.add(new Address_vod__c( Account_vod__c = acc.Id));
        }
        insert lAddresses;

        List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();
        List<TSF_vod__C> lTSFs = new List<TSF_vod__C>();

        for (Integer i = 0; i < lAccounts.size(); i++) {
            ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = lAccounts.get(i).Id, Territory2Id = territory.Id, AssociationCause='Territory2Manual');
            territoryAssociations.add(territoryAssociation);

            lTSFs.add(
                new TSF_vod__C(
                    Account_vod__c = lAccounts.get(i).Id,
                    Territory_vod__c = territory.Name,
                    Address_vod__c = lAddresses.get(i).Id,
                    External_Id_vod__c = lAccounts.get(i).Id + territory.Name
                ));
        }
        insert lTSFs;
        insert territoryAssociations;

        adminModeSetting.GNE_SFA2_Is_Admin_Mode__c = false;
		upsert adminModeSetting;

        SFA2_View_Config_gne__c viewConfig = new SFA2_View_Config_gne__c(
            View_Name_gne__c = 'My Accounts',
            Object_Type_gne__c = 'Account',
            Page_Name_gne__c = 'My Accounts'
        );
        insert viewConfig;

        SFA2_User_Preferences_gne__c userPreferences = new SFA2_User_Preferences_gne__c(
            Last_Territory_Used_gne__c = territory.Id,
            User_gne__c = testUser.Id,
            Last_View_Used_gne__c = viewConfig.Id
        );
        insert userPreferences;

        insert new User_Preference_gne__c(
            User_gne__c= testUser.Id,
            Account_gne__c = lAccounts.get(0).Id,
            Type_gne__c = 'HIDDENADDRESS',
            Active_gne__c = true
        );
    }
    

    static User testUser = [
        SELECT Id
        FROM User
        WHERE ProfileId IN: sfa2Profiles
        	AND isActive = true
        LIMIT 1
    ];

    @testSetup
    static void init() {        
        System.runAs(GNE_FRM_TestUtilities.createUser('adminUser', profile2Id.get('System Administrator'), false) ){
            
            Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
            Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
            Territory2 sampleTerritory = new Territory2(
                Name = '0B31-NORTHWEST_2', DeveloperName = 'Test_1', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, 
                external_id_gne__c = 'GNE-US;SFA;0B31-NORTHWEST_2', Parent_External_Id_gne__c ='GNE-US;SFA'
            );
            insert sampleTerritory;    
            
            Territory2 newTerritory = new Territory2(
                Name = '0B312-CHICAGO-INDIANAPOLIS_2', DeveloperName = 'Test_2', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, 
                external_id_gne__c = 'GNE-US;SFA;0B31-NORTHWEST_2;0B312-CHICAGO-INDIANAPOLIS_2', ParentTerritory2Id = sampleTerritory.Id,Parent_External_Id_gne__c ='GNE-US;SFA;0B31-NORTHWEST_2'
            );
            insert newTerritory;
            
            insert new UserTerritory2Association (UserId = testUser.Id, Territory2Id = newTerritory.Id);

            GNE_FRM_TestUtilities.createSchedulerConfig();
      
        	futureDML();
        }
    }

    @isTest
    static void testConstructor() {
        System.runAs(testUser) {
            GNE_SFA2_HCPs_Ctrl controller = new GNE_SFA2_HCPs_Ctrl();


            List<String> lTerritoryNames = new List<String>();
            Map<Id, Territory2> mapTerritories = new Map<Id, Territory2>([
                SELECT Id, Name
                FROM Territory2
                WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId = :testUser.Id)
               		AND (NOT External_id_gne__c Like 'INACTIVE TERRITORIES%')
            ]);

            for (Territory2 territory : mapTerritories.values()) {
                lTerritoryNames.add( territory.Name );
            }

            System.assertEquals(true, controller.userTerritoriesExist);

            SFA2_User_Preferences_gne__c myPreferences = [SELECT Id, Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1];
            System.assertEquals(myPreferences.Last_Territory_Used_gne__c , controller.territoryId);
            System.assertEquals( mapTerritories.size(), controller.territoriesSelectOptions.size() );
            for (SelectOption selectOpt : controller.territoriesSelectOptions) {
                System.assert( mapTerritories.containsKey( selectOpt.getValue() ) );
            }
        }
    }

    @isTest
    static void testGetDataServerSide() {
        System.runAs(testUser) {
            Territory2 territory = [Select Id, Name From Territory2 Where external_id_gne__c = 'GNE-US;SFA;0B31-NORTHWEST_2;0B312-CHICAGO-INDIANAPOLIS_2'];
            UserTerritory2Association ut = [SELECT Territory2Id FROM UserTerritory2Association WHERE UserID = :testUser.Id AND Territory2Id =:territory.Id Limit 1];
            List<Map<String, Object>> request = new List<Map<String, Object>> {
                new Map < String, Object> {'name' => 'sEcho', 'value' => 3},
                new Map < String, Object> {'name' => 'iDisplayStart', 'value' => 0},
                new Map < String, Object> {'name' => 'iDisplayLength', 'value' => 10},
                new Map < String, Object> {'name' => 'mDataProp_0', 'value' => 'Id'},
                new Map < String, Object> {'name' => 'mDataProp_1', 'value' => 'Account_vod__r.LastName'},
                new Map < String, Object> {'name' => 'mDataProp_2', 'value' => 'Account_vod__r.FirstName'},
                new Map < String, Object> {'name' => 'mDataProp_3', 'value' => 'Address_vod__r.Name'},
                new Map < String, Object> {'name' => 'iSortCol_0', 'value' => 0},
                new Map < String, Object> {'name' => 'sSortDir_0', 'value' => 'asc'},
                new Map < String, Object> {'name' => 'sSearch', 'value' => 'First'},
                new Map < String, Object> {'name' => 'sSearch_1', 'value' => 'Last'},
                new Map < String, Object> {'name' => 'territoryId', 'value' => territory.Id}
            };


            GNE_SFA2_HCPs_Ctrl controller = new GNE_SFA2_HCPs_Ctrl(true);
            GNE_SFA2_HCPs_Ctrl.Response response = GNE_SFA2_HCPs_Ctrl.getDataServerSide( request );

            System.assertEquals(10, response.aaData.size());
        }
    }

    @isTest
    static void testGetDataClientSide() {
        System.runAs(testUser) {
            Territory2 territory = [Select Id, Name From Territory2 Where external_id_gne__c = 'GNE-US;SFA;0B31-NORTHWEST_2;0B312-CHICAGO-INDIANAPOLIS_2'];
            UserTerritory2Association ut = [SELECT Territory2Id FROM UserTerritory2Association WHERE UserID = :testUser.Id AND Territory2Id =:territory.Id Limit 1];
            List<Map<String, Object>> request = new List<Map<String, Object>> {
                new Map < String, Object> {'name' => 'sEcho', 'value' => 3},
                new Map < String, Object> {'name' => 'iDisplayStart', 'value' => 0},
                new Map < String, Object> {'name' => 'iDisplayLength', 'value' => 10},
                new Map < String, Object> {'name' => 'mDataProp_0', 'value' => 'Id'},
                new Map < String, Object> {'name' => 'mDataProp_1', 'value' => 'Account_vod__r.LastName'},
                new Map < String, Object> {'name' => 'mDataProp_2', 'value' => 'Account_vod__r.FirstName'},
                new Map < String, Object> {'name' => 'mDataProp_3', 'value' => 'Address_vod__r.Name'},
                new Map < String, Object> {'name' => 'iSortCol_0', 'value' => 0},
                new Map < String, Object> {'name' => 'sSortDir_0', 'value' => 'asc'},
                new Map < String, Object> {'name' => 'sSearch', 'value' => 'First'},
                new Map < String, Object> {'name' => 'sSearch_1', 'value' => ''},
                new Map < String, Object> {'name' => 'territoryId', 'value' => ut.Territory2ID}
            };

            GNE_SFA2_HCPs_Ctrl controller = new GNE_SFA2_HCPs_Ctrl(true);
            GNE_SFA2_HCPs_Ctrl.Response response = GNE_SFA2_HCPs_Ctrl.getDataClientSide( request );

            System.assertEquals(20, response.aaData.size());
        }
    }

    @isTest
    static void testUpdateUserPreferences() {
        SFA2_User_Preferences_gne__c myPreferences = [SELECT Id, Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :testUser.Id LIMIT 1];
        Id lastTerritoryID = myPreferences.Last_Territory_Used_gne__c;
        delete myPreferences;

        System.runAs(testUser) {
            Territory2 territory = [Select Id From Territory2 where Id != :lastTerritoryID Limit 1];

            GNE_SFA2_HCPs_Ctrl.updateUserPreferences(territory.Id);

            myPreferences = [SELECT Id, Last_Territory_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1];
            System.assertEquals(territory.Id, myPreferences.Last_Territory_Used_gne__c);
        }
    }

    @isTest
    static void testHideAccounts() {
        System.runAs(testUser) {
            List<Id> lTSFIds = new List<Id>( new Map<Id, TSF_vod__C>([Select Id From TSF_vod__C]).keySet());
            UserTerritory2Association lUserTerritory = [Select Territory2Id From UserTerritory2Association Where UserID = :testUser.Id Limit 1];

            GNE_SFA2_HCPs_Ctrl.hideAccounts(lTSFIds, lUserTerritory.Territory2Id);

            List<TSF_vod__c>tsfes = [SELECT id, Account_vod__c,  Address_vod__c, Territory_vod__c FROM TSF_vod__c WHERE Territory_vod__c = :lUserTerritory.Territory2Id];
            System.assertEquals(0, tsfes.size());
        }
    }

    @isTest
    static void testExportToExcelClick() {
        System.runAs(testUser) {
            GNE_SFA2_HCPs_Ctrl ctrl = new GNE_SFA2_HCPs_Ctrl();
            PageReference testedPage = ctrl.exportToExcelClick();
            System.assert( testedPage.getUrl().containsIgnoreCase( Page.GNE_SFA2_HCPs_Export.getUrl() ));
            System.assertEquals( ctrl.territoryId, testedPage.getParameters().get('territoryId') );
        }
    }

    @isTest
    static void testExportToExcel() {
        System.runAs(testUser) {
            GNE_SFA2_HCPs_Ctrl ctrl = new GNE_SFA2_HCPs_Ctrl();
            ctrl.exportToExcel();
            System.assertNotEquals(null, ctrl.tsfsInExport );
        }
    }

    @isTest
    static void testHelperFunctions() {
        System.runAs(testUser) {

            PageReference hcpsPage = Page.GNE_SFA2_HCPs;
            Test.setCurrentPage(hcpsPage);

            GNE_SFA2_HCPs_Ctrl ctrl = new GNE_SFA2_HCPs_Ctrl();
            System.assertEquals( hcpsPage.getHeaders().get('host'), ctrl.getHostName() );

            System.assertEquals( 'Customers - ' + String.valueOf(Date.Today()), ctrl.getFileName());

            String props = ctrl.getWorkbookProperties();
            System.assertEquals('<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>My Customers</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>', props);

            System.assertEquals('Customers', ctrl.getActiveMenuItem() );
        }
    }

    @isTest
    static void testGetters(){
        System.runAs(testUser) {
            PageReference hcpsPage = Page.GNE_SFA2_HCPs;
            Test.setCurrentPage(hcpsPage);
            GNE_SFA2_HCPs_Ctrl ctrl = new GNE_SFA2_HCPs_Ctrl();
            ctrl.request = new GNE_SFA2_HCPs_Ctrl.RequestWrapper([SELECT Id, FirstName, LastName, Email, Phone, External_ID_gne__c FROM User WHERE Id = : Userinfo.getUserId() LIMIT 1]);
            ctrl.request.territory = 'test';

            Test.startTest();
            	ctrl.getTopics();
            	ctrl.getTerritories();
            	ctrl.getProducts();
            	ctrl.getFoimRequestExist();
            	ctrl.submitTicket();
            Test.stopTest();
        }
    }
}