@IsTest
private class gFRS_MigrateVendorsIdBatchTest {

    @TestSetup
    static void setup() {
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        customSettings.Validation_Rules_Enabled__c = false;
        upsert customSettings;

        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Id organizationId = gFRS_UnitTestHelper.createOrganization('12345', account.Id).Id;

        List<GFRS_Location__c> locations = new List<GFRS_Location__c>();
        for (Integer i = 0; i < 200; i++) {
            if (i < 190) {
                locations.add(new GFRS_Location__c(Name = 'Test location batch ' + i, Vendor_ID__c = String.format('000000000{0}', new List<String>{
                        i.format().leftPad(3, '0')
                }), Payment_Method__c = 'Z', Organization__c = organizationId));
            } else {
                locations.add(new GFRS_Location__c(Name = 'Test location batch ' + i, Organization__c = organizationId));
            }
        }
        insert locations;

        List<GFRS_SAP_feed__c> feeds = new List<GFRS_SAP_feed__c>();
        for (Integer i = 0; i < 100; i++) {
            String oldVendorIdTemplate = String.format('000000000{0}', new List<String>{
                    i.format().leftPad(3, '0')
            });
            String newVendorIdTemplate = String.format('0010000{0}', new List<String>{
                    i.format().leftPad(3, '0')
            });
            String partnerBankType = i.format().leftPad(4, '0');
            feeds.add(new GFRS_SAP_feed__c(Old_Vendor_Id__c = oldVendorIdTemplate, New_Vendor_Id__c = newVendorIdTemplate, Partner_Bank_Type__c = partnerBankType, Payment_Method__c = 'Q'));
        }
        insert feeds;
    }

    @IsTest
    private static void migrateVendorIdToOldVendorIdTest() {
        Test.startTest();
        gFRS_MigrateVendorsIdBatch migrateVendorsId = new gFRS_MigrateVendorsIdBatch();
        Id batchId = Database.executeBatch(migrateVendorsId, 200);
        Test.stopTest();

        List<GFRS_Location__c> locations = [SELECT Id, Vendor_ID__c, Old_Vendor_ID__c, Vendor_Account_Group__c, Partner_Bank_Type__c, Payment_Method__c FROM GFRS_Location__c WHERE Old_Vendor_ID__c != null];
        System.assertEquals(100, locations.size());

        for (GFRS_Location__c location : locations) {
            String suffix = location.Partner_Bank_Type__c.right(3);
            System.assertEquals(suffix, location.Vendor_ID__c.right(3));
            System.assertEquals(suffix, location.Old_Vendor_ID__c.right(3));
            System.assertEquals('PC01', location.Vendor_Account_Group__c);
            System.assertEquals('Q', location.Payment_Method__c);
        }

        List<GFRS_Location__c> locationsNotUpdated = [SELECT Id, Vendor_ID__c, Old_Vendor_ID__c, Vendor_Account_Group__c, Partner_Bank_Type__c, Payment_Method__c FROM GFRS_Location__c WHERE Old_Vendor_ID__c = null AND Vendor_Account_Group__c != null];
        System.assertEquals(90, locationsNotUpdated.size());

        for (GFRS_Location__c location : locationsNotUpdated) {
            System.assertEquals('Z003', location.Vendor_Account_Group__c);
        }
    }
}