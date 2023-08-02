@isTest
public class GNE_SFA2_CAN_MngAffiliationsBatch_Test {

    @isTest
    private static void testCreatingAffiliations() {
        User etlUser = [SELECT Id FROM User WHERE Profile_Name_gne__c = 'RCanada-SYS-AutomatedJob' LIMIT 1];

        System.runAs(etlUser) {
            Account hcoAccount = createHcoAccountWithAddress();
            Account hcpAccount = createHcpAccountWithAddress();

            Test.startTest();
            Database.executeBatch(new GNE_SFA2_CAN_Create_Affiliations_Batch(), 10);
            Test.stopTest();
        }

        List<Affiliation_vod__c> affiliations = [SELECT Id FROM Affiliation_vod__c];
        System.assertEquals(2, affiliations.size());
    }

    private static Account createHcoAccountWithAddress() {
        RecordType rt = [select id from recordtype where name = 'GNE-SFA-Roche_Canada' LIMIT 1];
        Account hcoAccount = new Account(Account_Type_gne__c = 'Hospital', Name = 'SomeName', RecordTypeId = rt.Id, Prim_IMS_Id_can__c = '12345');
        insert hcoAccount;
        Address_vod__c address = new Address_vod__c( Name = 'Test', Account_vod__c = hcoAccount.Id, Account_vod__r = hcoAccount, Inactive_vod__c = false, City_vod__c = 'Test City', Province_can_gne__c = 'NS', Postal_Code_can_gne__c = 'A3A 4H0');
        insert address;
        hcoAccount.Main_Address_gne__c = address.Id;
        hcoAccount.Main_Address_gne__r = address;
        update hcoAccount;
        return hcoAccount;
    }

    private static Account createHcpAccountWithAddress() {
        RecordType rt = [select id from recordtype where name = 'HCP Canada' LIMIT 1];
        Account hcpAccount = new Account(Account_Type_gne__c  = 'Physician', LastName ='SomeLastName', RecordTypeId = rt.Id);
        insert hcpAccount;
        Address_vod__c address = new Address_vod__c( Name = 'Test', Account_vod__c = hcpAccount.Id, Account_vod__r = hcpAccount, Inactive_vod__c = false, City_vod__c = 'Test City', Province_can_gne__c = 'NS', Postal_Code_can_gne__c = 'A3A 4H0');
        insert address;
        hcpAccount.Main_Address_gne__c = address.Id;
        hcpAccount.Main_Address_gne__r = address;
        update hcpAccount;
        return hcpAccount;
    }

    @isTest
    private static void testRemoveBatch() {
        Account hcpAccount = createHcpAccountWithAddress();
        Account hcoAccount = createHcoAccountWithAddress();
        Affiliation_vod__c aff = new Affiliation_vod__c(From_Account_vod__c=hcpAccount.Id, To_Account_vod__c=hcoAccount.Id, Role_vod__c = 'Affiliated with');
        insert aff;
        Test.startTest();
        Database.executeBatch(new GNE_SFA2_CAN_Remove_Affiliations_Batch('SELECT Id FROM Affiliation_vod__c'));
        Test.stopTest();

        List<Affiliation_vod__c> affs = [SELECT Id FROM Affiliation_vod__c];
        System.assertEquals(0, affs.size());
    }
}