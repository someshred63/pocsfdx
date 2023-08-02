/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-07-28
*  This is a test class for GNE_SFA2_AAChartsController
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_AAChartsController_Test {
	
	public static testMethod void testControllerMethods() {
		String testString = 'test';
		String hostName = System.URL.getSalesforceBaseUrl().toExternalForm();
		insert new SFA2_Configuration_Object_gne__c(Attributes_gne__c = 'activeMenuItem='+testString+';', Configuration_Type_gne__c = 'List Page', Is_Active_gne__c = true, Object_Name_gne__c = 'AACharts');
		
		GNE_SFA2_AAChartsController controller = new GNE_SFA2_AAChartsController();
		system.assert(!controller.isIframe);
		system.assertEquals(hostName, controller.hostName);
		system.assertEquals(null, controller.url);
		system.assertEquals(null, controller.aACharts());
		system.assert(controller.isIframe);
		system.assertEquals(null, controller.checkNewWindow());
		PageReference pr = Page.GNE_SFA2_AACharts;
		pr.getParameters().put('new_window','true');
		Test.setCurrentPage(pr);
		pr = controller.checkNewWindow();
		system.assert(!pr.getRedirect());
		system.assert(pr.getUrl().contains('https://null/iMap/AdvAssess1.jsp?serverName='));
        system.assertEquals(testString, controller.getActiveMenuItem());
	}
	
}