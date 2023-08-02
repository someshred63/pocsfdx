/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-14
*  Description: This is a test class for GNE_SFA2_ToT_Day_Edit_Create_Ext class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_ToT_Day_EditCreateExt_Test {
	
	public static testMethod void testToT_Day_Edit_Create_Ext() {
		PageReference pageRef = Page.GNE_SFA2_ToT_Day_Edit_Create_Layout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('objectId', '001test');
		Time_off_Territory_Day_gne__c testToTDay = new Time_off_Territory_Day_gne__c();
		GNE_SFA2_ToT_Day_Edit_Create_Ext ext = new GNE_SFA2_ToT_Day_Edit_Create_Ext(new ApexPages.StandardController(testToTDay));
		system.assertEquals(ext.myObject.Id,null);
		system.assertEquals(ext.myObject.get('Time_Off_Territory_gne__c'),'001test');
	}
	
}