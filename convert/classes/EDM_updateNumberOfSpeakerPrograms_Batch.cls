global class EDM_updateNumberOfSpeakerPrograms_Batch implements Database.Batchable<sObject> {
	
	String query;
	private Boolean adminModeEnabled;
	
	global EDM_updateNumberOfSpeakerPrograms_Batch() {
		query = 'SELECT Id from Speaker_Bureau_gne__c';

		adminModeEnabled = isAdminModeEnabled();
		if (adminModeEnabled == false){
			switchAdminMode(true);
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Set<Id> speakerBureauIds = new Set<Id>();
		for (Speaker_Bureau_gne__c speakerBureau : (List<Speaker_Bureau_gne__c>)scope) {
			speakerBureauIds.add(speakerBureau.Id);
		}
		
		List<Event_Bureaus_gne__c> eventBureaus = [
				SELECT Id, Medical_Event_gne__r.Status_gne__c, Speaker_Bureau_gne__c, Medical_Event_gne__c
				FROM Event_Bureaus_gne__c
				WHERE Medical_Event_gne__r.Event_Type_gne__c = 'Speaker Program' and 
					Medical_Event_gne__r.Status_gne__c in ('Occurred', 'Pending', 'Confirmed', 'Closed') and
					Speaker_Bureau_gne__c in :speakerBureauIds];

		System.debug('eventBureaus : ' + eventBureaus.size());

		Map<Id, Set<Id>> medicalEventsBySpeakerBureauId = new Map<Id, Set<Id>>();
		Set<Id> medicalEventIds = new Set<Id>();

		for (Event_Bureaus_gne__c eventBureau : eventBureaus) {
			Set<Id> tmpSet = medicalEventsBySpeakerBureauId.get(eventBureau.Speaker_Bureau_gne__c);
			if (tmpSet == null) {
				medicalEventsBySpeakerBureauId.put(eventBureau.Speaker_Bureau_gne__c, new Set<Id> {eventBureau.Medical_Event_gne__c});
			} else {
				tmpSet.add(eventBureau.Medical_Event_gne__c);
			}

			medicalEventIds.add(eventBureau.Medical_Event_gne__c);
		}

		List<Speaker_Bureau_Membership_gne__c> sbMemberships = [
				SELECT Id, Bureau_Member_gne__c, Speaker_Bureau_ID_gne__c
				FROM Speaker_Bureau_Membership_gne__c
				WHERE Speaker_Bureau_ID_gne__c in :speakerBureauIds];

		List<Event_Attendee_vod__c> attendees = [
				SELECT Id, Account_vod__c, Medical_Event_vod__r.Status_gne__c, Medical_Event_vod__c, Status_vod__c
				FROM Event_Attendee_vod__c 
				WHERE Medical_Event_vod__c in :medicalEventIds and
					Role_gne__c = 'Speaker'];

		Map<String, Integer> eventAttendeesByAccountIdMedicalEventIdAndStatus = new Map<String, Integer>();
		Map<Id, Set<Id>> eventAttendeesByMedicalEventId = new Map<Id, Set<Id>>();
		Map<Id, String> eventAttendeesByStatus = new Map<Id, String>();
		for (Event_Attendee_vod__c attendee : attendees) {
			String key = attendee.Account_vod__c + '#' + attendee.Medical_Event_vod__c + '#' + getSimpleStatus(attendee.Medical_Event_vod__r.Status_gne__c);
			Integer value = eventAttendeesByAccountIdMedicalEventIdAndStatus.get(key);
			value = value == null ? 1 : value + 1;
			eventAttendeesByAccountIdMedicalEventIdAndStatus.put(key, value);

			if (eventAttendeesByMedicalEventId.get(attendee.Account_vod__c) == null) {
				eventAttendeesByMedicalEventId.put(attendee.Account_vod__c, new Set<Id> {attendee.Medical_Event_vod__c});
				eventAttendeesByStatus.put(attendee.Account_vod__c, attendee.Status_vod__c);
			} else {
				eventAttendeesByMedicalEventId.get(attendee.Account_vod__c).add(attendee.Medical_Event_vod__c);
			}
		}

		for (Speaker_Bureau_Membership_gne__c sbMembership : sbMemberships) {

			Integer upcoming = 0;
			Integer completed = 0;
			Set<Id> medicalEventsForSpeakerBureau = medicalEventsBySpeakerBureauId.get(sbMembership.Speaker_Bureau_ID_gne__c);
			Set<Id> medicalEventsForAttendee = eventAttendeesByMedicalEventId.get(sbMembership.Bureau_Member_gne__c);

			if (medicalEventsForAttendee != null && medicalEventsForSpeakerBureau != null) {
				String attendeeStatus = eventAttendeesByStatus.get(sbMembership.Bureau_Member_gne__c);
				for (Id medicalEventId : medicalEventsForAttendee) {
					if (medicalEventsForSpeakerBureau.contains(medicalEventId)) {
						String startKey = sbMembership.Bureau_Member_gne__c + '#' + medicalEventId + '#';
						Integer value = eventAttendeesByAccountIdMedicalEventIdAndStatus.get(startKey + 'Upcoming');
						if (value != null && attendeeStatus == 'Accepted') {
							upcoming += value;
						}

						value = eventAttendeesByAccountIdMedicalEventIdAndStatus.get(startKey + 'Completed');
						if (value != null && attendeeStatus == 'Attended') {
							completed += value;
						}
					}
				}
				
			}
			sbMembership.Upcoming_Programs_gne__c = upcoming;
			sbMembership.Completed_Programs_gne__c = completed;
		}


		update sbMemberships;
	}
	
	global void finish(Database.BatchableContext BC) {
		if (adminModeEnabled == false){
			switchAdminMode(false);
		}
	}

	private String getSimpleStatus(String status_gne) {
		if (status_gne == 'Confirmed' || status_gne == 'Pending') {
			return 'Upcoming';
		} else if (status_gne == 'Occurred' || status_gne == 'Closed') {
			return 'Completed';
		}
		return '';
	}

	private Boolean isAdminModeEnabled(){
		List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId = :UserInfo.getUserId() LIMIT 1];
		return !adminModeSetting.isEmpty() && adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c;
	}

	private void switchAdminMode(Boolean isAdminMode) {
		Id currentUserId = UserInfo.getUserId();
		List<GNE_SFA2_Admin_Mode__c> adminModeSetting = [SELECT Id, SetupOwnerId, GNE_SFA2_Is_Admin_Mode__c FROM GNE_SFA2_Admin_Mode__c WHERE SetupOwnerId = :currentUserId LIMIT 1];		
		if (adminModeSetting.isEmpty()) {			
			insert new GNE_SFA2_Admin_Mode__c(SetupOwnerId = currentUserId, GNE_SFA2_Is_Admin_Mode__c = isAdminMode);
		} else {			
			adminModeSetting.get(0).GNE_SFA2_Is_Admin_Mode__c = isAdminMode;
			update adminModeSetting;
		}
	}
}