@isTest
public class GNE_FRM_TestData {
    public class ForRep2Territory_Batch_Test{
        public List<UserTerritory2Association> userTerritories {get;set;}
        public User afrmManager {get;set;}
        public User admin {get;set;}

        public ForRep2Territory_Batch_Test(){
            this.userTerritories = new List<UserTerritory2Association>();
            Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
            this.afrmManager = GNE_FRM_TestUtilities.createUser('frmManagert', ids2ProfilesMap.get('GNE-Field'), false);
            this.admin = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), false);
            insert new List<User> {this.afrmManager, this.admin};
            Territory2 terr = GNE_FRM_TestUtilities.createTerritory('Terr1', null, false);
            terr.External_Id_gne__c = 'Root;Terr1';
        	terr.Parent_External_Id_gne__c ='Root';
        	insert terr;
            this.userTerritories.add(new UserTerritory2Association (Territory2Id = terr.Id, UserId = afrmManager.Id, Id ='0R070000000MSebYYY'));
        }
    }

    public class ForSyncRecordsWithMDM_Test{
        public User afrmManager {get;set;}
        public User admin {get;set;}
        public List<Account> accountsWithMdmId {get;set;}
        public List<Account> accountsWithOutMdmId {get;set;}
        public Map<Id, Address_vod__c> accId2addressWithMdmId {get;set;}
        public Map<Id,Address_vod__c> accId2addressWithOutMdmId {get;set;}
        public Map<String, Integer> respondMap = new Map<String, Integer>();
        private Integer accountCounter = 20000000;
        private Integer addressCounter = 30000000;

        public ForSyncRecordsWithMDM_Test(Integer accWithMdm, Integer accWithoutMdm){
            Map<String, Id> name2RtId = GNE_FRM_TestUtilities.getAccountRecordTypes();
            Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
            this.afrmManager = GNE_FRM_TestUtilities.createUser('frmManagert', ids2ProfilesMap.get('GNE-Field'), false);
            this.admin = GNE_FRM_TestUtilities.createUser('adminUser', ids2ProfilesMap.get('System Administrator'), false);
            for(Account acc : [SELECT Id FROM Account]){
                respondMap.put(acc.Id, accountCounter++);
            }
            for(Address_vod__c add : [SELECT Id FROM Address_vod__c]){
                respondMap.put(add.Id, addressCounter++);
            }
        }
    }

    public class ForFRMAccountDCRControllerTest{
        public User frmUser {get;set;}
        public User admin {get;set;}

        public ForFRMAccountDCRControllerTest(){
            Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
            this.frmUser = GNE_FRM_TestUtilities.createUser('frmUser2', ids2ProfilesMap.get('GNE-Field'), false);
            this.admin = GNE_FRM_TestUtilities.createUser('adminUser2', ids2ProfilesMap.get('System Administrator'), false);
            insert new List<User> {this.frmUser, this.admin};
        }
    }

    public class ForGNE_FRM_DST_MatchLoserViewTest{
        public User frmUser {get;set;}
        public User admin {get;set;}

        public ForGNE_FRM_DST_MatchLoserViewTest(){
            Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
            this.frmUser = GNE_FRM_TestUtilities.createUser('frmUser2', ids2ProfilesMap.get('GNE-Field'), false);
            this.admin = GNE_FRM_TestUtilities.createUser('adminUser2', ids2ProfilesMap.get('System Administrator'), false);
            insert new List<User> {this.frmUser, this.admin};
            PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'Data_Stewardship_Tool'];
            insert new PermissionSetAssignment(AssigneeId = frmUser.id, PermissionSetId = ps.Id );
        }
    }

    public class ForGNE_FRM_DST_MergeManagementTest{
        public User frmUser {get;set;}

        public ForGNE_FRM_DST_MergeManagementTest(){
            Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
            this.frmUser = GNE_FRM_TestUtilities.createUser('frmUser2', ids2ProfilesMap.get('GNE-Field'), true);
            PermissionSet ps = [SELECT Id From PermissionSet WHERE Name = 'Data_Stewardship_Tool'];
            insert new PermissionSetAssignment(AssigneeId = frmUser.id, PermissionSetId = ps.Id );
        }
    }

    public class ForGNE_SFA2_SBC_Ctrl_Test {
        public User frmUser {get;set;}
        public User admin {get;set;}

        public ForGNE_SFA2_SBC_Ctrl_Test(){
            Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
            this.frmUser = GNE_FRM_TestUtilities.createUser('frmUser2', ids2ProfilesMap.get('GNE-Field'), false);
            this.admin = GNE_FRM_TestUtilities.createUser('adminUser2', ids2ProfilesMap.get('System Administrator'), false);
            insert new List<User> {this.frmUser, this.admin};
        }
    }

    public class ForGNE_SFA2_User_Trigger_HelperTest {
        public User frmUser1 {get;set;}
        public User frmUser2 {get;set;}
        public User opsUser {get;set;}

        public ForGNE_SFA2_User_Trigger_HelperTest() {
            Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
            this.frmUser1 = GNE_FRM_TestUtilities.createUser('frmUser1', ids2ProfilesMap.get('GNE-Field'), false);
            this.frmUser2 = GNE_FRM_TestUtilities.createUser('frmUser2', ids2ProfilesMap.get('GNE-Field'), false);
            this.opsUser  = GNE_FRM_TestUtilities.createUser('opsUser', ids2ProfilesMap.get('GNE-Field'), false);
            insert new List<User> {this.frmUser1, this.frmUser2, this.opsUser};
        }
    }
}