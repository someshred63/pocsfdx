@isTest
private class GNE_FRM_DST_MatchWinnerTriggerTest {
    @testSetup
    static void initData() {
        Account loserAcc = GNE_FRM_TestUtilities.createAccount('Loser Account', 'FRM_HCO','Clinic',false);
        loserAcc.MDMID_gne__c = '0001';
        Account winnerAcc = GNE_FRM_TestUtilities.createAccount('Winner Account', 'FRM_HCO','Pharmacy',false);
        winnerAcc.MDMID_gne__c = '0002';
        Account winnerAcc1 = GNE_FRM_TestUtilities.createAccount('Winner Account 02', 'FRM_HCO','Pharmacy',false);
        winnerAcc1.MDMID_gne__c = '0003';
        insert new List<Account>{loserAcc, winnerAcc, winnerAcc1};       
        
        Address_vod__c loserAddress = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', loserAcc.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c winnerAddress = GNE_FRM_TestUtilities.createAddress('519 East Alvin Avenue', winnerAcc.Id, 'SANTA MARIA', 'CA', '93455', false);
        Address_vod__c winnerAddress1 = GNE_FRM_TestUtilities.createAddress('529 East Alvin Avenue', winnerAcc1.Id, 'SANTA MARIA', 'CA', '93466', false);
        insert new List<Address_vod__c> {loserAddress, winnerAddress, winnerAddress1};      
            
        DST_Match_Loser__c loser = new DST_Match_Loser__c(	Match_Loser_Account_SfdcId__c = loserAcc.Id);
        insert new List<DST_Match_Loser__c>{loser};
            
    }
    
    @isTest
    static void testOnInsertTrigger(){
        Map<String, Account> name2Account = new Map<String, Account>();
        for(Account acc :[
           SELECT Id, Name FROM Account WHERE Name IN ('Winner Account', 'Loser Account' )
        ]){
            name2Account.put(acc.Name, acc);
        }
        DST_Match_Winner__c winner = new DST_Match_Winner__c(Match_Winner_SfdcId__c = name2Account.get('Winner Account').Id, Match_Loser_Account_SfdcId__c = name2Account.get('Loser Account').Id);
        
        Test.startTest();
            insert new List<DST_Match_Winner__c>{winner}; 
        Test.stopTest();
        
        winner = [
            SELECT Id, Match_Loser__c, Match_Winner_MdmId__c, Match_Winner_Text_SfdcId__c, Match_Winner_Name__c, Match_Winner_Accnt_Rec_Type__c, Match_Winner_Accnt_Type__c,
                Match_Winner_State__c, Match_Winner_Zip_Code__c, Match_Winner_Address1__c, Match_Winner_City__c
            FROM DST_Match_Winner__c
            WHERE Id = : winner.Id
        ];
        
        DST_Match_Loser__c loser = [SELECT Id FROM DST_Match_Loser__c LIMIT 1];
        
        System.assertEquals(winner.Match_Loser__c, loser.Id);
        System.assertEquals(winner.Match_Winner_MdmId__c, '0002');
        System.assertEquals(winner.Match_Winner_Text_SfdcId__c, name2Account.get('Winner Account').Id);
        System.assertEquals(winner.Match_Winner_Name__c, name2Account.get('Winner Account').Name);
        System.assertEquals(winner.Match_Winner_Accnt_Rec_Type__c, 'FRM_HCO');
        System.assertEquals(winner.Match_Winner_Accnt_Type__c, 'Pharmacy');
        System.assertEquals(winner.Match_Winner_State__c, 'CA');
        System.assertEquals(winner.Match_Winner_Zip_Code__c, '93455');
        System.assertEquals(winner.Match_Winner_Address1__c, '519 East Alvin Avenue');
        System.assertEquals(winner.Match_Winner_City__c, 'SANTA MARIA');
    }
    
    @isTest
    static void testOnUpdateTrigger(){
        Map<String, Account> name2Account = new Map<String, Account>();
        for(Account acc :[
           SELECT Id, Name FROM Account WHERE Name IN ('Winner Account', 'Loser Account', 'Winner Account 02' )
        ]){
            name2Account.put(acc.Name, acc);
        }
        DST_Match_Winner__c winner = new DST_Match_Winner__c(Match_Winner_SfdcId__c = name2Account.get('Winner Account').Id, Match_Loser_Account_SfdcId__c = name2Account.get('Loser Account').Id);
        insert new List<DST_Match_Winner__c>{winner}; 
        Test.startTest();
            winner.Match_Winner_SfdcId__c = name2Account.get('Winner Account 02').Id;
            update winner;
        Test.stopTest();
        
        winner = [
            SELECT Id, Match_Loser__c, Match_Winner_MdmId__c, Match_Winner_Text_SfdcId__c, Match_Winner_Name__c, Match_Winner_Accnt_Rec_Type__c, Match_Winner_Accnt_Type__c,
                Match_Winner_State__c, Match_Winner_Zip_Code__c, Match_Winner_Address1__c, Match_Winner_City__c
            FROM DST_Match_Winner__c
            WHERE Id = : winner.Id
        ];
        
        System.assertEquals(winner.Match_Winner_MdmId__c, '0003');
        System.assertEquals(winner.Match_Winner_Text_SfdcId__c, name2Account.get('Winner Account 02').Id);
        System.assertEquals(winner.Match_Winner_Name__c, name2Account.get('Winner Account 02').Name);
        System.assertEquals(winner.Match_Winner_Accnt_Rec_Type__c, 'FRM_HCO');
        System.assertEquals(winner.Match_Winner_Accnt_Type__c, 'Pharmacy');
        System.assertEquals(winner.Match_Winner_State__c, 'CA');
        System.assertEquals(winner.Match_Winner_Zip_Code__c, '93466');
        System.assertEquals(winner.Match_Winner_Address1__c, '529 East Alvin Avenue');
        System.assertEquals(winner.Match_Winner_City__c, 'SANTA MARIA');
    }
}