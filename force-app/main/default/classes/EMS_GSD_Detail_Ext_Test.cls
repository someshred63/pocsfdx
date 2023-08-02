@isTest
private class EMS_GSD_Detail_Ext_Test {

    static testMethod void saveExistingGSDDetail() {

        //Finding proper user
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Corporate Relations', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        EMS_Budget_Product_gne__c budget = EMS_Test_Util.createProductBudget(0, 100, mmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Donation', 'Donation / Patient Association', costCenters[0]);

        EMS_Event__c event = EMS_Test_Util.createEvent('Unplanned', mmUsers[0], 'Donation', 'Donation / Patient Association', Date.today(), Date.today() + 2);

        EMS_GSD_Detail__c gsd = EMS_Test_Util.createGSDDetail(event);

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(gsd);
        EMS_GSD_Detail_Ext ctrl = new EMS_GSD_Detail_Ext(stdCtrl);

        gsd.Institution_gne__c = 'Foo';

        EMS_Remote_Response result = EMS_GSD_Detail_Ext.saveGSDDetail(gsd);

        System.assertNotEquals(false, result.isSuccess);
    }

    static testMethod void saveNewGSDDetail() {

        //Finding proper user
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Corporate Relations', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        EMS_Budget_Product_gne__c budget = EMS_Test_Util.createProductBudget(0, 100, mmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Donation', 'Donation / Patient Association', costCenters[0]);

        EMS_Event__c event = EMS_Test_Util.createEvent('Unplanned', mmUsers[0], 'Donation', 'Donation / Patient Association', Date.today(), Date.today() + 2);

        Account acc = EMS_Test_Util.createAndInsertAccount('HCP Canada');

        EMS_GSD_Detail__c gsd = new EMS_GSD_Detail__c(
                EMS_Event__c = event.Id,
                Date_of_Request_Letter_gne__c = System.today(),
                HCP_HCO_Name__c = acc.Id,
                City_gne__c = 'Alberta',
                Country_gne__c = 'Canada',
                Institution_gne__c = 'Acme',
                Postal_Code_gne__c = 'A0A 1B1',
                Province_gne__c = 'Alberta',
                Recipient_Job_Title_gne__c = 'test',
                Street_1_gne__c = 'street1',
                Street_2_gne__c = 'street2',
                Phone_Number_gne__c = '8899633225',
                Email_Address_gne__c = 'email@testaddress.com',
                Name_of_Vendor_Signatory_gne__c = 'Name of Vandor',
                Email_Address_Vendor_Signatory_gne__c = 'email-diff@testaddress.com'
        );

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(gsd);
        EMS_GSD_Detail_Ext ctrl = new EMS_GSD_Detail_Ext(stdCtrl);

        EMS_Remote_Response result = EMS_GSD_Detail_Ext.saveGSDDetail(gsd);

        System.assertNotEquals(false, result.isSuccess);
    }

    static testMethod void saveInvalidGSDDetail() {

        //Finding proper user
        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Corporate Relations', 1, true);
        System.assertNotEquals(0, costCenters.size());

        test.startTest();

        EMS_Budget_Product_gne__c budget = EMS_Test_Util.createProductBudget(0, 100, mmUsers[0], costCenters[0].Id);
        EMS_Test_Util.createPossibleBudgetAllocationMapping('Donation', 'Donation / Patient Association', costCenters[0]);

        EMS_Event__c event = EMS_Test_Util.createEvent('Unplanned', mmUsers[0], 'Donation', 'Donation / Patient Association', Date.today(), Date.today() + 2);

        Account acc = EMS_Test_Util.createAndInsertAccount('HCP Canada');

        EMS_GSD_Detail__c gsd = new EMS_GSD_Detail__c();

        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(gsd);
        EMS_GSD_Detail_Ext ctrl = new EMS_GSD_Detail_Ext(stdCtrl);

        //Trying to save empty GSD detail
        EMS_Remote_Response result = EMS_GSD_Detail_Ext.saveGSDDetail(gsd);

        System.assertNotEquals(true, result.isSuccess);
    }
}