@isTest
private class GNE_SFA2_Account_Tactic_ExtTest {

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
    static void testController() {
        User usr = [SELECT Id FROM User WHERE Username = 'UsTest@gene.com' AND isActive = true LIMIT 1];

        System.runAs(usr) {

            Account account = new Account(Name = 'Test Account');
            insert account;

            Account_Tactic_vod__c at = new Account_Tactic_vod__c(Account_vod__c = account.Id);
            insert at;

            Test.setCurrentPage( Page.GNE_SFA2_Account_Tactic_Layout );

            ApexPages.StandardController stdController = new ApexPages.StandardController(at);
            GNE_SFA2_Account_Tactic_Ext controller = new GNE_SFA2_Account_Tactic_Ext(stdController);

            PageReference testedPage = controller.edit();

            System.assert( testedPage.getUrl().containsIgnoreCase( Page.GNE_SFA2_Account_Tactic_Edit_Layout.getUrl() ) );
            System.assertEquals( at.Id, testedPage.getParameters().get('id') );

            testedPage = controller.editStd();
            System.assert( testedPage.getUrl().containsIgnoreCase( Page.GNE_SFA2_Acc_Tactic_Std_Create_Layout.getUrl() ) );
            System.assertEquals( at.Id, testedPage.getParameters().get('id') );
        }
    }
}