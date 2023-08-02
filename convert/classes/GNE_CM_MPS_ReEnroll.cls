public virtual without sharing class GNE_CM_MPS_ReEnroll 
{	
	public enum PERGenerationType {FROM_CASE, FROM_FORM}
	
	public static final Map<String, String> INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE = new Map<String, String>{
        'EPO' => 'HMO/EPO',
        'PPO' => 'PPO',
        'HMO' => 'HMO/EPO',
        'POS' => 'POS',
        'Indemnity' => 'Indemnity',
        'Managed Medicaid' => 'Medicare/Medicaid',
        'MA-PD' => 'Medicare/Medicaid',
        'Medicare Part A' => 'Medicare/Medicaid',
        'Medicare Part B' => 'Medicare/Medicaid',
        'Medicare Advantage (Part C)' => 'Medicare/Medicaid',
        'Medicare Supplemental' => 'Medicare/Medicaid',
        'Prescription' => 'PBM'                     
    };	
	
	protected PERGenerationType genType { get; set; }
	
	// mapping form types names to class names
	public static Map<String, String> form2ClassMap = new Map<String, String>{'BioOncology Infused Products' => 'BioOnc_Infu', 'BioOncology Oral Products' => 'BioOnc_Oral', 'PEGASYS' => 'Pegasys'};
	
	protected Boolean isIntake { get; set; }

	public String mpsRegistrationIdFromBatch { get; set; }
	
	/**
	 * Utility used by CM Intake .
	 * 
	 * The method rewrites mostly patient specific data from the case into the PER.
	 * @param patientId the Patient Id
	 * @param cmForm the Intake form name
	 */
	public static Patient_Enrollment_Request_gne__c reEnrollPatient(String patientId, String cmForm) 
	{
		Patient_Enrollment_Request_gne__c perRet=null;
		
		// search for a case with this MPS form
		List<Case> lstCases=[SELECT Id FROM Case 
								WHERE Patient_gne__c=:patientId 
									AND Medical_History_gne__r.SMN_Form_gne__c=:cmForm 
								ORDER BY CreatedDate DESC LIMIT 1];
		
		if (!lstCases.IsEmpty())
		{
			perRet=reEnrollForm(lstCases[0].Id, false);
		}

		return perRet;
	}
		
	
	//Re-enroll method to be used to generate PERs from BR submissions that are submitted via 'Submit All'
	public static Patient_Enrollment_Request_gne__c reEnrollCase(String caseId, String mpsRegistrationId) 
	{
		try
        {   
			Case cs = loadCase(caseId);			
			// if there's already a PER, just clone it
			if (cs.Patient_Enrollment_Request_gne__c != null)
			{
		        Patient_Enrollment_Request_gne__c per = clonePER(cs.Patient_Enrollment_Request_gne__c);
		        insert per;
				return per;
			}
			else
			{
				// If no PER, then 'reverse engineer' it from case/medical history/patient.
				// In order to do that, get a re-enrollment object for the given product (field 'cs.Medical_History_gne__r.RecordType.Name'
				// contains the MH's product name).
				GNE_CM_MPS_ReEnroll reenrollObj = getReEnrollObject(cs.Medical_History_gne__r.RecordType.Name);
				// tell the object what type of generation we're doing
				reenrollObj.genType = PERGenerationType.FROM_CASE;
				reenrollObj.mpsRegistrationIdFromBatch = mpsRegistrationId;
		        Patient_Enrollment_Request_gne__c per = reenrollObj.generateCasePER(cs);
		        insert per;
				return per;
			}
		}
		 catch(Exception e)
        {
            GNE_CM_MPS_Utils.createAndLogErrors(new List<Database.SaveResult>(), 'Error in creating PER for Case ID: {0} and REG Id: {1}', new List<String>{caseId, mpsRegistrationId}, 'Patient_Enrollment_Request_gne__c','GNE_CM_MPS_ReEnroll.reEnrollCase', null);
           
            return null;            
        }
	}
		
	/**
	 * Entry point from Closed Case tab.
	 * 
	 * The method rewrites mostly patient specific data from the case into the PER.
	 * @param theId the Case Id
	 */
	public static Patient_Enrollment_Request_gne__c reEnrollCase(String caseId) 
	{
        try
        {   
			Case cs = loadCase(caseId);			
			// if there's already a PER, just clone it
			if (cs.Patient_Enrollment_Request_gne__c != null)
			{
		        Patient_Enrollment_Request_gne__c per = clonePER(cs.Patient_Enrollment_Request_gne__c);
		        insert per;
				return per;
			}
			else
			{
				// If no PER, then 'reverse engineer' it from case/medical history/patient.
				// In order to do that, get a re-enrollment object for the given product (field 'cs.Medical_History_gne__r.RecordType.Name'
				// contains the MH's product name).
				GNE_CM_MPS_ReEnroll reenrollObj = getReEnrollObject(cs.Medical_History_gne__r.RecordType.Name);
				// tell the object what type of generation we're doing
				reenrollObj.genType = PERGenerationType.FROM_CASE;
		        Patient_Enrollment_Request_gne__c per = reenrollObj.generateCasePER(cs);
		        insert per;
				return per;
			}
        }
        catch(Exception e)
        {
            Error_Log_gne__c err = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_ReEnroll', 'Low', 'reEnroll', 'Apex Class', e);
            Database.insert(err);
            return null;            
        }
	}


	/**
	 * Entry point from Re-enroll tab.
	 * 
	 * The method rewrites mostly patient specific data from the case into the PER.
	 * @param theId of the PER or Case Id
	 * 
	 * To Debug use:
	  		Patient_Enrollment_Request_gne__c per=GNE_CM_MPS_ReEnroll.reEnrollForm('<<case id>>');
	 		System.debug(per);
	  		delete per;	 
	 */
	public static Patient_Enrollment_Request_gne__c reEnrollForm (String theId) 
	{
		return reEnrollForm(theId, true);
	}
	
	public static Patient_Enrollment_Request_gne__c reEnrollForm (String theId, Boolean isMPS) 
	{
		System.debug('renrollForm----'+theId+'----isMPS---'+isMPS);
		if (theId.startsWith(Patient_Enrollment_Request_gne__c.sObjectType.getDescribe().getKeyPrefix())) 
		{		
	        Patient_Enrollment_Request_gne__c per = clonePER(theId);

            if (isMPS)
            {
            	insert per;
            }
			return per;
			
			/*
			//find Case related with old PER
			List<Case> perCase = [select Id from Case where Patient_Enrollment_Request_gne__c = :theId];
			if (perCase != null && perCase.size() != 0)
			{
				cs = loadCase(perCase[0].Id);
			}
			else
			{
				GNE_CM_Exception e = new GNE_CM_Exception('There is no case for PER: ' + theId);
				Database.insert(GNE_CM_MPS_Utils.createError('GNE_CM_MPS_ReEnroll', 'High', 'GNE_CM_MPS_ReEnroll', 'Apex Class', e));
				throw e;
			}
			*/
		} 
		else if (theId.startsWith(Case.sObjectType.getDescribe().getKeyPrefix())) 
		{			
			// load in the case w/ patient and Medical History
			Case cs = loadCase(theId);
		
			// start with this base implementation
			GNE_CM_MPS_ReEnroll reenrollObj = new GNE_CM_MPS_ReEnroll();

			// if we don't have Medical History we can't process
			if (cs.Medical_History_gne__c != null)
			{
				// The formName taken from the MPS_Form field will contain a name of the form corresponding to the MH's product.
				// E.g. for product 'Avastin' it will turn 'BioOncology Infused Products'.
				// We need to do some mapping due to class name issues.
				String formName = cs.Medical_History_gne__r.MPS_Form_gne__c;

				if (form2ClassMap.containsKey(formName))
				{
					formName = form2ClassMap.get(formName);
				}
				
				// instantiate class for the form re-enrollment, e.g. GNE_CM_MPS_ReEnroll_BioOnc_Infu.
				reenrollObj = getReEnrollObject(formName);
			}
			
			// tell the object what type of generation we're doing
			reenrollObj.genType=PERGenerationType.FROM_FORM;
			
			// signal to children our environment
			reenrollObj.isIntake=!isMPS;
			
        	Patient_Enrollment_Request_gne__c per = reenrollObj.generateFormPER(cs);
			
			per.Prescriber_gne__c = cs.Case_Treating_Physician_gne__c;
			
			system.debug('PER TO BE INSERTED: ' + per);
			
        	if (isMPS)
	        {
    	       	insert per;
        	}
        	
			return per;
		} 
		else
		{
			GNE_CM_Exception e = new GNE_CM_Exception('Invalid Id for Patient Re-Enroll: ' + theId);
			Database.insert(GNE_CM_MPS_Utils.createError('GNE_CM_MPS_ReEnroll', 'High', 'GNE_CM_MPS_ReEnroll', 'Apex Class', e));
			throw e;
		}
	} 
	
	
	/**
	 * 'Factory' to create ReEnroll objects based on product/form.
	 */
	public static GNE_CM_MPS_ReEnroll getReEnrollObject (String productForm)
	{		
		Type t = Type.forName('GNE_CM_MPS_ReEnroll' + (productForm != null ? ('_' + productForm.replace(' ', '_')) : ''));
		GNE_CM_MPS_ReEnroll reenrollObj = new GNE_CM_MPS_ReEnroll();
		
		if (t != null)
		{
			reenrollObj = (GNE_CM_MPS_ReEnroll)t.newInstance();
		}
		else
		{
			// log that object for product not found
			GNE_CM_Exception e  =  new GNE_CM_Exception('Patient Re-Enroll: Product class not found: ' + productform);
			Database.insert(GNE_CM_MPS_Utils.createError('GNE_CM_MPS_ReEnroll', 'High', 'GNE_CM_MPS_ReEnroll', 'Apex Class', e));
		}
		
		return reenrollObj;
	}
	
	
	/**
	 * Utility to clone existing PER
	 * 
	 * The method clones an existing PER.
	 * @param perId Id of PER to be cloned
	 */
	 
    public static Patient_Enrollment_Request_gne__c clonePER (Id perId)
    {
        try
        {  
        	if (perId != null)
            {
            	Patient_Enrollment_Request_gne__c per1 = (Patient_Enrollment_Request_gne__c) retrieveObject('Patient_Enrollment_Request_gne__c', perId, false);            	
            	Case lastCase = findTheMostRecentCaseForPer( per1.Patient_gne__c );  
            	copyInsuranceDefaultValuesToPer( per1, lastCase );
            	//per1 = mapInsurance(per1, lastCase);
            	/*
            	//find related insurances
            	List<Insurance_gne__c> relatedInsurances = [SELECT Subscriber_Name_gne__c, Patient_Relationship_to_Subscriber_gne__c, 
										            		Subscriber_DOB_gne__c, Subscriber_First_Name_gne__c, Rank_gne__c, 
										            		Payer_gne__c, Payer_gne__r.Name, Plan_Product_Type_gne__c, Payer_Ph_Provided_by_Customer_gne__c,
										            		Policy_Number_gne__c, Subscriber_Num_gne__c
															FROM  Insurance_gne__c
															WHERE ins_Insurance_gne__c = 'Active' AND Patient_Insurance_gne__c = :x.Patient_gne__c
															ORDER BY CreatedDate DESC];
				
				Insurance_gne__c latestPrimary;
				Insurance_gne__c latestSecondary;
		
				// find two latest active insurances - one with rank = "primary" and one with rank = "secondary"
				for (Insurance_gne__c ins : relatedInsurances)
				{
					if (ins.Rank_gne__c != null)
					{
						if (ins.Rank_gne__c.toLowerCase() == 'primary' && latestPrimary == null)
						{
							latestPrimary = ins;
						}
						else if (ins.Rank_gne__c.toLowerCase() == 'secondary' && latestSecondary == null)
						{
							latestSecondary = ins;
						}
					}
				}
				
				//PER adjustment base on insurance
				if (latestPrimary != null)
				{
					x.Is_Patient_Insured_gne__c = 'Yes';
					x.Primary_Insurance_Select_Type_gne__c = latestPrimary.Plan_Product_Type_gne__c;
					x.Primary_Payer_gne__c = latestPrimary.Payer_gne__c;
					x.Primary_Insurance_Carrier_Name_gne__c = latestPrimary.Payer_gne__r.Name;
					x.PI_Phone_gne__c = latestPrimary.Payer_Ph_Provided_by_Customer_gne__c;
					x.PI_Patient_Relationship_to_Subs_gne__c = latestPrimary.Patient_Relationship_to_Subscriber_gne__c;
					x.PI_Subscriber_First_Name_gne__c = latestPrimary.Subscriber_First_Name_gne__c;
					x.PI_Subscriber_Name_gne__c = latestPrimary.Subscriber_Name_gne__c;
					x.PI_Subscriber_DOB_gne__c = latestPrimary.Subscriber_DOB_gne__c;
					x.PI_Subscriber_ID_gne__c = latestPrimary.Subscriber_Num_gne__c;
					x.PI_Policy_Group_gne__c = latestPrimary.Policy_Number_gne__c;
				}
				
				if (latestSecondary != null)
				{
					x.Secondary_Insurance_Select_Type_gne__c = latestSecondary.Plan_Product_Type_gne__c;
					x.Secondary_Payer_gne__c = latestSecondary.Payer_gne__c;
					x.Secondary_Insurance_Carrier_Name_gne__c = latestSecondary.Payer_gne__r.Name;
					x.SI_Phone_gne__c = latestSecondary.Payer_Ph_Provided_by_Customer_gne__c;
					x.SI_Patient_Relationship_to_Subs_gne__c = latestSecondary.Patient_Relationship_to_Subscriber_gne__c;
					x.SI_Subscriber_First_Name_gne__c = latestSecondary.Subscriber_First_Name_gne__c;
					x.SI_Subscriber_Name_gne__c = latestSecondary.Subscriber_Name_gne__c;
					x.SI_Subscriber_DOB_gne__c = latestSecondary.Subscriber_DOB_gne__c;
					x.SI_Subscriber_ID_gne__c = latestSecondary.Subscriber_Num_gne__c;
					x.SI_Policy_Group_gne__c = latestSecondary.Policy_Number_gne__c;
				}
            	*/
            	System.debug('per1 after copying insurance values----'+per1);
            	//create new PER            	
            	Patient_Enrollment_Request_gne__c per = per1.clone(false,true); // to investigate: Why this object is copied?            	

                per.Status__c = 'Draft';
                per.Date_Submitted_gne__c = null;
                
                // set the owner to current user
                per.OwnerId=UserInfo.getUserId();
                
                // clear checkboxes in PER's Request Services section
                per.Benefits_Investigation_Prior_Auth_gne__c = false;
                per.Co_pay_Assistance_gne__c = false;
                per.Buy_and_Bill_gne__c = false;
                per.Appeals_Support_gne__c = false;
                per.GATCF_Patient_Assistance_gne__c = false;
                per.GATCF_Eligibility_Screening_gne__c = false;
                per.Other_gne__c = false;
                per.Services_Requested_Specify_Other_gne__c = null;
                per.Reason_for_Service_Request_gne__c = null;  
                per.PER_Source_gne__c='Clone';          
                per.Date_Intake_Processed_gne__c = null;  
                
                // All ADOT / Next Date of Treatment fields must be blank for EBI
                per.Next_Treatment_Date__c = null;
                per.Anticipated_Date_of_Treatment_gne__c = null;                       

               	if(per1.GNE_CM_MPS_RegId__c != null && per1.GNE_CM_MPSLocationId__c != null)
            	{
	               	List<GNE_CM_MPS_Location__c> locationList = [SELECT id, City__c,State__c,Zip__c,Office_Location_Address__c,Suite__c 
														            FROM GNE_CM_MPS_Location__c 
														            WHERE GNE_CM_MPS_Registration__c = :per1.GNE_CM_MPS_RegId__c 
														            AND Disabled__c = false 
														            AND id=:per1.GNE_CM_MPSLocationId__c];
					if (locationList.size() > 0)
					{
						per.Prescriber_City_gne__c = locationList[0].City__c;
						per.Prescriber_State_gne__c = locationList[0].State__c;
						per.Prescriber_zip_gne__c = locationList[0].Zip__c;
						if (locationList[0].Suite__c == null || locationList[0].Suite__c == '') 
						{
                			per.Prescriber_Street_Address_gne__c = locationList[0].Office_Location_Address__c;
                		}
		                else
		                {
		                	per.Prescriber_Street_Address_gne__c = locationList[0].Office_Location_Address__c + ', ' + locationList[0].Suite__c;
		                }
					}
            	}
               	
                /*
                // Uncomment or remove the fields below depending on the status of PFS-601
                // clear Requested Services PER fields present in PER object
                per.Services_Requested_Zelboraf_gne__c = null;
                per.Services_Requested_BioOnc_gne__c = null;
                per.Services_Requested_Lucentis_gne__c = null;
                per.Services_Requested_Pulmozyme_gne__c = null;
                per.Services_Requested_Rheum_gne__c = null;
                per.Services_Requested_Xolair_gne__c = null;
                per.Services_Requested_gne__c = null;
                per.Services_Requested_Pegasys_gne__c = null;
                per.Services_Requested_MPS_gne__c = null;
                */
                
                return per;
            }
            else
			{
                return null;
			}
        }
        catch(Exception e)
        {
        	system.debug(e);
            Error_Log_gne__c err  =  GNE_CM_MPS_Utils.createError('GNE_CM_MPS_ReEnroll', 'Low', 'reEnroll', 'Apex Class', e);
            Database.insert(err);
            return null;            
        }
     }
     
     /*private static void copyInsuranceDefaultValuesToPer(Patient_Enrollment_Request_gne__c patenrol, Case theCase ){                
        if( theCase == null){
        	return;
        } 
        List<Insurance_gne__c> insuranceList =
                    [SELECT Id,
                            Plan_Product_Type_gne__c, 
                            Payer_gne__r.Name,
                            Payer_Ph_Provided_by_Customer_gne__c, 
                            Patient_Relationship_to_Subscriber_gne__c,
                            Subscriber_First_Name_gne__c,
                            Subscriber_Name_gne__c,
                            Subscriber_DOB_gne__c, 
                            Subscriber_Num_gne__c,
                            Policy_Number_gne__c,
                            Group_Num_gne__c,
                            Rank_gne__c,
                            Case_Insurance_gne__r.CreatedDate,
                            ins_Insurance_gne__c,
                            Payer_gne__c,
                            Patient_Insurance_gne__r.pat_first_name_gne__c,
                            Patient_Insurance_gne__r.Name,
                            Patient_Insurance_gne__r.pat_dob_gne__c
                      FROM Insurance_gne__c
                      WHERE Patient_Insurance_gne__c = :patenrol.Patient_gne__c 
                      AND Patient_Insurance_gne__c <> null 
                      AND Rank_gne__c IN ('Primary', 'Secondary')
                      AND ins_Insurance_gne__c = :GNE_CM_Insurance_Dictionary.INS_INSURANCE_GNE_ACTIVE
                      AND Case_Insurance_gne__c = :theCase.Id
                      Order by Case_Insurance_gne__r.CreatedDate DESC
                      Limit 2            
        ]; 
        
                                                      
       // DateTime lastPrimaryInsurance  = DateTime.newInstance(1L);
       // DateTime lastSecondaryInsurance =  DateTime.newInstance(1L); // long long time ago -> January 1, 1970, 00:00:00 GMT
        Insurance_gne__c insurance;
        Insurance_gne__c secondaryInsurance;
        for(Insurance_gne__c ins : insuranceList){
            if(ins.Rank_gne__c == 'Primary'){
                insurance = ins;                
            }
            if(ins.Rank_gne__c == 'Secondary'){              
                secondaryInsurance = ins;                
            }
        }
        if(insurance != null &&
           insurance.ins_Insurance_gne__c != null &&
           insurance.ins_Insurance_gne__c == GNE_CM_Insurance_Dictionary.INS_INSURANCE_GNE_ACTIVE) {
            patenrol.Is_Patient_Insured_gne__c = GNE_CM_PER_Dictionary.IS_PATIENT_INSURED_GNE_YES;  
        } 
        //else {
            // patenrol.Is_Patient_Insured_gne__c = GNE_CM_PER_Dictionary.IS_PATIENT_INSURED_GNE_NO;   
        //}
        
        if(insurance != null){        	
            if(insurance.Plan_Product_Type_gne__c !=  null && //added
               insurance.Plan_Product_Type_gne__c != '' &&
               INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE.get(insurance.Plan_Product_Type_gne__c) != null) {
               patenrol.Primary_Insurance_Select_Type_gne__c = INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE.get(insurance.Plan_Product_Type_gne__c);  
            }
            else {
            	patenrol.Primary_Insurance_Select_Type_gne__c = null;
            }
            if (insurance.Payer_gne__c != null &&
                insurance.Payer_gne__r.Name != null &&
                insurance.Payer_gne__r.Name != ''){
                patenrol.Primary_Payer_gne__c = insurance.Payer_gne__c;
                patenrol.Primary_Insurance_Carrier_Name_gne__c = insurance.Payer_gne__r.Name;
            }
            else {
            	patenrol.Primary_Payer_gne__c = null;
                patenrol.Primary_Insurance_Carrier_Name_gne__c = null;
            }
            if (insurance.Payer_Ph_Provided_by_Customer_gne__c != null && // added
                insurance.Payer_Ph_Provided_by_Customer_gne__c != ''){
                patenrol.PI_Phone_gne__c = insurance.Payer_Ph_Provided_by_Customer_gne__c;
            }
            else {
            	patenrol.PI_Phone_gne__c = null;
            }                                 
            if (insurance.Patient_Relationship_to_Subscriber_gne__c != null &&
                insurance.Patient_Relationship_to_Subscriber_gne__c != ''){
                patenrol.PI_Patient_Relationship_to_Subs_gne__c = insurance.Patient_Relationship_to_Subscriber_gne__c;
            }
            else {
            	patenrol.PI_Patient_Relationship_to_Subs_gne__c = null;
            }
            if (!String.isblank(insurance.Patient_Relationship_to_Subscriber_gne__c) && 
        		insurance.Patient_Relationship_to_Subscriber_gne__c == 'Self'){
                patenrol.PI_Subscriber_First_Name_gne__c = insurance.Patient_Insurance_gne__r.pat_first_name_gne__c;
                patenrol.PI_Subscriber_Name_gne__c = insurance.Patient_Insurance_gne__r.Name;	
                patenrol.PI_Subscriber_DOB_gne__c = insurance.Patient_Insurance_gne__r.pat_dob_gne__c;
        	}
        	else {
        		patenrol.PI_Subscriber_First_Name_gne__c = null;
                patenrol.PI_Subscriber_Name_gne__c = null;	
                patenrol.PI_Subscriber_DOB_gne__c = null;
        	}            		
            
            //if (insurance.Subscriber_Name_gne__c != null &&
            //    insurance.Subscriber_Name_gne__c != ''){
            //    patenrol.PI_Subscriber_Name_gne__c = insurance.Subscriber_Name_gne__c;
            //}
            //if (insurance.Subscriber_DOB_gne__c != null){
            //    patenrol.PI_Subscriber_DOB_gne__c = insurance.Subscriber_DOB_gne__c;
            //}
            
            if(insurance.Subscriber_Num_gne__c != null && //added
               insurance.Subscriber_Num_gne__c != ''){
                patenrol.PI_Subscriber_ID_gne__c = insurance.Subscriber_Num_gne__c;     
            }
            else {
            	patenrol.PI_Subscriber_ID_gne__c = null;
            }
            if(insurance.Group_Num_gne__c != null && //added
               insurance.Group_Num_gne__c != '' ){
                patenrol.PI_Policy_Group_gne__c = insurance.Group_Num_gne__c;   
            }
            else {
            	patenrol.PI_Policy_Group_gne__c = null;
            }   
        }
        if(secondaryInsurance != null){         	   
            if(secondaryInsurance.Plan_Product_Type_gne__c !=  null && //added
               secondaryInsurance.Plan_Product_Type_gne__c != '' &&
               INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE.get(secondaryInsurance.Plan_Product_Type_gne__c) != null) {
               patenrol.Secondary_Insurance_Select_Type_gne__c = INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE.get(secondaryInsurance.Plan_Product_Type_gne__c);  
            }             
            else {
            	patenrol.Secondary_Insurance_Select_Type_gne__c = null;
            }      
            if (secondaryInsurance.Payer_gne__c != null &&
                secondaryInsurance.Payer_gne__r.Name != null &&
                secondaryInsurance.Payer_gne__r.Name != ''){
                patenrol.Secondary_Payer_gne__c = secondaryInsurance.Payer_gne__c; 	
                patenrol.Secondary_Insurance_Carrier_Name_gne__c = secondaryInsurance.Payer_gne__r.Name;
            }
            else {
            	patenrol.Secondary_Payer_gne__c = null; 	
                patenrol.Secondary_Insurance_Carrier_Name_gne__c = null;
            }
            if(secondaryInsurance.Payer_Ph_Provided_by_Customer_gne__c != null && // added
               secondaryInsurance.Payer_Ph_Provided_by_Customer_gne__c != ''){
               patenrol.SI_Phone_gne__c = secondaryInsurance.Payer_Ph_Provided_by_Customer_gne__c;
            } 
            else {
            	patenrol.SI_Phone_gne__c = null;
            }
            if (secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c != null &&
                secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c != ''){
                patenrol.SI_Patient_Relationship_to_Subs_gne__c = secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c;
            }
            else {
            	patenrol.SI_Patient_Relationship_to_Subs_gne__c = null;
            }
            if (!String.isblank(secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c) &&
            	secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c == 'Self'){                	
                patenrol.SI_Subscriber_First_Name_gne__c = secondaryInsurance.Patient_Insurance_gne__r.pat_first_name_gne__c;
                patenrol.SI_Subscriber_Name_gne__c = secondaryInsurance.Patient_Insurance_gne__r.Name;	
                patenrol.SI_Subscriber_DOB_gne__c = secondaryInsurance.Patient_Insurance_gne__r.pat_dob_gne__c;
            }
        	else {
        		patenrol.SI_Subscriber_First_Name_gne__c = null;
                patenrol.SI_Subscriber_Name_gne__c = null;	
                patenrol.SI_Subscriber_DOB_gne__c = null;
        	}
            
            
            //if (secondaryInsurance.Subscriber_First_Name_gne__c != null &&
            //    secondaryInsurance.Subscriber_First_Name_gne__c != '') {
            //    patenrol.SI_Subscriber_First_Name_gne__c = secondaryInsurance.Subscriber_First_Name_gne__c;
            //}
            //if (secondaryInsurance.Subscriber_Name_gne__c != null &&
            //    secondaryInsurance.Subscriber_Name_gne__c != '') {
            //    patenrol.SI_Subscriber_Name_gne__c = secondaryInsurance.Subscriber_Name_gne__c;
            //}
            //if (secondaryInsurance.Subscriber_DOB_gne__c != null){
            //    patenrol.SI_Subscriber_DOB_gne__c = secondaryInsurance.Subscriber_DOB_gne__c;
            //}
            
            if(secondaryInsurance.Subscriber_Num_gne__c != null && //added
               secondaryInsurance.Subscriber_Num_gne__c != ''){
               patenrol.SI_Subscriber_ID_gne__c = secondaryInsurance.Subscriber_Num_gne__c;    
            }
            else {
            	patenrol.SI_Subscriber_ID_gne__c = null;
            }
            if(secondaryInsurance.Group_Num_gne__c != null && //added
               secondaryInsurance.Group_Num_gne__c != '' ){
               patenrol.SI_Policy_Group_gne__c = secondaryInsurance.Group_Num_gne__c;      
            }
            else {
            	patenrol.SI_Policy_Group_gne__c = null;
            }
        }        
    }
    */
    
    private static void copyInsuranceDefaultValuesToPer(Patient_Enrollment_Request_gne__c patenrol, Case theCase ){                
        if( theCase == null){
        	return;
        }
        
        List<Insurance_gne__c> relatedInsurances = [
			SELECT 
				Id,
				Rank_gne__c,
				Plan_Product_Type_gne__c, 
				Payer_gne__c,
				Payer_gne__r.Name, 
				Payer_Ph_Provided_by_Customer_gne__c, 
				Subscriber_Name_gne__c, 
				Subscriber_Num_gne__c, 
				Policy_Number_gne__c,
				Patient_Relationship_to_Subscriber_gne__c, 
				Subscriber_DOB_gne__c, 
				Subscriber_First_Name_gne__c,
				Patient_Insurance_gne__r.pat_first_name_gne__c,
				Patient_Insurance_gne__r.Name,
				Patient_Insurance_gne__r.pat_dob_gne__c,
				Group_Num_gne__c,
				Case_Insurance_gne__r.CreatedDate,
                ins_Insurance_gne__c                
			FROM  Insurance_gne__c
			WHERE ins_Insurance_gne__c = 'Active' AND Patient_Insurance_gne__c = :theCase.Patient_gne__c
			ORDER BY CreatedDate DESC
		];           
          
		Insurance_gne__c insurance;
		Insurance_gne__c secondaryInsurance;
		
		// find two latest active insurances - one with rank = "primary" and one with rank = "secondary"
		for (Insurance_gne__c i : relatedInsurances)
		{
			if (i.Rank_gne__c!=null)
			{
				if (i.Rank_gne__c.toLowerCase() == 'primary')
				{
					if (insurance == null)
					{
						insurance = i;
					}
					else
					{
						continue;
					}
				}
				else if (i.Rank_gne__c.toLowerCase() == 'secondary')
				{
					if (secondaryInsurance == null)
					{
						secondaryInsurance = i;
					}
					else
					{
						continue;
					}
				}
			}
		}
		// calculate is patient insured   
        if(insurance != null &&
           insurance.ins_Insurance_gne__c != null &&
           insurance.ins_Insurance_gne__c == GNE_CM_Insurance_Dictionary.INS_INSURANCE_GNE_ACTIVE) {
           	patenrol.Is_Patient_Insured_gne__c = GNE_CM_PER_Dictionary.IS_PATIENT_INSURED_GNE_YES;  
        } else {
        	patenrol.Is_Patient_Insured_gne__c = GNE_CM_PER_Dictionary.IS_PATIENT_INSURED_GNE_NO;	
        }
        
        
        if(insurance == null){
        	insurance = new Insurance_gne__c(); //copy empty values when insurance is null ;        	
        }        	
        if(insurance.Plan_Product_Type_gne__c !=  null && //added
           insurance.Plan_Product_Type_gne__c != '' &&
           INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE.get(insurance.Plan_Product_Type_gne__c) != null) {
           patenrol.Primary_Insurance_Select_Type_gne__c = INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE.get(insurance.Plan_Product_Type_gne__c);  
        }
        else {
        	patenrol.Primary_Insurance_Select_Type_gne__c = null;
        }
        if (insurance.Payer_gne__c != null &&
            insurance.Payer_gne__r.Name != null &&
            insurance.Payer_gne__r.Name != ''){
            patenrol.Primary_Payer_gne__c = insurance.Payer_gne__c;
            if(String.isNOtBlank(insurance.Payer_gne__r.Name))
            {
	            if(insurance.Payer_gne__r.Name.length()>80)
	          	{
	          		patenrol.Primary_Insurance_Carrier_Name_gne__c = insurance.Payer_gne__r.Name.substring(0,80);		
	          	}else
	          	{
	          		patenrol.Primary_Insurance_Carrier_Name_gne__c = insurance.Payer_gne__r.Name;		
	          	}
	          }
        }
        else {
        	patenrol.Primary_Payer_gne__c = null;
            patenrol.Primary_Insurance_Carrier_Name_gne__c = null;
        }
        if (insurance.Payer_Ph_Provided_by_Customer_gne__c != null && // added
            insurance.Payer_Ph_Provided_by_Customer_gne__c != ''){
            patenrol.PI_Phone_gne__c = insurance.Payer_Ph_Provided_by_Customer_gne__c;
        }
        else {
        	patenrol.PI_Phone_gne__c = null;
        }                                 
        if (insurance.Patient_Relationship_to_Subscriber_gne__c != null &&
            insurance.Patient_Relationship_to_Subscriber_gne__c != ''){
            patenrol.PI_Patient_Relationship_to_Subs_gne__c = insurance.Patient_Relationship_to_Subscriber_gne__c;
        }
        else {
        	patenrol.PI_Patient_Relationship_to_Subs_gne__c = null;
        }
        if (!String.isblank(insurance.Patient_Relationship_to_Subscriber_gne__c) && 
    		insurance.Patient_Relationship_to_Subscriber_gne__c == 'Self'){
            patenrol.PI_Subscriber_First_Name_gne__c = insurance.Patient_Insurance_gne__r.pat_first_name_gne__c;
            patenrol.PI_Subscriber_Name_gne__c = insurance.Patient_Insurance_gne__r.Name;	
            patenrol.PI_Subscriber_DOB_gne__c = insurance.Patient_Insurance_gne__r.pat_dob_gne__c;
    	}
    	else {
    		patenrol.PI_Subscriber_First_Name_gne__c = null;
            patenrol.PI_Subscriber_Name_gne__c = null;	
            patenrol.PI_Subscriber_DOB_gne__c = null;
    	} 
        if(insurance.Subscriber_Num_gne__c != null && //added
           insurance.Subscriber_Num_gne__c != ''){
            patenrol.PI_Subscriber_ID_gne__c = insurance.Subscriber_Num_gne__c;     
        }
        else {
        	patenrol.PI_Subscriber_ID_gne__c = null;
        }
        if(insurance.Group_Num_gne__c != null && //added
           insurance.Group_Num_gne__c != '' ){
            patenrol.PI_Policy_Group_gne__c = insurance.Group_Num_gne__c;   
        }
        else {
        	patenrol.PI_Policy_Group_gne__c = null;
        }
          
        //secondary insurance 
        if(secondaryInsurance == null){
        	secondaryInsurance = new Insurance_gne__c(); // copy empty values
        }        	
                	   
        if(secondaryInsurance.Plan_Product_Type_gne__c !=  null && //added
           secondaryInsurance.Plan_Product_Type_gne__c != '' &&
           INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE.get(secondaryInsurance.Plan_Product_Type_gne__c) != null) {
           patenrol.Secondary_Insurance_Select_Type_gne__c = INSURANCE_TYPE_2_PLAN_PRODUCT_TYPE.get(secondaryInsurance.Plan_Product_Type_gne__c);  
        }             
        else {
        	patenrol.Secondary_Insurance_Select_Type_gne__c = null;
        }      
        if (secondaryInsurance.Payer_gne__c != null &&
            secondaryInsurance.Payer_gne__r.Name != null &&
            secondaryInsurance.Payer_gne__r.Name != ''){
            patenrol.Secondary_Payer_gne__c = secondaryInsurance.Payer_gne__c; 	
            if(String.isNOtBlank(secondaryInsurance.Payer_gne__r.Name))
            {
            	if(secondaryInsurance.Payer_gne__r.Name.length() >80)
            	{
            		patenrol.Secondary_Insurance_Carrier_Name_gne__c = secondaryInsurance.Payer_gne__r.Name.substring(0,80);		
            	}else
            	{
            		patenrol.Secondary_Insurance_Carrier_Name_gne__c = secondaryInsurance.Payer_gne__r.Name;		
            	}
            	
            }
            
        }
        else {
        	patenrol.Secondary_Payer_gne__c = null; 	
            patenrol.Secondary_Insurance_Carrier_Name_gne__c = null;
        }
        if(secondaryInsurance.Payer_Ph_Provided_by_Customer_gne__c != null && // added
           secondaryInsurance.Payer_Ph_Provided_by_Customer_gne__c != ''){
           patenrol.SI_Phone_gne__c = secondaryInsurance.Payer_Ph_Provided_by_Customer_gne__c;
        } 
        else {
        	patenrol.SI_Phone_gne__c = null;
        }
        if (secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c != null &&
            secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c != ''){
            patenrol.SI_Patient_Relationship_to_Subs_gne__c = secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c;
        }
        else {
        	patenrol.SI_Patient_Relationship_to_Subs_gne__c = null;
        }
        if (!String.isblank(secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c) &&
        	secondaryInsurance.Patient_Relationship_to_Subscriber_gne__c == 'Self'){                	
            patenrol.SI_Subscriber_First_Name_gne__c = secondaryInsurance.Patient_Insurance_gne__r.pat_first_name_gne__c;
            patenrol.SI_Subscriber_Name_gne__c = secondaryInsurance.Patient_Insurance_gne__r.Name;	
            patenrol.SI_Subscriber_DOB_gne__c = secondaryInsurance.Patient_Insurance_gne__r.pat_dob_gne__c;
        }
    	else {
    		patenrol.SI_Subscriber_First_Name_gne__c = null;
            patenrol.SI_Subscriber_Name_gne__c = null;	
            patenrol.SI_Subscriber_DOB_gne__c = null;
    	}
             
        if(secondaryInsurance.Subscriber_Num_gne__c != null && //added
           secondaryInsurance.Subscriber_Num_gne__c != ''){
           patenrol.SI_Subscriber_ID_gne__c = truncateValue(secondaryInsurance.Subscriber_Num_gne__c,Patient_Enrollment_Request_gne__c.PI_Subscriber_ID_gne__c.getDescribe());    
        }
        else {
        	patenrol.SI_Subscriber_ID_gne__c = null;
        }
        if(secondaryInsurance.Group_Num_gne__c != null && //added
           secondaryInsurance.Group_Num_gne__c != '' ){
           patenrol.SI_Policy_Group_gne__c = secondaryInsurance.Group_Num_gne__c;      
        }
        else {
        	patenrol.SI_Policy_Group_gne__c = null;
        }             
    }
    
    private static Case findTheMostRecentCaseForPer ( Id patientId ){
    	if(patientId == null){
    		return null;
    	}
    	List<Case> relatedCases = [
    		SELECT Id, Patient_gne__c, CreatedDate
    		FROM Case
    		WHERE Patient_gne__c = :patientId AND C_R_Case__c = :GNE_CM_Case_Dictionary.C_R_CASE_YES
    		ORDER BY CreatedDate DESC
			LIMIT 1
    	];
    	if( relatedCases.size() == 0 ){
    		return null;	
    	}
    	return relatedCases[0];    	
    } 

	/**
	 * Generate a PER from a case.
	 * 
	 * The method rewrites mostly patient specific data from the case into the PER.
	 * @param cs Case from which a PER will be generated
	 */
	public virtual Patient_Enrollment_Request_gne__c generateCasePER(Case cs)
	{
		system.debug('cs.Patient_gne__r: ' + cs.Patient_gne__r);
		system.debug('cs.Patient_gne__c: ' + cs.Patient_gne__c);
		system.debug('case.id: ' + cs.Id);
		Patient_Enrollment_Request_gne__c per = generateBasePER(cs.Patient_gne__r);
		
		// set common attributes			
		per.Prescriber_gne__c = cs.Case_Treating_Physician_gne__c;		
		per.product_gne__c = cs.Medical_History_gne__r.MPS_Form_gne__c;
		per.Indicate_Patient_s_Therapy_gne__c = cs.Medical_History_gne__r.RecordType.Name;
		//Rama. Since generateCasePER is virtual and we have overrides for each product we can't just duplicate it
		//Instead we are creating new class variable which will be only set from batch.
		//If this registration id from batch is available use it or else use currently logged in MPS User's registration
		if(mpsRegistrationIdFromBatch != null) {
			per.GNE_CM_MPS_RegId__c = mpsRegistrationIdFromBatch;
		} else {
			per.GNE_CM_MPS_RegId__c=GNE_CM_MPS_Utils.getMPSRegistration();
		}

		per.ICD9_Code_1_gne__c=coalesce(per.ICD9_Code_1_gne__c, cs.Medical_History_gne__r.ICD9_Code_1_gne__c);
		per.ICD9_Code_2_gne__c=coalesce(per.ICD9_Code_3_gne__c, cs.Medical_History_gne__r.ICD9_Code_2_gne__c);
		per.ICD9_Code_3_gne__c=coalesce(per.ICD9_Code_3_gne__c, cs.Medical_History_gne__r.ICD9_Code_3_gne__c);
		per.Disease_state_gne__c=coalesce(per.Disease_state_gne__c, cs.Medical_History_gne__r.Disease_state_gne__c);
		
		// read in practice info
		List<GNE_CM_MPS_Practice_Agreement_Location__c> lstPAL=[SELECT Id, Account__c,
									Address__c, MPS_Location__c,MPS_Practice_Agreement__c,MPS_Registration__c,
									Address__r.name, Address__r.Fax_vod__c, Address__r.Phone_vod__c,
									MPS_Location__r.City__c,MPS_Location__r.State__c,MPS_Location__r.Zip__c,
									MPS_Location__r.Office_Location_Address__c,MPS_Location__r.Suite__c
									//Bartek Borowiec PFS-1337 start code
									,MPS_Registration__r.Practice_Name__c
									//Bartek Borowiec PFS-1337 end code
									FROM GNE_CM_MPS_Practice_Agreement_Location__c 
									WHERE Address__c = :cs.Address_gne__c AND Address__c!=null 
									AND MPS_Registration__c=:per.GNE_CM_MPS_RegId__c AND MPS_Registration__c!=null];

		if (lstPAL.size()>0 && per.Prescriber_gne__c!=null)
		{								
			GNE_CM_MPS_Practice_Agreement_Location__c pal=lstPAL[0];
			
			per.GNE_CM_MPSLocationId__c=pal.MPS_Location__c;
			
			// read name & specialties
			Account acc=GNE_CM_MPS_Utils.getAccount(per.Prescriber_gne__c, per.GNE_CM_MPS_RegId__c,per.GNE_CM_MPSLocationId__c ); 
			if (acc!=null)
			{
				per.Prescriber_gne__c=acc.id;
				per.Prescriber_First_Name_gne__c=acc.firstname;
				per.Prescriber_Name__c=acc.lastname;
				if (acc.Subspecialties_gne__c != null && acc.Subspecialties_gne__c != '')
				{
					if (acc.Subspecialties_gne__c.length() > 40)
					{
						per.Specialty_gne__c=acc.Subspecialties_gne__c.substring(0, 39);
					}
					else
					{
						per.Specialty_gne__c=acc.Subspecialties_gne__c;
					}
				}
			}
			
			// address and contact info
			per.Treating_Location_ID_gne__c = pal.Address__c;
			if (pal.Address__c!=null)
			{
				//Bartek Borowiec PFS-1337 start comments 
				//per.Treating_Location_Name_gne__c=pal.Address__r.name;
				//Bartek Borowiec PFS-1337 end comments 
				per.Prescriber_Fax_gne__c=pal.Address__r.Fax_vod__c;
				per.Prescriber_Phone_gne__c=pal.Address__r.Phone_vod__c;
			}
			//Bartek Borowiec PFS-1337 code starts 
			if(pal.MPS_Registration__c != null)
			{
				per.Treating_Location_Name_gne__c = pal.MPS_Registration__r.Practice_Name__c;
			}
			//Bartek Borowiec PFS-1337 code ends
			if (pal.MPS_Location__c!=null)
			{
				per.Prescriber_City_gne__c=pal.MPS_Location__r.City__c;
				per.Prescriber_State_gne__c=pal.MPS_Location__r.State__c;
				per.Prescriber_zip_gne__c=pal.MPS_Location__r.Zip__c;
				if (pal.MPS_Location__r.Suite__c == null || pal.MPS_Location__r.Suite__c == '')
				{
					per.Prescriber_Street_Address_gne__c = pal.MPS_Location__r.Office_Location_Address__c;
				}
				else 
				{
					per.Prescriber_Street_Address_gne__c = pal.MPS_Location__r.Office_Location_Address__c + ', ' + pal.MPS_Location__r.Suite__c;				
				}
			}

			// license info
			Map<String, String> licenseInfo = GNE_CM_MPS_Utils.getLicenseInformation(per.Prescriber_gne__c);

			if (licenseInfo.size()>0){
				List<Address_vod__c> lstAdd=[select City_vod__c,State_vod__c,Zip_vod__c,Fax_vod__c,Phone_vod__c,Name, id from Address_vod__c where id=:per.Treating_Location_ID_gne__c];
				
				if (!lstAdd.IsEmpty())
				{
					Address_vod__c address=lstAdd[0];
					if (licenseInfo.containsKey(String.ValueOf(per.Prescriber_gne__c) + 'Tax ID' + String.ValueOf(address.State_vod__c) + address.id))
					{
						per.Prescriber_Tax_ID_gne__c = licenseInfo.get(String.ValueOf(per.Prescriber_gne__c) + 'Tax ID' + String.ValueOf(address.State_vod__c) + address.id);
					}
					if (licenseInfo.containsKey(String.ValueOf(per.Prescriber_gne__c) + 'PTAN' + String.ValueOf(address.State_vod__c) + address.id))
					{
						per.PTAN_gne__c = licenseInfo.get(String.ValueOf(per.Prescriber_gne__c) + 'PTAN' + String.ValueOf(address.State_vod__c) + address.id); 
					}           
					if (licenseInfo.containsKey(String.ValueOf(per.Prescriber_gne__c) + 'DEA #' + String.ValueOf(address.State_vod__c) + address.id))
					{               
						per.Prescriber_DEA_gne__c = licenseInfo.get(String.ValueOf(per.Prescriber_gne__c) + 'DEA #' + String.ValueOf(address.State_vod__c) + address.id); 
					}           
					if (licenseInfo.containsKey(String.ValueOf(per.Prescriber_gne__c) + String.ValueOf(address.State_vod__c) + address.id))
					{
						per.Prescriber_State_License_Number_gne__c = licenseInfo.get(String.ValueOf(per.Prescriber_gne__c) + String.ValueOf(address.State_vod__c) + address.id); 
					} 
					if (licenseInfo.ContainsKey(String.ValueOf(per.Prescriber_gne__c) + 'NPI #' + String.valueOf(address.State_vod__c) + address.id))
					{
						per.Prescriber_NPI_gne__c = licenseInfo.get(String.ValueOf(per.Prescriber_gne__c) + 'NPI #' + String.ValueOf(address.State_vod__c) + address.id); 
					}
				}  			
			}
		}			  
		copyInsuranceDefaultValuesToPer(per, cs);		
        //Santosh Changes 11/15/2013 START
        Medical_History_gne__c Mh = cs.Medical_History_gne__r;
        system.debug('****************'+ Mh.Product_gne__c);
        if(Mh.Product_gne__c == 'Gazyva')
        {       
            GNE_CM_MPS_ReEnroll_GA101 gaz = new GNE_CM_MPS_ReEnroll_GA101(); 
            return gaz.updateFormPERGazyva(per, cs.Medical_History_gne__r);
        }
        else
        {
		return updateFormPER(per, cs.Medical_History_gne__r);
	}
        //Santosh Changes 11/15/2013 End
    }
	
	/**
	 * Map fields from the insurance object(s) associated with the case.
	 */
	 
	 
	 
	/*private Patient_Enrollment_Request_gne__c mapInsurance (Case cs, Patient_Enrollment_Request_gne__c per)
	{
		system.debug('mapping from insurance');
		// populate insurance info
		List<Insurance_gne__c> relatedInsurances = [
			SELECT Id, Rank_gne__c, Plan_Product_Type_gne__c, Payer_gne__c, Payer_gne__r.Name, Payer_Ph_Provided_by_Customer_gne__c, 
			Subscriber_Name_gne__c, Subscriber_Num_gne__c, Policy_Number_gne__c,
			Patient_Relationship_to_Subscriber_gne__c, Subscriber_DOB_gne__c, Subscriber_First_Name_gne__c,
			Patient_Insurance_gne__r.pat_first_name_gne__c,Patient_Insurance_gne__r.Name,Patient_Insurance_gne__r.pat_dob_gne__c
			FROM  Insurance_gne__c
			WHERE ins_Insurance_gne__c = 'Active' AND Patient_Insurance_gne__c = :cs.Patient_gne__c
			ORDER BY CreatedDate DESC
		];
		Insurance_gne__c latestPrimary;
		Insurance_gne__c latestSecondary;
		
		// find two latest active insurances - one with rank = "primary" and one with rank = "secondary"
		for (Insurance_gne__c i : relatedInsurances)
		{
			if (i.Rank_gne__c!=null)
			{
				if (i.Rank_gne__c.toLowerCase() == 'primary')
				{
					if (latestPrimary == null)
					{
						latestPrimary = i;
					}
					else
					{
						continue;
					}
				}
				else if (i.Rank_gne__c.toLowerCase() == 'secondary')
				{
					if (latestSecondary == null)
					{
						latestSecondary = i;
					}
					else
					{
						continue;
					}
				}
			}
		}
		
		
		if (latestPrimary != null)
		{
			
			per.Primary_Insurance_Select_Type_gne__c = mapInsuranceProductTypeToPER(latestPrimary.Plan_Product_Type_gne__c);
			per.Primary_Insurance_Carrier_Name_gne__c = latestPrimary.Payer_gne__r.Name;
			per.Primary_Payer_gne__c = latestPrimary.Payer_gne__c;
			per.PI_Phone_gne__c = latestPrimary.Payer_Ph_Provided_by_Customer_gne__c;
			per.PI_Patient_Relationship_to_Subs_gne__c = latestPrimary.Patient_Relationship_to_Subscriber_gne__c;
			if (!String.isblank(latestPrimary.Patient_Relationship_to_Subscriber_gne__c) && 
				latestPrimary.Patient_Relationship_to_Subscriber_gne__c == 'Self'){
                per.PI_Subscriber_First_Name_gne__c = latestPrimary.Patient_Insurance_gne__r.pat_first_name_gne__c;
				per.PI_Subscriber_Name_gne__c = latestPrimary.Patient_Insurance_gne__r.Name;
				per.PI_Subscriber_DOB_gne__c = latestPrimary.Patient_Insurance_gne__r.pat_dob_gne__c;
            }
        	else {
        		per.PI_Subscriber_First_Name_gne__c = null;
                per.PI_Subscriber_Name_gne__c = null;	
                per.PI_Subscriber_DOB_gne__c = null;
        	}
			per.PI_Subscriber_ID_gne__c = truncateValue(latestPrimary.Subscriber_Num_gne__c, Patient_Enrollment_Request_gne__c.PI_Subscriber_ID_gne__c.getDescribe());
			per.PI_Policy_Group_gne__c = latestPrimary.Policy_Number_gne__c;
		}
		if (latestSecondary != null)
		{
			per.Secondary_Insurance_Select_Type_gne__c = mapInsuranceProductTypeToPER(latestSecondary.Plan_Product_Type_gne__c);
			per.Secondary_Insurance_Carrier_Name_gne__c = latestSecondary.Payer_gne__r.Name;
			per.Secondary_Payer_gne__c = latestSecondary.Payer_gne__c;
			per.SI_Phone_gne__c = latestSecondary.Payer_Ph_Provided_by_Customer_gne__c;
			per.SI_Patient_Relationship_to_Subs_gne__c = latestSecondary.Patient_Relationship_to_Subscriber_gne__c;
			if (!String.isblank(latestSecondary.Patient_Relationship_to_Subscriber_gne__c) &&
				latestSecondary.Patient_Relationship_to_Subscriber_gne__c == 'Self'){
                per.SI_Subscriber_First_Name_gne__c = latestSecondary.Patient_Insurance_gne__r.pat_first_name_gne__c;
				per.SI_Subscriber_Name_gne__c = latestSecondary.Patient_Insurance_gne__r.Name;
				per.SI_Subscriber_DOB_gne__c = latestSecondary.Patient_Insurance_gne__r.pat_dob_gne__c;
            }
            else{
            	per.SI_Subscriber_First_Name_gne__c = null;
				per.SI_Subscriber_Name_gne__c = null;
				per.SI_Subscriber_DOB_gne__c = null;
            }
			per.SI_Subscriber_ID_gne__c = truncateValue(latestSecondary.Subscriber_Num_gne__c, Patient_Enrollment_Request_gne__c.SI_Subscriber_ID_gne__c.getDescribe());
			per.SI_Policy_Group_gne__c = latestSecondary.Policy_Number_gne__c;
		}	
		
		return per;
	}
	*/
	
	


	/**
	 * Fetch a list of Medical Histories to be included in a Form 
	 * 
	 * @param cs Case from which a PER will be generated
	 */
	public virtual List<Medical_History_gne__c> getFormMedicalHistories(Case cs)
	{
		//return [select Id, RecordType.Name, ICD9_Code_1_gne__r.ICD9_Code_gne__c, ICD9_Code_2_gne__r.ICD9_Code_gne__c, ICD9_Code_3_gne__r.ICD9_Code_gne__c from Medical_History_gne__c where Patient_Med_Hist_gne__c = :cs.Patient_gne__c and MPS_Form_gne__c = :cs.Medical_History_gne__r.MPS_Form_gne__c ORDER BY CreatedDate DESC];
		return new List<Medical_History_gne__c>();
	}
	
	
	/**
	 * Generate a PER from a patient/form.
	 * 
	 * The method rewrites mostly patient specific data from the case into the PER.
	 * @param cs Case from which a PER will be generated
	 */
	public virtual Patient_Enrollment_Request_gne__c generateFormPER(Case cs)
	{	
		// generate from the latest case
		Patient_Enrollment_Request_gne__c per = generateCasePER(cs);
		system.debug('Reenroll per (reEnrollForm): '+ per);
		
		// then, for multi product forms, process other related medical Histories
		List<Medical_History_gne__c> lstFormMH=getFormMedicalHistories(cs);
		
		if (!lstFormMH.isEmpty())
		{
			// record type names mapped to their corresponding MH items																																																																																																																																								
			Map<String,String> recordTypesToMedicalHistory = new Map<String,String>();
			// medical history IDs mapped to record type names
			Map<String,Medical_History_gne__c> medicalHistoryIdMap = new Map<String,Medical_History_gne__c>();
			
			// the patient therapy will have the values of all drugs within this group
			per.Indicate_Patient_s_Therapy_gne__c = '';
	
			// get the latest medical histories for each product		
			for (Medical_History_gne__c mh : lstFormMH)
			{
				// concatenate therapies
				if (!recordTypesToMedicalHistory.containsKey(mh.RecordType.Name))
				{
					per.Indicate_Patient_s_Therapy_gne__c += (mh.RecordType.Name+';');
					recordTypesToMedicalHistory.put(mh.RecordType.Name, mh.Id);
					medicalHistoryIdMap.put(mh.Id, mh);
				}
				// map MH to RT and the other way
			}

			// get MH objects
			List<Medical_History_gne__c> lstMH = (List<Medical_History_gne__c>) GNE_CM_MPS_ReEnroll.retrieveObjects('Medical_History_gne__c', recordTypesToMedicalHistory.values(), true, 'ORDER BY CreatedDate DESC');

			for (Medical_History_gne__c mh : lstMH)
			{
				Medical_History_gne__c mhICD9 = medicalHistoryIdMap.get(mh.Id);
				
				mh.RecordType=(RecordType) GNE_CM_MPS_ReEnroll.retrieveObject('RecordType', mh.RecordTypeId, true);
				
				// set related items.
				mh.ICD9_Code_1_gne__r = mhICD9.ICD9_Code_1_gne__r;
				mh.ICD9_Code_2_gne__r = mhICD9.ICD9_Code_2_gne__r;
				mh.ICD9_Code_3_gne__r = mhICD9.ICD9_Code_3_gne__r;

				// update form specific fields
				per = updateFormPER(per, mh);
				
				per.ICD9_Code_1_gne__c=coalesce(per.ICD9_Code_1_gne__c, mh.ICD9_Code_1_gne__c);
				per.ICD9_Code_2_gne__c=coalesce(per.ICD9_Code_2_gne__c, mh.ICD9_Code_2_gne__c);
				per.ICD9_Code_3_gne__c=coalesce(per.ICD9_Code_3_gne__c, mh.ICD9_Code_3_gne__c);
				per.Disease_state_gne__c=coalesce(per.Disease_state_gne__c, mh.Disease_state_gne__c);
	
				// Update product level fields.
				// Create the product enroll object and update the per with product specific fields
				GNE_CM_MPS_ReEnroll reenrollObj = getReEnrollObject(mhICD9.RecordType.Name);
				// update product-specific fields
				per = reenrollObj.updatePER(per, mh);
			}
		}		
		return per;
	}


	/*
	 * Copy common Medical History fields
	 */
	public virtual Patient_Enrollment_Request_gne__c updatePER(Patient_Enrollment_Request_gne__c per, Medical_History_gne__c mh) 
	{
		return per;
	}

	/*
	 * Copy common Medical History fields
	 */
	public virtual Patient_Enrollment_Request_gne__c updateFormPER(Patient_Enrollment_Request_gne__c per, Medical_History_gne__c mh) 
	{
		return per;
	}
	
	/**
	 * Generate a PER from a patient.
	 * 
	 */
	private Patient_Enrollment_Request_gne__c generateBasePER(Patient_gne__c patient)
	{
		Patient_Enrollment_Request_gne__c per = new Patient_Enrollment_Request_gne__c();
		
		// patient fields
		per.PER_Source_gne__c = 'Paper';          		
		per.Status__c = 'Draft';    
		per.Patient_gne__c = patient.Id;
		per.Last_Name_gne__c = patient.Name;
		per.First_Name_gne__c = patient.pat_first_name_gne__c;
		per.DOB_gne__c = patient.pat_dob_gne__c!= null ? Datetime.newInstance(patient.pat_dob_gne__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy') : null;
		per.Gender__c = patient.pat_gender_gne__c;
		per.Home_Phone_gne__c = patient.pat_home_phone_gne__c;
		per.Work_or_Cell_Phone_gne__c = patient.pat_work_phone_gne__c;
		per.Email_Address_gne__c = patient.pat_email_gne__c;
		per.OK_to_Contact_Patient__c = patient.OK_to_Contact_Patient_gne__c;
		per.Is_yes_is_death_disease_progression_gne__c = patient.Is_yes_is_death_disease_progression_gne__c;
		per.Is_Patient_Deceased_gne__c = patient.pat_patient_deceased_gne__c;
		per.Preferred_Language_gne__c = patient.Preferred_Language_gne__c;
		
		// Patient Address fields
		List<Patient_Address_gne__c> lstAddr = [SELECT Address_Line_1_gne__c, City_gne__c, State_gne__c, Zip_gne__c 
												FROM Patient_Address_gne__c	
												WHERE Patient_gne__c = :patient.Id
												ORDER BY CreatedDate DESC];

		if (lstAddr.size()>0) 
		{
			per.Street_gne__c = lstAddr[0].Address_Line_1_gne__c;
			per.City_gne__c = lstAddr[0].City_gne__c;
			per.State_gne__c = lstAddr[0].State_gne__c;
			per.Zip__c = lstAddr[0].Zip_gne__c;
		}
		
		// Patient Contact fields
		List<Patient_Contact_gne__c> lstCont = [SELECT First_Name_gne__c,
					LAST_NAME_CONT_gne__c,
					pat_con_Home_Phone_gne__c,
					pat_con_Relationship_to_Patient_gne__c
				FROM Patient_Contact_gne__c
				WHERE pat_con_Patient_gne__c = :patient.Id
				ORDER BY CreatedDate DESC];
		
		if (lstCont.size()>0)	
		{
			per.Alternate_Contact_First_Name_gne__c = lstCont[0].First_Name_gne__c;
			per.Alternate_Contact_Last_Name_gne__c = lstCont[0].LAST_NAME_CONT_gne__c;
			per.Alternate_Contact_Phone_gne__c = lstCont[0].pat_con_Home_Phone_gne__c;
			per.Relationship_to_Patient_gne__c = lstCont[0].pat_con_Relationship_to_Patient_gne__c;
		}			

		// load in user specific settings
		List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :UserInfo.getUserId()];
		
		if (!mpsUsers.IsEmpty())
		{
			GNE_CM_MPS_User_Preferences_Utils.loadReimbursementClinicalContactStoredData(per);
		}	
		
		return per;
	}


	public static Case loadCase(String id)
	{
		Case caseRet = (Case)retrieveObject('Case', id, true);
				
		if (caseRet.Medical_History_gne__c != null)
		{
			caseRet.Medical_History_gne__r = (Medical_History_gne__c)retrieveObject('Medical_History_gne__c', caseRet.Medical_History_gne__c, true);
			caseRet.Medical_History_gne__r.RecordType = (RecordType)retrieveObject('RecordType', caseRet.Medical_History_gne__r.RecordTypeId, true);
			if (caseRet.Medical_History_gne__r.ICD9_Code_1_gne__c != null)
			{
				caseRet.Medical_History_gne__r.ICD9_Code_1_gne__r = (ICD9_Code_gne__c)retrieveObject('ICD9_Code_gne__c', caseRet.Medical_History_gne__r.ICD9_Code_1_gne__c, true);
			}
			if (caseRet.Medical_History_gne__r.ICD9_Code_2_gne__c != null)
			{
				caseRet.Medical_History_gne__r.ICD9_Code_2_gne__r = (ICD9_Code_gne__c)retrieveObject('ICD9_Code_gne__c', caseRet.Medical_History_gne__r.ICD9_Code_2_gne__c, true);
			}
			if (caseRet.Medical_History_gne__r.ICD9_Code_3_gne__c != null)
			{
				caseRet.Medical_History_gne__r.ICD9_Code_3_gne__r = (ICD9_Code_gne__c)retrieveObject('ICD9_Code_gne__c', caseRet.Medical_History_gne__r.ICD9_Code_3_gne__c, true);
			}
		}
		
		if (caseRet.Patient_gne__c != null)
		{
			caseRet.Patient_gne__r = (Patient_gne__c)retrieveObject('Patient_gne__c', caseRet.Patient_gne__c, true);			
		}
		
		return caseRet;
	}
	
	/**
	 * Retrieves object of a given type by its ID.
	 */
	public static sObject retrieveObject (String sObjName, String Id, Boolean bIncludeRO) 
	{
		sObject ret = null;
    
    	sObject[] objs = retrieveObjects(sObjName, new List<String> { Id }, bIncludeRO);
		if (objs.size() > 0)
		{
			ret = objs[0];
		}
		
    	return ret;
	}
	
	public static List<sObject> retrieveObjects(String sObjName, List<String> ids, Boolean bIncludeRO)
	{
		return retrieveObjects(sObjName, ids, bIncludeRO, null);
	}

	public static List<sObject> retrieveObjects(String sObjName, List<String> ids, Boolean bIncludeRO, String orderByClause) 
	{
		Map<String, Schema.SObjectField> M = Schema.getGlobalDescribe().get(sObjName).getDescribe().fields.getMap();
		String flds = '';

		// concat the field list
		for (Schema.SObjectField f : M.values())
		{
			Schema.Describefieldresult dr = f.getDescribe();
    		if (dr.isUpdateable() || bIncludeRO || dr.getName() == 'Id')
    		{
      			if (flds.length() > 0)
      			{
        			flds += ',';
      			}
      			flds += dr.getName();
    		}
  		}

  		String soql = 'SELECT ' + flds + ' FROM ' + sObjName + ' WHERE Id in :ids' + (orderByClause != null ? ' ' + orderByClause : '');
    	sObject[] objs=Database.query(soql);
    	
    	return objs;
	}


	public static String coalesce(String target, String source)
	{
		return target==null ? source : target;
	}

	public static Date coalesce(Date target, Date source)
	{
		return target==null ? source : target;
	}
		
		
	/*
	 * Returns destination pickval on if mhValue matches a pickval in target
	 */
	public static String getMapPickVal(String mhValue, Schema.DescribeFieldResult fld)
	{
		String retVal=null;
		
		if (mhValue!=null)
		{
			for (Schema.PicklistEntry f : fld.getPicklistValues())
			{
				if (f.getValue()==mhValue) 
				{
					retVal=f.getValue();
				}
			}
		}
		
		return retVal;
	}
		
	/*
	 * Returns destination pickval on if mhValue matches a pickval in target
	 */
	public static String getMapMultiPickVal(String mhValue, Schema.DescribeFieldResult fld)
	{
		String retVal=null;
		
		if (mhValue!=null)
		{
			retVal='';
			for (String s : mhValue.split(';'))
			{
				for (Schema.PicklistEntry f : fld.getPicklistValues())
				{
					if (f.getValue()==s) 
					{
						retVal+=(f.getValue() + ';');
					}
				}
			}
		}
		
		return retVal;
	}
		
		
	/**
	 * Picklist Helper
	 */
	public virtual String getPERDXPickVal(String ICD9Code, Schema.DescribeFieldResult fld)
	{
		String retVal=null;
		
		if (ICD9Code!=null)
		{
			for (Schema.PicklistEntry f : fld.getPicklistValues())
			{
				if (f.getValue().indexOf(ICD9Code)>-1) 
				{
					retVal=f.getValue();
				}
			}
			if (retVal==null)
			{
				for (Schema.PicklistEntry f : fld.getPicklistValues())
				{
					if (f.getValue().startsWith('Other')) 
					{
						retVal=f.getValue();
					}
				}
				
			}
		}
		
		return retVal;
	}
	
	private String mapInsuranceProductTypeToPER(String productType)
	{
		if (productType == 'Indemnity' || productType == 'POS' || productType == 'PPO')
		{
			return productType;
		}		
		else if (productType == 'EPO' || productType == 'HMO')
		{
			return 'HMO/EPO';
		}
		else if (productType == 'Managed Medicaid' || productType == 'Medicare Part A' || productType == 'Medicare Part B' || productType == 'Medicare Advantage (Part C)' || productType == 'Medicare Supplemental')
		{
			return 'Medicare/ Medicaid';
		}
		else
		{
			return null;
		}
	}
		
	public class MergeMultiSelectReturn
	{
		public String multiSelectValue { get; set; }
		public String multiSelectOtherValue { get; set; }
		
	}

	/*
	 * helper to trim strings
	 */
	public static String truncateValue(String sval, Schema.DescribeFieldResult fld)
	{
		String sRet=sval;
		
		if (sval!=null && sval.length()>fld.getLength())
		{
			sRet=sval.substring(0, fld.getLength());
		}
		return sRet;
	}
	
	
	/*
	 * Returns merged multiselect values
	 */
	public static MergeMultiSelectReturn MergeMultiSelect(String target, String targetOther, String source, Schema.DescribeFieldResult fld, Boolean useOther)
	{ 
		MergeMultiSelectReturn mmsr=new MergeMultiSelectReturn();
		
        // merge the previous treatments
    	source = (source==null) ? '' : source;
    	mmsr.multiSelectValue = (target==null) ? '' : target;
    	mmsr.multiSelectOtherValue = targetOther==null ? '' : targetOther;
        	
    	for (String s : source.split(';'))
    	{
    		String prev=getMapPickVal(s, fld);
    
    		if (useOther && prev==null)
    		{
    			if (mmsr.multiSelectValue.indexOf('Other')==-1)
    			{
    				mmsr.multiSelectValue+=('Other;');
    			}
    			if (mmsr.multiSelectOtherValue.indexOf(s)==-1)
    			{
    				mmsr.multiSelectOtherValue+=(s +';');
    			}
    			
    		}    		
    		else if (prev != null && mmsr.multiSelectValue.indexOf(prev) == -1)
    		{
    			mmsr.multiSelectValue += (prev + ';');
    		}
    		
    	}
    	
    	// remove unwanted entries
    	if (mmsr.multiSelectOtherValue!=null)
    	{
    		mmsr.multiSelectOtherValue=mmsr.multiSelectOtherValue.replace('Not Provided;', '');
    		mmsr.multiSelectOtherValue=mmsr.multiSelectOtherValue.replace('Not Provided', '');
    	}
        return mmsr;
	}
}