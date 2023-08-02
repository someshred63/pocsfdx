/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2013-11-07
*  Description: This is a test class for My_Setup_Products_Trigger trigger and GNE_My_Setup_Products_External_Id_Fill helper class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
public without sharing class GNE_My_Setup_Products_Trigger_Test {
    
    private static Product_vod__c createTestProduct(String prodName){
        Product_vod__c prod = new Product_vod__c(Name=prodName);
        insert prod;
        return prod;
    }
    
    private static My_Setup_Products_vod__c createTestSetup(Id userId, Id productId){
        My_Setup_Products_vod__c  setProd = new My_Setup_Products_vod__c(OwnerId=userId, Product_vod__c=productId);
        insert setProd;
        return setProd; 
    }
    
    public static testMethod void testCreatingAndUpdatingSetupProducts() {
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        Product_vod__c prod1 = createTestProduct('TestProd1');
        Product_vod__c prod2 = createTestProduct('TestProd2');
        try{
            createTestSetup(sfa2User.Id,prod1.Id);
            createTestSetup(sfa2User.Id,prod2.Id);
        } catch(Exception ex){
            system.assert(false,'It should never reach this line');
        }
        List<My_Setup_Products_vod__c> setupProducts = [SELECT Id, External_ID_gne__c, OwnerId, Product_vod__c FROM My_Setup_Products_vod__c WHERE Product_vod__c IN (:prod1.Id, :prod2.Id) AND OwnerId = :sfa2User.Id ];
        system.assertEquals(setupProducts.size(),2);
        system.assertEquals(setupProducts.get(0).External_ID_gne__c,(String)setupProducts.get(0).Product_vod__c+'_'+(String)setupProducts.get(0).OwnerId);
        system.assertEquals(setupProducts.get(1).External_ID_gne__c,(String)setupProducts.get(1).Product_vod__c+'_'+(String)setupProducts.get(1).OwnerId);

        try{
            createTestSetup(sfa2User.Id,prod1.Id);
        } catch(Exception ex){
            system.assert(true, 'it should fail due to External ID uniqueness');
        }
        
        setupProducts.get(0).Product_vod__c=setupProducts.get(1).Product_vod__c;
        try{
            update setupProducts.get(0);
        } catch(Exception ex){
            system.assert(true, 'it should fail due to External ID uniqueness');
        }
        Product_vod__c prod3 = createTestProduct('TestProd3');
        setupProducts.get(1).Product_vod__c=prod3.Id;
        try{
            update setupProducts;
            system.assert(true, 'Now no External_Id is duplicated, so it should update normally');
        } catch (Exception ex){
            system.assert(false,'It should never reach this line');
        }
    }
}