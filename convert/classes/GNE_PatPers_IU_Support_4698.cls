public class GNE_PatPers_IU_Support_4698 extends GNE_PatPers_IU_Support_Base
{
	public override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
	{
		System.debug('IN Support_4698');
		List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
		 
		GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
		survey1.questionNumber = '12';
		survey1.answerNumber = '63';
		survey1.answerText = 'Patient';
		surveyList.Add(survey1);
                
   		if(patient.pat_gender != null)
   		{
        	if (patient.pat_gender.equals('Male'))
         	{ 
            	GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	survey3.questionNumber = '1';
            	survey3.answerNumber = '1';
            	survey3.answerText = 'male';
            	surveyList.Add(survey3);
         	}     
         	else
         	{
          		GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            	survey3.questionNumber = '1';
            	survey3.answerNumber = '2';
            	survey3.answerText = 'Female';
            	surveyList.Add(survey3);
        	}
   		}

		GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey4.questionNumber = '2';
        survey4.answerNumber = '3';
        survey4.answerText = 'Yes';
        surveyList.Add(survey4);
  		
  		GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey5.questionNumber = '5001';
        survey5.answerNumber = '5001';
        survey5.answerText = 'Yes';
        surveyList.Add(survey5);

        GNE_PatPers_IU_SurveyInfo survey6 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey6.questionNumber = '5002';
        survey6.answerNumber = '5003';
        survey6.answerText = 'Yes';
        surveyList.Add(survey6);
        
        GNE_PatPers_IU_SurveyInfo survey7= new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
		survey7.questionNumber = '5003';
        survey7.answerNumber = '5005';
        survey7.answerText = 'Yes';
        surveyList.Add(survey7);
                
		//Venkat: Adding the below lines as part of M&E December 2011 changes. 
		GNE_PatPers_IU_SurveyInfo survey10= new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	    survey10.questionNumber = '5004';
	    survey10.answerNumber = '5005';
	    survey10.answerText = 'Yes';
	    surveyList.Add(survey10);
	    
		GNE_PatPers_IU_SurveyInfo survey11= new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	    survey11.questionNumber = '5005';
	    survey11.answerNumber = '5005';
	    survey11.answerText = 'Yes';
	    surveyList.Add(survey11);
	    
		GNE_PatPers_IU_SurveyInfo survey12= new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	    survey12.questionNumber = '5006';
	    survey12.answerNumber = '5005';
	    survey12.answerText = 'Yes';
	    surveyList.Add(survey12);
	    
		GNE_PatPers_IU_SurveyInfo survey13= new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	    survey13.questionNumber = '5007';
	    survey13.answerNumber = '5005';
	    survey13.answerText = 'Yes';
	    surveyList.Add(survey13);
           
		if(patient.pat_dob != null)
        {
	        String patyear = String.valueof(patient.pat_dob).substring(0,4);
	        GNE_PatPers_IU_SurveyInfo survey8 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	        survey8.questionNumber = '1005';
	        survey8.answerNumber = '1117';
	        survey8.answerText = patyear ;
	        surveyList.Add(survey8);
        }
                
        GNE_PatPers_IU_SurveyInfo survey9= new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey9.questionNumber = '4';
        survey9.answerNumber = '23';
        survey9.answerText = 'Actemra';
        surveyList.Add(survey9);
             
        GNE_PatPers_IU_SurveyInfo survey14= new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey14.questionNumber = '103';
        if (mHist.Product_gne__c=='Actemra Subcutaneous') 
        {
            survey14.answerNumber = '151';
            survey14.answerText = 'Actemra Injection';
        } 
        else 
        {
            survey14.answerNumber = '106';
            survey14.answerText = 'Actemra IV Infusion';
        }
        surveyList.Add(survey14);

        if (mHist.Date_of_first_treatment_gne__c!=null || mHist.Anticipated_Date_of_Treatment_gne__c!=null)
        {
            GNE_PatPers_IU_SurveyInfo survey15 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey15.questionNumber = '200';
            survey15.answerNumber = '157' ;
            if (mHist.Date_of_first_treatment_gne__c!=null )
            {
                survey15.answerText = mHist.Date_of_first_treatment_gne__c.format();
            }
            if (mHist.Anticipated_Date_of_Treatment_gne__c!=null )
            {
                survey15.answerText = mHist.Anticipated_Date_of_Treatment_gne__c.format();
            }
            surveyList.Add(survey15);
        }

        return surveyList;
    }   
}