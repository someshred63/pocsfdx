@isTest
public class GNE_SFA2_Curriculum_Child_Records_U_Test {

	@isTest
	public static void shouldDeleteOrphanedEventCurriculumJoinsWhenCurriculumDeleted() {
		//given
		Medical_Event_vod__c medEvent = createMedicalEvent();
		Event_Curriculum_gne__c evtCurr = createCurriculum();
		insert new Event_Curriculum_Join_gne__c(Medical_Event_gne__c = medEvent.Id, Event_Curriculum_gne__c = evtCurr.Id);
		System.assertEquals(1, [SELECT Count() FROM Event_Curriculum_Join_gne__c]);

		//when
		delete evtCurr;

		//then
		System.assertEquals(0, [SELECT Count() FROM Event_Curriculum_Join_gne__c]);
	}

	@isTest
	public static void shouldDeleteOrphanedSpeakerTrainingWhenCurriculumDeleted() {
		//given
		Account speaker = createSpeaker();
		Event_Curriculum_gne__c evtCurr = createCurriculum();
		createSpeakerTraining(speaker.Id, evtCurr.Id);
		System.assertEquals(1, [SELECT Count() FROM Speaker_Training_gne__c]);

		//when
		delete evtCurr;

		//then
		System.assertEquals(0, [SELECT Count() FROM Speaker_Training_gne__c]);
	}

	private static Event_Curriculum_gne__c createCurriculum() {
		Event_Curriculum_gne__c curriculum = new Event_Curriculum_gne__c(Curriculum_External_Id_gne__c='1111');
		insert curriculum;
		return curriculum;
	}

	private static Account createSpeaker() {
		String recTypeId = [SELECT Id FROM RecordType WHERE Name = 'Health Care Professional (Prescriber)' AND SobjectType = 'Account' LIMIT 1].Id;

		Account speaker = new Account();
		speaker.FirstName = 'Speaker1';
		speaker.LastName  = 'Speaker1';
		speaker.RecordTypeId = recTypeId;
		insert speaker;
		return speaker;
	}

	private static Speaker_Training_gne__c createSpeakerTraining(Id speakerId, Id curriculumId) {
		Speaker_Training_gne__c st = new Speaker_Training_gne__c();
		st.Speaker_gne__c = speakerId;
		st.Event_Curriculum_gne__c = curriculumId;
		st.Trained_Date_gne__c = Date.today();
		insert st;
		return st;
	}

	private static Medical_Event_vod__c createMedicalEvent() {
		Medical_Event_vod__c med = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
        med.Event_Type_gne__c='test';
        insert med;
        return med;
	}
}