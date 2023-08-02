/**
*  @author: Przemek Giszczak
*  Date: 2014-08-05
*  This is a test class for GNE_SFA2_Account_Team_Ext and GNE_SFA2_Account_Team_Edit_Create_Ext
*    
*  Modification History
*  Date        Name        Description
 */
@isTest
private class GNE_SFA2_Account_Team_Test {

    public static testMethod void test_GNE_SFA2_Account_Team_Ext() {
        Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_Team_gne__c act = GNE_SFA2_Triggers_Test_Util.prepareAccount_Team_gne( acc.Id, UserInfo.getUserId() );
		insert act;
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(act);
		
		GNE_SFA2_Account_Team_Ext testCtrl = new GNE_SFA2_Account_Team_Ext(stdctrl);
		
		system.assertEquals(act, testCtrl.myObject);
		PageReference pr = testCtrl.edit();
        system.assert(pr.getUrl().contains('GNE_SFA2_Account_Team_Edit_Create_Layout'));
        system.assertEquals(act.Id, pr.getParameters().get('id'));
        system.assertEquals(true, pr.getredirect());
    }
    
    public static testMethod void test_GNE_SFA2_Account_Team_Edit_Create_Ext() {
    	Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_Team_gne__c act = GNE_SFA2_Triggers_Test_Util.prepareAccount_Team_gne( acc.Id, UserInfo.getUserId() );
		//insert aei;
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(act);

		PageReference pr = Page.GNE_SFA2_Account_Team_Edit_Create_Layout;
		pr.getParameters().put('objectId', acc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_Account_Team_Edit_Create_Ext testCtrl = new GNE_SFA2_Account_Team_Edit_Create_Ext(stdctrl);

		system.assertEquals(acc.Id, testCtrl.myObject.get('Account_gne__c'));
    }
    
}