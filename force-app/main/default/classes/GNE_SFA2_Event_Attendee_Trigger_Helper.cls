/************************************************************
*  @author: Rakesh Boinepalli 
*  Date: 2012-12-13
*  Description: This is a helper class for GNE_SFA2_Event_Attendee_Trigger
*  Test class: 
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Event_Attendee_Trigger_Helper {
	
	public static Medical_Event_vod__c getMedicalEvent(){
		//this method is used inside test methods to get a sampple medical event. 
		 return [SELECT Id,Name,Event_Type_gne__c,Parent_Site_gne__c,Status_gne__c,Brands_gne__c,Indications_gne__c FROM Medical_Event_vod__c WHERE Event_Type_gne__c != null  LIMIT 1];
	}
	
	public static Speaker_Bureau_gne__c getSpeakerBureau(){
		return [SELECT id,Name FROM Speaker_Bureau_gne__c  LIMIT 1];
	}
	
	public static void populateSpeakersFields(List<Event_Attendee_vod__c> events){
		Set<Id> eventIds = new Set<Id>();
        Boolean isChange = false;
    	for(Event_Attendee_vod__c eventAttendee :events){
    		if(eventAttendee.Role_gne__c != null && eventAttendee.Role_gne__c.contains('Speaker')){
    			eventIds.add(eventAttendee.Medical_Event_vod__c);
    		}
    	}
    	if(eventIds.size()>0){
    		List<Medical_Event_vod__c> medialEvents = [SELECT me.ID, me.Source_System_ID_gne__c FROM Medical_Event_vod__c me WHERE me.id = :eventIds];
			for(Medical_Event_vod__c medialEvent : medialEvents ){
				em3_utils_2.populateSpeakersNameField(medialEvent.Source_System_ID_gne__c);
			}
    	}
	}


	public static void updateUpcomingAndCompletedNumberOfSpeakerProgramsOnSpeakerBureauMembership(Map<Id, Event_Attendee_vod__c> triggerOldMap, List<Event_Attendee_vod__c> triggerNewList) {
		Map<Id, Set<Id>> accountsByMedicalEvents = new Map<Id, Set<Id>>();
		Set<Id> accountsIds = new Set<Id>();

		System.debug('updateUpcomingAndCompletedNumberOfSpeakerProgramsOnSpeakerBureauMembership : ' + triggerNewList);

		for(Event_Attendee_vod__c eventAttendee : triggerNewList) {
			if (triggerOldMap == null) {
				if (isSpeaker(eventAttendee.Role_gne__c)) {
					addAccountsByMedicalEvents(accountsByMedicalEvents, eventAttendee);
					accountsIds.add(eventAttendee.Account_vod__c);
				}
			} else if (eventAttendee.Account_vod__c != triggerOldMap.get(eventAttendee.Id).Account_vod__c) {
				addAccountsByMedicalEvents(accountsByMedicalEvents, eventAttendee);
				accountsIds.add(eventAttendee.Account_vod__c);
				addAccountsByMedicalEvents(accountsByMedicalEvents, triggerOldMap.get(eventAttendee.Id));
				accountsIds.add(triggerOldMap.get(eventAttendee.Id).Account_vod__c);
			} else if (isSpeaker(eventAttendee.Role_gne__c) != isSpeaker(triggerOldMap.get(eventAttendee.Id).Role_gne__c)) {
				addAccountsByMedicalEvents(accountsByMedicalEvents, eventAttendee);
				accountsIds.add(eventAttendee.Account_vod__c);
			}
		}

		List<Speaker_Bureau_Membership_gne__c> sbMembershipsToRecalc = 
				retrieveSpeakerBureauMembershipsToRecalc(accountsByMedicalEvents, accountsIds);
		
		if (!sbMembershipsToRecalc.isEmpty()) {
			GNE_SFA2_Spkr_Bur_Mem_Field_Updates.updateUpcomingAndCompletedNumberOfSpeakerPrograms(null, sbMembershipsToRecalc);
			update sbMembershipsToRecalc;
		}
	}

	private static Boolean isSpeaker(String roles) {
		return roles != null && roles.contains('Speaker');
	}

	private static List<Speaker_Bureau_Membership_gne__c> retrieveSpeakerBureauMembershipsToRecalc(Map<Id, Set<Id>> accountsByMedicalEvents, Set<Id> accountsIds) {
		List<Speaker_Bureau_Membership_gne__c> sbMembershipsToRecalc = new List<Speaker_Bureau_Membership_gne__c>();
		System.debug('accountsByMedicalEvents : ' + accountsByMedicalEvents);

		if (accountsByMedicalEvents.isEmpty()) {
			return sbMembershipsToRecalc;
		}

		List<Event_Bureaus_gne__c> eventBureaus = [
				SELECT Id, Medical_Event_gne__r.Status_gne__c, Speaker_Bureau_gne__c, Medical_Event_gne__c
				FROM Event_Bureaus_gne__c
				WHERE Medical_Event_gne__c = :accountsByMedicalEvents.keySet() and
					Medical_Event_gne__r.Event_Type_gne__c = 'Speaker Program' and 
					Medical_Event_gne__r.Status_gne__c in ('Occurred', 'Pending', 'Confirmed', 'Closed')];

		System.debug('eventBureaus : ' + eventBureaus);

		Map<Id, Set<Id>> medicalEventsBySpeakerBureauId = new Map<Id, Set<Id>>();
		for (Event_Bureaus_gne__c eventBureau : eventBureaus) {
			if (medicalEventsBySpeakerBureauId.get(eventBureau.Speaker_Bureau_gne__c) == null) {
				medicalEventsBySpeakerBureauId.put(eventBureau.Speaker_Bureau_gne__c, new Set<Id> {eventBureau.Medical_Event_gne__c});
			} else {
				medicalEventsBySpeakerBureauId.get(eventBureau.Speaker_Bureau_gne__c).add(eventBureau.Medical_Event_gne__c);
			}
		}


		List<Speaker_Bureau_Membership_gne__c> sbMemberships = [
				SELECT Id, Bureau_Member_gne__c, Speaker_Bureau_ID_gne__c
				FROM Speaker_Bureau_Membership_gne__c WHERE 
				Speaker_Bureau_ID_gne__c in :medicalEventsBySpeakerBureauId.keySet() and Bureau_Member_gne__c in :accountsIds for update];

		System.debug('sbMemberships : ' + sbMemberships);

		for(Speaker_Bureau_Membership_gne__c sbMembership : sbMemberships) {
			for (Id medicalEventId : medicalEventsBySpeakerBureauId.get(sbMembership.Speaker_Bureau_ID_gne__c)) {
				if (accountsByMedicalEvents.get(medicalEventId) != null &&
					accountsByMedicalEvents.get(medicalEventId).contains(sbMembership.Bureau_Member_gne__c) != null) {
						sbMembershipsToRecalc.add(sbMembership);
						break;
				}
			}
			
		}
		System.debug('sbMembershipsToRecalc :' + sbMembershipsToRecalc);

		return sbMembershipsToRecalc;
	}

	private static void addAccountsByMedicalEvents(Map<Id, Set<Id>> accountsByMedicalEvents, Event_Attendee_vod__c eventAttendee){
		if (accountsByMedicalEvents.get(eventAttendee.Medical_Event_vod__c) == null) {
			accountsByMedicalEvents.put(eventAttendee.Medical_Event_vod__c, 
					new Set<Id> {eventAttendee.Account_vod__c});
		} else {
			accountsByMedicalEvents.get(eventAttendee.Medical_Event_vod__c).add(eventAttendee.Account_vod__c);
		}
	}
}