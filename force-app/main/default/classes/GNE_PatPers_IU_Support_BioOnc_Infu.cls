public virtual without sharing class GNE_PatPers_IU_Support_BioOnc_Infu extends GNE_PatPers_IU_Support_Base
{
    protected GNE_PatPers_IU_Utility util = new GNE_PatPers_IU_Utility();    

	public virtual override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact) 
    {
    	List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();

        GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey1.questionNumber = '290';
        survey1.answerNumber = '750';
        survey1.answerText = 'Yes';
        surveyList.Add(survey1);

        if (mHist.Date_of_Diagnosis_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey2.questionNumber = '594';
            survey2.answerNumber = '1610';
            survey2.answerText = mHist.Date_of_Diagnosis_gne__c.format();
            surveyList.Add(survey2);
        }

        GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey3.questionNumber = '737';
        survey3.answerNumber = '2052';
        surveyList.Add(survey3);

        if (mHist.Her2_Test_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey4.questionNumber = '738';
            if (mHist.Her2_Test_gne__c.contains('Positive') || mHist.Her2_Test_gne__c.contains('Yes'))
            {
                survey4.answerNumber = '2057';
            }    
            else if (mHist.Her2_Test_gne__c.contains('Negative') || mHist.Her2_Test_gne__c.contains('No'))
            {
                survey4.answerNumber = '2058';
            }    
            else
            {
                survey4.answerNumber = '2059';
            }    
            surveyList.Add(survey4);
        }
        else
        {
            GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey4.questionNumber = '738';
            survey4.answerNumber = '2059';
            surveyList.Add(survey4);
        }

		Integer otherCount = 0;
        Integer countUsed = 0;
        Integer segmentCount = 0;

		if (mHist.Concurrent_Therapy_Regimens_gne__c != null)
        {
        	segmentCount = util.countSegments(mHist.Concurrent_Therapy_Regimens_gne__c);
			system.debug(logginglevel.error, 'mHist.Concurrent_Therapy_Regimens_gne__c: ' + mHist.Concurrent_Therapy_Regimens_gne__c);
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Surgery'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2063';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Radiation'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2065';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Chemotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2067';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Hormone Therapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2085';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Herceptin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2105';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Other'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2115';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('None'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2117';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            /*if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Know'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2119';
                surveyList.Add(surveyC1);
                countUsed ++;
            }*/
           	if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Immunotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '4277';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Clinical Trial'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '4271';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Bone Marrow'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '4273';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            System.debug(LoggingLevel.error, ' infu loop concurrent surveyList: ' + surveyList);
           	System.debug('%%%% SEGMENTCOUNT: ' + segmentCount);
            System.debug('%%%% OTHERCOUNT: ' + otherCount);
            System.debug('%%%% COUNTUSED: ' + countUsed);
            if ((countUsed <= segmentCount)) 
            {
            	GNE_PatPers_IU_SurveyInfo surveyC2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC2.questionNumber = '740';
                surveyC2.answerNumber = '2107';
                surveyList.Add(surveyC2);
			}
		}
		
		otherCount = 0;
		countUsed = 0;
		segmentCount = 0;

        if (mHist.Previous_Therapy_Regimens_gne__c != null)
        {
        	segmentCount = util.countSegments(mHist.Previous_Therapy_Regimens_gne__c);
        	
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Surgery'))
            {
            	GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2064';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Radiation'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2066';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Chemotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2068';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Hormone Therapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2086';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            /*if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Herceptin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2106';
                surveyList.Add(surveyC1);
                countUsed ++;
            }*/
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Other'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2116';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('None'))
            {
            	GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2118';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            /*if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Know'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '2120';
                surveyList.Add(surveyC1);
                countUsed++;
            }*/
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Clinical Trial'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '4272';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Bone Marrow'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '4274';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Immunotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	surveyC1.questionNumber = '740';
                surveyC1.answerNumber = '4278';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            System.debug('%%%% SEGMENTCOUNT: ' + segmentCount);
            System.debug('%%%% OTHERCOUNT: ' + otherCount);
            System.debug('%%%% COUNTUSED: ' + countUsed);
            System.debug('$$$%$$ STRING = ' + mHist.Previous_Therapy_Regimens_gne__c);
            if ((countUsed < segmentCount)) 
            {
            	GNE_PatPers_IU_SurveyInfo surveyC2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC2.questionNumber = '740';
                surveyC2.answerNumber = '2108';
                surveyList.Add(surveyC2);
            }
        }
		GNE_PatPers_IU_SurveyInfo survey6 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey6.questionNumber = '743';
        survey6.answerNumber = '2130';
        survey6.answerText = 'Yes';
        surveyList.Add(survey6);
        
        GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey7.questionNumber = '744';
        survey7.answerNumber = '2132';
        surveyList.Add(survey7);

        if (mHist.Date_of_First_Treatment_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey8 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey8.questionNumber = '1015';
            survey8.answerNumber = '2991';
            survey8.answerText = mHist.Date_of_First_Treatment_gne__c.format();
            surveyList.Add(survey8);
        }

        GNE_PatPers_IU_SurveyInfo survey9 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey9.questionNumber = '1174';
        survey9.answerNumber = '3623';
        surveyList.Add(survey9);

        if ((mHist.Adjuvant_gne__c != null) && (mHist.Adjuvant_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey10 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey10.questionNumber = '1180';
            if (mHist.Adjuvant_gne__c.equals('Yes'))
            {
                survey10.answerNumber = '3636';
            }    
            else if (mHist.Adjuvant_gne__c.equals('No'))
            {
                survey10.answerNumber = '3637';
            }    
            else
            {
                survey10.answerNumber = '3826';
            }    
            surveyList.Add(survey10);
        } 
        else 
        {
            GNE_PatPers_IU_SurveyInfo survey10 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey10.questionNumber = '1180';
			survey10.answerNumber = '3826';
            surveyList.Add(survey10);
        }	

        if ((mHist.Therapy_Sequence_gne__c != null) && (mHist.Therapy_Sequence_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey10 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey10.questionNumber = '4005';  
            if (mHist.Therapy_Sequence_gne__c.equals('First Line Therapy'))
            {
                survey10.answerNumber = '4010';
            }    
            else if (mHist.Therapy_Sequence_gne__c.equals('Second Line Therapy'))
            {
                survey10.answerNumber = '4011';
            }    
            else if (mHist.Therapy_Sequence_gne__c.equals('Third Line Therapy'))
            {
                survey10.answerNumber = '4012';
            }    
            else if (mHist.Therapy_Sequence_gne__c.equals('Fourth Line Therapy'))
            {
                survey10.answerNumber = '4013';
            }    
            else if (mHist.Therapy_Sequence_gne__c.equals('Fifth Line Therapy'))
            {
                survey10.answerNumber = '4014';
            }    
            else if (mHist.Therapy_Sequence_gne__c.equals('Sixth Line Therapy'))
            {
                survey10.answerNumber = '4015';
            }    
            else if (mHist.Therapy_Sequence_gne__c.equals('Not Provided'))
            {
                survey10.answerNumber = '4016';
            }    
            else if (mHist.Therapy_Sequence_gne__c.equals('Other'))
            {
                survey10.answerNumber = '4017';
            }    
            else
            {
                survey10.answerNumber = '';
            }    
            surveyList.Add(survey10);
        } 

        if ((mHist.TNM_Staging_gne__c != null) && (mHist.TNM_Staging_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey10 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey10.questionNumber = '4006';
            if (mHist.TNM_Staging_gne__c.equals('Stage 0'))
            {
                survey10.answerNumber = '4018';
            }    
            else if (mHist.TNM_Staging_gne__c.equals('Stage I (Early Local Disease)'))
            {
                survey10.answerNumber = '4019';
            }
            else if (mHist.TNM_Staging_gne__c.equals('Stage IIA (Early Local Disease)'))
            {
                survey10.answerNumber = '4020';
            }
            else if (mHist.TNM_Staging_gne__c.equals('Stage IIB (Early Local Disease)'))
            {
                survey10.answerNumber = '4021';
            }
            else if (mHist.TNM_Staging_gne__c.equals('Stage IIC (Early Local Disease)'))
            {
                survey10.answerNumber = '4022';
            }
            else if (mHist.TNM_Staging_gne__c.equals('Stage III (Early Local Disease)'))
            {
                survey10.answerNumber = '4023';
            }
            else if (mHist.TNM_Staging_gne__c.equals('Stage IIIA (Advanced Local Disease)'))
            {
                survey10.answerNumber = '4024';
            }
            else if (mHist.TNM_Staging_gne__c.equals('Stage IIIB (Advanced Local Disease)'))
            {
                survey10.answerNumber = '4025';
            }
            else if (mHist.TNM_Staging_gne__c.equals('Stage IIIC (Advanced Local Disease)'))
            {
                survey10.answerNumber = '4026';
            }
            else if (mHist.TNM_Staging_gne__c.equals('Stage IV (Advanced Metastatic Disease)'))
            {
                survey10.answerNumber = '4027';
            }
            else
            {
                survey10.answerNumber = '';
            }
            surveyList.Add(survey10);
        } 
    	return surveyList;
    }
    
    
}