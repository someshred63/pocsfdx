public class GNE_PatPers_IU_Support_4709  extends GNE_PatPers_IU_Support_Base
{
    public virtual override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
    {
    	GNE_PatPers_IU_Utility util = new GNE_PatPers_IU_Utility();
	    List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();

	    // question 290
	    GNE_PatPers_IU_SurveyInfo survey290 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	    survey290.questionNumber = '290';
        survey290.answerNumber = '750';
        survey290.answerText = 'Yes';
        surveyList.Add(survey290);

        // question 8
        if (mHist.OCRE_Current_Treatment_gne__c != null) 
        {
        	Set<String> setTrtmt = new Set<String>();
        	setTrtmt.addAll(mHist.OCRE_Current_Treatment_gne__c.split(';'));

        	Map<String, String> mapTrmt2Ans = new Map<String, String> {
				'Aubagio' => '35',
				'Avonex' => '36',
				'Betaseron' => '37',
				'Copaxone' => '38',
				'Extavia' => '39',
				'Gilenya' => '40',
				'Lemtrada' => '41',
				'Novantrone' => '42',
				'Plegridy' => '43',
				'Rebif' => '44',
				'Tecfidera' => '45',
				'Tysabri' => '46'
        	};

 
        	for (String trmt : setTrtmt) 
        	{
	            if (mapTrmt2Ans.containsKey(trmt))
	            {
	                GNE_PatPers_IU_SurveyInfo survey8 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	                survey8.questionNumber = '8';
	                survey8.answerNumber = mapTrmt2Ans.get(trmt);
                    survey8.answerText = trmt;
	                surveyList.Add(survey8);
	            }

	            if (trmt=='Other') 
	            {
	                GNE_PatPers_IU_SurveyInfo survey8 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	                survey8.questionNumber = '8';
                    survey8.answerNumber = '47';
	                survey8.answerText = mHist.OCRE_Other_Treatment_gne__c;
	                surveyList.Add(survey8);

	            }
        	}
        }

        // question 4
        if (mHist.OCRE_Indication_gne__c == 'PPMS') 
        {
	    	GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	    	survey4.questionNumber = '4';
        	survey4.answerNumber = '8';
            survey4.answerText = 'Primary Progressive Multiple Sclerosis (PPMS)';
        	surveyList.Add(survey4);
    	} 
    	else if (mHist.OCRE_Indication_gne__c == 'RMS') 
        {
	    	GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
	    	survey4.questionNumber = '4';
        	survey4.answerNumber = '23';
            survey4.answerText = 'Relapsing Multiple Sclerosis (RMS)';
        	surveyList.Add(survey4);
    	}

    	// question 3
    	if (patient.pat_con_relationship_to_patient!=null) 
    	{
    		Map<String,String> mapRel = new Map<String, String> {
    			'Caregiver' => '28',
				'Child' => '29',
				'Family' => '30',
				'Friend' => '31',
				'Legal Guardian' => '32',
				'Parent' => '33',
				'Spouse' => '34',
				'Self' => '5' };

			if (mapRel.containsKey(patient.pat_con_relationship_to_patient))
			{
		    	GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
		    	survey3.questionNumber = '3';
	        	survey3.answerNumber = mapRel.get(patient.pat_con_relationship_to_patient);
                survey3.answerText = patient.pat_con_relationship_to_patient;
	        	surveyList.Add(survey3);
			}
    	}

    	// question 1504
        if (casePractice.OK_to_Contact_Patient_gne__c != null)
        {
            GNE_PatPers_IU_SurveyInfo survey1504 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey1504.questionNumber = '1504';
            if(String.valueOf(casePractice.OK_to_Contact_Patient_gne__c).equals('Yes'))
            {
               survey1504.answerNumber = '4819';
            }
            else if(String.valueOf(casePractice.OK_to_Contact_Patient_gne__c).equals('No'))
            {
               survey1504.answerNumber = '4820';
            }
            survey1504.answerText = String.valueOf(casePractice.OK_to_Contact_Patient_gne__c);
            surveyList.Add(survey1504);
        }
  
        // question 9001
        for (Patient_Program_gne__c pp : [SELECT Ok_to_Leave_Message_gne__c FROM Patient_Program_gne__c WHERE Transaction_ID__c=:transactionID])
        {
            if (pp.Ok_to_Leave_Message_gne__c!=null)
            {
                GNE_PatPers_IU_SurveyInfo survey9001 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                survey9001.questionNumber = '9001';
                survey9001.answerNumber = (pp.Ok_to_Leave_Message_gne__c == 'Yes' ? '1000' : '2000');
                survey9001.answerText = pp.Ok_to_Leave_Message_gne__c;
                surveyList.Add(survey9001);
                break;
            }
        }

        return surveyList;
    }
}