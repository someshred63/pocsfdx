@isTest
private class GNE_SFA2_MyTargets_ControllerTest {
    static Map<String, Id> ids2ProfilesMap = getProfiles();
    
    private static Map<String, Id> getProfiles() {
        Map<String, Id> ids2ProfilesMap = new Map<String, Id>();
        for (Profile profile : [SELECT Name FROM Profile WHERE Profile.Name LIKE 'RCanada-%' ]) {
            ids2ProfilesMap.put(profile.Name, profile.Id);
        }
        return ids2ProfilesMap;
    }
    
    @testSetup
    static void initData() {
        User manager = GNE_FRM_TestUtilities.createUser('RCManager', ids2ProfilesMap.get('RCanada-SFA-Manager'), true);
        User tsUser = GNE_FRM_TestUtilities.createUser('RCTsUser', ids2ProfilesMap.get('RCanada-SFA-TS'), false);
        tsUser.ManagerId = manager.Id;
        insert tsUser;
        
        insert new GNE_SFA2_Canadian_Users__c(Name='RCanada-SFA-TS'); 
        insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'SFA-Canada', Role_gne__c = 'TS',SetupOwnerId=tsUser.Id, Run_in_SFA2_UI_gne__c=true);
        insert new SFA2_Configuration_Object_gne__c(
            Name='My Targets List Page', Attributes_gne__c='activeMenuItem=My Targets;', Section_Header_gne__c='My Targets',Configuration_Type_gne__c='List Page',
        	Object_Name_gne__c='Account_MyTarget',Role_gne__c='TS',Application_Type__c='SFA-Canada'
        );
        insert new SFA2_View_Config_gne__c(
            View_Name_gne__c='MyTargets',View_Fields_gne__c='Account.LastName;Account.FirstName;HcoAccount;Product;RocheTarget;MyTarget;YtdInteractions;AccessRating;Account.Account_Type_gne__c;Account.Specialties_gne__c',
            Sorting_Field_gne__c='Account.Account_Order_can_gne__c',Filter_Statement_gne__c='[{"valueType": "BOOLEAN","value": "true","record": "TSF","operator": "eq","multiValue": [],"field": "My_Target_vod__c","brand": ""}]',
            Person_Record_Types_gne__c='HCP_Canada',Application_Type_gne__c='SFA-Canada',Role_gne__c='TS',Visibility_gne__c='restricted',Object_Type_gne__c='Account_MyTarget', Page_Name_gne__c='My Targets'
        );
        Territory2 terr;
        System.runAs(GNE_FRM_TestUtilities.createUser('superAdmin', GNE_FRM_TestUtilities.getProfiles().get('System Administrator'), false)){
            terr = GNE_FRM_TestUtilities.createTerritory('CHILDTERR', GNE_FRM_TestUtilities.getFakeId(Territory2.SObjectType), false);
            Territory2 parentTerr = new Territory2(Name = 'CAN-TEST-TERR', DeveloperName = 'TEST', Territory2ModelId = terr.Territory2ModelId, Territory2TypeId = terr.Territory2TypeId, External_Id_gne__c = 'Root;CAN-TEST-TERR', Parent_External_Id_gne__c ='Root');
            insert parentTerr;
            terr.ParentTerritory2Id = parentTerr.Id;
            insert terr;
            System.debug('terr '+terr);
            UserTerritory2Association uta = new UserTerritory2Association(Territory2Id = terr.Id, UserId =tsUser.Id );
        	insert uta;
        } 
        Product_vod__c prod = new Product_vod__c(Product_Type_vod__c = 'Detail', Region_Code_gne__c = 2,
			Detail_Product_Subtype_Code_gne__c = 'Diagnostic', OwnerId = tsUser.Id);
		insert prod;
		My_Setup_Products_vod__c mySetupProd = new My_Setup_Products_vod__c(Product_vod__c = prod.Id, OwnerId = tsUser.Id);
		insert mySetupProd;               
		List<Account> accs = new List<Account>();
		for(Integer i=0; i<10; i++){
			Account acc = GNE_FRM_TestUtilities.createAccount('John Kowalski'+i, 'HCP_Canada', 'Nurse', false, true);
			accs.add(acc);
		}
		insert accs;
		Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(accs[0].Id, 'address', true, 'addressName');
		insert addr;
		List<TSF_vod__c> tsfs = new List<TSF_vod__c>();
        List<Targets_and_Tiers_can_gne__c> tats = new List<Targets_and_Tiers_can_gne__c>();
		for(Account acc :accs){
			TSF_vod__c tsf = new TSF_vod__c();
            tsf.Account_vod__c =  acc.Id;
			tsf.Territory_vod__c = terr.Name;
			tsf.Address_vod__c =addr.Id;
			tsfs.add(tsf);
            tats.add(new Targets_and_Tiers_can_gne__c(Account_can_gne__c=acc.Id, My_Target_gne__c='MED', Target_gne__c='LOW', Territory_gne__c='CHILDTERR', Product_Catalog_gne__c =prod.Id, OwnerId = tsUser.Id)) ;
		}
		insert tsfs;
        insert tats;
        
        List<AccountShare> newAccountShares = new List<AccountShare>();

        for(Account acc :accs) {
            AccountShare thisAccountShare = new AccountShare();        
            thisAccountShare.userorgroupid = tsUser.Id;
            thisAccountShare.accountid = acc.Id;
            thisAccountShare.accountaccesslevel = 'Edit';
            thisAccountShare.OpportunityAccessLevel = 'None';      
            newAccountShares.add(thisAccountShare);                
        }
        insert newAccountShares;
    }
    
    @isTest
    static void initTest() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTarget');
    	Test.setCurrentPage(pageRef);
        Test.startTest();
        	User tsUser = [SELECT Id FROM User WHERE UserName = 'RCTsUseruser@gene.com' LIMIT 1];
        	String activeMenu;
        	GNE_SFA2_MyTargets_Controller ctrl;
        
            System.runAs(tsUser){                
                ctrl = new GNE_SFA2_MyTargets_Controller();
                ctrl.territoryId = [SELECT Id FROM Territory2 WHERE Name = 'CHILDTERR' LIMIT 1].Id ;
                ctrl.loadRecords();
            }
        Test.stopTest();
        
        System.assertEquals(10, ctrl.viewWrappers.size());
    }
    
    @isTest
    static void test_getMyTargetAndTiersTsfQueryCondition() {
         PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTarget');

        Test.setCurrentPage(pageRef);
        Test.startTest();
        	User tsUser = [SELECT Id FROM User WHERE UserName = 'RCTsUseruser@gene.com' LIMIT 1];
        
            System.runAs(tsUser){
                GNE_SFA2_MyTargets_Controller.getMyTargetAndTiersTsfQueryCondition(new List<String>{'CAN-TEST-TERR' });
            }
        Test.stopTest();        
    }
    
    @isTest
    static void test_methods() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTarget');
    	Test.setCurrentPage(pageRef);
        Test.startTest();
        	User tsUser = [SELECT Id FROM User WHERE UserName = 'RCTsUseruser@gene.com' LIMIT 1];
        	String activeMenu;
        	GNE_SFA2_MyTargets_Controller ctrl;
        
            System.runAs(tsUser){                
                ctrl = new GNE_SFA2_MyTargets_Controller();
                ctrl.territoryId = [SELECT Id FROM Territory2 WHERE Name = 'CHILDTERR' LIMIT 1].Id ;
                ctrl.loadRecords();
                ctrl.getActiveMenuItem();
                ctrl.getListPageName();
                ctrl.getCustomButtons();
                ctrl.getWorkbookProperties();
                ctrl.getFileName();
                ctrl.getHostName();
                ctrl.getSelectedTSFs();
                ctrl.refreshSelectedAccounts();
                ctrl.getIsViewCreatable();
                ctrl.getPageNumbers();
                ctrl.getIsViewEditable();
                ctrl.getDisablePrevious();
                ctrl.getDisableNext();
                ctrl.nextPage();
                ctrl.previousPage();
                ctrl.wrapperAsJson= ctrl.viewWrappers[0].accountId;
                ctrl.submitToManager();
            }
        Test.stopTest();    
        Targets_and_Tiers_can_gne__c tat = [SELECT Submitted_By_gne__c FROM Targets_and_Tiers_can_gne__c WHERE Account_can_gne__c = :ctrl.viewWrappers[0].accountId LIMIT 1];
        System.assertEquals(tsUser.Id, tat.Submitted_By_gne__c);        
    }
}