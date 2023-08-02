/************************************************************
*  @author: Rakesh Boinepalli 
*  Date: 2012-12-16
*  Description: This is a test class for GGNE_SFA2_Event_Curriculum_Trigger trigger
*  
*  Modification History
*  Date        	Name        		Description
*  2014-02-05	Piotr Przesmycki    Improved unit test      
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Event_Curriculum_Trigger_Test {
	
	public static testMethod void testEventCurriculumFieldUpdates() { 
		Id adminId = UserInfo.getUserId();
		Date d_x = date.today()-1;
		Event_Curriculum_gne__c event = new Event_Curriculum_gne__c(Deactivation_Date_gne__c = d_x);
 		try{
 	 		insert event;
 	 	}catch(Exception ex){
 	 		system.assert(false,'insert should have succeeded'+ex.getMessage());
 	 	}
	 	event = [SELECT Id, Deactivation_Date_gne__c, OwnerId FROM Event_Curriculum_gne__c WHERE Id= :event.Id LIMIT 1];
		system.assertNotEquals(event.OwnerId, adminId);
	 	event.Deactivation_Date_gne__c=Date.today()+1;
	 	event.OwnerId=adminId;
	 	try{
	 	 	update event;
	 	}catch(Exception ex){
	 	 	system.assert(false,'update should have succeeded'+ex.getMessage());
	 	}
 	 	event = [SELECT Id, Deactivation_Date_gne__c, OwnerId FROM Event_Curriculum_gne__c WHERE Id= :event.Id LIMIT 1];
 	 	system.assertEquals(event.OwnerId, adminId);
	 	event.Deactivation_Date_gne__c=d_x;
 	 	try{
 	 		update event;
 	 	}catch(Exception ex){
 	 		system.assert(false,'update should have succeeded'+ex.getMessage());
 	 	}
		event = [SELECT Id, Deactivation_Date_gne__c, OwnerId FROM Event_Curriculum_gne__c WHERE Id= :event.Id LIMIT 1];
	 	system.assertNotEquals(event.OwnerId, adminId);
	}
}