/****************************************************************************************************************
*  @author: Lukasz Bieniawski, Roche (contractor)
*  @email: lukasz.bieniawski@contractors.roche.com
*  Date: 2014-07-16
*  Description: Test Class for GNE_AllUserHistoryUtils
*  
*  Modification History
*  Date            Name               Description
*****************************************************************************************************************/

@isTest
private class GNE_SFA2_All_User_Hierarchy_Test {
        
    static testMethod void runInsertTests() {        
        User sysAdminUser = getTestUser('System Administrator', 0);
        System.runAs(sysAdminUser) {
            List<SObject> sobjList = new List<SObject>();
            
            User user1 = getTestUser('Standard User', 1);
            sobjList.add(user1);
            
            User user2 = getTestUser('Standard User', 2);
            sobjList.add(user2);
            
            insert sobjList;
            sobjList.clear();            

            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE', 
                Business_Role_gne__c = 'TEST_BUSINESS_ROLE',
                Role_Assigned_Date_gne__c = Datetime.now(), 
                User_gne__c = user2.Id, 
                User_RM_Role_Key_gne__c = 'u2test@TEST_BUSINESS_ROLE'
            );
            insert ubr1;

            Test.startTest();
             
            All_User_Hierarchy_gne__c auh1 = getUserHierarchyRecord(user1);
            auh1.FirstName_gne__c = 'testauh1-changed';
            auh1.LastName_gne__c = 'testauh1-changed';
            sobjList.add(auh1);

            All_User_Hierarchy_gne__c auh2 = getUserHierarchyRecord(user2);
            sobjList.add(auh2);
            
            insert sobjList;
            sobjList.clear();
            
            auh2.FirstName_gne__c = 'testauh2-updated';
            auh2.LastName_gne__c = 'testauh2-updated';
            auh2.Active_gne__c = false;
            update auh2;
            
            Test.stopTest();
            
            for (User userRecord : [SELECT Id, FirstName, LastName, IsActive, Role_Mgmt_Managed_User_gne__c FROM User WHERE Id = :user1.Id OR Id = :user2.Id]){
                if (userRecord.Id == user1.Id){
                    if (userRecord.Role_Mgmt_Managed_User_gne__c == 'TRUE'){
                        System.assertEquals(auh1.FirstName_gne__c, userRecord.FirstName);
                        System.assertEquals(auh1.LastName_gne__c, userRecord.LastName);
                    } else {
                        System.assertNotEquals(auh1.FirstName_gne__c, userRecord.FirstName);
                        System.assertNotEquals(auh1.LastName_gne__c, userRecord.LastName);
                    }
                } else if (userRecord.Id == user2.Id){
                    if (userRecord.Role_Mgmt_Managed_User_gne__c == 'TRUE'){
                        System.assertEquals(auh2.FirstName_gne__c, userRecord.FirstName);
                        System.assertEquals(auh2.LastName_gne__c, userRecord.LastName);
                        System.assertEquals(auh2.Active_gne__c, userRecord.IsActive);
                    } else {
                        System.assertNotEquals(auh2.FirstName_gne__c, userRecord.FirstName);
                        System.assertNotEquals(auh2.LastName_gne__c, userRecord.LastName);
                        System.assertNotEquals(auh2.Active_gne__c, userRecord.IsActive);
                    }
                }
            }
            
            List<User_Business_Role_gne__c> userBusinessRolesResult = [SELECT Id FROM User_Business_Role_gne__c WHERE User_gne__c = :user2.Id];
            System.assert(true, userBusinessRolesResult.isEmpty());
        }
    }
    
    static testMethod void runManagerAssignmentTests(){
        User sysAdminUser = getTestUser('System Administrator', 0);
        System.runAs(sysAdminUser) {
            List<SObject> sobjList = new List<SObject>();
            
            User user1 = getTestUser('Standard User', 1);           
            sobjList.add(user1);
            
            User user2 = getTestUser('Standard User', 2);
            sobjList.add(user2);
            
            insert sobjList;
            sobjList.clear();
            
            Test.startTest();
            
            All_User_Hierarchy_gne__c auh1 = getUserHierarchyRecord(user1);
            insert auh1;            
            
            All_User_Hierarchy_gne__c auh2 = getUserHierarchyRecord(user2);            
            auh2.All_User_Hierarchy_Level1_gne__c = auh1.Id;
            insert auh2;
                                    
            Test.stopTest();
            
            for (User userResult : [SELECT Id, IsActive, ManagerId FROM User WHERE Id = :user1.Id OR Id = :user2.Id]){
                if (userResult.Id == user1.Id){
                    // User1 - auh1                 
                    System.assertEquals(null, userResult.ManagerId);
                } else if (userResult.Id == user2.Id){
                    // User2 - auh2                 
                    System.assertEquals(user1.Id, userResult.ManagerId);
                }
            }
        }     
    }
    
    static testMethod void runManagerNotFoundAssignmentTests(){
        User sysAdminUser = getTestUser('System Administrator', 0);
        System.runAs(sysAdminUser) {
            List<SObject> sobjList = new List<SObject>();
            
            User user1 = getTestUser('Standard User', 1);           
            sobjList.add(user1);
            
            User user2 = getTestUser('Standard User', 2);
            sobjList.add(user2);
            
            insert sobjList;
            sobjList.clear();
            
            Test.startTest();
            
            All_User_Hierarchy_gne__c auh1 = getUserHierarchyRecord(user1);
            auh1.User_External_Id_gne__c += 'fake';
            insert auh1;
            
            All_User_Hierarchy_gne__c auh2 = getUserHierarchyRecord(user2);            
            auh2.All_User_Hierarchy_Level1_gne__c = auh1.Id;
            insert auh2;
                                    
            Test.stopTest();
            
            for (User userResult : [SELECT Id, IsActive, ManagerId FROM User WHERE Id = :user1.Id OR Id = :user2.Id]){
                if (userResult.Id == user1.Id){
                    // User1 - auh1
                    System.assertEquals(null, userResult.ManagerId);
                } else if (userResult.Id == user2.Id){
                    // User2 - auh2
                    System.assertEquals(null, userResult.ManagerId);
                }
            }
        }     
    }
    
    static testMethod void runManagerRemoveAssignmentTests(){
        User sysAdminUser = getTestUser('System Administrator', 0);
        System.runAs(sysAdminUser) {
            User user1 = getTestUser('Standard User', 1);           
            insert user1;
            
            User user2 = getTestUser('Standard User', 2);
            user2.ManagerId = user1.Id;
            insert user2;
                        
            Test.startTest();
            
            All_User_Hierarchy_gne__c auh2 = getUserHierarchyRecord(user2);            
            auh2.All_User_Hierarchy_Level1_gne__c = null;
            insert auh2;
            
            All_User_Hierarchy_gne__c auh1 = getUserHierarchyRecord(user1);
            auh1.All_User_Hierarchy_Level1_gne__c = auh2.Id;
            insert auh1;
                                    
            Test.stopTest();
            
            for (User userResult : [SELECT Id, IsActive, ManagerId FROM User WHERE Id = :user1.Id OR Id = :user2.Id]){
                if (userResult.Id == user2.Id){
                    // User2 - auh2
                    System.assertEquals(null, userResult.ManagerId);
                } else if (userResult.Id == user1.Id){
                    // User1 - auh1
                    System.assertEquals(user2.Id, userResult.ManagerId);
                }
            }
        }     
    }
    
    static testMethod void runSetIsUserActiveTests(){
        User sysAdminUser = getTestUser('System Administrator', 0);
        System.runAs(sysAdminUser) {
            List<SObject> sobjList = new List<SObject>();
            
            User user1 = getTestUser('Standard User', 1);
            user1.IsActive = true;          
            sobjList.add(user1);
            
            User user2 = getTestUser('Standard User', 2);
            user2.IsActive = false;         
            sobjList.add(user2);
            
            insert sobjList;
            sobjList.clear();
            
            Test.startTest();
            
            All_User_Hierarchy_gne__c auh1 = getUserHierarchyRecord(user1);
            auh1.Active_gne__c = false;
            sobjList.add(auh1);
            
            All_User_Hierarchy_gne__c auh2 = getUserHierarchyRecord(user2);
            auh2.Active_gne__c = true;
            sobjList.add(auh2);
            
            insert sobjList;
            sobjList.clear();
            
            Test.stopTest();
            
            for (User userResult : [SELECT Id, IsActive, ManagerId, Role_Mgmt_Managed_User_gne__c FROM User WHERE Id = :user1.Id OR Id = :user2.Id]){
                if (userResult.Id == user1.Id){
                    // User1 - auh1
                    if (userResult.Role_Mgmt_Managed_User_gne__c == 'TRUE'){
                        System.assertEquals(false, userResult.IsActive);
                    } else {
                        System.assertNotEquals(false, userResult.IsActive);
                    }
                } else if (userResult.Id == user2.Id){
                    // User2 - auh2 (only deactivation)
                    System.assertEquals(false, userResult.IsActive);
                }               
            }
        }     
    }
    
    static testMethod void runChangeDataOnUpdateTests(){
        User sysAdminUser = getTestUser('System Administrator', 0);
        System.runAs(sysAdminUser) {
            List<SObject> sobjList = new List<SObject>();
            
            User user1 = getTestUser('Standard User', 1);
            sobjList.add(user1);
            
            User user2 = getTestUser('Standard User', 2);
            sobjList.add(user2);
            
            insert sobjList;
            sobjList.clear();
            
            All_User_Hierarchy_gne__c auh1 = getUserHierarchyRecord(user1);            
            sobjList.add(auh1);
            
            All_User_Hierarchy_gne__c auh2 = getUserHierarchyRecord(user2);            
            sobjList.add(auh2);
            
            insert sobjList;
            sobjList.clear();
            
            Test.startTest();
            
            auh1.Active_gne__c = false;
            update auh1;
                        
            auh2.All_User_Hierarchy_Level1_gne__c = auh1.Id;            
            update auh2;
            
            Test.stopTest();
            
            for (User userResult : [SELECT Id, IsActive, ManagerId, Role_Mgmt_Managed_User_gne__c FROM User WHERE Id = :user1.Id OR Id = :user2.Id]){
                if (userResult.Id == user1.Id){
                    // User1 - auh1        
                    if (userResult.Role_Mgmt_Managed_User_gne__c == 'TRUE'){
                        System.assertEquals(false, userResult.IsActive);
                    } else {
                        System.assertNotEquals(false, userResult.IsActive);
                    }
                } else if (userResult.Id == user2.Id){
                    // User2 - auh2 (only deactivation) 
                    if (userResult.Role_Mgmt_Managed_User_gne__c == 'TRUE'){
                        System.assertEquals(null, userResult.ManagerId);
                    } else {
                        System.assertEquals(user1.Id, userResult.ManagerId);
                    }
                }
            }
        }     
    }
    
    static testMethod void runSetManagerCaseInsensitiveTests(){
        User sysAdminUser = getTestUser('System Administrator', 0);
        System.runAs(sysAdminUser) {
            List<SObject> sobjList = new List<SObject>();
            
            User user1 = getTestUser('Standard User', 1);
            user1.External_ID_gne__c = user1.External_ID_gne__c.toUpperCase();
            sobjList.add(user1);
            
            User user2 = getTestUser('Standard User', 2);
            sobjList.add(user2);
            
            insert sobjList;
            sobjList.clear();
            
            Test.startTest();
            
            All_User_Hierarchy_gne__c auh1 = getUserHierarchyRecord(user1);
            auh1.User_External_Id_gne__c = auh1.User_External_Id_gne__c.toLowerCase(); 
            insert auh1;
            
            All_User_Hierarchy_gne__c auh2 = getUserHierarchyRecord(user2);
            auh2.All_User_Hierarchy_Level1_gne__c = auh1.Id; 
            insert auh2;
                        
            Test.stopTest();
            
            for (User userResult : [SELECT Id, IsActive, ManagerId, Role_Mgmt_Managed_User_gne__c FROM User WHERE Id = :user2.Id]){
                System.assertEquals(user1.Id, userResult.ManagerId);
            }
        }     
    }
    
    private static All_User_Hierarchy_gne__c getUserHierarchyRecord(User user){
        return new All_User_Hierarchy_gne__c (
            User_External_Id_gne__c = user.External_ID_gne__c, 
            FirstName_gne__c = user.FirstName,
            LastName_gne__c = user.LastName, 
            email_id__c = user.Email,      
            Active_gne__c = user.IsActive
        );
    }
    
    private static User getTestUser(String profileName, Integer userIndex){
        String userAlias = 'u' + userIndex + 'test';
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User user = new User(
            Alias = userAlias, 
            Email = userAlias + '@gene.com',
            Emailencodingkey = 'UTF-8',
            FirstName = 'FName',             
            Lastname = 'Test', 
            Languagelocalekey = 'en_US',
            Localesidkey = 'en_US', 
            Profileid = profile.Id,
            Timezonesidkey = 'America/Los_Angeles', 
            Username = userAlias + '@gene.com',
            External_ID_gne__c = userAlias,
            IsActive = true
        );
        return user;
    }
}