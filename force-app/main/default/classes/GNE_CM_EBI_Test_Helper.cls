public class GNE_CM_EBI_Test_Helper
{
	public static final Map<String,Map<String,Object>> DEFAULTS = new Map<String,Map<String,Object>>{
		'adminCode' => new Map<String,Object>{
			'Admin_Code_gne__c' => '00000',
    		'Product_gne__c' => 'Avastin'
		},
		'benefitVerificationResponse' => new Map<String,Object>{
    		'Error_Message_gne__c' => '---',
    		'Product_gne__c' => 'Avastin',
    		'Status_gne__c' => 'Success'
		},
		'diagnosisCode' => new Map<String,Object>{
			'Diagnosis_Code_gne__c' => '000',
    		'Diagnosis_Rank_gne__c' => 'Primary'
		},
		'payerMapping' => new Map<String,Object>{
			'TransEngen_Payer_Id_gne__c' => 00000,
			'TransEngen_Payer_Name_gne__c' => 'Utah Medicaid'
		},
		'payerResult' => new Map<String,Object>{
    		'Full_Response_gne__c' => '---',
    		'Group_Number_gne__c' => 'XX00000',
    		'Insurance_Status_gne__c' => 'Active',
    		'Life_Max_gne__c' => 'N/A',
    		'Member_ID__c' => null,
    		'Other_Response_Message_gne__c' => '---',
    		'Payer_ID_gne__c' => 00000,
    		'Payer_Name_gne__c' => 'Utah Medicaid',
    		'Payer_Rank_gne__c' => null,
    		'Plan_Coverage_Message_gne__c' => '---',
    		'Plan_Effective_Date_gne__c' => system.today(),
    		'Plan_End_Date_gne__c' => system.today().addDays(30),
    		'Plan_Name_gne__c' => 'POS Choice II',
    		'Plan_Type_gne__c' => 'HMO',
    		'Relationship_gne__c' => null,
    		'Remaining_Benefit_gne__c' => 'N/A',
    		'Response_Error_Message_gne__c' => '---',
    		'Rx_Benefit_Manager_gne__c' => 'N/A',
    		'Rx_Benefit_Manager_Phone_gne__c' => '000-000-0000',
    		'Succeeded_gne__c' => 'Yes',
    		'Transaction_ID_gne__c' => null
    	},
    	'planAccumulator' => new Map<String,Object>{
    		'In_Network_gne__c' => true,
    		'Value_Name_gne__c' => '---',
    		'Value_Result_gne__c' => '---'
    	},
    	'request' => new Map<String,Object>{
    		'Benefit_Investigation_Date_Time_gne__c' => system.now(),
    		'Case_gne__c' => null,
    		'NPI_gne__c' => '0000000000',
    		'PER_gne__c' => null,
    		'Prescriber_gne__c' => null,
    		'Prescriber_First_Name_gne__c' => 'John',
    		'Prescriber_Last_Name_gne__c' => 'Doe',
    		'Prescriber_State_gne__c' => 'CA',
    		'Product_Name_gne__c' => 'Avastin',
    		'Requester_gne__c' => null,
    		'Retain_gne__c' => false,
    		'Service_Delivery_Date_gne__c' => system.today().addDays(7),
    		'Service_Delivery_Location_gne__c' => 'AIC'
    	},
    	'ruleIssue' => new Map<String,Object>{
    		'Benefit_Investigation_ID_gne__c' => null,
    		'Case_gne__c' => null,
    		'Code_Type_gne__c' => 'Admin',
    		'Coverage_Information_gne__c' => 'Copay applies',
    		'TE_Coverage_Information_gne__c' => 'Specialty Pharmacy',
    		'Description_gne__c' => '---',
    		'Drug_gne__c' => 'Avastin',
    		'eBI_Transaction_gne__c' => '---',
    		'Issue_Description_gne__c' => '---',
    		'Issue_Type_gne__c' => 'Rule Issue',
    		'Network_gne__c' => 'In Network',
    		'Next_Approval_Process_tech_gne__c' => 'None',
    		'Payer_gne__c' => null,
    		'Plan_Product_gne__c' => null,
    		'RuleId_gne__c' => '00000',
    		'Section_of_eBI_271_Response_gne__c' => 'Coverage',
    		'Status_gne__c' => 'Closed - Approved',
    		'Comments_gne__c' => '---',
    		'TE_Resolution_Type_gne__c' => 'Updated Rule Activated in PRD',
    		'TE_Rule_Suspended__c' => false,
    		'Type_gne__c' => 'New'
    	},
    	'ruleResult' => new Map<String,Object>{
    		'Value_Name_gne__c' => '---',
    		'Value_Result_gne__c' => '---'
    	},
    	'ruleResultSet' => new Map<String,Object>{
    		'Coverage_Message_gne__c' => '---',
    		'Coverage_Status_gne__c' => 'Covered',
    		'Diagnosis_Code_gne__c' => null,
    		'Diagnosis_Rank_gne__c' => 'Primary',
    		'Diagnosis_Rank_Coverage_Message_gne__c' => '---',
    		'In_Network_gne__c' => true,
    		'Rule_ID_gne__c' => '0000',
    		'Service_Code_gne__c' => '00000'
    	},
    	'specialtyPharmacy' => new Map<String,Object>{
    		
    	},
    	'specialtyPharmacyDefinition' => new Map<String,Object>{
    		'Specialty_Provider_City_gne__c' => 'San Francisco',
    		'Specialty_Provider_Name_gne__c' => 'John Doe',
    		'Specialty_Provider_Phone_Number_gne__c' => null,
    		'Specialty_Provider_State_gne__c' => 'CA'
    	},
    	'transactionStaging' => new Map<String,Object>{
    		'Begin_Date_gne__c' => '12/01/2012',
    		'Benefit_Investigation_Date_gne__c' => '12/02/2012',
    		'Benefit_Investigation_Time_gne__c' => '12:24',
    		'Diagnosis_Rank_gne__c' => 1,
    		'Diagnosis_Rank_Coverage_Message_gne__c' => 'test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1test1',
    		'Drug_Benefit_Manager_gne__c' => 'eaguayo',
    		'Drug_Benefit_Phone_gne__c' => '0813214549',
    		'eBI_Response_Error_Message_gne__c' => 'test2test2test2test2test2test2test2test2test2test2test2test2test2test2test2test2test2test2test2',
            'End_Date_gne__c' => '12/03/2012',
			'Group_Number_gne__c'  => '1235',
            'ICD9_Code_gne__c' => 'ABCDEF1' , 
            'IN_Buy_and_Bill_Ind_gne__c' => 'XXXXX',
            'IN_Copay_Applies_Ind_gne__c' => 'XXXXX',
            'IN_Coverage_Message_gne__c' => 'XXXXX',
            'IN_Coverage_Rule_ID_gne__c' => 'XXXXX',
            'IN_Coverage_Status_gne__c' => 'XXXXX',
            'IN_Deductible_Applies_Ind_gne__c' => 'XXXXX',
            'IN_Med_Doc_Ind_gne__c' => 'XXXXX',
            'IN_Notification_Ind_gne__c' => 'XXXXX',
            'IN_OOP_Max_Applies_Ind_gne__c' => 'XXXXX',
            'IN_Outpatient_Hospital_Copay_Amount_gne__c' => 'XXXXX',
            'IN_Outpatient_Hosp_Deduct_Met_Amnt_gne__c' => 'XXXXX',
            'IN_Outpatient_Hospital_Deduct_Amount_gne__c' => 'XXXXX',
            'IN_Outpatient_Surgical_Copay_Amount_gne__c' => 'XXXXX',
            'IN_Outpatient_Surgical_Deduct_Amount_gne__c' => 'XXXXX', 
            'IN_Outpatient_Surgic_Deduct_Met_Amnt_gne__c' => 'XXXXX', 
            'IN_Patient_Cost_Share_Applies_Ind_gne__c' => 'XXXXX', 
            'IN_Plan_Family_Deductible_Amount_gne__c' => 'XXXXX',
            'IN_Plan_Family_Deductible_Met_Amount_gne__c' => 'XXXXX', 
            'IN_Plan_Family_OOP_Max_Amount_gne__c' => 'XXXXX', 
            'IN_Plan_Family_OOP_Met_Amount_gne__c' => 'XXXXX', 
            'IN_Plan_Individual_Deductible_Amount_gne__c' => 'XXXXX', 
            'IN_Plan_Ind_Deductible_Met_Amount_gne__c' => 'XXXXX',
            'IN_Plan_Individual_OOP_Max_Amount_gne__c' => 'XXXXX', 
            'IN_Plan_Individual_OOP_Met_Amount_gne__c' => 'XXXXX', 
            'IN_Plan_Insurer_Cost_Share_gne__c' => 'XXXXX', 
            'IN_Plan_Office_Copay_Amount_gne__c' => 'XXXXX', 
            'IN_Plan_Patient_Cost_Share_gne__c' => 'XXXXX',
            'IN_Pre_Determination_Ind_gne__c' => 'XXXXX', 
            'IN_Prior_Auth_Ind_gne__c' => 'XXXXX', 
            'IN_Specialty_Pharmacy_ID_List_gne__c' => '11111,22222', 
            'IN_Specialty_Pharmacy_Ind_gne__c' => 'XXXXX', 
            'IN_Spend_Down_Met_Date_gne__c' => '12/04/2013',
            'IN_Spend_Down_Effective_Date_gne__c' => '12/08/2012',
            'IN_Spend_Down_Amount_gne__c' => 'XXXXX', 
/*done*/    'Insurance_Status_gne__c' => 'Active',
            'JCode_gne__c' => 'XXXXX', 
/*done*/    'Lifetime_Benefit_Max_gne__c' => 'Lifetime', 
/*done*/    'Lifetime_Benefit_Remaining_gne__c' => 'XXXXX',
            'OUT_Buy_and_Bill_Ind_gne__c' => 'Yes', 
            'OUT_Copay_Applies_Ind_gne__c' => 'XXXXX',
            'OUT_Coverage_Message_gne__c' => 'XXXXX', 
            'OUT_Coverage_Rule_ID_gne__c' => 'XXXXX', 
            'OUT_Coverage_Status_gne__c' => 'XXXXX', 
            'OUT_Deductible_Applies_Ind_gne__c' => 'XXXXX', 
            'OUT_Med_Doc_Ind_gne__c' => 'XXXXX', 
            'OUT_Notification_Ind_gne__c' => 'XXXXX', 
            'OUT_OOP_Max_Applies_Ind_gne__c' => 'XXXXX',
            'OUT_Outpatient_Hospital_Deduct_Amnt_gne__c' => 'XXXXX', 
            'OUT_Outpatient_Hosp_Deduct_Met_Amnt_gne__c' => 'XXXXX', 
            'OUT_Outpatient_Surgical_Copay_Amount_gne__c' => 'XXXXX', 
            'OUT_Outpatient_Surgical_Deduct_Amnt_gne__c' => 'XXXXX',
            'OUT_Outpatient_Surg_Deduct_Met_Amnt_gne__c' => 'XXXXX',
            'OUT_Outpatient_Hospital_Copay_Amount_gne__c' => 'XXXXX',
            'OUT_Patient_Cost_Share_Applies_Ind_gne__c' => 'XXXXX', 
            'OUT_Plan_Family_Deductible_Amount_gne__c' => 'XXXXX', 
            'OUT_Plan_Family_Deduct_Met_Amount_gne__c' => 'XXXXX', 
            'OUT_Plan_Family_OOP_Max_Amount_gne__c' => 'XXXXX',
            'OUT_Plan_Family_OOP_Met_Amount_gne__c' => 'XXXXX', 
            'OUT_Plan_Individual_Deduct_Met_Amnt_gne__c' => 'XXXXX', 
            'OUT_Plan_Individual_Deduct_Amount_gne__c' => 'XXXXX', 
            'OUT_Plan_Individual_OOP_Max_Amount_gne__c' => 'XXXXX', 
            'OUT_Plan_Individual_OOP_Met_Amount_gne__c' => 'XXXXX',
            'OUT_Plan_Insurer_Cost_Share_gne__c' => 'XXXXX', 
            'OUT_Plan_Office_Copay_Amount_gne__c' => 'XXXXX', 
            'OUT_Plan_Patient_Cost_Share_gne__c' => 'XXXXX', 
            'OUT_Pre_Determination_Ind_gne__c' => 'XXXXX', 
            'OUT_Prior_Auth_Ind_gne__c' => 'XXXXX', 
            'OUT_Specialty_Pharmacy_ID_List_gne__c' => '22222,11111',
            'OUT_Specialty_Pharmacy_Ind_gne__c' => 'XXXXX',
            'OUT_Spend_Down_Amount_gne__c' => 'XXXXX', 
            'OUT_Spend_Down_Effective_Date_gne__c' => '12/08/2012', 
            'OUT_Spend_Down_Met_Date_gne__c' => '12/09/1999', 
/*done*/    'Other_Response_Message_gne__c' => 'test4 fdkldklfjoeig giejilej oiej gheifh aeoi joej fhgoehfalskfn lehfoai ldkfn ioeh oafnalkdf ',             
/*done*/    'Plan_Coverage_Message_gne__c' => 'test3 test3 test3 dfj laskdjf oeijklgolke f',
/*done*/    'Plan_Type_gne__c' => 'plan type test', 
/*done*/    'Policy_Rank_gne__c' => 1, 
/*done*/    'Product_Name_gne__c' => 'the product name ',
/*done*/    'Relationship_gne__c' => 1, 
/*done*/    'Service_Delivery_Location_gne__c' => 1, 
/*done*/    'Subscriber_Date_of_Birth_gne__c' => '12/04/1972', 
/*done*/    'Subscriber_First_Name_gne__c' => 'XXXXX',
/*done*/    'Subscriber_ID_gne__c' => 'XXXXX', 
/*done*/    'Subscriber_Last_Name_gne__c' => 'XXXXX', 
/*done*/    'Subscriber_Middle_Name_gne__c' => 'X',
            'Transaction_Number_gne__c' => 12345,           
/*done*/	'Prescriber_State_gne__c' => 'AL',
/*?*/		'Patient_Date_of_Birth_gne__c' => '12/04/1989',
/*?*/		'Patient_First_Name_gne__c' => 'X',
/*?*/		'Patient_Gender_gne__c' => 'X',
/*?*/		'Patient_Last_Name_gne__c' => 'X',
/*done?*/   'Patient_Member_ID_gne__c' => 'X',
/*?*/		'Patient_Middle_Initial_gne__c' => 'X',
/*done*/	'Service_Delivery_Date_gne__c' => '12/04/2012',
/*done*/	'NPI_gne__c' => '123456'    	
    	}
	};
	
	public class SimpleEbiStructure
    {
    	public Patient_gne__c patient { get; set; }
    	public GNE_CM_EBI_Request__c request { get; set; }
    	public GNE_CM_EBI_Admin_Code__c adminCode { get; set; }
    	public GNE_CM_EBI_Admin_Code_Request__c adminCodeRequest { get; set; }
    	public GNE_CM_EBI_Diagnosis_Code__c diagnosisCode { get; set; }
    	public GNE_CM_EBI_Benefit_Verification_Response__c benefitVerificationResponse{ get; set; }
    	public GNE_CM_EBI_Rule_Issue__c ruleIssue { get; set; }
    	public Account payer { get; set; }
    	public GNE_CM_EBI_Payer_Mapping__c payerMapping { get; set; }
    	public GNE_CM_EBI_Payer_Result__c payerResult { get; set; }
    	public GNE_CM_EBI_Plan_Accumulator__c planAccumulator { get; set; }
    	public GNE_CM_EBI_Rule_Result_Set__c ruleResultSet { get; set; }
    	public GNE_CM_EBI_Rule_Result__c ruleResult { get; set; }
    	public GNE_CM_EBI_Specialty_Pharmacy__c specialtyPharmacy { get; set; }
    	public GNE_CM_EBI_Specialty_Pharmacy_Definition__c specialtyPharmacyDefintion { get; set; }
    	public GNE_CM_EBI_Transaction_Staging__c transactionStaging { get; set; }
    	
    	public SimpleEbiStructure(){}
    }
    
    public static GNE_CM_EBI_Admin_Code__c createAdminCode(Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Admin_Code__c adminCode = new GNE_CM_EBI_Admin_Code__c();
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('adminCode') && !DEFAULTS.get('adminCode').isEmpty()
    		? DEFAULTS.get('adminCode')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		adminCode.put(fName, oValues.get(fName));
    	}
    	return adminCode;
    }
    
    public static GNE_CM_EBI_Admin_Code__c createAdminCode()
    {
    	return createAdminCode(new Map<String,Object>());
    }
    public static GNE_CM_EBI_Admin_Code_Request__c createAdminCodeRequest(GNE_CM_EBI_Request__c r, GNE_CM_EBI_Admin_Code__c ac)
    {
    	return new GNE_CM_EBI_Admin_Code_Request__c(
    		EBI_Request_gne__c = r.Id,
    		EBI_Admin_Code_gne__c = ac.Id
    	);
    }
    
    public static GNE_CM_EBI_Admin_Code_Request__c createAdminCodeRequest(Id requestId, Id adminCodeId)
    {
    	return new GNE_CM_EBI_Admin_Code_Request__c(
    		EBI_Request_gne__c = requestId,
    		EBI_Admin_Code_gne__c = adminCodeId
    	);
    }
    
    public static GNE_CM_EBI_Benefit_Verification_Response__c createBenefitVerificationResponse(GNE_CM_EBI_Request__c r, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Benefit_Verification_Response__c benefitVerificationResponse = new GNE_CM_EBI_Benefit_Verification_Response__c(
    		Request_gne__c = r.Id,
    		Patient_gne__c = r.Patient_gne__c
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('benefitVerificationResponse') && !DEFAULTS.get('benefitVerificationResponse').isEmpty()
    		? DEFAULTS.get('benefitVerificationResponse')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		benefitVerificationResponse.put(fName, oValues.get(fName));
    	}
    	return benefitVerificationResponse;
    }
    
    public static GNE_CM_EBI_Benefit_Verification_Response__c createBenefitVerificationResponse(GNE_CM_EBI_Request__c r)
    {
    	return createBenefitVerificationResponse(r, null);
    }
    
    public static GNE_CM_EBI_Benefit_Verification_Response__c createBenefitVerificationResponse(Id requestId, Id patientId, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Benefit_Verification_Response__c benefitVerificationResponse = new GNE_CM_EBI_Benefit_Verification_Response__c(
    		Request_gne__c = requestId,
    		Patient_gne__c = patientId
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('benefitVerificationResponse') && !DEFAULTS.get('benefitVerificationResponse').isEmpty()
    		? DEFAULTS.get('benefitVerificationResponse')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		benefitVerificationResponse.put(fName, oValues.get(fName));
    	}
    	return benefitVerificationResponse;
    }
    
    public static GNE_CM_EBI_Benefit_Verification_Response__c createBenefitVerificationResponse(Id requestId, Id patientId)
    {
    	return createBenefitVerificationResponse(requestId, patientId, null);
    }
    
    public static GNE_CM_EBI_Diagnosis_Code__c createDiagnosisCode(GNE_CM_EBI_Request__c r, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Diagnosis_Code__c diagnosisCode = new GNE_CM_EBI_Diagnosis_Code__c(
    		EBI_Request_gne__c = r.Id
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('diagnosisCode') && !DEFAULTS.get('diagnosisCode').isEmpty()
    		? DEFAULTS.get('diagnosisCode')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		diagnosisCode.put(fName, oValues.get(fName));
    	}
    	return diagnosisCode;
    }
    
    public static GNE_CM_EBI_Diagnosis_Code__c createDiagnosisCode(GNE_CM_EBI_Request__c r)
    {
    	return createDiagnosisCode(r, null);
    }
    
    public static GNE_CM_EBI_Diagnosis_Code__c createDiagnosisCode(Id requestId, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Diagnosis_Code__c diagnosisCode = new GNE_CM_EBI_Diagnosis_Code__c(
    		EBI_Request_gne__c = requestId
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('diagnosisCode') && !DEFAULTS.get('diagnosisCode').isEmpty()
    		? DEFAULTS.get('diagnosisCode')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		diagnosisCode.put(fName, oValues.get(fName));
    	}
    	return diagnosisCode;
    }
    
    public static GNE_CM_EBI_Diagnosis_Code__c createDiagnosisCode(Id requestId)
    {
    	return createDiagnosisCode(requestId, null);
    }
    
    public static GNE_CM_EBI_Payer_Mapping__c createPayerMapping(Account a, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Payer_Mapping__c payerMapping = new GNE_CM_EBI_Payer_Mapping__c(
    		Account_gne__c = a.Id
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('payerMapping') && !DEFAULTS.get('payerMapping').isEmpty()
    		? DEFAULTS.get('payerMapping')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		payerMapping.put(fName, oValues.get(fName));
    	}
    	return payerMapping;
    }
    
    public static GNE_CM_EBI_Payer_Mapping__c createPayerMapping(Account a)
    {
    	return createPayerMapping(a, null);
    }
    
    public static GNE_CM_EBI_Payer_Mapping__c createPayerMapping(Id accountId, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Payer_Mapping__c payerMapping = new GNE_CM_EBI_Payer_Mapping__c(
    		Account_gne__c = accountId
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('payerMapping') && !DEFAULTS.get('payerMapping').isEmpty()
    		? DEFAULTS.get('payerMapping')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		payerMapping.put(fName, oValues.get(fName));
    	}
    	return payerMapping;
    }
    
    public static GNE_CM_EBI_Payer_Mapping__c createPayerMapping(Id accountId)
    {
    	return createPayerMapping(accountId, null);
    }
    
    public static GNE_CM_EBI_Payer_Result__c createPayerResult(GNE_CM_EBI_Benefit_Verification_Response__c bvr, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Payer_Result__c payerResult = new GNE_CM_EBI_Payer_Result__c(
    		EBI_Benefit_Verification_Response_gne__c = bvr.Id
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('payerResult') && !DEFAULTS.get('payerResult').isEmpty()
    		? DEFAULTS.get('payerResult')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		payerResult.put(fName, oValues.get(fName));
    	}
    	return payerResult;
    }
    
    public static GNE_CM_EBI_Payer_Result__c createPayerResult(GNE_CM_EBI_Benefit_Verification_Response__c bvr)
    {
    	return createPayerResult(bvr, null);
    }
    
    public static GNE_CM_EBI_Payer_Result__c createPayerResult(Id benefitVerificationResponseId, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Payer_Result__c payerResult = new GNE_CM_EBI_Payer_Result__c(
    		EBI_Benefit_Verification_Response_gne__c = benefitVerificationResponseId
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('payerResult') && !DEFAULTS.get('payerResult').isEmpty()
    		? DEFAULTS.get('payerResult')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		payerResult.put(fName, oValues.get(fName));
    	}
    	return payerResult;
    }
    
    public static GNE_CM_EBI_Payer_Result__c createPayerResult(Id benefitVerificationResponseId)
    {
    	return createPayerResult(benefitVerificationResponseId, null);
    }
    
    public static GNE_CM_EBI_Plan_Accumulator__c createPlanAccumulator(GNE_CM_EBI_Payer_Result__c pr, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Plan_Accumulator__c planAccumulator = new GNE_CM_EBI_Plan_Accumulator__c(
    		EBI_Payer_Result_gne__c = pr.Id
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('planAccumulator') && !DEFAULTS.get('planAccumulator').isEmpty()
    		? DEFAULTS.get('planAccumulator')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		planAccumulator.put(fName, oValues.get(fName));
    	}
    	return planAccumulator;
    }
    
    public static GNE_CM_EBI_Plan_Accumulator__c createPlanAccumulator(GNE_CM_EBI_Payer_Result__c pr)
    {
    	return createPlanAccumulator(pr, null);
    }
    
    public static GNE_CM_EBI_Plan_Accumulator__c createPlanAccumulator(Id payerResultId, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Plan_Accumulator__c planAccumulator = new GNE_CM_EBI_Plan_Accumulator__c(
    		EBI_Payer_Result_gne__c = payerResultId
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('planAccumulator') && !DEFAULTS.get('planAccumulator').isEmpty()
    		? DEFAULTS.get('planAccumulator')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		planAccumulator.put(fName, oValues.get(fName));
    	}
    	return planAccumulator;
    }
    
    public static GNE_CM_EBI_Plan_Accumulator__c createPlanAccumulator(Id payerResultId)
    {
    	return createPlanAccumulator(payerResultId, null);
    }
    
	public static GNE_CM_EBI_Request__c createRequest(Patient_gne__c p, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Request__c request = new GNE_CM_EBI_Request__c(
    		Patient_gne__c = p.Id
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('request') && !DEFAULTS.get('request').isEmpty()
    		? DEFAULTS.get('request')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		request.put(fName, oValues.get(fName));
    	}
    	return request;
    }
    
    public static GNE_CM_EBI_Request__c createRequest(Patient_gne__c p)
    {
    	return createRequest(p, null);
    }
    
    public static GNE_CM_EBI_Request__c createRequest(Id patientId, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Request__c request = new GNE_CM_EBI_Request__c(
    		Patient_gne__c = patientId
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('request') && !DEFAULTS.get('request').isEmpty()
    		? DEFAULTS.get('request')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		request.put(fName, oValues.get(fName));
    	}
    	return request;
    }
    
    public static GNE_CM_EBI_Request__c createRequest(Id patientId)
    {
    	return createRequest(patientId, null);
    }
    
    public static GNE_CM_EBI_Rule_Issue__c createRuleIssue(Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Rule_Issue__c ruleIssue = new GNE_CM_EBI_Rule_Issue__c();
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('ruleIssue') && !DEFAULTS.get('ruleIssue').isEmpty()
    		? DEFAULTS.get('ruleIssue')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		ruleIssue.put(fName, oValues.get(fName));
    	}
    	return ruleIssue;
    }
    
    public static GNE_CM_EBI_Rule_Issue__c createRuleIssue()
    {
    	return createRuleIssue(null);
    }
    
    public static GNE_CM_EBI_Rule_Result__c createRuleResult(GNE_CM_EBI_Rule_Result_Set__c rrs, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Rule_Result__c ruleResult = new GNE_CM_EBI_Rule_Result__c(
    		EBI_Rule_Result_Set_gne__c = rrs.Id
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('ruleResult') && !DEFAULTS.get('ruleResult').isEmpty()
    		? DEFAULTS.get('ruleResult')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		ruleResult.put(fName, oValues.get(fName));
    	}
    	return ruleResult;
    }
    
    public static GNE_CM_EBI_Rule_Result__c createRuleResult(GNE_CM_EBI_Rule_Result_Set__c rrs)
    {
    	return createRuleResult(rrs, null);
    }
    
    public static GNE_CM_EBI_Rule_Result__c createRuleResult(Id ruleResultSetId, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Rule_Result__c ruleResult = new GNE_CM_EBI_Rule_Result__c(
    		EBI_Rule_Result_Set_gne__c = ruleResultSetId
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('ruleResult') && !DEFAULTS.get('ruleResult').isEmpty()
    		? DEFAULTS.get('ruleResult')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		ruleResult.put(fName, oValues.get(fName));
    	}
    	return ruleResult;
    }
    
    public static GNE_CM_EBI_Rule_Result__c createRuleResult(Id ruleResultSetId)
    {
    	return createRuleResult(ruleResultSetId, null);
    }
    
    public static GNE_CM_EBI_Rule_Result_Set__c createRuleResultSet(GNE_CM_EBI_Payer_Result__c pr, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Rule_Result_Set__c ruleResultSet = new GNE_CM_EBI_Rule_Result_Set__c(
    		Payer_Result_gne__c = pr.Id
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('ruleResultSet') && !DEFAULTS.get('ruleResultSet').isEmpty()
    		? DEFAULTS.get('ruleResultSet')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		ruleResultSet.put(fName, oValues.get(fName));
    	}
    	return ruleResultSet;
    }
    
    public static GNE_CM_EBI_Rule_Result_Set__c createRuleResultSet(GNE_CM_EBI_Payer_Result__c pr)
    {
    	return createRuleResultSet(pr, null);
    }
    
    public static GNE_CM_EBI_Rule_Result_Set__c createRuleResultSet(Id payerResultId, Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Rule_Result_Set__c ruleResultSet = new GNE_CM_EBI_Rule_Result_Set__c(
    		Payer_Result_gne__c = payerResultId
    	);
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('ruleResultSet') && !DEFAULTS.get('ruleResultSet').isEmpty()
    		? DEFAULTS.get('ruleResultSet')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		ruleResultSet.put(fName, oValues.get(fName));
    	}
    	return ruleResultSet;
    }
    
    public static GNE_CM_EBI_Rule_Result_Set__c createRuleResultSet(Id payerResultId)
    {
    	return createRuleResultSet(payerResultId, null);
    }
    
    public static SimpleEbiStructure createSimpleEbiStructure(Map<String,Map<String,Object>> fValues)
    {
    	SimpleEbiStructure ses = new SimpleEbiStructure();
		if (fValues == null) {
			fValues = new Map<String,Map<String,Object>>();
		}
		ses.patient = GNE_CM_Test_Helper.createPatient('Marcellus', 'Wallace');
		insert ses.patient;
		ses.request =
			fValues.containsKey('request')
			? createRequest(ses.patient ,fValues.get('request'))
			: createRequest(ses.patient);
		insert ses.request;
		ses.adminCode =
			fValues.containsKey('adminCode')
			? createAdminCode(fValues.get('adminCode'))
			: createAdminCode();
		insert ses.adminCode;
		ses.adminCodeRequest = createAdminCodeRequest(ses.request, ses.adminCode);
		insert ses.adminCodeRequest;
		ses.diagnosisCode =
			fValues.containsKey('disgnosisCode')
			? createDiagnosisCode(ses.request, fValues.get('disgnosisCode'))
			: createDiagnosisCode(ses.request);
		insert ses.diagnosisCode;
		ses.payer = new Account(
			recordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Payer').getRecordTypeId(),
			Name = 'EBI Payer',
			Status_gne__c = 'Active',
			MDMID_Status_gne__c = 'Active'
		);
		insert ses.payer;
		ses.payerMapping =
			fValues.containsKey('payerMapping')
			? createPayerMapping(ses.payer, fValues.get('payerMapping'))
			: createPayerMapping(ses.payer);
		insert ses.payerMapping;
		ses.benefitVerificationResponse =
			fValues.containsKey('benefitVerificationResponse')
			? createBenefitVerificationResponse(ses.request, fValues.get('benefitVerificationResponse'))
			: createBenefitVerificationResponse(ses.request);
		insert ses.benefitVerificationResponse;
		ses.ruleIssue =
			fValues.containsKey('ruleIssue')
			? createRuleIssue(fValues.get('ruleIssue'))
			: createRuleIssue();
		insert ses.ruleIssue;
		ses.payerResult =
			fValues.containsKey('payerResult')
			? createPayerResult(ses.benefitVerificationResponse, fValues.get('payerResult'))
			: createPayerResult(ses.benefitVerificationResponse);
		insert ses.payerResult;
		ses.planAccumulator =
			fValues.containsKey('planAccumulator')
			? createPlanAccumulator(ses.payerResult, fValues.get('planAccumulator'))
			: createPlanAccumulator(ses.payerResult);
		insert ses.planAccumulator;
		ses.ruleResultSet = fValues.containsKey('ruleResultSet')
			? createRuleResultSet(ses.payerResult, fValues.get('ruleResultSet'))
			: createRuleResultSet(ses.payerResult);
		insert ses.ruleResultSet;
		ses.ruleResult = fValues.containsKey('ruleResult')
			? createRuleResult(ses.ruleResultSet, fValues.get('ruleResult'))
			: createRuleResult(ses.ruleResultSet);
		insert ses.ruleResult;
		ses.specialtyPharmacyDefintion = fValues.containsKey('specialtyPharmacyDefintion')
			? createSpecialtyPharmacyDefinition(fValues.get('specialtyPharmacyDefintion'))
			: createSpecialtyPharmacyDefinition();
		insert ses.specialtyPharmacyDefintion;
		ses.specialtyPharmacy = createSpecialtyPharmacy(ses.ruleResultSet, ses.specialtyPharmacyDefintion);
		insert ses.specialtyPharmacy;
		ses.transactionStaging =
			fValues.containsKey('transactionStaging')
			? createTransactionStaging(fValues.get('transactionStaging'))
			: createTransactionStaging();
		insert ses.transactionStaging;
    	return ses;
    }
    
    public static SimpleEbiStructure createSimpleEbiStructure()
    {
    	return createSimpleEbiStructure(null);
    }
    
    public static GNE_CM_EBI_Specialty_Pharmacy__c createSpecialtyPharmacy(GNE_CM_EBI_Rule_Result_Set__c rrs, GNE_CM_EBI_Specialty_Pharmacy_Definition__c spd)
    {
    	return new GNE_CM_EBI_Specialty_Pharmacy__c(
    		EBI_Rule_Result_Set_gne__c = rrs.Id,
    		EBI_Specialty_Pharmacy_Definition_gne__c = spd.Id
    	);
    }
    
    public static GNE_CM_EBI_Specialty_Pharmacy__c createSpecialtyPharmacy(Id ruleResultSetId, Id specialtyPharmacyDefinitionId)
    {
    	return new GNE_CM_EBI_Specialty_Pharmacy__c(
    		EBI_Rule_Result_Set_gne__c = ruleResultSetId,
    		EBI_Specialty_Pharmacy_Definition_gne__c = specialtyPharmacyDefinitionId
    	);
    }
    
    public static GNE_CM_EBI_Specialty_Pharmacy_Definition__c createSpecialtyPharmacyDefinition(Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Specialty_Pharmacy_Definition__c specialtyPharmacyDefinition = new GNE_CM_EBI_Specialty_Pharmacy_Definition__c();
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('specialtyPharmacyDefinition') && !DEFAULTS.get('specialtyPharmacyDefinition').isEmpty()
    		? DEFAULTS.get('specialtyPharmacyDefinition')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		specialtyPharmacyDefinition.put(fName, oValues.get(fName));
    	}
    	return specialtyPharmacyDefinition;
    }
    
    public static GNE_CM_EBI_Specialty_Pharmacy_Definition__c createSpecialtyPharmacyDefinition()
    {
    	return createSpecialtyPharmacyDefinition(null);
    }
    
    public static GNE_CM_EBI_Transaction_Staging__c createTransactionStaging(Map<String,Object> fValues)
    {
    	if (fValues == null) {
    		fValues = new Map<String,Object>();
    	}
    	GNE_CM_EBI_Transaction_Staging__c transactionStaging = new GNE_CM_EBI_Transaction_Staging__c();
    	Map<String,Object> oValues =
    		DEFAULTS != null && DEFAULTS.containsKey('transactionStaging') && !DEFAULTS.get('transactionStaging').isEmpty()
    		? DEFAULTS.get('transactionStaging')
    		: new Map<String,Object>();
    	for (String fName : fValues.keySet()) {
    		oValues.put(fName, fValues.get(fName));
    	}	
    	for (String fName : oValues.keySet()) {
    		transactionStaging.put(fName, oValues.get(fName));
    	}
    	return transactionStaging;
    }
    
    public static GNE_CM_EBI_Transaction_Staging__c createTransactionStaging()
    {
    	return createTransactionStaging(null);
    }    
}