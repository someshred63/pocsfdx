@isTest
private class iPhone_Get_ZipCodesByTerritoryNumberTest {

    @testSetup
    static void testData() {
        Map<String, Id> name2RtId = GNE_FRM_TestUtilities.getAccountRecordTypes();
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User user1 = GNE_FRM_TestUtilities.createUser('TESTUSERXXXX', ids2ProfilesMap.get('GNE-Field'), false);
		user1.External_ID_gne__c = 'xxxxxxx';

        GNE_SFA2_Util.updateAdminSetings(true);
        insert new List<User> {user1};


        String[] terrNumbers = new String[]{'00F1', '00F2'};
        String[] terrNames = new String[]{'00F1-SFA', '00F2-SFA'};
        futureDML(terrNumbers);
        insertTerritories(terrNames);
    }

    @future
    static void insertTerritories(String[] terrNames) {
    	Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
    	Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
        Territory2 parentTerr = new Territory2(Name = 'GNE-US-SFA', DeveloperName = 'TEST', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, External_Id_gne__c = 'Root;GNE-US-SFA', Parent_External_Id_gne__c ='Root');
        insert parentTerr;
        Territory2[] toInsert = new Territory2[]{};
        for(String num : terrNames){
            Territory2 terr = GNE_FRM_TestUtilities.createTerritory(num, parentTerr.Id, false);
            terr.Salesforce_Code_gne__c = 'TEST';
            terr.Salesforce_SubTeam_Code_gne__c = 'TEST';
            terr.external_id_gne__c = 'Root;GNE-US-SFA;'+terr.Name;
            terr.Parent_External_Id_gne__c = 'Root;GNE-US-SFA';
            terr.Territory2ModelId = terrModelId;
            terr.Territory2TypeId = terrTypeId;
            toInsert.add(terr);
        }
        insert toInsert;
    }

    @future
    static void futureDML(String[] terrNumbers) {
        Zip_to_Territory_gne__c [] zipsToInsert = new Zip_to_Territory_gne__c[]{};
        Integer zipcodeSufix = 1;
        for(String t : terrNumbers){
            for(Integer x = 0; x<10; x++){
                Zip_to_Territory_gne__c z2t = new Zip_to_Territory_gne__c(Territory_Number_gne__c = t,Zip_Code_gne__c=createZipCode(zipcodeSufix),STARS_BrandCode_gne__c='TEST');
                zipsToInsert.add(z2t);
                zipcodeSufix++;
            }
        }
        insert zipsToInsert;
    }

    public static String createZipCode(Integer zipcodeSufix) {
        String result = String.valueOf(zipcodeSufix);
        return '0'.repeat(5 - result.length()) + result;
    }

    @isTest
    static void testServiceRespond() {
        Test.startTest();
        	iPhone_Get_ZipCodesByTerritoryNumber.DeltaRecordsResponse response =
                (iPhone_Get_ZipCodesByTerritoryNumber.DeltaRecordsResponse)iPhone_Get_ZipCodesByTerritoryNumber.buildResponse('xxxxxxx','','');
        Test.stopTest();

        System.assertEquals(true, response.success);
        System.assertEquals('', response.lastZip);
        System.assertEquals(0, response.zc.size());
    }

    @isTest
    static void testServiceRespondForTerritoryNumber() {
        Territory2 t = [SELECT Territory_Number_gne__c FROM Territory2 WHERE Name = '00F1-SFA' LIMIT 1];
        User us = [select id from user where External_ID_gne__c = 'xxxxxxx'];
        System.debug('--+- Territory_Number_gne__c '+t.Territory_Number_gne__c);
        Test.startTest();
        	iPhone_Get_ZipCodesByTerritoryNumber.DeltaRecordsResponse response =
                (iPhone_Get_ZipCodesByTerritoryNumber.DeltaRecordsResponse)iPhone_Get_ZipCodesByTerritoryNumber.buildResponse('xxxxxxx',t.id,'');
        Test.stopTest();

        System.assertEquals(true, response.success);
        System.assertEquals('', response.lastZip);
        System.assertEquals(10, response.zc.size());
    }

}