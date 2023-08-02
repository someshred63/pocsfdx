/************************************************************
*  @author: Sebastian Pigulak
*  Date: 2017-01-16
*  This is a test class for GNE_SFA2_Med_Comm_Ext
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Med_Comm_Ext_Test {
	
	@isTest static void shouldEditMedComm() {
		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );
		
		GNE_SFA2_Med_Comm_Ext testExt = new GNE_SFA2_Med_Comm_Ext(stdCtrl);
		PageReference testPageRef = testExt.edit();
		System.assertNotEquals(null, testPageRef);
	}
	
	@isTest static void shouldDeleteMedComm() {
		Account testAcc = new Account();
		testAcc.Name = 'Test Acc';
		insert testAcc;

		Medical_Communication_gne__c mc = new Medical_Communication_gne__c();
		mc.Account_gne__c = testAcc.Id;
		insert mc;

		ApexPages.StandardController stdCtrl = new ApexPages.StandardController( mc );
		
		GNE_SFA2_Med_Comm_Ext testExt = new GNE_SFA2_Med_Comm_Ext(stdCtrl);
		PageReference testPageRef = testExt.deleteClick();
		System.assertNotEquals(null, testPageRef);
	}
	
}