@isTest
private class GNE_SFA2_BTT_Admin_Panel_Controller_Test {
    static testMethod void getRecordsTest() {
        List<SFA2_PREP_Testing_Strategy_gne__c> data = new List<SFA2_PREP_Testing_Strategy_gne__c>();
        final Integer REC_COUNT = 10;

        for (Integer i = 0; i < REC_COUNT; i++) {
            data.add(new SFA2_PREP_Testing_Strategy_gne__c(Name='Test' + i, Region_Code_gne__c=i));
        }

        insert data;

        List<SFA2_PREP_MBO_gne__c> mbos = new List<SFA2_PREP_MBO_gne__c>();
        for (SFA2_PREP_Testing_Strategy_gne__c strat : data) {
            mbos.add(new SFA2_PREP_MBO_gne__c(Testing_Strategy_ref_gne__c=strat.Id, Short_Description_gne__c='DESC'+strat.Name));
        }

        insert mbos;

        Test.startTest();

            GNE_SFA2_BTT_Admin_Panel_Controller ctrl = new GNE_SFA2_BTT_Admin_Panel_Controller();
            System.assertEquals(REC_COUNT, ctrl.getStrategies().size());
            System.assertEquals(REC_COUNT, ctrl.getMBOs().size());

        Test.stopTest();
    }

    static testMethod void sectionPickerTest() {
        Test.startTest();

            GNE_SFA2_BTT_Admin_Panel_Controller ctrl = new GNE_SFA2_BTT_Admin_Panel_Controller();

            ctrl.enableStrategiesSection();

            System.assertEquals(true, ctrl.isStratSelected);
            System.assertEquals(false, ctrl.isMBOSelected);

            ctrl.enableMBOSection();

            System.assertEquals(true, ctrl.isMBOSelected);
            System.assertEquals(false, ctrl.isStratSelected);
        
        Test.stopTest();
    }

    static testMethod void goBackTest() {
        Test.startTest();

            Test.setCurrentPageReference(new PageReference('Page.GNE_SFA2_BTT_Admin_Panel'));

            GNE_SFA2_BTT_Admin_Panel_Controller ctrl = new GNE_SFA2_BTT_Admin_Panel_Controller();
            System.assertEquals('/', ctrl.goBack().getURL());

            System.currentPageReference().getParameters().put('retURL', '/apex/TestRoute');
            
            ctrl = new GNE_SFA2_BTT_Admin_Panel_Controller();
            System.assertEquals('/apex/TestRoute', ctrl.goBack().getURL());
        
        Test.stopTest();
    }
}