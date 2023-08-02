/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-09
*  Description: This is a trigger for handling Questionnaire child record updates
*  Test class: GNE_SFA2_Questionnaire_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Questionnaire_Child_Record_Updt {
	
	@future
	private static void updateATLSSurveys(Set<Id> questionnaireIds) {
		List<Survey_gne__c> surveysToUpdate = new List<Survey_gne__c>();
	    for (Survey_gne__c survey :  [SELECT id, Category_gne__c, Is_ATLS_Survey_gne__c FROM Survey_gne__c WHERE Questionnaire_gne__c in :questionnaireIds ]) {
	      if (survey.Category_gne__c.Contains('ATLS')) {
	        survey.Is_ATLS_Survey_gne__c = true;
	      } else {
	        survey.Is_ATLS_Survey_gne__c = false;
	      }
	      
	      surveysToUpdate.add(survey);      
	    }
	    
	    if (surveysToUpdate.size() > 0) {
	      update surveysToUpdate;
	    }
	}
	
	private static void flagAtlsSurveys(List<Questionnaire_gne__c> triggerOld, List<Questionnaire_gne__c> triggerNew) {
		Set<Id> questionnaireIds = new Set<Id>();   
    
    	for (Integer i=0; i < triggerNew.size(); i++) {            
	        if (triggerNew[i].Category_gne__c != triggerOld[i].Category_gne__c) {
	              questionnaireIds.add(triggerNew[i].Id);
	        }
        }
        
        if (questionnaireIds.size() > 0){
        	updateATLSSurveys(questionnaireIds);
    	}
    
	}
	
	public static void onAfterUpdate(List<Questionnaire_gne__c> triggerOld, List<Questionnaire_gne__c> triggerNew) {
		flagAtlsSurveys(triggerOld, triggerNew);
	}
}