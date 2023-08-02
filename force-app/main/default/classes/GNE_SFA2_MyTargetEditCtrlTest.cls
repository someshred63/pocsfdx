@isTest
private class GNE_SFA2_MyTargetEditCtrlTest {
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
        User manager = GNE_FRM_TestUtilities.createUser('RCManager', ids2ProfilesMap.get('RCanada-SFA-Manager'), false);
        User tsUser = GNE_FRM_TestUtilities.createUser('RCTsUser', ids2ProfilesMap.get('RCanada-SFA-TS'), false);
        insert new List<User>{manager, tsUser};
            
        SFA2_Configuration_Object_gne__c co1 = new SFA2_Configuration_Object_gne__c(
            Name = 'Targets Approval', Is_Active_gne__c = true, Configuration_Type_gne__c = 'Menu Layout', 
            Object_Name_gne__c = 'Account', Role_gne__c='Manager', Application_Type__c='SFA-Canada',Attributes_gne__c='GNE_SFA2_MyTargetApproval;img/icons/icon-contacts@2x.png'
        );
        insert new List<SFA2_Configuration_Object_gne__c>{co1};
 
        Account acc = GNE_FRM_TestUtilities.createAccount('John Kowalski', 'HCP_Canada', 'Nurse', false, true);
        Account acc1 = GNE_FRM_TestUtilities.createAccount('Mohn Mowalski', 'HCP_Canada', 'Nurse', false, true);
        Account hcpAcc = GNE_FRM_TestUtilities.createAccount('HCP Clinic', 'GNE_SFA_Roche_Canada_can', 'Hospital', false);
        acc.Region_Code_gne__c = 2.0;
        acc1.Region_Code_gne__c = 2.0;
        hcpAcc.Region_Code_gne__c = 2.0;
        insert new List<Account>{acc, acc1, hcpAcc};
            
        Address_vod__c add1 = new Address_vod__c(Province_can_gne__c='QC',Account_vod__c=acc.Id, Primary_vod__c=true);
        Address_vod__c add2 = new Address_vod__c(Province_can_gne__c='QC',Account_vod__c=hcpAcc.Id, Primary_vod__c=true);
        insert new List<Address_vod__c>{add1,add2};
            
        Product_vod__c prod = new Product_vod__c(Product_Type_vod__c = 'Detail', Detail_Product_Subtype_Code_gne__c ='Other');
        insert prod;
        insert new My_Setup_Products_vod__c(Product_vod__c = prod.Id, OwnerId = tsUser.Id);
            
        Targets_and_Tiers_can_gne__c tat1 = new Targets_and_Tiers_can_gne__c(Account_can_gne__c=acc.Id, My_Target_gne__c='MED', Target_gne__c='LOW', Territory_gne__c='CHILDTERR', Product_Catalog_gne__c = prod.Id);
        Targets_and_Tiers_can_gne__c tat2 = new Targets_and_Tiers_can_gne__c(Account_can_gne__c=acc1.Id, My_Target_gne__c='MED', Target_gne__c='LOW', Submitted_By_gne__c=tsUser.Id, Submitted_DataTime_gne__c=System.now(),Submitted_To_gne__c=manager.Id, Product_Catalog_gne__c = prod.Id);
        insert new List<Targets_and_Tiers_can_gne__c>{tat1,tat2};

        Call2_vod__c call = new Call2_vod__c(Account_vod__c = acc.Id, Call_Date_vod__c = System.today());
        insert call;
        
        
        System.runAs(GNE_FRM_TestUtilities.createUser('superAdmin', GNE_FRM_TestUtilities.getProfiles().get('System Administrator'), false)){
            Territory2 terr = GNE_FRM_TestUtilities.createTerritory('CHILDTERR', GNE_FRM_TestUtilities.getFakeId(Territory2.SObjectType), false);
            Territory2 parentTerr = new Territory2(Name = 'CAN-TEST-TERR', DeveloperName = 'TEST', Territory2ModelId = terr.Territory2ModelId, Territory2TypeId = terr.Territory2TypeId, External_Id_gne__c = 'Root;CAN-TEST-TERR', Parent_External_Id_gne__c ='Root');
            insert parentTerr;
            terr.ParentTerritory2Id = parentTerr.Id;
            insert terr;
        }

    }
    
    @isTest
    static void initTest() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTargetEdit');
        Territory2 terr = [SELECT Id FROM Territory2 WHERE Name ='CHILDTERR' ORDER BY LastMOdifiedDate DESC LIMIT 1];
        pageRef.getParameters().put('territoryId', terr.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        	User tsUser = [SELECT Id FROM User WHERE UserName = 'RCTsUseruser@gene.com' LIMIT 1];
        	String activeMenu;
        	GNE_SFA2_MyTargetEditCtrl ctrl;
        	Integer pageNumbers;
        	Account acc = [SELECT Id, Account.RecordTypeId FROM Account WHERE FirstName = 'John'];
        
            System.runAs(tsUser){
                ctrl = new GNE_SFA2_MyTargetEditCtrl(new ApexPages.StandardController(acc));
                ctrl.getTats();
                ctrl.getAccessRatings();
                ctrl.getHCPAccounts();
            }
        Test.stopTest();
    }
    
    @isTest
    static void test_SaveMyTargets() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTargetEdit');
        Territory2 terr = [SELECT Id FROM Territory2 WHERE Name ='CHILDTERR' ORDER BY LastMOdifiedDate DESC LIMIT 1];
        pageRef.getParameters().put('territoryId', terr.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        	User tsUser = [SELECT Id FROM User WHERE UserName = 'RCTsUseruser@gene.com' LIMIT 1];
        	GNE_SFA2_MyTargetEditCtrl ctrl;

        	Account acc = [SELECT Id, Account.RecordTypeId FROM Account WHERE FirstName = 'John'];
        	Id hcpId =[SELECT Id FROM Account WHERE Name = 'HCP Clinic'].Id;
        
            System.runAs(tsUser){
                ctrl = new GNE_SFA2_MyTargetEditCtrl(new ApexPages.StandardController(acc));
                ctrl.getTats();
                ctrl.getAccessRatings();
                ctrl.getHCPAccounts();
                ctrl.selectedRating = 'Optimal';
                ctrl.selectedHCOId = hcpId;
                ctrl.SaveMyTargets();
            }
        Test.stopTest();

		Boolean isEnteredLoop = false;
        for(Targets_and_Tiers_can_gne__c tat : [
            SELECT Access_Rating__c, HCO_Account__c FROM Targets_and_Tiers_can_gne__c WHERE Account_can_gne__c = : acc.Id
        ]){
            System.assertEquals('Optimal', tat.Access_Rating__c);
            System.assertEquals(hcpId, tat.HCO_Account__c);
            isEnteredLoop = true;
        }
        System.assertEquals(true, isEnteredLoop);
    }
    
    @isTest
    static void test_SaveAndReturn() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTargetEdit');
        Territory2 terr = [SELECT Id FROM Territory2 WHERE Name ='CHILDTERR' ORDER BY LastMOdifiedDate DESC LIMIT 1];
        pageRef.getParameters().put('territoryId', terr.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        	User tsUser = [SELECT Id FROM User WHERE UserName = 'RCTsUseruser@gene.com' LIMIT 1];
        	GNE_SFA2_MyTargetEditCtrl ctrl;

        	Account acc = [SELECT Id, Account.RecordTypeId FROM Account WHERE FirstName = 'John'];
        	Id hcpId =[SELECT Id FROM Account WHERE Name = 'HCP Clinic'].Id;
        
            System.runAs(tsUser){
                ctrl = new GNE_SFA2_MyTargetEditCtrl(new ApexPages.StandardController(acc));
                ctrl.getTats();
                ctrl.getAccessRatings();
                ctrl.getHCPAccounts();
                ctrl.selectedRating = 'Optimal';
                ctrl.selectedHCOId = hcpId;
                ctrl.saveAndReturn();
            }
        Test.stopTest();

		Boolean isEnteredLoop = false;
        for(Targets_and_Tiers_can_gne__c tat : [
            SELECT Access_Rating__c, HCO_Account__c FROM Targets_and_Tiers_can_gne__c WHERE Account_can_gne__c = : acc.Id
        ]){
            System.assertEquals('Optimal', tat.Access_Rating__c);
            System.assertEquals(hcpId, tat.HCO_Account__c);
            isEnteredLoop = true;
        }
        System.assertEquals(true, isEnteredLoop);
    }
    
    @isTest
    static void test_returnToMyTarget() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTargetEdit');
        Territory2 terr = [SELECT Id FROM Territory2 WHERE Name ='CHILDTERR' ORDER BY LastMOdifiedDate DESC LIMIT 1];
        pageRef.getParameters().put('territoryId', terr.Id);
        Test.setCurrentPage(pageRef);
        Test.startTest();
        	User tsUser = [SELECT Id FROM User WHERE UserName = 'RCTsUseruser@gene.com' LIMIT 1];
        	GNE_SFA2_MyTargetEditCtrl ctrl;

        	Account acc = [SELECT Id, Account.RecordTypeId FROM Account WHERE FirstName = 'John'];
        	Id hcpId =[SELECT Id FROM Account WHERE Name = 'HCP Clinic'].Id;
        	PageReference retUrlPage;
            System.runAs(tsUser){
                ctrl = new GNE_SFA2_MyTargetEditCtrl(new ApexPages.StandardController(acc));
                retUrlPage =  ctrl.returnToMyTargetPage();
            }
        Test.stopTest();
		
        System.assertEquals(Page.GNE_SFA2_MyTargets.getUrl(), retUrlPage.getUrl().toLowerCase());
    }
}