/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2013-12-13
*  Description: This is a test class for GNE_SFA2_UI_Setting_Trigger trigger.
*  
*  Modification History
*  Date         Name                Description
*  2014-02-13   Piotr Przesmycki    Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data          
*************************************************************/
@isTest
public with sharing class GNE_SFA2_UI_Setting_Trigger_Test {

    public static testMethod void testExternalIdFieldUpdate() {
        GNE_SFA2_Util.switchAdminMode(false);
        //GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
        GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_UI_Setting_Trigger__c', false);
        SFA2_UI_Setting_gne__c uiSetting = GNE_SFA2_Triggers_Test_Util.prepareSFA2_UI_Setting_gne();
        uiSetting.Application_gne__c='SFA-US';
        uiSetting.Type_gne__c='Footer';
        insert uiSetting;
        uiSetting = [SELECT Id, Type_gne__c, External_ID_gne__c FROM SFA2_UI_Setting_gne__c WHERE Id=:uiSetting.Id];
        system.assertEquals(uiSetting.External_ID_gne__c,'SFA-US_null_null_Footer_null_null');
        uiSetting.Type_gne__c='Sidebar';
        update uiSetting;
        uiSetting = [SELECT Id, Type_gne__c, External_ID_gne__c FROM SFA2_UI_Setting_gne__c WHERE Id=:uiSetting.Id];
        system.assertEquals(uiSetting.External_ID_gne__c,'SFA-US_null_null_Sidebar_null_null');
    }
}