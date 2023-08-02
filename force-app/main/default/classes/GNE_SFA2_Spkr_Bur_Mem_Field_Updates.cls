public with sharing class GNE_SFA2_Spkr_Bur_Mem_Field_Updates {
	
	
	public static void onAfterInsert(List<Speaker_Bureau_Membership_gne__c> triggerNewList){
		
		updateContractStatusOnBrandAffiliation(triggerNewList);
		createMembershipHistory(triggerNewList);
		createClassificationHistory(triggerNewList);
		createMembershipTrainings(triggerNewList);
	}
	
	
	public static void onAfterUpdate(List<Speaker_Bureau_Membership_gne__c> triggerOldList,List<Speaker_Bureau_Membership_gne__c> triggerNewList){
		
		updateContractStatusOnBrandAffiliation(triggerNewList);
		createMembershipHistory(triggerOldList,triggerNewList);
		createClassificationHistory(triggerOldList,triggerNewList);
	}

	public static void onBeforeInsert(List<Speaker_Bureau_Membership_gne__c> triggerNewList){
		updateUpcomingAndCompletedNumberOfSpeakerPrograms(null, triggerNewList);
	}

	public static void onBeforeUpdate(Map<Id, Speaker_Bureau_Membership_gne__c> triggerOldMap, List<Speaker_Bureau_Membership_gne__c> triggerNewList) {
		updateUpcomingAndCompletedNumberOfSpeakerPrograms(triggerOldMap, triggerNewList);
	}

	public static void onBeforeDelete(List<Speaker_Bureau_Membership_gne__c> triggerOldList) {
		deleteMembershipTrainings(triggerOldList);
	}
	
	public static void updateContractStatusOnBrandAffiliation(List<Speaker_Bureau_Membership_gne__c> triggerList){
		
		if (System.isBatch() || System.isFuture()) {
			return; // Future method cannot be called from a future or batch method: UpsertBrandAffiliations.update_InsertSpContractBrandAff_beforeInsertUpdate(
		}

		List<String> accountIDList = new List<String>();
		Map<String,Date> accountID_Date_Map = new Map<String,Date>(); 
		Date endDate = null; 
		for (Integer i = 0 ;  i < triggerList.size(); i++)  { 
			accountIDList.add(triggerList[i].Bureau_Member_gne__c);
		}
		for(Speaker_Contract_gne__c objSpeakerContract : [Select Contracted_Party_ID__c, End_Date_gne__c from Speaker_Contract_gne__c where Contracted_Party_ID__c IN: accountIDList]){
			endDate = objSpeakerContract.End_Date_gne__c;
			endDate = date.newinstance(endDate.year(), endDate.month(), endDate.day());      
			accountID_Date_Map.put(objSpeakerContract.Contracted_Party_ID__c,endDate);  
		} 
		UpsertBrandAffiliations.update_InsertSpContractBrandAff_beforeInsertUpdate(accountID_Date_Map); 
	}

	public static void createMembershipHistory(List<Speaker_Bureau_Membership_gne__c> triggerNewList){
		List<EDM_SpeakerBureau_Membership_History_gne__c> history = new List<EDM_SpeakerBureau_Membership_History_gne__c>();
		for(Speaker_Bureau_Membership_gne__c sbm :triggerNewList){
			history.add(new EDM_SpeakerBureau_Membership_History_gne__c(
					EDM_Created_Date_gne__c = System.now(),
					EDM_Membership_Status_gne__c = sbm.Speaker_Status_gne__c,
					EDM_Speaker_Bureau_Membership_gne__c = sbm.Id,
					EDM_Updated_By_gne__c = UserInfo.getUserId()
				));
		}
		insert history;
	}

	public static void createMembershipHistory(List<Speaker_Bureau_Membership_gne__c> triggerOldList, List<Speaker_Bureau_Membership_gne__c> triggerNewList){
		List<EDM_SpeakerBureau_Membership_History_gne__c> history = new List<EDM_SpeakerBureau_Membership_History_gne__c>();
		for(Integer i = 0; i< triggerNewList.size(); i++){
			if(triggerNewList[i].Speaker_Status_gne__c != triggerOldList[i].Speaker_Status_gne__c){
				Speaker_Bureau_Membership_gne__c sbm = triggerNewList[i];
				history.add(new EDM_SpeakerBureau_Membership_History_gne__c(
					EDM_Created_Date_gne__c = System.now(),
					EDM_Membership_Status_gne__c = sbm.Speaker_Status_gne__c,
					EDM_Speaker_Bureau_Membership_gne__c = sbm.Id,
					EDM_Updated_By_gne__c = UserInfo.getUserId()
				));
			}
		}
		insert history;
	}

	public static void createClassificationHistory(List<Speaker_Bureau_Membership_gne__c> triggerNewList) {
		List<EDM_SBM_Classification_History_gne__c> history = new List<EDM_SBM_Classification_History_gne__c>();
		String type;
		Set<Id> memberIds = new Set<Id>();
		for (Speaker_Bureau_Membership_gne__c sbm : triggerNewList) {
			memberIds.add(sbm.Bureau_Member_gne__c);
			type = sbm.EDM_Bureau_Type_gne__c;
		}

		//get newest completed request of specified type for account
		Map<Id, EDM_Classification_Request_gne__c> requests = new Map<Id, EDM_Classification_Request_gne__c>();
		for (EDM_Classification_Request_gne__c request : [SELECT EDM_Account_gne__c, EDM_CV_Attachment_Link_gne__c,  EDM_Status_gne__c, EDM_Type_of_Classification_gne__c
 														   FROM EDM_Classification_Request_gne__c
 														   WHERE EDM_Account_gne__c IN :memberIds
 														   AND EDM_Status_gne__c = 'Completed'
 														   AND EDM_Type_of_Classification_gne__c = :type
 														   ORDER By LastModifiedDate]) {
			requests.put(request.EDM_Account_gne__c, request);
		}
		System.debug('##:REQUESTS:'+requests);
		for (Speaker_Bureau_Membership_gne__c sbm : triggerNewList){
			if(requests.get(sbm.Bureau_Member_gne__c) != null){
				history.add(new EDM_SBM_Classification_History_gne__c(
					EDM_Classification_Type_gne__c = type,
					EDM_Classification_Scope__c = sbm.Speaker_Scope_gne__c,
					EDM_Download_CV_gne__c = requests.get(sbm.Bureau_Member_gne__c).EDM_CV_Attachment_Link_gne__c,
					EDM_Speaker_Bureau_Membership_gne__c = sbm.Id
				));
			}
		}
		if(history.size()>0){
			insert history;
		}
	}

	public static void createClassificationHistory(List<Speaker_Bureau_Membership_gne__c> triggerOldList, List<Speaker_Bureau_Membership_gne__c> triggerNewList) {
		List<EDM_SBM_Classification_History_gne__c> history = new List<EDM_SBM_Classification_History_gne__c>();
		String type;
		Set<Id> memberIds = new Set<Id>();
		for (Speaker_Bureau_Membership_gne__c sbm : triggerNewList) {
			memberIds.add(sbm.Bureau_Member_gne__c);
			type = sbm.EDM_Bureau_Type_gne__c;
		}

		//get newest completed request of specified type for account
		Map<Id, EDM_Classification_Request_gne__c> requests = new Map<Id, EDM_Classification_Request_gne__c>();
		for (EDM_Classification_Request_gne__c request : [SELECT EDM_Account_gne__c, EDM_CV_Attachment_Link_gne__c,  EDM_Status_gne__c, EDM_Type_of_Classification_gne__c
 														   FROM EDM_Classification_Request_gne__c
 														   WHERE EDM_Account_gne__c IN :memberIds
 														   AND EDM_Status_gne__c = 'Completed'
 														   AND EDM_Type_of_Classification_gne__c = :type
 														   ORDER By LastModifiedDate]) {
			requests.put(request.EDM_Account_gne__c, request);
		}

		for(Integer i = 0; i < triggerNewList.size(); i++) {
			System.debug('$$ IF Condition values: type=' + type
							+ ' $Scope NEW=' + triggerNewList[i].Speaker_Scope_gne__c
							+ ' $Scope OLD=' + triggerOldList[i].Speaker_Scope_gne__c);

			if(triggerNewList[i].Speaker_Scope_gne__c != triggerOldList[i].Speaker_Scope_gne__c) {
				Speaker_Bureau_Membership_gne__c sbm = triggerNewList[i];
				if(requests.get(sbm.Bureau_Member_gne__c) != null){
					history.add(new EDM_SBM_Classification_History_gne__c(
						EDM_Classification_Type_gne__c = type,
						EDM_Classification_Scope__c = sbm.Speaker_Scope_gne__c,
						EDM_Download_CV_gne__c = requests.get(sbm.Bureau_Member_gne__c).EDM_CV_Attachment_Link_gne__c,
						EDM_Speaker_Bureau_Membership_gne__c = sbm.Id
					));
				}
			}
		}
		if(history.size()>0){
			insert history;
		}
	}

	public static void updateUpcomingAndCompletedNumberOfSpeakerPrograms (Map<Id, Speaker_Bureau_Membership_gne__c> triggerOldMap, List<Speaker_Bureau_Membership_gne__c> triggerNewList) {

		List<Speaker_Bureau_Membership_gne__c> memershipsToRecalc = new List<Speaker_Bureau_Membership_gne__c>();
		Set<Id> speakerBureauIdsToRecalc = new Set<Id>();
		Set<Id> accountIdsToRecalc = new Set<Id>();
		for(Speaker_Bureau_Membership_gne__c newMemership : triggerNewList) {
			if (triggerOldMap == null) {
				memershipsToRecalc.add(newMemership);
				speakerBureauIdsToRecalc.add(newMemership.Speaker_Bureau_ID_gne__c);
				accountIdsToRecalc.add(newMemership.Bureau_Member_gne__c);
			} else if (newMemership.Bureau_Member_gne__c != triggerOldMap.get(newMemership.Id).Bureau_Member_gne__c) {
				memershipsToRecalc.add(newMemership);
				speakerBureauIdsToRecalc.add(newMemership.Speaker_Bureau_ID_gne__c);
				accountIdsToRecalc.add(newMemership.Bureau_Member_gne__c);
			}
		}

		Map<Id, Set<Id>> medicalEventsBySpeakerBureauId = retrieveMedicalEventsBySpeakerBureauId(speakerBureauIdsToRecalc);
		Set<Id> medicalEventIds = new Set<Id> ();
		for (Set<Id> medicalEventIdsForSpeakerBureau : medicalEventsBySpeakerBureauId.values()) {
			medicalEventIds.addAll(medicalEventIdsForSpeakerBureau);
		}

		System.debug('speakerBureauIdsToRecalc = ' + speakerBureauIdsToRecalc);

		Map<Id, Set<Id>> eventAttendeesByMedicalEventId = new Map<Id, Set<Id>>();
		Map<String, List<Event_Attendee_vod__c>> eventAttendeesByAccountIdBureauIdAndStatus = retrieveEventAttendeesByAccountIdMedicalEventIdAndStatus(medicalEventIds, accountIdsToRecalc, eventAttendeesByMedicalEventId);

		for (Speaker_Bureau_Membership_gne__c sbMembership : memershipsToRecalc) {
			Integer upcoming = 0;
			Integer completed = 0;
			Set<Id> medicalEventsForSpeakerBureau = medicalEventsBySpeakerBureauId.get(sbMembership.Speaker_Bureau_ID_gne__c);
			Set<Id> medicalEventsForAttendee = eventAttendeesByMedicalEventId.get(sbMembership.Bureau_Member_gne__c);

			if (medicalEventsForAttendee != null && medicalEventsForSpeakerBureau != null) {
				for (Id medicalEventId : medicalEventsForAttendee) {
					if (medicalEventsForSpeakerBureau.contains(medicalEventId)) {
						upcoming += getAttendeeCountByStatus(eventAttendeesByAccountIdBureauIdAndStatus,
								sbMembership.Bureau_Member_gne__c, medicalEventId, 'Upcoming');
						completed += getAttendeeCountByStatus(eventAttendeesByAccountIdBureauIdAndStatus,
								sbMembership.Bureau_Member_gne__c, medicalEventId, 'Completed');
					}
				}
			}
			sbMembership.Upcoming_Programs_gne__c = upcoming;
			sbMembership.Completed_Programs_gne__c = completed;
		}
	}

	private static Map<Id, Set<Id>> retrieveMedicalEventsBySpeakerBureauId(Set<Id> speakerBureauIds) {
		List<Event_Bureaus_gne__c> eventBureaus = [
				SELECT Id, Medical_Event_gne__r.Status_gne__c, Speaker_Bureau_gne__c, Medical_Event_gne__c
				FROM Event_Bureaus_gne__c
				WHERE Medical_Event_gne__r.Event_Type_gne__c = 'Speaker Program' and 
					Medical_Event_gne__r.Status_gne__c in ('Occurred', 'Pending', 'Confirmed', 'Closed') and
					Speaker_Bureau_gne__c in :speakerBureauIds];

		System.debug('eventBureaus : ' + eventBureaus.size());

		Map<Id, Set<Id>> medicalEventsBySpeakerBureauId = new Map<Id, Set<Id>>();

		for (Event_Bureaus_gne__c eventBureau : eventBureaus) {
			Set<Id> tmpSet = medicalEventsBySpeakerBureauId.get(eventBureau.Speaker_Bureau_gne__c);
			if (tmpSet == null) {
				medicalEventsBySpeakerBureauId.put(eventBureau.Speaker_Bureau_gne__c, new Set<Id> {eventBureau.Medical_Event_gne__c});
			} else {
				tmpSet.add(eventBureau.Medical_Event_gne__c);
			}
		}

		return medicalEventsBySpeakerBureauId;
	}

	private static Map<String, List<Event_Attendee_vod__c>> retrieveEventAttendeesByAccountIdMedicalEventIdAndStatus(Set<Id> medicalEventIds, Set<Id> accountIds, Map<Id, Set<Id>> eventAttendeesByMedicalEventId) {
		Map<String, List<Event_Attendee_vod__c>> eventAttendeesByAccountIdMedicalEventIdAndStatus = new Map<String, List<Event_Attendee_vod__c>>();

		List<Event_Attendee_vod__c> attendees = [
				SELECT Id, Account_vod__c, Medical_Event_vod__r.Status_gne__c, Medical_Event_vod__c
				FROM Event_Attendee_vod__c 
				WHERE Role_gne__c = 'Speaker' and
					Medical_Event_vod__c in :medicalEventIds and
					Account_vod__c in :accountIds];

		for (Event_Attendee_vod__c attendee : attendees) {
			String key = attendee.Account_vod__c + '#' + attendee.Medical_Event_vod__c + '#' + getSimpleStatus(attendee.Medical_Event_vod__r.Status_gne__c);
			if (eventAttendeesByAccountIdMedicalEventIdAndStatus.get(key) == null) {
				eventAttendeesByAccountIdMedicalEventIdAndStatus.put(key, new List<Event_Attendee_vod__c> {attendee});
			} else {
				eventAttendeesByAccountIdMedicalEventIdAndStatus.get(key).add(attendee);
			}

			if (eventAttendeesByMedicalEventId.get(attendee.Account_vod__c) == null) {
				eventAttendeesByMedicalEventId.put(attendee.Account_vod__c, new Set<Id> {attendee.Medical_Event_vod__c});
			} else {
				eventAttendeesByMedicalEventId.get(attendee.Account_vod__c).add(attendee.Medical_Event_vod__c);
			}
		}

		return eventAttendeesByAccountIdMedicalEventIdAndStatus;
	}

	private static String getSimpleStatus(String status_gne) {
		if (status_gne == 'Confirmed' || status_gne == 'Pending') {
			return 'Upcoming';
		} else if (status_gne == 'Occurred' || status_gne == 'Closed') {
			return 'Completed';
		}
		return '';
	}

	private static Integer getAttendeeCountByStatus(Map<String, List<Event_Attendee_vod__c>> eventAttendeesByAccountIdBureauIdAndStatus, Id accountId, Id medicalEventId, String simpleStatus) {
		if (eventAttendeesByAccountIdBureauIdAndStatus.get(accountId + '#' + medicalEventId + '#' + simpleStatus) != null) {
			return eventAttendeesByAccountIdBureauIdAndStatus.get(accountId + '#' + medicalEventId + '#' + simpleStatus).size();
		}

		return 0;
	}

	private static void createMembershipTrainings(List<Speaker_Bureau_Membership_gne__c> triggerNewList) {
		List<Speaker_Training_gne__c> speakerTrainings = EDM_Speaker_Training_Util.getSpeakerTrainigs(triggerNewList);
		Set<EDM_Speaker_Training_Util.MembershipTrainingIdentifier> existingTrainingsMTIs = EDM_Speaker_Training_Util.getExistingMTIs(speakerTrainings, triggerNewList);

		List<Member_Trainings_gne__c> newMemberTrainings = new List<Member_Trainings_gne__c>();

		for (Speaker_Bureau_Membership_gne__c sbm : triggerNewList) {
            for (Speaker_Training_gne__c st : speakerTrainings) {
                EDM_Speaker_Training_Util.MembershipTrainingIdentifier mtiToCheck = new EDM_Speaker_Training_Util.MembershipTrainingIdentifier(sbm.Id, st.Id);
                if (sbm.Bureau_Member_gne__c == st.Speaker_gne__c && !existingTrainingsMTIs.contains(mtiToCheck)) {
                    newMemberTrainings.add(EDM_Speaker_Training_Util.getMemberTrainingFor(sbm.Id, st.Id));
                }
            }
        }

        insert newMemberTrainings;
	}

	private static void deleteMembershipTrainings(List<Speaker_Bureau_Membership_gne__c> triggerOldList) {
		delete [SELECT Id FROM Member_Trainings_gne__c WHERE Speaker_Bureau_Membership_gne__c IN :triggerOldList];
	}
}