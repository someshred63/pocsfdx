/****************************************************************************************************************
*  Modification History
*  Date            Name                 Description
*  15.07.2014      Lukasz Bieniawski    New sync logic for ManagerId User field - per SFA-784 point 5 
										- trigger modification instead of new batch logic.
                                        Test class GNE_SFA2_All_User_Hierarchy_Test added.
*****************************************************************************************************************/

public class GNE_AllUserHistoryUtils {

    // static variable to allow for disabling of future calls
    // (mainly for testing and to void calling a future method from 
    // another future method which will fail)
    public static boolean DisableFutureCalls { get; set; }
    static {
        DisableFutureCalls = false;
    }

    // method to handle insert event
    public static void HandleInsert(List<All_User_Hierarchy_gne__c> records) {
        // retrieve ids
        List<String> recordIds = new List<String>();
        for (All_User_Hierarchy_gne__c record : records) {
            recordIds.add(record.Id);
        }

        // call method to sync user record if not disabled
        if (recordIds.size() > 0 && DisableFutureCalls == false) {
            try {
                SyncUserRecord(recordIds);
            }
            catch (AsyncException ae) { }
        }
    }
    
    // method to handle update event
    public static void HandleUpdate(List<All_User_Hierarchy_gne__c> oldRecords, List<All_User_Hierarchy_gne__c> newRecords) {
        // retrieve ids and inactive records
        List<String> recordIds = new List<String>();
        List<All_User_Hierarchy_gne__c> inactives = new List<All_User_Hierarchy_gne__c>();
        //for (All_User_Hierarchy_gne__c newRecord : newRecords)
        for (integer i = 0; i < newRecords.size(); i++) {        
            // if first name, last name or active has changed
            if (newRecords[i].FirstName_gne__c != oldRecords[i].FirstName_gne__c ||
                newRecords[i].LastName_gne__c != oldRecords[i].LastName_gne__c ||
                newRecords[i].Active_gne__c != oldRecords[i].Active_gne__c ||
                newRecords[i].All_User_Hierarchy_Level1_gne__c != oldRecords[i].All_User_Hierarchy_Level1_gne__c) {                
                recordIds.add(newRecords[i].Id);                
            }
            if (newRecords[i].Active_gne__c != oldRecords[i].Active_gne__c && newRecords[i].Active_gne__c == false) {
                inactives.add(newRecords[i]);
            }
        }

        // if any records are now inactive
        if (inactives.size() > 0) {
            HandleInactivations(inactives);
        }

        // call method to sync user record if not disabled
        if (recordIds.size() > 0 && DisableFutureCalls == false) {
            try {
                SyncUserRecord(recordIds);
            }
            catch (AsyncException ae) { }
        }
    }
    
    // method to handle inactivations
    private static void HandleInactivations(List<All_User_Hierarchy_gne__c> records) {        
        // retrieve external ids
        List<String> externalIds = new List<String>();
        for (All_User_Hierarchy_gne__c record : records) {
            if (String.isNotBlank(record.User_External_Id_gne__c)) {
                externalIds.add(record.User_External_Id_gne__c);
            }
        }
        
        // query for users
        List<Id> userIds = new List<Id>();
        for (User u : [SELECT Id FROM User WHERE External_Id_gne__c IN :externalIds]) {
            userIds.add(u.Id);
        }
        
        if (userIds.size() > 0) {        
            // query for user business roles
            List<User_Business_Role_gne__c> userBusinessRoles = [SELECT Id FROM User_Business_Role_gne__c WHERE User_gne__c IN :userIds];
                            
            // delete user business roles
            if (userBusinessRoles.size() > 0) {
                delete (userBusinessRoles);
            }
            
            // update user delegations
           // UpdateUserDelegationsNonFuture(userIds);
        }
    }
    
    // method to sync user record (future annotated to
    //    avoid MIXED_DML exceptions)
    @future
    public static void SyncUserRecord(List<String> recordIds) {
    	GNE_SFA2_All_User_Hierarchy_Utils.SyncUserRecordByHierarchyIds(recordIds);
    }
    
    // test method for code coverage
    static testMethod void runInsertTests() {        
        // create test user to avoid mix dml issue
        Profile p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user1 = new User(alias = 'u1test', email='u1test@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1.Id,
            timezonesidkey='America/Los_Angeles', username='u1test@gene.com');
        insert (user1);
        User user2 = null;
        User user3 = null;
        All_User_Hierarchy_gne__c auh2 = null;
        All_User_Hierarchy_gne__c auh3 = null;
        User_Business_Role_gne__c ubr1 = null;
        
        // disable user delegation future calls
       // GNE_UserDelegationUtils.DisableFutureCalls = true;
        
        // run as test user
        System.runAs(user1) {
            // create test profile
            Profile p2 = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
         
            // create test users
            user2 = new User(alias = 'u2test', email='u2test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p2.Id,
                timezonesidkey='America/Los_Angeles', username='u2test@gene.com',
                External_ID_gne__c = 'u2test');
            insert (user2);
            System.assertNotEquals(user2.Id, null);
            
            // create test users
            user3 = new User(alias = 'u3test', email='u3test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p2.Id,
                timezonesidkey='America/Los_Angeles', username='u3test@gene.com',
                External_ID_gne__c = 'u3test');
            insert (user3);
            System.assertNotEquals(user3.Id, null);

            // create test user business role
            ubr1 = new User_Business_Role_gne__c(
                Name = 'TEST_BUSINESS_ROLE', Business_Role_gne__c = 'TEST_BUSINESS_ROLE',
                Role_Assigned_Date_gne__c = Datetime.now(), User_gne__c = user3.Id, 
                User_RM_Role_Key_gne__c = 'u3test@TEST_BUSINESS_ROLE');
            insert (ubr1);
            System.assertNotEquals(ubr1.Id, null);

            // start tests
            Test.startTest();

            // create all user history record
            auh2 = new All_User_Hierarchy_gne__c(
                User_External_Id_gne__c = 'u2test', FirstName_gne__c = 'testauh2',
                LastName_gne__c = 'testauh2', email_id__c = 'u2testauh@gene.com',
                Active_gne__c = true);
            insert (auh2);
            System.assertNotEquals(auh2.Id, null);
            
            // create all user history record
            auh3 = new All_User_Hierarchy_gne__c(
                User_External_Id_gne__c = 'u3test', FirstName_gne__c = 'testauh3',
                LastName_gne__c = 'testauh3', email_id__c = 'u3testauh@gene.com',
                Active_gne__c = true);
            insert (auh3);
            System.assertNotEquals(auh3.Id, null);
            
            // update all user history record
            auh3.FirstName_gne__c = 'testauh3-updated';
            auh3.LastName_gne__c = 'testauh3-updated';
            auh3.email_id__c = 'u3testauhupdated@gene.com';
            auh3.Active_gne__c = false;
            update (auh3);
            
            // stop tests
            Test.stopTest();
        }
        
        // run assertions
        user2 = [SELECT Id, FirstName, LastName, Email, IsActive FROM User WHERE Id = :user2.Id];
        System.assertEquals(user2.FirstName, 'testauh2');
        System.assertEquals(user2.LastName, 'testauh2');
        System.assertNotEquals(user2.Email, 'u2testauh@gene.com');
        System.assertEquals(user2.IsActive, true);       
        user3 = [SELECT Id, FirstName, LastName, Email, IsActive FROM User WHERE Id = :user3.Id];
        System.assertEquals(user3.FirstName, 'testauh3-updated');
        System.assertEquals(user3.LastName, 'testauh3-updated');
        System.assertNotEquals(user3.Email, 'u3testauh@gene.com');
        System.assertEquals(user3.IsActive, false);
    }
}