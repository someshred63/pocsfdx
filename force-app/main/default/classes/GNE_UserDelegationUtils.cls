public without sharing class GNE_UserDelegationUtils
{

    // static variable to allow for disabling of future calls
    // (mainly for testing and to void calling a future method from 
    // another future method which will fail)
    public static boolean DisableFutureCalls { get; set; }
    static 
    {
        DisableFutureCalls = false;
    }
    
    // method to handle inserts
    public static void HandleAfterInsert(List<User> records)
    {
    
        // retrieve each user id that was inserted/updated and add to list
        List<ID> userIDs = new List<ID>();
        for (User record : records)
        {
            
            // if user is a standard user (i.e. non-portal user)
            if (record.UserType == 'Standard')
            {
                userIDs.Add(record.Id);
            }
        }
        
        // update user delegations (future async call) if not disabled
        if (userIDs.size() > 0 && !DisableFutureCalls)
        {
        
            // call a @future method to update user delegations
            try
            {
                UpdateUserDelegations(userIDs);
            }
            catch (AsyncException ae)
            { }
        }
    }
    
    // method to handle inserts
    public static void HandleAfterUpdate(List<User> oldRecords, List<User> newRecords)
    {
    
        // retrieve each user id that was inserted/updated and add to list
        List<ID> userIDs = new List<ID>();
        for (integer i = 0; i < newRecords.size(); i++)
        {
            
            // if user is a standard user (i.e. non-portal user)
            if (newRecords[i].UserType == 'Standard')
            {
            
                // if active or username changed
                if (newRecords[i].IsActive != oldRecords[i].IsActive ||
                    newRecords[i].Username != oldRecords[i].Username)
                {
                    userIDs.Add(newRecords[i].Id);
                }
            }
        }
        
        // update user delegations (future async call) if not disabled
        if (userIDs.size() > 0 && !DisableFutureCalls)
        {
        
            // call a @future method to update user delegations
            try
            {
                UpdateUserDelegations(userIDs);
            }
            catch (AsyncException ae)
            { }
        }     
    }

   // future method to handle user delegation updates from user inserts/updates 
    @future
    public static void UpdateUserDelegations(List<ID> userIDs)
    {
        UpdateUserDelegationsNonFuture(userIDs);
    }
    
    // handles user delegation updates from non-user inserts/updates
    public static void UpdateUserDelegationsNonFuture(List<ID> userIDs)
    {

        // query to get user details
        List<User> users = [SELECT Id, Username FROM User WHERE Id IN :userIDs And Isactive=true];
       
        // query for existing user delegations for the list of users
        List<GNE_User_Delegation__c> userDelegations = [SELECT Id, Name, OwnerId FROM GNE_User_Delegation__c 
            WHERE OwnerId IN :userIDs];
        
        // loop through users
        for (User u : users)
        {
        
            // boolean to indicate if user delegation was found
            Boolean found = false;
            
            // loop through user delegations
            for (Integer i = 0; i < userDelegations.size(); i++)
            {
            
                // if the user is the owner of the user delegation
                if (u.Id == userDelegations[i].OwnerId)
                {
                
                    // update user delegation name
                    userDelegations[i].Name = u.Username;
                   
                    // mark as found and break for loop
                    found = true;
                    break;
                }
            }
            
            // if no user delegation found then create it
            if (!found)
            {
                userDelegations.Add(new GNE_User_Delegation__c(Name = u.Username, OwnerId = u.Id));
            }
        }
        
        // if there are user delegations to upsert, then upsert them
        if (userDelegations.size() > 0)
        {
            upsert (userDelegations);
        }
    }

    // method to check for user delegation for the provided user id
    public static String GetDelegatedUser(String userID)
    {

        // if valid user id passed in
        if (userID != null)
        {
        
            // query for active user delegation record for provided user id
            List<GNE_User_Delegation__c> userDelegation = [SELECT Delegated_User__c
FROM GNE_User_Delegation__c WHERE OwnerId = :userID AND Is_Delegation_Active__c = 'Yes' AND RecordType.Name='SPCM'];
            
            // if user delegation found
            if (userDelegation.size() == 1)
            {
                userID = userDelegation[0].Delegated_User__c; 
            }
        }
        
        // return user id
        return (userID);
    }
 
     // test method for user inserts
    static testMethod void runUserInsertTests()
    {

        // retrieve admin profile
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        // start test
        Test.startTest();

        // insert test users
        List<User> users = new List<User>();
        for (integer i = 0; i < 200; i++)
        {
            users.add(new User(alias = 'u' + i + 'test', email='u' + i + 'test@gene.com',
                emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1[0].Id,
                timezonesidkey='America/Los_Angeles', username='u' + i + 'test@gene.com'));
        }
        insert (users);
        
        // stop test
        Test.stopTest();
        
        // retrieve ids
        Set<Id> userIds = new Set<Id>();
        for (User u : users)
        {
            userIds.add(u.Id);
        }
        
        // run assertions
        List<GNE_User_Delegation__c> userDelegations = [SELECT Id, Name FROM GNE_User_Delegation__c WHERE OwnerId IN :userIds];
        System.assertEquals(userDelegations.size(), 200);
    }
    
    // test method for user updates
    static testMethod void runUserUpdateTests()
    {
        
        // create test user to avoid MIXED_DML errors
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(alias = 'dmltest', email='dmltest@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='dmltest@gene.com');
        insert (u1);
        
        // run as test user
        System.runAs(u1)
        {
        
            // insert test users
            List<User> users = new List<User>();
            for (integer i = 0; i < 200; i++)
            {
                users.add(new User(alias = 'u' + i + 'test', email='u' + i + 'test@gene.com',
                    emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p1[0].Id,
                    timezonesidkey='America/Los_Angeles', username='u' + i + 'test@gene.com'));
            }
            insert (users);
            
            // insert test user delegations
            List<GNE_User_Delegation__c> userDelegations = new List<GNE_User_Delegation__c>();
            for (integer i = 0; i < 200; i++)
            {
                userDelegations.add(new GNE_User_Delegation__c(Name = users[i].Username, 
                    OwnerId = users[i].Id));
            }
            insert (userDelegations);
        
            // start test
            Test.startTest();

            // update users
            for (integer i = 0; i < 200; i++)
            {
                users[i].Username = 'u' + i + 'test@gene.com_upd';
            }
            update (users);
        
            // stop test
            Test.stopTest();
            
            // get user delegation ids
            Set<Id> userDelegationIds = new Set<Id>();
            for (GNE_User_Delegation__c userDelegation : userDelegations)
            {
                userDelegationIds.add(userDelegation.Id);
            }
            
            // run assertions
            userDelegations = [SELECT Id, Name, OwnerId FROM GNE_User_Delegation__c 
                WHERE Id IN :userDelegationIds];
            System.assertEquals(userDelegations.size(), 200);
            for (GNE_User_Delegation__c userDelegation : userDelegations)
            {
                for (User u : users)
                {
                    if (u.Id == userDelegation.OwnerId)
                    {
                        System.assertEquals(u.Username, userDelegation.Name);
                    }
                }
            }
        }
    }
       
    // test method for code coverage
    static testMethod void runGetDelegatedUserTest()
    {
    
        // create test users
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u1 = new User(alias = 'u1test', email='testuser1@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='testuser1@gene.com');
        insert (u1);
        User u2 = new User(alias = 'u2test', email='testuser2@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='testuser2@gene.com');
        insert (u2);
        
        // create test user delegation
        GNE_User_Delegation__c ud = new GNE_User_Delegation__c(Name = u1.Username,
            OwnerId = u1.Id, Delegated_User__c = u2.Id, Start_Date__c = System.today() - 1,
            End_Date__c = System.today() + 1, Comments__c = 'Testing user delegation');
        insert (ud);
        
        // start test
        Test.startTest();
        
        // get delegated user
        String delegatedId = GNE_UserDelegationUtils.GetDelegatedUser(u1.Id);
        System.assertEquals(delegatedId, u2.Id);
        
        // stop test
        Test.stopTest();
    }
}