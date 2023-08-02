/************************************************************
*  @author: Lukasz Kozminski
*  Date: 2014-01-22
*  This is a test class for GNE_SFA2_View_Config_Trigger
*    
*  Modification History
*  Date        	Name       			Description
*  2014-08-27	Piotr Przesmycki	replaced dummyTest with actual test
*************************************************************/
@isTest
private class GNE_SFA2_View_Config_Trigger_Test {

    static testMethod void triggerTest() {
        SFA2_View_Config_gne__c view = new SFA2_View_Config_gne__c();
        view.Object_Type_gne__c = 'value1';
        view.Page_Name_gne__c = 'value2';
        view.View_Name_gne__c = 'value3';
        insert view;
        insert new SFA2_User_Preferences_gne__c(Last_View_Used_gne__c=view.Id);
        system.assertEquals(1, [SELECT Count() FROM SFA2_User_Preferences_gne__c]);
        /*Adding update just for coverage, since it doesn't contain any logic*/
        view.View_Name_gne__c = 'value4';
        update view;
        system.assertEquals(1, [SELECT Count() FROM SFA2_User_Preferences_gne__c]);
        delete view;
        system.assertEquals(0, [SELECT Count() FROM SFA2_User_Preferences_gne__c]);
    }
}