public virtual class CFAR_TrialWrapper extends CFAR_SObjectWrapper{
        Map<ID,CFAR_Product_gne__c> productsMap{get; private set;} 
        public String receivedDateString {get;set;}

        public Map<String,String> validationErrors {get; set;}
        
        public Map<String,CFAR_Trial_Type_of_Sample_gne__c> trialTypeOfSampleRecordsMap {get; set;}
        public String typeOfSampleId {get; set;}
        public CFAR_Trial_Type_of_Sample_gne__c newEditTrialTypeOfSample {get; set;}
        public String otherTOSId {get; set;}
        public Set<Id> usedTypeOfSamples;
        public CFAR_Trial_gne__c trialBeforeUpdate;
        public Set<Id> trialBeforeUpdateOGAs;
        public Set<Id> trialBeforeUpdateIMPShipped;
        public Set<Id> trialBeforeUpdateGIs;
        public String portalRONumber {get;set;}
        //public static final String TRIAL_REOPENED_STUDY_STATUS = 'Re-open';
        //public static final String TRIAL_ADMIN_FIX_STATUS = 'Admin Fix';
        public boolean generalInfoEditMode {get; set;}
        	            
        private List<String> fieldsToValidateAdd= new List<String> {'receivedDateStringError','productIdError','primaryContactError','therapeuticAreaError',
                                                                    'studyPhaseError','subjectTypeError','generalIndicationError','sampleSizeError','investigatorError',
                                                                    'mslError','trialTypeError','CTMSRequiredError','specificIndicationOtherError',
                                                                    'generalIndicationOtherError','SubjectTypeOtherError'
                                                                    };
 
        private Map<String,String> prePopulateValidationErrorsMap(List<String> fieldsList) {
            Map<String,String> errorsMap = new Map<String,String>(); 
            
            for(String s : fieldsList) {
                errorsMap.put(s,'');
            }
            return errorsMap;
        }
        
        
        public Map<String,String> getValidationErrors(){
            
            validationErrors = prePopulateValidationErrorsMap(fieldsToValidateAdd);
            
            String requiredString = 'You must enter a value';
            
            if (String.isBlank(receivedDateString)){
                validationErrors.put('receivedDateStringError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Received Date cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            else try {
                //Date.parse(receivedDateString);
                if (Date.parse(receivedDateString) > System.today()) {
                	validationErrors.put('receivedDateStringError', 'Received Date cannot be in the future');
                	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Received Date cannot be in the future');
                	ApexPages.addMessage(myMsg);
                }
            }
            catch(TypeException e) {
                validationErrors.put('receivedDateStringError', e.getMessage());
            }
            
            if (String.isBlank(productId)){
                validationErrors.put('productIdError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Theme cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            
            if (String.isBlank(String.valueOf(this.innerObject.get('Trial_Type_ref_gne__c')))){
                validationErrors.put('trialTypeError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Trial Type cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            
            if (String.isBlank(String.valueOf(this.innerObject.get('Genentech_Primary_Contact_ref_gne__c')))){
                validationErrors.put('primaryContactError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Primary Contact cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            
            if (String.isBlank(String.valueOf(this.innerObject.get('Therapeutic_Area_ref_gne__c')))){
                validationErrors.put('therapeuticAreaError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Medical Unit cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            
            if (!(this.selectedStudyPhase.size()>0)){
                validationErrors.put('studyPhaseError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Study Phase cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }

            if (String.isBlank(String.valueOf(this.innerObject.get('Subject_Type__c')))){
                validationErrors.put('subjectTypeError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Subject Type cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            if ('Other'.equals(String.valueOf(this.innerObject.get('Subject_Type__c'))) && String.isBlank(String.valueOf(this.innerObject.get('Subject_Type_Other_gne__c')))) {
            	validationErrors.put('SubjectTypeOtherError', requiredString);
            	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Subject Type Other cannot be blank. Please enter a value.');
            	ApexPages.addMessage(myMsg);
            }       
            
            if ('Human'.equals(String.valueOf(this.innerObject.get('Subject_Type__c'))) && String.isBlank(String.valueOf(this.innerObject.get('CTMS_gne__c')))) {
            	validationErrors.put('CTMSRequiredError', requiredString);
            	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'CTMS # cannot be blank. Please enter a value.');
            	ApexPages.addMessage(myMsg);
            }
            
            if (String.isBlank(String.valueOf(this.innerObject.get('CFAR_General_Indication_ref_gne__c')))){
                validationErrors.put('generalIndicationError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'General Indication cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            
            if (selectedGeneralIndications != null && !selectedGeneralIndications.isEmpty()) {
            	Set<String> sgiSet = new Set<String>(selectedGeneralIndications);
            	if (sgiSet.contains(CFAR_Utils.GENERAL_INDICATION_OTHER_OPTION_ID) && String.isBlank(String.valueOf(this.innerObject.get('General_Indication_Other_gne__c')))) {
            		validationErrors.put('generalIndicationOtherError', requiredString);
            		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'General Indication Other cannot be blank. Please enter a value.');
            		ApexPages.addMessage(myMsg);
            	}
            }
            
            if (selectedSpecificIndications != null && !selectedSpecificIndications.isEmpty()) {
            	Set<String> ssiSet = new Set<String>(selectedSpecificIndications);
            	if (ssiSet.contains(CFAR_Utils.SPECIFIC_INDICATION_OTHER_OPTION_ID) && String.isBlank(String.valueOf(this.innerObject.get('Specific_Indication_Other_gne__c')))) {
            		validationErrors.put('specificIndicationOtherError', requiredString);
            		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Specific Indication cannot be blank. Please enter a value.');
            		ApexPages.addMessage(myMsg);
            	}
            }
			
			if (this.sampleSize == '' || this.SampleSize == null){
                validationErrors.put('sampleSizeError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Sample Size cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
                System.debug('sample' + this.sampleSize);
            }
            else try {
                //Double.valueOf(this.sampleSize);

                if(Double.valueOf(this.sampleSize) == 0) {
                    validationErrors.put('sampleSizeError', 'Sample Size cannot be a 0. Please enter a number');
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Sample Size cannot be a 0. Please enter a number');
                    ApexPages.addMessage(myMsg);
                }
            }
            catch(TypeException e) {
                validationErrors.put('sampleSizeError', e.getMessage());
            }
            
            if (String.isBlank(String.valueOf(this.innerObject.get('Investigator_ref_gne__c')))){
                validationErrors.put('investigatorError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Investigator cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            
            if (String.isBlank(String.valueOf(this.innerObject.get('MSL_ref_gne__c')))){
                validationErrors.put('mslError', requiredString);
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'MSL/MSD cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
                
            for(String s : validationErrors.values()) {
            	if(s != '') {
            		break;
            	}
            }            
                   
            return validationErrors;            
        }
        
        public Database.SaveResult insertSobj(){            

               prepareSobjectForDML();
               return (Database.insert (this.innerObject)); 

        }
        
        private void prepareSobjectForDML(){
            this.innerObject.put('Received_Date_gne__c',Date.parse(this.receivedDateString));
            this.innerObject.put('Product_ref_gne__c',productId);
            this.innerObject.put('Planned_Enrollment_gne__c',Double.valueOf(this.sampleSize));
                        
        }
        


        public CFAR_TrialWrapper(){
            this.innerObject = new CFAR_Trial_gne__c(); 
            init();
        }
        
        public CFAR_TrialWrapper(CFAR_Trial_gne__c trial){
            super(trial);
            init();
        }
        
        
        private void init(){            
            this.receivedDateString = String.valueOf(DateTime.now().format('MM/dd/yyyy'));
              this.sampleSize = '';
            
            validationErrors = prePopulateValidationErrorsMap(fieldsToValidateAdd);
            this.generalInfoEditMode = true;
        }
        
        public void clear(){
            receivedDateString = ''; 
            sampleSize = '';
            productId = null; 
            productsMap = null; 
            primaryContactId = null;  
            investigatorId = null; 
            mslId = null; 
            //otherSubjectTypeValue = null; 
            this.innerObject = new CFAR_Trial_gne__c (); 
            selectedGeneralIndications = null;
            selectedGeneralIndicationsPopUp = null;
            selectedSpecificIndications = null;
            validationErrors = prePopulateValidationErrorsMap(fieldsToValidateAdd);
        }
        
        
        public ID productId { get; set; }
        
        public String ThemeNo {get
            {

                CFAR_SearchParameters params = new CFAR_SearchParameters();
                if(productId != null)
                    params.andEqualsParameters.put('Id',String.valueOf(productId));
                CFAR_Product_gne__c[] products = CFAR_DAO.getProducts(params); 

                return ( (products.size() == 1) ? String.valueOf(products[0].Theme_ref_gne__r.Name) : '' );                
            }
        }
        
        public ID primaryContactId {get;set;}
        public ID investigatorId {get;set;}
        public ID mslId {get;set;}
        
//type of sample logic to change end
        
        public void clearOtherGeneralIndication(){
        	boolean noOther = true;
        	if(this.selectedGeneralIndications != null && !this.selectedGeneralIndications.isEmpty()) {
	        	Set<String> selectedGeneralIndicationsSet = new Set<String>(this.selectedGeneralIndications);
	        	if (selectedGeneralIndicationsSet.contains(CFAR_Utils.GENERAL_INDICATION_OTHER_OPTION_ID)) {
	        		noOther = false;
	        	}
        	}
        	if(noOther) {
            	this.innerObject.put('General_Indication_Other_gne__c',null);
        	}
        }
        
        public Boolean getShowGeneralIndicationOther(){
        	Boolean retVal = false;
        	List<String> selectedGenIndications = null;
        	if(generalInfoEditMode) {
        		if(this.selectedGeneralIndications!= null && this.selectedGeneralIndications.size() > 0) {
	        		selectedGenIndications = this.selectedGeneralIndications;
        		}
        	} else {
        		List<CFAR_General_Indication_for_Trial_gne__c> gift = [select Id, CFAR_General_Indication_ref_gne__c from CFAR_General_Indication_for_Trial_gne__c where CFAR_Trial_ref_gne__c = :this.innerObject.Id and CFAR_General_Indication_ref_gne__c = :CFAR_Utils.GENERAL_INDICATION_OTHER_OPTION_ID limit 1];
        		if (!gift.isEmpty()) {
	        		//selectedGenIndications = CFAR_Utils.convert15to18ID(String.valueOf(this.innerObject.get('General_Indication_Multi_gne__c')).split(';'));
        			return true;
        		}
        	}

            if(selectedGenIndications != null && !selectedGenIndications.isEmpty()) {
	        	Set<String> selectedGenIndicationsSet = new Set<String>(selectedGenIndications);
	        	if (selectedGenIndicationsSet.contains(CFAR_Utils.GENERAL_INDICATION_OTHER_OPTION_ID)) {
	        		retVal = true;
	        	}
            }
            if (!retVal) {
            	this.innerObject.put('General_Indication_Other_gne__c', null);
            }
        	return retVal;
        }
        
        public void clearOtherSpecificIndication(){
        	boolean noOther = true;
        	if(this.selectedSpecificIndications != null && !this.selectedSpecificIndications.isEmpty()) {
	        	Set<String> selectedSpecificIndicationsSet = new Set<String>(this.selectedSpecificIndications);
	        	if (selectedSpecificIndicationsSet.contains(CFAR_Utils.SPECIFIC_INDICATION_OTHER_OPTION_ID)) {
	        		noOther = false;
	        	}
        	}
        	if(noOther) {
            	this.innerObject.put('Specific_Indication_Other_gne__c',null);
        	}
        }
        
        public Boolean getShowSpecificIndicationOther(){
        	Boolean retVal = false;
        	system.debug('s otherz check s');
        	List<String> selectedIndications = null;
        	if(generalInfoEditMode) {
        		system.debug('++editMode');
        		if(this.selectedSpecificIndications!= null && this.selectedSpecificIndications.size() > 0) {
	        		system.debug('++editMode2');
	        		selectedIndications = this.selectedSpecificIndications;
        		}
        	} else {
        		system.debug('++nieeditMode');
        		List<CFAR_Specific_Indication_for_Trial_gne__c> sift = [select Id, CFAR_Specific_Indication_ref_gne__c from CFAR_Specific_Indication_for_Trial_gne__c where CFAR_Trial_ref_gne__c = :this.innerObject.Id and CFAR_Specific_Indication_ref_gne__c = :CFAR_Utils.SPECIFIC_INDICATION_OTHER_OPTION_ID limit 1];
        		if (!sift.isEmpty()) {
	        		system.debug('++nieeditMode2');
	        		return true;
        		}
        	}
        	
        	system.debug('s +++ si ' + selectedIndications);
            if(selectedIndications != null && !selectedIndications.isEmpty()) {
         	   Set<String> selectedIndicationsSet = new Set<String>(selectedIndications);
         	   if (selectedIndicationsSet.contains(CFAR_Utils.SPECIFIC_INDICATION_OTHER_OPTION_ID)) {
         	   		retVal = true;
         	   }
            }
        	if (!retVal) {
            	this.innerObject.put('Specific_Indication_Other_gne__c', null);
            }
        	return retVal;
        }
         
        public void clearSubjectTypeOtherAndCTMS() {
            this.innerObject.put('Subject_Type_Other_gne__c', null);
            	this.innerObject.put('CTMS_gne__c', null);
        }

        public String sampleSize{get;set;}
        
        private transient List<SelectOption> PrimaryContactSelectOptions1;
		private transient List<SelectOption> PrimaryContactSelectOptions2;
		private transient List<SelectOption> PrimaryContactSelectOptions3;
		private transient List<SelectOption> PrimaryContactSelectOptions4;
			
		protected List<SelectOption> wholePrimaryContactSelectOptions;
		public virtual void initWholePrimaryContactSelectOptions() {
			wholePrimaryContactSelectOptions = getPrimaryContactSelectOptions();
		}
		
		public List<SelectOption> getPrimaryContactSelectOptions1() {
	    	PrimaryContactSelectOptions1 = CFAR_Utils.getContactSearchListPart1(wholePrimaryContactSelectOptions);
	        return PrimaryContactSelectOptions1;
    	}
    
	    public List<SelectOption> getPrimaryContactSelectOptions2() {
	    	PrimaryContactSelectOptions2 = CFAR_Utils.getContactSearchListPart2(wholePrimaryContactSelectOptions);
	        return PrimaryContactSelectOptions2;
	    }
	    
	    public List<SelectOption> getPrimaryContactSelectOptions3() {
	    	PrimaryContactSelectOptions3 = CFAR_Utils.getContactSearchListPart3(wholePrimaryContactSelectOptions);
	        return PrimaryContactSelectOptions3;
	    }
	    
	    public List<SelectOption> getPrimaryContactSelectOptions4() {
	    	PrimaryContactSelectOptions4 = CFAR_Utils.getContactSearchListPart4(wholePrimaryContactSelectOptions);
	    	return PrimaryContactSelectOptions4;
	    }

        public virtual SelectOption[] getPrimaryContactSelectOptions(){
            SelectOption[] selectOptions = new SelectOption[]{};
            selectOptions.add(new SelectOption('','--None--'));
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            if(this.innerObject != null && this.innerObject.get('frm_Genentech_Primary_Contact_ref_gne__c') != null) {
            	selectOptions.add(new SelectOption(String.valueOf(this.innerObject.get('Genentech_Primary_Contact_ref_gne__c')),String.valueOf(this.innerObject.get('frm_Genentech_Primary_Contact_ref_gne__c'))));
				String[] notInIds = new String[] {String.valueOf(this.innerObject.get('Genentech_Primary_Contact_ref_gne__c'))};
				searchParms.andNOTInParameters.put('Id', notInIds);            
            } 
            searchParms.andEqualsParameters.put('Active_gne__c','true'); 
            searchParms.sortExpression = 'Search_Name__c'; 
            searchParms.sortDirection = 'asc';  
            searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c', CFAR_Utils.getAvailableRolesForPrimaryContact());
            selectOptions.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;             
            return selectOptions;           
        }

        private transient List<SelectOption> srtChairSelectList;

        private transient List<SelectOption> srtChairSelectOptions1;
		private transient List<SelectOption> srtChairSelectOptions2;
		private transient List<SelectOption> srtChairSelectOptions3;
		private transient List<SelectOption> srtChairSelectOptions4;

		protected List<SelectOption> wholeSRTSelectOptions;
		public virtual void initWholeSRTChairSelectOptions() {
			wholeSRTSelectOptions = getSrtChairSelectList();
		}

        public List<SelectOption> getSRTChairSelectOptions1() {
	    	srtChairSelectOptions1 = CFAR_Utils.getContactSearchListPart1(wholeSRTSelectOptions);
	        return SRTChairSelectOptions1;
    	}
    
	    public List<SelectOption> getSRTChairSelectOptions2() {
	    	srtChairSelectOptions2 = CFAR_Utils.getContactSearchListPart2(wholeSRTSelectOptions);
	        return SRTChairSelectOptions2;
	    }
	    
	    public List<SelectOption> getSRTChairSelectOptions3() {
	    	srtChairSelectOptions3 = CFAR_Utils.getContactSearchListPart3(wholeSRTSelectOptions);
	        return SRTChairSelectOptions3;
	    }
	    
	    public List<SelectOption> getSRTChairSelectOptions4() {
	    	srtChairSelectOptions4 = CFAR_Utils.getContactSearchListPart4(wholeSRTSelectOptions);
	    	return SRTChairSelectOptions4;
	    }	

        public virtual SelectOption[] getSrtChairSelectList(){
            SelectOption[] selectOptions = new SelectOption[]{};
            selectOptions.add(new SelectOption('','--None--'));
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            if(this.innerObject != null && this.innerObject.get('frm_SRT_Chair_ref_gne__c') != null) {
            	selectOptions.add(new SelectOption(String.valueOf(this.innerObject.get('SRT_Chair_ref_gne__c')),String.valueOf(this.innerObject.get('frm_SRT_Chair_ref_gne__c'))));
				String[] notInIds = new String[] {String.valueOf(this.innerObject.get('SRT_Chair_ref_gne__c'))};
				searchParms.andNOTInParameters.put('Id', notInIds);        
            } 
            searchParms.andEqualsParameters.put('Active_gne__c','true');    
            searchParms.sortExpression = 'Search_Name__c'; 
            searchParms.sortDirection = 'asc';          
            searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c', CFAR_Utils.getAvailableRolesForSRTChair());
            selectOptions.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;             
            return selectOptions;
        }
        
        private transient List<SelectOption> InvestigatorSelectOptions1;
		private transient List<SelectOption> InvestigatorSelectOptions2;
		private transient List<SelectOption> InvestigatorSelectOptions3;
		private transient List<SelectOption> InvestigatorSelectOptions4;
			
		protected List<SelectOption> wholeInvestigatorSelectOptions;
		public virtual void initWholeInvestigatorSelectOptions() {
			wholeInvestigatorSelectOptions = getInvestigatorSelectOptions();
		}
		
		public List<SelectOption> getInvestigatorSelectOptions1() {
	    	InvestigatorSelectOptions1 = CFAR_Utils.getContactSearchListPart1(wholeInvestigatorSelectOptions);
	        return InvestigatorSelectOptions1;
    	}
    
	    public List<SelectOption> getInvestigatorSelectOptions2() {
	    	InvestigatorSelectOptions2 = CFAR_Utils.getContactSearchListPart2(wholeInvestigatorSelectOptions);
	        return InvestigatorSelectOptions2;
	    }
	    
	    public List<SelectOption> getInvestigatorSelectOptions3() {
	    	InvestigatorSelectOptions3 = CFAR_Utils.getContactSearchListPart3(wholeInvestigatorSelectOptions);
	        return InvestigatorSelectOptions3;
	    }
	    
	    public List<SelectOption> getInvestigatorSelectOptions4() {
	    	InvestigatorSelectOptions4 = CFAR_Utils.getContactSearchListPart4(wholeInvestigatorSelectOptions);
	    	return InvestigatorSelectOptions4;
	    }	
        
        public virtual SelectOption[] getInvestigatorSelectOptions(){
            SelectOption[] selectOptions = new SelectOption[]{};
            selectOptions.add(new SelectOption('','--None--'));
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            if(this.innerObject != null && this.innerObject.get('frm_Investigator_ref_gne__c') != null) {
            	selectOptions.add(new SelectOption(String.valueOf(this.innerObject.get('Investigator_ref_gne__c')),String.valueOf(this.innerObject.get('frm_Investigator_ref_gne__c'))));
				String[] notInIds = new String[] {String.valueOf(this.innerObject.get('Investigator_ref_gne__c'))};
				searchParms.andNOTInParameters.put('Id', notInIds);        
            } 
            searchParms.andEqualsParameters.put('Active_gne__c','true');    
            searchParms.sortExpression = 'Search_Name__c'; 
            searchParms.sortDirection = 'asc';          
            searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c', CFAR_Utils.getAvailableRolesForInvestigator());
            selectOptions.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;             
            return selectOptions;           
        }
        
        private transient List<SelectOption> MSLSelectOptions1;
		private transient List<SelectOption> MSLSelectOptions2;
		private transient List<SelectOption> MSLSelectOptions3;
		private transient List<SelectOption> MSLSelectOptions4;
			
		protected List<SelectOption> wholeMSLSelectOptions;
		public virtual void initWholeMSLSelectOptions() {
			wholeMSLSelectOptions = getMSLSelectOptions();
		}
		
		public List<SelectOption> getMSLSelectOptions1() {
	    	MSLSelectOptions1 = CFAR_Utils.getContactSearchListPart1(wholeMSLSelectOptions);
	        return MSLSelectOptions1;
    	}
    
	    public List<SelectOption> getMSLSelectOptions2() {
	    	MSLSelectOptions2 = CFAR_Utils.getContactSearchListPart2(wholeMSLSelectOptions);
	        return MSLSelectOptions2;
	    }
	    
	    public List<SelectOption> getMSLSelectOptions3() {
	    	MSLSelectOptions3 = CFAR_Utils.getContactSearchListPart3(wholeMSLSelectOptions);
	        return MSLSelectOptions3;
	    }
	    
	    public List<SelectOption> getMSLSelectOptions4() {
	    	MSLSelectOptions4 = CFAR_Utils.getContactSearchListPart4(wholeMSLSelectOptions);
	    	return MSLSelectOptions4;
	    }
        
        
        public virtual SelectOption[] getMSLSelectOptions(){
            SelectOption[] selectOptions = new SelectOption[]{};
            selectOptions.add(new SelectOption('','--None--'));
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            if(this.innerObject != null && this.innerObject.get('frm_MSL_ref_gne__c') != null) {
            	selectOptions.add(new SelectOption(String.valueOf(this.innerObject.get('MSL_ref_gne__c')),String.valueOf(this.innerObject.get('frm_MSL_ref_gne__c'))));
				String[] notInIds = new String[] {String.valueOf(this.innerObject.get('MSL_ref_gne__c'))};
				searchParms.andNOTInParameters.put('Id', notInIds);         
            } 
            searchParms.andEqualsParameters.put('Active_gne__c','true'); 
            searchParms.sortExpression = 'Search_Name__c'; 
            searchParms.sortDirection = 'asc';  
            searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c', CFAR_Utils.getAvailableRolesForMSL());
            selectOptions.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;             
            return selectOptions;           
        }                
    
        public virtual SelectOption[] getProductSelectOptions(){
            SelectOption[] selectOptions = new SelectOption[]{};
            selectOptions.add(new SelectOption('','--None--'));
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            searchParms.sortExpression = 'Name'; 
            searchParms.sortDirection = 'asc';            

            for (CFAR_Product_gne__c product : CFAR_DAO.getProductsForSelectOptions(searchParms)) {
                if (product.Active_gne__c == true || (trialBeforeUpdate != null && product.Id == trialBeforeUpdate.Product_ref_gne__c)) {
                    selectOptions.add(new SelectOption(product.Id, product.Name));
                }
            }                     
            return selectOptions;             
        }   
        
        private List<SelectOption> getTrialSelectOptions() {
        	List<SelectOption> selectOptions = new List<SelectOption>{new SelectOption('','--None--')};
        	CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        	parameters.sortExpression = 'LastModifiedDate'; 
        	parameters.sortDirection = 'desc';
        	selectOptions.addAll(CFAR_Utils.getTrialSelectOptions(parameters));
        	return selectOptions;
        }
        
        private transient List<SelectOption> trialSelectOptions1;
		private transient List<SelectOption> trialSelectOptions2;
		private transient List<SelectOption> trialSelectOptions3;
		private transient List<SelectOption> trialSelectOptions4;
			
		private List<SelectOption> wholeTrialSelectOptions;
		
		public void initWholeTrialSelectOptions() {
			wholeTrialSelectOptions = getTrialSelectOptions();
			System.debug('Slawek DBG wholeTrialSelectOptions: ' + wholeTrialSelectOptions.size());
		}
		
		public List<SelectOption> getTrialSelectOptions1() {
	    	trialSelectOptions1 = CFAR_Utils.getObjectSearchListPart1(wholeTrialSelectOptions);
	        System.debug('Slawek DBG trialSelectOptions1: ' + trialSelectOptions1.size());
	        return trialSelectOptions1;
    	}
    
	    public List<SelectOption> getTrialSelectOptions2() {
	    	trialSelectOptions2 = CFAR_Utils.getObjectSearchListPart2(wholeTrialSelectOptions);
	        System.debug('Slawek DBG trialSelectOptions2: ' + trialSelectOptions2.size());
	        return trialSelectOptions2;
    	}
    	
    	public List<SelectOption> getTrialSelectOptions3() {
	    	trialSelectOptions3 = CFAR_Utils.getObjectSearchListPart3(wholeTrialSelectOptions);
	        System.debug('Slawek DBG trialSelectOptions3: ' + trialSelectOptions3.size());
	        return trialSelectOptions3;
    	}
    	
    	public List<SelectOption> getTrialSelectOptions4() {
	    	trialSelectOptions4 = CFAR_Utils.getObjectSearchListPart4(wholeTrialSelectOptions);
	        System.debug('Slawek DBG trialSelectOptions4: ' + trialSelectOptions4.size());
	        return trialSelectOptions4;
    	}
        
        public SelectOption[] getTrialTypeSelectOptions() {
            SelectOption[] selectOptions = new SelectOption[]{};
            selectOptions.add(new SelectOption('','--None--'));
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            searchParms.sortExpression = 'Name'; 
            searchParms.sortDirection = 'asc'; 

            for (CFAR_Trial_Type_gne__c trType : CFAR_DAO.getTrialTypes(searchParms)) {
                if (trType.Active_gne__c == true || (trialBeforeUpdate != null && trType.Id == trialBeforeUpdate.Trial_Type_ref_gne__c)) {
                    selectOptions.add(new SelectOption(trType.Id, trType.Name));
                }
            }                            
            return selectOptions;           
        }  
        
        public SelectOption[] getTrialStatusSelectOptions() {
            SelectOption[] selectOptions = new SelectOption[]{};
            
            selectOptions.add(new SelectOption('','--None--'));
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            
            if(!CFAR_Utils.isCurrentUserAdmin()) {
                List<String> statusesStr = new List<String>{Label.CFAR_GSTARS_TRIAL_STATUS_REOPENED, Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX};
                List<CFAR_Trial_Status_gne__c> statuses = [select Id, Name from CFAR_Trial_Status_gne__c where Name in :statusesStr];
                if(!statuses.isEmpty()) {
                    List<String> notInIds = new List<String>();
                    if(searchParms.andNOTInParameters.containsKey('Id')) {
                            notInIds = searchParms.andNOTInParameters.get('Id');
                    }
                    for(CFAR_Trial_Status_gne__c t : statuses) {
                        notInIds.add(t.Id);
                    }
                    searchParms.andNOTInParameters.put('Id', notInIds);   
                }
            }
            searchParms.sortExpression = 'Name'; 
            searchParms.sortDirection = 'asc'; 
			// status sorting
			List<CFAR_Trial_Status_gne__c> sortedTrialStatuses = new List<CFAR_Trial_Status_gne__c>();
	        List<String> statusStringList = new List<String>();
	        statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_PROPOSAL_APPROVED);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_PROTOCOL_APPROVED);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_ENROLLMENT);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_FOLLOWUP);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_PUBLICATION);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_CLOSURE_PENDING);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_HOLD);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_REOPENED);
            statusStringList.add(Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX);        
        	
        	Set<String> statusStrigSet = new Set<String>();
        	statusStrigSet.addAll(statusStringList);
        	
        	List<CFAR_Trial_Status_gne__c> statusesSObjList = CFAR_DAO.getTrialStatuses(searchParms);
        	for(String sStatus: statusStringList) {
	            for (CFAR_Trial_Status_gne__c trSta : statusesSObjList) {
	                if (trSta.Active_gne__c == true || (trialBeforeUpdate != null && trSta.Id == trialBeforeUpdate.Trial_Status_ref_gne__c)) {
	                	if(trSta.Name == sStatus){
	                		selectOptions.add(new SelectOption(trSta.Id, trSta.Name));	
	                	}
	                }
	            }
            }
            
            for(CFAR_Trial_Status_gne__c tStat : statusesSObjList) {
            	if(!statusStrigSet.contains(tStat.Name) && (tStat.Active_gne__c == true || (trialBeforeUpdate != null && tStat.Id == trialBeforeUpdate.Trial_Status_ref_gne__c))) {            		
            		
            		selectOptions.add(new SelectOption(tStat.Id, tStat.Name));
            	}
            }
            
            return selectOptions;           
        }

        public List<SelectOption> getSRTTeamSelectOptions() {
            List<SelectOption> SRTTeams = new List<SelectOption>();
            for (CFAR_Picklist_Value_gne__c picklistValue : CFAR_DAO.getSRTTeams()) {
                if (picklistValue.Active_gne__c == true) {
                    SRTTeams.add(new SelectOption(picklistValue.Id, picklistValue.Name));
                }
            }
            return SRTTeams;
        }

        public List<SelectOption> getImpactSelectOptions() {
            List<SelectOption> Impact = new List<SelectOption>();
            for (CFAR_Picklist_Value_gne__c picklistValue : CFAR_DAO.getImpacts()) {
                Impact.add(new SelectOption(picklistValue.Id, picklistValue.Name));
            }
            return Impact;
        }

        public virtual SelectOption[] getTherapeuticAreasSelectOptions() {
            SelectOption[] selectOptions = new SelectOption[]{};
            selectOptions.add(new SelectOption('','--None--'));
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();                                 
            searchParms.sortExpression = 'Name'; 
            searchParms.sortDirection = 'asc';

            for (CFAR_Therapeutic_Area_gne__c ta : CFAR_DAO.getTherapeuticAreas(searchParms)) {
                if (ta.Active_gne__c == true || (trialBeforeUpdate != null && ta.Id == trialBeforeUpdate.Therapeutic_Area_ref_gne__c)) {
                    selectOptions.add(new SelectOption(ta.Id, ta.Name));
                }
            }             
            return selectOptions;           
        }
        
        public SelectOption[] getDollarAndDrugSelectOptions() {
            SelectOption[] selectOptions = new SelectOption[]{};
            selectOptions.add(new SelectOption('','--None--'));
			CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            searchParms.sortExpression = 'Name'; 
            searchParms.sortDirection = 'asc'; 

            for (CFAR_Dollar_and_Drug_gne__c drg : CFAR_DAO.getDollarAndDrug(searchParms)) {
                if (drg.Active_gne__c == true || (trialBeforeUpdate != null && drg.Id == trialBeforeUpdate.Dollar_and_Drug_ref_gne__c)) {
                    selectOptions.add(new SelectOption(drg.Id, drg.Name));
                }
            }                 
            return selectOptions;           
        }                                                                
        
        
        public set<Decimal> getFrozenYearsSet(){
		    String frozenYearsStr = (String)this.innerObject.get('Frozen_Accruals_JSON_gne__c');
		    if (String.isBlank(frozenYearsStr))
		        return new set<Decimal>();
		    else 
		    	return (set<Decimal>)JSON.deserialize(frozenYearsStr, set<Decimal>.class);
        }
        
        
        public void addFrozenDate(Decimal year){
        	set<Decimal> frozenYearsSet = getFrozenYearsSet(); 
		    frozenYearsSet.add(year); //Decimal.valueOf(year)
		    innerObject.put('Frozen_Accruals_JSON_gne__c',JSON.serialize(frozenYearsSet) ); 
        }
        
        public void removeFrozenDate(Decimal year){
        	set<Decimal> frozenYearsSet = getFrozenYearsSet(); 
		    frozenYearsSet.remove(year); //Decimal.valueOf(year)
		    innerObject.put('Frozen_Accruals_JSON_gne__c',JSON.serialize(frozenYearsSet) ); 
        }
        
        public String getTrialName(){
    		String newWrapperTrialName = ''; 
    		if(this.innerObject != null && this.innerObject.get('name')!= null  )
    			newWrapperTrialName = (String)this.innerObject.get('name'); 
    		return newWrapperTrialName; 
        }

    public List<SelectOption> availablePartnerships {
        get{
            Boolean isNA = false;
            Set<String> selectedPartnershipsSet = new Set<String>();
            if (selectedPartnerships != null && !selectedPartnerships.isEmpty()) {
                for (String agent : selectedPartnerships) {
                    if(agent!=null)
                        selectedPartnershipsSet.add(agent);
                }
                if(selectedPartnershipsSet.contains('N/A')){
                    isNA = true;
                }
            }
            availablePartnerships = new List<SelectOption>();
                if(!isNA) {
                    availablePartnerships.add(new SelectOption('N/A', 'N/A'));
                    for (CFAR_Partnership_gne__c partnership : [select Id, Name, Active_gne__c from CFAR_Partnership_gne__c order by Name]) {
                        if (partnership.Active_gne__c == true ) {
                            availablePartnerships.add(new SelectOption(partnership.Id, partnership.Name));
                        }
                        if(partnership.Active_gne__c == false && selectedPartnershipsSet.contains(partnership.Id)){
                    availablePartnerships.add(new SelectOption(partnership.Id, partnership.Name));
                }
            }
                } else availablePartnerships.add(new SelectOption('N/A', 'N/A'));

            return availablePartnerships;
        }
        set;
    }

    public List<String> selectedPartnerships {
        get; set;
    }

    public String getDisplayedPartnerships(){
        String da = '';

        if(this.innerObject.get('Partnership_Multi_gne__c') == null || String.valueof(this.innerObject.get('Partnership_Multi_gne__c')) == ''){
             da = '';
        } else if(String.valueOf(this.innerObject.get('Partnership_Multi_gne__c')).contains('N/A')){
            da = 'N/A';
        } else {
            String partnershipIds = String.valueOf(this.InnerObject.get('Partnership_Multi_gne__c'));
            List<String> ids = new List<String>();
            ids = partnershipIds.split(';');
            List<CFAR_Partnership_gne__c> selectedPartnerships = [select Id, Name from CFAR_Partnership_gne__c where ID IN :ids order by Name];
            if (!selectedPartnerships.isEmpty()) {
                da = '';
                for (CFAR_Partnership_gne__c ps : selectedPartnerships) {
                    da += (ps.Name + ', ');
                }
                if (!String.isBlank(da)) {
                    da = da.removeEnd(', ');
                }
            }
        }

        return da;
    }

        public String getDisplayedImpacts() {
            CFAR_Trial_Picklist_gne__c[] trialPicklist = [SELECT Id, Name, CFAR_PicklistValue_ref_gne__r.Name FROM CFAR_Trial_Picklist_gne__c WHERE CFAR_Trial_ref_gne__c = :this.innerObject.Id AND CFAR_PicklistValue_ref_gne__r.RecordType.Name = 'Impact'];
            if (!trialPicklist.isEmpty()) {
                String displayedImpacts = '';
                for (CFAR_Trial_Picklist_gne__c ps : trialPicklist) {
                    displayedImpacts += (ps.CFAR_PicklistValue_ref_gne__r.Name + ', ');
                }
                if (!String.isBlank(displayedImpacts)) {
                    displayedImpacts = displayedImpacts.removeEnd(', ');
                }
                return displayedImpacts;
            } else return '';
        }

        public String getDisplayedOtherGNEAgents(){
        	String da = null;
        	List<CFAR_Trial_Other_GNE_Agent_gne__c> selectedOGA = [select Id, frm_Other_GNE_Agent_Generic_gne__c, frm_Other_GNE_Agent_gne__c from CFAR_Trial_Other_GNE_Agent_gne__c where CFAR_Trial_ref_gne__c = :this.innerObject.Id order by frm_Other_GNE_Agent_gne__c];
        	
            if (this.innerObject.get('Other_GNE_Agents_Multi_gne__c') != null && String.valueof(this.innerObject.get('Other_GNE_Agents_Multi_gne__c')) == 'N/A'){
                da = 'N/A';
            }
            else if (!selectedOGA.isEmpty()) {
        		da = '';
        		for (CFAR_Trial_Other_GNE_Agent_gne__c OGA : selectedOGA) {
        			da += (OGA.frm_Other_GNE_Agent_Generic_gne__c + ', ');
        		}
        		if(!String.isBlank(da)) {
    				da = da.removeEnd(', ');
    			} else if (this.innerObject.get('Non_Interventional_gne__c') != null && String.valueOf(this.innerObject.get('Non_Interventional_gne__c')).containsIgnoreCase('no')) {
                    da = 'N/A';
                }
            } else if (this.innerObject.get('Non_Interventional_gne__c') != null && String.valueOf(this.innerObject.get('Non_Interventional_gne__c')).containsIgnoreCase('no')) {
                da = 'N/A';
            }
        	return da;
        }

        public String getDisplayedIMPShipped(){
        	String displayedIMP = null;
        	List<CFAR_Trial_IMP_Shipped__c> selectedIMP = [select Id, frm_IMP_Shipped_Generic__c, frm_IMP_Shipped__c from CFAR_Trial_IMP_Shipped__c where CFAR_Trial_ref_gne__c = :this.innerObject.Id order by frm_IMP_Shipped__c];
        	if (!selectedIMP.isEmpty()) {
        		displayedIMP = '';
        		for (CFAR_Trial_IMP_Shipped__c IMP : selectedIMP) {
        			displayedIMP += (IMP.frm_IMP_Shipped_Generic__c + ', ');
        		}
        		if(!String.isBlank(displayedIMP)) {
    				displayedIMP = displayedIMP.removeEnd(', ');
    			}
            } 
        	return displayedIMP;
        }

        public List<SelectOption> tieringOptions {
            get {
                List<SelectOption> tieringSelectOptions = new List<SelectOption>();
                for (Schema.PicklistEntry entry : CFAR_Trial_gne__c.Tiering_gne__c.getDescribe().getPicklistValues()) {
                    tieringSelectOptions.add(new SelectOption(entry.label, entry.value));
                }
                return tieringSelectOptions;
            }
            set;
        }

        public List<SelectOption> iresOptions {
            get {
                List<SelectOption> iresSelectOptions = new List<SelectOption>();
                for (Schema.PicklistEntry entry : CFAR_Trial_gne__c.IRES__c.getDescribe().getPicklistValues()) {
                    iresSelectOptions.add(new SelectOption(entry.label, entry.value));
                }
                return iresSelectOptions;
            }
            set;
        }
        

    	public List<SelectOption> availableOtherGNEAgents {
    													get{
                                                            Boolean isNA = false;
    														Set<Id> selectedOtherGNEAgentsSet = new Set<Id>();
        													if (selectedOtherGNEAgents != null && !selectedOtherGNEAgents.isEmpty()) {
            													for (String agent : selectedOtherGNEAgents) {
                                                                    if(agent!=null && agent != 'N/A')
            														  selectedOtherGNEAgentsSet.add(Id.valueOf(agent));
            													}
                                                                if(selectedOtherGNEAgents.contains('N/A')){
                                                                    isNA = true;
                                                                }
        													}
        													availableOtherGNEAgents = new List<SelectOption>();
                                                            if (!isNA){
                                                                availableOtherGNEAgents.add(new SelectOption('N/A', 'N/A'));
                                                                for (CFAR_Product_gne__c agent : [select Id, Name, Generic_Name_gne__c, Other_GNE_Agent_Active_gne__c from CFAR_Product_gne__c order by Name]) {
                                                                    if (agent.Other_GNE_Agent_Active_gne__c == true || (agent.Other_GNE_Agent_Active_gne__c == false && selectedOtherGNEAgentsSet.contains(agent.Id))
                                                                        || 
                                                                        (trialBeforeUpdate != null && trialBeforeUpdateOGAs != null && trialBeforeUpdateOGAs.contains(agent.Id))) {
                                                                        availableOtherGNEAgents.add(new SelectOption(agent.Id, agent.Generic_Name_gne__c));
                                                                    }
                                                                }
                                                            } else {
                                                                availableOtherGNEAgents.add(new SelectOption('N/A', 'N/A'));
                                                            }
        													return availableOtherGNEAgents;
    												   	} 
    												   	set;
    												  }
    	public List<String> selectedOtherGNEAgents {
                                                    get; set;
                                               }
        public List<SelectOption> availableIMPShipped {
            get{
                Set<Id> selectedIMPShippedSet = new Set<Id>();
                if (selectedIMPShipped != null && !selectedIMPShipped.isEmpty()) {
                    for (String imp : selectedIMPShipped) {
                        if(imp!=null)
                        selectedIMPShippedSet.add(Id.valueOf(imp));
                    }
                }
                availableIMPShipped = new List<SelectOption>();
                for (CFAR_Product_gne__c imp : [select Id, Name, Generic_Name_gne__c, Other_GNE_Agent_Active_gne__c from CFAR_Product_gne__c order by Name]) {
                    if (imp.Other_GNE_Agent_Active_gne__c == true || (imp.Other_GNE_Agent_Active_gne__c == false && selectedIMPShippedSet.contains(imp.Id))
                        || 
                           (trialBeforeUpdate != null && trialBeforeUpdateIMPShipped != null && trialBeforeUpdateIMPShipped.contains(imp.Id))) {
                            availableIMPShipped.add(new SelectOption(imp.Id, imp.Generic_Name_gne__c));
                    }
                }
                return availableIMPShipped;
               } 
               set;
        }
        
        public List<String> selectedIMPShipped {
            get; set;
        }                                                   

        public List<String> selectedImpact {get; set;}
    	public List<SelectOption> availableDiseaseStatus {
    													get{
    														
    														boolean isNa = false;
    														//Id NaValue = null;
    														
    														Set<String> selectedDiseaseStatusSet = new Set<String>();
        													if (selectedDiseaseStatus != null && !selectedDiseaseStatus.isEmpty()) {
            													selectedDiseaseStatusSet.addAll(selectedDiseaseStatus);
            													if (selectedDiseaseStatusSet.contains('NA')) {
            														isNa = true;
            													}
        													}
        													system.debug('isNa ' + isNa );
        													system.debug(selectedDiseaseStatusSet);
        													
        													availableDiseaseStatus = new List<SelectOption>();
        													List<SelectOption> availableDiseaseStatusAll = CFAR_Utils.getPicklistValues(new CFAR_Trial_gne__c(), 'Disease_Status_Picklist_gne__c');
        													system.debug('ade ' + availableDiseaseStatusAll);
        													if (selectedDiseaseStatusSet.isEmpty()) {
        														availableDiseaseStatus.addAll(availableDiseaseStatusAll);
        													}
        													else {
        														for (SelectOption so : availableDiseaseStatusAll) {
        																//exists some selected 
        																if(!isNa) {
        																	//selected is not NA
        																	if(!'NA'.equals(so.getLabel())) {
        																		availableDiseaseStatus.add(so);
        																	}	
        																} else {
        																	if('NA'.equals(so.getLabel())) {
        																		availableDiseaseStatus.add(so);
        																	}
        																}
        														}
        													}
        													
        													return availableDiseaseStatus;
    												   	} 
    												   	set;
    												  }
    	public List<String> selectedDiseaseStatus {get; set;}
    	public Boolean selectedDiseaseStatusParam1 {get; set;}

		public List<SelectOption> availableLineOfTherapy {
    													get{
    														
    														boolean isNa = false;
    														
    														Set<String> selectedLineOfTherapySet = new Set<String>();
        													if (selectedLineOfTherapy != null && !selectedLineOfTherapy.isEmpty()) {
            													selectedLineOfTherapySet.addAll(selectedLineOfTherapy);
            													if (selectedLineOfTherapySet.contains('N/A')) {
            														isNa = true;
            													}
        													}
        													system.debug('isNa ' + isNa );
        													system.debug(selectedLineOfTherapySet);
        													
        													availableLineOfTherapy = new List<SelectOption>();
        													List<SelectOption> availableLineOfTherapyAll = CFAR_Utils.getPicklistValues(new CFAR_Trial_gne__c(), 'Line_of_Therapy_gne__c');
        													system.debug('al ' + availableLineOfTherapyAll);
        													if(selectedLineOfTherapySet.isEmpty()) {
        														availableLineOfTherapy.addAll(availableLineOfTherapyAll);
        													}
        													else {
        														for (SelectOption so : availableLineOfTherapyAll) {
        																//exists some selected 
        																if(!isNa) {
        																	//selected is not NA
        																	if(!'N/A'.equals(so.getLabel())) {
        																		availableLineOfTherapy.add(so);
        																	}	
        																} else {
        																	if('N/A'.equals(so.getLabel())) {
        																		availableLineOfTherapy.add(so);
        																	}
        																}
        														}
        													}
        													
        													return availableLineOfTherapy;
    												   	} 
    												   	set;
    												  }
    	public List<String> selectedLineOfTherapy {get; set;}

		public List<SelectOption> availablePatientSubPopulation {
    													get{
    														
    														boolean isNa = false;
    														
    														Set<String> selectedPatientSubPopulationSet = new Set<String>();
        													if (selectedPatientSubPopulation != null && !selectedPatientSubPopulation.isEmpty()) {
            													selectedPatientSubPopulationSet.addAll(selectedPatientSubPopulation);
            													if (selectedPatientSubPopulationSet.contains('N/A')) {
            														isNa = true;
            													}
        													}
        													system.debug('isNa ' + isNa );
        													system.debug(selectedPatientSubPopulationSet);
        													
        													availablePatientSubPopulation = new List<SelectOption>();
        													List<SelectOption> availablePatientSubPopulationAll = CFAR_Utils.getPicklistValues(new CFAR_Trial_gne__c(), 'Sub_Patient_Population_gne__c');
        													system.debug('al ' + availablePatientSubPopulationAll);
        													if(selectedPatientSubPopulationSet.isEmpty()) {
        														availablePatientSubPopulation.addAll(availablePatientSubPopulationAll);
        													}
        													else {
        														for (SelectOption so : availablePatientSubPopulationAll) {
        																//exists some selected 
        																if(!isNa) {
        																	//selected is not NA
        																	if(!'N/A'.equals(so.getLabel())) {
        																		availablePatientSubPopulation.add(so);
        																	}	
        																} else {
        																	if('N/A'.equals(so.getLabel())) {
        																		availablePatientSubPopulation.add(so);
        																	}
        																}
        														}
        													}
        													return availablePatientSubPopulation;
    												   	} 
    												   	set;
    												  }
    	public List<String> selectedPatientSubPopulation {get; set;}

		public List<SelectOption> availableStudyPhase {
    													get{
    														
    														boolean isNa = false;
    														
    														Set<String> selectedStudyPhaseSet = new Set<String>();
        													if (selectedStudyPhase != null && !selectedStudyPhase.isEmpty()) {
            													selectedStudyPhaseSet.addAll(selectedStudyPhase);
            													if (selectedStudyPhaseSet.contains('N/A')) {
            														isNa = true;
            													}
        													}
        													system.debug('isNa ' + isNa );
        													system.debug(selectedStudyPhaseSet);
        													
        													availableStudyPhase = new List<SelectOption>();
        													List<SelectOption> availableStudyPhaseAll = CFAR_Utils.getPicklistValues(new CFAR_Trial_gne__c(), 'Study_Phase_Multi_gne__c');
        													system.debug('al ' + availableStudyPhaseAll);
        													if(selectedStudyPhaseSet.isEmpty()) {
        														availableStudyPhase.addAll(availableStudyPhaseAll);
        													}
        													else {
        														for (SelectOption so : availableStudyPhaseAll) {
        																//exists some selected 
        																if(!isNa) {
        																	//selected is not NA
        																	if(!'N/A'.equals(so.getLabel())) {
        																		availableStudyPhase.add(so);
        																	}	
        																} else {
        																	if('N/A'.equals(so.getLabel())) {
        																		availableStudyPhase.add(so);
        																	}
        																}
        														}
        													}
        													return availableStudyPhase;
    												   	} 
    												   	set;
    												  }
    	public List<String> selectedStudyPhase {get; set;}

        public String getDisplayedGeneralIndications() {
        	String di = null;
        	List<CFAR_General_Indication_for_Trial_gne__c> selectedGI = [select Id, CFAR_General_Indication_ref_gne__r.Name from CFAR_General_Indication_for_Trial_gne__c where CFAR_Trial_ref_gne__c = :this.innerObject.Id and CFAR_General_Indication_ref_gne__c != :String.valueOf(this.innerObject.get('CFAR_General_Indication_ref_gne__c')) order by CFAR_General_Indication_ref_gne__r.Name];
        	if (!selectedGI.isEmpty()) {
        		di = '';
        		for (CFAR_General_Indication_for_Trial_gne__c gi : selectedGI) {
        			di += (gi.CFAR_General_Indication_ref_gne__r.Name + ', ');
        		}
        		if(!String.isBlank(di)) {
    				di = di.removeEnd(', ');
    			}
        	}
        	return di;
    	}
        
   		public List<String> selectedGeneralIndications {get; set;}
   		
        public List<SelectOption> availableGeneralIndications {
        get{
            Set<Id> selectedGeneralIndicationsSet = new Set<Id>();
            if (selectedGeneralIndications != null && !selectedGeneralIndications.isEmpty()) {
                for (String gi : selectedGeneralIndications) {
                    selectedGeneralIndicationsSet.add(Id.valueOf(gi));
                }
            }
            
            availableGeneralIndications = new List<SelectOption>();
            String query = 'select Id, Name, Active_gne__c from CFAR_General_Indication_gne__c '; // order by Name '
            if(String.valueOf(this.innerObject.get('Therapeutic_Area_ref_gne__c')) == CFAR_Utils.BIOONCOLOGY_TA_ID) {
                query += ' where Name in( ';
                for(String s : CFAR_DAO.getGeneralIndicationsByTherapeuticArea ('BioOncology')) {
                    query += '\'' + s + '\',';
                }
                query = query.removeEnd(',');
                query += ') ';
            }
            query += 'order by Name ';
            system.debug(query);
                 
            for (CFAR_General_Indication_gne__c indication : Database.query(query)) {
                if (indication.Active_gne__c == true || (indication.Active_gne__c == false && selectedGeneralIndicationsSet.contains(indication.Id))
                			|| (trialBeforeUpdate != null && trialBeforeUpdateGIs != null && trialBeforeUpdateGIs.contains(indication.Id))) {
                    availableGeneralIndications.add(new SelectOption(indication.Id, indication.Name));
                }
            }
            return availableGeneralIndications;
            
        } 
        set;
    }
    
    public String getDisplayedSpecificIndications() {
        String di = null;
        List<CFAR_Specific_Indication_for_Trial_gne__c> selectedSI = [select Id, CFAR_Specific_Indication_ref_gne__r.Name from CFAR_Specific_Indication_for_Trial_gne__c where CFAR_Trial_ref_gne__c = :this.innerObject.Id order by CFAR_Specific_Indication_ref_gne__r.Name];
        if (!selectedSI.isEmpty()) {
        	di = '';
        	for (CFAR_Specific_Indication_for_Trial_gne__c si : selectedSI) {
        		di += (si.CFAR_Specific_Indication_ref_gne__r.Name + ', ');
        	}
        	if(!String.isBlank(di)) {
    			di = di.removeEnd(', ');
    		}
        }
        return di;
    }
    
	public List<String> selectedGeneralIndicationsPopUp {get; set;}
	
   	public List<SelectOption> availableGeneralIndicationsPopUp {
        get{
            Set<Id> selectedGeneralIndicationsSet = new Set<Id>();
            if (selectedGeneralIndicationsPopUp != null && !selectedGeneralIndicationsPopUp.isEmpty()) {
                for (String gi : selectedGeneralIndicationsPopUp) {
                    selectedGeneralIndicationsSet.add(Id.valueOf(gi));
                }
            }
            
            availableGeneralIndicationsPopUp = new List<SelectOption>();
            String query = 'select Id, Name, Active_gne__c from CFAR_General_Indication_gne__c '; // order by Name '
            if(String.valueOf(this.innerObject.get('Therapeutic_Area_ref_gne__c')) == CFAR_Utils.BIOONCOLOGY_TA_ID) {
                query += ' where Name in( ';
                for(String s : CFAR_DAO.getGeneralIndicationsByTherapeuticArea ('BioOncology')) {
                    query += '\'' + s + '\',';
                }
                query = query.removeEnd(',');
                query += ') ';
            }
            query += 'order by Name ';
            system.debug(query);
            List<SelectOption> otherGIValues = new List<SelectOption>();
                
            for (CFAR_General_Indication_gne__c indication : Database.query(query)) {
                if (indication.Active_gne__c == true || (indication.Active_gne__c == false && selectedGeneralIndicationsSet.contains(indication.Id))
                			|| (trialBeforeUpdate != null && trialBeforeUpdateGIs != null && trialBeforeUpdateGIs.contains(indication.Id))) {
                    if(!indication.Name.startsWith('Other')) availableGeneralIndicationsPopUp.add(new SelectOption(indication.Id, indication.Name));
                    else otherGIValues.add(new SelectOption(indication.Id, indication.Name));
               	}
            }       
            for(Selectoption so: otherGIValues){
            	availableGeneralIndicationsPopUp.add(so);
            }
            
            return availableGeneralIndicationsPopUp;
            
        } 
        set;
    }
    public List<String> selectedSpecificIndications {get; set;}
    public List<SelectOption> availableSpecificIndications {
        get{
            Set<Id> selectedSpecificIndicationsSet = new Set<Id>();
            if (selectedSpecificIndications != null && !selectedSpecificIndications.isEmpty()) {
                for (String gi : selectedSpecificIndications) {
                    selectedSpecificIndicationsSet.add(Id.valueOf(gi));
                }
            }
            
            availableSpecificIndications = new List<SelectOption>();
            String query = 'select Id, Name, Active_gne__c from CFAR_Specific_Indication_gne__c '; // order by Name '
            system.debug('sgi ' + selectedGeneralIndications );
            Boolean shouldExecuteQuery = true;
            if(String.valueOf(this.innerObject.get('Therapeutic_Area_ref_gne__c')) == CFAR_Utils.BIOONCOLOGY_TA_ID && this.selectedGeneralIndications != null && this.selectedGeneralIndications.size() > 0) {
                shouldExecuteQuery = false;
                query += ' where Name in( ';
                for(String s : CFAR_DAO.getSpecificIndicationsByTherapeuticAreaGeneralIndication('BioOncology', CFAR_DAO.getSelectedGeneralIndicationNames(selectedGeneralIndications))) {
                    s = String.escapeSingleQuotes(s);
                    query += '\'' + s + '\',';
                    shouldExecuteQuery = true;
                }
                query = query.removeEnd(',');
                query += ') ';
            }
            query += 'order by Name ';
            List<SelectOption> otherSIValues = new List<SelectOption>();
            
            system.debug(query);

            if(shouldExecuteQuery) {
	            for (CFAR_Specific_Indication_gne__c indication : Database.query(query)) {
	                if (indication.Active_gne__c == true || (indication.Active_gne__c == false && selectedSpecificIndicationsSet.contains(indication.Id))) {
                    if(!indication.Name.startsWith('Other')) availableSpecificIndications.add(new SelectOption(indication.Id, indication.Name));
                    else otherSIValues.add(new SelectOption(indication.Id, indication.Name));
               	}
	            }
            }
            for(Selectoption so: otherSIValues){
            	availableSpecificIndications.add(so);
            }
            return availableSpecificIndications;
            
        } 
        set;
    }
    
    public List<CFAR_Trial_Type_of_Sample_gne__c> getTrialTypeOfSampleRecords() {
        List<CFAR_Trial_Type_of_Sample_gne__c> samples = CFAR_DAO.getTrialTypeOfSampleRecords(this.innerObject.Id);
        trialTypeOfSampleRecordsMap = new Map<String,CFAR_Trial_Type_of_Sample_gne__c>();
        usedTypeOfSamples = new Set<Id>();
        for (CFAR_Trial_Type_of_Sample_gne__c sample : samples) {
            trialTypeOfSampleRecordsMap.put(sample.Id, sample);
            if (sample.frm_Type_of_Sample_ref_gne__c != 'Other') {
                usedTypeOfSamples.add(sample.Type_of_Sample_ref_gne__c);
            }
        }
        return samples;
    }
    
    public List<SelectOption> getAvailableTypesOfSamples() {
        List<SelectOption> atosList = new List<SelectOption>{new SelectOption('', '--None--')};
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name'; 
        searchParms.sortDirection = 'asc';
        
        CFAR_Trial_Type_of_Sample_gne__c sample;
        if(this.innerObject != null){
            List<CFAR_Trial_Type_of_Sample_gne__c> samples = [SELECT Type_of_Sample_ref_gne__c FROM CFAR_Trial_Type_of_Sample_gne__c WHERE Id = :String.valueOf(newEditTrialTypeOfSample.Id)];
            if(samples.size() > 0) sample = samples.get(0);
        }
        
        for (CFAR_Type_of_Sample_gne__c tos : CFAR_DAO.getTypeOfSample(searchParms)) {
            if ((tos.Active_gne__c == true && !usedTypeOfSamples.contains(tos.Id)) || (sample != null && tos.Id == sample.Type_of_Sample_ref_gne__c)) {
                atosList.add(new SelectOption(tos.Id, tos.Name));
            }
        }
        return atosList;
    }
    
    public void clearDiseaseStatusOther() {
    	if(this.selectedDiseaseStatus.size() > 0) {
    		Set<String> diseaseStatusTempSet = new Set<String>(this.selectedDiseaseStatus);
    		system.debug('LOOL'+diseaseStatusTempSet.contains('Other'));
    		if (!diseaseStatusTempSet.contains('Other')) {
    			this.innerObject.put('Disease_Status_Other_gne__c', null);
    		}
    	} else {
    		this.innerObject.put('Disease_Status_Other_gne__c', null);
    	}
    }
    
    public void clearBiomarkerDescription() {
        this.innerObject.put('Biomarker_Description_gne__c', null);
    }

    public Boolean duplicatedCTMS() {
    	Boolean retVal = false;
    	if (!String.isBlank(String.valueOf(this.innerObject.get('CTMS_gne__c')))) {
    		List<CFAR_Trial_gne__c> trials = [select Id, Name, CTMS_gne__c from CFAR_Trial_gne__c where CTMS_gne__c = :String.valueOf(this.innerObject.get('CTMS_gne__c')) and Id != :this.innerObject.Id order by Name limit 1];
    		if (!trials.isEmpty()) {
    			String message = 'CTMS # ' + String.valueOf(this.innerObject.get('CTMS_gne__c')) + ' already exists in study ' + trials.get(0).Name + '. Please enter a different CTMS number.';
    			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    			retVal = true;
    		}
    	}
    	return retVal;
    }
    
    public Boolean getIsDiseaseStatusOtherRequired() {
    	Boolean retVal = false;
    	if(this.selectedDiseaseStatus != null && !this.selectedDiseaseStatus.isEmpty()) {
    		System.debug('LOOOL:' + this.selectedDiseaseStatus);
    		Set<String> diseaseStatusTempSet = new Set<String>(this.selectedDiseaseStatus);
    		if (diseaseStatusTempSet.contains('Other')) {
    			retVal = true;
    		}
    	}
    	if (!retVal) { 
        	this.innerObject.put('Disease_Status_Other_gne__c', null);
    	}
    	return retVal;
    }

    public Boolean getIsLineOfTherapyOtherRequired() {
    	Boolean retVal = false;
    	if(this.selectedLineOfTherapy != null && !this.selectedLineOfTherapy.isEmpty()) {
    		System.debug('LOOOL:' + this.selectedLineOfTherapy);
    		Set<String> lineOfTherapyStatusTempSet = new Set<String>(this.selectedLineOfTherapy);
    		if (lineOfTherapyStatusTempSet.contains('Other')) {
    			retVal = true;
    		}
    	}
    	if (!retVal) {
    		this.innerObject.put('Line_of_Therapy_Other_gne__c', null);
    	}
    	return retVal;
    }
    public Boolean isInclusiveDescriptionRequired { get { return this.innerObject.get('Inclusive_Research_gne__c') == 'Yes'; } set; }

    public Boolean showInterventionalComment { get { return this.innerObject.get('Non_Interventional_gne__c') == 'No: Other'; } set; }
    
    public Boolean getIsSubPatientOtherRequired() {
    	Boolean retVal = isSubFieldRequired('Other');
    	if (!retVal) {
    		this.innerObject.put('Sub_Patient_Population_Other_Desc_gne__c', null);
    	}
    	return retVal;
    }
    
    public Boolean getIsSubPatientEthnicityRequired() {
    	Boolean retVal = isSubFieldRequired('Ethnicity');
    	if (!retVal) {
    		this.innerObject.put('Ethnicity_Description_gne__c', null);
    	}
    	return retVal;
    }
    
    public Boolean getIsSubPatientComorbidityRequired() {
    	Boolean retVal = isSubFieldRequired('Medical Comorbidity');
    	if (!retVal) {
    		this.innerObject.put('Medical_Comorbidity_Description_gne__c', null);
    	}
    	return retVal;
    }
    
    public Boolean getIsSubPatientRefactoryRequired() {
    	Boolean retVal = isSubFieldRequired('Treatment Refractory');
    	if (!retVal) {
    		this.innerObject.put('Treatment_Refractory_Description_gne__c', null);
    	}
    	return retVal;
    }
    
    public Boolean getIsSubPatientSensitiveRequired() {
    	Boolean retVal = isSubFieldRequired('Treatment Sensitive');
    	if (!retVal) {
    		this.innerObject.put('Treatment_Sensitive_Description_gne__c', null);
    	}
    	return retVal;
    }
    
    private Boolean isSubFieldRequired(String s){
    	Boolean retVal = false;
    	if(this.selectedPatientSubPopulation != null && !this.selectedPatientSubPopulation.isEmpty() && !String.isBlank(s)) {
    		Set<String> selectedPatientSubPopulationTempSet = new Set<String>(this.selectedPatientSubPopulation);
    		if (selectedPatientSubPopulationTempSet.contains(s)) {
    			retVal = true;
    		}
    	}
    	return retVal;
    }
            
    public class CFAR_TrialWrapperException extends Exception {}
}