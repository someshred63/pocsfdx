public without sharing class GNE_BusinessRolePermSetExt
{

    // properties
    private GNE_Business_Role_Permission_Set__c record { get; set; }
    private Map<String, Id> permissionSetMap = new Map<String, Id>();
    private ApexPages.StandardController standardController { get; set; }
    
    // constructor
    public GNE_BusinessRolePermSetExt(ApexPages.StandardController controller)
    {
    
        // set standard controller and get record
        standardController = controller;
        record = (GNE_Business_Role_Permission_Set__c)controller.getRecord();
    }

    // retrieve permission sets
    public List<SelectOption> getPermissionSets()
    {
    
        // declaration(s)
        List<SelectOption> options = new List<SelectOption>();
        
        // query for permission sets
        for (PermissionSet ps : [SELECT Id, Name, Label FROM PermissionSet WHERE ProfileId = null ORDER BY Label ASC])
        {
        
            // store permission set in list and add to option list
            permissionSetMap.Put(ps.Label, ps.Id);
            options.add(new SelectOption(ps.Label, ps.Label));
        }

        // return select option list
        return options;
    }
    
    // save overrride
    public PageReference save()
    {
    
        // set permissions set id
        UpdatePermissionSetId();
        
        // execute standard controller save
        return (standardController.save());
    }
    
    // update permission set id
    public void UpdatePermissionSetId()
    {
        
        // set permissions set id
        record.Permission_Set_Id__c = '';
        if (record.Permission_Set__c != null && record.Permission_Set__c != '')
        {
            if (permissionSetMap.containsKey(record.Permission_Set__c))
            {
                record.Permission_Set_Id__c = permissionSetMap.Get(record.Permission_Set__c);
            }
        }
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
    
        // create test permission sets
        PermissionSet ps1 = null;
        PermissionSet ps2 = null;
        System.runAs(u1)
        {
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            ps1 = new PermissionSet(Name = 'SPCM_TEST_PS1', Label = 'SPCM_TEST_PS1', UserLicenseId = ul.Id);
            insert(ps1);
            ps2 = new PermissionSet(Name = 'SPCM_TEST_PS2', Label = 'SPCM_TEST_PS2', UserLicenseId = ul.Id);
            insert(ps2);
        }
        
        // start test
        Test.startTest();
        System.runAs(u1)
        {
        
            // create test business role
            GNE_Business_Role__c br = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(br);
            
            // create test business role permission set
            GNE_Business_Role_Permission_Set__c brps = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = br.Id, Permission_Set__c = 'SPCM_TEST_PS1', Permission_Set_Id__c = ps1.Id);
            insert (brps);
            
            // set page reference
            PageReference pageRef = Page.GNE_BusinessRolePermissionSetDetail;
            Test.setCurrentPage(pageRef);
            
            // create controller extenstion
            GNE_BusinessRolePermSetExt controller = new GNE_BusinessRolePermSetExt(
                new ApexPages.StandardController(brps));
            
            // get permission sets
            List<SelectOption> permissionSets = controller.getPermissionSets();
            System.assert(permissionSets.size() >= 1);
            
            // update permission set value
            controller.record.Permission_Set__c = 'SPCM_TEST_PS2';
            
            // invoke methods
            controller.save();

            // run assertions
            System.assertEquals(controller.record.Permission_Set_Id__c, ps2.Id);
        }

        // stop test
        Test.stopTest();
    }
}