public with sharing class GNE_SFA2_Curriculum_Child_Records_Update {

	public static void deleteOrphanedEventCuriculumJoins(Set<Id> triggerOldIds){
		delete [SELECT Id FROM Event_Curriculum_Join_gne__c WHERE Event_Curriculum_gne__c IN :triggerOldIds];
	}

	public static void deleteOrphanedSpeakerTrainings(Set<Id> triggerOldIds){
		delete [SELECT Id FROM Speaker_Training_gne__c WHERE Event_Curriculum_gne__c IN :triggerOldIds];
	}
}