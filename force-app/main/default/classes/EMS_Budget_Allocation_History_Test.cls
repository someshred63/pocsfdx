@isTest
private class EMS_Budget_Allocation_History_Test {

    static testMethod void historyTest() {

        EMS_Budget_Allocation_gne__c ba = new EMS_Budget_Allocation_gne__c();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(ba);
        EMS_Budget_Allocation_History_Ext ctrl = new EMS_Budget_Allocation_History_Ext(stdCtrl);

    }
}