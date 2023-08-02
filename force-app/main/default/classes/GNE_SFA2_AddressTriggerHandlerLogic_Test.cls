@isTest
private class GNE_SFA2_AddressTriggerHandlerLogic_Test {
    @testSetup
    private static void initData(){
        Account baseAccount = GNE_FRM_TestUtilities.createAccount('Test acc', 'FRM_HCO', 'Clinic', false);
        Account incorrectAccount = GNE_FRM_TestUtilities.createAccount('incorect acc', 'Hospital_vod', 'Clinic', false);
        insert new List<Account> {baseAccount, incorrectAccount};
            
        Address_vod__c baseAddress = GNE_FRM_TestUtilities.createAddress('515 East Alvin Avenue', baseAccount.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c secondAddress = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', incorrectAccount.Id, 'SAN FRANCISCO', 'CA', '93454', false);
        insert new List<Address_vod__c> {baseAddress, secondAddress};        
    }
    
    /**
    * Scenario: future "SyncMdmEnable" is ENABLED
    * We update Address's (one of five fields we check for changes ('Name', 'Address_line_2_vod__c', 'City_vod__c', 'State_vod__c', 'Zip_vod__c'))
    * 1. related Account recordtype = 'FRM_HCO'
    * 2. related Account other recordtype
    * We excpect logic for change MDM_Synch_Status_gne__c will be triggered only for Account 'FRM_HCO'
    */
    @isTest
    private static void testUpdateAccountForEnabledFuture(){
        GNE_Foun_Misc_Config_Items_gne__c conf1 = new GNE_Foun_Misc_Config_Items_gne__c(
            Name = 'SyncMdmEnabled',
            Configuration_Value_gne__c = 'Enabled' 
        );
        insert conf1;
        List<Account> accounts = [SELECT Name, Account_type_gne__c, MDMID_Status_gne__c, MDM_Synch_Status_gne__c, RecordType.Name FROM Account ];
        for(Account a:accounts){
            if (a.RecordType.Name == 'FRM_HCO'){
                System.assertEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_PENDING, a.MDM_Synch_Status_gne__c);
                a.MDM_Synch_Status_gne__c = GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED;
            } else {
                System.assertNotEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_PENDING, a.MDM_Synch_Status_gne__c);
            }
        }
        update accounts;
        
        accounts = [SELECT Name, Account_type_gne__c, MDMID_Status_gne__c, MDM_Synch_Status_gne__c, RecordType.Name FROM Account ];
        for(Account a:accounts){
            if (a.RecordType.Name == 'FRM_HCO'){
                System.assertEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED, a.MDM_Synch_Status_gne__c);
            } else {
                System.assertNotEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED, a.MDM_Synch_Status_gne__c);

            }

        }

        List<Address_vod__c> addresses = [
            SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c
            FROM Address_vod__c
        ];
        Test.startTest();
            for(Address_vod__c ad:addresses){
                ad.Address_line_2_vod__c = '514 East Alvin Avenue';
            }
            update addresses;            
        Test.stopTest(); 
        
        accounts = [SELECT Name, Account_type_gne__c, MDMID_Status_gne__c, MDM_Synch_Status_gne__c FROM Account ];
        for(Account a:accounts){
            if(a.Name == 'Test acc'){
                //value of MDM_Synch_Status_gne__c was change in trigger logic
                System.assertEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_PENDING, a.MDM_Synch_Status_gne__c);
            } else {
                //no changes triggered in trigger logic
                System.assertNotEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_PENDING, a.MDM_Synch_Status_gne__c);
            }
        }
    }
    
    /**
    * Scenario: future "SyncMdmEnable" is DISABLED
    * We update Address's (one of five fields we check for changes ('Name', 'Address_line_2_vod__c', 'City_vod__c', 'State_vod__c', 'Zip_vod__c'))
    * 1. related Account recordtype = 'FRM_HCO'
    * 2. related Account other recordtype
    * We excpect no logic for change MDM_Synch_Status_gne__c will be triggered only for 'FRM_HCO'
    */
    @isTest
    private static void testUpdateAccountForDisabledFuture(){

        GNE_Foun_Misc_Config_Items_gne__c conf1 = new GNE_Foun_Misc_Config_Items_gne__c(
                Name = 'SyncMdmEnabled',
                Configuration_Value_gne__c = 'Disabled'
        );

        List<Account> accounts = [SELECT Name, Account_type_gne__c, MDMID_Status_gne__c, MDM_Synch_Status_gne__c, RecordType.Name FROM Account ];
        for(Account a:accounts){
            if (a.RecordType.Name == 'FRM_HCO'){
                System.assertEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_PENDING, a.MDM_Synch_Status_gne__c);
                a.MDM_Synch_Status_gne__c = GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED;
            } else {
                System.assertNotEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_PENDING, a.MDM_Synch_Status_gne__c);

            }
        }
        update accounts;
        
        accounts = [SELECT Name, Account_type_gne__c, MDMID_Status_gne__c, MDM_Synch_Status_gne__c, RecordType.Name FROM Account ];
        for(Account a:accounts){
            if (a.RecordType.Name == 'FRM_HCO'){
                System.assertEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED, a.MDM_Synch_Status_gne__c);
            }
        }
        
        List<Address_vod__c> addresses = [
            SELECT Name, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c
            FROM Address_vod__c
        ];
        Test.startTest();
            for(Address_vod__c ad:addresses){
                ad.Address_line_2_vod__c = '514 East Alvin Avenue';
            }
            update addresses; 
        Test.stopTest(); 
        
        accounts = [SELECT Name, Account_type_gne__c, MDMID_Status_gne__c, MDM_Synch_Status_gne__c FROM Account ];
        for(Account a:accounts){
            if(a.Name == 'Test acc'){
                //no changes triggered in trigger logic
                System.assertEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED, a.MDM_Synch_Status_gne__c);
            } else {
                System.assertNotEquals(GNE_SFA2_Account_Trigger_Helper.MDM_SYNCH_STATUS_SYNCHRONIZED, a.MDM_Synch_Status_gne__c);

            }
        }
    } 

}