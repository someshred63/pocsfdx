public with sharing class GNE_PatPers_IU_Support_4707 extends GNE_PatPers_IU_Support_Base{
	
	public virtual override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
    {
        GNE_PatPers_IU_Utility util = new GNE_PatPers_IU_Utility();    
    
        System.debug('In Support_4707');
                   
        List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
        
        GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey1.questionNumber = '290';
        survey1.answerNumber = '750';
        survey1.answerText = 'Yes';
        surveyList.Add(survey1);

        GNE_PatPers_IU_SurveyInfo survey2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey2.questionNumber = '1';
        survey2.answerNumber = '1';
        survey2.answerText = 'Yes';
        surveyList.Add(survey2);
        
        if(mHist.Has_Treatment_Started__c=='Yes')
        {
        	GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	        survey3.questionNumber = '11';
	        survey3.answerNumber = '35';
	        surveyList.Add(survey3);
        }else if(mHist.Has_Treatment_Started__c=='No')
        {
        	GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	        survey4.questionNumber = '11';
	        survey4.answerNumber = '34';
	        surveyList.Add(survey4);
        }

        if(mHist.Date_of_last_dispense_gne__c !=null)
        {
        	GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	        survey5.questionNumber = '12';
	        survey5.answerNumber = '36';
	        survey5.answerText = mHist.Date_of_last_dispense_gne__c.format();
	        surveyList.Add(survey5);
        }

        if(mHist.Lung_Biopsy_Date__c !=null)
        {
        	GNE_PatPers_IU_SurveyInfo survey6 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	        survey6.questionNumber = '13';
	        survey6.answerNumber = '43';
	        survey6.answerText = mHist.Lung_Biopsy_Date__c.format() ;
	        surveyList.Add(survey6);
        }


        return surveyList;
    }
}