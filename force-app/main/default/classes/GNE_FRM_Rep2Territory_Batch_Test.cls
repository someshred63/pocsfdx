@isTest
private class GNE_FRM_Rep2Territory_Batch_Test {

    @isTest static void testCreateRep2Terr(){
        GNE_FRM_TestData.ForRep2Territory_Batch_Test testData = new GNE_FRM_TestData.ForRep2Territory_Batch_Test();
        GNE_FRM_Rep2Territory_Create_Batch cb = new GNE_FRM_Rep2Territory_Create_Batch();
        Test.startTest();
            System.runAs(testData.admin){
                cb.execute(null, testData.userTerritories);
            }
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROm FRM_Rep_2_Terr_gne__c].size());
    }
    
    @isTest static void testRemoveUserTerritory(){
        GNE_FRM_TestData.ForRep2Territory_Batch_Test testData = new GNE_FRM_TestData.ForRep2Territory_Batch_Test();
        Territory2 terr = GNE_FRM_TestUtilities.createTerritory('Terr2', null, false);
        terr.External_Id_gne__c = 'Root;Terr2';
        terr.Parent_External_Id_gne__c ='Root';
        insert terr;
        testData.userTerritories.add(new UserTerritory2Association(Territory2Id = terr.Id, UserId = testData.afrmManager.Id, Id ='0R070000000MSebYYX'));
        GNE_FRM_Rep2Territory_Create_Batch cb = new GNE_FRM_Rep2Territory_Create_Batch();
        Test.startTest();
            System.runAs(testData.admin){
                cb.execute(null, testData.userTerritories);
            }
            System.assertEquals(2, [SELECT Id FROM FRM_Rep_2_Terr_gne__c].size());
            testData.userTerritories.remove(1) ;
            GNE_FRM_Rep2Territory_Clean_Batch cleanBatch = new GNE_FRM_Rep2Territory_Clean_Batch();
            Database.executeBatch(cleanBatch);
        Test.stopTest();
        List<FRM_Rep_2_Terr_gne__c> terrs = [SELECT Id, SFDC_TerritoryName_gne__c FROM FRM_Rep_2_Terr_gne__c];
        System.assertEquals(0, terrs.size());    
    }
    
}