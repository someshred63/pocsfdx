public class GNE_BusinessRoleDetailExt
{

    // business role record
    public GNE_Business_Role__c record { get; set; }
    
    // constructor
    public GNE_BusinessRoleDetailExt(ApexPages.StandardController controller)
    {
        record = [SELECT Id, Name, Active_Groups__c, Active_Permission_Sets__c FROM 
            GNE_Business_Role__c WHERE Id = :controller.getId()];
    }
    
    // method to get all related business role users
    public List<User_Business_Role_gne__c> getUsers()
    {
    
        // declaration(s)
        List<User_Business_Role_gne__c> users = new List<User_Business_Role_gne__c>();
        
        // query for user business roles for current business role
        users = [SELECT Id, Name, Business_Role_gne__c, User_gne__c, Role_Assigned_Date_gne__c FROM
            User_Business_Role_gne__c WHERE Business_Role_gne__c = :record.Name];
            
        // return list
        return (users);
    }
    
    // test method for code coverage
    static testMethod void runTests()
    {
    
        // create test admin user to avoid mix dml issue
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(alias = 'u1test', email='u1test@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='u1test@gene.com');
        insert (u1);
    
        // run as test users
        System.runAs(u1)
        {
    
            // create test permission set
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            PermissionSet ps1 = new PermissionSet(Name = 'SPCM_TEST_PS1', Label = 'SPCM_TEST_PS1', UserLicenseId = ul.Id);
            insert(ps1);
            System.assertNotEquals(ps1, null);
            
            // create test group
            Group g1 = new Group(Name = 'SPCM_TEST_G1', DeveloperName = 'SPCM_TEST_G1');
            insert(g1);
            System.assertNotEquals(g1, null);
            
            // create test business role
            GNE_Business_Role__c br1 = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(br1);
            System.assertNotEquals(br1, null);
            
            // create test user business role
            User_Business_Role_gne__c ubr1 = new User_Business_Role_gne__c(
                Name = u1.Username + '@TEST_BUSINESS_ROLE', Business_Role_gne__c = 'TEST_BUSINESS_ROLE',
                User_gne__c = u1.Id, Role_Assigned_Date_gne__c = DateTime.now(),
                User_RM_Role_Key_gne__c = u1.Username + '@TEST_BUSINESS_ROLE');
            insert (ubr1);
            System.assertNotEquals(ubr1, null);

            // start test
            Test.startTest();

            // set page reference
            PageReference pageRef = Page.GNE_BusinessRoleDetail;
            Test.setCurrentPage(pageRef);
            
            // create controller extenstion
            GNE_BusinessRoleDetailExt controller = new GNE_BusinessRoleDetailExt(
                new ApexPages.StandardController(br1));
            
            // get users
            List<User_Business_Role_gne__c> users = controller.getUsers();
            System.assert(users.size() == 1);

            // stop test
            Test.stopTest();
        }
    }
}