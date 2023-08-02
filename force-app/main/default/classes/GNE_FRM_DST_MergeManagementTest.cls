@isTest
private class GNE_FRM_DST_MergeManagementTest {    
    @testSetup
    static void initData() {
        Account loserAcc = GNE_FRM_TestUtilities.createAccount('Loser Account 01', 'FRM_HCO','Clinic',false);
        loserAcc.MDMID_gne__c = '0001';
        Account winnerAcc = GNE_FRM_TestUtilities.createAccount('Winner Account 01', 'FRM_HCO','Pharmacy',false);
        winnerAcc.MDMID_gne__c = '0002';
        Account loserAcc1 = GNE_FRM_TestUtilities.createAccount('Loser Account 02', 'FRM_HCO','Clinic',false);
        loserAcc.MDMID_gne__c = '0003';
        Account winnerAcc1 = GNE_FRM_TestUtilities.createAccount('Winner Account 02', 'FRM_HCO','Pharmacy',false);
        winnerAcc.MDMID_gne__c = '0004';
        Account loserAcc2 = GNE_FRM_TestUtilities.createAccount('Loser Account 03', 'FRM_HCO','Clinic',false);
        loserAcc.MDMID_gne__c = '0005';
        Account winnerAcc2 = GNE_FRM_TestUtilities.createAccount('Winner Account 03', 'FRM_HCO','Pharmacy',false);
        winnerAcc.MDMID_gne__c = '0006';
        insert new List<Account>{loserAcc, winnerAcc, loserAcc1, winnerAcc1,loserAcc2, winnerAcc2};       
        
        Address_vod__c loserAddress = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', loserAcc.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c winnerAddress = GNE_FRM_TestUtilities.createAddress('519 East Alvin Avenue', winnerAcc.Id, 'SANTA MARIA', 'CA', '93455', false);
        Address_vod__c loserAddress1 = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', loserAcc1.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c winnerAddress1 = GNE_FRM_TestUtilities.createAddress('519 East Alvin Avenue', winnerAcc1.Id, 'SANTA MARIA', 'CA', '93455', false);
        Address_vod__c loserAddress2 = GNE_FRM_TestUtilities.createAddress('514 East Alvin Avenue', loserAcc2.Id, 'SANTA MARIA', 'CA', '93454', false);
        Address_vod__c winnerAddress2 = GNE_FRM_TestUtilities.createAddress('519 East Alvin Avenue', winnerAcc2.Id, 'SANTA MARIA', 'CA', '93455', false);
        insert new List<Address_vod__c> {loserAddress, winnerAddress, loserAddress1, winnerAddress1,loserAddress2, winnerAddress2};
            
        DST_Match_Loser__c loser1 = new DST_Match_Loser__c(	Match_Loser_Account_SfdcId__c = loserAcc.Id);
        DST_Match_Loser__c loser2 = new DST_Match_Loser__c(	Match_Loser_Account_SfdcId__c = loserAcc.Id);
        DST_Match_Loser__c loser3 = new DST_Match_Loser__c(	Match_Loser_Account_SfdcId__c = loserAcc.Id);
        insert new List<DST_Match_Loser__c>{loser1, loser2, loser3 };
            
        DST_Match_Winner__c winner1 = new DST_Match_Winner__c(Match_Winner_SfdcId__c = winnerAcc.Id, Match_Loser_Account_SfdcId__c = loserAcc.Id);
        DST_Match_Winner__c winner2 = new DST_Match_Winner__c(Match_Winner_SfdcId__c = winnerAcc.Id, Match_Loser_Account_SfdcId__c = loserAcc.Id);
        DST_Match_Winner__c winner3 = new DST_Match_Winner__c(Match_Winner_SfdcId__c = winnerAcc.Id, Match_Loser_Account_SfdcId__c = loserAcc.Id);
        insert new List<DST_Match_Winner__c>{winner1, winner2, winner3};            
    }
    
    /**
     * initial test to test all getters
     */ 
    @isTest
    static void initTest() {   
        GNE_FRM_TestData.ForGNE_FRM_DST_MergeManagementTest testData = new GNE_FRM_TestData.ForGNE_FRM_DST_MergeManagementTest();
        PageReference pageRef = new PageReference('/apex/GNE_FRM_DST_MergeManagement');
        Test.setCurrentPage(pageRef);
        System.runAs(testData.frmUser) {
            Test.startTest();
                GNE_FRM_DST_MergeManagement_Ctrl controller = new GNE_FRM_DST_MergeManagement_Ctrl();        	
            Test.stopTest();
            System.assertEquals(3, controller.records.size());
        }
    }
    
    @isTest
    static void testViewLists() { 
        GNE_FRM_TestData.ForGNE_FRM_DST_MergeManagementTest testData = new GNE_FRM_TestData.ForGNE_FRM_DST_MergeManagementTest();
        System.runAs(testData.frmUser) {
            DST_Match_Loser__c [] losers = [SELECT Request_Analyst_gne__c, Mdm_Bundle_Status__c FROM DST_Match_Loser__c];
            losers[0].Mdm_Bundle_Status__c = 'Closed-Rejected';
            losers[1].Request_Analyst_gne__c = UserInfo.getUserId();
            update losers;
            PageReference pageRef = new PageReference('/apex/GNE_FRM_DST_MergeManagement');
            Test.setCurrentPage(pageRef);
                
            Test.startTest();
                GNE_FRM_DST_MergeManagement_Ctrl controller = new GNE_FRM_DST_MergeManagement_Ctrl();  
                controller.viewId ='open';
                controller.loadRecords();
                System.assertEquals(2, controller.records.size());
                controller.viewId = 'closed';
                controller.loadRecords();
                System.assertEquals(1, controller.records.size());
                controller.viewId = 'myBundles';
                controller.loadRecords();
                System.assertEquals(1, controller.records.size());            
            Test.stopTest();
        }
    }
}