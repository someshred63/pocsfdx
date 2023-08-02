// Herceptin
public class GNE_PatPers_IU_Support_4688 extends GNE_PatPers_IU_Support_BioOnc_Infu
{
	public override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
    {
    	List<GNE_PatPers_IU_SurveyInfo> surveyList = super.getSurveyList(transactionID, segmentID,  patientID, patient, 
    														mHist, casePractice, addyPractice, insPrimary, 
    														addyPrim, insSecondary, addySecondary, 
    														profile, productShipDate, preferredMethodOfContact);
       	GNE_PatPers_IU_SurveyInfo surveyP1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
       	surveyP1.questionNumber = '740';
       	surveyP1.answerNumber = '2105';
       	surveyList.Add(surveyP1);
		return 	surveyList;                                            
    }
}