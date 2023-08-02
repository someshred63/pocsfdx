@isTest
private class GNE_My_Territory_Team_DAO_Test {
    @testSetup
    static void testData() {
        Map<String, Id> name2RtId = GNE_FRM_TestUtilities.getAccountRecordTypes();
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User user1 = GNE_FRM_TestUtilities.createUser('TESTUSERXXXX', ids2ProfilesMap.get('GNE-Field'), false);
        User user2 = GNE_FRM_TestUtilities.createUser('TESTUSERYYYY', ids2ProfilesMap.get('GNE-Field'), false);
        User user3 = GNE_FRM_TestUtilities.createUser('TESTUSERZZZZ', ids2ProfilesMap.get('GNE-Field'), false);
		user1.External_ID_gne__c = 'xxxxxxx';
        user2.External_ID_gne__c = 'yyyyyyy';
        user3.External_ID_gne__c = 'zzzzzzz';

        GNE_SFA2_Util.updateAdminSetings(true);
        insert new List<User> {user1,user2,user3};

        insertTerritories(new String[]{'00F1-SFA', '00F2-SFA'}); 
        
    }

    @future
    static void insertTerritories(String[] terrNames ) {
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


    static void createMTT(String[] terrNumbers, Integer removed) {
        My_Territory_Team_gne__c [] teams = new My_Territory_Team_gne__c [] {};
        Integer counter = 1;
        for(User u :[SELECT Id FROM User WHERE Email IN ('testuserxxxxuser@gene.com','testuserzzzzuser@gene.com','testuseryyyyuser@gene.com')]){
            for(String ternum : terrNumbers){
                if(counter < removed){
                    teams.add(new My_Territory_Team_gne__c(UserId_gne__c = u.Id, Territory_Number_gne__c = ternum, isManuallyRemoved_gne__c = true));
                } else {
                    teams.add(new My_Territory_Team_gne__c(UserId_gne__c = u.Id, Territory_Number_gne__c = ternum, isManuallyRemoved_gne__c = false));
                }

            }
            counter++;
        }
        insert teams;
    }

    @isTest
    static void testgetVisibleTerritoryTeamByTerritory() {
        createMTT(new String[]{'00F1', '00F2'}, 1);
        Test.startTest();
        	List<My_Territory_Team_gne__c> result = GNE_My_Territory_Team_DAO.getVisibleTerritoryTeamByTerritory('00F1');
        Test.stopTest();

        System.assertEquals(3, result.size());
    }

    @isTest
    static void testgetTerritoryTeamByTerritory() {
        createMTT(new String[]{'00F1', '00F2'},2);
        Test.startTest();
        	List<My_Territory_Team_gne__c> result = GNE_My_Territory_Team_DAO.getTerritoryTeamByTerritory('00F1');
        Test.stopTest();

        System.assertEquals(3, result.size());
    }

    @isTest
    static void testgetTerritoryTeamByTerritoryAndUnixId() {
        createMTT(new String[]{'00F1', '00F2'},0);

        Test.startTest();
        	List<My_Territory_Team_gne__c> result = GNE_My_Territory_Team_DAO.getTerritoryTeamByTerritoryAndUnixId('00F1', 'xxxxxxx');
        Test.stopTest();

        System.assertEquals(1, result.size());
    }

    @isTest
    static void testgetTerritoryTeamByTerritoryAndUserId() {
        createMTT(new String[]{'00F1', '00F2'},0);
        User u = [SELECT Id FROM User WHERE Email IN ('testuserxxxxuser@gene.com') LIMIT 1];
        Test.startTest();
        	List<My_Territory_Team_gne__c> result = GNE_My_Territory_Team_DAO.getTerritoryTeamByTerritoryAndUserId('00F2', u.Id);
        Test.stopTest();

        System.assertEquals(1, result.size());
    }

    @isTest
    static void testgetTerritoryTeamByUserId() {
        createMTT(new String[]{'00F1', '00F2'},0);
        User u = [SELECT Id FROM User WHERE Email IN ('testuserxxxxuser@gene.com') LIMIT 1];
        Test.startTest();
        	List<My_Territory_Team_gne__c> result = GNE_My_Territory_Team_DAO.getTerritoryTeamByUserId( u.Id);
        Test.stopTest();

        System.assertEquals(2, result.size());
    }

    @isTest
    static void testgetById() {
        createMTT(new String[]{'00F1'},0);
        My_Territory_Team_gne__c mtt = [SELECT Id FROM  My_Territory_Team_gne__c LIMIT 1];
        Test.startTest();
        	My_Territory_Team_gne__c result = GNE_My_Territory_Team_DAO.getById(mtt.Id);
        Test.stopTest();

        System.assertEquals(mtt.Id, result.Id);
    }

    @isTest
    static void testsetVisibility() {
        createMTT(new String[]{'00F1'},0);
        My_Territory_Team_gne__c mtt = [SELECT Id FROM  My_Territory_Team_gne__c LIMIT 1];

        Test.startTest();
        	iPhone_Commons_gne.AlterDataResponse result = GNE_My_Territory_Team_DAO.setVisibility(mtt.Id);
        Test.stopTest();

        mtt = [SELECT Id, isManuallyRemoved_gne__c FROM  My_Territory_Team_gne__c LIMIT 1];

        System.assertEquals(true, mtt.isManuallyRemoved_gne__c);
        System.assertEquals(true, result.success);
    }
}