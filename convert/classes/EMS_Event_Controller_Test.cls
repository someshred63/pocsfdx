@isTest
private class EMS_Event_Controller_Test {

    static testMethod void myUnitTest() {

        ApexPages.currentPage().getParameters().put('msg', 'message');

        EMS_Event_Controller ctrl = new EMS_Event_Controller();

        ctrl.newClick();

        List_View_Setup_Ext.ConditionItem filter = new List_View_Setup_Ext.ConditionItem('Name', 'in', 'test', null, null);

        ctrl.getCustomFilterExpression(filter);

    }
}