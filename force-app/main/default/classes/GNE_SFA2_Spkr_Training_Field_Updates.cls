public with sharing class GNE_SFA2_Spkr_Training_Field_Updates {
	
	public static void onAfterInsert(List<Speaker_Training_gne__c> triggerNewList){
		 createMemberTrainings(triggerNewList);
	}
	 
	public static void onAfterUpdate(List<Speaker_Training_gne__c> triggerNewList){
		 createMemberTrainings(triggerNewList);
	}
	
	public static void createMemberTrainings(List<Speaker_Training_gne__c> triggerNewList){
		Set<Id> speakers = new Set<Id>();
		Set<Id> speakersTrToDel = new Set<Id>();
		Set<Id> allCurriculum = new Set<Id>();
		Set<Id> allSpBureau = new Set<Id>();
		Map<Id, Set<Id>> currToSB = new Map<Id, Set<Id>>();
		List<Member_Trainings_gne__c> memberTrainings = new List<Member_Trainings_gne__c>();
		
		//get all Speaker_gne__c
		for(Speaker_Training_gne__c tmpSpTr : triggerNewList){
			speakersTrToDel.add(tmpSpTr.Id);
			speakers.add(tmpSpTr.Speaker_gne__c);
			allCurriculum.add(tmpSpTr.Event_Curriculum_gne__c);
		} 
		
		List<Member_Trainings_gne__c> oldMTtoDel = [SELECT Id FROM Member_Trainings_gne__c m WHERE Speaker_Training_gne__c IN :speakersTrToDel];
		if(!oldMTtoDel.isEmpty()){
			delete oldMTtoDel;
		}
		system.debug(Logginglevel.INFO, 'lk triggerNewList.size(): '+triggerNewList.size());

		// Select all SBM for Speakers 
		List<Curriculum_Speaker_Bureau_gne__c> eventList =[SELECT Speaker_Bureau_gne__c, Event_Curriculum_gne__c FROM Curriculum_Speaker_Bureau_gne__c WHERE Event_Curriculum_gne__c IN : allCurriculum];
		for(Curriculum_Speaker_Bureau_gne__c tmpEvent : eventList){
			allSpBureau.add(tmpEvent.Speaker_Bureau_gne__c);
			if(!currToSB.containsKey(tmpEvent.Event_Curriculum_gne__c)){
				currToSB.put(tmpEvent.Event_Curriculum_gne__c, new Set<Id>());
			}
			currToSB.get(tmpEvent.Event_Curriculum_gne__c).add(tmpEvent.Speaker_Bureau_gne__c);
		}
		
		List<Speaker_Bureau_Membership_gne__c> speakerBMList = [SELECT Speaker_Bureau_ID_gne__c, Name,Bureau_Member_gne__c, Id FROM Speaker_Bureau_Membership_gne__c WHERE Speaker_Bureau_ID_gne__c IN : allSpBureau AND Bureau_Member_gne__c IN :speakers];
		for(Speaker_Training_gne__c tmpSpTr : triggerNewList){
			for(Speaker_Bureau_Membership_gne__c tmpSMB :speakerBMList){
				//find Speaker in related SBM
				if(tmpSpTr.Speaker_gne__c == tmpSMB.Bureau_Member_gne__c){
					//find related Curriculum
					for(Id speakerBureauId : currToSB.get(tmpSpTr.Event_Curriculum_gne__c)){
						if(speakerBureauId == tmpSMB.Speaker_Bureau_ID_gne__c){
							//create Membership training record for current speaker
							Member_Trainings_gne__c memberTraining = new Member_Trainings_gne__c();
							memberTraining.Speaker_Bureau_Membership_gne__c = tmpSMB.Id;
							memberTraining.Speaker_Training_gne__c = tmpSpTr.Id;
							memberTrainings.add(memberTraining);
						}
					}
				}
			}
		}
		system.debug(Logginglevel.INFO, 'lk memberTrainings.size: '+memberTrainings.size());
		upsert memberTrainings;
	}
}