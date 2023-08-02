/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/13/2012
*  Description: This class GNE_SFA2_Survey_Field_Update handles field updates on Survey_gne__c object on DML operations
*  This class is being used in GNE_SFA2_Survey_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_SFA2_Survey_Field_Update {
	
	// On Before Insert method
    public static void OnBeforeInsert (List<Survey_gne__c> oldSurveysList,  List<Survey_gne__c> newSurveysList){
        setATLSSurvey(null, newSurveysList);
    }
    
	// implemented based on trigger trg_GNE_Set_IsATLSSurvey_OnSurveyCreate on Survey_gne__c (before insert)
	private static void setATLSSurvey(Map<id, Survey_gne__c> oldSurveyMap, List<Survey_gne__c> newSurveyList){
		for(Survey_gne__c survey : newSurveyList){
	        if (survey.Category_gne__c.Contains('ATLS'))
	            survey.Is_ATLS_Survey_gne__c = True;
	        else
	            survey.Is_ATLS_Survey_gne__c = False;
	    }
	}

}