public with sharing class GNE_SFA2_Member_Train_Validation_Rules {
	
	public static void onBeforeInsert(List<Member_Trainings_gne__c> triggerNewList){
		runMemberTrainValidations(triggerNewList);
	}
	
	public static void onBeforeUpdate(List<Member_Trainings_gne__c> triggerNewList){
		runMemberTrainValidations(triggerNewList);
	}
	
	public static void runMemberTrainValidations(List<Member_Trainings_gne__c> triggerNewList){
		for(Member_Trainings_gne__c memTrain : triggerNewList){
			if(memTrain.Speaker_Bureau_Membership_gne__c == null && memTrain.Speaker_Training_gne__c == null){
				memTrain.addError(System.Label.MemTrain_Required_Fields_Needed);
			}
		}
	}
}