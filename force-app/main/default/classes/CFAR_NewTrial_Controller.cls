public with sharing class CFAR_NewTrial_Controller extends CFAR_BaseController{

    public CFAR_TrialWrapper trialWrapper{get; private set;}
    public CFAR_NewTrial_Controller(){
        trialWrapper = new CFAR_TrialWrapper();
        trialWrapper.initWholePrimaryContactSelectOptions();
        trialWrapper.initWholeInvestigatorSelectOptions();
        trialWrapper.initWholeMSLSelectOptions();
        trialWrapper.initWholeSRTChairSelectOptions();
        trialWrapper.generalInfoEditMode = true;
        wrapperValidationErrors = new Map<String,String>();
        trialWrapper.selectedStudyPhase = new List<String>();
        trialWrapper.availableStudyPhase = new List<SelectOption>();
        fillAddressTypes();
    }
    
    public Map<String,String> wrapperValidationErrors {get;set;}
    
    public PageReference add(){
         wrapperValidationErrors=this.trialWrapper.getValidationErrors();
		 if(selAddr == null){
            	wrapperValidationErrors.put('addressTypeError', 'You must enter a value');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Investigator Address cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }
            
            if(selAddrType == null){
            	wrapperValidationErrors.put('addressTypeError', 'You must enter a value');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Investigator Address Type cannot be blank. Please enter a value.');
                ApexPages.addMessage(myMsg);
            }

        if(String.isNotBlank(String.valueOf(trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c'))) &&
                (String.valueOf(trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c')).length() != 17
                        || String.valueOf(trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c')).left(7) != 'RO-IIS-'
                        || (String.valueOf(trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c')).right(5)).isNumeric() == false
                        || (String.valueOf(trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c')).substring(7,11)).isNumeric() == false
                        || String.valueOf(trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c')).charAt(6) != 45
                        || String.valueOf(trialWrapper.innerObject.get('IIS_Portal_RO_Number_gne__c')).charAt(11) != 45)){
                wrappervalidationErrors.put('portalRONumber', 'incorrect format ');
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Incorrect format for IIS Portal RO Number.');
                ApexPages.addMessage(myMsg);
            }
        
        if(String.isBlank(String.valueof(trialWrapper.innerObject.get('SRT_Team_ref_gne__c'))) || trialWrapper.innerObject.get('SRT_Team_ref_gne__c') == null){
            wrappervalidationErrors.put('SRTTeam', 'emptySRTTeam');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'SRT Team is required. Please select a value.');
            ApexPages.addMessage(myMsg);
        }
        
        for(String s : wrapperValidationErrors.values()) {
            if(s != '') {
                return null;
            }
        }
        CFAR_Utils.setGeneralIndicationsField(trialWrapper);
        CFAR_Utils.setSpecificIndicationsField(trialWrapper);
        String phase = '';
        if(trialWrapper.selectedStudyPhase.size() > 0) {
            for(String s : trialWrapper.selectedStudyPhase) {
                phase += s;
                phase += ';';
            }
                    
        }
        phase = phase.removeEnd(';');
        trialWrapper.innerObject.put('Study_Phase_Multi_gne__c',phase);
        
        System.Savepoint sp = Database.setSavepoint();        
        try {      
            if(!checkExternalDuplicate() || trialWrapper.duplicatedCTMS()){
                return null;
            }
            trialWrapper.innerObject.put('Dollar_and_Drug_ref_gne__c', selPIGneSupport);
            Database.SaveResult saveResult = trialWrapper.insertSobj();
            System.debug(String.format('########{0}  --sobj: {1} ',new String[] { ''+saveResult, ''+this.trialWrapper.innerObject  } )); 
             
            List<ID> trialIds = new List<ID>{String.valueOf(trialWrapper.innerObject.get('id'))};
            Map<ID,CFAR_Trial_gne__c> trialsAfterInsert = CFAR_DAO.geTrialsByIds(trialIds );
            this.trialWrapper.innerObject = trialsAfterInsert.values()[0];  // [select name from  CFAR_Trial_gne__c where id=:trialWrapper.innerObject.get('id') ]; 
            List<CFAR_Team_Member_gne__c> trialMembers = new List<CFAR_Team_Member_gne__c>();
            trialMembers.add(CFAR_Utils.createPITeamMemberNoSave((CFAR_Trial_gne__c) this.trialWrapper.innerObject, selAddr, selAddrType, selPIGneSupport));
            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger'});
            insert trialMembers;
            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{});

            CFAR_Trial_Picklist_gne__c[] newImpactJunctions = new List<CFAR_Trial_Picklist_gne__c>();

            if (trialWrapper.selectedImpact != null && !trialWrapper.selectedImpact.isEmpty()) {
                for (String si : trialWrapper.selectedImpact) {
                    newImpactJunctions.add(new CFAR_Trial_Picklist_gne__c(CFAR_Trial_ref_gne__c = this.trialWrapper.innerObject.Id, CFAR_PicklistValue_ref_gne__c = si));
                }
            }

            insert newImpactJunctions;

        } catch (Exception e) {
            Database.rollback(sp);
            String validationMessage;
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Portal RO Number already exists.');
            if(e.getMessage().contains('DUPLICATE_VALUE')){
                ApexPages.addMessage(myMsg);
            }

            return null; 
        }
        
        System.debug(LoggingLevel.INFO,'### finishing add...' );
         
        PageReference retPage = Page.CFAR_Trial;
        retPage.getParameters().put('Id',String.valueOf(trialWrapper.innerObject.get('id'))); 
        retPage.getParameters().put('trialadded',String.valueOf(this.trialWrapper.innerObject.get('Name')));
        retPage.setRedirect(true); 

        return retPage; 
    }
    
    public PageReference redirect(){
        return super.getReturnPage(); 
    }


    public PageReference clear(){
        //this.trialWrapper = new CFAR_TrialWrapper(); 
        this.trialWrapper.clear(); 
        return null; 
    }
    
    public String getConfirmMessage() {
        return System.Label.CFAR_NEW_TRIAL_SAVE_CONFIRM_gne;
    }

    private Boolean checkExternalDuplicate(){
        Boolean noDuplicates = CFAR_Utils.checkExternalDuplicate(null, ((CFAR_Trial_gne__c)trialWrapper.innerObject).Other_Trial_gne_Id__c);
        if(!noDuplicates)
            addErrorMessage('Trial with \'Other #\' ' + ((CFAR_Trial_gne__c)trialWrapper.innerObject).Other_Trial_gne_Id__c + ' already exists');
        return noDuplicates;
    }
    public void clearGeneralAndSpecificIndicationsForBiooncology(){

        if (((CFAR_Trial_gne__c)trialWrapper.innerObject).Therapeutic_Area_ref_gne__c != null && String.valueOf(((CFAR_Trial_gne__c)trialWrapper.innerObject).Therapeutic_Area_ref_gne__c) == CFAR_Utils.BIOONCOLOGY_TA_ID) {
            trialWrapper.selectedGeneralIndications = new List<String>();
            trialWrapper.selectedGeneralIndicationsPopUp = trialWrapper.selectedGeneralIndications;
            trialWrapper.selectedSpecificIndications = new List<String>();
            trialWrapper.innerObject.put('CFAR_General_Indication_ref_gne__c', null);
        }
    }   
    public PageReference submitGeneralIndication(){
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
            return null;
        }
    }
    
    public PageReference cancelGeneralIndication() {
        if (trialWrapper.selectedGeneralIndications == null || trialWrapper.selectedGeneralIndications.isEmpty()) {
            trialWrapper.selectedGeneralIndicationsPopUp = null;
        }
        return null;
    }
    
    public List<CFAR_General_Indication_gne__c> getSelectedGeneralIndicationMappings() {
        List<CFAR_General_Indication_gne__c> pairs = new List<CFAR_General_Indication_gne__c>();
        if(trialWrapper != null && trialWrapper.selectedGeneralIndicationsPopUp != null) {
            pairs = [Select Id, Name From CFAR_General_Indication_gne__c where Id in :trialWrapper.selectedGeneralIndicationsPopUp];
        }
        return pairs;
    }

    public List<SelectOption> getSRTTeamSelectOptions(){
        List<SelectOption> SRTTeams = new List<SelectOption>();

        for(CFAR_Picklist_Value_gne__c picklistValue : CFAR_DAO.getSRTTeams()){
            if(picklistValue.Active_gne__c == true) {
                SRTTeams.add(new SelectOption(picklistValue.Id, picklistValue.Name));
            }
        }
        return SRTTeams;

    }

    public Id selAddr {get; set;}
    private Map<Id, CFAR_Contact_Address_gne__c> addresses;
    public List<SelectOption> getContactAddressOptions() {
        Id investigatorId = (Id) trialWrapper.innerObject.get('Investigator_ref_gne__c');
        List<SelectOption> addrSelectOptions = new List<SelectOption>();
        if (String.isNotEmpty(investigatorId)) {
            List<CFAR_Contact_Address_JO_gne__c> addressJOList = CFAR_AddressUtils.getContactAddressList(investigatorId);
            addresses = new Map<Id, CFAR_Contact_Address_gne__c>();
            addrSelectOptions.add(new SelectOption('', '--None--'));
            if (addressJOList.isEmpty()) {
                selAddr = null;
            } else if (addressJOList.size() == 1) {
                selAddr = addressJOList.get(0).Id;
            } 
            for (CFAR_Contact_Address_JO_gne__c addrJO : addressJOList) {
                if (addrJO.active_gne__c == true) {
                    String address = addrJO.Contact_Address_ref_gne__r.Institution_gne__r.Name + ', ';

                    if(addrJO.Department_Division_gne__c != null)
                        address += addrJO.Department_Division_gne__c + ', ';
                        
                    address += addrJO.Contact_Address_ref_gne__r.Address_gne__c + ', ' + addrJO.Contact_Address_ref_gne__r.City_gne__c + ' ';

                    if (addrJO.Contact_Address_ref_gne__r.Country_gne__c == 'USA')
                        address += addrJO.Contact_Address_ref_gne__r.State_gne__c + ' ' + addrJO.Contact_Address_ref_gne__r.Zip_gne__c;

                    else
                        address += addrJO.Contact_Address_ref_gne__r.Province_gne__c + ' ' + addrJO.Contact_Address_ref_gne__r.Postal_Code_gne__c;

                    addrSelectOptions.add(new SelectOption(addrJO.Id, address));
                    addresses.put(addrJO.Id, addrJO.Contact_Address_ref_gne__r);
                }
            }
        }
    
            Boolean firstAddress = true;
            String currentInvestigatorId = String.valueOf(trialWrapper.innerObject.get('Investigator_ref_gne__c'));
            CFAR_Contact_gne__c selectedInvestigator = [SELECT Id, Primary_Role_Function_gne__c FROM CFAR_Contact_gne__c WHERE Id =:currentInvestigatorId ];
            if(CFAR_Team_Controller.isExternalRole(selectedInvestigator.Primary_Role_Function_gne__c) == false && addrSelectOptions.size() > 1)
            {
                for(SelectOption option : addrSelectOptions)
                    if(firstAddress)
                        selAddr = option.getValue();
                firstAddress = false;
            }       

        return addrSelectOptions;
    }

    public void investigatorChange() {
        selAddr = null;
        selAddrType = null;
    }

    public Id selAddrType {get; set;}
    public Id selPIGneSupport {get; set;}
    
    public List<SelectOption> getGneSupportSelectOptions() {
        List<SelectOption> selectOptions = new List<SelectOption>();

        for (CFAR_Dollar_and_Drug_gne__c drg : CFAR_DAO.getDollarAndDrugActive()) {
            selectOptions.add(new SelectOption(drg.Id, drg.Name));
        }                 
        return selectOptions;
    } 

    public List<SelectOption> getContactAddressTypeOptions() {
        List<SelectOption> addrTypeSelectOptions = new List<SelectOption>();
        addrTypeSelectOptions.add(new SelectOption('', '--None--'));
        if (selAddr == null) {
            selAddrType = null;
        } else {
            Id tmpAddrType;
            try{
            tmpAddrType = addresses.get(selAddr).Address_Type_ref_gne__c;
            }catch(Exception e){}
            if (selAddrType == null || tmpAddrType == null) {
                selAddrType = tmpAddrType;
            }
            if(addresses.size()>0){
                addrTypeSelectOptions.clear();
                for (CFAR_Address_Type_gne__c addressType : addressTypes) {
                    addrTypeSelectOptions.add(new SelectOption(addressType.Id, addressType.Name));
                }
            }
        }
        CFAR_Contact_Address_gne__c[] contactAddress = [SELECT Address_Type_ref_gne__c FROM CFAR_Contact_Address_gne__c WHERE Id  = :selAddr];
        if (contactAddress.size() > 0)
            selAddrType = contactAddress[0].Address_Type_ref_gne__c;
        return addrTypeSelectOptions;
    }

    private List<CFAR_Address_Type_gne__c> addressTypes;
    private void fillAddressTypes(){
        addressTypes = CFAR_DAO.getAddressTypes(new CFAR_SearchParameters());
    }

    public boolean getIsExternalInvestigatorRole() {
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        String investigatorId = (String) trialWrapper.innerObject.get('Investigator_ref_gne__c');
        if (String.isNotBlank(investigatorId)) {
            searchParms.andEqualsParameters.put('ID', investigatorId);
            CFAR_Contact_gne__c investigator = CFAR_DAO.getContacts(searchParms).get(0);
            return CFAR_Team_Controller.isExternalRole(investigator.Primary_Role_Function_gne__c);
        }
        return false;
    }
    
}