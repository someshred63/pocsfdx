public with sharing class CFAR_DrugSupply_Controller extends CFAR_TrialBaseController {

        //Specific and generic containers
        public String objectId {get; set;}
        public SObject s_object {get; set;}
        public CFAR_Cohort_gne__c newCohortObject {get;set;}
        public Map<Id, CFAR_SObjectWrapper> objectMapMolecule {get; set;}
        public List<SelectOption> productSelectOptions {get; set;}
        public List<SelectOption> moleculeConfigurationSelectOptions {get; set;}
        public List<SelectOption> dosageIntervalSelectOptions {get; set;}
        public List<CFAR_Cohort_gne__c> CohortList {get;set;}
        public List<DrugSupplyWrapper> drugSupplyWrapperList {get;set;}
        public String cohortNumber {get;set;}
        public String totalCohortPatients {get;set;}
        public String dosageFrequency {get;set;}
        public String quantity {get;set;}

        public String selectedDosageInterval {get;set;}
        public String monthsOnTherapy {get;set;}
        public String cohortComments {get;set;}

        //Variables
        public String selectedProduct {get; set;}
        public String selectedMoleculeConfiguration {get; set;}
        public String cohortId {get;set;}
        public Boolean isEditCohort {get;set;}
        public Boolean isEditMolecule {get;set;}
        public Boolean addCohort {get;set;}
        public Boolean isError {get;set;}
        public Boolean renderActionFunction {get;set;}

        public List<DrugSupplyWrapper> getDrugSupplyWrapperListM() {
                initDrugSupply();
                return drugSupplyWrapperList;
        }

        //Constructor
        public CFAR_DrugSupply_Controller() {

                super(true);
                componentID = 'componentID == DrugSupply Controller!! ';
                renderActionFunction = false;
                addCohort = false;
        }

        public void initDrugSupply(){
                if(isEditMolecule != true)      
                        fillDrugSupplyWrapperList();
                fillProductSelectOptions();
                fillMoleculeConfigurationSelectOptions();
                fillDosageIntervalSelectOptions();
                renderActionFunction = false;
        }

        public override void refreshTrialChildObjects() {

        }  
    	
        //Fill Containers Methods

        public void fillCohortList() {

                if(trial.Id != null){

                        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
                        parameters.sortDirection = 'asc';
                        parameters.sortExpression = 'Cohort_number_gne__c';
                        parameters.andEqualsParameters.put('Trial_ref_gne__c', trial.Id);

                        CohortList = CFAR_DAO.getCohorts(parameters);
                }
        }

        public void fillDrugSupplyWrapperList() {

                objectMapMolecule = new Map<Id, CFAR_SObjectWrapper>();
                drugSupplyWrapperList = new List<DrugSupplyWrapper>();
                Map<Id, List<CFAR_SObjectWrapper>> cohortId2WrapperMap = new Map<Id, List<CFAR_SObjectWrapper>>();
                fillCohortList();

                if (CohortList != null) {
                        Map<Id, CFAR_Cohort_gne__c> cohortMap = new Map<Id, CFAR_Cohort_gne__c>(CohortList);
                        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
                        parameters.sortDirection = 'asc';
                        parameters.sortExpression = 'CreatedDate';
                        parameters.andInParameters.put('Cohort_ref_gne__c', new List<Id> (cohortMap.keySet()));

                        try {
                                List<CFAR_SObjectWrapper> objectListMolecule;
                                for (SObject molecule : CFAR_DAO.getMolecules(parameters)) {
                                        Id cohortId = ((CFAR_Cohort_Molecule_gne__c) molecule).Cohort_ref_gne__c;
                                        CFAR_SObjectWrapper obj = new CFAR_SObjectWrapper(molecule, false);
                                        objectMapMolecule.put(molecule.Id, obj);
                                        if (cohortId2WrapperMap.containsKey(cohortId)) {
                                                objectListMolecule = cohortId2WrapperMap.get(cohortId);
                    } else {
                                                objectListMolecule = new List<CFAR_SObjectWrapper>();
                                                cohortId2WrapperMap.put(cohortId, objectListMolecule);
                                        }
                                        objectListMolecule.add(obj);
                                }
                                for (Id cohortId : cohortId2WrapperMap.keySet()) {
                                        DrugSupplyWrapper wrapperObject = new DrugSupplyWrapper();
                                        wrapperObject.Cohort = cohortMap.get(cohortId);
                                        wrapperObject.MoleculeList = cohortId2WrapperMap.get(cohortId);
                                        drugSupplyWrapperList.add(wrapperObject);
                                }
                        } catch (Exception e) {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                        }
                }
        }

        public void fillProductSelectOptions() {

                productSelectOptions = new List<SelectOption>();
                CFAR_SearchParameters parameters = new CFAR_SearchParameters();
                parameters.andEqualsParameters.put('IMP_Shipped_ref__r.Other_GNE_Agent_Active_gne__c', true);

                if(trial.Id != null)
                        parameters.andEqualsParameters.put('CFAR_Trial_ref_gne__c', String.ValueOf(trial.Id));
                List<CFAR_Trial_IMP_Shipped__c> impShipped = CFAR_DAO.getTrialIMPShipped(parameters);
                if(!impShipped.isEmpty()){
                        for(CFAR_Trial_IMP_Shipped__c agent : CFAR_DAO.getTrialIMPShipped(parameters)){
                                productSelectOptions.add(new SelectOption(agent.IMP_Shipped_ref__c, agent.IMP_Shipped_ref__r.Name));
                        }
                }
        }

        public void fillMoleculeConfigurationSelectOptions() {

                moleculeConfigurationSelectOptions = new List<SelectOption>();
                CFAR_SearchParameters parameters = new CFAR_SearchParameters();
                parameters.sortDirection = 'asc';

                if (selectedProduct != null) {
                        parameters.andEqualsParameters.put('Product_gne__c', selectedProduct);
                } else if (!productSelectOptions.isEmpty()) {
                        selectedProduct = productSelectOptions.get(0).getValue();
                        parameters.andEqualsParameters.put('Product_gne__c', selectedProduct);
                }
                for (CFAR_Molecule_Configuration_gne__c configuration : CFAR_DAO.getMoleculeConfigurations(parameters)) {
                        if(configuration.Active_gne__c == true){
                                moleculeConfigurationSelectOptions.add(new SelectOption(configuration.Id, configuration.Configuration_gne__c + ' ' + configuration.CFAR_Unit_type_ref_gne__r.Name));
                        }
                }
        }

		public void fillDosageIntervalSelectOptions() {
			dosageIntervalSelectOptions = new List<SelectOption> ();
			Schema.DescribeFieldResult fieldResult = CFAR_Cohort_Molecule_gne__c.Dosage_Interval_gne__c.getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry f : ple) {
				dosageIntervalSelectOptions.add(new SelectOption(f.getLabel(), f.getValue()));
			}
		}

        public SelectOption[] getTimeUnitsSelectOptions() {

                List<SelectOption> timeUnitList = new List<SelectOption>();
                timeUnitList.add(new SelectOption('Hours', 'Hours'));
                timeUnitList.add(new SelectOption('Days', 'Days'));
                timeUnitList.add(new SelectOption('Months', 'Months'));

                return timeUnitList;
        }

        // Action Methods

        public void saveMolecule() {

                if (canSaveMoleculeOrCohort(false)) {
                        this.s_object.put('Dosage_Frequency_gne__c', Integer.valueOf(dosageFrequency));
                        this.s_object.put('Months_On_Therapy_gne__c', Integer.valueOf(monthsOnTherapy));
                        this.s_object.put('Comments_gne__c', cohortComments);
                        this.s_object.put('Dosage_Interval_gne__c', selectedDosageInterval);
                        this.s_object.put('Dosage_Qty_gne__c', Integer.valueOf((Decimal.valueOf(quantity)).round(System.RoundingMode.UP)) );
                        this.s_object.put('Molecule_Configuration_ref_gne__c', selectedMoleculeConfiguration);
                        this.s_object.put('Cohort_ref_gne__c', cohortId);
                        ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
                        PageReference pr = ctrl.save();

                        isEditMolecule = false;
                        dosageFrequency = null;
                        monthsOnTherapy = null;
                        cohortComments = null;
                        quantity = null;

                        isEditMolecule = false;
                        isError = false;
                        fillDrugSupplyWrapperList();
                } else {
                        isError = true;
                }
        }
    
    	public Boolean newGNEAgent {get; set;}
    	public void addAnotherGNEAgent() {
            try{
				newGNEAgent = true;
                isEditMolecule = true;
                Schema.SObjectType targetType = Schema.getGlobalDescribe().get('CFAR_Cohort_Molecule_gne__c');
                s_object = targetType.newSObject();
                prepareFieldsToCreateMolecule();

                fillDrugSupplyWrapperList();
            CFAR_SObjectWrapper wrp = new CFAR_SObjectWrapper(this.s_object, true);
            for(DrugSupplyWrapper w : drugSupplyWrapperList){
                if(cohortId == w.Cohort.id){
                    w.MoleculeList.add(wrp);
                }
            }

                } catch(Exception ex){
                    System.debug(ex.getMessage());
                }
        }

        public void deleteMolecule() {

                if (canDeleteMolecule()) {
                        CFAR_Utils_WithoutSharing.deleteSObject(objectMapMolecule.get(objectId).innerObject);
                        fillDrugSupplyWrapperList();
                }
        }
        
        public Boolean getIsUserReadOnly() {
    	Boolean retVal = false;
    	Profile prof = [select Name from Profile where Id =: UserInfo.getProfileId() limit 1][0];
    	if (prof.Name.equals('GNE-CFAR-ReadOnlyUser-New')) {
    		retVal = true;
    	}
    	return retVal;
    }

        public void editMolecule() {
         		newGNEAgent = false;
                objectMapMolecule.get(objectId).selected = true;
                s_object = objectMapMolecule.get(objectId).innerObject.clone(true, true, true, true);
                isEditMolecule = true;
                prepareFieldsToEditMolecule();
        }

        private void prepareFieldsToEditMolecule() {

                try {
                        selectedMoleculeConfiguration = String.ValueOf(this.s_object.get('Molecule_Configuration_ref_gne__c'));
                        String moleculeId = String.ValueOf(this.s_object.get('Molecule_Configuration_ref_gne__c'));
                        CFAR_Cohort_Molecule_gne__c currentMolecule = [SELECT Dosage_Frequency_gne__c, Molecule_Configuration_ref_gne__r.Product_gne__c FROM CFAR_Cohort_Molecule_gne__c WHERE Molecule_Configuration_ref_gne__c = :moleculeId LIMIT 1];
                        selectedProduct = currentMolecule.Molecule_Configuration_ref_gne__r.Product_gne__c;
                        dosageFrequency = String.valueOf(s_object.get('Dosage_Frequency_gne__c'));
                        monthsOnTherapy = String.valueOf(s_object.get('Months_On_Therapy_gne__c'));
                        cohortComments = String.valueOf(s_object.get('Comments_gne__c'));
                        quantity = String.valueOf(s_object.get('Dosage_Qty_gne__c'));
                        selectedDosageInterval = String.valueOf(s_object.get('Dosage_Interval_gne__c'));
                        fillMoleculeConfigurationSelectOptions();
                        fillDosageIntervalSelectOptions();

                } catch (Exception e) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                }
        }

        private void prepareFieldsToCreateMolecule() {

                try {
                        this.s_object.put('Dosage_Qty_gne__c', 1);
                        this.s_object.put('Months_On_Therapy_gne__c', null);
                        this.s_object.put('Cohort_ref_gne__c', cohortId);
                        monthsOnTherapy = '';
                        quantity = '1';
                        cohortComments = '';
                        dosageFrequency = '';
                        selectedMoleculeConfiguration = null;
                        selectedDosageInterval = null;
                        selectedProduct = productSelectOptions.get(0).getValue();
                        fillDosageIntervalSelectOptions();
                        fillMoleculeConfigurationSelectOptions();
                } catch (Exception e) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                }
        }

        public void cancelEditMolecule() {
            if(!newGNEAgent){
                isEditMolecule = false;
				objectMapMolecule.get(objectId).selected = false;
            	isEditMolecule = false;
            } else{
            DrugSupplyWrapper tmpWrapper = new DrugSupplyWrapper();
            for(DrugSupplyWrapper w : drugSupplyWrapperList) {
                if (cohortId == w.Cohort.id) {
                    tmpWrapper = w;
                    break;
                }
            }
            if(tmpWrapper != null) {
                for (Integer i = 0; i < tmpWrapper.MoleculeList.size(); i++) {
                    if (tmpWrapper.MoleculeList.get(i).selected == true) {
                        tmpWrapper.MoleculeList.remove(i);
                    }
                }
            }

                 isEditMolecule = false;
            dosageFrequency = null;
            monthsOnTherapy = null;
            cohortComments = null;
            quantity = null;
            }
        }

        public void editCohort(){
                isEditCohort = true;
        }

        public void cancelEditCohort(){
                isEditCohort = false;
                fillDrugSupplyWrapperList();
        }

        public void saveCohort() {
                Set<CFAR_Cohort_gne__c> toUpdate = new Set<CFAR_Cohort_gne__c>();
                for (DrugSupplyWrapper wrapperObject : drugSupplyWrapperList) {
                        if (String.valueOf(wrapperObject.Cohort.Id) == cohortId) {
                                if (canUpdateCohort(wrapperObject)) {
                                    toUpdate.add(wrapperObject.Cohort);
                                }
                        }
                }

                if(!toUpdate.isEmpty()) {
                    update new List<CFAR_Cohort_gne__c>(toUpdate);
                    isEditCohort = false;
                    fillDrugSupplyWrapperList();
                }
        }

        public void deleteCohort() {
                Set<CFAR_Cohort_gne__c> toDelete = new Set<CFAR_Cohort_gne__c>();
                for (DrugSupplyWrapper wrapperObject : drugSupplyWrapperList) {
                        if (String.valueOf(wrapperObject.Cohort.Id) == cohortId) {
                            toDelete.add(wrapperObject.Cohort);
                        }
                }
                if(!toDelete.isEmpty()){
                    delete new List<CFAR_Cohort_gne__c>(toDelete);
                }
                fillDrugSupplyWrapperList();
        }

        public void addNewCohort() {

                addCohort = true;
                newCohortObject = new CFAR_Cohort_gne__c();
                newCohortObject.Trial_ref_gne__c = CFAR_Utils.getActualTrialId();

                Schema.SObjectType targetType = Schema.getGlobalDescribe().get('CFAR_Cohort_Molecule_gne__c');
                s_object = targetType.newSObject();
                s_object.put('Dosage_Qty_gne__c', 1);
                quantity = '1';
                cohortNumber = '1';
                try{
                    List<AggregateResult> highestNumberCohort = [SELECT MAX(Cohort_number_gne__c)am FROM CFAR_Cohort_gne__c WHERE Trial_ref_gne__c = :trial.Id];
                    cohortNumber = String.valueOf(Integer.valueOf(highestNumberCohort[0].get('am')) + 1);
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
        }

        public void createCohort() {

            isError = false;
            s_object.put('Molecule_Configuration_ref_gne__c', selectedMoleculeConfiguration);
            if (!canSaveMoleculeOrCohort(true)) {
                addNewCohort();
                isError = true;
                addCohort = true;

            } else {
                try {
                    newCohortObject.Total_Cohort_Patients_gne__c = Decimal.ValueOf(totalCohortPatients);
                    newCohortObject.Cohort_number_gne__c = Decimal.ValueOf(cohortNumber);
                    CFAR_SecurityUtils.insertRecord(newCohortObject);
                    s_object.put('Dosage_Frequency_gne__c', Integer.valueOf(dosageFrequency));
                    s_object.put('Months_On_Therapy_gne__c', Integer.valueOf(monthsOnTherapy));
                    s_object.put('Comments_gne__c', cohortComments);
                    s_object.put('Dosage_Interval_gne__c', selectedDosageInterval);
                    s_object.put('Cohort_ref_gne__c', String.valueOf(newCohortObject.Id));
                    s_object.put('Dosage_Qty_gne__c', Integer.valueOf((Decimal.valueOf(quantity)).round(System.RoundingMode.UP)) );

                if(s_object != null) {
                    ApexPages.StandardController ctrl = new ApexPages.StandardController(s_object);
                    PageReference pr = ctrl.save();
                }
                    addCohort = false;

                    // reset fields after save
                    newCohortObject.Total_Cohort_Patients_gne__c = null;
                    s_object.put('Dosage_Interval_gne__c', null);
                    dosageFrequency = null;
                    monthsOnTherapy = null;
                    cohortComments = null;
                    totalCohortPatients = null;
                    selectedProduct = null;
                    selectedMoleculeConfiguration = null;
                    selectedDosageInterval = null;

                    fillDrugSupplyWrapperList();
                } catch (Exception e) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                }
            }
        }

        // Validations

    public Boolean canSaveMoleculeOrCohort(Boolean validateCohort) {

        Boolean validationError = true;
        Boolean numberNotUnique = false;
        Decimal sumOfTotalCohortPatients = 0;

        if (validateCohort) {
            List<CFAR_Cohort_gne__c> listOfCohorts = [SELECT ID, Cohort_number_gne__c, Trial_ref_gne__r.Planned_Enrollment_gne__c, Trial_ref_gne__c, Total_Cohort_Patients_gne__c FROM CFAR_Cohort_gne__c WHERE Trial_ref_gne__c = : newCohortObject.trial_ref_gne__c];

            for (CFAR_Cohort_gne__c cohort : listOfCohorts) {
                sumOfTotalCohortPatients += cohort.Total_Cohort_Patients_gne__c;
            }

            if (!totalCohortPatients.isNumeric())
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Total patients: Invalid number.'));
            if (!cohortNumber.isNumeric())
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cohort #: Invalid number.'));
            if (totalCohortPatients == null || totalCohortPatients == '')
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Total patients cannot be blank. Please enter a value.'));
            if (cohortNumber == null)
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cohort # cannot be blank. Please enter a value.'));
            if (totalCohortPatients.isNumeric()){
                if ((Decimal.valueOf(totalCohortPatients) + sumOfTotalCohortPatients) > trial.Planned_Enrollment_gne__c){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Total patients cannot exceed GNE Contractual Enrollment'));
                    validationError =  false;
                }
            }
            for (CFAR_Cohort_gne__c c : CohortList) {
                if (cohortNumber == String.valueOf(c.Cohort_number_gne__c)) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cohort # must be unique within study'));
                    numberNotUnique = true;
                }
            }

            if (!totalCohortPatients.isNumeric()
                || !cohortNumber.isNumeric()
                || totalCohortPatients == null
                || totalCohortPatients == ''
                || cohortNumber == null
                || numberNotUnique) {
                validationError =  false;
            }

        }

        if (dosageFrequency == null || dosageFrequency == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Dosage Frequency cannot be blank. Please enter a value.'));
        } else if (!dosageFrequency.isNumeric()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Dosage Frequency: Invalid number.'));
        }        
        //if (s_object.get('Dosage_Interval_gne__c') == null) {
        if (selectedDosageInterval == null || selectedDosageInterval == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Dosage Interval cannot be blank. Please enter a value.'));
        }
        if (quantity == null || quantity == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quantity cannot be blank. Please enter a value.'));
        }

		if (dosageFrequency.length() > 9) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Dosage Frequency: Number is to big.'));
        }
        if (monthsOnTherapy.length() > 9) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Months On Therapy: Number is to big.'));
        }
        Decimal q = null;
        try {
        	if (quantity != null && quantity != '') {
        		q = Decimal.valueOf(quantity);
        	}
			if (quantity.length() > 9 && q != null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quantity: Number is to big.'));
            }
        } catch (exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quantity: Invalid number.'));
        }
        if (quantity != null && quantity != '' && q!= null && q <= 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Quantity: Invalid number.'));
        }        
        if (selectedMoleculeConfiguration == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Molecule Configuration cannot be blank. Please enter a value.'));
        }
        //if (s_object.get('Months_On_Therapy_gne__c') == null) {
        if (monthsOnTherapy == null || monthsOnTherapy == '') {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Months On Therapy cannot be blank. Please enter a value.'));
        } else if (!monthsOnTherapy.isNumeric()) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Months On Therapy: Invalid number.'));
        }
        if(selectedProduct == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'IMP Shipped cannot be blank. Please enter a value.'));
        }

        if (selectedMoleculeConfiguration == null
                || s_object.get('Dosage_Qty_gne__c') == null || quantity == null || (quantity.length() > 9 && q != null) || quantity == '' || q == null || q <= 0
                || selectedDosageInterval == null //s_object.get('Dosage_Interval_gne__c') == null
                || monthsOnTherapy == null
                || monthsOnTherapy == ''
                || (monthsOnTherapy != '' && monthsOnTherapy.isNumeric() == false)
                || monthsOnTherapy.length() > 9
                || dosageFrequency == null
                || dosageFrequency.length() > 9
                || dosageFrequency == ''
                || (dosageFrequency != '' && dosageFrequency.isNumeric() == false)
                || selectedProduct == null) {
            validationError = false;
        }

        return validationError;
    }

    
        private Boolean canUpdateCohort(DrugSupplyWrapper wrapperObject) {

                Boolean numberNotUnique = false;
        Decimal sumOfTotalCohortPatients = 0;
                List<CFAR_Cohort_gne__c> listOfCohorts = [SELECT ID, Cohort_number_gne__c, Trial_ref_gne__r.Planned_Enrollment_gne__c, Trial_ref_gne__c, Total_Cohort_Patients_gne__c FROM CFAR_Cohort_gne__c WHERE Trial_ref_gne__c =: wrapperObject.Cohort.trial_ref_gne__c and ID != : wrapperObject.Cohort.Id];
        
        for(CFAR_Cohort_gne__c cohort : listOfCohorts){
            sumOfTotalCohortPatients += cohort.Total_Cohort_Patients_gne__c;
        }
				
                if (wrapperObject.Cohort.Total_Cohort_Patients_gne__c == null)
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Total patients cannot be blank. Please enter a value.'));
                if (wrapperObject.Cohort.Total_Cohort_Patients_gne__c <= 0)
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Total patients: Invalid number.'));
                if ((wrapperObject.Cohort.Total_Cohort_Patients_gne__c +sumOfTotalCohortPatients) > trial.Planned_Enrollment_gne__c)
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Total patients cannot exceed GNE Contractual Enrollment'));
                if (wrapperObject.Cohort.Cohort_number_gne__c == null)
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cohort # cannot be blank. Please enter a value.'));
                for (CFAR_Cohort_gne__c c : CohortList) {
                        if (wrapperObject.Cohort.Id != c.Id && wrapperObject.Cohort.Cohort_number_gne__c == c.Cohort_number_gne__c) {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cohort # must be unique within study'));
                                numberNotUnique = true;
                        }
                }
                if (wrapperObject.Cohort.Cohort_number_gne__c == null 
                		|| wrapperObject.Cohort.Total_Cohort_Patients_gne__c <= 0
                        || (wrapperObject.Cohort.Total_Cohort_Patients_gne__c + sumOfTotalCohortPatients) > trial.Planned_Enrollment_gne__c 
                        || wrapperObject.Cohort.Total_Cohort_Patients_gne__c == null || numberNotUnique) {
                        return false;
                } else {
                        return true;
                }
        }

        public Boolean canDeleteMolecule() {
                renderActionFunction = true;
                Boolean canDeleteMolecule = true;
                for (DrugSupplyWrapper wrapperObject : drugSupplyWrapperList) {
                        if (String.valueOf(wrapperObject.Cohort.Id) == cohortId) {
                                if (wrapperObject.MoleculeList.size() < 2) {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot delete last molecule from a Cohort'));
                                        canDeleteMolecule = false;
                                        isError = true;
                                } else {
                                        canDeleteMolecule = true;
                                        isError = false;
                                }
                        }
                }
                return canDeleteMolecule;
        }

        public class DrugSupplyWrapper{

                public CFAR_Cohort_gne__c Cohort {get;set;}
                public List<CFAR_SObjectWrapper> MoleculeList {get; set;}
        }

}