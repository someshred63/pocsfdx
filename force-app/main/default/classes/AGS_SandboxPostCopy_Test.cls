/** @date 01/28/2017
* @Author Gabriel Juriewicz
* @description Unit Test for AGS_SandboxPostCopy_SetupCustomSettings Sandbox Post Copy Script
*/
@isTest
private class AGS_SandboxPostCopy_Test {
    @isTest
    static void testSandboxPostCopyScript() {
        // GIVEN
        AGS_SandboxPostCopy apexClass = new AGS_SandboxPostCopy();
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        User u = new User(
            FirstName           = 'AGGS',
            Alias               = 'gssptest',
            Email               = 'sandboxtestuser@gene.com',
            EmailEncodingKey    = 'UTF-8',
            LastName            = 'Case Monitor',
            LanguageLocaleKey   = 'en_US',
            LocaleSidKey        = 'en_US',
            ProfileId           = p.Id,
            TimeZoneSidKey      = 'America/Los_Angeles',
            Username            = 'sandboxtestuser@gene.com',
            External_ID_gne__c  = 'sandboxtestuser',
            IsActive            = true
        );
        insert u;
        All_User_Hierarchy_gne__c auh1 = new All_User_Hierarchy_gne__c(Name = 'auh1' , email_id__c = 'test@gene.com', User_External_Id_gne__c = 'sandboxtestuser', FirstName_gne__c = 'firstName', LastName_gne__c = 'lastName');
        insert auh1;

        All_User_Hierarchy_gne__c auh2 = new All_User_Hierarchy_gne__c(Name = 'auh2', email_id__c = 'test@gene.com', User_External_Id_gne__c = 'testExternalId', FirstName_gne__c = 'firstName', LastName_gne__c = 'lastName');
        insert auh2;

        AGS_Case_gne__c agsCase = AGS_TestUtil.createAgsCase();

        AGS_Case_Action_gne__c caseAction = new AGS_Case_Action_gne__c(AGS_Case_gne__c = agsCase.Id, AGS_Case_Analyst_Email_gne__c = 'analyst@gene.com');
        insert caseAction;

        AGS_ST_User_gne__c stUserWithRelationToUser = new AGS_ST_User_gne__c(SFDC_User__c = u.Id, Last_name__c = 'stUserWithRelation', Email_address__c = 'testEmail@gene.com');
        insert stUserWithRelationToUser;

        AGS_ST_User_gne__c stUserWithNoRelationToUser = new AGS_ST_User_gne__c(Last_name__c = 'stUserWithNoRelation', Email_address__c = 'testEmail@gene.com');
        insert stUserWithNoRelationToUser;
        // WHEN
        Test.startTest();
        System.Test.testSandboxPostCopyScript(apexClass, UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), 'dev');
        Test.stopTest();

        // THEN
        // Assert AGS_Email_Links__c
        AGS_Email_Links__c[] emailLinks = AGS_Email_Links__c.getall().values();
        System.assertEquals(1, emailLinks.size(), 'SandboxPostCopy script should create 1 AGS_Email_Links__c record.');
        System.assertEquals('Sandbox', emailLinks[0].Name, 'SandboxPostCopy script should create 1 AGS_Email_Links__c record with \'sandbox\' name.');
        System.assertEquals('https://comm.gene.com/', emailLinks[0].AGS_commportal_link__c, 'SandboxPostCopy script should create 1 AGS_Email_Links__c record and assign propper value to AGS_commportal_link__c field.');

        String b2bLink;
        if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('uat')) {
            b2bLink = 'https://b2bua.gene.com';
        } else if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('sqa')) {
            b2bLink = 'https://b2bqa.gene.com';
        } else {
            b2bLink = 'https://b2bdev.gene.com';
        }

        System.assertEquals(b2bLink, emailLinks[0].AGS_b2b_link__c, 'SandboxPostCopy script should create 1 AGS_Email_Links__c record and assign propper value to AGS_b2b_link__c field.');

        // Assert AGS_ST_Settings_gne__c
        AGS_ST_Settings_gne__c[] stSettings = AGS_ST_Settings_gne__c.getall().values();
        System.assertEquals(1, stSettings.size(), 'SandboxPostCopy script should create 1 AGS_ST_Settings_gne__c record.');
        System.assertEquals('f0l0wth3wr', stSettings[0].ARX_Password_gne__c, 'SandboxPostCopy script should create 1 AGS_ST_Settings_gne__c record and assign propper value to ARX_Password_gne__c field.');
        String sandboxName;

        if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('sqa')) {
            sandboxName = 'sqa';
        } else if (URL.getSalesforceBaseUrl().getHost().containsIgnoreCase('uat')) {
            sandboxName = 'uat';
        } else {
            sandboxName = 'dev';
        }

        System.assertEquals(sandboxName, stSettings[0].Name, 'SandboxPostCopy script should create 1 AGS_ST_Settings_gne__c record and assign propper value to Name field.');

        // Assert VDST_Settings__c
        VDST_Settings__c[] vdstSettings = VDST_Settings__c.getall().values();
        System.assertEquals(1, vdstSettings.size(), 'SandboxPostCopy script should create 1 VDST_Settings__c record.');
        System.assertEquals('W0nP@sC#', vdstSettings[0].SIMS_Password__c, 'SandboxPostCopy script should create 1 VDST_Settings__c record and assing propper value to SIMS_Password__c field.');
        System.assertEquals(sandboxName, vdstSettings[0].Name, 'SandboxPostCopy script should create 1 vdstSettings record and assign propper value to Name field.');

        // Assert All_User_Hierarchy_gne__c email mapping
        auh1 = [SELECT email_id__c FROM All_User_Hierarchy_gne__c WHERE Name = 'auh1'];
        System.assertEquals('sandboxtestuser@gene.com', auh1.email_id__c, 'Batch execute method, should assign to email_id__c field of UAH record, an email of user with same external Id.');

        auh2 = [SELECT email_id__c FROM All_User_Hierarchy_gne__c WHERE Name = 'auh2'];
        System.assertEquals('test=gene.com@example.com', auh2.email_id__c, 'Batch execute method, should format email_id__c field of AUH record if no user with the same external Id was found.');
    
        // Assert AGS_Case_Action_gne__c email formating
        caseAction = [SELECT AGS_Case_Analyst_Email_gne__c, AGS_Case_Resolver_Email_gne__c FROM AGS_Case_Action_gne__c];
        System.assertEquals('analyst=gene.com@example.com', caseAction.AGS_Case_Analyst_Email_gne__c, 'Batch execute method, should format AGS_Case_Analyst_Email_gne__c field to example.com email.');
        System.assertEquals(null, caseAction.AGS_Case_Resolver_Email_gne__c, 'Batch execute method, should not format AGS_Case_Analyst_Email_gne__c field if field is empty in a first place.');

        // seert AGS_ST_User_gne__c email mapping or formating
        stUserWithRelationToUser = [SELECT Email_address__c FROM AGS_ST_User_gne__c WHERE Last_name__c = 'stUserWithRelation'];
        System.assertEquals('sandboxtestuser@gene.com', stUserWithRelationToUser.Email_address__c, 'Batch execute method, should map email of related User object to Email_address__c of AGS ST User if such relation exists.');

        stUserWithNoRelationToUser = [SELECT Email_address__c FROM AGS_ST_User_gne__c WHERE Last_name__c = 'stUserWithNoRelation'];
        System.assertEquals('testemail=gene.com@example.com', stUserWithNoRelationToUser.Email_address__c, 'Batch execute method, should format Email_address__c field of AGS ST User, if record has no relation to User object.');
    }
}