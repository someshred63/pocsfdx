@isTest
private class GNE_My_Territory_Team_BatchTest {
    static Territory2[] toInsert = new Territory2[]{};
    @testSetup
    static void testData() {
        GNE_SFA2_Util.updateAdminSetings(true);

 		String[] userIds = new String[]{};
        Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
        User user1 = GNE_FRM_TestUtilities.createUser('frmManager', ids2ProfilesMap.get('GNE-Field'), false);
        User user2 = GNE_FRM_TestUtilities.createUser('frmUser2', ids2ProfilesMap.get('GNE-Field'), false);
        insert new List<User> {user1, user2};
        userIds.add(user1.Id);
        userIds.add(user2.Id);
        insertTerr();
        futureDML(userIds);
    }

    public static String createZipCode(Integer zipcodeSufix) {
        String result = String.valueOf(zipcodeSufix);
        return '0'.repeat(5 - result.length()) + result;
    }
    @future
    static void insertTerr(){
        Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
    	Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
        Territory2 parentTerr = new Territory2(Name = 'GNE-US-SFA', DeveloperName = 'TEST', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, External_Id_gne__c = 'Root;GNE-US-SFA', Parent_External_Id_gne__c ='Root');
        insert parentTerr;
        
        for(Integer x= 1; x<11; x++){
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
    }
    @future
    static void futureDML( String[] userIds) {
        String[] terrNumbers = new String[]{};
            for(Territory2 t: [SELECT name,Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c, external_id_gne__c FROM Territory2 WHERE Id IN : toInsert] ){
            terrNumbers.add(t.Territory_Number_gne__c);
        }
        Zip_to_Territory_gne__c [] zipsToInsert = new Zip_to_Territory_gne__c[]{};
        Integer zipcodeSufix = 1;
        for(String t : terrNumbers){
            for(Integer x = 0; x<10; x++){
                Zip_to_Territory_gne__c z2t = new Zip_to_Territory_gne__c(Territory_Number_gne__c = t,Zip_Code_gne__c=createZipCode(zipcodeSufix),STARS_BrandCode_gne__c='TEST');
                zipsToInsert.add(z2t);
                zipcodeSufix++;
                System.debug(z2t);
            }
        }
        insert zipsToInsert;
        createMTT(terrNumbers, userIds);
        createTeamMappings();
        createMRR(userIds);

    }

    static void createTeamMappings() {
        Product_vod__c productCatalog = new Product_vod__c();
        productCatalog.Therapeutic_Area_vod__c = 'Oncology';
        productCatalog.Brand_Code_gne__c = 'REMOVETHIS';
		insert productCatalog;
        Team_Mapping_gne__c tm = new Team_Mapping_gne__c();
        tm.Salesforce_Code_gne__c = 'TEST';
        tm.Salesforce_SubTeam_Code_gne__c = 'TEST';
        tm.Product_gne__c = productCatalog.Id;
        insert tm;

    }

    static void createMTT(String[] terrNumbers, String[] userIds){
        My_Territory_Team_gne__c[] mtts = new My_Territory_Team_gne__c[]{};
        for(String u : userIds){
            for(Integer x = 0; x < 4; x++){
                mtts.add(new My_Territory_Team_gne__c(UserId_gne__c = u, Territory_Number_gne__c = terrNumbers.get(x)));
            }
        }
        insert mtts;
    }

    static void createMRR(String[] userIds) {
        MA_Referral_Roster__c [] toInsert = new MA_Referral_Roster__c []{};
        for(String u : userIds){
            MA_Referral_Roster__c mrr = new MA_Referral_Roster__c(TA__c = 'Oncology', User__c = u, Is_Active__c=true, Is_Active_User__c=true, State__c = 'CA');
            toInsert.add(mrr);
        }
        GNE_SFA2_Util.updateAdminSetings(true);
        insert toInsert;
        GNE_SFA2_Util.updateAdminSetings(false);
    }


    @isTest
    static void initTestForBatch() {
        GNE_My_Territory_Team_Batch batch = new GNE_My_Territory_Team_Batch(new Set<String>{'00F1','00F2','00F3'});
        Test.startTest();
        	Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void initTestForBatchForPrev() {
        Set<String> territoriesNumbers = new Set<String>{'00F1','00F2','00F3'};
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] {};
        GNE_My_Territory_Team_Batch batch = new GNE_My_Territory_Team_Batch(territoriesNumbers, statistics, 1, System.now().addDays(-2), true);
        Test.startTest();
        	Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void initTestLimitException() {
        Set<String> territoriesNumbers = new Set<String>{'00F1','00F2','00F3'};
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] {};
        GNE_My_Territory_Team_Batch batch = new GNE_My_Territory_Team_Batch(territoriesNumbers, statistics, 1, System.now().addDays(-2));
        Test.startTest();
        	Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    static void testBatchWithScope() {
		Set<String> teritoriesNumbers = new Set<String>{'00F1','00F2','00F3'};
    	
        GNE_My_Territory_Team_Batch batch = new GNE_My_Territory_Team_Batch(teritoriesNumbers);
        batch.start(null);
        List<Zip_to_Territory_gne__c> scope = [SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c, Zip_Code_gne__c FROM Zip_to_Territory_gne__c WHERE Territory_Number_gne__c='00F1'];
        Test.startTest();
        	batch.runProcess(scope);
        Test.stopTest();
    }

    @isTest
    static void testAffectedTerr() {
        Product_vod__c prod = new Product_vod__c(Therapeutic_Area_vod__c='Oncology');
        insert prod;
        prod.Therapeutic_Area_vod__c = 'Analgesics';
        update prod;
        Set<String> territoriesNumbers = new Set<String>{'00F1','00F2','00F3'};
        GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] {};
        GNE_My_Territory_Team_Batch batch = new GNE_My_Territory_Team_Batch(territoriesNumbers, statistics, 1, System.now().addDays(-2));
        Test.startTest();
            Database.executeBatch(batch);
        Test.stopTest();
    }
}