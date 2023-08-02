/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-09
*  Description: This is a test class for GNE_SFA2_Questionnaire_Trigger trigger
*  
*  Modification History
*  Date        Name        		Description
*  2014-02-18  Piotr Przesmycki Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Questionnaire_Trigger_Test {
	
	private static Integer BATCH_SIZE = 201; 
	
	private static Questionnaire_gne__c prepareTestQuestionnaire(Boolean isATLS) {
		Questionnaire_gne__c testQuestionnaire = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(isATLS);
		insert testQuestionnaire;
		return testQuestionnaire;
	}
	
	private static List<Survey_gne__c> prepareTestSurveys(Questionnaire_gne__c testQuestionnaire) {
		List<Survey_gne__c> surveys = new List<Survey_gne__c>();
		for(Integer i = 0; i < BATCH_SIZE; i++) {
			surveys.add(GNE_SFA2_Triggers_Test_Util.prepareSurvey_gne(testQuestionnaire.Id));
		}
		insert surveys;
		return surveys;
	}
	
	public static testMethod void testQuestionnaireChildRecordUpdatesATLSAfterUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Questionnaire_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Questionnaire_gne__c testQuestionnaire = prepareTestQuestionnaire(false);
				List<Survey_gne__c> testSurveys = prepareTestSurveys(testQuestionnaire);
				
				Test.startTest();
				testQuestionnaire.Category_gne__c = 'ATLS';
				update testQuestionnaire;
				Test.stopTest();
				
				testSurveys = [ SELECT Is_ATLS_Survey_gne__c FROM Survey_gne__c WHERE Id IN :testSurveys ];
				for(Survey_gne__c testSurvey : testSurveys) {
					System.assertEquals(true, testSurvey.Is_ATLS_Survey_gne__c);
				}
			}
			
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testQuestionnaireChildRecordUpdatesNonATLSAfterUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_Questionnaire_Trigger', false);
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				Questionnaire_gne__c testQuestionnaire = prepareTestQuestionnaire(true);
				List<Survey_gne__c> testSurveys = prepareTestSurveys(testQuestionnaire);
				
				Test.startTest();
				testQuestionnaire.Category_gne__c = 'Sales';
				update testQuestionnaire;
				Test.stopTest();
				
				testSurveys = [ SELECT Is_ATLS_Survey_gne__c FROM Survey_gne__c WHERE Id IN :testSurveys ];
				for(Survey_gne__c testSurvey : testSurveys) {
					System.assertEquals(false, testSurvey.Is_ATLS_Survey_gne__c);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
}