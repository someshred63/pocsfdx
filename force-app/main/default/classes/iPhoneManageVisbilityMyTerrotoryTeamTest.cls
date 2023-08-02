@isTest
private class iPhoneManageVisbilityMyTerrotoryTeamTest {
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

    @isTest
    static void testServiceRespond() {
        Territory2 t = [SELECT Territory_Number_gne__c FROM Territory2 WHERE Name = '00F1-SFA' LIMIT 1];
        Test.startTest();
        	iPhoneManageVisbilityMyTerrotoryTeam.VisbilityRestResponse response =
                (iPhoneManageVisbilityMyTerrotoryTeam.VisbilityRestResponse )iPhoneManageVisbilityMyTerrotoryTeam.processRequest('xxxxxxx',t.Territory_Number_gne__c,true);
        Test.stopTest();

        My_Territory_Team_gne__c result = response.result;
        System.assertEquals(true, result.isManualAdded_gne__c);
    }

    @isTest
    static void testServiceRespond_ERROR_ARG_ISMISSING() {
        Territory2 t = [SELECT Territory_Number_gne__c FROM Territory2 WHERE Name = '00F1-SFA' LIMIT 1];
        Test.startTest();
        	iPhone_Commons_gne.BasicResponse response = (iPhone_Commons_gne.BasicResponse)iPhoneManageVisbilityMyTerrotoryTeam.processRequest('xxxxxxx',null,true);
        Test.stopTest();

        System.assertEquals('Argument missing', response.error.message);
    }

    @isTest
    static void testServiceRespond_COMMENT_NOREASON_FOR_CREATE() {
        Territory2 t = [SELECT Territory_Number_gne__c FROM Territory2 WHERE Name = '00F1-SFA' LIMIT 1];
        Test.startTest();
        	iPhoneManageVisbilityMyTerrotoryTeam.VisbilityRestResponse response =
                (iPhoneManageVisbilityMyTerrotoryTeam.VisbilityRestResponse )iPhoneManageVisbilityMyTerrotoryTeam.processRequest('xxxxxxx',t.Territory_Number_gne__c,false);
        Test.stopTest();

        System.assertEquals('Record does not exist. No reason for create only to hide record.', response.comment);
    }

    @isTest
    static void testServiceRespond_HIDE() {
        Territory2 t = [SELECT Territory_Number_gne__c FROM Territory2 WHERE Name = '00F1-SFA' LIMIT 1];
        Test.startTest();
        	iPhoneManageVisbilityMyTerrotoryTeam.VisbilityRestResponse response =
                (iPhoneManageVisbilityMyTerrotoryTeam.VisbilityRestResponse )iPhoneManageVisbilityMyTerrotoryTeam.processRequest('xxxxxxx',t.Territory_Number_gne__c,true);
            My_Territory_Team_gne__c result = response.result;
            System.assertEquals(true, result.isManualAdded_gne__c);
            System.assertEquals(false, result.isManuallyRemoved_gne__c);
            //hide
            response =
                (iPhoneManageVisbilityMyTerrotoryTeam.VisbilityRestResponse )iPhoneManageVisbilityMyTerrotoryTeam.processRequest('xxxxxxx',t.Territory_Number_gne__c,false);
            result = response.result;
        Test.stopTest();

        System.assertEquals(true, result.isManuallyRemoved_gne__c);
    }
}