public virtual without sharing class GNE_PatPers_IU_Support_BioOnc_Oral extends GNE_PatPers_IU_Support_Base
{
	public virtual override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact) 
	{
		List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
		if (patient.pat_dob != null)
		{ 
			GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
			survey1.questionNumber = '100';
			survey1.answerNumber = '101';
			survey1.answerText = 'Yes';
			surveyList.Add(survey1);
		}  
		if (productShipDate!=null)
		{
			GNE_PatPers_IU_SurveyInfo surveyS = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
			surveyS.questionNumber = '9006';
			surveyS.answerNumber = '9006';
			surveyS.answerText = Datetime.newInstance(productShipDate, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy');
			surveyList.Add(surveyS);
		}
		return surveyList;
	}
}