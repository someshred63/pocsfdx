/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 *
 *  @author: Krzysztof Leszek, Roche
 *  Date: 08-February-2010 
 *  Description: M&E Req# 00002522 - unit test class. Prevent Brand Affiliation duplicates 
 *               from being created (implemented using GNE_validateBrandAffiliation_BeforeInsertUpdate
 *               trigger on the Brand Affiliation object)
 *                           
 *  Modification History
 *  Date        Name        Description
 *                
 */
@isTest
private class Test_GNE_validateBrandAff_Trigger {
    private static ID accountId, productId, product2Id;
    
    static {
        // Create test account
        Account objAccount = new Account(FirstName = 'FName', LastName = 'LName');
        insert objAccount;
        accountId = objAccount.Id;
        
        // Create test product 1
        Product_vod__c objProduct = new Product_vod__c (Name = 'Test Product', Product_Type_vod__c = 'Detail');
        insert objProduct;
        productId = objProduct.Id;
        
        // Create test product 2
        objProduct = new Product_vod__c (Name = 'Test Product 2', Product_Type_vod__c = 'Detail');
        insert objProduct;
        product2Id = objProduct.Id;        
    }   
    
    static testMethod void runPositiveTestCases() {     
        Product_Metrics_vod__c objBrandAff = new Product_Metrics_vod__c(Account_vod__c = accountId, Products_vod__c = productId);
        insert objBrandAff;
        
        // Verify that the Unique Key field on the newly created brand affiliation record 
        // was populated by the trigger with value of the formula field
        objBrandAff = [SELECT Unique_Key_Calc_gne__c, Unique_Key_gne__c, Products_vod__c FROM Product_Metrics_vod__c WHERE Id = :objBrandAff.Id];                      
        System.assertEquals(objBrandAff.Unique_Key_Calc_gne__c, objBrandAff.Unique_Key_gne__c);  
        
       // Verify that the trigger correctly updates the Unique Field on a brand affiliation record 
       // when the product is changed       
       objBrandAff.Products_vod__c = product2Id;
       update objBrandAff;
       objBrandAff = [SELECT Unique_Key_Calc_gne__c, Unique_Key_gne__c, Products_vod__c FROM Product_Metrics_vod__c WHERE Id = :objBrandAff.Id];                      
       System.assertEquals(objBrandAff.Unique_Key_Calc_gne__c, objBrandAff.Unique_Key_gne__c);  
    }
    
    static testMethod void runNegativeTestCases() {
        // Test that the system does not allow duplicates
        insert new Product_Metrics_vod__c(Account_vod__c = accountId, Products_vod__c = productId);
        try {
            insert new Product_Metrics_vod__c(Account_vod__c = accountId, Products_vod__c = productId);
        } catch (DmlException e) {
          System.assert(e.getMessage().indexOf('DUPLICATE_VALUE') > 0);
          return;
        }
        System.assert(false);
    }      
    
    static testMethod void runNegativeTestCaseBatch() {
        // Test that the system prevents duplicates when data is loaded in bulk 
        Product_Metrics_vod__c objBrandAff = new Product_Metrics_vod__c(Account_vod__c = accountId, Products_vod__c = productId);
        insert objBrandAff;        
        
        // Prepare 200 duplicate Brand Affiliations to load               
        List<Product_Metrics_vod__c> objBrandAffList = new List<Product_Metrics_vod__c>{};
        for(Integer i=0; i<200;i++){
            objBrandAffList.add(new Product_Metrics_vod__c(Account_vod__c = accountId, Products_vod__c = productId));
        }
        
        // Negative test
        try {
            //Now insert data causing Brand Affiliation trigger to fire 
            insert objBrandAffList;
        } 
        catch (DmlException e) {
          System.assert(e.getMessage().indexOf('DUPLICATE_VALUE') > 0);
          return;
        } 
        finally {
            System.AssertEquals(1, database.countquery('SELECT count() FROM Product_Metrics_vod__c WHERE Account_vod__c = :accountId'));
        }       
    }    
    
    static testMethod void runPositiveTestCaseBatch() {       
        // Test that the system allows to load non-duplicate brand affiliation records in bulk mode
        List<Account> objAccountList = new List<Account>{};
        for(Integer i=0; i<50;i++){
            objAccountList.add(new Account(FirstName = 'FName'+i, LastName = 'LName'+i));
        }              
        insert objAccountList;          
        
        // Prepare 50 valid Brand Affiliations as load
        List<Product_Metrics_vod__c> objBrandAffList = new List<Product_Metrics_vod__c>{};
        for(Integer i=0; i<50;i++){
            objBrandAffList.add(new Product_Metrics_vod__c(Account_vod__c = objAccountList[i].Id, Products_vod__c = productId));
        }
        
        try {
            //Now insert data causing Brand Affiliation trigger to fire 
            insert objBrandAffList;
        } 
        catch (DmlException e) {
          System.assert(false);
        } 
        finally {
            System.AssertEquals(50, database.countquery('SELECT count() FROM Product_Metrics_vod__c WHERE Products_vod__c = :productId'));                    
        }            
    }           
}