public class GNE_PatPers_IU_Support_1802 extends GNE_PatPers_IU_Support_Base
{
	public override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
    {
		System.debug('In Support_1802');
        List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
        if ((patient.pat_gender != null) && (patient.pat_gender != ''))
        { 
            GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey1.questionNumber = '221';
            if (patient.pat_gender.equals('Male')) 
            {
                survey1.answerNumber = '532';
            } 
            else 
            {
                survey1.answerNumber = '533';
            }    
			surveyList.Add(survey1);
		}
            
        GNE_PatPers_IU_SurveyInfo survey2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey2.questionNumber = '290';
        survey2.answerNumber = '750';
        survey2.answerText = 'Yes';
        surveyList.Add(survey2);
        if ((mHist.freqcy_of_admin_gne__c != null) && (mHist.freqcy_of_admin_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey3.questionNumber = '870';
            if (mHist.freqcy_of_admin_gne__c.equals('QD') )
            {
                survey3.answerNumber = '2592';
            } 
            else if (mHist.freqcy_of_admin_gne__c.equals('BID') )
            {
                survey3.answerNumber = '2593';
            } 
            else
            {
                survey3.pass = false;
            }
            surveyList.Add(survey3);
		}
		system.debug('THERAPY TYPE: ' + mHist.therapy_type_gne__c);
        if ((mHist.therapy_type_gne__c != null) && (mHist.therapy_type_gne__c.length() > 3))
        {
            GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey4.questionNumber = '871';
            if (mHist.therapy_type_gne__c.equals('New Start')) 
            {
                survey4.answerNumber = '2594';
            } 
            else 
            {
                survey4.answerNumber = '2595';
            }    
            surveyList.Add(survey4);
		}
        else
        {
            GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey4.questionNumber = '871';
            survey4.pass = false;   
            surveyList.Add(survey4);
		}

        if((mHist.FEV1_gne__c != null) && (mHist.FEV1_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey5.questionNumber = '872';
            if (mHist.FEV1_gne__c.contains('70: Mild')) 
            {
                survey5.answerNumber = '2598';
            } 
            else if (mHist.FEV1_gne__c.contains('40-70: Moderate')) 
            {
                survey5.answerNumber = '2597';
            } 
            else if (mHist.FEV1_gne__c.contains('40: Severe')) 
            {
                survey5.answerNumber = '2596';
            } 
            else 
            {
                survey5.pass = false;
            }    
            surveyList.Add(survey5);
		}
            
        if ((mHist.Ancillary_Supplies_gne__c != null) && (mHist.Ancillary_Supplies_gne__c != ''))
        {            
            GNE_PatPers_IU_SurveyInfo survey6 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey6.questionNumber = '873';
            if (mHist.Ancillary_Supplies_gne__c.contains('One PARI LC'))
            {
                survey6.answerNumber = '2600';
            } 
            else if (mHist.Ancillary_Supplies_gne__c.contains('Sidestream'))
            {
                survey6.answerNumber = '2599';
            } 
            else
            {
            	survey6.answerNumber = '2601';
                
                GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                survey7.questionNumber = '874';
                if (mHist.Ancillary_Supplies_gne__c.contains('0)')) 
                {
                    survey7.answerNumber = '2602';
                } 
                else if (mHist.Ancillary_Supplies_gne__c.contains('1)')) 
                {
                    survey7.answerNumber = '2603';
                } 
                else if (mHist.Ancillary_Supplies_gne__c.contains('2)')) 
                {
                    survey7.answerNumber = '2604';
                }
                else if (mHist.Ancillary_Supplies_gne__c.contains('3)')) 
                {
                    survey7.answerNumber = '2605';    
                } 
                else 
                {
                	survey7.pass = false;
                }
				surveyList.Add(survey7);
			}
			surveyList.Add(survey6);
		}
        return surveyList;
    }
}