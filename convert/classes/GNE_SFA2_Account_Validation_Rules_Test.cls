@isTest
private class GNE_SFA2_Account_Validation_Rules_Test {
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
            Name = 'TEST_FRM_001',
            RecordTypeId = frmAccountRecordTypeId,
            Account_Type_gne__c = 'Hospital - Specialty Group'
        );
        Account acc2 = new Account(
            Name = 'TEST_FRM_002',
            RecordTypeId = frmAccountRecordTypeId
        );       
        Account acc3 = new Account(
            Name = 'TEST_NOT_FRM_001',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hospital GPO').getRecordTypeId()
        );
        insert new List<Account>{acc1, acc2, acc3};            
    }
    
    @isTest
    static void testInitLoad() {
        Map<String, Account> name2Account = new Map<String, Account> ();
        for(Account acc: [SELECT Name, OwnerId, RecordTypeId, Account_Type_gne__c FROM Account]) {
            name2Account.put(acc.Name, acc);
        }
        System.assertEquals(3, name2Account.size());
        for(String name : name2Account.keySet()) {
            if(name == 'TEST_FRM_001'){
                System.assertEquals(frmAccountRecordTypeId, name2Account.get(name).RecordTypeId);
                System.assertEquals(frmadminUserId, name2Account.get(name).OwnerId);                
            } else if(name == 'TEST_FRM_002') {
                System.assertEquals(frmadminUserId, name2Account.get(name).OwnerId);                
            } else if(name == 'TEST_NOT_FRM_001') {
                System.assertNotEquals(frmadminUserId, name2Account.get(name).OwnerId); 
            }
        }
    }
    
    @isTest
    static void testUpdateOwnerForFRMAndAccountTypeNotNULL() {
        Account acc = [SELECT OwnerId, Account_Type_gne__c FROM Account WHERE Name = 'TEST_FRM_001'];
        acc.OwnerId = UserInfo.getUserId();
        Boolean expectedExceptionThrown = false;
        Test.startTest();
        try{
            update acc;
        } catch (Exception ex){
            expectedExceptionThrown =  ex.getMessage().contains('FRM HCO accounts must be owned by FRM Admin User') ? true : false;
        }
        Test.stopTest();
        
        System.AssertEquals(true, expectedExceptionThrown);        
    }
    
    @isTest
    static void testUpdateOwnerForFRMAndAccountTypeIsNULL() {
        Account acc = [SELECT OwnerId, Account_Type_gne__c FROM Account WHERE Name = 'TEST_FRM_002'];
        acc.OwnerId = UserInfo.getUserId();
        Boolean expectedExceptionThrown = false;
        Test.startTest();
            try{
                update acc;
            } catch (Exception ex){
                expectedExceptionThrown =  ex.getMessage().contains('FRM HCO accounts must be owned by FRM Admin User') ? true : false;
            }
        Test.stopTest();
        
        System.AssertEquals(true, expectedExceptionThrown);        
    }
    
    @isTest
    static void testUpdateAccountTypeToCorrect() {
        Account [] accs = [SELECT Account_Type_gne__c FROM Account WHERE Name IN ('TEST_FRM_002','TEST_FRM_001')];
        
        for(Account acc : accs) {
            acc.Account_Type_gne__c = 'Hospital - General Admin';
        }
        Test.startTest();
        	update accs;
        Test.stopTest();
        
        for(Account acc : [SELECT OwnerId, Account_Type_gne__c, RecordTypeId FROM Account WHERE Name IN ('TEST_FRM_002','TEST_FRM_001')]){
            System.assertEquals(frmAccountRecordTypeId, acc.recordTypeId);
            System.assertEquals(frmadminUserId, acc.OwnerId);  
            System.assertEquals('Hospital - General Admin', acc.Account_Type_gne__c);   
        }            
    }
    
    @isTest
    static void testUpdateAccountTypeToIncorrect() {
        Account [] accs = [SELECT Account_Type_gne__c FROM Account WHERE Name IN ('TEST_FRM_002','TEST_FRM_001')];
        
        for(Account acc : accs) {
            acc.Account_Type_gne__c = 'xxxxxx';
        }
        Test.startTest();
        	Database.SaveResult[] srList = Database.update(accs, false);
        Test.stopTest();
        for(Database.SaveResult sr : srList){
            System.assertEquals(false, sr.isSuccess());
            for(Database.Error err : sr.getErrors()){
                System.assertEquals(new List<String>{'Account_Type_gne__c'}, err.getFields());
                System.assertEquals(true, err.getMessage().contains('FRM HCO Account Type value must be one of the following:'));
                
            }
        }
                   
    }
}