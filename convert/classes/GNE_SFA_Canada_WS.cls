global class GNE_SFA_Canada_WS {

	webservice static Boolean userIsValidToTakeSurvey(String questionnaireID) {

		Id uId = UserInfo.getUserId();
		
    	Boolean isValid = false;
    	List<Questionnaire_gne__c> questionnaireList = [SELECT Id, Territories_can_gne__c FROM Questionnaire_gne__c WHERE Id = :questionnaireID LIMIT 1];
    	if(questionnaireList != null && questionnaireList.size() > 0){
			
			Questionnaire_gne__c quest = questionnaireList.get(0);
		  	List<String> userTerritoriesNames = GNE_SFAC_TargetsAndTiers_Service.getUserTerritoriesNames(uId);
			
			List<String> territoriesList = new List<String>();
			if(quest.Territories_can_gne__c != null){
				String territories = quest.Territories_can_gne__c;
				territoriesList = territories.split(';');
			}
			
			Set<String> territoriesSet = new Set<String>();
			for(String terr : territoriesList){
				territoriesSet.add(terr);
			}

			for(String userTerr : userTerritoriesNames){
				if(territoriesSet.contains(userTerr)){
					return true;
				}
			}

    	}  
	    return false;          
                                     
  }

}