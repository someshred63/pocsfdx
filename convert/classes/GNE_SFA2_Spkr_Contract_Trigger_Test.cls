/************************************************************
*  @author:Rakesh Boinepalli 
*  Date: 2012-01-05
*  Description: This is a test class for GNE_SFA2_Spkr_Contract_Trigger trigger
*  
*  Modification History
*  Date         Name                	Description
*  2014-02-04   Piotr Przesmycki    	Fixed and improved unit test, increased Api version from 20.0 to 28.0          
*  2014-02-17   Piotr Przesmycki    	Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*  2015-07-09   Przemyslaw Giszczak 	Add status to Speaker_Bureau_Membership_gne__c against DmlException
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Spkr_Contract_Trigger_Test {
    
    public static testmethod void testInsert() { 
        User SFA2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(SFA2User){
            Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
            insert acc;

            Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
            Product_vod__c prod2 = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
            List<Product_vod__c> pList = new List<Product_vod__c>();
            pList.add(prod);
            pList.add(prod2);
            insert pList;

            Product_Metrics_vod__c pm = GNE_SFA2_Triggers_Test_Util.prepareProduct_Metrics_vod(acc.Id);
            pm.Products_vod__c = prod.Id;
            insert pm;

            Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
            insert sb;

            Speaker_Bureau_Membership_gne__c sbm = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(sb.Id, acc.Id, 'Approved');
            insert sbm;
            
            Speaker_Bureau_Product_gne__c sbp = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(prod.Id, sb.Id);
            Speaker_Bureau_Product_gne__c sbp2 = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(prod2.Id, sb.Id);
            List<Speaker_Bureau_Product_gne__c> sbpList = new List<Speaker_Bureau_Product_gne__c>();
            sbpList.add(sbp);
            sbpList.add(sbp2);
            insert sbpList;

            Speaker_Contract_gne__c spC = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Contract_gne(acc.Id, Date.today());
            System.assertEquals(1,[SELECT ID FROM Product_Metrics_vod__c].size());
            Test.startTest();
            insert spC;
            Test.stopTest();
            System.assertEquals(2,[SELECT ID FROM Product_Metrics_vod__c].size());
        }
    }

    public static testmethod void testUpdate() { 
        User SFA2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(SFA2User){
            Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
            insert acc;

            Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
            insert prod;

            Product_Metrics_vod__c pm = GNE_SFA2_Triggers_Test_Util.prepareProduct_Metrics_vod(acc.Id);
            pm.Products_vod__c = prod.Id;
            insert pm;

            Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
            insert sb;

            Speaker_Bureau_Membership_gne__c sbm = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(sb.Id, acc.Id, 'Approved');
            insert sbm;

            Speaker_Bureau_Product_gne__c sbp = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(prod.Id, sb.Id);
            insert sbp;

            Speaker_Contract_gne__c spC = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Contract_gne(acc.Id, Date.today());
            insert spC;

            Product_vod__c prod2 = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
            insert prod2;

            Speaker_Bureau_Product_gne__c sbp2 = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Product_gne(prod2.Id, sb.Id);
            insert sbp2;
            System.assertEquals(1,[SELECT ID FROM Product_Metrics_vod__c].size());
            
            Test.startTest();
            update spC;
            Test.stopTest();
            System.assertEquals(2,[SELECT ID FROM Product_Metrics_vod__c].size());
        }
    }
}