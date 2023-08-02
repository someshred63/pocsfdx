/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-07-29
*  This is a test class for GNE_SFA2_Acc_Ext_Id_Ext and GNE_SFA2_Acc_Ext_Id_Edit_Create_Ext
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Acc_Ext_Id_Test {
	
	public static testMethod void test_GNE_SFA2_Acc_Ext_Id_Ext() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_External_Id_gne__c aei = new Account_External_Id_gne__c(Account_gne__c = acc.Id);
		insert aei;
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(aei);

		GNE_SFA2_Acc_Ext_Id_Ext testCtrl = new GNE_SFA2_Acc_Ext_Id_Ext(stdctrl);

		system.assertEquals(aei, testCtrl.myObject);
		PageReference pr = testCtrl.edit();
        system.assert(pr.getUrl().contains('GNE_SFA2_Acc_Ext_Id_Edit_Create_Layout'));
        system.assertEquals(aei.Id, pr.getParameters().get('id'));
        system.assertEquals(true, pr.getredirect());
	}
	
	public static testMethod void test_GNE_SFA2_Acc_Ext_Id_Edit_Create_Ext() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_External_Id_gne__c aei = new Account_External_Id_gne__c(Account_gne__c = acc.Id);
		//insert aei;
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(aei);

		PageReference pr = Page.GNE_SFA2_Acc_Ext_Id_Edit_Create_Layout;
		pr.getParameters().put('objectId', acc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_Acc_Ext_Id_Edit_Create_Ext testCtrl = new GNE_SFA2_Acc_Ext_Id_Edit_Create_Ext(stdctrl);

		system.assertEquals(acc.Id, testCtrl.myObject.get('Account_gne__c'));
	}
	
}