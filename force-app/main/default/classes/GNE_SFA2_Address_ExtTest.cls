@isTest
private class GNE_SFA2_Address_ExtTest {
    @isTest
    static void testEdit() {
        User usr = GNE_SFA2_Util.selectSFA2User();
        System.runAs(usr) {
        	Account acc = new Account(Name = 'Test Account');
        	insert acc;

        	Address_vod__c address = new Address_vod__c(
        		Account_vod__c = acc.Id
        		);

        	insert address;

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(address);
            GNE_SFA2_Address_Ext ctrl = new GNE_SFA2_Address_Ext(stdCtrl);

            PageReference addressPage = Page.GNE_SFA2_Address_Layout;
            addressPage.getParameters().put('id',address.id);

            Test.setCurrentPage(addressPage);

            PageReference referencePage = Page.GNE_SFA2_Address_Edit_Create_Layout;
            PageReference testedPage = ctrl.edit();
            
            System.assert( testedPage.getUrl().containsIgnoreCase( referencePage.getUrl() ) );

            System.assertEquals(address.id, testedPage.getParameters().get('id') );
        }

    }

    @isTest
    static void testDataChangeRequestClick() {
        User usr = GNE_SFA2_Util.selectSFA2User();
        System.runAs(usr) {
        	Account acc = new Account(Name = 'Test Account');
        	insert acc;

        	Address_vod__c address = new Address_vod__c(
        		Account_vod__c = acc.Id
        		);

        	insert address;

            ApexPages.StandardController stdCtrl = new ApexPages.StandardController(address);
            GNE_SFA2_Address_Ext ctrl = new GNE_SFA2_Address_Ext(stdCtrl);

            PageReference addressPage = Page.GNE_SFA2_Address_Layout;
            addressPage.getParameters().put('id',address.id);

            Test.setCurrentPage(addressPage);

            PageReference referencePage = Page.GNE_SFA2_Address_Edit_Create_Layout;
            PageReference testedPage = ctrl.edit();
            
            System.assert( testedPage.getUrl().containsIgnoreCase( referencePage.getUrl() ),  testedPage.getUrl());

            System.assertEquals(address.id, testedPage.getParameters().get('id') );
        }
    }
}