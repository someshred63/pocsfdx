@isTest
private class GNE_SFA2_Advoc_Assess_ExtTest {

    @testSetup
    static void initData() {
        List<User> usersToInsertList = new List<User>{
                new User(
                        ProfileId = [SELECT Id FROM Profile WHERE Name = :'GNE-Field' LIMIT 1].Id,
                        TimeZoneSidKey = 'America/Los_Angeles',
                        Email = 'us@gene.com',
                        FirstName = 'usUser',
                        External_ID_gne__c = 'ustest',
                        Alias = 'ustest',
                        Username = 'UsTest@gene.com',
                        EmailEncodingKey = 'UTF-8',
                        LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US',
                        LastName = 'User',
                        IsActive = true
                )
        };

        insert usersToInsertList;

    }

    @isTest
    static void testEdit() {
        User usr = [SELECT Id FROM User WHERE Username = 'UsTest@gene.com' LIMIT 1];

        System.runAs(usr) {
            Account acc = new Account(Name = 'Test Account');
            insert acc;

            Product_vod__c product = new Product_vod__c(
                Manufacturer_gne__c = acc.id,
                Name = 'Test Product'
            );
            insert product;

            Product_Metrics_vod__c pm = new Product_Metrics_vod__c(
                Account_vod__c = acc.ID,
                Products_vod__c = product.Id
            );
            insert pm;

            Advocacy_Assessment_gne__c aa = new Advocacy_Assessment_gne__c(
                Brand_Affiliations_gne__c = pm.Id
            );
            insert aa;

            PageReference aaPage = Page.GNE_SFA2_Advoc_Assess_Layout;
            Test.setCurrentPage(aaPage);

            ApexPages.StandardController stdCtnrl = new ApexPages.StandardController(aa);
            GNE_SFA2_Advoc_Assess_Ext ctrl = new GNE_SFA2_Advoc_Assess_Ext( stdCtnrl );

            PageReference editPage = ctrl.edit();
            PageReference referencePage = Page.GNE_SFA2_Advoc_Assess_Edit_Create_Layout;

            System.assert( editPage.getUrl().containsIgnoreCase(  referencePage.getUrl() ) );
            System.assertEquals( aa.ID, editPage.getParameters().get('id') );
        }

    }
}