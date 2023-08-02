/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-10
*  Description: This is a test class for GNE_SFA2_Task_Edit_Create_Ext class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_Task_Edit_Create_Ext_Test {
	
	public static testMethod void testTask_Edit_Create_Ext() {
		PageReference pageRef = Page.GNE_SFA2_Task_Edit_Create_Layout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('objectId', '001test');
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO( 'test' );
		insert acc;
		Task testTask = GNE_SFA2_Triggers_Test_Util.prepareTask( acc.Id );
		insert testTask;
		GNE_SFA2_Task_Edit_Create_Ext ext = new GNE_SFA2_Task_Edit_Create_Ext(new ApexPages.StandardController(testTask));
		system.assertEquals(ext.myObject.Id,testTask.Id);
		system.assertEquals(ext.myObject.get('OwnerId'),UserInfo.getUserId());
		system.assertEquals(ext.myObject.get('WhatId'),'001test');
	}

	public static testMethod void testTask_WhoId(){
		PageReference pageRef = Page.GNE_SFA2_Task_Edit_Create_Layout;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('objectId', '003');
        Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO( 'test' );
		insert acc;
		Task testTask = GNE_SFA2_Triggers_Test_Util.prepareTask( acc.Id );
		insert testTask;
		GNE_SFA2_Task_Edit_Create_Ext ext = new GNE_SFA2_Task_Edit_Create_Ext(new ApexPages.StandardController(testTask));
        system.assertEquals(ext.myObject.get('WhoId'),'003');
	}

}