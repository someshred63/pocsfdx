// Tarceva
public virtual class GNE_PatPers_IU_Support_4689 extends GNE_PatPers_IU_Support_Base
{
    public virtual override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
    {
        GNE_PatPers_IU_Utility util = new GNE_PatPers_IU_Utility();    
    
        System.debug('In Support_4689');
                   
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
        survey3.questionNumber = '744';
        survey3.answerNumber = '2132';
        surveyList.Add(survey3);
        
        GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey4.questionNumber = '1041';
        survey4.answerNumber = '3108';
        surveyList.Add(survey4);
            
        if (segmentID.equals('4689')) 
        {  
            GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey5.questionNumber = '1042';
            survey5.answerNumber = '3110';
            surveyList.Add(survey5);
        }
            
        if (mHist.Tumor_Staging_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey6 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey6.questionNumber = '1043';
            if (mHist.Tumor_Staging_gne__c.contains('Stage 0'))
            {
                survey6.answerNumber = '3589';                
            }
            else if (mHist.Tumor_Staging_gne__c.contains('Stage IV'))
            {
                survey6.answerNumber = '3116';                
            }
            else if (mHist.Tumor_Staging_gne__c.contains('Stage IIIA'))
            {
                survey6.answerNumber = '3590';                
            }
            else if (mHist.Tumor_Staging_gne__c.contains('Stage IIIB'))
            {
                survey6.answerNumber = '3591';                
            }
            else if (mHist.Tumor_Staging_gne__c.contains('Stage III'))
            {
                survey6.answerNumber = '3115';                
            }
            else if (mHist.Tumor_Staging_gne__c.contains('Stage II'))
            {
                survey6.answerNumber = '3114';                
            }
            else if (mHist.Tumor_Staging_gne__c.contains('Stage I'))
            {
                survey6.answerNumber = '3113';                
            }
            else 
            {
                survey6.answerNumber = '3117';                
            }
            surveyList.Add(survey6);
        }

        Integer otherCount = 0;
        Integer countUsed = 0;
        Integer segmentCount = 0;
        boolean bSendSecondLine = false;
        boolean bSendFirstLine = false;
        if (mHist.Concurrent_Therapy_Regimens_gne__c != null) 
        {
            segmentCount = util.countSegments(mHist.Concurrent_Therapy_Regimens_gne__c);
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Surgery'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3124';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            /*if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Radiotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3125';
                surveyList.Add(surveyC1);
                countUsed++;
            }*/
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Alimta'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3126';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Carboplatin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3127';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Cisplatin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3128';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('gemzar'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3129';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('navelbine'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3130';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('taxol'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3131';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('taxotere'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3132';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Avastin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3134';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Iressa'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3135';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            GNE_PatPers_IU_SurveyInfo surveyC18 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            surveyC18.questionNumber = '1045';
            surveyC18.answerNumber = '3136';
            surveyList.Add(surveyC18);
            countUsed++;
            /*if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Other'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3137';
                surveyList.Add(surveyC1);
                otherCount++;
            }*/
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Radiation'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4261';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            /*if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Hormone'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4262';
                surveyList.Add(surveyC1);
                countUsed++;
            }*/
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Interleukin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4263';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Xeloda'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4264';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Zometa'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4265';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Irinotecan'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4266';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Vinblastine'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4267';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Oxaliplatin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4268';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Flourouracil'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4269';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('None'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4270';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if ((otherCount == 0) || (countUsed < segmentCount)) 
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3151';
                surveyList.Add(surveyC1);
            }
        }
        
        segmentCount = 0;
        otherCount = 0;
        countUsed = 0;
          
        if (mHist.Previous_Therapy_Regimens_gne__c != null) 
        {
            segmentCount = util.countSegments(mHist.Previous_Therapy_Regimens_gne__c);

            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Surgery'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3138';
                surveyList.Add(surveyC1);
                countUsed++;
                bSendSecondLine = true;
            }
           /* if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Radio'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3139';
                surveyList.Add(surveyC1);
                countUsed++;
                bSendSecondLine = true;
            }*/
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Alimta'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3140';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Carboplatin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3141';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Cisplatin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3142';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('gemzar'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3143';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('navelbine'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3144';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('taxol'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3145';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('taxotere'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3146';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Avastin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3148';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            /*if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Iressa'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3149';
                surveyList.Add(surveyC1);
                countUsed++;
            }*/
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Other'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '3151';
                surveyList.Add(surveyC1);
                otherCount++;
                bSendSecondLine = true;
                
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Radiation'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4251';
                surveyList.Add(surveyC1);
                bSendSecondLine = true;
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Hormone'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4252';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Interleukin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4253';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Xeloda'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4254';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Zometa'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4255';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Irinotecan'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4256';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Vinblastine'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4257';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Oxaliplatin'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4258';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            /*if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Flourouracil'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4259';
                surveyList.Add(surveyC1);
                countUsed++;
            }*/
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('None'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1045';
                surveyC1.answerNumber = '4260';
                surveyList.Add(surveyC1);
                countUsed++;
                bSendSecondLine = false;
                bSendFirstLine = true;
            }
        }
        else
        {
            bSendSecondLine = false;
            bSendFirstLine = false;
        }
        
        if (bSendFirstLine)
        {
            GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey7.questionNumber = '1044';
            survey7.answerNumber = '3120';
            surveyList.Add(survey7);
        }
        else if (bSendSecondLine)
        {
            GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey7.questionNumber = '1044';
            survey7.answerNumber = '3121';
            surveyList.Add(survey7);
        }
        
        if ((mHist.Therapy_Sequence_gne__c != null) && (mHist.Therapy_sequence_gne__c.Length() > 2))
        {
            GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey7.questionNumber = '1044';
            if (mHist.Therapy_Sequence_gne__c.contains('First Line')) 
            {
                survey7.answerNumber = '3120';
            } 
            else if (mHist.Therapy_Sequence_gne__c.contains('Second Line')) 
            {
                survey7.answerNumber = '3121';
            } 
            else 
            { 
                survey7.answerNumber = '3123';
            }
            surveyList.Add(survey7);
        }
        if (mHist.Date_of_First_Treatment_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey9 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey9.questionNumber = '1161';
            survey9.answerNumber = '3593';
            survey9.answerText = mHist.Date_of_First_Treatment_gne__c.format();
            surveyList.Add(survey9);    
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