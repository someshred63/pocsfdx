public virtual class GNE_PatPers_IU_Support_4687 extends GNE_PatPers_IU_Support_Base
{
	public virtual override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
    {
    	GNE_PatPers_IU_Utility util = new GNE_PatPers_IU_Utility();
        List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
         
        System.debug('In support_4687');
         
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
        survey3.questionNumber = '744';
        survey3.answerNumber = '2132';
        surveyList.Add(survey3);
        
        GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey4.questionNumber = '1031';
        survey4.answerNumber = '3053';
        surveyList.Add(survey4);
        
        GNE_PatPers_IU_SurveyInfo surveyC4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        surveyC4.questionNumber = '1300';
        surveyC4.answerNumber = '4060';
        surveyList.Add(surveyC4);

        if ((mHist.Tumor_Staging_gne__c != null) && (mHist.Tumor_Staging_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey5.questionNumber = '1032';
            if (mHist.Tumor_Staging_gne__c.contains('Stage IV')) 
            {
                survey5.answerNumber = '3056';                
            } 
            else if (mHist.Tumor_Staging_gne__c.equals('Not Provided')) 
            {
                survey5.answerNumber = '3057';                
            } 
            else 
            {
                survey5.answerNumber = '3055';
            }
            surveyList.Add(survey5);
		}
        else
        {
           GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
           survey5.questionNumber = '1032';
           survey5.answerNumber = '3057';                
           surveyList.Add(survey5);            
		}

        Integer otherCount = 0;
       	Integer countUsed = 0;
       	Integer segmentCount = 0;
       	boolean bSendSecondLine = false;
       	boolean bSendFirstLine = false;
        
        if (mHist.Concurrent_Therapy_Regimens_gne__c != null)
        {   
            segmentCount = util.countSegments(mHist.Concurrent_Therapy_Regimens_gne__c);
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Irinotecan'))  
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1033';
                surveyC1.answerNumber = '3059';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Other')) 
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1033';
                surveyC1.answerNumber = '3067';
                surveyList.Add(surveyC1);
                otherCount = 1;
            }
             
            if ((otherCount == 0) && (countUsed < segmentCount)) 
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1033';
                surveyC1.answerNumber = '3067';
                surveyList.Add(surveyC1);
            }
		}

        GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey7.questionNumber = '1034';
        survey7.answerNumber = '3074';
        surveyList.Add(survey7);
        if (mHist.Date_of_First_Treatment_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey9 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey9.questionNumber = '1157';
            survey9.answerNumber = '3575';
            survey9.answerText = mHist.Date_of_First_Treatment_gne__c.format();
            surveyList.Add(survey9);
        }
      	
      	segmentCount = 0;
      	otherCount = 0;
      	countUsed = 0;
           
    	if (mHist.Concurrent_Therapy_Regimens_gne__c != null) 
        {
            segmentCount = util.countSegments(mHist.Concurrent_Therapy_Regimens_gne__c);
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Surgery')) 
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4046';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Radiation'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4048';
                surveyList.Add(surveyC1);
                countUsed ++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Xeloda'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4054';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Chemotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4058';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Other'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4066';
                surveyList.Add(surveyC1);
                otherCount++;
            } 
            if ((otherCount == 0) && (countUsed < segmentCount)) 
			{
            	GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4066';
                surveyList.Add(surveyC1);
			}
		}
       	
       	otherCount = 0;
       	countused = 0;
       	segmentCount = 0;
       
       	if (mHist.Previous_Therapy_Regimens_gne__c != null)
       	{
			segmentCount = util.countSegments(mHist.Previous_Therapy_Regimens_gne__c);
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Surgery'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4047';
                surveyList.Add(surveyC1);
                bSendSecondLine = true;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Radiation'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4049';
                surveyList.Add(surveyC1);
                bSendSecondLine = false;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Irinotecan'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4051';
                surveyList.Add(surveyC1);
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Xeloda'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4055';
                surveyList.Add(surveyC1);
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Chemotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4059';
                surveyList.Add(surveyC1);
                bSendSecondLine = true;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Other'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4067';
                surveyList.Add(surveyC1);
                bSendSecondLine = true;
                otherCount++;
            } 
            System.debug('%%%% SEGMENTCOUNT: ' + segmentCount);
            System.debug('%%%% OTHERCOUNT: ' + otherCount);
            System.debug('%%%% COUNTUSED: ' + countUsed);
            System.debug('$$$%$$ STRING = ' + mHist.Previous_Therapy_Regimens_gne__c);
          	if ((otherCount == 0) && (countUsed < segmentCount)) 
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1300';
                surveyC1.answerNumber = '4067';
                surveyList.Add(surveyC1);
                bSendSecondLine = true;
           	}
		}
        else 
        {
		    bSendFirstLine = false;    
		    bSendSecondLine = false;
        }
        if (bSendFirstLine)
        {
            GNE_PatPers_IU_SurveyInfo survey8 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey8.questionNumber = '1044';
            survey8.answerNumber = '3120';
            surveyList.Add(survey8);
        }     
        else if (bSendSecondLine)
        {
            GNE_PatPers_IU_SurveyInfo survey8 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey8.questionNumber = '1044';
            survey8.answerNumber = '3121';
            surveyList.Add(survey8);
		}
        else
        { 
            GNE_PatPers_IU_SurveyInfo survey8 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey8.questionNumber = '1044';
            survey8.answerNumber = '3123';
            surveyList.Add(survey8);
		}       
        return surveyList;
	}
}