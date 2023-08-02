/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2013-11-07
*  Description: This is a helper class for handling My_Setup_Products_vod__c External Id field fill
*  Test class: GNE_My_Setup_Products_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*************************************************************/
public without sharing class GNE_My_Setup_Products_External_Id_Fill {
    
    private static void setExternalIdValueInsert(List<My_Setup_Products_vod__c> triggerNew){
        for(My_Setup_Products_vod__c mySetup : triggerNew){
                mySetup.External_ID_gne__c = mySetup.Product_vod__c + '_' +  mySetup.OwnerId;
        }
    }
    
    private static void setExternalIdValueUpdate(List<My_Setup_Products_vod__c> triggerOld, List<My_Setup_Products_vod__c> triggerNew){
        for(My_Setup_Products_vod__c mySetup : triggerNew){
            mySetup.External_ID_gne__c = mySetup.Product_vod__c + '_' + mySetup.OwnerId;
        }
    }
    
    public static void onBeforeInsert(List<My_Setup_Products_vod__c> triggerNew) {
        setExternalIdValueInsert(triggerNew);
    }
    
    public static void onBeforeUpdate(List<My_Setup_Products_vod__c> triggerOld, List<My_Setup_Products_vod__c> triggerNew) {
        setExternalIdValueUpdate(triggerOld, triggerNew);
    }
}