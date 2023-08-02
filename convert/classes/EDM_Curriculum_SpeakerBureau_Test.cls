@isTest
private class EDM_Curriculum_SpeakerBureau_Test {

	@testSetup 
	static void setupData() {
		Event_Curriculum_gne__c curriculum = createCurriculum();
		Speaker_Bureau_gne__c bureau = createBureau();
		Account speaker = createSpeaker();
		Speaker_Bureau_Membership_gne__c sbm = createSBM(bureau.Id, speaker.Id);
		Speaker_Training_gne__c speakerTraining = createSpeakerTraining(speaker.Id, curriculum.Id);
	}
	
	@isTest 
	static void shouldCreateMemberTraining() {
		//given
		Id breauId = [SELECT Id FROM Speaker_Bureau_gne__c LIMIT 1].Id;
		Id curriculumId = [SELECT Id FROM Event_Curriculum_gne__c LIMIT 1].Id;

		//when
		createCSB(breauId, curriculumId);

		//then
		List<Member_Trainings_gne__c> mts = [SELECT Id FROM Member_Trainings_gne__c];
		System.assertEquals(1, mts.size());
	}

	@isTest
	static void shouldNotCreateSecondMemberTrainingAsItAlreadyExists() {
		//given
		Id breauId = [SELECT Id FROM Speaker_Bureau_gne__c LIMIT 1].Id;
		Id curriculumId = [SELECT Id FROM Event_Curriculum_gne__c LIMIT 1].Id;

		createCSB(breauId, curriculumId);

		//when
		createCSB(breauId, curriculumId);

		//then
		List<Member_Trainings_gne__c> mts = [SELECT Id FROM Member_Trainings_gne__c];
		System.assertEquals(1, mts.size());
	}

	@isTest 
	static void shouldUpdateParentEventCurriculumOnUpdate() {
		//given
		Id breauId = [SELECT Id FROM Speaker_Bureau_gne__c LIMIT 1].Id;
		Id curriculumId = [SELECT Id FROM Event_Curriculum_gne__c LIMIT 1].Id;

		Curriculum_Speaker_Bureau_gne__c csb = createCSB(breauId, curriculumId);

		//when
		update csb;

		//then
		Event_Curriculum_gne__c ec = [SELECT Id, CreatedDate, LastModifiedDate FROM Event_Curriculum_gne__c LIMIT 1];
		System.assertNotEquals(ec.CreatedDate, ec.LastModifiedDate);
	}

	@isTest 
	static void shouldUpdateParentEventCurriculumOnDelete() {
		//given
		Id breauId = [SELECT Id FROM Speaker_Bureau_gne__c LIMIT 1].Id;
		Id curriculumId = [SELECT Id FROM Event_Curriculum_gne__c LIMIT 1].Id;

		Curriculum_Speaker_Bureau_gne__c csb = createCSB(breauId, curriculumId);

		//when
		delete csb;

		//then
		Event_Curriculum_gne__c ec = [SELECT Id, CreatedDate, LastModifiedDate FROM Event_Curriculum_gne__c LIMIT 1];
		System.assertNotEquals(ec.CreatedDate, ec.LastModifiedDate);
	}


	private static Event_Curriculum_gne__c createCurriculum() {
		Event_Curriculum_gne__c curriculum = new Event_Curriculum_gne__c(Curriculum_External_Id_gne__c='1111');
		insert curriculum;
		return curriculum;
	}

	private static Speaker_Bureau_gne__c createBureau() {
		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='Bureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		return bureau;
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

	private static Speaker_Bureau_Membership_gne__c createSBM(Id bureauId, Id speakerId) {
		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c();
		sbm.Speaker_Bureau_ID_gne__c = bureauId;
		sbm.Bureau_Member_gne__c = speakerId;
		sbm.Speaker_Status_gne__c = 'Approved';
		insert sbm;
		return sbm;
	}

	private static Curriculum_Speaker_Bureau_gne__c createCSB(Id bureauId, Id curriculumId) {
		Curriculum_Speaker_Bureau_gne__c csb = new Curriculum_Speaker_Bureau_gne__c();
		csb.Speaker_Bureau_gne__c = bureauId;
		csb.Event_Curriculum_gne__c = curriculumId;
		insert csb;
		return csb;
	}
}