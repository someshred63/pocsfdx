/// Class to support Insert and Update Trigger on Patient_Program object
/// Patient Persistency Enrollment -- CMGT-INT-05
/// Class sets up staging tables for transaction and survey data
/// Created / By: 11/26/2008 -- Jim Whitmoyer (INF)
/// Modified / By: 01/20/09 -- Jim Whitmoyer (INF) - segment id verification code
/// modified 0324 & 25 2008 -- jw -- error handling and exception throwing support fix
/// modified 04012009 - NuSpin product added.  -- jw
/// modified 04022009 - cleaned up error on segment failure return
/// modified 05272010 SKM- Added ICD9 Code filters for different segments-T-352
/// modified 08102010 SKM- Added ICD9 Code filters for different segments-T-189


public class GNE_PatPers_InsertUpdate_Trigger_Support
{    
	public static List<String> shipmentSurveyProducts=new List<String> { 'Erivedge', 'Zelboraf', 'Tarceva', 'Cotellic'};
	
	
    public boolean doNotProcessICD9Incorrect = false;    
    
    /**
     * This method creates survey staging records and inserts them into the database.
     *
     * @param transactionId - transaction ID of a patient program
     * @param internalTransactionId = ID of the transaction staging file
     * @param segmentId - value obtained from method GNE_PatPers_InsertUpdate_Trigger_Support.getSegmentIDByProduct basing on the product
     * @param patientId
     * @param mHist - medical history object
     *
     * @return the number of created survey staging records 
     */
    public Integer surveyStart(String transactionID, String internalTransactionID, String segmentID, String patientID, Medical_History_gne__c mHist,
                                Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary, Address_vod__c addyPrim, Insurance_gne__c insSecondary,
                                Address_vod__c addySecondary, ProfileID_License_gne__c[] profileList, String preferredMethodOfContact, Date productShipDate)
    {
        Integer recordsApplied = 0;
        GNE_PatPers_IU_support_Helpers pHelpers = new GNE_PatPers_IU_Support_Helpers();    
        
        GNE_PatPers_IU_PatientAndAddressInfo patient = pHelpers.GetPatientAndAddressInfo(patientId);
        
        // get the transaction staging file by ID
        Transaction_file_Staging_gne__c transRec = pHelpers.GetTransactionFileStagingRecord(internalTransactionID);
        
        List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
        
        // If medical history is not empty, get a survey list using an appropriate interface
        if (mHist != null)
        {
        	Type handlerType = Type.forName('GNE_PatPers_IU_Support_' + segmentId);
	        if (handlerType != null) 
	        {
	        	try 
	        	{
	        		GNE_PatPers_IU_Support_Base support = (GNE_PatPers_IU_Support_Base)handlerType.newInstance();
	        		surveyList = support.getSurveyList(transactionID, segmentID, patientID, patient, mHist, casePractice, addyPractice, 
	        						   insPrimary, addyPrim, insSecondary, addySecondary, profileList, productShipDate, preferredMethodOfContact);
	        	}
	        	catch (GNE_PatPers_Exception ex)
                {
                    throw new GNE_PatPers_Exception(ex.getMessage());   
                }
	        }
	        else
	        {
	        	throw new GNE_PatPers_Exception('Segment class not found: ' + segmentId);
	        }
        }

        // if at least survey has been successfully obtained
        if ((surveyList != null) && (surveyList.size() >= 1))
        {
            // remove duplicates from the list
            List<GNE_PatPers_IU_SurveyInfo> cleanList = (new GNE_PatPers_IU_Utility()).killDuplicates(surveyList);
            
            // create a list of survey staging objects
            List<Survey_Staging_gne__c> listSurvey = new List<Survey_Staging_gne__c>();
            
            // iterate through surveys
            for (integer surveyCounter = 0; surveyCounter < cleanList.size(); surveyCounter++)
            {
                if (cleanList[surveyCounter].pass)
                {
                    Survey_staging_gne__c survey = new Survey_staging_gne__c();
                    survey.Transaction_File_Staging_gne__c = transRec.ID;
                    survey.Transaction_ID_gne__c = transactionID;
                    survey.question_number_gne__c = cleanList[surveyCounter].questionNumber;
                    survey.answer_number_gne__c = cleanList[surveyCounter].answerNumber;
                    survey.Answer_Text_gne__c = cleanList[surveyCounter].answerText;
                    listSurvey.Add(survey);
                }
            } // for loop = survey list
            
            recordsApplied = listSurvey.size();
            
            try
            {
                // insert created survey staging objects
                Database.SaveResult[] saveResult = Database.Insert(listSurvey, false);
            }
            catch (DMLException ex)
            {
                throw new GNE_PatPers_Exception(ex.getMessage());
            } 
        } 
        // if there is no survey data
        else
        {
            recordsApplied = 0;
        }            

        if (doNotProcessICD9Incorrect == true)
        {
            recordsApplied = -1;
        }
        system.debug(recordsApplied);
        return  recordsApplied;
    }

	public String getSegmentIDByProduct(String brandName, GNE_PatPers_IU_PatientAndAddressInfo patient, Medical_History_gne__c mHist)
    {
        String segmentId = '0';
                	
        if (brandName != null) 
        {
        	Boolean patientAgeCondition = false;
        	Boolean icd9Condition = false;
        	List<Patient_Program_Config__c> patientProgramConfigList = [SELECT id, Patient_Min_Age__c, Patient_Max_Age__c, Segment_ID__c,
        																																	(SELECT Diagnosis_Code__c 
        																																		FROM Patient_Program_Diagnosis_Codes__r 
        																																	) 
																															        	FROM Patient_Program_Config__c
																															        	WHERE Product__c = :brandName];
        	if(patientProgramConfigList != null)
        	{
	        	for(Patient_Program_Config__c ppConfig : patientProgramConfigList)
	        	{
	        		if(ppConfig.Patient_Min_Age__c != null || ppConfig.Patient_Max_Age__c != null)
	        		{
	        			patientAgeCondition = getPatientAgeCondition(patient.pat_Age, ppConfig.Patient_Min_Age__c, ppConfig.Patient_Max_Age__c);
	        		}
	        		else
	        		{
	        			patientAgeCondition = true;	
	        		}
	        		if(patientAgeCondition)
	        		{
	        			//If there are no Diagnosis Code Configs for this Patient Program Config, it means there is no need for checking further for MH Diagnosis code match
	        			if(ppConfig.Patient_Program_Diagnosis_Codes__r.IsEmpty())
	        			{
	        				segmentId =  ppConfig.Segment_ID__c;
	        				break;
	        			}
	        			//Check for Diagnosis Code matches
	        			if(mHist.ICD9_Code_1_gne__c !=null)
	        			{
	        				//ICD9_Code_1_gne__r.icd9_code_gne__c
	        				for(Patient_Program_Diagnosis_Code__c ppDiagnosisCode :ppConfig.Patient_Program_Diagnosis_Codes__r)
		        			{
		        				 if(mHist.ICD9_Code_1_gne__c == ppDiagnosisCode.Diagnosis_Code__c)
		        				 {
		        				 		segmentId =  ppConfig.Segment_ID__c;
	        							break;
		        				 }
		        			}
	        			}//end check on ICD1 on MH
	        			
	        			
	        		}//end check on patientAgeCondition
	        	}
        	}//end null check on patientProgramConfigList
        }  
        return segmentId;
    }
    
    private Boolean getPatientAgeCondition(Double patientAge, Decimal ageMin, Decimal ageMax)
    {
    	Boolean flag = false;
    	
    	if(ageMin != null && ageMax != null)
		{
			if(patientAge >= double.valueOf(ageMin) && patientAge < double.valueOf(ageMax))
			{
				flag = true;
			}
		}
		else if(ageMin != null && patientAge >= double.valueOf(ageMin))
		{
			flag = true;
		}
		else if(ageMax != null && patientAge < double.valueOf(ageMax))
		{
			flag = true;
		}
    	return flag;
    }
	    
    /**
     * Utility method used by Shipment and Fulfillment triggers, method looks for related Patient Program records for
	 *	products which have post-shipment surveys and sets the reprocess flag for those records
	 *	which will force the generation of additional surveys 
     */
    public static void reprocessShippedPatientPrograms(Map<String, Date> mapCaseShipDates)
    {
		// if any changes were detected
		if (!mapCaseShipDates.IsEmpty())
		{
			Map<String, Date> mapPatProdComboDate=new Map<String, Date>();
			Set<String> setPatIds=new Set<String>();
	
			// map of patient to affected products		
			for (Case cs : [SELECT Id, Patient_gne__c, Product_gne__c
									FROM Case 
									WHERE Id IN :mapCaseShipDates.keyset() 
										AND Product_gne__c IN :shipmentSurveyProducts])
			{
				mapPatProdComboDate.put(cs.Patient_gne__c + '' + cs.Product_gne__c, mapCaseShipDates.get(cs.Id));
				setPatIds.add(cs.Patient_gne__c);
			}
			
			
			// track patient/product combinations already sent		
			Set<String> ppProcessedFlags=new Set<String>();	
			
			// load any potentially affected Patient Programs
			List<Patient_Program_gne__c> lstPatProg=[SELECT Id, Patient_gne__c, Program_Name_gne__c, 
					Program_Name_gne__r.Brand_gne__c, Reprocess_Flag_gne__c, Product_Ship_Date_gne__c,
					(SELECT Id FROM R00NR0000000Vb2IMAS) 
				FROM Patient_Program_gne__c 
				WHERE Program_Name_gne__r.Patient_Program_Processing_Required_gne__c=true 
						AND Patient_gne__c IN :setPatIds 
						AND Program_Name_gne__r.Brand_gne__c IN :shipmentSurveyProducts
						AND Product_Ship_Date_gne__c=null
				ORDER BY CreatedDate DESC, Id DESC];
					
			for (Patient_Program_gne__c pp : lstPatProg)	
			{
				String ppCombo=pp.Patient_gne__c + '' + pp.Program_Name_gne__r.Brand_gne__c;
				// set the flag for:
				// 		matching patient, brand and only no more than one Transaction File records
				if (mapPatProdComboDate.containsKey(ppCombo))
				{
					// if there are no files waiting to go
					if (!ppProcessedFlags.contains(ppCombo) && pp.R00NR0000000Vb2IMAS__r.IsEmpty())
					{
						// remember it
						ppProcessedFlags.add(ppCombo);
						// flag it
						pp.Reprocess_Flag_gne__c=true;
					}
					// mark all of them as shipped
					pp.Product_Ship_Date_gne__c=mapPatProdComboDate.get(ppCombo);
				}
			}
			update lstPatProg;			
		}    	
    }
}