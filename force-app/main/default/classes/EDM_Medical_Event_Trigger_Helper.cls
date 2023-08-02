public with sharing class EDM_Medical_Event_Trigger_Helper {

	public static void updateUpcomingAndCompletedNumberOfSpeakerProgramsOnSpeakerBureauMembership(Map<Id, Medical_Event_vod__c> triggerOldMap, List<Medical_Event_vod__c> triggerNewList) {
		Set<Id> medicalEventIdsToRecacl = new Set<Id>();

		for(Medical_Event_vod__c medicalEvent : triggerNewList) {
			if (triggerOldMap == null) {
				if (String.isNotBlank(getSimpleStatus(medicalEvent.Status_gne__c))) {
					medicalEventIdsToRecacl.add(medicalEvent.Id);
				}
			} else if (getSimpleStatus(medicalEvent.Status_gne__c) != getSimpleStatus(triggerOldMap.get(medicalEvent.Id).Status_gne__c)) {
				medicalEventIdsToRecacl.add(medicalEvent.Id);
			}
		}

		if (!medicalEventIdsToRecacl.isEmpty()) {
			List<Event_Bureaus_gne__c> eventBureaus = [
					SELECT Id, Speaker_Bureau_gne__c
					FROM Event_Bureaus_gne__c
					WHERE Medical_Event_gne__c = :medicalEventIdsToRecacl FOR UPDATE];

			Set<Id> speakerBureauIdsToRecacl = new Set<Id>();
			for (Event_Bureaus_gne__c eventBureau : eventBureaus) {
				speakerBureauIdsToRecacl.add(eventBureau.Speaker_Bureau_gne__c);
			}

			if (!speakerBureauIdsToRecacl.isEmpty()) {
				List<Speaker_Bureau_Membership_gne__c> sbMembershipsToRecalc = [
						SELECT Id, Bureau_Member_gne__c, Speaker_Bureau_ID_gne__c
						FROM Speaker_Bureau_Membership_gne__c WHERE
						Speaker_Bureau_ID_gne__c in :speakerBureauIdsToRecacl for update];
				if (!sbMembershipsToRecalc.isEmpty()) {
					GNE_SFA2_Spkr_Bur_Mem_Field_Updates.updateUpcomingAndCompletedNumberOfSpeakerPrograms(null, sbMembershipsToRecalc);
					update sbMembershipsToRecalc;
				}
			}
		}
	}

	private static String getSimpleStatus(String status_gne) {
		if (status_gne == 'Confirmed' || status_gne == 'Pending') {
			return 'Upcoming';
		} else if (status_gne == 'Occurred' || status_gne == 'Closed') {
			return 'Completed';
		}
		return '';
	}

	public static void deleteOrphanedEventCuriculumJoins(Set<Id> triggerOldIds){
		delete [SELECT Id FROM Event_Curriculum_Join_gne__c WHERE Medical_Event_gne__c IN :triggerOldIds];
	}

	public static void deleteOrphanedSpeakerTrainings(Set<Id> triggerOldIds){
		delete [SELECT Id FROM Speaker_Training_gne__c WHERE Medical_Event_ID_gne__c IN :triggerOldIds];
	}
}