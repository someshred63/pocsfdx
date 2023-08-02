@isTest
private class GNE_SFA2_User_Trigger_Helper_Test {
    private static Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
    
    @testSetup
    private static void initData(){
        Map<String,Profile_to_Group_Map_gne__c> profileMaskToGroupMap = new Map<String,Profile_to_Group_Map_gne__c>{
            'GNE-Field' => new Profile_to_Group_Map_gne__c(Group_Name_gne__c = 'PRF_GRP_US'), 
            'GNE-MCCO-AM' => new Profile_to_Group_Map_gne__c(Group_Name_gne__c = 'PRF_GRP_US')
        };
        
        List<Profile_to_Group_Map_gne__c> masksToInsert = new List<Profile_to_Group_Map_gne__c>();
        
        for(String key : profileMaskToGroupMap.keySet()) {
            Profile_to_Group_Map_gne__c pgMap = profileMaskToGroupMap.get(key);
            pgMap.Locale_gne__c = 'US';
            pgMap.Profile_Mask_gne__c = pgMap.Profile_Mask_gne__c==null ? key : pgMap.Profile_Mask_gne__c;
            masksToInsert.add(pgMap);
        }
        insert masksToInsert;
        
        GNE_FRM_TestUtilities.createUser('bfrmUser', ids2ProfilesMap.get('GNE-Field'), true);
    }
    
    @isTest
    static void insertUser() {
        User bfrmManager = GNE_FRM_TestUtilities.createUser('bfrmManager', ids2ProfilesMap.get('GNE-Field'), false);
        Test.startTest();
        	insert bfrmManager;
        Test.stopTest();
        GroupMember [] gms = [SELECT Id, Group.Name FROM GroupMember WHERE UserOrGroupId = :bfrmManager.Id];
        System.assertEquals(1, gms.size());
        System.assertEquals('PRF_GRP_US', gms[0].Group.Name);
    }
    
    @isTest
    static void updateUser() {
        User bfrmUser = [SELECT Id, ProfileId FROM USER WHERE UserName = 'bfrmUseruser@gene.com' LIMIT 1] ;
        bfrmUser.ProfileId = ids2ProfilesMap.get('GNE-Field');
        Test.startTest();
            update bfrmUser;
        Test.stopTest();
        GroupMember [] gms = [SELECT Id, Group.Name FROM GroupMember WHERE UserOrGroupId = :bfrmUser.Id];
        System.assertEquals(1, gms.size());
        System.assertEquals('PRF_GRP_US', gms[0].Group.Name);
    }
}