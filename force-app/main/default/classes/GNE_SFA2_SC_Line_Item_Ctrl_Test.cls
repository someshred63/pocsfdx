/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-13
*  This is a test for GNE_SFA2_SC_Line_Item_Ctrl class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest

private class GNE_SFA2_SC_Line_Item_Ctrl_Test {

    static testMethod void testCtrl() {
    	Speaker_Contract_Line_Item_gne__c scli = new Speaker_Contract_Line_Item_gne__c();
    	insert scli;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(scli);
		
		Test.startTest();
			GNE_SFA2_SC_Line_Item_Ctrl testCtrl = new GNE_SFA2_SC_Line_Item_Ctrl(stdCtrl);
			PageReference result = testCtrl.edit();
		Test.stopTest();
		system.assertEquals(scli.Id, result.getParameters().get('id'));
		system.assertEquals(true, result.getRedirect());
		system.assertEquals(result.getUrl(), '/apex/GNE_SFA2_SC_Line_Item_Edit_Create_Layout?id='+scli.Id);
    }
}