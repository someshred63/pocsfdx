/**
 * Test class for utility class GNE_CM_EBI_Util.
 * @author Radek Krawiec, Roche
 * @created 05/15/2013
 */
@isTest
public with sharing class GNE_CM_EBI_Util_Test
{
    public static testMethod void testGetPayerMappings()
    {
        Account payerAccount = getTestPayer();
        
        // make sure payer does not exist for this account
        GNE_CM_EBI_Payer_Mapping__c mapping = GNE_CM_EBI_Util.getPayerMapping(payerAccount.Id);
        System.assert(mapping == null, 'Payer Mapping should not exist yet for a newly-created account');
        
        // now insert a mapping for this payer
        GNE_CM_EBI_Payer_Mapping__c newMapping = new GNE_CM_EBI_Payer_Mapping__c(Account_gne__c = payerAccount.Id, TransEngen_Payer_Id_gne__c = 1234, TransEngen_Payer_Name_gne__c = 'Test');
        insert newMapping;
        
        // make sure a mapping now exists
        System.assert(GNE_CM_EBI_Util.getPayerMapping(payerAccount.Id) != null, 'Payer Mapping should exist for the payer');
    }
    
    public static testMethod void testGetPerformBITasksStatBI()
    {
        testGetPerformBITask('Stat BI - Perform BI');
    }
    
    public static testMethod void testGetPerformBITask()
    {
        testGetPerformBITask('Perform Benefit Investigation');
    }
    
    public static testMethod void testGetPerformBITaskStatBiNewEnrollmentReview()
    {
        testGetPerformBITask('Stat BI - New Enrollment Review');
    }
    
    public static testMethod void testGetPerformBITaskApppealReferral()
    {
        testGetPerformBITask('Perform Benefit Investigation for Appeals Referral');
    }
    
    public static testMethod void testGetPerformBITaskProactiveBI()
    {
        testGetPerformBITask('Perform Proactive Benefit Investigation');
    }
    
    public static testMethod void testGetPerformBITaskReverifyBI()
    {
        testGetPerformBITask('Reverify Benefit Investigation');
    }
    
    private static void testGetPerformBITask (String taskStatus)
    {
        insert GNE_CM_Test_Helper.createActualWorkingDays(10);
        
        // create a test case
        Case testCase = GNE_CM_Test_Helper.addTestCase('Herceptin', 'C&R - Standard Case');
        
        Integer activePerformBITasks = [SELECT COUNT() FROM Task WHERE WhatId = :testCase.Id AND Subject IN :GNE_CM_EBI_Util.ebiBiTaskSubjects AND Status <> 'Completed' AND IsDeleted = false ALL ROWS];
        
        // make sure no tasks exists for this case
        System.assert(activePerformBITasks == 0, 'No \'' + taskStatus + '\' tasks should not exist for a new case');
        
        // now add a task for this case
        Task t = new Task(WhatId = testCase.Id, Subject = taskStatus, Status = 'In Progress');
        insert t;
        
        activePerformBITasks = [SELECT COUNT() FROM Task WHERE WhatId = :testCase.Id AND Subject IN :GNE_CM_EBI_Util.ebiBiTaskSubjects AND Status <> 'Completed' AND IsDeleted = false ALL ROWS];
        
        System.assert(activePerformBITasks == 1, 'A \'' + taskStatus + '\' task should exist for a new case. Number of tasks: ' + activePerformBITasks);
    }
    
    public static testMethod void testMapResponse2BenefitInvestigationStandard()
    {
    	//Decimal dec = Decimal.valueOf('10');
    	/*Patient_gne__c p  = GNE_CM_Test_Helper.createPatient('test-fn-1', 'test-ln-1');
    	insert p;
    	GNE_CM_EBI_Request__c request = GNE_CM_EBI_Test_Helper.createRequest(p);
    	insert request;
    	GNE_CM_EBI_Benefit_Verification_Response__c response = GNE_CM_EBI_Test_Helper.createBenefitVerificationResponse(request);
    	insert response;
    	GNE_CM_EBI_Payer_Result__c payerResult = GNE_CM_EBI_Test_Helper.createPayerResult(response);
    	insert payerResult;
    	RecordType payerRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'MCO_vod'];    	    	
    	Id payerType = payerRecordType.id;
        Account payer = new Account(recordTypeId = payerType, Name = 'test payer', Status_gne__c = 'Active', MDMID_Status_gne__c = 'Active');
    	insert payer;
    	Case theCase = GNE_CM_Test_Helper.createCase('Polopiryna', 'testType');
    	insert theCase;
    	Insurance_gne__c insurance = GNE_CM_Test_Helper.createInsurance(theCase.Id, payer.Id, null);    	     	
    	
    	Test.startTest();
    	    	
    	Benefit_Investigation_gne__c benefitInvestigation = GNE_CM_EBI_Util.mapResponse2BenefitInvestigation(response);
    	
    	Test.stopTest();
    	
    	System.assert(benefitInvestigation != null);
    	System.assertEquals(request.Benefit_Investigation_Date_Time_gne__c, benefitInvestigation.BI_Obtained_Date_gne__c);    	
    	System.assertEquals(payerResult.Transaction_ID_gne__c, Decimal.valueOf(benefitInvestigation.eBI_Transaction_Num_gne__c));    	
    	System.assertEquals(payerResult.Insurance_Status_gne__c, insurance.ins_Insurance_gne__c);
    	System.assertEquals(payerResult.Plan_End_Date_gne__c, benefitInvestigation.Effective_Date_gne__c );
    	System.assertEquals(Decimal.valueOf(payerResult.Life_Max_gne__c), benefitInvestigation.In_Max_Life_Amount_gne__c);
    	System.assertEquals(Decimal.valueOf(payerResult.Life_Max_gne__c), benefitInvestigation.OT_Max_Life_Amount_gne__c );
    	System.assertEquals(Decimal.valueOf(payerResult.Remaining_Benefit_gne__c), benefitInvestigation.IN_Max_Remaining_Amount_gne__c );
    	System.assertEquals(Decimal.valueOf(payerResult.Remaining_Benefit_gne__c), benefitInvestigation.OT_Max_Remaining_Amount_gne__c );
    	System.assertEquals(payerResult.Rx_Benefit_Manager_gne__c, benefitInvestigation.Rx_Benefit_Manager_gne__c );
    	System.assertEquals(payerResult.Rx_Benefit_Manager_Phone_gne__c, benefitInvestigation.Rx_Benefit_Manager_Phone_gne__c );
    	System.assertEquals(request.JCode_gne__c, benefitInvestigation.Drug_Billing_Code_gne__c );*/    	
    }
    
    private static Account getTestPayer()
    {
        List<RecordType> recordTypes = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'MCO_vod'];
        
        if (recordTypes.isEmpty())
        {
            System.assert(false, 'Test configuration error. No record type MCO_vod found for object type Account');
        }
        
        Account acc = new Account (Name = 'Test Payer', RecordTypeId = recordTypes.get(0).Id);
        insert acc;
        return acc;
    }  
         
    private static void validatePER(Patient_Enrollment_Request_gne__c per, String productName)
    {
    	List<String> productNames = GNE_CM_EBI_Util.resolvePERProductNames(per);
        if(per.Patient_gne__r.PAN_gne__c == 'Yes')
        {
        	System.assert(productNames[0] == per.Patient_gne__r.PAN_Form_1_Product_gne__c, productName + ' PAN1 did not resolve properly');
        }
        else if(per.Patient_gne__r.PAN_Form_2_gne__c == 'Yes')
        {
        	System.assert(productNames[0] == per.Patient_gne__r.PAN_Form_2_Product_gne__c, productName + ' PAN2 did not resolve properly');
        }
        else
        {
        	System.assert(false, 'Test configuration error. ' + productName + ' PER does not have valid PAN on file.');
        }
    }

    private static Patient_Enrollment_Request_gne__c getTestPER(String product, String indicatePatientsTherapyRheum, String indicatePatientsTherapy5BioOncOra, 
    	String indicatePatientsTherapy, String patientPAN,  String patientPANForm1Product, String patientPANForm2, String patientPANForm2Product){
    
    	String patientName = 'TP-' + datetime.now().getTime();	
    	Patient_gne__c resultPatient = new Patient_gne__c(
    		Name = patientName,
    		pat_first_name_gne__c = patientName,
         	pat_dob_gne__c = system.today().addDays(-69),
         	pat_home_phone_gne__c  = '(222) 222-2222',
    		PAN_Form_1_Product_gne__c = patientPANForm1Product,
			PAN_Form_2_Product_gne__c = patientPANForm2Product
		);
    	//PAN_gne__c formula
    	if(patientPAN == 'Yes'){
    		resultPatient.PAN_Form_1_Expiration_Date_gne__c  = system.today().addDays(1);
    		resultPatient.PAN_Form_Signed_gne__c  = system.today().addDays(100);
    		resultPatient.PAN_Form_Rec_gne__c =  system.today();
    	}else if(patientPAN == 'No'){
    		resultPatient.PAN_Form_1_Expiration_Date_gne__c  = system.today().addDays(-1);
    	}else{
    		resultPatient.PAN_Form_1_Expiration_Date_gne__c = null;
    	}	
    	//PAN_Form_2_gne__c  formula
    	if(patientPANForm2 == 'Yes'){
    		resultPatient.PAN_Form_2_Exipration_Date_gne__c  = system.today().addDays(1);
    		resultPatient.PAN_Form_2_Signed_gne__c =  system.today().addDays(100);
    		resultPatient.PAN_Form_2_Rec_gne__c = system.today(); 
    	}else if(patientPANForm2 == 'No'){
    		resultPatient.PAN_Form_2_Exipration_Date_gne__c  = system.today().addDays(-1);
    	}else{
    		resultPatient.PAN_Form_2_Exipration_Date_gne__c = null;
    	}
    	insert resultPatient;
		Patient_Enrollment_Request_gne__c result = new Patient_Enrollment_Request_gne__c();
		result.Product_gne__c = product;
		result.Indicate_Patient_s_therapy_Rheum_gne__c = indicatePatientsTherapyRheum;
		result.Indicate_Patient_s_Therapy_BioOncOra_gne__c = indicatePatientsTherapy5BioOncOra;
		result.Indicate_Patient_s_Therapy_gne__c = indicatePatientsTherapy;
		result.Patient_gne__c = resultPatient.ID;
		insert result;
    	return [SELECT ID, Product_gne__c, Indicate_Patient_s_therapy_Rheum_gne__c, 
    			Indicate_Patient_s_Therapy_BioOncOra_gne__c, Indicate_Patient_s_Therapy_gne__c, 
    			Patient_gne__r.PAN_gne__c, Patient_gne__r.PAN_Form_1_Product_gne__c,
    			Patient_gne__r.PAN_Form_2_gne__c, Patient_gne__r.PAN_Form_2_Product_gne__c
    			FROM patient_enrollment_request_gne__c
				WHERE id = :result.ID][0];
    }
    
    /**
     * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     * getTestPER calls 3 FUTURE METHODS
     * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     */
    public static testMethod void testResolvePERProductNamesBIP_1(){
    	//BioOnc Infused - Avastin
        Patient_Enrollment_Request_gne__c perAvastin = getTestPER('BioOncology Infused Products', null, null, 'Avastin', 'Yes', 'Avastin', null, null);
        validatePER(perAvastin, 'BioOnc Infused - Avastin');
        //BioOnc Infused - Herceptin
        Patient_Enrollment_Request_gne__c perHerceptin = getTestPER('BioOncology Infused Products', null, null, 'Herceptin', 'Yes', 'Herceptin', null, null);
        validatePER(perHerceptin, 'BioOnc Infused - Herceptin');
        //BioOnc Infused - Kadcyla
        Patient_Enrollment_Request_gne__c perKadcyla = getTestPER('BioOncology Infused Products', null, null, 'Kadcyla', 'Yes', 'Kadcyla', null, null);
        validatePER(perKadcyla, 'BioOnc Infused - Kadcyla');
    }
    public static testMethod void testResolvePERProductNamesBIP_2(){
		//BioOnc Infused - Perjeta
        Patient_Enrollment_Request_gne__c perPerjeta = getTestPER('BioOncology Infused Products', null, null, 'PERJETA', 'Yes', 'Perjeta', null, null);
        validatePER(perPerjeta, 'BioOnc Infused - Perjeta');
        //BioOnc Infused - Rituxan
        Patient_Enrollment_Request_gne__c perRituxan = getTestPER('BioOncology Infused Products', null, null, 'Rituxan', 'Yes', 'Rituxan', null, null);
        validatePER(perRituxan, 'BioOnc Infused - Rituxan');    	
    }
    public static testMethod void testResolvePERProductNamesBOP_1(){
    	//BioOnc Oral - Erivedge
        Patient_Enrollment_Request_gne__c perErivedge = getTestPER('BioOncology Oral Products', null, 'Erivedge', null, 'Yes', 'Erivedge', null, null);
        validatePER(perErivedge, 'BioOnc Oral - Erivedge');
        //BioOnc Oral - Zelboraf
        Patient_Enrollment_Request_gne__c perZelboraf = getTestPER('BioOncology Oral Products', null, 'ZELBORAF', null, 'Yes', 'Zelboraf', null, null);
        validatePER(perZelboraf, 'BioOnc Oral - Zelboraf');
        //BioOnc Oral - Tarceva
        Patient_Enrollment_Request_gne__c perTarceva = getTestPER('BioOncology Oral Products', null, 'Tarceva', null, 'Yes', 'Tarceva', null, null);
        validatePER(perTarceva, 'BioOnc Oral - Tarceva');
    }
    public static testMethod void testResolvePERProductNamesBOP_2(){
    	//BioOnc Oral - Xeloda
        Patient_Enrollment_Request_gne__c perXeloda = getTestPER('BioOncology Oral Products', null, 'XELODA', null, 'Yes', 'Xeloda', null, null);
        validatePER(perXeloda, 'BioOnc Oral - Xeloda');
    }
    public static testMethod void testResolvePERProductNamesReumatlogy()
    {
        //Rheumatology - Rituxan RA
        Patient_Enrollment_Request_gne__c perRituxanRA = getTestPER('Rheumatology', 'Rituxan', null, null, 'Yes', 'Rituxan RA', 'Yes', 'Rituxan RA');
        validatePER(perRituxanRA, 'Rheumatology - Rituxan RA');
        //Rheumatology - Actemra
        Patient_Enrollment_Request_gne__c perActemra = getTestPER('Rheumatology', 'Actemra', null, null, 'Yes', 'Actemra', 'Yes', 'Rituxan RA');
        validatePER(perActemra, 'Rheumatology - Actemra');
        //Rheumatology - Actemra SQ
        Patient_Enrollment_Request_gne__c perActemraSQ = getTestPER('Rheumatology', 'Actemra Subcutaneous', null, null, 'Yes', 'Actemra Subcutaneous', null, null);
        validatePER(perActemraSQ, 'Rheumatology - Actemra SQ');
    }
    public static testMethod void testResolvePERProductNamesOther_1(){
    	//Lucentis
        Patient_Enrollment_Request_gne__c perLucentis = getTestPER('Lucentis', null, null, 'Lucentis', 'Yes', 'Lucentis', null, null);
        validatePER(perLucentis, 'Lucentis');
        //Pegasys
        Patient_Enrollment_Request_gne__c perPegasys = getTestPER('Pegasys', null, null, null, 'Yes', 'Pegasys', 'Yes', 'Pegasys');
        validatePER(perPegasys, 'Pegasys');
        //Pulmozyme
        Patient_Enrollment_Request_gne__c perPulomozyme = getTestPER('Pulmozyme', null, null, null, 'Yes', 'Pulmozyme', null, null);
        validatePER(perPulomozyme, 'Pulmozyme');	
    }
    public static testMethod void testResolvePERProductNamesOther_2()
    {
    	//Xolair
       	Patient_Enrollment_Request_gne__c perXolair = getTestPER('Xolair', null, null, null, 'Yes', 'Xolair', null, null);
       	validatePER(perXolair, 'Xolair');
    }
    
    public static testMethod void testResolvePERadminCode()
    {
    	Patient_Enrollment_Request_gne__c per = new Patient_Enrollment_Request_gne__c();
    	System.assert(GNE_CM_EBI_Util.resolvePERadminCode(per) == null, ' for PER without Product_gne__c admin code need to be null');
    	per.Product_gne__c = 'lucentis';
    	System.assertEquals(GNE_CM_EBI_Util.resolvePERadminCode(per), '67028');
		per.Product_gne__c = 'rheumatology';
	    per.Indicate_Patient_s_therapy_Rheum_gne__c = 'actemra';
		System.assertEquals(GNE_CM_EBI_Util.resolvePERadminCode(per), '96413');
		per.Indicate_Patient_s_therapy_Rheum_gne__c = 'RiTuXAn rA';
    	System.assertEquals(GNE_CM_EBI_Util.resolvePERadminCode(per), '96413');
    }
    
    public static testMethod void testResolveServiceDeliveryLocation(){
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('free standing infusion center'), 'AIC');
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('home'), 'Office');
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('hospital inpatient'), 'Office');
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('hospital outpatient'), 'Hospital Outpatient Setting');
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('md office / clinic'), 'Office');
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('non prescribing md office'), 'Office');
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('other'), 'Office');
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('prescribing md office'), 'Office');
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation('custom other'), 'custom other');
    }
    
    public static testMethod void testResolveServiceDeliveryLocationWithPER(){
    	Patient_Enrollment_Request_gne__c per = new Patient_Enrollment_Request_gne__c();
    	per.Product_gne__c = 'lucentis';
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per), 'Office');
    	
    	per.Product_gne__c = 'xolair';
    	per.Place_of_Administration_Xolair_gne__c = 'physician’s office';
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per), 'Office');
    	per.Place_of_Administration_Xolair_gne__c = 'hopd';
    	System.assert(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per) == null, 'GNE_CM_EBI_Util.resolveServiceDeliveryLocation for hopd returned not null value');
    	per.Place_of_Administration_Xolair_gne__c = 'alternate injection center';	
    	System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per), 'AIC');
        
        per.Product_gne__c = 'rheumatology';
        per.Place_of_infusion_gne__c = 'prescribing physician’s office';
        System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per), 'Office');
        per.Place_of_infusion_gne__c = 'other physician’s office';
        System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per), 'Office');
        per.Place_of_infusion_gne__c = 'hospital outpatient';
        System.assert(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per) == null, 'GNE_CM_EBI_Util.resolveServiceDeliveryLocation for rheumatology/hospital - outpatient returned not null value');
        per.Place_of_infusion_gne__c = 'other';
        System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per), 'AIC');
        
        per.Product_gne__c = 'biooncology infused products';
        per.Place_of_Administration_gne__c = 'physician’s office';
        System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per), 'Office');
        per.Place_of_Administration_gne__c = 'hospital - outpatient';
        System.assert(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per) == null, 'GNE_CM_EBI_Util.resolveServiceDeliveryLocation for biooncology infused products/hospital - outpatient returned not null value');
        per.Place_of_Administration_gne__c = 'hospital - inpatient';
        System.assertEquals(GNE_CM_EBI_Util.resolveServiceDeliveryLocation(per), 'Office');
    }
    
    public static testMethod void testCoverageMessageIdToProductNotCovered(){
    	System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('71', null), 'Site of Treatment');	
    	System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('70', null), 'Pre-Existing Clause');
    	System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('69', null), 'No Benefit for Injectables');
    	System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('68', null), 'Not on Formulary');
    	System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('67', null), 'No Benefit');
    	System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('66', null), 'No Drug Coverage');
    	System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('65', null), 'Experimental / Investigational');
    	System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('64', null), 'Diagnosis off label');
		System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('63', null), 'Diagnosis');
		System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('62', null), 'Out-of-Network Coverage Undetermined');
		System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('61', null), 'In-Network Coverage Undetermined');
		System.assertEquals(GNE_CM_EBI_Util.coverageMessageIdToProductNotCovered('7', null), 'No Out of Network Benefit');
    }
    
    public static testMethod void testCoverageStatusToProductCovered(){
    	System.assertEquals(GNE_CM_EBI_Util.coverageStatusToProductCovered('covered', null), 'Yes, if Medically Necessary');
    	System.assertEquals(GNE_CM_EBI_Util.coverageStatusToProductCovered('not covered', null), 'No');
    	System.assert(GNE_CM_EBI_Util.coverageStatusToProductCovered('undetermined') == null, 'GNE_CM_EBI_Util.coverageStatusToProductCovered for undetermined returned not null value');
    }
    
    public static testMethod void testInsuranceStatusPayerResultToInsurance(){
    	System.assertEquals(GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance('active', null), 'Active');
    	System.assertEquals(GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance('inactive', null), 'Terminated');
    	System.assert(GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance('incomplete', null) == null, 'GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance for incomplete returned not null value');
    	System.assert(GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance('ineligible', null) == null, 'GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance for ineligible returned not null value');
    	System.assert(GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance('not found', null) == null, 'GNE_CM_EBI_Util.insuranceStatusPayerResultToInsurance for not found returned not null value');
    }
}