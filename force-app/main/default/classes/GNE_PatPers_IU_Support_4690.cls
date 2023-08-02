public virtual class GNE_PatPers_IU_Support_4690 extends GNE_PatPers_IU_Support_Base
{
    public virtual override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
    {
    	GNE_PatPers_IU_Utility util = new GNE_PatPers_IU_Utility();
	    List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
	    system.debug('In Support_4690');
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
  
        if (patient.pat_dob != null)
        {
            GNE_PatPers_IU_SurveyInfo survey2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey2.questionNumber = '222';
            survey2.answerNumber = '534';
            survey2.answerText = patient.pat_dob.format();
            surveyList.Add(survey2);
        }
            
        GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey3.questionNumber = '290';
        survey3.answerNumber = '750';
        survey3.answerText = 'Yes';
        surveyList.Add(survey3);
           
        GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey4.questionNumber = '294';
        survey4.answerNumber = '760';
        survey4.answerText = 'Patient';
        surveyList.Add(survey4);
       
        GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey5.questionNumber = '593';
        survey5.answerNumber = '1608';
        survey5.answerText = 'Yes';
        surveyList.Add(survey5);
        
        if (mHist.Date_of_Diagnosis_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey6 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey6.questionNumber = '594';
            survey6.answerNumber = '1610';
            survey6.answerText = mHist.Date_of_Diagnosis_gne__c.format();
            surveyList.Add(survey6);
        }
        GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey7.questionNumber = '595';
        survey7.answerNumber = '4143';
        surveyList.Add(survey7);
            
		Integer otherCount = 0;
		Integer countUsed = 0;
		Integer segmentCount = 0;
    
        if (mHist.Concurrent_Therapy_Regimens_gne__c != null)
        {   
            segmentCount = util.countSegments(mHist.Concurrent_Therapy_Regimens_gne__c);
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Surgery'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '596';
                surveyC1.answerNumber = '1617';
                surveyList.Add(surveyC1); 
                countUsed++;           
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Radiation'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '596';
                surveyC1.answerNumber = '1618';
                surveyList.Add(surveyC1); 
                countUsed++;                
            }                    
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Chemotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '596';
                surveyC1.answerNumber = '1812';
                surveyList.Add(surveyC1);
                countUsed++;                
         	}
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Other'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '596';
                surveyC1.answerNumber = '3036';
                surveyList.Add(surveyC1);
                otherCount++;
            }
            if (mHist.Concurrent_Therapy_Regimens_gne__c.Contains('Not Prov'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '596';
                surveyC1.answerNumber = '3037';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if ((otherCount == 0) || (countUsed < segmentCount)) 
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '596';
                surveyC1.answerNumber = '3036';
                surveyList.Add(surveyC1);
            }
		}
        
        Boolean icd9IsNumeric = false;
        Double icd9Number; 
        try
        {
            if(mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9')
            {
                icd9Number = Double.valueOf(mHist.ICD9_Code_1_gne__r.ICD9_Code_gne__c);    
                icd9IsNumeric = true;    
            }
            
        }catch(System.TypeException e)
        {
            icd9IsNumeric = false;
        }

        GNE_PatPers_IU_SurveyInfo survey9 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey9.questionNumber = '1028';
        if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9' 
             && icd9IsNumeric
             && (icd9Number >= 200.7
                 && icd9Number <= 200.78)
            )
        {
        	survey9.answerNumber = '3043';
        }	
        else if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9'
                    && icd9IsNumeric
                    &&(icd9Number >= 202.0
                        && icd9Number <= 202.8)
                )    
        {
        	survey9.answerNumber = '3042';
        }
        else
        {
            //For all other ICD9 and any ICD-10 code, we only use 3044.
        	survey9.answerNumber = '3044';
        }	
        surveyList.Add(survey9);

        GNE_PatPers_IU_SurveyInfo survey12 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey12.questionNumber = '1029';
		if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9'
                && mHist.ICD9_Code_1_gne__r.Name.contains('202'))
		{
        	survey12.answerNumber = '3045';
		}
        else if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9'
                    && mHist.ICD9_Code_1_gne__r.Name.contains('204.1'))
        {
        	survey12.answerNumber = '3046';
        }	
        else if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-10'
                    && (mHist.ICD9_Code_1_gne__r.Name.contains('C91.10')
                        || mHist.ICD9_Code_1_gne__r.Name.contains('C91.11')
                        || mHist.ICD9_Code_1_gne__r.Name.contains('C91.12'))
                )
        {
            survey12.answerNumber = '3046';
        }   
        
        else if ((mHist.ICD9_Code_1_gne__r.Name != null) && (mHist.ICD9_Code_1_gne__r.Name != ''))
        {
        	survey12.answerNumber = '3050';
        }	
        else
        { 
        	survey12.pass = false;
        }	
        surveyList.Add(survey12);
            
        GNE_PatPers_IU_SurveyInfo survey11 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey11.questionNumber = '1030';
        if (mHist.Current_Rtx_Tx_Course_gne__c != null)
        {
        	survey11.answerNumber = '3052';
        }	
        else
        {
        	survey11.answerNumber = '3051';
        }	
        surveyList.Add(survey11);
            
		GNE_PatPers_IU_SurveyInfo survey15 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
       	survey15.questionNumber = '1127';
           
        survey15.answerNumber = '3416';
        surveyList.Add(survey15);           
            
		segmentCount = 0;
      	otherCount = 0;
      	countUsed = 0;
          
        if (mHist.Previous_Therapy_Regimens_gne__c != null) 
        {
        	segmentCount = util.countSegments(mHist.Previous_Therapy_Regimens_gne__c);
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Surgery'))
            {
            	GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '3417';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Radiation'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '3418';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Chemotherapy'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '3419';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Other'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '3424';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Rituxan'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4233';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Post Bone'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4234';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Immuno'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4235';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Watch and'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4236';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Radio Labeled'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4237';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('NSAID'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4238';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('DMARD'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4239';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Enbrel'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4240';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Remicaide'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4241';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Humira'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4242';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Methotrexate'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4243';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('Abateacept'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4244';
                surveyList.Add(surveyC1);
                countUsed++;
              
            }
            if (mHist.Previous_Therapy_Regimens_gne__c.Contains('None'))
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
                surveyC1.answerNumber = '4245';
                surveyList.Add(surveyC1);
                countUsed++;
            }
            if ((otherCount == 0) || (countUsed < segmentCount)) 
            {
                GNE_PatPers_IU_SurveyInfo surveyC1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveyC1.questionNumber = '1128';
               surveyC1.answerNumber = '3424';
               surveyList.Add(surveyC1);

            }
		}
		
        GNE_PatPers_IU_SurveyInfo survey14 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey14.questionNumber = '1325';
        survey14.answerNumber = '4146';
        surveyList.Add(survey14);
  
        return surveyList;
    }
}