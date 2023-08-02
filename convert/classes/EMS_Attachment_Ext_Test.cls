@isTest
private class EMS_Attachment_Ext_Test {

    private static String type = 'Program';
    private static String subtype = 'Product Promo';

    static testMethod void AttachmentExtTest() {

        //Finding proper user
        List<Id> pmUsers = EMS_Test_Util.findExistingUser('PM', null);
        System.assertNotEquals(0, pmUsers.size());

        //Creating cost center and product budget
        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Department', 1, true);
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createProductBudget(0.0, 1000.0, pmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(type, subtype, costCenters[0]);

        //Creating test event
        EMS_Event__c event = EMS_Test_Util.createEvent('Draft', pmUsers[0], type, subtype, Date.today(), Date.today() + 7, 100.00);

        EMS_Attachment_gne__c attachment = EMS_Test_Util.createAttachment(event, 'Other');

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(attachment);
        EMS_Attachement_Ext Extension = new EMS_Attachement_Ext(stdCtrl);

        Extension.edit();
    }
}