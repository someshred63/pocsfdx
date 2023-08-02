/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-11-05
*  Description: This is a test for GNE_SFA2_Events_OnSpeakerBureau_Ext class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest
private class GNE_SFA2_Events_OnSpeakerBureau_Ext_Test {
	
	public static testMethod void testGetters() {
		Speaker_Bureau_gne__c speakerBureau = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
		insert speakerBureau;
		Medical_Event_vod__c me = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today()+1);
		insert me;
		List<Medical_Event_vod__c> meChilds = new List<Medical_Event_vod__c>();
		Medical_Event_vod__c meChild = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today()+1);
		meChild.parent_medical_event_gne__c = me.Id;
		meChild.City_Name_gne__c = 'San Francisco';
		meChild.State_Province_Code_gne__c = '12345';
		meChild.Speakers_Name_gne__c = 'test';
		meChilds.add(meChild);
		meChild = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today()+1);
		meChild.parent_medical_event_gne__c = me.Id;
		meChild.City_Name_gne__c = 'Atlanta';
		meChild.State_Province_Code_gne__c = '54321';
		meChild.Speakers_Name_gne__c = 'Larry';
		meChilds.add(meChild);
		insert meChilds;
		List<Event_Bureaus_gne__c> events = new List<Event_Bureaus_gne__c>();
		for(Integer i = 0; i<5; i++){
			events.add(new Event_Bureaus_gne__c(Speaker_Bureau_gne__c = speakerBureau.Id, Medical_Event_gne__c = me.Id));
		}
		insert events;
		Event_Attendee_vod__c attendee = GNE_SFA2_Triggers_Test_Util.prepareEvent_Attendee_vod(null, UserInfo.getUserId(), null, me.Id);
		insert attendee;
		GNE_SFA2_Events_OnSpeakerBureau_Ext ext = new GNE_SFA2_Events_OnSpeakerBureau_Ext(new ApexPages.StandardController(speakerBureau));
		system.assertEquals(1, ext.totalPages);
		system.assertEquals(false, ext.hasNext);
		system.assertEquals(false, ext.hasPrevious);
		system.assertEquals(null, ext.next());
		system.assertEquals(2, ext.currentPage);
		system.assertEquals(null, ext.previous());
		system.assertEquals(1, ext.currentPage);
		ext.currentPage = 30;
		system.assertEquals(null, ext.first());
		system.assertEquals(1, ext.currentPage);
		system.assertEquals(null, ext.last());
		system.assertEquals(1, ext.currentPage);
		system.assertEquals(null, ext.changePage());
		system.assertEquals(1, ext.currentPage);
		Test.setCurrentPage(Page.Events_RelatedList_OnSpeakerBureau);
		PageReference pr = ext.getShowAll();
		system.assert(pr.getUrl().contains('Events_RelatedList_OnSpeakerBureau'));
		system.assertEquals(speakerBureau.Id, pr.getParameters().get('id'));
		system.assertEquals('true', pr.getParameters().get('all'));
		system.assertEquals(true, pr.getRedirect());
		pr = ext.getBackToSpeakerBureau();
		system.assert(pr.getUrl().contains('/'+speakerBureau.Id));
		system.assertEquals(true, pr.getRedirect());

		system.assertEquals(5, ext.getRecords().size());

		system.assertEquals(true, ext.getEventBureau_IsCreateable());
		system.assertEquals(true, ext.getEventBureau_IsUpdateable());
		system.assertEquals(true, ext.getEventBureau_IsDeletable());

		system.assertEquals(true, ext.getEventAttendee_IsCreateable());
		system.assertEquals(true, ext.getEventAttendee_IsUpdateable());
		system.assertEquals(true, ext.getEventAttendee_IsDeletable());
		ext.delId = attendee.Id;
		ext.DelEventAttd();
		system.assertEquals(0, [SELECT Count() FROM Event_Attendee_vod__c]);

		ext.delId = events[0].Id;
		ext.DelSpkrEvent();
		system.assertEquals(4, [SELECT Count() FROM Event_Bureaus_gne__c]);
	}
}