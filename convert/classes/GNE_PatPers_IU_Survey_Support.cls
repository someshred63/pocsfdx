public  class GNE_PatPers_IU_Survey_Support 
{
    public List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, 
                                                String patientID,
                                                GNE_PatPers_IU_PatientAndAddressInfo patient)
    {
        
         List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
         List<survey_data_gne__c> lstSurveyData=[select segmentid_gne__c,Answer_Number_gne__c,Question_Number_gne__c,Answer_Text_gne__c from survey_data_gne__c where segmentID_gne__c=:segmentId Limit 1000];
         GNE_PatPers_IU_SurveyInfo survey =null;//new GNE_PatPers_IU_SurveyInfo(transactionID, segmentId, patient.patientID);
         for(survey_data_gne__c surveyData :lstSurveyData){
         	survey =new GNE_PatPers_IU_SurveyInfo(transactionID, segmentId, patient.patientID);
            survey.answerNumber = surveyData.Answer_Number_gne__c;
            survey.questionNumber = surveyData.Question_Number_gne__c;
            survey.answerText = surveyData.Answer_Text_gne__c;
            surveyList.Add(survey);
            
         }          
         return surveyList;
    }
    
    @IsTest
    public static void testMe()
    {
           
        GNE_PatPers_IU_PatientAndAddressInfo patient = new GNE_PatPers_IU_PatientAndAddressInfo();
        patient.pat_dob = Date.newInstance(1969,12,12);
        GNE_PatPers_IU_Survey_Support pSup = new GNE_PatPers_IU_Survey_Support();
        List<GNE_PatPers_IU_SurveyInfo> sur = pSup.getSurveyList('0030ASmItdsaw0', '09833wxcASmild', 
                                                'lkignvckdeessxz', patient);
        List<survey_data_gne__c> lstSurveyData=[select id from survey_data_gne__c  Limit 500];
        Database.delete(lstSurveyData);
        GNE_PatPers_IU_SurveyInfo sur1 = 
                new GNE_PatPers_IU_SurveyInfo('trans1','segmentid1','patient01');
        sur1.answerNumber='test';
        sur1.answerText='test';
        sur1.questionNumber='test';
        
        GNE_PatPers_IU_SurveyInfo sur2 = 
                new GNE_PatPers_IU_SurveyInfo('trans1','segmentid1','patient01');
        sur2.answerNumber='test1';
        sur2.answerText='test1';
        sur2.questionNumber='test1';
        List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
        surveyList.add(sur1);
        surveyList.add(sur2);  
         
        
    }
}