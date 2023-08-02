@isTest
private class GNE_SFA2_Account_Field_Updates_Test {
    static final Id frmadminUserId = [SELECT Id FROM User WHERE External_ID_gne__c = 'frmadmin'].Id;
    static final Id frmAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('HCO').getRecordTypeId();
    
    @testSetup
    static void testData() {
        CORE_Pub_Org_Typ_Map__c cs1 = new CORE_Pub_Org_Typ_Map__c(Name = 'FRM_HCO', Account_Owner_gne__c = 'frmadmin', Account_Record_Type_gne__c = 'FRM_HCO', Account_Type_gne__c = 'Physician Practice');
        CORE_Pub_Org_Typ_Map__c cs2 = new CORE_Pub_Org_Typ_Map__c(Name = 'FRM_HCO:1', Account_Owner_gne__c = 'frmadmin', Account_Record_Type_gne__c = 'FRM_HCO', Account_Type_gne__c = 'Infusion/Injection Center');
        CORE_Pub_Org_Typ_Map__c cs3 = new CORE_Pub_Org_Typ_Map__c(Name = 'FRM_HCO:2', Account_Owner_gne__c = 'frmadmin', Account_Record_Type_gne__c = 'FRM_HCO', Account_Type_gne__c = 'Hospital - General Admin');
        CORE_Pub_Org_Typ_Map__c cs4 = new CORE_Pub_Org_Typ_Map__c(Name = 'FRM_HCO:3', Account_Owner_gne__c = 'frmadmin', Account_Record_Type_gne__c = 'FRM_HCO', Account_Type_gne__c = 'Hospital - Specialty Group');
        insert new List<CORE_Pub_Org_Typ_Map__c>{cs1, cs2, cs3, cs4};
                 
        Account acc1 = new Account(
            Name = 'TEST_NOT_FRM_001',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital GPO').getRecordTypeId()
        );
        insert new List<Account>{acc1};            
    }
    
    @isTest
    static void testchangeRecordTypeToFRM() {
        Account acc = [SELECT OwnerId, Account_Type_gne__c, RecordTypeId FROM Account WHERE Name = 'TEST_NOT_FRM_001'];
        System.AssertEquals(UserInfo.getUserId(), acc.OwnerId);     
        
        acc.RecordTypeId = frmAccountRecordTypeId;

        Test.startTest();
            update acc;
        Test.stopTest();
        
        acc = [SELECT OwnerId, Account_Type_gne__c, RecordTypeId FROM Account WHERE Name = 'TEST_NOT_FRM_001'];
        System.AssertEquals(frmadminUserId, acc.OwnerId);        
    }
}