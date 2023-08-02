@isTest
private class GNE_SFA2_BTT_MBO_Edit_Create_Ctrl_Test {
    static testMethod void createTest() {
        SFA2_PREP_Testing_Strategy_gne__c strat = new SFA2_PREP_Testing_Strategy_gne__c(Name='Test', Region_Code_gne__c=1);
        insert strat;

        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.GNE_SFA2_BTT_MBO_Edit_Create'));
            GNE_SFA2_BTT_MBO_Edit_Create_Ctrl ctrl = new GNE_SFA2_BTT_MBO_Edit_Create_Ctrl();

            System.assertEquals(null, System.currentPageReference().getParameters().get('id'));

            ctrl.Mbo.Testing_Strategy_ref_gne__c = strat.Id;
            ctrl.Mbo.Short_Description_gne__c = 'DECS';

            System.assertEquals('/apex/GNE_SFA2_BTT_Admin_Panel', EncodingUtil.urlDecode(ctrl.submit().getURL(), 'UTF-8'));
            System.assertEquals(1, [SELECT COUNT() FROM SFA2_PREP_MBO_gne__c WHERE Id = :ctrl.Mbo.Id]);

            ctrl.Mbo.Testing_Strategy_ref_gne__c = strat.Id;
            ctrl.Mbo.Short_Description_gne__c = 'DECS';

            System.assertEquals('/apex/GNE_SFA2_BTT_MBO_Edit_Create?retURL=/apex/GNE_SFA2_BTT_Admin_Panel', EncodingUtil.urlDecode(ctrl.quickSubmit().getURL(), 'UTF-8'));
            System.assertEquals(1, [SELECT COUNT() FROM SFA2_PREP_MBO_gne__c WHERE Id = :ctrl.Mbo.Id]);

        Test.stopTest();
    }

    static testMethod void editTest() {
        SFA2_PREP_Testing_Strategy_gne__c strat = new SFA2_PREP_Testing_Strategy_gne__c(Name='Test', Region_Code_gne__c=1);
        insert strat;

        SFA2_PREP_MBO_gne__c mbo = new SFA2_PREP_MBO_gne__c(Testing_Strategy_ref_gne__c=strat.Id, Short_Description_gne__c='DESC');
        insert mbo;

        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.GNE_SFA2_BTT_MBO_Edit_Create'));
            System.currentPageReference().getParameters().put('id', mbo.Id);
            GNE_SFA2_BTT_MBO_Edit_Create_Ctrl ctrl = new GNE_SFA2_BTT_MBO_Edit_Create_Ctrl();

            System.assertNotEquals(null, ctrl.Mbo.Id);

        Test.stopTest();
    }

    static testMethod void goBackTest() {
        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.GNE_SFA2_BTT_MBO_Edit_Create'));

            GNE_SFA2_BTT_MBO_Edit_Create_Ctrl ctrl = new GNE_SFA2_BTT_MBO_Edit_Create_Ctrl();
            System.assertEquals('/', ctrl.goBack().getURL());

            System.currentPageReference().getParameters().put('retURL', '/apex/TestRoute');
            
            ctrl = new GNE_SFA2_BTT_MBO_Edit_Create_Ctrl();
            System.assertNotEquals(null, ctrl.retURL);
            System.assertEquals('/apex/TestRoute', ctrl.goBack().getURL());
        
        Test.stopTest();
    }
}