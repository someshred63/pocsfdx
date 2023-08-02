/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/31/2012
*  Description: This class GNE_SFA2_CallDiscussion_ChildRcrd_Update handles updates Dependent objects and Referenced objects on Call2_Discussion_vod__c object on DML operations
*  This class is being used in GNE_SFA2_Call_Discussion_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public without sharing class GNE_SFA2_CallDiscussion_ChildRcrd_Update {

	public static void OnAfterInsert(Map<Id,Call2_Discussion_vod__c> oldCallDiscMap,  List<Call2_Discussion_vod__c> newCallDiscList){
		em3Processing(newCallDiscList, true);
	}

	public static void OnAfterUpdate(Map<Id,Call2_Discussion_vod__c> oldCallDiscMap,  List<Call2_Discussion_vod__c> newCallDiscList){
		em3Processing(newCallDiscList, false);
	}

	public static void OnAfterDelete(Map<Id,Call2_Discussion_vod__c> oldCallDiscMap,  List<Call2_Discussion_vod__c> newCallDiscList){}

	public static void OnBeforeDelete(Map<Id,Call2_Discussion_vod__c> oldCallDiscMap){
		em3ProcessingDelete(oldCallDiscMap);
	}

	private static void em3Processing(List<Call2_Discussion_vod__c> newCallDiscList, boolean isInsert) {
		if(!GNE_EM3_CALL_UTIL.isCurrentUserUseEDM()) {
			return;
		}

		List<Speaker_Training_gne__c> speakerTrainingsToUpsert = new List<Speaker_Training_gne__c>();
		List<Speaker_Training_gne__c> speakerTrainingsToDelete = new List<Speaker_Training_gne__c>();

		for(Call2_Discussion_vod__c cDisc : [
			SELECT Call2_vod__c, Call2_vod__r.id, Call2_vod__r.Completed_gne__c, Call2_vod__r.Call_Date_vod__c, Activity_gne__c, Event_Curriculum_gne__c, Event_Curriculum_gne__r.Curriculum_Status_gne__c,          
				Call2_vod__r.Account_vod__c, Call2_vod__r.Visit_Reason_gne__c, Call2_vod__r.Interaction_Type_gne__c, Call2_vod__r.Interaction_Location_gne__c,
				Call2_vod__r.Account_vod__r.isPersonAccount, Product_Strategy_vod__r.Name,
				(SELECT Id, Speaker_gne__c, Event_Curriculum_gne__c, Delivery_Method_gne__c, Call_Discussion_ID_gne__c, Interaction_ID_gne__c, Training_Method_gne__c, Location_gne__c, 
					Status_gne__c, Training_Status_gne__c, Trained_Date_gne__c FROM Speaker_Training__r) 
			FROM Call2_Discussion_vod__c 
			WHERE Id IN :newCallDiscList]) {

			Boolean isTLLInteractionForSBT = cDisc.Call2_vod__r.Account_vod__r.isPersonAccount 
												&& GNE_SFA2_Interaction_Util.isTLLInteractionForSBT(cDisc) 
												&& cDisc.Call2_vod__r.Completed_gne__c
												&& String.isNotBlank(cDisc.Event_Curriculum_gne__c);
			Boolean isValidForEM3 = GNE_EM3_CALL_UTIL.createSPvalidation(cDisc) && String.isNotBlank(cDisc.Event_Curriculum_gne__c);
			Boolean hasSpeakerTraining = cDisc.Speaker_Training__r != null && cDisc.Speaker_Training__r.size() > 0;
			Boolean isValidForCCorOCC = shouldHandleTrainingForCCorOCC(cDisc) && String.isNotBlank(cDisc.Event_Curriculum_gne__c);
            Boolean isValidForCRMProfile = shouldHandleTrainingForCRMProfiles(cDisc);

			if (hasSpeakerTraining) {
				for (Speaker_Training_gne__c speakerTraining : cDisc.Speaker_Training__r) {
					if (isTLLInteractionForSBT || isValidForEM3 || isValidForCCorOCC) {
						setSpeakerTrainingDetailsFromCallDiscussion(speakerTraining, cDisc);
						speakerTrainingsToUpsert.add(speakerTraining);
					} else if (!isValidForEM3 && !isValidForCCorOCC){
						speakerTrainingsToDelete.add(speakerTraining);
					}
				}
			} else if (isTLLInteractionForSBT || isValidForEM3 || isValidForCCorOCC || isValidForCRMProfile) {
				Speaker_Training_gne__c speakerTraining = new Speaker_Training_gne__c();
				setSpeakerTrainingDetailsFromCallDiscussion(speakerTraining, cDisc);
				speakerTrainingsToUpsert.add(speakerTraining);
			}
		}		

		if(!speakerTrainingsToUpsert.isEmpty()) {
			Database.upsert(speakerTrainingsToUpsert);

			//SFA-2685
            List<Id> currIdList = getCurriculumsIdFromSpeakerTrainings(speakerTrainingsToUpsert);
            For (Id curr : currIdList) {
                System.enqueueJob(new EDM_CurriculumSuccessorCrawler(curr, true));
            }
		}

		if(!speakerTrainingsToDelete.isEmpty()) {
			delete speakerTrainingsToDelete;
		}
	}

	private static void em3ProcessingDelete(Map<Id,Call2_Discussion_vod__c> oldCallDiscMap) {
		List<Speaker_Training_gne__c> speakerTrainingsToDelete = 
			[SELECT Id FROM Speaker_Training_gne__c where Call_Discussion_ID_gne__c in :oldCallDiscMap.keySet()];		

		if(!speakerTrainingsToDelete.isEmpty()) {
			delete speakerTrainingsToDelete;
		}
	}

	private static void setSpeakerTrainingDetailsFromCallDiscussion(Speaker_Training_gne__c speakerTraining, Call2_Discussion_vod__c cDisc) {
		speakerTraining.Speaker_gne__c 				= cDisc.Call2_vod__r.Account_vod__c;
		speakerTraining.Event_Curriculum_gne__c = cDisc.Event_Curriculum_gne__c;
		if (speakerTraining.Delivery_Method_gne__c != 'Automatic') {
			speakerTraining.Delivery_Method_gne__c = '1:1 Training/Deck Update';
		}
		speakerTraining.Interaction_ID_gne__c 	= cDisc.Call2_vod__r.Id;
		speakerTraining.Call_Discussion_ID_gne__c 	= cDisc.Id;
		speakerTraining.Training_Method_gne__c 		= 'Field managed Speaker Training';
		speakerTraining.Location_gne__c 			= cDisc.Call2_vod__r.Interaction_Location_gne__c;
		speakerTraining.Trained_Date_gne__c 		= cDisc.Call2_vod__r.Call_Date_vod__c;
		speakerTraining.Status_gne__c 				= cDisc.Event_Curriculum_gne__r.Curriculum_Status_gne__c;
		speakerTraining.Training_Status_gne__c 		= cDisc.Event_Curriculum_gne__r.Curriculum_Status_gne__c;
	}

	private static Boolean shouldHandleTrainingForCCorOCC(Call2_Discussion_vod__c cDisc) {
		String currentUserProfileName = GNE_SFA2_Util.getCurrentUserProfileName();

		Boolean isInteractionCompleted = (cDisc.Call2_vod__r.Completed_gne__c == true);
		Boolean isCCorOCC 			   = (currentUserProfileName.startsWithIgnoreCase('GNE-SFA-CC') || currentUserProfileName.startsWithIgnoreCase('GNE-SFA-OCC'));
		Boolean isActivityTraining 	   = (cDisc.Activity_gne__c == 'Training/Deck Content' || cDisc.Activity_gne__c == 'Training/Annual Compliance');
		Boolean isAccountHCP 		   = (cDisc.Call2_vod__r.Account_vod__r.isPersonAccount == true);

		return isInteractionCompleted && isCCorOCC && isActivityTraining && isAccountHCP;
	}
    
    private static Boolean shouldHandleTrainingForCRMProfiles(Call2_Discussion_vod__c cDisc) {
		String currentUserProfileName = GNE_SFA2_Util.getCurrentUserProfileName();
        Boolean result = true;

		result &= (cDisc.Call2_vod__r.Interaction_Type_gne__c == 'Speaker Program');
		result &= (cDisc.Call2_vod__r.Completed_gne__c == true);
		result &= (currentUserProfileName.startsWithIgnoreCase('GNE-CRM'));
		result &= (cDisc.Product_Strategy_vod__r.Name == '1:1 Speaker Training');
		result &= (cDisc.Call2_vod__r.Account_vod__r.isPersonAccount == true);

		return result;
	}

	private static List<Id> getCurriculumsIdFromSpeakerTrainings(List<Speaker_Training_gne__c> spkrList) {
        Set<Id> currSet = new Set<Id>();
        
        for (Speaker_Training_gne__c spkr : spkrList) {
            currSet.add(spkr.Event_Curriculum_gne__c);
        }

        return new List<Id>(currSet);
    }
}