@isTest(seeAllData = false)
private class CFAR_DrugSupply_Controller_Test {

	static void setup() {
		//add Trial
		CFAR_TestUtils.createTestTrial();
		CFAR_DrugSupply_Controller_Test.createProductForTests('testProduct');
		CFAR_DrugSupply_Controller_Test.createTrialIMPShippedForTests();
		CFAR_DrugSupply_Controller_Test.createMoleculeConfigurationForTests();

	}

	static void createProductForTests(String productName){
		CFAR_Theme_gne__c newTheme = new CFAR_Theme_gne__c (
				Name = '0000',
				Theme_Name_gne__c = '0000',
				Active_gne__c = true
		);
		insert newTheme;

		CFAR_Product_gne__c newProduct = new CFAR_Product_gne__c(
				Name = productName,
				Abbreviation_gne__c = 'abc',
				Description_gne__c = 'testProduct',
				Generic_Name_gne__c = productName,
				Other_GNE_Agent_Active_gne__c = true,
				Active_gne__c = true,
				Theme_ref_gne__c = newTheme.Id
		);
		insert newProduct;
	}

	static void createTrialIMPShippedForTests() {
		CFAR_Trial_IMP_Shipped__c newTrialIMPShipped = new CFAR_Trial_IMP_Shipped__c();
		newTrialIMPShipped.IMP_Shipped_ref__c = [SELECT ID FROM CFAR_Product_gne__c LIMIT 1].Id;
		newTrialIMPShipped.CFAR_Trial_ref_gne__c = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id;

		insert newTrialIMPShipped;
	}

	static void createUnitTypeForTests(String unitTypeName) {
		CFAR_Unit_Type_gne__c unitType = new CFAR_Unit_Type_gne__c(Name = unitTypeName, Active_gne__c = true);
		insert unitType;
	}

	static void createMoleculeConfigurationForTests() {
		createUnitTypeForTests('tablet');
		CFAR_Molecule_Configuration_gne__c newMoleculeConfig = new CFAR_Molecule_Configuration_gne__c ();
		newMoleculeConfig.Active_gne__c = true;
		newMoleculeConfig.Configuration_gne__c = '100 mg';
		newMoleculeConfig.CFAR_Unit_Type_ref_gne__c = [SELECT ID FROM CFAR_Unit_Type_gne__c LIMIT 1].Id;
		newMoleculeConfig.Product_gne__c = [SELECT ID FROM CFAR_Product_gne__c LIMIT 1].Id;

		insert newMoleculeConfig;
	}


	static testMethod void createNewCohortOK() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());


	}

	static testMethod void create2CohortsOK() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '2';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '2';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment2';

		ctrl.createCohort();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(2, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(2, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(2, ctrl.CohortList.size());

	}

	static testMethod void create2CohortsNOK() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '2';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '2';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment2';

		ctrl.createCohort();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Cohort # must be unique within study')) b = true;
		}
		system.assert(b);

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());

	}

	static testMethod void editSecondCohortNOK() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '2';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '2';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment2';

		ctrl.createCohort();
		ctrl.getDrugSupplyWrapperListM();

		ctrl.editCohort();
		ctrl.objectId = [SELECT ID FROM CFAR_Cohort_gne__c WHERE Cohort_Number_gne__c = 2].get(0).Id;

		ctrl.drugSupplyWrapperList.get(1).Cohort.Cohort_Number_gne__c = 1;

		ctrl.cohortId = ctrl.objectId;
		ctrl.saveCohort();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Cohort # must be unique within study')) b = true;
		}
		system.assert(b);

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c WHERE Cohort_Number_gne__c = 1].size());

	}

	static testMethod void createNewCohortNOKCohortNumberIncorrectNumber() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Cohort #: Invalid number.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKTotalCohortPatientsEmpty() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Total patients cannot be blank. Please enter a value.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKTotalCohortPatientsIncorrectNumber() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = 'abc';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Total patients: Invalid number.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKTotalCohortPatientsExceeded() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '10000';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Total patients cannot exceed GNE Contractual Enrollment')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKSelectedProduct() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = null;
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		ctrl.getIsUserReadOnly();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('IMP Shipped cannot be blank. Please enter a value.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKQuantityEmpty() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '10000';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Quantity cannot be blank. Please enter a value.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKQuantityTooBig() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '10000';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '44444444444444444444444444';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Quantity: Number is to big.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKQuantityIncorrectNumber() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '10000';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = 'abc';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Quantity: Invalid number.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKMoleculeConfiguration() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = null;
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Molecule Configuration cannot be blank. Please enter a value.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKDosageFrequencyEmpty() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Dosage Frequency cannot be blank. Please enter a value.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKDosageFrequencyIncorrectNumber() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = 'abc';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Dosage Frequency: Invalid number.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKDosageFrequencyTooBig() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '333333333333333333333333333333';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Dosage Frequency: Number is to big.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKDosageInterval() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = null;
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Dosage Interval cannot be blank. Please enter a value.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKMonthsOnTherapyEmpty() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Months On Therapy cannot be blank. Please enter a value.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void createNewCohortNOKMonthsOnTherapyTooBig() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '33333333333333333333333333333';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();
		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Months On Therapy: Number is to big.')) b = true;
		}
		system.assert(b);

	}

	static testMethod void addAnotherGNEAgentOK() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();
		ctrl.addAnotherGNEAgent();
		System.assert(ctrl.newGNEAgent == true);
		System.assert(ctrl.isEditMolecule == true);

		ctrl.getTimeUnitsSelectOptions();
		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;

		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '2';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '2';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment2';

		ctrl.saveMolecule();

		System.assert(ctrl.isEditMolecule == false);

		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(2, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());

	}

	static testMethod void cancelAddAnotherGNEAgentOK() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();
		ctrl.addAnotherGNEAgent();
		System.assert(ctrl.newGNEAgent == true);
		System.assert(ctrl.isEditMolecule == true);

		ctrl.getTimeUnitsSelectOptions();
		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;

		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '2';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '2';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment2';

		ctrl.cancelEditMolecule();

		System.assert(ctrl.isEditMolecule == false);

		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());

	}

	static testMethod void editGNEAgentOK() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.initDrugSupply();
		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.objectId = ctrl.drugSupplyWrapperList.get(0).MoleculeList[0].innerObject.Id;
		ctrl.editMolecule();

		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '9';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '9';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '9';
		ctrl.cohortComments = 'testComment9';

		ctrl.saveMolecule();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		CFAR_Cohort_Molecule_gne__c modifiedMolecule = [
				SELECT
					Cohort_ref_gne__c,Comments_gne__c,Dosage_Frequency_gne__c,Dosage_Interval_gne__c,Dosage_Qty_gne__c,
					Id,Molecule_Configuration_ref_gne__c,Months_On_Therapy_gne__c,Name
				FROM
					CFAR_Cohort_Molecule_gne__c
		];

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());
		System.assertEquals(9, modifiedMolecule.Dosage_Qty_gne__c);
		System.assertEquals(ctrl.drugSupplyWrapperList.get(0).Cohort.Id, modifiedMolecule.Cohort_ref_gne__c);
		System.assertEquals(9, modifiedMolecule.Dosage_Frequency_gne__c);
		System.assertEquals(9, modifiedMolecule.Months_On_Therapy_gne__c);
		System.assertEquals('testComment9', modifiedMolecule.Comments_gne__c);

	}

	static testMethod void cancelEditGNEAgent() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.initDrugSupply();
		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.objectId = ctrl.drugSupplyWrapperList.get(0).MoleculeList[0].innerObject.Id;
		ctrl.editMolecule();

		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '9';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '9';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '9';
		ctrl.cohortComments = 'testComment9';

		ctrl.cancelEditMolecule();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		CFAR_Cohort_Molecule_gne__c modifiedMolecule = [
				SELECT
						Cohort_ref_gne__c,Comments_gne__c,Dosage_Frequency_gne__c,Dosage_Interval_gne__c,Dosage_Qty_gne__c,
						Id,Molecule_Configuration_ref_gne__c,Months_On_Therapy_gne__c,Name
				FROM
						CFAR_Cohort_Molecule_gne__c
		];

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());
		System.assertEquals(1, modifiedMolecule.Dosage_Qty_gne__c);
		System.assertEquals(ctrl.drugSupplyWrapperList.get(0).Cohort.Id, modifiedMolecule.Cohort_ref_gne__c);
		System.assertEquals(1, modifiedMolecule.Dosage_Frequency_gne__c);
		System.assertEquals(12, modifiedMolecule.Months_On_Therapy_gne__c);
		System.assertEquals('testComment', modifiedMolecule.Comments_gne__c);

	}

	static testMethod void deleteGNEAgentOK() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();
		ctrl.addAnotherGNEAgent();
		System.assert(ctrl.newGNEAgent == true);
		System.assert(ctrl.isEditMolecule == true);

		ctrl.getTimeUnitsSelectOptions();
		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;

		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '2';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '2';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment2';

		ctrl.saveMolecule();

		System.assert(ctrl.isEditMolecule == false);

		ctrl.getDrugSupplyWrapperListM();
		System.assertEquals(2, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());

		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.objectId = ctrl.drugSupplyWrapperList.get(0).MoleculeList[0].innerObject.Id;

		ctrl.deleteMolecule();

		Test.stopTest();

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());

	}

	static testMethod void deleteGNEAgentNOKLastGNEAgent() {
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();

		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.objectId = ctrl.drugSupplyWrapperList.get(0).MoleculeList[0].innerObject.Id;

		ctrl.deleteMolecule();

		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Cannot delete last molecule from a Cohort')) b = true;
		}
		system.assert(b);

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());

	}

	static testMethod void editCohortOK(){
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();
		ctrl.editCohort();
		ctrl.objectId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;

		ctrl.drugSupplyWrapperList.get(0).Cohort.Total_Cohort_Patients_gne__c = 200;

		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.saveCohort();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());
		System.assertEquals(1, ctrl.drugSupplyWrapperList.get(0).Cohort.Cohort_number_gne__c);
		System.assertEquals(1, [SELECT Cohort_number_gne__c FROM CFAR_Cohort_gne__c].get(0).Cohort_number_gne__c);
		System.assertEquals(200, ctrl.drugSupplyWrapperList.get(0).Cohort.Total_Cohort_Patients_gne__c);
		System.assertEquals(200, [SELECT Total_Cohort_Patients_gne__c FROM CFAR_Cohort_gne__c].get(0).Total_Cohort_Patients_gne__c);
	}

	static testMethod void editCohortNOKTotalCohortPatientsInvalidNumber(){
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();
		ctrl.editCohort();
		ctrl.objectId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;

		ctrl.drugSupplyWrapperList.get(0).Cohort.Total_Cohort_Patients_gne__c = -10;

		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.saveCohort();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(100, ctrl.drugSupplyWrapperList.get(0).Cohort.Total_Cohort_Patients_gne__c);
		System.assertEquals(100, [SELECT Total_Cohort_Patients_gne__c FROM CFAR_Cohort_gne__c].get(0).Total_Cohort_Patients_gne__c);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Total patients: Invalid number.')) b = true;
		}
		system.assert(b);
	}

	static testMethod void editCohortNOKTotalCohortPatientsExeeded(){
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();
		ctrl.editCohort();
		ctrl.objectId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;

		ctrl.drugSupplyWrapperList.get(0).Cohort.Total_Cohort_Patients_gne__c =  9999999;

		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.saveCohort();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(100, ctrl.drugSupplyWrapperList.get(0).Cohort.Total_Cohort_Patients_gne__c);
		System.assertEquals(100, [SELECT Total_Cohort_Patients_gne__c FROM CFAR_Cohort_gne__c].get(0).Total_Cohort_Patients_gne__c);

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		Boolean b = false;
		for(Apexpages.Message msg : msgs){
			if (msg.getDetail().contains('Total patients cannot exceed GNE Contractual Enrollment')) b = true;
		}
		system.assert(b);
	}

	static testMethod void cancelEditCohort(){
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();
		ctrl.editCohort();
		ctrl.objectId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;

		ctrl.drugSupplyWrapperList.get(0).Cohort.Total_Cohort_Patients_gne__c = 200;

		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.cancelEditCohort();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(1, ctrl.CohortList.size());
		System.assertEquals(1, ctrl.drugSupplyWrapperList.get(0).Cohort.Cohort_number_gne__c);
		System.assertEquals(1, [SELECT Cohort_number_gne__c FROM CFAR_Cohort_gne__c].get(0).Cohort_number_gne__c);
		System.assertEquals(100, ctrl.drugSupplyWrapperList.get(0).Cohort.Total_Cohort_Patients_gne__c);
		System.assertEquals(100, [SELECT Total_Cohort_Patients_gne__c FROM CFAR_Cohort_gne__c].get(0).Total_Cohort_Patients_gne__c);
	}

	static testMethod void deleteCohortOK(){
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		ctrl.getDrugSupplyWrapperListM();

		ctrl.cohortId = ctrl.drugSupplyWrapperList.get(0).Cohort.Id;
		ctrl.deleteCohort();
		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(0, ctrl.CohortList.size());
	}

	static testMethod void emptyCohort(){
		CFAR_DrugSupply_Controller_Test.setup();
		CFAR_Trial_gne__c trial = [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1];

		CFAR_Utils.setActualTrialId(trial.Id);

		//check new Trial created
		System.assertEquals(1, [SELECT ID FROM CFAR_Trial_gne__c].size());
		//check actualTrialId
		System.assertEquals(CFAR_Utils.getActualTrialId(), [SELECT ID FROM CFAR_Trial_gne__c LIMIT 1].Id);

		Test.startTest();

		CFAR_DrugSupply_Controller ctrl = new CFAR_DrugSupply_Controller();
		ctrl.getDrugSupplyWrapperListM();
		ctrl.addNewCohort();

		ctrl.cohortNumber = '1';
		ctrl.totalCohortPatients = '100';
		ctrl.selectedProduct = ctrl.productSelectOptions.get(0).getValue();
		ctrl.quantity = '1';
		ctrl.selectedMoleculeConfiguration = ctrl.moleculeConfigurationSelectOptions.get(0).getValue();
		ctrl.dosageFrequency = '1';
		ctrl.selectedDosageInterval = ctrl.dosageIntervalSelectOptions.get(0).getValue();
		ctrl.monthsOnTherapy = '12';
		ctrl.cohortComments = 'testComment';

		ctrl.createCohort();

		CFAR_Cohort_Molecule_gne__c toDelete = [SELECT ID FROM CFAR_Cohort_Molecule_gne__C LIMIT 1];
		delete toDelete;

		ctrl.getDrugSupplyWrapperListM();

		Test.stopTest();

		System.assertEquals(1, [SELECT ID FROM CFAR_Cohort_gne__c].size());
		System.assertEquals(0, [SELECT ID FROM CFAR_Cohort_Molecule_gne__c].size());
		System.assertEquals(0, ctrl.drugSupplyWrapperList.size());
	}
}