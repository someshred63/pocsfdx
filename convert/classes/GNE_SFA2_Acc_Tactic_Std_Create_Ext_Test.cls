/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-07-29
*  This is a test class for GNE_SFA2_Acc_Tactic_Std_Create_Ext
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Acc_Tactic_Std_Create_Ext_Test {
	
	public static testMethod void testConstructor() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_Tactic_vod__c ats = GNE_SFA2_Triggers_Test_Util.prepareAccount_Tactic_vod(acc.Id);
		ApexPages.StandardController stdctrl = new ApexPages.StandardController(ats);

		PageReference pr = Page.GNE_SFA2_Account_Tactic_Layout;
		pr.getParameters().put('objectId', acc.Id);
		Test.setCurrentPage(pr);
		GNE_SFA2_Acc_Tactic_Std_Create_Ext testCtrl = new GNE_SFA2_Acc_Tactic_Std_Create_Ext(stdctrl);

		system.assertEquals(ats, testCtrl.myObject);
	}	
}