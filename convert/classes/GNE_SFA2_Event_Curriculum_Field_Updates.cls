public with sharing class GNE_SFA2_Event_Curriculum_Field_Updates {
	
	public static void onBeforeInsert(List<Event_Curriculum_gne__c> triggerNewList) {		
		setOwnerForInactiveEventCurricula(triggerNewList);
		setNameToPRCCode(triggerNewList);
	}

	public static void onBeforeUpdate(List<Event_Curriculum_gne__c> triggerNewList) {		
		setOwnerForInactiveEventCurricula(triggerNewList);
		setNameToPRCCode(triggerNewList);
	}

	private static void setOwnerForInactiveEventCurricula(List<Event_Curriculum_gne__c> curricula) {
		String queueId = '';
	
		// get queue to be set as owner of inactive event curriculum objects
		List<QueueSobject> queueSobjectList = [Select QueueId from QueueSobject where Queue.Name = 'No Users'];
		if(queueSobjectList.size() > 0){
			queueId = queueSobjectList[0].QueueId;
		}
		
		// set owner of inactive event curriculum objects
		if(queueId != '') {
			for (Event_Curriculum_gne__c eventCurriculum : curricula) {
				if (eventCurriculum.Deactivation_Date_gne__c <= System.today()) {
					eventCurriculum.OwnerId = queueId;
				}
			}
		}
	}

	private static void setNameToPRCCode(List<Event_Curriculum_gne__c> curricula) {
		for (Event_Curriculum_gne__c curriculum : curricula) {
			if (curriculum.Name != curriculum.Aprimo_ID_gne__c && String.isNotBlank(curriculum.Aprimo_ID_gne__c)) {
				curriculum.Name = curriculum.Aprimo_ID_gne__c.left(80);
			}
		}
	}
}