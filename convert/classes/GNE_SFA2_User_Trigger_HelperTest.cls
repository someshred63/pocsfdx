@istest
private class GNE_SFA2_User_Trigger_HelperTest {
    
    @testSetup
    static void initData() {
        Profile_to_Group_Map_gne__c frm_IFRM_1 = new Profile_to_Group_Map_gne__c(
            Group_Name_gne__c = 'PRF_GRP_US_FRM',
            Profile_Mask_gne__c = 'GNE-Field'            
        );
        
        Profile_to_Group_Map_gne__c frm_IFRM_2 = new Profile_to_Group_Map_gne__c(
            Group_Name_gne__c = 'GNE_SFA2_SpeakerContractVisible',
            Profile_Mask_gne__c = 'GNE-Field'    
        );       
        
        Profile_to_Group_Map_gne__c ops = new Profile_to_Group_Map_gne__c(
            Group_Name_gne__c = 'PRF_GRP_US',
            Profile_Mask_gne__c = 'GNE-Field'  
        );
        
        insert new List<Profile_to_Group_Map_gne__c> {frm_IFRM_1, frm_IFRM_2, ops};
        GNE_FRM_TestData.ForGNE_SFA2_User_Trigger_HelperTest testData = new GNE_FRM_TestData.ForGNE_SFA2_User_Trigger_HelperTest();
    }
    
    static testMethod void initLoad() {
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        
        User [] users = [SELECT Id, ProfileId, UserName FROM User WHERE UserName IN ('frmUser1user@gene.com', 'frmUser2user@gene.com','opsUseruser@gene.com')];

        for(User u : users){
            if(u.UserName == 'frmUser1user@gene.com'){
                u.ProfileId = ids2ProfilesMap.get('GNE-Field');
            }
            if(u.UserName == 'frmUser2user@gene.com'){
                u.ProfileId = ids2ProfilesMap.get('GNE-Field');
            }
            if(u.UserName == 'opsUseruser@gene.com'){
                u.ProfileId = ids2ProfilesMap.get('GNE-Field');
            }
        }
        
        Test.startTest();
        	Database.update(users);
        Test.stopTest();
        
        Map<Id, List<GroupMember>> userId2groups = new Map<Id, List<GroupMember>>();
        for(GroupMember gm : [SELECT Id, UserOrGroupId, Group.DeveloperName FROM GroupMember WHERE UserOrGroupId IN :users]) {
            if(!userId2groups.containsKey(gm.UserOrGroupId)) {
                userId2groups.put(gm.UserOrGroupId, new List<GroupMember>());
            }
            userId2groups.get(gm.UserOrGroupId).add(gm);
        }
        for(Id i : userId2groups.keySet()){
             System.debug(userId2groups.get(i));
        }
       
        
        users = [SELECT Id, ProfileId, UserName FROM User WHERE Id IN :users];
        Boolean runOne = false;
        Boolean runThree = false;
        
        for(User u : users){
            if(u.UserName == 'frmUser1user@gene.com'){
                runOne = true;
                System.assertEquals(3, userId2groups.get(u.Id).size());
                Boolean isCorrectAssigment = true;
                Set<String> newGroups = new Set<String>{'GNE_SFA2_SpeakerContractVisible', 'PRF_GRP_US_FRM' , 'PRF_GRP_US'};
                for(GroupMember gm: userId2groups.get(u.Id)){
                    if(!newGroups.contains(gm.Group.DeveloperName)){
                        isCorrectAssigment = false;
                    }
                }
                System.assertEquals(true, isCorrectAssigment);
            }

            if(u.UserName == 'opsUseruser@gene.com'){
                runThree = true;
                System.assertEquals(3, userId2groups.get(u.Id).size());
                Boolean isCorrectAssigment = true;
                Set<String> newGroups = new Set<String>{'GNE_SFA2_SpeakerContractVisible', 'PRF_GRP_US_FRM', 'PRF_GRP_US' };
                for(GroupMember gm: userId2groups.get(u.Id)){
                    if(!newGroups.contains(gm.Group.DeveloperName)){
                        isCorrectAssigment = false;
                    }
                }
                System.assertEquals(true, isCorrectAssigment);                
            }
        }
        System.assertEquals(true, runOne && runThree);
    }
    
    @isTest
    static void insertUser() {
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User afrmManager = GNE_FRM_TestUtilities.createUser('afrmManager', ids2ProfilesMap.get('GNE-Field'), false);
        Test.startTest();
        	insert afrmManager;
        Test.stopTest();
        GroupMember [] gms = [SELECT Id, Group.Name FROM GroupMember WHERE UserOrGroupId = :afrmManager.Id ORDER BY Group.Name];
        System.assertEquals(3, gms.size());
        System.assertEquals('PRF_GRP_US', gms[1].Group.Name);
    }
}