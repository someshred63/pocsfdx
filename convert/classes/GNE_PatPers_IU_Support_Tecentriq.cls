public virtual class GNE_PatPers_IU_Support_Tecentriq extends GNE_PatPers_IU_Support_Base
{
    public override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
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

        // question 3
        if (patient.pat_con_relationship_to_patient!=null) 
        {
            Map<String,String> mapRel = new Map<String, String> {
                'Caregiver' => '101',
                'Child' => '102',
                'Family' => '103',
                'Friend' => '104',
                'Legal Guardian' => '105',
                'Parent' => '107',
                'Spouse' => '108',
                'Self' => '109' 
            };

            if (mapRel.containsKey(patient.pat_con_relationship_to_patient))
            {
                GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                survey3.questionNumber = '3';
                survey3.answerNumber = mapRel.get(patient.pat_con_relationship_to_patient);
                survey3.answerText = patient.pat_con_relationship_to_patient;
                surveyList.Add(survey3);
            }
        }

        // question 1
        if (segmentID=='4711') 
        {
            GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey1.questionNumber = '1';
            survey1.answerNumber = '1';
            survey1.answerText = 'mUC';
            surveyList.Add(survey1);
        }
        else if (segmentID=='4712')
        {
            GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey1.questionNumber = '1';
            survey1.answerNumber = '48';
            survey1.answerText = 'NSCLC';
            surveyList.Add(survey1);
        }
        
        // question 101
        Map<String, String> mapQ101 = new Map<String, String> {
            'Stage 0 / Dukes A' => '111',
            'Stage IA' => '112',
            'Stage IB' => '113',
            'Stage IIA (Early Local Disease) / Dukes B' => '114',
            'Stage IIB (Early Local Disease) / Dukes B' => '115',
            'Stage IIIA (Advanced Local Disease) / Dukes C' => '116',
            'Stage IIIB (Advanced Local Disease) / Dukes C' => '117',
            'Stage IIIC (Advanced Local Disease) / Dukes C' => '118',
            'Stage IV (Advanced Metastatic Disease) / Dukes D' => '119'
        };

        GNE_PatPers_IU_SurveyInfo survey101 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey101.questionNumber = '101';

        if (mHist.Tumor_Staging_gne__c!=null && mapQ101.containsKey(mHist.Tumor_Staging_gne__c))
        {
            survey101.answerNumber = mapQ101.get(mHist.Tumor_Staging_gne__c);
            survey101.answerText = mHist.Tumor_Staging_gne__c;
        }
        else
        {
            survey101.answerNumber = '110';
            survey101.answerText = 'Not Provided';
        }
        surveyList.Add(survey101);


       // question 102
        Map<String, String> mapQ102 = new Map<String, String> {
            'Abateacept (Orencia)' => '120',
            'Chemotherapy' => '121',
            'DMARDS' => '122',
            'Enbrel' => '123',
            'Herceptin' => '124',
            'Hormone Therapy' => '125',
            'Humira' => '126',
            'Immuno Therapy' => '127',
            'Methotrexate' => '128',
            'None' => '129',
            'NSAID' => '130',
            'Other' => '131',
            'Post Bone Marrow Transplant' => '132',
            'Radiation' => '133',
            'Radio Labeled Antibodies' => '134',
            'Remicaide' => '135',
            'Rituxan' => '136',
            'Surgery' => '137',
            'Watch and Wait' => '138'
        };

        if (mHist.Previous_Therapy_Regimens_gne__c!=null)
        {
            for (String pt : mHist.Previous_Therapy_Regimens_gne__c.split(';'))
            {
                if (mapQ102.containsKey(pt))
                {
                    GNE_PatPers_IU_SurveyInfo survey102 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                    survey102.questionNumber = '102';
                    survey102.answerNumber = mapQ102.get(pt);
                    survey102.answerText = pt;
                    surveyList.Add(survey102);
                }
            }
        }

       // question 103
        Map<String, String> mapQ103 = new Map<String, String> {
            '5-FU/Leucovorin' => '139',
            'Bone Marrow Transplant' => '140',
            'Capecitabine' => '141',
            'Carboplatin' => '142',
            'Chemotherapy' => '143',
            'Cisplatin (platinol)' => '144',
            'Clinical Trial' => '145',
            'Docetaxel (Taxotere' => '146',
            'FOLFOX (Oxaliplatin, 5-FU/LV)' => '147',
            'Herceptin' => '148',
            'Hormone Therapy' => '149',
            'IFL (Irinotecan, 5-FU/LV) "Saltz"' => '150',
            'Immunotherapy' => '151',
            'Irinotecan' => '152',
            'Irinotecan (Camptosar, CPT-11)' => '153',
            'None' => '154',
            'Not Provided' => '155',
            'Other' => '156',
            'Oxaliplatin' => '157',
            'Paclitaxel (taxol)' => '158',
            'Perjeta' => '159',
            'Platinum Agents' => '160',
            'Radiation' => '161',
            'Rituxan' => '162',
            'Single Agent' => '163',
            'Surgery' => '164',
            'Tamoxifen' => '165',
            'Tarceva' => '166',
            'XELIRI (Capecitabine, Irinotecan)' => '167',
            'Xeloda' => '168',
            'Xeloda (Capecitabine)' => '169',
            'XELOX (Oxaliplatin, Capecitabine)' => '170'
        };

        if (mhist.Concurrent_Therapy_Regimens_gne__c!=null)
        {
            for (String ct : mhist.Concurrent_Therapy_Regimens_gne__c.split(';'))
            {
                if (mapQ103.containsKey(ct))
                {
                    GNE_PatPers_IU_SurveyInfo survey103 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                    survey103.questionNumber = '103';
                    survey103.answerNumber = mapQ103.get(ct);
                    survey103.answerText = ct;
                    surveyList.Add(survey103);
                }
            }
        }

        // question 104
        Map<String, String> mapQ104 = new Map<String, String> {
            'Yes' => '171',
            'No' => '172'
        };

        if (mhist.Has_Treatment_Started__c!=null && mapQ104.containsKey(mhist.Has_Treatment_Started__c))
        {
            GNE_PatPers_IU_SurveyInfo survey104 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey104.questionNumber = '104';
            survey104.answerNumber = mapQ104.get(mHist.Has_Treatment_Started__c);
            survey104.answerText = mHist.Has_Treatment_Started__c;
            surveyList.Add(survey104);
        }

        // question 105
        Map<String, String> mapQ105 = new Map<String, String> {
            'Yes' => '173',
            'No' => '174'
        };

        if (mHist.Has_Treatment_Started__c!=null && mapQ105.containsKey(mHist.Has_Treatment_Started__c))
        {
            GNE_PatPers_IU_SurveyInfo survey105 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey105.questionNumber = '105';
            survey105.answerNumber = mapQ105.get(mHist.Has_Treatment_Started__c);
            survey105.answerText = mHist.Has_Treatment_Started__c;
            surveyList.Add(survey105);
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