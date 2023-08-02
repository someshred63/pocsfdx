/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-07
*  Description: This is a test class for GNE_SFA2_Task_Ext class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_Task_Ext_Test {
	
	public static testMethod void testTaskExt() {
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO( 'test' );
		insert acc;
		Task testTask = GNE_SFA2_Triggers_Test_Util.prepareTask( acc.Id );
		insert testTask;
		Id taskId = testTask.Id;
		ApexPages.StandardController controller = new ApexPages.StandardController(testTask);
		GNE_SFA2_Task_Ext te = new GNE_SFA2_Task_Ext(controller);
		
		PageReference pr = te.editTask();
		system.assertEquals(pr.getUrl(), '/apex/GNE_SFA2_Task_Edit_Create_Layout?id='+taskId);
		system.assert(pr.getRedirect(),'this should be set to true');
		
		pr = te.createFollowUpTask();
		system.assertEquals(pr,null);

		pr = te.updateAccountTask();
		system.assertEquals(pr.getUrl(), '/apex/GNE_SFA2_MCCO_ART_AddAccount?id='+taskId);
		system.assert(pr.getRedirect(),'this should be set to true');

		pr = te.createFollowUpEvent();
		system.assertEquals(pr.getUrl(), '/apex/SFDCToGCalRedirectProgressPage');
		system.assert(pr.getRedirect(),'this should be set to true');
		
		pr = te.deleteTask();
		system.assertEquals(pr.getUrl(), '/apex/GNE_SFA2_MyTasks');
		system.assert(pr.getRedirect(),'this should be set to true');
		system.assertEquals([SELECT Id FROM Task WHERE Id=:taskId].size(),0);
	}
	
}