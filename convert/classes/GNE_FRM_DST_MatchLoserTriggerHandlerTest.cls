@isTest
private class GNE_FRM_DST_MatchLoserTriggerHandlerTest {
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
        
        List<RecordType> rts = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'CORE_Merge_Object__c' AND DeveloperName IN ('Group', 'Main') ORDER BY DeveloperName];
        CORE_Merge_Object__c parentMO = new CORE_Merge_Object__c(Object_Type_gne__c='ALL', Object_Name_gne__c='ALL', RecordTypeId = rts[0].Id, Order_gne__c=0,Region_Code_gne__c = 1,External_Id_gne__c='ALL-US');
        insert parentMO;
        List<CORE_Merge_Object__c> mobjs = new List<CORE_Merge_Object__c>{
            new CORE_Merge_Object__c(Name = 'Account-US', Object_Type_gne__c='Account', Object_Name_gne__c='Account', Parent_Merge_Object_gne__c=parentMO.Id,RecordTypeId = rts[1].Id,Order_gne__c=1,Region_Code_gne__c = 1,External_Id_gne__c='Account-US'), 
            new CORE_Merge_Object__c(Name = 'Address-US',Object_Type_gne__c='Address_vod__c', Object_Name_gne__c='Address', Parent_Merge_Object_gne__c=parentMO.Id,RecordTypeId = rts[1].Id,Order_gne__c=2,Region_Code_gne__c = 1,External_Id_gne__c='Address-US')
        };
        insert mobjs;       
    }
    
    @isTest
    static void insertMergeBundle(){
        Account [] accounts = [SELECT Id, Name FROM Account ORDER BY Name];
        DST_Match_Loser__c loser;
        DST_Match_Winner__c winner;
        String loserTxtId;
        for(Account acc : accounts){
            if(acc.Name == 'Loser Account'){
                loser = new DST_Match_Loser__c(Match_Loser_Account_SfdcId__c = acc.Id);
                loserTxtId = acc.Id;
            }
            if(acc.Name == 'Winner Account')winner = new DST_Match_Winner__c(Match_Winner_SfdcId__c = acc.Id, Match_Loser_Account_SfdcId__c = loser.Match_Loser_Account_SfdcId__c);
        }
        Test.startTest();
            insert loser;
            insert winner;       
        Test.stopTest(); 
        
        loser = [
            SELECT Match_Loser_Account_MdmId__c, Match_Loser_Text_SFDC_ID__c, Match_Loser_Name__c, Match_Loser_Accnt_Rec_Type__c,
               Match_Loser_Accnt_Type__c, Match_Loser_Address1__c, Match_Loser_City__c, Match_Loser_State__c, Match_Loser_Zip_Code__c,
               Winner_MdmId__c
            FROM DST_Match_Loser__c
            LIMIT 1
        ];
        System.assertEquals('0001', loser.Match_Loser_Account_MdmId__c);
        System.assertEquals(loserTxtId, loser.Match_Loser_Text_SFDC_ID__c);
        System.assertEquals('Loser Account', loser.Match_Loser_Name__c);
        System.assertEquals('FRM_HCO', loser.Match_Loser_Accnt_Rec_Type__c);
        System.assertEquals('Clinic', loser.Match_Loser_Accnt_Type__c);
        System.assertEquals('514 East Alvin Avenue', loser.Match_Loser_Address1__c);
        System.assertEquals('SANTA MARIA', loser.Match_Loser_City__c);
        System.assertEquals('93454', loser.Match_Loser_Zip_Code__c);
        System.assertEquals('CA', loser.Match_Loser_State__c);
        
    }
    
    @isTest
    static void changeWinner(){
        Account [] accounts = [SELECT Id, Name,(SELECT Id FROM Address_vod__r ) FROM Account ORDER BY Name];
        DST_Match_Loser__c loser;
        DST_Match_Winner__c winner;
        String loserTxtId;
        String winnerTxtId;
        String newWinnerTxtId;
        String addressId;
        for(Account acc : accounts){
            if(acc.Name == 'Loser Account'){
                loser = new DST_Match_Loser__c(Match_Loser_Account_SfdcId__c = acc.Id);
                loserTxtId = acc.Id;
            } else if(acc.Name == 'Winner Account'){
                winner = new DST_Match_Winner__c(Match_Winner_SfdcId__c = acc.Id, Match_Loser_Account_SfdcId__c = loser.Match_Loser_Account_SfdcId__c);
                winnerTxtId = acc.Id;
            } else if (acc.Name == 'Winner Account 02'){
                newWinnerTxtId = acc.Id;
                addressId = acc.Address_vod__r[0].Id;
            }
        }
        insert loser;
        insert winner; 
        loser.Winner_SfdcId__c = winnerTxtId;
        update loser;   
        loser = [
            SELECT Winner_MdmId__c,Winner_Account_Name_gne__c
            FROM DST_Match_Loser__c
            LIMIT 1
        ];
        System.assertEquals('0002', loser.Winner_MdmId__c);
        
        Test.startTest();
            loser.Winner_SfdcId__c = newWinnerTxtId;
            update loser;        
        Test.stopTest(); 
        
        loser = [
            SELECT Winner_Account_Name_gne__c, Winner_MdmId__c, Winner_Text_SfdcId__c, Winer_Address_Id_txt_gne__c
            FROM DST_Match_Loser__c
            LIMIT 1
        ];
        System.assertEquals('0003', loser.Winner_MdmId__c);
        System.assertEquals('Winner Account 02', loser.Winner_Account_Name_gne__c);
        System.assertEquals(newWinnerTxtId, loser.Winner_Text_SfdcId__c);
        System.assertEquals(addressId, loser.Winer_Address_Id_txt_gne__c);
    }
    
    @isTest
    static void approveBundle(){
        Account [] accounts = [SELECT Id, Name,(SELECT Id FROM Address_vod__r ) FROM Account ORDER BY Name];
        DST_Match_Loser__c loser;
        DST_Match_Winner__c winner;
        String loserTxtId;
        String winnerTxtId;
        for(Account acc : accounts){
            if(acc.Name == 'Loser Account'){
                loser = new DST_Match_Loser__c(Match_Loser_Account_SfdcId__c = acc.Id);
                loserTxtId = acc.Id;
            } else if(acc.Name == 'Winner Account'){
                winner = new DST_Match_Winner__c(Match_Winner_SfdcId__c = acc.Id, Match_Loser_Account_SfdcId__c = loser.Match_Loser_Account_SfdcId__c);
                winnerTxtId = acc.Id;
            } 
        }
        insert loser;
        insert winner; 
        
        Test.startTest();
            loser.Winner_SfdcId__c = winnerTxtId;
            loser.Mdm_Bundle_Status__c = DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_APPROVED;
            update loser;        
        Test.stopTest(); 
        
        CORE_Merge_Candidate__c [] mergeCandidates = [
            SELECT External_Id_gne__c,Status_gne__c, Candidate_Type_calc_gne__c, Object_Name_calc_gne__c, Master_Id_gne__c, Id_gne__c, CreatedDate, Error_Codes_gne__c, 
                Error_Details_gne__c, Loaded_Date_gne__c, MDM_Id_gne__c, Merge_Job_gne__c, Object_Type_calc_gne__c, Processed_Date_gne__c,  Source_gne__c, Type_gne__c 
            FROM CORE_Merge_Candidate__c 
        ];
        System.assertEquals(4, mergeCandidates.size());
        Boolean isLoserCandidateIsCorrect = false;
        Boolean isWinnerCandidateIsCorrect = false;
        for(CORE_Merge_Candidate__c c:mergeCandidates){
            if(c.Candidate_Type_calc_gne__c == 'WINNER' && c.Status_gne__c == 'Loaded' && c.Master_Id_gne__c == winnerTxtId && c.Id_gne__c == winnerTxtId){
                isWinnerCandidateIsCorrect = true;
            }
            if(c.Candidate_Type_calc_gne__c == 'LOSER' && c.Status_gne__c == 'Loaded' && c.Master_Id_gne__c == winnerTxtId && c.Id_gne__c == loserTxtId){
                isLoserCandidateIsCorrect = true;
            }
        }
        System.assertEquals(true, isWinnerCandidateIsCorrect);
        System.assertEquals(true, isLoserCandidateIsCorrect);        
    }
   
}