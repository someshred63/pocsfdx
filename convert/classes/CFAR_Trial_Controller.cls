public virtual with sharing class CFAR_Trial_Controller extends CFAR_TrialBaseController {

    public String selectedTabName {get; 
    	set {
    		if (value != selectedTabName && value == 'gInd') {
                cancelEditGeneralInfo();
            }
            selectedTabName = value;
    	}
    }

    public Boolean trialAdded {get; set;}
    public String infoMessage {get; set;}
    
    public Id mainTrialId {get; set;}
    
    public Boolean productGNEAgentSame {get;set;}
    
    public String generalIndIdx  {get;set;}
    public String specificIndIdx  {get;set;}
    
	public Boolean showNewTOSPopup {get; set;}
    public Boolean disabledIMPShipped{get;set;}

    private String oldProductId {get;set;}
    public String maTypeLinkedToStatus {get;set;}
    public Map<String, String> allTrialStatus {get; set;}

    public static final Map<String, String> trialStatusToMaType {
        get {
            if (trialStatusToMaType == null) {
                trialStatusToMaType = new MAp<String, String>();
                for (String k : CFAR_MilestonesUtils.maTypeToTrialStatus.keySet()) {
                    trialStatusToMaType.put(CFAR_MilestonesUtils.maTypeToTrialStatus.get(k) , k);
                }
            }
            return trialStatusToMaType;
        }
        set;
    }

    public CFAR_Trial_Controller(){
        super();
        componentID = 'componentID == Trial Controller!! '; 
        
        setUpTab();
        if(mainTrialId == null && trialWrapper.innerObject != null && trialWrapper.innerObject.Id != null) {
            mainTrialId = trialWrapper.innerObject.Id;
        }
        
        if(ApexPages.currentPage().getParameters().containsKey('trialadded') && ApexPages.currentPage().getParameters().get('trialadded') != '') {
            infoMessage = String.format(Label.CFAR_TRIAL_ADDED, new String[]{ApexPages.currentPage().getParameters().get('trialadded')});
            trialAdded = true;
        } else {
            trialAdded = false;
        }
        isError = false;
        showNewTOSPopup = false;
        errorMessage = '';
        trialWrapper.generalInfoEditMode = false;
        trialWrapper.initWholeTrialSelectOptions();
        initAllAvailableTrialStatus();
    }

    public Map<String, String> initAllAvailableTrialStatus(){
        allTrialStatus = new Map<String, String>();
        for(CFAR_Trial_Status_gne__c status : [Select Id, Name FROM CFAR_Trial_Status_gne__c]){
            allTrialStatus.put(String.valueOf(status.id), String.valueOf(status.Name));
        }

        return allTrialStatus;
    }
    
    public void refreshMainTrial() {
        if(mainTrialId != null) {
            trial  = CFAR_DAO.getTrial(mainTrialId);
        } else {
            trial = null;
        }
        cancelEditGeneralInfo();
        hideTrialAddedMessage();
        refreshTrialChildObjects();
    }

    public Boolean BOMremovalConfirmation {get; set;}

    public Boolean BOMValuesPresent {
        get {
            CFAR_Trial_gne__c trialRecord = [SELECT Id, Sub_Patient_Population_gne__c, Biomarker_Description_gne__c, Biomarker_Questions_gne__c FROM CFAR_Trial_gne__c WHERE Id = :trialWrapper.innerObject.Id];
            if ((trialRecord.Biomarker_Questions_gne__c != null && trialRecord.Biomarker_Questions_gne__c != '') ||
                    (trialRecord.Sub_Patient_Population_gne__c != null && trialRecord.Sub_Patient_Population_gne__c != '') ||
                    (trialRecord.Biomarker_Description_gne__c != null && trialRecord.Biomarker_Description_gne__c != '')) {
                return true;
            } else return false;
        }
        set;
    }

    public void labSupportChanged() {
        if (String.valueOf(trialWrapper.innerObject.get('Lab_Support_gne__c')) != 'YES' && BOMremovalConfirmation) {
            trialWrapper.innerObject.put('Vendor_gne__c',null);
        } else {
            trialWrapper.innerObject.put('Lab_Support_gne__c', 'YES');
        }
    }

    public void inclusiveResearchChanged() {
        if (String.valueOf(trialWrapper.innerObject.get('Inclusive_Research_gne__c')) == 'Yes') {
            trialWrapper.isInclusiveDescriptionRequired = true;
        } else {
            trialWrapper.isInclusiveDescriptionRequired = false;
            trialWrapper.innerObject.put('Inclusive_Research_Description_gne__c', null);
        }
    }

    public void interventionalPicklistChanged() {
        if (String.valueOf(trialWrapper.innerObject.get('Non_Interventional_gne__c')) == 'No: Other') {
            trialWrapper.showInterventionalComment = true;                   
        } else {
            trialWrapper.showInterventionalComment = false;
            trialWrapper.innerObject.put('Interventional_Picklist_Comment__c', null);
        }
    }
    
    private void setUpTab() {
        Cookie cook = ApexPages.currentPage().getCookies().get('SelectedTabTrialCookie');
        if(cook == null) {
            selectedTabName = 'gInd';
        } else {
            selectedTabName = cook.getValue();
        }
    }
    
    public void editGeneralInfo() {
    	
        editMode = true;
        trialWrapper.generalInfoEditMode = true;
        refreshTrial();
        oldProductId = String.valueOf(trialWrapper.innerObject.get('Product_ref_gne__c'));
        generalIndIdx = String.valueOf(trialWrapper.innerObject.get('CFAR_General_Indication_ref_gne__c'));
        specificIndIdx = String.valueOf(trialWrapper.innerObject.get('CFAR_Specific_Indication_ref_gne__c'));
        trialWrapper.availableOtherGNEAgents = new List<SelectOption>();
        trialWrapper.selectedOtherGNEAgents = new List<String>();
        trialWrapper.availableIMPShipped = new List<SelectOption>();
        trialWrapper.selectedIMPShipped = new List<String>();
        trialWrapper.selectedImpact = new List<String>();
        trialWrapper.selectedPartnerships = new List<String>();
        trialWrapper.selectedGeneralIndications = new List<String>();
        trialWrapper.selectedGeneralIndicationsPopUp = new List<String>();
        trialWrapper.selectedSpecificIndications = new List<String>();
        trialWrapper.availableDiseaseStatus = new List<SelectOption>();
        
        if(trialWrapper.innerObject.get('Dollar_and_Drug_ref_gne__c') != null){         
            String dollarDrugName = getGNESupportName();
            if(dollarDrugName == '$ Only'){
                trialWrapper.innerObject.put('IMP_Shipped_Multi_gne__c', null);
                trialWrapper.selectedIMPShipped = new List<String>();
                disabledIMPShipped = true;
            }else{
                disabledIMPShipped = false;
            }
        } else {
            disabledIMPShipped = false;
        }

        if(trialWrapper.innerObject.get('Disease_Status_Picklist_gne__c') != null) {
        	String status = String.valueOf(trialWrapper.innerObject.get('Disease_Status_Picklist_gne__c'));
        	trialWrapper.selectedDiseaseStatus = status.split(';');
        } else {
        	trialWrapper.selectedDiseaseStatus = new List<String>();
        }
        trialWrapper.availableLineOfTherapy = new List<SelectOption>();
        if(trialWrapper.innerObject.get('Line_Of_Therapy_gne__c') != null) {
        	String line = String.valueOf(trialWrapper.innerObject.get('Line_Of_Therapy_gne__c'));
        	trialWrapper.selectedLineOfTherapy = line.split(';');
        } else {
        	trialWrapper.selectedLineOfTherapy = new List<String>();
        }
        trialWrapper.availablePatientSubPopulation = new List<SelectOption>();
        if(trialWrapper.innerObject.get('Sub_Patient_Population_gne__c') != null) {
        	String line = String.valueOf(trialWrapper.innerObject.get('Sub_Patient_Population_gne__c'));
        	trialWrapper.selectedPatientSubPopulation = line.split(';');
        } else {
        	trialWrapper.selectedPatientSubPopulation = new List<String>();
        }
        trialWrapper.availableStudyPhase = new List<SelectOption>();
        if(trialWrapper.innerObject.get('Study_Phase_Multi_gne__c') != null) {
        	String phase = String.valueOf(trialWrapper.innerObject.get('Study_Phase_Multi_gne__c'));
        	trialWrapper.selectedStudyPhase = phase.split(';');
        } else {
        	trialWrapper.selectedStudyPhase = new List<String>();
        }
        setSelectedOtherGNEAgentsList();
        setSelectedIMPShippedList();
        setSelectedPartnershipsList();
        setSelectedGILists();
        setSelectedSIList();
        setSelectedImpactsList();
        
        system.debug('selecteed '+trialWrapper.selectedGeneralIndications);

        List<CFAR_Trial_gne__c> trials = [SELECT Trial_Type_ref_gne__c, Trial_Status_ref_gne__c, IIS_Portal_RO_Number_gne__c, Trial_Status_ref_gne__r.Name, Therapeutic_Area_ref_gne__c,
                                                Dollar_and_Drug_ref_gne__c, Product_ref_gne__c, CTMS_gne__c, Subject_Type__c,
                                                (select Other_GNE_Agent_ref_gne__c from gSTARS_Trial_Other_GNE_Agents__r),
                                                (select IMP_Shipped_ref__c from gSTARS_Trial_IMP_Shipped__r),
                                                (select CFAR_General_Indication_ref_gne__c from gstars_General_Indications_for_Trial__r)
                                                FROM CFAR_Trial_gne__c WHERE Id = :String.valueOf(trialWrapper.innerObject.get('Id'))];
        if(trials.size() > 0) trialWrapper.trialBeforeUpdate = trials.get(0);
        else trialWrapper.trialBeforeUpdate = null;
        if (trialWrapper.trialBeforeUpdate != null && !trialWrapper.trialBeforeUpdate.gSTARS_Trial_Other_GNE_Agents__r.isEmpty()) {
        	trialWrapper.trialBeforeUpdateOGAs = new Set<Id>();
        	for (CFAR_Trial_Other_GNE_Agent_gne__c OGA : trialWrapper.trialBeforeUpdate.gSTARS_Trial_Other_GNE_Agents__r) {
        		trialWrapper.trialBeforeUpdateOGAs.add(OGA.Other_GNE_Agent_ref_gne__c);
        	}
        }
        else {
        	trialWrapper.trialBeforeUpdateOGAs = null;
        }
        if (trialWrapper.trialBeforeUpdate != null && !trialWrapper.trialBeforeUpdate.gSTARS_Trial_IMP_Shipped__r.isEmpty()) {
        	trialWrapper.trialBeforeUpdateIMPShipped = new Set<Id>();
        	for (CFAR_Trial_IMP_Shipped__c IMP : trialWrapper.trialBeforeUpdate.gSTARS_Trial_IMP_Shipped__r) {
        		trialWrapper.trialBeforeUpdateIMPShipped.add(IMP.IMP_Shipped_ref__c);
        	}
        }
        else {
        	trialWrapper.trialBeforeUpdateIMPShipped = null;
        }
        if (trialWrapper.trialBeforeUpdate != null && !trialWrapper.trialBeforeUpdate.gstars_General_Indications_for_Trial__r.isEmpty()) {
        	trialWrapper.trialBeforeUpdateGIs = new Set<Id>();
        	for (CFAR_General_Indication_for_Trial_gne__c GI : trialWrapper.trialBeforeUpdate.gstars_General_Indications_for_Trial__r) {
        		trialWrapper.trialBeforeUpdateGIs.add(GI.CFAR_General_Indication_ref_gne__c);
        	}
        }
        else {
        	trialWrapper.trialBeforeUpdateGIs = null;
        }

        CFAR_Milestone_Activity_gne__c[] linkedMa = [SELECT Name FROM CFAR_Milestone_Activity_gne__c WHERE CFAR_Trial_ref_gne__c = :String.valueOf(trialWrapper.innerObject.get('Id'))
            AND Name = :trialStatusToMaType.get(String.valueOf(trialWrapper.innerObject.get('frm_Trial_Status_ref_gne__c'))) AND Actual_Date_gne__c != null LIMIT 1];

        maTypeLinkedToStatus = !linkedMa.isEmpty() ? linkedMa[0].Name : '';
    }

    private void setSelectedOtherGNEAgentsList() {
        if(trialWrapper.innerObject.get('Other_GNE_Agents_Multi_gne__c') != null) {
            List<String> ids = new List<String>();
            String gneAgentsIds = String.valueOf(trialWrapper.innerObject.get('Other_GNE_Agents_Multi_gne__c'));
            ids = gneAgentsIds.split(';');
            if (gneAgentsIds.contains('N/A')){
                trialWrapper.selectedOtherGNEAgents.add('N/A');
            } else {
    	        List<CFAR_Trial_Other_GNE_Agent_gne__c> selectedOGA = [select Id, Other_GNE_Agent_ref_gne__c from CFAR_Trial_Other_GNE_Agent_gne__c where CFAR_Trial_ref_gne__c = :mainTrialId order by frm_Other_GNE_Agent_gne__c];
    	        for (CFAR_Trial_Other_GNE_Agent_gne__c sOGA : selectedOGA) {
    		        trialWrapper.selectedOtherGNEAgents.add(sOGA.Other_GNE_Agent_ref_gne__c);
    	        }
            }
        }
    }

    private void setSelectedIMPShippedList() {
    	List<CFAR_Trial_IMP_Shipped__c> selectedIMP = [select Id, IMP_Shipped_ref__c from CFAR_Trial_IMP_Shipped__c where CFAR_Trial_ref_gne__c = :mainTrialId order by frm_IMP_Shipped__c];
    	for (CFAR_Trial_IMP_Shipped__c sIMP : selectedIMP) {
    		trialWrapper.selectedIMPShipped.add(sIMP.IMP_Shipped_ref__c);
    	}
    }

    private void setSelectedImpactsList() {
        for (CFAR_Trial_Picklist_gne__c si : [SELECT Id, Name, CFAR_PicklistValue_ref_gne__r.Id, CFAR_PicklistValue_ref_gne__r.Name
            FROM CFAR_Trial_Picklist_gne__c WHERE CFAR_Trial_ref_gne__c = :trialWrapper.innerObject.Id
            AND CFAR_PicklistValue_ref_gne__r.RecordType.Name = 'Impact']) {
            trialWrapper.selectedImpact.add(si.CFAR_PicklistValue_ref_gne__c);
        }
    }

    private void setSelectedPartnershipsList() {
        if(trialWrapper.innerObject.get('Partnership_Multi_gne__c') != null) {
            List<String> ids = new List<String>();
            String partnershipIds = String.valueOf(trialWrapper.innerObject.get('Partnership_Multi_gne__c'));
            ids = partnershipIds.split(';');
            if(partnershipIds.contains('N/A')){
                trialWrapper.selectedPartnerships.add('N/A');
            }else {
                List<CFAR_Partnership_gne__c> selectedPartnership = [select Id, Name from CFAR_Partnership_gne__c where Id IN :ids];
            for (CFAR_Partnership_gne__c ps : selectedPartnership) {
                    trialWrapper.selectedPartnerships.add(ps.Id);
                }
            }
        }
    }
    
    private void setSelectedSIList() {
    	List<CFAR_Specific_Indication_for_Trial_gne__c> selectedSI = [select Id, CFAR_Specific_Indication_ref_gne__c from CFAR_Specific_Indication_for_Trial_gne__c where CFAR_Trial_ref_gne__c = :mainTrialId order by CFAR_Specific_Indication_ref_gne__r.Name];
    	for (CFAR_Specific_Indication_for_Trial_gne__c sSI : selectedSI) {
    		trialWrapper.selectedSpecificIndications.add(sSI.CFAR_Specific_Indication_ref_gne__c);
    	}
    }
    
    private void setSelectedGILists() {
    	List<CFAR_General_Indication_for_Trial_gne__c> selectedGI = [select Id, CFAR_General_Indication_ref_gne__c from CFAR_General_Indication_for_Trial_gne__c where CFAR_Trial_ref_gne__c = :mainTrialId order by CFAR_General_Indication_ref_gne__r.Name];
    	for (CFAR_General_Indication_for_Trial_gne__c sGI : selectedGI) {
    		trialWrapper.selectedGeneralIndications.add(sGI.CFAR_General_Indication_ref_gne__c);
    		trialWrapper.selectedGeneralIndicationsPopUp.add(sGI.CFAR_General_Indication_ref_gne__c);
    	}
    }
  
    public void clearGeneralAndSpecificIndicationsForBiooncology() {
        if (((CFAR_Trial_gne__c)trialWrapper.innerObject).Therapeutic_Area_ref_gne__c != null && String.valueOf(((CFAR_Trial_gne__c)trialWrapper.innerObject).Therapeutic_Area_ref_gne__c) == CFAR_Utils.BIOONCOLOGY_TA_ID /**bioOncologyTAId*/) {
            trialWrapper.selectedGeneralIndications = new List<String>();
            trialWrapper.selectedGeneralIndicationsPopUp = TrialWrapper.selectedGeneralIndications;
            trialWrapper.selectedSpecificIndications = new List<String>();
            trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', null);
        }
    }


    private void setOtherGNEAgentsField() {
        String agentsField = null;
        if (trialWrapper.selectedOtherGNEAgents != null && !trialWrapper.selectedOtherGNEAgents.isEmpty()) {
            agentsField = '';  
            for (String s : trialWrapper.selectedOtherGNEAgents) {
                agentsField += (s + ';');
            }
            agentsField = agentsField.removeEnd(';');
        }
        trialWrapper.innerObject.put('Other_GNE_Agents_Multi_gne__c', agentsField);
    }

    private void setIMPShippedField() {
        String impField = null;
        if (trialWrapper.selectedIMPShipped != null && !trialWrapper.selectedIMPShipped.isEmpty()) {
            impField = '';  
            for (String s : trialWrapper.selectedIMPShipped) {
                impField += (s + ';');
            }
            impField = impField.removeEnd(';');
        }
        trialWrapper.innerObject.put('IMP_Shipped_Multi_gne__c', impField);
    }

    public void clearIMPShippedField() {        

        if (trialWrapper.innerObject.get('Dollar_and_Drug_ref_gne__c') != null){
            String dollarDrugName = getGNESupportName();
            if (dollarDrugName == '$ Only') {        
                trialWrapper.selectedIMPShipped = new List<String>();
                if(!removeIMPShippedWithProductsInCohort()) {
                    trialWrapper.innerObject.put('IMP_Shipped_Multi_gne__c', null);
                    disabledIMPShipped = true;
                }
            } else {
                if(trialWrapper.selectedIMPShipped.isEmpty() && disabledIMPShipped && !trialWrapper.selectedOtherGNEAgents.contains('N/A')) {
                    for(String s : trialWrapper.selectedOtherGNEAgents){
                        if(!trialWrapper.selectedIMPShipped.contains(s)){
                            trialWrapper.selectedIMPShipped.add(s);
                        }
                    }
                }
                disabledIMPShipped = false;
            }
        } else {
            if(trialWrapper.selectedIMPShipped.isEmpty() && disabledIMPShipped && !trialWrapper.selectedOtherGNEAgents.contains('N/A')) {
                for(String s : trialWrapper.selectedOtherGNEAgents){
                    if(!trialWrapper.selectedIMPShipped.contains(s)){
                        trialWrapper.selectedIMPShipped.add(s);
                    }
                }
            }
            disabledIMPShipped = false;
        }
    }
    
    private void setPartnershipField() {
        String partnershipField = null;
        if (trialWrapper.selectedPartnerships != null && !trialWrapper.selectedPartnerships.isEmpty()) {
            partnershipField = '';
            for (String s : trialWrapper.selectedPartnerships) {
                partnershipField += (s + ';');
            }
            partnershipField = partnershipField.removeEnd(';');
        }
        trialWrapper.innerObject.put('Partnership_Multi_gne__c', partnershipField);
    }
    
    public void cancelEditGeneralInfo() {
        editMode = false;
        trialWrapper.generalInfoEditMode = false;
        trialWrapper.trialBeforeUpdate = null;
        refreshTrial();
    }
    
    public void createCookie() {
        selectedTabName =  Apexpages.currentPage().getParameters().get('selectedTabName');
        Cookie tab = new Cookie('SelectedTabTrialCookie',selectedTabName,null,-1,false);
        ApexPages.currentPage().setCookies(new Cookie[]{tab});
    }
    
    private Boolean moreThan13OtherGNEAgents(){
        Boolean retVal = false;
        if (trialWrapper.selectedOtherGNEAgents != null && trialWrapper.selectedOtherGNEAgents.size() > 13) {
            addErrorMessage('Please select max 13 Studied Products');
            retVal = true;
        }
        return retVal;
    }

    private Boolean removeIMPShippedWithProductsInCohort(){
        Boolean retVal = false;

        Set<String> setOfIMPShippedInTrial = new Set<String>();
        Set<String> setOfMoleculesInCohort = new Set<String>();

        for (String molecule : trialWrapper.selectedIMPShipped)
            setOfIMPShippedInTrial.add(molecule);

        for (CFAR_Cohort_Molecule_gne__c moleculeConfiguration : [Select Molecule_Configuration_ref_gne__r.Product_gne__c FROM CFAR_Cohort_Molecule_gne__c WHERE Cohort_ref_gne__r.Trial_ref_gne__c = : mainTrialId])
            setOfMoleculesInCohort.add(String.valueOf(moleculeConfiguration.Molecule_Configuration_ref_gne__r.Product_gne__c));

        for (String molecule : setOfMoleculesInCohort) {
            if (!setOfIMPShippedInTrial.contains(molecule) || (!setOfMoleculesInCohort.isEmpty() && setOfIMPShippedInTrial.contains('N/A'))) {
                addErrorMessage('Cannot delete Molecule when it is used in a Cohort.');           
                retVal = true;
            }
        }
        return retVal;
    }

    private Boolean moreThan13IMPShipped(){
        Boolean retVal = false;
        if (trialWrapper.selectedIMPShipped != null && trialWrapper.selectedIMPShipped.size() > 13) {
            addErrorMessage('Please select max 13 IMP Shipped');
            retVal = true;
        }
        return retVal;
    }

    private Boolean moreThan15SpecificIndications(){
        Boolean retVal = false;
        if (trialWrapper.selectedSpecificIndications != null && trialWrapper.selectedSpecificIndications.size() > 15) {
            addErrorMessage('You can choose max 15 Specific Indications!');
            retVal = true;
        }
        return retVal;
    }
    
    public void saveTrial(){
        if(checkExternalDuplicate() && !trialWrapper.duplicatedCTMS() && /*!productGNEAgentSame &&*/ !requiredFieldIsEmpty() && !moreThan13OtherGNEAgents() && !moreThan13IMPShipped()
        		&& !moreThan15SpecificIndications() && !removeIMPShippedWithProductsInCohort()){
        	System.Savepoint sp = Database.setSavepoint();
            try{
                setOtherGNEAgentsField();
                setIMPShippedField();
                setPartnershipField();
                CFAR_Utils.setGeneralIndicationsField(trialWrapper);
                CFAR_Utils.setSpecificIndicationsField(trialWrapper);
                String status = '';
                if(trialWrapper.selectedDiseaseStatus.size() > 0) {
                	for(String s : trialWrapper.selectedDiseaseStatus) {
                		status += s;
                		status += ';';
                	}
                	
                }
                status = status.removeEnd(';');
                trialWrapper.innerObject.put('Disease_Status_Picklist_gne__c',status);
                
                String line = '';
                if(trialWrapper.selectedLineOfTherapy.size() > 0) {
                	for(String s : trialWrapper.selectedLineOfTherapy) {
                		line += s;
                		line += ';';
                	}
                	
                }
                line = line.removeEnd(';');
                trialWrapper.innerObject.put('Line_Of_Therapy_gne__c',line);
                
                String population = '';
                if(trialWrapper.selectedPatientSubPopulation.size() > 0) {
                	for(String s : trialWrapper.selectedPatientSubPopulation) {
                		population += s;
                		population += ';';
                	}
                	
                }
                population = population.removeEnd(';');
                trialWrapper.innerObject.put('Sub_Patient_Population_gne__c',population);
                
                String phase = '';
                if(trialWrapper.selectedStudyPhase.size() > 0) {
                	for(String s : trialWrapper.selectedStudyPhase) {
                		phase += s;
                		phase += ';';
                	}
                	
                }
                phase = phase.removeEnd(';');
                trialWrapper.innerObject.put('Study_Phase_Multi_gne__c',phase);
                
                removeTypeOfSampleRecordsIfLabSupportIsNotYes();

                syncGneSupportWithPiMember();
                upsert (CFAR_Trial_gne__c)trialWrapper.innerObject;
                editMode = false;
                trialWrapper.generalInfoEditMode = false;
                trialWrapper.trialBeforeUpdate = null;
                refreshTrial();
                      
                if(oldProductId != String.valueOf(trialWrapper.innerObject.get('Product_ref_gne__c'))){
                    System.DEBUG('ProductId changed - '+ oldProductId+'=>'+String.valueOf(trialWrapper.innerObject.get('Product_ref_gne__c')));
                    System.DEBUG('Id sizes -'+oldProductId.length()+'    '+String.valueOf(trialWrapper.innerObject.get('Product_ref_gne__c')).length());
                    trialWrapper.initWholeTrialSelectOptions();
                }
                saveImpacts();
            } catch (Exception e){
            	Database.rollback(sp);
                String validationMessage;
                if(e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION, ') != -1){
                    String[] splitStr = e.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                    validationMessage = splitStr[1].substring(0,splitStr[1].length() - 4);
                }else if(e.getMessage().contains('DUPLICATE_VALUE')){
                    validationMessage = 'Portal RO Number already exists.';
                }
                else {
                    validationMessage = e.getMessage();
                }
                addErrorMessage(validationMessage);
            }
        }
    }

    private void saveImpacts() {
        CFAR_Trial_Picklist_gne__c[] newImpactJunctions = new List<CFAR_Trial_Picklist_gne__c>();
        CFAR_Trial_Picklist_gne__c[] impactJunctionsToDelete = new List<CFAR_Trial_Picklist_gne__c>();
        Set<String> existingImpactJunctions = new Set<String>();
        Set<String> selectedImpactSet = new Set<String>();

        for (String si : trialWrapper.selectedImpact) {
            selectedImpactSet.add(si);
        }

        for (CFAR_Trial_Picklist_gne__c tp : [SELECT Id, Name, CFAR_PicklistValue_ref_gne__c, CFAR_PicklistValue_ref_gne__r.Name FROM CFAR_Trial_Picklist_gne__c WHERE CFAR_Trial_ref_gne__c = :trialWrapper.innerObject.Id AND CFAR_PicklistValue_ref_gne__r.RecordType.Name = 'Impact']) {
            existingImpactJunctions.add(tp.CFAR_PicklistValue_ref_gne__c);
            if (!selectedImpactSet.contains(tp.CFAR_PicklistValue_ref_gne__c)) {
                impactJunctionsToDelete.add(tp);
            }
        }

        if (trialWrapper.selectedImpact != null && !trialWrapper.selectedImpact.isEmpty()) {
            for (String s : trialWrapper.selectedImpact) {
                if (!existingImpactJunctions.contains(s)) {
                    newImpactJunctions.add(new CFAR_Trial_Picklist_gne__c(CFAR_Trial_ref_gne__c = trialWrapper.innerObject.Id, CFAR_PicklistValue_ref_gne__c = s));
                }
            }
        }

        insert newImpactJunctions;
        delete impactJunctionsToDelete;
    }

    private Boolean contractRequestedDateFilled(String trialId){
        Boolean retVal = true;
        List<String> contractStatuses = new List<String> {Label.CFAR_GSTARS_CONTRACT_TRACKING_DECREASE_TYPE, Label.CFAR_GSTARS_CONTRACT_TRACKING_INCREASE_TYPE, Label.CFAR_GSTARS_CONTRACT_TRACKING_ORGINAL_TYPE};
        List<CFAR_Budget_Contract_Tracking_gne__c> b = [SELECT ID,frm_Trial_Id_gne__c,frm_Type_gne__c, Contract_Requested_Date__c
        FROM CFAR_Budget_Contract_Tracking_gne__c
        WHERE Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.Id = :trialId AND frm_Type_gne__c IN :contractStatuses];
        for(CFAR_Budget_Contract_Tracking_gne__c bct : b){
            if(bct.Contract_Requested_Date__c == null){
                retVal = false;
                break;
            }
        }
        return retVal;
    }
    
    private Boolean requiredFieldIsEmpty() {
        Boolean retVal = false;
        String RONumber = 'RO-IIS-' + Date.Today().Year() +'-';
        List<String> messagesList = new List<String>();
        if (((CFAR_Trial_gne__c)trialWrapper.innerObject).Product_ref_gne__c == null) {
            messagesList.add('Please select Theme Name');
            retVal = true;
        }

        Sobject innerObj = trialWrapper.innerObject;
        String status = allTrialStatus.get(String.valueOf(innerObj.get('Trial_Status_ref_gne__c')));

        Date latestCommentDate;
        if(innerObj.get('Latest_Comment_Date_gne__c') != null) {
            latestCommentDate = (Date) innerObj.get('Latest_Comment_Date_gne__c');
        } else latestCommentDate = Date.Today().addYears(-1);

		String sta = String.valueOf(innerObj.get('Trial_Status_ref_gne__c'));

        if( allTrialStatus.get(sta) == 'Concluded' || allTrialStatus.get(sta) == 'Premature Termination'){
            if((innerObj.get('IRB_Closure_Letter_Received_gne__c') == false || (innerObj.get('IRB_Closure_Letter_Received_gne__c') == true && innerObj.get('IRB_Closure_Received_Date_gne__c') == null))
                    && String.valueOf(innerObj.get('IRB_Required_gne__c')) != 'NO'){
                messagesList.add('Please make sure IRB Closure Letter received (actual date entered in reg doc section UNLESS IRB required is set to NO)');
                retVal = true;
            }

            if((innerObj.get('Study_Closure_Letter_Received_gne__c') == false || (innerObj.get('Study_Closure_Letter_Received_gne__c') == true && innerObj.get('Study_Closure_Letter_Received_gne__c') == null))){
                messagesList.add('Please make sure Study Closure Letter Sent (actual date entered in reg doc section)');
                retVal = true;
            }

            if((innerObj.get('Final_Study_Report_Received_gne__c') == false || (innerObj.get('Final_Study_Report_Received_gne__c') == true && innerObj.get('Final_Study_Report_Received_Date_gne__c') == null))
                    && String.valueOf(innerObj.get('FSR_Required_gne__c')) != 'NO'){
                messagesList.add('Please make sure the Final Study Report received (actual date entered in reg doc section UNLESS FSR required is set to NO)');
                retVal = true;
            }

            if(Integer.valueOf(innerObj.get('Payments_With_Invoice_Paid_Or_Cancelled__c')) > 0){
                messagesList.add('Please make sure All payments in payment section have status of Refund, Invoice Paid or Unpaid Contract Amount');
                retVal = true;
            }
        }

        if(allTrialStatus.get(sta) == 'Concluded' && integer.ValueOf(innerObj.get('Milestones_Without_Actual_Date_gne__c')) > 0){
            messagesList.add('Please make sure All Milestone dates have an actual date entered');
            retVal = true;
        }

        if (allTrialStatus.get(sta) == 'Concluded' && !isCostCenterValue100()) {
            messagesList.add('Please, make sure aggregated Cost Center Values are 100');
            retVal = true;
        }   

        if(allTrialStatus.get(sta) == 'Concluded' && (Integer.valueOf(innerObj.get('Enrollment_Enrolled_Num_gne__c')) != (Integer.valueOf(innerObj.get('Enrollment_Completed_Num_gne__c')) + Integer.valueOf(innerObj.get('Enrollment_Discontinued_Num_gne__c'))))){
            messagesList.add('Please make sure Actual Enrollment Table - # Enrolled must equal # Discontinued + # Completed Trial');
            retVal = true;
        }

        if (String.isBlank(String.valueOf(((CFAR_Trial_gne__c)trialWrapper.innerObject).CFAR_General_Indication_ref_gne__c))){
        	messagesList.add('Please select General Indication');
            retVal = true;
        }

        if (trialWrapper.selectedGeneralIndications != null && !trialWrapper.selectedGeneralIndications.isEmpty()) {
            Set<String> sgiSet = new Set<String>(trialWrapper.selectedGeneralIndications);
            if (sgiSet.contains(CFAR_Utils.GENERAL_INDICATION_OTHER_OPTION_ID) && String.isBlank(String.valueOf(trialWrapper.innerObject.get('General_Indication_Other_gne__c')))) {
            	messagesList.add('Please add General Indication Other');
           		retVal = true;
            }
        }
            
        if (trialWrapper.selectedSpecificIndications != null && !trialWrapper.selectedSpecificIndications.isEmpty()) {
            Set<String> ssiSet = new Set<String>(trialWrapper.selectedSpecificIndications);
            if (ssiSet.contains(CFAR_Utils.SPECIFIC_INDICATION_OTHER_OPTION_ID) && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Specific_Indication_Other_gne__c')))) {
            	messagesList.add('Please add Specific Indication Other');
           		retVal = true;
            }
        }
		
		if (((CFAR_Trial_gne__c)trialWrapper.innerObject).Trial_Type_ref_gne__c == null) {
            messagesList.add('Please select Trial Type');
            retVal = true;
        }
        if (((CFAR_Trial_gne__c)trialWrapper.innerObject).Therapeutic_Area_ref_gne__c == null) {
            messagesList.add('Please select Medical Unit');
            retVal = true;
        }
        if (((CFAR_Trial_gne__c)trialWrapper.innerObject).Subject_Type__c == null) {
            messagesList.add('Please select Subject Type');
            retVal = true;
        }

        if ('Human'.equals(((CFAR_Trial_gne__c)trialWrapper.innerObject).Subject_Type__c) && String.isBlank(((CFAR_Trial_gne__c)trialWrapper.innerObject).CTMS_gne__c)) {
        	messagesList.add('Please add CTMS #');
            retVal = true;
        }
        
        if (trialWrapper.getIsDiseaseStatusOtherRequired() && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Disease_Status_Other_gne__c')))) {
        	messagesList.add('Please add Disease Status Other');
           	retVal = true;
        }
        
        if (trialWrapper.getIsLineOfTherapyOtherRequired() && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Line_of_Therapy_Other_gne__c')))) {
        	messagesList.add('Please add Line of Therapy Other');
           	retVal = true;
        }

        if (trialWrapper.isInclusiveDescriptionRequired && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Inclusive_Research_Description_gne__c')))) {
            messagesList.add('Please add Inclusive Research Description');
            retVal = true;
        }
        
        if(String.isBlank(String.valueof(trialWrapper.innerObject.get('SRT_Team_ref_gne__c'))) || trialWrapper.innerObject.get('SRT_Team_ref_gne__c') == null){
            messagesList.add('SRT Team is required. Please select a value.');
            retVal = true;
        }
        
        if(trialWrapper.selectedPatientSubPopulation != null && !trialWrapper.selectedPatientSubPopulation.isEmpty()) {
        	Set<String> selectedPatientSubPopulationTempSet = new Set<String>(trialWrapper.selectedPatientSubPopulation);
           	if (selectedPatientSubPopulationTempSet.contains('Other') && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Sub_Patient_Population_Other_Desc_gne__c')))) {
           		messagesList.add('Please add Patient Sub-Population Other Description');
           		retVal = true;
           	}
           	if (selectedPatientSubPopulationTempSet.contains('Ethnicity') && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Ethnicity_Description_gne__c')))) {
           		messagesList.add('Please add Ethnicity Description');
           		retVal = true;
           	}
           	if (selectedPatientSubPopulationTempSet.contains('Medical Comorbidity') && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Medical_Comorbidity_Description_gne__c')))) {
           		messagesList.add('Please add Medical Comorbidity Description');
           		retVal = true;
           	}
           	if (selectedPatientSubPopulationTempSet.contains('Treatment Refractory') && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Treatment_Refractory_Description_gne__c')))) {
           		messagesList.add('Please add Treatment Refractory Description');
           		retVal = true;
           	}
           	if (selectedPatientSubPopulationTempSet.contains('Treatment Sensitive') && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Treatment_Sensitive_Description_gne__c')))) {
           		messagesList.add('Please add Treatment Sensitive Description');
           		retVal = true;
           	}
        }

        if ('Other'.equals(String.valueOf(((CFAR_Trial_gne__c)trialWrapper.innerObject).Subject_type__c)) && String.isBlank(String.valueOf(trialWrapper.innerObject.get('Subject_Type_Other_gne__c')))) {
        	messagesList.add('Please add Subject Type Other');
           	retVal = true;
        }
        
        if (trialWrapper.selectedStudyPhase == null || trialWrapper.selectedStudyPhase.isEmpty()) {
            System.debug('StudyPhase if');
        	messagesList.add('Please select Study Phase');
           	retVal = true;
        }
        
        if (retVal && !messagesList.isEmpty()) {
            addErrorMessages(messagesList);
        }
        return retVal;
    }
    
    private Boolean checkExternalDuplicate(){
    	Boolean noDuplicates = CFAR_Utils.checkExternalDuplicate(((CFAR_Trial_gne__c)trialWrapper.innerObject).Id, ((CFAR_Trial_gne__c)trialWrapper.innerObject).Other_Trial_gne_Id__c);
    	if(!noDuplicates)
			addErrorMessage('Trial with \'Other #\' ' + ((CFAR_Trial_gne__c)trialWrapper.innerObject).Other_Trial_gne_Id__c + ' already exists');
        return noDuplicates;
    }

    private String getGNESupportName(){
        String dollarDrugId = String.valueof(trialWrapper.innerObject.get('Dollar_and_Drug_ref_gne__c'));
        return [SELECT Name FROM CFAR_Dollar_and_Drug_gne__c WHERE Id =: dollarDrugId].Name;
    }

    public void processStudiedProducts() {
        String dollarDrugId = null;
        if (trialWrapper.innerObject.get('Dollar_and_Drug_ref_gne__c') != null){           
            String dollarDrugName = getGNESupportName();
            if (dollarDrugName != '$ Only'){
                autopopulateIMPShipped();
            }
        } else if (dollarDrugId == null){
            autopopulateIMPShipped();
        }

    }

    public void processIMPShipped() {
        
        Set<String> setOfIMPShippedInTrial = new Set<String>();
        Set<String> setOfMoleculesInCohort = new Set<String>();

        for (String molecule : trialWrapper.selectedIMPShipped)
            setOfIMPShippedInTrial.add(molecule);

        for (CFAR_Cohort_Molecule_gne__c moleculeConfiguration : [Select Molecule_Configuration_ref_gne__r.Product_gne__c FROM CFAR_Cohort_Molecule_gne__c WHERE Cohort_ref_gne__r.Trial_ref_gne__c = : mainTrialId])
            setOfMoleculesInCohort.add(String.valueOf(moleculeConfiguration.Molecule_Configuration_ref_gne__r.Product_gne__c));

        for (String molecule : setOfMoleculesInCohort) {
            if (!setOfIMPShippedInTrial.contains(molecule) || (!setOfMoleculesInCohort.isEmpty() && setOfIMPShippedInTrial.contains('N/A'))) {
                trialWrapper.selectedIMPShipped.add(molecule);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot delete Molecule when it is used in a Cohort.'));
            }
        }

    }

    public void autopopulateIMPShipped(){
        List<String> productsFromMulti = new List<String>();
        if(trialWrapper.innerObject.get('Other_GNE_Agents_Multi_gne__c') != null){
            productsFromMulti = String.valueOf(trialWrapper.innerObject.get('Other_GNE_Agents_Multi_gne__c')).split(';');
        }
        if (!trialWrapper.selectedOtherGNEAgents.contains('N/A')){
            for(String s : trialWrapper.selectedOtherGNEAgents){
                if(!trialWrapper.selectedIMPShipped.contains(s) && !productsFromMulti.contains(s)){
                    trialWrapper.selectedIMPShipped.add(s);
                }
            }
        }else{
            trialWrapper.innerObject.put('IMP_Shipped_Multi_gne__c', null);
            trialWrapper.selectedIMPShipped = new List<String>();
        }
    }

    public void hideTrialAddedMessage(){
        trialAdded = false;
    }
    
    private void removeTypeOfSampleRecordsIfLabSupportIsNotYes() {
    	if(String.valueOf(trialWrapper.innerObject.get('Lab_Support_gne__c')) != 'YES') {
    		List<CFAR_Trial_Type_of_Sample_gne__c> trialTypesOfSamplesToDel = [select Id from CFAR_Trial_Type_of_Sample_gne__c where CFAR_Trial_ref_gne__c = :mainTrialId];
    		if (!trialTypesOfSamplesToDel.isEmpty()) {
    			delete trialTypesOfSamplesToDel;
    		}
            trialWrapper.innerObject.put('Sub_Patient_Population_gne__c', null);
            trialWrapper.innerObject.put('Biomarker_Description_gne__c', null);
            trialWrapper.innerObject.put('Biomarker_Questions_gne__c', null);
            trialWrapper.selectedPatientSubPopulation = new List<String>();
            trialWrapper.innerObject.put('Sub_Patient_Population_Other_Desc_gne__c', null);
            trialWrapper.innerObject.put('Treatment_Sensitive_Description_gne__c', null);
            trialWrapper.innerObject.put('Treatment_Refractory_Description_gne__c', null);
            trialWrapper.innerObject.put('Medical_Comorbidity_Description_gne__c', null);
            trialWrapper.innerObject.put('Ethnicity_Description_gne__c', null);
        }
    }
    
    private void syncGneSupportWithPiMember() {
        CFAR_Team_Member_gne__c[] pi = [SELECT Dollar_and_Drug_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c = :String.valueOf(trialWrapper.innerObject.get('Id')) AND frm_Function_Role_gne__c = 'PI = Primary (or Principal) Investigator' AND frm_Is_Inactive_gne__c = false LIMIT 1];
        if(!pi.isEmpty() && pi[0].Dollar_and_Drug_ref_gne__c != String.valueOf(trialWrapper.innerObject.get('Dollar_and_Drug_ref_gne__c'))){
            pi[0].Dollar_and_Drug_ref_gne__c = String.valueOf(trialWrapper.innerObject.get('Dollar_and_Drug_ref_gne__c'));
            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger'});
            update pi;
            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{});
        }
    }

    public void deleteTrialTypeOfSample() {
    	System.Savepoint sp = Database.setSavepoint();
    	try {
    		delete trialWrapper.trialTypeOfSampleRecordsMap.get(trialWrapper.typeOfSampleId);
    	}
    	catch (Exception e) {
    		Database.rollback(sp);
    		addErrorMessage(e.getMessage());
    	}
    }
    
    public void createNewTrialTypeOfSample() {
        trialWrapper.newEditTrialTypeOfSample = new CFAR_Trial_Type_of_Sample_gne__c(CFAR_Trial_ref_gne__c = mainTrialId);
        setOtherTOSId();
        showNewTOSPopup = true;
        isError = false;
        errorMessage = '';
    }
    
    public void editTrialTypeOfSample() {
    	trialWrapper.newEditTrialTypeOfSample = trialWrapper.trialTypeOfSampleRecordsMap.get(trialWrapper.typeOfSampleId);
    	setOtherTOSId();
    	showNewTOSPopup = true;
        isError = false;
        errorMessage = '';
    }
    
    public PageReference submitTrialTypeOfSample() {
    	isError = false;
        errorMessage = '';
        System.Savepoint sp = Database.setSavepoint();
        try {
        	if (trialWrapper.newEditTrialTypeOfSample.Type_of_Sample_ref_gne__c == null) {
        		errorMessage = 'Please select Type of Sample';
        		isError = true;
        		return null;
        	} else if (trialWrapper.newEditTrialTypeOfSample.Type_of_Sample_ref_gne__c == trialWrapper.otherTOSId && String.isBlank(trialWrapper.newEditTrialTypeOfSample.Type_of_Sample_Other_gne__c)){
        		errorMessage = 'Please add Type of Sample Other';
        		isError = true;
        		return null;
        	}
        	upsert trialWrapper.newEditTrialTypeOfSample;
        }
        catch (Exception e) {
            Database.rollback(sp);
            errorMessage = e.getMessage();
            isError = true;
            return null;
        }
        return null;
    }
    
    public void cancelTOS() {
        showNewTOSPopup = false;

    }
    
    private void setOtherTOSId() {
    	List<CFAR_Type_of_Sample_gne__c> otherTOSList = [select Id from CFAR_Type_of_Sample_gne__c where Name = 'Other' order by Active_gne__c desc, LastModifiedDate desc limit 1];
    	if (!otherTOSList.isEmpty()) {
    		trialWrapper.otherTOSId = otherTOSList[0].Id;
    	}
    }
    
    public void clearTypeOfSampleOther() {
        trialWrapper.newEditTrialTypeOfSample.Type_of_Sample_Other_gne__c = null;
    }
    
    public PageReference submitGeneralIndication(){
        System.debug('giPopup ' + trialWrapper.selectedGeneralIndicationsPopUp);
        System.debug('giNiePopup ' + trialWrapper.selectedGeneralIndications);
        isError = false;
        errorMessage = '';
        if(trialWrapper.selectedGeneralIndicationsPopUp.size() > 15) {
            isError = true;
            errorMessage = 'You can choose max 15 General Indications!';
            return null;
        }
        if(trialWrapper.selectedGeneralIndicationsPopUp.size() > 1 && (ApexPages.currentPage().getParameters().get('primaryInd') == null || ApexPages.currentPage().getParameters().get('primaryInd') =='')) {
            isError = true;
            errorMessage = 'You have to choose Primary General Indication! ';
            return null;
        } else {
            
            trialWrapper.selectedGeneralIndications = trialWrapper.selectedGeneralIndicationsPopUp;
            if(trialWrapper.selectedGeneralIndicationsPopUp.size() == 1) {
                trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c',trialWrapper.selectedGeneralIndicationsPopUp.get(0));
            } else {
                trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c',ApexPages.currentPage().getParameters().get('primaryInd'));
            }

            if (trialWrapper.selectedGeneralIndications != null && !trialWrapper.selectedGeneralIndications.isEmpty()) {
            	if (trialWrapper.selectedSpecificIndications != null && !trialWrapper.selectedSpecificIndications.isEmpty()) {
            		Set<String> selectedSpecificIndicationsSet = new Set<String>(trialWrapper.selectedSpecificIndications);
            		if (selectedSpecificIndicationsSet.contains(CFAR_Utils.SPECIFIC_INDICATION_OTHER_OPTION_ID)) {
            			return null;
            		}
            	}
            	Set<String> selectedGeneralIndicationsSet = new Set<String>(trialWrapper.selectedGeneralIndications);
            	if (selectedGeneralIndicationsSet.contains(CFAR_Utils.GENERAL_INDICATION_HEAD_AND_NECK_OPTION_ID) || selectedGeneralIndicationsSet.contains(CFAR_Utils.GENERAL_INDICATION_OTHER_MALIGNANCIES_OPTION_ID)) {
            		if (trialWrapper.selectedSpecificIndications == null) {
            			trialWrapper.selectedSpecificIndications = new List<String>();
            		}
            		trialWrapper.selectedSpecificIndications.add(CFAR_Utils.SPECIFIC_INDICATION_OTHER_OPTION_ID);
            	}
            }
            
            System.debug('giPopup2 ' + trialWrapper.selectedGeneralIndicationsPopUp);
            System.debug('giNiePopup2 ' + trialWrapper.selectedGeneralIndications);
            return null;
        }
    }
    
    public PageReference cancelGeneralIndication() {
        trialWrapper.selectedGeneralIndicationsPopUp = trialWrapper.selectedGeneralIndications;
        return null;
    }
    
    public List<CFAR_General_Indication_gne__c> getSelectedGeneralIndicationMappings() {
    	List<CFAR_General_Indication_gne__c> pairs = new List<CFAR_General_Indication_gne__c>();
    	if(trialWrapper != null && trialWrapper.selectedGeneralIndicationsPopUp != null) {
    		pairs = [Select Id, Name From CFAR_General_Indication_gne__c where Id in :trialWrapper.selectedGeneralIndicationsPopUp];
    	}
    	return pairs;
    }
    
    public Boolean trialWithInactiveInvestigator {
    	get {
    		Boolean retVal = false;
    		if (mainTrialId != null) {
    			retVal = [select Id from CFAR_Team_Member_gne__c
    				  	  where CFAR_Trial_ref_gne__c = :mainTrialId
    				  	  and frm_Function_Role_gne__c = 'PI = Primary (or Principal) Investigator'
    				  	  and frm_Is_Inactive_gne__c = false
    				  	  limit 1].isEmpty();
    		}
    		return retVal;
    	}
    	set;
    }

    public Boolean isCostCenterValue100() {
        List<AggregateResult> ccValue = [SELECT SUM(Value__c) FROM Cost_Center_for_Trial__c WHERE gStars_Trial__c = :mainTrialId];
        return ((Decimal)ccValue[0].get('expr0') == 100) ? true : false;
    }
}