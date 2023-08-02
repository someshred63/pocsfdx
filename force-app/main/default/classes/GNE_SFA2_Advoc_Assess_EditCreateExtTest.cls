@isTest
private class GNE_SFA2_Advoc_Assess_EditCreateExtTest {

    @testSetup
    static void initData() {
        List<User> usersToInsertList = new List<User>{
            new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'GNE-Field' LIMIT 1].Id,
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
    static void testConstructor() {
    	User usr = [SELECT Id FROM User WHERE Username = 'UsTest@gene.com' LIMIT 1];

        System.runAs(usr) {
            PageReference testedPage = Page.GNE_SFA2_Advoc_Assess_Edit_Create_Layout;
            testedPage.getParameters().put('objectId','testId');
            Test.setCurrentPage(testedPage);

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Advocacy_Assessment_gne__c());
            GNE_SFA2_Advoc_Assess_Edit_Create_Ext ctrl = new GNE_SFA2_Advoc_Assess_Edit_Create_Ext(stdCtrl);

            System.assertNotEquals(null, ctrl.myObject);
            System.assertEquals('testId',ctrl.myObject.get('Brand_Affiliations_gne__c') );
            System.assertEquals(UserInfo.getUserId(), ctrl.myObject.get('OwnerId') );


        }
    }
}