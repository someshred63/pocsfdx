global class GNE_BusinessRoleUtils
{

    // method to sync permission set names for business roles
    webService static Integer syncRolePermissionSetNames()
    { 
        
        // query for all business role permission sets
        List<GNE_Business_Role_Permission_Set__c> records = [SELECT Id, Permission_Set_Id__c, Permission_Set__c FROM
            GNE_Business_Role_Permission_Set__c];
            
        // loop through records and extract permission set ids
        Map<Id, GNE_Business_Role_Permission_Set__c> permSetMap = new Map<Id, GNE_Business_Role_Permission_Set__c>();
        for (GNE_Business_Role_Permission_Set__c record : records)
        {
            if (!permSetMap.containsKey(record.Permission_Set_Id__c))
            {
                permSetMap.put(record.Permission_Set_Id__c, record);
            }
        }
        
        // query for permission set details
        List<GNE_Business_Role_Permission_Set__c> updates = new List<GNE_Business_Role_Permission_Set__c>();
        for (PermissionSet permSet : [SELECT Id, Label FROM PermissionSet WHERE Id IN :permSetMap.keySet()])
        {
        
            // check for updates
            for (GNE_Business_Role_Permission_Set__c record : records)
            {
                if (record.Permission_Set_Id__c == permSet.Id &&
                    record.Permission_Set__c != permSet.Label)
                {
                    record.Permission_Set__c = permSet.Label;
                    updates.add(record);
                }
            }
            
            // remove from map
            permSetMap.remove(permSet.Id);
        }
        
        // check for records to delete
        if (permSetMap.size() > 0)
        {
            delete (permSetMap.Values());
        }
        
        // if there are updates to make
        if (updates.size() > 0)
        {
            update (updates);
        }
        
        // return records updated
        return (updates.size());
    }
    
    // method to sync public group names for business roles
    webService static Integer syncRolePublicGroupNames()
    { 
        
        // query for all business role public groups
        List<GNE_Business_Role_Public_Group__c> records = [SELECT Id, Public_Group_Id__c, Public_Group__c FROM
            GNE_Business_Role_Public_Group__c];
            
        // loop through records and extract permission set ids
        Map<Id, GNE_Business_Role_Public_Group__c> pubGroupMap = new Map<Id, GNE_Business_Role_Public_Group__c>();
        for (GNE_Business_Role_Public_Group__c record : records)
        {
            if (!pubGroupMap.containsKey(record.Public_Group_Id__c))
            {
                pubGroupMap.put(record.Public_Group_Id__c, record);
            }
        }
        
        // query for public group details
        List<GNE_Business_Role_Public_Group__c> updates = new List<GNE_Business_Role_Public_Group__c>();
        for (Group pubGroup : [SELECT Id, Name FROM Group WHERE Id IN :pubGroupMap.keySet()])
        {
            for (GNE_Business_Role_Public_Group__c record : records)
            {
                if (record.Public_Group_Id__c == pubGroup.Id &&
                    record.Public_Group__c != pubGroup.Name)
                {
                    record.Public_Group__c = pubGroup.Name;
                    updates.add(record);
                }
            }
            
            // remove from map
            pubGroupMap.remove(pubGroup.Id);
        }
        
        // check for records to delete
        if (pubGroupMap.size() > 0)
        {
            delete (pubGroupMap.Values());
        }
        
        // if there are updates to make
        if (updates.size() > 0)
        {
            update (updates);
        }
        
        // return records updated
        return (updates.size());
    }
    
    // test method for code coverage
    static testMethod void runTests()
    {
    
        // create test user to avoid mix dml issue
        List<Profile> p1 = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User u1 = new User(alias = 'u1test', email='u1test@gene.com',
            emailencodingkey='UTF-8', lastname='Test', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p1[0].Id,
            timezonesidkey='America/Los_Angeles', username='u1test@gene.com');
        insert (u1);
        
        // run as test user
        System.runAs(u1)
        {
        
            // create test permission sets
            UserLicense ul = [SELECT Id FROM UserLicense WHERE Name = 'Salesforce'];
            PermissionSet ps1 = new PermissionSet(Name = 'SPCM_TEST_PS1', Label = 'SPCM_TEST_PS1', UserLicenseId = ul.Id);
            insert(ps1);
            PermissionSet ps2 = new PermissionSet(Name = 'SPCM_TEST_PS2', Label = 'SPCM_TEST_PS2', UserLicenseId = ul.Id);
            insert(ps2);
            System.assertNotEquals(ps1.Id, null);
            System.assertNotEquals(ps2.Id, null);
            
            // create test groups
            Group g1 = new Group(Name = 'SPCM_TEST_G1', DeveloperName = 'SPCM_TEST_G1');
            insert(g1);
            Group g2 = new Group(Name = 'SPCM_TEST_G2', DeveloperName = 'SPCM_TEST_G2');
            insert(g2);
            System.assertNotEquals(g1.Id, null);
            System.assertNotEquals(g2.Id, null);

            // create test business role
            GNE_Business_Role__c br = new GNE_Business_Role__c(Name = 'TEST_BUSINESS_ROLE');
            insert(br);
            System.assertNotEquals(br.Id, null);
            
            // create test business role permission sets
            GNE_Business_Role_Permission_Set__c brps1 = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = br.Id, Permission_Set__c = 'SPCM_TEST_PS1', Permission_Set_Id__c = ps1.Id);
            insert (brps1);
            GNE_Business_Role_Permission_Set__c brps2 = new GNE_Business_Role_Permission_Set__c(
                Business_Role__c = br.Id, Permission_Set__c = 'SPCM_TEST_PS2', Permission_Set_Id__c = ps2.Id);
            insert (brps2);
            System.assertNotEquals(brps1.Id, null);
            System.assertNotEquals(brps2.Id, null);
            
            // create test business role public groups
            GNE_Business_Role_Public_Group__c brpg1 = new GNE_Business_Role_Public_Group__c(
                Business_Role__c = br.Id, Public_Group__c = 'SPCM_TEST_G1', Public_Group_Id__c = g1.Id);
            insert (brpg1);
            GNE_Business_Role_Public_Group__c brpg2 = new GNE_Business_Role_Public_Group__c(
                Business_Role__c = br.Id, Public_Group__c = 'SPCM_TEST_G2', Public_Group_Id__c = g2.Id);
            insert (brpg2);
            System.assertNotEquals(brpg1.Id, null);
            System.assertNotEquals(brpg2.Id, null);
            
            // sync names sets to set the bar
            GNE_BusinessRoleUtils.syncRolePermissionSetNames();
            GNE_BusinessRoleUtils.syncRolePublicGroupNames();
            
            // update permission set and group names/labels
            ps1.Label = 'SPCM_TEST_PS1_UPDATED';
            update (ps1);
            g1.Name = 'SPCM_TEST_G1_UPDATED';
            update (g1);
            
            // delete permission set and public group
            delete (ps2);
            delete (g2);
            
            // sync names and run assertions
            Integer permSetCount = GNE_BusinessRoleUtils.syncRolePermissionSetNames();
            System.assertEquals(permSetCount, 1);
            Integer pubGroupCount = GNE_BusinessRoleUtils.syncRolePublicGroupNames();
            System.assertEquals(pubGroupCount, 1);
        }
    }
}