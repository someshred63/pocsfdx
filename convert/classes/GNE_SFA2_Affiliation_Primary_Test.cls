@IsTest
private class GNE_SFA2_Affiliation_Primary_Test {

    @TestSetup
    private static void setup() {
        GNE_SFA2_Util.switchAdminMode(false);
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Address_Trigger', false);
        GNE_SFA2_Util.insertCanadianProfileNamesCustomSetting();
        GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
        GNE_SFA2_Address_Test_Helper.insertCustomSettings();
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(sfa2User) {
            List<Account> testAccounts = new List<Account>();

            Account hcp = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Smith');
            testAccounts.add(hcp);

            Account hco1 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('HCO1');
            hco1.INS_ID_gne__c = '12345';
            testAccounts.add(hco1);

            Account hco2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('HCO2');
            testAccounts.add(hco2);

            Account hco3 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('HCO3');
            testAccounts.add(hco3);

            Account hco4 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('HCO4');
//            hco4.INS_ID_gne__c = '6789';
            testAccounts.add(hco4);

            Account hco5 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('HCO5');
            hco5.INS_ID_gne__c = '6789';
            testAccounts.add(hco5);

            insert testAccounts;
        }
    }

    @IsTest
    static void testInsert() {
        Account hcp = [SELECT Id, Name FROM Account WHERE IsPersonAccount = true ORDER BY Name];
        List<Account> hcos = [SELECT Id, Name, INS_ID_gne__c FROM Account WHERE IsPersonAccount = false ORDER BY Name ASC];

        System.debug('First primary: ' + hcos.get(0).INS_ID_gne__c);
        Affiliation_vod__c testAffiliation1 = new Affiliation_vod__c(From_Account_vod__c = hcp.Id, To_Account_vod__c = hcos.get(0).Id,
                Parent_vod__c = false, Primary_gne__c = true);

        Affiliation_vod__c testAffiliation2 = new Affiliation_vod__c(From_Account_vod__c = hcp.Id, To_Account_vod__c = hcos.get(1).Id,
                Primary_gne__c = false);

        Affiliation_vod__c testAffiliation3 = new Affiliation_vod__c(From_Account_vod__c = hcp.Id, To_Account_vod__c = hcos.get(2).Id,
                Primary_gne__c = false);

        Affiliation_vod__c testAffiliation4 = new Affiliation_vod__c(From_Account_vod__c = hcp.Id, To_Account_vod__c = hcos.get(3).Id,
                Primary_gne__c = false);

        Affiliation_vod__c testAffiliation5 = new Affiliation_vod__c(From_Account_vod__c = hcp.Id, To_Account_vod__c = hcos.get(4).Id,
                Primary_gne__c = false);
        insert new List<Affiliation_vod__c>{
                testAffiliation1, testAffiliation2, testAffiliation3, testAffiliation4
        };
        Test.startTest();
        List<Affiliation_vod__c> affiliations = [SELECT Id FROM Affiliation_vod__c];
        System.assertEquals(8, affiliations.size());
        Map<Id, Affiliation_vod__c> primaryAffiliations = new Map<Id, Affiliation_vod__c>([SELECT Id FROM Affiliation_vod__c WHERE Primary_gne__c = TRUE]);
        System.assertEquals(2, primaryAffiliations.size());
        testAffiliation5.Primary_gne__c = true;
        System.debug('New primary: ' + hcos.get(4).INS_ID_gne__c);
        insert testAffiliation5;

        Map<Id, Affiliation_vod__c> newPrimaryAffiliations = new Map<Id, Affiliation_vod__c>([SELECT Id FROM Affiliation_vod__c WHERE Primary_gne__c = TRUE]);
        System.assertEquals(2, newPrimaryAffiliations.size());
        for (Affiliation_vod__c aff : newPrimaryAffiliations.values()) {
            System.assert(!primaryAffiliations.containsKey(aff.Id));
        }

        Map<Id, Affiliation_vod__c> noLongerPrimaryAffiliation = new Map<Id, Affiliation_vod__c>([SELECT Id, Primary_gne__c FROM Affiliation_vod__c WHERE Id = :primaryAffiliations.keySet()]);

        for (Affiliation_vod__c aff : noLongerPrimaryAffiliation.values()) {
            System.assertEquals(false, aff.Primary_gne__c);
        }
    }

    @IsTest
    static void testUpdate() {
        List<Account> accounts = [SELECT Id, FirstName, LastName FROM Account];
        Account account = accounts.get(0);


        Affiliation_vod__c testAffiliation1 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = accounts.get(1).Id,
                Parent_vod__c = false, Role_vod__c = '-Top Payer 1-', Primary_gne__c = true);

        Affiliation_vod__c testAffiliation2 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = accounts.get(2).Id,
                Parent_vod__c = true, Role_vod__c = '-Top Payer 1-');

        Affiliation_vod__c testAffiliation3 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = accounts.get(3).Id,
                Parent_vod__c = false, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 2-');

        Affiliation_vod__c testAffiliation4 = new Affiliation_vod__c(From_Account_vod__c = account.Id, To_Account_vod__c = accounts.get(4).Id,
                Parent_vod__c = true, Web_Order_Enabled_gne__c = true, Role_vod__c = '-Top Payer 2-');

        insert new List<Affiliation_vod__c>{
                testAffiliation1, testAffiliation2, testAffiliation3, testAffiliation4
        };
        Test.startTest();
        List<Affiliation_vod__c> affiliations = [SELECT Id FROM Affiliation_vod__c];
        System.assertEquals(8, affiliations.size());

        Map<Id, Affiliation_vod__c> primaryAffiliations = new Map<Id, Affiliation_vod__c>([SELECT Id FROM Affiliation_vod__c WHERE Primary_gne__c = TRUE]);
        System.assertEquals(2, primaryAffiliations.size());

        testAffiliation4.Primary_gne__c = true;
        update testAffiliation4;

        Map<Id, Affiliation_vod__c> newPrimaryAffiliations = new Map<Id, Affiliation_vod__c>([SELECT Id FROM Affiliation_vod__c WHERE Primary_gne__c = TRUE]);
        System.assertEquals(2, newPrimaryAffiliations.size());
        for (Affiliation_vod__c aff : newPrimaryAffiliations.values()) {
            System.assert(!primaryAffiliations.containsKey(aff.Id));
        }

        Map<Id, Affiliation_vod__c> noLongerPrimaryAffiliation = new Map<Id, Affiliation_vod__c>([SELECT Id, Primary_gne__c FROM Affiliation_vod__c WHERE Id = :primaryAffiliations.keySet()]);

        for (Affiliation_vod__c aff : noLongerPrimaryAffiliation.values()) {
            System.assertEquals(false, aff.Primary_gne__c);
        }
    }
}