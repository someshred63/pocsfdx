/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-13
*  This is a test for GNE_SFA2_SC_Line_Item_Edit_Create_Ctrl class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest

private class GNE_SFA2_SC_Line_Item_Edit_Create_Test {

    static testMethod void testCtrl() {
		String objectId = '01I70000000BHtJ';
		ApexPages.currentPage().getParameters().put( 'objectId', objectId);
    	Speaker_Contract_Line_Item_gne__c scli = new Speaker_Contract_Line_Item_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(scli);
		
		Test.startTest();
			GNE_SFA2_SC_Line_Item_Edit_Create_Ctrl testCtrl = new GNE_SFA2_SC_Line_Item_Edit_Create_Ctrl(stdCtrl);
		Test.stopTest();
		system.assertEquals(testCtrl.myObject.get('Speaker_Contract_gne__c'), objectId);
		
    }
}