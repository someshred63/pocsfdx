@isTest
private class GNE_SFA2_MyTargetApprovalCtrlTest {
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
        insert new List<User>{manager};
        tsUser.ManagerId = manager.Id;
        insert  tsUser;
            
        SFA2_Configuration_Object_gne__c co1 = new SFA2_Configuration_Object_gne__c(
            Name = 'Targets Approval', Is_Active_gne__c = true, Configuration_Type_gne__c = 'Menu Layout', 
            Object_Name_gne__c = 'Account', Role_gne__c='Manager', Application_Type__c='SFA-Canada',Attributes_gne__c='GNE_SFA2_MyTargetApproval;img/icons/icon-contacts@2x.png'
        );
        insert new List<SFA2_Configuration_Object_gne__c>{co1};
 
        Account acc = GNE_FRM_TestUtilities.createAccount('John Kowalski', 'HCP_Canada', 'Nurse', false, true);
        Account acc1 = GNE_FRM_TestUtilities.createAccount('Mohn Mowalski', 'HCP_Canada', 'Nurse', false, true);
        insert new List<Account>{acc, acc1};
            
        Targets_and_Tiers_can_gne__c tat1 = new Targets_and_Tiers_can_gne__c(Account_can_gne__c=acc.Id, My_Target_gne__c='MED', Target_gne__c='LOW', Submitted_By_gne__c=tsUser.Id, Submitted_DataTime_gne__c=System.now(),Submitted_To_gne__c=manager.Id);
        Targets_and_Tiers_can_gne__c tat2 = new Targets_and_Tiers_can_gne__c(Account_can_gne__c=acc1.Id, My_Target_gne__c='MED', Target_gne__c='LOW', Submitted_By_gne__c=tsUser.Id, Submitted_DataTime_gne__c=System.now(),Submitted_To_gne__c=manager.Id);
        insert new List<Targets_and_Tiers_can_gne__c>{tat1,tat2};

        Call2_vod__c call = new Call2_vod__c(Account_vod__c = acc.Id, Call_Date_vod__c = System.today());
        insert call;

    }
    
    @isTest
    static void initTest() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTargetApproval');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        	User manager = [SELECT Id FROM User WHERE UserName = 'RCManageruser@gene.com' LIMIT 1];
        	String activeMenu;
        	GNE_SFA2_MyTargetApprovalCtrl ctrl;
        	Integer pageNumbers;
        
            System.runAs(manager){
                ctrl = new GNE_SFA2_MyTargetApprovalCtrl();
                ctrl.loadRecords();
                activeMenu = ctrl.getActiveMenuItem();
                pageNumbers =  ctrl.getPageNumbers();
                ctrl.nextPage();
                ctrl.previousPage();
            }
        Test.stopTest();
        
        System.assertEquals(2, ctrl.viewWrappers.size());
        System.assertEquals('', activeMenu);
        System.assertEquals(1, pageNumbers);
        System.assertEquals(true, ctrl.getDisablePrevious());
        System.assertEquals(true, ctrl.getDisableNext());
    }
    
    @isTest
    static void test_SubmitRecords() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_MyTargetApproval');
        Test.setCurrentPage(pageRef);
        Test.startTest();
            User manager = [SELECT Id FROM User WHERE UserName = 'RCManageruser@gene.com' LIMIT 1];
            GNE_SFA2_MyTargetApprovalCtrl ctrl;
            
            System.runAs(manager){
                ctrl = new GNE_SFA2_MyTargetApprovalCtrl();
                ctrl.loadRecords();
                ctrl.keyFromVfp = ctrl.viewWrappers[0].key;
                ctrl.approveRecord();
                ctrl.keyFromVfp = ctrl.viewWrappers[1].key;
                ctrl.rejectRecord();
                ctrl.submitRecords();
            }
        Test.stopTest();
		Integer countApproved = 0;
        Integer countRejected = 0;
        for(Targets_and_Tiers_can_gne__c tat :[SELECT Id,Target_gne__c, My_Target_gne__c FROM Targets_and_Tiers_can_gne__c]){
            if(tat.Target_gne__c == 'MED' && tat.My_Target_gne__c ==  'MED'){
                countRejected++;
            }
            if(tat.Target_gne__c == 'LOW' && tat.My_Target_gne__c ==  'LOW'){
                countApproved ++;
            }
		}
        System.assertEquals(1, countRejected);
        System.assertEquals(1, countApproved);
	}
}