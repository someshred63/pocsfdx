@isTest(SeeAllData = false)
private class CFAR_Trial_Controller_Test {

	@testSetup
	static void setup() {
		User testUser = CFAR_TestUtils.createTestAverageUser();
		System.runAs(testUser){
			CFAR_TestUtils.createPicklistValue(new List<String>{'Label Expansion', 'Guidelines / Compendia Listing', 'CDP Data Gaps',
			'Published Manuscript', 'Congress: Oral Presentation', 'Congress: Abstract or Poster'}, 'Impact');
			CFAR_TestUtils.createTestTrial();
		}
	}

	@isTest
    static void baseControllerTest(){
        
        User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
        System.runAs(testUser){
            CFAR_BaseController cont = new CFAR_BaseController();
            Test.startTest();
        System.assertEquals(true, cont.getIsAverageUser());
        
        System.assertEquals(false, cont.getCurrentUserIsAdmin());
            
        System.assertEquals(false, cont.getisITAdminOrSFDCAdmin());
        System.assertEquals(false, cont.getIsReadOnly());
        cont.getReturnPage();
        cont.cancel();
        cont.addErrorMessage('message');
        cont.addErrorMessages(new List<String>());
        cont.logMessage();
            test.stopTest();
        }
    }
    
    
	@isTest 
	static void setLabSupportTest() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			testTrial.Lab_Support_gne__c = 'YES';
			testTrial.Vendor_gne__c = 'test';
			testTrial.Type_of_Sample_Other_gne__c = 'test';
			List<CFAR_Trial_Status_gne__c> ts = new List<CFAR_Trial_Status_gne__c>();
			ts.add(new CFAR_Trial_Status_gne__c (name='Re-open',Active_gne__c=true));
			insert ts;

			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, 'Re-open');
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			
 			System.assertEquals(cont.trialWrapper.innerObject.get('Vendor_gne__c'), 'test');
			System.assertEquals(cont.trialWrapper.innerObject.get('Type_of_Sample_Other_gne__c'), 'test');

			cont.trialWrapper.innerObject.put('Lab_Support_gne__c', 'NO');
			cont.BOMremovalConfirmation = true;
			cont.labSupportChanged();

			System.assertEquals(cont.trialWrapper.innerObject.get('Vendor_gne__c'), null);			
		}	
	}

	@isTest 
	static void editGenInfoTest() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, 'Re-open');
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('Specific_Indication_Other_gne__c', 'test');
			cont.cancelEditGeneralInfo();
			System.assertEquals(null, cont.trialWrapper.innerObject.get('Specific_Indication_Other_gne__c'));
		}			
	}

	@isTest 
	static void editGenInfoTestDollarDrug() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {

			CFAR_Product_gne__c product1 = new CFAR_Product_gne__c();
			product1.Name =  'Accutane';
			product1.Generic_Name_gne__c = 'generic';
			product1.Abbreviation_gne__c = 'ACC';
			insert product1;

			CFAR_Product_gne__c product2 = new CFAR_Product_gne__c();
			product2.Name =  'Actemra';
			product2.Generic_Name_gne__c = 'actem';
			product2.Abbreviation_gne__c = 'ACM';
			insert product2;
			
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
        	CFAR_Trial_Other_GNE_Agent_gne__c trialOtherGNEAgent = CFAR_DataFactory.createTrialOtherAgent(testTrial, product1);
			insert trialOtherGNEAgent;

			CFAR_Dollar_and_Drug_gne__c ddDollarOnly = CFAR_TestUtils.createDollarAndDrug('$ Only');
			CFAR_Dollar_and_Drug_gne__c ddDrugOnly = CFAR_TestUtils.createDollarAndDrug('Drug Only');
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, 'Re-open');
			testTrial.Other_GNE_Agents_Multi_gne__c = product1.Id;
			testTrial.Dollar_and_Drug_ref_gne__c = ddDollarOnly.Id;
			update testTrial;

			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('Dollar_and_Drug_ref_gne__c', ddDrugOnly.Id);
			cont.clearIMPShippedField();
			cont.trialWrapper.selectedOtherGNEAgents.add(product2.Id);
			cont.processStudiedProducts();
			cont.trialWrapper.innerObject.put('Dollar_and_Drug_ref_gne__c', ddDollarOnly.Id);
			cont.clearIMPShippedField();
			cont.saveTrial();
		}			
	}

	@isTest
	static void editGeneralInformationTest() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, 'Active Enrollment');
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			//System.assertEquals(null, cont.trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c'));
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2016-11111');
			cont.saveTrial();
			//System.assertEquals('RO-IIS-2016-11111', cont.trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c'));
		}
	}
	@isTest
	static void editGeneralInformationIncorrectPortalRONumberTest() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, 'Active Enrollment');
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'abc');
			cont.saveTrial();
			System.assert(ApexPages.getMessages().get(0).getDetail().contains('Incorrect format'));
		}
	}

	@isTest
	static void editGeneralInformationPartnershipTest() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Partnership_gne__c partnership = new CFAR_Partnership_gne__c();
			partnership.Name = 'test';
			partnership.Active_gne__c = true;
			insert partnership;

			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, 'Active Enrollment');
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'abc');
			cont.trialWrapper.selectedPartnerships.add(partnership.Name);
			cont.saveTrial();
			System.assert(ApexPages.getMessages().get(0).getDetail().contains('Incorrect format'));
			System.assert([SELECT IIS_Portal_RO_Number_gne__c FROM CFAR_Trial_gne__c].get(0).IIS_Portal_RO_Number_gne__c.contains('RO-IIS-'));
		}
	}

	@isTest
	static void editGeneralInformationDuplicatePortalRONumberTest() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
			CFAR_Trial_gne__c testTrial2 = testTrial.clone(true, true, true, true);
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, 'Active Enrollment');
			testTrial2 = CFAR_TestUtils.setTrialStatus(testTrial, 'Active Enrollment');
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
			cont.saveTrial();
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial2);
			cont.mainTrialId = testTrial2.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('IIS_Portal_RO_Number_gne__c', 'RO-IIS-2017-12345');
			cont.saveTrial();
		}
	}

	@isTest 
	static void cookieTest() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_TestUtils.createProduct('TestProd', 'TST', 'TestGen');
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
						
			testTrial = CFAR_TestUtils.setTrialStatus(testTrial, 'Re-open');
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();

			Apexpages.currentPage().getParameters().put('selectedTabName', 'testTab');
			cont.createCookie();
			Map<String, System.Cookie> cookies = Apexpages.currentPage().getCookies();
			for(String aa : cookies.keySet()) {
				System.debug('---- ' + aa);
				System.debug('++++ ' + cookies.get(aa));
			}
		}
	}
	
	@isTest
	static void testSaveExtension() {

		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedGeneralIndications = null;
            cont.processStudiedProducts();

			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertNOTEquals(2, [SELECT ID FROM CFAR_Trial_gne__c].size());
		}
	}

	@isTest
	static void testCreateNewTypeOfSample(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Type_of_Sample_gne__c sample = new CFAR_Type_of_Sample_gne__c();
			sample.Name = 'sample';
			sample.Active_gne__c = true;
			insert sample;

			CFAR_Type_of_Sample_gne__c sample2 = new CFAR_Type_of_Sample_gne__c();
			sample2.Name = 'Other';
			sample2.Active_gne__c = true;
			insert sample2;

			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();

			//new Type Of Sample
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.createNewTrialTypeOfSample();
			cont.submitTrialTypeOfSample();
			cont.trialWrapper.newEditTrialTypeOfSample.Type_of_sample_ref_gne__c = sample.id;
			cont.submitTrialTypeOfSample();
			cont.trialWrapper.newEditTrialTypeOfSample.Type_of_sample_ref_gne__c = sample2.id;
			cont.submitTrialTypeOfSample();
			cont.trialWrapper.newEditTrialTypeOfSample.Type_of_sample_ref_gne__c = sample.id;
			cont.trialWrapper.newEditTrialTypeOfSample.comments_gne__c = 'comment';
			cont.submitTrialTypeOfSample();
			System.assertEquals(1, [SELECT ID FROM CFAR_Trial_Type_Of_Sample_gne__c].size());
			
			//edit Type Of Sample
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.trialWrapper.getTrialTypeOfSampleRecords();
			cont.trialWrapper.typeOfSampleId = [SELECT ID FROM CFAR_Trial_Type_Of_Sample_gne__c].get(0).id;
			cont.editTrialTypeOfSample();

			//cancel create new Type of Sample
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.createNewTrialTypeOfSample();
			cont.trialWrapper.newEditTrialTypeOfSample.Type_of_sample_ref_gne__c = sample.id;
			cont.trialWrapper.newEditTrialTypeOfSample.comments_gne__c = 'comment2';
			cont.cancelTOS();
			System.assertEquals(1, [SELECT ID FROM CFAR_Trial_Type_Of_Sample_gne__c].size());

			//delete Type of sample
			cont.trialWrapper = new CFAR_TrialWrapper(testTrial);
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.trialWrapper.getTrialTypeOfSampleRecords();
			cont.trialWrapper.typeOfSampleId = [SELECT ID FROM CFAR_Trial_Type_Of_Sample_gne__c].get(0).id;
			cont.deleteTrialTypeOfSample();
			System.assertEquals(0, [SELECT ID FROM CFAR_Trial_Type_Of_Sample_gne__c].size());
		}
	}

	@isTest
	static void testEmptyTreatmentSensitiveDescription(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedPatientSubPopulation.add('Treatment Sensitive');
            cont.trialWrapper.getIsSubPatientSensitiveRequired();
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertEquals(0, cont.trialWrapper.selectedPatientSubPopulation.size());
		}
	}

	@isTest
	static void testEmptyPatientSubPopulationOtherDescription(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedPatientSubPopulation.add('Other');
            cont.trialWrapper.getIsSubPatientOtherRequired(); 
            cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
            
			System.assertEquals(0, cont.trialWrapper.selectedPatientSubPopulation.size());
		}
	}

	@isTest
	static void testEmptyDiseaseStatusOtherDescription(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedDiseaseStatus.add('Other');
            cont.trialWrapper.clearDiseaseStatusOther();
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertNOTEquals(1, cont.trialWrapper.selectedDiseaseStatus.size());
		}
	}
    
    @isTest
	static void testDiseaseStatusOther(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedDiseaseStatus.add('Other');
            cont.trialWrapper.clearDiseaseStatusOther();
            cont.trialWrapper.innerObject.put('Disease_Status_Other_gne__c', 'desc');
            cont.trialWrapper.selectedDiseaseStatus.add('test');
            cont.trialWrapper.clearDiseaseStatusOther();
			cont.saveTrial();
			
            cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertNOTEquals(1, cont.trialWrapper.selectedDiseaseStatus.size());
		}
	}

	@isTest
	static void testSubjectTypeIsHuman(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('Subject_Type__c', 'Human');
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertNotEquals('Human', cont.trialWrapper.innerObject.get('Subject_Type__c'));
		}
	}

	@isTest
	static void testEmptyLineOfTherapyOtherDescription(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedLineOfTherapy.add('Other');
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertNotEquals(1, cont.trialWrapper.selectedLineOfTherapy.size());
		}
	}

	@isTest
	static void testSubjectTypeIsOther(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.innerObject.put('Subject_Type__c', 'Other');
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertNotEquals('Other', cont.trialWrapper.innerObject.get('Subject_Type__c'));
		}
	}

	@isTest
	static void testEmptyTreatmentRefractoryDescription(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedPatientSubPopulation.add('Treatment Refractory');
            cont.trialWrapper.getIsSubPatientRefactoryRequired();
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertEquals(0, cont.trialWrapper.selectedPatientSubPopulation.size());
		}
	}

	@isTest
	static void testEmptyMedicalComorbidityDescription(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedPatientSubPopulation.add('Medical Comorbidity');
            cont.trialWrapper.getIsSubPatientComorbidityRequired();
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertEquals(0, cont.trialWrapper.selectedPatientSubPopulation.size());
		}
	}

	@isTest
	static void testEmptyEthnicityDescription(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedPatientSubPopulation.add('Ethnicity');
            cont.trialWrapper.getIsSubPatientEthnicityRequired();
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			System.assertEquals(0, cont.trialWrapper.selectedPatientSubPopulation.size());
		}
	}


	@isTest
	static void testAddGeneralAndSpecificIndications(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial3('RO-IIS-2017-22221');

			CFAR_Specific_Indication_gne__c ind1 = CFAR_TestUtils.createSpecificIndication('T1');
			CFAR_Specific_Indication_gne__c ind2 = CFAR_TestUtils.createSpecificIndication('T2');
			CFAR_Specific_Indication_gne__c ind3 = CFAR_TestUtils.createSpecificIndication('T3');
			CFAR_Specific_Indication_gne__c ind4 = CFAR_TestUtils.createSpecificIndication('T4');
			CFAR_Specific_Indication_gne__c ind5 = CFAR_TestUtils.createSpecificIndication('T5');
			CFAR_Specific_Indication_gne__c ind6 = CFAR_TestUtils.createSpecificIndication('T6');
			CFAR_Specific_Indication_gne__c ind7 = CFAR_TestUtils.createSpecificIndication('T7');
			CFAR_Specific_Indication_gne__c ind8 = CFAR_TestUtils.createSpecificIndication('T8');
			CFAR_Specific_Indication_gne__c ind9 = CFAR_TestUtils.createSpecificIndication('T9');
			CFAR_Specific_Indication_gne__c ind10 = CFAR_TestUtils.createSpecificIndication('Other');
			CFAR_Specific_Indication_gne__c ind11 = CFAR_TestUtils.createSpecificIndication('T11');
			CFAR_Specific_Indication_gne__c ind12 = CFAR_TestUtils.createSpecificIndication('T12');
			CFAR_Specific_Indication_gne__c ind13 = CFAR_TestUtils.createSpecificIndication('T13');
			CFAR_Specific_Indication_gne__c ind14 = CFAR_TestUtils.createSpecificIndication('T14');
			CFAR_Specific_Indication_gne__c ind15 = CFAR_TestUtils.createSpecificIndication('T15');
			CFAR_Specific_Indication_gne__c ind16 = CFAR_TestUtils.createSpecificIndication('T16');

			CFAR_Specific_Indication_gne__c specIndication = new CFAR_Specific_Indication_gne__c();
			specIndication.Name = 'Other';
			insert specIndication;

			CFAR_General_Indication_gne__c gi1 = new CFAR_General_Indication_gne__c();
			gi1.Name = 'Other';
			gi1.Active_gne__c = true;
			insert gi1;

			CFAR_General_Indication_for_Trial_gne__c giForTrial = new CFAR_General_Indication_for_Trial_gne__c();
			giForTrial.CFAR_General_Indication_ref_gne__c = gi1.id;
			giForTrial.CFAR_Trial_ref_gne__c = testTrial.id;
			insert giForTrial;

			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.trialWrapper.selectedGeneralIndications.add(cont.trialWrapper.availableGeneralIndications.get(0).getValue());
            cont.trialWrapper.selectedGeneralIndications.add('Other');
			Apexpages.currentPage().getParameters().put('generalInfoId', gi1.Id);
			cont.submitGeneralIndication();
            System.assertEquals(null, cont.trialWrapper.getDisplayedGeneralIndications());
            System.assertEquals(null, cont.trialWrapper.getDisplayedSpecificIndications());
			cont.trialWrapper.selectedSpecificIndications.add(cont.trialWrapper.availableSpecificIndications.get(0).getValue());
			Apexpages.currentPage().getParameters().put('specificInfoId', specIndication.Id);
			cont.clearGeneralAndSpecificIndicationsForBiooncology();
			cont.trialWrapper.selectedSpecificIndications.add(cont.trialWrapper.availableSpecificIndications.get(0).getValue());
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind1.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind2.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind3.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind4.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind5.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind6.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind7.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind8.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind9.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind10.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind11.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind12.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind13.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind14.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind15.id));
			cont.trialWrapper.selectedSpecificIndications.add(String.valueOf(ind16.id));
			cont.getSelectedGeneralIndicationMappings();
            cont.trialWrapper.clearOtherGeneralIndication();
            cont.trialWrapper.clearOtherSpecificIndication();
			cont.cancelGeneralIndication();
            System.assertEquals(true, cont.trialWithInactiveInvestigator);
			Apexpages.currentPage().getParameters().put('specificInfoId', specIndication.Id);
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();

			System.assertNotEquals(17, cont.trialWrapper.selectedSpecificIndications.size());

		}
	}

	@isTest
	static void TestUtils_Test(){
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser){
			List<CFAR_Address_Type_gne__c> addressTypes = CFAR_TestUtils.createAddressTypes();
			List<CFAR_Countries_gne__c> countries = CFAR_TestUtils.createCountries();
			List<CFAR_States_gne__c> states = CFAR_TestUtils.createStates();


		}
	}

	@isTest
	static void testSave() {
		User testUser = [SELECT Id FROM User WHERE alias = 'testAvg'];
		System.runAs(testUser) {
			delete [SELECT Id FROM CFAR_Trial_gne__c];
			delete [SELECT Id FROM CFAR_Specific_Indication_gne__c];
			delete [SELECT Id FROM CFAR_Trial_Status_gne__c];
			CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
			CFAR_Therapeutic_Area_gne__c ta = new CFAR_Therapeutic_Area_gne__c();
			ta.Name = 'BioOncology';
			ta.Active_gne__c = true;
			insert ta;

			CFAR_Therapeutic_Area_gne__c ta2 = new CFAR_Therapeutic_Area_gne__c();
			ta2.Name = 'CNS';
			ta2.Active_gne__c = true;
			insert ta2;
			System.assertEquals(3, [SELECT ID FROM CFAR_Therapeutic_Area_gne__c].size());

			CFAR_Trial_gne__c testTrial = CFAR_TestUtils.createTestTrial3('RO-IIS-2017-22222');
			CFAR_Trial_gne__c fakeTrialForTest = new CFAR_Trial_gne__c();
			fakeTrialForTest.Planned_Enrollment_gne__c = 1;
			fakeTrialForTest.Received_Date_gne__c = System.today();
			fakeTrialForTest.IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-12312';
			insert fakeTrialForTest;

			System.assertEquals(2, [SELECT ID FROM CFAR_Trial_gne__c].size());
			CFAR_Specific_Indication_gne__c ind1 = CFAR_TestUtils.createSpecificIndication('T1');
			CFAR_Specific_Indication_gne__c ind2 = CFAR_TestUtils.createSpecificIndication('T2');
			System.assertEquals(3, [SELECT ID FROM CFAR_Specific_Indication_gne__c].size());
			testTrial.Specific_Indication_Other_gne__c = ind1.Id;

			CFAR_Trial_Type_gne__c trialType = new CFAR_Trial_Type_gne__c();
			trialType.Name = 'COOP';
			trialType.Active_gne__c = true;
			insert trialType;

			CFAR_Specific_Indication_gne__c specIndication = new CFAR_Specific_Indication_gne__c();
			specIndication.Name = 'Other';
			insert specIndication;

			CFAR_Specific_Indication_for_Trial_gne__c siForTrial = new CFAR_Specific_Indication_for_Trial_gne__c();
			siForTrial.CFAR_Specific_Indication_ref_gne__c = specIndication.id;
			siForTrial.CFAR_Trial_ref_gne__c = testTrial.id;
			insert siForTrial;

			CFAR_Picklist_Value_gne__c randomPicklistValue1 = [SELECT Name FROM CFAR_Picklist_Value_gne__c WHERE Name = 'Label Expansion'];
			CFAR_Picklist_Value_gne__c randomPicklistValue2 = [SELECT Name FROM CFAR_Picklist_Value_gne__c WHERE Name = 'Congress: Abstract or Poster'];

			List<CFAR_Trial_Status_gne__c> ts = new List<CFAR_Trial_Status_gne__c>();
			ts.add(new CFAR_Trial_Status_gne__c (name='Active Enrollment',Active_gne__c=true));
			insert ts;
			System.assertEquals(2, [SELECT ID FROM CFAR_Trial_Status_gne__c].size());

			CFAR_Product_gne__c pr = new CFAR_Product_gne__c();
			pr.Name = 'Avastin';
			pr.Generic_Name_gne__c = 'generic';
			pr.Abbreviation_gne__c = 'AVA';
			pr.Active_gne__c = true;
			pr.Other_GNE_Agent_Active_gne__c = true;
			insert pr;

			CFAR_Trial_gne__c testTrial2 = CFAR_TEstUtils.createTestTrial2();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			System.assertEquals([SELECT ID, Name, Active_gne__c FROM CFAR_Trial_Status_gne__c WHERE Name =: 'Follow-up'].get(0).id, cont.trialWrapper.innerObject.get('Trial_Status_ref_gne__c'));
			Test.startTest();
			cont.editGeneralInfo();
            System.assertNotEquals(0, cont.trialWrapper.availableGeneralIndicationsPopUp.size());
			((CFAR_Trial_gne__c)cont.trialWrapper.innerObject).Lab_Support_gne__c = 'YES';
			cont.trialWrapper.selectedDiseaseStatus.add(cont.trialWrapper.availableDiseaseStatus.get(1).getValue());
			cont.trialWrapper.selectedLineOfTherapy.add(cont.trialWrapper.availableLineOfTherapy.get(1).getValue());
			cont.trialWrapper.selectedPatientSubPopulation.add(cont.trialWrapper.availablePatientSubPopulation.get(1).getValue());
			cont.trialWrapper.selectedSpecificIndications.add(cont.trialWrapper.availableSpecificIndications.get(0).getValue());
			Apexpages.currentPage().getParameters().put('specificInfoId', specIndication.Id);
			cont.trialWrapper.addFrozenDate(2016);
            cont.trialWrapper.removeFrozenDate(2016);
            cont.trialWrapper.selectedImpact = new List<String> {randomPicklistValue1.Id, randomPicklistValue2.Id};
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			CFAR_Trial_Picklist_gne__c[] newlyCreatedPicklistJunctions = [SELECT Id, CFAR_PicklistValue_ref_gne__c, CFAR_PicklistValue_ref_gne__r.Name FROM CFAR_Trial_Picklist_gne__c];
			System.assertEquals(true, cont.trialWrapper.getDisplayedImpacts().contains('Label Expansion'));
			System.assertEquals(true, cont.trialWrapper.getDisplayedImpacts().contains('Congress: Abstract or Poster'));
			System.assertEquals(2, newlyCreatedPicklistJunctions.size());

			System.assertNotEquals(null, cont.trialWrapper.getDisplayedSpecificIndications());
            System.assertEquals(null, cont.trialWrapper.getDisplayedGeneralIndications());
            System.assertEquals(null, cont.trialWrapper.getDisplayedOtherGNEAgents());
            System.assertNotEquals('', cont.trialWrapper.getTrialName());

			System.assertEquals(1, cont.trialWrapper.selectedDiseaseStatus.size());
			System.assertEquals(1, cont.trialWrapper.selectedLineOfTherapy.size());
			System.assertEquals(1, cont.trialWrapper.selectedPatientSubPopulation.size());
			
			cont.trialWrapper.selectedImpact = new List<String> {randomPicklistValue1.Id};
			cont.saveTrial();
			cont.mainTrialId = testTrial.Id;
			cont.refreshMainTrial();

			newlyCreatedPicklistJunctions = [SELECT Id, CFAR_PicklistValue_ref_gne__c, CFAR_PicklistValue_ref_gne__r.Name FROM CFAR_Trial_Picklist_gne__c];
			System.assertEquals(true, cont.trialWrapper.getDisplayedImpacts().contains('Label Expansion'));
			System.assertEquals(false, cont.trialWrapper.getDisplayedImpacts().contains('Congress: Abstract or Poster'));
			System.assertEquals(1, newlyCreatedPicklistJunctions.size());
			System.assertEquals('Label Expansion', newlyCreatedPicklistJunctions[0].CFAR_PicklistValue_ref_gne__r.Name);
			CFAR_Product_gne__c product = CFAR_TestUtils.createProduct('TestProd', 'TST', 'TestGen');
			cont.trialWrapper.selectedOtherGNEAgents = new List<String>{product.Id};
			cont.saveTrial();
			cont.mainTrialId = fakeTrialForTest.Id;
			cont.refreshMainTrial();
			cont.editGeneralInfo();
			cont.saveTrial();
				Test.stopTest();
		}	
	}

	@isTest
	static void getAvailableTypesOfSamples_shouldReturnAvailableTypesOfSamples() {
		//GIVEN
		CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
		CFAR_Type_of_Sample_gne__c typeOfSample1 = CFAR_TestUtils.createTypeOfSample('typeOfSample1');
		CFAR_TestUtils.createTypeOfSample('typeOfSample2');
		CFAR_Trial_Type_of_Sample_gne__c trialTypeOfSample1 = CFAR_TestUtils.createTrialTypeOfSample(trial.Id, typeOfSample1.Id, 'trialTypeOfSample1');
		CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
		cont.mainTrialId = trial.Id;
		cont.refreshMainTrial();
		cont.trialWrapper.newEditTrialTypeOfSample = trialTypeOfSample1;
		cont.trialWrapper.getTrialTypeOfSampleRecords();

		//WHEN
		List<SelectOption> availableTypes = cont.trialWrapper.getAvailableTypesOfSamples();

		//THEN
		System.assertEquals(3, availableTypes.size(), 'Should return available types of samples');
	}

	@isTest
	static void availablePartnerships_shouldReturnAvailablePartnerships() {
		//GIVEN
		CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
		CFAR_Partnership_gne__c partnership = CFAR_TestUtils.createPartnership('testPartnership1', true);
		CFAR_TestUtils.createPartnership('testPartnership2', true);
		CFAR_TestUtils.createPartnership('testPartnership3', true);
		cont.trialWrapper.selectedPartnerships = new List<String>();
		cont.trialWrapper.selectedPartnerships.add(partnership.Name);
		cont.mainTrialId = trial.Id;
		cont.refreshMainTrial();

		//WHEN
		List<SelectOption> availablePartnerships = cont.trialWrapper.availablePartnerships;

		//THEN
		System.assertEquals(4, availablePartnerships.size(), 'Should return available partnerships');

		//WHEN
		cont.trialWrapper.selectedPartnerships.add('N/A');
		availablePartnerships = cont.trialWrapper.availablePartnerships;

		//THEN
		System.assertEquals(1, availablePartnerships.size(), 'If Selected partnerships contains N/A, Should return just N/A');
	}

	@isTest
	static void availableOtherGNEAgents_shouldReturnavailAbleOtherGNEAgents() {
		//GIVEN
		CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
		CFAR_Product_gne__c product = CFAR_TestUtils.createProduct('TestProd', 'TST', 'TestGen');
		CFAR_TestUtils.createProduct('TestProd2', 'TSC', 'TestGen2');
		CFAR_TestUtils.createProduct('TestProd3', 'TSE', 'TestGen3');
		cont.trialWrapper.selectedOtherGNEAgents = new List<String>();
		cont.trialWrapper.selectedOtherGNEAgents.add(product.Id);
		cont.mainTrialId = trial.Id;
		cont.refreshMainTrial();

		//WHEN
		List<SelectOption> availableOtherGNEAgents = cont.trialWrapper.availableOtherGNEAgents;

		//THEN
		System.assertEquals(5, availableOtherGNEAgents.size(), 'Should return available Other Gna Agents');
	}

	@isTest
	static void getDisplayedPartnerships_shouldReturnDisplayedPartnerships() {
		//GIVEN
		CFAR_Trial_gne__c trial = [SELECT Id FROM CFAR_Trial_gne__c LIMIT 1];
		CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
		cont.mainTrialId = trial.Id;

		//WHEN
		String displayedPartnerships = cont.trialWrapper.getDisplayedPartnerships();

		//THEN
		System.assertEquals('', displayedPartnerships);

		//WHEN
		cont.trialWrapper.innerObject.put('Partnership_Multi_gne__c', 'N/A');
		displayedPartnerships = cont.trialWrapper.getDisplayedPartnerships();

		//THEN
		System.assertEquals('N/A', displayedPartnerships);

		//WHEN
	 	CFAR_Partnership_gne__c partnership1 = CFAR_TestUtils.createPartnership('testPartnership2', true);
		CFAR_Partnership_gne__c partnership2 = CFAR_TestUtils.createPartnership('testPartnership3', true);
		trial.Partnership_Multi_gne__c = partnership1.Id + ';' + partnership2.Id;
		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TrialTrigger'});
		update trial;
		cont.refreshMainTrial();
		displayedPartnerships = cont.trialWrapper.getDisplayedPartnerships();

		//THEN
		System.assertEquals('testPartnership2, testPartnership3', displayedPartnerships);
	}

	@isTest
	static void getSRTTeamSelectOptions_ShouldReturnSRTTeamSelectOptions() {
		//WHEN
		CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
		List<SelectOption> availableSrtTeamSelectOptions = cont.trialWrapper.getSRTTeamSelectOptions();

		//THEN
		System.assertEquals(1, availableSrtTeamSelectOptions.size(),
			'Should return 1 SRT select option that was created on trial creation in setup function');
	}

	@isTest
	static void getImpactSelectOptions_ShouldReturnImpactSelectOptions() {
		//WHEN
		CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
		List<SelectOption> availableImpactSelectOptions = cont.trialWrapper.getImpactSelectOptions();

		//THEN
		System.assertEquals(6, availableImpactSelectOptions.size(),
			'Should return 6 impact select options that were created in setup function');
	}

	@isTest
	static void availableOtherGNEAgents_ShouldGetAvailableOtherGNEAgents() {
		//WHEN
		CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
		List<SelectOption> availableImpactSelectOptions = cont.trialWrapper.getImpactSelectOptions();

		//THEN
		System.assertEquals(6, availableImpactSelectOptions.size(),
			'Should return 6 impact select options that were created in setup function');
	}

	@isTest
	static void testPartnershipMultiselect() {
		CFAR_Trial_Controller cont = new CFAR_Trial_Controller();
		((CFAR_Trial_gne__c)cont.trialWrapper.innerObject).Partnership_Multi_gne__c = String.join(new List<String>((Set<String>)JSON.deserialize(JSON.serialize(new Map<Id, CFAR_Partnership_gne__c>([SELECT Id FROM CFAR_Partnership_gne__c LIMIT 3]).keySet()), Set<String>.class)), ';');
		((CFAR_Trial_gne__c)cont.trialWrapper.innerObject).Therapeutic_Area_ref_gne__c = CFAR_Utils.BIOONCOLOGY_TA_ID;
		cont.editGeneralInfo();
		cont.clearGeneralAndSpecificIndicationsForBiooncology();

		System.debug(((CFAR_Trial_gne__c)cont.trialWrapper.innerObject).Partnership_Multi_gne__c);
		System.debug(cont.trialWrapper.selectedPartnerships);

		System.debug(cont.trialWrapper.selectedGeneralIndications);
		System.debug(cont.trialWrapper.selectedGeneralIndicationsPopUp);
		System.debug(cont.trialWrapper.selectedSpecificIndications);
		System.debug(((CFAR_Trial_gne__c)cont.trialWrapper.innerObject).CFAR_General_Indication_ref_gne__c);

		System.assert(cont.trialWrapper.selectedSpecificIndications.isEmpty());
		System.assert(cont.trialWrapper.selectedGeneralIndications.isEmpty());
		System.assert(cont.trialWrapper.selectedGeneralIndicationsPopUp.isEmpty());
		System.assertEquals(((CFAR_Trial_gne__c)cont.trialWrapper.innerObject).CFAR_General_Indication_ref_gne__c, null);

		//JSON.serialize(new Set<Id>(new Map<Id, CFAR_Partnership_gne__c>([SELECT Id FROM CFAR_Partnership_gne__c LIMIT 3]).keySet()),';');
	}
}