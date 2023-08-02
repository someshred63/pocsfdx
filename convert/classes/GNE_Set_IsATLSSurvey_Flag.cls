public with sharing class GNE_Set_IsATLSSurvey_Flag {
	@future
	public static void setIsATLSSurveyFlag(Set<Id> QuestIds){
		List<Survey_gne__c> surveys = new List<Survey_gne__c>();
		
		for (Survey_gne__c s :  [select id, Category_gne__c, Is_ATLS_Survey_gne__c 
									from Survey_gne__c 
									where Questionnaire_gne__c in :QuestIds]) 
		{
			Survey_gne__c survey = new Survey_gne__c();
			survey.id = s.id;			
			
			if (s.Category_gne__c.Contains('ATLS'))
				survey.Is_ATLS_Survey_gne__c = true;
			else
				survey.Is_ATLS_Survey_gne__c = false;
			
			surveys.add(survey);			
		}
		
		if (surveys.size() > 0)
			update surveys;
    }
}