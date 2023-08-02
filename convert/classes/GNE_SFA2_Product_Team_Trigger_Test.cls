/************************************************************
*  @author:unknown
*  Date: unknown
*  Description: This is a test class for GNE_SFA2_Spkr_Bur_Membership_Trigger trigger
*  
*  Modification History
*  Date         Name                	Description
*  2014-02-04   Piotr Przesmycki    	Fixed and improved unit test, removed SeeAllData annotation, added header to class
*  2014-02-21   Piotr Przesmycki    	Using GNE_SFA2_Trigger_Test_Util to prepare data
*  2015-07-09   Przemyslaw Giszczak 	Add status to Speaker_Bureau_Membership_gne__c against DmlException
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Product_Team_Trigger_Test {
    
    public static testMethod void testInsert_negative(){ 
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            //negative testing 
            Test.startTest();
            System.runAs(sfa2User){
                try{
                    Speaker_Bureau_Product_gne__c spkrBP = new Speaker_Bureau_Product_gne__c();
                    insert spkrBP;
                    system.assert(false,'It should fail');
                }catch(Exception e){
                    System.assert(true,'This is expected as mandatory fields are missing' );
                }
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testInsert_positive(){ 
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            //positive testing 
            Test.startTest();
            System.runAs(sfa2User){
                try{
                    product_vod__c prV = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
                    insert prV;

                    Speaker_Bureau_gne__c spkrB = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
                    insert spkrB;

                    Speaker_Bureau_Product_gne__c spkrBP = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(prV.Id, spkrB.Id);
                    insert spkrBP;

                    system.assert(true,'It should work');
                }catch(Exception e){
                    System.assert(false,e.getMessage());
                }
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpdate(){
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            System.runAs(sfa2User){
            Test.startTest();
            product_vod__c prV = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
            insert prV;
            Speaker_Bureau_gne__c spkrB = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
            insert spkrB;
                try{
                    Speaker_Bureau_Product_gne__c spkrBP = new Speaker_Bureau_Product_gne__c(Product_vod_gne__c=prV.Id,Speaker_Bureau_gne__c=spkrB.Id);
                    insert spkrBP;
                    update spkrBP;
                    system.assert(true, 'both update and insert should work');
                } catch(Exception e){
                    System.assert(false,e.getMessage());
                }
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testUpsertBrandAffliations(){
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            Test.startTest();
            System.runAs(sfa2User){
                Speaker_Bureau_gne__c spkrB = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
                insert spkrB;

                product_vod__c prV = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
                insert prV;

                Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
                insert acc;

                Speaker_Bureau_Membership_gne__c spkrBM = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(spkrB.Id, acc.Id, 'Approved');
                insert spkrBM;

                Speaker_Contract_gne__c spC = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Contract_gne(acc.Id, Date.today());
                insert spC;

                Product_Metrics_vod__c pmV = GNE_SFA2_Triggers_Test_Util.prepareProduct_Metrics_vod(acc.Id);
                pmV.Products_vod__c=prV.Id;
                insert pmV;
                try{
                    Speaker_Bureau_Product_gne__c spkrBP = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(prV.Id, spkrB.Id);
                    insert spkrBP;
                    update spkrBP;
                    system.assert(true,'It should work');
                } catch(Exception e){
                    System.assert(false,e.getMessage());
                }
            }
            Test.stopTest();
        }
    }

}