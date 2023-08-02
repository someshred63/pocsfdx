public class GNE_PatPers_IU_Support_1570 extends GNE_PatPers_IU_Support_Base
{
	public override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact) 
    {
		List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
		if (patient.pat_dob != null)
		{ 
			GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
			survey1.questionNumber = '47';
			survey1.answerNumber = '113';
			survey1.answerText = patient.pat_dob.format();
			surveyList.Add(survey1);
	    }  
		GNE_PatPers_IU_SurveyInfo survey2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
		survey2.questionNumber = '290';
		survey2.answerNumber = '750';
		survey2.answerText = 'Yes';
		surveyList.Add(survey2);
		return surveyList;
	}
}