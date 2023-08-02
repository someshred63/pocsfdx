public class GNE_PatPers_IU_Support_8076 extends GNE_PatPers_IU_Support_Base
{
  /*
  --XOLAIR survey information Process
  --Last Modified by SKM on 8/26/10
  */
  
  	public override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact) 
    {
        List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
        GNE_PatPers_IU_SurveyInfo survey = null; 
         
        if (mHist.Therapy_Type_gne__c != null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1496';
            if(mHist.Therapy_Type_gne__c.equals('New Start'))
            {
                survey.answerNumber = '4802';
                survey.answerText ='Naive Start';
                surveyList.Add(survey);
            }
            else if(mHist.Therapy_Type_gne__c.equals('Restart'))
            {
                survey.answerNumber = '4803';
                survey.answerText ='Restart';
                surveyList.Add(survey);
            }
            else if(mHist.Therapy_Type_gne__c.equals('Continued'))
            {
                survey.answerNumber = '4804';
                survey.answerText ='Continued Tx';
                surveyList.Add(survey);
            }
        } 
          
        if (mHist.Dispense_Month_Supply_gne__c != null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1498';
            if(mHist.Dispense_Month_Supply_gne__c == 1)
            {
                survey.answerNumber = '4807';
                survey.answerText ='30 days supply';
                surveyList.Add(survey);
            }
            else if(mHist.Dispense_Month_Supply_gne__c == 3)
            {
                survey.answerNumber = '4809';
                survey.answerText ='90 days supply';
                surveyList.Add(survey);
            } 
        }

        if (mHist.Dosage_mg_gne__c != null && mHist.Dose_Frequency_in_weeks_gne__c!=null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1499';
            if(mHist.Dosage_mg_gne__c == 150 && mHist.Dose_Frequency_in_weeks_gne__c.equalsIgnoreCase('Every 4 weeks'))
            {
                survey.answerNumber = '4810';
                survey.answerText ='150 mg/dose every 4 weeks';
                surveyList.Add(survey);
            }
            else if(mHist.Dosage_mg_gne__c == 300 && mHist.Dose_Frequency_in_weeks_gne__c.equalsIgnoreCase('Every 4 weeks'))
            {
                survey.answerNumber = '4811';
                survey.answerText ='300 mg/dose every 4 weeks';
                surveyList.Add(survey);
            }
            else if(mHist.Dosage_mg_gne__c == 225 && mHist.Dose_Frequency_in_weeks_gne__c.equalsIgnoreCase('Every 2 weeks'))
            {
                survey.answerNumber = '4812';
                survey.answerText ='225 mg/dose every 2 weeks';
                surveyList.Add(survey);
            }
            else if(mHist.Dosage_mg_gne__c == 300 && mHist.Dose_Frequency_in_weeks_gne__c.equalsIgnoreCase('Every 2 weeks'))
            {
                survey.answerNumber = '4813';
                survey.answerText ='300 mg/dose every 2 weeks';
                surveyList.Add(survey);
            }
            else if(mHist.Dosage_mg_gne__c == 375 && mHist.Dose_Frequency_in_weeks_gne__c.equalsIgnoreCase('Every 2 weeks'))
            {
                survey.answerNumber = '4814';
                survey.answerText ='375 mg/dose every 2 weeks';
                surveyList.Add(survey);
            }
        }                                      
        
        if (mHist.Refill_times_gne__c!= null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1500';
            survey.answerNumber = '4815';
            survey.answerText =String.valueOf(mHist.Refill_times_gne__c);
            surveyList.Add(survey);
        } 
        if (mHist.Ship_To_gne__c != null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1502';
            survey.answerNumber = '4817';
            survey.answerText =mHist.Ship_To_gne__c;
            surveyList.Add(survey);
        } 
          
        if (casePractice.OK_to_Contact_Patient_gne__c != null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1504';
            if(String.valueOf(casePractice.OK_to_Contact_Patient_gne__c).equals('Yes'))
            {
               survey.answerNumber = '4819';
            }
            else if(String.valueOf(casePractice.OK_to_Contact_Patient_gne__c).equals('No'))
            {
               survey.answerNumber = '4820';
            }
            survey.answerText =String.valueOf(casePractice.OK_to_Contact_Patient_gne__c);
            surveyList.Add(survey);
        }

        survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey.questionNumber = '1505';
        survey.answerNumber = '4821';
        survey.answerText ='Yes';
        surveyList.Add(survey);
 
        if (mHist.Patient_has_CIU_more_than_6_weeks_gne__c != null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1700';
            if(String.valueOf(mhist.Patient_has_CIU_more_than_6_weeks_gne__c).equals('Yes'))
            {
               survey.answerNumber = '5100';
            }
            else if(String.valueOf(mhist.Patient_has_CIU_more_than_6_weeks_gne__c).equals('No'))
            {
               survey.answerNumber = '5101';
            }
            survey.answerText =String.valueOf(mHist.Patient_has_CIU_more_than_6_weeks_gne__c);
            surveyList.Add(survey);
        } 

        if (mHist.H1_antihistamines_gne__c != null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1701';
            if(String.valueOf(mhist.H1_antihistamines_gne__c).equals('Yes'))
            {
               survey.answerNumber = '5102';
            }
            else if(String.valueOf(mhist.H1_antihistamines_gne__c).equals('No'))
            {
               survey.answerNumber = '5103';
            }
            survey.answerText =String.valueOf(mHist.H1_antihistamines_gne__c);
            surveyList.Add(survey);
        } 

        if (mHist.Other_CIU_therapies_gne__c!= null)
        {
            survey = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey.questionNumber = '1701';
            survey.answerNumber = '5104';
            survey.answerText =String.valueOf(mHist.Other_CIU_therapies_gne__c);
            surveyList.Add(survey);
        } 

    return surveyList;
    
    }
}