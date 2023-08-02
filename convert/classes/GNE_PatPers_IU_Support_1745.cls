public class GNE_PatPers_IU_Support_1745 extends GNE_PatPers_IU_Support_Base
{
	public override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact) 
    {
        String ME = casePractice.Case_Treating_Physician_gne__r.ME__c;
        String STARS_ID = casePractice.Case_Treating_Physician_gne__r.STARS_ID_gne__c;
        String firstName = casePractice.Case_Treating_Physician_gne__r.firstName;
        String lastName = casePractice.Case_Treating_Physician_gne__r.LastName;
        
        String name = firstname + ' ' + lastName;
        String street = addyPractice.Name;
        String city = addyPractice.City_vod__c;
        String state = addyPractice.State_vod__c; 
        String zip = addyPractice.Zip_vod__c;   


		List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
		System.debug('GNE 1745: ' + patient.pat_gender );
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
        surveyList.Add(survey2);
          
        if ((mHist.Therapy_Type_gne__c != null) && (mHist.Therapy_Type_gne__c != ''))
        {
			GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
			survey3.questionNumber = '860';
			if (mHist.Therapy_Type_gne__c.equals('New Start')) 
			{
			    survey3.answerNumber = '2567';
			} 
			else if (mHist.Therapy_Type_gne__c.equals('Continued')) 
			{
			    survey3.answerNumber = '2568';
			} 
			else if (mHist.Therapy_Type_gne__c.equals('Restart')) 
			{
			    survey3.answerNumber = '2569';
			} 
			else 
			{
			    survey3.answerNumber = '';
			}
			surveyList.Add(survey3);
        }
            
        if ((mHist.ICD9_Code_1_gne__r.Name != null) && (mHist.ICD9_Code_1_gne__r.Name != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey4.questionNumber = '861';
            if (mHist.ICD9_Code_1_gne__r.Name.contains('758.6')) 
            {
				survey4.answerNumber = '2572';
            } 
            else if (mHist.ICD9_Code_1_gne__r.Name.contains('253.2')) 
            {
				survey4.answerNumber = '2573';
            }
            else if (mHist.ICD9_Code_1_gne__r.Name.contains('585')) 
            {
				survey4.answerNumber = '2574';
            }
            else if (mHist.ICD9_Code_1_gne__r.Name.contains('783.43')) 
            {
				survey4.answerNumber = '2575';
            }
            else  
            {
				survey4.pass = false;
            }
            surveyList.Add(survey4);
		}
              
        if (mHist.ICD9_Code_2_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey87 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey87.questionNumber = '862';          
            survey87.answerNumber = '2577';
            survey87.answerText = mHist.ICD9_Code_2_gne__r.Name;
            surveyList.Add(survey87);
		}
            
        if ((mHist.ICD9_Code_2_gne__r.icd9_code_gne__c != null) && (mHist.ICD9_Code_2_gne__r.icd9_code_gne__c != ''))
		{
            GNE_PatPers_IU_SurveyInfo survey88 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey88.questionNumber = '863';          
            survey88.answerNumber = '2578';
            survey88.answerText = mHist.ICD9_Code_2_gne__r.ICD9_Code_gne__c;
            surveyList.Add(survey88);
		}
            
        if ((mHist.Drug_gne__c != null) && (mHist.Drug_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey7.questionNumber = '864';
            if  (mHist.Drug_gne__c.Equals('Nutropin AQ Cartridge 1x10 mg')) 
            {
                survey7.answerNumber = '2580';
            }
            else if  (mHist.Drug_gne__c.Equals('Nutropin AQ 1x10 mg')) 
            {
                survey7.answerNumber = '2583';
            }
            else if  (mHist.Drug_gne__c.Equals('Nutropin 1x5 mg')) 
            {
                survey7.answerNumber = '2584';
            }
            else if  (mHist.Drug_gne__c.Equals('Nutropin 1x10 mg')) 
            {
                survey7.answerNumber = '2585';
            }
            else if  (mHist.Drug_gne__c.Equals('Nutropin AQ Cartridge 1x20 mg')) 
            {
                survey7.answerNumber = '4393';
            }
            else if (mHist.Drug_gne__c.Equals('Nutropin AQ NuSpin 1x5 mg')) 
            {
                survey7.answerNumber = '4684';    
            }
            else if (mHist.Drug_gne__c.Equals('Nutropin AQ NuSpin 1x10 mg')) 
            {
                survey7.answerNumber = '4685';    
            }
            else if (mHist.Drug_gne__c.Equals('Nutropin AQ NuSpin 1x20 mg')) 
            {
                survey7.answerNumber = '4686';
            } 
            else if (mHist.Drug_gne__c.contains('Other'))
            {
                survey7.answerNumber = '2582';
                GNE_PatPers_IU_SurveyInfo surveysize = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                surveysize.questionNumber = '865';
                surveysize.answerNumber = '2586';
                surveysize.answerText = string.valueOf(mHist.Needle_Size_gne__c);
                surveyList.Add(surveysize);
            }    
            else 
            {
                survey7.pass = false;
                survey7.answerNumber = '';
            }
            surveyList.Add(survey7);
        }
		if (mHist.Dilute_with_ml_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey9 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey9.questionNumber = '866';
            survey9.answerNumber = '2587';
            survey9.answerText = string.valueOf(mHist.Dilute_with_ml_gne__c);
            surveyList.Add(survey9);
        }
        if (mHist.Dose_per_Inj_ml_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey11 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey11.questionNumber = '868';
            survey11.answerNumber = '2589';
            survey11.answerText = string.valueOf(mHist.Dose_per_Inj_ml_gne__c);
            surveyList.Add(survey11);
        }
        if (mHist.Dose_mg_kg_wk_gne__c != null)
        {   
            GNE_PatPers_IU_SurveyInfo survey12 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey12.questionNumber = '869';
            survey12.answerNumber = '2590';
            survey12.answerText = string.valueOf(mHist.Dose_mg_kg_wk_gne__c);
            surveyList.Add(survey12);
        }
        if (Name != null)
        {
            GNE_PatPers_IU_SurveyInfo survey13 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey13.questionNumber = '412';
            survey13.answerNumber = '1061';
            survey13.answerText = Name;
            surveyList.Add(survey13);
        }
        if (street != null)
        {
            GNE_PatPers_IU_SurveyInfo survey14 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey14.questionNumber = '439';
            survey14.answerNumber = '1135';
            survey14.answerText = street;
            surveyList.Add(survey14);
        }
        if (city != null)
        {
            GNE_PatPers_IU_SurveyInfo survey15 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey15.questionNumber = '413';
            survey15.answerNumber = '1062';
            survey15.answerText = city;
            surveyList.Add(survey15);
        }
        if (state != null)
        {
            GNE_PatPers_IU_SurveyInfo survey16 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey16.questionNumber = '414';
            survey16.answerNumber = '1063';
            survey16.answerText = state;
            surveyList.Add(survey16);
        }
        if (zip != null) 
        {
            GNE_PatPers_IU_SurveyInfo survey17 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey17.questionNumber = '440';
            survey17.answerNumber = '1136';
            survey17.answerText = Zip;
            surveyList.Add(survey17);
        }
        if (ME != null)
        {
            GNE_PatPers_IU_SurveyInfo survey18 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey18.questionNumber = '796';
            survey18.answerNumber = '2324';
            survey18.answerText = ME;
            surveyList.Add(survey18);
        }
        if (STARS_ID != null)
        {
            GNE_PatPers_IU_SurveyInfo survey19 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey19.questionNumber = '1284';
            survey19.answerNumber = '3983';
            survey19.answerText = STARS_ID;
            surveyList.Add(survey19);
        }
		return surveyList;
	}
}