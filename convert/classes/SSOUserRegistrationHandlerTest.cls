@IsTest
private class SSOUserRegistrationHandlerTest {
    
    @testSetup
    private static void testSetup() {
        GNE_Foun_Misc_Config_Items_gne__c config = GNE_Foun_Misc_Config_Items_gne__c.getValues('SSO_Jit_GroupAssignmentEnabled');
        if(config == null) {
            config = new GNE_Foun_Misc_Config_Items_gne__c(name='SSO_Jit_GroupAssignmentEnabled', Configuration_Value_gne__c='true');
        } else {
            config.Configuration_Value_gne__c = 'true';
        }
        upsert config;
    }
    
    @IsTest
    static void updateUserWithGroupMember() {
        SSOUserRegistrationHandler handler = new SSOUserRegistrationHandler();
        Auth.UserData sampleData = new Auth.UserData('testId', 'testFirst', 'testLast',
                                                     'testFirst testLast', 'testuser@gene.com', null, 'testuserlong', 'en_US', 'facebook',
                                                     null, new Map<String, String>{'language' => 'en_US'});
        String pid = [SELECT  Id FROM Profile WHERE Name = 'GNE-INFREQUENT-USER']?.Id;
        Map<string,String> tempUser =  new Map<String, String>
        {'language' => 'en_US' ,
            'Username'=>'testaskdhjkasdj@gene.com' ,
            'LastName'=>'asdjhgasjhd',
            'Email'=>'askdasgdhgas@gene.com',
            'Alias'=>'asdhagsd',
            'CommunityNickname'=>'asdjasgdjhahsdhasd',
            'TimeZoneSidKey'=>'America/Los_Angeles',
            'LocaleSidKey'=>'en_US',
            'EmailEncodingKey'=>'UTF-8',
            'ProfileId'=>pid,
            'LanguageLocaleKey'=>'en_US' }; 
                
        User u = GNE_FRM_TestUtilities.createUser('testaskdhjkasdj', pid, true);
        
        String uid = u.id;
        
        sampleData = new Auth.UserData('testNewId', 'testNewFirst', 'testNewLast',
                                       'testNewFirst testNewLast', 'testaskdhjkasdj@gene.com', null, 'testnewuserlong', 'en_US', 'facebook',
                                       null, new Map<String, String>{});
        handler.updateUser(uid,null,null,null, '', tempUser,null);
        
        User updatedUser = [SELECT UserName, Email, FirstName, LastName, alias FROM user WHERE id=:uid];
        Group group_PRF_GRP_US = [SELECT Id FROM Group WHERE Name = 'PRF_GRP_US' LIMIT 1];
        GroupMember[] groupMembers = [SELECT Id FROM GroupMember WHERE GroupId =:group_PRF_GRP_US.Id AND UserOrGroupId =:updatedUser.Id];
        System.Assert.areEqual(1, groupMembers.size());
        System.Assert.areEqual('testaskdhjkasdjuser@gene.com', updatedUser.userName);
    }

}