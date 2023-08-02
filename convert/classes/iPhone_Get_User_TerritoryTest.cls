@isTest
private class iPhone_Get_User_TerritoryTest {

    @testSetup
    static void testData() {
        Map<String, Id> name2RtId = GNE_FRM_TestUtilities.getAccountRecordTypes();
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User user1 = GNE_FRM_TestUtilities.createUser('TESTUSERXXXX', ids2ProfilesMap.get('GNE-Field'), false);
        user1.External_ID_gne__c = 'TESTUSERXXXX';
        User user2 = GNE_FRM_TestUtilities.createUser('TESTUSERYYYY', ids2ProfilesMap.get('GNE-Field'), false);
        User user3 = GNE_FRM_TestUtilities.createUser('TESTUSERZZZZ', ids2ProfilesMap.get('GNE-Field'), false);
        GNE_SFA2_Util.updateAdminSetings(true);
        insert new List<User> {user1,user2,user3};

        futureDML();
    }

    @future
    static void futureDML() {
    	Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
    	Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
        Territory2 parentTerr = new Territory2(Name = 'GNE-US-SFA', DeveloperName = 'TEST', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, External_Id_gne__c = 'Root;GNE-US-SFA', Parent_External_Id_gne__c ='Root');
        insert parentTerr;
        Territory2[] toInsert = new Territory2[]{};
        for(Integer x= 1; x<21; x++){
            Territory2 terr = GNE_FRM_TestUtilities.createTerritory('00F'+x+'-TEST', parentTerr.Id, false);
            terr.Salesforce_Code_gne__c = 'TEST';
            terr.Salesforce_SubTeam_Code_gne__c = 'TEST';
            terr.external_id_gne__c = 'Root;GNE-US-SFA;'+terr.Name;
            terr.Parent_External_Id_gne__c = 'Root;GNE-US-SFA';
            terr.Territory2ModelId = terrModelId;
            terr.Territory2TypeId = terrTypeId;
            
            toInsert.add(terr);
        }
        insert toInsert;
        List<UserTerritory2Association> uta2insert = new List<UserTerritory2Association>();
        for(Territory2 t:[SELECT Id FROM Territory2 WHERE External_id_gne__c Like 'GNE-US%' AND Territory_Number_gne__c != null LIMIT 2]) {
            for(User u :[SELECT Id FROM User WHERE External_ID_gne__c = 'TESTUSERXXXX']){
                uta2insert.add(new UserTerritory2Association(UserId=u.Id, Territory2Id=t.Id));
            }
            
        }
        insert uta2insert;
    }

    /*
     * we are not able to create user territory
     */
    @isTest
    static void testServiceResponseForExistingUser() {
        User[] existingUserInSystem = [
            SELECT Id, External_ID_gne__c
            FROM User
            WHERE Id IN (SELECT UserId FROM UserTerritory2Association)
            AND isActive = true
            AND Profile.Name IN ('GNE-SFA-Actemra-Manager','GNE-SFA-DM','GNE-SFA-Actemra-CS','GNE-SFA-CS','GNE-SFA-Lucentis-CS') LIMIT 1
        ];
        if(existingUserInSystem.isEmpty()) return;

        Test.startTest();
        	iPhone_Commons_gne.RestResponse response = iPhone_Get_User_Territory_gne.processRequest(String.valueOf(System.now().addDays(-5)),existingUserInSystem[0].External_ID_gne__c, new String[]{}, '');
        Test.stopTest();
        System.assertEquals(true, response.success);
    }

    @isTest
    static void testServiceResponseForExistingUserAndTerritoryLastSyncDate() {
        Territory2[] terrs = [SELECT Territory_Number_gne__c FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE User.External_ID_gne__c = 'TESTUSERXXXX')];
        My_Territory_Team_gne__c [] teams = new My_Territory_Team_gne__c [] {};

        for(User u :[SELECT Id FROM User WHERE Email IN ('testuserxxxxuser@gene.com','testuserzzzzuser@gene.com','testuseryyyyuser@gene.com')]){
            for(Territory2 terr: terrs){
                teams.add(new My_Territory_Team_gne__c(UserId_gne__c = u.Id, Territory_Number_gne__c=terr.Territory_Number_gne__c));
            }
        }
        insert teams;

        Test.startTest();
        	iPhone_Get_User_Territory_gne.DeltaRecordsResponse response = (iPhone_Get_User_Territory_gne.DeltaRecordsResponse)iPhone_Get_User_Territory_gne.processRequest(String.valueOf(System.now().addDays(-5)),'TESTUSERXXXX', new String[]{}, '');
        Test.stopTest();
        System.debug(response);

        System.assertEquals(true, response.success);
        System.assertEquals(1, response.records.size());
    }

    @isTest
    static void testServiceResponseForExistingUserAndTerritory() {
        Territory2[] terrs = [SELECT Territory_Number_gne__c FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE User.External_ID_gne__c = 'TESTUSERXXXX')];
        My_Territory_Team_gne__c [] teams = new My_Territory_Team_gne__c [] {};

        for(User u :[SELECT Id FROM User WHERE Email IN ('testuserxxxxuser@gene.com','testuserzzzzuser@gene.com','testuseryyyyuser@gene.com')]){
            for(Territory2 terr: terrs){
                teams.add(new My_Territory_Team_gne__c(UserId_gne__c = u.Id, Territory_Number_gne__c=terr.Territory_Number_gne__c));
            }
        }
        insert teams;

        Test.startTest();
        	iPhone_Get_User_Territory_gne.DeltaRecordsResponse response =
                (iPhone_Get_User_Territory_gne.DeltaRecordsResponse)iPhone_Get_User_Territory_gne.processRequest(
                    '',
                    'TESTUSERXXXX',
                    new String[]{terrs[0].Territory_Number_gne__c},
                    ''
                );
        Test.stopTest();
        System.assertEquals(true, response.success);
        System.assertEquals(1, response.records.size());
    }

    @isTest
    static void testServiceResponseForExistingUserAndTerritoryDelta() {
    	Territory2[] terrs = [SELECT Territory_Number_gne__c FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE User.External_ID_gne__c = 'TESTUSERXXXX')];

        Territory2[] commonTerrs = [SELECT Id FROm Territory2 WHERE Name Like '00F%-TEST'];
        System.debug(commonTerrs);

        My_Territory_Team_gne__c [] teams = new My_Territory_Team_gne__c [] {};
        Zip_to_Territory_gne__c [] zips = new Zip_to_Territory_gne__c[]{};
        Integer zipcodeSufix = 1;
        for(User u :[SELECT Id FROM User WHERE Email IN ('testuserxxxxuser@gene.com','testuserzzzzuser@gene.com','testuseryyyyuser@gene.com') AND External_ID_gne__c != 'TESTUSERXXXX']){
            for(Territory2 terr: terrs){

                teams.add(new My_Territory_Team_gne__c(UserId_gne__c = u.Id, Territory_Number_gne__c = terr.Territory_Number_gne__c,  Common_Terriotires_gne__c=commonTerrs.get(zipcodeSufix).Id));
                zips.add(new Zip_to_Territory_gne__c(STARS_BrandCode_gne__c = 'TEST', Zip_Code_gne__c = createZipCode(zipcodeSufix), Territory_Number_gne__c = terr.Territory_Number_gne__c));
                zipcodeSufix++;
                if(zipcodeSufix > 20) break;
            }
        }
        insert teams;
        insert zips;


        Test.startTest();
        	iPhone_Get_User_Territory_gne.DeltaRecordsResponse response =
                (iPhone_Get_User_Territory_gne.DeltaRecordsResponse)iPhone_Get_User_Territory_gne.processRequest(
                    String.valueOf(System.now().addDays(-5)),
                    'TESTUSERXXXX',
                    new String[]{terrs[0].Territory_Number_gne__c},
                    ''
                );
        Test.stopTest();
        System.assertEquals(true, response.success);
        System.assertEquals(1, response.records.size());
        iPhone_Get_User_Territory_gne.UserTerritoryRecord utr = (iPhone_Get_User_Territory_gne.UserTerritoryRecord)response.records[0];
    }

    public static String createZipCode(Integer zipcodeSufix) {
        String result = String.valueOf(zipcodeSufix);
        return '0'.repeat(5 - result.length()) + result;
    }
}