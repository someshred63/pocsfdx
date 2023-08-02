public with sharing class EDM_CurriculumSuccessorCrawler implements Queueable {

	public class CurriculumsToProcessListItem {
		public Id curriculumToProcess;
		public Boolean isMedEventOrInteraction;

		public CurriculumsToProcessListItem(Id curriculumId, Boolean isMedEventOrInteraction) {
			this.curriculumToProcess = curriculumId;
			this.isMedEventOrInteraction = isMedEventOrInteraction;
		}
	}

	private List<CurriculumsToProcessListItem> curriculumsToProcess;

	public EDM_CurriculumSuccessorCrawler(Id parentCurriculumId) {
		this(parentCurriculumId, false);
	}

	public EDM_CurriculumSuccessorCrawler(Id parentCurriculumId, Boolean isMedEventOrInteraction) {
		this(new List<CurriculumsToProcessListItem>{
			new CurriculumsToProcessListItem(parentCurriculumId, isMedEventOrInteraction)
		});
	}

	public EDM_CurriculumSuccessorCrawler(List<CurriculumsToProcessListItem> curriculumsToProcess) {
		this.curriculumsToProcess = curriculumsToProcess;
	}

	public void execute(QueueableContext context) {
        Id parentCurriculumId;
        Boolean isMedEventOrInteraction;

        if (curriculumsToProcess != null && !curriculumsToProcess.isEmpty()) {
        	CurriculumsToProcessListItem curriculumToProcessItem = curriculumsToProcess.remove(0);
        	parentCurriculumId = curriculumToProcessItem.curriculumToProcess;
        	isMedEventOrInteraction = curriculumToProcessItem.isMedEventOrInteraction;
        }

		System.debug('parentCurriculumId: ' + parentCurriculumId);
        System.debug('isMedEventOrInteraction: ' + isMedEventOrInteraction);

        CurriculumsToProcessListItem currToProcessItemNotMedEvent = null;

		if (parentCurriculumId != null) {
			List<Event_Curriculum_gne__c> parentCurriculum =
				isMedEventOrInteraction ?	getCurriculumWithTrainingsById(parentCurriculumId) :
							getCurriculumWithAutomaticTrainingsById(parentCurriculumId);


			if (parentCurriculum.size() > 0 && parentCurriculum[0].Replaced_By_Curr_gne__c != null) {
				List<Speaker_Training_gne__c> trainings = parentCurriculum[0].Training_Interactions__r;

				List<Event_Curriculum_gne__c> successorCurriculum = getCurriculumWithAutomaticTrainingsById(parentCurriculum[0].Replaced_By_Curr_gne__c);
				System.debug('*** successorCurriculum: ' + successorCurriculum);

				if (successorCurriculum.size() > 0 && successorCurriculum[0].Speaker_Retraining_Required_gne__c == 'No'
					&& successorCurriculum[0].Start_Date_gne__c != null && successorCurriculum[0].Approval_Date_gne__c != null) {
					Set<String> uniqueSpeakers = getSpeakersWithExistingAutomaticTrainings(successorCurriculum[0].Training_Interactions__r);

					List<Speaker_Training_gne__c> trainingsToInsert = new List<Speaker_Training_gne__c>();

					for (Speaker_Training_gne__c training : trainings) {
						if (!uniqueSpeakers.contains(training.Speaker_gne__c)) {
							Speaker_Training_gne__c newTraining = training.clone(false, true, false, false);
							newTraining.Event_Curriculum_gne__c = successorCurriculum[0].Id;
							newTraining.Curriculum_Version_ID_gne__c = successorCurriculum[0].Curriculum_External_Id_gne__c;
							newTraining.Trained_Date_gne__c = successorCurriculum[0].Approval_Date_gne__c;
							if (isMedEventOrInteraction) {
								newTraining.Delivery_Method_gne__c = 'Automatic';
							}
							trainingsToInsert.add(newTraining);
							//avoid duplicates from parent curriculum
							uniqueSpeakers.add(training.Speaker_gne__c);
						}
					}

					if (trainingsToInsert.size() > 0) {
						insert trainingsToInsert;
					}

					if (!Test.isRunningTest()) {
						currToProcessItemNotMedEvent = new CurriculumsToProcessListItem(successorCurriculum[0].Id, false);						
					}
				}
			}
		}

		if (curriculumsToProcess != null && !Test.isRunningTest()) {
			if (currToProcessItemNotMedEvent != null) {
				//repack list
				List<CurriculumsToProcessListItem> curriculumsToProcessTemp = new List<CurriculumsToProcessListItem>();
				curriculumsToProcessTemp.add(currToProcessItemNotMedEvent);
				curriculumsToProcessTemp.addAll(curriculumsToProcess);

				curriculumsToProcess = curriculumsToProcessTemp;				
			}
	
			if (!curriculumsToProcess.isEmpty()) {
				System.enqueueJob(new EDM_CurriculumSuccessorCrawler(curriculumsToProcess));
			}
		}
	}

	private List<Event_Curriculum_gne__c> getCurriculumWithAutomaticTrainingsById(Id curriculumId) {
		return [SELECT Id, Replaced_By_Curr_gne__c, Curriculum_External_Id_gne__c, Speaker_Retraining_Required_gne__c,
					   Approval_Date_gne__c, Start_Date_gne__c,
					(SELECT Id, Call_Discussion_ID_gne__c, Curriculum_Version_ID_gne__c, Delivery_Method_gne__c,
							 Event_Curriculum_gne__c, Expiration_Date_gne__c, Interaction_ID_gne__c, Location_gne__c,
							 Medical_Event_ID_gne__c, OwnerId, Speaker_gne__c, Speaker_Scope_gne__c, Status_gne__c,
							 Trained_Date_gne__c, Training_Method_gne__c, Training_Status_gne__c
					 FROM Training_Interactions__r
					 WHERE Delivery_Method_gne__c = 'Automatic')
				FROM Event_Curriculum_gne__c
				WHERE Id = :curriculumId];
	}

	private List<Event_Curriculum_gne__c> getCurriculumWithTrainingsById(Id curriculumId) {
		return [SELECT Id, Replaced_By_Curr_gne__c, Curriculum_External_Id_gne__c, Speaker_Retraining_Required_gne__c,
					(SELECT Id, Call_Discussion_ID_gne__c, Curriculum_Version_ID_gne__c, Delivery_Method_gne__c,
							 Event_Curriculum_gne__c, Expiration_Date_gne__c, Interaction_ID_gne__c, Location_gne__c,
							 Medical_Event_ID_gne__c, OwnerId, Speaker_gne__c, Speaker_Scope_gne__c, Status_gne__c,
							 Trained_Date_gne__c, Training_Method_gne__c, Training_Status_gne__c
					 FROM Training_Interactions__r)
				FROM Event_Curriculum_gne__c
				WHERE Id = :curriculumId];
	}

	private Set<String> getSpeakersWithExistingAutomaticTrainings(List<Speaker_Training_gne__c> childTrainings) {
		Set<String> uniqueSpeakers = new Set<String>();

		for (Speaker_Training_gne__c existingST : childTrainings) {
			uniqueSpeakers.add(existingST.Speaker_gne__c);
		}

		return uniqueSpeakers;
	}
}