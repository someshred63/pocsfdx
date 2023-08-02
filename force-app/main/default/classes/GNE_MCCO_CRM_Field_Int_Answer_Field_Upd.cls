public with sharing class GNE_MCCO_CRM_Field_Int_Answer_Field_Upd {

	public static void onAfterInsert(List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> triggerNew){
		//Map<Id, GNE_MCCO_CRM_Field_Intelligence_Answer__c> answersMap = new Map<Id, GNE_MCCO_CRM_Field_Intelligence_Answer__c>([
		//		SELECT Id, Survey_Question_gne__r.Type_gne__c, Survey_Question_gne__r.Values_gne__c 
		//		FROM GNE_MCCO_CRM_Field_Intelligence_Answer__c WHERE Id IN :triggerNew]
		//);
		//List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> toUpdate = new List<GNE_MCCO_CRM_Field_Intelligence_Answer__c>();
		//for(GNE_MCCO_CRM_Field_Intelligence_Answer__c answer :triggerNew){
			//GNE_MCCO_CRM_Field_Intelligence_Answer__c detailedAnswer = answersMap.get(answer.Id);
			//detailedAnswer.Answer_for_Reports_gne__c = getAnswerForReports(detailedAnswer.Survey_Question_gne__r.Type_gne__c, detailedAnswer.Survey_Question_gne__r.Values_gne__c, answer.Answer_gne__c);
		//	toUpdate.add(answer);
		//}
		//update toUpdate;
		update [SELECT Id FROM GNE_MCCO_CRM_Field_Intelligence_Answer__c WHERE Id IN :triggerNew];
	}

	public static void onBeforeUpdate(List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> triggerNew){
		Map<Id, GNE_MCCO_CRM_Field_Intelligence_Answer__c> answersMap = new Map<Id, GNE_MCCO_CRM_Field_Intelligence_Answer__c>([
				SELECT Id, Survey_Question_gne__r.Type_gne__c, Survey_Question_gne__r.Values_gne__c 
				FROM GNE_MCCO_CRM_Field_Intelligence_Answer__c WHERE Id IN :triggerNew]
		);

		for(GNE_MCCO_CRM_Field_Intelligence_Answer__c answer :triggerNew){
			GNE_MCCO_CRM_Field_Intelligence_Answer__c detailedAnswer = answersMap.get(answer.Id);
			answer.Answer_for_Reports_gne__c = getAnswerForReports(detailedAnswer.Survey_Question_gne__r.Type_gne__c, detailedAnswer.Survey_Question_gne__r.Values_gne__c, answer.Answer_gne__c);
		}
	}

	private static String getAnswerForReports(String questionType, String values, String answer){
		if(questionType.equalsIgnoreCase('Rank')){
			return prepareRankAnswer(values, answer);
		}
		return answer;
	}

	private static String prepareRankAnswer(String values, String answer){
		List<String> valuesList = values.split(';;;');
		List<String> answerList = answer.split(';;;');
		String result = '';
		for(Integer i = 0; i < valuesList.size(); i++){
			if(i<answerList.size() && String.isNotBlank(answerList[i])){
				result += valuesList[i] + '-' + answerList[i] + ';;;';
			} else {
				result += valuesList[i] + '-?;;;';
			}
		}
		result = result.removeEndIgnoreCase(';;;');
		return result;
	}
}