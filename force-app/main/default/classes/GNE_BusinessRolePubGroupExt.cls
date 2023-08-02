public without sharing class GNE_BusinessRolePubGroupExt
{

    // properties
    private GNE_Business_Role_Public_Group__c record { get; set; }
    private Map<String, Id> publicGroupMap = new Map<String, Id>();
    private ApexPages.StandardController standardController { get; set; }
    
    // constructor
    public GNE_BusinessRolePubGroupExt(ApexPages.StandardController controller)
    {
    
        // set standard controller and get record
        standardController = controller;
        record = (GNE_Business_Role_Public_Group__c)controller.getRecord();
    }

    // retrieve public groups
    public List<SelectOption> getPublicGroups()
    {
    
        // declaration(s)
        List<SelectOption> options = new List<SelectOption>();
        
        // query for public groups
        for (Group g : [SELECT Id, Name FROM Group WHERE Type = 'Regular' ORDER BY Name ASC])
        {
        
            // store public group in list and add to option list
            publicGroupMap.Put(g.Name, g.Id);
            options.add(new SelectOption(g.Name, g.Name));
        }

        // return select option list
        return options;
    }
    
    // save overrride
    public PageReference save()
    {
    
        // set public group id
        UpdatePublicGroupId();
        
        // execute standard controller save
        return (standardController.save());
    }
    
    // update public group id
    public void UpdatePublicGroupId()
    {
        
        // set public group id
        record.Public_Group_Id__c = '';
        if (record.Public_Group__c != null && record.Public_Group__c != '')
        {
            if (publicGroupMap.containsKey(record.Public_Group__c))
            {
                record.Public_Group_Id__c = publicGroupMap.Get(record.Public_Group__c);
            }
        }
    }

    // test method for code coverage
    static testMethod void runTests()
    {
    
        // create test admin user to avoid mix dml issue
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(alias = 'u1test', email='testuser1@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='testuser1@gene.com');
        insert (u1);
    
        // create test public groups
        Group g1 = null;
        Group g2 = null;
        System.runAs(u1)
        {
            g1 = new Group(Name = 'SPCM_TEST_G1', DeveloperName = 'SPCM_TEST_G1');
            insert(g1);
            g2 = new Group(Name = 'SPCM_TEST_G2', DeveloperName = 'SPCM_TEST_G2');
            insert(g2);
        }
        
        // start test
        Test.startTest();
        System.runAs(u1)
        {
        
            // create test external role
            GNE_Business_Role__c br = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(br);
            
            // create test business role public group
            GNE_Business_Role_Public_Group__c brps = new GNE_Business_Role_Public_Group__c(
                Business_Role__c = br.Id, Public_Group__c = 'SPCM_TEST_G1', Public_Group_Id__c = g1.Id);
            insert (brps);
            
            // set page reference
            PageReference pageRef = Page.GNE_BusinessRolePublicGroupDetail;
            Test.setCurrentPage(pageRef);
            
            // create controller extenstion
            GNE_BusinessRolePubGroupExt controller = new GNE_BusinessRolePubGroupExt(
                new ApexPages.StandardController(brps));
            
            // get public groups
            List<SelectOption> publicGroups = controller.getPublicGroups();
            System.assert(publicGroups.size() >= 1);
            
            // update public group value
            controller.record.Public_Group__c = 'SPCM_TEST_G2';
            
            // invoke methods
            controller.save();
            
            // run assertions
            System.assertEquals(controller.record.Public_Group_Id__c, g2.Id);
        }

        // stop test
        Test.stopTest();
    }
}