/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-12
*  Description: This is a helper class for Brand Affiliation related unit tests
*  
*  Modification History
*  Date        Name        Description
*  
*************************************************************/
public without sharing class GNE_SFA2_Brand_Affiliation_Test_Helper {
    public static Integer BATCH_SIZE = 201; // 201 to test agains governor limits
    
    /* helper method used for preparing test accounts */
    public static List<Account> prepareTestAccounts() {
        List<Account> testData = new List<Account>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testData.add(new Account(firstName = 'firstName' + i, lastName = 'lastName' + i));
        }
        insert testData;
        return testData;
    }
    
    /* helper method used for preparing test products */
    public static List<Product_vod__c> prepareTestProducts() {
        List<Product_vod__c> testData = new List<Product_vod__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testData.add(new Product_vod__c(Name = 'testProduct' + i));
        }
        insert testData;
        return testData;
    }
    
    /* helper method used for preparing test brand affiliations */
    public static List<Product_Metrics_vod__c> prepareTestBrandAffiliations(List<Account> accounts, List<Product_vod__c> products){
        List<Product_Metrics_vod__c> testData = new List<Product_Metrics_vod__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testData.add(new Product_Metrics_vod__c(Account_vod__c = accounts[i].Id, Products_vod__c = products[i].Id));
        }
        insert testData;
        return testData;
    }
    
    /* helper method used for preparing test speaker contracts */
    public static List<Speaker_Contract_gne__c> prepareTestSpeakerContracts(List<Account> accounts){
        List<Speaker_Contract_gne__c> testData = new List<Speaker_Contract_gne__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testData.add(new Speaker_Contract_gne__c(Contracted_Party_ID__c = accounts[i].Id, End_Date_gne__c = System.today()));
        }
        insert testData;
        return testData;
    }
    
    /* helper method used for preparing test speaker bureaus */
    public static List<Speaker_Bureau_gne__c> prepareTestSpeakerBureaus(){
        List<Speaker_Bureau_gne__c> testData = new List<Speaker_Bureau_gne__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testData.add(new Speaker_Bureau_gne__c(Name = 'testSeakerBureau'));
        }
        insert testData;
        return testData;
    }
    
    /* helper method used for preparing test speaker bureau memberships */
    public static List<Speaker_Bureau_Membership_gne__c> prepareTestSpeakerBureausMemberships(List<Speaker_Bureau_gne__c> speakerBureaus, List<Account> accounts){
        List<Speaker_Bureau_Membership_gne__c> testData = new List<Speaker_Bureau_Membership_gne__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testData.add(
                new Speaker_Bureau_Membership_gne__c(
                    Speaker_Bureau_ID_gne__c = speakerBureaus[i].Id,
                     Bureau_Member_gne__c = accounts[i].Id,
                     Speaker_Status_gne__c='Approved'
                     )
                );
        }
        
        insert testData;
        return testData;
    }
    
    /* helper method used for preparing test speaker bureau products */
    public static List<Speaker_Bureau_Product_gne__c> prepareTestSpeakerBureauProducts(List<Speaker_Bureau_gne__c> speakerBureaus, List<Product_vod__c> products){
        List<Speaker_Bureau_Product_gne__c> testData = new List<Speaker_Bureau_Product_gne__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testData.add(new Speaker_Bureau_Product_gne__c(Speaker_Bureau_gne__c = speakerBureaus[i].Id, Product_vod_gne__c = products[i].Id));
        }
        insert testData;
        return testData;
    }
}