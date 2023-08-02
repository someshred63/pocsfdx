public virtual class GNE_PatPers_IU_Support_1974 extends GNE_PatPers_IU_Support_Base
{
	public virtual override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
    {
   
		String ins_primaryType;
		String ins_primaryName;
		String ins_primaryNumber;
		String ins_secondaryType;
		String ins_secondaryName;
		String ins_secondaryNumber;
		String phone = '';

		// from address table (address_vod)   
		String phys_DEA;
		String phys_TAX_ID;
		String phys_License;
		String phys_Medicare;
		String phys_Medicaid;
		String phys_UPIN;
     
	    String phys_ME = casePractice.Case_Treating_Physician_gne__r.ME__c;
	    String phys_STARS_ID = casePractice.Case_Treating_Physician_gne__r.STARS_ID_gne__c;
	    String phys_firstName = casePractice.Case_Treating_Physician_gne__r.firstName;
	    String phys_lastName = casePractice.Case_Treating_Physician_gne__r.LastName;
	    String phys_fullName = phys_firstname + ' ' + phys_lastName;
	    String phys_address1 = addyPractice.Name;
	    String phys_city = addyPractice.City_vod__c;
	    String phys_state = addyPractice.State_vod__c; 
	    String phys_zip = addyPractice.Zip_vod__c;   
	    String caseID = casePractice.Id;
 
 
	    if ((profile != null) && (profile.size() >= 1))
	    {
	    	for (integer c=0;c<profile.size();c++)
	    	{
	  			if ((profile[c].ID_License_Type_gne__c != null) && (profile[c].ID_License_Type_gne__c != ''))
	  			{ 
			    	if (profile[c].ID_License_Type_gne__c.Contains('DEA'))
			      	{          
			     		phys_DEA = profile[c].ID_License_gne__c; 
			  		}
          			else if (profile[c].ID_License_Type_gne__c.Contains('Tax ID'))
          			{          
		            	phys_TAX_ID = profile[c].ID_License_gne__c; 
		          	}
		          	else if (profile[c].ID_License_Type_gne__c.Contains('State License'))
          			{          
            			phys_License = profile[c].ID_License_gne__c;
          			}
          			else if (profile[c].ID_License_Type_gne__c.Contains('Medicare'))
          			{          
            			phys_Medicare = profile[c].ID_License_gne__c;
          			}
          			else if (profile[c].ID_License_Type_gne__c.Contains('State Medicaid'))
          			{          
           				phys_Medicaid = profile[c].ID_License_gne__c;
          			}
          			else if (profile[c].ID_License_Type_gne__c.Contains('UPIN'))
          			{          
            			phys_UPIN = profile[c].ID_License_gne__C;        
          			}
        		}
      		}   
   		}
                                                                                                                         
	    if (insPrimary != null)
	    {
			String temp = insPrimary.Plan_Product_type_gne__c;
          	phone = '';
          	String typeIns = 'None';
          	if (addyPrim != null) 
          	{
             	phone = addyPrim.Phone_vod__c;
          	}
          	if (temp != null)
          	{
	            if ((temp.contains('HMO')) || (temp.contains('EPO'))) 
	            {
                	typeIns = 'HMO/EPO';
	            }
	            else if (temp.contains('PPO')) 
	            {
                	typeIns = 'PPO';
            	}
            	else if (temp.contains('POS')) 
            	{
                	typeIns = 'POS';
            	}
            	else if (temp.contains('Indemnity')) 
            	{
                	typeIns = 'Indemnity';
            	}
            	else if (temp.contains('Medicare')) 
            	{
	                typeIns = 'Medicare';
    	        }
            }
          	if (typeIns != null)
            {
                ins_primaryType = typeIns;
                ins_primaryName = insPrimary.Payer_gne__r.Name;
                ins_primaryNumber = phone;
            } 
		}          
      	if (insSecondary != null)
      	{
			String temp = insSecondary.Plan_Product_type_gne__c;
  			phone = '';
  			String typeIns = 'None';
  			if (addySecondary != null) 
  			{
     			phone = addySecondary.Phone_vod__c;
  			}
			if (temp != null)
  			{
				if ((temp.contains('HMO')) || (temp.contains('EPO'))) 
				{
                	typeIns = 'HMO/EPO';
				}
				else if (temp.contains('PPO')) 
				{
		        	typeIns = 'PPO';
				}
				else if (temp.contains('POS')) 
				{
                	typeIns = 'POS';
				}
				else if (temp.contains('Indemnity'))
				{
                	typeIns = 'Indemnity';
				}
				else if (temp.contains('Medicare')) 
				{
                	typeIns = 'Medicare';
				}
            }
          	if (typeIns != null)
            {
                ins_SecondaryType = typeIns;
                ins_SecondaryName = insSecondary.Payer_gne__r.Name;
                ins_SecondaryNumber = phone;
            } 
		}          

        List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
        System.debug('In Support_1974');
        GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey1.questionNumber = '290';
        survey1.answerNumber = '750';
        survey1.answerText = 'Yes';
        surveyList.Add(survey1);
        if (ins_PrimaryName != null)
        {
            GNE_PatPers_IU_SurveyInfo survey2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey2.questionNumber = '961';
            if (ins_PrimaryType.equals('None')) 
            {
                survey2.answerNumber = '2900';
            } 
            else if (ins_PrimaryType.equals('HMO/EPO')) 
            {
                survey2.answerNumber = '2896';
            } 
            else if (ins_PrimaryType.equals('PPO')) 
            {
                survey2.answerNumber = '2897';
            } 
            else if (ins_PrimaryType.equals('POS')) 
            {
                survey2.answerNumber = '2898';
            } 
            else if (ins_PrimaryType.equals('Indemnity')) 
            {
                survey2.answerNumber = '2899';
            } 
            else if (ins_PrimaryType.equals('Medicare')) 
            {
                survey2.answerNumber = '2901';
            }
            surveyList.Add(survey2);
    
            if (!survey2.answerNumber.equals('2900'))
            {
                GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                survey3.questionNumber = '962';
                survey3.answerNumber = '2902';
                survey3.answerText = ins_PrimaryName;
                surveyList.Add(survey3);
                
                GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                survey4.questionNumber = '963';
                survey4.answerNumber = '2903';
                survey4.answerText = ins_PrimaryNumber;
                surveyList.Add(survey4);
            }
        }   
        if (ins_SecondaryType != null)
        {            
            GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey5.questionNumber = '969';
            if (ins_SecondaryType.equals('None')) 
            {
                survey5.answerNumber = '2915';
            } 
            else if (ins_SecondaryType.equals('HMO/EPO')) 
            {
                survey5.answerNumber = '2911';
        	}
        	else if (ins_SecondaryType.equals('PPO')) 
        	{
                survey5.answerNumber = '2912';
            } 
            else if (ins_SecondaryType.equals('POS')) 
            {
                survey5.answerNumber = '2913';
            } 
            else if (ins_SecondaryType.equals('Indemnity')) 
            {
                survey5.answerNumber = '2914';
            } 
            else if (ins_SecondaryType.equals('Medicare')) 
            {
                survey5.answerNumber = '2916';
            }
            surveyList.Add(survey5);            
        
            if (! survey5.answerNumber.equals('2915'))
            {
                GNE_PatPers_IU_SurveyInfo survey6 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                survey6.questionNumber = '970';
                survey6.answerNumber = '2917';
                survey6.answerText = ins_secondaryName;
                surveyList.Add(survey6);
                
                GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
                survey7.questionNumber = '971';
                survey7.answerNumber = '2918';
                survey7.answerText = ins_SecondaryNumber;
                surveyList.Add(survey7);
            }
        }
        GNE_PatPers_IU_SurveyInfo survey8 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey8.questionNumber = '979';
        if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9'
                && mHist.ICD9_Code_1_gne__r.Name.contains('362.52')) 
        {
        	survey8.answerNumber = '2932';
        }
        else if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-10'
                && mHist.ICD9_Code_1_gne__r.Name.contains('H35.32')) 
        {
            survey8.answerNumber = '2932';
        }
        else
        {
            survey8.answerNumber = '2933';
          
            GNE_PatPers_IU_SurveyInfo survey9 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey9.questionNumber = '980';
            survey9.answerNumber = '2934';
            survey9.answerText = mHist.ICD9_Code_1_gne__r.ICD9_Code_gne__c;
            surveyList.Add(survey9);
        }
        surveyList.Add(survey8);
        if ((mHist.Eye_Affected_gne__c != null) && (mHist.Eye_Affected_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey10 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey10.questionNumber = '981';
            if (mHist.Eye_Affected_gne__c.equals('Both')) 
            {
                survey10.answerNumber = '2937';
            } 
            else if (mHist.Eye_Affected_gne__c.equals('Left')) 
            {
                survey10.answerNumber = '2936';
        	} 
        	else if (mHist.Eye_Affected_gne__c.equals('Right')) 
        	{
                survey10.answerNumber = '2935';
            } 
            else 
            {
                survey10.pass = false;
            }
            surveyList.Add(survey10);
        }   
        if ((mHist.Eye_Being_treated_gne__c != null) && (mHist.Eye_Being_treated_gne__c != ''))
        { 
            GNE_PatPers_IU_SurveyInfo survey11 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey11.questionNumber = '982';
            if (mHist.Eye_Being_treated_gne__c.equals('Both')) 
            {
                survey11.answerNumber = '2940';
            } 
            else if (mHist.Eye_being_treated_gne__c.equals('Left')) 
            {
                survey11.answerNumber = '2939';
            } 
            else if (mHist.Eye_being_treated_gne__c.equals('Right')) 
            {
                survey11.answerNumber = '2938';
            } 
            else
            {
                survey11.pass = false;
            }
            surveyList.Add(survey11);
        }
        if ((mHist.VA_eye_being_treated_gne__c != null) && (mHist.VA_eye_being_treated_gne__c != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey12 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey12.questionNumber = '983';
            survey12.answerNumber = '2941';
            survey12.answerText = mHist.VA_eye_being_treated_gne__c;
            surveyList.Add(survey12);
        }
            
        GNE_PatPers_IU_SurveyInfo survey13 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey13.questionNumber = '984';
        if (mHist.Date_of_First_treatment_gne__c != null)
        {
            if (mHist.Date_of_First_treatment_gne__c < Date.today())
            {
                survey13.answerNumber = '2942';
            }
            else
            {
                survey13.answerNumber = '2943';
            }
        }
        else
        {
            survey13.pass = false;
        }
        surveyList.Add(survey13);
        
        GNE_PatPers_IU_SurveyInfo survey14 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey14.questionNumber = '985';
        if (mHist.Date_of_First_treatment_gne__c != null)
        {
            survey14.answerNumber = '2944';
            survey14.answerText = mHist.Date_of_First_treatment_gne__c.format();
        }
        else
        {
            survey14.pass = false;
        }
        surveyList.Add(survey14);
        if ((phys_lastName != null) && (phys_lastName != ''))
        {          
            GNE_PatPers_IU_SurveyInfo survey15 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey15.questionNumber = '999';
            survey15.answerNumber = '2960';
            survey15.answerText = phys_firstName + ' ' + phys_lastName;
            surveyList.Add(survey15);
        }
        if ((phys_DEA != null) && (phys_DEA != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey16 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey16.questionNumber = '987';
            survey16.answerNumber = '2948';
            survey16.answerText = phys_DEA;
            surveyList.Add(survey16);
        }
        if ((phys_TAX_ID != null) && (phys_TAX_ID != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey17 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey17.questionNumber = '988';
            survey17.answerNumber = '2949';
            survey17.answerText = phys_TAX_ID;
            surveyList.Add(survey17);
        }                
        if ((phys_License != null) && (phys_License != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey18 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey18.questionNumber = '989';
            survey18.answerNumber = '2950';
            survey18.answerText = phys_License;
            surveyList.Add(survey18);
        }
        if ((phys_Medicare != null) && (phys_Medicare != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey19 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey19.questionNumber = '990';
            survey19.answerNumber = '2951';
            survey19.answerText = phys_Medicare;
            surveyList.Add(survey19);
        }
        if ((phys_Medicaid != null) && (phys_Medicaid != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey20 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey20.questionNumber = '1000';
            survey20.answerNumber = '2961';
            survey20.answerText = phys_Medicaid;
            surveyList.Add(survey20);
        }
        if ((phys_UPIN != null) && (phys_Medicaid != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey21 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey21.questionNumber = '991';
            survey21.answerNumber = '2952';
            survey21.answerText = phys_UPIN;
            surveyList.Add(survey21);
        }
        if ((phys_Address1 != null) && (phys_Address1 != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey22 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey22.questionNumber = '992';
            survey22.answerNumber = '2953';
            survey22.answerText = phys_Address1;
            surveyList.Add(survey22);
        }
        if ((phys_city != null) && (phys_city != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey23 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey23.questionNumber = '993';
            survey23.answerNumber = '2954';
            survey23.answerText = phys_City;
            surveyList.Add(survey23);
        }
        if ((phys_state != null) && (phys_state != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey24 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey24.questionNumber = '994';
            survey24.answerNumber = '2955';
            survey24.answerText = phys_State;
            surveyList.Add(survey24);
        }
        if ((phys_zip != null) && (phys_zip != ''))
        {
            GNE_PatPers_IU_SurveyInfo survey25 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey25.questionNumber = '995';
            survey25.answerNumber = '2956';
            survey25.answerText = phys_Zip;
            surveyList.Add(survey25);           
        }
        return surveyList;
	}
}