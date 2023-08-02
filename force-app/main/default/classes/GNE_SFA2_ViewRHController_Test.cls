/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-28
*  Description: This is a test class for GNE_SFA2_ViewRHController class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_ViewRHController_Test {
	
	public static testMethod void test_ViewRHController() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				Account testAcc = new Account(Name = 'testAcc');
				insert testAcc;
				PageReference pr = Page.GNE_SFA2_Account_Layout;
				pr.getParameters().put('id',testAcc.Id);
				Test.setCurrentPage(pr);
				GNE_SFA2_ViewRHController vrhController = new GNE_SFA2_ViewRHController();
				system.assertEquals(0,vrhController.physycianCount);
				
			}
		}
	}	
}