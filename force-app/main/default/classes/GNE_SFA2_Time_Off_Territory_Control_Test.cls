/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-28
*  Description: This is a test class for GNE_SFA2_Time_Off_Territory_Controller class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_Time_Off_Territory_Control_Test {
	
	public static testMethod void test_Time_Off_Territory_Controller() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		String sect ='testSect';
		String activeMenuItem = 'testAttr';
		String attr ='activeMenuItem='+activeMenuItem+';';

		insert new SFA2_Configuration_Object_gne__c(Attributes_gne__c=attr, Section_Header_gne__c=sect,
					Configuration_Type_gne__c = 'List Page', Is_Active_gne__c = true, Application_Type__c = 'SFA-US',
                    Object_Name_gne__c = 'Time_Off_Territory_gne__c');
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				
				GNE_SFA2_Time_Off_Territory_Controller cont = new GNE_SFA2_Time_Off_Territory_Controller();
				PageReference newToT = Page.GNE_SFA2_TimeOffTerritory_Create_Layout;
       			newToT.getParameters().put('retURL', '/apex/GNE_SFA2_Time_Off_Territory'); 
        		system.assertEquals(newTot.getParameters(),cont.newClick().getParameters());
        		system.assertEquals(newTot.getParameters(),cont.newClick().getParameters());
			}
		}
	}

	public static testMethod void test_List_View_Base_Controller() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		String sect ='testSect';
		String activeMenuItem = 'testAttr';
		String attr ='activeMenuItem='+activeMenuItem+';';
		SFA2_Configuration_Object_gne__c conf = new SFA2_Configuration_Object_gne__c(Attributes_gne__c=attr, Section_Header_gne__c=sect,
					Configuration_Type_gne__c = 'List Page', Is_Active_gne__c = true, Application_Type__c = 'SFA-US',
                    Object_Name_gne__c = 'Time_Off_Territory_gne__c');
		insert conf;
		List<SFA2_Configuration_Object_Detail_gne__c> det = new List<SFA2_Configuration_Object_Detail_gne__c>();
		det.add(new SFA2_Configuration_Object_Detail_gne__c(API_Name_gne__c = 'button1', Label_gne__c = 'button1', Attributes_gne__c = '', Is_Required_gne__c = false,
                                                      		Is_Read_Only_gne__c = true, Order_gne__c = 1.0, Type_gne__c = 'Button', Style_gne__c=null,
                                                      		Configuration_Object_ref_gne__c=conf.Id, Is_Active_gne__c=true));
		insert det;

		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c=true, App_Name_gne__c='SFA-US');
				
				GNE_SFA2_Time_Off_Territory_Controller cont = new GNE_SFA2_Time_Off_Territory_Controller();
        		GNE_SFA2_List_View_Base_Controller baseController = cont.thisController;

        		system.assertNotEquals(baseController.getButtons(),null);
				system.assertEquals(baseController.getListPageName(),sect);
				system.assertEquals(baseController.getActiveMenuItem(),activeMenuItem);

				Set<Id> selectedRec = new Set<Id>{conf.Id,det[0].Id};
				baseController.setSelectedRecords(selectedRec);
				system.assertEquals(baseController.getSelectedRecords(),selectedRec);

				system.assertEquals('',baseController.getCustomFilterExpression(null));

			}
		}
	}
}