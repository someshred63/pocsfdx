@isTest
public class GNE_SFA2_Team2ProductMapping_Test {

    @isTest
    private static void testSavingMapping() {
        User canadaOpsUser = [SELECT Id, Name FROM User WHERE Profile_Name_gne__c LIKE 'RCanada-SFA-OPS' AND IsActive = true LIMIT 1];

        System.runAs(canadaOpsUser) {
            addSampleProduct();
            Team_Mapping_gne__c mapping = new Team_Mapping_gne__c(Salesforce_Code_gne__c = 'Test');
            ApexPages.StandardController standardController = new ApexPages.StandardController(mapping);
            GNE_SFA2_Team2ProductMapping_Ctrl mainController = new GNE_SFA2_Team2ProductMapping_Ctrl(standardController);
            mainController.product = 'Test';
            mainController.salesforceCode = 'TestCode';
            mainController.salesforceSubTeamCode = 'TestSubTeamCode';

            mainController.salesforceCodeForSearch = 'TestCode';
            mainController.salesforceSubTeamCodeForSearch = 'TestSubTeamCode';

            Test.startTest();
            mainController.saveTeamMapping();
            mainController.search();
            Test.stopTest();

            List<Team_Mapping_gne__c> queriedMapping = mainController.mappings;
            System.assertEquals(queriedMapping.isEmpty(),false);
            System.assertEquals(queriedMapping.size(),1);
        }
    }

    private static void addSampleProduct() {
        Product_vod__c product = new Product_vod__c(Name = 'Test', Product_Type_vod__c = 'Detail', active__c = true);
        insert product;
    }

    @isTest
    private static void testPageMessages() {
        User canadaOpsUser = [SELECT Id, Name FROM User WHERE Profile_Name_gne__c LIKE 'RCanada-SFA-OPS' AND IsActive = true LIMIT 1];

        System.runAs(canadaOpsUser) {
            addSampleProduct();
            Team_Mapping_gne__c mapping = new Team_Mapping_gne__c(Salesforce_Code_gne__c = 'Test');
            ApexPages.StandardController standardController = new ApexPages.StandardController(mapping);
            GNE_SFA2_Team2ProductMapping_Ctrl mainController = new GNE_SFA2_Team2ProductMapping_Ctrl(standardController);

            mainController.saveTeamMapping();
           
            System.assertEquals(checkIfMessageContains('Choose product'), true);
            mainController.product = 'Test';
            
            System.assertEquals(checkIfMessageContains('Enter Salesforce Code'), true);
            mainController.salesforceCode = 'TestCode';
            
            System.assertEquals(checkIfMessageContains('Enter Salesforce Sub Team Code'), true);
            mainController.salesforceSubTeamCode = 'TestSubTeamCode';

            mainController.saveTeamMapping();
            mainController.search();

            System.assertEquals(checkIfMessageContains('Enter search keywords'), true);
            mainController.salesforceCodeForSearch = 'TestCode';
        }
    }

    private static Boolean checkIfMessageContains(String textMessage) {
        List<Apexpages.Message> messages = ApexPages.getMessages();
        Boolean isThere = false;
        for(Apexpages.Message message : messages){
            if(message.getDetail().contains(textMessage))
                isThere = true;
        }
        return isThere;
    }
}