@isTest
private class GNE_FRM_DST_MatchLoserViewTest {
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
            
        DST_Match_Loser__c loser = new DST_Match_Loser__c(	Match_Loser_Account_SfdcId__c = loserAcc.Id);
        insert new List<DST_Match_Loser__c>{loser};
            
        DST_Match_Winner__c winner = new DST_Match_Winner__c(Match_Winner_SfdcId__c = winnerAcc.Id, Match_Loser_Account_SfdcId__c = loserAcc.Id);
        insert new List<DST_Match_Winner__c>{winner};        
    
    }
    
    /**
     * initial test to test all getters
     */ 
    @isTest
    static void initTest() {
        DST_Match_Loser__c bundle = [
            SELECT Id, Mdm_Bundle_Status__c, Request_Analyst_gne__c
            FROM DST_Match_Loser__c 
            LIMIT 1
        ];
        
        PageReference pageRef = new PageReference('/apex/GNE_FRM_DST_MatchloserView?id='+bundle.Id);
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            GNE_FRM_DST_MatchLoserView_Ctrl controller = new GNE_FRM_DST_MatchLoserView_Ctrl(new ApexPages.StandardController(bundle));
        	System.assertEquals(false, controller.getExceptionVisible());
        	System.assertEquals(true, controller.disableButton);
            controller.getAvailableDataStewards();
        	controller.changeStatus();
            System.assertEquals(false, controller.isReasonVisible);
            controller.enableButtons();
        	System.assertEquals(false, controller.disableButton);
        	controller.getHistories();
        Test.stopTest();
    }
    
    @isTest
    static void editBundle() {
        DST_Match_Loser__c bundle = [
            SELECT Id, Mdm_Bundle_Status__c, Request_Analyst_gne__c
            FROM DST_Match_Loser__c 
            LIMIT 1
        ];
        GNE_FRM_TestData.ForGNE_FRM_DST_MatchLoserViewTest testData = new GNE_FRM_TestData.ForGNE_FRM_DST_MatchLoserViewTest();
        PageReference pageRef = new PageReference('/apex/GNE_FRM_DST_MatchloserView?id='+bundle.Id);
        Test.setCurrentPage(pageRef);
        System.runAs(testData.frmUser) {
            Test.startTest();               
                GNE_FRM_DST_MatchLoserView_Ctrl controller = new GNE_FRM_DST_MatchLoserView_Ctrl(new ApexPages.StandardController(bundle));
                controller.editBundle();
                System.assertEquals(true, controller.isEditMode);
                controller.saveBundle();  
            Test.stopTest();
            
            System.assertEquals(false, controller.isEditMode);
            bundle = [
                SELECT Id, Mdm_Bundle_Status__c, Request_Analyst_gne__c
                FROM DST_Match_Loser__c 
                WHERE Id =:bundle.Id
            ];
            System.assertEquals(UserInfo.getUserId(), bundle.Request_Analyst_gne__c);   
        }
    }
    
    @isTest
    static void enterIntoEditMode() {
        DST_Match_Loser__c bundle = [
            SELECT Id, Mdm_Bundle_Status__c, Request_Analyst_gne__c
            FROM DST_Match_Loser__c 
            LIMIT 1
        ];
        
        PageReference pageRef = new PageReference('/apex/GNE_FRM_DST_MatchloserView?id='+bundle.Id+'&editMode=true');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            GNE_FRM_DST_MatchLoserView_Ctrl controller = new GNE_FRM_DST_MatchLoserView_Ctrl(new ApexPages.StandardController(bundle));
        Test.stopTest();
        System.assertEquals(true, controller.isEditMode);
        System.assertEquals(UserInfo.getUserId(), bundle.Request_Analyst_gne__c);
    }
    
    @isTest
    static void cancelAction() {
        DST_Match_Loser__c bundle = [
            SELECT Id, Mdm_Bundle_Status__c, Request_Analyst_gne__c
            FROM DST_Match_Loser__c 
            LIMIT 1
        ];
        
        PageReference pageRef = new PageReference('/apex/GNE_FRM_DST_MatchloserView?id='+bundle.Id+'&editMode=true');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            GNE_FRM_DST_MatchLoserView_Ctrl controller = new GNE_FRM_DST_MatchLoserView_Ctrl(new ApexPages.StandardController(bundle));
            System.assertEquals(true, controller.isEditMode);
            controller.cancelAction();
        Test.stopTest();
        System.assertEquals(false, controller.isEditMode);
    }
}