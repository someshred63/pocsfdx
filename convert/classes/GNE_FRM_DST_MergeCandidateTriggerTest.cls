@isTest
private class GNE_FRM_DST_MergeCandidateTriggerTest {
    @testSetup
    static void initData() {
        Account loserAcc = GNE_FRM_TestUtilities.createAccount('Loser Account', 'FRM_HCO','Clinic',false);
        loserAcc.MDMID_gne__c = '0001';
        Account winnerAcc = GNE_FRM_TestUtilities.createAccount('Winner Account', 'FRM_HCO','Pharmacy',false);
        winnerAcc.MDMID_gne__c = '0002';
        insert new List<Account>{loserAcc, winnerAcc};       
        
        Address_vod__c loserAddress = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', loserAcc.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c winnerAddress = GNE_FRM_TestUtilities.createAddress('519 East Alvin Avenue', winnerAcc.Id, 'SANTA MARIA', 'CA', '93455', false);
        insert new List<Address_vod__c> {loserAddress, winnerAddress};
        
        List<RecordType> rts = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'CORE_Merge_Object__c' AND DeveloperName IN ('Group', 'Main') ORDER BY DeveloperName];
        CORE_Merge_Object__c parentMO = new CORE_Merge_Object__c(Object_Type_gne__c='ALL', Object_Name_gne__c='ALL', RecordTypeId = rts[0].Id, Order_gne__c=0,Region_Code_gne__c = 1,External_Id_gne__c='ALL-US');
        insert parentMO;
        List<CORE_Merge_Object__c> mobjs = new List<CORE_Merge_Object__c>{
            new CORE_Merge_Object__c(Name = 'Account-US', Object_Type_gne__c='Account', Object_Name_gne__c='Account', Parent_Merge_Object_gne__c=parentMO.Id,RecordTypeId = rts[1].Id,Order_gne__c=1,Region_Code_gne__c = 1,External_Id_gne__c='Account-US'), 
            new CORE_Merge_Object__c(Name = 'Address-US',Object_Type_gne__c='Address_vod__c', Object_Name_gne__c='Address', Parent_Merge_Object_gne__c=parentMO.Id,RecordTypeId = rts[1].Id,Order_gne__c=2,Region_Code_gne__c = 1,External_Id_gne__c='Address-US')
        };
        insert mobjs;    
        
        DST_Match_Loser__c loser = new DST_Match_Loser__c(Match_Loser_Account_SfdcId__c = loserAcc.Id);
        insert new List<DST_Match_Loser__c>{loser};
        
        DST_Match_Winner__c winner = new DST_Match_Winner__c(Match_Winner_SfdcId__c = winnerAcc.Id, Match_Loser_Account_SfdcId__c = loserAcc.Id);
        insert new List<DST_Match_Winner__c>{winner}; 
    }
    
    @isTest
    static void test_populateStatusOnLosers_Processed_Scenario() {
        Map<String, Account> name2Account = new Map<String, Account>();
        for(Account acc :[
           SELECT Id, Name FROM Account WHERE Name IN ('Winner Account', 'Loser Account' )
        ]){
            name2Account.put(acc.Name, acc);
        }
        DST_Match_Loser__c loser = [SELECT Id, Winner_SfdcId__c, Mdm_Bundle_Status__c FROM DST_Match_Loser__c LIMIT 1];
        loser.Winner_SfdcId__c = name2Account.get('Winner Account').Id;
        loser.Mdm_Bundle_Status__c = DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_APPROVED;
        update loser;
        
        CORE_Merge_Candidate__c [] mergeCandidates = [
            SELECT External_Id_gne__c,Status_gne__c, Candidate_Type_calc_gne__c, Object_Name_calc_gne__c, Master_Id_gne__c, Id_gne__c, CreatedDate, Error_Codes_gne__c, 
                Error_Details_gne__c, Loaded_Date_gne__c, MDM_Id_gne__c, Merge_Job_gne__c, Object_Type_calc_gne__c, Processed_Date_gne__c,  Source_gne__c, Type_gne__c 
            FROM CORE_Merge_Candidate__c 
        ];
        
        for(CORE_Merge_Candidate__c mc: mergeCandidates){
            mc.Status_gne__c = 'Processed';
        }
        Test.startTest();
            update mergeCandidates;        
        Test.stopTest(); 
        Boolean isBundleIsCorrect = false;
        for(DST_Match_Loser__c ml :[SELECT Mdm_Bundle_Status__c, Merge_Bundle_Exception__c FROM DST_Match_Loser__c]){
            System.debug(ml.Mdm_Bundle_Status__c);
            System.assertEquals('Merged', ml.Mdm_Bundle_Status__c);
            isBundleIsCorrect = true;
        }
        System.assertEquals(true, isBundleIsCorrect);        
    }
}