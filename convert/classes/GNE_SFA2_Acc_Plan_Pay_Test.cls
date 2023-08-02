/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-07-29
*  This is a test class for GNE_SFA2_Acc_Plan_Pay_Ext and GNE_SFA2_Acc_Plan_Pay_Edit_Create_Ext
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Acc_Plan_Pay_Test {
	
	public static testMethod void test_GNE_SFA2_Acc_Plan_Pay_Ext() {
		Account_Plan_Payer_gne__c app = new Account_Plan_Payer_gne__c();
		insert app;
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(app);

		GNE_SFA2_Acc_Plan_Pay_Ext testCtrl = new GNE_SFA2_Acc_Plan_Pay_Ext(stdctrl);

		system.assertEquals(app, testCtrl.myObject);
		PageReference pr = testCtrl.edit();
        system.assert(pr.getUrl().contains('GNE_SFA2_Acc_Plan_Pay_Edit_Create_Layout'));
        system.assertEquals(app.Id, pr.getParameters().get('id'));
        system.assertEquals(true, pr.getredirect());
	}
	
	public static testMethod void test_GNE_SFA2_Acc_Plan_Pay_Edit_Create_Ext() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_Plan_Payer_gne__c app = new Account_Plan_Payer_gne__c();
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(app);

		PageReference pr = Page.GNE_SFA2_Acc_Plan_Pay_Layout;
		pr.getParameters().put('objectId', acc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_Acc_Plan_Pay_Edit_Create_Ext testCtrl = new GNE_SFA2_Acc_Plan_Pay_Edit_Create_Ext(stdctrl);

		system.assertEquals(acc.Id, testCtrl.myObject.get('Account_Plan_gne__c'));
	}
	
}