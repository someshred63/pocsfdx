/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-27
*  Description: This is a test class for GNE_SFA2_TLMap_Controller class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_TLMap_Controller_Test {
	
	public static testMethod void testForSFA2User() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		String sect ='testSect';
		String activeMenuItem = 'testAttr';
		String attr ='activeMenuItem='+activeMenuItem+';';

		insert new SFA2_Configuration_Object_gne__c(Attributes_gne__c=attr, Section_Header_gne__c=sect,
					Configuration_Type_gne__c = 'List Page', Is_Active_gne__c = true, Application_Type__c = 'SFA-US',
                    Object_Name_gne__c = 'TLMap');
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				
				GNE_SFA2_TLMap_Controller cont = new GNE_SFA2_TLMap_Controller();
				SFA2_Configuration_Object_gne__c pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('TLMap');
				system.assertEquals(cont.getListPageName(),sect);
				system.assertEquals(cont.getActiveMenuItem(),activeMenuItem);
				system.assertEquals(cont.envUrl, Utilities.getGlobalVariable('BO_Server_Name'));
			}
		}
	}

	public static testMethod void testForNotSFA2User() {
		GNE_SFA2_TLMap_Controller cont = new GNE_SFA2_TLMap_Controller();
		String sect ='testSect';
		String activeMenuItem = 'testAttr';
		String attr ='activeMenuItem='+activeMenuItem+';';

		insert new SFA2_Configuration_Object_gne__c(Attributes_gne__c=attr, Section_Header_gne__c=sect,
					Configuration_Type_gne__c = 'List Page', Is_Active_gne__c = true, Application_Type__c = 'SFA-US',
                    Object_Name_gne__c = 'TLMap');
		
		system.assertEquals(cont.getListPageName(),'');
		system.assertEquals(cont.getActiveMenuItem(),'');
		system.assertEquals(cont.envUrl, Utilities.getGlobalVariable('BO_Server_Name'));
	}

}