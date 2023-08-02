@isTest
private class GNE_FRM_Sync_Records_With_MDM_Test {

    @testSetup
    private static void initData(){
        Account baseAccount = GNE_FRM_TestUtilities.createAccount('Test acc', 'FRM_HCO', 'Clinic', false);
        Account incorrectAccount = GNE_FRM_TestUtilities.createAccount('Test acc', 'Hospital_vod', 'Clinic', false);
        insert new List<Account> {baseAccount, incorrectAccount};
            
        Address_vod__c baseAddress = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', baseAccount.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c secondAddress = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', incorrectAccount.Id, 'SANTA MARIA', 'CA', '93454', false);
        insert new List<Address_vod__c> {baseAddress, secondAddress};
            
        GNE_Foun_Misc_Config_Items_gne__c conf1 = new GNE_Foun_Misc_Config_Items_gne__c(
        	Name = 'SyncMdmEnabled',
        	Configuration_Value_gne__c = 'Enabled' 
    	);
        insert conf1;

        GNE_FRM_TestUtilities.createSchedulerConfig();
    }
    
    /*
     * send request as FRM User, Account has correct recordType
     * expected result: request will be send to MDM and we will receive response with mdmIds 
     * On SFDC side mdmId wil be populated
     */ 
    private static testMethod void testSendAccountAsFrmUser_positive() {
        GNE_FRM_TestData.ForSyncRecordsWithMDM_Test testData = new GNE_FRM_TestData.ForSyncRecordsWithMDM_Test(0,0);
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        Account baseAccount = [SELECT MDMID_gne__c, RecordTypeId, Name, MDMID_Status_gne__c, Account_Type_gne__c, Stewardship_System_Name_gne__c, OwnerId FROM Account WHERE RecordType.Name = 'FRM_HCO' LIMIT 1];
        insert testData.afrmManager;
        baseAccount.OwnerId = testData.afrmManager.Id;
        update baseAccount;
        Address_vod__c baseAddress = [
            SELECT Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c , 
                Address_line_2_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s
            FROM Address_vod__c 
            WHERE Account_vod__c = :baseAccount.Id AND  MDM_Address_ID_gne__c = null LIMIT 1];
        Integer accMdmId = testData.respondMap.get(baseAccount.Id);
        Integer addrMdmId = testData.respondMap.get(baseAddress.Id);
        callMock.response = '{"tns:putCreateHCOResponse":{"tns:newOrganizationDetails":{"tns:newOrganization":{"tns:mdmId":"'+ accMdmId +'","tns:mdmAddressId":"'+ addrMdmId +'"}}}}';
        
        Test.setMock(HttpCalloutMock.class, callMock);
        
        Test.startTest();
            System.runAs(testData.afrmManager) {
                //GNE_FRM_Synchronize_Records_With_MDM.syncOnAccountUpsert(baseAccount, baseAddress, GNE_FRM_Synchronize_Records_With_MDM.DML_Type.DML_INSERT, false);
                Database.executeBatch(new GNE_FRM_Sync_Records_With_MDM_Batch(), 1);
            }
        Test.stopTest();
        
        baseAccount = [SELECT MDMID_gne__c, RecordTypeId, Name, MDMID_Status_gne__c, Account_Type_gne__c, Stewardship_System_Name_gne__c FROM Account WHERE Id = :baseAccount.Id];
        baseAddress = [SELECT Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Id = :baseAddress.Id];
        System.assertEquals(String.valueOf(testData.respondMap.get(baseAccount.Id)), baseAccount.MDMID_gne__c);
        System.assertEquals(String.valueOf(testData.respondMap.get(baseAddress.Id)), baseAddress.MDM_Address_ID_gne__c);
    }
    
    /*
     * send request as FRM User, Account has incorrect recordType
     * expected result: request will be NOT send to MDM 
     */ 
    private static testMethod void testSendAccountAsFrmUser_incorrectAccountType() {
        GNE_FRM_TestData.ForSyncRecordsWithMDM_Test testData = new GNE_FRM_TestData.ForSyncRecordsWithMDM_Test(0,0);
        Account baseAccount = [SELECT MDMID_gne__c, RecordTypeId, Name, MDMID_Status_gne__c, Account_Type_gne__c, Stewardship_System_Name_gne__c FROM Account WHERE RecordType.Name != 'FRM_HCO' LIMIT 1];
        Address_vod__c baseAddress = [
            SELECT Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c,
                Address_line_2_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s
            FROM Address_vod__c WHERE Account_vod__c = :baseAccount.Id AND  MDM_Address_ID_gne__c = null LIMIT 1];
        Integer accMdmId = testData.respondMap.get(baseAccount.Id);
        Integer addrMdmId = testData.respondMap.get(baseAddress.Id);
        
        Test.startTest();
            GNE_FRM_Synchronize_Records_With_MDM.syncOnAccountUpsert(baseAccount, baseAddress, GNE_FRM_Synchronize_Records_With_MDM.DML_Type.DML_INSERT, false);
        Test.stopTest();
        
        baseAccount = [SELECT MDMID_gne__c, RecordTypeId, Name, MDMID_Status_gne__c, Account_Type_gne__c, Stewardship_System_Name_gne__c FROM Account WHERE Id = :baseAccount.Id];
        baseAddress = [SELECT Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Id = :baseAddress.Id];
        System.assertEquals(null, baseAccount.MDMID_gne__c);
        System.assertEquals(null, baseAddress.MDM_Address_ID_gne__c);
    }
    
    /*
     * send request FROM Batch as NOT FRM User
     * expected result: request will be send to MDM and we will receive response with mdmIds 
     * On SFDC side mdmId will be populated
     */ 
    private static testMethod void testBatch(){
        GNE_FRM_TestData.ForSyncRecordsWithMDM_Test testData = new GNE_FRM_TestData.ForSyncRecordsWithMDM_Test(0,0);
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        
        Account baseAccount = [SELECT MDMID_gne__c, RecordTypeId, Name, MDMID_Status_gne__c, Account_Type_gne__c, Stewardship_System_Name_gne__c, OwnerId FROM Account WHERE RecordType.Name = 'FRM_HCO' LIMIT 1];
        Address_vod__c baseAddress = [SELECT Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Account_vod__c = :baseAccount.Id AND  MDM_Address_ID_gne__c = null LIMIT 1];
        
        Integer accMdmId = testData.respondMap.get(baseAccount.Id);
        Integer addrMdmId = testData.respondMap.get(baseAddress.Id);
        callMock.response = '{"tns:putCreateHCOResponse":{"tns:newOrganizationDetails":{"tns:newOrganization":{"tns:mdmId":"'+ accMdmId +'","tns:mdmAddressId":"'+ addrMdmId +'"}}}}';
        
        Test.setMock(HttpCalloutMock.class, callMock);
        Test.startTest();
            GNE_FRM_Sync_Records_With_MDM_Batch batch = new GNE_FRM_Sync_Records_With_MDM_Batch();
        	Database.executeBatch(batch, 1);
        Test.stopTest();
        
        Account incorrectAccount = [SELECT MDMID_gne__c, RecordTypeId, Name, MDMID_Status_gne__c, Account_Type_gne__c, Stewardship_System_Name_gne__c FROM Account WHERE RecordType.Name != 'FRM_HCO' LIMIT 1];
        Address_vod__c secondAddress = [SELECT Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Account_vod__c = :incorrectAccount.Id AND  MDM_Address_ID_gne__c = null LIMIT 1];
        System.assertEquals(null, incorrectAccount.MDMID_gne__c);
        System.assertEquals(null, secondAddress.MDM_Address_ID_gne__c);
        baseAccount = [SELECT MDMID_gne__c, RecordTypeId, Name, MDMID_Status_gne__c, Account_Type_gne__c, Stewardship_System_Name_gne__c FROM Account WHERE Id = :baseAccount.Id];
        baseAddress = [SELECT Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Id = :baseAddress.Id];
        System.assertEquals(String.valueOf(testData.respondMap.get(baseAccount.Id)), baseAccount.MDMID_gne__c);
        System.assertEquals(String.valueOf(testData.respondMap.get(baseAddress.Id)), baseAddress.MDM_Address_ID_gne__c);
    }
    
    /*
     * send request FROM Batch and receive empty body 
     * expected result: request will be send to MDM and we will receive response with mdmIds 
     * On SFDC side mdmId will be populated
     */ 
    private static testMethod void reciveEmptyBody(){
        GNE_FRM_TestData.ForSyncRecordsWithMDM_Test testData = new GNE_FRM_TestData.ForSyncRecordsWithMDM_Test(0,0);
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        
        Account baseAccount = [SELECT MDMID_gne__c, RecordTypeId, Name, MDMID_Status_gne__c, Account_Type_gne__c, Stewardship_System_Name_gne__c, OwnerId FROM Account WHERE RecordType.Name = 'FRM_HCO' LIMIT 1];
        Address_vod__c baseAddress = [SELECT Name, Id, Primary_vod__c, MDM_Address_ID_gne__c, City_vod__c, State_vod__c, Zip_vod__c FROM Address_vod__c WHERE Account_vod__c = :baseAccount.Id AND  MDM_Address_ID_gne__c = null LIMIT 1];
        
        Integer accMdmId = testData.respondMap.get(baseAccount.Id);
        Integer addrMdmId = testData.respondMap.get(baseAddress.Id);
        callMock.response = '{}';
        
        Test.setMock(HttpCalloutMock.class, callMock);
        Test.startTest();
            GNE_FRM_Sync_Records_With_MDM_Batch batch = new GNE_FRM_Sync_Records_With_MDM_Batch();
        	Database.executeBatch(batch, 1);
        Test.stopTest();
        Error_Log_gne__c [] logs = [SELECT Error_Description__c FROM Error_Log_gne__c];
        System.assertEquals(1, logs.size());
        for(Error_Log_gne__c el :logs){
            System.assertEquals('Empty Response from MDM', el.Error_Description__c);
        }
    }
}