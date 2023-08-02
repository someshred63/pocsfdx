@isTest
private class EMS_Attachment_Edit_Create_Ext_Test {

    private static String type = 'Program';
    private static String subtype = 'Product Promo';

    static testMethod void insertAlreadyCreatedAttachment() {

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

        //Create attachment and insert it to database
        Attachment att = new Attachment();
        att.parentId = attachment.id;
        att.Name = 'Test';
        att.Body = Blob.valueOf('...');

        insert att;

        ApexPages.currentPage().getParameters().put('objectId', event.id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(attachment);
        EMS_Attachment_Edit_Create_Ext Extension = new EMS_Attachment_Edit_Create_Ext(stdCtrl);

        //Make save on existing attachment
        Extension.save();

        //Cancel operation with returning url
        ApexPages.currentPage().getParameters().put('retUrl', 'test');
        Extension.Cancel();

        //Make save on existing attachment with returning url
        Extension.save();
    }

    static testMethod void insertNewAttachment() {

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

        ApexPages.currentPage().getParameters().put('objectId', event.id);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(attachment);
        EMS_Attachment_Edit_Create_Ext Extension = new EMS_Attachment_Edit_Create_Ext(stdCtrl);

        //Save with no file selected
        Extension.save();

        //Create test file
        Extension.Attachment.Name = 'New';
        Extension.Attachment.Body = Blob.valueOf('...');

        // Save new attachment
        Extension.save();

        //Cancel operation without returning url
        Extension.Cancel();
    }

    static testMethod void insertInvalidAttachment() {

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

        ApexPages.currentPage().getParameters().put('objectId', event.id);
        ApexPages.currentPage().getParameters().put('retUrl', 'test');

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(attachment);
        EMS_Attachment_Edit_Create_Ext Extension = new EMS_Attachment_Edit_Create_Ext(stdCtrl);

        //Save with no file selected
        Extension.save();

        //Create invalid file
        Extension.Attachment.Name = 'New';

        // Save invalid attachment
        Extension.save();
    }

}