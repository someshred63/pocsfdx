/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-01-08
*  Description: This is a test class for GNE_SFA2_ToT_Day_Ext class.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_ToT_Day_Ext_Test {
	
	public static testMethod void testToTDayExt() {
		Time_Off_Territory_gne__c tot = new Time_Off_Territory_gne__c();
		insert tot;
		Time_off_Territory_Day_gne__c testToTDay = GNE_SFA2_Triggers_Test_Util.prepareTime_off_Territory_Day_gne(tot.Id, Date.today());
		insert testToTDay;
		Id ToTDayId = testToTDay.Id;
		ApexPages.StandardController controller = new ApexPages.StandardController(testToTDay);
		GNE_SFA2_ToT_Day_Ext te = new GNE_SFA2_ToT_Day_Ext(controller);
		
		PageReference pr = te.edit();
		system.assertEquals(pr.getUrl(), '/apex/GNE_SFA2_ToT_Day_Edit_Create_Layout?id='+ToTDayId);
		system.assert(pr.getRedirect(),'this should be set to true');
		
		pr = te.deleteClick();
		system.assertEquals(pr.getUrl(), '/' + tot.Id);
		system.assert(pr.getRedirect(),'this should be set to true');
		system.assertEquals([SELECT Id FROM Time_off_Territory_Day_gne__c WHERE Id=:ToTDayId].size(),0);
	}
	
}