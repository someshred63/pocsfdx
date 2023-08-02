@isTest
private class GNE_SFA2_BTT_Strategy_Edit_Create_Test {
    static testMethod void createTest() {
        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.GNE_SFA2_BTT_Strategy_Edit_Create'));
            GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl ctrl = new GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl();

            System.assertEquals(null, System.currentPageReference().getParameters().get('id'));
            System.assertEquals(true, ctrl.isEditable);
            System.assertEquals(null, ctrl.Strategy.Id);

            ctrl.Strategy.Name = 'Test';
            ctrl.Strategy.Region_Code_gne__c = 1;
            ctrl.Strategy.Active_for_Call_gne__c = true;

            String url = EncodingUtil.urlDecode(ctrl.submit().getURL(), 'UTF-8');
            System.assertEquals('/apex/GNE_SFA2_BTT_Strategy_Edit_Create?id=' + ctrl.Strategy.Id + '&readonly=1&retURL=null', url);
            System.assertEquals(1, [SELECT COUNT() FROM SFA2_PREP_Testing_Strategy_gne__c WHERE Id = :ctrl.Strategy.Id]);
            System.assertEquals(1, [SELECT COUNT() FROM Team_Mapping_gne__c WHERE Product_gne__c=: ctrl.Strategy.Product_gne__c]);

            ctrl.Strategy.Name = 'TestQuick';
            ctrl.Strategy.Region_Code_gne__c = 1;
            ctrl.Strategy.Active_for_Call_gne__c = false;

            System.assertEquals('/apex/GNE_SFA2_BTT_Strategy_Edit_Create?retURL=/apex/GNE_SFA2_BTT_Admin_Panel', EncodingUtil.urlDecode(ctrl.quickSubmit().getURL(), 'UTF-8'));
            System.assertEquals(1, [SELECT COUNT() FROM SFA2_PREP_Testing_Strategy_gne__c WHERE Id = :ctrl.Strategy.Id]);
            System.assertEquals(0, [SELECT COUNT() FROM Team_Mapping_gne__c WHERE Product_gne__c=: ctrl.Strategy.Product_gne__c]);

        Test.stopTest();
    }

    static testMethod void editTest() {
        SFA2_PREP_Testing_Strategy_gne__c strat = new SFA2_PREP_Testing_Strategy_gne__c(Name='Test', Region_Code_gne__c=1, Active_for_Call_gne__c=true);
        insert strat;

        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.GNE_SFA2_BTT_Strategy_Edit_Create'));
            System.currentPageReference().getParameters().put('id', strat.Id);
            GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl ctrl = new GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl();

            System.assertEquals(strat.Id, ctrl.Strategy.Id);
            System.assertEquals(true, ctrl.Strategy.Active_for_Call_gne__c);
            System.assertEquals(true, ctrl.isEditable);

            String name = 'TestModified';
            ctrl.Strategy.Name = name;
            ctrl.Strategy.Active_for_Call_gne__c = false;
            ctrl.submit();

            System.assertEquals(name, [SELECT Name FROM SFA2_PREP_Testing_Strategy_gne__c WHERE Id = :ctrl.Strategy.Id].Name);
            System.assertEquals(0, [SELECT COUNT() FROM Team_Mapping_gne__c WHERE Product_gne__c=: ctrl.Strategy.Product_gne__c]);

        Test.stopTest();
    }

    static testMethod void viewTest() {
        SFA2_PREP_Testing_Strategy_gne__c strat = new SFA2_PREP_Testing_Strategy_gne__c(Name='Test', Region_Code_gne__c=1);
        insert strat;

        SFA2_PREP_MBO_gne__c mbo = new SFA2_PREP_MBO_gne__c(Testing_Strategy_ref_gne__c=strat.Id, Short_Description_gne__c='DESC');
        insert mbo;

        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.GNE_SFA2_BTT_Strategy_Edit_Create'));
            System.currentPageReference().getParameters().put('id', strat.Id);
            System.currentPageReference().getParameters().put('readonly', '1');
            GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl ctrl = new GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl();

            System.assertEquals(strat.Id, ctrl.Strategy.Id);
            System.assertEquals(false, ctrl.isEditable);            
            System.assertEquals(1, ctrl.MBOs.size());

        Test.stopTest();
    }

    static testMethod void goBackTest() {
        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.GNE_SFA2_BTT_Strategy_Edit_Create'));

            GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl ctrl = new GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl();
            System.assertEquals('/', ctrl.goBack().getURL());

            System.currentPageReference().getParameters().put('retURL', '/apex/TestRoute');
            
            ctrl = new GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl();
            System.assertNotEquals(null, ctrl.retURL);
            System.assertEquals('/apex/TestRoute', ctrl.goBack().getURL());
        
        Test.stopTest();
    }
}