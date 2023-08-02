@isTest
private class GNE_SFA2_FRM_HCO_Mapping_Trigger_Test {
    @testSetup
    static void initData() {
        Account aHCO = GNE_FRM_TestUtilities.createAccount('Test Clinic HCO', 'FRM_HCO', 'Clinic', false);
        Account aHCP = GNE_FRM_TestUtilities.createAccount('Prof HCP', 'Professional_vod', 'Health Care Professional', false, true);
        insert new List<Account> {aHCO, aHCP};

        Address_vod__c hcpAddress1 = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', aHCP.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c hcpAddress2 = GNE_FRM_TestUtilities.createAddress('515 East Alvin Avenue', aHCP.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c hcpAddress3 = GNE_FRM_TestUtilities.createAddress('516 East Alvin Avenue', aHCP.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c hcpAddress4 = GNE_FRM_TestUtilities.createAddress('517 East Alvin Avenue', aHCP.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c hcpAddress5 = GNE_FRM_TestUtilities.createAddress('523 East Alvin Avenue', aHCP.Id, 'SANTA MARIA', 'CA', '93454', false);
        insert new List<Address_vod__c> {hcpAddress1, hcpAddress2, hcpAddress3, hcpAddress4, hcpAddress5};

        FRM_HCO_Mapping_gne__c p1 = new FRM_HCO_Mapping_gne__c(FRM_HCO_Account_gne__c = aHCO.Id, HCP_Account_gne__c = aHCP.Id, HCP_Address_gne__c = hcpAddress1.Id, PACT_Prescriber_Id_gne__c = '00163000001vRjs', PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemZ');
        FRM_HCO_Mapping_gne__c p2 = new FRM_HCO_Mapping_gne__c(FRM_HCO_Account_gne__c = aHCO.Id, HCP_Account_gne__c = aHCP.Id, HCP_Address_gne__c = hcpAddress2.Id, PACT_Prescriber_Id_gne__c = '00163000001vRjd', PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemX');
        FRM_HCO_Mapping_gne__c p3 = new FRM_HCO_Mapping_gne__c(FRM_HCO_Account_gne__c = aHCO.Id, HCP_Account_gne__c = aHCP.Id, HCP_Address_gne__c = hcpAddress3.Id, PACT_Prescriber_Id_gne__c = '00163000001vRjf', PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemC');
        FRM_HCO_Mapping_gne__c p4 = new FRM_HCO_Mapping_gne__c(FRM_HCO_Account_gne__c = aHCO.Id, HCP_Account_gne__c = aHCP.Id, HCP_Address_gne__c = hcpAddress4.Id, PACT_Prescriber_Id_gne__c = '00163000001vRjg', PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemV');
        insert new List<FRM_HCO_Mapping_gne__c> {p1, p2, p3, p4};
    }

    @isTest
    static void testDeleteRecords() {
        Test.startTest();
        delete [SELECT Id FROM FRM_HCO_Mapping_gne__c];
        Test.stopTest();

        FRM_HCO_Mapping_Deleted_gne__c [] mapsDeleted = [SELECT FRM_HCO_Account_Id_gne__c, HCP_Account_gne__c FROM FRM_HCO_Mapping_Deleted_gne__c];
        Map<String, Id> name2Id = new Map<String, Id>();
        for (Account a : [
                    SELECT Name FROM Account
                ]) {
            name2Id.put(a.Name, a.Id);
        }

        System.assertEquals(4, mapsDeleted.size());
        for (FRM_HCO_Mapping_Deleted_gne__c md : mapsDeleted) {
            System.assertEquals(md.FRM_HCO_Account_Id_gne__c, name2Id.get('Test Clinic HCO'));
            System.assertEquals(md.HCP_Account_gne__c, name2Id.get('Prof HCP'));
        }
    }

    @isTest
    static void testBulkDeleteRecords() {
        Map<String, Id> name2Id = new Map<String, Id>();
        for (Account a : [
                    SELECT Name FROM Account
                ]) {
            name2Id.put(a.Name, a.Id);
        }
        FRM_HCO_Mapping_gne__c [] toInsert = new FRM_HCO_Mapping_gne__c[] {};
        Address_vod__c [] addresses = new Address_vod__c [] {};
        for (Integer x = 0; x < 300; x++) {
            Address_vod__c hcpAddress = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', name2Id.get('Prof HCP'), 'SANTA MARIA', 'CA', '93454', false);
            addresses.add(hcpAddress);
        }

        GNE_SFA2_Util.updateAdminSetings(true);
        insert addresses;
        GNE_SFA2_Util.updateAdminSetings(false);

        for (Address_vod__c av : addresses) {
            FRM_HCO_Mapping_gne__c mapping = new FRM_HCO_Mapping_gne__c(
                FRM_HCO_Account_gne__c = name2Id.get('Test Clinic HCO'),
                HCP_Account_gne__c = name2Id.get('Prof HCP'),
                HCP_Address_gne__c = av.Id
            );
            toInsert.add(mapping);
        }
        Database.SaveResult[] sResults = Database.insert(toInsert, false);

        Test.startTest();
        delete [SELECT Id FROM FRM_HCO_Mapping_gne__c];
        Test.stopTest();

        FRM_HCO_Mapping_Deleted_gne__c [] mapsDeleted = [SELECT FRM_HCO_Account_Id_gne__c, HCP_Account_gne__c FROM FRM_HCO_Mapping_Deleted_gne__c];

        System.assertEquals(304, mapsDeleted.size());
        for (FRM_HCO_Mapping_Deleted_gne__c md : mapsDeleted) {
            System.assertEquals(md.FRM_HCO_Account_Id_gne__c, name2Id.get('Test Clinic HCO'));
            System.assertEquals(md.HCP_Account_gne__c, name2Id.get('Prof HCP'));
        }
    }    

    @isTest
    static void test_InsertHiddenHCPToFRMHCOMapping(){
        delete [SELECT Id FROM FRM_HCO_Mapping_gne__c];
        GNE_FRM_TestUtilities.CalloutMock callMock = new GNE_FRM_TestUtilities.CalloutMock();
        GNE_FRM_TestUtilities.CalloutMock callMockAfter = new GNE_FRM_TestUtilities.CalloutMock();
        callMock.response = '[{"HCP_Prescriber_Last_Name__c":"Tester","DisplayUrl":"TEST0","HCP_PACT_ID__c": "00163000001vRjs","HCP_Address_PACT_ID__c":"a0063000000qemZ","Products_List__c":"Tecentriq;Venclexta", "HCP_City__c":"SANTA MARIA", "HCP_Prescriber_Address_Line_1__c":"Test Rd" }]';
        callMockAfter.response = '[{"HCP_Prescriber_Last_Name__c":"Tester","DisplayUrl":"TEST0","HCP_PACT_ID__c": "00163000001vRjs","HCP_Address_PACT_ID__c":"a0063000000qemZ","Products_List__c":"Ocrevus", "HCP_City__c":"SANTA MARIA", "HCP_Prescriber_Address_Line_1__c":"Test Rd" }]';

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, callMock);
        List<Case__x> serviceRequests = (List<Case__x>)JSON.deserializeStrict(callMock.response,List<Case__x>.class);
        GNE_SFA2_HCPtoFRMHCOMappingEngine mappingEngine = new GNE_SFA2_HCPtoFRMHCOMappingEngine();
        mappingEngine.init(serviceRequests);
        HCP_To_FRM_HCO_Mapping_gne__c originalMapping = [SELECT Id, HCP_Account_gne__c, HCP_Address_gne__c, Products_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE PACT_Prescriber_Id_gne__c = '00163000001vRjs' AND PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemZ' AND IsHidden_gne__c = false and Products_gne__c = 'Tecentriq;Venclexta' LIMIT 1];        
        mappingEngine.hideMapping(originalMapping.Id);

        Test.setMock(HttpCalloutMock.class, callMockAfter);
        List<Case__x> serviceRequestsAfter = (List<Case__x>)JSON.deserializeStrict(callMockAfter.response,List<Case__x>.class);
        mappingEngine = new GNE_SFA2_HCPtoFRMHCOMappingEngine();
        mappingEngine.init(serviceRequestsAfter);

        List<HCP_To_FRM_HCO_Mapping_gne__c> finalMapping = [SELECT Id, IsHidden_gne__c, HCP_Account_gne__c, HCP_Address_gne__c, Products_gne__c FROM HCP_To_FRM_HCO_Mapping_gne__c WHERE PACT_Prescriber_Id_gne__c = '00163000001vRjs' AND PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemZ' and Products_gne__c = 'Ocrevus'];                
        system.assertEquals(1, finalMapping.size());
        system.assertEquals(false, finalMapping[0].IsHidden_gne__c);
        system.assertEquals('Ocrevus', finalMapping[0].Products_gne__c);

        Test.stopTest(); 
    }

    @isTest
    static void test_DeleteTempMappings() {
        Map<String, Id> name2Id = new Map<String, Id>();
        for (Account a : [SELECT Name FROM Account]) {
            name2Id.put(a.Name, a.Id);
        }
        Address_vod__c address1 = [SELECT Id FROM Address_vod__c WHERE Name = '523 East Alvin Avenue' LIMIT 1];
        HCP_To_FRM_HCO_Mapping_gne__c mapping = new HCP_To_FRM_HCO_Mapping_gne__c(
            HCP_Account_gne__c = name2Id.get('Prof HCP'),
            HCP_Address_gne__c = address1.Id,
            PACT_Prescriber_Id_gne__c = '00163000001vRjs',
            PACT_Prescriber_Address_Id_gne__c = 'a0063000000qemZ'
        );
        insert new List<HCP_To_FRM_HCO_Mapping_gne__c> {mapping};
        //create
        FRM_HCO_Mapping_gne__c p1 = new FRM_HCO_Mapping_gne__c(
            FRM_HCO_Account_gne__c = name2Id.get('Test Clinic HCO'),
            HCP_Account_gne__c = name2Id.get('Prof HCP'),
            HCP_Address_gne__c = address1.Id
        );
        Test.startTest();
        insert new List<FRM_HCO_Mapping_gne__c> {p1};
        Test.stopTest();
    }

    @isTest
    static void testAvoidMappingsDuplicate() {
        List<FRM_HCO_Mapping_gne__c> fhm = [SELECT FRM_HCO_Account_gne__c, HCP_Account_gne__c, HCP_Address_gne__c FROM FRM_HCO_Mapping_gne__c];
        
        FRM_HCO_Mapping_gne__c newFHM = new FRM_HCO_Mapping_gne__c(FRM_HCO_Account_gne__c = fhm[0].FRM_HCO_Account_gne__c,
                HCP_Account_gne__c = fhm[0].HCP_Account_gne__c,
                HCP_Address_gne__c = fhm[0].HCP_Address_gne__c
            );

        Test.startTest();
        try {
            insert newFHM;
        } catch(Exception e) {
            System.AssertEquals(e.getMessage().contains(System.Label.GNE_SFA2_ErrMsg_Mapping_Duplicate), true);  
        } 
        Test.stopTest();
    }
}